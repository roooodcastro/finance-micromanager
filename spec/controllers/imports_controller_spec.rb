# frozen_string_literal: true

RSpec.describe ImportsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
    allow(Current).to receive_messages(profile:)
  end

  describe 'GET index', :travel_to_now do
    subject(:index_request) { get :index, format: }

    let!(:import_a) { create(:import, profile:) }
    let!(:import_b) { create(:import, profile:) }

    let(:expected_props) do
      {
        'imports' => array_including(
          CamelizeProps.call(import_a.as_json),
          CamelizeProps.call(import_b.as_json)
        )
      }
    end

    before { index_request }

    context 'when the format is HTML', :inertia do
      let(:format) { :html }

      it 'renders the index component' do
        expect_inertia.to render_component('imports/Index')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end

    context 'when the format is JSON' do
      let(:format) { :json }

      it 'renders the imports as json' do
        expect(json_response).to match(expected_props)
      end
    end
  end

  describe 'GET show', :inertia, :travel_to_now do
    subject(:show_request) { get :show, params: { id: import.id } }

    context 'when the import is in progress' do
      let!(:import) { create(:import, :ptsb, :in_progress, profile:) }
      let(:expected_props) { CamelizeProps.call(import_object: import.as_json) }

      before do
        create(:import_transaction, import:).tap { |it| it.matches = [] }
        create(:import_transaction, import:).tap { |it| it.matches = [] }
      end

      it 'renders the preview component' do
        show_request
        expect_inertia.to render_component('imports/Preview')
        expect(inertia.props.deep_stringify_keys).to include(CamelizeProps.call(expected_props))
      end
    end

    context 'when the import is finished' do
      let!(:import) { create(:import, :ptsb, :finished, profile:) }

      let(:expected_props) { { 'importObject' => CamelizeProps.call(import.as_json) } }

      it 'renders the show component' do
        show_request
        expect_inertia.to render_component('imports/Show')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end

    context 'when the import is cancelled' do
      let!(:import) { create(:import, :ptsb, :cancelled, profile:) }

      let(:expected_props) { { 'importObject' => CamelizeProps.call(import.as_json) } }

      it 'renders the show component' do
        show_request
        expect_inertia.to render_component('imports/Show')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: { import: params } }

    let(:source_file) { fixture_file_upload('n26.csv', 'text/csv') }
    let(:source) { Import.sources[:n26] }
    let(:wallet) { create(:wallet, profile:) }

    context 'when parameters are present and valid for an import' do
      let(:params) { { source_file: source_file, source: source, wallet_id: wallet.id } }

      it 'creates a new import and renders json' do
        expect { create_request }.to change { Import.count }.by(1)
        expected_json = {
          'message'  => 'File was successfully uploaded, import started.',
          'importId' => Import.last.id
        }
        expect(json_response).to eq(CamelizeProps.call(expected_json))
      end
    end

    context 'when the import cannot be created' do
      let(:params) { { source_file: source_file, source: source, wallet_id: nil } }

      let(:expected_json) do
        { 'message' => 'Import could not be started: Wallet must exist' }
      end

      it 'does not create a new import and renders json error' do
        expect { create_request }.to not_change { Import.count }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'PATCH update', :aggregate_errors do
    subject(:update_request) { patch :update, params: { id: import.id } }

    let(:import) { create(:import, :ptsb, :in_progress, profile:) }
    let(:category) { create(:category, profile:) }
    let(:subcategory) { create(:subcategory, category:) }

    before do
      allow(Current).to receive_messages(user:, profile:)
    end

    context 'when a transaction is to be imported' do
      let!(:import_transaction) do
        create(
          :import_transaction,
          import:               import,
          wallet:               import.wallet,
          name:                 'Tesco',
          original_import_name: 'CNC TESCO STORES 03/05 1',
          amount:               -15.25,
          transaction_date:     '2023-05-03',
          action:               :import,
          category:             category,
          subcategory:          subcategory
        )
      end

      it 'imports the transaction and marks the import as complete' do
        expect { update_request }
          .to change { Transaction.count }
          .by(1)
          .and change { import.reload.status }
          .to('finished')

        new_transaction = Transaction.last
        expect(new_transaction.name).to eq('Tesco')
        expect(new_transaction.raw_import_name).to eq('CNC TESCO STORES 03/05 1')
        expect(new_transaction.amount.to_f).to eq(-15.25)
        expect(new_transaction.transaction_date).to eq(Date.parse('2023-05-03'))
        expect(new_transaction.category_id).to eq(category.id)
        expect(new_transaction.subcategory_id).to eq(subcategory.id)
        expect(new_transaction.created_by).to eq(user)
        expect(new_transaction.updated_by).to eq(user)
        expect(new_transaction.import_id).to eq(import.id)
        expect(new_transaction.import_preview_id).to eq(import_transaction.id)
        expect(new_transaction.wallet).to eq(import.wallet)
        expect(new_transaction.profile).to eq(profile)
      end
    end

    context 'when a transaction is to be skipped' do
      before do
        create(
          :import_transaction,
          import:               import,
          wallet:               import.wallet,
          name:                 'Tesco',
          original_import_name: 'CNC TESCO STORES 03/05 1',
          amount:               -15.25,
          transaction_date:     '2023-05-03',
          action:               'skip',
          category:             category,
          subcategory:          subcategory
        )
      end

      it 'does not import the transaction and marks the import as complete' do
        expect { update_request }
          .to not_change { Transaction.count }
          .and change { import.reload.status }
          .to('finished')
      end
    end

    context 'when a transaction is to be matched' do
      let!(:existing_transaction) { create(:transaction, profile: profile, wallet: import.wallet) }

      let!(:import_transaction) do
        create(
          :import_transaction,
          import:               import,
          wallet:               import.wallet,
          name:                 'Tesco',
          original_import_name: 'CNC TESCO STORES 03/05 1',
          amount:               -15.25,
          transaction_date:     '2023-05-03',
          action:               'match',
          match_transaction_id: existing_transaction.id,
          category_id:          existing_transaction.category_id
        )
      end

      it 'updates the existing transaction and marks the import as complete' do
        expect { update_request }
          .to not_change { Transaction.count }
          .and change { import.reload.status }
          .to('finished')

        expect(existing_transaction.reload.name).to eq('Tesco')
        expect(existing_transaction.raw_import_name).to eq('CNC TESCO STORES 03/05 1')
        expect(existing_transaction.amount.to_f).to eq(-15.25)
        expect(existing_transaction.transaction_date).to eq(Date.parse('2023-05-03'))
        expect(existing_transaction.updated_by).to eq(user)
        expect(existing_transaction.import_id).to eq(import.id)
        expect(existing_transaction.import_preview_id).to eq(import_transaction.id)
        expect(existing_transaction.wallet).to eq(import.wallet)
        expect(existing_transaction.profile).to eq(profile)
      end
    end

    context 'when a transaction is to be blocked' do
      before do
        create(
          :import_transaction,
          import:               import,
          wallet:               import.wallet,
          name:                 'Tesco',
          original_import_name: 'CNC TESCO STORES 03/05 1',
          amount:               -15.25,
          transaction_date:     '2023-05-03',
          action:               'block',
          category:             category,
          subcategory:          subcategory
        )
      end

      it 'does not import the transaction and marks the import as complete' do
        expect { update_request }
          .to not_change { Transaction.count }
          .and change { import.reload.status }
          .to('finished')
      end
    end

    context 'when the transaction to be imported is invalid' do
      before do
        create(
          :import_transaction,
          import:               import,
          wallet:               import.wallet,
          name:                 'Tesco',
          original_import_name: 'CNC TESCO STORES 03/05 1',
          amount:               -15.25,
          transaction_date:     '2023-05-03',
          action:               'import',
          category_id:          nil
        )
      end

      it 'does not import the transaction' do
        expect { update_request }
          .to not_change { Transaction.count }
          .and change { import.reload.status }
          .to('finished')
      end
    end

    context 'when transaction to be imported is older than last reconciliation date' do
      before do
        create(
          :import_transaction,
          import:               import,
          wallet:               import.wallet,
          name:                 'Tesco',
          original_import_name: 'CNC TESCO STORES 03/05 1',
          amount:               -15.25,
          transaction_date:     '2023-05-03',
          action:               'import',
          category:             category,
          subcategory:          subcategory
        )

        create(:reconciliation, :finished, profile: profile, date: '2024-01-01')
        profile.reload
      end

      it 'does not import the transaction' do
        expect { update_request }
          .to not_change { Transaction.count }
          .and change { import.reload.status }
          .to('finished')
      end
    end

    context 'when two transactions from different months are to be imported' do
      before do
        create(
          :import_transaction,
          import:               import,
          wallet:               import.wallet,
          name:                 'Tesco',
          original_import_name: 'CNC TESCO STORES 03/05 1',
          amount:               -15.25,
          transaction_date:     '2023-05-03',
          action:               'import',
          category:             category
        )

        create(
          :import_transaction,
          import:               import,
          wallet:               import.wallet,
          name:                 'Costa Café',
          original_import_name: 'COSTA',
          transaction_date:     '2023-06-01',
          amount:               -5.65,
          action:               'import',
          category:             category
        )

        allow(Budgets::UpdateBudgetInstancesAmountsService).to receive(:call)
      end

      it 'imports the transactions and calls the budget recalculator passing the 2 reference dates' do
        expect(Budgets::UpdateBudgetInstancesAmountsService).not_to receive(:call).with(import.profile)
        expect(Budgets::UpdateBudgetInstancesAmountsService)
          .to receive(:call)
          .with(import.profile, [Date.parse('2023-05-03'), Date.parse('2023-06-01')])

        expect { update_request }.to change { Transaction.count }.by(2)
      end
    end

    context 'when an unexpected error occurs' do
      before do
        create(
          :import_transaction,
          import:               import,
          wallet:               import.wallet,
          name:                 'Tesco',
          original_import_name: 'CNC TESCO STORES 03/05 1',
          amount:               -15.25,
          transaction_date:     '2023-05-03',
          action:               'import',
          category:             category,
          subcategory:          subcategory
        )

        allow(TransactionImports::ImportActions::ImportTransaction)
          .to receive(:execute!)
          .and_raise(ActiveRecord::ActiveRecordError)
      end

      it 'does not import the transaction and does not update the import entity' do
        expect { update_request }
          .to not_change { Transaction.count }
          .and not_change { import.reload.status }
      end
    end
  end

  describe 'DELETE destroy', :aggregate_errors do
    subject(:destroy_request) { delete :destroy, params: { id: import.id } }

    context 'when the import is in progress' do
      let!(:import) { create(:import, :ptsb, profile:) }

      it 'sets the import status as cancelled' do
        expect { destroy_request }.to change { import.reload.status }.to('cancelled')
        expect(flash[:success]).to eq('Import was successfully cancelled.')
        expect(response).to redirect_to(import_path(import.id))
      end
    end

    context 'when the import is already finished' do
      let!(:import) { create(:import, :finished, :ptsb, profile:) }

      it 'does not change the status' do
        expect { destroy_request }.not_to change { import.reload.status }
        expect(flash[:error]).to eq('Cannot cancel this import because it has already been finished.')
        expect(response).to redirect_to(import_path(import.id))
      end
    end
  end
end

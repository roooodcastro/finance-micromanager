# frozen_string_literal: true

RSpec.describe ReconciliationsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
    allow(Current).to receive(:profile).and_return(profile)
  end

  describe 'GET index' do
    let!(:reconciliation) { create(:reconciliation, profile:) }

    context 'when the format is HTML', :inertia do
      it 'renders the index component' do
        get :index, format: :html

        expect_inertia.to render_component('reconciliations/Index')
                      .and include_camelized_props({ reconciliations: [reconciliation.as_json] })
      end
    end

    context 'when the format is JSON' do
      let(:expected_props) { CamelizeProps.call('reconciliations' => [reconciliation.as_json]) }

      it 'renders the reconciliations as json' do
        get :index, format: :json

        expect(json_response).to match(hash_including(expected_props))
      end
    end
  end

  describe 'GET show' do
    subject(:show) { get :show, params: { id: reconciliation.id }, format: request_format }

    let!(:reconciliation) { create(:reconciliation, profile:) }

    context 'when the format is HTML', :inertia do
      let(:request_format) { :html }
      let(:expected_props) { { reconciliation: reconciliation.as_json } }

      it 'renders the show component' do
        show
        expect_inertia.to render_component('reconciliations/Show').and include_camelized_props(expected_props)
      end
    end

    context 'when the format is JSON' do
      let(:request_format) { :json }
      let(:query_wallet_balances) { [ReconciliationWalletBalancesQuery::WalletBalance.new('wallet_id', 12_345, 'eur')] }
      let(:expected_wallet_balances) { { 'wallet_id' => 123.45 } }
      let(:expected_props) do
        CamelizeProps.call(
          reconciliation:  reconciliation.as_json,
          wallet_balances: expected_wallet_balances
        )
      end

      before do
        allow(ReconciliationWalletBalancesQuery)
          .to receive(:run)
          .with(reconciliation_id: reconciliation.id)
          .and_return(query_wallet_balances)
      end

      it 'renders the reconciliations as json' do
        show
        expect(json_response).to eq(expected_props)
      end
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: { reconciliation: params } }

    let(:params) { { date: } }

    context 'when the date is present and valid' do
      let(:date) { 1.day.ago.to_date }

      let(:expected_json) do
        {
          'message'        => "Reconciliation for #{I18n.l(date)} was successfully started.",
          'reconciliation' => Reconciliation.last.as_json
        }
      end

      it 'creates a new reconciliation and renders json' do
        expect { create_request }.to change { Reconciliation.count }.by(1)
        expect(json_response).to eq(CamelizeProps.call(expected_json))
      end
    end

    context 'when the reconciliation cannot be started' do
      let(:date) { 1.day.ago.to_date }

      let(:expected_json) do
        {
          'message' => "Reconciliation for #{I18n.l(date)} could not be started: Date has to be newer than the date " \
                       'from the last finished reconciliation'
        }
      end

      before { create(:reconciliation, :finished, profile: profile, date: 1.day.ago.to_date) }

      it 'does not create a new reconciliation and renders json error' do
        expect { create_request }.to not_change { Reconciliation.count }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'PATCH update' do
    subject(:update_request) { patch :update, params: { id: reconciliation.id, reconciliation: params } }

    let(:params) { { date: new_date } }
    let(:reconciliation) { create(:reconciliation, profile: profile, date: Date.current) }

    context 'when the date is present and valid' do
      let(:new_date) { 1.day.from_now.to_date }

      let(:expected_json) { { 'message' => "Reconciliation for #{I18n.l(new_date)} was successfully updated." } }

      it 'updates the reconciliation and renders json' do
        expect { update_request }.to change { reconciliation.reload.date }.to(new_date)
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when the reconciliation cannot be updated' do
      let(:new_date) { 1.day.from_now.to_date }
      let(:reconciliation) { create(:reconciliation, :cancelled, profile:) }

      let(:expected_json) do
        {
          'message' => "Reconciliation for #{I18n.l(new_date)} could not be updated: This reconciliation has been " \
                       'cancelled. Further changes to it are not possible'
        }
      end

      before { create(:reconciliation, :finished, profile: profile, date: 1.day.ago.to_date) }

      it 'does not update the reconciliation and renders json error' do
        expect { update_request }.to not_change { reconciliation.reload.date }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'PATCH finish' do
    subject(:finish_request) { patch :finish, params: { id: reconciliation.id } }

    let(:reconciliation) { create(:reconciliation, profile:) }

    context 'when the reconciliation can be finished' do
      let(:expected_json) do
        {
          'message' => "Reconciliation for #{I18n.l(reconciliation.date)} has been successfully finalised. No " \
                       'balance difference was detected.'
        }
      end

      it 'finalised the reconciliation and renders json' do
        expect { finish_request }.to change { reconciliation.reload.status }.to('finished')
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when the reconciliation cannot be updated' do
      let(:reconciliation) { create(:reconciliation, :cancelled, profile:) }

      let(:expected_json) do
        {
          'message' => "Reconciliation for #{I18n.l(reconciliation.date)} could not be finalised: " \
                       'This reconciliation has been cancelled. Further changes to it are not possible'
        }
      end

      before { create(:reconciliation, :finished, profile: profile, date: 1.day.ago.to_date) }

      it 'does not finish the reconciliation and renders json error' do
        expect { finish_request }.to not_change { reconciliation.reload.status }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:destroy) { delete :destroy, params: { id: reconciliation.id } }

    context 'when the cancellation works' do
      let(:reconciliation) { create(:reconciliation, :in_progress, profile:) }
      let(:expected_json) do
        { 'message' => "Reconciliation for #{I18n.l(1.day.ago.to_date)} was successfully cancelled." }
      end

      it 'changes the status to cancelled and renders json' do
        expect { destroy }.to change { reconciliation.reload.status }.to('cancelled')
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when the reconciliation cannot be cancelled' do
      let(:reconciliation) { create(:reconciliation, :finished, profile:) }

      let(:expected_json) do
        {
          'message' => "Reconciliation for #{I18n.l(1.day.ago.to_date)} could not be cancelled: This reconciliation " \
                       'is already finished. Further changes to it are not possible'
        }
      end

      it 'does not change the status and renders json error' do
        expect { destroy }.to not_change { reconciliation.reload.status }
        expect(json_response).to eq(expected_json)
      end
    end
  end
end

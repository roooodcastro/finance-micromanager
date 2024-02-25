# frozen_string_literal: true

RSpec.describe ImportsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
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

    before { show_request }

    context 'when the import is in progress' do
      let!(:import) { create(:import, :in_progress, profile:) }

      let(:expected_props) do
        {
          'importObject' => CamelizeProps.call(import.as_json)
        }
      end

      it 'renders the preview component' do
        expect_inertia.to render_component('imports/Preview')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end

    context 'when the import is finished' do
      let!(:import) { create(:import, :finished, profile:) }

      let(:expected_props) { { 'importObject' => CamelizeProps.call(import.as_json) } }

      it 'renders the show component' do
        expect_inertia.to render_component('imports/Show')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end

    context 'when the import is cancelled' do
      let!(:import) { create(:import, :cancelled, profile:) }

      let(:expected_props) { { 'importObject' => CamelizeProps.call(import.as_json) } }

      it 'renders the show component' do
        expect_inertia.to render_component('imports/Show')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: { import: params } }

    let(:source_file) { fixture_file_upload('n26.csv', 'text/csv') }
    let(:source) { Import.sources.values.sample }
    let(:wallet) { create(:wallet, profile:) }

    context 'when parameters are present and valid for an import' do
      let(:params) { { source_file: source_file, source: source, wallet_id: wallet.id } }

      let(:expected_json) { { 'message' => 'File was successfully uploaded, import started.' } }

      it 'creates a new import and renders json' do
        expect { create_request }.to change { Import.count }.by(1)
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
end

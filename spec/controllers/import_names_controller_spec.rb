# frozen_string_literal: true

RSpec.describe ImportNamesController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
  end

  describe 'GET index' do
    subject(:index_request) { get :index, format: }

    let!(:import_name_a) { create(:import_name, profile:) }
    let!(:import_name_b) { create(:import_name, profile:) }

    let(:expected_props) do
      {
        'importNames' => array_including(
          CamelizeProps.call(import_name_a.as_json),
          CamelizeProps.call(import_name_b.as_json)
        ),
        'pagination'  => {
          'count' => 2, 'from' => 1, 'to' => 2, 'limit' => 25, 'page' => 1, 'pages' => 1, 'series' => ['1']
        }
      }
    end

    before { index_request }

    context 'when the format is HTML', :inertia do
      let(:format) { :html }

      it 'renders the index component' do
        expect_inertia.to render_component('import_names/Index')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end

    context 'when the format is JSON' do
      let(:format) { :json }

      it 'renders the import_names as json' do
        expect(json_response).to match(expected_props)
      end
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: { import_name: params } }

    context 'when parameters are present and valid for a custom rule automation' do
      let(:params) { { import_name: 'NETFLIX_CARD', transaction_name: 'Netflix' } }

      let(:expected_json) { { 'message' => 'Import Name was successfully created.' } }

      it 'creates a new import_name and renders json' do
        expect { create_request }.to change { ImportName.count }.by(1)
        expect(json_response).to eq(CamelizeProps.call(expected_json))
      end
    end

    context 'when the import_name cannot be created' do
      let(:params) { { transaction_name: 'Netflix' } }

      let(:expected_json) do
        { 'message' => 'Import Name could not be created: Import name can\'t be blank' }
      end

      it 'does not create a new import name and renders json error' do
        expect { create_request }.to not_change { ImportName.count }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'PATCH update' do
    subject(:update_request) do
      patch :update, params: { id: import_name.id, import_name: params }
    end

    let(:import_name) { create(:import_name, profile:) }

    context 'when the new name is present and valid' do
      let(:params) { { transaction_name: 'New Name' } }

      let(:expected_json) { { 'message' => 'Import Name was successfully updated.' } }

      it 'updates the import name and renders json' do
        expect { update_request }.to change { import_name.reload.transaction_name }.to('New Name')
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when the import name cannot be updated' do
      let(:params) { { transaction_name: nil } }

      let(:expected_json) do
        { 'message' => 'Import Name could not be updated: Transaction name can\'t be blank' }
      end

      it 'does not update the import name and renders json error' do
        expect { update_request }.to not_change { import_name.reload.transaction_name }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'DELETE destroy', :travel_to_now do
    subject(:destroy_request) do
      delete :destroy, params: { id: import_name.id }
    end

    let!(:import_name) { create(:import_name, profile:) }
    let(:expected_json) { { 'message' => 'Import Name was successfully removed.' } }

    it 'disables the import name and renders json' do
      expect { destroy_request }.to change { ImportName.count }.by(-1)
      expect(json_response).to eq(expected_json)
    end
  end
end

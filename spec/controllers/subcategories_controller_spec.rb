# frozen_string_literal: true

RSpec.describe SubcategoriesController, :travel_to_now do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }
  let(:category) { create(:category, profile: profile, name: 'MyCat') }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
  end

  describe 'GET index' do
    let!(:subcategory) { create(:subcategory, category:) }

    let(:expected_props) { CamelizeProps.call(category: category.as_json, subcategories: [subcategory.as_json]) }

    it 'renders the subcategories as json' do
      get :index, params: { category_id: category.id }

      expect(json_response).to eq(expected_props)
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: }

    context 'when params are valid' do
      let(:params) { { category_id: category.id, subcategory: { name: 'Test' } } }

      let(:expected_json) do
        CamelizeProps.call(
          'subcategories' => [Subcategory.first.as_json],
          'message'       => "Subcategory \"#{Subcategory.first.display_name}\" was successfully created."
        )
      end

      it 'creates the new subcategory and renders json' do
        expect { create_request }.to change { Subcategory.count }.by(1)

        expect(json_response).to eq(expected_json)
      end
    end

    context 'when params are invalid' do
      let(:params) { { category_id: category.id, subcategory: { name: '' } } }

      let(:expected_json) do
        CamelizeProps.call(
          'subcategory' => Subcategory.new(category: category, name: '').as_json,
          'message'     => 'Subcategory could not be created: Name can\'t be blank'
        )
      end

      it 'does not create a new subcategory' do
        expect { create_request }.not_to change { Subcategory.count }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'PATCH update' do
    subject(:update_request) { patch :update, params: }

    let!(:subcategory) { create(:subcategory, category: category, name: 'ThisSub') }

    let(:expected_json) do
      CamelizeProps.call(
        'subcategories' => [subcategory.reload.as_json],
        'message'       => "Subcategory \"#{subcategory.display_name}\" was successfully updated."
      )
    end

    context 'when params are valid' do
      let(:params) { { category_id: category.id, id: subcategory.id, subcategory: { name: 'New Name' } } }

      it 'updates the category' do
        expect { update_request }.to not_change { Category.count }.and change { subcategory.reload.name }.to('New Name')

        expect(json_response).to eq(expected_json)
      end
    end

    context 'when params are invalid' do
      let(:params) { { category_id: category.id, id: subcategory.id, subcategory: { name: '' } } }

      let(:expected_json) do
        CamelizeProps.call(
          'message'     => "Subcategory \"ThisSub\" could not be updated: Name can't be blank",
          'subcategory' => subcategory.as_json.merge(name: '', display_name: 'MyCat/')
        )
      end

      it 'does not update the subcategory' do
        expect { update_request }.to not_change { Subcategory.count }.and not_change { subcategory.reload.name }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'DELETE destroy', :travel_to_now do
    subject(:delete_request) { delete :destroy, params: { category_id: category.id, id: subcategory.id } }

    let!(:subcategory) { create(:subcategory, category:) }
    let!(:other_subcategory) { create(:subcategory, category:) }
    let(:expected_json) do
      {
        'category'      => category.as_json,
        'subcategories' => [other_subcategory.as_json],
        'message'       => "Subcategory \"#{subcategory.display_name}\" was successfully disabled."
      }
    end

    it 'disabled the subcategory and renders json' do
      expect { delete_request }
        .to not_change { Subcategory.count }
        .and change { subcategory.reload.disabled_at }
        .to(Time.current)
        .and change { subcategory.disabled_by }
        .to(user)

      expect(json_response).to eq(CamelizeProps.call(expected_json))
    end
  end

  describe 'PATCH reenable' do
    subject(:reenable_request) { patch :reenable, params: { category_id: category.id, id: subcategory.id } }

    let!(:subcategory) { create(:subcategory, :disabled, category:) }
    let!(:other_subcategory) { create(:subcategory, category:) }
    let(:expected_json) do
      {
        'category'      => category.as_json,
        'subcategories' => [subcategory.as_json, other_subcategory.as_json],
        'message'       => "Subcategory \"#{subcategory.display_name}\" was successfully re-enabled."
      }
    end

    it 'disabled the subcategory and renders json' do
      expect { reenable_request }
        .to not_change { Subcategory.count }
        .and change { subcategory.reload.disabled_at }
        .to(nil)
        .and change { subcategory.disabled_by }
        .to(nil)

      expect(json_response).to eq(CamelizeProps.call(expected_json))
    end
  end
end

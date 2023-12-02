# frozen_string_literal: true

RSpec.describe SubcategoriesController do
  let(:user) { create(:user) }
  let(:wallet) { create(:wallet, user:) }
  let(:category) { create(:category, wallet:) }

  before do
    sign_in user
    session[:current_wallet_id] = wallet.id
  end

  describe 'GET index', :inertia do
    let!(:subcategory) { create(:subcategory, category:) }

    let(:expected_props) { CamelizeProps.call(category: category.as_json, subcategories: [subcategory.as_json]) }

    it 'renders the subcategories as json' do
      get :index, params: { category_id: category.id }

      expect(json_response).to eq(expected_props)
    end
  end

  describe 'GET new', :inertia do
    let(:expected_props) do
      CamelizeProps.call(category: category.as_json, subcategory: Subcategory.new(category_id: category.id).as_json)
    end

    it 'renders the new component' do
      get :new, params: { category_id: category.id }

      expect_inertia.to render_component('subcategories/New').and include_props(expected_props.deep_stringify_keys)
    end
  end

  describe 'GET edit', :inertia do
    let!(:subcategory) { create(:subcategory, category:) }

    let(:expected_props) { CamelizeProps.call(category: category.as_json, subcategory: subcategory.as_json) }

    it 'renders the edit component' do
      get :edit, params: { category_id: category.id, id: subcategory.id }

      expect_inertia.to render_component('subcategories/Edit').and include_props(expected_props)
    end
  end

  describe 'POST create', :inertia do
    subject(:create_request) { post :create, params: }

    context 'when params are valid' do
      let(:params) { { category_id: category.id, subcategory: { name: 'Test' } } }

      it 'creates the new subcategory' do
        expect { create_request }.to change { Subcategory.count }.by(1)

        expect(response).to redirect_to(category_path(category.id))
        expect(Subcategory.last.name).to eq('Test')
        expect(Subcategory.last.category).to eq(category)
      end
    end

    context 'when params are invalid' do
      let(:params) { { category_id: category.id, subcategory: { name: '' } } }

      let(:expected_props) do
        CamelizeProps.call(
          category:    category.as_json,
          subcategory: Subcategory.new(category: category, name: '').as_json
        )
      end

      it 'does not create a new subcategory' do
        expect { create_request }.not_to change { Subcategory.count }
        expect_inertia.to render_component('subcategories/New').and include_props(expected_props)
      end
    end
  end

  describe 'PATCH update', :inertia do
    subject(:update_request) { patch :update, params: }

    let!(:subcategory) { create(:subcategory, category:) }

    context 'when params are valid' do
      let(:params) { { category_id: category.id, id: subcategory.id, subcategory: { name: 'New Name' } } }

      it 'updates the category' do
        expect { update_request }.to not_change { Category.count }.and change { subcategory.reload.name }.to('New Name')

        expect(response).to redirect_to(category_path(category.id))
      end
    end

    context 'when params are invalid' do
      let(:params) { { category_id: category.id, id: subcategory.id, subcategory: { name: '' } } }

      let(:expected_props) do
        CamelizeProps.call(category: category.as_json, subcategory: subcategory.as_json.merge(name: ''))
      end

      it 'does not update the subcategory' do
        expect { update_request }.to not_change { Subcategory.count }.and not_change { subcategory.reload.name }
        expect_inertia.to render_component('subcategories/Edit').and include_props(expected_props)
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
end

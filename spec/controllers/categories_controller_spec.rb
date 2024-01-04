# frozen_string_literal: true

RSpec.describe CategoriesController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
  end

  describe 'GET index' do
    subject(:index_request) { get :index, format: }

    let!(:category) { create(:category, profile:) }

    context 'for a HTML request', :inertia do
      let(:format) { :html }

      it 'renders the index component' do
        index_request

        expect_inertia.to render_component('categories/Index')
                      .and include_props({ categories: [CamelizeProps.call(category.as_json)] })
      end
    end

    context 'for a JSON request' do
      let(:format) { :json }

      it 'renders the categories as json' do
        index_request

        expect(json_response).to eq({ 'categories' => [CamelizeProps.call(category.as_json)] })
      end
    end
  end

  describe 'GET show', :inertia do
    subject(:show_request) { get :show, format: format, params: { id: category.id } }

    let!(:category) { create(:category, profile:) }

    before do
      allow(CategorySerializer)
        .to receive(:new)
        .with(category)
        .and_return(instance_double(CategorySerializer, as_json: 'serializer_json'))
    end

    context 'for a HTML request', :inertia do
      let(:format) { :html }

      it 'renders the show component' do
        show_request

        expect_inertia.to render_component('categories/Show').and include_props({ category: 'serializer_json' })
      end
    end

    context 'for a JSON request' do
      let(:format) { :json }

      it 'renders the category as json' do
        show_request

        expect(json_response).to eq({ 'category' => 'serializer_json' })
      end
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: }

    context 'when params are valid' do
      let(:params) { { category: { name: 'Test', color: '#FF00FF' } } }

      it 'creates the new category' do
        expect { create_request }.to change { Category.count }.by(1)

        expect(json_response).to eq({ 'message' => 'Category "Test" was successfully created.' })
        expect(Category.last.name).to eq('Test')
        expect(Category.last.color).to eq('#FF00FF')
        expect(Category.last.profile).to eq(profile)
      end
    end

    context 'when params are invalid' do
      let(:params) { { category: { name: 'Test', color: '#invalid' } } }

      it 'does not create a new category' do
        expect { create_request }.not_to change { Category.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq({ 'message' => 'Category could not be created: Color is invalid' })
      end
    end
  end

  describe 'PATCH update', :inertia do
    subject(:update_request) { patch :update, params: }

    let!(:category) { create(:category, profile: profile, name: 'Test') }

    context 'when params are valid' do
      let(:params) { { id: category.id, category: { name: 'New Name', color: '#FF00FF' } } }

      it 'updates the category' do
        expect { update_request }.not_to change { Category.count }

        expect(json_response).to eq({ 'message' => 'Category "New Name" was successfully updated.' })
        expect(Category.last.name).to eq('New Name')
        expect(Category.last.color).to eq('#FF00FF')
      end
    end

    context 'when params are invalid' do
      let(:params) { { id: category.id, category: { color: '#invalid' } } }

      it 'does not update the category' do
        expect { update_request }.not_to change { Category.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq({ 'message' => 'Category "Test" could not be updated: Color is invalid' })
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:delete_request) { delete :destroy, params: { id: category.id } }

    let!(:category) { create(:category, profile:) }

    it 'destroys the category and renders json' do
      expect { delete_request }
        .to not_change { Category.count }
        .and change { category.reload.disabled? }
        .to(true)

      expect(json_response).to eq('message' => "Category \"#{category.name}\" was successfully disabled.")
    end
  end
end

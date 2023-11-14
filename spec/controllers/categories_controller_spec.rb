# frozen_string_literal: true

RSpec.describe CategoriesController do
  let(:user) { create(:user) }
  let(:account) { create(:account, user:) }

  before do
    sign_in user
    session[:current_account_id] = account.id
  end

  describe 'GET index', :inertia do
    let!(:category) { create(:category, account:) }

    it 'renders the index component' do
      get :index

      expect_inertia.to render_component('categories/Index')
                    .and include_props({ categories: [CamelizeProps.call(category.as_json)] })
    end
  end

  describe 'GET new', :inertia do
    it 'renders the new component' do
      get :new

      expect_inertia.to render_component('categories/New')
                    .and include_props({ category: an_instance_of(Category) })
    end
  end

  describe 'GET edit', :inertia do
    let!(:category) { create(:category, account:) }

    it 'renders the edit component' do
      get :edit, params: { id: category.id }

      expect_inertia.to render_component('categories/Edit')
                    .and include_props({ category: })
    end
  end

  describe 'POST create', :inertia do
    subject(:create_request) { post :create, params: }

    context 'when params are valid' do
      let(:params) { { category: { name: 'Test', color: '#FF00FF' } } }

      it 'creates the new category' do
        expect { create_request }.to change { Category.count }.by(1)

        expect(response).to redirect_to(categories_path)
        expect(Category.last.name).to eq('Test')
        expect(Category.last.color).to eq('#FF00FF')
        expect(Category.last.account).to eq(account)
      end
    end

    context 'when params are invalid' do
      let(:params) { { category: { name: 'Test', color: '#invalid' } } }

      it 'does not create a new category' do
        expect { create_request }.not_to change { Category.count }

        expect_inertia.to render_component('categories/New')
        expect(inertia.props[:category].name).to eq 'Test'
        expect(inertia.props[:category].color).to eq '#invalid'
      end
    end
  end

  describe 'PATCH update', :inertia do
    subject(:update_request) { patch :update, params: }

    let!(:category) { create(:category, account:) }

    context 'when params are valid' do
      let(:params) { { id: category.id, category: { name: 'New Name', color: '#FF00FF' } } }

      it 'updates the category' do
        expect { update_request }.not_to change { Category.count }

        expect(response).to redirect_to(categories_path)
        expect(Category.last.name).to eq('New Name')
        expect(Category.last.color).to eq('#FF00FF')
      end
    end

    context 'when params are invalid' do
      let(:params) { { id: category.id, category: { color: '#invalid' } } }

      it 'does not create a new category' do
        expect { update_request }.not_to change { Category.count }

        expect_inertia.to render_component('categories/Edit')
        expect(inertia.props[:category].name).to eq category.name
        expect(inertia.props[:category].color).to eq '#invalid'
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:delete_request) { delete :destroy, params: { id: category.id } }

    let!(:category) { create(:category, account:) }

    it 'destroys the categroy and redirect to index' do
      expect { delete_request }.to change { Category.count }.by(-1)
      expect(response).to redirect_to categories_path
    end
  end
end

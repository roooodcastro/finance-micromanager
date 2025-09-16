# frozen_string_literal: true

class CategoriesController < AbstractAuthenticatedController
  before_action :set_category, only: %i[show update destroy reenable]

  def index
    respond_to do |format|
      format.html { render inertia: 'categories/Index' }
      format.json do
        initial_relation = Current
                           .profile
                           .categories
                           .includes(:active_subcategories)
                           .order({ category_type: :desc }, :name)

        categories = CategorySearch.new(initial_relation, search_params).search

        render json: camelize_props(categories: categories.as_json)
      end
    end
  end

  def show
    category_serializer = CategorySerializer.new(@category)

    props = camelize_props(category: category_serializer.as_json(include_summary: true))

    respond_to do |format|
      format.html { render inertia: 'categories/Show', props: props }
      format.json { render json: props }
    end
  end

  def create
    category = Current.profile.categories.new(category_params)

    if category.save
      render json: camelize_props(message: t('.success', name: category.name))
    else
      render json:   camelize_props(message: t('.error', error: category.error_messages)),
             status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)

      render json: camelize_props(message: t('.success', name: @category.name))
    else
      render json: camelize_props(
        message: t('.error', name: @category.name_was, error: @category.error_messages)
      ), status: :unprocessable_entity
    end
  end

  def destroy
    @category.disable!
    render json: { message: t('.success', name: @category.name) }
  rescue ActiveRecord::RecordInvalid
    render json: { message: t('.error', name: @category.name) }, status: :unprocessable_entity
  end

  def reenable
    @category.enable!
    render json: { message: t('.success', name: @category.name) }
  rescue ActiveRecord::RecordInvalid
    render json: { message: t('.error', name: @category.name) }, status: :unprocessable_entity
  end

  private

  def set_category
    @category = Current.profile.categories.find(params[:id])
  end

  def category_params
    expected_params = params.expect(category: %i[name color favourite category_type])
    if Category::USER_SELECTABLE_CATEGORY_TYPES.exclude?(expected_params[:category_type])
      expected_params.delete(:category_type)
    end
    expected_params
  end

  def search_params
    params.permit(%i[show_system show_disabled]).to_h.symbolize_keys
  end
end

# frozen_string_literal: true

class CategoriesController < AbstractAuthenticatedController
  before_action :set_category, only: %i[show update destroy]

  def index
    categories = Current.profile.categories.active
                        .includes(:active_subcategories).order({ category_type: :desc }, :name)

    props = camelize_props(categories: categories.as_json)

    respond_to do |format|
      format.html { render inertia: 'categories/Index', props: props }
      format.json { render json: props }
    end
  end

  def show
    category_serializer = CategorySerializer.new(@category)

    props = camelize_props(category: category_serializer.as_json(
      include_summary:             true,
      include_recent_transactions: true
    ))

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
      render json:   camelize_props(message: t('.error', error: category.errors.full_messages.join(', '))),
             status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)

      render json: camelize_props(message: t('.success', name: @category.name))
    else
      render json: camelize_props(
        message: t('.error', name: @category.name_was, error: @category.errors.full_messages.join(', '))
      ), status: :unprocessable_entity
    end
  end

  def destroy
    if @category.disable!
      render json: { message: t('.success', name: @category.name) }
    else
      render json: { message: t('.error', name: @category.name) }, status: :unprocessable_entity
    end
  end

  private

  def set_category
    @category = Current.profile.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :color)
  end
end

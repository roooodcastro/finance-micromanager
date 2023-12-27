# frozen_string_literal: true

class CategoriesController < AbstractAuthenticatedController
  before_action :set_category, only: %i[show edit update destroy]

  def index
    categories = Current.profile.categories.includes(:active_subcategories).order({ category_type: :desc }, :name)

    props = { categories: categories.as_json }

    respond_to do |format|
      format.html { render inertia: 'categories/Index', props: camelize_props(props) }
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

  def new
    category = Category.new

    render inertia: 'categories/New', props: { category: }
  end

  def edit
    render inertia: 'categories/Edit', props: { category: @category }
  end

  def create
    category = Current.profile.categories.new(category_params)

    if category.save
      redirect_to categories_path, success: t('.success')
    else
      flash.now[:error] = t('.error', error: category.errors.full_messages)
      render inertia: 'categories/New', props: { category: }
    end
  end

  def update
    if @category.update(category_params)
      flash[:success] = t('.success')
      redirect_to categories_path
    else
      flash.now[:error] = t('.error', error: @category.errors.full_messages)
      render inertia: 'categories/Edit', props: { category: @category }
    end
  end

  def destroy
    category_id = @category.id
    @category.destroy

    render json: camelize_props(category_id: category_id, message: t('.success', name: @category.name))
  end

  private

  def set_category
    @category = Current.profile.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :color)
  end
end

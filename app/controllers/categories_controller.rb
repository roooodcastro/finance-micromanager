# frozen_string_literal: true

class CategoriesController < AbstractAuthenticatedController
  include Pagy::Backend

  before_action :set_category, only: %i[edit update destroy]

  def index
    categories = Current.account.categories

    pagy, categories = pagy(categories)
    props            = { categories: categories.as_json, pagination: pagy_metadata(pagy) }

    respond_to do |format|
      format.html { render inertia: 'categories/Index', props: camelize_props(props) }
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
    category = Current.account.categories.new(category_params)

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
    @category.destroy

    redirect_to categories_url, success: t('.success')
  end

  private

  def set_category
    @category = Current.account.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :color)
  end
end

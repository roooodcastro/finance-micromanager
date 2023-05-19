# frozen_string_literal: true

class CategoriesController < AbstractAuthenticatedController
  before_action :set_category, only: %i[show edit update destroy]

  def index
    categories = Category.all

    render inertia: 'categories/Index', props: { categories: }
  end

  def show
    render inertia: 'categories/Show'
  end

  def new
    category = Category.new

    render inertia: 'categories/New', props: { category: }
  end

  def edit
    render inertia: 'categories/Edit', props: { category: @category }
  end

  def create
    category = Category.new(category_params)

    if category.save
      flash[:success] = t('.success')
      redirect_to categories_path
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
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :color).merge(account: Current.account)
  end
end

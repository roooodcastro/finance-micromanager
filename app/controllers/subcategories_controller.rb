# frozen_string_literal: true

class SubcategoriesController < AbstractAuthenticatedController
  before_action :set_category
  before_action :set_subcategory, only: %i[edit update]

  def index
    subcategories = @category.subcategories
    props         = { category: @category.as_json, subcategories: subcategories.as_json }

    respond_to do |format|
      format.html { render inertia: 'subcategories/Index', props: camelize_props(props) }
      format.json { render json: camelize_props(props) }
    end
  end

  def new
    subcategory = Subcategory.new(category_id: @category.id)
    props       = { category: @category.as_json, subcategory: subcategory.as_json }

    render inertia: 'subcategories/New', props: camelize_props(props)
  end

  def edit
    props = { category: @category.as_json, subcategory: @subcategory.as_json }

    render inertia: 'subcategories/Edit', props: camelize_props(props)
  end

  def create
    subcategory = @category.subcategories.new(subcategory_params)

    if subcategory.save
      redirect_to category_path(@category.id), success: t('.success', name: subcategory.display_name)
    else
      flash.now[:error] = t('.error', error: subcategory.errors.full_messages)
      props             = { category: @category.as_json, subcategory: subcategory.as_json }
      render inertia: 'subcategories/New', props: camelize_props(props)
    end
  end

  def update
    if @subcategory.update(subcategory_params)
      flash[:success] = t('.success', name: @subcategory.display_name)
      redirect_to category_path(@category.id)
    else
      flash.now[:error] = t('.error', name: @subcategory.display_name, error: @subcategory.errors.full_messages)
      props             = { category: @category.as_json, subcategory: @subcategory.as_json }
      render inertia: 'subcategories/Edit', props: camelize_props(props)
    end
  end

  private

  def set_category
    @category = Current.wallet.categories.find(params[:category_id])
  end

  def set_subcategory
    @subcategory = @category.subcategories.find(params[:id])
  end

  def subcategory_params
    params.require(:subcategory).permit(:name)
  end
end

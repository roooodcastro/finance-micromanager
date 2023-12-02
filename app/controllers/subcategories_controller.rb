# frozen_string_literal: true

class SubcategoriesController < AbstractAuthenticatedController
  before_action :set_category
  before_action :set_subcategory, only: %i[update destroy]

  def index
    render json: camelize_props(
      category:      @category.as_json,
      subcategories: @category.subcategories.active.as_json
    )
  end

  def create
    subcategory = @category.subcategories.new(subcategory_params)

    if subcategory.save
      render json: camelize_props(
        subcategories: @category.subcategories.active.as_json,
        message:       t('.success', name: subcategory.display_name)
      )
    else
      render json: camelize_props(
        subcategory: subcategory.as_json,
        message:     t('.error', error: subcategory.errors.full_messages.join(', '))
      ), status: :unprocessable_entity
    end
  end

  def update
    if @subcategory.update(subcategory_params)

      render json: camelize_props(
        subcategories: @category.subcategories.active.as_json,
        message:       t('.success', name: @subcategory.display_name)
      )
    else
      render json: camelize_props(
        subcategory: @subcategory.as_json,
        message:     t('.error', name: @subcategory.name_was, error: @subcategory.errors.full_messages.join(', '))
      ), status: :unprocessable_entity
    end
  end

  def destroy
    @subcategory.disable!

    render json: camelize_props(
      category:      @category.as_json,
      subcategories: @category.subcategories.active.as_json,
      message:       t('.success', name: @subcategory.display_name)
    )
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

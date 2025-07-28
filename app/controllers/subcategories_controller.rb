# frozen_string_literal: true

class SubcategoriesController < AbstractAuthenticatedController
  before_action :set_category
  before_action :set_subcategory, only: %i[update destroy reenable]

  def index
    render json: camelize_props(
      category:      @category.as_json,
      subcategories: subcategories_for_props.as_json
    )
  end

  def create
    subcategory = @category.subcategories.new(subcategory_params)

    if subcategory.save
      render json: camelize_props(
        subcategories: subcategories_for_props.as_json,
        message:       t('.success', name: subcategory.display_name)
      )
    else
      render json: camelize_props(
        subcategory: subcategory.as_json,
        message:     t('.error', error: subcategory.error_messages)
      ), status: :unprocessable_entity
    end
  end

  def update
    if @subcategory.update(subcategory_params)

      render json: camelize_props(
        subcategories: subcategories_for_props.as_json,
        message:       t('.success', name: @subcategory.display_name)
      )
    else
      render json: camelize_props(
        subcategory: @subcategory.as_json,
        message:     t('.error', name: @subcategory.name_was, error: @subcategory.error_messages)
      ), status: :unprocessable_entity
    end
  end

  def destroy
    @subcategory.disable!

    render json: camelize_props(
      category:      @category.as_json,
      subcategories: subcategories_for_props.as_json,
      message:       t('.success', name: @subcategory.display_name)
    )
  end

  def reenable
    @subcategory.enable!

    render json: camelize_props(
      category:      @category.as_json,
      subcategories: subcategories_for_props.as_json,
      message:       t('.success', name: @subcategory.display_name)
    )
  end

  private

  def subcategories_for_props
    subcategories = @category.subcategories.order(:name)
    subcategories = subcategories.active unless params[:show_disabled].to_b
    subcategories
  end

  def set_category
    @category = Current.profile.categories.find(params[:category_id])
  end

  def set_subcategory
    @subcategory = @category.subcategories.find(params[:id])
  end

  def subcategory_params
    params.expect(subcategory: [:name])
  end
end

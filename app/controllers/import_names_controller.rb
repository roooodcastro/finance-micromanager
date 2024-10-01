# frozen_string_literal: true

class ImportNamesController < AbstractAuthenticatedController
  include Pagy::Backend

  before_action :set_import_name, only: %i[update destroy]

  MAX_PAGINATION = 2**32

  def index
    import_names       = Current.profile.import_names.order(:import_name)
    pagination_limit   = params[:fetch_all] ? MAX_PAGINATION : current_pagination_limit
    pagy, import_names = pagy(import_names, limit: pagination_limit)
    props              = camelize_props(import_names: import_names.as_json, pagination: pagy_metadata(pagy))

    respond_to do |format|
      format.html { render inertia: 'import_names/Index', props: props }
      format.json { render json: props }
    end
  end

  def create
    import_name = Current.profile.import_names.new(import_name_params)

    if import_name.save
      render json: camelize_props(message: t('.success'))
    else
      error = import_name.error_messages
      render json:   camelize_props(message: t('.error', error:)),
             status: :unprocessable_entity
    end
  end

  def update
    if @import_name.update(import_name_params)
      render json: camelize_props(message: t('.success'))
    else
      error = @import_name.error_messages
      render json:   camelize_props(message: t('.error', error:)),
             status: :unprocessable_entity
    end
  end

  def destroy
    @import_name.destroy!

    render json: camelize_props(message: t('.success'))
  end

  private

  def set_import_name
    @import_name = Current.profile.import_names.find(params[:id])
  end

  def import_name_params
    params.require(:import_name).permit(:import_name, :transaction_name)
  end
end

# frozen_string_literal: true

class ImportsController < AbstractAuthenticatedController
  before_action :set_import, only: %i[show]
  def index
    imports = Current.profile.imports.order(created_at: :desc)
    props   = camelize_props(imports: imports.as_json)

    respond_to do |format|
      format.html { render inertia: 'imports/Index', props: props }
      format.json { render json: props }
    end
  end

  def show
    props = camelize_props(import_object: @import.as_json)

    if @import.in_progress?
      render inertia: 'imports/Preview', props: props
    else
      render inertia: 'imports/Show', props: props
    end
  end

  def create
    import = Current.profile.imports.new(import_params)

    if import.save
      render json: camelize_props(message: t('.success'))
    else
      error = import.errors.full_messages.join(', ')
      render json:   camelize_props(message: t('.error', error:)),
             status: :unprocessable_entity
    end
  end

  private

  def set_import
    @import = Current.profile.imports.find(params[:id])
  end

  def import_params
    params.require(:import).permit(:source, :wallet_id, :source_file)
  end
end

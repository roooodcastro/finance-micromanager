# frozen_string_literal: true

class ImportsController < AbstractAuthenticatedController
  def index
    imports = Current.profile.imports.order(created_at: :desc)
    props   = camelize_props(imports: imports.as_json)

    respond_to do |format|
      format.html { render inertia: 'imports/Index', props: props }
      format.json { render json: props }
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

  def import_params
    params.require(:import).permit(:source, :wallet_id, :file)
  end
end

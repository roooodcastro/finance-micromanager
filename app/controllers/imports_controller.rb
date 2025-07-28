# frozen_string_literal: true

class ImportsController < AbstractAuthenticatedController
  before_action :set_import, only: %i[show update destroy]
  def index
    imports = Current.profile.imports.includes(:profile, :wallet).order(created_at: :desc)
    props   = camelize_props(imports: imports.as_json)

    respond_to do |format|
      format.html { render inertia: 'imports/Index', props: props }
      format.json { render json: props }
    end
  end

  def show
    props = camelize_props(import_object: @import.as_json)

    inertia_layout = @import.in_progress? ? 'imports/Preview' : 'imports/Show'
    render inertia: inertia_layout, props: props
  end

  def create
    import = TransactionImports::ImportCreator.call(import_params)

    if import.persisted?
      render json: camelize_props(message: t('.success'), import_id: import.id)
    else
      error = import.error_messages
      render json:   camelize_props(message: t('.error', error:)),
             status: :unprocessable_entity
    end
  end

  def update
    importer = TransactionImports::Importer.new(@import)
    success  = importer.import!

    if success
      flash[:success] = t('.success')
      props           = camelize_props(importer.statistics_recorder.as_json.merge(import_object: @import.as_json))
      render inertia: 'imports/Results', props: props
    else
      flash[:error] = t('.error')
      redirect_to import_path(@import.id)
    end
  end

  def destroy
    if @import.finished?
      flash[:error] = t('.already_finished')
    else
      TransactionImports::CancelImport.call(@import)
      flash[:success] = t('.success')
    end

    redirect_to @import
  end

  private

  def set_import
    @import = Current.profile.imports.includes(:profile).find(params[:id])
  end

  def import_params
    params.expect(import: %i[source wallet_id source_file])
  end
end

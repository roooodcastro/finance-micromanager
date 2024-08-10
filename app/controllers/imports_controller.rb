# frozen_string_literal: true

class ImportsController < AbstractAuthenticatedController
  before_action :set_import, only: %i[show update destroy]
  def index
    imports = Current.profile.imports.order(created_at: :desc)
    props   = camelize_props(imports: imports.as_json)

    respond_to do |format|
      format.html { render inertia: 'imports/Index', props: props }
      format.json { render json: props }
    end
  end

  def show
    return render_preview if @import.in_progress?

    props = camelize_props(
      import_object:         @import.as_json,
      imported_transactions: @import.transactions.includes(:category, :subcategory, :wallet).as_json
    )
    render inertia: 'imports/Show', props: props
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

  def update
    importer = TransactionImports::Importer.new(@import)
    success  = importer.import!(update_import_params.to_h)

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
      return render json: camelize_props(message: t('.already_finished')), status: :unprocessable_entity
    end

    @import.cancelled!

    render json: camelize_props(message: t('.success'))
  end

  private

  def set_import
    @import = Current.profile.imports.includes(:profile).find(params[:id])
  end

  def import_params
    params.require(:import).permit(:source, :wallet_id, :source_file)
  end

  def update_import_params
    transaction_ids   = params[:transactions].keys
    permit_attributes = transaction_ids.map do |id|
      { id => %i[name transaction_date action_id category_id match_transaction_id] }
    end
    params.require(:transactions).permit(permit_attributes)
  end

  def render_preview
    props = camelize_props(import_object: @import.as_json,
                           preview_data:  TransactionImports::BaseParser.generate_preview(@import))
    render inertia: 'imports/Preview', props: props
  end
end

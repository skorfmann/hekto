class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document, only: %i[show edit update destroy]

  # GET /documents
  def index
    items_per_page = 30 # Adjust as needed
    @pagy_by_month, documents_by_month = pagy(
      current_account.documents.with_metadata,
      page_param: :page_by_month,
      items: items_per_page
    )

    @documents_by_month = documents_by_month.paginated_grouped_by_month(@pagy_by_month.page, items_per_page)

    # Uncomment to authorize with Pundit
    # authorize @documents
  end

  # GET /documents/1 or /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new

    # Uncomment to authorize with Pundit
    # authorize @document
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents or /documents.json
  def create
    @document = current_account.documents.new(document_params)
    @document.owner = current_user

    respond_to do |format|
      if @document.save
        @document.file.attach(params[:document][:file]) if params[:document][:file].present?
        # Enqueue background job for processing
        DocumentProcessingJob.perform_later(@document.id)

        format.html { redirect_to @document, notice: 'Document was successfully uploaded and is being processed.' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1 or /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        if params[:document][:file].present?
          @document.file.attach(params[:document][:file])
          # Enqueue background job for processing
          DocumentProcessingJob.perform_later(@document.id)
        end

        format.html { redirect_to @document, notice: 'Document was successfully updated and is being processed.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1 or /documents/1.json
  def destroy
    @document.destroy!
    respond_to do |format|
      format.html { redirect_to documents_url, status: :see_other, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def new_batch_upload
  end

  def create_batch_upload
    if params[:files].present?
      uploaded_count = 0
      params[:files].each do |file|
        document = current_account.documents.create(file:, owner: current_user)
        if document.persisted?
          DocumentProcessingJob.perform_later(document.id)
          uploaded_count += 1
        end
      end
      redirect_to documents_path,
                  notice: "#{uploaded_count} documents were successfully uploaded and are being processed."
    else
      redirect_to new_batch_upload_documents_path, alert: 'Please select files to upload.'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_document
    @document = current_account.documents.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @document
  rescue ActiveRecord::RecordNotFound
    redirect_to documents_path
  end

  # Only allow a list of trusted parameters through.
  def document_params
    params.require(:document).permit(:file, metadata: {})
  end
end

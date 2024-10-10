class VendorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vendor, only: [:show, :edit, :update, :destroy]

  # GET /vendors
  def index
    @pagy, @vendors = pagy(current_account.vendors.sort_by_params(params[:sort], sort_direction))

    # Uncomment to authorize with Pundit
    # authorize @vendors
  end

  # GET /vendors/1 or /vendors/1.json
  def show
  end

  # GET /vendors/new
  def new
    @vendor = Vendor.new

    # Uncomment to authorize with Pundit
    # authorize @vendor
  end

  # GET /vendors/1/edit
  def edit
  end

  # POST /vendors or /vendors.json
  def create
    @vendor = current_account.vendors.new(vendor_params)

    # Uncomment to authorize with Pundit
    # authorize @vendor

    respond_to do |format|
      if @vendor.save
        format.html { redirect_to @vendor, notice: "Vendor was successfully created." }
        format.json { render :show, status: :created, location: @vendor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vendors/1 or /vendors/1.json
  def update
    respond_to do |format|
      if @vendor.update(vendor_params)
        format.html { redirect_to @vendor, notice: "Vendor was successfully updated." }
        format.json { render :show, status: :ok, location: @vendor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vendors/1 or /vendors/1.json
  def destroy
    @vendor.destroy!
    respond_to do |format|
      format.html { redirect_to vendors_url, status: :see_other, notice: "Vendor was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_vendor
    @vendor = current_account.vendors.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @vendor
  rescue ActiveRecord::RecordNotFound
    redirect_to vendors_path
  end

  # Only allow a list of trusted parameters through.
  def vendor_params
    params.require(:vendor).permit(:name, :address, :city, :country, :metadata, :sources)

    # Uncomment to use Pundit permitted attributes
    # params.require(:vendor).permit(policy(@vendor).permitted_attributes)
  end
end

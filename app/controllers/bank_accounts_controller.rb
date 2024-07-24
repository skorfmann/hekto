class BankAccountsController < ApplicationController
  before_action :set_bank_account, only: %i[show edit update destroy]

  # GET /bank_accounts
  def index
    @pagy, @bank_accounts = pagy(current_account.bank_accounts.sort_by_params(params[:sort], sort_direction))

    # Uncomment to authorize with Pundit
    # authorize @bank_accounts
  end

  # GET /bank_accounts/1 or /bank_accounts/1.json
  def show
  end

  # GET /bank_accounts/new
  def new
    @bank_account = current_account.bank_accounts.new

    # Uncomment to authorize with Pundit
    # authorize @bank_account
  end

  # GET /bank_accounts/1/edit
  def edit
  end

  # POST /bank_accounts or /bank_accounts.json
  def create
    @bank_account = current_account.bank_accounts.new(bank_account_params)

    # Uncomment to authorize with Pundit
    # authorize @bank_account

    respond_to do |format|
      if @bank_account.save
        format.html { redirect_to @bank_account, notice: 'Bank account was successfully created.' }
        format.json { render :show, status: :created, location: @bank_account }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bank_accounts/1 or /bank_accounts/1.json
  def update
    respond_to do |format|
      if @bank_account.update(bank_account_params)
        format.html { redirect_to @bank_account, notice: 'Bank account was successfully updated.' }
        format.json { render :show, status: :ok, location: @bank_account }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_accounts/1 or /bank_accounts/1.json
  def destroy
    @bank_account.destroy!
    respond_to do |format|
      format.html do
        redirect_to bank_accounts_url, status: :see_other, notice: 'Bank account was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bank_account
    @bank_account = current_account.bank_accounts.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @bank_account
  rescue ActiveRecord::RecordNotFound
    redirect_to bank_accounts_path
  end

  # Only allow a list of trusted parameters through.
  def bank_account_params
    params.require(:bank_account).permit(:name, :number, :balance, :account_type)

    # Uncomment to use Pundit permitted attributes
    # params.require(:bank_account).permit(policy(@bank_account).permitted_attributes)
  end
end

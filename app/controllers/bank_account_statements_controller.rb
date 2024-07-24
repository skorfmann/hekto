class BankAccountStatementsController < ApplicationController
  before_action :set_bank_account
  before_action :set_bank_account_statement, only: %i[show edit update destroy]

  def index
    @pagy, @bank_account_statements = pagy(@bank_account.bank_account_statements.sort_by_params(params[:sort],
                                                                                                sort_direction))
  end

  def show
  end

  def new
    @bank_account_statement = @bank_account.bank_account_statements.new
  end

  def edit
  end

  def create
    @bank_account_statement = @bank_account.bank_account_statements.new(bank_account_statement_params)
    @bank_account_statement.account = current_account

    respond_to do |format|
      if @bank_account_statement.save
        BankStatementProcessingJob.perform_later(@bank_account_statement.id)
        format.html do
          redirect_to [@bank_account, @bank_account_statement],
                      notice: 'Bank account statement was successfully created and is being processed.'
        end
        format.json { render :show, status: :created, location: [@bank_account, @bank_account_statement] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bank_account_statement.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @bank_account_statement.update(bank_account_statement_params)
        format.html do
          redirect_to [@bank_account, @bank_account_statement],
                      notice: 'Bank account statement was successfully updated.'
        end
        format.json { render :show, status: :ok, location: [@bank_account, @bank_account_statement] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bank_account_statement.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bank_account_statement.destroy!
    respond_to do |format|
      format.html do
        redirect_to bank_account_bank_account_statements_url(@bank_account), status: :see_other,
                                                                             notice: 'Bank account statement was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  def set_bank_account
    @bank_account = current_account.bank_accounts.find(params[:bank_account_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to bank_accounts_path, alert: 'Bank account not found.'
  end

  def set_bank_account_statement
    @bank_account_statement = @bank_account.bank_account_statements.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to bank_account_bank_account_statements_path(@bank_account), alert: 'Bank account statement not found.'
  end

  def bank_account_statement_params
    params.require(:bank_account_statement).permit(:file)
  end
end

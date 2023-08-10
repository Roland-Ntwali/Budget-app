class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category

  def index
    @transactions = @category.transactions.order(created_at: :desc)
    @total_amount = @transactions.sum(:amount)
  end

  def new
    @category = Category.find(params[:category_id])
    @categories = current_user.categories
    @transaction = Transaction.new
  end

  def create
    @transaction = @category.transactions.build(transaction_params)
    @transaction.author = current_user
    @transaction.date = Date.parse(params[:transaction][:date]) unless params[:transaction][:date].nil?

    if @transaction.save
      flash[:success] = "You've just added a new expense."
      
      # Fetch the transactions again after creating the new one
      @transactions = @category.transactions.order(created_at: :desc)
      
      redirect_to category_transactions_path(@category)
    else
      flash.now[:error] = @transaction.errors.full_messages.first
      render :new
    end
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
    flash[:success] = 'Expense item has been removed.'
    redirect_to category_transactions_path(@category)
  end

  private

  def set_category
    @category = current_user.categories.find(params[:category_id])
  end

  def transaction_params
    params.require(:transaction).permit(:name, :amount, :category_id)
  end
end

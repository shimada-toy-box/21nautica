# Petty Cash Model
class PettyCash < ActiveRecord::Base
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :expense_head
  belongs_to :truck
  validates  :transaction_type, :transaction_amount, presence: true
  before_create :update_date, :update_balance
  def update_date
    self.date = Date.today.strftime('%d/%m/%Y')
  end

  def update_balance
    self.available_balance = if transaction_type.eql?('Deposit')
                               current_balance + transaction_amount
                             else
                               current_balance - transaction_amount
                             end
  end

  private

  def current_balance
    PettyCash.last.try(:available_balance).to_f
  end
end
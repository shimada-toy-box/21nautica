class AddInvoiceNumberToImportExpenses < ActiveRecord::Migration
  def change
    add_column :import_expenses, :invoice_number, :string
  end
end

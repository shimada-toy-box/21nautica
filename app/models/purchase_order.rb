class PurchaseOrder < ActiveRecord::Base
  belongs_to :supplier
  has_many :purchase_order_items

  accepts_nested_attributes_for :purchase_order_items, allow_destroy: true
  validates_presence_of :number, :date, :supplier_id
end

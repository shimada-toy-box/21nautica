#
# == Schema Information
# Table name: customers
#
#  id            :integer      not null, primary key
#  bill_number   :text
#  bill_date     :datetime
#  vendor_id     :integer
#  value         :float
#  remark        :text
#  created_by    :integer
#  created_on    :datetime
#  approved_by   :integer
class Bill < ActiveRecord::Base
  attr_accessor :bill_items_total
  belongs_to :created_by, class_name: 'User'
  belongs_to :approved_by, class_name: 'User'
  belongs_to :vendor
  has_many :bill_items
  has_many :debit_notes
  has_one :vendor_ledger, as: :voucher

  accepts_nested_attributes_for :bill_items, allow_destroy: true
  accepts_nested_attributes_for :debit_notes, allow_destroy: true

  validates_associated :bill_items

  validates_uniqueness_of :bill_number, scope: [:bill_number, :bill_date, :vendor_id]
  validates_presence_of :bill_number, :vendor_id, :bill_date, :value, :created_by

  after_save :set_bill_vendor_ledger

  def set_bill_vendor_ledger
    self.vendor_ledger.nil? ? self.create_vendor_ledger(vendor_id: vendor_id, amount: value, bill_date: bill_date) : 
      vendor_ledger.update_attributes(vendor_id: vendor_id, bill_date: bill_date, amount: value)
  end
end

class UserMailer < ActionMailer::Base
  #default from: ENV['EMAIL_FROM']
  default from: ["info@reliablefreight.co.ke"] if Rails.env == "development"

  def mail_report(customer,type)
    @customer = customer
    emails = if ENV['HOSTNAME'] == 'RFS'
               customer.emails
             else
               customer.add_default_emails_to_customer
             end
    time = DateTime.parse(Time.now.to_s).strftime("%d_%b_%Y")
    if type == 'export'
      attachments["Export_#{customer.name.tr(" ", "_")}_#{time}.xlsx"] = File.read("#{Rails.root}/tmp/#{customer.name.tr(" ", "_")}_#{time}.xlsx")
    else
      attachments["Import_#{customer.name.tr(" ", "_")}_#{time}.xlsx"] = File.read("#{Rails.root}/tmp/Imports_#{customer.name.tr(" ", "_")}_#{time}.xlsx")
    end
    mail(to: emails, subject: "Customer Update #{customer.name}")
    type == 'export' ? File.delete("#{Rails.root}/tmp/#{customer.name.tr(" ", "_")}_#{time}.xlsx"):
      File.delete("#{Rails.root}/tmp/Imports_#{customer.name.tr(" ", "_")}_#{time}.xlsx")
  end

  def error_mail_report(customer, e)
    @customer = customer
    @exception = e
    mail(to: "paritoshbotre@joshsoftware.com", subject: "Error Report")
  end

  def send_emails_to_all_customer(customer)
    emails = customer.add_default_emails_to_customer
    mail(to: emails, subject: 'Our correct bank details')
  end

  def mail_report_status(type)
    attachments["daily_report.log"] = File.read("#{Rails.root}/tmp/daily_report.log")
    users = ["paritoshbotre@joshsoftware.com", "sameert@joshsoftware.com"]
    mail(to: users.join(", "), subject: "#{type} Report Status")
    File.delete("#{Rails.root}/tmp/daily_report.log")
  end

  def welcome_message_import(import, authority_letter_pdf = nil, authorisation_letter_pdf = nil)
    @import = import
    customer = Customer.find(@import.customer_id)
    emails = customer.add_default_emails_to_customer
    attach_pdf(authority_letter_pdf) if authority_letter_pdf
    attach_pdf(authorisation_letter_pdf) if authorisation_letter_pdf
    mail(to: emails, subject: "Your new order")
    File.delete("#{Rails.root}/tmp/#{File.basename authority_letter_pdf}") if authority_letter_pdf
    File.delete("#{Rails.root}/tmp/#{File.basename authorisation_letter_pdf}") if authorisation_letter_pdf
  end

  def attach_pdf(pdf)
    pdf_name = File.basename pdf
    attachment_name = pdf_name.gsub("#{@import.bl_number}_", '')
    attachments[attachment_name] = File.read(pdf)
  end

  def mail_expense_report(type)
    @type = type
    time = DateTime.parse(Time.now.to_s).strftime("%d_%b_%Y")
    attachments["Expense_#{@type}_#{time}.xlsx"] = File.read("#{Rails.root}/tmp/Expense_#{@type}_#{time}.xlsx")
    mail(to: "kaushik@21nautica.com, rajan@21nautica.com" ,subject: "Expense #{@type}")
    File.delete("#{Rails.root}/tmp/Expense_#{@type}_#{time}.xlsx")
  end

  def mail_invoice(invoice, attachment)
    attachment_name = File.basename attachment
    attachments[attachment_name] = File.read(attachment)
    subject = "Invoice // #{invoice.customer_name} // #{invoice.bl_number} // #{invoice.number}"
    emails = invoice.customer.add_default_emails_to_customer
    mail(to: emails , subject: subject)
    File.delete(attachment)
  end

  def payment_received_receipt(customer, attachment)
    attachment_name = File.basename attachment
    attachments[attachment_name] = File.read(attachment)
    emails = customer.add_default_emails_to_customer
    mail(to: emails , subject: "Thank you for your payment")
    File.delete(attachment)
  end

  def late_document_mail(import)
    #this mail is triggered after saving the import and if import eta date is less than current date
    #nd also if bl_received_date is greater than eta date
    @import = import
    mail(to: import.customer.emails.split(","), subject: "Late Document -BL Number #{@import.bl_number}")
  end

  def late_bl_received_mail(import)
    @import = import
    mail(to: import.customer.emails.split(","), subject: "Late Document - BL Number #{@import.bl_number}")
  end

  def rotation_number_mail(import)
    @import = import
    mail(to: @import.customer.emails.split(","), subject: "Rotation Number for BL Number #{@import.bl_number}")
  end

  def bl_entry_number_reminder(imports, customer)
    @imports = imports
    mail(to: customer.emails.split(","), subject: "Pending Documents – #{Date.today.to_date.try(:to_formatted_s)}")
  end

  def container_dropped_mail(import_item)
    @import_item = import_item
    mail(to: @import_item.import.customer.emails.split(","), subject: "Container Dropped")
  end

  def container_returned_date_report(customer_id)
    @customer = Customer.find(customer_id)
    emails = if ENV['HOSTNAME'] == 'RFS'
               @customer.emails
             else
               @customer.add_default_emails_to_customer
             end
    time = DateTime.parse(Time.now.to_s).strftime("%d_%b_%Y")
    attachments["ContainerReturned_#{@customer.name.tr(" ", "_")}_#{time}.xlsx"] = File.read("#{Rails.root}/tmp/ContainerReturned_#{@customer.name.tr(" ", "_")}_#{time}.xlsx")
    mail(to: emails, subject: "Container Returned Report - #{@customer.name}")
    File.delete("#{Rails.root}/tmp/ContainerReturned_#{@customer.name.tr(" ", "_")}_#{time}.xlsx")
  end

  def petty_cash_ledger
    email="prashant.bangar@joshsoftware.com"
    attachments["Petty Cash Ledger_#{Date.yesterday}.xlsx"] = File.read("#{Rails.root}/tmp/Petty Cash Ledger_#{Date.yesterday}.xlsx")
    mail(to:email,subject:"Petty Cash Ledger_#{Date.yesterday}")
    File.delete("#{Rails.root}/tmp/Petty Cash Ledger_#{Date.yesterday}.xlsx")
  end

  def non_truck_allocated_container_report
    #set internal emails to emails variables
    emails = "kiranmahale@joshsoftware.com"
    time = DateTime.parse(Time.now.to_s).strftime("%d_%b_%Y")
    attachments["Truck_Allocation_#{time}.xlsx"] = File.read("#{Rails.root}/tmp/Truck_Allocation_#{time}.xlsx")
    mail(to: emails, subject: "Non Truck Allocation")
    File.delete("#{Rails.root}/tmp/Truck_Allocation_#{time}.xlsx")
  end

  def purchase_order_status_report
    #set internal emails to emails variables
    emails = "kiranmahale@joshsoftware.com"
    time = DateTime.parse(Time.now.to_s).strftime("%d_%b_%Y")
    attachments["PurchaseOrderStatus_#{time}.xlsx"] = File.read("#{Rails.root}/tmp/PurchaseOrderStatus_#{time}.xlsx")
    mail(to: emails, subject: "Purchase Order Status")
    File.delete("#{Rails.root}/tmp/PurchaseOrderStatus_#{time}.xlsx")
  end

  def purchase_order_summary
    beg_month = Date.today.beginning_of_month
    @purchase_order_hash = PurchaseOrder.where(date: [beg_month..Date.today]).group(:date).sum(:total_cost)
    #set internal emails to emails variables
    emails = "kiranmahale@joshsoftware.com"
    if @purchase_order_hash.count > 1
      mail(to: emails, subject: "Purchase Order Summary")
    end
  end

  def new_order_summary
    yesterday = Date.yesterday
    beg_month = Date.today.beginning_of_month
    @orders_opened = Import.where(created_at: Date.today)
    daily_import_items = ImportItem.where(created_at: Date.today).non_third_party_container.count
    monthly_import_items = ImportItem.where(created_at: [beg_month..Date.today]).non_third_party_container.count
    subject = "New Order - #{daily_import_items}/#{monthly_import_items}"
    #set internal emails to emails variables
    emails = "kiranmahale@joshsoftware.com"
    mail(to: emails, subject: subject)
  end
end

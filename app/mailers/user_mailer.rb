class UserMailer < ActionMailer::Base
  default from: "Kaushik Somanathan<kaushik@21nautica.com>"

  def send_analysis_report(customer)
    @customer = customer
    analysis_report = Report::CustomerAnalysis.new.calculate_margin(@customer)
    attachments["Analysis_#{customer.name.tr(" ", "_")}.xlsx"] = File.read("#{Rails.root}/tmp/#{customer.name.tr(" ", "_")}.xlsx")
    mail(to: @customer.emails, subject: "Customer Analysis Report")
    File.delete("#{Rails.root}/tmp/#{customer.name.tr(" ", "_")}.xlsx")
  end

  def mail_report(customer,type)
    @customer = customer
    time = DateTime.parse(Time.now.to_s).strftime("%d_%b_%Y")
    if type == 'export'
      daily_report =Report::Daily.new
      daily_report.create(@customer)
      attachments["Export_#{customer.name.tr(" ", "_")}_#{time}.xlsx"] = File.read("#{Rails.root}/tmp/#{customer.name.tr(" ", "_")}_#{time}.xlsx")
    else
      daily_report =Report::DailyImport.new
      daily_report.create(@customer)
      attachments["Import_#{customer.name.tr(" ", "_")}_#{time}.xlsx"] = File.read("#{Rails.root}/tmp/Imports_#{customer.name.tr(" ", "_")}_#{time}.xlsx")
    end
    mail(to: @customer.emails, subject: "Customer Update #{customer.name}")
    type == 'export' ? File.delete("#{Rails.root}/tmp/#{customer.name.tr(" ", "_")}_#{time}.xlsx"): 
      File.delete("#{Rails.root}/tmp/Imports_#{customer.name.tr(" ", "_")}_#{time}.xlsx")
  end

  def welcome_message_import(import)
    @import = import
    customer = Customer.find(@import.customer_id)
    mail(to: customer.emails,subject: "Your new order")
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
    mail(to: (invoice.customer.emails + ", accounts@21nautica.com") , subject: subject)
    File.delete(attachment)
  end

  def payment_received_receipt(email_ids, attachment)
    attachment_name = File.basename attachment
    attachments[attachment_name] = File.read(attachment)
    mail(to: (email_ids + ", accounts@21nautica.com"), subject: "Thank you for your payment")
    File.delete(attachment)
  end

end

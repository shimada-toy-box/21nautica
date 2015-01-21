# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@InvoiceFilterInit = ->
  FilterJS invoices, "#invoices_search_result",
    template: "#invoices_search_result_template"
    search:
      ele: "#invoices_searchbox"

@loadupdatemodal = ->
  $('#invoiceUpdateModal').on 'show.bs.modal', (event) ->
    link_tag = $(event.relatedTarget)
    id = link_tag.attr('data-invoice-id')
    row = $("#invoices_index_table tr[invoice_id= '" + id + "']")
    row_class = link_tag.attr('data-row-class')
    $('#invoiceUpdateModal #customer_name label').text("Customer Name : 
    " + $(row).find("td.customer").text())
    
    $('#invoiceUpdateModal #bl_number label').text("BL Number : 
    " + $(row).find("td.bl_num").text())

    $('#invoiceUpdateModal #invoiced_date label').text("Invoice Date : 
    " + $(row).find("td.date").text())
    
    $('#invoiceUpdateModal #invoice_number').val $(row).find("td.number").text()
    $('#invoiceUpdateModal #invoice_document_number').val $(row).find("td.document_num").text()
    $('#invoiceUpdateModal #invoice_amount').val $(row).find("td.amount").text()
    $('#invoiceUpdateModal #invoice_amount').attr('readonly','readonly') if (row_class isnt 'warning')
    $('#invoiceUpdateModal form').attr('action', "/invoices/" + id )

  $('#invoiceUpdateModal').on 'hide.bs.modal', (event) ->
    $('#invoiceUpdateModal #invoice_amount').removeAttr('readonly')
    $('#invoiceUpdateModal .alert').remove()

@load_additional_invoice_modal = ->
  $('#AdditionalInvoiceModal').on 'show.bs.modal', (event) ->
    link_tag = $(event.relatedTarget)
    id = link_tag.attr('data-invoice-id')
    $('#AdditionalInvoiceModal form').attr('action', "/invoices/" + id + "/additional-invoice")
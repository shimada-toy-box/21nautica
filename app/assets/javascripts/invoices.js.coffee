# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

containers_quantity = (value, containers) ->
  quantity = if value in ["ICD", "Demurrage", "Empty", "Final Clearing", "Haulage", "Forest Permits"] then containers else 1

calculate_amount = ->
  amount = 0
  $('.subtotal').each ->
    amount = parseInt(amount) + parseInt($(this).val())

  removed_amount = 0
  $('.fields[style*="display: none;"] .subtotal').each ->
    removed_amount = parseInt(removed_amount) + parseInt($(this).val())
  return (amount - removed_amount)

load_particular_select_and_rate_event = ->
  $(".myselect").change ->
    value = $(this).find(".form-control").val()
    if value is "Other"
      select_name = $(this).find(".form-control").attr("name")
      new_input = $(this).find('.form-control').replaceWith('<input type="text" name=' + select_name + ' data-validation-error-msg="Enter particular" data-validation="required" class="form-control">')

    quantity = containers_quantity(value, containers)
    rate = $(this).closest(".fields").find(".rate").val()
    $(this).closest(".fields").find(".quantity").val quantity
    $(this).closest(".fields").find(".subtotal").val (quantity * rate)
    $('#invoiceUpdateModal #invoice_amount input').val(calculate_amount)

  $(".rate").change ->
    rate = $(this).val()
    qty = $(this).closest(".fields").find(".quantity").val()
    $(this).closest(".fields").find(".subtotal").val (rate * qty)
    $('#invoiceUpdateModal #invoice_amount input').val(calculate_amount)

@load_nested_form_events = ->
  $(document).on "nested:fieldAdded", (event) ->
    load_particular_select_and_rate_event()

  $(document).on "nested:fieldRemoved", (event) ->
    $('.fields[style*="display: none;"] .form-control').each ->
      $(this).removeAttr("data-validation")
    $('.fields[style*="display: none;"] .rate').each ->
      $(this).removeAttr("data-validation")

    $('#invoiceUpdateModal #invoice_amount input').val(calculate_amount)

@InvoiceFilterInit = ->
  FilterJS invoices, "#invoices_search_result",
    template: "#invoices_search_result_template"
    search:
      ele: "#invoices_searchbox"

@loadupdatemodal = ->
  $('#invoiceUpdateModal').on 'show.bs.modal', (event) ->
    $('#invoiceUpdateModal #invoice_amount').attr('readonly','readonly')
    load_particular_select_and_rate_event()

  $('#invoiceUpdateModal').on 'hide.bs.modal', (event) ->
    $('#invoiceUpdateModal .alert').remove()
    $('#invoiceUpdateModal .fields').remove()

@validate_invoice_form = ->
  $.validate
    form: "#invoice_form"
    scrollToTopOnError: false
  return
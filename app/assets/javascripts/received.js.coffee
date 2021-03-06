# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

show_received_index_table = ->
  customer_id = $(this).val()
  if customer_id
    $.ajax
      url: "/received"
      type: "GET"
      data:
        customer_id: customer_id

$(document).on "page:load ready", ->
  $("#received_customer_id").change(show_received_index_table)
  $("#received_payment_date").datepicker(
    format :"dd-mm-yyyy")
  $("#received_payment_date").datepicker('setDate', new Date())
  return
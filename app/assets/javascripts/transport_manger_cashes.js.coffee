datatable_initialize = ->
  row = 0
  id = 0
  imitemsTable = $('#transport_cash_table').dataTable({
                    "order": [[0, 'asc' ]],
                    "bJQueryUI": false,
                    "bFilter": true,
                    'bPaginate': false
                    })

$(document).ready datatable_initialize

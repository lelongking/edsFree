lemon.defineWidget Template.customerManagementSaleDetails,
  helpers:
    formatNumberBeforeDebtBalance: -> accounting.formatNumber(@beforeDebtBalance) if @beforeDebtBalance isnt 0
    allowDelete: -> @_id is Template.parentData().transaction
    transactionClass: (value)->
      if value is undefined
        if @receivable then 'receive' else 'paid'
      else
        if value >= 0 then 'receive' else 'paid'

  events:
    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id

#
#    "click .deleteSales": (event, template) ->
#      Meteor.call 'customerManagementDeleteSale', @_id, (error, result) -> if error then console.log error
#      Meteor.call 'reCalculateMetroSummaryTotalReceivableCash', (error, result) -> if error then console.log error
#      Meteor.call 'reCalculateMetroSummary', (error, result) -> if error then console.log error
#
#    "click .deleteTransaction": (event, template) ->
#      Meteor.call 'customerManagementDeleteTransaction', @_id, (error, result) -> if error then console.log error
#      Meteor.call 'reCalculateMetroSummaryTotalReceivableCash', (error, result) -> if error then console.log error
#      Meteor.call 'reCalculateMetroSummary', (error, result) -> if error then console.log error
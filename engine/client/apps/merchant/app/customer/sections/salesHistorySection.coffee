scope = logics.customerManagement
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

lemon.defineHyper Template.customerManagementSalesHistorySection,
  helpers:
    allSales: -> scope.findAllOrders()
    oldDebts: -> scope.findOldDebtCustomer()
    debtTotalCash: ->
      if customer = Session.get('customerManagementCurrentCustomer')
        customer.debtCash + customer.loanCash
      else 0

  rendered: ->
    @ui.$paySaleAmount.inputmask("numeric", numericOption)

  events:
    "keyup input.transaction-field":  (event, template) ->
      scope.checkAllowCreateAndCreateTransaction(event, template)

    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id

    "click .createTransaction": (event, template) ->
      scope.createTransactionOfCustomer(event, template)

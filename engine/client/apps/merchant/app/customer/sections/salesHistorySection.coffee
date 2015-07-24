scope = logics.customerManagement
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

lemon.defineHyper Template.customerManagementSalesHistorySection,
  helpers:
    allSales: -> logics.customerManagement.findAllOrders()
    oldDebts: -> logics.customerManagement.findOldDebtCustomer()
    debtTotalCash: ->
      if customer = Session.get('customerManagementCurrentCustomer')
        customer.debtCash + customer.loanCash
      else 0

    transactionDescription: -> if Session.get("customerManagementOldDebt") then 'ghi chú nợ cũ' else 'ghi chú trả tiền'
    transactionStatus: -> if Session.get("customerManagementOldDebt") then 'Nợ Cũ' else 'Trả Tiền'

  rendered: ->
    @ui.$paySaleAmount.inputmask("numeric", numericOption)

  events:
    "keyup input.transaction-field":  (event, template) ->
      scope.checkAllowCreateAndCreateTransaction(event, template)

    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id

    "click .createTransaction": (event, template) ->
      scope.createTransactionOfCustomer(event, template)

scope = logics.billDetail
Enums = Apps.Merchant.Enums
lemon.defineApp Template.billDetail,
  helpers:
    currentBill: -> Session.get('currentBillHistory')
    depositOptions: -> scope.depositOptions
    discountOptions: -> scope.discountOptions
    sellerSelectOptions: -> scope.sellerSelectOptions
    customerSelectOptions: -> scope.customerSelectOptions
    paymentMethodSelectOptions: -> scope.paymentMethodSelectOptions
    paymentsDeliverySelectOptions: -> scope.paymentsDeliverySelectOptions

  created: ->
    UnitProductSearch.search('')

  destroyed: ->
    Session.set("editingId")
    Session.set("currentBillHistory")

  events:
    "click .caption.inner": (event, template) -> scope.currentBillHistory.addDetail(@_id); event.stopPropagation()
    "click .accountingConfirm": (event, template) ->
      Meteor.call 'orderAccountConfirm', scope.currentBillHistory._id, (error, result) ->
        Meteor.call 'orderExportConfirm', scope.currentBillHistory._id, (error, result) ->
          Session.set("currentBillHistory")
          Session.set("editingId")
          Router.go 'billManager'
scope = logics.orderManager
Enums = Apps.Merchant.Enums
lemon.defineApp Template.orderManager,
  helpers:
    details: ->
      details = []; orders = Schema.orders.find({
        merchant    : Merchant.getId()
        orderType   : {$in:[ Enums.getValue('OrderTypes', 'success'), Enums.getValue('OrderTypes', 'fail') ]}
        orderStatus : Enums.getValue('OrderStatus', 'finish')
      }).fetch()
      if orders.length > 0
        for key, value of _.groupBy(orders, (item) -> moment(item.version.createdAt).format('MM/YYYY'))
          details.push({createdAt: key, data: value})
      details


#  created: ->
#    UnitProductSearch.search('')
#    Session.setDefault('globalBarcodeInput', '')
#
#
##    lemon.dependencies.resolve('saleManagement')
#    Session.setDefault('allowCreateOrderDetail', false)
#    Session.setDefault('allowSuccessOrder', false)


#    if mySession = Session.get('mySession')
#      Session.set('currentOrder', Schema.orders.findOne(mySession.currentOrder))
#      Meteor.subscribe('orderDetails', mySession.currentOrder)

  rendered: ->
#    scope.templateInstance = @
#    $(document).on "keypress", (e) -> scope.handleGlobalBarcodeInput(e)
#    $("[name=deliveryDate]").datepicker('setDate', scope.deliveryDetail?.deliveryDate)


  destroyed: ->
#    $(document).off("keypress")

  events:
    "click .caption.inner": (event, template) ->
      Meteor.users.update(userId, {$set: {'sessions.currentOrderBill': @_id}}) if userId = Meteor.userId()


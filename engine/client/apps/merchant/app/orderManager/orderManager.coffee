scope = logics.orderManager
Enums = Apps.Merchant.Enums
lemon.defineApp Template.orderManager,
  helpers:
    details: ->
      details = []
      orderQuery =
        merchant    : Merchant.getId()
        orderType   : {$in:[ Enums.getValue('OrderTypes', 'success')]}
        orderStatus : Enums.getValue('OrderStatus', 'finish')

      orderQuery.seller = Meteor.userId() unless User.roleIsManager()
      orders = Schema.orders.find(orderQuery).fetch()

      if orders.length > 0
        for key, value of _.groupBy(orders, (item) -> moment(item.version.createdAt).format('MM/YYYY'))
          details.push({createdAt: key, data: value})
      details

  rendered: ->
  destroyed: ->
#    $(document).off("keypress")

  events:
    "click .caption.inner": (event, template) ->
      Meteor.users.update(userId, {$set: {'sessions.currentOrderBill': @_id}}) if userId = Meteor.userId()


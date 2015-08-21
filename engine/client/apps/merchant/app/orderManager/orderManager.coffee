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

      orderQuery.seller = Meteor.userId() unless User.hasManagerRoles()
      orders = Schema.orders.find(orderQuery, {sort:{accountingConfirmAt: -1}}).fetch()

      if orders.length > 0
        for key, value of _.groupBy(orders, (item) -> moment(item.accountingConfirmAt).format('MM/YYYY'))
          totalCash = 0
          totalCash += item.finalPrice for item in value
          details.push({createdAt: key, data: value, totalCash: totalCash})
      details

  rendered: ->
  destroyed: ->
#    $(document).off("keypress")

  events:
    "click .caption.inner": (event, template) ->
      Meteor.users.update(userId, {$set: {'sessions.currentOrderBill': @_id}}) if userId = Meteor.userId()


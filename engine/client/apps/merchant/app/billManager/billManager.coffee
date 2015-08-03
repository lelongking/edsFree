scope = logics.billManager
Enums = Apps.Merchant.Enums

gridOrderQuery =
  orderType: {$in:[
    Enums.getValue('OrderTypes', 'tracking')
    Enums.getValue('OrderTypes', 'success')
    Enums.getValue('OrderTypes', 'fail')
  ]}
  orderStatus: {$in:[
    Enums.getValue('OrderStatus', 'accountingConfirm')
    Enums.getValue('OrderStatus', 'exportConfirm')
    Enums.getValue('OrderStatus', 'success')
    Enums.getValue('OrderStatus', 'fail')
    Enums.getValue('OrderStatus', 'importConfirm')
  ]}


lemon.defineApp Template.billManager,
  helpers:
    allBills: ->
      orderQuery =
        merchant    : Merchant.getId()
        orderType   : Enums.getValue('OrderTypes', 'tracking')
        orderStatus : Enums.getValue('OrderStatus', 'sellerConfirm')
      orderQuery.seller = Meteor.userId() unless User.hasManagerRoles()

      Schema.orders.find(orderQuery).map (item) ->
        item.buyerName  = -> Schema.customers.findOne(item.buyer)?.name ? item.orderName
        item.sellerName = ->
          if user = Meteor.users.findOne(item.seller)
            user.profile?.name ? user.emails[0].address
          else
            'Khách Hàng'
        item

    waitingGridOptions:
      itemTemplate: 'billThumbnail'
      reactiveSourceGetter: ->
        gridOrderQuery.accountingConfirmAt = {$gte: moment().subtract(7, 'days').startOf('day')._d}
        gridOrderQuery.seller = Meteor.userId() unless User.hasManagerRoles()
        Schema.orders.find(gridOrderQuery)

    deliveringGridOptions:
      itemTemplate: 'billThumbnail'
      reactiveSourceGetter: ->
        gridOrderQuery.accountingConfirmAt = {$lt: moment().subtract(7, 'days').startOf('day')._d}
        gridOrderQuery.seller = Meteor.userId() unless User.hasManagerRoles()
        Schema.orders.find(gridOrderQuery)

  events:
    "click .caption.inner": (event, template) ->
      Session.set("currentBillHistory", @)
      Router.go 'billDetail'


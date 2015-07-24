scope = logics.billManager
Enums = Apps.Merchant.Enums
lemon.defineApp Template.billManager,
  helpers:
    allBills: -> Schema.orders.find({
      merchant    : Merchant.getId()
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'sellerConfirm')
    }).map((item) ->
      item.buyerName  = -> Schema.customers.findOne(item.buyer)?.name ? item.orderName
      item.sellerName = ->
        if user = Meteor.users.findOne(item.seller)
          user.profile?.name ? user.emails[0].address
        else
          'Khách Hàng'
      item)

    waitingGridOptions:
      itemTemplate: 'billThumbnail'
      reactiveSourceGetter: -> Schema.orders.find({
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
        accountingConfirmAt: {$gte: moment().subtract(7, 'days').startOf('day')._d}
      })

    deliveringGridOptions:
      itemTemplate: 'billThumbnail'
      reactiveSourceGetter: -> Schema.orders.find({
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
        ]}
        accountingConfirmAt: {$lt: moment().subtract(7, 'days').startOf('day')._d}
      })

  events:
    "click .caption.inner": (event, template) ->
      Session.set("currentBillHistory", @)
      Router.go 'billDetail'


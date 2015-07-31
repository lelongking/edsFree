Enums = Apps.Merchant.Enums
Meteor.methods
  recalculateOrderBillNo: ->
    Schema.customers.find().forEach(
      (customer) -> Schema.customers.update customer._id , $set:{billNo: 0}
    )
    customers = {}
    orderCount = 0
    Schema.orders.find({
      orderType   : Enums.getValue('OrderTypes', 'success')
      orderStatus : Enums.getValue('OrderStatus', 'finish')
    },{sort: {successDate: 1}}).forEach(
      (order)->
        orderCount += 1
        if customers[order.buyer] then customers[order.buyer] += 1 else customers[order.buyer] = 1
        Schema.orders.update order._id, $set:{
          orderCode:"#{Helpers.orderCodeCreate(customers[order.buyer]-1)}/#{Helpers.orderCodeCreate(orderCount-1)}"
        }
    )
    Schema.customers.update(key, $set:{billNo: value}) for key, value of customers
    Schema.merchants.update(Merchant.getId(), $set:{saleBill: orderCount})

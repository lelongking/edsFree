Enums = Apps.Merchant.Enums
Meteor.methods
  recalculateOrderBillNo: ->
    Schema.customers.find({merchant: Merchant.getId()}).forEach(
      (customer) -> Schema.customers.update customer._id , $set:{billNo: 0}
    )
    customers = {}
    orderCount = 0
    Schema.orders.find({
      merchant    : Merchant.getId()
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

  recalculateImportBillNo: ->
    Schema.providers.find({merchant: Merchant.getId()}).forEach(
      (provider) -> Schema.providers.update provider._id , $set:{billNo: 0}
    )
    providers = {}
    providerCount = 0
    Schema.imports.find({
      merchant  : Merchant.getId()
      importType: Enums.getValue('ImportTypes', 'success')
    },{sort: {successDate: 1, 'version.createdAt': 1}}).forEach(
      (currentImport)->
        providerCount += 1
        if providers[currentImport.provider] then providers[currentImport.provider] += 1 else providers[currentImport.provider] = 1
        Schema.imports.update currentImport._id, $set:{
          importCode:"#{Helpers.orderCodeCreate(providers[currentImport.provider]-1)}/#{Helpers.orderCodeCreate(providerCount-1)}"
        }
    )
    Schema.providers.update(key, $set:{billNo: value}) for key, value of providers
    Schema.merchants.update(Merchant.getId(), $set:{importBill: providerCount})

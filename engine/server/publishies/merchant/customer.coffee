Meteor.publishComposite 'availableCustomers', ->
  self = @
  return {
    find: ->
      myProfile = Schema.userProfiles.findOne({user: self.userId})
      return EmptyQueryResult if !myProfile
      Schema.customers.find {parentMerchant: myProfile.parentMerchant}
    children: [
      find: (customer) -> AvatarImages.find {_id: customer.avatar}
    ]
  }

Meteor.publish 'availableCustomerAreas', ->
  myProfile = Schema.userProfiles.findOne({user: @userId})
  return [] if !myProfile
  Schema.customerAreas.find({parentMerchant: myProfile.parentMerchant})



Meteor.publishComposite 'customerManagementDataByCustomSale', (customerId, customSaleId)->
  self = @
  return {
    find: ->
      myProfile = Schema.userProfiles.findOne({user: self.userId})
      return EmptyQueryResult if !myProfile
      Schema.customSales.find {_id: customSaleId, buyer: customerId, parentMerchant: myProfile.parentMerchant}
    children: [
      find: (customSale) -> Schema.customSaleDetails.find {customSale: customSale._id}
    ,
      find: (customSale) -> Schema.transactions.find {latestSale: customSale._id}
    ]
  }

Meteor.publishComposite 'customerManagementData', (customerId, currentRecords = 0, limitRecords = 5)->
  self = @
  salesCount = Schema.sales.find({buyer: customerId}, {sort: {'version.createdAt': 1}}).count()
  customSalesCount = Schema.customSales.find({buyer: customerId}, {sort: {debtDate: 1}}).count()

  return {
    find: ->
      myProfile = Schema.userProfiles.findOne({user: self.userId})
      return EmptyQueryResult if !myProfile
      Schema.customers.find {_id: customerId, parentMerchant: myProfile.parentMerchant}
    children: [
      find: (customer) ->
        if customer.customSaleModeEnabled
          if customSalesCount > currentRecords
            skipCustomSaleRecords  = currentRecords
            limitCustomSaleRecords = limitRecords
          else
            skipCustomSaleRecords  = customSalesCount
            limitCustomSaleRecords = 0
          Schema.customSales.find {buyer: customer._id}, {sort: {debtDate: -1}, skip: skipCustomSaleRecords, limit: limitCustomSaleRecords}
        else
          if salesCount < currentRecords + limitRecords
            if salesCount + limitRecords > currentRecords
              skipCustomSaleRecords  = 0
              limitCustomSaleRecords = limitRecords + currentRecords - salesCount
            else
              skipCustomSaleRecords  = currentRecords - salesCount
              limitCustomSaleRecords = limitRecords
            Schema.customSales.find {buyer: customer._id}, {sort: {debtDate: -1}, skip: skipCustomSaleRecords, limit: limitCustomSaleRecords}
          else
            EmptyQueryResult
      children: [
        find: (customSale, customer) -> Schema.customSaleDetails.find {customSale: customSale._id}
      ,
        find: (customSale, customer) -> Schema.transactions.find {latestSale: customSale._id}
      ]
    ,
      find: (customer) ->
        if customer.customSaleModeEnabled
          Schema.sales.find {buyer: customer._id}
        else
          if salesCount > currentRecords
            skipSaleRecords  = currentRecords
            limitSaleRecords = limitRecords
            Schema.sales.find {buyer: customer._id}, {sort: {'version.createdAt': -1}, skip: skipSaleRecords, limit: limitSaleRecords}
          else
            EmptyQueryResult
      children: [
        find: (sale, customer) -> Schema.saleDetails.find {sale: sale._id}
        children: [
          find: (saleDetail, customer) -> Schema.products.find {_id: saleDetail.product}
          children: [
            find: (product, customer) -> Schema.productUnits.find {product: product._id}
            children: [
              find: (productUnit, customer) -> Schema.branchProductUnits.find {productUnit: productUnit._id}
            ]
          ,
            find: (product, customer) -> if product.buildInProduct then Schema.buildInProducts.find {_id: product.buildInProduct} else EmptyQueryResult
            children: [
              find: (buildInProduct, customer) -> Schema.buildInProductUnits.find {buildInProduct: buildInProduct._id}
            ]
          ]
        ]
      ,
        find: (sale, customer) -> Schema.returns.find {timeLineSales: sale._id}
        children: [
          find: (returns, customer) -> Schema.returnDetails.find {return: returns._id}
        ]
      ,
        find: (sale, customer) -> Schema.transactions.find {latestSale: sale._id}
      ]
    ]
  }



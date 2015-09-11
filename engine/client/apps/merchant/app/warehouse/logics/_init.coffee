Enums = Apps.Merchant.Enums
logics.warehouse = {warehouseDetail: {totalCostPrice: 0, totalRevenue: 0}}
Apps.Merchant.warehouseInit = []
Apps.Merchant.warehouseReactive = []


findProductTrade =
  Schema.products.find(
    {$or: [
      {'quantities.saleQuantity'     : {$ne: 0}}
      {'quantities.inStockQuantity'  : {$ne: 0}}
    ]}
    {
      sort:
        allQuantity           : -1
        normsQuantityCount : 1
    }
  )

findProductNotTrade =
  Schema.products.find(
    {
      'quantities.saleQuantity'     : 0
      'quantities.inStockQuantity'  : 0
    }
    {
      sort:
        normsQuantityCount : -1
    }
  )

Apps.Merchant.warehouseReactive.push (scope) ->

Apps.Merchant.warehouseInit.push (scope) ->
  scope.listProductsNotTrade = ->
    productCount = findProductTrade.count(); totalCostPrice = 0; totalRevenue = 0
    lists = findProductNotTrade.map(
      (product) ->
        productCount += 1
        product.count = productCount
        quality       = product.quantities[0].inStockQuantity
        quality       = 0 if quality < 0
        costPrice     = quality * product.getPrice(undefined, 'import')
        revenue       = quality * product.getPrice()

        product.costPrice = costPrice ? 0
        product.revenue   = revenue ? 0
        totalCostPrice   += product.costPrice
        totalRevenue     += product.revenue

        product
    )
    return {
      details       : lists
      totalCostPrice: totalCostPrice
      totalRevenue  : totalRevenue
    }

  scope.listProductsTrade = (count = 0)->
    productCount = count; totalCostPrice = 0; totalRevenue = 0
    lists = findProductTrade.map(
      (product) ->
        productCount += 1
        product.count = productCount
        quality       = product.quantities[0].inStockQuantity
        quality       = 0 if quality < 0
        costPrice     = quality * product.getPrice(undefined, 'import')
        revenue       = quality * product.getPrice()

        product.costPrice = costPrice ? 0
        product.revenue   = revenue ? 0
        totalCostPrice   += product.costPrice
        totalRevenue     += product.revenue

        product
    )
    return {
      details       : lists
      totalCostPrice: totalCostPrice
      totalRevenue  : totalRevenue
    }
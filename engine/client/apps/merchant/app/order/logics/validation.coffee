logics.sales.validation = {}
Apps.Merchant.salesInit.push (scope) ->
  logics.sales.validation.orderDetail = (product, quality, price, discountCash)->
    if quality < 1
      console.log 'Số lượng nhỏ nhất là 1.'
      return false
    else if price < product.price
      console.log 'Giá sản phẩm không thể nhỏ hơn giá bán.'
      return false
    else if discountCash > price*quality
      console.log 'Giảm giá lớn hơn số tiền hiện có.'
      return false
    else
      return true

  logics.sales.validation.checkProductInStockQuantity = (order, orderDetails)->
    product_ids = _.union(_.pluck(orderDetails, 'product'))
    products = Schema.products.find({_id: {$in: product_ids}}).fetch()

    orderDetails = _.chain(orderDetails)
    .groupBy("product")
    .map (group, key) ->
      return {
      product: key
      quality: _.reduce(group, ((res, current) -> res + current.quality), 0)
      }
    .value()
    try
      for currentDetail in orderDetails
        currentProduct = _.findWhere(products, {_id: currentDetail.product})
        if currentProduct.availableQuantity < currentDetail.quality
          throw {message: "lỗi", item: currentDetail}

      return {}
    catch e
      return {error: e}

  scope.validation.getCrossProductQuantity = (productId, branchProductId, orderId) ->
    currentProduct = Schema.products.findOne(productId)
    if branchProduct  = Schema.branchProductSummaries.findOne(branchProductId)
      currentProduct.price       = branchProduct.price if branchProduct.price
      currentProduct.importPrice = branchProduct.importPrice if branchProduct.importPrice

      currentProduct.salesQuantity     = branchProduct.salesQuantity
      currentProduct.totalQuantity     = branchProduct.totalQuantity
      currentProduct.availableQuantity = branchProduct.availableQuantity
      currentProduct.inStockQuantity   = branchProduct.inStockQuantity
      currentProduct.returnQuantityByCustomer    = branchProduct.returnQuantityByCustomer
      currentProduct.returnQuantityByDistributor = branchProduct.returnQuantityByDistributor
      currentProduct.basicDetailModeEnabled     = branchProduct.basicDetailModeEnabled

    sameProducts = Schema.orderDetails.find({product: productId, order: orderId}).fetch()
    crossProductQuantity = 0
    crossProductQuantity += item.quality for item in sameProducts
    return {
      product: currentProduct
      quality: crossProductQuantity
    }

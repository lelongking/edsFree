Enums = Apps.Merchant.Enums
Meteor.methods
  productInventory: (productId, inventoryDetail = {})->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    product = Schema.products.findOne({_id: productId, inventoryInitial: false})
    return {valid: false, error: 'product not found!'} if !product
    return {valid: false, error: 'importDetails Error!'} if inventoryDetail.product isnt product._id

    inventoryQuantities = -product.quantities[0].availableQuantity
    inventoryQuantities += inventoryDetail.quantity if inventoryDetail.quantity > 0

    importId = Import.insert(null,'Tồn kho đầu kỳ', null)
    if importFound = Schema.imports.findOne(importId)
      importFound.addImportDetail(product.basicUnitId(), inventoryQuantities, inventoryDetail.expireDay)

    importFound = Schema.imports.findOne(importId)
    if importFound?.details.length > 0
      updateImportInventory =
        $set:
          importType: Enums.getValue('ImportTypes', 'inventorySuccess')
        $inc:
          'details.0.basicOrderQuantity'     : product.quantities[0].saleQuantity
          'details.0.basicQuantityAvailable' : -product.quantities[0].saleQuantity

      if Schema.imports.update(importId, updateImportInventory)
        updateQuery =
          $set:
            inventoryInitial: true
            allowDelete     : false
            status          : Enums.getValue('ProductStatuses', 'confirmed')
          $inc:
            'quantities.0.availableQuantity' : inventoryQuantities
            'quantities.0.inStockQuantity'   : inventoryQuantities
            'quantities.0.importQuantity'    : inventoryQuantities
        Schema.products.update(product._id, updateQuery)

        importDetail = importFound.details[0]
        Schema.orders.find({'details.product': product._id}).forEach(
          (order)->
            updateOrderQuery = {$push:{}, $inc:{}}

            for detail, detailIndex in order.details
              if detail.product is product._id
                updateOrderQuery.$set = {}
                updateOrderQuery.$set["details.#{detailIndex}.importIsValid"] = true

                importDetailOfOrder =
                  _id         : importFound._id
                  detailId    : importDetail._id
                  product     : importDetail.product
                  productUnit : importDetail.productUnit
                  price       : importDetail.price
                  conversion  : importDetail.conversion
                  quality     : detail.basicQuantity/importDetail.conversion
                  createdAt   : new Date()
                  basicQuantity          : detail.basicQuantity
                  basicQuantityReturn    : 0
                  basicQuantityAvailable : detail.basicQuantity

                updateOrderQuery.$push["details.#{detailIndex}.imports"]                 = importDetailOfOrder
                updateOrderQuery.$inc["details.#{detailIndex}.basicImportQuantity"]      = detail.basicQuantity
                updateOrderQuery.$inc["details.#{detailIndex}.basicImportQuantityDebit"] = -detail.basicQuantity

            Schema.orders.update(order._id, updateOrderQuery)
        )
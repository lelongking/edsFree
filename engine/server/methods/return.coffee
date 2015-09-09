Meteor.methods
  submitDistributorReturn: (currentDistributorReturn)->
    try
      throw 'currentDistributorReturn sai' if !currentDistributorReturn
      returnDetails = Schema.returnDetails.find({return: currentDistributorReturn._id}).fetch()
      (if detail.returnQuantity is 0 then throw 'So luong lon hon 0.') for detail in returnDetails

      totalReturnQuantity = 0
      totalReturnPrice = 0
      for item in returnDetails
        totalReturnQuantity += item.returnQuantity
        totalReturnPrice += item.finalPrice

      returnDetailGroups = _.chain(returnDetails)
      .groupBy("product")
      .map (group, key) ->
        return {
        product: key
        quality: _.reduce(group, ((res, current) -> res + current.returnQuantity), 0)
        }
      .value()

      for returnDetail in returnDetailGroups
        quality = 0
        Schema.productDetails.find({
          distributor: currentDistributorReturn.distributor
          product: returnDetail.product
          availableQuantity: {$gt:0}
        }).forEach((productDetail)-> quality += productDetail.availableQuantity)
        if quality < returnDetail.quality then throw 'So luong khong du.'

      for product in returnDetailGroups
        for returnDetail in _.where(returnDetails, {product: product.product})
          if returnDetail.unit
            productDetailLikeUnit = Schema.productDetails.find({
              distributor: currentDistributorReturn.distributor
              product: returnDetail.product
              unit: returnDetail.unit
              availableQuantity: {$gt:0}
            }).fetch()
            productDetailUnLikeUnit = Schema.productDetails.find({
              distributor: currentDistributorReturn.distributor
              product: returnDetail.product
              unit: { $ne: returnDetail.unit }
              availableQuantity: {$gt:0}
            }).fetch()
          else
            productDetailLikeUnit = Schema.productDetails.find({
              distributor: currentDistributorReturn.distributor
              product: returnDetail.product
              unit: { $exists: false }
              availableQuantity: {$gt:0}
            }).fetch()
            productDetailUnLikeUnit = Schema.productDetails.find({
              distributor: currentDistributorReturn.distributor
              product: returnDetail.product
              unit: { $exists: true }
              availableQuantity: {$gt:0}
            }).fetch()

          transactionQuantity = 0
          for productDetail in productDetailLikeUnit.concat(productDetailUnLikeUnit)
            requiredQuantity = returnDetail.returnQuantity - transactionQuantity
            if productDetail.availableQuantity > requiredQuantity then takenQuantity = requiredQuantity
            else takenQuantity = productDetail.availableQuantity

            productOption =
              availableQuantity: -takenQuantity
              inStockQuantity  : -takenQuantity
              returnQuantityByDistributor: takenQuantity
            Schema.productDetails.update productDetail._id, $inc: productOption

            productOption.totalQuantity = -takenQuantity
            Schema.products.update productDetail.product, $inc: productOption
            Schema.branchProductSummaries.update productDetail.branchProduct, $inc: productOption

            transactionQuantity += takenQuantity
            Schema.returnDetails.update returnDetail._id, $addToSet: {productDetail: {productDetail: productDetail._id, returnQuantity: takenQuantity}}
            if transactionQuantity == returnDetail.returnQuantity then break

        distributor = Schema.distributors.findOne(currentDistributorReturn.distributor)
        Schema.distributors.update distributor._id, $inc:{importTotalCash: -totalReturnPrice, importDebt: -totalReturnPrice}

        timeLineImport = Schema.imports.findOne({distributor: currentDistributorReturn.distributor, finish: true, submitted: true}, {sort: {'version.createdAt': -1}})
        Schema.returns.update currentDistributorReturn._id, $set: {
          timeLineImport: timeLineImport._id
          status: 2
          'version.createdAt': new Date()
          allowDelete: false
          beforeDebtBalance: distributor.importDebt
          debtBalanceChange: totalReturnPrice
          latestDebtBalance: distributor.importDebt - totalReturnPrice
        }

        Meteor.call 'reCalculateMetroSummaryTotalPayableCash'
        MetroSummary.updateMyMetroSummaryBy(['createReturn'], currentDistributorReturn._id)
        Meteor.call 'updateMetroSummaryBy', 'createReturnDistributor', currentDistributorReturn._id, currentDistributorReturn.merchant

        if distributor = Schema.distributors.findOne(currentDistributorReturn.distributor)
          Meteor.call 'distributorToReturns', distributor

    catch error
      throw new Meteor.Error('submitDistributorReturn', error)

#  submitCustomerReturn: (currentCustomerReturn)->
#    try
#      throw 'currentCustomerReturn sai' if !currentCustomerReturn
#      returnDetails = Schema.returnDetails.find({return: currentCustomerReturn._id}).fetch()
#      (if detail.returnQuantity is 0 then throw 'So luong lon hon 0.') for detail in returnDetails
#
#      totalReturnQuantity = 0
#      totalReturnPrice = 0
#      for item in returnDetails
#        totalReturnQuantity += item.returnQuantity
#        totalReturnPrice += item.finalPrice
#
#      returnDetails = _.chain(returnDetails)
#      .groupBy("product")
#      .map (group, key) ->
#        return {
#        product: key
#        quality: _.reduce(group, ((res, current) -> res + current.returnQuantity), 0)
#        }
#      .value()
#
#      for returnDetail in returnDetails
#        quality = 0
#        Schema.sales.find({buyer: currentCustomerReturn.customer}).forEach(
#          (sale)->
#            Schema.saleDetails.find({sale: sale._id, product: returnDetail.product}).forEach(
#              (saleDetail)-> quality += (saleDetail.quality - saleDetail.returnQuantity)
#            )
#        )
#        if quality < returnDetail.quality then throw 'So luong khong du.'
#
#      for returnDetail in returnDetails
#        saleDetails = []
#        Schema.sales.find({buyer: currentCustomerReturn.customer}).forEach(
#          (sale)->
#            Schema.saleDetails.find({sale: sale._id, product: returnDetail.product}).forEach(
#              (saleDetail)-> saleDetails.push saleDetail
#            )
#        )
#
#        transactionQuantity = 0
#        for saleDetail in saleDetails
#          requiredQuantity = returnDetail.quality - transactionQuantity
#          availableReturnQuantity = saleDetail.quality - saleDetail.returnQuantity
#          if availableReturnQuantity > requiredQuantity then takenQuantity = requiredQuantity
#          else takenQuantity = availableReturnQuantity
#
#          branchProduct = Schema.branchProductSummaries.findOne(saleDetail.branchProduct)
#          updateOption = {}
#          if branchProduct.basicDetailModeEnabled is false
#            updateOption.availableQuantity = takenQuantity
#            updateOption.inStockQuantity   = takenQuantity
#            Schema.productDetails.update saleDetail.productDetail, $inc: updateOption
#
#          updateOption.returnQuantityByCustomer = takenQuantity
#          Schema.products.update branchProduct.product, $inc: updateOption
#          Schema.branchProductSummaries.update branchProduct._id, $inc: updateOption
#
#          Schema.saleDetails.update saleDetail._id, $inc:{returnQuantity: takenQuantity}
#          Schema.sales.update saleDetail.sale, $set:{allowDelete: false}
#
#          transactionQuantity += takenQuantity
#          if transactionQuantity == returnDetail.quality then break
#
#      if customer = Schema.customers.findOne(currentCustomerReturn.customer)
#        Schema.customers.update customer._id, $inc:{saleTotalCash: -totalReturnPrice, saleDebt: -totalReturnPrice}
#
#        timeLineSale = Schema.sales.findOne({buyer: currentCustomerReturn.customer}, {sort: {'version.createdAt': -1}})
#        Schema.returns.update currentCustomerReturn._id, $set: {
#          timeLineSales: timeLineSale._id
#          status: 2
#          'version.createdAt': new Date()
#          allowDelete: false
#          beforeDebtBalance: customer.saleDebt
#          debtBalanceChange: totalReturnPrice
#          latestDebtBalance: customer.saleDebt - totalReturnPrice
#        }
#        MetroSummary.updateMyMetroSummaryBy(['createReturn'], currentCustomerReturn._id)
#        Meteor.call 'reCalculateMetroSummaryTotalReceivableCash'
#        Meteor.call 'customerToReturns', customer
#        Meteor.call 'updateMetroSummaryBy', 'createReturnCustomer', currentCustomerReturn._id, currentCustomerReturn.merchant
#
#    catch error
#      throw new Meteor.Error('submitCustomerReturn', error)

Enums = Apps.Merchant.Enums
scope = logics.productManagement

lemon.defineHyper Template.productManagementSalesHistorySection,
  helpers:
    allSaleDetails: ->
      details = []
      if product = Session.get("productManagementCurrentProduct")
        orderOption   = sort: {orderType: Enums.getValue('OrderTypes', 'success') , 'successDate': 1}
        orderSelector = {
          'details.product': product._id
          orderType        : Enums.getValue('OrderTypes', 'success')
          orderStatus      : Enums.getValue('OrderStatus', 'finish')
        }
        details = Schema.orders.find(orderSelector, orderOption).map(
          (order) ->
            details = []
            for detail, index in order.details
              if detail.product is product._id
                detail.buyer = order.buyer
                details.push(detail)
            order.details = details
            order
        )
      details

    allSaleDetailsss: ->
      details = []
      if product = Session.get("productManagementCurrentProduct")
        importOption   = sort: {importType: Enums.getValue('ImportTypes', 'success') , 'version.createdAt': 1}
        importSelector = {'details.product': product._id}
        allImports = Schema.imports.find(importSelector, importOption).map(
          (item) ->
            item.isImport = true
            item
        )

        orderOption   = sort: {orderType: Enums.getValue('OrderTypes', 'success') , 'version.createdAt': -1}
        orderSelector = {
          'details.product': product._id
          orderType        : Enums.getValue('OrderTypes', 'success')
          orderStatus      : Enums.getValue('OrderStatus', 'finish')
        }
        allOrders = Schema.orders.find(orderSelector, orderOption).map(
          (order) ->
            for detail in order.details
              detail.buyer     = order.buyer
              detail.createdAt = order.accountingConfirmAt
              if detail.import?.length > 0
                item.buyer = order.buyer for item in detail.import

            order.isOrder = true
            order
        )
        for key, value of _.groupBy(allImports.concat(allOrders), (item) -> moment(item.accountingConfirmAt ? item.version.createdAt).format('L'))
          details.push({createdAt: key, data: value})

      return details

    saleQuality   : -> @qualities?[0].saleQuality ? 0
    inStockQuality: -> @qualities?[0].inStockQuality ? 0
    importQuality : -> @qualities?[0].importQuality ? 0
    totalPrice: -> @price * @quality

    isProduct: -> @product is Session.get("productManagementCurrentProduct")._id
    isInventory: -> Template.parentData().importType is -2
    availableQuality: -> @availableQuality/@conversion
    providerName: -> Template.parentData().importName


  #  events:
  #    "click .basicDetailModeDisable": ->
  #      if branchProduct = Session.get("productManagementBranchProductSummary")
  #        if branchProduct.basicDetailModeEnabled is true
  #          Meteor.call 'updateProductBasicDetailMode', branchProduct._id, (error, result) ->
  #            Meteor.subscribe('productManagementData', branchProduct.product)
  #          Session.set("productManagementDetailEditingRowId")
  #          Session.set("productManagementDetailEditingRow")
  #          Session.set("productManagementUnitEditingRowId")
  #          Session.set("productManagementUnitEditingRow")
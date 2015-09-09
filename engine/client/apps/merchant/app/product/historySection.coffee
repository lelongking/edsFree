Enums = Apps.Merchant.Enums
scope = logics.productManagement

lemon.defineHyper Template.productManagementSalesHistorySection,
  helpers:
    isProduct: -> @product is Session.get("productManagementCurrentProduct")?._id
    getOwnerName: ->
      data = Template.parentData()
      if data.model is 'imports'
        owner = Schema.providers.findOne(data.provider)
      else if data.model is 'orders'
        owner = Schema.customers.findOne(data.buyer)
      else if data.model is 'returns'
        owner = Schema.customers.findOne(data.owner)
        owner = Schema.providers.findOne(data.owner) unless owner
      owner?.name ? 'Error Not Find Name'


    allSaleDetailsss: ->
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

    allSaleDetails: ->
      details = []
      combined = []
      if product = Session.get("productManagementCurrentProduct")

        importSelector = {
          'details.product': product._id
          importType       : $in: [Enums.getValue('ImportTypes', 'inventorySuccess'), Enums.getValue('ImportTypes', 'success')]
        }
        Schema.imports.find(importSelector).forEach(
          (item) ->
            for detail in item.details
              if detail.product is product._id
                if item.importType is Enums.getValue('ImportTypes', 'inventorySuccess')
                  detail.ownerName = 'Nhập Kho Đầu Kỳ'
                  detail.billNo    = '----'
                  detail.createdAt = item.version.createdAt
                else
                  owner = Schema.providers.findOne(item.provider)
                  detail.ownerName = owner?.name ? 'Error Not Find Name'
                  detail.billNo    = item.importCode
                  detail.createdAt = item.successDate
                detail.activity  = 'Nhập Kho'
                combined.push(detail)
        )

        orderSelector = {
          'details.product': product._id
          orderType        : Enums.getValue('OrderTypes', 'success')
          orderStatus      : Enums.getValue('OrderStatus', 'finish')
        }
        Schema.orders.find(orderSelector).forEach(
          (item) ->
            for detail in item.details
              if detail.product is product._id
                owner = Schema.customers.findOne(item.buyer)
                detail.ownerName = owner?.name ? 'Error Not Find Name'
                detail.billNo    = item.orderCode
                detail.createdAt = item.successDate
                detail.activity  = 'Bán Hàng'
                combined.push(detail)
        )

        returnSelector = {
          'details.product': product._id
          returnStatus     : Enums.getValue('ReturnStatus', 'success')
        }
        Schema.returns.find(returnSelector).map(
          (item) ->
            for detail in item.details
              if detail.product is product._id
                owner = Schema.customers.findOne(item.owner)
                owner = Schema.providers.findOne(item.owner) unless owner
                detail.ownerName = owner?.name ? 'Error Not Find Name'
                detail.billNo    = item.returnCode
                detail.createdAt = item.successDate
                detail.activity  = 'Trả Hàng'
                combined.push(detail)
        )

        sorted = _.sortBy combined, (item) -> item.createdAt
        combined = _.groupBy(sorted, (item) -> moment(item.createdAt).format('L'))
        details.push({createdAt: key, details: value}) for key, value of combined
      return details

    saleQuantity    : -> @quantities?[0].saleQuantity ? 0
    inStockQuantity : -> @quantities?[0].inStockQuantity ? 0
    inOderQuantity  : -> @quantities?[0].inOderQuantity ? 0
    importQuantity  : -> @quantities?[0].importQuantity ? 0
    totalPrice      : -> @price * @quality

    isProduct: -> @product is Session.get("productManagementCurrentProduct")._id
    isInventory: -> Template.parentData().importType is -2
    availableQuantity: -> @availableQuantity/@conversion
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
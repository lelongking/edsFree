scope = logics.productManagement

lemon.defineWidget Template.productManagementImportDetails,
  helpers:
    isProduct: -> @product is Session.get("productManagementCurrentProduct")._id
    providerName: -> Template.parentData().importName
    totalPrice: -> (@price ? @salePrice) * @quality
    isInventory: -> Template.parentData().importType is -2

#    if orderFound = Schema.orders.findOne({_id:order._id, 'details.productUnit': productUnitId})

#    order
#    order = {}
#    if orderFound = Schema.orders.findOne({_id:order._id, 'details.productUnit': productUnitId})
#      for detail in orderFound.details
#        saleDetails.push detail if detail.productUnit is productUnitId

#  unitSaleQuantity: -> Math.round(@quality/@conversionQuantity*100)/100
#  isShowDisableMode: -> !Session.get("productManagementCurrentProduct")?.basicDetailModeEnabled
#
#  distributorName: ->
#    distributorName = Schema.distributors.findOne(@distributor)?.name
#    partnerName = Schema.partners.findOne(@partner)?.name
#    distributorName ? partnerName ? ''
#
#  buyerName: -> Schema.customers.findOne(Schema.sales.findOne(@sale)?.buyer)?.name
#
#  totalPrice: -> @unitPrice * @unitQuantity
#  expireDate: -> if @expire then moment(@expire).format('DD/MM/YYYY') else 'KHÔNG'
#  saleQuantity: -> @quality - @returnQuantity
#
#  distributorReturnQuantity: (temp)->
#    console.log @
#
#  importDetails: ->
#    importId = Template.instance().data._id
#    Schema.productDetails.find {import: importId, product: Session.get("productManagementCurrentProduct")._id}
#
#  saleDetails: -> Schema.saleDetails.find {productDetail: @_id}
#  returnDetails: ->
#    return {
#      productDetail: @
#      returnDetails: Schema.returnDetails.find {productDetail: $elemMatch: {productDetail: @_id}}
#    }
#
#lemon.defineWidget Template.productManagementReturnDetails,
#  returnQuantity: ->
#    for detail in @productDetail
#      if detail.productDetail is Template.instance().data.productDetail._id
#        return detail.returnQuantity/@conversionQuantity
#
#  returnFinalPrice: ->
#    for detail in @productDetail
#      if detail.productDetail is Template.instance().data.productDetail._id
#        return detail.returnQuantity*@unitReturnsPrice/@conversionQuantity
#

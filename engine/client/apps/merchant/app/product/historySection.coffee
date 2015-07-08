scope = logics.productManagement
#
lemon.defineHyper Template.productManagementSalesHistorySection,
  saleQuality   : -> @qualities?[0].saleQuality ? 0
  inStockQuality: -> @qualities?[0].inStockQuality ? 0
  importQuality : -> @qualities?[0].importQuality ? 0
#
  newImport: ->
    if product = Session.get("productManagementCurrentProduct")
      option = sort: {'version.createdAt': 1}
      selector = {'details.product': product._id}
      currentImport = Schema.imports.find(selector, option)
      return {
        isShowDetail: if currentImport.count() > 0 then true else false
        detail: currentImport
      }
#
#  allSaleDetails: -> Schema.saleDetails.find({product: @_id})
#
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
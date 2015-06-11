logics.productManagement = {}
Apps.Merchant.productManagementInit = []
Apps.Merchant.productManagementReactive = []



Apps.Merchant.productManagementInit.push (scope) ->
  scope.productManagementCreationMode = (productSearch)->
    if ProductSearch.history[productSearch].data?.length is 1
      nameIsExisted = ProductSearch.history[productSearch].data[0].name isnt Session.get("productManagementSearchFilter")
    Session.set("productManagementCreationMode", nameIsExisted)

  scope.createNewProduct = (template, productSearch) ->
    fullText   = Session.get("productManagementSearchFilter")
    newProduct = Helpers.splitName(fullText)
    newProduct.merchant = Session.get("myProfile").merchant

    existedQuery = {name: newProduct.name, merchant: newProduct.merchant}
    if Schema.products.findOne(existedQuery)
      template.ui.$searchFilter.notify("Sản phẩm đã tồn tại.", {position: "bottom"})
    else
      newProduct.units = [{name: 'MacDinh', allowDelete: false, isBase: true}]
      newProductId = Schema.products.insert newProduct
      if Match.test(newProductId, String)
        Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': newProductId}})
        ProductSearch.cleanHistory()

  scope.ProductSearchFindPreviousProduct = (productSearch) ->
    if previousRow = ProductSearch.history[productSearch].data.getPreviousBy('_id', Session.get('mySession').currentProduct)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': previousRow._id}})

  scope.ProductSearchFindNextProduct = (productSearch) ->
    if nextRow = ProductSearch.history[productSearch].data.getNextBy('_id', Session.get('mySession').currentProduct)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': nextRow._id}})




Apps.Merchant.productManagementReactive.push (scope) ->
  scope.currentProduct = Schema.products.findOne(Session.get('mySession').currentProduct)
  Session.set "productManagementCurrentProduct", scope.currentProduct

#    if Session.get("productManagementSearchFilter")?.trim().length > 1
#      if scope.managedBranchProductList.length + scope.managedMerchantProductList > 0
#        productNameLists = _.pluck(scope.managedBranchProductList, 'name')
#        Session.set("productManagementCreationMode", !_.contains(productNameLists, Session.get("productManagementSearchFilter").trim()))
#      else
#        Session.set("productManagementCreationMode", true)
#    else
#      Session.set("productManagementCreationMode", false)

#  merchantId = Session.get("myProfile")?.currentMerchant
#  productId  = Session.get("mySession")?.currentProductManagementSelection
#  if productId and merchantId
#    product = Schema.products.findOne(productId)
#    branchProduct = Schema.branchProductSummaries.findOne({merchant: merchantId, product: productId})
#    if product and branchProduct
#      Session.set("productManagementBranchProductSummary", branchProduct)
#      product.price       = branchProduct.price if branchProduct.price
#      product.importPrice = branchProduct.importPrice if branchProduct.importPrice
#
#      product.salesQuality     = branchProduct.salesQuality
#      product.totalQuality     = branchProduct.totalQuality
#      product.availableQuality = branchProduct.availableQuality
#      product.inStockQuality   = branchProduct.inStockQuality
#      product.returnQualityByCustomer    = branchProduct.returnQualityByCustomer
#      product.returnQualityByDistributor = branchProduct.returnQualityByDistributor
#      product.basicDetailModeEnabled     = branchProduct.basicDetailModeEnabled
#
#      buildInProduct = Schema.buildInProducts.findOne(product.buildInProduct) if product.buildInProduct
#      if buildInProduct
#        Session.set("productManagementBuildInProduct", buildInProduct)
#        product.productCode = buildInProduct.productCode
#        product.basicUnit = buildInProduct.basicUnit
#
#        product.name = buildInProduct.name if !product.name
#        product.image = buildInProduct.image if !product.image
#        product.description = buildInProduct.description if !product.description
#      Session.set("productManagementCurrentProduct", product)
#
#  if Session.get("productManagementUnitEditingRowId")
#    if productUnit = Schema.productUnits.findOne Session.get("productManagementUnitEditingRowId")
#      buildInProductUnit = Schema.buildInProductUnits.findOne(productUnit.buildInProductUnit) if productUnit.buildInProductUnit
#      if buildInProductUnit
#        productUnit.unit              = buildInProductUnit.unit if !productUnit.unit
#        productUnit.productCode       = buildInProductUnit.productCode if !productUnit.productCode
#        productUnit.conversionQuality = buildInProductUnit.conversionQuality if !productUnit.conversionQuality
#      Session.set("productManagementUnitEditingRow", productUnit)
#
#  if Session.get("productManagementDetailEditingRowId")
#    Session.set("productManagementDetailEditingRow", Schema.productDetails.findOne(Session.get("productManagementDetailEditingRowId")))

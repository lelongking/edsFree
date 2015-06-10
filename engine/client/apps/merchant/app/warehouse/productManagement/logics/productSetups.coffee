Apps.Merchant.productManagementInit.push (scope) ->
  scope.createProduct = (template)->
    fullText    = Session.get("productManagementSearchFilter")

    newProduct = Helpers.splitName(fullText)
    newProduct.merchant = Session.get('myProfile').merchant

    existedQuery = {name: newProduct.name, merchant: newProduct.merchant}
    if Schema.products.findOne(existedQuery)
      template.ui.$searchFilter.notify("Sản phẩm đã tồn tại.", {position: "bottom"})
    else
      newProduct.units = [{name: 'MacDinh', allowDelete: false, isBase: true}]
      Schema.products.insert newProduct
#        while true
#          randomBarcode = Helpers.randomBarcode()
#          existedQuery.productCode = randomBarcode
#          if !Schema.products.findOne(existedQuery)
#            product.productCode = randomBarcode
#            productId = Schema.products.insert product, (error, result) -> console.log error if error
#            UserSession.set('currentProductManagementSelection', productId)
#            Meteor.subscribe('productManagementData', productId)
#            template.ui.$searchFilter.val(''); Session.set("productManagementSearchFilter", "")
#            break

#  scope.editProduct = (template) ->
#    product = Session.get("productManagementCurrentProduct")
#    branchProduct = Session.get("productManagementBranchProductSummary")
#    if product and branchProduct
#      newName  = template.ui.$productName.val()
#      newPrice = template.ui.$productPrice.inputmask('unmaskedvalue')
#      newImportPrice = template.ui.$importPrice.inputmask('unmaskedvalue')
#      newProductCode = template.ui.$productCode.val()
#      return if newName.replace("(", "").replace(")", "").trim().length < 2
#
#      productEdit = {$set: {}, $unset: {}}; productEdit.$set = splitName(newName)
#      branchProductEdit = {$set: {}, $unset: {}}
#
#      if newPrice.length > 0
#        if branchProduct.parentMerchant is branchProduct.merchant and branchProduct.price isnt Number(newPrice)
#          productEdit.$set.price = newPrice
#        if branchProduct.price is Number(newPrice) then branchProductEdit.$unset.price = ""
#        else branchProductEdit.$set.price = newPrice
#      if newImportPrice.length > 0
#        if branchProduct.parentMerchant is branchProduct.merchant and branchProduct.importPrice isnt Number(newImportPrice)
#          productEdit.$set.importPrice = newImportPrice
#        if branchProduct.importPrice is Number(newImportPrice) then branchProductEdit.$unset.importPrice = ""
#        else branchProductEdit.$set.importPrice = newImportPrice
#
#      buildInProduct = Session.get("productManagementBuildInProduct")
#      if product.buildInProduct
#        buildInProduct = if product.buildInProduct is buildInProduct._id then buildInProduct else Schema.buildInProducts.findOne(product.buildInProduct)
#        delete productEdit.$set.basicUnit; productEdit.$unset.basicUnit = ""; productEdit.$unset.productCode = ""
#        (delete productEdit.$set.name; productEdit.$unset.name = "") if buildInProduct.name is productEdit.$set.name
#      else
#        delete productEdit.$set.basicUnit if Schema.productUnits.findOne({product: product._id})
#        if newProductCode.length > 0 and newProductCode isnt product.productCode
#          productEdit.$set.productCode = newProductCode
#          barcodeFound = Schema.products.findOne {productCode: newProductCode, merchant: product.merchant}
#        if productEdit.$set.name.length > 0
#          if productEdit.$set.name is product.name then delete productEdit.$set.name
#          else productFound = Schema.products.findOne {name: productEdit.$set.name, merchant: product.merchant}
#
#
#      if productEdit.$set.name and productEdit.$set.name.length is 0
#        template.ui.$productName.notify("Tên sản phẩn không thể để trống.", {position: "right"})
#      else if productFound and productFound._id isnt product._id
#        template.ui.$productName.notify("Tên sản phẩm đã tồn tại.", {position: "right"})
#      else if barcodeFound and barcodeFound._id isnt product._id
#        template.ui.$productCode.notify("Mã sản phẩm đã tồn tại.", {position: "right"})
#      else
#        delete productEdit.$set if _.keys(productEdit.$set).length is 0
#        delete productEdit.$unset if _.keys(productEdit.$unset).length is 0
#        if _.keys(productEdit).length > 0
#          Schema.products.update product._id, productEdit, (error, result)->
#            if error then console.log error
#
#        delete branchProductEdit.$set if _.keys(branchProductEdit.$set).length is 0
#        delete branchProductEdit.$unset if _.keys(branchProductEdit.$unset).length is 0
#        if _.keys(branchProductEdit).length > 0
#          Schema.branchProductSummaries.update branchProduct._id, branchProductEdit, (error, result)->
#            if error then console.log error
#
#        productName = (
#          if product.buildInProduct
#            if productEdit.$set?.name then productEdit.$set.name else product.name ? buildInProduct.name
#          else
#            productEdit.$set?.name ? product.name
#        )
#        template.ui.$productName.val productName
#        Session.set("productManagementShowEditCommand", false)
#
#  scope.deleteProduct = (product)->
#    if product.allowDelete and !product.buildInProduct
#      Meteor.call 'deleteBranchProduct', product._id, (error, result) ->
#        if error then console.log error.error
#        else
#          UserSession.set('currentProductManagementSelection', Schema.metroSummaries.findOne({merchant: Session.get('myProfile').currentMerchant})?.productList[0] ? '')
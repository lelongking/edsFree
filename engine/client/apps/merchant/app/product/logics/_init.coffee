logics.productManagement = {}
Apps.Merchant.productManagementInit = []
Apps.Merchant.productManagementReactive = []

Apps.Merchant.productManagementReactive.push (scope) ->
  scope.currentProduct = Schema.products.findOne(Session.get('mySession').currentProduct)
  Session.set "productManagementCurrentProduct", scope.currentProduct

Apps.Merchant.productManagementInit.push (scope) ->
  scope.productManagementCreationMode = (productSearch)->
    if ProductSearch.history[productSearch].data?.length is 1
      nameIsExisted = ProductSearch.history[productSearch].data[0].name isnt Session.get("productManagementSearchFilter")
    Session.set("productManagementCreationMode", nameIsExisted)

  scope.createNewProduct = (template, productSearch) ->
    fullText   = Session.get("productManagementSearchFilter")
    newProduct = Helpers.splitName(fullText)
    newProduct.merchant = Session.get("myProfile").merchant

    if Product.nameIsExisted(newProduct.name, newProduct.merchant)
      template.ui.$searchFilter.notify("Sản phẩm đã tồn tại.", {position: "bottom"})
    else
      ProductSearch.cleanHistory() if Match.test(Product.insert(newProduct), String)
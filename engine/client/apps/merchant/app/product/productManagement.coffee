scope = logics.productManagement

lemon.defineApp Template.productManagement,
  creationMode: -> Session.get("productManagementCreationMode")
  currentProduct: -> Session.get("productManagementCurrentProduct")
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
  activeClass:-> if Session.get("productManagementCurrentProduct")?._id is @._id then 'active' else ''

  created: ->
    ProductSearch.search ''
    Session.set("productManagementSearchFilter", "")

#    if currentProduct = Session.get("mySession").currentProductManagementSelection
#      Meteor.subscribe('productManagementData', currentProduct)

# loal danh sach san pham con lai
#    lemon.dependencies.resolve('productManagements')

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      productSearch = Helpers.Searchify searchFilter
      Session.set("productManagementSearchFilter", searchFilter)
      currentProductId = Session.get('mySession').currentProduct

      if event.which is 17 then console.log 'up'

      else if event.which is 38
        previousRow = ProductSearch.history[productSearch].data.getPreviousBy('_id', currentProductId)
        Product.setSession(previousRow._id) if previousRow

      else if event.which is 40
        nextRow = ProductSearch.history[productSearch].data.getNextBy('_id', currentProductId)
        Product.setSession(nextRow._id) if nextRow

      else
        if event.which is 13
          newProduct = Helpers.splitName(searchFilter)
          newProduct.merchant = Session.get("myProfile").merchant
          if Product.nameIsExisted(newProduct.name, newProduct.merchant)
            template.ui.$searchFilter.notify("Sản phẩm đã tồn tại.", {position: "bottom"})
          else
            ProductSearch.cleanHistory() if Match.test(Product.insert(newProduct), String)

        ProductSearch.search productSearch
        scope.productManagementCreationMode(productSearch)

    "click .createProductBtn": (event, template) ->
      fullText   = Session.get("productManagementSearchFilter")
      newProduct = Helpers.splitName(fullText)
      newProduct.merchant = Session.get("myProfile").merchant

      if Product.nameIsExisted(newProduct.name, newProduct.merchant)
        template.ui.$searchFilter.notify("Sản phẩm đã tồn tại.", {position: "bottom"})
      else
        ProductSearch.cleanHistory() if Match.test(Product.insert(newProduct), String)
      ProductSearch.search Helpers.Searchify(fullText)

    "click .inner.caption": (event, template) -> Product.setSession(@_id)
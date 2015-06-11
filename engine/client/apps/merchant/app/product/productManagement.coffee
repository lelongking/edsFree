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

      if event.which is 17 then console.log 'up'
      else if event.which is 38 then scope.ProductSearchFindPreviousProduct(productSearch)
      else if event.which is 40 then scope.ProductSearchFindNextProduct(productSearch)
      else
        scope.createNewProduct(template, productSearch) if event.which is 13
        ProductSearch.search productSearch
        scope.productManagementCreationMode(productSearch)

    "click .createProductBtn": (event, template) ->
      fullText   = Session.get("productManagementSearchFilter")
      productSearch = Helpers.Searchify(fullText)

      scope.createNewProduct(template, productSearch)
      ProductSearch.search productSearch

    "click .inner.caption": (event, template) ->
      if userId = Meteor.userId()
        Meteor.subscribe('productManagementCurrentProductData', @_id)
        Meteor.users.update(userId, {$set: {'sessions.currentProduct': @_id}})

#    "click .deleteBranchProduct":  (event, template) ->
#      Meteor.call('deleteBranchProduct', @_id); event.stopPropagation()
#    "click .deleteMerchantProduct":  (event, template) ->
#      Meteor.call('deleteMerchantProduct', @_id); event.stopPropagation()
#    "click .addBranchProduct":  (event, template) ->
#      Meteor.call('addBranchProduct', @_id); event.stopPropagation()
#    "click .addMerchantAndBranchProduct":  (event, template) ->
#      Meteor.call('getBuildInProduct', @_id); event.stopPropagation()

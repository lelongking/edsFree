scope = logics.productManagement

lemon.defineApp Template.productManagement,
  topSaleProducts: -> scope.managedTopSaleProducts()
  productFilterSearch: -> Schema.products.find()

  showFilterSearch: -> Session.get("productManagementSearchFilter")?.length > 1
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
  currentProduct: -> Session.get("productManagementCurrentProduct")
  activeClass:-> if Session.get("productManagementCurrentProduct")?._id is @._id then 'active' else ''




  creationMode: -> Session.get("productManagementCreationMode")
#  showDeleteBranchProduct: -> @inStockQuality == @availableQuality == @totalQuality == @salesQuality == 0
#  showDeleteMerchantProduct: -> if @branchList?.length is 0 then true else false

  created: ->
#    if currentProduct = Session.get("mySession").currentProductManagementSelection
#      Meteor.subscribe('productManagementData', currentProduct)
#
#    lemon.dependencies.resolve('productManagements')
    Session.set("productManagementSearchFilter", "")

  events:
    "input .search-filter": (event, template) ->
      Helpers.deferredAction ->
        Session.set("productManagementSearchFilter", template.ui.$searchFilter.val())
      , "productManagementSearchProduct"

    "keypress input[name='searchFilter']": (event, template)->
      scope.createProduct(template) if event.which is 13 and Session.get("productManagementSearchFilter")?.trim().length > 1

    "click .createProductBtn": (event, template) -> scope.createProduct(template)

    "click .inner.caption": (event, template) ->
      if userId = Meteor.userId()
        Meteor.users.update(userId, {$set: {'sessions.currentProduct': @_id}})
#        Meteor.subscribe('productManagementData', @_id)

#    "click .deleteBranchProduct":  (event, template) ->
#      Meteor.call('deleteBranchProduct', @_id); event.stopPropagation()
#    "click .deleteMerchantProduct":  (event, template) ->
#      Meteor.call('deleteMerchantProduct', @_id); event.stopPropagation()
#    "click .addBranchProduct":  (event, template) ->
#      Meteor.call('addBranchProduct', @_id); event.stopPropagation()
#    "click .addMerchantAndBranchProduct":  (event, template) ->
#      Meteor.call('getBuildInProduct', @_id); event.stopPropagation()

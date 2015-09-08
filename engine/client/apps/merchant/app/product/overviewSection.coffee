scope = logics.productManagement
Enums = Apps.Merchant.Enums

lemon.defineHyper Template.productManagementOverviewSection,
  rendered: ->
    Session.set('productManagementIsShowProductUnit', false)
    Session.set('productManagementIsShowProductInventory', false)
    scope.overviewTemplateInstance = @
    @ui.$productName.autosizeInput({space: 10}) if @ui.$productName
  #    @ui.$productPrice.inputmask("numeric",   {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign:false})
  #    @ui.$importPrice.inputmask("numeric",   {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign:false})

  helpers:
    currentProduct: -> scope.currentProduct
    isShowSubmit: ->
      if scope.currentProduct.status isnt Enums.getValue('ProductStatuses', 'confirmed') then true
      else if Session.get('productManagementAllowInventory') is false then false
      else if scope.currentProduct.inventoryInitial is false then true

    productUnits: ->
      for productUnit in @units
        for item in productUnit.priceBooks
          if item.priceBook is Session.get('priceBookBasic')._id
            productUnit.salePrice   = item.salePrice
            productUnit.importPrice = item.importPrice
      @units

    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$productName.change()
      , 50 if scope.overviewTemplateInstance?.ui?.$productName?
      @name

    depositOptions:
      reactiveSetter: (val) ->
      reactiveValue: -> Session.get('test') ? 0
      reactiveMax: -> 1000
      reactiveMin: -> 0
      reactiveStep: -> 10
      others:
        forcestepdivisibility: 'none'

  events:
    "click .avatar": (event, template) ->
      if User.hasManagerRoles()
        template.find('.avatarFile').click()

    "change .avatarFile": (event, template) ->
      if User.hasManagerRoles()
        files = event.target.files
        if files.length > 0
          AvatarImages.insert files[0], (error, fileObj) ->
            Schema.products.update(Session.get('productManagementCurrentProduct')._id, {$set: {avatar: fileObj._id}})
            AvatarImages.findOne(Session.get('productManagementCurrentProduct').avatar)?.remove()

    "click .productDelete": (event, template) ->
      if Session.get('myProfile').roles isnt 'seller' and @allowDelete
        scope.currentProduct.remove()
        Product.setSession(Schema.products.findOne()._id)
        ProductSearch.cleanHistory()
        ProductSearch.search()


    "click .submitInventory": (event, template) ->
      if Session.get('productManagementAllowInventory')
        inventoryDetails = Session.get('productManagementInventoryDetails')
        scope.currentProduct.submitInventory(inventoryDetails) if inventoryDetails
      else
        scope.currentProduct.productConfirm()


    "keyup .panel-heading input.editable": (event, template) ->
      #TODO: lam lai cho hoan chinh phan cap nha, tim kiem
      if Session.get("productManagementCurrentProduct")
        if event.which is 13
          $productName    = template.ui.$productName
          $salePrice      = template.ui.$productPrice
          $basicUnitName  = template.ui.$productBasicUnit

          if $productName.val().length > 0
            productFound = Schema.products.findOne {name: $productName.val(), merchant: Merchant.getId()}

          if $productName.val() is 0
            $productName.notify("Tên sản phẩm không thể để trống.", {position: "right"})
          else if productFound and productFound._id isnt scope.currentProduct._id
            $productName.notify("Tên sản phẩm đã tồn tại.", {position: "right"})
#            $productName.val scope.currentProduct.name
          else
            Schema.products.update scope.currentProduct._id, {$set: {name: $productName.val()}}

          updateOption = {name: $basicUnitName.val(), salePrice: accounting.parse($salePrice.val())}
          console.log 'click', updateOption
          scope.currentProduct.unitUpdate scope.currentProduct.basicUnitId(), updateOption

          ProductSearch.cleanHistory()
          ProductSearch.search(ProductSearch.getCurrentQuery())

    # Click mo rong hoac dong mo rong thong tin chi tiet cua san pham
    "click .title.productUnit": (event, template)->
      Session.set('productManagementIsShowProductUnit', !Session.get('productManagementIsShowProductUnit'))
    "click .title.productInventory": (event, template)->
      Session.set('productManagementIsShowProductInventory', !Session.get('productManagementIsShowProductInventory'))
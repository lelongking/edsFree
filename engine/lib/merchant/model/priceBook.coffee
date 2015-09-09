Enums = Apps.Merchant.Enums
simpleSchema.priceBooks = new SimpleSchema
  name            : type: String ,unique  : true, index: 1
  owner           : type: String ,optional: true
  description     : type: String ,optional: true
  priceBookType   : type: Number ,defaultValue: Enums.getValue('PriceBookTypes', 'customer')
  products        : type: [String] ,optional: true

  childPriceBooks : type: [String] , optional: true
  parentPriceBook : type: String   ,optional: true

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : type: simpleSchema.Version
  isBase      : simpleSchema.BooleanNotUpdate(false)

Schema.add 'priceBooks', "PriceBook", class PriceBook
  @transform: (doc) ->
    doc.remove = -> #ok
      if doc.allowDelete is true and doc.isBase is false
        if Schema.priceBooks.remove doc._id
          Schema.products.find({'priceBooks._id': doc._id, merchant: Merchant.getId()}).forEach(
            (product)->
              for priceBook, index in product.priceBooks
                if priceBook._id is doc._id
                  Schema.products.update product._id, $pull: {priceBooks: priceBook}
                  break
          )

          basicPrice = Schema.priceBooks.findOne({isBase: true, merchant: Merchant.getId()})
          Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentPriceBook': basicPrice._id}})

    doc.updatePriceOfProduct = (productId, salePrice, importPrice) -> #ok
      priceBookId = @_id; priceBookIsBase = @isBase; priceBookType = @priceBookType; unitUpdateQuery = $set:{}
      if product = Schema.products.findOne({_id: productId, 'priceBooks._id': priceBookId, merchant: Merchant.getId()})
        for item, index in product.priceBooks
          priceBookQuery = "priceBooks.#{index}"
          if priceBookIsBase
            if salePrice isnt undefined and salePrice >= 0 and salePrice isnt item.salePrice
              unitUpdateQuery.$set["#{priceBookQuery}.basicSale"] = salePrice
              unitUpdateQuery.$set["#{priceBookQuery}.salePrice"] = salePrice if item._id is priceBookId

            if importPrice isnt undefined and importPrice >= 0 and importPrice isnt item.importPrice
              unitUpdateQuery.$set["#{priceBookQuery}.basicImport"] = importPrice
              unitUpdateQuery.$set["#{priceBookQuery}.importPrice"] = importPrice if item._id is priceBookId

          else if item._id is priceBookId
            if _.contains([0, 1, 2], priceBookType) and salePrice and salePrice >= 0 and salePrice isnt item.salePrice
              unitUpdateQuery.$set["#{priceBookQuery}.salePrice"] = salePrice

            if _.contains([0, 3, 4], priceBookType) and importPrice and importPrice >= 0 and importPrice isnt item.importPrice
              unitUpdateQuery.$set["#{priceBookQuery}.importPrice"] = importPrice

            break

        console.log unitUpdateQuery
        Schema.products.update(product._id, unitUpdateQuery) unless _.isEmpty(unitUpdateQuery.$set)


    doc.deletePriceOfProduct = (productId)-> #ok
      console.log product
      if product = Schema.products.findOne({_id: productId, 'priceBooks._id': @_id, merchant: Merchant.getId()})
        for item, index in product.priceBooks
          if item._id is @_id
            priceBookDetail = item
            break

        if priceBookDetail
          Schema.products.update product._id, $pull: {priceBooks: priceBookDetail}
          Schema.priceBooks.update @_id, $pull: {products:product._id}

    doc.selectedPriceProduct = (productId)-> #ok
      if userId = Meteor.userId()
        if @priceBookType isnt 1
          userUpdate = $addToSet:{}; userUpdate.$addToSet["sessions.productUnitSelected.#{@_id}"] = productId
          Meteor.users.update(userId, userUpdate)

    doc.unSelectedPriceProduct = (productId)-> #ok
      if userId = Meteor.userId()
        userUpdate = $pull:{}; userUpdate.$pull["sessions.productUnitSelected.#{@_id}"] = productId
        Meteor.users.update(userId, userUpdate)

    doc.changePriceProductTo = (ownerId, model) -> #ok
      if ownerId and (user = Meteor.users.findOne(Meteor.userId()))
        merchantId = user.profile.merchant

        if model is 'customers'
          console.log 'is customer: ' + ownerId
          if customerFound = Schema.customers.findOne({_id: ownerId, merchant: merchantId})
            productUnitList = []; productIdSelected = user.sessions.productUnitSelected[@_id]

            if !(priceBookOfGroup = PriceBook.findOneByOwner(customerFound._id, model))
              insertOption = {name: customerFound.name, owner: customerFound._id, priceBookType: 1}
              priceBookId = Schema.priceBooks.insert(insertOption)
              (priceBookOfGroup = Schema.priceBooks.findOne(priceBookId)) if priceBookId

        else if model is 'customerGroups'
          console.log 'is customerGroup: ' + ownerId
          if customerGroupFound = Schema.customerGroups.findOne({_id: ownerId, merchant: merchantId})
            productUnitList = []; productIdSelected = user.sessions.productUnitSelected[@_id]

            if !(priceBookOfGroup = PriceBook.findOneByOwner(customerGroupFound._id, model))
              insertOption = {name: customerGroupFound.name, owner: customerGroupFound._id, priceBookType: 2}
              priceBookId = Schema.priceBooks.insert(insertOption)
              (priceBookOfGroup = Schema.priceBooks.findOne(priceBookId)) if priceBookId


        #phải có bảng giá và không trùng với bản giá sẽ cập nhật và không trùng với bản giá gốc
        if priceBookOfGroup and priceBookOfGroup._id isnt @_id and priceBookOfGroup.isBase isnt true
          console.log 'productIds:' + productIdSelected
          for productId in productIdSelected
            query = findProductIndexAndPriceBookIndex(productId, @_id, priceBookOfGroup._id)
            console.log query

            #cả hai bản giá đều chưa có giá của unit
            if query.priceBookFromIndex isnt undefined and query.priceBookToIndex isnt undefined


            #bản giá cập nhật không có giá của unit dc chon
            else if query.priceBookFromIndex isnt undefined #lấy giá từ bảng gốc thêm vào bản cập nhật
              priceBook = { _id : priceBookOfGroup._id }
              priceBook.basicSale   = query.basicSale if query.basicSale
              priceBook.salePrice   = query.salePrice if query.salePrice
              priceBook.basicImport = query.basicImport if query.basicImport
              priceBook.importPrice = query.importPrice if query.importPrice

              console.log priceBook
              Schema.products.update query.productId, $push: { priceBooks: priceBook }
              Schema.priceBooks.update priceBookOfGroup._id, $push: {products: query.productId}
#              Schema.priceBooks.update @_id, $pull: {products: query.productId}

#                  cập nhật lại giá của bản giá cập nhật theo bản giá gốc
#                unitUpdateQuery = $set:{}
#                unitUpdateQuery.$set["units.#{productUnitIndex}.priceBooks.#{query.priceBookToIndex}.salePrice"] = query.salePrice
#                unitUpdateQuery.$set["units.#{productUnitIndex}.priceBooks.#{query.priceBookToIndex}.discountSalePricesss"] = query.discountSalePrice
#                Schema.products.update(query.productId, unitUpdateQuery) unless _.isEmpty(unitUpdateQuery.$set)



            #bản giá nguồn không có giá của unit dc chon, bản giá cập nhật có giá của unit
            else if query.priceBookToIndex isnt undefined #không làm gi hết.

            #cả hai bản giá đều có gia của unit
            else #không làm gi hết.

            productUnitList.push productId

          userUpdate = $set:{}
          userUpdate.$set["sessions.productUnitSelected.#{@_id}"] = []
          userUpdate.$set['sessions.currentPriceBook'] = priceBookOfGroup._id
          Meteor.users.update(user._id, userUpdate)


  @findOneByOwner = (ownerId, priceBookType, merchantId = Merchant.getId()) ->
    priceBookQuery = {owner: ownerId, merchant: merchantId}
    if priceBookType is 'customers'           then priceBookQuery.priceBookType = 1
    else if priceBookType is 'customerGroups' then priceBookQuery.priceBookType = 2
    else if priceBookType is 'providers'      then priceBookQuery.priceBookType = 3
    else if priceBookType is 'providerGroups' then priceBookQuery.priceBookType = 4
    Schema.priceBooks.findOne priceBookQuery

  @findOneByUnitAndBuyer = (buyerId, merchantId = Session.get('merchant')._id) ->
    Schema.priceBooks.findOne({
      owner        : buyerId
      priceBookType : 1
      merchant      : merchantId})

  @findOneByUnitAndBuyerGroup = (buyerGroupId, merchantId = Session.get('merchant')._id) ->
    Schema.priceBooks.findOne({
      owner        : buyerGroupId
      priceBookType : 2
      merchant      : merchantId})

  @findOneByUnitAndProvider = (providerId, merchantId = Session.get('merchant')._id) ->
    Schema.priceBooks.findOne({
      owner        : providerId
      priceBookType : 3
      merchant      : merchantId})

  @findOneByUnitAndProviderGroup = (providerGroupId, merchantId = Session.get('merchant')._id) ->
    Schema.priceBooks.findOne({
      owner        : providerGroupId
      priceBookType : 4
      merchant      : merchantId})


  @insert: (ownerId, name) ->
    if !PriceBook.findOneByOwner(ownerId)
      Schema.priceBooks.insert {owner: ownerId, name: name}


  #xoa san pham vao bang priceBook basic
  @reUpdateByRemoveProduct: (productId)->
    if userId = Meteor.userId()
      merchantId = Meteor.users.findOne(userId).profile.merchant
      product = Schema.products.findOne({_id: productId, merchant: merchantId})
      priceBook = Schema.priceBooks.findOne({products: productId, priceBookType: 0, merchant: merchantId})
      Schema.priceBooks.update priceBook._id, {$pull: {products: productId}} if priceBook and !product


  #them san pham vao bang priceBook basic
  @addProduct: (productId)->
    if userId = Meteor.userId()
      merchantId = Meteor.users.findOne(userId).profile.merchant
      product    = Schema.products.findOne({_id: productId, merchant: merchantId})
      priceBook  = Schema.priceBooks.findOne({products: {$ne: productId}, priceBookType: 0, merchant: merchantId})
      Schema.priceBooks.update(priceBook._id, {$addToSet: {products: productId}}) if priceBook and product


  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profile.merchant}
    Schema.priceBooks.findOne(existedQuery)


  @setSession: (priceBookId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentPriceBook': priceBookId}})

#Dang FIx------------------------------------------->
findProductIndexAndPriceBookIndex = (productId, priceBookFormId, priceBookToId, merchantId = Merchant.getId())-> #ok
  query =
    productId          : undefined
    priceBookFromIndex : undefined
    priceBookToIndex   : undefined

    basicSale          : undefined
    salePrice          : undefined
    basicImport        : undefined
    importPrice        : undefined

  if productFound = Schema.products.findOne({_id: productId, merchant: merchantId})
    for item, index in productFound.priceBooks
      if item._id is priceBookFormId
        query.priceBookFromIndex = index
        query.basicSale          = item.basicSale if item.basicSale
        query.salePrice          = item.salePrice if item.salePrice

        query.basicImport        = item.basicImport if item.basicImport
        query.importPrice        = item.importPrice if item.importPrice

      if item._id is priceBookToId
        query.priceBookToIndex = index


    query.productId = productFound._id
  return query
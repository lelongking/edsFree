simpleSchema.priceBooks = new SimpleSchema
  name            : type: String ,unique  : true, index: 1
  owner           : type: String ,optional: true
  description     : type: String ,optional: true
  priceBookType   : type: Number ,defaultValue: 2
  products        : type: [Object] ,optional: true
  'products.$._id' : type: String
  'products.$.unit': type: String

  childPriceBooks : type: [String] , optional: true
  parentPriceBook : type: String   ,optional: true



  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version}
  isBase      :
    type: Boolean
    autoValue: ->
      if @isInsert
        return false
      else if @isUpsert
        return { $setOnInsert: false }

      return

Schema.add 'priceBooks', "PriceBook", class PriceBook
  @transform: (doc) ->
    doc.remove = ->
      if @allowDelete is true and @isBase is false
        if Schema.priceBooks.remove @_id
          products = Schema.products.find({'units.priceBooks.priceBook': @_id, merchant: Merchant.getId()}).fetch()
          for product in products
            unitDeleteQuery = $pullAll: {}
            for unit, unitIndex in product.units
              unitPrice = []

              for priceBook, index in unit.priceBooks
                if priceBook.priceBook is @_id
                  unitPrice.push priceBook

              unitDeleteQuery.$pullAll["units.#{unitIndex}.priceBooks"] = unitPrice
            Schema.products.update(product._id, unitDeleteQuery)

          basicPrice = Schema.priceBooks.findOne({isBase: true, merchant: Merchant.getId()})
          Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentPriceBook': basicPrice._id}})

    doc.updateProductUnitPrice = (productUnitId, salePrice, importPrice, callback) ->
      priceBookId = @_id; priceBookType = @priceBookType; priceBookIndex = undefined; productUnitIndex = undefined
      product = Schema.products.findOne({'units._id': productUnitId, merchant: Merchant.getId()})

      for unit, i in product.units
        if unit._id is productUnitId
          productUnitIndex = i

          for item, index in unit.priceBooks
            if item.priceBook is priceBookId
              priceBookIndex = index
              priceBookFound = item

      if productUnitIndex >= 0
        if @isBase
          if priceBookFound
            unitUpdateQuery = $set:{}; priceBookQuery = "units.#{productUnitIndex}.priceBooks"

            for item, index in product.units[productUnitIndex].priceBooks
              if salePrice and salePrice >= 0 and salePrice isnt priceBookFound.salePrice
                unitUpdateQuery.$set["#{priceBookQuery}.#{index}.basicSale"]         = salePrice
                unitUpdateQuery.$set["#{priceBookQuery}.#{index}.discountSalePrice"] = salePrice - item.salePrice
                if item.priceBook is priceBookId
                  unitUpdateQuery.$set["#{priceBookQuery}.#{index}.salePrice"]         = salePrice
                  unitUpdateQuery.$set["#{priceBookQuery}.#{index}.discountSalePrice"] = 0
                  unitUpdateQuery.$set["#{priceBookQuery}.#{index}.updateSalePriceAt"] = new Date()

              if importPrice and importPrice >= 0 and importPrice isnt priceBookFound.importPrice
                unitUpdateQuery.$set["#{priceBookQuery}.#{index}.basicImport"]         = importPrice
                unitUpdateQuery.$set["#{priceBookQuery}.#{index}.discountImportPrice"] = importPrice - item.importPrice
                if item.priceBook is priceBookId
                  unitUpdateQuery.$set["#{priceBookQuery}.#{index}.importPrice"]         = importPrice
                  unitUpdateQuery.$set["#{priceBookQuery}.#{index}.discountImportPrice"] = 0
                  unitUpdateQuery.$set["#{priceBookQuery}.#{index}.updateImportPriceAt"] = new Date()

            console.log unitUpdateQuery
            Schema.products.update(product._id, unitUpdateQuery) unless _.isEmpty(unitUpdateQuery.$set)

        else
          if priceBookIndex isnt undefined
            console.log 'update'
            unitUpdateQuery = $set:{}; priceBookQuery = "units.#{productUnitIndex}.priceBooks.#{priceBookIndex}"

            if _.contains([0, 1, 2], priceBookType)
              if salePrice and salePrice >= 0
                unitUpdateQuery.$set["#{priceBookQuery}.salePrice"]         = salePrice
                unitUpdateQuery.$set["#{priceBookQuery}.discountSalePrice"] = priceBookFound.basicSale - salePrice
                unitUpdateQuery.$set["#{priceBookQuery}.updateSalePriceAt"] = new Date()

            if _.contains([0, 3, 4], priceBookType)
              if importPrice and importPrice >= 0
                unitUpdateQuery.$set["#{priceBookQuery}.importPrice"]         = importPrice
                unitUpdateQuery.$set["#{priceBookQuery}.discountImportPrice"] = priceBookFound.basicImport - importPrice
                unitUpdateQuery.$set["#{priceBookQuery}.updateImportPriceAt"] = new Date()

            Schema.products.update(product._id, unitUpdateQuery, callback) unless _.isEmpty(unitUpdateQuery.$set)

          else
            console.log 'insert'
            unitUpdateQuery = $push: {}; priceBook = {priceBook: priceBookId}
            if _.contains([1, 2], priceBookType)
              if salePrice and salePrice >= 0 and salePrice isnt priceBookFound.salePrice
                priceBook.salePrice = salePrice
                unitUpdateQuery.$push["units.#{productUnitIndex}.priceBooks"] = priceBook

            if _.contains([3, 4], priceBookType)
              if importPrice and importPrice >= 0 and importPrice isnt priceBookFound.importPrice
                priceBook.importPrice = importPrice
                unitUpdateQuery.$push["units.#{productUnitIndex}.priceBooks"] = priceBook

            Schema.products.update(product._id, unitUpdateQuery, callback) unless _.isEmpty(unitUpdateQuery.$push)

    doc.deleteUnitPrice = (productUnitId)->
      product = Schema.products.findOne({'units._id': productUnitId, merchant: Merchant.getId()})
      for unit, i in product.units
        if unit._id is productUnitId
          productUnitIndex = i

          for item, index in unit.priceBooks
            priceBookDetail = item if item.priceBook is @_id

      if priceBookDetail
        unitDeleteQuery = $pull: {}
        unitDeleteQuery.$pull["units.#{productUnitIndex}.priceBooks"] = priceBookDetail
        Schema.products.update(product._id, unitDeleteQuery)

        for item, index in @products
          productUnit = item if item.unit is productUnitId
        Schema.priceBooks.update @_id, $pull: {products:productUnit} if productUnit

    doc.selectedPriceProduct = (productId)->
      if userId = Meteor.userId()
        if @priceBookType isnt 1
          userUpdate = $addToSet:{}; userUpdate.$addToSet["sessions.productUnitSelected.#{@_id}"] = productId
          Meteor.users.update(userId, userUpdate)

    doc.unSelectedPriceProduct = (productId)->
      if userId = Meteor.userId()
        userUpdate = $pull:{}; userUpdate.$pull["sessions.productUnitSelected.#{@_id}"] = productId
        Meteor.users.update(userId, userUpdate)

    doc.changePriceProductTo = (ownerId, model) ->
      if ownerId and (user = Meteor.users.findOne(Meteor.userId()))
        merchantId = user.profiles.merchant

        if model is 'customers'
          console.log 'is customer: ' + ownerId
          if customerFound = Schema.customers.findOne({_id: ownerId, merchant: merchantId})
            productUnitList = []; productUnitSelected = user.sessions.productUnitSelected[@_id]

            if !(priceBookOfGroup = PriceBook.findOneByOwner(customerFound._id, model))
              insertOption = {name: customerFound.name, owner: customerFound._id, priceBookType: 1}
              priceBookId = Schema.priceBooks.insert(insertOption)
              (priceBookOfGroup = Schema.priceBooks.findOne(priceBookId)) if priceBookId

        else if model is 'customerGroups'
          console.log 'is customerGroup: ' + ownerId
          if customerGroupFound = Schema.customerGroups.findOne({_id: ownerId, merchant: merchantId})
            productUnitList = []; productUnitSelected = user.sessions.productUnitSelected[@_id]

            if !(priceBookOfGroup = PriceBook.findOneByOwner(customerGroupFound._id, model))
              insertOption = {name: customerGroupFound.name, owner: customerGroupFound._id, priceBookType: 2}
              priceBookId = Schema.priceBooks.insert(insertOption)
              (priceBookOfGroup = Schema.priceBooks.findOne(priceBookId)) if priceBookId


        #phải có bảng giá và không trùng với bản giá sẽ cập nhật và không trùng với bản giá gốc
        if priceBookOfGroup and priceBookOfGroup._id isnt @_id and priceBookOfGroup.isBase isnt true
          console.log 'units:' + productUnitSelected
          for productUnitId in productUnitSelected
            query = findUnitIndexAndPriceBookIndex(productUnitId, @_id, priceBookOfGroup._id)
            console.log query
            if query.productUnitIndex >= 0
              #cả hai bản giá đều chưa có giá của unit
              if query.priceBookFromIndex isnt undefined and query.priceBookToIndex isnt undefined


              #bản giá cập nhật không có giá của unit dc chon
              else if query.priceBookFromIndex isnt undefined #lấy giá từ bảng gốc thêm vào bản cập nhật
                priceBook =
                  priceBook           : priceBookOfGroup._id
                  basicSale           : query.basicSale
                  salePrice           : query.salePrice
                  discountSalePrice   : query.discountSalePrice
                  updateImportPriceAt : new Date()

                unitUpdateQuery = $push: {}
                unitUpdateQuery.$push["units.#{query.productUnitIndex}.priceBooks"] = priceBook
                console.log unitUpdateQuery

                unless _.isEmpty(unitUpdateQuery.$push)
                  Schema.products.update(query.productId, unitUpdateQuery)
                  Schema.priceBooks.update @_id, $push: {products:{_id:query.productId, unit: productUnitId}}

  #                  cập nhật lại giá của bản giá cập nhật theo bản giá gốc
  #                unitUpdateQuery = $set:{}
  #                unitUpdateQuery.$set["units.#{productUnitIndex}.priceBooks.#{query.priceBookToIndex}.salePrice"] = query.salePrice
  #                unitUpdateQuery.$set["units.#{productUnitIndex}.priceBooks.#{query.priceBookToIndex}.discountSalePricesss"] = query.discountSalePrice
  #                Schema.products.update(query.productId, unitUpdateQuery) unless _.isEmpty(unitUpdateQuery.$set)



              #bản giá nguồn không có giá của unit dc chon, bản giá cập nhật có giá của unit
              else if query.priceBookToIndex isnt undefined #không làm gi hết.

              #cả hai bản giá đều có gia của unit
              else #không làm gi hết.

              productUnitList.push productUnitId

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

  @reUpdateByRemoveProductUnit: (productUnitId)->
    if userId = Meteor.userId()
      merchantId = Meteor.users.findOne(userId).profiles.merchant
      product = Schema.products.findOne({'units._id': productUnitId, merchant: merchantId})
      priceBook = Schema.priceBooks.findOne({productUnits: productUnitId, priceBookType: 0, merchant: merchantId})
      if priceBook and !product
        Schema.priceBooks.update priceBook._id, {$pull: {productUnits: productUnitId}}

  @addProductUnit: (productUnitId)->
    if userId = Meteor.userId()
      merchantId = Meteor.users.findOne(userId).profiles.merchant
      product = Schema.products.findOne({'units._id': productUnitId, merchant: merchantId})
      console.log product
      priceBook = Schema.priceBooks.findOne({productUnits: {$ne: productUnitId}, priceBookType: 0, merchant: merchantId})
      if priceBook and product
        Schema.priceBooks.update priceBook._id, {$addToSet: {productUnits: productUnitId}}

  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profiles.merchant}
    Schema.priceBooks.findOne(existedQuery)

  @setSession: (priceBookId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentPriceBook': priceBookId}})

findUnitIndexAndPriceBookIndex = (unitId, priceBookFormId, priceBookToId, merchantId = Merchant.getId())->
  query =
    productId          : undefined
    productUnitIndex   : undefined
    priceBookFromIndex : undefined
    priceBookToIndex   : undefined

    basicSale          : undefined
    salePrice          : undefined
    discountSalePrice  : 0

    basicImport        : undefined
    importPrice        : undefined
    discountImportPrice: 0

  if productFound = Schema.products.findOne({'units._id': unitId, merchant: merchantId})
    for unit, i in productFound.units
      if unit._id is unitId
        query.productUnitIndex = i

        for item, index in unit.priceBooks
          if item.priceBook is priceBookFormId
            query.priceBookFromIndex = index
            query.basicSale          = item.basicSale if item.basicSale
            query.salePrice          = item.salePrice if item.salePrice
            query.discountSalePrice  = item.discountSalePrice if item.discountSalePrice

            query.basicImport        = item.basicImport if item.basicImport
            query.importPrice        = item.importPrice if item.importPrice
            query.discountImportPrice= item.discountImportPrice if item.discountImportPrice

          if item.priceBook is priceBookToId
            query.priceBookToIndex = index


    query.productId = productFound._id
  return query
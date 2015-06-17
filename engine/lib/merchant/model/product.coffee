simpleSchema.products = new SimpleSchema
  name        : {type: String   ,unique  : true, index: 1}
  description : {type: String   ,optional: true}
  image       : {type: String   ,optional: true}
  groups      : {type: [String] ,defaultValue: []}

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version}

  units: type: [Object], optional: true
  'units.$._id'        : simpleSchema.UniqueId
  'units.$.barcode'    : simpleSchema.Barcode
  'units.$.name'       : simpleSchema.OptionalString
  'units.$.conversion' : simpleSchema.DefaultNumber(1)
  'units.$.importPrice': simpleSchema.DefaultNumber()
  'units.$.salePrice'  : simpleSchema.DefaultNumber()
  'units.$.isBase'     : simpleSchema.DefaultBoolean(false)
  'units.$.allowDelete': simpleSchema.DefaultBoolean()
  'units.$.createdAt'  : simpleSchema.DefaultCreatedAt

#  prices           : type: [Object], defaultValue: []
#  'prices.$.branch': type: String  , optional: true
#  'prices.$.unit'  : type: String
#  'prices.$.isBase': simpleSchema.DefaultBoolean(false)
#  'prices.$.sale'  : simpleSchema.DefaultNumber()
#  'prices.$.import': simpleSchema.DefaultNumber()

  qualities                        : type: [Object], optional: true
  'qualities.$.upperGapQuality'    : simpleSchema.DefaultNumber()
  'qualities.$.availableQuality'   : simpleSchema.DefaultNumber()
  'qualities.$.inOderQuality'      : simpleSchema.DefaultNumber()
  'qualities.$.inStockQuality'     : simpleSchema.DefaultNumber()
  'qualities.$.saleQuality'        : simpleSchema.DefaultNumber()
  'qualities.$.returnSaleQuality'  : simpleSchema.DefaultNumber()
  'qualities.$.importQuality'      : simpleSchema.DefaultNumber()
  'qualities.$.returnImportQuality': simpleSchema.DefaultNumber()

Schema.add 'products', "Product", class Product
  @transform: (doc) ->
    doc.unitName = doc.units[0].name if doc.units
    doc.unitCreate = (name = 'New')-> Schema.products.update @_id, {$push: { units:{} }}

    doc.unitUpdate = (unitId, option, callback) ->
      unitNameIsNotExist = true
      barcodeIsNotExit   = true

      for instance, i in @units
        unitNameIsNotExist = false if option.name and instance.name is option.name
        if instance._id is unitId
          updateIndex = i
          updateInstance = instance


      unitUpdateQuery = $set:{}
      if option.name and unitNameIsNotExist
        unitUpdateQuery.$set["units.#{updateIndex}.name"] = option.name

      if option.barcode and barcodeIsNotExit
        unitUpdateQuery.$set["units.#{updateIndex}.barcode"] = option.barcode

      if option.importPrice and option.importPrice >= 0
        unitUpdateQuery.$set["units.#{updateIndex}.importPrice"] = option.importPrice

      if option.salePrice and option.salePrice >= 0
        unitUpdateQuery.$set["units.#{updateIndex}.salePrice"] = option.salePrice

      if updateInstance.allowDelete and option.conversion and option.conversion >= 1
        unitUpdateQuery.$set["units.#{updateIndex}.conversion"] = option.conversion

      Schema.products.update(@_id, unitUpdateQuery, callback) unless _.isEmpty(unitUpdateQuery.$set)

    doc.unitRemove = (unitId, callback)->
      for instance, i in @units
        if instance._id is unitId
          removeIndex = i
          removeInstance = instance
          break

      if removeInstance and removeInstance.allowDelete and !removeInstance.isBase
        removeUnitQuery = { $pull:{ units: @units[removeIndex] } }
        Schema.products.update(@_id, removeUnitQuery, callback)

    doc.remove = (callback)->
      if @allowDelete
        Schema.products.remove @_id, callback

  @insert: ()->

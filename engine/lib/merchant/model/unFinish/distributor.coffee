simpleSchema.distributors = new SimpleSchema
  parentMerchant:
    type: String

  merchant:
    type: String

  creator:
    type: String

  name:
    type: String

  description:
    type: String
    optional: true

  representative:
    type: String
    optional: true

  builtIn:
    type: [String]
    optional: true

  importProductList:
    type: [String]
    optional: true

  phone:
    type: String
    optional: true

  allowDelete:
    type: Boolean
    defaultValue: true

  status:
    type: Boolean
    defaultValue: true

  avatar:
    type: String
    optional: true

  totalDebit:
    type: Number
    defaultValue: 0

  totalSales:
    type: Number
    defaultValue: 0

  styles:
    type: String
    defaultValue: Helpers.RandomColor()

  location: { type: simpleSchema.Location, optional: true }
  version: { type: simpleSchema.Version }

#-------------------------------------------------------------------
  customImportModeEnabled:
    type: Boolean
    defaultValue: true

  customImportPaid:
    type: Number
    defaultValue: 0

  customImportLoan:
    type: Number
    defaultValue: 0

  customImportDebt:
    type: Number
    defaultValue: 0

  customImportTotalCash:
    type: Number
    defaultValue: 0

  importPaid:
    type: Number
    defaultValue: 0

  importDebt:
    type: Number
    defaultValue: 0

  importTotalCash:
    type: Number
    defaultValue: 0
#---------------------------------
  returnImportModeEnabled:
    type: Boolean
    defaultValue: false

  currentReturn:
    type: String
    optional: true

  lastImport:
    type: String
    optional: true


Schema.add 'distributors', "Distributor", class Distributor
  @insideMerchant: (merchantId) -> @schema.find({parentMerchant: merchantId})
  @canDeleteByMe: () ->
    if userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
      @schema.find
        parentMerchant: userProfile.parentMerchant
        creator       : userProfile.user
        allowDelete   : true

  @createNew: (name, phone, address)->
    if userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
      distributor =
        parentMerchant   : userProfile.parentMerchant
        merchant         : userProfile.currentMerchant
        creator          : userProfile.user
        name             : name

      distributor.phone    = phone if phone
      distributor.location = {address: [address]} if address


      findDistributor =  Schema.providers.findOne({
        parentMerchant: distributor.parentMerchant
        name          : distributor.name
      })

      if findDistributor
        {error:'Tên nhà phân phối bị trùng lặp.'}
      else
        @schema.insert distributor, (error, result)-> if error then {error: error} else {result: result}
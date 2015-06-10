customerProfile = new SimpleSchema
  avatar      : simpleSchema.OptionalString
  gender      : simpleSchema.OptionalString
  address     : simpleSchema.OptionalString
  phone       : simpleSchema.OptionalString
  dateOfBirth : simpleSchema.OptionalString
  description : simpleSchema.OptionalString
  pronoun     : simpleSchema.OptionalString
  companyName : simpleSchema.OptionalString
  email       : simpleSchema.OptionalString

customerTransaction = new SimpleSchema
  salePaid     : simpleSchema.DefaultNumber()
  saleDebt     : simpleSchema.DefaultNumber()
  saleTotalCash: simpleSchema.DefaultNumber()

#----------------------------------------------------------------------------------------------------------------------
simpleSchema.customers = new SimpleSchema
  name   : simpleSchema.StringUniqueIndex
  areas  : simpleSchema.OptionalStringArray
  billNo : simpleSchema.OptionalString

  profiles:
    type: customerProfile
    optional: true

  transactions:
    type: customerTransaction
    optional: true

  merchant   : simpleSchema.DefaultMerchant
  allowDelete: simpleSchema.DefaultBoolean()
#  customerType :
  creator    : simpleSchema.DefaultCreator
  version    : { type: simpleSchema.Version }

Schema.add 'customers', "Customer", class Customer
  @insideMerchant: (merchantId) -> @schema.find({parentMerchant: merchantId})
  @insideBranch: (branchId) -> @schema.find({currentMerchant: branchId})
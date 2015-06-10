simpleSchema.transactions = new SimpleSchema
  parentMerchant:
    type: String
    optional: true

  merchant:
    type: String
    optional: true

  warehouse:
    type: String
    optional: true

  parent:
    type: String
    optional: true

  parentTransaction:
    type: String
    optional: true

  creator:
    type: String
    optional: true

  owner:
    type: String
    optional: true

  group:
    type: String

  receivable:
    type: Boolean

  allowDelete:
    type: Boolean
    defaultValue: true

  styles:
    type: String
    defaultValue: Helpers.RandomColor()

  version: {type: simpleSchema.Version}
#---------------------------------------------
  description:
    type: String
    optional: true

  debtBalanceChange:
    type: Number
    optional: true

  beforeDebtBalance:
    type: Number
    optional: true

  latestDebtBalance:
    type: Number
    optional: true

  debtDate:
    type: Date
    defaultValue: new Date()

  latestSale:
    type: String
    optional: true

  latestImport:
    type: String
    optional: true

  confirmed:
    type: Boolean
    defaultValue: false

  conformer:
    type: String
    optional: true

  conformedAt:
    type: Date
    optional: true

#---------------------------------------------
  totalCash:
    type: Number
    optional: true

  dueDay:
    type: Date
    optional: true

  status:
    type: String
    defaultValue: 'success'

  depositCash:
    type: Number
    optional: true

  debitCash:
    type: Number
    optional: true

Schema.add 'transactions', "Transaction", class Transaction
  @newBySale: (sale)->
    option =
      merchant    : sale.merchant
      warehouse   : sale.warehouse
      parent      : sale._id
      creator     : sale.seller
      owner       : sale.buyer
      styles      : sale.styles ? Helpers.RandomColor()
      group       : 'sale'
      receivable  : true
      totalCash   : sale.finalPrice
      depositCash : sale.deposit
      debitCash   : sale.debit
      allowDelete : false
    if sale.paymentMethod == 0
      option.dueDay = new Date()
      option.status = 'closed'
    else
#    transaction.dueDay = new Date()
      option.status = 'tracking'
    option._id = Schema.transactions.insert option
    option

  @newByReturn: (returns)->
    option =
      merchant    : returns.merchant
      warehouse   : returns.warehouse
      parent      : returns._id
      creator     : returns.creator
      owner       : Schema.sales.findOne(returns.sale).buyer
      group       : 'return'
      receivable  : false
      totalCash   : returns.finallyPrice
      depositCash : returns.finallyPrice
      debitCash   : 0
      dueDay      : new Date()
      allowDelete : false
      status      : 'closed'
    option._id = Schema.transactions.insert option
    option

  @newByImport: (imports)->
    option =
      merchant    : imports.merchant
      warehouse   : imports.warehouse
      parent      : imports._id
      owner       : imports.distributor
      creator     : Meteor.userId()
      group       : 'import'
      receivable  : false
      totalCash   : imports.totalPrice
      depositCash : imports.deposit
      debitCash   : imports.debit
      allowDelete : false

    if imports.debit == 0
      option.dueDay = new Date()
      option.status = 'closed'
    else
      option.status = 'tracking'

    option._id = Schema.transactions.insert option
    option

  @newByCustomer: (customerId, description, totalCash, depositCash, debtDate)->
    profile = Schema.userProfiles.findOne({user: Meteor.userId()})
    customer  = Schema.customers.findOne({_id: customerId, parentMerchant: profile.parentMerchant})
    if profile and customer and depositCash >= 0 and totalCash >= depositCash and (debtDate is undefined or debtDate < (new Date()))
      option =
        merchant    : profile.currentMerchant
        warehouse   : profile.currentWarehouse
        creator     : profile.user
        owner       : customer._id
        group       : 'customer'
        receivable  : true
        description : description
        totalCash   : totalCash
        depositCash : depositCash
        debitCash   : (totalCash - depositCash)
      option.debtDate = debtDate if debtDate

      if option.debit is 0
        option.dueDay = new Date()
        option.status = 'closed'
      else
        option.status = 'tracking'

      option._id = Schema.transactions.insert option
      if option._id
        TransactionDetail.newByTransaction(option)
        MetroSummary.updateMetroSummaryByNewTransaction(option.merchant, option.debitCash)
        Schema.customers.update customer._id, $inc:{totalPurchases: option.totalCash, totalDebit: option.debitCash}
        Meteor.call('checkExpireDateTransaction', option._id)
      option

  @newByDistributor: (distributorId, description, totalCash, depositCash, debtDate)->
    profile     = Schema.userProfiles.findOne({user: Meteor.userId()})
    distributor = Schema.distributors.findOne({_id: distributorId, parentMerchant: profile.parentMerchant})
    if profile and distributor and depositCash >= 0 and totalCash >= depositCash and (debtDate is undefined or debtDate < (new Date()))
      option =
        merchant    : profile.currentMerchant
        warehouse   : profile.currentWarehouse
        creator     : profile.user
        owner       : distributor._id
        group       : 'distributor'
        receivable  : false
        description : description
        totalCash   : totalCash
        depositCash : depositCash
        debitCash   : (totalCash - depositCash)
      option.debtDate = debtDate if debtDate

      if option.debit is 0
        option.dueDay = new Date()
        option.status = 'closed'
      else
        option.status = 'tracking'

      option._id = Schema.transactions.insert option
      if option._id
        TransactionDetail.newByTransaction(option)
        MetroSummary.updateMetroSummaryByNewTransaction(option.merchant, option.debitCash)

        setOption = {allowDelete: false}
        incOption = {totalSales: option.totalCash, totalDebit: option.debitCash}
        Schema.distributors.update distributor._id, $set: setOption, $inc: incOption
        Meteor.call('checkExpireDateTransaction', option._id)
      option

  @newByCustomSale: (customSaleId)->
    if profile = Schema.userProfiles.findOne({user: Meteor.userId()})
      if customSale = Schema.customSales.findOne({_id: customSaleId, parentMerchant: profile.parentMerchant})
        customer = Schema.customers.findOne({_id: customSale.buyer, parentMerchant: profile.parentMerchant})
        if customer and customSale.allowDelete is false and customSale.confirm is false
          option =
            merchant    : profile.currentMerchant
            warehouse   : profile.currentWarehouse
            creator     : profile.user
            parent      : customSale._id
            owner       : customer._id
            group       : 'customSale'
            receivable  : true
            description : customSale.description
            totalCash   : customSale.totalCash
            depositCash : customSale.depositCash
            debitCash   : (customSale.totalCash - customSale.depositCash)
            debtDate    : customSale.debtDate

          if option.debit is 0
            option.dueDay = new Date()
            option.status = 'closed'
          else
            option.status = 'tracking'

          if transactionId = Schema.transactions.insert option
            option._id = transactionId
            TransactionDetail.newByTransaction(option)
            #        MetroSummary.updateMetroSummaryByNewTransaction(option.merchant, option.debitCash)

            for customSaleDetail in Schema.customSaleDetails.find({customSale: customSale._id}).fetch()
              Schema.customSaleDetails.update customSaleDetail._id, $set: {allowDelete: false}
            Schema.customSales.update customSale._id, $set: {confirm: true}

            incCustomerOption = {totalCustomSaleDeposit: option.depositCash, totalCustomSalePurchases: option.totalCash}
            Schema.customers.update customer._id, $inc: incCustomerOption
            Meteor.call('checkExpireDateTransaction', option._id)

        return option

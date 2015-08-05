Enums = Apps.Merchant.Enums

simpleSchema.transactions = new SimpleSchema
  transactionName : type: String, defaultValue: 'ĐƠN HÀNG'
  transactionCode : type: String, optional: true
  description     : type: String, optional: true

  transactionType : type: Number  , defaultValue: Enums.getValue('TransactionTypes', 'provider')
  status          : type: Number  , defaultValue: Enums.getValue('TransactionStatuses', 'initialize')
  receivable      : type: Boolean , defaultValue: true  #true(no),false(tra)  ban hang (true), khach hang tra (false), nhap kho (true), tra NCC (false)
  owedCash        : type: Number  , defaultValue: 0     # so tien con no, luôn bang 0 neu receivable is  false
  owner           : type: String  , optional: true      # chu no (KH hoac NCC)
  parent          : type: String  , optional: true      # thong tin phiu ban, phiu nhap (Nhap - Ban - ko co) tuy theo
  dueDay          : type: Date    , optional: true      # han no
  isBeginCash     : type: Boolean , optional: true      # han no

  beforeDebtBalance: type: Number, defaultValue: 0
  debtBalanceChange: type: Number, defaultValue: 0
  paidBalanceChange: type: Number, defaultValue: 0
  latestDebtBalance: type: Number, defaultValue: 0

  merchant   : simpleSchema.DefaultMerchant
  allowDelete: simpleSchema.DefaultBoolean()
  creator    : simpleSchema.DefaultCreator
  version    : { type: simpleSchema.Version }

  details                : type: [Object], optional: true
  'details.$.transaction': type: String
  'details.$.paymentCash': type: Number

Schema.add 'transactions', "Transaction", class Transaction
  @transform: (doc) ->


  debtDate:
    type: Date
    defaultValue: new Date()

  paidDate:
    type: Date
    defaultValue: new Date()

  confirmed:
    type: Boolean
    defaultValue: false

  conformer:
    type: String
    optional: true

  conformedAt:
    type: Date
    optional: true

Enums = Apps.Merchant.Enums
simpleSchema.transactions = new SimpleSchema
  transactionName   : simpleSchema.DefaultString('ĐƠN HÀNG')
  transactionCode   : simpleSchema.OptionalString

  transactionType   : simpleSchema.DefaultNumber(Enums.getValue('TransactionTypes', 'import'))
  receivable        : type: Boolean #phai thu neu true
  owedCash          : type: Number, optional: true # luôn bang 0 neu receivable is  false

  status            : simpleSchema.DefaultNumber(Enums.getValue('TransactionStatuses', 'initialize'))
  owner             : simpleSchema.OptionalString
  staff             : simpleSchema.OptionalString # co neu phiu no
  parent            : simpleSchema.OptionalString # thong tin phiu ban, nhap

  description  : simpleSchema.OptionalString
  dueDay       : type: Date, optional: true #han tra tuy theo co the co

  beforeDebtBalance: type: Number, optional: true
  debtBalanceChange: type: Number, optional: true
  latestDebtBalance: type: Number, optional: true

  merchant   : simpleSchema.DefaultMerchant
  allowDelete: simpleSchema.DefaultBoolean()
  creator    : simpleSchema.DefaultCreator
  version    : { type: simpleSchema.Version }

  details                : type: [Object], defaultValue: []
  'details.$.transaction': type: String
  'details.$.paymentCash': type: String

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

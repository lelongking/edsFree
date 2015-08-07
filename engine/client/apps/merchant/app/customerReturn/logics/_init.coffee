Enums = Apps.Merchant.Enums
logics.customerReturn = {}
Apps.Merchant.customerReturnInit = []
Apps.Merchant.customerReturnReactiveRun = []


Apps.Merchant.customerReturnInit.push (scope) ->

Apps.Merchant.customerReturnReactiveRun.push (scope) ->
  if Session.get('mySession')
    scope.currentCustomerReturn = Schema.returns.findOne(Session.get('mySession').currentCustomerReturn)
    Session.set 'currentCustomerReturn', scope.currentCustomerReturn

    #load danh sach san pham cua phieu ban
    parent = Schema.orders.findOne(Session.get('currentCustomerReturn')?.parent)
    Session.set 'currentReturnParent', parent?.details

  #readonly 2 Select Khach Hang va Phieu Ban
  if customerReturn = Session.get('currentCustomerReturn')
    $(".customerSelect").select2("readonly", false)
    $(".orderSelect").select2("readonly", if customerReturn.owner then false else true)
  else
    $(".customerSelect").select2("readonly", true)
    $(".orderSelect").select2("readonly", true)
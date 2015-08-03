Enums = Apps.Merchant.Enums
logics.customerReturn = {}
Apps.Merchant.customerReturnInit = []
Apps.Merchant.customerReturnReactiveRun = []


Apps.Merchant.customerReturnInit.push (scope) ->
  scope.ddd = 0


Apps.Merchant.customerReturnReactiveRun.push (scope) ->
  if Session.get('mySession')
    console.log Session.get('mySession').currentCustomerReturn
    scope.currentCustomerReturn = Schema.returns.findOne Session.get('mySession').currentCustomerReturn
    Session.set 'currentCustomerReturn', scope.currentCustomerReturn

  if newOwnerId = Session.get('currentCustomerReturn')?.owner
    if !(oldOwnerId = Session.get('currentOwner')?._id) or oldOwnerId isnt newOwnerId
      Session.set('currentCustomerReturn', Schema.returns.findOne newOwnerId)
  else
    Session.set 'currentCustomerReturn'


  if customerReturn = Session.get('currentCustomerReturn')
    $(".customerSelect").select2("readonly", false)
    $(".orderSelect").select2("readonly", if customerReturn.owner then true else false)
  else
    $(".customerSelect").select2("readonly", true)
    $(".orderSelect").select2("readonly", true)
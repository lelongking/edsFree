Enums = Apps.Merchant.Enums
logics.providerReturn = {}
Apps.Merchant.providerReturnInit = []
Apps.Merchant.providerReturnReactiveRun = []


Apps.Merchant.providerReturnInit.push (scope) ->

Apps.Merchant.providerReturnReactiveRun.push (scope) ->
  if Session.get('mySession')
    scope.currentProviderReturn = Schema.returns.findOne(Session.get('mySession').currentProviderReturn)
    Session.set 'currentProviderReturn', scope.currentProviderReturn

    #load danh sach san pham cua phieu ban
    parent = Schema.imports.findOne(Session.get('currentProviderReturn')?.parent)
    Session.set 'currentReturnParent', parent?.details

  #readonly 2 Select Khach Hang va Phieu Ban
  if providerReturn = Session.get('currentProviderReturn')
    $(".providerSelect").select2("readonly", false)
    $(".importSelect").select2("readonly", if providerReturn.owner then false else true)
  else
    $(".providerSelect").select2("readonly", true)
    $(".importSelect").select2("readonly", true)
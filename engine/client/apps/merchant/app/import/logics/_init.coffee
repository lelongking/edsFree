logics.import = {}
Apps.Merchant.importInit = []
Apps.Merchant.importReload = []
Apps.Merchant.importReactive = []

Apps.Merchant.importInit.push (scope) ->
  scope.tabOptions =
    source: Import.findNotSubmitted()
    currentSource: 'currentImport'
    caption: 'importName'
    key: '_id'
    createAction  : -> Import.insert()
    destroyAction : (instance) -> if instance then Import.findNotSubmitted().count() if instance.remove() else -1
    navigateAction: (instance) -> Import.setSession(instance._id)

  scope.depositOptions =
    reactiveSetter: (val) -> scope.currentImport.changeField('depositCash', val)
    reactiveValue: -> Session.get('currentImport')?.depositCash ? 0
    reactiveMax: -> 99999999999
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  scope.discountOptions =
    reactiveSetter: (val) -> scope.currentImport.changeField('discountCash', val)
    reactiveValue: -> Session.get('currentImport')?.discountCash ? 0
    reactiveMax: -> Session.get('currentImport')?.totalPrice ? 0
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

Apps.Merchant.importReactive.push (scope) ->
  if Session.get('mySession')
    scope.currentImport = Schema.imports.findOne Session.get('mySession').currentImport
    Session.set 'currentImport', scope.currentImport

  if newProviderId = Session.get('currentImport')?.provider
    if !(oldProviderId = Session.get('currentProvider')?._id) or oldProviderId isnt newProviderId
      Session.set('currentProvider', Schema.providers.findOne newProviderId)
  else
    Session.set 'currentProvider'
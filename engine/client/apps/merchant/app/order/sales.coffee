scope = logics.sales

lemon.defineApp Template.sales,
  productTextSearch: -> ProductSaleSearch?.getCurrentQuery() ? ''
  allowCreateOrderDetail: -> if !scope.currentProduct then 'disabled'
  allowSuccessOrder: -> if Session.get('allowSuccess') then '' else 'disabled'
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined

  created: ->
    ProductSaleSearch.search('')
    Session.setDefault('globalBarcodeInput', '')


#    lemon.dependencies.resolve('saleManagement')
    Session.setDefault('allowCreateOrderDetail', false)
    Session.setDefault('allowSuccessOrder', false)


#    if mySession = Session.get('mySession')
#      Session.set('currentOrder', Schema.orders.findOne(mySession.currentOrder))
#      Meteor.subscribe('orderDetails', mySession.currentOrder)

  rendered: ->
    scope.templateInstance = @
    $(document).on "keypress", (e) -> scope.handleGlobalBarcodeInput(e)
#    $("[name=deliveryDate]").datepicker('setDate', scope.deliveryDetail?.deliveryDate)


  destroyed: ->
    $(document).off("keypress")

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      productSearch = Helpers.Searchify searchFilter
      if event.which is 17 then console.log 'up' else ProductSaleSearch.search productSearch

    "click .addSaleDetail": ->
      scope.currentOrder.addDetail(@_id); event.stopPropagation()

    "click .finish": (event, template)->
      scope.currentOrder.submit()

    "click .print-command": (event, template) -> window.print()

    "change [name='advancedMode']": (event, template) ->
      scope.templateInstance.ui.extras.toggleExtra 'advanced', event.target.checked

    "change [name ='deliveryDate']": (event, template) -> scope.updateDeliveryDate()

    'input .contactName': (event, template)->
      Helpers.deferredAction ->
        scope.updateDeliveryContactName(template.find(".contactName"))
      , "salesCurrentProductSearchProduct"

    'input .contactPhone': (event, template)->
      Helpers.deferredAction ->
        scope.updateDeliveryContactPhone(template.find(".contactPhone"))
      , "salesCurrentProductSearchProduct"

    'input .deliveryAddress': (event, template)->
      Helpers.deferredAction ->
        scope.updateDeliveryAddress(template.find(".deliveryAddress"))
      , "salesCurrentProductSearchProduct"

    'input .comment': (event, template)->
      Helpers.deferredAction ->
        scope.updateDeliveryComment(template.find(".comment"))
      , "salesCurrentProductSearchProduct"

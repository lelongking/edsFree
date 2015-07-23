scope = logics.billManager

lemon.defineApp Template.billManager,
  helpers:
    allBills: -> Schema.orders.find({orderType: 6}).map(
      (item) ->
        item.buyerName  = -> Schema.customers.findOne(item.buyer)?.name ? item.orderName
        item.sellerName = ->
          if user = Meteor.users.findOne(item.seller)
            user.profile?.name ? user.emails[0].address
          else
            'Khách Hàng'

        item

    )
#    allowCreateOrderDetail: -> if !scope.currentProduct then 'disabled'
#    allowSuccessOrder: -> if Session.get('allowSuccess') then '' else 'disabled'
#    avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
#
#  created: ->
#    Session.setDefault('globalBarcodeInput', '')
#
#
##    lemon.dependencies.resolve('saleManagement')
#    Session.setDefault('allowCreateOrderDetail', false)
#    Session.setDefault('allowSuccessOrder', false)


#    if mySession = Session.get('mySession')
#      Session.set('currentOrder', Schema.orders.findOne(mySession.currentOrder))
#      Meteor.subscribe('orderDetails', mySession.currentOrder)

  rendered: ->
#    scope.templateInstance = @
#    $(document).on "keypress", (e) -> scope.handleGlobalBarcodeInput(e)
#    $("[name=deliveryDate]").datepicker('setDate', scope.deliveryDetail?.deliveryDate)


#  destroyed: ->
#    $(document).off("keypress")

#  events:
#    "click .print-command": (event, template) -> window.print()
#    "keyup input[name='searchFilter']": (event, template) ->
#      searchFilter  = template.ui.$searchFilter.val()
#      productSearch = Helpers.Searchify searchFilter
#      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch
#
#    "click .addSaleDetail": ->
#      scope.currentOrder.addDetail(@_id); event.stopPropagation()
#
#    "click .finish": (event, template)->
#      scope.currentOrder.orderConfirm()


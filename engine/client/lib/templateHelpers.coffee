Template.registerHelper 'getSession', (sessionName)-> Session.get(sessionName)
Template.registerHelper 'sellerName', -> Session.get('myProfile')?.name ? 'Nhân Viên'

Template.registerHelper 'isRowEditing', -> Session.get("editingId") is @_id
Template.registerHelper 'totalPrice', -> if @totalPrice then @totalPrice else @price * @quality * @conversion

Template.registerHelper 'firstName', -> Helpers.firstName(@name ? @)
Template.registerHelper 'avatarUrl', -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
Template.registerHelper 'activeClass', (sessionName)-> if Session.get(sessionName)?._id is @_id  then 'active' else ''
Template.registerHelper 'isDisabled', (sessionName)-> if Session.get(sessionName) then '' else 'disabled'
Template.registerHelper 'isNotDisabled', (sessionName)-> if Session.get(sessionName) then '' else 'disabled'
Template.registerHelper 'isManager', -> User.hasManagerRoles()
Template.registerHelper 'formatNumberBeforeDebtBalance', -> accounting.formatNumber(@beforeDebtBalance) if @beforeDebtBalance isnt 0
Template.registerHelper 'showBeforeDebtBalance', -> @beforeDebtBalance isnt 0
Template.registerHelper 'showConversion', -> @conversion is 1
Template.registerHelper 'calculateTotalPrice', -> @quality * @price
Template.registerHelper 'calculateFinalPrice', -> @quality * (@price - @discountCash)


Template.registerHelper 'orderCode', (orderCode)->
  return orderCode if orderCode
  if @orderCode then @orderCode else '----/----'

Template.registerHelper 'transactionClass', (value)->
  if value is undefined then (if @receivable then 'receive' else 'paid')
  else (if value >= 0 then 'receive' else 'paid')

Template.registerHelper 'getBuyerName', (buyerId)-> Schema.customers.findOne(buyerId)?.name ? 'Khách hàng không tồn tại'
Template.registerHelper 'getSellerName', (sellerId)-> Meteor.users.findOne(sellerId)?.profile.name ? 'Nhân viên không tồn tại'
Template.registerHelper 'getProductName', (productId)-> Schema.products.findOne(productId)?.name ? 'Sản phẩm không tồn tại'
Template.registerHelper 'getProductBasicName', (unitId)-> Schema.products.findOne({'units._id': unitId})?.unitName()
Template.registerHelper 'getProductUnitName', (unitId)->
  if product = Schema.products.findOne({'units._id': unitId})
    productUnit = _.findWhere(product.units, {_id: unitId})
    productUnit.name


Template.registerHelper 'crossReturnAvailableQuantity', ->
  currentDetail = @; currentParent = Session.get('currentReturnParent')
  if currentDetail and currentParent

    for orderDetail in currentParent
      if orderDetail.productUnit is currentDetail.productUnit
        crossAvailable = orderDetail.availableBasicQuantity - currentDetail.returnQuantities

    if crossAvailable < 0
      crossAvailable = Math.ceil(Math.abs(crossAvailable/currentDetail.conversion))*(-1)
    else
      Math.ceil(Math.abs(crossAvailable/currentDetail.conversion))

    return {
      crossAvailable: crossAvailable
      isValid: crossAvailable > 0
      invalid: crossAvailable < 0
      errorClass: if crossAvailable >= 0 then '' else 'errors'
    }


#old----------------------------------------------->
Template.registerHelper 'systemVersion', -> Schema.systems.findOne()?.version ? '?'
Template.registerHelper 'currentAppInfo', -> Session.get("currentAppInfo")
Template.registerHelper 'appCollapseClass', -> if Session.get('collapse') then 'icon-angle-double-left' else 'icon-angle-double-right'

Template.registerHelper 'dayOfWeek', -> moment(Session.get('realtime-now')).format("dddd")
Template.registerHelper 'timeDMY', -> moment(Session.get('realtime-now')).format("DD/MM/YYYY")
Template.registerHelper 'timeHM', -> moment(Session.get('realtime-now')).format("HH:mm")
Template.registerHelper 'timeS', -> moment(Session.get('realtime-now')).format("ss")

Template.registerHelper 'sessionGet', (name) -> Session.get(name)
Template.registerHelper 'authenticated', (name) -> Meteor.userId() isnt null
Template.registerHelper 'metroUnLocker', (context) ->  if context < 1 then ' locked'
Template.registerHelper 'listToFormatNumber', (context) ->  accounting.formatNumber(context?.length ? 0)
Template.registerHelper 'formatNumber', (context) ->  accounting.formatNumber(context)
Template.registerHelper 'formatNumberAbs', (number) -> accounting.formatNumber(Math.abs(number))
Template.registerHelper 'formatNumberK', (context) ->  accounting.formatNumber(context/1000)

Template.registerHelper 'pad', (number) -> if number < 10 then '0' + number else number
Template.registerHelper 'round', (number) -> Math.round(number)
Template.registerHelper 'momentFromNow', (date) -> moment(date).fromNow()
Template.registerHelper 'momentFormat', (date, format) ->
  if date then moment(date).format(format)
  else '---/---/------'
Template.registerHelper 'momentCalendar', (date) -> moment(date).calendar()

Template.registerHelper 'productNameFromId', (id) -> Schema.products.findOne(id)?.name
Template.registerHelper 'productCodeFromId', (id) -> Schema.products.findOne(id)?.productCode
Template.registerHelper 'skullsNameFromId', (id) -> Schema.products.findOne(id)?.skulls
Template.registerHelper 'ownerNameFromId', (id) -> Schema.customers.findOne(id)?.name


Template.registerHelper 'genderString', (gender) -> if gender then 'Nam' else 'Nữ'
Template.registerHelper 'allowAction', (val) -> if val then '' else 'disabled'



Template.registerHelper 'crossBillAvailableQuantity', ->
  cross = logics.sales.validation.getCrossProductQuantity(@product, @branchProduct, @order)
  crossAvailable = if cross.product then (cross.product.availableQuantity - cross.quality) else 0
  if crossAvailable < 0
    crossAvailable = Math.ceil(Math.abs(crossAvailable/@conversionQuantity))*(-1)
  else
    Math.ceil(Math.abs(crossAvailable/@conversionQuantity))

  if cross.product.basicDetailModeEnabled is true
    return {
      crossAvailable: 0
      isValid: true
      invalid: false
      errorClass: ''
    }

    Schema.orderDetails.update @_id, $set:{inValid: false} if @inValid
  else
    if crossAvailable >= 0
      Schema.orderDetails.update @_id, $set:{inValid: false} if @inValid
    else
      Schema.orderDetails.update @_id, $set:{inValid: true} if !@inValid

    return {
      crossAvailable: crossAvailable
      isValid: crossAvailable > 0
      invalid: crossAvailable < 0
      errorClass: if crossAvailable >= 0 then '' else 'errors'
    }

Template.registerHelper 'aliasLetter', (fullAlias) -> fullAlias?.substring(0,1)

Template.registerHelper 'activeClassByCount', (count) -> if count > 0 then 'active' else ''
Template.registerHelper 'onlineStatus', (userId)->
  currentUser = Meteor.users.findOne(userId)
  if currentUser?.status?.online
    return 'online'
  else if currentUser?.status?.idle
    return 'idle'
  else
    return 'offline'

#Notifications----------------------------------------------->
Template.registerHelper 'notificationSenderAvatar', ->
  profile = Meteor.users.findOne(@sender)?.profile
  return undefined if !profile?.image
  AvatarImages.findOne(profile.image)?.url()
Template.registerHelper 'notificationSenderName', ->
  Meteor.users.findOne(@sender)?.profile?.name ? '?'

Template.registerHelper 'notificationSenderAlias', ->
  Meteor.users.findOne(@sender)?.profile?.name.split(' ').pop() ? '?'

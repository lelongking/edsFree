Template.registerHelper 'getSession', (sessionName)-> Session.get(sessionName)
Template.registerHelper 'sellerName', -> Session.get('myProfile')?.name ? 'Nhân Viên'

Template.registerHelper 'isRowEditing', -> Session.get("editingId") is @_id
Template.registerHelper 'totalPrice', -> if @totalPrice then @totalPrice else @price * @quality

Template.registerHelper 'firstName', -> Helpers.firstName(@name ? @)
Template.registerHelper 'avatarUrl', -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
Template.registerHelper 'activeClass', (sessionName)-> if Session.get(sessionName)?._id is @_id  then 'active' else ''
Template.registerHelper 'isDisabled', (sessionName)-> if Session.get(sessionName) then '' else 'disabled'
Template.registerHelper 'isNotDisabled', (sessionName)-> if Session.get(sessionName) then '' else 'disabled'



Template.registerHelper 'getBuyerName', (buyerId)-> Schema.customers.findOne(buyerId)?.name ? 'Khách hàng không tồn tại'
Template.registerHelper 'getProductName', (productId)-> Schema.products.findOne(productId)?.name ? 'Sản phẩm không tồn tại'
Template.registerHelper 'getProductUnitName', (unitId)->
  if product = Schema.products.findOne({'units._id': unitId})
    productUnit = _.findWhere(product.units, {_id: unitId})
    productUnit.name


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
Template.registerHelper 'momentFormat', (date, format) ->
  if date then moment(date).format(format)
  else '--/--/----'
Template.registerHelper 'momentCalendar', (date) -> moment(date).calendar()

Template.registerHelper 'productNameFromId', (id) -> Schema.products.findOne(id)?.name
Template.registerHelper 'productCodeFromId', (id) -> Schema.products.findOne(id)?.productCode
Template.registerHelper 'skullsNameFromId', (id) -> Schema.products.findOne(id)?.skulls
Template.registerHelper 'ownerNameFromId', (id) -> Schema.customers.findOne(id)?.name


Template.registerHelper 'genderString', (gender) -> if gender then 'Nam' else 'Nữ'
Template.registerHelper 'allowAction', (val) -> if val then '' else 'disabled'

Template.registerHelper 'crossBillAvailableQuality', ->
  cross = logics.sales.validation.getCrossProductQuality(@product, @branchProduct, @order)
  crossAvailable = if cross.product then (cross.product.availableQuality - cross.quality) else 0
  if crossAvailable < 0
    crossAvailable = Math.ceil(Math.abs(crossAvailable/@conversionQuality))*(-1)
  else
    Math.ceil(Math.abs(crossAvailable/@conversionQuality))

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
  profile = Schema.userProfiles.findOne({user: @sender})
  return undefined if !profile?.avatar
  AvatarImages.findOne(profile.avatar)?.url()
Template.registerHelper 'notificationSenderAlias', ->
  Schema.userProfiles.findOne({user: @sender})?.fullName.split(' ').pop() ? '?'

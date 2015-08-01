Enums = Apps.Merchant.Enums
scope = logics.turnoverStaff

lemon.defineApp Template.orderStaffHistorySection,
  created: ->
  helpers:
    historyOrder: -> findOderHistory()
    orderStatus: -> if @orderType is Enums.getValue('OrderTypes', 'success') then 'Hoàn Thành' else 'Đang Chờ Duyệt'
    totalTurnoverCash: ->
      total = 0
      findOderHistory().forEach((order)-> total += order.finalPrice)
      Meteor.users.update(Meteor.userId(), $set:{'profile.turnoverCash': total}) if total isnt Session.get('myProfile').turnoverCash
      total

findOderHistory = ->
  Schema.orders.find({
    seller  : Meteor.userId()
    merchant: Merchant.getId()
    orderType: {$in:[
      Enums.getValue('OrderTypes', 'tracking')
      Enums.getValue('OrderTypes', 'success')
    ]}
    orderStatus: {$in:[
      Enums.getValue('OrderStatus', 'accountingConfirm')
      Enums.getValue('OrderStatus', 'exportConfirm')
      Enums.getValue('OrderStatus', 'success')
      Enums.getValue('OrderStatus', 'finish')
    ]}
  })
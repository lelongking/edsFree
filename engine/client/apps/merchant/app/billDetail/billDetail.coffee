scope = logics.billDetail
Enums = Apps.Merchant.Enums
lemon.defineApp Template.billDetail,
  helpers:
    currentBill: -> Session.get('currentBillHistory')
    depositOptions: -> scope.depositOptions
    discountOptions: -> scope.discountOptions
    sellerSelectOptions: -> scope.sellerSelectOptions
    customerSelectOptions: -> scope.customerSelectOptions
    paymentMethodSelectOptions: -> scope.paymentMethodSelectOptions
    paymentsDeliverySelectOptions: -> scope.paymentsDeliverySelectOptions

  created: ->
    UnitProductSearch.search('')

  destroyed: ->
    Session.set("editingId")
    Session.set("currentBillHistory")

  events:
    "click .caption.inner": (event, template) ->
      scope.currentBillHistory.addDetail(@_id); event.stopPropagation() if User.hasManagerRoles()

    "click .accountingConfirm": (event, template) ->
      Meteor.call 'orderAccountConfirm', scope.currentBillHistory._id, (error, result) ->
        Meteor.call 'orderExportConfirm', scope.currentBillHistory._id, (error, result) ->
          Session.set("currentBillHistory")
          Session.set("editingId")
          Router.go 'billManager'

    "click .export-command": (event, template) ->
      dataArray = []; customer = Session.get("currentBuyer")
      headOrder    = ['Sản Phẩm', 'ĐVT', 'Thùng', 'Chai/Gói', '']
      headCustomer = ['Khách Hàng', 'Số ĐT', 'Địa Chỉ', 'Số Phiếu']
      headColumns = headOrder.concat(headCustomer)
      dataArray[index] = [head] for head, index in headColumns

      orderDataLength = 1
      if currentOrder = scope.currentBillHistory
        for detail in currentOrder.details
          orderDataLength += 1
          if product = Schema.products.findOne(detail.product)
            unitQuantity = if product.units[1] then Math.floor(detail.basicQuantity/product.units[1].conversion) else 0

            array = [
              product.name
              product.unitName()
              unitQuantity
              detail.basicQuantity
            ]
            dataArray[index].push(array[index] ? '') for head, index in headOrder


      customerData = [
        customer?.name
        customer?.profiles?.phone
        customer?.profiles?.address
        currentOrder.orderCode
      ]
      dataArray[index+headOrder.length].push(customerData[index] ? '') for head, index in headCustomer
      maxLength = 2
      maxLength = orderDataLength if orderDataLength > maxLength



      console.log 'export'
      link = window.document.createElement('a')
      link.setAttribute 'href', 'data:text/csv;charset=utf-8,' + encodeURI(Helpers.JSON2CSV(dataArray, maxLength))
      link.setAttribute 'download', 'xuat_kho.csv'
      link.click()
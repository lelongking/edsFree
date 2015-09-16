Enums = Apps.Merchant.Enums
lemon.defineApp Template.customerManagementNavigationPartial,
  events:
    "click .customerOldDebt": (event, template) ->
      oldDebt = Session.get("customerManagementOldDebt")
      if oldDebt is true
        Session.set("customerManagementOldDebt")
      else
        Session.set("customerManagementOldDebt", true)

    "click .customerPaid": (event, template) ->
      oldDebt = Session.get("customerManagementOldDebt")
      if oldDebt is false
        Session.set("customerManagementOldDebt")
      else
        Session.set("customerManagementOldDebt", false)

    "click .customerToSales": (event, template) ->
      if customer = Session.get("customerManagementCurrentCustomer")
        Meteor.call 'customerToOrder', customer._id, (error, result) -> if error then console.log error else Router.go('/sales')

    "click .customerExport": (event, template) ->
      dataArray = []; customer = Session.get("customerManagementCurrentCustomer")

      headOrder    = ['Phiếu Bán', 'Ngày Lập', 'Tên Hàng', 'Q.Cách', 'ĐVT', 'Thùng', 'Chai/Gói', 'Đơn Giá', 'Thành Tiền', '']
      headReturn   = ['Phiếu Trả', 'Ngày Lập', 'Tên Hàng', 'Q.Cách', 'ĐVT', 'Thùng', 'Chai/Gói', 'Đơn Giá', 'Thành Tiền', '']
      headCustomer = ['Khách Hàng', 'Số ĐT', 'Địa Chỉ', 'Nợ Đầu Kỳ', 'Thu Nợ Tong Kỳ']

      headColumns = headOrder.concat(headReturn).concat(headCustomer)
      dataArray[index] = [head] for head, index in headColumns

      orderDataLength = 1
      Schema.orders.find({
        buyer      : Session.get("customerManagementCustomerId")
        orderType  : Enums.getValue('OrderTypes', 'success')
        orderStatus: Enums.getValue('OrderStatus', 'finish')
      }).forEach(
        (order) ->
          for detail in order.details
            orderDataLength += 1
            if product = Schema.products.findOne(detail.product)
              fullName     = product.name.split('-')
              productName  = fullName[0].replace(/^\s*/, "").replace(/\s*$/, "")
              productSkull = if fullName[1] then fullName[1].replace(/^\s*/, "").replace(/\s*$/, "") else ""
              unitQuantity = if product.units[1] then Math.floor(detail.basicQuantity/product.units[1].conversion) else 0

              array = [
                order.orderCode
                moment(order.successDate).format('MM/DD/YYYY')
                productName
                productSkull
                product.unitName()
                unitQuantity
                detail.basicQuantity
                detail.price
                detail.price * detail.basicQuantity
              ]
              dataArray[index].push(array[index] ? '') for head, index in headOrder
      )

      returnDataLength = 1
      Schema.returns.find({
        owner       : Session.get("customerManagementCustomerId")
        returnType  : Enums.getValue('ReturnTypes', 'customer')
        returnStatus: Enums.getValue('ReturnStatus', 'success')
      }).forEach(
        (currentReturn) ->
          for detail in currentReturn.details
            returnDataLength += 1
            if product = Schema.products.findOne(detail.product)
              fullName     = product.name.split('-')
              productName  = fullName[0].replace(/^\s*/, "").replace(/\s*$/, "")
              productSkull = if fullName[1] then fullName[1].replace(/^\s*/, "").replace(/\s*$/, "") else ""
              unitQuantity = if product.units[1] then Math.floor(detail.basicQuantity/product.units[1].conversion) else 0

              array = [
                currentReturn.returnCode
                moment(currentReturn.successDate).format('MM/DD/YYYY')
                productName
                productSkull
                product.unitName()
                unitQuantity
                detail.basicQuantity
                detail.price
                detail.price * detail.basicQuantity
              ]
              dataArray[index+headOrder.length].push(array[index] ? '') for head, index in headReturn
      )

      customerData = [
        customer.name
        customer.profiles.phone
        customer.profiles.address
        customer.beginCash
        customer.paidCash
      ]
      dataArray[index+headOrder.length+headReturn.length].push(customerData[index] ? '') for head, index in headCustomer

      maxLength = 2
      maxLength = orderDataLength if orderDataLength > maxLength
      maxLength = returnDataLength if returnDataLength > maxLength

      link = window.document.createElement('a')
      link.setAttribute 'href', 'data:text/csv;charset=utf-8,' + encodeURI(Helpers.JSON2CSV(dataArray, maxLength))
      link.setAttribute 'download', 'upload_data.csv'
      link.click()


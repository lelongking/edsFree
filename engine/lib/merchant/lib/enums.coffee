Apps.Merchant.Enums.PermissionType = [
  _id: 0
  value  : 'admin'
  display: 'Quản Lý'
,
  _id: 1
  value  : 'accounting'
  display: 'Kế Toán'
,
  _id: 2
  value  : 'seller'
  display: 'Kinh Doanh'
]
Apps.Merchant.Enums.GenderTypes = [
  _id: false
  display: 'NỮ'
,
  _id: true
  display: 'NAM'
]

#----------Order---------->
Apps.Merchant.Enums.OrderTypes = [
  _id    : 0
  value  : 'initialize'
  display: 'theo doi'
,
  _id    : 1
  value  : 'tracking'
  display: 'moi tao'
,
  _id    : 2
  value  : 'success'
  display: 'moi tao'
,
  _id    : 3
  value  : 'fail'
  display: 'moi tao'
]

Apps.Merchant.Enums.OrderStatus = [
  _id    : 0
  value  : 'initialize'
  display: 'moi tao'
,
  _id    : 1
  value  : 'sellerConfirm'
  display: 'da kiem tra'
,
  _id    : 2
  value  : 'accountingConfirm'
  display: 'ke toan xac nhan'
,
  _id    : 3
  value  : 'exportConfirm'
  display: 'xuat hàng ra kho'
,
  _id    : 4
  value  : 'success'
  display: 'thanh cong'
,
  _id    : 5
  value  : 'fail'
  display: 'that bai'
,
  _id    : 6
  value  : 'importConfirm'
  display: 'tra hang vao kho'
,
  _id    : 7
  value  : 'finish'
  display: 'hoan tat'
]

Apps.Merchant.Enums.PaymentMethods = [
  _id    : 0
  value  : 'direct'
  display: 'TIỀN MẶT'
,
  _id: 1
  value  : 'debt'
  display: 'GHI NỢ'
]

Apps.Merchant.Enums.DeliveryTypes = [
  _id    : 0
  value  :'direct'
  display: 'TRỰC TIẾP'
,
  _id    : 1
  value  :'delivery'
  display: 'GIAO HÀNG'
]

#----------Delivery---------->
Apps.Merchant.Enums.DeliveryStatus =[
  _id    : 0
  value  :'unDelivered'
  display: 'chua giao hang'
,
  _id    : 1
  value  :'delivered'
  display: 'dang giao hang'
,
  _id    : 2
  value  :'failDelivery'
  display: 'giao hang that bai'
,
  _id    : 3
  value  :'successDelivery'
  display: 'giao hang thanh cong'
]


#----------Price-Book---------->
Apps.Merchant.Enums.PriceBookTypes = [
  _id    : 0
  value  : 'all'
  display: 'TOÀN BỘ'
,
  _id    : 1
  value  : 'customer'
  display: 'KHÁCH HÀNG'
#,
#  _id    : 2
#  value  : 'customerGroup'
#  display: 'NHÓM KHÁCH HÀNG'
,
  _id: 3
  value  : 'provider'
  display: 'NHÀ CUNG CẤP'
#,
#  _id    : 4
#  value  : 'providerGroup'
#  display: 'NHÓM NHÀ CUNG CẤP'
]


#----------Import---------->
Apps.Merchant.Enums.ImportTypes = [
  _id    : -2
  value  : 'inventorySuccess'
  display: 'xac nhan ton kho dau ky'
,
  _id    : -1
  value  : 'inventory'
  display: 'dau ky'
,
  _id    : 0
  value  : 'initialize'
  display: 'moi tao'
,
  _id    : 1
  value  : 'staffConfirmed'
  display: 'nhân viên đã xác nhận'
,
  _id    : 2
  value  : 'accountingWaiting'
  display: 'chờ xác nhận kết toán'
,
  _id    : 3
  value  : 'confirmedWaiting'
  display: 'cho kho xac nhan'
,
  _id    : 4
  value  : 'success'
  display: 'hoàn thành'
]

#----------Transaction---------->
Apps.Merchant.Enums.TransactionTypes = [
  _id    : 0
  value  : 'provider'
  display: 'Nha Cung Cap'
,
  _id    : 1
  value  : 'customer'
  display: 'Khach Hang'
,
  _id    : 2
  value  : 'other'
  display: 'Thu Chi'
]

Apps.Merchant.Enums.TransactionStatuses = [
  _id    : 0
  value  : 'initialize'
  display: 'moi tao'
,
  _id    : 1
  value  : 'tracking'
  display: 'Con No'
,
  _id    : 2
  value  : 'closed'
  display: 'Het No'
]


#----------Product---------->
Apps.Merchant.Enums.ProductStatuses = [
  _id    : 0
  value  : 'initialize'
  display: 'moi tao'
,
  _id    : 1
  value  : 'confirmed'
  display: 'da kiem tra'
]

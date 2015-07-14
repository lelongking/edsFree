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
  display: 'moi tao'
,
  _id    : 1
  value  : 'checked'
  display: 'da kiem tra'
,
  _id    : 2
  value  : 'seller'
  display: 'nhan vien xac nhan'
,
  _id    : 3
  value  : 'accounting'
  display: 'ke toan xac nhan'
,
  _id    : 4
  value  : 'export'
  display: 'kho xuat hang'
,
  _id    : 5
  value  : 'import'
  display: 'kho nhan hang'
,
  _id    : 6
  value  : 'success'
  display: 'ket thuc'
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
  value  : 'import'
  display: 'Nha Cung Cap'
,
  _id    : 1
  value  : 'sales'
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

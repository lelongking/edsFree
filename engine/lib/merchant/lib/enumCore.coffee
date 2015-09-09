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
#----------Group---------->
Apps.Merchant.Enums.GroupTypes = [
  _id    : 0
  value  : 'product'
  display: 'Sản Phẩm'
,
  _id    : 1
  value  : 'customer'
  display: 'Khách Hàng'
,
  _id    : 2
  value  : 'provider'
  display: 'Nhà Cung Cấp'
]

#----------Notification---------->
Apps.Merchant.Enums.NotificationGroups = [
  _id    : 0
  value  : 'productQuantity'
  display: 'sap het ton kho'
,
  _id    : 1
  value  : 'productExpire'
  display: 'sp het han'
,
  _id    : 2
  value  : 'newOrder'
  display: 'thanh cong'
,
  _id    : 3
  value  : 'fail'
  display: 'that bai'
]

#----------Order---------->
Apps.Merchant.Enums.OrderTypes = [
  _id    : 0
  value  : 'initialize'
  display: 'moi tao'
,
  _id    : 1
  value  : 'tracking'
  display: 'theo doi'
,
  _id    : 2
  value  : 'success'
  display: 'thanh cong'
,
  _id    : 3
  value  : 'fail'
  display: 'that bai'
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
  display: 'Nhà Cung Cấp'
,
  _id    : 1
  value  : 'customer'
  display: 'Khách Hàng'
,
  _id    : 2
  value  : 'return'
  display: 'Trả Hàng'
#,
#  _id    : 3
#  value  : 'other'
#  display: 'Thu Chi Khác'
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

Apps.Merchant.Enums.TransactionReceivable = [
  _id    : false
  value  : 'false'
  display: 'Phiếu Chi'
,
  _id    : true
  value  : 'true'
  display: 'Phiếu Thu'
]

#----------Return---------->
Apps.Merchant.Enums.ReturnTypes = [
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
  display: 'Khac'
]

Apps.Merchant.Enums.ReturnStatus = [
  _id    : 0
  value  : 'initialize'
  display: 'moi tao'
,
  _id    : 1
  value  : 'success'
  display: 'hoan thanh'
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

#---------Loại Hinh Cty---
Apps.Merchant.Enums.Product33Statuses = [
  _id    : 0
  value  : 'initialize'
  display: 'Cá Nhân'
,
  _id    : 1
  value  : 'confirmed'
  display: 'Đại Lý'
,
  _id    : 1
  value  : 'confirmed'
  display: 'CTCP'
,
  _id    : 1
  value  : 'confirmed'
  display: 'CT-TNHH'
,
  _id    : 1
  value  : 'confirmed'
  display: 'DNTN'
,
  _id    : 1
  value  : 'confirmed'
  display: 'DNNN'
,
  _id    : 1
  value  : 'confirmed'
  display: 'Cơ Sở'
,
  _id    : 1
  value  : 'confirmed'
  display: 'HTX'
]

#---------Khu Vuc 63 tinh thanh---
Apps.Merchant.Enums.Area = [
  _id    : 0
  value  : 'VN'
  display: 'Việt Nam'
  children : [
  ]
,
  _id    : 1
  value  : 'AG'
  display: 'An Giang'
  children : [
    _id    : 0
    value  : 'AP'
    display: 'An Phú'
  ,
    _id    : 1
    value  : 'CĐ'
    display: 'Châu Đốc'
  ,
    _id    : 2
    value  : 'CP'
    display: 'Châu Phú'
  ,
    _id    : 3
    value  : 'CT'
    display: 'Châu Thành'
  ,
    _id    : 4
    value  : 'LX'
    display: 'Long Xuyên'
  ,
    _id    : 5
    value  : 'VN'
    display: 'Tân Châu'
  ,
    _id    : 6
    value  : 'VN'
    display: 'Thoại Sơn'
  ,
    _id    : 7
    value  : 'VN'
    display: 'Tịnh Biên'
  ,
    _id    : 8
    value  : 'VN'
    display: 'Tri Tôn'
  ]
,
  _id    : 2
  value  : 'VT'
  display: 'Bà Rịa - Vũng Tàu'
  children : [
  ]
,
  _id    : 3
  value  : 'BL'
  display: 'Bạc Liêu'
  children : [
    _id    : 0
    value  : 'BL'
    display: 'Bạc Liêu'
  ,
    _id    : 1
    value  : 'ĐH'
    display: 'Đông Hải'
  ,
    _id    : 2
    value  : 'GR'
    display: 'Giá Rai'
  ,
    _id    : 3
    value  : 'HB'
    display: 'Hoà Bình'
  ,
    _id    : 4
    value  : 'HD'
    display: 'Hồng Dân'
  ,
    _id    : 5
    value  : 'PL'
    display: 'Phước Long'
  ,
    _id    : 6
    value  : 'VL'
    display: 'Vĩnh Lợi'
  ]
,
  _id    : 4
  value  : 'BK'
  display: 'Bắc Kạn'
  children : [
  ]
,
  _id    : 5
  value  : 'BG'
  display: 'Bắc Giang'
  children : [
  ]
,
  _id    : 6
  value  : 'BN'
  display: 'Bắc Ninh'
  children : [
  ]
,
  _id    : 7
  value  : 'BT'
  display: 'Bến Tre'
  children : [
  ]
,
  _id    : 8
  value  : 'BD'
  display: 'Bình Dương'
  children : [
  ]
,
  _id    : 9
  value  : 'BĐ'
  display: 'Bình Định'
  children : [
  ]
,
  _id    : 10
  value  : 'BP'
  display: 'Bình Phước'
  children : [
  ]
,
  _id    : 11
  value  : 'BT'
  display: 'Bình Thuận'
  children : [
  ]
,
  _id    : 12
  value  : 'CM'
  display: 'Cà Mau'
  children : [
    _id    : 0
    value  : 'CM'
    display: 'Cà Mau'
  ,
    _id    : 1
    value  : 'CN'
    display: 'Cái Nước'
  ,
    _id    : 2
    value  : 'ĐD'
    display: 'Đầm Dơi'
  ,
    _id    : 3
    value  : 'NC'
    display: 'Năm Căn'
  ,
    _id    : 4
    value  : 'NH'
    display: 'Ngọc Hiển'
  ,
    _id    : 5
    value  : 'PT'
    display: 'Phú Tân'
  ,
    _id    : 6
    value  : 'TB'
    display: 'Thới Bình'
  ,
    _id    : 7
    value  : 'TVT'
    display: 'Trần Văn Thời'
  ,
    _id    : 8
    value  : 'UM'
    display: 'U Minh'
  ]
,
  _id    : 13
  value  : 'CB'
  display: 'Cao Bằng'
  children : [
  ]
,
  _id    : 14
  value  : 'CT'
  display: 'Cần Thơ'
  children : [
    _id    : 0
    value  : 'BT'
    display: 'Quận Bình Thủy'
  ,
    _id    : 1
    value  : 'CR'
    display: 'Quận Cái Răng'
  ,
    _id    : 2
    value  : 'CĐ'
    display: 'Huyện Cờ Đỏ'
  ,
    _id    : 3
    value  : 'NK'
    display: 'Quận Ninh Kiều'
  ,
    _id    : 4
    value  : 'OM'
    display: 'Quận Ô Môn'
  ,
    _id    : 5
    value  : 'PĐ'
    display: 'Huyện Phong Điền'
  ,
    _id    : 6
    value  : 'TN'
    display: 'Quận Thốt Nốt'
  ,
    _id    : 7
    value  : 'TL'
    display: 'Huyện Thới Lai'
  ,
    _id    : 8
    value  : 'VT'
    display: 'Huyện Vĩnh Thạnh'
  ]
,
  _id    : 15
  value  : 'ĐN'
  display: 'Đà Nẵng'
  children : [
  ]
,
  _id    : 16
  value  : 'ĐL'
  display: 'Đắk Lắk'
  children : [
  ]
,
  _id    : 17
  value  : 'ĐN1'
  display: 'Đắk Nông'
  children : [
  ]
,
  _id    : 18
  value  : 'ĐN'
  display: 'Đồng Nai'
  children : [
  ]
,
  _id    : 19
  value  : 'ĐT'
  display: 'Đồng Tháp'
  children : [
  ]
,
  _id    : 20
  value  : 'ĐB'
  display: 'Điện Biên'
  children : [
  ]
,
  _id    : 21
  value  : 'GL'
  display: 'Gia Lai'
  children : [
  ]
,
  _id    : 22
  value  : 'HG'
  display: 'Hà Giang'
  children : [
  ]
,
  _id    : 23
  value  : 'HNA'
  display: 'Hà Nam'
  children : [
  ]
,
  _id    : 24
  value  : 'HN'
  display: 'Hà Nội'
  children : [
  ]
,
  _id    : 25
  value  : 'HT'
  display: 'Hà Tĩnh'
  children : [
  ]
,
  _id    : 26
  value  : 'HD'
  display: 'Hải Dương'
  children : [
  ]
,
  _id    : 27
  value  : 'HP'
  display: 'Hải Phòng'
  children : [
  ]
,
  _id    : 28
  value  : 'HB'
  display: 'Hòa Bình'
  children : [
  ]
,
  _id    : 29
  value  : 'HG'
  display: 'Hậu Giang'
  children : [
  ]
,
  _id    : 30
  value  : 'HY'
  display: 'Hưng Yên'
  children : [
  ]
,
  _id    : 31
  value  : 'HCM'
  display: 'TP. Hồ Chí Minh'
  children : [
  ]
,
  _id    : 32
  value  : 'KH'
  display: 'Khánh Hòa'
  children : [
  ]
,
  _id    : 33
  value  : 'KG'
  display: 'Kiên Giang'
  children : [
  ]
,
  _id    : 34
  value  : 'KT'
  display: 'Kon Tum'
  children : [
  ]
,
  _id    : 35
  value  : 'LCH'
  display: 'Lai Châu'
  children : [
  ]
,
  _id    : 36
  value  : 'LC'
  display: 'Lào Cai'
  children : [
  ]
,
  _id    : 37
  value  : 'LS'
  display: 'Lạng Sơn'
  children : [
  ]
,
  _id    : 38
  value  : 'LĐ'
  display: 'Lâm Đồng'
  children : [
  ]
,
  _id    : 39
  value  : 'LA'
  display: 'Long An'
  children : [
  ]
,
  _id    : 40
  value  : 'NĐ'
  display: 'Nam Định'
  children : [
  ]
,
  _id    : 41
  value  : 'NA'
  display: 'Nghệ An'
  children : [
  ]
,
  _id    : 42
  value  : 'NB'
  display: 'Ninh Bình'
  children : [
  ]
,
  _id    : 43
  value  : 'NT'
  display: 'Ninh Thuận'
  children : [
  ]
,
  _id    : 44
  value  : 'PT'
  display: 'Phú Thọ'
  children : [
  ]
,
  _id    : 45
  value  : 'PY'
  display: 'Phú Yên'
  children : [
  ]
,
  _id    : 46
  value  : 'QB'
  display: 'Quảng Bình'
  children : [
  ]
,
  _id    : 47
  value  : 'QN'
  display: 'Quảng Nam'
  children : [
  ]
,
  _id    : 48
  value  : 'QNG'
  display: 'Quảng Ngãi'
  children : [
  ]
,
  _id    : 49
  value  : 'QNI'
  display: 'Quảng Ninh'
  children : [
  ]
,
  _id    : 50
  value  : 'QT'
  display: 'Quảng Trị'
  children : [
  ]
,
  _id    : 51
  value  : 'ST'
  display: 'Sóc Trăng'
  children : [
    _id    : 0
    value  : 'ST'
    display: 'Sóc Trăng'
  ,
    _id    : 1
    value  : 'ST'
    display: 'Châu Thành'
  ,
    _id    : 2
    value  : 'ST'
    display: 'Cù Lao Dung'
  ,
    _id    : 3
    value  : 'ST'
    display: 'Kế Sách'
  ,
    _id    : 4
    value  : 'ST'
    display: 'Long Phú'
  ,
    _id    : 5
    value  : 'ST'
    display: 'Mỹ Tú'
  ,
    _id    : 6
    value  : 'ST'
    display: 'Mỹ Xuyên'
  ,
    _id    : 7
    value  : 'ST'
    display: 'Ngã Năm'
  ,
    _id    : 8
    value  : 'ST'
    display: 'Thạnh Trị'
  ,
    _id    : 9
    value  : 'ST'
    display: 'Trần Đề'
  ,
    _id    : 10
    value  : 'ST'
    display: 'Vĩnh Châu'
  ]
,
  _id    : 52
  value  : 'SL'
  display: 'Sơn La'
  children : [
  ]
,
  _id    : 53
  value  : 'TN'
  display: 'Tây Ninh'
  children : [
  ]
,
  _id    : 54
  value  : 'TB'
  display: 'Thái Bình'
  children : [
  ]
,
  _id    : 55
  value  : 'TN'
  display: 'Thái Nguyên'
  children : [
  ]
,
  _id    : 56
  value  : 'TH'
  display: 'Thanh Hóa'
  children : [
  ]
,
  _id    : 57
  value  : 'TTH'
  display: 'Thừa Thiên - Huế'
  children : [
  ]
,
  _id    : 58
  value  : 'TG'
  display: 'Tiền Giang'
  children : [
  ]
,
  _id    : 59
  value  : 'TV'
  display: 'Trà Vinh'
  children : [
  ]
,
  _id    : 60
  value  : 'TQ'
  display: 'Tuyên Quang'
  children : [
  ]
,
  _id    : 61
  value  : 'VL'
  display: 'Vĩnh Long'
  children : [
  ]
,
  _id    : 62
  value  : 'VP'
  display: 'Vĩnh Phúc'
  children : [
  ]
,
  _id    : 63
  value  : 'initialize'
  display: 'Yên Bái'
  children : [
  ]
]
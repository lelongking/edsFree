lemon.defineApp Template.staffManagementNavigationPartial,
  helpers:
    showDetail: -> if Session.get('showCustomerListNotOfStaff') then 'Danh sách khách hàng' else 'Thêm khách hàng'
  events:
    "click .addCustomerToStaff": (event, template) ->
      Session.set('showCustomerListNotOfStaff', !Session.get('showCustomerListNotOfStaff'))
      Session.set('staffManagementCustomerListNotOfStaffSelect', [])
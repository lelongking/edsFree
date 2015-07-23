lemon.defineApp Template.orderManagers,
  rendered: ->
    $("[name=fromDate]").datepicker('setDate', Session.get('orderFilterStartDate'))
    $("[name=toDate]").datepicker('setDate', Session.get('orderFilterToDate'))

  events:
    "click .createSale": (event, template)-> Router.go('/sales')
    "click #filterBills": (event, template)->
      Session.set('orderFilterStartDate', $("[name=fromDate]").datepicker().data().datepicker.dates[0])
      Session.set('orderFilterToDate', $("[name=toDate]").datepicker().data().datepicker.dates[0])
    "click .thumbnails": (event, template) ->
#      Meteor.subscribe('saleDetails', @_id)
      Session.set('currentBillManagerSale', @)
      $(template.find '#salePreview').modal()
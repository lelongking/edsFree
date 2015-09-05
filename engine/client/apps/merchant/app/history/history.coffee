scope = logics.basicHistory

lemon.defineApp Template.basicHistory,
  created: ->
    option = {name: 'synthesisDebts',template: 'historySynthesisDebts', data: {}}
    Session.set("basicHistoryDynamics", option)

  helpers:
    basicHistoryDynamics: -> Session.get("basicHistoryDynamics")
    optionActiveClass: (templateName)-> 'active' if Session.get("basicHistoryDynamics").name is templateName

  events:
    "click .icon-print-6": (event, template)->
      name = 'tong_hop_cong_no_' + moment().format('MM/YYYY')
      blobURL = Apps.Merchant.tableToExcel('historyTable', 'W3C Example Table')
      $(event.target).attr 'download', name + '.xls'
      $(event.target).attr 'href', blobURL

logics.priceBook = {}
Apps.Merchant.priceBookInit = []
Apps.Merchant.priceBookReactive = []

Apps.Merchant.priceBookReactive.push (scope) ->
  scope.currentPriceBook = Schema.priceBooks.findOne(Session.get('mySession').currentPriceBook)
  Session.set "currentPriceBook", scope.currentPriceBook

Apps.Merchant.priceBookInit.push (scope) ->
  scope.getPriceBookPrevious = (search, current) ->
    PriceBookSearch.history[search].data.getPreviousBy('_id', Session.get('mySession').currentPriceBook)
  scope.getPriceBookNext     = (search) ->
    PriceBookSearch.history[search].data.getNextBy('_id', Session.get('mySession').currentPriceBook)

  scope.searchPriceBookSearchAndCreate = (event, template)->
    searchFilter  = template.ui.$searchFilter.val()
    priceBookSearch = Helpers.Searchify searchFilter
    Session.set("priceBookSearchFilter", searchFilter)

    if event.which is 17 then console.log 'up'
    else if event.which is 38
      PriceBook.setSession(previousRow._id) if previousRow = scope.getPriceBookPrevious(priceBookSearch)
    else if event.which is 40
      PriceBook.setSession(nextRow._id) if nextRow = scope.getPriceBookNext(priceBookSearch)
    else
      scope.createNewPriceBook(template, searchFilter) if event.which is 13
      PriceBookSearch.search priceBookSearch

  scope.createNewPriceBook = (template, searchFilter) ->
    if PriceBook.nameIsExisted(searchFilter, Session.get("myProfile").merchant)
      template.ui.$searchFilter.notify("Bảng giá đã tồn tại.", {position: "bottom"})
    else
      newPriceBookId = PriceBook.insert searchFilter
      if Match.test(newPriceBookId, String)
        PriceBook.setSession(newPriceBookId)
        PriceBookSearch.cleanHistory()
        PriceBookSearch.search PriceBookSearch.getCurrentQuery()





#  scope.checkAllowUpdateOverview = (template) ->
#    Session.set "priceBookManagementShowEditCommand",
#      template.ui.$priceBookName.val() isnt Session.get("priceBookManagementCurrentPriceBook").name or
#        template.ui.$priceBookPhone.val() isnt (Session.get("priceBookManagementCurrentPriceBook").profiles.phone ? '') or
#        template.ui.$priceBookAddress.val() isnt (Session.get("priceBookManagementCurrentPriceBook").profiles.address ? '')
#
#  scope.editPriceBook = (template) ->
#    priceBook = Session.get("priceBookManagementCurrentPriceBook")
#    if priceBook and Session.get("priceBookManagementShowEditCommand")
#      name    = template.ui.$priceBookName.val()
#      phone   = template.ui.$priceBookPhone.val()
#      address = template.ui.$priceBookAddress.val()
#
#      return if name.replace("(", "").replace(")", "").trim().length < 2
#      editOptions = Helpers.splitName(name)
#      editOptions.profiles.phone = phone if phone.length > 0
#      editOptions.profiles.address = address if address.length > 0
#
#      console.log editOptions
#
#      if editOptions.name.length > 0
#        priceBookFound = Schema.priceBooks.findOne {name: editOptions.name, parentMerchant: priceBook.parentMerchant}
#
#      if editOptions.name.length is 0
#        template.ui.$priceBookName.notify("Tên khách hàng không thể để trống.", {position: "right"})
#      else if priceBookFound and priceBookFound._id isnt priceBook._id
#        template.ui.$priceBookName.notify("Tên khách hàng đã tồn tại.", {position: "right"})
#        template.ui.$priceBookName.val editOptions.name
#        Session.set("priceBookManagementShowEditCommand", false)
#      else
#        Schema.priceBooks.update priceBook._id, {$set: editOptions}, (error, result) -> if error then console.log error
#        template.ui.$priceBookName.val editOptions.name
#        Session.set("priceBookManagementShowEditCommand", false)
#
#        PriceBookSearch.cleanHistory()
#        PriceBookSearch.search(PriceBookSearch.getCurrentQuery())
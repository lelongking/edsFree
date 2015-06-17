scope = logics.import

lemon.defineApp Template.import,
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
#  showEditImportCurrentProduct: ->
#    if product = Session.get('importCurrentProduct')
#      if product.price > 0 and product.importPrice > 0
#        if Session.get('showEditProduct') then true else false
#      else true
#    else false
#
#  productSelectionActiveClass: ->
#    if currentImport = Session.get('currentImport')
#      if @unit
#        if currentImport.currentUnit is @unit._id then 'active' else ''
#      else if !currentImport.currentUnit
#        if @product._id is currentImport.currentProduct then 'active' else ''

  created: ->
    UnitProductSearch.search('')
#    lemon.dependencies.resolve('importManagement')
#    Session.set("importManagementSearchFilter", "")
#    if Session.get("mySession")
#      if currentImport = Schema.imports.findOne(Session.get("mySession").currentImport)
#        Session.set('currentImport', currentImport)
#        Meteor.subscribe('importDetails', currentImport._id)
#
#        Session.set('importCurrentProduct', Schema.products.findOne currentImport.currentProduct)
#        scope.currentImportDetails = ImportDetail.findBy(currentImport._id)

  rendered: ->
    scope.templateInstance = @
#    @ui.$depositCash.inputmask("numeric", {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11})
#    @ui.$depositCash.val Session.get('currentImport')?.deposit ? 0

  events:
    "click .print-command": -> window.print()

    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      productSearch = Helpers.Searchify searchFilter
      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch

    'click .addImportDetail': (event, template)->
      scope.currentImport.addImportDetail(@_id)
      event.stopPropagation()

    'click .importSubmitted': (event, template)->
      if currentImport = Session.get('currentImport')
        importLists = Import.findNotSubmitted().fetch()
        if nextRow = importLists.getNextBy("_id", currentImport._id)
          Import.setSession(nextRow._id)
        else if previousRow = importLists.getPreviousBy("_id", currentImport._id)
          Import.setSession(previousRow._id)
        else
          Import.setSession(Import.insert())

        Meteor.call 'importSubmitted', currentImport._id, (error, result) -> if error then console.log error



#    'click .excel-import': (event, template) -> $(".excelFileSource").click()
#    'change .excelFileSource': (event, template) ->
#      if event.target.files.length > 0
#        console.log 'importing'
#        $excelSource = $(".excelFileSource")
#        $excelSource.parse
#          config:
#            complete: (results, file) ->
#              console.log file
#              console.log results
#              #              if file.name is "nhap_kho.csv"
#              #              if file.type is "text/csv" || file.type is "application/vnd.ms-excel"
#              logics.import.importFileProductCSV(results.data)
#
#
#        $excelSource.val("")

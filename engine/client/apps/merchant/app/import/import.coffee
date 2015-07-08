scope = logics.import

lemon.defineApp Template.import,
  created: ->  UnitProductSearch.search('')
  rendered: -> scope.templateInstance = @
  events:
    "click .print-command": -> window.print()

    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      productSearch = Helpers.Searchify searchFilter
      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch

    'click .addImportDetail': (event, template)->
      scope.currentImport.addImportDetail(@_id) if @inventoryInitial
      event.stopPropagation()

    'click .importSubmit': (event, template)->
      if currentImport = Session.get('currentImport')
        importLists = Import.findNotSubmitted().fetch()
        if nextRow = importLists.getNextBy("_id", currentImport._id)
          Import.setSession(nextRow._id)
        else if previousRow = importLists.getPreviousBy("_id", currentImport._id)
          Import.setSession(previousRow._id)
        else
          Import.setSession(Import.insert())

        scope.currentImport.importSubmit()



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

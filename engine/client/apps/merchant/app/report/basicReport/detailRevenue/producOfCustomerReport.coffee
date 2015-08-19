scope = logics.basicReport

lemon.defineApp Template.productOfCustomerReport,
  helpers:
    customerSelectOptions: -> scope.customerSelectOptions

  rendered: ->
    nv.addGraph ->
      logics.basicReport.productOfCustomer = nv.models.pieChart()
      logics.basicReport.productOfCustomer.x((d)-> d.name )
      logics.basicReport.productOfCustomer.y((d)-> d.totalCash/1000000 )
      logics.basicReport.productOfCustomer.labelType("percent")
      logics.basicReport.productOfCustomer.showLabels(true)
      logics.basicReport.productOfCustomer.labelsOutside(true)


      d3.select('#productOfCustomer')
      .datum(logics.basicReport.products)
      .transition().duration(500)
      .call(logics.basicReport.productOfCustomer)
      nv.utils.windowResize(logics.basicReport.productOfCustomer.update())
      logics.basicReport.productOfCustomer
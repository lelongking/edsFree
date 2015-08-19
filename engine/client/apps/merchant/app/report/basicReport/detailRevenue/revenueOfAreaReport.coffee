scope = logics.basicReport

lemon.defineApp Template.revenueOfAreaReport,
  helpers:
    areaSelectOptions: -> scope.areaSelectOptions

  rendered: ->
    nv.addGraph ->
      #    tp = (key, y, e) ->
      #      console.log key
      #      '<h3>' + key.data.name + '</h3>' + '<p>!!' + y + '!!</p>' + '<p>Doanh So: ' + accounting.formatNumber(key.data.totalCash/1000000) + '</p>'
      #
      #    pieChart.tooltipContent(tp)

      logics.basicReport.revenueOfArea = nv.models.pieChart()
      logics.basicReport.revenueOfArea.x((d)-> d.name )
      logics.basicReport.revenueOfArea.y((d)-> d.totalCash/1000000 )
      logics.basicReport.revenueOfArea.labelType("percent")
      logics.basicReport.revenueOfArea.showLabels(true)
      logics.basicReport.revenueOfArea.labelsOutside(true)


      d3.select('#revenueOfAreaReport')
      .datum(logics.basicReport.customers)
      .transition().duration(500)
      .call(logics.basicReport.revenueOfArea)
      nv.utils.windowResize(logics.basicReport.revenueOfArea.update())
      logics.basicReport.revenueOfArea
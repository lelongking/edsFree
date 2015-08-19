scope = logics.basicReport

lemon.defineApp Template.revenueBasicCustomerReport,
  rendered: ->
    nv.addGraph ->
      customerGroups = Schema.customers.find({debtCash: {$gt: 0}},{$sort: {debtCash: -1}, limit: 20}).fetch()
      height = 500; width = 600
      pieChart = nv.models.pieChart()
      pieChart.x((d)-> d.name )
      pieChart.y((d)-> d.totalCash/1000000 )
      pieChart.labelType("percent")
      pieChart.showLabels(true)
      pieChart.labelsOutside(true)
#      pieChart.width(width).height(height)
  #    pieChart.valueFormat((d)-> accounting.formatNumber(d) + " Tr")



  #    tp = (key, y, e) ->
  #      console.log key
  #      '<h3>' + key.data.name + '</h3>' + '<p>!!' + y + '!!</p>' + '<p>Doanh So: ' + accounting.formatNumber(key.data.totalCash/1000000) + '</p>'
  #
  #    pieChart.tooltipContent(tp)

      d3.select('#revenueOfCustomerReport')
      .datum(customerGroups)
#      .attr('width', width).attr('height', height)
      .transition().duration(500)
      .call(pieChart)
      nv.utils.windowResize(pieChart.update)
      pieChart
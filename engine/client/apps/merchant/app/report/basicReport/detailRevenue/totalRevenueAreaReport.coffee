scope = logics.basicReport

lemon.defineApp Template.totalRevenueAreaReport,
  rendered: ->

    customerGroups = Schema.customerGroups.findOne({totalCash: {$gt: 0}})
    customers = Schema.customers.find({group: customerGroups._id, totalCash: {$gt: 0}}).fetch()

    height = 350; width = 350
    chart = nv.models.pieChart()
    chart.x((d) -> d.name )
    chart.y((d) -> d.totalCash/1000000)
    chart.labelType("percent")
    chart.valueFormat((d)-> accounting.formatNumber(d) + " Tr")
    chart.width(width).height(height)

#    tp = (key, y, e) ->
#      console.log key
#      '<h3>' + key.data.name + '</h3>' + '<p>!!' + y + '!!</p>' + '<p>Doanh So: ' + accounting.formatNumber(key.data.totalCash/1000000) + '</p>'
#
#    chart.tooltipContent(tp)

    d3.select('#totalRevenueArea')
    .datum(customers)
    .transition()
    .duration(500)
    .attr('width', width).attr('height', height)
    .call(chart)
    nv.utils.windowResize(chart.update)
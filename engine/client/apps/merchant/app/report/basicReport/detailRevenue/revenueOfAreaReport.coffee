scope = logics.basicReport

lemon.defineApp Template.revenueOfAreaReport,
  customerSelectOptions: -> scope.customerSelectOptions

  rendered: ->
    array = {}
    customer = Schema.customers.findOne({},{$sort: {billNo: -1}})
    order = Schema.orders.find({ buyer:customer._id }).forEach(
      (order) ->
        for item in order.details
          array[item.product] = {value: 0} unless array[item.product]
          array[item.product].value += item.quality * item.price
    )
    dataBarChart = [
      {
        key   : "Cumulative Return"
        values: []
      }
    ]
    dataPieChart = []

    for key, value of array
      productName = Schema.products.findOne(key).name
      dataBarChart[0].values.push({label: productName, value: value.value})
      dataPieChart.push({label: productName, value: value.value})

#    nv.addGraph ->
#      barChart = nv.models.discreteBarChart()
#      .x((d) -> d.label).y((d) -> d.value)
#      .staggerLabels(true).showValues(true).duration(250)
#
#      d3.select('#productByCustomer').datum(dataBarChart).call(barChart)
#      nv.utils.windowResize barChart.update
#      barChart

    nv.addGraph ->
      height = 350; width = 350
      pieChart = nv.models.pieChart()
      pieChart.x((d) -> d.label )
      pieChart.y((d) -> d.value/1000000)
      pieChart.labelType("percent")
      pieChart.showLabels(true)
      pieChart.valueFormat((d)-> accounting.formatNumber(d) + " Tr")
      pieChart.width(width).height(height)

      #    tp = (key, y, e) ->
      #      console.log key
      #      '<h3>' + key.data.name + '</h3>' + '<p>!!' + y + '!!</p>' + '<p>Doanh So: ' + accounting.formatNumber(key.data.totalCash/1000000) + '</p>'
      #
      #    pieChart.tooltipContent(tp)

      d3.select('#productByCustomer')
      .datum(dataPieChart)
      .transition()
      .duration(500)
      .attr('width', width).attr('height', height)
      .call(pieChart)
      nv.utils.windowResize(pieChart.update)
      pieChart
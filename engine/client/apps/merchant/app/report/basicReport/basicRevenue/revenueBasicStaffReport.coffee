scope = logics.basicReport

lemon.defineApp Template.revenueBasicStaffReport,
  rendered: ->
    nv.addGraph ->
      customerGroups = Meteor.users.find().fetch()
      console.log customerGroups
      height = 500; width = 600
      pieChart = nv.models.pieChart()
      pieChart.x((d)-> d.profile.name )
      pieChart.y((d)-> d.saleCash/1000000 )
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
scope = logics.basicReport

lemon.defineApp Template.revenueBasicAreaReport,
  created: ->
    Session.set('revenueBasicAreaReportView', 'totalCash')
    scope.dataView =
      x: ['x']
      totalCash: 0
      debtCash: 0
      beginCash: 0
      dataTotalCash :['data1']
      dataDebtCash  :['data2']
      dataBeginCash :['data3']

    Schema.customerGroups.find({totalCash: {$gt: 0}},{$sort: {totalCash: -1}}).forEach(
      (group) ->
        scope.dataView.x.push(group.name)
        beginCash = 0
        debtCash  = 0
        Schema.customers.find(group: group._id).forEach(
          (customer)->
            beginCash += (customer.beginCash ? 0)/1000000
            debtCash  += ((customer.debtCash ? 0) + (customer.loanCash ? 0))/1000000
        )
        scope.dataView.totalCash += Math.round(debtCash+beginCash)
        scope.dataView.debtCash  += Math.round(debtCash)
        scope.dataView.beginCash += Math.round(beginCash)

        scope.dataView.dataTotalCash.push(Math.round(debtCash+beginCash))
        scope.dataView.dataDebtCash.push(Math.round(debtCash))
        scope.dataView.dataBeginCash.push(Math.round(beginCash))
    )

  rendered: ->
    scope.revenueBasicArea =
      c3.generate
        bindto: '#revenueBasic'
        size: height: 600
        data:
          x: 'x'
          columns: [
            scope.dataView.x
            scope.dataView.dataTotalCash
          ]
          names: {
            data1: 'Tổng Doanh Số'
            data2: 'Doanh Số'
            data3: 'Nợ Củ'
          }
          type: 'bar'
          labels:
            format:
              data1: (v, id, i, j)-> v + ' Tr'
              data2: (v, id, i, j)-> v + ' Tr'
              data3: (v, id, i, j)-> v + ' Tr'

        axis:
          x: type: 'category'
          rotated: true
        legend: show: false
        tooltip:
          format:
#            title: (d) ->
#              'Data ' + d
            value: (value, ratio, id) ->
              if id is "data1"
                parseFloat(value*100/scope.dataView.totalCash).toFixed(2) + ' %'
              else if id is "data2"
                parseFloat(value*100/scope.dataView.debtCash).toFixed(2) + ' %'
              else if id is "data3"
                parseFloat(value*100/scope.dataView.beginCash).toFixed(2) + ' %'


  destroyed: ->
    logics.basicReport.revenueBasicArea.destroy()

  helpers:
    isActive: (show)->
      'active' if Session.get('revenueBasicAreaReportView') is show


  events:
    "click .showTotalCash": (event, template) ->
      Session.set('revenueBasicAreaReportView', 'totalCash')
      logics.basicReport.revenueBasicArea.unload({ids: ['data2', 'data3']})
      setTimeout (->
        logics.basicReport.revenueBasicArea.load({columns: [logics.basicReport.dataView.dataTotalCash]})
        return
      ), 300



    "click .showDebtCash": (event, template) ->
      Session.set('revenueBasicAreaReportView', 'debtCash')
      logics.basicReport.revenueBasicArea.unload({ids: ['data1', 'data3']})
      setTimeout (->
        logics.basicReport.revenueBasicArea.load({columns: [logics.basicReport.dataView.dataDebtCash]})
        return
      ), 300


    "click .showBeginCash": (event, template) ->
      Session.set('revenueBasicAreaReportView', 'beginCash')
      logics.basicReport.revenueBasicArea.unload({ids: ['data1','data2']})
      setTimeout (->
        logics.basicReport.revenueBasicArea.load({columns: [logics.basicReport.dataView.dataBeginCash]})
        return
      ), 300



#    nv.addGraph ->
#      customerGroups = Schema.customerGroups.find({totalCash: {$gt: 0}},{$sort: {totalCash: -1}}).fetch()
#      height = 500; width = 600
#      pieChart = nv.models.pieChart()
#      pieChart.x((d)-> d.name )
#      pieChart.y((d)-> d.totalCash/1000000 )
#      pieChart.labelType("percent")
#      pieChart.showLabels(true)
#      pieChart.labelsOutside(true)
##      pieChart.width(width).height(height)
#  #    pieChart.valueFormat((d)-> accounting.formatNumber(d) + " Tr")
#
#
#
#  #    tp = (key, y, e) ->
#  #      console.log key
#  #      '<h3>' + key.data.name + '</h3>' + '<p>!!' + y + '!!</p>' + '<p>Doanh So: ' + accounting.formatNumber(key.data.totalCash/1000000) + '</p>'
#  #
#  #    pieChart.tooltipContent(tp)
#
#      d3.select('#totalRevenueAll')
#      .datum(customerGroups)
##      .attr('width', width).attr('height', height)
#      .transition().duration(500)
#      .call(pieChart)
#      nv.utils.windowResize(pieChart.update)
#      pieChart
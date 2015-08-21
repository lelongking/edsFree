scope = logics.basicHistory

lemon.defineApp Template.historySynthesisDebts,
  created: ->
    Session.set('revenueBasicAreaReportView', 'totalCash')

  helpers:
    customerGroups: ->
      sumBeginCash  = 0
      sumDebtCash   = 0
      sumReturnCash = 0
      sumPaidCash   = 0
      sumTotalCash  = 0

      Schema.customerGroups.find({}).map(
        (customerGroup) ->
          customerGroup.beginCash  = 0
          customerGroup.debtCash   = 0
          customerGroup.returnCash = 0
          customerGroup.paidCash   = 0
          customerGroup.totalCash  = 0
          customerGroup.customerDetails =
            Schema.customers.find({group: customerGroup._id}).map(
              (customer) ->
                customer.beginCash  = 0 unless customer.beginCash
                customer.returnCash = 0 unless customer.returnCash
                customer.beginCash += customer.loanCash

                customerGroup.beginCash  += customer.beginCash
                customerGroup.debtCash   += customer.debtCash
                customerGroup.returnCash += customer.returnCash
                customerGroup.paidCash   += customer.paidCash

                customerGroup.totalCash  = customerGroup.beginCash + customerGroup.debtCash - customerGroup.returnCash - customerGroup.paidCash
                customer
            )


          sumBeginCash  += customerGroup.beginCash
          sumDebtCash   += customerGroup.debtCash
          sumReturnCash += customerGroup.returnCash
          sumPaidCash   += customerGroup.paidCash
          sumTotalCash  = sumBeginCash + sumDebtCash - sumReturnCash - sumPaidCash

          customerGroup.sumBeginCash  = sumBeginCash
          customerGroup.sumDebtCash   = sumDebtCash
          customerGroup.sumReturnCash = sumReturnCash
          customerGroup.sumPaidCash   = sumPaidCash
          customerGroup.sumTotalCash  = sumTotalCash

          customerGroup
      )
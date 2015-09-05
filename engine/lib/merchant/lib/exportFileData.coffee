Apps.Merchant.tableToExcel = do ->
  uri = 'data:application/vnd.ms-excel;base64,'
  template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40"><meta http-equiv="content-type" content="application/vnd.ms-excel; charset=UTF-8"><head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table>{table}</table></body></html>'

  base64 = (s) ->
    window.btoa unescape(encodeURIComponent(s))

  format = (s, c) ->
    s.replace /{(\w+)}/g, (m, p) ->
      c[p]

  (table, name) ->

    if !table.nodeType
      table = document.getElementById(table)
    ctx =
      worksheet: name or 'Worksheet'
      table: table.innerHTML
#    window.location.href = uri + base64(format(template, ctx))
#    return
    blob = new Blob([ format(template, ctx) ])
    blobURL = window.URL.createObjectURL(blob)
    blobURL

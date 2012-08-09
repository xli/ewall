
download_export_file = (url, file) ->
  $('#exporting_wall').html("<h2>Export finished</h2>")
  window.location.href = url + '.ewall?export_file=' + encodeURIComponent(file)

export_progress = (url, file) ->
  $.ajax
    url: url + '.json'
    dataType: 'json'
    data:
      file: file
    type: 'GET'
    success: (completed) ->
      if (completed == true)
        download_export_file url, file
      else
        setTimeout ->
          export_progress(url, file)
        , 1000

import_progress = (url) ->
  $.ajax
    url: url
    dataType: 'json'
    type: 'GET'
    success: (completed) ->
      if (completed == true)
        window.location.href = '/walls'
      else
        setTimeout ->
          import_progress(url)
        , 1000


$(document).ready ->
  if ($('#exporting_wall').length)
    exporting = $('#exporting_wall')
    file = exporting.data('export-file')
    url = exporting.data('url')
    export_progress(url, file)
  if ($('#importing_wall').length)
    exporting = $('#importing_wall')
    url = exporting.data('url')
    import_progress(url)
  if ($('.import-ewall').length)
    $('.import-ewall').click (e) ->
      $('#import_form').dialog
        title: 'Import wall'
        width: 400
        modal: true



download_export_file = (url, file) ->
  $('#exporting_wall').html("<h2>Export finished</h2>")
  window.location.href = url + '.ewall?export_file=' + encodeURIComponent(file)

export_progress = (url, file) ->
  $.ajax
    url: url + '.json'
    dataType: 'json'
    data:
      export_file: file
    type: 'GET'
    success: (completed) ->
      if (completed == true)
        download_export_file url, file
      else
        setTimeout ->
          export_progress(url, file)
        , 1000

$(document).ready ->
  if ($('#exporting_wall').length)
    exporting = $('#exporting_wall')
    file = exporting.data('export-file')
    url = exporting.data('url')
    export_progress(url, file)

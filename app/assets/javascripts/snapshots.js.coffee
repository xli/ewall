# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

update_status = ->
  $.ajax
    url: window.location.href
    dataType: 'json'
    type: 'GET'
    success: (snapshot) ->
      if snapshot.in_analysis != 100
        $('.snapshot-analysis .bar').css('width', snapshot.in_analysis + '%')
        update_status_later()
      else
        $('.snapshot-analysis .bar').css('width', '100%')
        setTimeout ->
          window.location.reload()
        , 1000

update_status_later = ->
  setTimeout ->
    update_status()
  , 1000

$(document).ready ->
  if $('.snapshot-analysis').length
    update_status_later()

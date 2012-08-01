
changeFromColumn = (element) ->
  fromColumnIndex = $(element).attr('data-change-from-position').split(' ')[0]
  return $($('td.column')[parseInt(fromColumnIndex, 10)])

viewLargerImage = (srcImg) ->
  identifier = srcImg.attr('data-identifier');
  saveButton = $('<button type="submit">Save</button>').addClass('btn btn-mini btn-primary');
  cardIdentifier = $('<input type="text"/>').attr('value', identifier);
  cardIdentifier.change (e) ->
    saveButton.html('Saving...').attr('disabled', true);
    $.ajax
      url: srcImg.attr('data-url')
      dataType: 'json'
      data:
        card:
          identifier: cardIdentifier.val()
      type: 'PUT'
      success: ->
        saveButton.html('Save').attr('disabled', false)
  img = $("<img/>" ).attr("src", srcImg.attr('src')).attr("width", '100%');
  cardIdentifierDiv = $("<div/>").addClass('form-inline').append(cardIdentifier).append(saveButton)
  div = $("<div/>").addClass('clearfix card').append(img).append(cardIdentifierDiv);
  div.dialog
    title: 'Card'
    width: 400
    modal: true
    close: ->
      div.remove()

window.showDiff = ->
  $('.columns-diff td img').popover({placement: 'top'}).dblclick (e) ->
    $('.columns-diff td img').popover('hide')
    viewLargerImage $(e.target)
  $('img.change-removed,img.change-move').hover (e) ->
    changeFromColumn(e.target).addClass('highlight')
  , (e) ->
    changeFromColumn(e.target).removeClass('highlight')


$(document).ready ->
  $('.different-snapshot-link').click (e) ->
    $('.different-snapshot-link').parent().removeClass('active')
    $(e.target).parent().addClass('active')
    $(e.target).parents('.btn-group').find('.dropdown-toggle .selection').html($(e.target).html())
  $('.different-snapshot-link:first').click();

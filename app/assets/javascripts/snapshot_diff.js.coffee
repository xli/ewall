
changeFromColumn = (element) ->
  fromColumnIndex = $(element).attr('data-change-from-position').split(' ')[0]
  return $($('td.column')[parseInt(fromColumnIndex, 10)])

viewLargerImage = (srcImg) ->
  identifier = srcImg.attr('data-identifier');
  saveButton = $('<button type="submit">Save</button>').addClass('btn btn-primary');
  cardIdentifier = $('<input type="text"/>').attr('value', identifier);
  cardIdentifierDiv = $("<div/>").addClass('card-identifier-form clearfix').append(cardIdentifier).append(saveButton)
  cardIdentifier.keydown (e) ->
    saveButton.html('Save')

  cardIdentifier.change (e) ->
    saveButton.addClass('disabled');
    $.ajax
      url: srcImg.attr('data-url')
      dataType: 'json'
      data:
        card:
          identifier: cardIdentifier.val()
      type: 'PUT'
      success: ->
        saveButton.html('Saved').removeClass('disabled')

  img = $("<img/>" ).attr("src", srcImg.attr('src')).attr("width", '100%');
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

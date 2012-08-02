# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


card = (index, element) ->
  return {
    index: index
    number: $(element).attr('id').replace('card_', '')
    description: $(element).find('.card-inner-wrapper').text().replace(/\n\s*\n\s*\#\d+\s*\n\s*\n\s*/m, '')
  }

render_cards = (cards) ->
  td = $("<td class='clearfix'/>")
  $.each cards, (index, card) ->
    div = $('<div class="card-icon clearfix" title="Not on the last wall snapshot"><span class="card-summary-number"></span><span class="card-summary"></span></div>')
    div.find('.card-summary-number').html('#' + card.number).attr('identifier', card.number)
    div.find('.card-summary').html(card.description)
    td.append(div)
  return td

show_diff = (columns, mingle_wall_columns) ->
  $.each columns, (index, cards) ->
    target = $(mingle_wall_columns[index])
    $.each cards, (i, card) ->
      card_img = $("<img class='card'/>").attr("src", card.image)
      card_div = target.find('.card-summary-number[identifier="' + card.identifier + '"]')[0]
      if (card_div)
        $(card_div).parent().css('opacity', '.2').attr('title', 'Found on the same column of last wall snapshot')
      else
        m = $('#mingle_wall').find('.card-summary-number[identifier="' + card.identifier + '"]')[0]
        if (m)
          $(m).parent().css("border", '2px dashed lightgreen').attr('title', 'Found on the different column of last wall snapshot').hover (e) ->
            target.append(card_img).addClass('highlight')
          , (e) ->
            target.append(card_img).removeClass('highlight')
            card_img.remove()
        else
          $('#mingle_wall').find('td.removed-cards').append(card_img)

show_heads = (heads, mingle_wall_heads) ->
  $.each heads, (index, card) ->
    card_img = $("<img class='card'/>").attr("src", card.image)
    if (mingle_wall_heads[index])
      $(mingle_wall_heads[index]).append(card_img)

$(document).ready ->
  if $('#mingle_wall').length
    $.ajax
      url: $('#mingle_wall').data('uri')
      dataType: 'json'
      type: 'GET'
      success: (resp) ->
        if resp.error
          $('#mingle_wall div').html('<div class="alert alert-error">'+resp.error+"</div>")
          return
        pool = $(resp.html.replace(/<img /g, '<span ')).find('#swimming-pool')
        pool.find('.lane-card-number').remove()
        column_heads = pool.find('.lane_header span').map (index, ele) ->
          return $(ele).text().trim()

        table = $('<table><thead><tr></tr></thead><tbody><tr></tr></tbody></table');
        head = table.find('thead tr')
        body = table.find('tbody tr')
        pool.find('#row_0 td').each (index, column) ->
          cards = $(column).find('.card-icon').map (index, element) ->
            return card(index, element)
          head.append($("<th/>").html(column_heads[index]))
          body.append(render_cards(cards))
        head.append($("<th class='removed-cards-head'/>").html("Unmatched Cards"))
        body.append($("<td class='removed-cards'/>"))
        $('#mingle_wall').html(table)
        show_heads(resp.snapshot_heads, head.find('th'))
        show_diff(resp.snapshot_columns, body.find('td'))

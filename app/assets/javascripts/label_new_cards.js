(function() {
  function updateTypeaheadImg($this) {
    var identifier = $this.$menu.find('.active').attr('data-value');
    var index = $this.source.indexOf(identifier);
    var img = $this.$element.data('source-img')[index];
    var root = $('#label_new_cards');
    root.find('.typeahead-img').attr('src', img);
  }

  $.fn.typeahead.Constructor.prototype.originalRender = $.fn.typeahead.Constructor.prototype.render
  $.fn.typeahead.Constructor.prototype.originalNext = $.fn.typeahead.Constructor.prototype.next
  $.fn.typeahead.Constructor.prototype.originalPrev = $.fn.typeahead.Constructor.prototype.prev
  $.fn.typeahead.Constructor.prototype.render = function (items) {
    this.originalRender(items);
    updateTypeaheadImg(this);
    return this
  }
  $.fn.typeahead.Constructor.prototype.next = function (event) {
    this.originalNext(event);
    updateTypeaheadImg(this);
  }
  $.fn.typeahead.Constructor.prototype.prev = function (event) {
    this.originalPrev(event);
    updateTypeaheadImg(this);
  }

  function startLableNewCards() {
    var newCards = $('.new-card img').toArray();
    var root = $('#label_new_cards');
    root.data('cards', newCards);
    root.data('cards-size', newCards.length);
    root.dialog({
      title: title(root),
      width: 930,
      modal: true,
      close: function() {
        // todo: refresh page, but not show labeling new cards dialog
      }
    });
    labelNextNewCard();
  }
  function title(root) {
    return 'Label New Cards (' + completed(root) + '/' + root.data('cards-size') + ')';
  }
  function completed(root) {
    return root.data('cards-size') - root.data('cards').length;
  }

  function labelNextNewCard() {
    var root = $('#label_new_cards');
    var next = root.data('cards').pop();
    if (next) {
      var completed_pers = completed(root) * 100/root.data('cards-size');
      root.dialog({title: title(root)});
      root.find('.progress .bar').css('width', completed_pers + '%');
      root.find('img.card').attr('src', next.src).fadeIn();
      root.find('form').attr('action', $(next).data('url'));
      root.find('input[name="card[positive]"]').val(1);

      var identifier = $(next).data('identifier');
      root.find('input[name="card[identifier]"]').val(identifier).focus().select();
      var typeahead_img = '/assets/card_not_found.png'
      if (identifier) {
        // convert to string, because it maybe number and got automatically converted to number in js
        identifier = identifier + '';
        var index = root.find('.typeahead').data('source').indexOf(identifier);
        if (index && index >= 0) {
          typeahead_img = root.find('.typeahead').data('source-img')[index];
        }
      }
      root.find('.typeahead-img').attr('src', typeahead_img);
    } else {
      $('#head_navbar_ul li[name="walls"] a')[0].click();
    }
  }

  $(document).ready(function() {
    if ($('.new-card').length > 0) {
      $('#label_new_cards .icon-thumbs-down').click(function(e) {
        $(e.target).siblings('input[name="card[positive]"]').val(0);
        $(e.target).parent('form').submit();
      });
      $("#label_new_cards form").bind('ajax:complete', function() {
        labelNextNewCard();
      });
      startLableNewCards();
    }
    $('.typeahead').typeahead();
  });
})();


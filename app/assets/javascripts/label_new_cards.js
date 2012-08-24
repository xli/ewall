(function() {
  function updateTypeaheadImg($this) {
    var activeItem = $this.$menu.find('.active')
    var identifier = activeItem.attr('data-value');
    var index = $this.source.indexOf(identifier);
    var img = $this.$element.data('source-img')[index];
    activeItem.append($("<img/>").attr("src", img));
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

  function startLabelNewCards() {
    var newCards = $('.new-card img').toArray();
    var root = $('#label_new_cards');
    root.data('cards', newCards);
    updateCardIndex(root, 0);
    root.dialog({
      title: title(root),
      width: 700,
      modal: true
    });
    labelNextNewCard();
  }
  function title(root) {
    return 'Label New Cards (' + completed(root) + '/' + root.data('cards').length + ')';
  }
  function currentCardIndex(root) {
    return root.data('label-index');
  }
  function updateCardIndex(root, index) {
    root.data('label-index', index);
  }
  function completed(root) {
    return currentCardIndex(root);
  }

  function labelNextNewCard() {
    var root = $('#label_new_cards');
    var next = root.data('cards')[currentCardIndex(root)];
    if (next) {
      labelCard(root, next);
    } else {
      $('#head_navbar_ul li[name="walls"] a')[0].click();
    }
  }
  function labelPrevCard() {
    var root = $('#label_new_cards');
    var next = root.data('cards')[currentCardIndex(root)];
    if (next) {
      labelCard(root, next);
    }
  }
  function labelCard(root, card) {
    var completed_pers = completed(root) * 100/root.data('cards').length;
    root.dialog({title: title(root)});
    root.find('.progress .bar').css('width', completed_pers + '%');
    root.find('img.card').attr('src', card.src).fadeIn();
    root.find('form').attr('action', $(card).data('url'));
    cardPositive(root).val(1);

    var identifier = $(card).data('identifier');
    cardIdentifier(root).val(identifier).focus().select();
  }
  function updateLocalCardObject() {
    var root = $('#label_new_cards');
    var card = root.data('cards')[currentCardIndex(root)];
    var identifier = cardIdentifier(root).val();
    $(card).data('identifier', identifier);
  }
  function cardIdentifier(root) {
    return root.find('input[name="card[identifier]"]');
  }
  function cardPositive(root) {
    return root.find('input[name="card[positive]"]');
  }

  $(document).ready(function() {
    if ($('.new-card').length > 0) {
      var root = $('#label_new_cards');
      root.find('.icon-thumbs-down').click(function(e) {
        var form = $(e.target).parents('form');
        cardIdentifier(form).val('');
        cardPositive(form).val(0);
        form.submit();
      });
      root.find('form').bind('ajax:complete', function() {
        updateLocalCardObject();
        updateCardIndex(root, currentCardIndex(root) + 1);
        labelNextNewCard();
      });
      root.find('.prev-image').click(function(e) {
        updateCardIndex(root, currentCardIndex(root) - 1);
        labelPrevCard();
      });
      startLabelNewCards();
    }
    $('.typeahead').typeahead();
  });
})();


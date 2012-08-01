
function initGallery() {
  var $gallery = $("#gallery");
  var $trash = $("#trash");
  $( "li", $gallery ).draggable({
    cancel: "a.ui-icon", // clicking an icon won't initiate dragging
    revert: "invalid", // when not dropped, the item will revert back to its initial position
    containment: "document", // stick to demo-frame if present
    helper: "clone",
    cursor: "move"
  });
  $trash.droppable({
    accept: "#gallery > li",
    activeClass: "ui-state-highlight",
    drop: function( event, ui ) {
      deleteImage( ui.draggable );
    }
  });
  $gallery.droppable({
    accept: "#trash li",
    activeClass: "custom-state-active",
    drop: function( event, ui ) {
      recycleImage( ui.draggable );
    }
  });

  $( "ul.gallery > li" ).click(function( event ) {
    var $item = $( this ),
      $target = $( event.target );
    if ( $target.is( "a.ui-icon-trash" ) ) {
      deleteImage( $item );
    } else if ( $target.is( "a.ui-icon-zoomin" ) ) {
      viewLargerImage( $target );
    } else if ( $target.is( "a.ui-icon-refresh" ) ) {
      recycleImage( $item );
    } else if ($target.is("a.card-identifier")) {
      viewLargerImage( $target );
    }

    return false;
  });
  
  // image preview function, demonstrating the ui.dialog used as a modal window
  function viewLargerImage($link) {
    var srcImg = $link.siblings( "img" );
    var identifier = srcImg.attr('data-identifier');
    var saveButton = $('<button type="submit">Save</button>').addClass('btn btn-mini btn-primary');
    var cardIdentifier = $('<input type="text"/>').attr('value', identifier);
    cardIdentifier.change(function(e) {
      saveButton.html('Saving...').attr('disabled', true);
      $.ajax({
        url: srcImg.attr('data-url'),
        dataType: 'json',
        data: {card: {identifier: cardIdentifier.val()}},
        type: 'PUT',
        success: function() {
          srcImg.siblings('a.card-identifier').html(cardIdentifier.val());
          saveButton.html('Save').attr('disabled', false);
        }
      });
    });
    
    var img = $("<img alt='" + srcImg.attr('alt') + "'/>" ).attr("src", srcImg.attr('src')).attr("width", '100%');
    var cardIdentifierDiv = $("<div/>").addClass('form-inline').append(cardIdentifier).append(saveButton)
    var div = $("<div/>").addClass('clearfix card').append(img).append(cardIdentifierDiv);
    div.dialog({
      title: 'Card',
      width: 400,
      modal: true,
      close: function() {div.remove();}
    });
  }
  var recycle_icon = "<a href='#' title='Recycle this image' class='ui-icon ui-icon-refresh'>Recycle image</a>";
  function deleteImage( $item ) {
    updatePositive($item, false, function(r) {
      $item.fadeOut(function() {
        var $list = $( "ul", $trash ).length ?
          $( "ul", $trash ) :
          $( "<ul class='gallery ui-helper-reset'/>" ).appendTo( $trash );

        $item.find( "a.ui-icon-trash" ).remove();
        $item.append( recycle_icon ).appendTo( $list ).fadeIn();
      });
    });
  }

  // image recycle function
  var trash_icon = "<a href='#' title='Delete this image' class='ui-icon ui-icon-trash'>Delete image</a>";
  function recycleImage( $item ) {
    updatePositive($item, true, function(r) {
      $item.fadeOut(function() {
        $item
          .find( "a.ui-icon-refresh" )
            .remove()
          .end()
          .append(trash_icon)
          .appendTo( $gallery )
          .fadeIn();
      });
    });
  }

  function updatePositive(item, value, callback) {
    $.ajax({
      url: item.find('img').attr('data-url'),
      dataType: 'json',
      data: {card: {positive: value}},
      type: 'PUT',
      success: callback
    });
  }
}
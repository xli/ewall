// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery.ui.all
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$(document).ready(function() {
  var active = $('#head_navbar_ul').data('active');
  if (active == 'home') {
    $('#brand').addClass('active')
  } else {
    $('#head_navbar_ul li[name="' + active + '"]').addClass('active');
  }

  $('input[value="Upload"]').click(function(e) {
    if ($('#snapshot_file').val() == '') {
      alert('Choose a card wall image to upload');
      return false;
    } else {
      inProgress("Upload");
      return true;
    }
  });

  if ($("#gallery").length) {
    initGallery();
  }
});

window.inProgress = function(title) {
  $('<div class="progress progress-striped"><div class="bar" style="width: 100%;"></div></div>').dialog({
    title: title + " in progress",
    width: 400,
    modal: true
  });
}

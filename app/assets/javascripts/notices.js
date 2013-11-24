$(document).ready(function () {
  $(document.body).trigger('NotificationRetrieval');
});

$(document).on('NotificationRetrieval', function () {
  retrieveNotifications();
});

var notificationPooling = true;

function onBlur() {
  notificationPooling = false;
}
function onFocus() {
  notificationPooling = true;
}

if (/*@cc_on!@*/false) { // check for Internet Explorer
  document.onfocusin = onFocus;
  document.onfocusout = onBlur;
} else {
  window.onfocus = onFocus;
  window.onblur = onBlur;
}

function retrieveNotifications(pollingTimeOut) {

  if (pollingTimeOut === undefined) {
    pollingTimeOut = 5000;
  }

  setTimeout(function () {
    if (notificationPooling) {
      var url = $('#notification_placeholder').data('url');
      $.get(url, function (response) {
        update_notifications(response);
      });
    }
    retrieveNotifications(pollingTimeOut);
  }, pollingTimeOut);
}

function update_notifications(data) {
  var old_counter = parseInt($("#notification_bubble").text());
  $('#notice_bar').html(data);
  var counter = $('#notice_bar').find('table').data('notice-count');
  if (counter !== old_counter) {
//    $("#notification_buble").slideUp(200).slideDown(200);
    $("#notification_bubble").css({opacity: 0}).text(counter)
        .css({top: '-10px'}).animate({top: '-1px', opacity: 1}, 500);
  }
}


import ToastActions from './react_app/actions/ToastNotificationActions';
import $ from 'jquery';

export function notify(notification) {
  ToastActions.addNotification(notification);
}

export function importFlashMessagesFromRails() {
  const notifications = $('#notifications').data().flash;

  notifications.forEach(notification => {
    let [type, message] = notification;

    // normalize rails flash names
    if (type === 'danger') {
      type = 'error';
    }

    notify({type: type, message: message});
  });
}

// clear all notifications when leaving the page
$(window).bind('beforeunload', function () {
  ToastActions.closeNotifications();
});

// load notifications from Rails
$(document).on('ContentLoad', function () {
  importFlashMessagesFromRails();
});

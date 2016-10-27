import AppDispatcher from '../dispatcher';
import {ACTIONS} from '../constants';
import AppEventEmitter from './AppEventEmitter';

const _notifications = {};

class NotificationsEventEmitter extends AppEventEmitter {
  constructor() {
    super();
  }

  getNotifications() {
    return (_notifications.data || []);
  }
}

const NotificationsStore = new NotificationsEventEmitter();

AppDispatcher.register(action => {
  switch (action.actionType) {
    case ACTIONS.RECEIVED_NOTIFICATIONS: {
      _notifications.data = action.response.notifications;

      NotificationsStore.emitChange();
      break;
    }
    case ACTIONS.NOTIFICATIONS_REQUEST_ERROR: {
      NotificationsStore.emitError(action.info);
      break;
    }

    default:
      // no op
      break;
  }
});

export default NotificationsStore;

import { combineReducers } from 'redux';
import statistics from './statistics';
import hosts from './hosts';
import notifications from './notifications/';
import toasts from './toasts';
import users from './users';
export default combineReducers({
  statistics,
  hosts,
  notifications,
  toasts,
  users
});

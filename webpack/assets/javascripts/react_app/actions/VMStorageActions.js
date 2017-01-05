import AppDispatcher from '../dispatcher';
import {ACTIONS} from '../constants';

export default {
  addController(attributes) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.CONTROLLER_ADDED,
      attributes
    });
  },
  removeController(id) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.CONTROLLER_REMOVED,
      id: id
    });
  },
  updateController(id, attributes) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.CONTROLLER_UPDATED,
      id: id,
      attributes: attributes
    });
  },
  addDisk(controllerId, diskId) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.DISK_ADDED,
      controllerId: controllerId,
      diskId: diskId
    });
  },
  removeDisk(controllerId, diskId) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.DISK_REMOVED,
      controllerId: controllerId,
      diskId: diskId
    });
  }
};

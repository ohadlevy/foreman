import AppDispatcher from '../dispatcher';
import ActionTypes from '../constants';

export default {
  receivedStatistics(rawStatistics) {
    AppDispatcher.dispatch({
      actionType: ActionTypes.RECEIVED_STATISTICS,
      rawStatistics
    });
  }
};

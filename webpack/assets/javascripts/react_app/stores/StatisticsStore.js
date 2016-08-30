import AppDispatcher from '../dispatcher';
import ActionTypes from '../constants';
import AppEventEmitter from './AppEventEmitter';

const _statistics = {};

class StatisticsEventEmitter extends AppEventEmitter {
  constructor() {
    super();
    super.setMaxListeners(20);
  }

  getStatisticsData(id) {
    _statistics[id] = _statistics[id] || { data: [] };

    return _statistics[id];
  }
}

const StatisticsStore = new StatisticsEventEmitter();

AppDispatcher.register(action => {
  switch (action.actionType) {
    case ActionTypes.RECEIVED_STATISTICS: {
      const item = action.rawStatistics;

      /*
       for playing
       setTimeout(()=> {
       _statistics[item.id] = _statistics[item.id] || {};
       _statistics[item.id].data = item.data || [];
       _statistics[item.id].isLoaded = true;

       StatisticsStore.emitChange();
       }, Math.random() * (7000 - 3000) + 3000);
       */

      _statistics[item.id] = _statistics[item.id] || {};
      _statistics[item.id].data = item.data || [];
      _statistics[item.id].isLoaded = true;

      StatisticsStore.emitChange({id: item.id});
      break;
    }

    default:
      // no op
      break;
  }
});

export default StatisticsStore;

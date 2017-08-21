import { applyMiddleware, createStore, compose } from 'redux';
import thunk from 'redux-thunk';
import createLogger from 'redux-logger';
import reducer from './reducers';
import throttle from 'lodash/throttle';

import { loadState, saveState } from '../common/sessionStorage';

const persistentState = loadState();

let middleware = [thunk];

if (process.env.NODE_ENV !== 'production' && !global.__testing__) {
  middleware = [...middleware, createLogger()];
}

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

const store = createStore(
  reducer,
  persistentState,
  composeEnhancers(applyMiddleware(...middleware))
);

store.subscribe(
  throttle(() => {
    saveState({
      // Initially caching only notification state, to avoid unplanned side effects
      notifications: store.getState().notifications
    });
  }),
  1000
);

export default store;

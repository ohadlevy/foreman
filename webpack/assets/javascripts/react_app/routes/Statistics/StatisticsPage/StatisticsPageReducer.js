import Immutable from 'seamless-immutable';

import {
  STATISTICS_PAGE_META_RESOLVED,
  STATISTICS_PAGE_META_FAILED,
  STATISTICS_PAGE_HIDE_LOADING,
  STATISTICS_DATA_REQUEST,
  STATISTICS_DATA_SUCCESS,
  STATISTICS_DATA_FAILURE,
} from '../constants';

const initialState = Immutable({
  statisticsMeta: [],
  charts: Immutable({}),
  message: { type: 'empty', text: '' },
  isLoading: true,
  hasError: false,
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case STATISTICS_PAGE_META_RESOLVED:
      return state.set('statisticsMeta', payload);
    case STATISTICS_PAGE_HIDE_LOADING:
      return state.set('isLoading', false);
    case STATISTICS_PAGE_META_FAILED:
      return state.merge(payload);
    case STATISTICS_DATA_REQUEST:
      return state.setIn(['charts', payload.id], payload);
    case STATISTICS_DATA_SUCCESS:
      return state.setIn(['charts', payload.id], {
        ...state.charts[payload.id],
        data: payload.data,
      });
    case STATISTICS_DATA_FAILURE:
      return state.setIn(['charts', payload.item.id], {
        ...state.charts[payload.item.id],
        error: payload.error,
      });

    default:
      return state;
  }
};

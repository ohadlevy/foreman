import Immutable from 'seamless-immutable';
import { STATUS } from '../../constants';
import {
  AUTO_COMPLETION_REQUEST,
  AUTO_COMPLETION_SUCCESS,
  AUTO_COMPLETION_FAILURE,
} from './AutoCompleteConstants';

const initialState = Immutable({
  options: [],
  status: 'PENDING',
  error: null,
  searchQuery: '',
});

export default (state = initialState, action) => {
  const { payload, type } = action;
  switch (type) {
    case AUTO_COMPLETION_REQUEST:
      return state.set('error', null).set('status', STATUS.PENDING);

    case AUTO_COMPLETION_SUCCESS:
      return state
        .set(
          'options',
          Object.keys(payload)
            .filter(k => !['query', 'url'].includes(k))
            .map(k => payload[k]),
        )
        .set('searchQuery', payload.query)
        .set('error', null)
        .set('status', STATUS.RESOLVED);

    case AUTO_COMPLETION_FAILURE:
      return state.set('error', payload.error).set('status', STATUS.ERROR);

    default:
      return state;
  }
};

import {
  USERS_PERSONAL_ACCESS_TOKEN_FORM_UPDATE,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED
} from '../../../consts';
import Immutable from 'seamless-immutable';
import { map } from 'lodash';

const initialState = Immutable({
  isOpen: false,
  attributes: {name: ''}
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED: {
      return state.set('isOpen', payload.isOpen);
    }

    case USERS_PERSONAL_ACCESS_TOKEN_FORM_UPDATE: {

      // newAttributes[payload.key] = payload.newValues;
      return state.set('attributes', ...state.attributes, payload.key: payload.newValues);
    }

    default: {
      return state;
    }
  }
};

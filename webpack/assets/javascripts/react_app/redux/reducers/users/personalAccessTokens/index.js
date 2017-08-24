import {
  USERS_PERSONAL_ACCESS_TOKEN_FORM_BUTTON,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED
} from '../../../consts';
import Immutable from 'seamless-immutable';

const initialState = Immutable({
  isOpen: false,
  isSuccessful: false,
  body: ''
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case USERS_PERSONAL_ACCESS_TOKEN_FORM_BUTTON: {
      return state.set('isOpen', false).set('isSuccessful', false).set('body', null);
    }

    case USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED: {
      return state.set('isOpen', true);
    }

    case USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS: {
      return state.set('isSuccessful', true).set('body', payload.body);
    }

    default: {
      return state;
    }
  }
};

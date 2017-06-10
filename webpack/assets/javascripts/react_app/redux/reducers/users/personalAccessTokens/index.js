import {
  USERS_PERSONAL_ACCESS_TOKEN_FORM_BUTTON,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED,
  USERS_PERSONAL_ACCESS_GET_REQUEST,
  USERS_PERSONAL_ACCESS_GET_SUCCESS,
  USERS_PERSONAL_ACCESS_GET_FAILURE

} from '../../../consts';
import Immutable from 'seamless-immutable';

const initialState = Immutable({
  isOpen: false,
  isSuccessful: false,
  body: '',
  tokens: []
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
      return state.set('isSuccessful', true).set('body', payload.body).set('tokens', [...state.tokens, payload.body]);
    }

    case USERS_PERSONAL_ACCESS_GET_REQUEST:
    case USERS_PERSONAL_ACCESS_GET_SUCCESS: {
      return state.set('tokens', payload.results);
    }

    case USERS_PERSONAL_ACCESS_GET_FAILURE: {
      return state.set(
        payload.id,
        { error: payload.error }
      );
    }

    default: {
      return state;
    }
  }
};

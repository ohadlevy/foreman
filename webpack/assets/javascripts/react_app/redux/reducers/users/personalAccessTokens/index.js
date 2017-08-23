import {
  USERS_PERSONAL_ACCESS_TOKEN_FORM_SUBMIT,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED
} from '../../../consts';
import Immutable from 'seamless-immutable';

const initialState = Immutable({
  isOpen: false,
  isSuccessful: false,
  body: '',
  attributes: { name: '' }
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED: {
      return state.set('isOpen', payload.isOpen);
    }

    case USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS: {
      return state.set('isSuccessful', payload.isSuccessful).set('body', payload.body);
    }

    case USERS_PERSONAL_ACCESS_TOKEN_FORM_SUBMIT: {
      return state.set('attributes', ...state.attributes, payload);
    }

    default: {
      return state;
    }
  }
};

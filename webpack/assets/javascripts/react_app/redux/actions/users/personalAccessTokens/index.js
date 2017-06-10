import {
  USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_UPDATE
} from '../../../consts';

export const showForm = personalAccessToken => {
  return {
    type: USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED,
    payload: { isOpen: true }
  };
};

export const updateForm = (key, newValues) => {
  return {
    type: USERS_PERSONAL_ACCESS_TOKEN_FORM_UPDATE,
    payload: {
      key,
      newValues
    }
  };
};

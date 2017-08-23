import {
  USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_SUBMIT,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_SUBMIT_FAILED
} from '../../../consts';
import API from '../../../../API';

export const showForm = personalAccessToken => {
  return {
    type: USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED,
    payload: { isOpen: true }
  };
};

export const showFormSuccess = body => {
  return {
    type: USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS,
    payload: { isSuccessful: true, body }
  };
};

export const submitForm = (values, userId) => {
  // TODO: maybe just pass the URL instead.
  const url = `/api/users/${userId}/personal_access_tokens`;

  API.post(url, values).done(formSubmitDone).fail(checkErrors);
  return {};
};

function formSubmitDone({ tokens }) {
  return {
    type: USERS_PERSONAL_ACCESS_TOKEN_FORM_SUBMIT,
    payload: tokens // check this
  };
}

function checkErrors({ jqXHR, textStatus, errorThrown }) {
  return {
    type: USERS_PERSONAL_ACCESS_TOKEN_FORM_SUBMIT_FAILED,
    payload: { jqXHR, textStatus, errorThrown } // check this
  };
}

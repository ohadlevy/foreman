import {
  USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS,
  USERS_PERSONAL_ACCESS_TOKEN_FORM_BUTTON
} from '../../../consts';
import { SubmissionError } from 'redux-form';

const fieldErrors = ({ error }) => {
  let errors = {};

  error.errors.forEach(key => {
    if (error.errors.hasOwnProperty(key)) {
      if (key === 'base') {
        errors._error = error.errors.base;
      } else {
        errors[key] = error.errors[key].join(', ');
      }
    }
  });
  return new SubmissionError(errors);
};

const checkErrors = response => {
  if (response.ok) {
    return response;
  }
  if (response.status === 422) {
    // Handle invalid form data
    return response.json().then(body => {
      throw fieldErrors(body);
    });
  }
  throw new SubmissionError({
    _error: [__('Error submitting data: ') + response.statusText]
  });
};

export const showForm = personalAccessToken => {
  return {
    type: USERS_PERSONAL_ACCESS_TOKEN_FORM_OPENED,
    payload: {}
  };
};

export const submitForm = (userId, name, expiresAt, csrfToken) => {
  let data = {
    name,
    // eslint-disable-next-line camelcase
    expires_at: expiresAt
  };
  let url = `/api/users/${userId}/personal_access_tokens`;

  return dispatch => {
    // TODO: extract into generic API handler once there are more use cases
    return fetch(url, {
      credentials: 'include',
      method: 'post',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify(data)
    })
      .then(checkErrors)
      .then(response => {
        return response
          .json()
          .then(body => ({
            type: USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS,
            payload: { body }
          }))
          .then(dispatch);
      })
      .catch(error => {
        // eslint-disable-next-line no-console
        console.log(error);
        throw error;
      });
  };
};

export const hideForm = () => {
  return {
    type: USERS_PERSONAL_ACCESS_TOKEN_FORM_BUTTON,
    payload: {}
  };
};

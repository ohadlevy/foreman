import React from 'react';
import { Field, reduxForm } from 'redux-form';
import { SubmissionError } from 'redux-form';

const renderField = ({ input, label, type, meta: { touched, error } }) =>
  <div>
    <label>
      {label}
    </label>
    <div>
      <input {...input} placeholder={label} type={type} />
      {touched &&
        error &&
        <span>
          {error}
        </span>}
    </div>
  </div>;

const checkErrors = (response) => {
  if (response.ok) {
    return response;
  }
  if (response.status === 422) {
    // Handle invalid form data
    return response.json().then(body => {
      throw new SubmissionError({
        name: body.error.errors.name.join(', '), // TODO: improve
        _error: __('Form is invalid.')
      });
    });
  }
  throw new SubmissionError({
    _error: __('Error submitting data: ') + response.statusText
  });
};

class TokenForm extends React.Component {
  submit(values, dispatch, props) {
    let userId = props.data.user_id;
    let data = {
      name: values.name
    };
    let url = `/api/users/${userId}/personal_access_tokens`;

    return fetch(url, {
      credentials: 'include',
      method: 'post',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': props.data['csrf-token']
      },
      body: JSON.stringify(data)
    }).then(checkErrors).then(response => {
      return response.json().then(props.showFormSuccess);
    });
  }

  render() {
    const { handleSubmit, submitting, error } = this.props;

    return (
      <form className="form-horizontal well" onSubmit={handleSubmit(this.submit)}>
      {error &&
        <strong>
          {error}
        </strong>}
      <Field
        name="name"
        type="text"
        component={renderField}
        label={__('Name')}
      />
      <button type="submit" disabled={submitting}>
         {__('Create')}
        </button>
      </form>
    );
  }
}
export default reduxForm({
  form: 'personal_access_token_create'
})(TokenForm);

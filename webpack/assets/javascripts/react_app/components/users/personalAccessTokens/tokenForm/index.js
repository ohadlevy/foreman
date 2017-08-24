import React from 'react';
import { reduxForm } from 'redux-form';
import Form from '../../../common/forms/Form';
import TextField from '../../../common/forms/TextField';
import { required, length, date } from 'redux-form-validators';

const validations = {
  name: [required(), length({ max: 254 })],
  // TODO: rename this var?
  // eslint-disable-next-line camelcase
  expires_at: [required(), date({ format: 'yyyy-mm-dd', '>': 'today' })]
};

// Reusable with any other form
const validate = values => {
  const errors = {};

  Object.keys(validations).forEach(field => {
    let value = values[field];

    errors[field] = validations[field]
      .map(validateField => {
        return validateField(value, values);
      })
      .find(x => x);
  });
  return errors;
};

class TokenForm extends React.Component {
  // eslint-disable-next-line camelcase
  submit({ name, expires_at }, dispatch, props) {
    return props.submitForm(props.data.user_id, name, expires_at, props.data['csrf-token']);
  }

  render() {
    const { handleSubmit, submitting, error, anyTouched } = this.props;

    return (
      <Form
        onSubmit={handleSubmit(this.submit)}
        onCancel={this.props.hideForm}
        disabled={submitting}
        submitting={submitting}
        touched={anyTouched}
        error={error}
      >
        <TextField name="name" type="text" required="true" label={__('Name')} />
        <TextField name="expires_at" type="date" label={__('Expires at')} />
      </Form>
    );
  }
}
export default reduxForm({
  form: 'personal_access_token_create',
  validate
})(TokenForm);

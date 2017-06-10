import React from 'react';
import { reduxForm } from 'redux-form';
import Form from '../../../common/forms/Form';
import TextField from '../../../common/forms/TextField';
import { required, length, date } from 'redux-form-validators';
import * as FormActions from '../../../../redux/actions/common/forms';

const validations = {
  name: [required(), length({ max: 254 })],
  // TODO: rename this var?
  // eslint-disable-next-line camelcase
  expires_at: [date({ unless: value => { return value.expires_at === undefined; }, format: 'yyyy-mm-dd', '>': 'today' })]
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
    // FIXME: This does not work
    const { submitForm } = FormActions;
    const { data } = props;
    // eslint-disable-next-line camelcase
    const values = { name, expires_at };

    return submitForm({url: data.url, values, item: 'PersonalAccessToken'});
  }

  render() {
    const { handleSubmit, submitting, error } = this.props;

    return (
      <Form
        onSubmit={handleSubmit(this.submit)}
        onCancel={this.props.hideForm}
        disabled={submitting}
        submitting={submitting}
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

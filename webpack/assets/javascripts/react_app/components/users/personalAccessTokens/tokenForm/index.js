import React from 'react';
import { reduxForm } from 'redux-form';
import Form from '../../../common/forms/Form';
import TextField from '../../../common/forms/TextField';

class TokenForm extends React.Component {
  // eslint-disable-next-line camelcase
  submit({name, expires_at}, dispatch, props) {
    return props.submitForm(
      props.data.user_id,
      name,
      expires_at,
      props.data['csrf-token']
    );
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
      <TextField
        name="name"
        type="text"
        required="true"
        label={__('Name')}
      />
      <TextField
        name="expires_at"
        type="date"
        label={__('Expires at')}
      />
      </Form>
    );
  }
}
export default reduxForm({
  form: 'personal_access_token_create'
})(TokenForm);

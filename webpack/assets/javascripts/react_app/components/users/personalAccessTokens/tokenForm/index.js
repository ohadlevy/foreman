import React from 'react';
import { handleSubmit, reduxForm } from 'redux-form';
// import { SubmissionError } from 'redux-form';
import Form from '../../../common/forms/Form';
import TextInput from '../../../common/forms/TextInput';

// const checkErrors = response => {
//   if (response.ok) {
//     return response;
//   }
//   if (response.status === 422) {
//     // Handle invalid form data
//     return response.json().then(({ error }) => {
//       throw new SubmissionError({
//         name: error.errors.name.join(', '), // TODO: improve
//         _error: __('Form is invalid.')
//       });
//     });
//   }
//   throw new SubmissionError({
//     _error: __('Error submitting data: ') + response.statusText
//   });
// };

class TokenForm extends React.Component {
  // submit({ name }, dispatch, props) {
  //   let userId = props.data.user_id;
  //   let data = {
  //     name
  //   };
  //   let url = `/api/users/${userId}/personal_access_tokens`;
  //
  //   return fetch(url, {
  //     credentials: 'include',
  //     method: 'post',
  //     headers: {
  //       'Content-Type': 'application/json',
  //       Accept: 'application/json',
  //       'X-CSRF-Token': props.data['csrf-token']
  //     },
  //     body: JSON.stringify(data)
  //   })
  //     .then(checkErrors)
  //     .then(response => {
  //       return response.json().then(props.showFormSuccess);
  //     });
  // }
  //
  render() {
    const { handleSubmit, onSubmit, onCancel, error } = this.props;

    return (
      <Form handleSubmit={handleSubmit} onSubmit={onSubmit} onCancel={onCancel} error={error}>
        <TextInput label="name" />
      </Form>
    );
  }
}
export default reduxForm({
  form: 'personal_access_token_create'
})(TokenForm);

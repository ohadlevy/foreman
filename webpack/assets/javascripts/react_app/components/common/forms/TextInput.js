import React from 'react';
import CommonForm from './CommonForm';
import { Field } from 'redux-form';

const TextInput = ({ label, className = '', touched, error }) => {
  return (
    <CommonForm label={label} className={className}>
      <Field name={label} type="text" component="input" />
      {touched &&
        error &&
        <span>
          {error}
        </span>}
    </CommonForm>
  );
};

export default TextInput;

import React from 'react';
import CommonForm from './CommonForm';
import { Field } from 'redux-form';

const renderField = ({
  input,
  label,
  type,
  required,
  className,
  meta: { touched, error }
}) => (
    <CommonForm
      label={label}
      className={className}
      touched={touched}
      required={required}
      error={error}>
      <input {...input} type={type} className="form-control" />
    </CommonForm>
);

const TextField = ({
  name,
  label,
  type = 'text',
  className = '',
  required
}) => {
  return (
    <Field
      name={name}
      type={type}
      component={renderField}
      required={required}
      className={className}
      label={label}
    />
  );
};

export default TextField;

import React from 'react';
import Submit from './Submit';

export default ({
  className = 'form-horizontal well',
  handleSubmit,
  onSubmit,
  onCancel,
  children,
  error = false,
  touched,
  disabled = false
}) =>
  <form className={className} onSubmit={handleSubmit}>
    {error &&
      <strong>
        {error}
      </strong>}
    {children}
    <Submit onCancel={onCancel} disabled={disabled} />
  </form>;

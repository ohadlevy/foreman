import React from 'react';
import Actions from './Actions';
import AlertPanel from '../AlertPanel/';

export default ({
  className = 'form-horizontal well',
  onSubmit,
  onCancel,
  children,
  error = false,
  touched,
  disabled = false,
  submitting = false,
  title = __('Unable to save')
}) =>
  <form className={className} onSubmit={onSubmit}>
    {error &&
      <AlertPanel className="base in fade" type="danger" title={title}>
        <span className="text">
          {error.map((e, idx) =>
            <li key={idx}>
              {e}
            </li>
          )}
        </span>
      </AlertPanel>}
    {children}
    <Actions onCancel={onCancel} disabled={disabled} submitting={submitting} touched={touched} />
  </form>;

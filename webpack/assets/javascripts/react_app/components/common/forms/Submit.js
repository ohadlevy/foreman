import React from 'react';
import Button from '../../common/forms/Button';

export default ({ onSubmit, onCancel, disabled = false }) => {
  return (
    <div className="clearfix">
      <div className="form-actions">
        <Button className="btn-default" disabled={disabled} onSubmit={onCancel}>
          {__('Cancel')}
        </Button>

        <Button className="btn-primary" disabled={disabled} onSubmit={onSubmit}>
          {__('Submit')}
        </Button>

      </div>
    </div>
  );
};

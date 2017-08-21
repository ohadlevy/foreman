import React from 'react';
import Button from '../../common/forms/Button';

export default ({
  onCancel,
  disabled = false,
  submitting = false
}) => {
  return (
    <div className="clearfix">
      <div className="form-actions">
        <Button className="btn-default" disabled={disabled} onClick={onCancel}>
          {__('Cancel')}
        </Button>

        <Button className="btn-primary" type="submit" disabled={disabled || submitting}>
         {__('Submit')} &nbsp;
         {submitting && <span className="spinner spinner-sm spinner-inline pull-right"></span>}
        </Button>

      </div>
    </div>
  );
};

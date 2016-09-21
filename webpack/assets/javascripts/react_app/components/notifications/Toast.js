import React from 'react';
import {Button} from 'react-bootstrap';

const ToastIcons = {
  success: 'ok',
  danger: 'error-circle-o',
  warning: 'warning-triangle-o',
  'default': 'info'
};

const Toast = (props) => {
  const type = (props.type || 'success');
  let icon;

  icon = 'pficon pficon-' + (ToastIcons[type] || ToastIcons.default);
  return (
    <div className={ 'toast-pf toast-pf-max-width toast-pf-top-right alert alert-' +
      type + ' alert-dismissable' }>
      <Button className="close" data-dismiss="alert" aria-hidden="true">
        <span className="pficon pficon-close"></span>
      </Button>
      <div className="pull-right toast-pf-action">
        <a href="#">{props.link}</a>
      </div>
    <span className={ icon }></span>
    <strong>{props.title}</strong> {props.message}
  </div>
  );
};

export default Toast;

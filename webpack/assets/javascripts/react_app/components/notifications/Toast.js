import React from 'react';
import {Button} from 'react-bootstrap';

const ToastIcons = {
  success: {icon: 'ok', className: 'success'},
  notice: {icon: 'ok', className: 'success'},
  danger: {icon: 'error-circle-o', className: 'danger'},
  error: {icon: 'error-circle-o', className: 'danger'},
  warning: {icon: 'warning-triangle-o', className: 'warning'},
  'default': {icon: 'info', className: 'info'}
};

export default class Toast extends React.Component {
  constructor(props) {
    super(props);
    this.type = (props.type || 'success');
  }
  icon() {
    return 'pficon pficon-' + (ToastIcons[this.type].icon || ToastIcons.default.icon);
  }
  closeBtn() {
    return (
      <Button className="close" data-dismiss="alert" aria-hidden="true">
        <span className="pficon pficon-close"></span>
      </Button>
    );
  }
  render() {
    return (
      <div className={ 'toast-pf toast-pf-max-width toast-pf-top-right alert alert-' +
        ToastIcons[this.type].className + ' alert-dismissable' }>
        {this.props.close && this.closeBtn()}
        <div className="pull-right toast-pf-action">
          <a href="#">{this.props.link}</a>
        </div>
        <span className={ this.icon() }></span>
        <strong>{this.props.title}</strong> {this.props.message}
      </div>
    );
  }
}
Toast.defaultProps = { close: true };
export default Toast;

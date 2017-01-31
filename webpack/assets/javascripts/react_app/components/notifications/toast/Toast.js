import React from 'react';
import Icon from '../../common/Icon';
import Alert from '../../common/Alert';

export default class Toast extends React.Component {
  constructor(props) {
    super(props);
    this.type = (props.type || 'success');
  }
  render() {
    return (
      <Alert
        type={this.type}
        dismissable={this.props.close}
        css="toast-pf"
        >
        <div className="pull-right toast-pf-action">
          <a href="#">
            {this.props.link}
          </a>
        </div>
        <Icon type={this.type}/>
        <strong>
          {this.props.title}
        </strong>
        {this.props.message}
      </Alert>
    );
  }
}
Toast.defaultProps = { close: true };

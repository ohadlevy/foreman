import React from 'react';
import Icon from './Icon';
import { ALERT_CSS } from '../../constants';

/* eslint-disable max-params */
const Alert = ({children, type = 'info', dismissable = false, css = null}) => {
  let classNames = css ? ALERT_CSS[type] + ' ' + css : ALERT_CSS[type];

  if (dismissable) {
    classNames += ' ' + ALERT_CSS.dismissable;
  }

  const closeBtn = (
    <button className="close" data-dismiss="alert" aria-hidden="true">
      <Icon type="close" />
    </button>
  );

  return (
    <div className={classNames}>
      {dismissable && closeBtn}
      {children}
    </div>
  );
};

export default Alert;

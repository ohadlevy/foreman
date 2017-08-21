import React from 'react';
import getAlertClass from './Alert.consts';
import Icon from '../Icon/';
import Button from '../forms/Button';

export default ({
  className = '',
  type,
  children,
  title,
  onClose
}) => {
  const CloseButton = ({onClick}) => (
    <Button className="close" aria-hidden="true" onClick={onClick}>
      <Icon type="close" />
    </Button>
  );

  return (
    <div
      className={`${getAlertClass(type, onClose)}${className ? ' ' + className : ''}`}
    >
      {onClose && <CloseButton onClick={onClose} />}
      <Icon type={type} />
      {title && <strong>{title}</strong>}
      {title && <br />}
      {children}
    </div>
  );
};

import React from 'react';

const Button = (props) => {
  return (
    <button
      onClick={props.click}
      disabled={props.disabled}
      className={props.className || 'btn btn-default'}
    >
      {props.children}
    </button>
  );
};

export default Button;

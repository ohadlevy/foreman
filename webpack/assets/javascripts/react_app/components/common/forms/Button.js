import React from 'react';

export default ({ className, onClick, children, disabled = false, type = 'button' }) => {
  const _className = `btn ${className}`;

  return (
    <button disabled={disabled} onClick={onClick} type={type} className={_className}>
      {children}
    </button>
  );
};

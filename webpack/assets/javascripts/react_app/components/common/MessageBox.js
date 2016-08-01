// temporary component
// will be replaced by patternfly markup when available
import React from 'react';

const messageBoxStyles = {
  container: {
    flexGrow: 1,
    flexShrink: 1,
    display: 'flex',
    flexDirection: 'column',
    alignContent: 'center',
    justifyContent: 'center'
  },

  content: {
    flexBasis: '30px',
    textAlign: 'center'
  },

  icon: {
    fontSize: '22px'
  },

  message: {
    color: '#363636',
    fontSize: '12px',
    textTransform: 'capitalize'
  }
};

const MessageBox = ({ msg, icontype, style }) =>
(
    <div style={{ ...messageBoxStyles.container, ...style }}>
      <div className={'pficon pficon-' + icontype}
           style={{ ...messageBoxStyles.content, ...messageBoxStyles.icon }}></div>
      <div style={{ ...messageBoxStyles.content, ...messageBoxStyles.message }}>{msg}</div>
    </div>
  );

export default MessageBox;


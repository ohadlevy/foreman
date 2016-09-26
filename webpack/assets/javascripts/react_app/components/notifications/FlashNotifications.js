import React from 'react';
import Expire from './Expire';
import Toast from './Toast';

const FlashNotifications = ({flash, sticky}) => {
  let content = [];

  Object.keys(flash).forEach((type, index) => {
    content.push(
      <Expire key={index} sticky={sticky}>
        <Toast message={flash[type]} type={type} key={index}/>
      </Expire>
    );
  });
  return (
    <div>
      {content}
    </div>
  );
};

export default FlashNotifications;

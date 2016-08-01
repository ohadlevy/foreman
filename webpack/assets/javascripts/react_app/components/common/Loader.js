import React from 'react';
import styles from './LoaderStyles';

const Loader = ({ showContent, children }) => {
const content = showContent ? {...children } :
    <div className="spinner spinner-lg"></div>;

  return (
    <div style={styles.root}>
      {content}
    </div>
  );
};

export default Loader;

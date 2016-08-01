import React from 'react';

const Panel = (props) =>
 (
    <div className="panel panel-default" style={props.style}>
      {props.children}
    </div>
  );

export default Panel;

/**
 * Created by gail on 8/28/16.
 */
import React from 'react';

const PanelBody = ({children, style}) =>
  (
    <div className="panel-body" style={style}>
      {children}
    </div>
  );

export default PanelBody;

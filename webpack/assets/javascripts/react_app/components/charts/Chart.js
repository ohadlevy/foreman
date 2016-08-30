import React from 'react';

const Chart = ({cssClass, id, hasData}) => {
  if (hasData) {
    return (<div className={cssClass} id={id + 'Chart'}></div>);
  } else {
    let noData = _('No data').toString();
    return (<p>{noData}</p>);
  }
};

export default Chart;

import React from 'react';

const Chart = ({drawChart, cssClass, id}) => {
    drawChart();
    return (<div className={cssClass} id={id + 'Chart'}></div>);
};

export default Chart;

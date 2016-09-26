import React from 'react';
import StatisticsChartsList from '../components/charts/StatisticsChartsList';
import FlashNotifications from '../components/notifications/FlashNotifications';

import ReactDOM from 'react-dom';

export function mount(component, selector, data) {

  const components = {
    StatisticsChartsList: {
      type: StatisticsChartsList,
      markup: <StatisticsChartsList data={data}/>
    },
    FlashNotifications: {
     type: FlashNotifications,
     markup: <FlashNotifications flash={data}/>
   }
  };

  const reactNode = document.querySelector(selector);

  if (reactNode) {
    ReactDOM.render(components[component].markup, reactNode);
  } else {
    const componentName = components[component].type.name;

    // eslint-disable-next-line no-console
    console.log(`Cannot find \'${selector}\' element for mounting the \'${componentName}\'`);
  }
}

import React from 'react';
import StatisticsChartsList from '../components/charts/StatisticsChartsList';
import PowerStatusContainer from '../components/hosts/PowerStatusContainer';
import DrawerIcon from '../components/notifications/DrawerIcon';
import DrawerBox from '../components/notifications/DrawerBox';
import ReactDOM from 'react-dom';

export function mount(component, selector, data) {

  const components = {
    StatisticsChartsList: {
      type: StatisticsChartsList,
      markup: <StatisticsChartsList data={data}/>
    },
    PowerStatusContainer: {
      type: PowerStatusContainer,
      markup: <PowerStatusContainer url={data.url} id={data.id}/>
    },
    DrawerIcon: {
      type: DrawerIcon,
      markup: <DrawerIcon url={data.url}/>
    },
    DrawerBox: {
      type: DrawerBox,
      markup: <DrawerBox data={data} />
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

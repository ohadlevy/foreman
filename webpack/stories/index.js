import React from 'react';

/* eslint-disable no-unused-vars */
import { storiesOf, action, linkTo } from '@kadira/storybook';
require('../assets/javascripts/bundle');
require('../../app/assets/javascripts/application');
import StatisticsChartsList from
'../assets/javascripts/react_app/components/charts/StatisticsChartsList';
import Chart from '../assets/javascripts/react_app/components/charts/Chart';
import Search from '../assets/javascripts/react_app/components/common/Search';
import Toast from '../assets/javascripts/react_app/components/notifications/Toast';

storiesOf('Search', module)
  .add('Initial State', () => (
    <Search />
  ))
  .add('with Existing query', () => (
    <Search query="query" />
  )
);

storiesOf('Notifications', module)
  .add('Success State', () => (
    <Toast title="Great Succees!" />
  ))
  .add('Error', () => (
    <Toast message="Please don't do that again" type="danger"/>
  ))
  .add('Success with link', () => (
    <Toast title="Payment recieved"
      link="click for details" />
  ))
  .add('Warning', () => (
    <Toast message="I'm not sure you should do that" type="warning"/>
  )
);

storiesOf('Statistics', module)
  .add('Initial State', () => (
    <StatisticsChartsList data={[
        {
          'id': 'operatingsystem',
          'title': 'OS Distribution',
          'url': 'statistics/operatingsystem',
          'search': '/hosts?search=os_title=~VAL~'
        }, {
          'id': 'architecture',
          'title': 'Architecture Distribution',
          'url': 'statistics/architecture',
          'search': '/hosts?search=facts.architecture=~VAL~'
        }, {
          'id': 'environment',
          'title': 'Environment Distribution',
          'url': 'statistics/environment',
          'search': '/hosts?search=environment=~VAL~'
        }, {
          'id': 'hostgroup',
          'title': 'Host Group Distribution',
          'url': 'statistics/hostgroup',
          'search': '/hosts?search=hostgroup=~VAL~'
        }, {
          'id': 'compute_resource',
          'title': 'Compute Resource Distribution',
          'url': 'statistics/compute_resource',
          'search': '/hosts?search=compute_resource=~VAL~'
        }, {
          'id': 'processorcount',
          'title': 'Number of CPUs',
          'url': 'statistics/processorcount',
          'search': '/hosts?search=facts.processorcount=~VAL1~'
        }, {
          'id': 'manufacturer',
          'title': 'Hardware',
          'url': 'statistics/manufacturer',
          'search': '/hosts?search=facts.manufacturer~~VAL~'
        }, {
          'id': 'memory',
          'title': 'Average memory usage',
          'url': 'statistics/memory',
          'search': '/hosts?search='
        }, {
          'id': 'swap',
          'title': 'Average swap usage',
          'url': 'statistics/swap',
          'search': '/hosts?search='
        }, {
          'id': 'puppetclass',
          'title': 'Class Distribution',
          'url': 'statistics/puppetclass',
          'search': '/hosts?search=class=~VAL1~'
        }, {
          'id': 'location',
          'title': 'Location Distribution',
          'url': 'statistics/location',
          'search': '/hosts?search=location=~VAL~'
        }, {
          'id': 'organization',
          'title': 'Organization Distribution',
          'url': 'statistics/organization',
          'search': '/hosts?search=organization=~VAL~'
        }
    ]}></StatisticsChartsList>
  ))
  .add('standalone', () => (
    <Chart
    hasData={true}
    noDataMsg={__('No data available').toString()}
    cssClass="statistics-pie small"/>
  )
);

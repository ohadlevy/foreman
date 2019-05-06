import React from 'react';
import PropTypes from 'prop-types';
import PageLayout from '../common/PageLayout/PageLayout';
import StatisticsChartsList from '../../components/statistics/StatisticsChartsList';

const Statistics = () => (
  <PageLayout header={__('Statistics')} searchable={false}>
    <StatisticsChartsList
      data={[
        {
          id: 'operatingsystem',
          title: 'OS Distribution',
          url: '/statistics/operatingsystem',
          search: '/hosts?search=os_title=~VAL~',
        },
        {
          id: 'architecture',
          title: 'Architecture Distribution',
          url: '/statistics/architecture',
          search: '/hosts?search=facts.architecture=~VAL~',
        },
        {
          id: 'environment',
          title: 'Environment Distribution',
          url: '/statistics/environment',
          search: '/hosts?search=environment=~VAL~',
        },
        {
          id: 'hostgroup',
          title: 'Host Group Distribution',
          url: '/statistics/hostgroup',
          search: '/hosts?search=hostgroup_title=~VAL~',
        },
        {
          id: 'compute_resource',
          title: 'Compute Resource Distribution',
          url: '/statistics/compute_resource',
          search: '/hosts?search=compute_resource=~VAL~',
        },
        {
          id: 'processorcount',
          title: 'Number of CPUs',
          url: '/statistics/processorcount',
          search: '/hosts?search=facts.processorcount=~VAL1~',
        },
        {
          id: 'manufacturer',
          title: 'Hardware',
          url: '/statistics/manufacturer',
          search: '/hosts?search=facts.manufacturer~~VAL~',
        },
        {
          id: 'memory',
          title: 'Average Memory Usage',
          url: '/statistics/memory',
          search: '/hosts?search=',
        },
        {
          id: 'swap',
          title: 'Average Swap Usage',
          url: '/statistics/swap',
          search: '/hosts?search=',
        },
        {
          id: 'puppetclass',
          title: 'Class Distribution',
          url: '/statistics/puppetclass',
          search: '/hosts?search=class=~VAL1~',
        },
        {
          id: 'location',
          title: 'Location Distribution',
          url: '/statistics/location',
          search: '/hosts?search=location=~VAL~',
        },
        {
          id: 'organization',
          title: 'Organization Distribution',
          url: '/statistics/organization',
          search: '/hosts?search=organization=~VAL~',
        },
      ]}
    />
  </PageLayout>
);

export default Statistics;

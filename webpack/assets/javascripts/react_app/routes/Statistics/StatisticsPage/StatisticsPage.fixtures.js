import { statisticsData } from '../../../components/statistics/StatisticsChartsList.fixtures';
import { noop } from '../../../common/helpers';

export const statisticsProps = {
  statisticsMeta: statisticsData,
  charts: [
    {
      data: [['centOS 7.1', 6]],
      id: 'operatingsystem',
      search: '/hosts?search=os_title=~VAL~',
      title: 'OS Distribution',
      url: 'statistics/operatingsystem',
    },
  ],
  isLoading: false,
  hasData: true,
  hasError: false,
  message: {},
  getStatisticsMeta: noop,
  getStatisticsData: noop,
};

export const successRequestData = [
  {
    id: 'operatingsystem',
    title: 'OS Distribution',
    url: 'statistics/operatingsystem',
    search: '/hosts?search=os_title=~VAL~',
  },
  {
    id: 'architecture',
    title: 'Architecture Distribution',
    url: 'statistics/architecture',
    search: '/hosts?search=facts.architecture=~VAL~',
  },
];

export const request = {
  id: 'operatingsystem',
  title: 'OS Distribution',
  url: 'statistics/operatingsystem',
  search: '/hosts?search=os_title=~VAL~',
};

export const response = {
  id: 'operatingsystem',
  data: [['RedHat 3', 2]],
};

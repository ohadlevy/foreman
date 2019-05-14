import React from 'react';
import PropTypes from 'prop-types';
import { withRenderHandler } from '../../../../common/HOC';
import StatisticsChartsList from '../../../../components/statistics/StatisticsChartsList';

const Statistics = ({ statisticsMeta, getStatisticsData, charts }) => (
  <StatisticsChartsList
    data={statisticsMeta}
    getStatisticsData={getStatisticsData}
    charts={charts}
  />
);

Statistics.propTypes = {
  statisticsMeta: PropTypes.array.isRequired,
  getStatisticsData: PropTypes.func.isRequired,
  charts: PropTypes.oneOfType([PropTypes.array, PropTypes.object]).isRequired,
};

export default withRenderHandler({
  Component: Statistics,
});

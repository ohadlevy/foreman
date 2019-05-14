import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';

import StatisticsChartsList from './StatisticsChartsList';
import { statisticsData } from './StatisticsChartsList.fixtures';

describe('StatisticsChartsList', () => {
  it('should render no panels for empty data', () => {
    const wrapper = shallow(
      <StatisticsChartsList charts={[]} data={statisticsData} />
    );

    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('should render two panels for fixtures data', () => {
    const wrapper = shallow(
      <StatisticsChartsList charts={statisticsData} data={statisticsData} />
    );

    expect(wrapper.render().find('.chart-box')).toHaveLength(2);
  });
});

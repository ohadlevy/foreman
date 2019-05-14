import API from '../../../../API';

import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { getStatisticsMeta, getStatisticsData } from '../StatisticsPageActions';
import {
  statisticsProps,
  successRequestData,
} from '../StatisticsPage.fixtures';

jest.mock('../../../../API');

const runStatisticsAction = (callback, props, serverMock) => {
  API.get.mockImplementation(serverMock);

  return callback(props);
};

const fixtures = {
  'should fetch statisticsMeta': () =>
    runStatisticsAction(getStatisticsMeta, {}, async () => ({
      data: statisticsProps.statistics,
    })),
  'should fetch statisticsMeta and fail': () =>
    runStatisticsAction(getStatisticsMeta, {}, async () => {
      throw new Error('some-error');
    }),
  'should fetch statisticsData': () =>
    runStatisticsAction(getStatisticsData, successRequestData, async () => ({
      data: statisticsProps.charts,
    })),
  'should fetch statisticsData and fail': () =>
    runStatisticsAction(getStatisticsData, successRequestData, async () => {
      throw new Error('some-error');
    }),
};

describe('StatisticsPage actions', () =>
  testActionSnapshotWithFixtures(fixtures));

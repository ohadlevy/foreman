import { testReducerSnapshotWithFixtures } from '../../../../common/testHelpers';
import { request, response } from '../StatisticsPage.fixtures';

import {
  STATISTICS_PAGE_META_RESOLVED,
  STATISTICS_PAGE_META_FAILED,
  STATISTICS_PAGE_HIDE_LOADING,
  STATISTICS_DATA_REQUEST,
  STATISTICS_DATA_SUCCESS,
  STATISTICS_DATA_FAILURE,
} from '../../constants';
import reducer from '../StatisticsPageReducer';

const fixtures = {
  'should return the initial state': {},
  'should handle STATISTICS_PAGE_FETCH_META': {
    action: {
      type: STATISTICS_PAGE_META_RESOLVED,
      payload: [],
    },
  },
  'should handle STATISTICS_PAGE_HIDE_LOADING': {
    action: {
      type: STATISTICS_PAGE_HIDE_LOADING,
    },
  },
  'should handle STATISTICS_PAGE_SHOW_MESSAGE': {
    action: {
      type: STATISTICS_PAGE_META_FAILED,
      payload: {
        hasError: true,
        message: { type: 'error', text: 'some-error' },
      },
    },
  },
  'should handle STATISTICS_DATA_REQUEST': {
    action: {
      type: STATISTICS_DATA_REQUEST,
      payload: request,
    },
  },
  'should handle STATISTICS_DATA_SUCCESS': {
    action: {
      type: STATISTICS_DATA_SUCCESS,
      payload: response,
    },
  },
  'should handle STATISTICS_DATA_FAILURE': {
    action: {
      type: STATISTICS_DATA_FAILURE,
      payload: { error: 'some-error', item: request },
    },
  },
};

describe('StatisticsPage reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));

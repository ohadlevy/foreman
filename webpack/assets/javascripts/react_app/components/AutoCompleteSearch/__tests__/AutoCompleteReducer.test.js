import reducer from '../AutoCompleteReducer';
import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  AUTO_COMPLETION_REQUEST,
  AUTO_COMPLETION_FAILURE,
  AUTO_COMPLETION_SUCCESS,
} from '../AutoCompleteConstants';
import { STATUS } from '../../../constants';

const getMockOptions = () => [
  {
    completed: '',
    part: ' hardware_model ',
    label: ' hardware_model ',
    category: '',
  },
  {
    completed: '',
    part: ' info ',
    label: ' info ',
    category: '',
  },
  {
    completed: '',
    part: ' name ',
    label: ' name ',
    category: '',
  },
  {
    completed: '',
    part: ' vendor_class ',
    label: ' vendor_class ',
    category: '',
  },
  {
    completed: '',
    part: ' not',
    label: ' not',
    category: 'Operators',
  },
  {
    completed: '',
    part: ' has',
    label: ' has',
    category: 'Operators',
  },
];

const getMockError = () => new Error('Oops');

const fixtures = {
  'should return the initial state': {},
  'should handle AUTO_COMPLETION_REQUEST': {
    action: {
      type: AUTO_COMPLETION_REQUEST,
      payload: {
        options: [],
        error: null,
        status: STATUS.PENDING,
      },
    },
  },
  'should handle AUTO_COMPLETION_SUCCESS': {
    action: {
      type: AUTO_COMPLETION_SUCCESS,
      payload: {
        options: getMockOptions(),
        searchQuery: '',
        error: null,
        status: STATUS.RESOLVED,
      },
    },
  },
  'should handle AUTO_COMPLETION_FAILURE': {
    action: {
      type: AUTO_COMPLETION_FAILURE,
      payload: {
        error: getMockError(),
        status: STATUS.ERROR,
      },
    },
  },
};

describe('AutoCompleteSearch reducer', () => testReducerSnapshotWithFixtures(reducer, fixtures));

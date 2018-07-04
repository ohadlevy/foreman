import {
  AUTO_COMPLETION_FAILURE,
  AUTO_COMPLETION_REQUEST,
  AUTO_COMPLETION_SUCCESS,
} from './AutoCompleteConstants';

import { getOptions } from './AutoCompleteActions';

import { ajaxRequestAction } from '../../redux/actions/common';

jest.unmock('./AutoCompleteActions');
jest.mock('../../redux/actions/common');

describe('AutoComplete actions', () => {
  it('getOptions should call ajaxRequestAction with search query', () => {
    const query = 'name = model2';
    const url = 'models/auto_complete_search?search=name+%3D+model2';
    const dispatch = jest.fn();
    const expectedParams =
        {
          dispatch,
          failedAction: AUTO_COMPLETION_FAILURE,
          item: { url, query },
          requestAction: AUTO_COMPLETION_REQUEST,
          successAction: AUTO_COMPLETION_SUCCESS,
          url,
        };
    const dispatcher = getOptions(query);

    dispatcher(dispatch);
    expect(ajaxRequestAction).toBeCalledWith(expectedParams);
  });
});

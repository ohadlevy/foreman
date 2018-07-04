import {
  AUTO_COMPLETION_REQUEST,
  AUTO_COMPLETION_SUCCESS,
  AUTO_COMPLETION_FAILURE,
} from './AutoCompleteConstants';
import { ajaxRequestAction } from '../../redux/actions/common';

export const getOptions = query => (dispatch) => {
  const q = query.replace(/\s/g, '+').replace(/=/g, '%3D');

  const url = `models/auto_complete_search?search=${q}`;
  return ajaxRequestAction({
    dispatch,
    requestAction: AUTO_COMPLETION_REQUEST,
    successAction: AUTO_COMPLETION_SUCCESS,
    failedAction: AUTO_COMPLETION_FAILURE,
    url,
    item: { url, query },
  });
};

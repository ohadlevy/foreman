import API from '../../../API';

import {
  STATISTICS_PAGE_META_RESOLVED,
  STATISTICS_PAGE_META_FAILED,
  STATISTICS_PAGE_HIDE_LOADING,
  STATISTICS_PAGE_URL,
  STATISTICS_DATA_REQUEST,
  STATISTICS_DATA_SUCCESS,
  STATISTICS_DATA_FAILURE,
} from '../constants';
import { ajaxRequestAction } from '../../../redux/actions/common';

export const getStatisticsMeta = (
  url = STATISTICS_PAGE_URL
) => async dispatch => {
  const onFetchSuccess = ({ data }) => {
    dispatch(hideLoading());
    dispatch({
      type: STATISTICS_PAGE_META_RESOLVED,
      payload: data,
    });
  };

  const onFetchError = ({ message }) => {
    dispatch(hideLoading());
    dispatch({
      type: STATISTICS_PAGE_META_FAILED,
      payload: {
        hasError: true,
        message: {
          type: 'error',
          text: message,
        },
      },
    });
  };
  try {
    const response = await API.get(url);
    return onFetchSuccess(response);
  } catch (error) {
    return onFetchError(error);
  }
};

export const getStatisticsData = charts => dispatch =>
  Promise.all(
    charts.map(chart =>
      ajaxRequestAction({
        dispatch,
        requestAction: STATISTICS_DATA_REQUEST,
        successAction: STATISTICS_DATA_SUCCESS,
        failedAction: STATISTICS_DATA_FAILURE,
        url: chart.url,
        item: chart,
      })
    )
  );

const hideLoading = () => ({
  type: STATISTICS_PAGE_HIDE_LOADING,
});

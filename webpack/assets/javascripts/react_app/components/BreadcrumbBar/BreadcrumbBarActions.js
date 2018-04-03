import API from '../../API';

import {
  BREADCRUMB_BAR_TOGGLE_SWITCHER,
  BREADCRUMB_BAR_CLOSE_SWITCHER,
  BREADCRUMB_BAR_RESOURCES_REQUEST,
  BREADCRUMB_BAR_RESOURCES_SUCCESS,
  BREADCRUMB_BAR_RESOURCES_FAILURE,
} from './BreadcrumbBarConstants';

export const toggleSwitcher = () => ({
  type: BREADCRUMB_BAR_TOGGLE_SWITCHER,
});

export const closeSwitcher = () => ({
  type: BREADCRUMB_BAR_CLOSE_SWITCHER,
});

export const loadSwitcherResourcesByResource = (resource, options = {}) => (dispatch) => {
  const {
    reosurceUrl, nameField, switcherItemUrl,
  } = resource;
  const { page = 1 } = options;

  const beforeRequest = () =>
    dispatch({
      type: BREADCRUMB_BAR_RESOURCES_REQUEST,
      payload: { resource, options },
    });

  const onRequestSuccess = response =>
    dispatch({ type: BREADCRUMB_BAR_RESOURCES_SUCCESS, payload: formatResults(response) });

  const onRequestFail = error =>
    dispatch({ type: BREADCRUMB_BAR_RESOURCES_FAILURE, payload: error });

  const formatResults = ({ data }) => {
    const switcherItems = Object.values(data.results).map((x, i) =>
      (data.results instanceof Array ?
        { name: x[nameField], url: switcherItemUrl.replace(':id', x.id) } :
        { name: x[i][nameField], url: switcherItemUrl.replace(':id', x[i].id) }));
    return {
      items: switcherItems,
      page: data.page,
      pages: Number(data.total) / Number(data.per_page),
    };
  };
  beforeRequest();

  return API.get(reosurceUrl, {}, { page }).then(onRequestSuccess, onRequestFail);
};

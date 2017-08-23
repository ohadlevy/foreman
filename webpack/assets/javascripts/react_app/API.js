import $ from 'jquery';

export default {
  get(url) {
    $.ajaxPrefilter((options, originalOptions, jqXHR) => {
      jqXHR.originalRequestOptions = originalOptions;
    });
    return $.getJSON(url);
  },
  post(url, data) {
    return $.ajax({
      url,
      contentType: 'application/json',
      type: 'post',
      dataType: 'json',
      data
    });
  },
  markNotificationAsRead(id) {
    const data = JSON.stringify({ seen: true });

    $.ajax({
      url: `/notification_recipients/${id}`,
      contentType: 'application/json',
      type: 'put',
      dataType: 'json',
      data,
      error(jqXHR, textStatus, errorThrown) {
        /* eslint-disable no-console */
        console.log(jqXHR);
      }
    });
  },
  markGroupNotificationAsRead(group) {
    $.ajax({
      url: `/notification_recipients/group/${group}`,
      contentType: 'application/json',
      type: 'PUT',
      error(jqXHR, textStatus, errorThrown) {
        /* eslint-disable no-console */
        console.log(jqXHR);
      }
    });
  }
};

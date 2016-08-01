import ServerActions from './actions/ServerActions';

export default {
  getStatisticsData(url) {
    $.getJSON(url)
      .success(
        rawStatistics => ServerActions.receivedStatistics(rawStatistics)
      )
      // eslint-disable-next-line no-console
      .error(error => console.log(error));
  }
};

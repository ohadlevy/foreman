export const selectStatisticsPage = state => state.statisticsPage;
export const selectStatisticsCharts = state =>
  selectStatisticsPage(state).charts;
export const selectStatisticsMetadata = state =>
  selectStatisticsPage(state).statisticsMeta;
export const selectStatisticsIsLoading = state =>
  selectStatisticsPage(state).isLoading;
export const selectStatisticsMessage = state =>
  selectStatisticsPage(state).message;
export const selectStatisticsHasError = state =>
  selectStatisticsPage(state).hasError;
export const selectStatisticsHasMetadata = state =>
  selectStatisticsMetadata(state).length > 0;

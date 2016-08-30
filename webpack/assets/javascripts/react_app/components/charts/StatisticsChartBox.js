import React from 'react';
import helpers from '../../common/helpers';
// import ChartHeader from './ChartHeader';
import Chart from './Chart';
import ChartModal from './ChartModal';
import Loader from '../common/Loader';
import Panel from '../common/Panel/Panel';
import PanelHeading from '../common/Panel/PanelHeading';
import PanelTitle from '../common/Panel/PanelTitle';
import PanelBody from '../common/Panel/PanelBody';
import StatisticsStore from '../../stores/StatisticsStore';
import StatisticsChartActions from '../../actions/StatiscticChartActions';
import statisticsPage from '../../../pages/statistics_page';
import styles from './StatisticsChartsListStyles';

export default class StatisticsChartBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showModal: false, isLoaded: false };
    helpers.bindMethods(this, [
      'drawChart',
      'onChange',
      'onClick',
      'closeModal',
      'openModal',
      'drawModal']
    );
  }

  static propTypes = {
    title: React.PropTypes.string,
    id: React.PropTypes.any
  };

  componentDidMount() {
    StatisticsChartActions.getStatisticsData(this.props.url);
    StatisticsStore.addChangeListener(this.onChange);
  }

  componentWillUnmount() {
    StatisticsStore.removeChangeListener(this.onChange);
  }

  onChange(event) {
    if (event.id != this.props.id) {
      return;
    }

    const statistics = StatisticsStore.getStatisticsData(this.props.id);

    this.setState({
      isLoaded: statistics.isLoaded,
      hasData: !!statistics.data.length,
      data: statistics.data });
  }

  onClick() {
    if (this.state.data && this.state.hasData) {
      this.openModal();
    }
  }

  componentDidUpdate() {
    let start = Date.now();
    this.drawChart()
    let end = Date.now();
    console.log(this.props.id + ': took ' + (end - start) + 'ms to render');
 }

  drawChart() {
    statisticsPage.generateChart(this.props, this.state.data);
  }

  openModal() {
    this.setState({ showModal: true });
  }

  closeModal() {
    this.setState({ showModal: false });
  }

  drawModal() {
    statisticsPage.generateModalChart(this.props, this.state.data);
  }

  render() {
    let tooltip = {
      onClick: this.onClick,
      title: _('Expand the chart').toString(),
      'data-toggle': 'tooltip',
      'data-placement': 'top'
    };

    return (
      <Panel style={styles.panel}>
        <PanelHeading {...tooltip} style={styles.heading}>
          <PanelTitle text={this.props.title}/>
        </PanelHeading>

        <PanelBody style={styles.body}>
          <Loader showContent={this.state.isLoaded}>
            <Chart {...this.props}
                   drawChart={this.drawChart}
                   hasData={this.state.hasData}
                   cssClass="statistics-pie small c3"/>
          </Loader>

          <ChartModal {...this.props}
                      show={this.state.showModal}
                      onHide={this.closeModal}
                      drawChart={this.drawModal}
          />
        </PanelBody>
      </Panel>
    );
  }
}

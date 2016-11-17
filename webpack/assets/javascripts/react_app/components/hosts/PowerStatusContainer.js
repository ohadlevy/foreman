import React from 'react';
import HostsStore from '../../stores/HostsStore';
import HostsActions from '../../actions/HostsActions';
import PowerStatus from './PowerStatus';
import {observer} from 'mobx-react';

@observer
class PowerStatusContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {host: HostsStore.getHostsData(props.id)};
  }

  componentDidMount() {
    HostsActions.getHostPowerState(this.props.id, this.props.url);
  }

  render() {
    const power = this.state.host.power;

    return (
      <PowerStatus
        state={power.state}
        title={power.title}
        loadingStatus={power.isLoading}
        statusText={power.statusText}
      />
    );
  }
}

export default PowerStatusContainer;

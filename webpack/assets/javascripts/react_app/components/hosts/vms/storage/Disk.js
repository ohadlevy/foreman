import React from 'react';
import VMStorageActions from '../../../../actions/VMStorageActions';
// import { VMStorageVMWare } from '../../../../constants';
import { Button } from 'react-bootstrap';

class Disk extends React.Component {
  constructor(props) {
    super(props);
  }
  removeDisk(event) {
    VMStorageActions.removeDisk(this.props.controllerID, this.props.id);
  }
  render() {
    return (
      <Button
      onClick={this.removeDisk.bind(this)}
      bsStyle="warning">
      Remove Disk
      </Button>
    );
  }
}

export default Disk;

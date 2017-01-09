import React from 'react';
import VMStorageActions from '../../../../actions/VMStorageActions';
import { VMStorageVMWare } from '../../../../constants';
import { Button } from 'react-bootstrap';
import Disk from './Disk';

class Controller extends React.Component {
  constructor(props) {
    super(props);
  }
  disks() {
    return this.props.disks.map((disk, index) => {
      // TODO: add disk component
      return (<Disk
        key={index}
        id={index}
        controllerId={this.props.position}
        {...disk}
        />);
    });
  }
  addDisk(controllerPosition, e) {
    VMStorageActions.addDisk(controllerPosition);
  }
  removeDisk(controllerPosition, e) {
    VMStorageActions.removeDisk(controllerPosition);
    // TODO
  }
  controllerUpdated(attribute, e) {
    const value = e.target.value;
    let attributes = {};

    attributes[attribute] = value;
    VMStorageActions.updateController(this.props.position, attributes);
  }
  selectableTypes() {
    return Object.entries(VMStorageVMWare.ControllerTypes).map((attribute) => {
      return (<option key={attribute[0]} value={attribute[0]}>{attribute[1]}</option>);
    });
  }
  removeController(id, e) {
    VMStorageActions.removeController(id);
  }
  render() {
    return (
      <div className="col-md-3">
        <h2> Controller {this.props.position + 1} </h2>
        <h3> Total disks {this.props.disks.length}/{VMStorageVMWare.MaxDisksPerController} </h3>
        <select
          value={this.props.type}
          onChange={this.controllerUpdated.bind(this, 'type')}
          >
          {this.selectableTypes()}
        </select>
        <Button
          disabled={this.props.disks.length >= VMStorageVMWare.MaxDisksPerController}
          onClick={this.addDisk.bind(this, this.props.position)}>
          Create Disk
        </Button>
        <Button
          onClick={this.removeController.bind(this, this.props.position)}
          bsStyle="warning">
          Remove Controller
        </Button>
      </div>
    );
  }
}

export default Controller;

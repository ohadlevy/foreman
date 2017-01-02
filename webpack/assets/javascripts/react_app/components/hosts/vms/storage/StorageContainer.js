import React from 'react';
import helpers from '../../../../common/helpers';
import Button from './Button';
import Controller from './Controller';

const MaxControllers = 4;
const KeyIndex = 1000;
const MaxDisksPerController = 15;

class StorageContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      controllers: []
    };
    helpers.bindMethods(this, [
      'addController', 'removeController', 'addDisk', 'removeDisk'
    ]);
  }
  addController(e) {
    e.preventDefault();
    let controllers = this.state.controllers;

    controllers.push({
      key: controllers.length,
      type: this.defaultControllerType(),
      disks: []
    });
    this.setState({controllers: controllers});
  }
  removeController(currentPosition,e) {
    // TODO
  }
  defaultControllerType() {
    return 'default';
  }
  defaultDiskAttributes() {
    return {size: 0, type: this.defaultControllerType()};
  }
  addDisk(controllerPosition, e) {
    e.preventDefault();
    let controllers = this.state.controllers.map((controller) => {
      if (this.state.controllers[controllerPosition] === controller &&
        controller.disks.length < MaxDisksPerController) {
        let c = controller;

        c.disks.push(this.defaultDiskAttributes());
        return c;
      } else {
        return controller;
      }
    });
    this.setState({controllers: controllers});
  }
  removeDisk(controllerPosition,e) {
    // TODO
  }
  controllers() {
    return this.state.controllers.map((controller) => {
      return (<Controller
        {...controller}
        position={controller.key}
        maxDisks={MaxDisksPerController}
        addDisk={this.addDisk} />);
      });
    }
    render() {
      return (
        <div className="row">
          <h1>
            {this.state.controllers.length + '/' + MaxControllers + ' controllers used'}
          </h1>
          <div className="row">
            {this.controllers()}
          </div>
          <div className="row fr">
            <Button
              click={this.addController}
              disabled={this.state.controllers.length >= MaxControllers} >
              Add Controller
            </Button>
          </div>
          <div className="row">

            <small>
              <code>
                JSON:
                {JSON.stringify(this.state.controllers)}
              </code>
            </small>
          </div>
        </div>
      );
  }
}

export default StorageContainer;

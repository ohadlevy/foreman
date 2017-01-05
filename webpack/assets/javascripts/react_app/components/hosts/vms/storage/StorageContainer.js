import React from 'react';
import helpers from '../../../../common/helpers';
import { Button } from 'react-bootstrap';
import Controller from './Controller';
import VMStorageStore from '../../../../stores/VMStorageStore';
import VMStorageActions from '../../../../actions/VMStorageActions';
import { VMStorageVMWare } from '../../../../constants';

class StorageContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = { controllers: VMStorageStore.getControllers() };
    helpers.bindMethods(this, [
      'onChange', 'onError',
      'addController', 'removeController'
    ]);
  }
  componentDidMount() {
    VMStorageStore.addChangeListener(this.onChange);
    VMStorageStore.addErrorListener(this.onError);
  }
  componentWillUnmount() {
    VMStorageStore.removeChangeListener(this.onChange);
    VMStorageStore.removeErrorListener(this.onError);
  }
  onChange(event) {
    this.setState({ controllers: VMStorageStore.getControllers() });
  }
  onError(info) {
    if (this.props.id === info.id) {
      this.setState({
        errorMessage: info.textStatus
      });
    }
  }
  addController(e) {
    VMStorageActions.addController();
  }
  removeController(currentPosition, e) {
    VMStorageActions.removeController(currentPosition);
  }

  controllers() {
    return this.state.controllers.map((controller) => {
      return (<Controller
        key={controller.position}
        {...controller}
        />);
      });
    }
    render() {
      return (
        <div className="row">
          <h1>
            {this.state.controllers.length + '/' + VMStorageVMWare.MaxControllers +
              ' controllers used'}
          </h1>
          <div className="row">
            {this.controllers()}
          </div>
          <div className="row fr">
            <Button
              onClick={this.addController}
              disabled={this.state.controllers.length >= VMStorageVMWare.MaxControllers} >
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

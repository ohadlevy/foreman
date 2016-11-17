import { observable } from 'mobx';

class HostPower {
  @observable id;
  @observable state;
  @observable statusText;
  @observable isLoading;
  @observable errors;

  constructor(id, attributes) {
    this.id = id;
    this.isLoading = attributes.isLoading;
    this.state = attributes.state;
    this.statusText = attributes.statusText;
    this.lastChecked = Date.now();
  }
}

export default HostPower;

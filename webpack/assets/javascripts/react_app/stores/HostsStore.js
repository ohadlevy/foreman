import { observable } from 'mobx';
import HostPower from './hosts/power';

class HostsStore {
  @observable hosts = {};

  addHostPowerState(id, attributes) {
    this.hosts[id] = this.hosts[id] || {};
    this.hosts[id].power = new HostPower(id, attributes);
  }

  getHostsData(id) {
    return (this.hosts[id] = this.hosts[id] || {power: {}});
  }
}

export default new HostsStore();

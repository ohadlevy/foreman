import API from '../API';
import HostsStore from '../stores/HostsStore';
import {STATUS} from '../constants';

export default {
  getHostPowerState(id, url) {
    HostsStore.addHostPowerState(id, { isLoading: STATUS.PENDING });
    // IP or URL
      API.get(url)
      .success(
        (response, textStatus, jqXHR) => {
          response.isLoading = STATUS.RESOLVED;
          HostsStore.addHostPowerState(id, response);
        })
      .error((jqXHR, textStatus, errorThrown) => {
        HostsStore.addHostPowerState(id,
          {
            state: 'na',
            textStatus: textStatus,
            isLoading: STATUS.ERROR
          });
        });
    }
};

import AppDispatcher from '../dispatcher';
import { ACTIONS, VMStorageVMWare } from '../constants';
import AppEventEmitter from './AppEventEmitter';

let _vmStorage = {controllers: []};

class VMStorageEventEmitter extends AppEventEmitter {
  constructor() {
    super();
  }
  getControllers() {
    return _vmStorage.controllers;
  }
  getControllersCount() {
    return this.getControllers().length;
  }
}

const VMStorageStore = new VMStorageEventEmitter();

AppDispatcher.register(action => {
  switch (action.actionType) {
    case ACTIONS.CONTROLLER_ADDED: {

      if (_vmStorage.controllers.length < VMStorageVMWare.MaxControllers) {
        let attributes = Object.assign(
          { position: _vmStorage.controllers.length, disks: [] },
            Object.assign({}, VMStorageVMWare.defaultConrollerAttributes));

        _vmStorage.controllers.push(attributes);
        VMStorageStore.emitChange({id: attributes.position});
      } else {

        VMStorageStore.emitError({
          action: ACTIONS.CONTROLLER_ADDED,
          errors: {message: 'Unable to add - maximum amount of controllers has been reached'}
        });
      }
      break;
    }
    case ACTIONS.CONTROLLER_REMOVED: {
      const id = action.controllerId;

      _vmStorage.splice(id);
      VMStorageStore.emitChange({id: id});
      break;
    }
    case ACTIONS.CONTROLLER_UPDATED: {
      const id = action.id;
      const newAttributes = action.attributes;

      _vmStorage.controllers[id] = Object.assign(_vmStorage.controllers[id], newAttributes);

      VMStorageStore.emitChange({id: id});
      break;
    }
    case ACTIONS.DISK_ADDED: {
      const id = action.controllerId;
      let controller = _vmStorage.controllers[id];

      if (controller.disks.length < VMStorageVMWare.MaxDisksPerController) {
        controller.disks.push(Object.assign({}, VMStorageVMWare.defaultDiskAttributes));
        VMStorageStore.emitChange({id: id});
      } else {
        VMStorageStore.emitError({
          action: ACTIONS.DISK_ADDED,
          errors: {message: 'Unable to add - maximum amount of disks has been reached'}
        });
      }
      break;
    }
    case ACTIONS.DISK_REMOVED: {
      const controller = action.controllerId;
      const disk = action.diskId;

      _vmStorage.controllers[controller].disks.splice(disk);
      VMStorageStore.emitChange({id: controller});
      break;
    }
    default:
    // no op
    break;
  }
});

export default VMStorageStore;

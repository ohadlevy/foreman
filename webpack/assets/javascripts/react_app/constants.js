export const ACTIONS = {
  RECEIVED_STATISTICS: 'RECEIVED_STATISTICS',
  STATISTICS_REQUEST_ERROR: 'STATISTICS_REQUEST_ERROR',
  RECEIVED_HOSTS_POWER_STATE: 'RECEIVED_HOSTS_POWER_STATE',
  HOSTS_REQUEST_ERROR: 'HOSTS_REQUEST_ERROR',
  CONTROLLER_ADDED: 'CONTROLLER_ADDED',
  CONTROLLER_REMOVED: 'CONTROLLER_REMOVED',
  DISK_ADDED: 'DISK_ADDED',
  DISK_REMOVED: 'DISK_REMOVED'
};

export const STATUS = {
  PENDING: 'PENDING',
  RESOLVED: 'RESOLVED',
  ERROR: 'ERROR'
};

export const VMStorageVMWare = {
  ControllerTypes: {
    VirtualBusLogicController: 'Bus Logic Parallel',
    VirtualLsiLogicController: 'LSI Logic Parallel',
    VirtualLsiLogicSASController: 'LSI Logic SAS',
    ParaVirtualSCSIController: 'VMware Paravirtual'
  },
  MaxControllers: 4,
  defaultConrollerAttributes: {
    type: 'ParaVirtualSCSIController'
  },
  MaxDisksPerController: 15,
  defaultDiskAttributes: {
    size: 0
    // TODO: add more attributes here.
  }
};

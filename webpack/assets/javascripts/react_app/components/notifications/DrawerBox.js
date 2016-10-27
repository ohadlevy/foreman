import React, { Component } from 'react';
import helpers from '../../common/helpers';
import NotificationsStore from '../../stores/NotificationsStore';

class DrawerBox extends Component {
  constructor(props) {
    super(props);
    this.state = { notifications: NotificationsStore.getNotifications() };
    helpers.bindMethods(this, ['onChange']);
  }
  componentDidMount() {
    NotificationsStore.addChangeListener(this.onChange);
  }
  onChange() {
    this.setState({ notifications: NotificationsStore.getNotifications() });
  }
  render() {
    const notifications = this.state.notifications.map(notification => {
      <Notification notification />;
    });

    return (
      <div>
      <div className="drawer-pf-title">
        <a className="drawer-pf-toggle-expand"></a>
        <h3 className="text-center">Notifications Drawer</h3>
      </div>
      <div>
      { notifications }
      </div>
      </div>
    );
  }
}

export default DrawerBox;

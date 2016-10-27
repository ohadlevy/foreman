import React, { Component } from 'react';
import helpers from '../../common/helpers';
import NotificationsStore from '../../stores/NotificationsStore';
import NotificationActions from '../../actions/NotificationActions';

class DrawerIcon extends Component {
  constructor(props) {
    super(props);
    this.state = { open: false, count: 0, isLoaded: false };
    helpers.bindMethods(this, ['onChange']);
  }
  componentDidMount() {
    NotificationsStore.addChangeListener(this.onChange);
    // NotificationsStore.addErrorListener(this.onError);
    NotificationActions.getNotifications(this.props.url);
  }

  onChange() {
    this.setState({
      count: NotificationsStore.getNotifications().length,
      isLoaded: true
    });
  }

  iconType() {
    return this.state.count === 0 ? 'fa-bell-o' : 'fa-bell';
  }
  render() {
    return (
      <a className="nav-item-iconic drawer-pf-trigger-icon">
        <span className={'fa ' + this.iconType()} title={__('Notifications')}></span>
      </a>
    );
  }
}

export default DrawerIcon;

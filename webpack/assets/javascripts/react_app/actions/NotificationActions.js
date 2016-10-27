import API from '../API';

const TIMER = 10000;

export default {
  getNotifications(url) {
    setTimeout(() => {
      API.getNotifications(url);
      this.getNotifications(url);
    }, TIMER);
  }
};

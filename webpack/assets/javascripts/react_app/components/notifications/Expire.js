import React from 'react';

export default class Expire extends React.Component {
  constructor(props) {
    super(props);
    this.state = {visible: true };
  }
  componentWillReceiveProps(nextProps) {
    // reset the timer if children are changed
    if (nextProps.children !== this.props.children) {
      this.setTimer();
      this.setState({visible: true});
    }
  }
  componentDidMount() {
    this.setTimer();
  }
  clearTimer() {
    if (!this.props.sticky) {
      clearTimeout(this._timer);
    }
  }
  setTimer() {
    // do nothing if it has a sticky content.
    if (this.props.sticky) {
      return;
    }

    // clear any existing timer
    if (this._timer != null) {
      this.clearTimer();
    }

    // hide after `delay` milliseconds
    this._timer = setTimeout(() => {
      this.setState({visible: false});
      this._timer = null;
    }, this.props.delay);
  }
  componentWillUnmount() {
    this.clearTimer();
  }
  onMouseEnter() {
    if (this._timer) {
      this.clearTimer();
    }
  }
  onMouseLeave() {
    this.setTimer();
  }
  render() {
    return (
      this.state.visible ?
      <div onMouseEnter={this.onMouseEnter} onMouseLeave={this.onMouseLeave.bind(this)}>
        {this.props.children}
      </div> :
      <span />
    );
  }
}

Expire.defaultProps = { delay: 8000, sticky: false };
export default Expire;

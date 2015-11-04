var LookupKeyOrderElement = React.createClass({
  getInitialState: function () {
    return {name: this.props.name, position: this.props.position}
  },
  handleUp: function () {
    var currentPosition = this.props.position;
    this.props.changeCallback(this.state.name, currentPosition - 1, currentPosition);
  },
  handleDown: function () {
    var currentPosition = this.props.position;
    this.props.changeCallback(this.state.name, currentPosition + 1, currentPosition);
  },
  showUp: function() {
    return this.props.position > 0
  },
  showDown: function() {
    return this.props.position < this.props.listLength - 1
  },

  render: function () {
    return (
        <li>
          {this.state.name}
          <a hidden={!this.showUp()} onClick={this.handleUp}> <Glyphicon glyph='arrow-up'/></a>
          <a hidden={!this.showDown()} onClick={this.handleDown}> <Glyphicon glyph='arrow-down'/></a>
        </li>
    );
  }
});

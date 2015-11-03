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
  render: function () {
    return (
        <li>
          {this.state.name}
          <a onClick={this.handleUp}> <Glyphicon glyph='arrow-up'/></a>
          <a onClick={this.handleDown}> <Glyphicon glyph='arrow-down'/></a>
        </li>
    );
  }
});

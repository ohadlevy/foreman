var LookupKeyOrderList = React.createClass({
  getInitialState: function () {
    return {order: this.props.data.order, inputName: this.props.data.input_name};
  },
  reOrder: function (name, newPosition, oldPosition) {
    console.log('child ' + name + ' has changed position from: ' + oldPosition + ' to: ' + newPosition);
    var list = this.state.order;
    if (newPosition < 0 || newPosition >= list.length) {
      // min/max edge cases
      console.log('invalid position in array');
      return false;
    }
    // swap positions
    var valueToSwap = list[newPosition];
    list[newPosition] = name;
    list[oldPosition] = valueToSwap;

    this.setState({order: list});
  },
  addNewElement: function (event) {
    event.preventDefault();

    newName = 'works';
    var list = this.state.order;
    if (list.indexOf(newName) === -1)
      list = list.concat(newName);

    this.setState({order: list});
  },

  render: function () {
    var self = this;
    var listLength = this.state.order.length;

    return (
        <ul>
          {this.state.order.map(function (element, i) {
              return <LookupKeyOrderElement name={element} position={i} key={element} changeCallback={self.reOrder} listLength={listLength}/>
              })}

          <button onClick={this.addNewElement}><Glyphicon glyph='plus'/></button>

          {/* adds a text area to keep compatibility with current rails form. */}
          <textarea value={this.state.order.join('\n')}
                    name={this.state.inputName}
                    readOnly
                    hidden
          />
        </ul>
    );
  }
});

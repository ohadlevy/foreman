var LookupKeyOrderList = React.createClass({
  getInitialState: function () {
    return {order: this.props.data.order, inputName: this.props.data.input_name }
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
  render: function () {
    var self = this;

    return (
        <ul>
          {this.state.order.map(function (element, i) {
            return <LookupKeyOrderElement name={element} position={i} key={element} changeCallback={self.reOrder}/>
          })}
          <textarea type="text"
                    value={this.state.order.join('\n')}
                    //onChange={fill_in_matchers()}
                    id='order'
                    name={this.state.inputName}
                    readOnly={true}
                    hidden={true} />
        </ul>
    );
  }
});

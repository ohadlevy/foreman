var Icon = React.createClass({
  propTypes: {
    name: React.PropTypes.string
  },

  render: function () {
    var className = 'glyphicon glyphicon-' + this.props.name;
    return (
        <span className={className} aria-hidden="true"/>
    );
  }
});

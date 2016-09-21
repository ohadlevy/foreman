import React, { Component } from 'react';
import helpers from '../../common/helpers';
import {Form, FormGroup, ControlLabel, FormControl, Button} from 'react-bootstrap';

class Search extends Component {
  constructor(props) {
    super(props);
    this.state = { value: this.props.query || ''};
    helpers.bindMethods(this, ['handleChange', 'clearClicked', 'handleSubmit' ]);
  }
  handleChange(event) {
    event.preventDefault();
    this.setState({value: event.target.value});
  }
  clearButton() {
    let content;

    if (this.state.value.length > 0) {
      content = (
        <Button className="clear" onClick={this.clearClicked}>
          <span className="pficon pficon-close"></span>
        </Button>
      );
    }
    return content;
  }
  clearClicked(event) {
    event.preventDefault();
    this.setState({value: ''});
  }
  handleSubmit(event) {
    event.preventDefault();
    let query = this.state.value.trim();

    if (!query) {
      return;
    }
    // TODO: send request to the server
    this.setState({value: ''});
  }
  render() {
    return (
      <Form role="form" className="search-pf has-button" onSubmit={this.handleSubmit}>
        <FormGroup className="has-clear" controlId="search1">
          <div className="search-pf-input-group">
            <ControlLabel srOnly={true}>Search</ControlLabel>
            <FormControl
              type="search"
              value={this.state.value}
              placeholder="Search"
              onChange={this.handleChange}
              />
            {this.clearButton()}
          </div>
        </FormGroup>
        <FormGroup>
          <Button type="submit" bsStyle="default"><span className="fa fa-search"></span></Button>
        </FormGroup>
      </Form>
    );
  }
}

export default Search; // Don’t forget to use export default!

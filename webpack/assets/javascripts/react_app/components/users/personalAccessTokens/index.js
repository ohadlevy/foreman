import React from 'react';
import Button from '../../common/forms/Button';
import TokenForm from './tokenForm/';
import * as PersonalAccessTokenActions from '../../../redux/actions/users/personalAccessTokens';
import { connect } from 'react-redux';

class PersonalAccessToken extends React.Component {
  render() {
    const { attributes, isOpen, updateForm } = this.props;

    const button = (
      <Button className="btn-success" onClick={this.props.showForm.bind(this)}>
        {__('Create Personal Access Token')}
      </Button>
    );

    const form = <TokenForm {...attributes} updateForm={updateForm}/>;

    return isOpen ? form : button;
  }
}

const mapStateToProps = state => ({
  isOpen: state.users.personalAccessTokens.isOpen,
  attributes: state.users.personalAccessTokens.attributes
});

export default connect(mapStateToProps, PersonalAccessTokenActions)(PersonalAccessToken);

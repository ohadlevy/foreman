import React from 'react';
import Button from '../../common/forms/Button';
import TokenForm from './tokenForm/';
import * as PersonalAccessTokenActions from '../../../redux/actions/users/personalAccessTokens';
import { connect, Provider } from 'react-redux';

class PersonalAccessToken extends React.Component {
  render() {
    const { attributes, isOpen, isSuccessful,
      updateForm, showFormSuccess,
      store, data, body } = this.props;

    const button = (
      <p>
      <Button className="btn-success" onClick={this.props.showForm.bind(this)}>
        {__('Create Personal Access Token')}
      </Button>
      </p>
    );

    const form = (
      <Provider store={store}>
      <TokenForm {...attributes} updateForm={updateForm}
      data={data} showFormSuccess={showFormSuccess}/>
      </Provider>
    );

    if (isSuccessful) {
      return <pre>{body.token_value}</pre>;
    }

    return isOpen ? form : button;
  }
}

const mapStateToProps = state => ({
  isOpen: state.users.personalAccessTokens.isOpen,
  isSuccessful: state.users.personalAccessTokens.isSuccessful,
  body: state.users.personalAccessTokens.body,
  attributes: state.users.personalAccessTokens.attributes
});

export default connect(mapStateToProps, PersonalAccessTokenActions)(PersonalAccessToken);

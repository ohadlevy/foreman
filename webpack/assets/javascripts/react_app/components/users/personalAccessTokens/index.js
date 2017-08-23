import React from 'react';
import Button from '../../common/forms/Button';
import TokenForm from './tokenForm/';
import * as PersonalAccessTokenActions from '../../../redux/actions/users/personalAccessTokens';
import { connect } from 'react-redux';

class PersonalAccessToken extends React.Component {
  onSubmit(values) {
    this.props.submitForm(values, this.props.user_id);
  }
  onCancel() {
    alert('not implemented');
  }
  render() {
    const {
      attributes,
      isOpen,
      isSuccessful,
      showFormSuccess,
      data,
      showForm,
      body
    } = this.props;

    const button = (
      <p>
        <Button className="btn-success" onClick={showForm.bind(this)}>
          {__('Create Personal Access Token')}
        </Button>
      </p>
    );

    const form = (
      <TokenForm
        {...attributes}
        data={data}
        onSubmit={this.onSubmit.bind(this)}
        onCancel={this.onCancel.bind(this)}
        showFormSuccess={showFormSuccess}
        />
    );

    if (isSuccessful) {
      return (
        <pre>
          {body.token_value}
        </pre>
      );
    }

    return isOpen ? form : button;
  }
}

const mapStateToProps = ({ users }) => ({
  isOpen: users.personalAccessTokens.isOpen,
  isSuccessful: users.personalAccessTokens.isSuccessful,
  body: users.personalAccessTokens.body,
  attributes: users.personalAccessTokens.attributes
});

export default connect(mapStateToProps, PersonalAccessTokenActions)(PersonalAccessToken);

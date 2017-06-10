import React from 'react';
import Button from '../../common/forms/Button';
import Alert from '../../common/Alert';
import TokenForm from './tokenForm/';
import * as PersonalAccessTokenActions from '../../../redux/actions/users/personalAccessTokens';
import ClipboardButton from 'react-clipboard.js';
import TokenList from './TokenList';

import { connect } from 'react-redux';

class PersonalAccessTokens extends React.Component {
  componentDidMount() {
    // eslint-disable-next-line camelcase
    const { data: { user_id }, getTokens } = this.props;

    getTokens(user_id);
  }

  render() {
    const {
      attributes,
      isOpen,
      isSuccessful,
      submitForm,
      hideForm,
      showForm,
      data,
      tokens,
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
      <TokenForm {...attributes} hideForm={hideForm} data={data} submitForm={submitForm} />
    );

    let headerActions;

    if (isSuccessful) {
      headerActions = (
        <Alert type="success" onClose={hideForm} title={__('Your New Personal Access Token')}>
          <code style={{ fontSize: '120%' }}>{body.token_value}</code>
          &nbsp;
          <ClipboardButton
            data-clipboard-text={body.token_value}
            component="a"
            title={__('Copy to clipboard!')}
          >
            <i className="fa fa-clipboard" aria-hidden="true" />
          </ClipboardButton>
          <br />
          {__(
            'Make sure to copy your new personal access token now. You won’t be able to see it again!'
          )}
        </Alert>
      );
    } else {
      headerActions = isOpen ? form : button;
    }

    return (
      <div className="row">
        <div className="col-md-12">
         <p>{__('Personal Access Tokens allow you to authenticate API requests without using your password.')}</p>
         {headerActions}
         <TokenList tokens={tokens ? tokens.filter(token => token['active?']) : undefined}
           title={__('Active Personal Access Tokens')}
           emptyText={__('This user does not have any active Personal Access Tokens.')}
           revocable="true"
          />
         <TokenList tokens={tokens ? tokens.filter(token => !token['active?']) : undefined}
           title={__('Inactive Personal Access Tokens')}
           emptyText={__('This user does not have any inactive Personal Access Tokens.')}
         />
        </div>
      </div>
    );
  }
}

const mapStateToProps = ({ users }) => ({
  isOpen: users.personalAccessTokens.isOpen,
  isSuccessful: users.personalAccessTokens.isSuccessful,
  body: users.personalAccessTokens.body,
  attributes: users.personalAccessTokens.attributes,
  tokens: users.personalAccessTokens.tokens
});

export default connect(mapStateToProps, PersonalAccessTokenActions)(PersonalAccessTokens);

import React from 'react';
import Button from '../../common/forms/Button';
import AlertPanel from '../../common/AlertPanel';
import TokenForm from './tokenForm/';
import * as PersonalAccessTokenActions from '../../../redux/actions/users/personalAccessTokens';
import ClipboardButton from 'react-clipboard.js';
import TokenList from './TokenList';

import { connect } from 'react-redux';

class PersonalAccessToken extends React.Component {
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

    if (isSuccessful) {
      return (
        <AlertPanel type="success" onClose={hideForm} title={__('Your New Personal Access Token')}>
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
        </AlertPanel>
      );
    }

    return (
      <div>
        {isOpen ? form : button}
        <TokenList tokens={tokens} />
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

export default connect(mapStateToProps, PersonalAccessTokenActions)(PersonalAccessToken);

import React from 'react';
import TextInput from '../../../common/forms/TextInput';
import Submit from '../../../common/forms/Submit';

class TokenForm extends React.Component {
  render() {
    const { name, updateForm } = this.props;
    // TODO this needs to be extracted somewhere
    // more complicated than it should.
    const getEventValue = e => {
    if (!e.target) {
      return e;
    }
    return e.target.type === 'checkbox' ? e.target.checked : e.target.value;
  };

  const _updateForm = (attribute, e) => {
    updateForm({ [attribute]: getEventValue(e) });
  };

    return (
      <form className="form-horizontal well">
        <TextInput label={__('name')} value={name} onChange={_updateForm.bind(this, 'name')} />
        <Submit />
      </form>
    );
  }
}
export default TokenForm;

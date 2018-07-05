import React from 'react';
import debounce from 'lodash/debounce';
import { TypeAheadSelect } from 'patternfly-react';
import { Menu, MenuItem, Highlighter } from 'react-bootstrap-typeahead';
import './auto-complete.scss';
import { STATUS } from '../../constants';

const AutoCompleteSearchBox = (props) => {
  let _typeahead = null;
  const TYPE_DELAY = 250;

  const inputChanged = (input) => {
    debounce(() => {
      props.getOptions(input);
    }, TYPE_DELAY);
  };
  const handleInputChange = (query) => {
    inputChanged(query);
  };

  const handleInputFocus = ({ target }) => {
    inputChanged(target.value);
  };

  const handleItemSelect = (selectedOptions) => {
    // adds additional whitespace to query
    const query = `${selectedOptions[0].trim()} `;
    props.getOptions(query);
    /**
    *  HACK: I had no choice but to call to an inner function,
    * due to lack of design in react-bootstrap-typeahead.
    */
    _typeahead.getInstance()._showMenu();
  };

  const handleClear = () => {
    _typeahead.getInstance().clear();
    props.getOptions('');
  };

  const filterResult = ({ label }, { text }) =>
    label.replace(/\s/g, '').includes(text.replace(/\s/g, ''));

  const groupBy = (list, keyGetter) => {
    const map = new Map();
    list.forEach((item) => {
      const key = keyGetter(item);
      const collection = map.get(key);
      if (!collection) {
        map.set(key, [item]);
      } else {
        collection.push(item);
      }
    });
    return map;
  };

  const renderMenu = (results, menuProps) => {
    let idx = 0;
    const grouped = groupBy(results, ({ category }) => category);
    const items = [...grouped.entries()].sort().map(category => [
      !!idx && <Menu.Divider key={`${category}-divider`} />,
      <Menu.Header key={`${category}-header`}>{category[0]}</Menu.Header>,
      category[1].map(({ label }) => {
        const item = (
          <MenuItem key={idx} option={label} position={idx}>
            <Highlighter search={menuProps.text}>{label}</Highlighter>
          </MenuItem>
        );
        idx += 1;
        return item;
      }),
    ]);
    return <Menu {...menuProps}>{items}</Menu>;
  };

  return (
    <div>
      <TypeAheadSelect
        placeholder={__('Filter ...')}
        options={props.options}
        isLoading={props.status === STATUS.PENDING}
        filterBy={filterResult}
        onInputChange={handleInputChange}
        onChange={handleItemSelect}
        onFocus={handleInputFocus}
        renderMenu={renderMenu}
        defaultInputValue={props.data.search ? props.data.search : ''}
        emptyLabel={null}
        highlightOnlyResult={true}
        ref={(ref) => {
          _typeahead = ref;
        }}
      />
      <a className="clear-button" onClick={handleClear} title="" data-original-title="Clear">
        &times;
      </a>
    </div>
  );
};

export default AutoCompleteSearchBox;

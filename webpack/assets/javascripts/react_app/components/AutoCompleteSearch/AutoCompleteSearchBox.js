import React from 'react';
import _ from 'lodash';
import { TypeAheadSelect } from 'patternfly-react';
import { Menu, MenuItem, Highlighter } from 'react-bootstrap-typeahead';
import './auto-complete.scss';
import { STATUS } from '../../constants';

class AutoCompleteSearchBox extends React.Component {
  constructor(props) {
    super(props);
    this.handleInputChange = _.debounce(this.handleInputChange, 250);
    this.handleInputFocus = _.debounce(this.handleInputFocus, 250);
    this.handleClear = this.handleClear.bind(this);
    this.filterResult = this.filterResult.bind(this);
    this.groupBy = this.groupBy.bind(this);
    this.handleInputChange = this.handleInputChange.bind(this);
    this.handleItemSelect = this.handleItemSelect.bind(this);
    this.handleInputFocus = this.handleInputFocus.bind(this);
    this.handleClear = this.handleClear.bind(this);
    this.renderMenu = this.renderMenu.bind(this);
  }

  handleInputChange(query) {
    this.props.getOptions(query);
  }

  handleItemSelect(selectedOptions) {
    const query = `${selectedOptions[0]} `;
    if (query) {
      this.props.getOptions(query);
      /**
       *  HACK: I had no choice but to call to an inner function,
       * due to lack of design in react-bootstrap-typeahead.
        */
      this._typeahead.getInstance()._showMenu();
    }
  }

  handleInputFocus(e) {
    this.props.getOptions(e.target.value);
  }

  handleClear() {
    this._typeahead.getInstance().clear();
    this.props.getOptions('');
  }

  filterResult(option, props) {
    return option.label.replace(/\s/g, '').includes(props.text.replace(/\s/g, ''));
  }

  groupBy(list, keyGetter) {
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
  }

  renderMenu(results, menuProps) {
    let idx = 0;
    const grouped = this.groupBy(results, r => r.category);
    const items = [...grouped.entries()].sort().map(category => [
      !!idx && <Menu.Divider key={`${category}-divider`} />,
            <Menu.Header key={`${category}-header`}>
                {category[0]}
            </Menu.Header>,
            category[1].map((option) => {
              const item =
                    <MenuItem key={idx} option={option.label} position={idx}>
                        <Highlighter search={menuProps.text}>
                            {option.label}
                        </Highlighter>
                    </MenuItem>;
              idx += 1;
              return item;
            }),
    ]);
    return <Menu {...menuProps}>{items}</Menu>;
  }

  render() {
    return (
            <div>
                <TypeAheadSelect
                    placeholder={__('Filter ...')}
                    options={this.props.options}
                    isLoading={this.props.status === STATUS.PENDING}
                    filterBy={this.filterResult}
                    onInputChange={this.handleInputChange}
                    onChange={this.handleItemSelect}
                    onFocus={this.handleInputFocus}
                    renderMenu={this.renderMenu}
                    defaultInputValue={this.props.data.search ? this.props.data.search : ''}
                    emptyLabel={null}
                    highlightOnlyResult={true}
                    ref={(ref) => { this._typeahead = ref; }}
                />
                <a
                    className="clear-button"
                    onClick={this.handleClear}
                    title=""
                    data-original-title="Clear">
                    ×
                </a>
            </div>
    );
  }
}

export default AutoCompleteSearchBox;

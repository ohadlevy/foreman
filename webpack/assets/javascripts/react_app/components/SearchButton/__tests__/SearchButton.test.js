import toJson from 'enzyme-to-json';
import { mount } from 'enzyme';
import React from 'react';
import SearchButton from '../SearchButton';

const URL = 'http://localhost';
const SEARCH_QUERY = 'name';

const wrapper = () => mount(<SearchButton searchQuery={SEARCH_QUERY} />);

const setupTurbolinksMock = () => {
  global.Turbolinks = {
    visit: jest.fn(),
  };

  Object.defineProperty(window.location, 'href', {
    writable: true,
    value: URL,
  });
};

describe('SearchButton', () => {
  it('should match snapshot', () => {
    expect(toJson(wrapper())).toMatchSnapshot();
  });
});

describe('SearchButton', () => {
  it('should create a link with the search query', () => {
    setupTurbolinksMock();
    wrapper()
      .find('button')
      .simulate('click');
    expect(global.Turbolinks.visit).toBeCalled();
    expect(global.Turbolinks.visit).toHaveBeenLastCalledWith(`${URL}/?search=${SEARCH_QUERY}`);
  });
});

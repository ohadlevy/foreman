import URI from 'urijs';
import React from 'react';
import { Button, Icon } from 'patternfly-react';

const handleClick = (searchQuery) => {
  const uri = new URI(window.location.href);
  uri.setSearch('search', searchQuery.trim());
  window.Turbolinks.visit(uri.toString());
};

const SearchButton = ({ searchQuery }) => (
    <Button
        onClick={() => handleClick(searchQuery)}>
        <Icon name="search" />
        {' Search'}
    </Button>
);

export default SearchButton;

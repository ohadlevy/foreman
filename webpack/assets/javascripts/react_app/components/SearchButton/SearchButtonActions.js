import URI from 'urijs';

export const runSearch = (searchQuery) => {
  const uri = new URI(window.location.href);
  uri.setSearch('search', searchQuery.trim());
  window.Turbolinks.visit(uri.toString());
};

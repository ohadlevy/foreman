export const breadcrumbItems = {
  items: [
    {
      caption: 'root',
      url: '/some-url',
    },
    {
      caption: 'child',
    },
  ],
};

export const breadcrumbTitleItems = {
  items: [
    {
      caption: 'title',
    },
  ],
};

export const resource = {
  reosurceUrl: 'some/url', nameField: 'name', switcherItemUrl: 'some/url/:id',
};

export const resourceList = [
  { name: 'Host 1', url: '#' },
  { name: 'Host 2', url: '#' },
  { name: 'Host 3 with a very long name', url: '#' },
  { name: 'Host 4', url: undefined, onClick: jest.fn() },
  { name: 'Host 5', url: '#', onClick: undefined },
];

export const serverResourceListResponse = {
  data: {
    page: 1,
    total: 3,
    per_page: 2,
    results: [
      { id: '1', name: 'name-1' },
      { id: '2', name: 'name-2' },
      { id: '3', name: 'name-3' },
    ],
  },
};

export const breadcrumbSwitcherLoading = {
  loading: true,
  resources: [],
};

export const breadcrumbSwitcherLoaded = {
  loading: false,
  resources: resourceList,
};

export const breadcrumbSwitcherLoadedWithPagination = {
  ...breadcrumbSwitcherLoaded,
  currentPage: 2,
  totalPages: 3,
};

export const breadcrumbBar = {
  data: {
    resource,
    breadcrumbItems: breadcrumbItems.items,
    isSwitchable: false,
  },
};

export const breadcrumbBarSwithcable = {
  data: {
    resource,
    breadcrumbItems: breadcrumbItems.items,
    isSwitchable: true,
  },
};

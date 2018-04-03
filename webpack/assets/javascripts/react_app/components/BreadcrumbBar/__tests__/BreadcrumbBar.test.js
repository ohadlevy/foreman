import React from 'react';
import { shallow } from 'enzyme';

import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import BreadcrumbBar from '../BreadcrumbBar';
import BreadcrumbSwitcher from '../components/BreadcrumbSwitcher';
import { breadcrumbBar, breadcrumbBarSwithcable } from '../BreadcrumbBar.fixtures';

const createStubs = () => ({
  toggleSwitcher: jest.fn(),
  closeSwitcher: jest.fn(),
  loadSwitcherResourcesByResource: jest.fn(),
});

const fixtures = {
  'renders breadcrumb-bar': breadcrumbBar,
  'renders switchable breadcrumb-bar': breadcrumbBarSwithcable,
};

describe('BreadcrumbBar', () => {
  describe('rendering', () => testComponentSnapshotsWithFixtures(BreadcrumbBar, fixtures));

  describe('triggering', () => {
    it('should trigger callbacks', () => {
      const props = { ...breadcrumbBarSwithcable, ...createStubs() };
      const component = shallow(<BreadcrumbBar {...props} />);

      const breadcrumbswitcher = component.find(BreadcrumbSwitcher);

      expect(props.toggleSwitcher.mock.calls.length).toBe(0);
      expect(props.closeSwitcher.mock.calls.length).toBe(0);
      expect(props.loadSwitcherResourcesByResource.mock.calls.length).toBe(0);

      breadcrumbswitcher.simulate('togglerClick');
      expect(props.toggleSwitcher.mock.calls.length).toBe(1);

      breadcrumbswitcher.simulate('overlayHide');
      expect(props.closeSwitcher.mock.calls.length).toBe(1);

      breadcrumbswitcher.simulate('overlayEnter');
      expect(props.loadSwitcherResourcesByResource.mock.calls.length).toBe(1);

      breadcrumbswitcher.simulate('nextPageClick');
      expect(props.loadSwitcherResourcesByResource.mock.calls.length).toBe(2);

      breadcrumbswitcher.simulate('prevPageClick');
      expect(props.loadSwitcherResourcesByResource.mock.calls.length).toBe(3);

      expect(props.loadSwitcherResourcesByResource.mock.calls).toMatchSnapshot('loadSwitcherResourcesByResource calls');
    });
  });
});

import React from 'react';
import { shallow } from 'enzyme';
import { Overlay } from 'react-bootstrap';

import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import BreadcrumbSwitcher from './BreadcrumbSwitcher';
import BreadcrumbSwitcherToggler from './BreadcrumbSwitcherToggler';
import BreadcrumbSwitcherPopover from './BreadcrumbSwitcherPopover';
import {
  breadcrumbSwitcherLoading,
  breadcrumbSwitcherLoaded,
  breadcrumbSwitcherLoadedWithPagination,
} from '../BreadcrumbBar.fixtures';

const createStubs = () => ({
  onTogglerClick: jest.fn(),
  onOverlayEnter: jest.fn(),
  onOverlayHide: jest.fn(),
  onPrevPageClick: jest.fn(),
  onNextPageClick: jest.fn(),
});

const fixtures = {
  'render closed': { open: false, ...createStubs() },
  'render loading state': { open: true, ...breadcrumbSwitcherLoading, ...createStubs() },
  'render resources list': { open: true, ...breadcrumbSwitcherLoaded, ...createStubs() },
  'render resources list with pagination': {
    open: true,
    ...breadcrumbSwitcherLoadedWithPagination,
    ...createStubs(),
  },
};

describe('BreadcrumbSwitcher', () => {
  describe('rendering', () => testComponentSnapshotsWithFixtures(BreadcrumbSwitcher, fixtures));

  describe('triggering', () => {
    it('should trigger callbacks', () => {
      const props = {
        currentPage: 2,
        totalPages: 3,
        ...createStubs(),
      };
      const component = shallow(<BreadcrumbSwitcher {...props} />);

      const togglerButton = component.find(BreadcrumbSwitcherToggler);
      const overlay = component.find(Overlay);
      const popover = component.find(BreadcrumbSwitcherPopover);

      expect(props.onTogglerClick.mock.calls.length).toBe(0);
      expect(props.onOverlayEnter.mock.calls.length).toBe(0);
      expect(props.onOverlayHide.mock.calls.length).toBe(0);
      expect(props.onPrevPageClick.mock.calls.length).toBe(0);
      expect(props.onNextPageClick.mock.calls.length).toBe(0);

      togglerButton.simulate('click');
      expect(props.onTogglerClick.mock.calls.length).toBe(1);

      overlay.simulate('enter');
      expect(props.onOverlayEnter.mock.calls.length).toBe(1);

      popover.simulate('nextPageClick');
      expect(props.onNextPageClick.mock.calls.length).toBe(1);

      popover.simulate('prevPageClick');
      expect(props.onPrevPageClick.mock.calls.length).toBe(1);

      overlay.simulate('hide');
      expect(props.onOverlayHide.mock.calls.length).toBe(1);
    });
  });
});

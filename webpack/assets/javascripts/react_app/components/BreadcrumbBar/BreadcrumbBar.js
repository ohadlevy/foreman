import React from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../common/helpers';
import Breadcrumb from './components/Breadcrumb';
import BreadcrumbSwitcher from './components/BreadcrumbSwitcher';

class BreadcrumbBar extends React.Component {
  render() {
    const {
      data: { breadcrumbItems, isSwitchable, resource },
      currentPage,
      totalPages,
      resourceSwitcherItems,
      isLoadingResources,
      hasError,
      isSwitcherOpen,
      toggleSwitcher,
      closeSwitcher,
      loadSwitcherResourcesByResource,
    } = this.props;

    const isTitle = breadcrumbItems.length === 1;
    return (
      <div className="breadcrumb-bar">
        <Breadcrumb title items={breadcrumbItems} isTitle={isTitle}>
          {isSwitchable && (
            <BreadcrumbSwitcher
              open={isSwitcherOpen}
              isLoadingResources={isLoadingResources}
              hasError={hasError}
              resources={resourceSwitcherItems}
              onTogglerClick={() => toggleSwitcher()}
              onOverlayHide={() => closeSwitcher()}
              onOverlayEnter={() => loadSwitcherResourcesByResource(resource)}
              onNextPageClick={() =>
                 loadSwitcherResourcesByResource(resource, { page: Number(currentPage) + 1 }) }
              onPrevPageClick={() =>
                 loadSwitcherResourcesByResource(resource, { page: Number(currentPage) - 1 }) }
              currentPage={currentPage}
              totalPages={totalPages}
            />
          )}
        </Breadcrumb>
        {!isTitle && <hr className="breadcrumb-line" />}
      </div>
    );
  }
}

BreadcrumbBar.propTypes = {
  data: PropTypes.shape({
    isSwitchable: PropTypes.bool,
    resource: PropTypes.shape({
      nameField: PropTypes.string,
      reosurceUrl: PropTypes.string,
      switcherItemUrl: PropTypes.string,
    }),
    breadcrumbItems: Breadcrumb.propTypes.items,
  }),
  currentPage: PropTypes.number,
  totalPages: PropTypes.number,
  resourceSwitcherItems: BreadcrumbSwitcher.propTypes.resources,
  isLoadingResources: PropTypes.bool,
  hasError: PropTypes.bool,
  isSwitcherOpen: PropTypes.bool,
  toggleSwitcher: PropTypes.func,
  closeSwitcher: PropTypes.func,
  loadSwitcherResourcesByResource: PropTypes.func,
};

BreadcrumbBar.defaultProps = {
  data: {
    breadcrumbItems: [],
    isSwitchable: false,
  },
  currentPage: 1,
  totalPages: 1,
  resourceSwitcherItems: [],
  isLoadingResources: false,
  hasError: false,
  isSwitcherOpen: false,
  toggleSwitcher: noop,
  closeSwitcher: noop,
  loadSwitcherResourcesByResource: noop,
};

export default BreadcrumbBar;

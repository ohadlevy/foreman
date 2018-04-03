import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { Overlay } from 'react-bootstrap';

import { noop } from '../../../common/helpers';

import BreadcrumbSwitcherPopover from './BreadcrumbSwitcherPopover';
import BreadcrumbSwitcherToggler from './BreadcrumbSwitcherToggler';

class BreadcrumbSwitcher extends React.Component {
  render() {
    const {
      open,
      currentPage,
      totalPages,
      isLoadingResources,
      hasError,
      resources,
      onTogglerClick,
      onOverlayHide,
      onOverlayEnter,
      onNextPageClick,
      onPrevPageClick,
    } = this.props;

    return (
      <div className="breadcrumb-switcher" style={{ position: 'relative' }}>
        <BreadcrumbSwitcherToggler
          onClick={() => onTogglerClick()}
          ref={(ref) => {
            this.togglerRef = ref;
          }}
        />

        <Overlay
          rootClose
          show={open}
          container={this}
          placement="bottom"
          onHide={() => onOverlayHide()}
          onEnter={() => onOverlayEnter()}
          target={() => ReactDOM.findDOMNode(this.togglerRef)}
        >
          <BreadcrumbSwitcherPopover
            id="breadcrumb-switcher-popover"
            loading={isLoadingResources}
            hasError={hasError}
            resources={resources}
            onNextPageClick={() => onNextPageClick()}
            onPrevPageClick={() => onPrevPageClick()}
            currentPage={currentPage}
            totalPages={totalPages}
          />
        </Overlay>
      </div>
    );
  }
}

BreadcrumbSwitcher.propTypes = {
  open: PropTypes.bool,
  currentPage: PropTypes.number,
  totalPages: PropTypes.number,
  isLoadingResources: PropTypes.bool,
  hasError: PropTypes.bool,
  resources: BreadcrumbSwitcherPopover.propTypes.resources,
  onTogglerClick: PropTypes.func,
  onOverlayHide: PropTypes.func,
  onOverlayEnter: PropTypes.func,
  onPrevPageClick: PropTypes.func,
  onNextPageClick: PropTypes.func,
};

BreadcrumbSwitcher.defaultProps = {
  open: false,
  currentPage: 1,
  totalPages: 1,
  isLoadingResources: false,
  hasError: false,
  resources: [],
  onTogglerClick: noop,
  onOverlayHide: noop,
  onOverlayEnter: noop,
  onPrevPageClick: noop,
  onNextPageClick: noop,
};

export default BreadcrumbSwitcher;

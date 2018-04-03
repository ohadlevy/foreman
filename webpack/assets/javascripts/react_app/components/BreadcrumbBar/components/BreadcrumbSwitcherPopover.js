import React from 'react';
import PropTypes from 'prop-types';
import { Popover, ListGroup, ListGroupItem, Pager, Icon } from 'patternfly-react';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import './BreadcrumbSwitcherPopover.scss';

const BreadcrumbSwitcherPopover = ({
  resources,
  onNextPageClick,
  onPrevPageClick,
  loading,
  hasError,
  currentPage,
  totalPages,
  ...props
}) => {
  let popoverBody;

  if (loading) {
    popoverBody = (
      <div className="breadcrumb-switcher-popover-loading text-center">
        <Icon name="spinner" spin size="lg" />
      </div>
    );
  } else if (hasError) {
    popoverBody = (<div className="breadcrumb-switcher-popover-error">{__('Error: Unable to load resources.')}</div>);
  } else {
    popoverBody = (
      <React.Fragment>
        <ListGroup className="scrollable-list">
          {resources.map(({ onClick, url, name }) => (
            <ListGroupItem className="no-border" key={`id-${name}`} href={url} onClick={onClick}>
              <EllipsisWithTooltip>{name}</EllipsisWithTooltip>
            </ListGroupItem>
          ))}
        </ListGroup>
        <Pager
          className="pager-sm"
          messages={{ nextPage: __('Next'), previousPage: __('Previous') }}
          onNextPage={onNextPageClick}
          onPreviousPage={onPrevPageClick}
          disablePrevious={currentPage === 1}
          disableNext={currentPage === Math.ceil(totalPages)}
        />
      </React.Fragment>
    );
  }

  return (
    <Popover className="breadcrumb-switcher-popover" {...props}>
      {popoverBody}
    </Popover>
  );
};

BreadcrumbSwitcherPopover.propTypes = {
  ...Popover.propTypes,
  loading: PropTypes.bool,
  hasError: PropTypes.bool,
  currentPage: PropTypes.number,
  totalPages: PropTypes.number,
  resources: PropTypes.arrayOf(PropTypes.shape({
    name: PropTypes.string.isRequired,
    href: PropTypes.string,
    onClick: PropTypes.func,
  })),
};

BreadcrumbSwitcherPopover.defaultProps = {
  loading: false,
  hasError: false,
  currentPage: 1,
  totalPages: 1,
  resources: [],
};

export default BreadcrumbSwitcherPopover;

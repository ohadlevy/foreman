import React from 'react';
import PropTypes from 'prop-types';
import { VncConsole } from '@patternfly/react-console';
import { VNC } from './Console.constants';

const Console = props => {
  const getVncAttributes = ({
    host,
    proxy_port,
    encrypt,
    password,
  } = props) => ({
    host,
    port: proxy_port,
    encrypt,
    credentials: { password },
  });

  const console = () => {
    const { type } = props;
    switch (type) {
      case VNC:
        return <VncConsole {...getVncAttributes()} />;
      default:
        return null;
    }
  };
  const showPassword = <p>show password: {props.password}</p>;

  return (
    <div>
      {showPassword}
      {console()}
    </div>
  );
};

Console.propTypes = {
  type: PropTypes.oneOf([VNC]),
  host: PropTypes.string.isRequired /** FQDN or IP to connect to */,
  port: PropTypes.string /** TCP Port */,
  password: PropTypes.string.isRequired /** host:port/path */,
  encrypt:
    PropTypes.bool /** For all following, see: https://github.com/novnc/noVNC/blob/master/docs/API.md */,
};

Console.defaultProps = {
  type: VNC,
  port: '',
  encrypt: false,
};

export default Console;

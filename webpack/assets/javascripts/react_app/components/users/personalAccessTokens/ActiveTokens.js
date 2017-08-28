import React from 'react';
import Token from './Token';

export default ({ tokens }) =>
  <table className="table table-bordered table-striped table-fixed">
    <thead>
      <tr>
        <th>
          {__('Name')}
        </th>
        <th>
          {__('Created')}
        </th>
        <th>
          {__('Expires')}
        </th>
        <th>
          {__('Last Used')}
        </th>
        <th>
          {__('Actions')}
        </th>
      </tr>
    </thead>
    <tbody>
      {tokens && tokens.map(token => <Token key={token.id} {...token} />)}
    </tbody>
  </table>;

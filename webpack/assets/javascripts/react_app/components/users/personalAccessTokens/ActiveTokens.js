import React from 'react';

export default ({ tokens }) =>
  <table>
    <thead>
      <tr>
        <th>
          {__('Name')}
        </th>
        <th>
          {__('Created At')}
        </th>
        <th>
          {__('Expires At')}
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
      <tr>
        {tokens.length}
      </tr>
    </tbody>
  </table>;

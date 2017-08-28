import React from 'react';
import TimeAgo from '../../common/TimeAgo';

/* eslint-disable camelcase */
export default ({ id, name, created_at, expires_at, updated_at }) =>
  <tr>
    <td>
      {name}
    </td>
    <td>
      <TimeAgo date={created_at} />
    </td>
    <td>
      <TimeAgo date={expires_at} />
    </td>
    <td>
      <TimeAgo date={updated_at} />
    </td>
    <td>
      <span className="btn btn-sm btn-default">
        <a
          data-confirm="Are you sure?"
          data-id="aid_personal_access_tokens_1_revoke"
          rel="nofollow"
          data-method="put"
          href={`/users/${id}-admin/personal_access_tokens/${id}/revoke`}
        >
          Revoke
        </a>
      </span>
    </td>
  </tr>;

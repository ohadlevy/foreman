import React from 'react';
import TimeAgo from '../../common/TimeAgo';

/* eslint-disable camelcase */
export default ({ id, name, created_at, expires_at, last_used_at, user_id, revocable }) => (
  <tr>
    <td>{name}</td>
    <td>
      <TimeAgo date={created_at} />
    </td>
    <td>
      <TimeAgo date={expires_at} />
    </td>
    <td>
      <TimeAgo date={last_used_at} />
    </td>
    <td>
      {revocable && (
        <span className="btn btn-sm btn-default">
          <a
            data-confirm="Are you sure?"
            data-id="aid_personal_access_tokens_1_revoke"
            rel="nofollow"
            data-method="put"
            href={`/users/${user_id}/personal_access_tokens/${id}/revoke`}
          >
            Revoke
          </a>
        </span>
      )}
    </td>
  </tr>
);

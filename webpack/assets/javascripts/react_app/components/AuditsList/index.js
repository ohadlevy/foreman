import React from 'react';
import { ListView, Row, Col } from 'patternfly-react';

const heading = audit => audit.username;

const style = { color: '#999' };
const description = audit => (
  <ListView.Description>
    <ListView.DescriptionHeading style={style}>
      ({audit.remote_address})
    </ListView.DescriptionHeading>
    <ListView.DescriptionText>{audit.action}</ListView.DescriptionText>
    <ListView.DescriptionText>{audit.auditable_type}</ListView.DescriptionText>
    <ListView.AdditionalInfo>{audit.auditable_name}</ListView.AdditionalInfo>
  </ListView.Description>
);

export default ({ data: { audits } }) => (
  <div>
    <ListView>
      {audits.map(({ audit }) => (
        <ListView.Item
          key={audit.id}
          //   actions={renderActions(item.actions)}
          // checkboxInput={<input type="checkbox" />}
          // leftContent={<ListView.Icon name="plane" />}
          // additionalInfo={renderAdditionalInfoItems(item.properties)}
          heading={heading(audit)}
          description={description(audit)}
          stacked
        >
          <Row>
            <Col sm={11}>{audit.request_uuid}</Col>
          </Row>
        </ListView.Item>
      ))}
    </ListView>
  </div>
);

import React from 'react';
import { ListView, Row, Col } from 'patternfly-react';

export default ({ data: { audits } }) => (
  <div>
    <ListView>
      {audits.map(({ audit }, index) => (
        <ListView.Item
          key={index}
          //   actions={renderActions(item.actions)}
          checkboxInput={<input type="checkbox" />}
          leftContent={<ListView.Icon name="plane" />}
          //   additionalInfo={renderAdditionalInfoItems(item.properties)}
          heading={`${audit.username}(${audit.remote_address})`}
          description="a very long description"
          stacked
        >
          <Row>
            <Col sm={11}>{audit.expandedContentText}</Col>
          </Row>
        </ListView.Item>
      ))}
    </ListView>
  </div>
);

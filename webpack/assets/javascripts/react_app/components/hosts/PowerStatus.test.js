jest.unmock('./PowerStatus');

import React from 'react';
import { mount } from 'enzyme';
import PowerStatus from './PowerStatus';

describe('PowerStatus', () => {

  it('pending', () => {
    const box = mount(
      <PowerStatus
        loadingStatus="PENDING"
      />
    );

    expect(box.find('.spinner.spinner-xs').length).toBe(1);
  });

  it('error', () => {
    const box = mount(
      <PowerStatus
        loadingStatus="ERROR"
      />
    );

    expect(box.find('.fa.fa-power-off.host-power-status.na').length).toBe(1);
  });

  it('resolved', () => {
    const box = mount(
      <PowerStatus
        state="on"
        title="On"
        loadingStatus="RESOLVED"
     />
    );

    expect(box.find('.fa.fa-power-off.host-power-status.on').length).toBe(1);
    expect(box.find({title: 'On' }).length).toBe(1);
  });

    it('resolved', () => {
    const box = mount(
      <PowerStatus
        state="off"
        title="Off"
        loadingStatus="RESOLVED"
     />
    );

    expect(box.find('.fa.fa-power-off.host-power-status.off').length).toBe(1);
    expect(box.find({title: 'Off' }).length).toBe(1);
  });
});

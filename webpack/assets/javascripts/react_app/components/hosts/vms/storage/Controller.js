import React from 'react';
import Button from './Button';

const Controller = (props) => {
  const disks = props.disks.map((disk) => {
    // TODO: add disk component
    return disk;
  });
  return (
    <div className="col-md-3">
      <h2> Controller {props.position + 1} </h2>
      <h3> Total disks {props.disks.length}/{props.maxDisks} </h3>
      <h4> type:{props.type}, position:{props.position} </h4>
      <Button
        disabled={props.disks.length >= props.maxDisks}
        click={props.addDisk.bind(this, props.position)}>
        Create Disk
      </Button>
    </div>
  );
};

export default Controller;

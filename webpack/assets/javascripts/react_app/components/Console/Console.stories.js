import React from 'react';
import { storiesOf } from '@storybook/react';
import { withKnobs } from '@storybook/addon-knobs';
import Console from './Console';
import Story from '../../../../../stories/components/Story';

storiesOf('Components/Console', module)
  .addDecorator(withKnobs)
  .add('Console', () => (
    <Story narrow>
      <Console />
    </Story>
  ));

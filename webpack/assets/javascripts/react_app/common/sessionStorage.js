import Immutable from 'seamless-immutable';

export const loadState = () => {
  try {
    const seralizedState = sessionStorage.getItem('state');

    if (seralizedState === null) {
      return undefined;
    }
    return Immutable(JSON.parse(seralizedState));
  } catch (err) {
    return undefined;
  }
};

export const saveState = state => {
  try {
    const seralizedState = JSON.stringify(state);

    sessionStorage.setItem('state', seralizedState);
  } catch (err) {
    // ignore errors, todo log somewhere
  }
};

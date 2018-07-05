import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as actions from './AutoCompleteActions';
import AutoCompleteSearchBox from './AutoCompleteSearchBox';
import reducer from './AutoCompleteReducer';

export const reducers = { search: reducer };

const mapStateToProps = ({ search }) => ({ ...search });
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export default connect(mapStateToProps, mapDispatchToProps)(AutoCompleteSearchBox);

import { connect } from 'react-redux';
import SearchButton from './SearchButton';

const mapStateToProps = ({ search }) => ({ searchQuery: search.searchQuery });

export default connect(mapStateToProps)(SearchButton);

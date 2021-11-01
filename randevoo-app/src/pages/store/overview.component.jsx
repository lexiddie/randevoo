import React, { useEffect } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import { Input } from 'reactstrap';

import StoreOverview from '../../components/store-overview/store-overview.component';
import { startSearch } from '../../redux/store/store.actions';

const Overview = (props) => {
  const { startSearch } = props;
  const onChangeSearch = (event) => {
    const { value } = event.target;
    startSearch(value);
  };
  useEffect(() => {
    startSearch('');
  }, []);
  return (
    <>
      <div className='store-search'>
        <Input type='search' name='search' placeholder='Search' onChange={(e) => onChangeSearch(e)} />
      </div>
      <div className='store-content'>
        <StoreOverview />
      </div>
    </>
  );
};

const mapDispatchToProps = (dispatch) => ({
  startSearch: (searchKey) => dispatch(startSearch(searchKey))
});

export default withRouter(connect(null, mapDispatchToProps)(Overview));

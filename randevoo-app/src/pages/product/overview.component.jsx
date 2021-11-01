import React, { useEffect } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import { Input } from 'reactstrap';

import ProductOverview from '../../components/product-overview/product-overview.component';
import { startSearch } from '../../redux/product/product.actions';

const Product = (props) => {
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
      <div className='product-search'>
        <Input type='search' name='search' placeholder='Search' onChange={(e) => onChangeSearch(e)} />
      </div>
      <div className='product-content'>
        <ProductOverview />
      </div>
    </>
  );
};

const mapDispatchToProps = (dispatch) => ({
  startSearch: (searchKey) => dispatch(startSearch(searchKey))
});

export default withRouter(connect(null, mapDispatchToProps)(Product));

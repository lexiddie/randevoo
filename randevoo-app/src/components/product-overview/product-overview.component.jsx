import React from 'react';
import { connect } from 'react-redux';
import { createStructuredSelector } from 'reselect';
import { withRouter } from 'react-router-dom';

import ProductItem from '../product-item/product-item.component';

import { selectProducts, selectIsSearch, selectSearchProducts } from '../../redux/product/product.selectors';

const ProductOverview = (props) => {
  const { products, iProducts, isSearch, history } = props;

  const previewItem = (productId) => {
    history.push(`/admin/product/${productId}`);
  };
  return (
    <div className='product-overview'>
      <div>
        {isSearch
          ? iProducts.map((item) => <ProductItem key={item.id} item={item} previewItem={() => previewItem(item.id)} />)
          : products.map((item) => <ProductItem key={item.id} item={item} previewItem={() => previewItem(item.id)} />)}
      </div>
    </div>
  );
};

const mapStateToProps = createStructuredSelector({
  products: selectProducts,
  iProducts: selectSearchProducts,
  isSearch: selectIsSearch
});

export default withRouter(connect(mapStateToProps)(ProductOverview));

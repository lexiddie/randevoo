import React from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import ProductItem from '../product-item/product-item.component';

const StoreProductOverview = (props) => {
  const { products, history } = props;

  const previewItem = (productId) => {
    history.push(`/admin/product/${productId}`);
  };
  return (
    <div className='store-product-overview'>
      <div>
        {products.map((item) => (
          <ProductItem key={item.id} item={item} previewItem={previewItem} />
        ))}
      </div>
    </div>
  );
};

export default withRouter(connect()(StoreProductOverview));

import React from 'react';
import { connect } from 'react-redux';
import { withRouter, Route } from 'react-router-dom';

import Overview from './overview.component';
import Preview from '../../components/product-preview/product-preview.component';

const Product = (props) => {
  const { match } = props;

  return (
    <div className='product'>
      <div className='product-page'>
        <Route exact path={`${match.path}`} component={Overview} />
        <Route path={`${match.path}/:productId`} component={Preview} />
      </div>
    </div>
  );
};

export default withRouter(connect()(Product));

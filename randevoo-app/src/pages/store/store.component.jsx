import React from 'react';
import { connect } from 'react-redux';
import { withRouter, Route } from 'react-router-dom';

import Overview from './overview.component';
import Preview from '../../components/store-preview/store-preview.component';

const Store = (props) => {
  const { match } = props;

  return (
    <div className='store'>
      <div className='store-page'>
        <Route exact path={`${match.path}`} component={Overview} />
        <Route path={`${match.path}/:storeId`} component={Preview} />
      </div>
    </div>
  );
};

export default withRouter(connect()(Store));

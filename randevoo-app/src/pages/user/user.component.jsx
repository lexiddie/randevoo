import React from 'react';
import { connect } from 'react-redux';
import { withRouter, Route } from 'react-router-dom';

import Overview from './overview.component';
import Preview from '../../components/user-preview/user-preview.component';

const User = (props) => {
  const { match } = props;

  return (
    <div className='user'>
      <div className='user-page'>
        <Route exact path={`${match.path}`} component={Overview} />
        <Route path={`${match.path}/:userId`} component={Preview} />
      </div>
    </div>
  );
};

export default withRouter(connect()(User));

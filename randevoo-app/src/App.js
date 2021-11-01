import React from 'react';
import { withRouter, Switch, Route } from 'react-router-dom';
import { connect } from 'react-redux';

import Home from '../src/pages/home/home.component';
import Admin from '../src/pages/admin/admin.component';
import SignIn from '../src/pages/sign-in/sign-in.component';

import 'bootstrap/dist/css/bootstrap.min.css';
import './sass/index.scss';

const App = (props) => {
  return (
    <div className='app'>
      <Switch>
        <Route exact path='/' component={Home} />
        <Route path='/admin' component={Admin} />
        <Route path='/sign-in' component={SignIn} />
      </Switch>
    </div>
  );
};

export default withRouter(connect()(App));

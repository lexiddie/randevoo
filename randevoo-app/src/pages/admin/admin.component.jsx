import React, { useEffect } from 'react';
import { createStructuredSelector } from 'reselect';
import { withRouter, Route, Redirect } from 'react-router-dom';
import { connect } from 'react-redux';

import { fetchCategoriesStart } from '../../redux/category/category.actions';
import { fetchProductsStart } from '../../redux/product/product.actions';
import { fetchStoresStart } from '../../redux/store/store.actions';
import { fetchUsersStart } from '../../redux/user/user.actions';

import Header from '../../components/header/header.component';
import Product from '../product/product.component';
import Store from '../store/store.component';
import User from '../user/user.component';

import { selectIsSignIn } from '../../redux/authentication/authentication.selectors';

import { collection, getDocs } from 'firebase/firestore';
import { firestore } from '../../firebase/firebase.utils';

const Admin = (props) => {
  const { match, history, isSignIn, fetchCategoriesStart, fetchProductsStart, fetchStoresStart, fetchUsersStart } = props;

  const sortObject = (data) => {
    const result = Object.keys(data)
      .sort()
      .reduce((obj, key) => {
        obj[key] = data[key];
        return obj;
      }, {});
    return result;
  };

  const checkSignIn = () => {
    if (!isSignIn) {
      history.push('/sign-in');
    }
  };

  useEffect(() => {
    checkSignIn();
    // fetchCategoriesStart();

    // const variationRef = collection(firestore, 'variations');
    // try {
    //   const snapshot = getDocs(variationRef);
    //   if (snapshot.empty) {
    //     console.log('No categories');
    //   }
    //   let tempList = [];
    //   snapshot.forEach((doc) => {
    //     let record = doc.data();
    //     record = sortObject(record);
    //     tempList.push(record);
    //   });
    //   console.log(`Checking Result`, JSON.stringify(tempList));
    // } catch (err) {
    //   console.log('Error getting document:', err);
    // }

    fetchProductsStart();
    fetchStoresStart();
    fetchUsersStart();
  }, [isSignIn]);

  return (
    <div className='admin'>
      <Header />
      <Route path={`${match.path}/product`} component={Product} />
      <Route path={`${match.path}/store`} component={Store} />
      <Route path={`${match.path}/user`} component={User} />
      {match.isExact ? <Redirect to={`${match.path}/product`} /> : null}
    </div>
  );
};

const mapStateToProps = createStructuredSelector({
  isSignIn: selectIsSignIn
});

const mapDispatchToProps = (dispatch) => ({
  fetchCategoriesStart: () => dispatch(fetchCategoriesStart()),
  fetchProductsStart: () => dispatch(fetchProductsStart()),
  fetchStoresStart: () => dispatch(fetchStoresStart()),
  fetchUsersStart: () => dispatch(fetchUsersStart())
});

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Admin));

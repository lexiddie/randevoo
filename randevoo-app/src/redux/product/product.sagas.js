import { takeLatest, call, put, all } from 'redux-saga/effects';
import { store } from '../store';

import { fetchProducts } from './product.services';
import { searchProducts } from './product.utils';
import { fetchProductsSuccess, fetchProductsFailure, setSearchResult } from './product.actions';
import { ProductActionTypes } from './product.types';

export function* fetchProduct() {
  try {
    const products = yield call(fetchProducts);
    yield put(fetchProductsSuccess(products));
  } catch (error) {
    console.log(`Fetching in categories has error`, error);
    yield put(fetchProductsFailure(error));
  }
}

export function* fetchProductsStart() {
  yield takeLatest(ProductActionTypes.FETCH_PRODUCTS_START, fetchProduct);
}

export function* searchStartProducts({ payload }) {
  const state = store.getState();
  const products = state.product.products;
  try {
    const iProducts = yield call(searchProducts, payload, products);
    yield put(setSearchResult(iProducts));
  } catch (error) {
    console.log(`Searching has error`, error);
  }
}

export function* searchStart() {
  yield takeLatest(ProductActionTypes.PRODUCT_SEARCH_START, searchStartProducts);
}

export function* productSagas() {
  yield all([call(fetchProductsStart), call(searchStart)]);
}

import { takeLatest, call, put, all } from 'redux-saga/effects';
import { store } from '../store';

import { fetchStores, fetchStore, fetchStoreInfo } from './store.services';
import { searchStores } from './store.utils';
import { fetchStoresSuccess, fetchStoresFailure, setStore, setStoreInfo, cleanStore, cleanStoreInfo, setSearchResult } from './store.actions';
import { StoreActionTypes } from './store.types';

export function* fetchStoresAsync() {
  try {
    const stores = yield call(fetchStores);
    yield put(fetchStoresSuccess(stores));
  } catch (error) {
    console.log(`Fetching in stores has error`, error);
    yield put(fetchStoresFailure(error));
  }
}

export function* fetchStoresStart() {
  yield takeLatest(StoreActionTypes.FETCH_STORES_START, fetchStoresAsync);
}

export function* fetchStoreAsync({ payload }) {
  try {
    yield put(cleanStore());
    const store = yield call(fetchStore, payload);
    yield put(setStore(store));
  } catch (error) {
    console.log(`Fetching in store has error`, error);
  }
}

export function* fetchStoreStart() {
  yield takeLatest(StoreActionTypes.FETCH_STORE, fetchStoreAsync);
}

export function* fetchStoreInfoAsync({ payload }) {
  try {
    yield put(cleanStoreInfo());
    const storeInfo = yield call(fetchStoreInfo, payload);
    yield put(setStoreInfo(storeInfo));
  } catch (error) {
    console.log(`Fetching in store info has error`, error);
  }
}

export function* fetchStoreInfoStart() {
  yield takeLatest(StoreActionTypes.FETCH_STORE_INFO, fetchStoreInfoAsync);
}

export function* searchStartStores({ payload }) {
  const state = store.getState();
  const stores = state.store.stores;
  try {
    const iStores = yield call(searchStores, payload, stores);
    yield put(setSearchResult(iStores));
  } catch (error) {
    console.log(`Searching has error`, error);
  }
}

export function* searchStart() {
  yield takeLatest(StoreActionTypes.STORE_SEARCH_START, searchStartStores);
}

export function* storeSagas() {
  yield all([call(fetchStoresStart), call(fetchStoreStart), call(fetchStoreInfoStart), call(searchStart)]);
}

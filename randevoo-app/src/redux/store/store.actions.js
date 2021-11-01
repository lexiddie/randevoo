import { StoreActionTypes } from './store.types';

export const fetchStoresStart = () => ({
  type: StoreActionTypes.FETCH_STORES_START
});

export const fetchStoresSuccess = (data) => ({
  type: StoreActionTypes.FETCH_STORES_SUCCESS,
  payload: data
});

export const fetchStoresFailure = (data) => ({
  type: StoreActionTypes.FETCH_STORES_FAILURE,
  payload: data
});

export const fetchStore = (storeId) => ({
  type: StoreActionTypes.FETCH_STORE,
  payload: storeId
});

export const setStore = (data) => ({
  type: StoreActionTypes.SET_STORE,
  payload: data
});

export const cleanStore = () => ({
  type: StoreActionTypes.CLEAN_STORE
});

export const fetchStoreInfo = (storeId) => ({
  type: StoreActionTypes.FETCH_STORE_INFO,
  payload: storeId
});

export const setStoreInfo = (data) => ({
  type: StoreActionTypes.SET_STORE_INFO,
  payload: data
});

export const cleanStoreInfo = () => ({
  type: StoreActionTypes.CLEAN_STORE_INFO
});

export const startSearch = (searchKey) => ({
  type: StoreActionTypes.STORE_SEARCH_START,
  payload: searchKey
});

export const setSearchResult = (data) => ({
  type: StoreActionTypes.STORE_SET_SEARCH_RESULT,
  payload: data
});

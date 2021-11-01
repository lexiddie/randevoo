import { ProductActionTypes } from './product.types';

export const fetchProductsStart = () => ({
  type: ProductActionTypes.FETCH_PRODUCTS_START
});

export const fetchProductsSuccess = (data) => ({
  type: ProductActionTypes.FETCH_PRODUCTS_SUCCESS,
  payload: data
});

export const fetchProductsFailure = (data) => ({
  type: ProductActionTypes.FETCH_PRODUCTS_FAILURE,
  payload: data
});

export const startSearch = (searchKey) => ({
  type: ProductActionTypes.PRODUCT_SEARCH_START,
  payload: searchKey
});

export const setSearchResult = (data) => ({
  type: ProductActionTypes.PRODUCT_SET_SEARCH_RESULT,
  payload: data
});

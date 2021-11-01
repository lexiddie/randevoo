import { ProductActionTypes } from './product.types';

const INITIAL_STATE = {
  products: [],
  iProducts: [],
  searchKey: '',
  isFetching: false,
  errorMessage: undefined
};

const mainReducer = (state = INITIAL_STATE, action) => {
  switch (action.type) {
    case ProductActionTypes.FETCH_PRODUCTS_START:
      return {
        ...state,
        isFetching: true
      };
    case ProductActionTypes.FETCH_PRODUCTS_SUCCESS:
      return {
        ...state,
        isFetching: false,
        products: action.payload
      };
    case ProductActionTypes.FETCH_PRODUCTS_FAILURE:
      return {
        ...state,
        isFetching: false,
        errorMessage: action.payload
      };
    case ProductActionTypes.PRODUCT_SEARCH_START:
      return {
        ...state,
        searchKey: action.payload
      };
    case ProductActionTypes.PRODUCT_SET_SEARCH_RESULT:
      return {
        ...state,
        iProducts: action.payload
      };
    default:
      return state;
  }
};

export default mainReducer;

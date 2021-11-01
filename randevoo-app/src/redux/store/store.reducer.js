import { StoreActionTypes } from './store.types';

const INITIAL_STATE = {
  stores: [],
  iStores: [],
  searchKey: '',
  currentStore: null,
  currentStoreInfo: null,
  isFetching: false,
  errorMessage: undefined
};

const storeReducer = (state = INITIAL_STATE, action) => {
  switch (action.type) {
    case StoreActionTypes.FETCH_STORES_START:
      return {
        ...state,
        isFetching: true
      };
    case StoreActionTypes.FETCH_STORES_SUCCESS:
      return {
        ...state,
        isFetching: false,
        stores: action.payload
      };
    case StoreActionTypes.FETCH_STORES_FAILURE:
      return {
        ...state,
        isFetching: false,
        errorMessage: action.payload
      };
    case StoreActionTypes.FETCH_STORE:
      return {
        ...state
      };
    case StoreActionTypes.SET_STORE:
      return {
        ...state,
        currentStore: action.payload
      };
    case StoreActionTypes.CLEAN_STORE:
      return {
        ...state,
        currentStore: null
      };
    case StoreActionTypes.FETCH_STORE_INFO:
      return {
        ...state
      };
    case StoreActionTypes.SET_STORE_INFO:
      return {
        ...state,
        currentStoreInfo: action.payload
      };
    case StoreActionTypes.CLEAN_STORE_INFO:
      return {
        ...state,
        currentStoreInfo: null
      };
    case StoreActionTypes.STORE_SEARCH_START:
      return {
        ...state,
        searchKey: action.payload
      };
    case StoreActionTypes.STORE_SET_SEARCH_RESULT:
      return {
        ...state,
        iStores: action.payload
      };
    default:
      return state;
  }
};

export default storeReducer;

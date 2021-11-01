import { UserActionTypes } from './user.types';

const INITIAL_STATE = {
  users: [],
  iUsers: [],
  searchKey: '',
  currentUser: null,
  currentUserProvider: null,
  isFetching: false,
  errorMessage: undefined
};

const userReducer = (state = INITIAL_STATE, action) => {
  switch (action.type) {
    case UserActionTypes.FETCH_USERS_START:
      return {
        ...state,
        isFetching: true
      };
    case UserActionTypes.FETCH_USERS_SUCCESS:
      return {
        ...state,
        isFetching: false,
        users: action.payload
      };
    case UserActionTypes.FETCH_USERS_FAILURE:
      return {
        ...state,
        isFetching: false,
        errorMessage: action.payload
      };
    case UserActionTypes.FETCH_USER:
      return {
        ...state
      };
    case UserActionTypes.SET_USER:
      return {
        ...state,
        currentUser: action.payload
      };
    case UserActionTypes.CLEAN_USER:
      return {
        ...state,
        currentUser: null
      };
    case UserActionTypes.FETCH_USER_PROVIDER:
      return {
        ...state
      };
    case UserActionTypes.SET_USER_PROVIDER:
      return {
        ...state,
        currentUserProvider: action.payload
      };
    case UserActionTypes.CLEAN_USER_PROVIDER:
      return {
        ...state,
        currentUserProvider: null
      };
    case UserActionTypes.USER_SEARCH_START:
      return {
        ...state,
        searchKey: action.payload
      };
    case UserActionTypes.USER_SET_SEARCH_RESULT:
      return {
        ...state,
        iUsers: action.payload
      };
    default:
      return state;
  }
};

export default userReducer;

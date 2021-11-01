import { UserActionTypes } from './user.types';

export const fetchUsersStart = () => ({
  type: UserActionTypes.FETCH_USERS_START
});

export const fetchUsersSuccess = (data) => ({
  type: UserActionTypes.FETCH_USERS_SUCCESS,
  payload: data
});

export const fetchUsersFailure = (data) => ({
  type: UserActionTypes.FETCH_USERS_FAILURE,
  payload: data
});

export const fetchUser = (userId) => ({
  type: UserActionTypes.FETCH_USER,
  payload: userId
});

export const setUser = (data) => ({
  type: UserActionTypes.SET_USER,
  payload: data
});

export const cleanUser = () => ({
  type: UserActionTypes.CLEAN_USER
});

export const fetchUserProvider = (userId) => ({
  type: UserActionTypes.FETCH_USER_PROVIDER,
  payload: userId
});

export const setUserProvider = (data) => ({
  type: UserActionTypes.SET_USER_PROVIDER,
  payload: data
});

export const cleanUserProvider = () => ({
  type: UserActionTypes.CLEAN_USER_PROVIDER
});

export const startSearch = (searchKey) => ({
  type: UserActionTypes.USER_SEARCH_START,
  payload: searchKey
});

export const setSearchResult = (data) => ({
  type: UserActionTypes.USER_SET_SEARCH_RESULT,
  payload: data
});

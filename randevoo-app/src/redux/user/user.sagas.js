import { takeLatest, call, put, all } from 'redux-saga/effects';
import { store } from '../store';

import { fetchUsers, fetchUser, fetchUserProvider } from './user.services';
import { searchUsers } from './user.utils';
import { fetchUsersSuccess, fetchUsersFailure, setUser, cleanUser, setUserProvider, cleanUserProvider, setSearchResult } from './user.actions';
import { UserActionTypes } from './user.types';

export function* fetchUsersAsync() {
  try {
    const users = yield call(fetchUsers);
    yield put(fetchUsersSuccess(users));
  } catch (error) {
    console.log(`Fetching in users has error`, error);
    yield put(fetchUsersFailure(error));
  }
}

export function* fetchUsersStart() {
  yield takeLatest(UserActionTypes.FETCH_USERS_START, fetchUsersAsync);
}

export function* fetchUserAsync({ payload }) {
  try {
    yield put(cleanUser());
    const user = yield call(fetchUser, payload);
    yield put(setUser(user));
  } catch (error) {
    console.log(`Fetching in user has error`, error);
  }
}

export function* fetchUserStart() {
  yield takeLatest(UserActionTypes.FETCH_USER, fetchUserAsync);
}

export function* fetchStoreInfoAsync({ payload }) {
  try {
    yield put(cleanUserProvider());
    const userProvider = yield call(fetchUserProvider, payload);
    yield put(setUserProvider(userProvider));
  } catch (error) {
    console.log(`Fetching in user provider has error`, error);
  }
}

export function* fetchUserProviderStart() {
  yield takeLatest(UserActionTypes.FETCH_USER_PROVIDER, fetchStoreInfoAsync);
}

export function* searchStartUsers({ payload }) {
  const state = store.getState();
  const users = state.user.users;
  try {
    const iUsers = yield call(searchUsers, payload, users);
    yield put(setSearchResult(iUsers));
  } catch (error) {
    console.log(`Searching has error`, error);
  }
}

export function* searchStart() {
  yield takeLatest(UserActionTypes.USER_SEARCH_START, searchStartUsers);
}

export function* userSagas() {
  yield all([call(fetchUsersStart), call(fetchUserStart), call(fetchUserProviderStart), call(searchStart)]);
}

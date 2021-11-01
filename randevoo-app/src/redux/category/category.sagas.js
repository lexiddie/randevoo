import { takeLatest, call, put, all } from 'redux-saga/effects';

import { fetchCategories, fetchSubcategories, fetchVariations } from './category.services';
import { setCategories, setSubcategories, setVariations } from './category.actions';
import { CategoryActionTypes } from './category.types';

export function* fetchCategory() {
  try {
    const categories = yield call(fetchCategories);
    yield put(setCategories(categories));

    const subcategories = yield call(fetchSubcategories);
    yield put(setSubcategories(subcategories));

    const variations = yield call(fetchVariations);
    yield put(setVariations(variations));
  } catch (error) {
    console.log(`Fetching in categories has error`, error);
  }
}

export function* fetchCategoriesStart() {
  yield takeLatest(CategoryActionTypes.FETCH_CATEGORIES_START, fetchCategory);
}

export function* categorySagas() {
  yield all([call(fetchCategoriesStart)]);
}

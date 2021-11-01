import { all, call } from 'redux-saga/effects';

import { authenticationSagas } from './authentication/authentication.sagas';
import { categorySagas } from './category/category.sagas';
import { productSagas } from './product/product.sagas';
import { storeSagas } from './store/store.sagas';
import { userSagas } from './user/user.sagas';

export default function* rootSaga() {
  yield all([call(authenticationSagas), call(categorySagas), call(productSagas), call(storeSagas), call(userSagas)]);
}

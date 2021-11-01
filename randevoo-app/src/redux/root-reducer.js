import { combineReducers } from 'redux';
import { persistReducer } from 'redux-persist';
import storage from 'redux-persist/lib/storage';

import authenticationReducer from './authentication/authentication.reducer';
import userReducer from './user/user.reducer';
import productReducer from './product/product.reducer';
import storeReducer from './store/store.reducer';
import categoryReducer from './category/category.reducer';

const persistConfig = {
  key: 'root',
  storage,
  whileList: ['authentication', 'category']
};

const rootReducer = combineReducers({
  authentication: authenticationReducer,
  product: productReducer,
  store: storeReducer,
  user: userReducer,
  category: categoryReducer
});

export default persistReducer(persistConfig, rootReducer);

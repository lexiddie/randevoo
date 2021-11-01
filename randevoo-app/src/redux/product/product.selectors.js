import { createSelector } from 'reselect';
import { getProduct, getProducts } from './product.utils';

const selectProduct = (state) => state.product;

export const selectProducts = createSelector([selectProduct], (product) => (product.products ? product.products.sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1)) : []));

export const selectIsSearch = createSelector([selectProduct], (product) => (product.searchKey === '' ? false : true));

export const selectSearchProducts = createSelector([selectProduct], (product) => (product.iProducts ? product.iProducts.sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1)) : []));

export const selectPreviewProduct = (productId) => createSelector([selectProduct], (product) => getProduct(productId, product.products));

export const selectStoreProducts = (storeId) => createSelector([selectProduct], (product) => getProducts(storeId, product.products));

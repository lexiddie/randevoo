import { createSelector } from 'reselect';
import { getStore, getStores } from './store.utils';

const selectStore = (state) => state.store;

export const selectStores = createSelector([selectStore], (store) => store.stores);

export const selectCurrentStore = createSelector([selectStore], (store) => (store.currentStore ? store.currentStore : null));

export const selectCurrentStoreInfo = createSelector([selectStore], (store) => (store.currentStoreInfo ? store.currentStoreInfo : null));

export const selectIsSearch = createSelector([selectStore], (store) => (store.searchKey === '' ? false : true));

export const selectSearchStores = createSelector([selectStore], (store) => (store.iStores ? store.iStores.sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1)) : []));

export const selectPreviewStore = (storeId) => createSelector([selectStore], (store) => getStore(storeId, store.stores));

export const selectUserStores = (userId) => createSelector([selectStore], (store) => getStores(userId, store.stores));

import { createSelector } from 'reselect';
import { getUser } from './user.utils';

const selectUser = (state) => state.user;

export const selectUsers = createSelector([selectUser], (user) => user.users);

export const selectIsSignIn = createSelector([selectUser], (user) => user.isSignIn);

export const selectCurrentUser = createSelector([selectUser], (user) => (user.currentUser ? user.currentUser : null));

export const selectCurrentUserProvider = createSelector([selectUser], (user) => (user.currentUserProvider ? user.currentUserProvider : null));

export const selectIsSearch = createSelector([selectUser], (user) => (user.searchKey === '' ? false : true));

export const selectSearchUsers = createSelector([selectUser], (user) => (user.iUsers ? user.iUsers.sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1)) : []));

export const selectPreviewUser = (userId) => createSelector([selectUser], (user) => getUser(userId, user.users));

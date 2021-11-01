export const getStore = (storeId, stores) => {
  const store = stores.filter((element) => element.id === storeId)[0];
  return store;
};

export const getStores = (userId, stores) => {
  const records = stores.filter((element) => element.userId === userId);
  return records;
};

export const searchStores = (searchKey, stores) => {
  const iStores = stores.filter((store) => store.username.toLowerCase().includes(searchKey.toLowerCase()));
  return iStores;
};

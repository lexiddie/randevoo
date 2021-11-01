export const getProduct = (productId, products) => {
  const product = products.filter((element) => element.id === productId)[0];
  return product;
};

export const getProducts = (storeId, products) => {
  const records = products.filter((element) => element.businessId === storeId);
  return records;
};

export const searchProducts = (searchKey, products) => {
  const iProducts = products.filter((product) => product.name.toLowerCase().includes(searchKey.toLowerCase()));
  return iProducts;
};

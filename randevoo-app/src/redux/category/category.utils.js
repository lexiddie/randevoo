export const getSubcategory = (subcategoryId, categories, subcategories) => {
  console.log(`This function is running`);
  const subcategory = subcategories.filter((item) => item.id === subcategoryId)[0];
  console.log(`Checking subcategoryId`, subcategoryId);
  const category = categories.filter((item) => item.id === subcategory.categoryId)[0];
  delete subcategory.categoryId;
  return { ...subcategory, category: category };
};

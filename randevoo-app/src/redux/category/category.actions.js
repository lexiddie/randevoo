import { CategoryActionTypes } from './category.types';

export const fetchCategoriesStart = () => ({
  type: CategoryActionTypes.FETCH_CATEGORIES_START
});

export const setCategories = (data) => ({
  type: CategoryActionTypes.SET_CATEGORIES,
  payload: data
});

export const setSubcategories = (data) => ({
  type: CategoryActionTypes.SET_SUBCATEGORIES,
  payload: data
});

export const setVariations = (data) => ({
  type: CategoryActionTypes.SET_VARIATIONS,
  payload: data
});

export const getSubcategory = (subcategoryId) => ({
  type: CategoryActionTypes.GET_SUBCATEGORY,
  payload: subcategoryId
});

export const setSubcategory = (subcategory) => ({
  type: CategoryActionTypes.SET_SUBCATEGORY,
  payload: subcategory
});

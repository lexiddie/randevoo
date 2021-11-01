import { createSelector } from 'reselect';
import { getSubcategory } from './category.utils';

const selectCategory = (state) => state.category;

export const selectCategories = createSelector([selectCategory], (category) => category.categories);

export const selectSubcategories = createSelector([selectCategory], (category) => category.subcategories);

export const selectVariations = createSelector([selectCategory], (category) => category.variations);

export const selectSubcategory = (subcategoryId) => createSelector([selectCategory], (category) => getSubcategory(subcategoryId, category.categories, category.subcategories));

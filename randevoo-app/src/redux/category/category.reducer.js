import { CategoryActionTypes } from './category.types';

const INITIAL_STATE = {
  categories: [],
  subcategories: [],
  variations: [],
  currentSubcategory: null
};

const categoryReducer = (state = INITIAL_STATE, action) => {
  switch (action.type) {
    case CategoryActionTypes.FETCH_CATEGORIES_START:
      return {
        ...state
      };
    case CategoryActionTypes.SET_CATEGORIES:
      return {
        ...state,
        categories: action.payload
      };
    case CategoryActionTypes.SET_SUBCATEGORIES:
      return {
        ...state,
        subcategories: action.payload
      };
    case CategoryActionTypes.SET_VARIATIONS:
      return {
        ...state,
        variations: action.payload
      };
    case CategoryActionTypes.GET_SUBCATEGORY:
      return {
        ...state
      };
    case CategoryActionTypes.SET_SUBCATEGORY:
      return {
        ...state,
        currentSubcategory: action.payload
      };
    default:
      return state;
  }
};

export default categoryReducer;

import { collection, getDocs } from 'firebase/firestore';
import { firestore } from '../../firebase/firebase.utils';

export const fetchCategories = async () => {
  return new Promise(async (resolve, reject) => {
    const categoryRef = collection(firestore, 'categories');
    try {
      const snapshot = await getDocs(categoryRef);
      if (snapshot.empty) {
        console.log('No categories');
        resolve([]);
      }
      let tempList = [];
      snapshot.forEach((doc) => {
        const record = doc.data();
        tempList.push(record);
      });
      resolve(tempList);
    } catch (err) {
      console.log('Error getting document:', err);
      reject(err);
    }
  });
};

export const fetchSubcategories = async () => {
  return new Promise(async (resolve, reject) => {
    const subcategoryRef = collection(firestore, 'subcategories');
    try {
      const snapshot = await getDocs(subcategoryRef);
      if (snapshot.empty) {
        console.log('No subcategories');
        resolve([]);
      }
      let tempList = [];
      snapshot.forEach((doc) => {
        const record = doc.data();
        tempList.push(record);
      });
      resolve(tempList);
    } catch (err) {
      console.log('Error getting document:', err);
      reject(err);
    }
  });
};

export const fetchVariations = async () => {
  return new Promise(async (resolve, reject) => {
    const variationRef = collection(firestore, 'variations');
    try {
      const snapshot = await getDocs(variationRef);
      if (snapshot.empty) {
        console.log('No variations');
        resolve([]);
      }
      let tempList = [];
      snapshot.forEach((doc) => {
        const record = doc.data();
        tempList.push(record);
      });
      resolve(tempList);
    } catch (err) {
      console.log('Error getting document:', err);
      reject(err);
    }
  });
};

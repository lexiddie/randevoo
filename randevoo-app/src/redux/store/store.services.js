import { query, doc, getDoc, collection, getDocs, orderBy, where, limit } from 'firebase/firestore';
import { firestore } from '../../firebase/firebase.utils';

export const fetchStores = async () => {
  return new Promise(async (resolve, reject) => {
    const businessRef = collection(firestore, 'businesses');
    const q = query(businessRef, orderBy('createdAt', 'desc'));
    try {
      const snapshot = await getDocs(q);
      if (snapshot.empty) {
        console.log('No business');
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

export const fetchStore = async (storeId) => {
  return new Promise(async (resolve, reject) => {
    const businessRef = doc(firestore, 'businesses', storeId);
    try {
      const doc = await getDoc(businessRef);
      if (!doc.exists) {
        console.log('No store is found');
        resolve(null);
      } else {
        const record = doc.data();
        resolve(record);
      }
    } catch (err) {
      console.log('Error getting document:', err);
      reject(err);
    }
  });
};

export const fetchStoreInfo = async (storeId) => {
  return new Promise(async (resolve, reject) => {
    const bizInfoRef = collection(firestore, 'bizInfos');
    const q = query(bizInfoRef, where('businessId', '==', storeId), limit(1));
    try {
      const snapshot = await getDocs(q);
      if (snapshot.empty) {
        console.log('No business');
        resolve(null);
      }
      snapshot.forEach((doc) => {
        const record = doc.data();
        resolve(record);
      });
    } catch (err) {
      console.log('Error getting document:', err);
      reject(err);
    }
  });
};

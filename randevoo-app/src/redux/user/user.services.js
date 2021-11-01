import { query, doc, getDoc, collection, getDocs, orderBy, where, limit } from 'firebase/firestore';
import { firestore } from '../../firebase/firebase.utils';

export const fetchUsers = async () => {
  return new Promise(async (resolve, reject) => {
    const userRef = collection(firestore, 'users');
    const q = query(userRef, orderBy('createdAt', 'desc'));
    try {
      const snapshot = await getDocs(q);
      if (snapshot.empty) {
        console.log('No user');
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

export const fetchUser = async (userId) => {
  return new Promise(async (resolve, reject) => {
    const userRef = doc(firestore, 'users', userId);
    try {
      const doc = await getDoc(userRef);
      if (!doc.exists) {
        console.log('No user is found');
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

export const fetchUserProvider = async (userId) => {
  return new Promise(async (resolve, reject) => {
    const providerRef = collection(firestore, 'providers');
    const q = query(providerRef, where('userId', '==', userId), limit(3));
    try {
      const snapshot = await getDocs(q);
      if (snapshot.empty) {
        console.log('No provider');
        resolve(null);
      }
      snapshot.forEach((doc) => {
        const record = doc.data();
        resolve(record);
      });
    } catch (err) {
      console.log('error getting document:', err);
      reject(err);
    }
  });
};

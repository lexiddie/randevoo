import { query, collection, getDocs, orderBy } from 'firebase/firestore';
import { firestore } from '../../firebase/firebase.utils';

export const fetchProducts = async () => {
  return new Promise(async (resolve, reject) => {
    const productRef = collection(firestore, 'products');
    const q = query(productRef, orderBy('createdAt', 'desc'));
    try {
      const snapshot = await getDocs(q);
      if (snapshot.empty) {
        console.log('no products');
        resolve([]);
      }
      let templist = [];
      snapshot.forEach((doc) => {
        const record = doc.data();
        templist.push(record);
      });
      resolve(templist);
    } catch (err) {
      console.log('error getting document:', err);
      reject(err);
    }
  });
};

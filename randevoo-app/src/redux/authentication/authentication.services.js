import { collection, getDocs, query, where, limit } from 'firebase/firestore';
import { firestore } from '../../firebase/firebase.utils';
import { SHA256 } from 'crypto-js';

export const authenticatedAccount = async (credential) => {
  const { username, password } = credential;
  const code = SHA256(password).toString();
  return new Promise(async (resolve, reject) => {
    const adminRef = query(collection(firestore, 'admins'), where('username', '==', username), where('password', '==', code), limit(1));
    try {
      const snapshot = await getDocs(adminRef);
      if (snapshot.empty) {
        console.log('No account');
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

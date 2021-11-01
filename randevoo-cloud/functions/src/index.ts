import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
// import * as events from 'events';
import algoliasearch from 'algoliasearch';

admin.initializeApp();

// const emitter = new events.EventEmitter();
// emitter.setMaxListeners(200);

const db = admin.firestore();
const message = admin.messaging();
let isProduction: Boolean = false;

if (process.env.NODE_ENV === 'production') {
  isProduction = true;
}

const ALGOLIA_ID = functions.config().algolia.app_id;
const ALGOLIA_ADMIN_KEY = functions.config().algolia.api_key;

const algoliaClient = algoliasearch(ALGOLIA_ID, ALGOLIA_ADMIN_KEY);

const productIndexing = isProduction ? 'prod_products' : 'dev_products';
const productIndex = algoliaClient.initIndex(productIndexing);

const collectionIndexing = isProduction ? 'prod_collections' : 'dev_collections';
const collectionIndex = algoliaClient.initIndex(collectionIndexing);

const userIndexing = isProduction ? 'prod_users' : 'dev_users';
const userIndex = algoliaClient.initIndex(userIndexing);

const businessIndexing = isProduction ? 'prod_businesses' : 'dev_businesses';
const businessIndex = algoliaClient.initIndex(businessIndexing);

// Create a HTTP request cloud function.
export const sendProductToAlgolia = functions.region('asia-east2').https.onRequest(async (req, res) => {
  // This array will contain all records to be indexed in Algolia.
  // A record does not need to necessarily contain all properties of the Firestore document,
  // only the relevant ones.
  const algoliaRecords: any[] = [];

  // Retrieve all documents from the products collection.
  const querySnapshot = await db.collection('products').get();

  querySnapshot.docs.forEach((doc) => {
    const document = doc.data();
    // Essentially, you want your records to contain any information that facilitates search,
    // display, filtering, or relevance. Otherwise, you can leave it out.
    const record = {
      objectID: document.id,
      name: document.name,
      price: document.price,
      photoUrl: document.photoUrls[0],
      description: document.description,
      businessId: document.businessId,
      subcategoryId: document.subcategoryId
    };
    algoliaRecords.push(record);
  });

  // After all records are created, we save them to
  productIndex
    .saveObjects(algoliaRecords)
    .then(() => {
      res.status(200).send('Products were indexed to Algolia successfully.');
    })
    .catch((err) => {
      console.error('Error when indexing Products into Algolia', err);
      res.status(404).send('Error when indexing Products into Algolia.');
    });
});

// const updateProduct = (product: any): Promise<any> => {
//   return new Promise((resolve, reject) => {
// const productRef = db.collection('products');
// productRef
//   .doc(product.id)
//   .update({
//     ...product,
//     variants: product.information
//   })
//   .then(() => {
//     console.log(`Product has been updated`);
//     resolve(1);
//   })
//   .catch((err) => {
//     console.log(`Product cannot be updated`, err);
//     resolve(1);
//   });
//   });
// };

// export const updateProducts = functions.region('asia-east2').https.onRequest(async (req, res) => {
//   const querySnapshot = await db.collection('products').get();

//   let count = 0;

//   querySnapshot.docs.forEach(async (doc) => {
//     const document = doc.data();

//     const result = await updateProduct(document);
//     count += result;
//   });
//   if (count === querySnapshot.size) {
//     res.status(200).send('Products were added variationInfos.');
//   } else {
//     res.status(404).send('Error when indexing Products with variationInfos.');
//   }
// });

export const productSync = functions
  .region('asia-east2')
  .firestore.document('products/{productId}')
  .onWrite(async (change, context) => {
    const docId = context.params.productId;
    // If the document does not exist, it has been deleted.
    const document = change.after.exists ? change.after.data() : null;
    const oldDocument = change.before.exists ? change.before.data() : null;

    if (document == null && oldDocument != null) {
      deletingProduct(oldDocument.id);
      productIndex
        .deleteObject(oldDocument.id)
        .then(() => {
          console.log(`Product was deleted to Algolia successfully.`, docId);
        })
        .catch((err) => {
          console.error('Error when deleting Product into Algolia', err);
        });
    } else if (document != null) {
      if (!document.isActive || !document.isAvailable || document.isBanned) {
        deletingProduct(document.id);
        productIndex
          .deleteObject(document.id)
          .then(() => {
            console.log(`Product was deleted to Algolia successfully.`, docId);
          })
          .catch((err) => {
            console.error('Error when deleting Product into Algolia', err);
          });
      } else {
        const record = {
          objectID: document.id,
          name: document.name,
          price: document.price,
          photoUrl: document.photoUrls[0],
          description: document.description,
          businessId: document.businessId,
          subcategoryId: document.subcategoryId
        };
        productIndex
          .saveObject(record)
          .then(() => {
            console.log(`Product was indexed to Algolia successfully.`, docId);
          })
          .catch((err) => {
            console.error('Error when indexing Product into Algolia', err);
          });
      }
    }
  });

export const sendCollectionToAlgolia = functions.region('asia-east2').https.onRequest(async (req, res) => {
  const algoliaRecords: any[] = [];
  const querySnapshot = await db.collection('collections').get();

  querySnapshot.docs.forEach((doc) => {
    const document = doc.data();
    const record = {
      objectID: document.id,
      name: document.name,
      photoUrl: document.photoUrl,
      products: document.products,
      businessId: document.businessId
    };
    algoliaRecords.push(record);
  });

  collectionIndex
    .saveObjects(algoliaRecords)
    .then(() => {
      res.status(200).send('Collections were indexed to Algolia successfully.');
    })
    .catch((err) => {
      console.error('Error when indexing Collections into Algolia', err);
      res.status(404).send('Error when indexing Collections into Algolia.');
    });
});

export const collectionSync = functions
  .region('asia-east2')
  .firestore.document('collections/{collectionId}')
  .onWrite(async (change, context) => {
    const docId = context.params.collectionId;
    // If the document does not exist, it has been deleted.
    const document = change.after.exists ? change.after.data() : null;
    const oldDocument = change.before.exists ? change.before.data() : null;

    if (document == null && oldDocument != null) {
      collectionIndex
        .deleteObject(oldDocument.id)
        .then(() => {
          console.log(`Collection was deleted to Algolia successfully.`, docId);
        })
        .catch((err) => {
          console.error('Error when deleting Collection into Algolia', err);
        });
    } else if (document != null) {
      const record = {
        objectID: document.id,
        name: document.name,
        photoUrl: document.photoUrl,
        products: document.products,
        businessId: document.businessId
      };
      collectionIndex
        .saveObject(record)
        .then(() => {
          console.log(`Collection was indexed to Algolia successfully.`, docId);
        })
        .catch((err) => {
          console.error('Error when indexing Collection into Algolia', err);
        });
    }
  });

export const sendUserToAlgolia = functions.region('asia-east2').https.onRequest(async (req, res) => {
  const algoliaRecords: any[] = [];
  const querySnapshot = await db.collection('users').get();

  querySnapshot.docs.forEach((doc) => {
    const document = doc.data();
    const record = {
      objectID: document.id,
      name: document.name,
      username: document.username,
      location: document.location,
      profileUrl: document.profileUrl
    };
    algoliaRecords.push(record);
  });
  userIndex
    .saveObjects(algoliaRecords)
    .then(() => {
      res.status(200).send('Users were indexed to Algolia successfully.');
    })
    .catch((err) => {
      console.error('Error when indexing Users into Algolia', err);
      res.status(404).send('Error when indexing Users into Algolia.');
    });
});

export const userSync = functions
  .region('asia-east2')
  .firestore.document('users/{userId}')
  .onWrite(async (change, context) => {
    const docId = context.params.userId;
    // If the document does not exist, it has been deleted.
    const document = change.after.exists ? change.after.data() : null;
    const oldDocument = change.before.exists ? change.before.data() : null;

    if (document == null && oldDocument != null) {
      userIndex
        .deleteObject(oldDocument.id)
        .then(() => {
          console.log(`User was deleted to Algolia successfully.`, docId);
        })
        .catch((err) => {
          console.error('Error when deleting User into Algolia', err);
        });
    } else if (document != null) {
      if (document.isBanned) {
        console.log(`\n`);
        findingStores(document.id, true);
        userIndex
          .deleteObject(document.id)
          .then(() => {
            console.log(`User was deleted to Algolia successfully.`, docId);
          })
          .catch((err) => {
            console.error('Error when deleting User into Algolia', err);
          });
      } else {
        if (oldDocument != null && !oldDocument.isBanned !== !document.isBanned) {
          console.log(`\n`);
          findingStores(document.id, false);
        }
        const record = {
          objectID: document.id,
          name: document.name,
          username: document.username,
          location: document.location,
          profileUrl: document.profileUrl
        };
        userIndex
          .saveObject(record)
          .then(() => {
            console.log(`User was indexed to Algolia successfully.`, docId);
          })
          .catch((err) => {
            console.error('Error when indexing User into Algolia', err);
          });
      }
    }
  });

export const sendBusinessToAlgolia = functions.region('asia-east2').https.onRequest(async (req, res) => {
  const algoliaRecords: any[] = [];
  const querySnapshot = await db.collection('businesses').get();

  querySnapshot.docs.forEach((doc) => {
    const document = doc.data();
    const record = {
      objectID: document.id,
      name: document.name,
      username: document.username,
      location: document.location,
      type: document.type,
      profileUrl: document.profileUrl
    };
    algoliaRecords.push(record);
  });
  businessIndex
    .saveObjects(algoliaRecords)
    .then(() => {
      res.status(200).send('Businesses were indexed to Algolia successfully.');
    })
    .catch((err) => {
      console.error('Error when indexing Businesses into Algolia', err);
      res.status(404).send('Error when indexing Businesses into Algolia.');
    });
});

export const businessSync = functions
  .region('asia-east2')
  .firestore.document('businesses/{businessId}')
  .onWrite(async (change, context) => {
    const docId = context.params.businessId;
    // If the document does not exist, it has been deleted.
    const document = change.after.exists ? change.after.data() : null;
    const oldDocument = change.before.exists ? change.before.data() : null;

    if (document == null && oldDocument != null) {
      businessIndex
        .deleteObject(oldDocument.id)
        .then(() => {
          console.log(`Business was deleted to Algolia successfully.`, docId);
        })
        .catch((err) => {
          console.error('Error when deleting Business into Algolia', err);
        });
    } else if (document != null) {
      if (document.isBanned) {
        console.log(`\n`);

        // banningUser(document.userId);
        // findingStores(document.userId, true);

        findingProducts(document.id, true);

        businessIndex
          .deleteObject(document.id)
          .then(() => {
            console.log(`Business was deleted to Algolia successfully.`, docId);
          })
          .catch((err) => {
            console.error('Error when deleting Business into Algolia', err);
          });
      } else {
        if (oldDocument != null && !oldDocument.isBanned !== !document.isBanned) {
          console.log(`\n`);

          // unbanningUser(document.userId);
          // findingStores(document.userId, false);

          findingProducts(document.id, false);
        }

        const record = {
          objectID: document.id,
          name: document.name,
          username: document.username,
          location: document.location,
          type: document.type,
          profileUrl: document.profileUrl
        };
        businessIndex
          .saveObject(record)
          .then(() => {
            console.log(`Business was indexed to Algolia successfully.`, docId);
          })
          .catch((err) => {
            console.error('Error when indexing Business into Algolia', err);
          });
      }
    }
  });

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

// // Mock Business1
// const biz1 = 'Fvb3sxEA9jS9UOoh6Pjv';
// // Mock Business2
// const biz2 = '2vzWJEn5IXX3wSl7rw7z';

// // Mock User1
// const user1 = 'quQSxknGC0tsrO59rKFD';
// // Mock User2
// const user2 = 'eyYSsNYVjlQ55zDCWeps';
// // MOck User3
// const user3 = 'nViXh4jnXj9G6uDGEvLD';

// // Mock Device1 YFX2ucOXvPgHikFGPbUm
// // Mock Device2 fKLisZGHO3fW5A2FseC3
// // Mock Device3 7tldACDviSETcZQ6cefc
// // Mock Device4 X6tgSK7AfsAHkbK9IB5C

// // Mock Token1
// const token1 = 'cL7bZodb10n9llS0gOwatS:APA91bGLvu3GohzlkSRD8NyGSSlA8v4ODaTymdE6JbwCYMRediXy9W_nSCNYUDc2x57ORKN6vWD0j6Seu-28cK0mr1YMv9PJsrGI4M9RPzkmBPpbbMUSoe2DDdl-vGNdUB_n49-4tLSQ';
// // Mock Token2
// const token2 = 'ei7SQzRrl0M1lSez1UUug8:APA91bHSIkySt6p43bA8C4XGWQ9RuNFtt9DZPg7A8Oz6zi6tf4uRdFww8cdii2cx8pp9aexohNQ_kqBQ2u0BFgPIgs-NzxMhgsWQRBPJ2ObHDV6lWbNgJw8CccA17MWqjW2uTeYgHu5D';
// // Mock Token3
// const token3 = 'cWw4NnNhF0MyvBkeE3SZ6R:APA91bECt0ulolPB3myalwB5vj-Hk5kRLtvcOYtvN463Uil6s18ThhJJTnwIjrK7cB7clqzZ3dggu5OxVebj4umlsq1aHvZh9HYpYxNemtuorxtO2XmB_Fh9V6nU8L6cC1bZZrUbbHeI';

// export const createMockData = functions.firestore.document('mocks/{mockId}').onCreate(async (snap, _) => {
//   const businessRef = db.collection('businesses');
//   const userRef = db.collection('users');
//   const deviceRef = db.collection('devices');
//   const batch = db.batch();
//   const biz1 = {
//     id: 'Fvb3sxEA9jS9UOoh6Pjv',
//     name: 'Off White',
//     username: 'offwhite',
//     location: 'Singapore, Singapore',
//     type: 'Fashion',
//     isBanned: false,
//     userId: 'quQSxknGC0tsrO59rKFD'
//   };
//   batch.set(businessRef.doc(biz1.id), biz1);
//   const biz2 = {
//     id: '2vzWJEn5IXX3wSl7rw7z',
//     name: 'Nike Thailand',
//     username: 'nikethai',
//     location: 'Bangkok, Thailand',
//     type: 'Public',
//     isBanned: false,
//     userId: 'quQSxknGC0tsrO59rKFD'
//   };
//   batch.set(businessRef.doc(biz2.id), biz2);
//   const user1 = {
//     id: 'quQSxknGC0tsrO59rKFD',
//     name: 'Lex',
//     username: 'alexander',
//     location: 'Bangkok, Thailand',
//     isBanned: false
//   };
//   batch.set(userRef.doc(user1.id), user1);
//   const user2 = {
//     id: 'eyYSsNYVjlQ55zDCWeps',
//     name: 'Kevin',
//     username: 'kevin',
//     location: 'Bang Rak, Thailand',
//     isBanned: false
//   };
//   batch.set(userRef.doc(user2.id), user2);
//   const user3 = {
//     id: 'nViXh4jnXj9G6uDGEvLD',
//     name: 'John',
//     username: 'john',
//     location: 'Samut Prakan, Thailand',
//     isBanned: false
//   };
//   batch.set(userRef.doc(user3.id), user3);
//   const device1 = {
//     id: 'YFX2ucOXvPgHikFGPbUm',
//     accountId: 'Fvb3sxEA9jS9UOoh6Pjv',
//     tokens: [
//       {
//         fcmToken: token1
//       },
//       {
//         fcmToken: token2
//       },
//       {
//         fcmToken: token3
//       }
//     ]
//   };
//   batch.set(deviceRef.doc(device1.id), device1);
//   const device2 = {
//     id: 'fKLisZGHO3fW5A2FseC3',
//     accountId: '2vzWJEn5IXX3wSl7rw7z',
//     tokens: [
//       {
//         fcmToken: token1
//       },
//       {
//         fcmToken: token2
//       },
//       {
//         fcmToken: token3
//       }
//     ]
//   };
//   batch.set(deviceRef.doc(device2.id), device2);
//   const device3 = {
//     id: '7tldACDviSETcZQ6cefc',
//     accountId: 'quQSxknGC0tsrO59rKFD',
//     tokens: [
//       {
//         fcmToken: token1
//       },
//       {
//         fcmToken: token2
//       },
//       {
//         fcmToken: token3
//       }
//     ]
//   };
//   batch.set(deviceRef.doc(device3.id), device3);
//   const device4 = {
//     id: 'X6tgSK7AfsAHkbK9IB5C',
//     accountId: 'eyYSsNYVjlQ55zDCWeps',
//     tokens: [
//       {
//         fcmToken: token1
//       },
//       {
//         fcmToken: token2
//       },
//       {
//         fcmToken: token3
//       }
//     ]
//   };
//   batch.set(deviceRef.doc(device4.id), device4);
//   batch.commit();
// });

// const banningUser = (userId: string) => {
//   const userRef = db.collection('users');
//   userRef
//     .doc(userId)
//     .update({
//       isBanned: true
//     })
//     .then(() => {
//       console.log(`User has been banned ${userId}`);
//     })
//     .catch((err) => {
//       console.log(`User cannot be banned ${userId}`, err);
//     });
// };

// const unbanningUser = (userId: string) => {
//   const userRef = db.collection('users');
//   userRef
//     .doc(userId)
//     .update({
//       isBanned: false
//     })
//     .then(() => {
//       console.log(`User has been unbanned ${userId}`);
//     })
//     .catch((err) => {
//       console.log(`User cannot be unbanned ${userId}`, err);
//     });
// };

// const getBusiness = async (businessId: string): Promise<any> => {
//   return new Promise((resolve, reject) => {

const findingStores = (userId: string, toBan: boolean) => {
  const bizRef = db.collection('businesses');
  bizRef
    .where('userId', '==', userId)
    .get()
    .then((records) => {
      if (!records.empty) {
        records.forEach((doc) => {
          const record = doc.data();
          if (toBan) {
            banningStore(record.id);
          } else {
            unbanningStore(record.id);
          }
        });
      }
    })
    .catch((err) => {
      console.log(`Error getting document of stores: ${err}`);
    });
};

const banningStore = (storeId: string) => {
  const bizRef = db.collection('businesses');
  bizRef
    .doc(storeId)
    .update({
      isBanned: true
    })
    .then(() => {
      console.log(`Store has been banned ${storeId}`);
    })
    .catch((err) => {
      console.log(`Store cannot be banned ${storeId}`, err);
    });
};

const unbanningStore = (storeId: string) => {
  const bizRef = db.collection('businesses');
  bizRef
    .doc(storeId)
    .update({
      isBanned: false
    })
    .then(() => {
      console.log(`Store has been unbanned ${storeId}`);
    })
    .catch((err) => {
      console.log(`Store cannot be unbanned ${storeId}`, err);
    });
};

const findingProducts = (storeId: string, toDeactivate: boolean) => {
  const productRef = db.collection('products');
  productRef
    .where('businessId', '==', storeId)
    .get()
    .then((records) => {
      if (!records.empty) {
        records.forEach((doc) => {
          const record = doc.data();
          if (toDeactivate) {
            deactivateProduct(record.id);
          } else {
            activateProduct(record.id);
          }
        });
      }
    })
    .catch((err) => {
      console.log(`Error getting document of stores: ${err}`);
    });
};

const deactivateProduct = (productId: string) => {
  const productRef = db.collection('products');
  productRef
    .doc(productId)
    .update({
      isActive: false
    })
    .then(() => {
      console.log(`Product has been deactivated ${productId}`);
    })
    .catch((err) => {
      console.log(`Product cannot be deactivated ${productId}`, err);
    });
};

const activateProduct = (productId: string) => {
  const productRef = db.collection('products');
  productRef
    .doc(productId)
    .update({
      isActive: true
    })
    .then(() => {
      console.log(`Product has been activated ${productId}`);
    })
    .catch((err) => {
      console.log(`Product cannot be activated ${productId}`, err);
    });
};

const deletingProduct = (productId: string) => {
  const saveRef = db.collection('saves');
  saveRef
    .where('productId', '==', productId)
    .get()
    .then((records) => {
      if (!records.empty) {
        records.forEach((doc) => {
          const record = doc.data();
          deleteSave(record.id);
        });
      }
    })
    .catch((err) => {
      console.log(`Error getting document of saves: ${err}`);
    });

  const bagRef = db.collection('bags');
  bagRef
    .where('productId', '==', productId)
    .get()
    .then((records) => {
      if (!records.empty) {
        records.forEach((doc) => {
          const record = doc.data();
          deleteBag(record.id);
        });
      }
    })
    .catch((err) => {
      console.log(`Error getting document of bags: ${err}`);
    });
};

const deleteSave = (saveId: string) => {
  const saveRef = db.collection('saves');
  saveRef
    .doc(saveId)
    .delete()
    .then(() => {
      console.log(`Save has been deleted successfully: ${saveId}`);
    })
    .catch((err) => {
      console.log(`Deletion of save err: `, err);
    });
};

const deleteBag = (bagId: string) => {
  const bagRef = db.collection('bags');
  bagRef
    .doc(bagId)
    .delete()
    .then(() => {
      console.log(`Bag has been deleted successfully: ${bagId}`);
    })
    .catch((err) => {
      console.log(`Deletion of bag err: `, err);
    });
};

// export const createMockSave = functions.firestore.document('mocks1/{mock}').onCreate(async (snap, _) => {
//   const saveRef = db.collection('saves');
//   const bagRef = db.collection('bags');
//   // const batch = db.batch();

//   [...Array(10).keys()].forEach((element, index) => {
//     const genId = saveRef.doc().id;
//     const data = {
//       id: genId,
//       productId: index >= 5 ? 'lxc5euWjCCNucpzTnxaJ' : 'YQsIrLz4pGhWorzh7Qj3'
//     };
//     saveRef
//       .doc(genId)
//       .set(data)
//       .then(() => {
//         console.log(`New save has been added`);
//       })
//       .catch((err: any) => {
//         console.log(`Error adding save:`, err);
//       });
//   });

//   [...Array(10).keys()].forEach((element, index) => {
//     const genId = bagRef.doc().id;
//     const data = {
//       id: genId,
//       productId: index >= 5 ? 'lxc5euWjCCNucpzTnxaJ' : 'YQsIrLz4pGhWorzh7Qj3'
//     };
//     bagRef
//       .doc(genId)
//       .set(data)
//       .then(() => {
//         console.log(`New bag has been added`);
//       })
//       .catch((err: any) => {
//         console.log(`Error adding bag:`, err);
//       });
//   });
// });

// export const createMockProducts = functions.firestore.document('pros/{proId}').onCreate(async (snap, _) => {
//   const productRef = db.collection('products');
//   const collectionRef = db.collection('collections');
//   const batch = db.batch();
//   const product1 = {
//     id: 'lxc5euWjCCNucpzTnxaJ',
//     businessId: 'Fvb3sxEA9jS9UOoh6Pjv',
//     name: 'Off-White Industrial buckled belt',
//     price: 6790,
//     photoUrls: ['1', '2'],
//     isActive: true,
//     isAvailable: true,
//     isBanned: false,
//     description: `Off-White ‘defines the grey area between black and white’. What does that mean? A fresh reinterpretation of styles you know and love. Made in Italy, this yellow and red Industrial buckled belt from Off-White features a dual-colour design, a logo print and a logo-engraved front buckle fastening.`
//   };
//   batch.set(productRef.doc(product1.id), product1);
//   const product2 = {
//     id: 'YQsIrLz4pGhWorzh7Qj3',
//     businessId: 'Fvb3sxEA9jS9UOoh6Pjv',
//     name: 'Off-White mini 2.0 Industrial belt',
//     price: 7890,
//     photoUrls: ['1', '2'],
//     isActive: true,
//     isAvailable: true,
//     isBanned: false,
//     description: `Style is all about the details. Upgrade your everyday looks with this mini 2.0 industrial belt from Off-White. Designed in red and white, this piece won't let you get unnoticed in the streets. Go for it.`
//   };
//   batch.set(productRef.doc(product2.id), product2);
//   const product3 = {
//     id: 'qnZK4R8YiLaseJAN8Z6w',
//     businessId: 'Fvb3sxEA9jS9UOoh6Pjv',
//     name: 'Off-White logo print belt',
//     price: 5290,
//     photoUrls: ['1', '2'],
//     isActive: true,
//     isAvailable: true,
//     isBanned: false,
//     description: `Buckle up. This logo belt comes in understated tones, but that doesn't mean it wont't make a high impact. The perfect finishing touch. Featuring an all over logo print, no belt loops and a buckle detail.`
//   };
//   batch.set(productRef.doc(product3.id), product3);
//   const collection1 = {
//     id: 'OZExOAdSqUk2Iehbd7X4',
//     name: 'Off-White Men Belt',
//     photoUrl: '',
//     products: ['1', '2'],
//     businessId: biz1
//   };
//   batch.set(collectionRef.doc(collection1.id), collection1);
//   const collection2 = {
//     id: 'nurTithW2KM1ZXhVDhID',
//     name: 'Off-White New Season Bags',
//     photoUrl: '',
//     products: ['1', '2'],
//     businessId: biz2
//   };
//   batch.set(collectionRef.doc(collection2.id), collection2);
//   const collection3 = {
//     id: 'wt40mgQYvonic15gVFlU',
//     name: 'Off-White Designer Sneakers',
//     photoUrl: '',
//     products: ['1', '2'],
//     businessId: biz1
//   };
//   batch.set(collectionRef.doc(collection3.id), collection3);
//   batch.commit();
// });

// const getRandomArbitrary = (min: number, max: number) => {
//   min = Math.ceil(min);
//   max = Math.floor(max);
//   return Math.floor(Math.random() * (max - min) + min);
// };

// export const createChat = functions.firestore.document('tests/{testId}').onCreate(async (snap, _) => {
//   const chatRef = db.collection('chats');
//   const accounts = [biz1, biz2, user1, user2];
//   const randomInt = getRandomArbitrary(0, 3);
//   const receiverId = accounts[randomInt];
//   const docId1 = chatRef.doc().id;
//   const chat1 = {
//     id: docId1,
//     senderId: user3,
//     receiverId: receiverId,
//     type: 'text',
//     isRead: false,
//     content: `Hello, my man`
//   };
//   chatRef.doc(docId1).set(chat1);
//   const docId2 = chatRef.doc().id;
//   const chat2 = {
//     id: docId2,
//     senderId: user3,
//     receiverId: receiverId,
//     type: 'photo',
//     isRead: false,
//     content: 'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/message_images%2FmqDrMMvVNFLXA9MKTA2b?alt=media&token=fbd29be7-5c79-43a5-a888-339bba1e001b'
//   };
//   chatRef.doc(docId2).set(chat2);
// });

const getBusiness = async (businessId: string): Promise<any> => {
  return new Promise((resolve, reject) => {
    const businessRef = db.collection('businesses').doc(businessId);
    businessRef
      .get()
      .then((doc) => {
        if (!doc.exists) {
          console.log('No business is found');
          resolve('');
        } else {
          const business = doc.data();
          resolve(business);
        }
      })
      .catch(() => {
        reject('Error getting document:');
      });
  });
};

const getUser = async (userId: string): Promise<any> => {
  return new Promise((resolve, reject) => {
    const userRef = db.collection('users').doc(userId);
    userRef
      .get()
      .then((doc) => {
        if (!doc.exists) {
          console.log('No user is found');
          resolve('');
        } else {
          const user = doc.data();
          resolve(user);
        }
      })
      .catch(() => {
        reject('Error getting document:');
      });
  });
};

const getAccountInfo = async (accountId: string) => {
  let account = await getUser(accountId);
  if (account !== '') {
    return account;
  } else {
    account = await getBusiness(accountId);
    return account;
  }
};

const getDevice = async (accountId: string): Promise<any> => {
  return new Promise((resolve, reject) => {
    const deviceRef = db.collection('devices');
    deviceRef
      .where('accountId', '==', accountId)
      .limit(1)
      .get()
      .then((devices) => {
        if (!devices.empty) {
          devices.forEach((doc) => {
            const currentDoc = doc.data();
            resolve(currentDoc);
            return;
          });
        }
        resolve('');
      })
      .catch(() => {
        reject('Error getting document:');
      });
  });
};

export const observeMessages = functions
  .region('asia-east2')
  .firestore.document('messages/{messageId}/contents/{contentId}')
  .onCreate(async (snap, context) => {
    const messengerId = context.params.messageId;
    const doc = snap.data();
    const senderId = doc.senderId;
    const receiverId = doc.receiverId;
    if (doc.isRead === false) {
      const senderInfo = await getAccountInfo(senderId);
      const receiverInfo = await getAccountInfo(receiverId);
      const device = await getDevice(receiverId);
      const tokens = device.tokens.map((element: any) => element.fcmToken);
      const payload = {
        notification: {
          title: `[${receiverInfo.username}] New Message`,
          body: doc.type === 'text' ? `[${senderInfo.username}]: ${doc.content}` : `(${senderInfo.username}) sent you a photo`,
          imageUrl: doc.type === 'photo' ? doc.content : undefined
        },
        data: {
          messengerId: messengerId,
          senderId: senderId,
          receiverId: receiverId,
          content: 'message'
        },
        android: {
          notification: {
            sound: 'default'
          }
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: 'default'
            }
          },
          fcm_options: {
            image: ''
          }
        },
        tokens: tokens
      };

      message.sendMulticast(payload).then((response) => {
        if (response.failureCount > 0) {
          const failedTokens: any = [];
          response.responses.forEach((resp, idx) => {
            if (!resp.success) {
              failedTokens.push(tokens[idx]);
            }
          });
          console.log('List of tokens that caused failures: ' + failedTokens);
        }
      });

      // Second sendToDevice
      // message
      //   .sendToDevice(tokens, payload)
      //   .then(function (response) {
      //     // See the MessagingDevicesResponse reference documentation for
      //     // the contents of response.
      //     console.log('Successfully sent message:', response);
      //   })
      //   .catch(function (error) {
      //     console.log('Error sending message:', error);
      //   });
    }
  });

// export const createReservation = functions.firestore.document('books/{bookId}').onCreate(async (snap, _) => {
// 	const reservationRef = db.collection('reservations');
// 	const timeslotRef = db.collection('timeslots');
// 	const timeslotId = 'CdDHrdZdAozYBFXsRBrh';
// 	const statuses = ['Pending', 'Approved', 'Completed', 'Failed', 'Canceled', 'Declined'];
// 	let randomInt = getRandomArbitrary(0, 6);
// 	console.log(`Checking Random`, randomInt);
// 	const status = statuses[randomInt];
// 	console.log(`Checking Current Status`, status);
// 	const docId1 = reservationRef.doc().id;
// 	randomInt = getRandomArbitrary(0, 1);
// 	const canceledBys = [user1, biz1];
// 	const canceler = canceledBys[randomInt];
// 	console.log(`Checking Current Canceler`, canceler);
// 	if (status === 'Canceled') {
// 		const reserve1 = {
// 			id: docId1,
// 			userId: user1,
// 			businessId: biz1,
// 			status: status,
// 			isCanceled: true,
// 			canceledBy: canceler,
// 			timeslotId: timeslotId,
// 			products: ['first', 'second']
// 		};
// 		reservationRef.doc(docId1).set(reserve1);
// 	} else {
// 		const reserve1 = {
// 			id: docId1,
// 			userId: user1,
// 			businessId: biz1,
// 			status: status,
// 			isCanceled: false,
// 			canceledBy: '',
// 			timeslotId: timeslotId,
// 			products: ['first', 'second']
// 		};
// 		reservationRef.doc(docId1).set(reserve1);
// 	}

// 	const timeslot = {
// 		id: timeslotId,
// 		date: '2021-2-22',
// 		time: '8:30 - 10:30'
// 	};
// 	timeslotRef.doc(timeslotId).set(timeslot);
// });

const getTimeslot = async (timeslotId: string): Promise<any> => {
  return new Promise(async (resolve, _) => {
    const timeslotRef = db.collection('timeslots').doc(timeslotId);
    const doc = await timeslotRef.get();
    if (!doc.exists) {
      console.log('No such timeslot!');
      resolve('');
    } else {
      const data = doc.data();
      resolve(data);
    }
  });
};

// Reservation Status
// 1. Pending
// 2. Approved
// 3. Completed
// 4. Failed
// 5. Canceled
// 6. Declined

const dispatchActivity = (senderId: String, receiverId: String, reservationId: String, content: String) => {
  const activityRef = db.collection('activities');
  const recordId = activityRef.doc().id;
  const record = {
    id: recordId,
    senderId: senderId,
    receiverId: receiverId,
    reservationId: reservationId,
    content: content,
    createdAt: new Date().toISOString()
  };
  activityRef
    .doc(recordId)
    .set(record)
    .then(() => {
      console.log(`Activity has been added`);
    })
    .catch((err) => {
      console.log(`Activity cannot be added`, err);
    });
};

export const observeReservation = functions
  .region('asia-east2')
  .firestore.document('reservations/{reservationId}')
  .onWrite(async (change, _) => {
    const doc = change.after.exists ? change.after.data() : null;
    if (doc == null) {
      return;
    }
    const reservationId = doc.id;
    const userId = doc.userId;
    const businessId = doc.businessId;
    const timeslotId = doc.timeslotId;
    const status = doc.status;
    const isCanceled = doc.isCanceled;
    const canceledBy = doc.canceledBy;
    const products = doc.products;
    let payload: any;
    let tokens: any;
    if (doc != null) {
      const userInfo = await getAccountInfo(userId);
      const businessInfo = await getAccountInfo(businessId);
      const timeslot = await getTimeslot(timeslotId);
      const date = timeslot.date;
      const time = timeslot.time.replace(/\s/g, '');
      const productString = `${date} ${time} for ${products.length} ${products.length === 1 ? 'product' : 'products'}`;
      if (status === 'Pending' || (status === 'Canceled' && canceledBy === userId && isCanceled == false)) {
        const device = await getDevice(businessId);
        tokens = device.tokens.map((element: any) => element.fcmToken);
        if (status === 'Pending') {
          const title = `[${businessInfo.username}] New Reservation`;
          const body = `[${userInfo.username}] has requested a reservation, ${productString}.`;
          const content = `username has requested a reservation, ${productString}.`;
          payload = {
            notification: {
              title: title,
              body: body
            },
            data: {
              reservationId: reservationId,
              senderId: userId,
              receiverId: businessId,
              content: 'reservation'
            },
            tokens: tokens
          };
          dispatchActivity(userId, businessId, reservationId, content);
        } else {
          const title = `[${businessInfo.username}] Cancellation Requested`;
          const body = `[${userInfo.username}] has requested for cancellation, ${productString}.`;
          const content = `username has requested for cancellation, ${productString}.`;
          payload = {
            notification: {
              title: title,
              body: body
            },
            data: {
              reservationId: reservationId,
              senderId: userId,
              receiverId: businessId,
              content: 'reservation'
            },
            android: {
              notification: {
                sound: 'default'
              }
            },
            apns: {
              payload: {
                aps: {
                  badge: 1,
                  sound: 'default'
                }
              },
              fcm_options: {
                image: ''
              }
            },
            tokens: tokens
          };
          dispatchActivity(userId, businessId, reservationId, content);
        }
      } else {
        const device = await getDevice(userId);
        tokens = device.tokens.map((element: any) => element.fcmToken);
        if (status === 'Approved') {
          const title = `[${userInfo.username}] Reservation Approved`;
          const body = `[${businessInfo.username}] has approved your reservation, ${productString}.`;
          const content = `username has approved your reservation, ${productString}.`;
          payload = {
            notification: {
              title: title,
              body: body
            },
            data: {
              reservationId: reservationId,
              senderId: businessId,
              receiverId: userId,
              content: 'reservation'
            },
            android: {
              notification: {
                sound: 'default'
              }
            },
            apns: {
              payload: {
                aps: {
                  badge: 1,
                  sound: 'default'
                }
              },
              fcm_options: {
                image: ''
              }
            },
            tokens: tokens
          };
          dispatchActivity(businessId, userId, reservationId, content);
        } else if (status === 'Completed') {
          const title = `[${userInfo.username}] Reservation Completed`;
          const body = `You have completed your reservation to [${businessInfo.username}], ${productString}.`;
          const content = `You have completed your reservation to username, ${productString}.`;
          payload = {
            notification: {
              title: title,
              body: body
            },
            data: {
              reservationId: reservationId,
              senderId: businessId,
              receiverId: userId,
              content: 'reservation'
            },
            android: {
              notification: {
                sound: 'default'
              }
            },
            apns: {
              payload: {
                aps: {
                  badge: 1,
                  sound: 'default'
                }
              },
              fcm_options: {
                image: ''
              }
            },
            tokens: tokens
          };
          dispatchActivity(businessId, userId, reservationId, content);
        } else if (status === 'Failed') {
          const title = `[${userInfo.username}] Reservation Failed`;
          const body = `You have failed to complete your reservation to [${businessInfo.username}], ${productString}.`;
          const content = `You have failed to complete your reservation to username, ${productString}.`;
          payload = {
            notification: {
              title: title,
              body: body
            },
            data: {
              reservationId: reservationId,
              senderId: businessId,
              receiverId: userId,
              content: 'reservation'
            },
            android: {
              notification: {
                sound: 'default'
              }
            },
            apns: {
              payload: {
                aps: {
                  badge: 1,
                  sound: 'default'
                }
              },
              fcm_options: {
                image: ''
              }
            },
            tokens: tokens
          };
          dispatchActivity(businessId, userId, reservationId, content);
        } else if (status === 'Canceled') {
          if (canceledBy === userId && isCanceled === true) {
            const title = `[${userInfo.username}] Cancellation Approved`;
            const body = `Your cancellation has been approved by [${businessInfo.username}], ${productString}.`;
            const content = `Your cancellation has been approved by username, ${productString}.`;
            payload = {
              notification: {
                title: title,
                body: body
              },
              data: {
                reservationId: reservationId,
                senderId: businessId,
                receiverId: userId,
                content: 'reservation'
              },
              android: {
                notification: {
                  sound: 'default'
                }
              },
              apns: {
                payload: {
                  aps: {
                    badge: 1,
                    sound: 'default'
                  }
                },
                fcm_options: {
                  image: ''
                }
              },
              tokens: tokens
            };
            dispatchActivity(businessId, userId, reservationId, content);
          } else {
            const title = `[${userInfo.username}] Reservation Canceled`;
            const body = `Your reservation has been canceled by [${businessInfo.username}], ${productString}.`;
            const content = `Your reservation has been canceled by username, ${productString}.`;
            payload = {
              notification: {
                title: title,
                body: body
              },
              data: {
                reservationId: reservationId,
                senderId: businessId,
                receiverId: userId,
                content: 'reservation'
              },
              android: {
                notification: {
                  sound: 'default'
                }
              },
              apns: {
                payload: {
                  aps: {
                    badge: 1,
                    sound: 'default'
                  }
                },
                fcm_options: {
                  image: ''
                }
              },
              tokens: tokens
            };
            dispatchActivity(businessId, userId, reservationId, content);
          }
        } else if (status === 'Declined') {
          const title = `[${userInfo.username}] Reservation Declined`;
          const body = `Your reservation has been declined by [${businessInfo.username}], ${productString}.`;
          const content = `Your reservation has been declined by username, ${productString}.`;
          payload = {
            notification: {
              title: title,
              body: body
            },
            data: {
              reservationId: reservationId,
              senderId: businessId,
              receiverId: userId,
              content: 'reservation'
            },
            android: {
              notification: {
                sound: 'default'
              }
            },
            apns: {
              payload: {
                aps: {
                  badge: 1,
                  sound: 'default'
                }
              },
              fcm_options: {
                image: ''
              }
            },
            tokens: tokens
          };
          dispatchActivity(businessId, userId, reservationId, content);
        }
      }
      message.sendMulticast(payload).then((response) => {
        if (response.failureCount > 0) {
          const failedTokens: any = [];
          response.responses.forEach((resp, idx) => {
            if (!resp.success) {
              failedTokens.push(tokens[idx]);
            }
          });
          console.log('List of tokens that caused failures: ' + failedTokens);
        }
      });
    }
  });

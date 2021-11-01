export const getUser = (userId, users) => {
  const user = users.filter((element) => element.id === userId)[0];
  return user;
};

export const searchUsers = (searchKey, users) => {
  const iUsers = users.filter((store) => store.username.toLowerCase().includes(searchKey.toLowerCase()));
  return iUsers;
};

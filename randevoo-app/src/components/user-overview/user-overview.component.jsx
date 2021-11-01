import React from 'react';
import { connect } from 'react-redux';
import { createStructuredSelector } from 'reselect';
import { withRouter } from 'react-router-dom';

import UserItem from '../user-item/user-item.component';

import { selectUsers, selectSearchUsers, selectIsSearch } from '../../redux/user/user.selectors';

const UserOverview = (props) => {
  const { users, iUsers, isSearch, history } = props;

  const previewItem = (userId) => {
    history.push(`/admin/user/${userId}`);
  };
  return (
    <div className='store-overview'>
      <div>
        {isSearch
          ? iUsers.map((item) => <UserItem key={item.id} item={item} previewItem={() => previewItem(item.id)} />)
          : users.map((item) => <UserItem key={item.id} item={item} previewItem={() => previewItem(item.id)} />)}
      </div>
    </div>
  );
};

const mapStateToProps = createStructuredSelector({
  users: selectUsers,
  iUsers: selectSearchUsers,
  isSearch: selectIsSearch
});

export default withRouter(connect(mapStateToProps)(UserOverview));

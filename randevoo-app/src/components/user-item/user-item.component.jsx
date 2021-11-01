import React from 'react';
import { connect } from 'react-redux';

import ProfileIcon from '../../assets/profile.png';

const UserItem = ({ item, previewItem }) => {
  const { username, profileUrl } = item;
  return (
    <div className='user-item' onClick={() => previewItem(item.id)}>
      <img className='user-photo' src={profileUrl !== '' ? profileUrl : ProfileIcon} alt='User Profile' />
      <div className='user-footer'>
        <span className='username'>{username}</span>
      </div>
      <div className={`ban-status ${item.isBanned ? 'active' : ''}`}>
        <span>Is banned</span>
      </div>
    </div>
  );
};

export default connect()(UserItem);

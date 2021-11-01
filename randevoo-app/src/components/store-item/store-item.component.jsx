import React from 'react';
import { connect } from 'react-redux';

import ProfileIcon from '../../assets/profile.png';

const StoreItem = ({ item, previewItem }) => {
  const { username, location, profileUrl } = item;
  return (
    <div className='store-item' onClick={() => previewItem(item.id)}>
      <img className='store-photo' src={profileUrl !== '' ? profileUrl : ProfileIcon} alt='Store Profile' />
      <div className='store-footer'>
        <span className='username'>{username}</span>
        <span className='location'>{location}</span>
      </div>
      <div className={`ban-status ${item.isBanned ? 'active' : ''}`}>
        <span>Is banned</span>
      </div>
    </div>
  );
};

export default connect()(StoreItem);

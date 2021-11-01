import React from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import StoreItem from '../store-item/store-item.component';

const UserStoreOverview = (props) => {
  const { stores, history } = props;

  const previewItem = (storeId) => {
    history.push(`/admin/store/${storeId}`);
  };
  return (
    <div className='user-store-overview'>
      <div>
        {stores.map((item) => (
          <StoreItem key={item.id} item={item} previewItem={() => previewItem(item.id)} />
        ))}
      </div>
    </div>
  );
};

export default withRouter(connect()(UserStoreOverview));

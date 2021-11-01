import React from 'react';
import { connect } from 'react-redux';
import { createStructuredSelector } from 'reselect';
import { withRouter } from 'react-router-dom';

import StoreItem from '../store-item/store-item.component';

import { selectStores, selectSearchStores, selectIsSearch } from '../../redux/store/store.selectors';

const StoreOverview = (props) => {
  const { stores, iStores, isSearch, history } = props;

  const previewItem = (storeId) => {
    history.push(`/admin/store/${storeId}`);
  };
  return (
    <div className='store-overview'>
      <div>
        {isSearch
          ? iStores.map((item) => <StoreItem key={item.id} item={item} previewItem={() => previewItem(item.id)} />)
          : stores.map((item) => <StoreItem key={item.id} item={item} previewItem={() => previewItem(item.id)} />)}
      </div>
    </div>
  );
};

const mapStateToProps = createStructuredSelector({
  stores: selectStores,
  iStores: selectSearchStores,
  isSearch: selectIsSearch
});

export default withRouter(connect(mapStateToProps)(StoreOverview));

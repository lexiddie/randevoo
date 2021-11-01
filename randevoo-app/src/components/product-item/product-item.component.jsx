import React from 'react';
import { connect } from 'react-redux';
import NumberFormat from 'react-number-format';

import CustomButton from '../custom-button/custom-button.component';

const ProductItem = ({ item, previewItem }) => {
  const { name, price, photoUrls } = item;
  return (
    <div className='product-item'>
      <div className='product-photo' style={{ backgroundImage: `url(${photoUrls[0]})` }} />
      <div className='product-footer'>
        <span className='name'>{name}</span>
        <NumberFormat className='price' value={price} displayType={'text'} thousandSeparator={true} prefix={'฿'} />
      </div>
      <CustomButton className='custom-button' onClick={() => previewItem(item.id)} inverted>
        Preview Now
      </CustomButton>
      <div className={`ban-status ${item.isBanned || !item.isActive ? 'active' : ''}`}>
        <span className={`${!item.isBanned ? 'hide' : ''}`}>Is banned</span>
        <span className={`${!item.isActive ? 'inactive' : 'hide'}`}>{`${!item.isActive ? 'Is inactive' : ''}`}</span>
      </div>
    </div>
  );
};

export default connect()(ProductItem);

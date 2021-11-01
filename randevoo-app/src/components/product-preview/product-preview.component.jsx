import React, { useEffect, useState } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import SimpleImageSlider from 'react-simple-image-slider';
import NumberFormat from 'react-number-format';
import { Map, Marker, GoogleApiWrapper } from 'google-maps-react';

import { Label, Button, Modal, ModalHeader, ModalFooter, Card, CardBody, FormGroup } from 'reactstrap';

import { selectPreviewProduct } from '../../redux/product/product.selectors';
import { fetchStore, fetchStoreInfo } from '../../redux/store/store.actions';
import { selectCurrentStore, selectCurrentStoreInfo } from '../../redux/store/store.selectors';
// import { selectSubcategory } from '../../redux/category/category.selectors';

import { doc, updateDoc } from 'firebase/firestore';
import { firestore } from '../../firebase/firebase.utils';

import mapStyle from '../../data/GoogleMaps.json';
import jsonColors from '../../data/Colors.json';
import StoreLogo from '../../assets/store.png';

const ActionModal = (props) => {
  const { modal, toggle, banProduct, product } = props;

  const banningProduct = () => {
    banProduct(!product.isBanned);
    toggle();
  };

  return (
    <Modal className='modal-rounded' size='md' centered isOpen={modal} toggle={toggle}>
      <Card>
        <ModalHeader className='modal-header' toggle={toggle}>
          {product.isBanned ? `Unban Confirmation` : `Ban Confirmation`}
        </ModalHeader>
        <CardBody>
          <FormGroup>
            <Label className='modal-info font-size-20'>
              {product.isBanned ? `Are you sure you want to unban this product?` : `Are you sure you want to ban this product?`}
            </Label>
          </FormGroup>

          <ModalFooter className='d-flex flex-wrap justify-content-between'>
            {/* <Button className='main-btn-default w-100x' onClick={toggle}>
              Confirm
            </Button> */}

            <Button className='w-40x main-btn-caution' onClick={banningProduct}>
              Confirm
            </Button>
            <Button className='w-40x' color='secondary' onClick={toggle}>
              Cancel
            </Button>
          </ModalFooter>
        </CardBody>
      </Card>
    </Modal>
  );
};

const ProductPreview = (props) => {
  const { history, product, fetchStore, fetchStoreInfo, store, storeInfo, google } = props;
  // const { name, price, subcategoryId, photoUrls, description, businessId } = product;
  const { name, price, photoUrls, description, businessId } = product;
  const images = photoUrls.map((element) => ({ url: element }));
  const [colors, setColors] = useState([]);
  const [sizes, setSizes] = useState([]);
  const [modal, setModal] = useState(false);
  const [quantity, setQuantity] = useState(0);
  const [available, setAvailable] = useState(0);

  const dispatchAmount = () => {
    if (product == null) {
      return;
    }
    const quantity = product.variants.reduce((total, current) => parseFloat(total) + parseFloat(current.quantity), 0);
    setQuantity(quantity);
    const available = product.variants.reduce((total, current) => parseFloat(total) + parseFloat(current.quantity), 0);
    setAvailable(available);
  };

  const toggleModal = () => {
    setModal(!modal);
  };

  const mapLoaded = (map) => {
    map.setOptions({
      styles: mapStyle
    });
  };

  const getVariants = () => {
    if (product == null) {
      return;
    }
    const tempColors = [];
    const tempSizes = [];
    product.variants.forEach((item, _) => {
      if (!tempColors.some((j) => j.name === item.color)) {
        const color = jsonColors.filter((first) => first.name === item.color)[0];
        const data = {
          name: item.color,
          code: color !== undefined ? color.code : 'None'
        };
        tempColors.push(data);
      }

      if (!tempSizes.includes(item.size)) {
        tempSizes.push(item.size);
      }
    });
    setColors(tempColors);
    setSizes(tempSizes);
  };

  const previewStore = (storeId) => {
    history.push(`/admin/store/${storeId}`);
  };

  const banProduct = async (toBan) => {
    if (product == null) {
      return;
    }
    const productRef = doc(firestore, 'products', product.id);
    try {
      await updateDoc(productRef, {
        isBanned: toBan ? true : false
      });
      toBan ? console.log(`The product has been banned successfully.`) : console.log(`The product has been unbanned successfully.`);
    } catch (err) {
      console.log(`Err has occurred: `, err);
    }
  };

  useEffect(() => {
    dispatchAmount();
    // fetchCategoriesStart();
    getVariants();
    fetchStore(businessId);
    fetchStoreInfo(businessId);
  }, []);

  return (
    <div className='product-preview'>
      <ActionModal modal={modal} toggle={toggleModal} banProduct={banProduct} product={product} />
      <div>
        <div>
          <SimpleImageSlider
            images={images}
            bgColor={'#FFFFFF'}
            useGPURender={true}
            height={800}
            width={800}
            navStyle={2}
            showNavs={true}
            showBullets={true}
          />
        </div>
        <div>
          <div>
            <div className='product-status'>
              <span className={`${product.isBanned ? 'banned' : ''}`}>{product.isBanned ? `Product is banned` : `Product is active💛`}</span>
            </div>
            <div className='product-action-button'>
              <Button className='main-btn-default' onClick={toggleModal}>
                {product.isBanned ? `Unban Product` : `Ban Product`}
              </Button>
            </div>
            <span>{name}</span>
            <NumberFormat className='price' value={price} displayType={'text'} thousandSeparator={true} prefix={'฿'} />
            <div className='display-variant m-t-30'>
              <span>Color</span>
              <div>
                {product != null
                  ? colors.map((item, index) => (
                      <span key={`color-key-${index}`}>
                        <div style={{ backgroundColor: `#${item.code}` }}></div>
                        {item.name}
                      </span>
                    ))
                  : null}
              </div>
            </div>
            <div className='display-variant'>
              <span>Size</span>
              <div>
                {product != null
                  ? sizes.map((item, index) => (
                      <span className='size' key={`size-key-${index}`}>
                        {item}
                      </span>
                    ))
                  : null}
              </div>
            </div>
            <div className='amount'>
              <span>{`Quantity: ${quantity}`}</span>
            </div>
            <div className='amount'>
              <span>{`Available: ${available}`}</span>
            </div>
            <div className='description'>
              <span>Description</span>
              <span>{description}</span>
            </div>
            <div className='store-info' onClick={() => previewStore(store.id)}>
              {store != null ? (
                <>
                  <span>Listed By</span>
                  <div>
                    <img src={store.profileUrl} alt='Store Profile' />
                    <span>{store.username}</span>
                  </div>
                </>
              ) : null}
            </div>
            <div className='google-maps'>
              <span>Google Maps</span>
              <div>
                {storeInfo != null ? (
                  <Map
                    google={google}
                    initialCenter={{
                      lat: storeInfo.geoPoint.lat,
                      lng: storeInfo.geoPoint.long
                    }}
                    zoom={15}
                    onReady={(_, map) => mapLoaded(map)}>
                    <Marker icon={StoreLogo} />
                  </Map>
                ) : (
                  <></>
                )}
              </div>
            </div>
            {/* <div className='action-button'>
              <CustomButton className='custom-button' onClick={() => console.log(`On clicked actions`)} inverted>
                Actions
              </CustomButton>
            </div> */}
          </div>
        </div>
      </div>
    </div>
  );
};

const mapStateToProps = (state, ownProps) => {
  return {
    product: selectPreviewProduct(ownProps.match.params.productId)(state),
    store: selectCurrentStore(state),
    storeInfo: selectCurrentStoreInfo(state)
  };
};

const mapDispatchToProps = (dispatch) => ({
  fetchStore: (storeId) => dispatch(fetchStore(storeId)),
  fetchStoreInfo: (storeId) => dispatch(fetchStoreInfo(storeId))
});

export default withRouter(
  GoogleApiWrapper(() => {
    const apiKey = process.env.REACT_APP_GOOGLE_MAPS_API;
    return {
      apiKey: apiKey,
      language: 'EN'
    };
  })(connect(mapStateToProps, mapDispatchToProps)(ProductPreview))
);

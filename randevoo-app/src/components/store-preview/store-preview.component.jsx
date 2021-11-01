import React, { useEffect, useState } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import { TabContent, TabPane, Nav, NavItem, NavLink, Label, Button, Modal, ModalHeader, ModalFooter, Card, CardBody, FormGroup } from 'reactstrap';

import { selectStoreProducts } from '../../redux/product/product.selectors';
import { fetchUser } from '../../redux/user/user.actions';
import { selectCurrentUser } from '../../redux/user/user.selectors';
import { fetchStoreInfo } from '../../redux/store/store.actions';
import { selectPreviewStore, selectCurrentStoreInfo } from '../../redux/store/store.selectors';

import { doc, updateDoc } from 'firebase/firestore';
import { firestore } from '../../firebase/firebase.utils';

import StoreProductOverview from '../store-product-overview/store-product-overview.component';
import StoreAbout from '../store-about/store-about.component';

import ProfileIcon from '../../assets/profile.png';

const ActionModal = (props) => {
  const { modal, toggle, banStore, store } = props;

  const banningStore = () => {
    banStore(!store.isBanned);
    toggle();
  };

  return (
    <Modal className='modal-rounded' size='md' centered isOpen={modal} toggle={toggle}>
      <Card>
        <ModalHeader className='modal-header' toggle={toggle}>
          {store.isBanned ? `Unban Confirmation` : `Ban Confirmation`}
        </ModalHeader>
        <CardBody>
          <FormGroup>
            <Label className='modal-info font-size-20'>
              {store.isBanned ? `Are you sure you want to unban this store?` : `Are you sure you want to ban this store?`}
            </Label>
          </FormGroup>

          <ModalFooter className='d-flex flex-wrap justify-content-between'>
            {/* <Button className='main-btn-default w-100x' onClick={toggle}>
              Confirm
            </Button> */}

            <Button className='w-40x main-btn-caution' onClick={banningStore}>
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

const StorePreview = (props) => {
  const [activeTab, setActiveTab] = useState('1');
  const tabList = ['Listings', 'About'];
  const [modal, setModal] = useState(false);

  const toggleModal = () => {
    setModal(!modal);
  };

  const { fetchStoreInfo, store, storeInfo, fetchUser, user, products } = props;

  const toggle = (value) => {
    setActiveTab(value);
  };

  const dispatchSite = () => {
    if (store != null && store.website !== '') {
      window.open(`https://${store.website}`, '_blank');
    }
  };

  const dispatchGoogleMaps = () => {
    if (storeInfo != null && storeInfo.geoPoint.lat !== '' && storeInfo.geoPoint.long !== '') {
      const url = `https://www.google.com/maps/search/?api=1&query=${storeInfo.geoPoint.lat},${storeInfo.geoPoint.long}`;
      window.open(url, '_blank');
    }
  };

  const banStore = async (toBan) => {
    if (store == null) {
      return;
    }
    const storeRef = doc(firestore, 'businesses', store.id);
    try {
      await updateDoc(storeRef, {
        isBanned: toBan ? true : false
      });
      toBan ? console.log(`The store has been banned successfully.`) : console.log(`The store has been unbanned successfully.`);
    } catch (err) {
      console.log(`Err has occurred: `, err);
    }
  };

  useEffect(() => {
    fetchStoreInfo(store.id);
    fetchUser(store.userId);
  }, []);

  return (
    <>
      <div className='store-preview'>
        <ActionModal modal={modal} toggle={toggleModal} banStore={banStore} store={store} />
        <div>
          <div className='store-profile'>
            <div>
              <div>
                <img className='store-img' src={store.profileUrl !== '' ? store.profileUrl : ProfileIcon} alt='Store Profile' />
              </div>
              <div>
                <div className='store-name'>
                  <span>{store.name}</span>
                </div>
                <div className='store-type'>
                  <span>{store.type}</span>
                </div>
                <div className='store-bio'>
                  <span>{store.bio}</span>
                </div>
                <div className='store-site' onClick={dispatchSite}>
                  <span>{store.website}</span>
                </div>
                <div className='store-location' onClick={dispatchGoogleMaps}>
                  <span>{store.location}</span>
                </div>
              </div>
            </div>
          </div>
          <div>
            <div>
              <div>
                <div className='store-status'>
                  <span className={`${store.isBanned ? 'banned' : ''}`}>{store.isBanned ? `Account is banned` : `Account is active💛`}</span>
                </div>
                <div className='store-action-button'>
                  <Button className='main-btn-default' onClick={toggleModal}>
                    {store.isBanned ? `Unban Account` : `Ban Account`}
                  </Button>
                </div>
                <Nav>
                  {tabList.map((item, index) => {
                    return (
                      <NavItem key={`store-tab-${index}`}>
                        <NavLink
                          className={`${(index + 1).toString() === activeTab ? 'active' : ''}`}
                          onClick={() => {
                            toggle(`${index + 1}`);
                          }}>
                          <span className={`${(index + 1).toString() === activeTab ? 'active' : ''}`}>{item}</span>
                        </NavLink>
                      </NavItem>
                    );
                  })}
                </Nav>
                <TabContent activeTab={activeTab}>
                  <TabPane tabId='1'>
                    <StoreProductOverview activeTab={activeTab} products={products} />
                  </TabPane>
                  <TabPane tabId='2'>
                    {storeInfo != null && user != null ? <StoreAbout activeTab={activeTab} store={store} storeInfo={storeInfo} user={user} /> : null}
                  </TabPane>
                </TabContent>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

const mapStateToProps = (state, ownProps) => {
  return {
    store: selectPreviewStore(ownProps.match.params.storeId)(state),
    storeInfo: selectCurrentStoreInfo(state),
    products: selectStoreProducts(ownProps.match.params.storeId)(state),
    user: selectCurrentUser(state)
  };
};

const mapDispatchToProps = (dispatch) => ({
  fetchStoreInfo: (storeId) => dispatch(fetchStoreInfo(storeId)),
  fetchUser: (userId) => dispatch(fetchUser(userId))
});

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(StorePreview));

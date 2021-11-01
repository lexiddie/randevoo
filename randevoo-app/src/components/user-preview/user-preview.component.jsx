import React, { useEffect, useState } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import { TabContent, TabPane, Nav, NavItem, NavLink, Label, Button, Modal, ModalHeader, ModalFooter, Card, CardBody, FormGroup } from 'reactstrap';

import { selectUserStores } from '../../redux/store/store.selectors';
import { selectPreviewUser, selectCurrentUserProvider } from '../../redux/user/user.selectors';
import { fetchUserProvider } from '../../redux/user/user.actions';

import { doc, updateDoc } from 'firebase/firestore';
import { firestore } from '../../firebase/firebase.utils';

import UserStoreOverview from '../user-store-overview/user-store-overview.component';
import UserAbout from '../user-about/user-about.component';

import ProfileIcon from '../../assets/profile.png';

const ActionModal = (props) => {
  const { modal, toggle, banUser, user } = props;

  const banningUser = () => {
    banUser(!user.isBanned);
    toggle();
  };

  return (
    <Modal className='modal-rounded' size='md' centered isOpen={modal} toggle={toggle}>
      <Card>
        <ModalHeader className='modal-header' toggle={toggle}>
          {user.isBanned ? `Unban Confirmation` : `Ban Confirmation`}
        </ModalHeader>
        <CardBody>
          <FormGroup>
            <Label className='modal-info font-size-20'>
              {user.isBanned ? `Are you sure you want to unban this user?` : `Are you sure you want to ban this user?`}
            </Label>
          </FormGroup>

          <ModalFooter className='d-flex flex-wrap justify-content-between'>
            {/* <Button className='main-btn-default w-100x' onClick={toggle}>
              Confirm
            </Button> */}

            <Button className='w-40x main-btn-caution' onClick={banningUser}>
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

const UserPreview = (props) => {
  const [activeTab, setActiveTab] = useState('1');
  const tabList = ['Stores', 'About'];
  const [modal, setModal] = useState(false);

  const toggleModal = () => {
    setModal(!modal);
  };

  const { user, provider, stores, fetchUserProvider } = props;

  const toggle = (value) => {
    setActiveTab(value);
  };

  const dispatchSite = () => {
    if (user != null && user.website !== '') {
      window.open(`https://${user.website}`, '_blank');
    }
  };

  const banUser = async (toBan) => {
    if (user == null) {
      return;
    }
    const userRef = doc(firestore, 'users', user.id);
    try {
      await updateDoc(userRef, {
        isBanned: toBan ? true : false
      });
      toBan ? console.log(`The user has been banned successfully.`) : console.log(`The user has been unbanned successfully.`);
    } catch (err) {
      console.log(`Err has occurred: `, err);
    }
  };

  useEffect(() => {
    fetchUserProvider(user.id);
  }, []);

  return (
    <>
      <div className='user-preview'>
        <ActionModal modal={modal} toggle={toggleModal} banUser={banUser} user={user} />
        <div>
          <div className='user-profile'>
            <div>
              <div>
                <img className='user-img' src={user.profileUrl !== '' ? user.profileUrl : ProfileIcon} alt='Store Profile' />
              </div>
              <div>
                <div className='user-name'>
                  <span>{user.name}</span>
                </div>
                <div className='user-bio'>
                  <span>{user.bio}</span>
                </div>
                <div className='user-site' onClick={dispatchSite}>
                  <span>{user.website}</span>
                </div>
                <div className='user-location'>
                  <span>{user.location}</span>
                </div>
              </div>
            </div>
          </div>
          <div>
            <div>
              <div>
                <div className='user-status'>
                  <span className={`${user.isBanned ? 'banned' : ''}`}>{user.isBanned ? `User is banned` : `User is active💛`}</span>
                </div>
                <div className='user-action-button'>
                  <Button className='main-btn-default' onClick={toggleModal}>
                    {user.isBanned ? `Unban User` : `Ban User`}
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
                    <UserStoreOverview activeTab={activeTab} stores={stores} />
                  </TabPane>
                  <TabPane tabId='2'>
                    {provider != null && user != null ? <UserAbout activeTab={activeTab} user={user} provider={provider} /> : null}
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
    user: selectPreviewUser(ownProps.match.params.userId)(state),
    stores: selectUserStores(ownProps.match.params.userId)(state),
    provider: selectCurrentUserProvider(state)
  };
};

const mapDispatchToProps = (dispatch) => ({
  fetchUserProvider: (userId) => dispatch(fetchUserProvider(userId))
});

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(UserPreview));

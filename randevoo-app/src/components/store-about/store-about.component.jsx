import React from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import { Map, Marker, GoogleApiWrapper } from 'google-maps-react';
import Moment from 'moment';

import mapStyle from '../../data/GoogleMaps.json';
import StoreLogo from '../../assets/store.png';
import PhoneIcon from '../../assets/telephone.png';
import EmailIcon from '../../assets/email.png';

const StoreAboutOverview = (props) => {
  const { history, google, store, storeInfo, user } = props;

  const mapLoaded = (map) => {
    map.setOptions({
      styles: mapStyle
    });
  };

  const previewUser = (userId) => {
    history.push(`/admin/user/${userId}`);
  };

  return (
    <div className='store-about'>
      <div className='managed-by' onClick={() => previewUser(store.userId)}>
        {store != null ? (
          <>
            <span>Managed By</span>
            <div>
              <img src={user.profileUrl} alt='User Profile' />
              <span>{user.username}</span>
            </div>
          </>
        ) : null}
      </div>

      <div className='joined-date'>
        <span>Joined Date</span>
        <span>{Moment.utc(store.createdAt).local().format('MMMM, DD YYYY')}</span>
      </div>

      <div className='contact-info'>
        <span>Contact Info</span>
        <div>
          <div>
            <img src={PhoneIcon} alt='Telephone Icon' />
            <span>{storeInfo.phoneNumber !== '' ? storeInfo.phoneNumber : 'No phone to show!🙄😬'}</span>
          </div>
          <div>
            <img src={EmailIcon} alt='Email Icon' />
            <span>{storeInfo.email !== '' ? storeInfo.email : 'No email to show!🙄😬'}</span>
          </div>
        </div>
      </div>
      <div className='about'>
        <span>About</span>
        <span>{storeInfo.about !== '' ? storeInfo.about : 'No about to show!🙄😬'}</span>
      </div>
      <div className='policy'>
        <span>Policy</span>
        <span>{storeInfo.policy !== '' ? storeInfo.policy : 'No policy to show!🙄😬'}</span>
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
    </div>
  );
};

export default withRouter(
  GoogleApiWrapper(() => {
    const apiKey = process.env.REACT_APP_GOOGLE_MAPS_API;
    return {
      apiKey: apiKey,
      language: 'EN'
    };
  })(connect()(StoreAboutOverview))
);

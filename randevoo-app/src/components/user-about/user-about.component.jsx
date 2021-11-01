import React from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import Moment from 'moment';

import GoogleIcon from '../../assets/google.png';

const UserAbout = (props) => {
  const { user, provider } = props;

  return (
    <div className='user-about'>
      <div className='user-provider'>
        {user != null ? (
          <>
            <span>Provider</span>
            <div>
              <img src={GoogleIcon} alt='Google Provider' />
              <span>{provider.email}</span>
            </div>
          </>
        ) : null}
      </div>

      <div className='joined-date'>
        <span>Joined Date</span>
        <span>{Moment.utc(user.createdAt).local().format('MMMM, DD YYYY')}</span>
      </div>
    </div>
  );
};

export default withRouter(connect()(UserAbout));

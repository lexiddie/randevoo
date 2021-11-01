import React from 'react';
import { connect } from 'react-redux';
import contents from '../../data/Info.json';
import SimpleImageSlider from 'react-simple-image-slider';

import Logo from '../../assets/randevoo-logo.png';

const Home = (props) => {
  const slides = [
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F1.jpg?alt=media&token=49ce2ae8-b84c-4744-b4bf-320408fed565',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F2.jpg?alt=media&token=89c0b10d-9ad1-4ff5-b00c-2c2d1b083a69',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F3.jpg?alt=media&token=e95dd2be-9c92-407d-a98e-0d28d2eb15f2',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F4.jpg?alt=media&token=759ebe85-67a0-45e0-9f6d-7587f08550cd',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F5.jpg?alt=media&token=17933eff-e9a4-4da3-9865-026559fc0827',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F6.jpg?alt=media&token=81821a97-61f8-45de-b2cc-d295e3422a91',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F7.jpg?alt=media&token=7f46f843-2d2e-42d6-a2ab-8992b80afe8e',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F8.jpg?alt=media&token=b03b2acc-d1f2-4cb8-95bb-686da7b47312',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F9.jpg?alt=media&token=d8608261-ecae-4411-9438-14539db83d5c',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F10.jpg?alt=media&token=20230361-d937-4261-bd58-d837cfa33fd6',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F11.jpg?alt=media&token=0e46ba1b-5866-4eb1-8a62-b2ab93f1a926',
    'https://firebasestorage.googleapis.com/v0/b/randevoo-e2dc4.appspot.com/o/randevoo_ui%2F12.jpg?alt=media&token=5a7ce584-ed33-4c57-af67-57a59d9333f5'
  ];

  const images = slides.map((element) => ({ url: element }));

  return (
    <div className='home'>
      <div>
        <div>
          <div className='home-logo'>
            <div>
              <img src={Logo} alt='Logo' />
            </div>
            <div>
              <span>Randevoo</span>
              <span>Online Reservation Platform</span>
            </div>
          </div>
        </div>
        <div>
          <SimpleImageSlider images={images} bgColor={'#FFFFFF'} useGPURender={true} height={800} width={370} navStyle={2} showNavs={true} showBullets={true} />
        </div>
        <div>
          {contents.map((item, index) => (
            <div className='content-data' key={`info-key-${index}`}>
              <h4>{item.label}</h4>
              <p>{item.content}</p>
            </div>
          ))}
        </div>
      </div>
      <div>
        <span>{`© ${new Date().getFullYear()} randevoo. All Right Reserved`}</span>
      </div>
    </div>
  );
};

export default connect()(Home);

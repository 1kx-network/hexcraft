// src/App.js
import React from 'react';
import EthEvents from './components/EthEvents';

const App = () => {
  const divStyle = {
    backgroundImage: 'url("bg.jpeg")',
    backgroundSize: 'cover',
    backgroundPosition: 'center top',
    width: "100%",
    height: "1000px", // Adjust the height as needed
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    color: 'white', // Optional: Text color on top of the image
  };
  return (
    <div >
      <div style={divStyle} >
        <EthEvents />
      </div>
    </div>
  );
};

export default App;

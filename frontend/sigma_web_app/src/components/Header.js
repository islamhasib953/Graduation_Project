// src/components/Header.js
import React, { useState } from "react";
// import { useNavigate } from "react-router-dom";
import logo from "../assets/logo.png"; // Replace with the actual path to your logo
import "../styles/Header.css";

const Header = () => {
  // const navigate = useNavigate();
  const [isDarkMode, setIsDarkMode] = useState(false);

  const toggleDarkMode = () => {
    setIsDarkMode(!isDarkMode);
    document.body.classList.toggle("dark-mode");
  };

  return (
    <header className="header">
      <div className="logo-container">
        <img
          src={logo}
          alt="Sigma Baby Healthcare Logo"
          className="logo-image"
        />
        <span className="logo-text">Sigma | Baby Healthcare</span>
      </div>
      {/* Navigation links (commented out) */}
      {/* <nav className="nav-links">
        <button onClick={() => navigate('/')}>Home</button>
        <button onClick={() => navigate('/history')}>Medical History</button>
        <button onClick={() => navigate('/about')}>About</button>
      </nav> */}
      <div className="dark-mode-toggle">
        <button onClick={toggleDarkMode}>
          {isDarkMode ? "Light Mode" : "Dark Mode"}
        </button>
      </div>
    </header>
  );
};

export default Header;

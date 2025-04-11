// src/pages/SplashScreen.js
import React, { useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import logo from "../assets/logo.png"; // Replace with your actual logo path
import "../styles/SplashScreen.css";

const SplashScreen = () => {
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    // Extract childId from the URL
    const searchParams = new URLSearchParams(location.search);
    const childId =
      searchParams.get("childId") || location.pathname.split("/")[2];

    const timer = setTimeout(() => {
      if (childId) {
        // Redirect to the medical history page after 3 seconds
        navigate(`/history/${childId}/view`);
      } else {
        navigate("/");
      }
    }, 3000); // 3 seconds

    return () => clearTimeout(timer);
  }, [navigate, location]);

  return (
    <div className="splash-screen">
      <img src={logo} alt="Logo" className="splash-logo" />
    </div>
  );
};

export default SplashScreen;

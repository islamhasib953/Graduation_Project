// src/components/SearchBar.js
import React from "react";
import { useNavigate } from "react-router-dom";

const SearchBar = ({ childId }) => {
  const navigate = useNavigate();

  return (
    <div className="search-bar">
      <input type="text" placeholder="Search a diagnosis" />
      <button onClick={() => navigate(`/search/${childId}`)}>Search</button>
    </div>
  );
};

export default SearchBar;

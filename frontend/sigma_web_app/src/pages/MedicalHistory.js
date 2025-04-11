// src/pages/MedicalHistory.js
import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { getHistory } from "../services/api";
import { ClipLoader } from "react-spinners";
import Header from "../components/Header";
import Footer from "../components/Footer";
import "../styles/MedicalHistory.css";

const MedicalHistory = () => {
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [search, setSearch] = useState("");
  const navigate = useNavigate();
  const { childId } = useParams();

  useEffect(() => {
    const fetchHistory = async () => {
      try {
        setLoading(true);
        const response = await getHistory(childId);
        setHistory(response.data || []);
        setLoading(false);
      } catch (error) {
        console.error("Error fetching history:", error);
        setError("Failed to load medical history. Please try again.");
        setHistory([]);
        setLoading(false);
      }
    };
    fetchHistory();
  }, [childId]);

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {
      day: "numeric",
      month: "numeric",
      year: "numeric",
    });
  };

  const handleSearch = (e) => {
    setSearch(e.target.value);
  };

  const filteredHistory = history.filter((record) =>
    record.diagnosis.toLowerCase().includes(search.toLowerCase())
  );

  if (loading)
    return (
      <div className="loader">
        <ClipLoader color="#00B4D8" />
      </div>
    );
  if (error) return <div className="error">{error}</div>;

  return (
    <>
      <Header />
      <div className="medical-history-container">
        <h1 className="page-title">Medical History</h1>
        <div className="search-bar">
          <input
            type="text"
            placeholder="Search a diagnosis"
            value={search}
            onChange={handleSearch}
          />
        </div>

        <div className="history-table">
          <div className="table-header">
            <span>Diagnosis</span>
            <span>Disease</span>
            <span>Treatment</span>
            <span>Date</span>
            <span>Doctor</span>
            <span>Details</span>
          </div>

          {filteredHistory.length > 0 ? (
            filteredHistory.map((record) => (
              <div key={record._id} className="table-row">
                <span>{record.diagnosis || "N/A"}</span>
                <span>{record.disease || "N/A"}</span>
                <span>{record.treatment || "N/A"}</span>
                <span>{record.date ? formatDate(record.date) : "N/A"}</span>
                <span>{record.doctor || "Dr. Islam Hasib"}</span>
                <button
                  className="details-button"
                  onClick={() => navigate(`/history/${childId}/${record._id}`)}
                >
                  Details
                </button>
              </div>
            ))
          ) : (
            <div className="no-records">No medical history found.</div>
          )}
        </div>
      </div>
      <Footer />
    </>
  );
};

export default MedicalHistory;

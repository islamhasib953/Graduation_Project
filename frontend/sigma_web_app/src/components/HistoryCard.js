// src/components/HistoryCard.js
import React from "react";
import { useNavigate } from "react-router-dom";

const HistoryCard = ({ record, childId }) => {
  const navigate = useNavigate();

  return (
    <div className="history-card">
      <div className="record-info">
        <p>
          <strong>Diagnosis:</strong> {record.diagnosis || "N/A"}
        </p>
        <p>
          <strong>Disease:</strong> {record.disease || "N/A"}
        </p>
        <p>
          <strong>Treatment:</strong> {record.treatment || "N/A"}
        </p>
        <p>
          <strong>Date:</strong> {record.date || "N/A"}
        </p>
        <p>
          <strong>Time:</strong> {record.time || "N/A"}
        </p>
        <p>
          <strong>Notes:</strong> {record.notes || "N/A"}
        </p>
        {record.notesImage && (
          <p>
            <strong>Notes Image:</strong> {record.notesImage}
          </p>
        )}
      </div>
      <button onClick={() => navigate(`/history/${childId}/${record._id}`)}>
        Details
      </button>
    </div>
  );
};

export default HistoryCard;

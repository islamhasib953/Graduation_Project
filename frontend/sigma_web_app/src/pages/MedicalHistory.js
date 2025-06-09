// src/pages/MedicalHistory.js
import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { getHistory } from "../services/api";
import { ClipLoader } from "react-spinners";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";
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

  const downloadAllHistoryAsPDF = async () => {
    const doc = new jsPDF();

    // Fetch and convert logo to base64
    let logoBase64 = null;
    try {
      const logoResponse = await fetch(`${process.env.PUBLIC_URL}/logo.png`); // Path to logo in public/
      if (!logoResponse.ok)
        throw new Error(`Failed to fetch logo: ${logoResponse.status}`);
      const logoBlob = await logoResponse.blob();
      const logoReader = new FileReader();
      logoBase64 = await new Promise((resolve) => {
        logoReader.onloadend = () => resolve(logoReader.result);
        logoReader.readAsDataURL(logoBlob);
      });
    } catch (err) {
      console.error("Error loading logo:", err);
    }

    for (let index = 0; index < filteredHistory.length; index++) {
      const record = filteredHistory[index];

      // Add new page for each record
      if (index > 0) doc.addPage();

      // Add Header with Logo
      if (logoBase64) {
        try {
          doc.addImage(logoBase64, "PNG", 20, 10, 30, 30); // Logo on the left
        } catch (err) {
          console.error("Failed to add logo to PDF:", err);
        }
      }
      doc.setFontSize(20);
      doc.setTextColor(0, 119, 182);
      doc.text("Sigma | Baby Healthcare", 55, 25); // Text next to logo

      doc.setFontSize(14);
      doc.setTextColor(3, 4, 94);
      doc.text("Medical History Details", 55, 35);

      // Prepare table data
      const tableData = [
        ["Diagnosis", record.diagnosis || "N/A"],
        ["Disease", record.disease || "N/A"],
        ["Treatment", record.treatment || "N/A"],
        ["Notes", record.notes || "N/A"],
        ["Date", record.date ? formatDate(record.date) : "N/A"],
        ["Doctor", record.doctorName || "N/A"],
      ];

      // Add table using jspdf-autotable
      autoTable(doc, {
        startY: 45,
        head: [["Field", "Details"]],
        body: tableData,
        theme: "striped",
        styles: {
          fontSize: 12,
          cellPadding: 3,
          textColor: [3, 4, 94],
          lineColor: [0, 119, 182],
          lineWidth: 0.2,
          halign: "left",
        },
        headStyles: {
          fillColor: [0, 119, 182],
          textColor: [202, 240, 248],
          fontSize: 13,
          lineWidth: 0.2,
          lineColor: [0, 119, 182],
          halign: "left",
        },
        alternateRowStyles: {
          fillColor: [144, 224, 239],
        },
        bodyStyles: {
          lineWidth: 0.1,
          lineColor: [144, 224, 239],
        },
        columnStyles: {
          0: { cellWidth: 40 },
          1: { cellWidth: 130 },
        },
        margin: { left: 20, right: 20 },
      });

      // Add Notes Images (if exist)
      const notesImages = Array.isArray(record.notesImage)
        ? record.notesImage
        : [record.notesImage].filter(Boolean);
      let finalY = doc.lastAutoTable.finalY || 45;

      if (notesImages.length > 0) {
        try {
          const imageData = await Promise.all(
            notesImages.map(async (imageUrl) => {
              console.log("Fetching image:", imageUrl);
              const response = await fetch(imageUrl, { mode: "cors" });
              if (!response.ok) {
                console.error(
                  `Failed to fetch image: ${imageUrl}, Status: ${response.status}`
                );
                return null; // Skip failed images
              }
              const blob = await response.blob();
              const reader = new FileReader();
              return new Promise((resolve) => {
                reader.onloadend = () => resolve(reader.result);
                reader.readAsDataURL(blob);
              });
            })
          );

          imageData.forEach((base64, index) => {
            if (base64) {
              doc.setFontSize(12);
              doc.setTextColor(3, 4, 94);
              doc.text(`Notes Image ${index + 1}:`, 20, finalY + 10);
              doc.addImage(base64, "JPEG", 20, finalY + 15, 100, 50);
              finalY += 65;
            }
          });
        } catch (err) {
          console.error("Error loading images for PDF:", err);
        }
      }

      // Add Footer
      const pageHeight = doc.internal.pageSize.height;
      doc.setFontSize(10);
      doc.setTextColor(0, 119, 182);
      doc.text(
        `Downloaded on: ${new Date().toLocaleString("en-US", {
          month: "short",
          day: "numeric",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
        })}`,
        20,
        pageHeight - 10
      );
    }

    doc.save("all-medical-history.pdf");
  };

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
        <button
          className="download-all-button"
          onClick={downloadAllHistoryAsPDF}
          style={{
            marginBottom: "20px",
            padding: "10px 20px",
            backgroundColor: "#00B4D8",
            color: "#03045E",
            border: "none",
            borderRadius: "6px",
            cursor: "pointer",
          }}
        >
          Download All History as PDF
        </button>

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
                <span>{record.doctorName || "N/A"}</span>
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

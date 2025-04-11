// src/pages/HistoryDetails.js
import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { getHistoryDetails } from "../services/api";
import { ClipLoader } from "react-spinners";
import Skeleton from "react-loading-skeleton";
import "react-loading-skeleton/dist/skeleton.css";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable"; // Import autoTable explicitly
import Header from "../components/Header";
import Footer from "../components/Footer";
import "../styles/HistoryDetails.css";

const BASE_URL = "http://localhost:3000"; // Replace with your actual server BASE_URL

const HistoryDetails = () => {
  const { childId, historyId } = useParams();
  const [details, setDetails] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchDetails = async () => {
      try {
        setLoading(true);
        const response = await getHistoryDetails(childId, historyId);
        console.log("API Response:", response);
        setDetails(response.data);
        setLoading(false);
      } catch (error) {
        console.error("Error fetching details:", error);
        setError("Failed to load history details. Please try again.");
        setLoading(false);
      }
    };
    fetchDetails();
  }, [childId, historyId]);

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
    });
  };

  const formatTimestamp = () => {
    const now = new Date();
    return now.toLocaleString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const handleShare = async () => {
    const shareData = {
      title: "Medical History Details",
      text: `Diagnosis: ${details.diagnosis || "N/A"}\nDisease: ${
        details.disease || "N/A"
      }\nTreatment: ${details.treatment || "N/A"}\nNotes: ${
        details.notes || "N/A"
      }`,
    };

    try {
      if (navigator.share) {
        await navigator.share(shareData);
      } else {
        navigator.clipboard.writeText(shareData.text);
        alert("Details copied to clipboard!");
      }
    } catch (err) {
      console.error("Error sharing:", err);
      alert("Failed to share. Details copied to clipboard instead.");
      navigator.clipboard.writeText(shareData.text);
    }
  };

  const handleDownloadPDF = async () => {
    const doc = new jsPDF();

    // Add Logo in the Header with Error Handling
    const logoBase64 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."; // Replace with your logo's base64 string
    try {
      if (logoBase64) {
        doc.addImage(logoBase64, "PNG", 20, 10, 30, 30); // Add logo at position (20, 10), size 30x30
      }
    } catch (err) {
      console.error("Failed to load logo for PDF:", err);
      // Continue without the logo
    }

    // Add Header
    doc.setFontSize(20);
    doc.setTextColor(0, 119, 182); // #0077B6 (Deep blue)
    doc.text("Sigma | Baby Healthcare", 55, 20); // Adjusted position to be next to the logo
    doc.setFontSize(14);
    doc.setTextColor(3, 4, 94); // #03045E (Dark blue)
    doc.text("Medical History Details", 55, 30);

    // Prepare table data
    const tableData = [
      ["Diagnosis", details.diagnosis || "N/A"],
      ["Disease", details.disease || "N/A"],
      ["Treatment", details.treatment || "N/A"],
      ["Notes", details.notes || "N/A"],
      ["Date", details.date ? formatDate(details.date) : "N/A"],
      ["Doctor", details.doctor || "Dr. John Doe"],
    ];

    // Add table using jspdf-autotable
    autoTable(doc, {
      startY: 45, // Start the table directly after the header
      head: [["Field", "Details"]], // Table header
      body: tableData, // Table body
      theme: "striped", // Use striped theme for alternating row colors
      styles: {
        fontSize: 12,
        cellPadding: 3,
        textColor: [3, 4, 94], // #03045E for text
        lineColor: [0, 119, 182], // #0077B6 for vertical lines
        lineWidth: 0.2, // Thickness of vertical lines
        halign: "left", // Left alignment for English text
      },
      headStyles: {
        fillColor: [0, 119, 182], // #0077B6 for header background
        textColor: [202, 240, 248], // #CAF0F8 for header text
        fontSize: 13,
        lineWidth: 0.2,
        lineColor: [0, 119, 182], // #0077B6 for borders
        halign: "left", // Left alignment for header
      },
      alternateRowStyles: {
        fillColor: [144, 224, 239], // #90E0EF for alternate rows
      },
      bodyStyles: {
        lineWidth: 0.1, // Thickness of horizontal lines
        lineColor: [144, 224, 239], // #90E0EF for horizontal lines
      },
      columnStyles: {
        0: { cellWidth: 40 }, // Width of the first column (Field): 40mm
        1: { cellWidth: 130 }, // Width of the second column (Details): 130mm
      },
      margin: { left: 20, right: 20 },
    });

    // Add Notes Image (if exists)
    const notesImage = details.notesImage || "";
    if (notesImage) {
      try {
        const imgUrl = `${BASE_URL}/${notesImage}`;
        const response = await fetch(imgUrl);
        const blob = await response.blob();
        const reader = new FileReader();
        reader.readAsDataURL(blob);
        reader.onloadend = () => {
          const base64data = reader.result;
          const finalY = doc.lastAutoTable.finalY || 45; // Get the Y position after the table
          doc.setFontSize(12);
          doc.setTextColor(3, 4, 94); // #03045E
          doc.text("Notes Image:", 20, finalY + 10); // Image title
          doc.addImage(base64data, "JPEG", 20, finalY + 15, 100, 50); // Add image
          // Add Footer
          const pageHeight = doc.internal.pageSize.height;
          doc.setFontSize(10);
          doc.setTextColor(0, 119, 182); // #0077B6
          doc.text(`Downloaded on: ${formatTimestamp()}`, 20, pageHeight - 10);
          doc.save("medical-history.pdf");
        };
      } catch (err) {
        console.error("Failed to load image for PDF:", err);
        // Add Footer and save without the image
        const pageHeight = doc.internal.pageSize.height;
        doc.setFontSize(10);
        doc.setTextColor(0, 119, 182);
        doc.text(`Downloaded on: ${formatTimestamp()}`, 20, pageHeight - 10);
        doc.save("medical-history.pdf");
      }
    } else {
      // Add Footer
      const pageHeight = doc.internal.pageSize.height;
      doc.setFontSize(10);
      doc.setTextColor(0, 119, 182);
      doc.text(`Downloaded on: ${formatTimestamp()}`, 20, pageHeight - 10);
      doc.save("medical-history.pdf");
    }
  };

  const handleEdit = () => {
    navigate(`/history/${childId}/${historyId}/edit`);
  };

  if (loading) {
    return (
      <>
        <Header />
        <div className="history-details-container">
          <Skeleton height={40} width={100} style={{ marginBottom: "20px" }} />
          <Skeleton height={30} width={200} style={{ marginBottom: "10px" }} />
          <Skeleton count={4} height={100} style={{ marginBottom: "20px" }} />
        </div>
        <Footer />
      </>
    );
  }

  if (error) return <div className="error">{error}</div>;
  if (!details) return <div className="error">No details found.</div>;

  const diagnosis = details.diagnosis || "N/A";
  const disease = details.disease || "N/A";
  const treatment = details.treatment || "N/A";
  const notes = details.notes || "N/A";
  const date = details.date || "";
  const time = details.time || "N/A";
  const notesImage = details.notesImage || "";

  return (
    <>
      <Header />
      <div className="history-details-container">
        <div className="action-buttons">
          <button
            className="back-button"
            onClick={() => navigate(`/history/${childId}/view`)}
          >
            Back
          </button>
          <button className="share-button" onClick={handleShare}>
            Share
          </button>
          <button className="download-button" onClick={handleDownloadPDF}>
            Download PDF
          </button>
        </div>

        <h1 className="page-title">History Details</h1>

        <div className="timeline-indicator">
          <div className="timeline-dot"></div>
          <span className="date">
            {date ? formatDate(date) : "N/A"}{" "}
            {time !== "N/A" ? `at ${time}` : ""}
          </span>
          <span className="author">By {details.doctor || "Dr. John Doe"}</span>
        </div>

        <div className="section-card">
          <h3>Diagnosis</h3>
          <p>{diagnosis}</p>
        </div>

        <div className="section-card">
          <h3>Disease</h3>
          <p>{disease}</p>
        </div>

        <div className="section-card">
          <h3>Treatment</h3>
          <p>{treatment}</p>
        </div>

        <div className="section-card">
          <h3>Notes</h3>
          <p>{notes}</p>
        </div>

        {notesImage && (
          <div className="section-card">
            <h3>Notes Image</h3>
            <img
              src={`${BASE_URL}/${notesImage}`}
              alt="Notes Image"
              className="notes-image"
              onError={(e) => console.error("Failed to load image:", e)}
            />
          </div>
        )}
      </div>
      <Footer />
    </>
  );
};

export default HistoryDetails;

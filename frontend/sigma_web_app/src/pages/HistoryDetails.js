import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { getHistoryDetails } from "../services/api";
import Skeleton from "react-loading-skeleton";
import "react-loading-skeleton/dist/skeleton.css";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";
import Header from "../components/Header";
import Footer from "../components/Footer";
import "../styles/HistoryDetails.css";

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
        console.log("Notes Image URL:", response.data.notesImage);
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

    // Fetch and convert logo to base64
    let logoBase64 = null;
    try {
      const logoResponse = await fetch(`${process.env.PUBLIC_URL}/logo.png`);
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
      ["Diagnosis", details.diagnosis || "N/A"],
      ["Disease", details.disease || "N/A"],
      ["Treatment", details.treatment || "N/A"],
      ["Notes", details.notes || "N/A"],
      ["Date", details.date ? formatDate(details.date) : "N/A"],
      ["Doctor", details.doctorName || "N/A"],
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
    const notesImages = Array.isArray(details.notesImage)
      ? details.notesImage
      : [details.notesImage].filter(Boolean);
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
              throw new Error(`Failed to fetch image: ${imageUrl}`);
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
          doc.setFontSize(12);
          doc.setTextColor(3, 4, 94);
          doc.text(`Notes Image ${index + 1}:`, 20, finalY + 10);
          doc.addImage(base64, "JPEG", 20, finalY + 15, 100, 50);
          finalY += 65;
        });

        const pageHeight = doc.internal.pageSize.height;
        doc.setFontSize(10);
        doc.setTextColor(0, 119, 182);
        doc.text(`Downloaded on: ${formatTimestamp()}`, 20, pageHeight - 10);
      } catch (err) {
        console.error("Error loading images for PDF:", err);
      } finally {
        doc.save("medical-history.pdf");
      }
    } else {
      const pageHeight = doc.internal.pageSize.height;
      doc.setFontSize(10);
      doc.setTextColor(0, 119, 182);
      doc.text(`Downloaded on: ${formatTimestamp()}`, 20, pageHeight - 10);
      doc.save("medical-history.pdf");
    }
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
  const notesImages = Array.isArray(details.notesImage)
    ? details.notesImage
    : [details.notesImage].filter(Boolean);

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
          <span className="author">By {details.doctorName || "N/A"}</span>
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

        {notesImages.length > 0 && (
          <div className="section-card">
            <h3>Notes Images</h3>
            <div className="notes-images-container">
              {notesImages.map((image, index) => (
                <img
                  key={index}
                  src={image}
                  alt={`Note ${index + 1}`}
                  className="notes-image"
                  onError={(e) =>
                    console.error(`Image ${index + 1} load error:`, e)
                  }
                />
              ))}
            </div>
          </div>
        )}
      </div>
      <Footer />
    </>
  );
};

export default HistoryDetails;

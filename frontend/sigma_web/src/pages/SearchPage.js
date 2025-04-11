// // src/pages/SearchPage.js
// import React, { useState } from "react";
// import { filterHistory } from "../services/api";
// import HistoryCard from "../components/HistoryCard";
// import "../styles/SearchPage.css";

// const SearchPage = () => {
//   const [searchCriteria, setSearchCriteria] = useState({
//     diagnosis: "",
//     fromDate: "",
//     toDate: "",
//   });
//   const [results, setResults] = useState([]);
//   const childId = "123"; // استبدل هذا بـ childId الفعلي

//   const handleSearch = async () => {
//     try {
//       const data = await filterHistory(childId, searchCriteria);
//       setResults(data);
//     } catch (error) {
//       console.error("Error searching history:", error);
//     }
//   };

//   return (
//     <div className="search-page">
//       <h2>Search Medical History</h2>
//       <div className="search-form">
//         <input
//           type="text"
//           placeholder="Search by diagnosis"
//           value={searchCriteria.diagnosis}
//           onChange={(e) =>
//             setSearchCriteria({ ...searchCriteria, diagnosis: e.target.value })
//           }
//         />
//         <input
//           type="date"
//           value={searchCriteria.fromDate}
//           onChange={(e) =>
//             setSearchCriteria({ ...searchCriteria, fromDate: e.target.value })
//           }
//         />
//         <input
//           type="date"
//           value={searchCriteria.toDate}
//           onChange={(e) =>
//             setSearchCriteria({ ...searchCriteria, toDate: e.target.value })
//           }
//         />
//         <button onClick={handleSearch}>Apply</button>
//         <button
//           onClick={() =>
//             setSearchCriteria({ diagnosis: "", fromDate: "", toDate: "" })
//           }
//         >
//           Cancel
//         </button>
//       </div>
//       <div className="search-results">
//         {results.map((record) => (
//           <HistoryCard key={record.id} record={record} />
//         ))}
//       </div>
//     </div>
//   );
// };

// export default SearchPage;



// src/pages/SearchPage.js
import React, { useState } from 'react';
import { useParams } from 'react-router-dom';
import { filterHistory } from '../services/api';
import HistoryCard from '../components/HistoryCard';
import '../styles/SearchPage.css';

const SearchPage = () => {
  const { childId } = useParams(); // استخراج childId من الـ URL
  const [searchCriteria, setSearchCriteria] = useState({ diagnosis: '', fromDate: '', toDate: '' });
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false); // إضافة حالة تحميل
  const [error, setError] = useState(null); // إضافة حالة للأخطاء

  const handleSearch = async () => {
    try {
      setLoading(true);
      const data = await filterHistory(childId, searchCriteria);
      setResults(data);
      setLoading(false);
    } catch (error) {
      console.error('Error searching history:', error);
      setError('Failed to search history. Please try again.');
      setLoading(false);
    }
  };

  return (
    <div className="search-page">
      <h2>Search Medical History</h2>
      <div className="search-form">
        <input
          type="text"
          placeholder="Search by diagnosis"
          value={searchCriteria.diagnosis}
          onChange={(e) => setSearchCriteria({ ...searchCriteria, diagnosis: e.target.value })}
        />
        <input
          type="date"
          value={searchCriteria.fromDate}
          onChange={(e) => setSearchCriteria({ ...searchCriteria, fromDate: e.target.value })}
        />
        <input
          type="date"
          value={searchCriteria.toDate}
          onChange={(e) => setSearchCriteria({ ...searchCriteria, toDate: e.target.value })}
        />
        <button onClick={handleSearch}>Apply</button>
        <button onClick={() => setSearchCriteria({ diagnosis: '', fromDate: '', toDate: '' })}>
          Cancel
        </button>
      </div>
      {loading && <div>Loading...</div>}
      {error && <div>{error}</div>}
      <div className="search-results">
        {results.map((record) => (
          <HistoryCard key={record.id} record={record} childId={childId} />
        ))}
      </div>
    </div>
  );
};

export default SearchPage;
// // src/App.js
import React from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";
import SplashScreen from "./pages/SplashScreen";
import MedicalHistory from "./pages/MedicalHistory";
import HistoryDetails from "./pages/HistoryDetails";
import SearchPage from "./pages/SearchPage";
import "./App.css";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<SplashScreen />} />
        {/* مسار جديد للتعامل مع الرابط القادم من بطاقة NFC */}
        <Route path="/history/:childId" element={<SplashScreen />} />
        <Route path="/history/:childId/view" element={<MedicalHistory />} />
        <Route
          path="/history/:childId/:historyId"
          element={<HistoryDetails />}
        />
        <Route path="/search/:childId" element={<SearchPage />} />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </Router>
  );
}

export default App;


// src/App.js
// import React from 'react';
// import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
// import MedicalHistory from './pages/MedicalHistory';
// import HistoryDetails from './pages/HistoryDetails';

// function App() {
//   return (
//     <Router>
//       <Routes>
//         <Route path="/history" element={<MedicalHistory />} />
//         <Route path="/history/:childId" element={<MedicalHistory />} />
//         <Route path="/history/:childId/:historyId" element={<HistoryDetails />} />
//       </Routes>
//     </Router>
//   );
// }

// export default App;
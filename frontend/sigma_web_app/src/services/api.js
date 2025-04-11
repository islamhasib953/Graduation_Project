// src/services/api.js
import axios from "axios";

const API_BASE_URL = "https://sigma-three-ruby.vercel.app"; // استبدل هذا بـ URL الـ API الخاص بك

// export const getHistory = async (childId) => {
//   const response = await axios.get(`${API_BASE_URL}/api/history/${childId}`);
//   return response.data;
// };

export const getHistory = async (childId) => {
  try {
    const response = await axios.get(`${API_BASE_URL}/api/history/${childId}`);
    return response.data; // { status: "success", data: [...] }
  } catch (error) {
    console.error("Error in getHistory:", error);
    return { data: [] }; // إرجاع مصفوفة فارغة في حالة الخطأ
  }
};

export const getHistoryDetails = async (childId, historyId) => {
  const response = await axios.get(
    `${API_BASE_URL}/api/history/${childId}/${historyId}`
  );
  return response.data;
};

export const filterHistory = async (childId, criteria) => {
  const response = await axios.get(
    `${API_BASE_URL}/api/history/filter/${childId}`,
    {
      params: criteria,
    }
  );
  return response.data;
};

import axios from 'axios';

// Change this to match your backend port if needed
const API_URL = 'http://localhost:5000/api/v1';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add a request interceptor to attach the token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('adminToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export const adminLogin = async (id, password) => {
  const response = await api.post('/admin/login', { id, password });
  if (response.data.success && response.data.token) {
    localStorage.setItem('adminToken', response.data.token);
  }
  return response.data;
};

export const logout = () => {
  localStorage.removeItem('adminToken');
};

export const getFarmers = async (page = 1, limit = 50) => {
  const response = await api.get(`/admin/farmers?page=${page}&limit=${limit}`);
  return response.data;
};

export const deleteFarmer = async (id) => {
  const response = await api.delete(`/admin/farmers/${id}`);
  return response.data;
};

export const sendBroadcast = async (data) => {
  // data: { title, message, title_kn, message_kn, type }
  const response = await api.post('/notifications/send', data);
  return response.data;
};

export default api;

import axios from "axios";

// Get the base URL from environment or use window.location.origin in the browser
// Server-side: use internal URL (app is running on localhost inside the same pod)
// Client-side (browser): use the actual public origin
const baseURL =
  typeof window !== "undefined"
    ? "/api"
    : "http://qbshop-service/api";
// Safely get token from cookie - works both on server and client
const getTokenFromCookie = (): string | null => {
  if (typeof document === 'undefined') {
    return null; // Server-side: no cookies accessible this way
  }
  const cookies = document.cookie.split(';');
  const tokenCookie = cookies.find(cookie => cookie.trim().startsWith('token='));
  return tokenCookie ? decodeURIComponent(tokenCookie.split('=')[1].trim()) : null;
};

// Add request interceptor to include token
export const axiosInstance = axios.create({
  baseURL,
  headers: {
    "Content-Type": "application/json",
  },
  withCredentials: true, // Important for sending cookies
});

// Add request interceptor to include token from cookie
axiosInstance.interceptors.request.use(
  async (config) => {
    const token = getTokenFromCookie();

    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }

    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

const fetchData = {
  get: async (url: string, params = {}) => {
    try {
      const token = getTokenFromCookie();

      const config = {
        params,
        headers: token ? { 'Authorization': `Bearer ${token}` } : {}
      };

      console.log('Making GET request with config:', { url, config });
      const response = await axiosInstance.get(url, config);
      return response;
    } catch (error) {
      console.error("Error fetching data:", error);
      throw error;
    }
  },
  post: async (url: string, data = {}) => {
    try {
      const token = getTokenFromCookie();

      const config = {
        headers: token ? { 'Authorization': `Bearer ${token}` } : {}
      };

      console.log('Making POST request with config:', { url, data, config });
      const response = await axiosInstance.post(url, data, config);
      return response;
    } catch (error) {
      console.error("Error posting data:", error);
      throw error;
    }
  },
};

export default fetchData;

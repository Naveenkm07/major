import React, { useState, useEffect } from 'react';
import { Users, Activity, BellRing } from 'lucide-react';
import { getFarmers } from '../services/api';

const Dashboard = () => {
  const [stats, setStats] = useState({ totalFarmers: 0, activeFarmers: 0 });
  const [recentFarmers, setRecentFarmers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      const res = await getFarmers(1, 5); // Fetch first 5 for recent
      if (res.success) {
        setStats({
          totalFarmers: res.pagination.total || 0,
          activeFarmers: res.pagination.total || 0, // Mocking active for now
        });
        setRecentFarmers(res.data || []);
      }
    } catch (error) {
      console.error("Failed to fetch dashboard data", error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ position: 'relative' }}>
      {loading && (
        <div className="loader-overlay">
          <div className="spinner"></div>
        </div>
      )}
      
      <div className="page-header">
        <h1 className="page-title">Dashboard Overview</h1>
        <p className="page-subtitle">Welcome back, Admin. Here's what's happening today.</p>
      </div>

      <div className="stat-grid">
        <div className="stat-card glass">
          <div className="stat-icon blue">
            <Users />
          </div>
          <div className="stat-details">
            <h3>Total Farmers</h3>
            <p>{stats.totalFarmers}</p>
          </div>
        </div>
        <div className="stat-card glass">
          <div className="stat-icon green">
            <Activity />
          </div>
          <div className="stat-details">
            <h3>Active Farmers</h3>
            <p>{stats.activeFarmers}</p>
          </div>
        </div>
        <div className="stat-card glass">
          <div className="stat-icon purple">
            <BellRing />
          </div>
          <div className="stat-details">
            <h3>Broadcasts Sent</h3>
            <p>--</p>
          </div>
        </div>
      </div>

      <div className="glass" style={{ padding: '24px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <h2 style={{ fontSize: '1.25rem' }}>Recently Registered Farmers</h2>
        </div>
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Phone</th>
                <th>Language</th>
                <th>Joined</th>
              </tr>
            </thead>
            <tbody>
              {recentFarmers.map(farmer => (
                <tr key={farmer._id}>
                  <td>{farmer.name || 'N/A'}</td>
                  <td>{farmer.phone}</td>
                  <td><span className="badge badge-active">{farmer.languagePreference || 'en'}</span></td>
                  <td>{new Date(farmer.createdAt).toLocaleDateString()}</td>
                </tr>
              ))}
              {recentFarmers.length === 0 && !loading && (
                <tr>
                  <td colSpan="4" style={{ textAlign: 'center', color: '#64748b' }}>No farmers found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;

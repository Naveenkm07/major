import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, LogOut, Edit2, Trash2, Search, MapPin, Phone } from 'lucide-react';

export default function Dashboard() {
  const [farmers, setFarmers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  
  const navigate = useNavigate();
  const token = localStorage.getItem('adminToken');

  useEffect(() => {
    fetchFarmers();
  }, []);

  const fetchFarmers = async () => {
    try {
      const res = await fetch('https://krushikadhara-backend.onrender.com/api/v1/admin/farmers', {
        headers: { Authorization: `Bearer ${token}` }
      });
      const data = await res.json();
      if (data.success) {
        setFarmers(data.data);
      } else {
        if (res.status === 401 || res.status === 403) handleLogout();
        setError(data.error);
      }
    } catch (err) {
      setError('Failed to fetch data');
    } finally {
      setLoading(false);
    }
  };

  const deleteFarmer = async (id, name) => {
    if (!window.confirm(`Are you sure you want to completely delete ${name}?`)) return;
    try {
      const res = await fetch(`https://krushikadhara-backend.onrender.com/api/v1/admin/farmers/${id}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.ok) {
        setFarmers(farmers.filter(f => f._id !== id));
      } else {
        alert('Failed to delete');
      }
    } catch (err) {
      alert('Error deleting');
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('adminToken');
    navigate('/login');
  };

  const filteredFarmers = farmers.filter(f => 
    (f.name?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
    (f.phoneNumber || '').includes(searchTerm) ||
    (f.district?.toLowerCase() || '').includes(searchTerm.toLowerCase())
  );

  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      {/* Sidebar */}
      <div className="glass-panel" style={{ width: '280px', margin: '20px', display: 'flex', flexDirection: 'column', padding: '24px' }}>
        <h2 style={{ color: 'var(--primary-color)', marginBottom: '40px', fontSize: '1.5rem' }}>KrushikaDhara<br/><span style={{color: 'var(--text-main)'}}>Admin</span></h2>
        
        <nav style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <button className="btn" style={{ background: 'rgba(51, 65, 85, 0.4)', justifyContent: 'flex-start' }}>
            <Users size={20} /> Farmer Database
          </button>
        </nav>

        <button onClick={handleLogout} className="btn btn-danger" style={{ width: '100%' }}>
          <LogOut size={18} /> Logout
        </button>
      </div>

      {/* Main Content */}
      <div style={{ flex: 1, padding: '20px 20px 20px 0', display: 'flex', flexDirection: 'column' }}>
        
        <header className="glass-panel" style={{ padding: '20px', marginBottom: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h1 style={{ fontSize: '1.5rem', marginBottom: '4px' }}>Farmer Database</h1>
            <p>Manage all registered farmers</p>
          </div>
          
          <div style={{ position: 'relative', width: '300px' }}>
            <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
            <input 
              type="text" 
              placeholder="Search by name, phone, district..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{ paddingLeft: '40px' }}
            />
          </div>
        </header>

        <main className="glass-panel" style={{ flex: 1, padding: '24px', display: 'flex', flexDirection: 'column' }}>
          {error && <div style={{ color: 'var(--danger-color)', marginBottom: '16px' }}>{error}</div>}
          
          <div className="table-container" style={{ flex: 1 }}>
            {loading ? (
              <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-muted)' }}>Loading records...</div>
            ) : (
              <table>
                <thead>
                  <tr>
                    <th>Farmer Name</th>
                    <th>Contact</th>
                    <th>Location</th>
                    <th>Farm Size</th>
                    <th>Crops</th>
                    <th style={{ textAlign: 'right' }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredFarmers.length === 0 ? (
                    <tr><td colSpan="6" style={{ textAlign: 'center', padding: '40px' }}>No records found.</td></tr>
                  ) : (
                    filteredFarmers.map(farmer => (
                      <tr key={farmer._id}>
                        <td>
                          <div style={{ fontWeight: '500' }}>{farmer.name || 'N/A'}</div>
                          <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>{farmer._id}</div>
                        </td>
                        <td>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}><Phone size={14}/> {farmer.phoneNumber || 'N/A'}</div>
                          {farmer.email && <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>{farmer.email}</div>}
                        </td>
                        <td>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                            <MapPin size={14}/> 
                            {farmer.district ? `${farmer.district}, ${farmer.state}` : 'N/A'}
                          </div>
                        </td>
                        <td>{farmer.farmSize ? `${farmer.farmSize} Acres` : 'N/A'}</td>
                        <td>
                          <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
                            {(farmer.cropTypes && farmer.cropTypes.length > 0) ? farmer.cropTypes.map((c, i) => (
                              <span key={i} className="badge badge-success">{c}</span>
                            )) : <span className="badge badge-warning">None</span>}
                          </div>
                        </td>
                        <td style={{ textAlign: 'right' }}>
                          <button className="btn-icon" title="Delete" onClick={() => deleteFarmer(farmer._id, farmer.name)}>
                            <Trash2 size={18} color="var(--danger-color)" />
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            )}
          </div>
        </main>
      </div>
    </div>
  );
}

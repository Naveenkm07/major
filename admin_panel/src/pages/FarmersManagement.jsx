import React, { useState, useEffect } from 'react';
import { getFarmers, deleteFarmer } from '../services/api';
import { Trash2, Search } from 'lucide-react';

const FarmersManagement = () => {
  const [farmers, setFarmers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchFarmers(page);
  }, [page]);

  const fetchFarmers = async (pageNumber) => {
    try {
      setLoading(true);
      const res = await getFarmers(pageNumber, 20);
      if (res.success) {
        setFarmers(res.data);
        setTotalPages(Math.ceil(res.pagination.total / 20) || 1);
      }
    } catch (error) {
      console.error("Failed to fetch farmers", error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this farmer?')) {
      try {
        const res = await deleteFarmer(id);
        if (res.success) {
          setFarmers(farmers.filter(f => f._id !== id));
        }
      } catch (error) {
        alert("Failed to delete farmer.");
      }
    }
  };

  const filteredFarmers = farmers.filter(farmer => 
    farmer.phone.includes(searchTerm) || (farmer.name && farmer.name.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  return (
    <div style={{ position: 'relative' }}>
      {loading && (
        <div className="loader-overlay">
          <div className="spinner"></div>
        </div>
      )}
      
      <div className="page-header">
        <h1 className="page-title">Farmers Management</h1>
        <p className="page-subtitle">View and manage all registered farmers on the platform.</p>
      </div>

      <div className="glass" style={{ padding: '24px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
          <div className="input-group" style={{ margin: 0, width: '300px', flexDirection: 'row', alignItems: 'center' }}>
            <Search size={18} style={{ position: 'absolute', marginLeft: '12px', color: '#64748b' }} />
            <input 
              type="text" 
              placeholder="Search by name or phone..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{ paddingLeft: '40px', width: '100%', margin: 0 }}
            />
          </div>
        </div>

        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Profile</th>
                <th>Contact</th>
                <th>Location</th>
                <th>Farm Details</th>
                <th>Crops</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredFarmers.map(farmer => (
                <tr key={farmer._id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <img 
                        src={(farmer.avatar && farmer.avatar.startsWith('http')) ? farmer.avatar : 'https://ui-avatars.com/api/?name=' + (farmer.name || 'F') + '&background=10b981&color=fff'} 
                        alt="Avatar" 
                        style={{ width: '40px', height: '40px', borderRadius: '50%', objectFit: 'cover' }} 
                      />
                      <div>
                        <div style={{ fontWeight: '500' }}>{farmer.name || 'N/A'}</div>
                        <div style={{ fontSize: '0.85rem', color: '#64748b' }}>{farmer.languagePreference || 'en'}</div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>{farmer.phone || farmer.phoneNumber || 'N/A'}</div>
                    {farmer.email && <div style={{ fontSize: '0.85rem', color: '#64748b' }}>{farmer.email}</div>}
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      {farmer.district ? `${farmer.district}, ${farmer.state}` : (farmer.location?.coordinates?.length === 2 ? `${farmer.location.coordinates[1].toFixed(4)}, ${farmer.location.coordinates[0].toFixed(4)}` : 'N/A')}
                    </div>
                  </td>
                  <td>
                    <div>{farmer.farmSize ? `${farmer.farmSize} Acres` : 'Size: N/A'}</div>
                    <div style={{ fontSize: '0.85rem', color: '#64748b' }}>Soil: {farmer.soilType || 'N/A'}</div>
                    <div style={{ fontSize: '0.85rem', color: '#64748b' }}>Irrig: {farmer.irrigationType || 'N/A'}</div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
                      {(farmer.cropTypes && farmer.cropTypes.length > 0) ? farmer.cropTypes.map((c, i) => (
                        <span key={i} className="badge badge-active">{c}</span>
                      )) : <span className="badge badge-inactive">None</span>}
                    </div>
                  </td>
                  <td>
                    <button 
                      className="btn btn-danger" 
                      style={{ padding: '6px 10px', fontSize: '0.8rem' }}
                      onClick={() => handleDelete(farmer._id)}
                    >
                      <Trash2 size={16} /> Delete
                    </button>
                  </td>
                </tr>
              ))}
              {filteredFarmers.length === 0 && !loading && (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', color: '#64748b', padding: '32px' }}>
                    No farmers found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Simple Pagination */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '20px' }}>
          <button 
            className="btn" 
            onClick={() => setPage(p => Math.max(1, p - 1))}
            disabled={page === 1}
            style={{ background: 'white', border: '1px solid #e2e8f0' }}
          >
            Previous
          </button>
          <span style={{ fontSize: '0.875rem', color: '#64748b' }}>Page {page} of {totalPages}</span>
          <button 
            className="btn" 
            onClick={() => setPage(p => Math.min(totalPages, p + 1))}
            disabled={page === totalPages}
            style={{ background: 'white', border: '1px solid #e2e8f0' }}
          >
            Next
          </button>
        </div>
      </div>
    </div>
  );
};

export default FarmersManagement;

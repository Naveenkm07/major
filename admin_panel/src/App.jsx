import React from 'react';
import { Routes, Route, Navigate, useNavigate, useLocation, Link } from 'react-router-dom';
import { LayoutDashboard, Users, BellRing, LogOut, Sprout } from 'lucide-react';
import { logout } from './services/api';

// Pages
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import FarmersManagement from './pages/FarmersManagement';
import BroadcastNotifications from './pages/BroadcastNotifications';

const ProtectedRoute = ({ children }) => {
  const token = localStorage.getItem('adminToken');
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  return children;
};

const AppLayout = ({ children }) => {
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const navItems = [
    { path: '/', label: 'Dashboard', icon: LayoutDashboard },
    { path: '/farmers', label: 'Farmers', icon: Users },
    { path: '/broadcast', label: 'Broadcasts', icon: BellRing },
  ];

  return (
    <div className="app-container">
      <aside className="sidebar glass">
        <div className="logo">
          <Sprout size={28} />
          KrushikaDhara
        </div>
        <nav className="sidebar-nav">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`nav-link ${isActive ? 'active' : ''}`}
              >
                <Icon size={20} />
                {item.label}
              </Link>
            );
          })}
        </nav>
        <button className="btn btn-danger" onClick={handleLogout} style={{ marginTop: 'auto', width: '100%' }}>
          <LogOut size={18} /> Logout
        </button>
      </aside>
      <main className="main-content">
        {children}
      </main>
    </div>
  );
};

function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      
      <Route path="/" element={<ProtectedRoute><AppLayout><Dashboard /></AppLayout></ProtectedRoute>} />
      <Route path="/farmers" element={<ProtectedRoute><AppLayout><FarmersManagement /></AppLayout></ProtectedRoute>} />
      <Route path="/broadcast" element={<ProtectedRoute><AppLayout><BroadcastNotifications /></AppLayout></ProtectedRoute>} />
      
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default App;

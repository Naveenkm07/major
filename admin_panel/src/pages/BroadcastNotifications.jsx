import React, { useState } from 'react';
import { Send, AlertCircle, CheckCircle2 } from 'lucide-react';
import { sendBroadcast } from '../services/api';

const BroadcastNotifications = () => {
  const [formData, setFormData] = useState({
    title: '',
    message: '',
    title_kn: '',
    message_kn: '',
  });
  
  const [loading, setLoading] = useState(false);
  const [status, setStatus] = useState({ type: '', msg: '' });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setStatus({ type: '', msg: '' });
    
    try {
      // type: 'broadcast' is required by the backend to send to topic 'all_farmers'
      const res = await sendBroadcast({ ...formData, type: 'broadcast' });
      if (res.success) {
        setStatus({ type: 'success', msg: 'Broadcast notification sent successfully!' });
        setFormData({ title: '', message: '', title_kn: '', message_kn: '' });
      } else {
        setStatus({ type: 'error', msg: res.message || 'Failed to send broadcast.' });
      }
    } catch (error) {
      setStatus({ type: 'error', msg: error.response?.data?.message || 'An error occurred while sending.' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Broadcast Notifications</h1>
        <p className="page-subtitle">Send alerts, scheme updates, and weather warnings to all registered farmers.</p>
      </div>

      <div className="grid-2">
        <div className="glass" style={{ padding: '32px' }}>
          <h2 style={{ fontSize: '1.25rem', marginBottom: '24px' }}>Compose Message</h2>
          
          {status.msg && (
            <div className={status.type === 'success' ? 'success-msg' : 'error-msg'} style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              {status.type === 'success' ? <CheckCircle2 size={18} /> : <AlertCircle size={18} />}
              {status.msg}
            </div>
          )}

          <form onSubmit={handleSubmit}>
            <div className="input-group">
              <label>Title (English)</label>
              <input 
                type="text" 
                name="title"
                placeholder="e.g. Heavy Rain Alert"
                value={formData.title}
                onChange={handleChange}
                required
              />
            </div>
            <div className="input-group">
              <label>Message (English)</label>
              <textarea 
                name="message"
                placeholder="e.g. Heavy rains expected in coastal areas..."
                rows="3"
                value={formData.message}
                onChange={handleChange}
                required
              ></textarea>
            </div>
            
            <hr style={{ border: 0, borderTop: '1px solid #e2e8f0', margin: '24px 0' }} />

            <div className="input-group">
              <label>Title (Kannada)</label>
              <input 
                type="text" 
                name="title_kn"
                placeholder="ಉದಾ. ಭಾರಿ ಮಳೆ ಎಚ್ಚರಿಕೆ"
                value={formData.title_kn}
                onChange={handleChange}
              />
            </div>
            <div className="input-group">
              <label>Message (Kannada)</label>
              <textarea 
                name="message_kn"
                placeholder="ಉದಾ. ಕರಾವಳಿ ಪ್ರದೇಶಗಳಲ್ಲಿ ಭಾರಿ ಮಳೆ ನಿರೀಕ್ಷಿಸಲಾಗಿದೆ..."
                rows="3"
                value={formData.message_kn}
                onChange={handleChange}
              ></textarea>
            </div>

            <button type="submit" className="btn btn-primary" style={{ width: '100%', marginTop: '16px' }} disabled={loading}>
              {loading ? 'Sending Broadcast...' : <><Send size={18} /> Send to All Farmers</>}
            </button>
          </form>
        </div>

        <div>
          <div className="glass" style={{ padding: '32px', marginBottom: '24px', background: 'rgba(59, 130, 246, 0.05)' }}>
             <h3 style={{ fontSize: '1.1rem', color: 'var(--secondary)', marginBottom: '12px' }}>
               <AlertCircle size={18} style={{ display: 'inline', verticalAlign: 'text-bottom', marginRight: '8px' }} />
               Guidelines
             </h3>
             <ul style={{ paddingLeft: '20px', color: '#475569', fontSize: '0.95rem', lineHeight: '1.6' }}>
               <li>Broadcasts are sent to <strong>every registered user</strong> via push notifications.</li>
               <li>Providing the Kannada translation is highly recommended, as many farmers use Kannada as their primary language.</li>
               <li>If Kannada fields are left blank, the English text will be shown to everyone.</li>
               <li>Use short, clear titles for maximum impact.</li>
             </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default BroadcastNotifications;

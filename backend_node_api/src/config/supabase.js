const { createClient } = require('@supabase/supabase-js');
const config = require('./index');
const logger = require('../utils/logger');

let supabase = null;

if (config.supabase.url && config.supabase.serviceRoleKey) {
    supabase = createClient(config.supabase.url, config.supabase.serviceRoleKey, {
        auth: {
            autoRefreshToken: false,
            persistSession: false
        }
    });
    logger.info('Supabase Client initialized with Service Role Key');
} else {
    logger.warn('Supabase URL or Service Role Key missing. Supabase functionality will be disabled.');
}

module.exports = supabase;

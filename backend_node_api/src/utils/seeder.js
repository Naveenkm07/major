/**
 * KrushikaDhara – Database Seeder
 *
 * Populates the database with example documents for all 10 collections.
 * Usage: node src/utils/seeder.js
 *
 * Flags:
 *   --destroy   Wipe all data before seeding
 */

const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '..', '..', '.env') });

const {
    Farmer,
    PestScan,
    MarketPrice,
    CropCalendar,
    GovernmentScheme,
    CommunityPost,
    Comment,
    Notification,
    FarmerLocation,
    ChatHistory,
} = require('../models');

// ─── Example: Farmers ────────────────────────────────
const farmers = [
    {
        name: 'Rajesh Kumar',
        phoneNumber: '9876543210',
        email: 'rajesh@example.com',
        passwordHash: 'password123',
        village: 'Khandwa',
        district: 'East Nimar',
        state: 'Madhya Pradesh',
        farmSize: 5.5,
        cropTypes: ['wheat', 'soybean'],
        preferredLanguage: 'hi',
    },
    {
        name: 'Lakshmi Devi',
        phoneNumber: '9123456789',
        email: 'lakshmi@example.com',
        passwordHash: 'password123',
        village: 'Raichur',
        district: 'Raichur',
        state: 'Karnataka',
        farmSize: 3.0,
        cropTypes: ['rice', 'cotton'],
        preferredLanguage: 'kn',
    },
    {
        name: 'Suresh Patel',
        phoneNumber: '9988776655',
        email: 'suresh@example.com',
        passwordHash: 'password123',
        village: 'Anand',
        district: 'Anand',
        state: 'Gujarat',
        farmSize: 8.0,
        cropTypes: ['groundnut', 'cotton', 'mustard'],
        preferredLanguage: 'gu',
    },
];

// ─── Example: PestScans ──────────────────────────────
const createPestScans = (farmerIds) => [
    {
        farmerId: farmerIds[0],
        imageUrl: 'https://s3.ap-south-1.amazonaws.com/krushikadhara/scans/wheat_rust_001.jpg',
        cropType: 'wheat',
        diseaseDetected: 'rust',
        confidenceScore: 0.92,
        treatmentSuggestion: 'Apply Propiconazole 25% EC @ 1ml/litre of water. Spray twice at 15-day intervals.',
        scanDate: new Date('2026-02-15'),
    },
    {
        farmerId: farmerIds[1],
        imageUrl: 'https://s3.ap-south-1.amazonaws.com/krushikadhara/scans/rice_blast_002.jpg',
        cropType: 'rice',
        diseaseDetected: 'blast',
        confidenceScore: 0.87,
        treatmentSuggestion: 'Spray Tricyclazole 75% WP @ 0.6g/litre. Ensure proper spacing between plants.',
        scanDate: new Date('2026-03-01'),
    },
    {
        farmerId: farmerIds[2],
        imageUrl: 'https://s3.ap-south-1.amazonaws.com/krushikadhara/scans/groundnut_healthy_003.jpg',
        cropType: 'groundnut',
        diseaseDetected: 'healthy',
        confidenceScore: 0.95,
        treatmentSuggestion: 'Plant is healthy. Continue regular monitoring and balanced fertilization.',
        scanDate: new Date('2026-03-10'),
    },
];

// ─── Example: MarketPrices ───────────────────────────
const marketPrices = [
    {
        cropName: 'Wheat',
        marketName: 'Indore Mandi',
        pricePerKg: 25.5,
        trend: 'rising',
        location: { state: 'Madhya Pradesh', district: 'Indore', coordinates: { type: 'Point', coordinates: [75.8577, 22.7196] } },
        lastUpdated: new Date(),
    },
    {
        cropName: 'Rice',
        marketName: 'Raichur APMC',
        pricePerKg: 32.0,
        trend: 'stable',
        location: { state: 'Karnataka', district: 'Raichur', coordinates: { type: 'Point', coordinates: [77.3551, 16.2076] } },
        lastUpdated: new Date(),
    },
    {
        cropName: 'Cotton',
        marketName: 'Rajkot Market',
        pricePerKg: 63.75,
        trend: 'falling',
        location: { state: 'Gujarat', district: 'Rajkot', coordinates: { type: 'Point', coordinates: [70.8022, 22.3039] } },
        lastUpdated: new Date(),
    },
    {
        cropName: 'Soybean',
        marketName: 'Khandwa Mandi',
        pricePerKg: 45.0,
        trend: 'rising',
        location: { state: 'Madhya Pradesh', district: 'East Nimar', coordinates: { type: 'Point', coordinates: [76.3526, 21.8262] } },
        lastUpdated: new Date(),
    },
];

// ─── Example: CropCalendar ───────────────────────────
const cropCalendar = [
    { cropName: 'Wheat', stage: 'land_preparation', recommendedAction: 'Deep ploughing and levelling', fertilizerAdvice: 'Apply FYM @ 10 tonnes/hectare', irrigationAdvice: 'Pre-sowing irrigation (palewa)', month: 10, season: 'rabi' },
    { cropName: 'Wheat', stage: 'sowing', recommendedAction: 'Sow seeds at 5cm depth, row spacing 22.5cm', fertilizerAdvice: 'Basal dose: DAP @ 130kg/ha + MOP @ 55kg/ha', irrigationAdvice: 'Light irrigation after sowing if soil dry', month: 11, season: 'rabi' },
    { cropName: 'Wheat', stage: 'vegetative', recommendedAction: 'First weeding at 30 DAS', fertilizerAdvice: 'Top dress urea @ 65kg/ha at first irrigation', irrigationAdvice: 'First irrigation at 21 DAS (CRI stage)', month: 12, season: 'rabi' },
    { cropName: 'Wheat', stage: 'flowering', recommendedAction: 'Monitor for rust and aphid attack', fertilizerAdvice: 'Foliar spray of Zinc Sulphate 0.5%', irrigationAdvice: 'Irrigation at flowering stage', month: 2, season: 'rabi' },
    { cropName: 'Wheat', stage: 'harvesting', recommendedAction: 'Harvest when grain moisture is 12-14%', fertilizerAdvice: 'No fertilizer required', irrigationAdvice: 'Stop irrigation 15 days before harvest', month: 4, season: 'rabi' },
    { cropName: 'Rice', stage: 'land_preparation', recommendedAction: 'Puddling and levelling of field', fertilizerAdvice: 'Apply FYM or compost @ 12.5 tonnes/ha', irrigationAdvice: 'Maintain standing water 5cm during puddling', month: 6, season: 'kharif' },
    { cropName: 'Rice', stage: 'sowing', recommendedAction: 'Transplant 25-day old seedlings', fertilizerAdvice: 'Basal: NPK @ 50:30:30 kg/ha', irrigationAdvice: 'Maintain 2-3cm water after transplanting', month: 7, season: 'kharif' },
    { cropName: 'Rice', stage: 'harvesting', recommendedAction: 'Harvest when 80% grains are golden', fertilizerAdvice: 'No application needed', irrigationAdvice: 'Drain field 10 days before harvest', month: 10, season: 'kharif' },
];

// ─── Example: GovernmentSchemes ──────────────────────
const governmentSchemes = [
    {
        schemeName: 'PM-KISAN',
        description: 'Pradhan Mantri Kisan Samman Nidhi provides ₹6,000 per year in three installments to small and marginal farmer families.',
        eligibility: ['Land-holding farmer family', 'Family holding cultivable land up to 2 hectares', 'Valid Aadhaar card'],
        benefits: ['₹6,000 per year in 3 installments of ₹2,000', 'Direct bank transfer', 'No middlemen involved'],
        applicationLink: 'https://pmkisan.gov.in',
        ministry: 'Ministry of Agriculture & Farmers Welfare',
        schemeType: 'central',
    },
    {
        schemeName: 'PMFBY',
        description: 'Pradhan Mantri Fasal Bima Yojana provides crop insurance coverage to farmers at minimal premium rates.',
        eligibility: ['All farmers including sharecroppers and tenant farmers', 'Both loanee and non-loanee farmers'],
        benefits: ['Crop insurance coverage', 'Premium: 2% for Kharif, 1.5% for Rabi', 'Full sum insured for natural calamities'],
        applicationLink: 'https://pmfby.gov.in',
        ministry: 'Ministry of Agriculture & Farmers Welfare',
        schemeType: 'central',
    },
    {
        schemeName: 'Soil Health Card Scheme',
        description: 'Provides soil health cards to farmers with crop-wise nutrient recommendations for improving soil fertility.',
        eligibility: ['All farmers across India', 'No size or income restrictions'],
        benefits: ['Free soil testing', 'Personalized fertilizer recommendations', 'Improved yields through balanced nutrition'],
        applicationLink: 'https://soilhealth.dac.gov.in',
        ministry: 'Ministry of Agriculture & Farmers Welfare',
        schemeType: 'central',
    },
];

// ─── Example: CommunityPosts ─────────────────────────
const createCommunityPosts = (farmerIds) => [
    {
        farmerId: farmerIds[0],
        content: 'Got excellent wheat yield this season using SHC recommendations. Applied DAP and MOP as per soil health card advice. Yield increased by 20%! 🌾',
        location: { state: 'Madhya Pradesh', district: 'East Nimar' },
        category: 'success_story',
        tags: ['wheat', 'soil_health', 'yield'],
    },
    {
        farmerId: farmerIds[1],
        content: 'Can anyone suggest a good organic pest control method for rice stem borer? I want to reduce chemical pesticide usage this season.',
        location: { state: 'Karnataka', district: 'Raichur' },
        category: 'crop_advice',
        tags: ['rice', 'organic_farming', 'pest_control'],
    },
];

// ─── Example: Notifications ─────────────────────────
const createNotifications = (farmerIds) => [
    {
        farmerId: farmerIds[0],
        title: 'Wheat Rust Alert! ⚠️',
        message: 'Yellow rust has been reported in East Nimar district. Monitor your wheat crop and apply preventive fungicide spray.',
        type: 'disease_alert',
        readStatus: false,
    },
    {
        farmerId: farmerIds[0],
        title: 'Soybean prices rising 📈',
        message: 'Soybean prices at Khandwa Mandi have risen by 8% in the last week. Current rate: ₹45/kg.',
        type: 'market_update',
        readStatus: true,
    },
    {
        farmerId: farmerIds[1],
        title: 'PM-KISAN installment credited',
        message: 'Your PM-KISAN installment of ₹2,000 has been credited to your bank account.',
        type: 'scheme_update',
        readStatus: false,
    },
];

// ─── Example: FarmerLocations ────────────────────────
const createFarmerLocations = (farmerIds) => [
    {
        farmerId: farmerIds[0],
        location: { type: 'Point', coordinates: [76.3526, 21.8262] }, // Khandwa
        cropType: ['wheat', 'soybean'],
        resourcesAvailable: ['tractor', 'seed_drill'],
    },
    {
        farmerId: farmerIds[1],
        location: { type: 'Point', coordinates: [77.3551, 16.2076] }, // Raichur
        cropType: ['rice', 'cotton'],
        resourcesAvailable: ['transplanter', 'sprayer'],
    },
    {
        farmerId: farmerIds[2],
        location: { type: 'Point', coordinates: [72.8311, 21.1702] }, // Anand
        cropType: ['groundnut', 'cotton', 'mustard'],
        resourcesAvailable: ['tractor', 'harvester', 'irrigation_pump'],
    },
];

// ─── Example: ChatHistory ────────────────────────────
const createChatHistory = (farmerIds) => [
    {
        farmerId: farmerIds[0],
        question: 'When should I sow wheat in Madhya Pradesh?',
        answer: 'The ideal sowing time for wheat in Madhya Pradesh is mid-October to mid-November. Varieties like HI-1544 and JW-3020 perform well in your region. Ensure pre-sowing irrigation (palewa) before sowing.',
        intent: 'crop_advice',
        confidence: 0.91,
        language: 'en',
        sessionId: 'session_001',
        timestamp: new Date('2026-03-10T10:30:00'),
    },
    {
        farmerId: farmerIds[0],
        question: 'What fertilizer should I use after first irrigation?',
        answer: 'After the first irrigation at CRI stage (21 days), apply urea @ 65 kg/hectare as top dressing. If you applied full basal dose, this amount is sufficient for good tillering.',
        intent: 'crop_advice',
        confidence: 0.88,
        language: 'en',
        sessionId: 'session_001',
        timestamp: new Date('2026-03-10T10:32:00'),
    },
    {
        farmerId: farmerIds[1],
        question: 'PM-KISAN ke liye kaise apply karein?',
        answer: 'PM-KISAN yojana ke liye aap pmkisan.gov.in par online apply kar sakte hain. Aapko Aadhaar card, bank account details, aur zameen ke documents chahiye. Aap apne nearest CSC center se bhi apply kar sakte hain.',
        intent: 'scheme',
        confidence: 0.85,
        language: 'hi',
        sessionId: 'session_002',
        timestamp: new Date('2026-03-11T14:00:00'),
    },
];

// ═══════════════════════════════════════════════════════
// Seeder Execution
// ═══════════════════════════════════════════════════════
const seedDatabase = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('📦 Connected to MongoDB');

        if (process.argv.includes('--destroy')) {
            console.log('🗑️  Destroying existing data...');
            await Promise.all([
                Farmer.deleteMany({}),
                PestScan.deleteMany({}),
                MarketPrice.deleteMany({}),
                CropCalendar.deleteMany({}),
                GovernmentScheme.deleteMany({}),
                CommunityPost.deleteMany({}),
                Comment.deleteMany({}),
                Notification.deleteMany({}),
                FarmerLocation.deleteMany({}),
                ChatHistory.deleteMany({}),
            ]);
            console.log('✅ All data destroyed');
        }

        // 1. Seed Farmers
        const createdFarmers = await Farmer.create(farmers);
        const farmerIds = createdFarmers.map((f) => f._id);
        console.log(`✅ Seeded ${createdFarmers.length} farmers`);

        // 2. Seed PestScans
        const scans = await PestScan.create(createPestScans(farmerIds));
        console.log(`✅ Seeded ${scans.length} pest scans`);

        // 3. Seed MarketPrices
        const prices = await MarketPrice.create(marketPrices);
        console.log(`✅ Seeded ${prices.length} market prices`);

        // 4. Seed CropCalendar
        const calendar = await CropCalendar.create(cropCalendar);
        console.log(`✅ Seeded ${calendar.length} crop calendar entries`);

        // 5. Seed GovernmentSchemes
        const schemes = await GovernmentScheme.create(governmentSchemes);
        console.log(`✅ Seeded ${schemes.length} government schemes`);

        // 6. Seed CommunityPosts
        const posts = await CommunityPost.create(createCommunityPosts(farmerIds));
        console.log(`✅ Seeded ${posts.length} community posts`);

        // 7. Seed Comments
        const comments = await Comment.create([
            { postId: posts[0]._id, farmerId: farmerIds[1], commentText: 'Great results! Which variety did you use?' },
            { postId: posts[0]._id, farmerId: farmerIds[2], commentText: 'I also followed SHC recommendations. Yields improved significantly.' },
            { postId: posts[1]._id, farmerId: farmerIds[0], commentText: 'Try neem oil spray @ 5ml/litre. Works well for stem borer.' },
        ]);
        console.log(`✅ Seeded ${comments.length} comments`);

        // 8. Seed Notifications
        const notifications = await Notification.create(createNotifications(farmerIds));
        console.log(`✅ Seeded ${notifications.length} notifications`);

        // 9. Seed FarmerLocations
        const locations = await FarmerLocation.create(createFarmerLocations(farmerIds));
        console.log(`✅ Seeded ${locations.length} farmer locations`);

        // 10. Seed ChatHistory
        const chats = await ChatHistory.create(createChatHistory(farmerIds));
        console.log(`✅ Seeded ${chats.length} chat history entries`);

        console.log('\n🌾 Database seeding complete!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Seeder error:', error.message);
        process.exit(1);
    }
};

seedDatabase();

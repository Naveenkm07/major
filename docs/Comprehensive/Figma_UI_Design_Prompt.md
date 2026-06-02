# Figma UI/UX Design Prompt: KrushikaDhara

**Context**: You are designing the UI for a Flutter-based smart agriculture application called KrushikaDhara, aimed at smallholder farmers in Karnataka, India. 
**Goal**: Generate the core screens for this mobile app. The design must be high-contrast, accessible for older demographics, and heavily utilize "Voice-First" navigation.

---

## 1. Global Design System (Material 3)

- **Primary Color**: Agricultural Green (`#2E7D32`) - Use for main buttons, app bars, and active states.
- **Secondary Color**: Harvest Orange (`#F57C00`) - Use for alerts, important highlights, and the Voice Assistant microphone.
- **Background Color**: Off-White (`#F9FBE7`) - Essential for reducing glare and improving readability under direct sunlight in the field.
- **Typography**: `Roboto` or `Inter`. **CRITICAL**: Base body text must be `16sp` minimum. Do not use small, light fonts.
- **Layout Rule (For Flutter)**: Use **Auto Layout** for everything! Flutter translates Auto Layout directly into `Row` and `Column` widgets perfectly.

---

## 2. Core Screens to Design

Please generate the following 7 screens in a mobile aspect ratio (e.g., iPhone 14 / Android Large):

### Screen 1: Onboarding & Login
- **Header**: App Logo (A modern, simple leaf motif) and "KrushikaDhara".
- **Language Selector**: A prominent dropdown or toggle switch to choose between "English" and "ಕನ್ನಡ (Kannada)".
- **Inputs**: A large text field for Phone Number.
- **Button**: A massive, full-width Primary Green button: "Get OTP".

### Screen 2: Home Dashboard
- **Top Section**: A Weather Widget card showing the current temperature, a weather icon (sun/rain), and a soil moisture percentage.
- **Middle Section**: "Dynamic Crop Calendar". A vertical timeline showing what the farmer needs to do this week (e.g., "Apply Fertilizer", "Water Crops").
- **Bottom Section**: "Mandi Price Alerts" horizontal scrolling ticker or small cards.
- **Floating Action Button (FAB)**: A large, pulsing Orange microphone icon fixed at the bottom right for the Voice Assistant.

### Screen 3: Disease Scanner (Camera View)
- **Background**: A full-screen camera viewfinder showing a crop leaf.
- **Overlay**: A bounding box targeting a spot on the leaf.
- **Bottom Sheet (Half-screen modal)**: 
  - **Status**: "Bacterial Blight Detected" with a Red severity badge.
  - **Action**: "Recommended Treatment: Streptocycline at 0.5 g/L".
  - **Buttons**: Two buttons -> "Save to Profile" and "Ask AI for organic alternative".

### Screen 4: Voice Assistant Chat UI
- **Header**: "KrushikaDhara AI Assistant".
- **Chat Area**: Standard messaging bubbles. The AI's bubbles should be Primary Green. The user's bubbles should be light grey.
- **Input Area**: Instead of a traditional keyboard input, the bottom should feature a massive, centrally placed Orange microphone button. Text: "Tap and speak in Kannada".

### Screen 5: Scheme & Loan Discovery
- **Top**: A search bar.
- **Filters**: Horizontal scrolling chips (e.g., "Subsidies", "Loans", "Equipment", "DCC Bank").
- **Content**: A vertical list of large cards. Each card must have:
  - Scheme Name (e.g., "Krishi Bhagya")
  - A Green badge: "You are Eligible"
  - Subsidy Amount (e.g., "₹50,000")
  - Button: "How to Apply"

### Screen 6: Community Forum & Farmer Connect
- **Top Bar**: Segmented control: "Discussions" vs "Equipment Map".
- **Discussions Tab**: 
  - A scrollable feed of user posts.
  - Each post needs: User Avatar, Name, Timestamp, Text content, Image grid (if any), and Action buttons (Like 👍, Comment 💬).
  - A Floating Action Button (FAB) to "Create New Post".
- **Equipment Map Tab**: 
  - A Google Maps-style view showing nearby farmers.
  - Map Pins representing tractors or equipment available for sharing.

### Screen 7: User Profile & Settings
- **Header**: Large User Avatar and Phone Number.
- **My Crops Section**: A horizontal list of chips showing the crops they grow (e.g., "Tomato 🍅", "Ragi 🌾"). Button to "Add Crop".
- **Location Settings**: Input field for current District (vital for Mandi/Weather).
- **Preferences**: Notification toggles (Mandi Alerts, Disease Warning Alerts).
- **Footer**: Logout button.

---

## 3. Developer Handoff Notes
- Ensure all icons are exported as SVGs.
- Keep the component hierarchy clean so the Flutter developer can easily map them to `StatelessWidgets`.

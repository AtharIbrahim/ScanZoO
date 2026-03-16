# 📊 Database Structure & Setup Guide

## Firestore Database Collections:

### 1. **stickers/** Collection
Stores all sticker information
```
stickers/{stickerId}
├── stickerId: string (e.g., "STK-123456789")
├── qrCode: string (URL to the sticker)
├── status: string ("inactive" | "active" | "suspended" | "expired")
├── userId: string | null (owner's user ID)
├── createdAt: timestamp
├── activatedAt: timestamp | null
├── expiryDate: timestamp | null
├── emergencyContactIds: array<string> (IDs of contacts for this sticker)
└── vehicleInfo: object | null
    ├── make: string
    ├── model: string
    ├── year: string
    ├── color: string
    └── plateNumber: string
```

### 2. **users/** Collection
Stores user profiles and emergency contacts (pool of contacts to choose from)
```
users/{userId}
├── uid: string
├── email: string
├── displayName: string | null
├── photoURL: string | null
├── hasActiveSticker: boolean
├── activeStickerIds: array<string>
├── emergencyContacts: array<object> (pool of all user contacts with unique IDs)
│   └── [
│       {
│         id: string (unique contact ID)
│         name: string
│         phone: string
│         relationship: string
│         isPrimary: boolean
│       }
│   ]
├── createdAt: timestamp
└── updatedAt: timestamp
```

**Note:** Users can have multiple stickers, and each sticker can be linked to different emergency contacts from the user's contact pool.

### 3. **scanHistory/** Collection ⭐ NEW
Tracks all sticker scan activities
```
scanHistory/{scanId}
├── stickerId: string (which sticker was scanned)
├── userId: string (owner of the sticker)
├── scannedAt: timestamp
├── action: string ("activated" | "viewed" | "blocked" | "unblocked")
└── metadata: object
    ├── source: string ("app" | "web")
    ├── userAgent: string (browser info)
    └── timestamp: string (ISO date)
```

## How It Works:

### When User Activates Sticker (In-App):
1. Sticker status changes: `inactive` → `active`
2. `userId` field is set to current user
3. User selects emergency contacts for this specific sticker
4. Selected contact IDs are stored in sticker's `emergencyContactIds` array
5. Entry added to `scanHistory` with `action: "activated"`

### When Someone Scans QR Code (Website):
1. Website reads `stickers/{id}` to get owner info and `emergencyContactIds`
2. Website reads `users/{ownerId}` to get user's emergency contacts
3. Website filters and displays only the contacts whose IDs are in the sticker's `emergencyContactIds`
4. **NEW:** Website logs to `scanHistory` with `action: "viewed"`

### Multi-Sticker Support:
- Users can have multiple active stickers (e.g., multiple cars)
- Each sticker can have different emergency contacts
- Contacts are managed at user level but linked to specific stickers
- Example: User has 2 cars:
  - Car 1 sticker → linked to Wife + Brother
  - Car 2 sticker → linked to Friend + Neighbor
3. Website displays emergency contacts
4. **NEW:** Website logs to `scanHistory` with `action: "viewed"`

### When User Blocks/Unblocks Sticker:
1. Sticker status changes: `active` ↔ `suspended`
2. Entry added to `scanHistory` with appropriate action

## 🔥 Firebase Setup Required:

### Step 1: Deploy Firestore Rules
```bash
cd c:\dev\projects\123FlutterDev\project3_car_scanner\car_scanner
firebase deploy --only firestore:rules
```

### Step 2: Deploy Updated Website
Upload the updated `scan_website` folder to Netlify with the new `js/scan.js` file.

### Step 3: Test the Flow

#### Test 1: Website Scan Logging
1. Open: `https://car-scanner.netlify.app/scan/123456789`
2. Emergency contacts should load
3. Check Firebase Console → Firestore → `scanHistory` collection
4. You should see a new document with:
   - `action: "viewed"`
   - `source: "web"`
   - `scannedAt: [timestamp]`

#### Test 2: App Scan History
1. Open your Flutter app
2. Activate a sticker (or block/unblock existing one)
3. Go to Home → "View Scan History"
4. You should see:
   - Previous activations
   - All website views
   - Block/unblock actions

## 📱 Scan History Screen Features:

- **Color-coded actions:**
  - 🟢 Green = Activated
  - 🔵 Blue = Viewed (website scan)
  - 🔴 Red = Blocked
  - 🟠 Orange = Unblocked

- **Shows:**
  - Action type
  - Date & time
  - Sticker ID
  - Vehicle info (if available)
  - Current sticker status

## ⚠️ Important Security Notes:

1. **Anonymous reads allowed** for:
   - `stickers` collection (needed for website)
   - `users` collection (needed for emergency contacts)

2. **Anonymous writes allowed** ONLY for:
   - `scanHistory` collection
   - ONLY with `action: "viewed"`
   - Must include required fields

3. **Authenticated writes required** for:
   - Everything else (activation, blocking, etc.)

## 🧪 Testing Checklist:

- [ ] Deploy updated Firestore rules
- [ ] Deploy updated website files
- [ ] Test: Scan QR code from website
- [ ] Verify: Check scanHistory collection created
- [ ] Test: Open app scan history screen
- [ ] Verify: See "viewed" entries from website
- [ ] Test: Activate new sticker in app
- [ ] Verify: See "activated" entry in history
- [ ] Test: Block/unblock sticker
- [ ] Verify: See block/unblock entries

## 🐛 Troubleshooting:

### "Nothing shows in scan history"
- Check Firebase Console → Firestore
- Look for `scanHistory` collection
- If empty, website isn't logging (deploy latest JS file)
- If exists but app doesn't show, check user authentication

### "Permission denied" errors
- Deploy latest `firestore.rules`
- Check Firebase Console → Firestore → Rules tab
- Verify rules are active

### "Sticker not found" on website
- Verify sticker exists in Firestore
- Check sticker status is "active"
- Verify userId is not null


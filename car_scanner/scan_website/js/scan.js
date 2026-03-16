// Firebase configuration is injected by /js/firebase-config.js (ignored by git).
const firebaseConfig = window.CAR_SCANNER_FIREBASE_CONFIG;

if (!firebaseConfig || !firebaseConfig.apiKey || firebaseConfig.apiKey.includes('REPLACE')) {
    throw new Error('Missing Firebase config. Create scan_website/js/firebase-config.js from firebase-config.example.js');
}

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();

// Extract sticker ID from URL
function getStickerIdFromURL() {
    const path = window.location.pathname;
    const segments = path.split('/').filter(s => s.length > 0);
    
    // Looking for pattern like /scan/STK-123 or /s/STK-123
    if (segments.length >= 2) {
        return segments[segments.length - 1];
    }
    
    // Check URL parameters as fallback
    const params = new URLSearchParams(window.location.search);
    return params.get('id') || params.get('sticker');
}

// Load and display emergency contacts
async function loadEmergencyContacts() {
    const contentDiv = document.getElementById('content');
    const stickerId = getStickerIdFromURL();

    if (!stickerId) {
        showError('Invalid QR Code', 'Could not extract sticker ID from the URL.');
        return;
    }

    try {
        // Get sticker document
        const stickerDoc = await db.collection('stickers').doc(stickerId).get();

        if (!stickerDoc.exists) {
            showError('Sticker Not Found', 'This sticker is not registered in our system.');
            return;
        }

        const stickerData = stickerDoc.data();
        
        // Check if sticker is active
        if (stickerData.status !== 'active') {
            showError('Inactive Sticker', 'This sticker is not currently active.');
            return;
        }

        const userId = stickerData.userId;
        if (!userId) {
            showError('No Owner', 'This sticker is not assigned to any user.');
            return;
        }

        const contactsToDisplay = stickerData.publicEmergencyContacts || [];

        if (contactsToDisplay.length === 0) {
            showError('No Contacts', 'No emergency contacts have been linked to this vehicle sticker yet. The owner needs to link contacts first.');
            return;
        }

        // Display the information
        displayContacts(stickerData, contactsToDisplay);

        // Log the scan to history
        await logScanToHistory(stickerId, userId);

    } catch (error) {
        console.error('Error loading contacts:', error);
        showError('Error', 'Failed to load contact information. Please try again.');
    }
}

function displayContacts(stickerData, contacts) {
    const contentDiv = document.getElementById('content');
    
    let html = '';

    // Info box
    html += `
        <div class="info-box">
            <p>⚠️ This vehicle owner has set up emergency contacts. Please call one of the contacts below if assistance is needed.</p>
        </div>
    `;

    // Vehicle info if available
    if (stickerData.vehicleInfo) {
        const vehicle = stickerData.vehicleInfo;
        html += `
            <div class="vehicle-info">
                <h3>Vehicle Information</h3>
                <div class="vehicle-detail">
                    <span class="label">Make & Model</span>
                    <span class="value">${vehicle.make} ${vehicle.model}</span>
                </div>
                <div class="vehicle-detail">
                    <span class="label">Year</span>
                    <span class="value">${vehicle.year}</span>
                </div>
                <div class="vehicle-detail">
                    <span class="label">Color</span>
                    <span class="value">${vehicle.color}</span>
                </div>
                <div class="vehicle-detail">
                    <span class="label">Plate Number</span>
                    <span class="value">${vehicle.plateNumber || vehicle.licensePlate || ''}</span>
                </div>
            </div>
        `;
    }

    // Emergency contacts section
    html += '<div class="contacts-section"><h3>Emergency Contacts</h3>';

    // Sort contacts to show primary first
    const sortedContacts = [...contacts].sort((a, b) => {
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;
        return 0;
    });

    sortedContacts.forEach(contact => {
        html += `
            <div class="contact-card ${contact.isPrimary ? 'primary' : ''}">
                ${contact.isPrimary ? '<span class="contact-badge">Primary Contact</span>' : ''}
                <div class="contact-name">${escapeHtml(contact.name)}</div>
                <div class="contact-relationship">${escapeHtml(contact.relationship)}</div>
                <div class="contact-phone">
                    <span class="phone-number">${escapeHtml(contact.phone)}</span>
                    <a href="tel:${contact.phone}" class="call-button">
                        📞 Call Now
                    </a>
                </div>
            </div>
        `;
    });

    html += '</div>';

    contentDiv.innerHTML = html;
}

function showError(title, message) {
    const contentDiv = document.getElementById('content');
    contentDiv.innerHTML = `
        <div class="error">
            <div class="error-icon">⚠️</div>
            <h2>${escapeHtml(title)}</h2>
            <p>${escapeHtml(message)}</p>
        </div>
    `;
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Log scan to history
async function logScanToHistory(stickerId, userId) {
    try {
        await db.collection('scanHistory').add({
            stickerId: stickerId,
            userId: userId, // Owner of the sticker
            scannedAt: firebase.firestore.FieldValue.serverTimestamp(),
            action: 'viewed',
            metadata: {
                source: 'web',
                userAgent: navigator.userAgent,
                timestamp: new Date().toISOString()
            }
        });
        console.log('Scan logged to history');
    } catch (error) {
        // Don't show error to user, just log it
        console.error('Failed to log scan history:', error);
    }
}

// Load contacts when page loads
window.addEventListener('DOMContentLoaded', loadEmergencyContacts);

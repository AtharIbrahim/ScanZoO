// Firebase configuration is injected by /js/firebase-config.js (ignored by git).
const firebaseConfig = window.CAR_SCANNER_FIREBASE_CONFIG;

if (!firebaseConfig || !firebaseConfig.apiKey || firebaseConfig.apiKey.includes('REPLACE')) {
    throw new Error('Missing Firebase config. Create scan_website/js/firebase-config.js from firebase-config.example.js');
}

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
const auth = firebase.auth();

// DOM Elements
const loginSection = document.getElementById('loginSection');
const adminContent = document.getElementById('adminContent');
const loginForm = document.getElementById('loginForm');
const loginError = document.getElementById('loginError');
const logoutBtn = document.getElementById('logoutBtn');
const stickerForm = document.getElementById('stickerForm');
const resetBtn = document.getElementById('resetBtn');
const formMessage = document.getElementById('formMessage');

// Stats elements
const totalStickersEl = document.getElementById('totalStickers');
const activeStickersEl = document.getElementById('activeStickers');
const inactiveStickersEl = document.getElementById('inactiveStickers');
const stickersListEl = document.getElementById('stickersList');

// Auth State Observer
auth.onAuthStateChanged((user) => {
    if (user) {
        // User is logged in
        loginSection.style.display = 'none';
        adminContent.style.display = 'block';
        logoutBtn.style.display = 'block';
        
        // Load data
        loadStats();
        loadRecentStickers();
    } else {
        // User is logged out
        loginSection.style.display = 'block';
        adminContent.style.display = 'none';
        logoutBtn.style.display = 'none';
    }
});

// Login Form Handler
loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const email = document.getElementById('loginEmail').value.trim();
    const password = document.getElementById('loginPassword').value;
    
    try {
        loginError.style.display = 'none';
        await auth.signInWithEmailAndPassword(email, password);
    } catch (error) {
        console.error('Login error:', error);
        loginError.textContent = getErrorMessage(error.code);
        loginError.style.display = 'block';
    }
});

// Logout Handler
logoutBtn.addEventListener('click', async () => {
    try {
        await auth.signOut();
    } catch (error) {
        console.error('Logout error:', error);
        alert('Error logging out. Please try again.');
    }
});

// Sticker Form Handler
stickerForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const stickerId = document.getElementById('stickerId').value.trim();
    const qrCode = document.getElementById('qrCode').value.trim();
    const expiryDate = document.getElementById('expiryDate').value;
    const status = document.getElementById('status').value;
    const userId = document.getElementById('userId').value.trim();
    
    // Vehicle info
    const vehicleMake = document.getElementById('vehicleMake').value.trim();
    const vehicleModel = document.getElementById('vehicleModel').value.trim();
    const vehicleYear = document.getElementById('vehicleYear').value;
    const vehicleColor = document.getElementById('vehicleColor').value.trim();
    const vehiclePlate = document.getElementById('vehiclePlate').value.trim();
    
    // Validate sticker ID
    if (!stickerId) {
        showMessage('Please enter a sticker ID', 'error');
        return;
    }
    
    try {
        // Check if sticker already exists
        const existingDoc = await db.collection('stickers').doc(stickerId).get();
        if (existingDoc.exists) {
            showMessage(`Sticker with ID "${stickerId}" already exists!`, 'error');
            return;
        }
        
        // Prepare sticker data
        const stickerData = {
            stickerId: stickerId,
            qrCode: qrCode || stickerId,
            status: status,
            createdAt: firebase.firestore.FieldValue.serverTimestamp(),
            updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
            expiryDate: firebase.firestore.Timestamp.fromDate(new Date(expiryDate))
        };
        
        // Add userId if provided
        if (userId) {
            stickerData.userId = userId;
            if (status === 'active') {
                stickerData.activatedAt = firebase.firestore.FieldValue.serverTimestamp();
            }
        } else {
            stickerData.userId = '';
        }
        
        // Add vehicle info if any field is filled
        if (vehicleMake || vehicleModel || vehicleYear || vehicleColor || vehiclePlate) {
            stickerData.vehicleInfo = {
                make: vehicleMake || '',
                model: vehicleModel || '',
                year: vehicleYear ? parseInt(vehicleYear) : 0,  // Convert to integer
                color: vehicleColor || '',
                licensePlate: vehiclePlate || ''
            };
        }
        
        // Add sticker to Firestore
        await db.collection('stickers').doc(stickerId).set(stickerData);
        
        showMessage(`✅ Sticker "${stickerId}" added successfully!`, 'success');
        
        // Reset form
        stickerForm.reset();
        
        // Reload data
        loadStats();
        loadRecentStickers();
        
        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
        
    } catch (error) {
        console.error('Error adding sticker:', error);
        showMessage(`Error: ${error.message}`, 'error');
    }
});

// Reset Form Handler
resetBtn.addEventListener('click', () => {
    stickerForm.reset();
    formMessage.style.display = 'none';
});

// Auto-fill QR Code from Sticker ID
document.getElementById('stickerId').addEventListener('input', (e) => {
    const qrCodeInput = document.getElementById('qrCode');
    if (!qrCodeInput.value) {
        qrCodeInput.value = e.target.value;
    }
});

// Load Statistics
async function loadStats() {
    try {
        const snapshot = await db.collection('stickers').get();
        const stickers = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        
        totalStickersEl.textContent = stickers.length;
        activeStickersEl.textContent = stickers.filter(s => s.status === 'active').length;
        inactiveStickersEl.textContent = stickers.filter(s => s.status === 'inactive').length;
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

// Load Recent Stickers
async function loadRecentStickers() {
    try {
        const snapshot = await db.collection('stickers')
            .orderBy('createdAt', 'desc')
            .limit(10)
            .get();
        
        if (snapshot.empty) {
            stickersListEl.innerHTML = `
                <div class="empty-state">
                    <div class="empty-state-icon">📦</div>
                    <p>No stickers yet. Add your first sticker above!</p>
                </div>
            `;
            return;
        }
        
        const stickersHTML = snapshot.docs.map(doc => {
            const data = doc.data();
            const createdDate = data.createdAt ? 
                data.createdAt.toDate().toLocaleDateString('en-US', { 
                    month: 'short', 
                    day: 'numeric', 
                    year: 'numeric' 
                }) : 'N/A';
            
            const expiryDate = data.expiryDate ? 
                data.expiryDate.toDate().toLocaleDateString('en-US', { 
                    month: 'short', 
                    day: 'numeric', 
                    year: 'numeric' 
                }) : 'N/A';
            
            const statusClass = `status-${data.status}`;
            
            return `
                <div class="sticker-item">
                    <div class="sticker-info">
                        <div class="sticker-id">${data.stickerId}</div>
                        <div class="sticker-meta">
                            Created: ${createdDate} | Expires: ${expiryDate}
                            ${data.userId && data.userId !== '' ? ` | User: ${data.userId.substring(0, 8)}...` : ' | Unassigned'}
                        </div>
                    </div>
                    <span class="sticker-status ${statusClass}">
                        ${data.status.toUpperCase()}
                    </span>
                </div>
            `;
        }).join('');
        
        stickersListEl.innerHTML = stickersHTML;
    } catch (error) {
        console.error('Error loading stickers:', error);
        stickersListEl.innerHTML = `
            <div class="empty-state">
                <p style="color: #e53e3e;">Error loading stickers. Please refresh the page.</p>
            </div>
        `;
    }
}

// Show Message
function showMessage(text, type) {
    formMessage.textContent = text;
    formMessage.className = `message ${type}`;
    formMessage.style.display = 'block';
    
    // Hide after 5 seconds
    setTimeout(() => {
        formMessage.style.display = 'none';
    }, 5000);
}

// Get User-Friendly Error Message
function getErrorMessage(errorCode) {
    switch (errorCode) {
        case 'auth/invalid-email':
            return 'Invalid email address format.';
        case 'auth/user-disabled':
            return 'This account has been disabled.';
        case 'auth/user-not-found':
            return 'No account found with this email.';
        case 'auth/wrong-password':
            return 'Incorrect password.';
        case 'auth/invalid-credential':
            return 'Invalid email or password.';
        case 'auth/too-many-requests':
            return 'Too many failed login attempts. Please try again later.';
        default:
            return 'Login failed. Please check your credentials and try again.';
    }
}

// Set default expiry date (30 days from now)
window.addEventListener('DOMContentLoaded', () => {
    const expiryInput = document.getElementById('expiryDate');
    const defaultDate = new Date();
    defaultDate.setDate(defaultDate.getDate() + 30);
    expiryInput.value = defaultDate.toISOString().split('T')[0];
});

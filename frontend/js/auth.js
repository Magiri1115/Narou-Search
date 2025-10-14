// Authentication Module with FirebaseUI
import { auth, db, firebase, analytics } from './firebase.js';

// Initialize FirebaseUI
let ui = null;

// Auth State Management
let currentUser = null;

// Initialize FirebaseUI
function initializeFirebaseUI() {
  // Check if FirebaseUI is loaded
  if (typeof firebaseui === 'undefined') {
    console.error('FirebaseUI is not loaded');
    return null;
  }

  // Initialize or get existing instance
  if (!ui) {
    ui = new firebaseui.auth.AuthUI(auth);
  }
  return ui;
}

// Initialize auth state listener
export function initAuth() {
  auth.onAuthStateChanged(async (user) => {
    currentUser = user;

    if (user) {
      // User is logged in
      console.log('User logged in:', user.email);

      // Save user data to Firestore
      try {
        const userRef = db.collection('users').doc(user.uid);
        const userDoc = await userRef.get();
        if (!userDoc.exists) {
          await userRef.set({
            email: user.email,
            displayName: user.displayName || '',
            photoURL: user.photoURL || '',
            createdAt: new Date().toISOString(),
            emailVerified: user.emailVerified
          });
          console.log('✅ User data saved to Firestore');
        }
      } catch (error) {
        console.warn('Firestore save failed (non-critical):', error);
      }

      updateUI(user);
      showSearchEngine();

      if (analytics) {
        analytics.logEvent('user_login', {
          user_id: user.uid,
          method: user.providerData[0]?.providerId || 'unknown'
        });
      }
    } else {
      // User is not logged in
      console.log('User not logged in');
      updateUI(null);
      showLoginScreen();
      renderFirebaseUI();
    }
  });
}

// Render FirebaseUI
function renderFirebaseUI() {
  const ui = initializeFirebaseUI();
  if (!ui) {
    console.error('Failed to initialize FirebaseUI');
    return;
  }

  const uiConfig = {
    callbacks: {
      signInSuccessWithAuthResult: function(authResult, redirectUrl) {
        // User successfully signed in
        const user = authResult.user;
        console.log('Sign in success:', user.email);

        // Don't redirect automatically
        return false;
      },
      signInFailure: function(error) {
        // Handle sign-in errors
        console.error('Sign in error:', error);
        alert('ログインエラー: ' + (error.message || 'エラーが発生しました'));
        return Promise.resolve();
      },
      uiShown: function() {
        // The widget is rendered
        console.log('FirebaseUI widget shown');
      }
    },
    // Use popup for sign-in flow
    signInFlow: 'popup',
    signInOptions: [
      // Email/Password
      {
        provider: firebase.auth.EmailAuthProvider.PROVIDER_ID,
        requireDisplayName: true
      },
      // Google
      {
        provider: firebase.auth.GoogleAuthProvider.PROVIDER_ID,
        scopes: [
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile'
        ]
      }
    ],
    // Terms of service url (optional)
    tosUrl: '#',
    // Privacy policy url (optional)
    privacyPolicyUrl: '#'
  };

  // Clear previous UI if exists
  const container = document.getElementById('firebaseui-auth-container');
  if (container) {
    container.innerHTML = '';
  }

  // Start FirebaseUI
  if (container) {
    ui.start('#firebaseui-auth-container', uiConfig);
  }
}

// Show search engine (hide login screen)
function showSearchEngine() {
  const mainContainer = document.querySelector('.container');
  const authContainer = document.querySelector('.auth-container');
  const loginScreen = document.getElementById('login-screen');

  if (loginScreen) loginScreen.style.display = 'none';
  if (mainContainer) mainContainer.style.display = 'block';
  if (authContainer) authContainer.style.display = 'flex';
}

// Show login screen only (hide search engine)
function showLoginScreen() {
  const mainContainer = document.querySelector('.container');
  const authContainer = document.querySelector('.auth-container');
  const loginScreen = document.getElementById('login-screen');

  if (loginScreen) loginScreen.style.display = 'flex';
  if (mainContainer) mainContainer.style.display = 'none';
  if (authContainer) authContainer.style.display = 'none';
}

// Update UI based on auth state
function updateUI(user) {
  const authBtn = document.getElementById('auth-btn');
  const userInfo = document.getElementById('user-info');

  if (user) {
    // User is signed in
    if (authBtn) {
      authBtn.textContent = 'ログアウト';
      authBtn.onclick = handleSignOut;
    }

    if (userInfo) {
      const displayName = user.displayName || user.email || 'User';
      userInfo.innerHTML = `<span class="user-email">${displayName}</span>`;
      userInfo.style.display = 'block';
    }
  } else {
    // User is signed out
    if (authBtn) {
      authBtn.textContent = 'ログイン';
      authBtn.onclick = () => {}; // No action needed, login screen is already shown
    }

    if (userInfo) {
      userInfo.style.display = 'none';
    }
  }
}

// Sign Out
export async function handleSignOut() {
  try {
    await auth.signOut();

    if (analytics) {
      analytics.logEvent('user_logout');
    }

    // Reset UI
    if (ui) {
      ui.reset();
    }

    return { success: true };
  } catch (error) {
    console.error('Sign out error:', error);
    return { success: false, error: error.message };
  }
}

// Get current user
export function getCurrentUser() {
  return currentUser;
}

// Export renderFirebaseUI for manual use
export { renderFirebaseUI };

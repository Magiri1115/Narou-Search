// Firebase initialization script (non-module)
// This runs before any ES modules

const firebaseConfig = {
  apiKey: "AIzaSyClAGj-WtUmoUNG8jsa1EZA9MCJc3jsirE",
  authDomain: "magiri.firebaseapp.com",
  projectId: "magiri",
  storageBucket: "magiri.firebasestorage.app",
  messagingSenderId: "320365702855",
  appId: "1:320365702855:web:44912f5e14dbb4b8d598e2",
  measurementId: "G-QYG3E95KE1"
};

// Initialize Firebase
window.app = firebase.initializeApp(firebaseConfig);
window.analytics = firebase.analytics();
window.auth = firebase.auth();
window.db = firebase.firestore();
window.firebase = firebase;

// Set persistence to SESSION - user will be logged out when browser/tab is closed
firebase.auth().setPersistence(firebase.auth.Auth.Persistence.SESSION)
  .then(() => {
    console.log('✅ Firebase initialized (Session persistence - logout on browser close)');
  })
  .catch((error) => {
    console.error('Persistence error:', error);
  });

console.log('✅ FirebaseUI loaded:', typeof firebaseui);

// Backend Authentication Module
const API_BASE_URL = 'http://localhost:8000';

// Auth State Management
let currentUser = null;
let accessToken = null;
let refreshToken = null;

// Load tokens from localStorage
function loadTokens() {
    accessToken = localStorage.getItem('access_token');
    refreshToken = localStorage.getItem('refresh_token');
}

// Save tokens to localStorage
function saveTokens(access, refresh) {
    accessToken = access;
    refreshToken = refresh;
    localStorage.setItem('access_token', access);
    if (refresh) {
        localStorage.setItem('refresh_token', refresh);
    }
}

// Clear tokens
function clearTokens() {
    accessToken = null;
    refreshToken = null;
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user');
}

// Initialize auth state
export async function initAuth() {
    loadTokens();

    if (accessToken) {
        try {
            const user = await getCurrentUser();
            if (user) {
                currentUser = user;
                updateUI(user);
                showSearchEngine();
                return;
            }
        } catch (error) {
            console.error('Failed to load user:', error);
            // Try to refresh token
            if (refreshToken) {
                try {
                    await refreshAccessToken();
                    const user = await getCurrentUser();
                    if (user) {
                        currentUser = user;
                        updateUI(user);
                        showSearchEngine();
                        return;
                    }
                } catch (refreshError) {
                    console.error('Failed to refresh token:', refreshError);
                }
            }
        }
    }

    // Not logged in
    currentUser = null;
    showLoginScreen();
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
            const displayName = user.nickname || user.name || user.email;
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

// Email/Password Sign Up
export async function handleEmailSignUp(email, password, personalInfo) {
    try {
        const response = await fetch(`${API_BASE_URL}/api/auth/signup`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                email,
                password,
                ...personalInfo
            })
        });

        const data = await response.json();

        if (!response.ok) {
            return { success: false, error: data.error || 'Signup failed' };
        }

        // Save tokens
        saveTokens(data.access_token, data.refresh_token);
        currentUser = data.user;

        // Update UI
        updateUI(currentUser);
        showSearchEngine();

        return {
            success: true,
            user: data.user,
            message: 'アカウントが作成されました'
        };
    } catch (error) {
        console.error('Signup error:', error);
        return { success: false, error: 'ネットワークエラーが発生しました' };
    }
}

// Email/Password Sign In
export async function handleEmailSignIn(email, password) {
    try {
        const response = await fetch(`${API_BASE_URL}/api/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email, password })
        });

        const data = await response.json();

        if (!response.ok) {
            return { success: false, error: data.error || 'Login failed' };
        }

        // Save tokens
        saveTokens(data.access_token, data.refresh_token);
        currentUser = data.user;

        // Update UI
        updateUI(currentUser);
        showSearchEngine();

        return { success: true, user: data.user };
    } catch (error) {
        console.error('Login error:', error);
        return { success: false, error: 'ネットワークエラーが発生しました' };
    }
}

// Google Sign In (will be implemented later if needed)
export async function handleGoogleSignIn() {
    return {
        success: false,
        error: 'Googleログインは現在利用できません。メールアドレスでログインしてください。'
    };
}

// Sign Out
export async function handleSignOut() {
    try {
        if (refreshToken) {
            await fetch(`${API_BASE_URL}/api/auth/logout`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${refreshToken}`
                }
            });
        }
    } catch (error) {
        console.error('Logout error:', error);
    } finally {
        clearTokens();
        currentUser = null;
        updateUI(null);
        showLoginScreen();
    }
}

// Get current user from backend
async function getCurrentUser() {
    if (!accessToken) return null;

    const response = await fetch(`${API_BASE_URL}/api/auth/me`, {
        headers: {
            'Authorization': `Bearer ${accessToken}`
        }
    });

    if (!response.ok) {
        throw new Error('Failed to get current user');
    }

    const data = await response.json();
    return data.user;
}

// Refresh access token
async function refreshAccessToken() {
    if (!refreshToken) {
        throw new Error('No refresh token');
    }

    const response = await fetch(`${API_BASE_URL}/api/auth/refresh`, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${refreshToken}`
        }
    });

    if (!response.ok) {
        clearTokens();
        throw new Error('Failed to refresh token');
    }

    const data = await response.json();
    saveTokens(data.access_token, refreshToken);
}

// Get access token for API requests
export function getAccessToken() {
    return accessToken;
}

// Get current user
export function getCurrentUserData() {
    return currentUser;
}

// Make authenticated API request
export async function authenticatedFetch(url, options = {}) {
    loadTokens();

    if (!accessToken) {
        throw new Error('Not authenticated');
    }

    const headers = {
        ...options.headers,
        'Authorization': `Bearer ${accessToken}`
    };

    let response = await fetch(url, { ...options, headers });

    // If token expired, try to refresh
    if (response.status === 401 && refreshToken) {
        try {
            await refreshAccessToken();
            headers['Authorization'] = `Bearer ${accessToken}`;
            response = await fetch(url, { ...options, headers });
        } catch (error) {
            clearTokens();
            window.location.reload();
            throw error;
        }
    }

    return response;
}

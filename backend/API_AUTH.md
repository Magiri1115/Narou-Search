# Authentication API Documentation

## Overview
The Narou Search backend now includes a complete authentication system with JWT tokens, user management, and session handling.

## Base URL
```
http://localhost:8000
```

## Authentication Endpoints

### 1. User Signup
Create a new user account.

**Endpoint:** `POST /api/auth/signup`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "田中太郎",           // Optional
  "nickname": "太郎",           // Optional
  "birthdate": "1990-01-01",   // Optional
  "gender": "male"             // Optional
}
```

**Response (201 Created):**
```json
{
  "message": "User created successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "田中太郎",
    "nickname": "太郎",
    "email_verified": false
  },
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc..."
}
```

**Validation:**
- Email must be valid format
- Password must be at least 6 characters
- Email must be unique

---

### 2. User Login
Login with email and password.

**Endpoint:** `POST /api/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "田中太郎",
    "nickname": "太郎",
    "email_verified": false
  },
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc..."
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": "Invalid email or password"
}
```

---

### 3. Logout
Invalidate the refresh token.

**Endpoint:** `POST /api/auth/logout`

**Headers:**
```
Authorization: Bearer <refresh_token>
```

**Response (200 OK):**
```json
{
  "message": "Logged out successfully"
}
```

---

### 4. Refresh Access Token
Get a new access token using a refresh token.

**Endpoint:** `POST /api/auth/refresh`

**Headers:**
```
Authorization: Bearer <refresh_token>
```

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGc..."
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": "Invalid or expired token"
}
```

---

### 5. Get Current User
Get the authenticated user's information.

**Endpoint:** `GET /api/auth/me`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "田中太郎",
    "nickname": "太郎",
    "birthdate": "1990-01-01",
    "gender": "male",
    "email_verified": false,
    "created_at": "2024-01-01T00:00:00"
  }
}
```

---

## Token Management

### Access Token
- **Expiry:** 1 hour
- **Usage:** Include in `Authorization: Bearer <token>` header for protected endpoints
- **Purpose:** Short-lived token for API access

### Refresh Token
- **Expiry:** 30 days
- **Usage:** Use to obtain new access tokens
- **Storage:** Store securely (httpOnly cookie recommended for web apps)

### Token Format
Tokens are JWT (JSON Web Tokens) with HS256 signature.

**Access Token Payload:**
```json
{
  "user_id": 1,
  "email": "user@example.com",
  "type": "access",
  "exp": "2024-01-01T01:00:00",
  "iat": "2024-01-01T00:00:00"
}
```

**Refresh Token Payload:**
```json
{
  "user_id": 1,
  "type": "refresh",
  "jti": "unique-token-id",
  "exp": "2024-01-31T00:00:00",
  "iat": "2024-01-01T00:00:00"
}
```

---

## Protected Endpoints

To protect an endpoint with authentication, use the `AuthMiddleware`:

```julia
include("app/middleware/AuthMiddleware.jl")
using .AuthMiddleware

route("/api/protected", AuthMiddleware.require_auth(my_handler), method = GET)
```

The middleware will:
1. Check for valid Authorization header
2. Verify the JWT token
3. Return 401 if unauthorized
4. Set `user_id` in request payload if authenticated

---

## Security Features

1. **Password Hashing:** BCrypt with auto-generated salt
2. **JWT Tokens:** HS256 signature algorithm
3. **Token Expiry:** Automatic expiration handling
4. **Refresh Token Storage:** Database-backed token validation
5. **CORS Support:** Enabled for all auth endpoints

---

## Environment Variables

Set these in your environment or `.env` file:

```bash
JWT_SECRET=your-secret-key-change-this-in-production  # Required for production
DB_PATH=/path/to/database.sqlite3                      # Optional, defaults to backend/db/production.sqlite3
```

---

## Database Schema

### Users Table
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name TEXT,
    nickname TEXT,
    birthdate TEXT,
    gender TEXT,
    email_verified INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### Refresh Tokens Table
```sql
CREATE TABLE refresh_tokens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    token TEXT UNIQUE NOT NULL,
    expires_at TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## Example Usage

### Using cURL

**Signup:**
```bash
curl -X POST http://localhost:8000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

**Login:**
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

**Get User Info:**
```bash
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer <access_token>"
```

---

## Error Handling

All endpoints return appropriate HTTP status codes and error messages:

- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Authentication failed
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource already exists (e.g., duplicate email)
- `500 Internal Server Error` - Server error

Error Response Format:
```json
{
  "error": "Error message describing what went wrong"
}
```

---

## Installation

1. Add required packages to `Project.toml`:
```toml
BCrypt = "c3bfe2a2-0c2f-4d3f-8383-7c0090c1f8d3"
JWTs = "9b8b2e7e-8e2e-4be4-b6e6-6c88e9b3c3e3"
```

2. Install dependencies:
```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

3. Run the server:
```bash
julia --project=. backend/server.jl
```

The authentication system will automatically create the necessary database tables on first run.

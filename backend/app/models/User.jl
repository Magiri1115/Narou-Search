"""
User data model
"""
module UserModel

using SQLite
using DBInterface
using Dates
using SHA

export User, create_user, find_user_by_email, find_user_by_id, verify_password, create_tables

"""
User struct
"""
struct User
    id::Union{Int, Nothing}
    email::String
    password_hash::String
    name::Union{String, Nothing}
    nickname::Union{String, Nothing}
    birthdate::Union{String, Nothing}
    gender::Union{String, Nothing}
    email_verified::Bool
    created_at::Union{DateTime, Nothing}
    updated_at::Union{DateTime, Nothing}
end

"""
Create users and refresh_tokens tables
"""
function create_tables(db::SQLite.DB)
    # Users table
    DBInterface.execute(db, """
        CREATE TABLE IF NOT EXISTS users (
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
        )
    """)

    # Index on email
    DBInterface.execute(db, """
        CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)
    """)

    # Refresh tokens table
    DBInterface.execute(db, """
        CREATE TABLE IF NOT EXISTS refresh_tokens (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            token TEXT UNIQUE NOT NULL,
            expires_at TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    """)

    # Indexes on refresh_tokens
    DBInterface.execute(db, """
        CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id)
    """)

    DBInterface.execute(db, """
        CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token)
    """)
end

"""
Hash password using SHA256 with salt
"""
function hash_password(password::String)::String
    # Generate random salt
    salt = bytes2hex(rand(UInt8, 16))
    # Hash password with salt
    hash = bytes2hex(sha256(password * salt))
    # Return salt:hash format
    return "$salt:$hash"
end

"""
Verify password against hash
"""
function verify_password(password::String, stored_hash::String)::Bool
    try
        parts = split(stored_hash, ":")
        if length(parts) != 2
            return false
        end
        salt = parts[1]
        expected_hash = parts[2]
        # Hash the provided password with the stored salt
        actual_hash = bytes2hex(sha256(password * salt))
        # Compare hashes
        return actual_hash == expected_hash
    catch
        return false
    end
end

"""
Create a new user
"""
function create_user(
    db::SQLite.DB,
    email::String,
    password::String;
    name::Union{String, Nothing} = nothing,
    nickname::Union{String, Nothing} = nothing,
    birthdate::Union{String, Nothing} = nothing,
    gender::Union{String, Nothing} = nothing
)::Union{User, Nothing}

    # Check if user already exists
    existing = find_user_by_email(db, email)
    if !isnothing(existing)
        return nothing
    end

    # Hash password
    password_hash = hash_password(password)

    # Insert user
    try
        DBInterface.execute(db, """
            INSERT INTO users (email, password_hash, name, nickname, birthdate, gender, email_verified)
            VALUES (?, ?, ?, ?, ?, ?, 0)
        """, [email, password_hash, name, nickname, birthdate, gender])

        # Return the created user
        return find_user_by_email(db, email)
    catch e
        @error "Failed to create user" exception=e
        return nothing
    end
end

"""
Find user by email
"""
function find_user_by_email(db::SQLite.DB, email::String)::Union{User, Nothing}
    result = DBInterface.execute(db, """
        SELECT id, email, password_hash, name, nickname, birthdate, gender,
               email_verified, created_at, updated_at
        FROM users
        WHERE email = ?
    """, [email])

    for row in result
        return User(
            row.id,
            row.email,
            row.password_hash,
            row.name,
            row.nickname,
            row.birthdate,
            row.gender,
            row.email_verified == 1,
            isnothing(row.created_at) ? nothing : DateTime(row.created_at),
            isnothing(row.updated_at) ? nothing : DateTime(row.updated_at)
        )
    end

    return nothing
end

"""
Find user by ID
"""
function find_user_by_id(db::SQLite.DB, id::Int)::Union{User, Nothing}
    result = DBInterface.execute(db, """
        SELECT id, email, password_hash, name, nickname, birthdate, gender,
               email_verified, created_at, updated_at
        FROM users
        WHERE id = ?
    """, [id])

    for row in result
        return User(
            row.id,
            row.email,
            row.password_hash,
            row.name,
            row.nickname,
            row.birthdate,
            row.gender,
            row.email_verified == 1,
            isnothing(row.created_at) ? nothing : DateTime(row.created_at),
            isnothing(row.updated_at) ? nothing : DateTime(row.updated_at)
        )
    end

    return nothing
end

"""
Save refresh token
"""
function save_refresh_token(db::SQLite.DB, user_id::Int, token::String, expires_at::DateTime)
    DBInterface.execute(db, """
        INSERT INTO refresh_tokens (user_id, token, expires_at)
        VALUES (?, ?, ?)
    """, [user_id, token, string(expires_at)])
end

"""
Find refresh token
"""
function find_refresh_token(db::SQLite.DB, token::String)::Union{NamedTuple, Nothing}
    result = DBInterface.execute(db, """
        SELECT user_id, expires_at
        FROM refresh_tokens
        WHERE token = ?
    """, [token])

    for row in result
        return (user_id = row.user_id, expires_at = DateTime(row.expires_at))
    end

    return nothing
end

"""
Delete refresh token
"""
function delete_refresh_token(db::SQLite.DB, token::String)
    DBInterface.execute(db, """
        DELETE FROM refresh_tokens WHERE token = ?
    """, [token])
end

"""
Delete all refresh tokens for a user
"""
function delete_user_refresh_tokens(db::SQLite.DB, user_id::Int)
    DBInterface.execute(db, """
        DELETE FROM refresh_tokens WHERE user_id = ?
    """, [user_id])
end

end # module

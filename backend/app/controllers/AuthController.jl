"""
Authentication Controller
"""
module AuthController

using Genie, Genie.Renderer.Json, Genie.Requests
using SQLite
using JSON3
using Dates
using HTTP

# Load models and utilities
include("../models/User.jl")
using .UserModel

include("../utils/JWTHelper.jl")
using .JWTHelper

# Database connection
include("../../config/env.jl")
using .EnvConfig

export signup, login, logout, refresh, me

"""
User signup endpoint
POST /api/auth/signup
Body: { email, password, name?, nickname?, birthdate?, gender? }
"""
function signup()
    # Handle CORS preflight
    if HTTP.method(Genie.Requests.getrequest()) == "OPTIONS"
        return Genie.Renderer.Json.json(Dict("status" => "ok"), headers = Dict(
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "POST, OPTIONS",
            "Access-Control-Allow-Headers" => "Content-Type, Authorization"
        ))
    end

    try
        # Get request body
        payload = Genie.Requests.jsonpayload()

        # Validate required fields
        if !haskey(payload, :email) || !haskey(payload, :password)
            return Genie.Renderer.Json.json(
                Dict("error" => "Email and password are required"),
                status = 400,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        email = string(payload[:email])
        password = string(payload[:password])

        # Validate email format
        if !occursin(r"^[^\s@]+@[^\s@]+\.[^\s@]+$", email)
            return Genie.Renderer.Json.json(
                Dict("error" => "Invalid email format"),
                status = 400,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        # Validate password length
        if length(password) < 6
            return Genie.Renderer.Json.json(
                Dict("error" => "Password must be at least 6 characters"),
                status = 400,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        # Optional fields
        name = haskey(payload, :name) ? string(payload[:name]) : nothing
        nickname = haskey(payload, :nickname) ? string(payload[:nickname]) : nothing
        birthdate = haskey(payload, :birthdate) ? string(payload[:birthdate]) : nothing
        gender = haskey(payload, :gender) ? string(payload[:gender]) : nothing

        # Create user
        db = get_db()
        user = create_user(db, email, password;
            name = name,
            nickname = nickname,
            birthdate = birthdate,
            gender = gender
        )

        if isnothing(user)
            return Genie.Renderer.Json.json(
                Dict("error" => "User already exists"),
                status = 409,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        # Generate tokens
        access_token = generate_access_token(user.id, user.email)
        refresh_token = generate_refresh_token(user.id)

        # Save refresh token to database
        save_refresh_token(db, user.id, refresh_token, get_refresh_token_expiry())

        # Return success response
        return Genie.Renderer.Json.json(
            Dict(
                "message" => "User created successfully",
                "user" => Dict(
                    "id" => user.id,
                    "email" => user.email,
                    "name" => user.name,
                    "nickname" => user.nickname,
                    "email_verified" => user.email_verified
                ),
                "access_token" => access_token,
                "refresh_token" => refresh_token
            ),
            status = 201,
            headers = Dict("Access-Control-Allow-Origin" => "*")
        )

    catch e
        @error "Signup error" exception=e
        return Genie.Renderer.Json.json(
            Dict("error" => "Internal server error"),
            status = 500,
            headers = Dict("Access-Control-Allow-Origin" => "*")
        )
    end
end

"""
User login endpoint
POST /api/auth/login
Body: { email, password }
"""
function login()
    # Handle CORS preflight
    if HTTP.method(Genie.Requests.getrequest()) == "OPTIONS"
        return Genie.Renderer.Json.json(Dict("status" => "ok"), headers = Dict(
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "POST, OPTIONS",
            "Access-Control-Allow-Headers" => "Content-Type, Authorization"
        ))
    end

    try
        # Get request body
        payload = Genie.Requests.jsonpayload()

        # Validate required fields
        if !haskey(payload, :email) || !haskey(payload, :password)
            return Genie.Renderer.Json.json(
                Dict("error" => "Email and password are required"),
                status = 400,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        email = string(payload[:email])
        password = string(payload[:password])

        # Find user
        db = get_db()
        user = find_user_by_email(db, email)

        if isnothing(user)
            return Genie.Renderer.Json.json(
                Dict("error" => "Invalid email or password"),
                status = 401,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        # Verify password
        if !verify_password(password, user.password_hash)
            return Genie.Renderer.Json.json(
                Dict("error" => "Invalid email or password"),
                status = 401,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        # Generate tokens
        access_token = generate_access_token(user.id, user.email)
        refresh_token = generate_refresh_token(user.id)

        # Save refresh token to database
        save_refresh_token(db, user.id, refresh_token, get_refresh_token_expiry())

        # Return success response
        return Genie.Renderer.Json.json(
            Dict(
                "message" => "Login successful",
                "user" => Dict(
                    "id" => user.id,
                    "email" => user.email,
                    "name" => user.name,
                    "nickname" => user.nickname,
                    "email_verified" => user.email_verified
                ),
                "access_token" => access_token,
                "refresh_token" => refresh_token
            ),
            headers = Dict("Access-Control-Allow-Origin" => "*")
        )

    catch e
        @error "Login error" exception=e
        return Genie.Renderer.Json.json(
            Dict("error" => "Internal server error"),
            status = 500,
            headers = Dict("Access-Control-Allow-Origin" => "*")
        )
    end
end

"""
Logout endpoint
POST /api/auth/logout
Headers: Authorization: Bearer <refresh_token>
"""
function logout()
    # Handle CORS preflight
    if HTTP.method(Genie.Requests.getrequest()) == "OPTIONS"
        return Genie.Renderer.Json.json(Dict("status" => "ok"), headers = Dict(
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "POST, OPTIONS",
            "Access-Control-Allow-Headers" => "Content-Type, Authorization"
        ))
    end

    try
        # Get refresh token from Authorization header
        auth_header = Genie.Requests.getheader("Authorization")
        if isnothing(auth_header) || !startswith(auth_header, "Bearer ")
            return Genie.Renderer.Json.json(
                Dict("error" => "No token provided"),
                status = 401,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        token = replace(auth_header, "Bearer " => "")

        # Delete refresh token
        db = get_db()
        delete_refresh_token(db, token)

        return Genie.Renderer.Json.json(
            Dict("message" => "Logged out successfully"),
            headers = Dict("Access-Control-Allow-Origin" => "*")
        )

    catch e
        @error "Logout error" exception=e
        return Genie.Renderer.Json.json(
            Dict("error" => "Internal server error"),
            status = 500,
            headers = Dict("Access-Control-Allow-Origin" => "*")
        )
    end
end

"""
Refresh access token endpoint
POST /api/auth/refresh
Headers: Authorization: Bearer <refresh_token>
"""
function refresh()
    # Handle CORS preflight
    if HTTP.method(Genie.Requests.getrequest()) == "OPTIONS"
        return Genie.Renderer.Json.json(Dict("status" => "ok"), headers = Dict(
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "POST, OPTIONS",
            "Access-Control-Allow-Headers" => "Content-Type, Authorization"
        ))
    end

    try
        # Get refresh token from Authorization header
        auth_header = Genie.Requests.getheader("Authorization")
        if isnothing(auth_header) || !startswith(auth_header, "Bearer ")
            return Genie.Renderer.Json.json(
                Dict("error" => "No token provided"),
                status = 401,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        token = replace(auth_header, "Bearer " => "")

        # Verify token
        payload = verify_token(token)
        if isnothing(payload)
            return Genie.Renderer.Json.json(
                Dict("error" => "Invalid or expired token"),
                status = 401,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        # Check if refresh token exists in database
        db = get_db()
        token_record = find_refresh_token(db, token)
        if isnothing(token_record)
            return Genie.Renderer.Json.json(
                Dict("error" => "Invalid refresh token"),
                status = 401,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        # Get user
        user_id = payload["user_id"]
        user = find_user_by_id(db, user_id)
        if isnothing(user)
            return Genie.Renderer.Json.json(
                Dict("error" => "User not found"),
                status = 404,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        # Generate new access token
        access_token = generate_access_token(user.id, user.email)

        return Genie.Renderer.Json.json(
            Dict(
                "access_token" => access_token
            ),
            headers = Dict("Access-Control-Allow-Origin" => "*")
        )

    catch e
        @error "Refresh error" exception=e
        return Genie.Renderer.Json.json(
            Dict("error" => "Internal server error"),
            status = 500,
            headers = Dict("Access-Control-Allow-Origin" => "*")
        )
    end
end

"""
Get current user endpoint
GET /api/auth/me
Headers: Authorization: Bearer <access_token>
"""
function me()
    # Handle CORS preflight
    if HTTP.method(Genie.Requests.getrequest()) == "OPTIONS"
        return Genie.Renderer.Json.json(Dict("status" => "ok"), headers = Dict(
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "GET, OPTIONS",
            "Access-Control-Allow-Headers" => "Content-Type, Authorization"
        ))
    end

    try
        # Get access token from Authorization header
        auth_header = Genie.Requests.getheader("Authorization")
        if isnothing(auth_header) || !startswith(auth_header, "Bearer ")
            return Genie.Renderer.Json.json(
                Dict("error" => "No token provided"),
                status = 401,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        token = replace(auth_header, "Bearer " => "")

        # Verify token
        payload = verify_token(token)
        if isnothing(payload)
            return Genie.Renderer.Json.json(
                Dict("error" => "Invalid or expired token"),
                status = 401,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        # Get user
        user_id = payload["user_id"]
        db = get_db()
        user = find_user_by_id(db, user_id)

        if isnothing(user)
            return Genie.Renderer.Json.json(
                Dict("error" => "User not found"),
                status = 404,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        return Genie.Renderer.Json.json(
            Dict(
                "user" => Dict(
                    "id" => user.id,
                    "email" => user.email,
                    "name" => user.name,
                    "nickname" => user.nickname,
                    "birthdate" => user.birthdate,
                    "gender" => user.gender,
                    "email_verified" => user.email_verified,
                    "created_at" => user.created_at
                )
            ),
            headers = Dict("Access-Control-Allow-Origin" => "*")
        )

    catch e
        @error "Me error" exception=e
        return Genie.Renderer.Json.json(
            Dict("error" => "Internal server error"),
            status = 500,
            headers = Dict("Access-Control-Allow-Origin" => "*")
        )
    end
end

end # module

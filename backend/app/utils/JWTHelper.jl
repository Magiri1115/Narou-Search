"""
JWT Helper Module
"""
module JWTHelper

using Dates
using JSON3
using Base64
using SHA
using Random

export generate_access_token, generate_refresh_token, verify_token, decode_token

# Secret key for JWT (should be in environment variable in production)
const JWT_SECRET = get(ENV, "JWT_SECRET", "your-secret-key-change-this-in-production")
const ACCESS_TOKEN_EXPIRY = Hour(1)
const REFRESH_TOKEN_EXPIRY = Day(30)

"""
Base64 URL encoding
"""
function base64url_encode(data::Vector{UInt8})::String
    encoded = base64encode(data)
    # Replace characters and remove padding
    encoded = replace(encoded, "+" => "-")
    encoded = replace(encoded, "/" => "_")
    encoded = replace(encoded, r"=+$" => "")
    return encoded
end

"""
Base64 URL decoding
"""
function base64url_decode(data::String)::Vector{UInt8}
    # Add padding if needed
    data = replace(data, "-" => "+")
    data = replace(data, "_" => "/")
    padding = 4 - (length(data) % 4)
    if padding != 4
        data = data * repeat("=", padding)
    end
    return base64decode(data)
end

"""
Create HMAC SHA256 signature
"""
function create_signature(message::String, secret::String)::String
    # Simple HMAC implementation (for production, use a proper crypto library)
    key_bytes = Vector{UInt8}(secret)
    message_bytes = Vector{UInt8}(message)

    # If key is longer than block size (64 bytes for SHA256), hash it
    if length(key_bytes) > 64
        key_bytes = SHA.sha256(key_bytes)
    end

    # Pad key to block size
    if length(key_bytes) < 64
        key_bytes = vcat(key_bytes, zeros(UInt8, 64 - length(key_bytes)))
    end

    # Create inner and outer padded keys
    ipad = UInt8(0x36)
    opad = UInt8(0x5c)

    inner_key = key_bytes .⊻ ipad
    outer_key = key_bytes .⊻ opad

    # HMAC = H(outer_key || H(inner_key || message))
    inner_hash = SHA.sha256(vcat(inner_key, message_bytes))
    hmac = SHA.sha256(vcat(outer_key, inner_hash))

    return base64url_encode(hmac)
end

"""
Generate JWT token
"""
function generate_token(payload::Dict, expiry::Period)::String
    # Header
    header = Dict(
        "alg" => "HS256",
        "typ" => "JWT"
    )

    # Add expiry to payload
    payload["exp"] = string(now() + expiry)
    payload["iat"] = string(now())

    # Encode header and payload
    header_json = JSON3.write(header)
    payload_json = JSON3.write(payload)

    header_encoded = base64url_encode(Vector{UInt8}(header_json))
    payload_encoded = base64url_encode(Vector{UInt8}(payload_json))

    # Create signature
    message = "$header_encoded.$payload_encoded"
    signature = create_signature(message, JWT_SECRET)

    return "$message.$signature"
end

"""
Generate access token
"""
function generate_access_token(user_id::Int, email::String)::String
    payload = Dict(
        "user_id" => user_id,
        "email" => email,
        "type" => "access"
    )
    return generate_token(payload, ACCESS_TOKEN_EXPIRY)
end

"""
Generate refresh token
"""
function generate_refresh_token(user_id::Int)::String
    payload = Dict(
        "user_id" => user_id,
        "type" => "refresh",
        "jti" => string(uuid4())  # Unique token ID
    )
    return generate_token(payload, REFRESH_TOKEN_EXPIRY)
end

"""
Decode JWT token (without verification)
"""
function decode_token(token::String)::Union{Dict, Nothing}
    parts = split(token, ".")
    if length(parts) != 3
        return nothing
    end

    try
        payload_json = String(base64url_decode(parts[2]))
        payload = JSON3.read(payload_json, Dict)
        return payload
    catch e
        @error "Failed to decode token" exception=e
        return nothing
    end
end

"""
Verify JWT token
"""
function verify_token(token::String)::Union{Dict, Nothing}
    parts = split(token, ".")
    if length(parts) != 3
        return nothing
    end

    # Verify signature
    message = "$(parts[1]).$(parts[2])"
    expected_signature = create_signature(message, JWT_SECRET)

    if parts[3] != expected_signature
        @warn "Invalid token signature"
        return nothing
    end

    # Decode payload
    payload = decode_token(token)
    if isnothing(payload)
        return nothing
    end

    # Check expiry
    if haskey(payload, "exp")
        exp = DateTime(payload["exp"])
        if exp < now()
            @warn "Token expired"
            return nothing
        end
    end

    return payload
end

"""
Get refresh token expiry datetime
"""
function get_refresh_token_expiry()::DateTime
    return now() + REFRESH_TOKEN_EXPIRY
end

end # module

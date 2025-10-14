"""
Authentication Middleware
"""
module AuthMiddleware

using Genie, Genie.Renderer.Json, Genie.Requests

# Load utilities
include("../utils/JWTHelper.jl")
using .JWTHelper

include("../models/User.jl")
using .UserModel

include("../../config/env.jl")
using .EnvConfig

export require_auth, get_current_user

"""
Get current user from request
Returns user_id if authenticated, nothing otherwise
"""
function get_current_user()::Union{Int, Nothing}
    try
        # Get access token from Authorization header
        auth_header = Genie.Requests.getheader("Authorization")
        if isnothing(auth_header) || !startswith(auth_header, "Bearer ")
            return nothing
        end

        token = replace(auth_header, "Bearer " => "")

        # Verify token
        payload = verify_token(token)
        if isnothing(payload)
            return nothing
        end

        # Return user_id
        return payload["user_id"]
    catch
        return nothing
    end
end

"""
Middleware to require authentication
Usage: Add this before protected route handlers
"""
function require_auth(handler)
    return function()
        # Handle CORS preflight
        if Genie.Router.method() == "OPTIONS"
            return Genie.Renderer.Json.json(Dict("status" => "ok"), headers = Dict(
                "Access-Control-Allow-Origin" => "*",
                "Access-Control-Allow-Methods" => "GET, POST, PUT, DELETE, OPTIONS",
                "Access-Control-Allow-Headers" => "Content-Type, Authorization"
            ))
        end

        user_id = get_current_user()

        if isnothing(user_id)
            return Genie.Renderer.Json.json(
                Dict("error" => "Unauthorized - Please login"),
                status = 401,
                headers = Dict("Access-Control-Allow-Origin" => "*")
            )
        end

        # User is authenticated, proceed to handler
        # Store user_id in params for handler to use
        Genie.Requests.payload(:user_id, user_id)

        return handler()
    end
end

end # module

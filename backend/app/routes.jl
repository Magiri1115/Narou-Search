

using Genie.Router

include("controllers/SearchController.jl")
using .SearchController


route("/") do
    "Narou Search API - OK"
end

route("/search", SearchController.search, method = GET)
route("/search", SearchController.search, method = POST)
route("/search", SearchController.search, method = OPTIONS)

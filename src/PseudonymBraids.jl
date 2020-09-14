module PseudonymBraids

import PeaceCypher: sign, hash
using PeaceCypher

using Tables
using SynchronicBallot
using Sockets
using Pkg.TOML

# For keychain I will likely need a method `newsigner`

abstract type Agent end
abstract type Action end
abstract type Braid end


include("core.jl")
include("sbraids.jl")
include("sbraider.jl")
include("keychains.jl")

export Guardian, Registrator, Member, Braider
export Transaction, pseudonyms, BraidChain, Contract
export SynchronicBraider

end # module

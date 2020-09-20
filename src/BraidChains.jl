module BraidChains

import PeaceCypher: sign, hash
using PeaceCypher

using SynchronicBallot
import SynchronicBallot: Mix, GateKeeper

using Tables
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

# I could capitalize every letter to sepperate Agents from everyone else
# export GUARDIAN, REGISTRATOR, MEMBER, BRAIDER

export Guardian, Registrator, Member, Braider, Agent
export Transaction, pseudonyms, BraidChain, Contract, state

export BraiderConfig, Mix, GateKeeper, BraidOfficer, braid

export TransactionLog, TransactionHole, Trigger, TransactionVector

export KeyChain, braid!, update!

end # module

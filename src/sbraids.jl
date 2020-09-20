#using Infiltrator

function fold(dict::Dict)
    io = IOBuffer()
    TOML.print(io, dict)
    return take!(io)
end

unfold(bytes::Vector{UInt8}) = TOML.parse(String(copy(bytes)))


struct Contract 
    signatures::Vector
end

Contract(signatures::Vector{Vector{UInt8}}) = Dict[unfold(s) for s in signatures]

PeaceCypher.id(c::Contract, notary::Notary) = [id(s, notary) for s in c.signatures]

function PeaceCypher.verify(document, c::Contract, notary::Notary)
    for signature in c.signatures
        verify(document, signature, notary) || return false
    end
    return true
end

struct Mixer <: Agent 
    mixer::ID
end


struct MetaData
    mix::ID
    gk::ID
    hash::Hash
end

function Base.Dict(m::MetaData)
    dict = Dict()
    dict["mix"] = string(m.mix, base=16)
    dict["gk"] = string(m.gk, base=16)
    dict["N"] = m.hash.N
    dict["hash"] = string(m.hash.hash, base=16)
    return dict
end

function MetaData(dict::Dict)

    mix = parse(BigInt, dict["mix"], base=16)
    gk = parse(BigInt, dict["gk"], base=16)
    N = dict["N"]
    hash = parse(BigInt, dict["hash"], base=16)

    return MetaData(ID(mix), ID(gk), Hash(N, hash))
end

struct SynchronicBraid <: Braid
    metadata::MetaData
    pseudonyms::Vector{ID}
end

function SynchronicBraid(ballot::Ballot)
    metadata = MetaData(unfold(ballot.metadata))
    pseudonyms = ID[]
    
    for i in 1:size(ballot.votes, 2)
        bytes = ballot.votes[:,i]
        str = String(copy(bytes))
        id = parse(BigInt, str, base=16)
        push!(pseudonyms, ID(id))
    end

    return SynchronicBraid(metadata, pseudonyms)
end




# struct SynchronicBraid{ID} <: Braid
#     braider::ID #Braider{ID}
#     mix::ID #Mixer{ID}
#     hash::Hash
#     pseudonyms::Vector{ID}
# end

pseudonyms(braid::SynchronicBraid) = braid.pseudonyms

function validate(state::State, braid::SynchronicBraid, signers::Vector) 
#    @infiltrate
    # for id in braid.pseudonyms
    #     id in state.pseudonyms || return false
    # end

    length(unique(braid.pseudonyms)) == length(unique(signers)) == length(signers) || return false

    braid.metadata.gk in state.braiders || return false

    for signer in signers
        signer in state.pseudonyms || return false
    end

    return true
end


function Base.push!(tlog::BraidChain, row::Transaction{T}) where T <: Braid
    #signers = [id(s, tlog.crypto) for s in row.signatures]
    signers = id(row.signature, tlog.notary)
    
    @assert validate(tlog.state, row.document, signers)

    ### At this point we are also able to validate also that ledger is also validated by hashes
    
    @assert validate(tlog, row.document.metadata.hash)

    @assert verify(row.document, row.signature, tlog.notary)

    push!(tlog.state, row.document, signers)
    push!(tlog.transactions, row)
end

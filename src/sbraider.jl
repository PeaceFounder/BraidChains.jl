# This is where most of the code from PeaceVote will go

# abstract type AbstractPort end


### Could have additional information on regulation 
struct BraiderConfig
    N::UInt8
    M::UInt8
    gk::GateKeeper
end


# DHasym, DHsym 

struct BraidOfficer <: Officer
    sb::BraiderConfig
    bc::BraidChain
end

### This module actually specifies seal method with fold and unfold. I could use thoose for unfolding data to a Dictionary. It should be arguable whether it would not be better to type each signature

function SynchronicBallot.regulation(bo::BraidOfficer)

    N, M = bo.sb.N, bo.sb.M
    mix = bo.sb.gk.mix.id
    gk = bo.sb.gk.id
    hash = Hash(bo.bc)

    metadata = MetaData(mix, gk, hash)
    mbytes = fold(Dict(metadata))
    
    return Regulation(N, M, mbytes)
end

Base.in(id, bo::BraidOfficer) = id in pseudonyms(bo.bc)


function SynchronicBallot.audit!(bo::BraidOfficer, ballot::Ballot, signatures)

    braid = SynchronicBraid(ballot)
    contract = Contract(Dict[unfold(i) for i in signatures])
    transaction = Transaction(braid, contract)
    push!(bo.bc, transaction)

    return nothing
end


function validate(sb::SynchronicBraid, bo::BraidOfficer, id)
    bc, tlog = bo.sb, bo.bc

    metadata = sb.metadata

    validate(tlog, metadata.hash) || return false
    bc.gk.id == metadata.gk || return false
    bc.gk.mix.id == metadata.mix || return false
    
    id in sb.pseudonyms || return false
    
    return true
end


serve!(bo::BraidOfficer, signer::Signer) = SynchronicBallot.serve!(bo.sb.gk, bo, signer)



function braid(oldsigner::Signer, newsigner::Signer, bo::BraidOfficer)

    newid = id(newsigner)
    idbytes = Vector{UInt8}(newid, base=16, length=bo.sb.M)    


    signbraid = (ballot) -> begin
        braid = SynchronicBraid(ballot)
        @assert validate(braid, bo, newid)
        signature = sign(braid, oldsigner)
        fold(Dict(signature))
    end
    
    vote(idbytes, bo.sb.gk, oldsigner, signbraid)
    
    return nothing
end

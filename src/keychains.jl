# Key managment for braiding from PeaceVote. 


mutable struct Key
    id::ID
    key
    generated::UInt64
    created::Union{Int, Nothing}
    expired::Union{Int, Nothing}
end

function newkey(notary::Notary)
    signer = newsigner(notary)

    thisid = id(signer)
    key = signer.key
    t = time_ns()
    
    return Key(thisid, key, t, nothing, nothing)
end


mutable struct KeyChain
    keys::Vector{Key}
    id::ID
    notary::Notary
    index::Int ### Keeps track on the position where the braidchain had been validated
end

KeyChain(keys::Vector{Key}, id::ID, notary::Notary) = KeyChain(keys, id, notary, 0)


PeaceCypher.id(kc::KeyChain) = kc.id


function generate_key!(kc::KeyChain)
    key = newkey(kc.notary)
    push!(kc.keys, key)

    return Signer(key.key, kc.notary)
    #return key.id
end

function KeyChain(notary::Notary)
    key = newkey(notary)
    kc = KeyChain(Key[key], key.id, notary)
    return kc
end


function set_created!(keys::Vector{Key}, id::ID, n::Int)

    for key in keys
        if key.id == id
            #@assert isnothing(key.created)
            key.created = n
        end
    end

    return nothing
end

function set_expired!(keys::Vector{Key}, id::ID, n::Int)

    for key in keys
        if key.id == id
            key.expired = n
        end
    end

    return nothing
end

function Base.push!(kc::KeyChain, x::Transaction)
    kc.index += 1
end

function Base.push!(kc::KeyChain, t::Transaction{Member})
    kc.index += 1

    cid = t.document.id
    set_created!(kc.keys, cid, kc.index)
        
    return nothing
end

function Base.push!(kc::KeyChain, t::Transaction{T}) where T <: Braid
    kc.index += 1
    
    for cid in pseudonyms(t.document)
        set_created!(kc.keys, cid, kc.index)
    end

    for eid in id(t.signature, kc.notary)
        set_expired!(kc.keys, eid, kc.index)
    end 

    return nothing    
end


function get_signer(kc::KeyChain, n::Int)
    for ki in kc.keys
        if ki.created <= n && ( isnothing(ki.expired) || ki.expired > n)
            return Signer(ki.key, kc.notary)
        end
    end
end

#get_signer(kc::KeyChain) = get_signer(kc, kc.index)

Base.lastindex(kc::KeyChain) = kc.index
Base.getindex(kc::KeyChain, n::Int) = get_signer(kc, n)


function update!(kc::KeyChain, bc::BraidChain)
    i0 = kc.index + 1
    for i in i0:length(bc.transactions)
        push!(kc, bc.transactions[i])
    end
end


function addtrigger!(kc::KeyChain, bc::BraidChain)

    transactions = bc.transactions
    trigger = Trigger(transactions, t -> update!(kc, bc))
    bc.transactions = trigger

    return nothing
end


function braid!(kc::KeyChain, bo::BraidOfficer)
    oldsigner = kc[end]
    newsigner = generate_key!(kc)
    
    braid(oldsigner, newsigner, bo)
end



# The API I would like to have

# vote(proposal, keychain)
# keychain[n] would return a valid signer whoose id is in the pseudonyms.
# @test id(keychain[n]) in pseudonyms(bc, n)
# braid!(keychain, braidchain). The braid command proceeds with last confirmed key. 
# The keychain could already store a last index so it would not need to go through all transactions again.





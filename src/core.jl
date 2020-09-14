struct Guardian{ID} <: Agent 
    id::ID
end

struct Registrator{ID} <: Agent
    id::ID
end

struct Member{ID} <: Agent
    id::ID
end

struct Braider{ID} <: Agent 
    id::ID
end

### I could have S argument but I would not need to dispatch on it
### The signature could be a just a String if necessary
struct Transaction{T} # where T <: Union{Agent,Action,Braid}
    document::T
    signature
end

Transaction(x, s::Signature) = Transaction(x, Dict(s))
Transaction(x, s::Signer) = Transaction(x, sign(x, s))

# The next step would be to define expanded Transaction with signers unpacked

### For each pseudonym I could also keep track of anonymity set size
### That could be something to consider in the future

struct State{ID}
    guardian::ID
    members::Set{ID}
    pseudonyms::Set{ID}
    registrators::Set{ID}
    braiders::Set{ID}
end

State{ID}(guardian::Guardian{ID}) where ID = State(guardian.id,Set{ID}(),Set{ID}(),Set{ID}(),Set{ID}())
State(guardian::Guardian{ID}) where ID = State{ID}(guardian)

function Base.push!(state::State, registrator::Registrator)
    push!(state.registrators, registrator.id)    
end

function Base.push!(state::State, member::Member)
    push!(state.members, member.id)
    push!(state.pseudonyms, member.id)
end

function Base.push!(state::State, braider::Braider)
    push!(state.braiders, braider.id)
end

function Base.push!(state::State{ID}, braid::Braid, signers::Vector{ID}) where ID
    for signer in signers
        pop!(state.pseudonyms, signer)
    end
    
    for id in pseudonyms(braid)
        push!(state.pseudonyms, id)
    end
end


# Validation of power of the signer to add an element of the sort. Also validates that something like dublicate is not beeing added.

function validate(state::State{ID}, registrator::Registrator{ID}, signer::ID) where ID 
    if registrator.id in state.registrators return false end
    return signer == state.guardian
end

function validate(state::State{ID}, member::Member{ID}, signer::ID) where ID
    if member.id in state.members return false end
    return signer == state.guardian || signer in state.registrators
end

function validate(state::State{ID}, braider::Braider{ID}, signer::ID) where ID
    if braider.id in state.braiders return false end
    return signer == state.guardian 
end


# Before one pushes the state it is necessary to validate. On the other hand if validation had already bben done then push! as a raw thing makes sense for recovery of intermidiate states.


struct BraidChain 
    transactions::Vector{Transaction}
    notary::Notary
    state::State
end

BraidChain(guardian::Guardian{ID}, notary::Notary) where ID = BraidChain(Transaction[],notary,State{ID}(guardian))


Tables.istable(::Type{BraidChain}) = true

Tables.isrowtable(::Type{BraidChain}) = true

Tables.rows(log::BraidChain) = log.transactions

Base.eltype(log::BraidChain) = Transaction
Base.length(log::BraidChain) = length(log.transactions)

### I could perhaps add another field for the row!


# struct TransactionRow{T} <: Tables.AbstractRow
#     row::Int
#     source::BraidChain
# end

# Base.iterate(log::BraidChain, st=1) = st > length(log) ? nothing : (TransactionRow(st, log), st + 1)

# getcolumn(m::TransactionRow, ::Type, col::Int, nm::Symbol) =
#     getfield(getfield(m, :source), :matrix)[getfield(m, :row), col]
# getcolumn(m::MatrixRow, i::Int) =
#     getfield(getfield(m, :source), :matrix)[getfield(m, :row), i]
# getcolumn(m::MatrixRow, nm::Symbol) =
#     getfield(getfield(m, :source), :matrix)[getfield(m, :row), getfield(getfield(m, :source), :lookup)[nm]]
# columnnames(m::MatrixRow) = names(getfield(m, :source))



function Base.push!(log::BraidChain, row::Transaction{T}) where T
    signerid = id(row.signature, log.notary)

    @assert validate(log.state, row.document, signerid)
    @assert verify(row.document, row.signature, log.notary)

    push!(log.state, row.document)
    push!(log.transactions, row)
end


function Base.append!(log::BraidChain, rows::Vector{Transaction}) 
    for row in rows
        push!(log, row)
    end
end


pseudonyms(tlog::BraidChain) = tlog.state.pseudonyms

function pseudonyms(tlog::BraidChain, n::Int)
    @assert length(tlog.transactions) >= n

    state = State(Guardian(tlog.state.guardian))
    
    for transaction in tlog.transactions[1:n]
        if transaction.document isa Braid
            signers = [id(s, tlog.crypto) for s in row.signature]
            push!(state, transaction.document, signers)
        else
            push!(state, transaction.document)
        end
    end

    return state.pseudonyms
end


function PeaceCypher.hash(tlog::BraidChain, N::Int)
    str = "$(tlog.transactions[1:N])"
    return hash(str, tlog.notary)
end

struct Hash
    N::Int
    hash
end

Hash(tlog::BraidChain, N::Int) = Hash(N,hash(tlog, N))
Hash(tlog::BraidChain) = Hash(tlog, length(tlog))


validate(tlog::BraidChain, th::Hash) = hash(tlog, th.N) == th.hash

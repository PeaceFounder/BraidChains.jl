using PseudonymBraids: AbstractCrypto, AbstractSigner

struct Crypto <: AbstractCrypto end

struct Signer <: AbstractSigner end

sign(data,s::Signer) = nothing

verify(crypto::Crypto,data,signature) = nothing
SecureSocket(crypto::Crypto,socket::IO,key) = nothing
G(crypto::Crypto) = nothing
rngint(crypto::Crypto) = nothing

crypto = Crypto()

# Somewhere far far away

mixer = Signer(crypto)

MIXER_PORT = 2000
MIXER_ID = id(mixer)

mix = Mixer(crypto, MIXER_PORT, MIXER_ID)
@async serve(mix, mixer)

# Using the mixer

guardian = Signer(crypto)
tlog = TransactionLog(crypto, id(guardian))

registrator = Signer(crypto)
reg = Registrator(id(registrator))
append!(tlog, reg, guardian)

braider = Signer(crypto)
braiderconf = Braider(crypto, mix, 3, 64, id(braider))

@async serve!(braiderconf, tlog, braider) # one here could also include delay for the hash put in the ledger. 

# Users perspective

user = Signer(crypto)

# on the server
member = Member(id(user))
append!(tlog, member, registrator)

# back to user

kc = KeyChain(crypto, user)
braid!(braidconf, tlog, kc)

# Now we can analyze the transaction log

pseudonyms(tlog) # returns the current pseudonyms who are able to braid
pseudonyms(tlog, n) # returns pseudonyms at row n

hash(tlog, n) # returns the ledger hashes

sign(data,n,kc) # signs data with coresponding pseudonym tagged by nth row in the TransactionLog

# For construction it shall also be able to construct the transaction log quickly:

append!(tlog, [(data, sig)], validate=false) 

# this way some final state is being constructed

### Theese methods also return n up to which transaction log is valid. 
validate!(tlog) # does a proper thing # default is :all
validate!(tlog, type=:hash) 
validate!(tlog, type=:signatures) 

# To get the current state one does
state(tlog) 

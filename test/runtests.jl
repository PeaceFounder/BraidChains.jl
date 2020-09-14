import PeaceCypher: sign, hash
using PeaceCypher
using PseudonymBraids: AbstractCrypto, AbstractSigner

using SynchronicBallot

notary = Notary()
cypher = CypherSuite(notary)


# Somewhere far far away

mixkey = newsigner(notary)

MIX_PORT = 2000
MIX_ID = id(mixkey)

mix = Mix(notary, MIX_PORT, MIX_ID)
@async serve(mix, mixkey)

# Using the mixer

guardiankey = newsigner(notary)
tlog = TransactionLog(notary, id(guardiankey))

registrator = newsigner(notary)
reg = Registrator(id(registrator))
push!(tlog, Transaction(reg, guardiankey))

braider = newsigner(notary)

push!(tlog, Transaction(Braider(id(braider)), guardiankey))

### TODO ####
braiderconf = SynchronicBraider(cypher, mix, 3, 64, id(braider))
@async serve!(braiderconf, tlog, braider) # one here could also include delay for the hash put in the ledger. 
################

# Users perspective

user = newsigner(notary)

# on the server
push!(tlog, Transaction(Member(id(user)), registrator))

# back to user

### TODO #####
kc = KeyChain(notary, user)
braid!(braidconf, tlog, kc)
###############

# Now we can analyze the transaction log

pseudonyms(tlog) # returns the current pseudonyms who are able to braid
pseudonyms(tlog, n) # returns pseudonyms at row n

hash(tlog, n) # returns the ledger hashes

### TODO ######
# perhaps kc[n] could select the key for nth row 
sign(data,n,kc) # signs data with coresponding pseudonym tagged by nth row in the TransactionLog
#########

# To get the current state one does
state(tlog) 

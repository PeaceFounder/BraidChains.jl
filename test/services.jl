notary = Notary()
cypher = CypherSuite(notary)

# Somewhere far far away

mixkey = newsigner(notary)

MIX_PORT = 2000
MIX_ID = id(mixkey)

mix = Mix(MIX_PORT, MIX_ID, cypher)
@async SynchronicBallot.serve(mix, mixkey)

sleep(1.)

# Using the mixer

guardiankey = newsigner(notary)
transactions = Trigger(TransactionVector(), t -> println(typeof(t.document)))
tlog = BraidChain(transactions, Guardian(id(guardiankey)), notary)

registrator = newsigner(notary)
reg = Registrator(id(registrator))
push!(tlog, Transaction(reg, guardiankey))

braider = newsigner(notary)

push!(tlog, Transaction(Braider(id(braider)), guardiankey))


gk = GateKeeper(2001, id(braider), cypher, mix)
sb = BraiderConfig(UInt8(3), UInt8(64), gk)
bo = BraidOfficer(sb, tlog)
botask = @async BraidChains.serve!(bo, braider) 
sleep(1.)


### Registration of members ###

member1key = newsigner(notary)
member2key = newsigner(notary)
member3key = newsigner(notary)

member1 = Member(id(member1key))
member2 = Member(id(member2key))
member3 = Member(id(member3key))

# on the server
push!(tlog, Transaction(member1, registrator))
push!(tlog, Transaction(member2, registrator))
push!(tlog, Transaction(member3, registrator))

# back to user

pseudonym1 = newsigner(notary)
pseudonym2 = newsigner(notary)
pseudonym3 = newsigner(notary)

@show istaskstarted(botask)

@sync begin
    @async braid(member1key, pseudonym1, bo)
    @async braid(member2key, pseudonym2, bo)
    @async braid(member3key, pseudonym3, bo)
end


### Some tests

@test pseudonyms(tlog, 5) == Set([id(member1key), id(member2key), id(member3key)]) == tlog.state.members
@test pseudonyms(tlog) == Set([id(pseudonym1), id(pseudonym2), id(pseudonym3)])
@test tlog.state.braiders == Set([id(braider)])
@test tlog.state.registrators == Set([id(registrator)])



# ### TODO #####
# kc = KeyChain(notary, user)
# braid!(braidconf, tlog, kc)
# ###############


# ### TODO ######
# # perhaps kc[n] could select the key for nth row 
# sign(data,n,kc) # signs data with coresponding pseudonym tagged by nth row in the TransactionLog
# #########


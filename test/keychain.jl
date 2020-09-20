notary = Notary()
cypher = CypherSuite(notary)

# Somewhere far far away

mixkey = newsigner(notary)

MIX_PORT = 3000
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


gk = GateKeeper(3001, id(braider), cypher, mix)
sb = BraiderConfig(UInt8(3), UInt8(64), gk)
bo = BraidOfficer(sb, tlog)
botask = @async BraidChains.serve!(bo, braider) 
sleep(1.)


### Registration of members ###

member1 = KeyChain(notary)
member2 = KeyChain(notary)
member3 = KeyChain(notary)

# on the server
push!(tlog, Transaction(Member(id(member1)), registrator))
push!(tlog, Transaction(Member(id(member2)), registrator))
push!(tlog, Transaction(Member(id(member3)), registrator))


update!(member1, tlog)
update!(member2, tlog)
update!(member3, tlog)


@show istaskstarted(botask)

### First Braid

@sync begin
    @async braid!(member1, bo)
    @async braid!(member2, bo)
    @async braid!(member3, bo)
end

### After that I shall repeat the procedure

sleep(1.)

update!(member1, tlog)
update!(member2, tlog)
update!(member3, tlog)

@test id(member1[end]) in pseudonyms(tlog)
@test id(member2[end]) in pseudonyms(tlog)
@test id(member3[end]) in pseudonyms(tlog)


### Second Braid

@sync begin
    @async braid!(member1, bo)
    @async braid!(member2, bo)
    @async braid!(member3, bo)
end

sleep(1.)

update!(member1, tlog)
update!(member2, tlog)
update!(member3, tlog)

@test id(member1[end]) in pseudonyms(tlog)
@test id(member2[end]) in pseudonyms(tlog)
@test id(member3[end]) in pseudonyms(tlog)





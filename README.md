
# PseudonymBraids

Authetification and anonimity does not merge well together and is a cornerstone for privecy preserving electroinc voting or electronic cash. Until now two approaches exist to solve the problem of anonymous authetification. Blind signatures allow creation of signatures of messages unliked to the person who asks them to the authorithy, with which one can have usual authetification. In contrast ring signatures allow creation of untracable signature locally on behalf of the group without involvment of the authorithy. Both schemes unfortunatelly are not directly applicable to electronivc voting where message is the vote and it is delivered with anonymous channel to ballot box.

Particularly for blind signature scheme there are two profound issues. In the process of signature generation the user may abort the protocol. Is it because network connection failed or because user has malicious intentions of obtaining two votes? The second issue is that the blind signature issuer is not accountable. It can maliciously issue additional signed votes as long as some voters abstain from elections, which often is quite a large popoulation, without leaving any traces. An eassy extension here would be to involve multiple parties forming a blind contract (each party makes a blind signature) if absolute consent is reached. 

On the other hand, the ring signature scheme with extension of linkability is not practical. To make a signature a substational computational resources are needed and signatures are large scaling with the size of the group. Thus unless anonimity set size is relaxed, grouping randomized in advance this scheme currently is not practical. Although amazingly it have found place in cryptocurrencies such as Monero for guaranteeing transaction untracability in a much more complex protocol.

The last aproach is to anonimize the signature through distributed computations on a block assuming that involed parties do not collaborate. This method requires that multiple participants execute the protocol at the same time perfoming a ballot over mixnetwork, dc netwoer or etc which afterwards is signed by each participant on the basis that the block contains participants message and is valid only if all participants had made the signature. This method is highly unpractical since any participant can abbort whoole protocol and every participant must be online when it is executed. On the other hand it only needs basic crytpography and is safe against aborts. 

In any of the scemes the message instead of a vote can be a new sers generated pseudonym itself which then is can be used to sign the votes. A benefit of such additional complexitiy is that the pseudonym can be used to authorize a new pseudonym anonymously allowing to increse the anonimity set size incrimentally and thus number of participants in each run can be small. This process I call a pseudonym braiding whihc in the result forms untiable knot (braid). The braids are stored in a transaction log allowing to fix the state of the system for external applications such as voting. 

## Design

This package implements the netwokr protocol which happens to be rather complex thus all care had been done to limit all necessary dependencies to minimum and put storage, syncronization, socket anonimization as another layer by type composition. The goal of this package is to provide client API and server services to do braiding which produces anonymous pseudonyms which can be used for electronic voting, electronic cash and vehicular networks VANETs. 

## Status

Currently the API is almost finalized and is shown in the tests. The some code had already been written in `PeaceVote` package which needs to be upstreamed here. Some code would also need to be written. And lastly a proper docstrings needs to be written for the exported symbols as well as docs.

The protocol for braiding currently lacks code which would prevent for single memeber to spoil every braid and thus making the braiding service broken. Some blacklisting strategies of the pseudonyms needs to be thought about and implemented. Additionally a different braiders implemented by making participants of the braid part of the mixnet and thus making services easier to deploy. 

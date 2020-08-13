# Summary

PseudonymBraids protocol allows to create a list of anonymous while legitimate pseudonyms which can be aplied to voting. This design works out details on how to interface the package to provide a remote electronic voting solution for the masses. The necessary components which shall be discussed is registration, syncronization, voting including casting and lastly counting.

# Motivation

The main challenge for the remote electronic voting system is to provide a public and trustless cryptographic proof that each vote is produced by a legitimate member who votes only once while still preserving strong privacy guarantees through distributed multiparty computations. Linkable ring signatures with TOR would be excellent but unfortunately are rather expensive computationally and in signature size. Alternatively, one can create an anonymous signature with a blind signature scheme, but it involves authority who has the ability to stuff ballot (no guarantees for legitimacy).

Instead we can use PseudonymBraids protocol for braiding pseudonyms through small trustless ballots for giving every member a chances to enlarge their anonymity set. In that way the proof of braiding through ballots is provided by PseudonymBraids package where everyone can ensure the legitimacy of the pseudonym by validating identities of the members. Thus a vote signed by a such pseudonym as consequency gives proof of legitimacy while preserving privacy through lost data in distributed multiparty computations when PseudonymBraids protocol is executed.

# Agents

For the project we have two roles a memeber and the guardian who can delegate his powers of maintaining the self-governing community deme. All participants and rolse can be found in `TransactionLog <: Table` which are appended there by the guardian designed hierarchy. A generic agent is created under abstract type `Agent` defined under `PseudonymBraids`. Concrete types are then defined

- `Guardian{ID} <: Agent` an agent which starts the transaction log and can append to the transaction log other agents.
- `Registrator{ID} <: Agent` is a pseudonym which can sign and append new members to the transaction log
- `Member{ID} <: Agent` is signed by the guardian or any other registrator
- `Braider{ID} <: Agent` is an agent who provides the service for braiding member pseudonyms.

In `PeaceVote` we shall subtype `Agent` to give a new role

- `Proposer{ID} <: Agent` one who is legitimate to put proposals for others to vote on. It might be a server or etc. The importance of this role is to prevent adversary of tampering of the proposals while they are delivered to the voter. 

It is fine for `Braider{ID}`, `Registrator{ID}` and `Proposer{ID}` to be hosted on the same server for convinience.

Additionally with agents `TransactionLog` stores subtypes of `Action`. Two kinds of actions are currently considered:

- `Stop{N} <: Action` stops the priveleges granted at `N`. For example that can be used to change keys of the servers in case a possible hack had happened. The stop action can be performed by the same agents who could add coresponding row to the table at that given time. 
- `ResetBraids <: Action` action which can be performed by the guardian to restart braiding from present memebers. This action is necessary to for ensuring that members who had been stoped no longer holds any powers.

# HTTP microservice

A note is that all HTTP requests needs to be performed with ip anonymization to prevent anyone to learn propbailities of particular pseudonym to be linked to that particular ip address. Or that particular ip address is currently voting.

## Access

To acces the services the configuration signed by guardian at entracnce link, let's say `mydeme.org/status`, is provided. The configuration contains:

- `UUID` of the deme and it's description
- Cryptography configuration as a string which is parsed by `PeaceCypher` package on which `PeaceVote` shall depend on.
- Configuration of the braider 
- Optional configuration of the provided mix. 
- And access point at which `TransactionLog` is hosted
- Date at which the configuration had been issued
- Hashes of previous configurations. That is necessary to ensure that the guardian's key had not been used by anyone else in the past.

Uppon anonymous download with TOR over HTTPS the configuration file is stored locally and further all new configurarions are saved and verified with provided signature to ensure that guardian does not change.

## Registration

To register for the deme a public pseudonym locally is generated. Then a link is opened `mydeme.org/profile?id=1235` where `1235` is the pseudonym (hash of the public key). That would oppen the right profile page registration where email address could be filled in and validated and/or other means of identification. If registration had been succesfull it is shown in that page and the id is signed and added to `TransactionLog`.

## Voting

To vote first one needs to get proposals. Uppon HTTP request `mydeme.org/proposals` which would provide all available proposals or the proposal can be accsessed by a hash `mydeme.org/proposals?pid=1332`. The later one could be useful to make self contained QR codes or other elements which can be embeded into web pages. Thoose elements would include

- `UUID` of the deme
- entrance link as backup if `UUID` can not be resolved
- hash of the proposal to download it locally

# User Interface

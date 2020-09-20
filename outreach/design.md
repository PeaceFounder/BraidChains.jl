# Update 20/09

Currently a lot of packages had been already registered with the Julia package registry. Some of thoose packages will change behavior:

- `Synchronizers` shall only be concerned on synchronization of anything which supports `Tables` interface
- `Recruiters` an HTTP server components which allows to register to a system by filling a WEB form and confirming email address with a link as it is often practiced.

Package `PeaceFounder` will provide electronic voting solution dealing with registration, synchronization, storage, vote casting and voting with HTTP and thus would be an end user application. Previosuly this role was filled by `PeaceVote`, due to a larger ambition of building a new ways of using internet. As the aims of that project started to become vague, the project for the sake of focus is currently dropped and thus also `DemeNet` package is stalled. The `PeaceVote` package name will be used to implement all different sorts of proposals and how one can count votes on them. 


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

The next step for the participant is to synchronize locally `TransactionLog`. The `PeaceVote` package defines a `RemoteTransactionLog` which stores `TransactionLog`, the access point and path at which cache is stored. For server it provides a `serve` method. Similarly `PeaceVote` extends `KeyChain` with `StoredKeyChain` which extends the `braid!` method to include storage calls.

## Registration

To register for the deme a public pseudonym locally is generated. Then a link is opened `mydeme.org/profile?id=1235` where `1235` is the pseudonym (hash of the public key). That would oppen the right profile page registration where email address could be filled in and validated and/or other means of identification. If registration had been succesfull it is shown in that page and the id is signed and added to `TransactionLog`.

## Voting

To vote first one needs to get proposals. Uppon HTTP request `mydeme.org/proposals` which would provide all available proposals or the proposal can be accsessed by a hash `mydeme.org/proposals?pid=1332`. The later one could be useful to make self contained QR codes or other elements which can be embeded into web pages. Thoose elements would include

- `UUID` of the deme
- entrance link as backup if `UUID` can not be resolved
- hash of the proposal to download it locally

The proposal itself contains metadata:

- `N` the state of the `TransactionLog` which determines pseudonym set who can participate in voting. (This is how double spending problem is solved).
- Date of creation or update
- Hash of parrent proposal in case updates had been made
- A type of the proposal which is subtype of `AbstractProposal`. The type determines how the vote on it should be filled, votes counted and etc.
- The metadata associated to the particular proposal type. How the votes shall be counted (like preferential way), time up to which votes can be delivered and etc.
- The main body of the proposal containing its name, description and question(s) with possible choices.

Filling out the proposal produces a vote. The `Vote` contains hash of the proposal and data produced making a vote in a `AbstractString` form. To improve clarity `TOML` will be used as the data format. 

To cast the vote `N` of the proposal is used to choose the right pseudonym from the `KeyChain` to sign it. The vote and the signature is then delivered with TOR to `mydeme.org/vote` which if succesfull returns the server signature of the vote together with signature. That is stored locally together with vote to prove in case of dispue that the vote was delivered to the ballot box. In case the vote is not accepted by the server while still being valid it can be given to the third party to confirm the fact. (the next section discusees antibribery and coercion mechanisms).

During or after the ballot (as specified in metadata of the proposal) all votes which were casted for the proposal can be downloaded from `mydeme.org/votes?pid=1332`. To count the votes a method `tally(proposal, votes)` which returns a subtype of `AbstractTally` which defines how the results shall be displayed on the screen. 

# Antibribery and anticoercion mechanism

There are two possible bribery/coercion mechanisms with the present system. The first one is that briber/coercer asks for a valid key of the pseudonym with which he/she could make votes himself. The second way is that briber/coercers asks to make a valid vote and give it to him/her before a delivery to the ballot box. Then the briber/coercer can cast the vote himself and check that it is sucesfully counted in the final tally.

To prevent sharing of the keys a tamper resistant hardware such as smartcard can be used. To make sure that everyone is using a tamper resitstant hardware the registration protocol entails creation of a vendor certificate for the member pseudonym from a secret vendor key stored in the card. The certificate then is validated before the pseudonym gets added to `TransactionLog`. The braiding is performed as usual trusting that vendors provided protocol prevents extraction of secret keys.

To prevent the second strategy where briber/coercer can cast the vote and observer that it is properly counted we can use a paper ballot as a backup strategy. At the voting station voter uses his pseudonym to sign a document stating that his vote is delivered as a paper ballot and then is allowed to enter voting booth to cast a vote. The last step for ellection officials is to count the paper ballot votes and discount any possible votes made by the pseudonyms which gave the paper ballot a priority. The final tally is published which is validated by independent auditors which keep participating pseudonyms in paper ballot confidential. Thus briber/coercer would never practially know whether the vote had been changed in the voting station.

# Deploy

A dcoker container could be used which uses PeaceVote and configures the service with in a Julia source file. 

- The guardian key generation
- The server key generation and key storage
- Adding agents to `TransactionLog`

# User Interface

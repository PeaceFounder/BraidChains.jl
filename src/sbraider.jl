# This is where most of the code from PeaceVote will go

abstract type AbstractPort end




# DHasym, DHsym 

struct BraidOfficer <: Officer
    N::UInt8
    M::UInt8
    bc::BraidChain
end



### This module actually specifies seal method with fold and unfold. I could use thoose for unfolding data to a Dictionary. It should be arguable whether it would not be better to type each signature






### Could have additional information on regulation 
struct SynchronicBraider
    gk::GateKeeper
end


function serve!(sb::SynchronicBraider, tlog::BraidChain, signer::Signer)
    
end

# ! stands for global state. 
function braid(oldsigner::Signer, newsigner::Signer, sb::SynchronicBraider, tlog::BraidChain)
    
end

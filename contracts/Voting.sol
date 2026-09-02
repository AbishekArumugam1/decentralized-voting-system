// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

// ===================================================== 
// Voting.sol — Gas-Optimized Decentralized Voting
// Deploy this on Sepolia testnet via Remix IDE 
// https://ethereum.org 
// ===================================================== 

contract Voting { 

    // ----------------------------------------------- 
    // DATA STRUCTURES & STATE VARIABLES
    // ----------------------------------------------- 

    struct Candidate { 
        string name; 
        uint256 voteCount; 
    } 

    // Dynamic array tracking current ballot candidates
    Candidate[] private candidates; 

    // Storage tracking address authorization status
    mapping(address => bool) public hasVoted; 

    // Administrative authority signature
    address public immutable owner; 

    // ----------------------------------------------- 
    // CUSTOM ERRORS (Gas-Saving Mechanism)
    // ----------------------------------------------- 
    error NotOwner();
    error AlreadyVoted();
    error InvalidCandidateIndex();

    // ----------------------------------------------- 
    // EVENTS
    // ----------------------------------------------- 
    event CandidateAdded(string name);
    event VoteCast(address indexed voter, uint256 indexed candidateIndex);

    // ----------------------------------------------- 
    // MODIFIERS
    // ----------------------------------------------- 
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    // ----------------------------------------------- 
    // CONSTRUCTOR & MUTABLE STATE LOGIC
    // ----------------------------------------------- 

    // Accepts initial array of candidate names on contract instantiation
    constructor(string[] memory _initialCandidates) {
        owner = msg.sender;
        uint256 length = _initialCandidates.length;
        
        for (uint256 i = 0; i < length; i++) {
            _addCandidate(_initialCandidates[i]);
        }
    }

    // Administrative interface to append candidates post-deployment
    function addCandidate(string calldata _name) external onlyOwner {
        _addCandidate(_name);
    }

    // Native execution pathway to register candidate state
    function _addCandidate(string memory _name) private {
        candidates.push(Candidate({
            name: _name,
            voteCount: 0
        }));
        emit CandidateAdded(_name);
    }

    // Primary execution path allowing distinct addresses to submit entry counts
    function vote(uint256 candidateIndex) external {
        if (hasVoted[msg.sender]) revert AlreadyVoted();
        if (candidateIndex >= candidates.length) revert InvalidCandidateIndex();

        hasVoted[msg.sender] = true; 
        candidates[candidateIndex].voteCount += 1; 

        emit VoteCast(msg.sender, candidateIndex); 
    } 

    // ----------------------------------------------- 
    // VIEW FUNCTIONS (Cost-free reads)
    // ----------------------------------------------- 

    // Exposes current state matrix directly to Web3 frontends
    function getCandidates() external view returns (Candidate[] memory) { 
        return candidates; 
    } 

    // Returns structural bounding count
    function getCandidateCount() external view returns (uint256) { 
        return candidates.length; 
    } 

    // External check verification logic
    function checkIfVoted(address voter) external view returns (bool) { 
        return hasVoted[voter]; 
    } 
}

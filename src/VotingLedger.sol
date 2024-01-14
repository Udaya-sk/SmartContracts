// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract VotingLedger {
    struct Vote {
        address owner;
        uint256 endTime;
        uint256[] votesMap;
        mapping(address => bool) votingAudit;
        uint256 options;
    }

    event memberAdded(address indexed member, uint256 joinedAt);
    event voteCreated(uint256 indexed voteId, uint256 addedAt);
    event voted(address indexed _member, uint256 votedAt);

    uint256 private nextVoteId;
    mapping(uint256 => Vote) votes;
    mapping(address => bool) members;

    function join() public {
        require(!members[msg.sender], "you already have the membership");
        members[msg.sender] = true;
        emit memberAdded(msg.sender, block.timestamp);
    }

    function createVote(uint256 endTs, uint256 options) external {
        require(endTs > block.timestamp, "invalid endTs");
        require(options >= 2 && options < 9, "Too many options");
        uint256 voteId = nextVoteId;
        votes[voteId].owner = msg.sender;
        votes[voteId].endTime = endTs;
        votes[voteId].options = options;
        votes[voteId].votesMap = new uint256[](options);
        emit voteCreated(voteId, block.timestamp);
        nextVoteId++;
    }

    modifier canVote(uint256 voteId, uint256 option) {
        require(voteId < nextVoteId, "invalid vote id");
        require(option < votes[voteId].options, "invalid options");
        require(members[msg.sender], "not a member");
        require(
            block.timestamp < votes[voteId].endTime,
            "voting window is closed"
        );
        require(
            !votes[voteId].votingAudit[msg.sender],
            "you already exercised your vote"
        );
        _;
    }

    function castMyVote(
        uint256 voteId,
        uint256 option
    ) external canVote(voteId, option) {
        votes[voteId].votesMap[option] += 1;
        emit voted(msg.sender, block.timestamp);
    }

    function getVote(
        uint256 voteId
    )
        external
        view
        returns (address, uint256 endTime, uint256[] memory voteMap)
    {
        require(voteId < nextVoteId, "invalid vote id");
        return (
            votes[voteId].owner,
            votes[voteId].endTime,
            votes[voteId].votesMap
        );
    }
}

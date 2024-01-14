// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Twitter {
    struct Tweet {
        uint256 id;
        address owner;
        string tweet;
        uint256 timestamp;
        uint256 likes;
    }

    address private owner;
    uint256 private MAX_TWEET_LENGTH = 20;
    mapping(address => Tweet[]) private tweets;
    event newTweetEvent(uint256 id, address author, string tweet);

    constructor() {
        owner = msg.sender;
    }

    function tweet(string memory _tweet) public {
        require(
            bytes(_tweet).length <= MAX_TWEET_LENGTH,
            "tweet length is long"
        );
        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            owner: msg.sender,
            tweet: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });
        tweets[msg.sender].push(newTweet);
        emit newTweetEvent(newTweet.id, newTweet.owner, newTweet.tweet);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner can tweet");
        _;
    }

    function changeTweetLength(uint256 len) public onlyOwner {
        MAX_TWEET_LENGTH = len;
    }

    function get(
        address _owner,
        uint256 index
    ) public view returns (Tweet memory) {
        return tweets[_owner][index];
    }

    function getTweet(
        address _owner,
        uint256 index
    ) public view returns (string memory) {
        return get(_owner, index).tweet;
    }

    function getAll(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }

    function likeTweet(address author, uint256 tweetId) external {
        require(tweets[author][tweetId].id == tweetId, "tweet does not exist");
        tweets[author][tweetId].likes++;
    }

    function unlikeTweet(address author, uint256 tweetId) external {
        require(tweets[author][tweetId].id == tweetId, "tweet does not exist");
        tweets[author][tweetId].likes--;
    }

    function getLikes(
        address author,
        uint256 tweetId
    ) external view returns (uint256) {
        require(tweets[author][tweetId].id == tweetId, "tweet does not exist");
        return tweets[author][tweetId].likes;
    }
}

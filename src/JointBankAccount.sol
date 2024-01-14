// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7 <0.9.0;

contract JointBankAccount {
    struct Account {
        address[] owners;
        uint256 balance;
        mapping(uint256 => WithDrawalRequest) withDrawals;
    }

    struct WithDrawalRequest {
        address user;
        uint256 amount;
        uint256 approvalCount;
        mapping(address => bool) approvals;
        bool isApproved;
    }

    mapping(uint256 => Account) public _accounts;
    mapping(address => uint256[]) public ownersAccount;

    uint256 public nextAccountId;
    uint256 public nextWithdrawalId;

    function createAccount(address[] memory accountOwners) external {
        _accounts[nextAccountId].owners = accountOwners;
        _accounts[nextAccountId].balance = 0;
        for (uint256 i = 0; i < accountOwners.length; i++) {
            ownersAccount[accountOwners[i]].push(nextAccountId);
        }
        nextAccountId++;
    }

    modifier ownersOnly(uint256 accountId) {
        require(
            isAccountPresent(accountId),
            "only owner can deposit or withdraw"
        );
        _;
    }

    function isAccountPresent(uint256 accountId) private view returns (bool) {
        uint256[] memory accounts = ownersAccount[msg.sender];
        for (uint i = 0; i < accounts.length; i++) {
            if (accounts[i] == accountId) {
                return true;
            }
        }
        return false;
    }

    modifier notApproved(uint256 accountId, uint256 withDrawReqId) {
        require(
            isAccountNotAlreadyApproved(accountId, withDrawReqId),
            "account already approved"
        );
        _;
    }

    function isAccountNotAlreadyApproved(
        uint256 accountId,
        uint256 withDrawReqId
    ) private view returns (bool) {
        return
            !_accounts[accountId].withDrawals[withDrawReqId].approvals[
                msg.sender
            ];
    }

    modifier sufficientFundOnly(uint256 accountId, uint256 amount) {
        require(
            isSufficientFund(accountId, amount),
            "sufficient fund not available"
        );
        _;
    }

    function isSufficientFund(
        uint256 accountId,
        uint256 amount
    ) private view returns (bool) {
        return _accounts[accountId].balance > amount;
    }

    modifier approvedWithDrawsOnly(uint256 accountId, uint256 withDrawReqId) {
        require(
            _accounts[accountId].withDrawals[withDrawReqId].isApproved,
            "withdrawal request is not approved"
        );
        _;
    }

    function getBalance(
        uint256 accountId
    ) external view ownersOnly(accountId) returns (uint256) {
        return _accounts[accountId].balance;
    }

    function deposit(
        uint256 accountId,
        uint256 amount
    ) external ownersOnly(accountId) {
        _accounts[accountId].balance += amount;
    }

    function withDrawRequest(
        uint256 accountId,
        uint256 amount
    ) external ownersOnly(accountId) sufficientFundOnly(accountId, amount) {
        WithDrawalRequest storage withdrawalReq = _accounts[accountId]
            .withDrawals[nextWithdrawalId];
        withdrawalReq.amount = amount;
        withdrawalReq.approvalCount = 1;
        withdrawalReq.user = msg.sender;
        withdrawalReq.isApproved = false;
        withdrawalReq.approvals[msg.sender] = true;
        nextWithdrawalId++;
    }

    function approveWithDrawRequest(
        uint256 withDrawReqId,
        uint256 accountId
    ) external ownersOnly(accountId) notApproved(accountId, withDrawReqId) {
        _accounts[accountId].withDrawals[withDrawReqId].approvals[
            msg.sender
        ] = true;
        _accounts[accountId].withDrawals[withDrawReqId].approvalCount++;
        if (
            _accounts[accountId].owners.length ==
            _accounts[accountId].withDrawals[withDrawReqId].approvalCount
        ) {
            _accounts[accountId].withDrawals[withDrawReqId].isApproved = true;
        }
    }

    function withDrawMoney(
        uint256 accountId,
        uint256 withDrawReqId
    )
        external
        approvedWithDrawsOnly(accountId, withDrawReqId)
        returns (uint256)
    {
        _accounts[accountId].balance -= _accounts[accountId]
            .withDrawals[withDrawReqId]
            .amount;
        return _accounts[accountId].withDrawals[withDrawReqId].amount;
    }

    function getApprovalCount(
        uint256 accountId,
        uint256 withDrawReqId
    ) external view returns (uint256) {
        return _accounts[accountId].withDrawals[withDrawReqId].approvalCount;
    }
}

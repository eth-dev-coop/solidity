// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ApplicantPool.sol";

contract MemberPool {
    event MemberReportUpdate(address member);
    event MemberCreated(address sender);
    event MemberPunished(address sender);
    event MemberRewarded(address sender);
    event VoteAgainstMemberStart(address sender);
    event VoteAgainstMemberEnd(address sender);
    string public name;
    string public shortSummary;
    string public longSummary;
    address[] public members;
    mapping(address => bool) memberActive;
    address[] projects;
    //members rep props
    mapping(address => address) userToMemberUp;
    mapping(address => int256) memberPoints;
    address public applicantPoolAddress;
    address immutable creator;

    constructor(
        address _applicantPoolAddress,
        address _creator,
        string memory _name
    ) {
        applicantPoolAddress = _applicantPoolAddress;
        creator = _creator;
        name = _name;
    }

    modifier memberOnly(address sender) {
        require(memberActive[sender], "Required to be a memeber");
        _;
    }

    function getMembers()
        public
        view
        memberOnly(msg.sender)
        returns (address[] memory)
    {}

    function getMemberRep(address member) public view returns (int32) {}

    function isMember(address id) public view returns (bool) {
        return memberActive[id];
    }

    function increaseMemberRep(address member) public {
        address caller = userToMemberUp[msg.sender];
        require(member != caller, "Already voted");
        memberPoints[member] += 1;
        userToMemberUp[msg.sender] = member;
        emit MemberRewarded(msg.sender);
    }

    function reportMember(address member, string calldata report)
        public
        view
        returns (uint32)
    {}

    function getMemberReports(address member)
        public
        view
        returns (string[] memory)
    {}

    function dismissMemberReport(address member)
        public
        memberOnly(msg.sender)
    {}

    function highlightReport(address member, string calldata comment)
        public
        memberOnly(msg.sender)
    {}

    function admitApplicant(address applicant) public memberOnly(msg.sender) {
        require(applicant != address(0));
        ApplicantPool pool = ApplicantPool(applicantPoolAddress);
        uint256 voteEndTime = pool.getApplicantVoteEndDate(applicant);
        require(voteEndTime > block.timestamp, "To soon to end vote");

        uint256 memberCount = getMemberCount();
        uint256 voteCount = pool.getApplicantVoteCount(applicant);

        //TODO determine best percentage to require...
        require(
            (((voteCount / memberCount) * 100) > 5),
            "Invalid number of votes or proceed."
        );

        pool.approveApplicant(applicant);

        members.push(applicant);
        memberActive[applicant] = true;
    }

    function getMemberCount() public view returns (uint256) {
        return members.length;
    }

    function getApplicants()
        public
        view
        memberOnly(msg.sender)
        returns (address[] memory)
    {
        ApplicantPool pool = ApplicantPool(applicantPoolAddress);
        return pool.getApplicants();
    }
}
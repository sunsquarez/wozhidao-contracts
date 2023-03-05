// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract AccountManager {
  struct Account {
    string username;
    string headline;
    string location;
    string linkedin;
    string github;
    string website;
    bool isActive;
  }

  mapping (address => Account) private accounts;

  event AccountCreated(
    address indexed accountAddress,
    string username,
    string headline,
    string location,
    string linkedin,
    string github,
    string website
  );

  event AccountDeactivated(
    address indexed accountAddress
  );

  modifier accountNotExists {
    require(!accounts[msg.sender].isActive, "Account already exists for this address");
    _;
  }

  modifier accountExists {
    require(accounts[msg.sender].isActive, "Account does not exist for this address");
    _;
  }

  function createAccount(
    string memory _username,
    string memory _headline,
    string memory _location,
    string memory _linkedin,
    string memory _github,
    string memory _website
  ) public accountNotExists {
    require(bytes(_username).length > 0, "Name must not be empty");
    Account memory newAccount = Account(
      _username,
      _headline,
      _location,
      _linkedin,
      _github,
      _website,
      true
    );
    accounts[msg.sender] = newAccount;
    emit AccountCreated(
      msg.sender,
      _username,
      _headline,
      _location,
      _linkedin,
      _github,
      _website
    );
  }

  function getAccount(address _accountAddress) public view returns (
    string memory username,
    string memory headline,
    string memory location,
    string memory linkedin,
    string memory github,
    string memory website,
    bool isActive
  ) {
    username = accounts[_accountAddress].username;
    headline = accounts[_accountAddress].headline;
    location = accounts[_accountAddress].location;
    linkedin = accounts[_accountAddress].linkedin;
    github = accounts[_accountAddress].github;
    website = accounts[_accountAddress].website;
    isActive = accounts[_accountAddress].isActive;
  }

  function deactivateAccount() public accountExists {
    accounts[msg.sender].isActive = false;
    emit AccountDeactivated(msg.sender);
  }
}

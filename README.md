# Introduction
This is a Hardhat project that includes two Solidity smart contracts, `AccountManager` and `QuestionManager`, designed for a [simple Q&A platform dapp](https://wozhidao.vercel.app/). Please note that the dapp is for demonstration purposes only and should not be used for production use cases.

## AccountManager
The `AccountManager` contract is responsible for managing user accounts. It allows users to create an account by providing their username, headline, location, LinkedIn profile, Github profile, and personal website. Once an account is created, its information is stored in the contract's internal mapping with the user's Ethereum address as the key. The contract also allows users to deactivate their account.
## QuestionManager
The `QuestionManager` contract is responsible for managing questions asked by users. It allows users to create a question by providing the question title, description, and reward amount in Ether. Once a question is created, its information is stored in the contract's internal mapping with a unique ID as the key. The contract also allows other users to answer the question and claim the reward if their answer is accepted by the question creator.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract QuestionManager {
  struct Question {
    string title;
    string description;
    address creator;
    uint256 bounty;
    mapping(uint256 => Answer) answers;
    uint256 numAnswers;
    uint256 numVoters;
    address bestAnswer;
    bool bountyAwarded;
    bool bountyWithdrawed;
    uint256 created_at;
  }

  struct Answer {
    string text;
    address author;
    address[] upvoters;
    address[] downvoters;
    bool isBestAnswer;
    uint256 created_at;
  }

  mapping(uint256 => Question) public questions;
  uint256 public numQuestions;

  event NewQuestion(uint256 indexed _id, string _title, string _description, address indexed _creator, uint256 _bounty);
  event NewAnswer(uint256 indexed _id, uint256 indexed _questionId, string _text, address indexed _author);
  event BountyAwarded(uint256 indexed _id, uint256 indexed _questionId, address indexed _author);
  event BountyWithdrawed(uint256 indexed _questionId);
  event Upvoted(uint256 indexed _answerId, address indexed _voter);
  event Downvoted(uint256 indexed _answerId, address indexed _voter);

  function createQuestion(string memory _title, string memory _description) external payable {
    require(msg.value > 0, "Bounty must be greater than zero.");
    numQuestions++;
    questions[numQuestions].title = _title;
    questions[numQuestions].description = _description;
    questions[numQuestions].creator = msg.sender;
    questions[numQuestions].bounty = msg.value;
    questions[numQuestions].created_at = block.timestamp;
    emit NewQuestion(numQuestions, _title, _description, msg.sender, msg.value);
  }

  function getAllQuestions() external view returns (uint256[] memory) {
    uint256[] memory questionIds = new uint256[](numQuestions);
    for (uint256 i = 1; i <= numQuestions; i++) {
      questionIds[i-1] = i;
    }
    return questionIds;
  }

  function getQuestionsByAddress(address _creator) external view returns (uint256[] memory) {
    uint256[] memory questionIds = new uint256[](numQuestions);
    uint256 count = 0;
    for (uint256 i = 1; i <= numQuestions; i++) {
      if (questions[i].creator == _creator) {
        questionIds[count] = i;
        count++;
      }
    }
    uint256[] memory result = new uint256[](count);
    for (uint256 i = 0; i < count; i++) {
      result[i] = questionIds[i];
    }
    return result;
  }

  function getQuestionDetails(uint256 _questionId) external view returns (
    string memory,
    string memory,
    address,
    uint256,
    uint256,
    uint256,
    address,
    bool,
    bool,
    uint256,
    uint256[] memory
  ) {
    require(_questionId > 0 && _questionId <= numQuestions, "Invalid question ID");
    Question storage question = questions[_questionId];

    uint256[] memory answerIds = new uint256[](question.numAnswers);
    for (uint256 i = 0; i < question.numAnswers; i++) {
      answerIds[i] = i;
    }

    return (
      question.title,
      question.description,
      question.creator,
      question.bounty,
      question.numAnswers,
      question.numVoters,
      question.bestAnswer,
      question.bountyAwarded,
      question.bountyWithdrawed,
      question.created_at,
      answerIds
    );
  }

  function findAnswer(uint256 _questionId, uint256 _answerId) internal view returns (Answer storage) {
    require(_questionId > 0 && _questionId <= numQuestions, "Invalid question ID.");
    require(_answerId > 0 && _answerId <= questions[_questionId].numAnswers, "Invalid answer ID.");
    return questions[_questionId].answers[_answerId];
  }

  function getAnswerDetails(uint256 _questionId, uint256 _answerId) external view returns (
    string memory,
    address,
    uint256,
    bool,
    address[] memory,
    address[] memory
  ) {
    require(_questionId > 0 && _questionId <= numQuestions, "Invalid question ID");
    require(_answerId > 0 && _answerId <= questions[_questionId].numAnswers, "Invalid answer ID");
    Answer storage answer = findAnswer(_questionId, _answerId);
    return (
      answer.text,
      answer.author,
      answer.created_at,
      answer.isBestAnswer,
      answer.upvoters,
      answer.downvoters
    );
  }

  function addAnswer(uint256 _questionId, string memory _text) external {
    require(_questionId <= numQuestions && _questionId > 0, "Invalid question ID.");
    questions[_questionId].numAnswers++;
    questions[_questionId].answers[questions[_questionId].numAnswers].text = _text;
    questions[_questionId].answers[questions[_questionId].numAnswers].author = msg.sender;
    questions[_questionId].answers[questions[_questionId].numAnswers].created_at = block.timestamp;
    emit NewAnswer(questions[_questionId].numAnswers, _questionId, _text, msg.sender);
  }

  function isNotInArray(address[] memory arr, address addr) public pure returns (bool) {
    for (uint i = 0; i < arr.length; i++) {
        if (arr[i] == addr) {
            return false;
        }
    }
    return true;
  }

  function upvote(uint256 _questionId, uint256 _answerId) external {
    require(_questionId > 0 && _questionId <= numQuestions, "Invalid question ID.");
    require(_answerId > 0 && _answerId <= questions[_questionId].numAnswers, "Invalid answer ID.");
    Answer storage answer = findAnswer(_questionId, _answerId);
    require(isNotInArray(answer.upvoters, msg.sender), "User has already voted.");
    require(isNotInArray(answer.downvoters, msg.sender), "User has already voted.");
    answer.upvoters.push(msg.sender);
    questions[_questionId].numVoters++;
    emit Upvoted(_answerId, msg.sender);
  }

  function downvote(uint256 _questionId, uint256 _answerId) external {
    require(_questionId > 0 && _questionId <= numQuestions, "Invalid question ID.");
    require(_answerId > 0 && _answerId <= questions[_questionId].numAnswers, "Invalid answer ID.");
    Answer storage answer = findAnswer(_questionId, _answerId);
    require(isNotInArray(answer.upvoters, msg.sender), "User has already voted.");
    require(isNotInArray(answer.downvoters, msg.sender), "User has already voted.");
    answer.downvoters.push(msg.sender);
    questions[_questionId].numVoters++;
    emit Downvoted(_answerId, msg.sender);
  }

  function awardBounty(uint256 _questionId, uint256 _answerId) external {
    require(_questionId <= numQuestions && _questionId > 0, "Invalid question ID.");
    require(questions[_questionId].creator == msg.sender, "Only the creator can award the bounty.");
    require(questions[_questionId].bestAnswer == address(0), "Bounty has already been awarded.");
    require(questions[_questionId].bountyAwarded == false, "Bounty has already been awarded.");
    Answer storage answer = findAnswer(_questionId, _answerId);
    answer.isBestAnswer = true;
    questions[_questionId].bestAnswer = answer.author;
    questions[_questionId].bountyAwarded = true;
    payable(answer.author).transfer(questions[_questionId].bounty);
    emit BountyAwarded(_answerId, _questionId, answer.author);
  }
  
  function withdrawBounty(uint256 _questionId) external {
    require(_questionId <= numQuestions && _questionId > 0, "Invalid question ID.");
    require(questions[_questionId].creator == msg.sender, "Only the creator can withdraw the bounty.");
    require(questions[_questionId].bountyAwarded == false, "Bounty has already been awarded.");
    require(questions[_questionId].numAnswers == 0, "There is potential answer to this question.");
    questions[_questionId].bountyWithdrawed = true;
    payable(questions[_questionId].creator).transfer(questions[_questionId].bounty);
    emit BountyWithdrawed(_questionId);
  }
}

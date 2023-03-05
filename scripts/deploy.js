async function main() {
  const AccountManager = await hre.ethers.getContractFactory("AccountManager");
  const accountManager = await AccountManager.deploy();
  await accountManager.deployed();
  console.log("AccountManager deployed to:", accountManager.address);

  const QuestionManager = await hre.ethers.getContractFactory("QuestionManager");
  const questionManager = await QuestionManager.deploy();
  await questionManager.deployed();
  console.log("QuestionManager deployed to:", questionManager.address);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

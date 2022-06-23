async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  const Token = await ethers.getContractFactory("UniSwap"); // name of the artifect when we compile our contract
  const token = await Token.deploy('0xE592427A0AEce92De3Edee1F18E0157C05861564');
  console.log("Token address:", token.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

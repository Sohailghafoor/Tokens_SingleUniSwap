require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-ethers");

const INFURA_API_KEY = "3b2dad5f4a7f44cd9d85b2f41cb9b842";
const ROPSTEN_PRIVATE_KEY =
  "1a238ef45c9c976d0ab0b2ed34ee58cd1e9aebb2c6a451373261185007937126";
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.7.5"
      },
      {
        version: "0.8.0"
      }
     
    ]
  },
  networks: {
    ropsten: {
      url: `https://ropsten.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [`0x${ROPSTEN_PRIVATE_KEY}`],
    },
  },
  etherscan: {
    // ehterscan API key, obtain from etherscan.io. allow us to connect with our ether scan account.
    apiKey: "27GY3QA4QHPSWIU759AHMYIP96PI2HAEUZ",
  },
};
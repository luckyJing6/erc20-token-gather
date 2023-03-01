import { HardhatUserConfig } from "hardhat/config"
import "hardhat-deploy"
import "@nomicfoundation/hardhat-toolbox"
import "@nomiclabs/hardhat-etherscan"
import "dotenv/config"
import "./tesk/test"


const config: HardhatUserConfig = {
  solidity: "0.8.17",
  defaultNetwork: "hardhat",
  networks: {
    localhost: {
      url: "http://localhost:8545",
      chainId: 31337,
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY!],
      chainId: 5,
    },
    dev: {
      url: 'HTTP://127.0.0.1:7545',
      chainId: 1337
    }
  },
  namedAccounts: {
    deployer: 0
  },
  gasReporter: {
    enabled: false,
    currency: 'USD',
    // outputFile: 'gas-report.txt'
  },
  etherscan: {
    apiKey: {
      goerli: process.env.ETHERSCAN_GOERLI_KEY!
    },
    customChains: [
      {
        network: "goerli",
        chainId: 5,
        urls: {
          apiURL: "https://api-goerli.etherscan.io/api",
          browserURL: "https://goerli.etherscan.io"
        }
      }
    ]
  }
};

export default config;

import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { verifyContractChainIds } from '../helper-hardhat-config';
import { verify } from '../utils/verify';


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const { deploy } = deployments
  const deployer = (await getNamedAccounts()).deployer
  const chainId = network.config.chainId!

  const SimpleUsdcTokenDeploy = await deploy("SimpleUsdcToken", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: 1
  })

  if (verifyContractChainIds.includes(chainId)) {
    await verify(SimpleUsdcTokenDeploy.address, [], 'contracts/simple-token/SimpleUsdcToken.sol:SimpleUsdcToken')
  }
  console.log('contract address: ', SimpleUsdcTokenDeploy.address)
  console.log('-----------')
};

func.tags = ["usdc", "all"]

export default func;
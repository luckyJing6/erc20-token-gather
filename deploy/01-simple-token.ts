import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { verifyContractChainIds } from '../helper-hardhat-config';
import { verify } from '../utils/verify';


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const { deploy } = deployments
  const deployer = (await getNamedAccounts()).deployer
  const chainId = network.config.chainId!

  const simpleTokenDeploy = await deploy("SimpleToken", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: 1
  })
  console.log('contract address: ', simpleTokenDeploy.address)

  if (verifyContractChainIds.includes(chainId)) {
    await verify(simpleTokenDeploy.address, [], 'contracts/simple-token/SimpleToekn.sol:SimpleToken')
  }
};

func.tags = ["simple-token"]

export default func;
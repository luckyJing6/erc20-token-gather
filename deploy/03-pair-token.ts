import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { verifyContractChainIds } from '../helper-hardhat-config';
import { verify } from '../utils/verify';


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const { deploy } = deployments
  const deployer = (await getNamedAccounts()).deployer
  const chainId = network.config.chainId!

  const pairTokenDeploy = await deploy("PairToken", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: 1
  })

  if (verifyContractChainIds.includes(chainId)) {
    await verify(pairTokenDeploy.address, [], 'contracts/simple-token/PairToken.sol:PairToken')
  }
  console.log('contract address: ', pairTokenDeploy.address)
  console.log('-----------')
};

func.tags = ["pair-token", "all"]

export default func;
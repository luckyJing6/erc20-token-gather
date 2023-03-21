import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { verifyContractChainIds } from '../helper-hardhat-config';
import { verify } from '../utils/verify';


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const { deploy } = deployments
  const deployer = (await getNamedAccounts()).deployer
  const chainId = network.config.chainId!

  const TokenPairFactoryDeploy = await deploy("TokenPairFactory", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: 1
  })

  if (verifyContractChainIds.includes(chainId)) {
    await verify(TokenPairFactoryDeploy.address, [])
  }
  console.log('contract address: ', TokenPairFactoryDeploy.address)
  console.log('-----------')

};

func.tags = ["pair", "all"]

export default func;
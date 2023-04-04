import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { verifyContractChainIds } from '../helper-hardhat-config';
import { verify } from '../utils/verify';


const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const { deploy } = deployments
  const deployer = (await getNamedAccounts()).deployer
  const chainId = network.config.chainId!

  // 部署UUPS1
  const UUPS1Deploy = await deploy("UUPS1", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: 1
  })

  // 部署UUPS2
  const UUPS2Deploy = await deploy("UUPS2", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: 1
  })

  // 部署UUPSproxy
  const UUPSProxyDeployArgs = [
    UUPS1Deploy.address
  ]
  const UUPSProxyDeploy = await deploy("UUPSProxy", {
    from: deployer,
    args: UUPSProxyDeployArgs,
    log: true,
    waitConfirmations: 1
  })

  if (verifyContractChainIds.includes(chainId)) {
    await verify(UUPS1Deploy.address, [])
    await verify(UUPS2Deploy.address, [])
    await verify(UUPSProxyDeploy.address, UUPSProxyDeployArgs)
  }
  console.log('uups1 address: ', UUPS1Deploy.address)
  console.log('uups2 address: ', UUPS2Deploy.address)
  console.log('proxy address: ', UUPSProxyDeploy.address)
  console.log('-----------')
};

func.tags = ["uups", "all"]

export default func;
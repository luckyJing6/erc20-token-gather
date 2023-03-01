import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";

task("myTask", "test")
  .setAction(
    async (args, hre: HardhatRuntimeEnvironment) => {
      console.log('test task')
    }
  )

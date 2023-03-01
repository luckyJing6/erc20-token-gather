import { run } from 'hardhat'
export async function verify(contractAddress: string, args?: any[], contractPath?: string) {
  console.log("Verifying contract...")
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args || [],
      contract: contractPath,
    });
    console.log('verify contract success...')
  } catch (error: any) {
    if (error.message.toLowerCase().includes('already verified')) {
      console.log('Contract source code already verified')
    } else {
      console.log(error)
    }
  }
}
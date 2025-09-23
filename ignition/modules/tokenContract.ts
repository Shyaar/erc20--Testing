import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("tokenContractModule", (m) => {
  const tokenContract = m.contract("TokenContract", ["Blockfuse", "BLT"]);

  return { tokenContract };
});

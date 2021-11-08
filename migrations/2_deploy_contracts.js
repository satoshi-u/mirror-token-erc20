const MirToken = artifacts.require("MirToken");
const MirTokenSale = artifacts.require("MirTokenSale");
const TrimMirror = artifacts.require("TrimMirror");

module.exports = async function (deployer, network, accounts) {
  const delegate1Addr = accounts[1];
  const delegate2Addr = accounts[2];
  const tokenPrice = 1000000000000000; // 1000000000000000 (10**15) WEI = 0.001 ETH

  await deployer.deploy(TrimMirror);
  await deployer.deploy(MirToken, 1000000, delegate1Addr, delegate2Addr);
  await deployer.deploy(MirTokenSale, MirToken.address, TrimMirror.address, tokenPrice);
};

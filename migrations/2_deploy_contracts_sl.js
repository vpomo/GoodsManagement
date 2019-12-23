const GoodsManagement = artifacts.require('./GoodsManagement.sol');

module.exports = (deployer) => {
    //http://www.onlineconversion.com/unix_time.htm
    var administrationWallet = "0xa57aeB1145Ab9ffCeBA6DC23bEF419570bD38110";
    deployer.deploy(GoodsManagement, administrationWallet);
};

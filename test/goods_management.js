var GoodsManagement = artifacts.require("./GoodsManagement.sol");
//import assertRevert from './helpers/assertRevert';

var contractGM;


contract('GoodsManagement', (accounts) => {
    var owner = accounts[0]; // for test
    var decimal = Number(1e18);

    var buyEthOne = Number(0.02 * decimal);

    it('should deployed contract GoodsManagement', async () => {
        assert.equal(undefined, contractGM);
        contractGM = await GoodsManagement.deployed();
        assert.notEqual(undefined, contractGM);
    });

    it('get address contract', async () => {
        assert.notEqual(undefined, contractGM.address);
    });

    it('add goods contract', async () => {
        await contractGM.setAdmin(accounts[0], true);
        await contractGM.addToCatalog("goods 1", "info googs 1", 20, 1);
    });


});

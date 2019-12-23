var GoodsManagement = artifacts.require("./GoodsManagement.sol");
//import assertRevert from './helpers/assertRevert';

var contractGM;


contract('GoodsManagemen', (accounts) => {
    var owner = accounts[0]; // for test
    var decimal = Number(1e18);

    var buyEthOne = Number(0.02 * decimal);

    it('should deployed contract GoodsManagemen', async () => {
        assert.equal(undefined, contractGM);
        contractGM = await GoodsManagemen.deployed();
        assert.notEqual(undefined, contractGM);
    });

    it('get address contract', async () => {
        assert.notEqual(undefined, contractGM.address);
    });


});

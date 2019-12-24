pragma solidity >0.4.99 <0.6.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma experimental ABIEncoderV2;

contract GoodsManagement is Ownable {

    struct Amount {
        uint mainPart;
        uint afterComma;
    }

    struct Goods {
        string name;
        string measure;
        Amount cost;
    }

    mapping(uint => Goods) public catalog;
    //goodsId (increment) -> Goods

    struct FactoryOrder {
        uint goodsId;
        Amount quantity;
        bool isConfirmForBuy;
    }

    struct FinalSaleOrder {
        uint goodsId;
        Amount quantity;
    }

    struct ClientOrder {
        uint goodsId;
        Amount quantity;
        bool isStocked;
    }

    struct StoreOrder {
        uint goodsId;
        Amount quantity;
    }

    mapping(address => bool) public managers;
    mapping(address => bool) public loaders;
    mapping(address => bool) public admins;

    mapping(uint => mapping(address => FactoryOrder[])) private ordersForBuy;
    //data -> manager address -> FactoryOrder

    mapping(uint => mapping(address => ClientOrder[])) private ordersForClient;
    //data -> loader address -> ClientOrder

    FinalSaleOrder[] finalSaleOrder;

    mapping(uint => StoreOrder) private storehouse;
    //storehouseId -> StoreOrder

    uint public currentGoodsId;
    uint public currentStoreId;

    modifier onlyManagers {
        require(managers[msg.sender] || admins[msg.sender], "only managers method called");
        _;
    }

    modifier onlyLoaders {
        require(loaders[msg.sender] || admins[msg.sender], "only loaders method called");
        _;
    }

    modifier onlyAdmins {
        require(admins[msg.sender], "only admins method called");
        _;
    }

    event SetManager(address indexed walletUser, bool status, address indexed admin);
    event SetLoader(address indexed walletUser, bool status, address indexed admin);
    event SetAdmin(address indexed walletUser, bool status, address indexed admin);

    event AddFactoryGoods(uint date, address manager, uint goodsId, uint mainPartAmount, uint afterCommaAmount, bool isConfirmForBuy);
    event AddClientGoods(uint date, address loader, uint goodsId, uint mainPartAmount, uint afterCommaAmount, bool isStocked);
    event AddFinalSaleOrder(uint goodsId, uint mainPartAmount, uint afterCommaAmount);

    constructor () public {
        currentGoodsId = 1;
        currentStoreId = 1;
    }

    function () external payable {}

    function getBalanceContract() public view returns (uint) {
        return address(this).balance;
    }

    function getGoodsById(uint id) public view returns
    (
        string memory name,
        string memory measure,
        uint mainPartAmount,
        uint afterCommaAmount
    ) {
        Goods memory goods = catalog[id];
        name = goods.name;
        measure = goods.measure;
        mainPartAmount = goods.cost.mainPart;
        afterCommaAmount = goods.cost.afterComma;
    }

    function addToCatalog(
        string memory name,
        string memory measure,
        uint mainPartAmount,
        uint afterCommaAmount
    ) public onlyAdmins {
        Goods storage goods = catalog[currentGoodsId];
        currentGoodsId++;
        goods.name = name;
        goods.measure = measure;
        goods.cost.mainPart = mainPartAmount;
        goods.cost.afterComma = afterCommaAmount;
    }

    function addToStore(
        uint goodsId,
        uint mainPartAmount,
        uint afterCommaAmount
    ) public onlyLoaders {
        StoreOrder storage storeOrder = storehouse[currentStoreId];
        currentStoreId++;
        storeOrder.goodsId = goodsId;
        storeOrder.quantity.mainPart = mainPartAmount;
        storeOrder.quantity.afterComma = afterCommaAmount;
    }

    function setAmountToStore(
        uint storeId,
        uint mainPartAmount,
        uint afterCommaAmount
    ) public onlyLoaders {
        StoreOrder storage storeOrder = storehouse[storeId];
        storeOrder.quantity.mainPart = mainPartAmount;
        storeOrder.quantity.afterComma = afterCommaAmount;
    }

    function addToFinalSaleOrder(
        uint goodsId,
        uint mainPartAmount,
        uint afterCommaAmount
    ) public onlyAdmins {
        finalSaleOrder.push(
            FinalSaleOrder(
                goodsId,
                Amount(mainPartAmount, afterCommaAmount)
            )
        );
        emit AddFinalSaleOrder(goodsId, mainPartAmount, afterCommaAmount);
    }

    function addToOrderForBuy(
        uint date,
        address manager,
        uint goodsId,
        uint mainPartAmount,
        uint afterCommaAmount,
        bool isConfirmForBuy
    ) public onlyManagers {
        ordersForBuy[date][manager].push(
            FactoryOrder(
                goodsId,
                Amount(mainPartAmount, afterCommaAmount),
                isConfirmForBuy
            )
        );
        emit AddFactoryGoods(date, manager, goodsId, mainPartAmount, afterCommaAmount, isConfirmForBuy);
    }

    function addToOrderForClient(
        uint date,
        address loader,
        uint goodsId,
        uint mainPartAmount,
        uint afterCommaAmount,
        bool isStocked
    ) public onlyLoaders {
        ordersForClient[date][loader].push(
            ClientOrder(
                goodsId,
                Amount(mainPartAmount, afterCommaAmount),
                isStocked
            )
        );
        emit AddClientGoods(date, loader, goodsId, mainPartAmount, afterCommaAmount, isStocked);
    }

    function confirmFactoryGoods(
        uint date,
        address manager,
        uint orderId,
        bool isConfirmForBuy
    ) public onlyAdmins {
        if (ordersForBuy[date][manager].length > orderId) {
            FactoryOrder storage factoryOrder = ordersForBuy[date][manager][orderId];
            factoryOrder.isConfirmForBuy = isConfirmForBuy;
        }
    }

    function stockClientGoods(
        uint date,
        address loader,
        uint orderId,
        bool isStocked
    ) public onlyAdmins {
        if (ordersForBuy[date][loader].length > orderId) {
            ClientOrder storage clientOrder = ordersForClient[date][loader][orderId];
            clientOrder.isStocked = isStocked;
        }
    }

    function sizeOrdersForBuy(
        uint date,
        address manager
    ) public view returns (uint) {
        return ordersForBuy[date][manager].length;
    }

    function sizeOrdersForClient(
        uint date,
        address loader
    ) public view returns (uint) {
        return ordersForClient[date][loader].length;
    }

    function setManager(address _newUser, bool _status) onlyOwner public {
        managers[_newUser] = _status;
        emit SetManager(_newUser, _status, msg.sender);
    }

    function setLoader(address _newUser, bool _status) onlyOwner public {
        loaders[_newUser] = _status;
        emit SetLoader(_newUser, _status, msg.sender);
    }

    function setAdmin(address _newUser, bool _status) onlyOwner public {
        admins[_newUser] = _status;
        emit SetAdmin(_newUser, _status, msg.sender);
    }
}
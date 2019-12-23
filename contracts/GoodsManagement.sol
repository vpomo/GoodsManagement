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
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

    mapping(address => string) public managers;
    mapping(address => string) public loaders;

    mapping(uint => mapping(address => FactoryOrder)) private ordersForBuy;
    //data -> manager address -> FactoryOrder

    mapping(uint => mapping(address => ClientOrder)) private ordersForClient;
    //data -> loader address -> ClientOrder

    FinalSaleOrder[] finalSaleOrder;

    mapping(uint => StoreOrder) public storehouse;
    //storehouseId -> StoreOrder


    constructor (address payable beneficiarAddress) public {
        setBeneficiarAddress(beneficiarAddress);
    }

    function () external payable {}

    function getBalanceContract() public view returns (uint) {
        return address(this).balance;
    }

    function getGamesByIndex(uint index) public view returns
    (
        address player,
        uint betAmount,
        uint prize,
        bool isWinner,
        uint[] memory symbols,
        bool started,
        string memory symbolWinner
    ) {
        Game memory game = games[index];
        player = game.player;
        betAmount = game.betAmount;
        prize = game.prize;
        isWinner = game.isWinner;
        symbols = game.symbols;
        started = game.started;
        symbolWinner = game.symbolWinner;
    }
}
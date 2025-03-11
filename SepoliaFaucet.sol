// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SepoliaFaucet {
    address public owner;
    uint256 public constant DRIP_AMOUNT = 0.01 ether;
    uint256 public constant DRIP_INTERVAL = 24 hours;

    mapping(address => uint256) public lastDripTime; // Время последнего запроса для адреса
    mapping(bytes32 => uint256) public lastDripTimeByIP; // Время последнего запроса для IP

    event Drip(address indexed user, bytes32 indexed ipHash, uint256 amount);
    event Funded(address indexed funder, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Функция запроса монет с IP и капчей
    function drip(bytes32 ipHash) external {
        require(block.timestamp >= lastDripTime[msg.sender] + DRIP_INTERVAL, "Address: Wait 24 hours");
        require(block.timestamp >= lastDripTimeByIP[ipHash] + DRIP_INTERVAL, "IP: Wait 24 hours");
        require(address(this).balance >= DRIP_AMOUNT, "Faucet is out of funds");

        lastDripTime[msg.sender] = block.timestamp;
        lastDripTimeByIP[ipHash] = block.timestamp;
        payable(msg.sender).transfer(DRIP_AMOUNT);

        emit Drip(msg.sender, ipHash, DRIP_AMOUNT);
    }

    // Пополнение крана
    function fund() external payable {
        require(msg.value > 0, "Must send some ETH");
        emit Funded(msg.sender, msg.value);
    }

    // Вывод средств владельцем
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        emit Funded(msg.sender, msg.value);
    }
}
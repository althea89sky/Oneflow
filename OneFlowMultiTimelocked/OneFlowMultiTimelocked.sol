// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title OneFlowMultiTimelocked
/// @notice A smart contract for distributing ETH and ERC-20 tokens to 5 wallets with a custom time lock and configurable rates.
/// @author althea89sky

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract OneFlowMultiTimelocked {
    address public owner;

    address public LP1;
    address public LP2;
    address public LP3;
    address public LP4;
    address public DEV;

    uint256 public R1;
    uint256 public R2;
    uint256 public R3;
    uint256 public R4;
    uint256 public R5;

    uint256 public lastDistributionTime;
    uint256 public timeLockDuration = 1 hours;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier timeLockPassed() {
        require(block.timestamp >= lastDistributionTime + timeLockDuration, "Time lock active");
        _;
    }

    constructor(
        address _lp1,
        address _lp2,
        address _lp3,
        address _lp4,
        address _dev
    ) {
        owner = msg.sender;

        LP1 = _lp1;
        LP2 = _lp2;
        LP3 = _lp3;
        LP4 = _lp4;
        DEV = _dev;

        R1 = 2000;
        R2 = 2000;
        R3 = 2000;
        R4 = 2000;
        R5 = 2000;

        lastDistributionTime = block.timestamp;
    }

    // Wallet Setters
    function setLP1(address _lp1) external onlyOwner { LP1 = _lp1; }
    function setLP2(address _lp2) external onlyOwner { LP2 = _lp2; }
    function setLP3(address _lp3) external onlyOwner { LP3 = _lp3; }
    function setLP4(address _lp4) external onlyOwner { LP4 = _lp4; }
    function setDEV(address _dev) external onlyOwner { DEV = _dev; }

    // Bulk wallet setter (optional)
    function setWallets(address _lp1, address _lp2, address _lp3, address _lp4, address _dev) external onlyOwner {
        LP1 = _lp1;
        LP2 = _lp2;
        LP3 = _lp3;
        LP4 = _lp4;
        DEV = _dev;
    }

    // Rate setter
    function setRates(uint256 _r1, uint256 _r2, uint256 _r3, uint256 _r4, uint256 _r5) external onlyOwner {
        require(_r1 + _r2 + _r3 + _r4 + _r5 <= 10000, "Rates exceed 100%");
        R1 = _r1;
        R2 = _r2;
        R3 = _r3;
        R4 = _r4;
        R5 = _r5;
    }

    // Time lock setter
    function setTimeLock(uint256 seconds_) external onlyOwner {
        timeLockDuration = seconds_;
    }

    // Ownership transfer
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }

    // ETH distribution
    receive() external payable {
        distributeETH();
    }

    fallback() external payable {
        distributeETH();
    }

    function distributeETH() public timeLockPassed {
        uint256 amount = address(this).balance;
        require(amount > 0, "No ETH to distribute");

        if (R1 > 0) payable(LP1).transfer((amount * R1) / 10000);
        if (R2 > 0) payable(LP2).transfer((amount * R2) / 10000);
        if (R3 > 0) payable(LP3).transfer((amount * R3) / 10000);
        if (R4 > 0) payable(LP4).transfer((amount * R4) / 10000);
        if (R5 > 0) payable(DEV).transfer((amount * R5) / 10000);

        lastDistributionTime = block.timestamp;
    }

    // ERC-20 token distribution
    function distributeToken(address token) external onlyOwner timeLockPassed {
        IERC20 t = IERC20(token);
        uint256 bal = t.balanceOf(address(this));
        require(bal > 0, "No token balance");

        if (R1 > 0) t.transfer(LP1, (bal * R1) / 10000);
        if (R2 > 0) t.transfer(LP2, (bal * R2) / 10000);
        if (R3 > 0) t.transfer(LP3, (bal * R3) / 10000);
        if (R4 > 0) t.transfer(LP4, (bal * R4) / 10000);
        if (R5 > 0) t.transfer(DEV, (bal * R5) / 10000);

        lastDistributionTime = block.timestamp;
    }
}

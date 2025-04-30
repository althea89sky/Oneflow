// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title OneFlow
/// @notice A lightweight, open-source smart contract for rate-based forwarding of ETH and ERC-20 tokens.
/// @author althea89sky

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract OneFlow {
    address public owner;
    address public poolWallet;
    uint256 public rate; // in basis points (10000 = 100%)

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _poolWallet, uint256 _rate) {
        require(_poolWallet != address(0), "Invalid wallet");
        require(_rate <= 10000, "Rate too high");

        owner = msg.sender;
        poolWallet = _poolWallet;
        rate = _rate;
    }

    function setPoolWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid wallet");
        poolWallet = _wallet;
    }

    function setRate(uint256 _rate) external onlyOwner {
        require(_rate <= 10000, "Rate must be <= 10000");
        rate = _rate;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }

    receive() external payable {
        _distributeETH(msg.value);
    }

    fallback() external payable {
        _distributeETH(msg.value);
    }

    function _distributeETH(uint256 amount) internal {
        if (rate > 0 && amount > 0) {
            uint256 sendAmount = (amount * rate) / 10000;
            payable(poolWallet).transfer(sendAmount);
        }
    }

    function distributeToken(address token) external onlyOwner {
        IERC20 t = IERC20(token);
        uint256 bal = t.balanceOf(address(this));
        require(bal > 0, "No token balance");

        uint256 sendAmount = (bal * rate) / 10000;
        t.transfer(poolWallet, sendAmount);
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Not enough ETH");
        payable(owner).transfer(amount);
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner, amount);
    }
}

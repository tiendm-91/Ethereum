// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Kế thừa từ ERC20 của OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken1 is ERC20 {
    constructor(uint256 initialSupply) ERC20("My Token", "MTK") {
        // Chuyển toàn bộ token đến địa chỉ tạo hợp đồng (msg.sender)
        _mint(msg.sender, initialSupply);
    }
}

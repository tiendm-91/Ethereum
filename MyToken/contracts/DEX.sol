// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DEX {
    using SafeMath for uint256;

    IERC20 public myToken1;
    IERC20 public myToken2;
    
    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidity;

    event Token1Purchase(address indexed buyer, uint256 token2Sold, uint256 token1Bought);
    event Token2Purchase(address indexed buyer, uint256 token1Sold, uint256 token2Bought);
    event LiquidityProvided(address indexed provider, uint256 token1Amount, uint256 token2Amount);
    event LiquidityRemoved(address indexed provider, uint256 token1Amount, uint256 token2Amount);

    constructor(address token1Address, address token2Address) {
        myToken1 = IERC20(token1Address);
        myToken2 = IERC20(token2Address);
    }

    // Khởi tạo pool với lượng token1 và token2 ban đầu
    function initPool(uint256 token1Amount, uint256 token2Amount) public {
        require(totalLiquidity == 0, "Pool already initialized");
        
        totalLiquidity = token1Amount.add(token2Amount);
        liquidity[msg.sender] = totalLiquidity;
        
        require(myToken1.transferFrom(msg.sender, address(this), token1Amount), "Token1 transfer failed");
        require(myToken2.transferFrom(msg.sender, address(this), token2Amount), "Token2 transfer failed");
    }

    // Hàm tính giá theo công thức AMM
    function getPrice(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        return (inputAmount.mul(outputReserve)).div(inputReserve.add(inputAmount));
    }

    // Giao dịch từ token1 sang token2
    function token1ToToken2Swap(uint256 token1Sold) public {
        uint256 token2Reserve = myToken2.balanceOf(address(this));
        uint256 token2Bought = getPrice(token1Sold, myToken1.balanceOf(address(this)), token2Reserve);
        require(myToken1.transferFrom(msg.sender, address(this), token1Sold), "Token1 transfer failed");
        require(myToken2.transfer(msg.sender, token2Bought), "Token2 transfer failed");
        emit Token1Purchase(msg.sender, token1Sold, token2Bought);
    }

    // Giao dịch từ token2 sang token1
    function token2ToToken1Swap(uint256 token2Sold) public {
        uint256 token1Reserve = myToken1.balanceOf(address(this));
        uint256 token1Bought = getPrice(token2Sold, myToken2.balanceOf(address(this)), token1Reserve);
        require(myToken2.transferFrom(msg.sender, address(this), token2Sold), "Token2 transfer failed");
        require(myToken1.transfer(msg.sender, token1Bought), "Token1 transfer failed");
        emit Token2Purchase(msg.sender, token2Sold, token1Bought);
    }

    // Cung cấp thanh khoản cho pool
    function provideLiquidity(uint256 token1Amount, uint256 token2Amount) public {
        require(token1Amount > 0 && token2Amount > 0, "Invalid amounts");

        uint256 token1Reserve = myToken1.balanceOf(address(this));
        uint256 token2Reserve = myToken2.balanceOf(address(this));

        uint256 token2AmountRequired = (token1Amount.mul(token2Reserve)).div(token1Reserve);
        require(token2Amount == token2AmountRequired, "Incorrect token2 amount");

        require(myToken1.transferFrom(msg.sender, address(this), token1Amount), "Token1 transfer failed");
        require(myToken2.transferFrom(msg.sender, address(this), token2Amount), "Token2 transfer failed");

        liquidity[msg.sender] = liquidity[msg.sender].add(token1Amount.add(token2Amount));
        totalLiquidity = totalLiquidity.add(token1Amount.add(token2Amount));

        emit LiquidityProvided(msg.sender, token1Amount, token2Amount);
    }

    // Người dùng chỉ nhập token1Amount, DEX tự tính token2Amount
    function provideLiquidityWithToken1(uint256 token1Amount) public {
        uint256 token1Reserve = myToken1.balanceOf(address(this));
        uint256 token2Reserve = myToken2.balanceOf(address(this));

        require(token1Reserve > 0 && token2Reserve > 0, "Pool not initialized");

        uint256 token2AmountRequired = (token1Amount * token2Reserve) / token1Reserve;

        require(myToken1.transferFrom(msg.sender, address(this), token1Amount), "Token1 transfer failed");
        require(myToken2.transferFrom(msg.sender, address(this), token2AmountRequired), "Token2 transfer failed");

        liquidity[msg.sender] += token1Amount + token2AmountRequired;
        totalLiquidity += token1Amount + token2AmountRequired;

        emit LiquidityProvided(msg.sender, token1Amount, token2AmountRequired);
    }

    // Người dùng chỉ nhập token2Amount, DEX tự tính token1Amount
    function provideLiquidityWithToken2(uint256 token2Amount) public {
        uint256 token1Reserve = myToken1.balanceOf(address(this));
        uint256 token2Reserve = myToken2.balanceOf(address(this));

        require(token1Reserve > 0 && token2Reserve > 0, "Pool not initialized");

        uint256 token1AmountRequired = (token2Amount * token1Reserve) / token2Reserve;

        require(myToken1.transferFrom(msg.sender, address(this), token1AmountRequired), "Token1 transfer failed");
        require(myToken2.transferFrom(msg.sender, address(this), token2Amount), "Token2 transfer failed");

        liquidity[msg.sender] += token1AmountRequired + token2Amount;
        totalLiquidity += token1AmountRequired + token2Amount;

        emit LiquidityProvided(msg.sender, token1AmountRequired, token2Amount);
    }


    // Rút thanh khoản từ pool
    function removeLiquidity(uint256 liquidityAmount) public {
        require(liquidityAmount > 0 && liquidityAmount <= liquidity[msg.sender], "Invalid liquidity amount");

        uint256 token1Amount = (liquidityAmount.mul(myToken1.balanceOf(address(this)))).div(totalLiquidity);
        uint256 token2Amount = (liquidityAmount.mul(myToken2.balanceOf(address(this)))).div(totalLiquidity);

        liquidity[msg.sender] = liquidity[msg.sender].sub(liquidityAmount);
        totalLiquidity = totalLiquidity.sub(liquidityAmount);

        require(myToken1.transfer(msg.sender, token1Amount), "Token1 transfer failed");
        require(myToken2.transfer(msg.sender, token2Amount), "Token2 transfer failed");

        emit LiquidityRemoved(msg.sender, token1Amount, token2Amount);
    }

    // Kiểm tra số dư thanh khoản của người dùng
    function getLiquidity(address provider) public view returns (uint256) {
        return liquidity[provider];
    }

    // Kiểm tra số dư của token1 và token2 trong hợp đồng
    function getToken1Balance() public view returns (uint256) {
        return myToken1.balanceOf(address(this));
    }

    function getToken2Balance() public view returns (uint256) {
        return myToken2.balanceOf(address(this));
    }
}

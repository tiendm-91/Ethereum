const DEX = artifacts.require("DEX");
const MyToken1 = artifacts.require("MyToken1");
const MyToken2 = artifacts.require("MyToken2");

module.exports = async function (deployer, network, accounts) {
    const account0 = accounts[0];

    // Triển khai MyToken1 và MyToken2
    await deployer.deploy(MyToken1, web3.utils.toWei("1000000", "ether"));
    await deployer.deploy(MyToken2, web3.utils.toWei("1000000", "ether"));

    // Lấy instance của MyToken1 và MyToken2
    const myToken1 = await MyToken1.deployed();
    const myToken2 = await MyToken2.deployed();

    // Triển khai DEX
    await deployer.deploy(DEX, myToken1.address, myToken2.address);
    const dex = await DEX.deployed();

    // Kiểm tra số dư ban đầu của accounts[0]
    const balanceMyToken1 = await myToken1.balanceOf(account0);
    const balanceMyToken2 = await myToken2.balanceOf(account0);
    console.log("Initial MyToken1 balance of account0:", web3.utils.fromWei(balanceMyToken1, "ether"));
    console.log("Initial MyToken2 balance of account0:", web3.utils.fromWei(balanceMyToken2, "ether"));

    // Xác định số lượng token cung cấp vào pool
    const token1Amount = web3.utils.toWei("100000", "ether");
    const token2Amount = web3.utils.toWei("100000", "ether");

    // Cấp quyền cho DEX để sử dụng token1 và token2
    await myToken1.approve(dex.address, token1Amount, { from: account0 });
    await myToken2.approve(dex.address, token2Amount, { from: account0 });

    // Gọi initPool để cung cấp thanh khoản ban đầu
    await dex.initPool(token1Amount, token2Amount, { from: account0 });

    // Kiểm tra số dư trong DEX sau khi cung cấp thanh khoản
    const dexToken1Balance = await myToken1.balanceOf(dex.address);
    const dexToken2Balance = await myToken2.balanceOf(dex.address);
    console.log("MyToken1 balance in DEX:", web3.utils.fromWei(dexToken1Balance, "ether"));
    console.log("MyToken2 balance in DEX:", web3.utils.fromWei(dexToken2Balance, "ether"));
};

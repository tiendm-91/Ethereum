const MyToken1 = artifacts.require("MyToken1");
const MyToken2 = artifacts.require("MyToken2");
const DEX = artifacts.require("DEX");

module.exports = async function(callback) {
    try {
        // Lấy danh sách tài khoản
        const accounts = await web3.eth.getAccounts();
        const account0 = accounts[0];

        // Lấy instance của các hợp đồng đã deploy
        const myToken1 = await MyToken1.deployed();
        const myToken2 = await MyToken2.deployed();
        const dex = await DEX.deployed();

        // Kiểm tra số dư MyToken1 và MyToken2 của accounts[0]
        const balanceMyToken1 = await myToken1.balanceOf(account0);
        const balanceMyToken2 = await myToken2.balanceOf(account0);

        console.log("MyToken1 balance of accounts[0]:", web3.utils.fromWei(balanceMyToken1, "ether"));
        console.log("MyToken2 balance of accounts[0]:", web3.utils.fromWei(balanceMyToken2, "ether"));

        // Kiểm tra số dư MyToken1 và MyToken2 trong hợp đồng DEX
        const dexToken1Balance = await myToken1.balanceOf(dex.address);
        const dexToken2Balance = await myToken2.balanceOf(dex.address);

        console.log("MyToken1 balance in DEX:", web3.utils.fromWei(dexToken1Balance, "ether"));
        console.log("MyToken2 balance in DEX:", web3.utils.fromWei(dexToken2Balance, "ether"));
        
        callback();
    } catch (error) {
        console.error("Lỗi khi kiểm tra số dư:", error);
        callback(error);
    }
};

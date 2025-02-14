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

        // Số lượng token1 cần swap (1000 MyToken1)
        const token2Amount = web3.utils.toWei("1000", "ether");

        // Kiểm tra số dư trước giao dịch
        const balanceMyToken1Before = await myToken1.balanceOf(account0);
        const balanceMyToken2Before = await myToken2.balanceOf(account0);
        console.log("Trước swap:");
        console.log("MyToken1 balance of accounts[0]:", web3.utils.fromWei(balanceMyToken1Before, "ether"));
        console.log("MyToken2 balance of accounts[0]:", web3.utils.fromWei(balanceMyToken2Before, "ether"));

        // Chấp thuận DEX sử dụng MyToken2
        await myToken2.approve(dex.address, token2Amount, { from: account0 });

        // Gửi lệnh swap MyToken2 -> MyToken1
        await dex.token2ToToken1Swap(token2Amount, { from: account0 });

        // Kiểm tra số dư sau giao dịch
        const balanceMyToken1After = await myToken1.balanceOf(account0);
        const balanceMyToken2After = await myToken2.balanceOf(account0);
        console.log("Sau swap:");
        console.log("MyToken1 balance of accounts[0]:", web3.utils.fromWei(balanceMyToken1After, "ether"));
        console.log("MyToken2 balance of accounts[0]:", web3.utils.fromWei(balanceMyToken2After, "ether"));

        callback();
    } catch (error) {
        console.error("Lỗi khi swap token:", error);
        callback(error);
    }
};

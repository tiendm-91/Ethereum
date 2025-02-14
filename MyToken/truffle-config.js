module.exports = {
  networks: {
    geth: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "1001", // Match network id với mạng của bạn
      from: "0xbd0CBDb6116523118Ff6f3E42Ac126b401e3A66F",  // Địa chỉ ví của bạn
      gas: 8000000,           // Gas limit (tăng thêm nếu cần thiết)
      gasPrice: 20000000000,  // Giá gas (có thể thay đổi nếu cần thiết)
    },
  },
  compilers: {
    solc: {
      version: "0.8.19", // Chọn phiên bản hợp lệ cho Solidity
    },
  },
};

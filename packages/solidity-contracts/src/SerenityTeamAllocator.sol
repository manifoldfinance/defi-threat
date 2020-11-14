/**
 * Source Code first verified at https://etherscan.io on Thursday, March 28, 2019
 (UTC) */

pragma solidity ^0.5.7;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


// Time-locked wallet for Serenity advisors tokens
contract SerenityTeamAllocator {
    // Address of team member to allocations mapping
    mapping (address => uint256) allocations;

    ERC20Basic erc20_contract = ERC20Basic(0xBC7942054F77b82e8A71aCE170E4B00ebAe67eB6);
    uint constant expiresAt = 1556668800;
    address owner;

    constructor () public {
        owner = msg.sender;

        allocations[0x86970B23b8008B0E35F20fACdf4962D3A899F256] = 1000000 ether;
        allocations[0x403E732e419eccb3626Dc2130beec825E1023990] = 1000000 ether;
        allocations[0xc9CC83Ec6309e93FC72E305d24BDF34c93cA0C59] = 1000000 ether;
        allocations[0xa96aC207db973B12f352eC3886E1b118ad81DC57] = 1000000 ether;
        allocations[0xcC11EA5095E93AD5600573e31cB4F72923ECdDE3] = 1000000 ether;
        allocations[0xe7eC8124e15306c06AA2C1Da052e8169E697aBd2] = 100000 ether;
        allocations[0x4a0F4c7D631D34033f289dd33463937fbc401BeE] = 200000 ether;
        allocations[0xe46af6b7d32dcd9D82A0Ae123e3d9b7744f6C1C4] = 50000 ether;
        allocations[0xf6Df849c19BAeeCd4F85Ba528ca7772Bdc202C4e] = 100000 ether;
        allocations[0x34ee4A2124E8eeA848FB9ece82FCf8909138AD4d] = 100000 ether;
        allocations[0xAc05bde6291ba1bFb2b7F4d8DbcEb553051fd360] = 20000 ether;
        allocations[0xff44a930f51Ce4Ff459f52DF5Edb9becAD065f7C] = 200000 ether;
        allocations[0x81599e1560CaaB74443e5F5fb5Bb501cd9724b49] = 200000 ether;
        allocations[0xbfe92111a720bD37352Db5811a4F75647291e620] = 250000 ether;
        allocations[0xeB0A24d8Fa86A4d04BA97cB436D1Bb527A82B51e] = 100000 ether;
        allocations[0x109745E787B1dE54eBD576Adf9D9d4B70f88617B] = 100000 ether;
        allocations[0xC09375659859d66F625a07CB27A2919Ed6C84240] = 100000 ether;
        allocations[0xBb41A7Eac242e1314952555DFc7d732963275248] = 100000 ether;
        allocations[0x8e5eC5F5632e73A9A54105f9676f14Cbfe1e5Cc7] = 100000 ether;
        allocations[0x28D8AE88c0376aCca9b4779c9aF77a0D60eB0b10] = 20000 ether;
        allocations[0x3d918626c5075E4D63952297b97157BAb60a15F9] = 100000 ether;
        allocations[0xE223BDa5278a0cb09Bc154F93b85EB0C2742F369] = 200000 ether;
        allocations[0x60EDEA24c5815BBEf72CAC728f96a21D41Ea4214] = 100000 ether;
        allocations[0x28FA1C07464b8DEe70fA37627a38aCEF3630e27F] = 80000 ether;
        allocations[0xB0e9a0F2f4Fd171ecb23e07429B41cf52F995b82] = 100000 ether;
        allocations[0x1651F2d6a6a62C4aA02a766491AdAC587C2A2D9A] = 300000 ether;
        allocations[0x927d41d0c7A0029eDd0D6D55aacfb932FDAC8FbD] = 100000 ether;
        allocations[0xF22B4481eB9a224fA97dfD2fEbA1e06531A61433] = 100000 ether;
        allocations[0xa4e2EaFad3399FF285Dd4Fd8B4139d3cc6D30438] = 100000 ether;
        allocations[0xfe9220DDdaDd1065CAc7249730ee613C63f2e187] = 100000 ether;
        allocations[0xba93A0De5Db0E98F66e9E1C8253D4dd9557b3895] = 50000 ether;
        allocations[0x23da4c7Ad3B04396b0e0b6F870dDFA025153E097] = 20000 ether;
        allocations[0xc388657E3Edcb143D8B0FA922384D1b87bDcb0DC] = 30000 ether;
        allocations[0x50907432E86bc2FfDBEF238e9Df7c48A01d88dd8] = 30000 ether;
        allocations[0x357898808506B884Ab48b3E3f6d383560e69fc8e] = 50000 ether;
        allocations[0x79E9947FfF564d491d980BaB866Ca9F0980178D8] = 10000 ether;
        allocations[0xFD1E7E1525a32F11AaBA21f6fE1F05e4DE2cEB27] = 50000 ether;
        allocations[0x26B77a0c4e6B0F529f4Ea31752c23f05dd388697] = 100000 ether;
        allocations[0x3caA984A70F128c3B2b262861B805644A2ed6Bc0] = 100000 ether;
        allocations[0x11C6F9ccf49EBE938Dae82AE6c50a64eB5778dCC] = 30000 ether;
        allocations[0xb1A46c484BD58D984270BA710BEb2feF0A965aDc] = 50000 ether;
    }

    // Unlock team member's tokens by transferring them to their address
    function unlock() external {

        uint256 amount = allocations[msg.sender];
        allocations[msg.sender] = 0;

        if (!erc20_contract.transfer(msg.sender, amount)) {
            revert();
        }
    }

    // Return unclaimed tokens back to the Serenity wallet
    function reclaim() external {
        require (now >= expiresAt);
        require (msg.sender == owner);

        uint256 tokens_left = erc20_contract.balanceOf(address(this));

        if (!erc20_contract.transfer(owner, tokens_left)) {
            revert();
        }
    }

}
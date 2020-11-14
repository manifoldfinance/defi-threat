/**
 * Source Code first verified at https://etherscan.io on Friday, April 12, 2019
 (UTC) */

pragma solidity ^0.5.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address) external view returns (uint);
}

interface ICDP {
    function give(bytes32 cup, address guy) external;
}


contract Exit {

    event LogTransferETH(address dest, uint amount);
    event LogTransferERC20(address token, address dest, uint amount);
    event LogTransferCDP(uint num, address dest);

    /**
     * @dev MakerDAO CDP engine address
     */
    function getSaiTubAddress() public pure returns (address sai) {
        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;
    }

    /**
     * @dev withdrawing ETH
     */
    function transferETH(address payable dest) public payable {
        dest.transfer(address(this).balance);
        emit LogTransferETH(dest, address(this).balance);
    }

    /**
     * @dev withdrawing ERC20
     */
    function transferERC20(address tokenAddr) public {
        IERC20 tkn = IERC20(tokenAddr);
        uint tknBal = tkn.balanceOf(address(this));
        tkn.transfer(msg.sender, tknBal);
        emit LogTransferERC20(tokenAddr, msg.sender, tknBal);
    }

    /**
     * @dev withdrawing CDP
     */
    function transferCDP(uint num) public {
        ICDP(getSaiTubAddress()).give(bytes32(num), msg.sender);
        emit LogTransferCDP(num, msg.sender);
    }

}
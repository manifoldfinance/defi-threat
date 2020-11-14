/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

// Verified using https://dapp.tools

// hevm: flattened sources of src/Leverager.sol
pragma solidity >0.4.13 >=0.5.0 <0.6.0;

////// lib/ds-math/src/math.sol
/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >0.4.13; */

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

////// src/interfaces/IERC20.sol
/* pragma solidity >=0.5.0 <0.6.0; */

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}
////// src/interfaces/IExchange.sol
/* pragma solidity >=0.5.0 <0.6.0; */

/* import "./IERC20.sol"; */

interface IExchange {
    // specify either srcAmount = 0 or dstAmount = 0
    // actual amount - actual srcAmount if srcAmount is zero or actual dstAmount if dstAmount is zero
    function swap(IERC20 srcToken, uint srcAmount, IERC20 dstToken, uint dstAmount) external returns (uint actualAmount);
}

////// src/interfaces/ILender.sol
/* pragma solidity >=0.5.0 <0.6.0; */

/* import "./IERC20.sol"; */

interface ILender {
    function supplyAndBorrow(
        bytes32 agreementId,
        IERC20 principalToken,
        uint principalAmount,
        IERC20 collateralToken,
        uint collateralAmount) external returns (bytes32 _agreementId);

    function repayAndReturn(
        bytes32 agreementId,
        IERC20 principalToken,
        uint repaymentAmount,
        IERC20 collateralToken,
        uint withdrawAmount) external;

    function getOwedAmount(bytes32 agreementId, IERC20 principalToken) external returns (uint);
}

////// src/interfaces/IPriceFeed.sol
/* pragma solidity >=0.5.0 <0.6.0; */

/* import "./IERC20.sol"; */

interface IPriceFeed {
    function convertAmountToETH(IERC20 srcToken, uint srcAmount) external view returns (uint ethAmount);
    function convertAmountFromETH(IERC20 dstToken, uint ethAmount) external view returns (uint dstAmount);
}

////// src/Leverager.sol
/* pragma solidity >=0.5.0 <0.6.0; */

/* import "ds-math/math.sol"; */
/* import "./interfaces/IERC20.sol"; */
/* import "./interfaces/IExchange.sol"; */
/* import "./interfaces/IPriceFeed.sol"; */
/* import "./interfaces/ILender.sol"; */

contract Leverager is DSMath {

    struct Position {
        bytes32 agreementId;
        address owner;
        address heldToken;
        uint heldAmount;
        address principalToken;
    }

    uint public positionsCount;
    mapping (uint => Position) public positions;

    event PositionOpened(
        address indexed owner,
        uint positionId,
        // IExchange exchange,
        // ILender lender,
        // IPriceFeed priceFeed,
        address heldToken, 
        uint heldAmount, 
        address principalToken,
        uint wadMaxBaseRatio
    );

    event Iteration(uint num, uint recievedEthAmount);

    event PositionClosed(
        address indexed owner
    );

    // deposit token is a held token
    // FOR DELEGATECALL ONLY!
    // addresses[0] = lender
    // addresses[1] = exchange
    // addresses[2] = priceFeed
    // addresses[3] = heldToken
    // addresses[4] = principalToken
    // uints[0] =     initialDepositAmount
    // uints[1] =     wadMaxBaseRatio
    // uints[2] =     maxIterations
    // uints[3] =     minCollateralEthAmount
    // 
    // arrays in params used to evade "stack too deep" during compilation
    function openShortPosition (
        address[5] calldata addresses,
        uint[4] calldata uints
    ) external {
        positionsCount = add(positionsCount, 1);
        uint positionId = positionsCount;
        uint recievedAmount = uints[0];
        uint recievedEthAmount;
        uint heldAmount = uints[0];
        bytes32 agreementId;

        IERC20(addresses[3]).transferFrom(msg.sender, address(this), uints[0]);

        for (uint i = 0; i < uints[2]; i++) {
            uint principalAmount = calcPrincipal(IERC20(addresses[3]), recievedAmount, IERC20(addresses[4]), uints[1], IPriceFeed(addresses[2]));

            bool ok;
            bytes memory result;
            (ok, result) = addresses[0].delegatecall(
                abi.encodeWithSignature(
                    "supplyAndBorrow(bytes32,address,uint256,address,uint256)",
                    agreementId, addresses[4], principalAmount, addresses[3], recievedAmount
                )
            );
            require(ok, "supplyAndBorrow failed");
            agreementId = _bytesToBytes32(result);
            
            (ok, result) = addresses[1].delegatecall(
                abi.encodeWithSignature(
                    "swap(address,uint256,address,uint256)",
                    addresses[4], principalAmount, addresses[3], 0
                )
            );
            require(ok, "swap failed");
            recievedAmount = uint(_bytesToBytes32(result));
            recievedEthAmount = IPriceFeed(addresses[2]).convertAmountToETH(IERC20(addresses[3]), recievedAmount);
            heldAmount += recievedAmount;

            emit Iteration(i, recievedEthAmount);

            if(recievedEthAmount < uints[3])
                break;
        }

        positions[positionId] = Position({
            agreementId: agreementId,
            owner: msg.sender,
            heldToken: addresses[3],
            heldAmount: heldAmount,
            principalToken: addresses[4]
        });

        emit PositionOpened(msg.sender, positionId, addresses[3], heldAmount, addresses[4], uints[1]);
    }
    
    // FOR DELEGATECALL ONLY!
    // function closeShortPosition(
    //     bytes32 positionId,
    //     address exchange,
    //     address lender,
    //     uint maxIterations
    // ) external {
    //     Position storage position = positions[positionId];

    //     for (var i = 0; i < maxIterations; i++) {
    //         uint owedAmount = lender.getOwedAmount(position.agreementId, position.principalToken);

    //         bool ok;
    //         bytes memory result;
    //         (ok, result) = exchange.delegatecall(
    //             abi.encodeWithSignature(
    //                 "swap(address,uint256,address,uint256)",
    //                 position.heldToken, 0, position.principalToken, owedAmount
    //             )
    //         );
    //         require(ok, "swap failed");
    //         recievedAmount = uint(_bytesToBytes32(result));

    //         (ok, result) = lender.delegatecall(
    //             abi.encodeWithSignature(
    //                 "repayAndReturn(bytes32,address,uint256,address,uint256)",
    //                 position.agreementId, position.principalToken, uint(-1), position.heldToken, uint(-1)
    //             )
    //         );
    //         require(ok, "supplyAndBorrow failed");
    //     }

    //     delete positions[positionId];
        
    //     emit PositionClosed(msg.sender);
    // }

    // determines how much we can borrow from a lender in order to maintain provided collateral ratio
    function calcPrincipal(
        IERC20 heldToken,
        uint depositAmount,
        IERC20 principalToken,
        uint wadMaxBaseRatio,
        IPriceFeed priceFeed
    ) public view returns (uint principalAmount){
        uint collateralETH = priceFeed.convertAmountToETH(heldToken, depositAmount);
        uint principalETH = wdiv(collateralETH, wadMaxBaseRatio);
        principalAmount = priceFeed.convertAmountFromETH(principalToken, principalETH);
    }

    function _bytesToBytes32(bytes memory source) internal pure returns (bytes32 result) {
        if (source.length == 0)
            return 0x0;

        assembly {
            result := mload(add(source, 32))
        }
    }
}
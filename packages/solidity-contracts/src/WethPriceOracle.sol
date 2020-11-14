/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

/*

    Copyright 2019 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;

// File: contracts/protocol/lib/Monetary.sol

/**
 * @title Monetary
 * @author dYdX
 *
 * Library for types involving money
 */
library Monetary {

    /*
     * The price of a base-unit of an asset.
     */
    struct Price {
        uint256 value;
    }

    /*
     * Total value of an some amount of an asset. Equal to (price * amount).
     */
    struct Value {
        uint256 value;
    }
}

// File: contracts/protocol/interfaces/IPriceOracle.sol

/**
 * @title IPriceOracle
 * @author dYdX
 *
 * Interface that Price Oracles for Solo must implement in order to report prices.
 */
contract IPriceOracle {

    // ============ Constants ============

    uint256 public constant ONE_DOLLAR = 10 ** 36;

    // ============ Public Functions ============

    /**
     * Get the price of a token
     *
     * @param  token  The ERC20 token address of the market
     * @return        The USD price of a base unit of the token, then multiplied by 10^36.
     *                So a USD-stable coin with 18 decimal places would return 10^18.
     *                This is the price of the base unit rather than the price of a "human-readable"
     *                token amount. Every ERC20 may have a different number of decimals.
     */
    function getPrice(
        address token
    )
        public
        view
        returns (Monetary.Price memory);
}

// File: contracts/external/interfaces/IMakerOracle.sol

/**
 * @title IMakerOracle
 * @author dYdX
 *
 * Interface for the price oracles run by MakerDao
 */
interface IMakerOracle {

    // Event that is logged when the `note` modifier is used
    event LogNote(
        bytes4 indexed msgSig,
        address indexed msgSender,
        bytes32 indexed arg1,
        bytes32 indexed arg2,
        uint256 msgValue,
        bytes msgData
    ) anonymous;

    // returns the current value (ETH/USD * 10**18) as a bytes32
    function peek()
        external
        view
        returns (bytes32, bool);

    // requires a fresh price and then returns the current value
    function read()
        external
        view
        returns (bytes32);
}

// File: contracts/external/oracles/WethPriceOracle.sol

/**
 * @title WethPriceOracle
 * @author dYdX
 *
 * PriceOracle that returns the price of Wei in USD
 */
contract WethPriceOracle is
    IPriceOracle
{
    // ============ Storage ============

    IMakerOracle public MEDIANIZER;

    // ============ Constructor =============

    constructor(
        address medianizer
    )
        public
    {
        MEDIANIZER = IMakerOracle(medianizer);
    }

    // ============ IPriceOracle Functions =============

    function getPrice(
        address /* token */
    )
        public
        view
        returns (Monetary.Price memory)
    {
        (bytes32 value, /* bool fresh */) = MEDIANIZER.peek();
        return Monetary.Price({ value: uint256(value) });
    }
}
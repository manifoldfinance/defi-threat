/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/core/interfaces/IVault.sol

/*
    Copyright 2018 Set Labs Inc.

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

/**
 * @title IVault
 * @author Set Protocol
 *
 * The IVault interface provides a light-weight, structured way to interact with the Vault
 * contract from another contract.
 */
interface IVault {

    /*
     * Withdraws user's unassociated tokens to user account. Can only be
     * called by authorized core contracts.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _to             The address to transfer token to
     * @param  _quantity       The number of tokens to transfer
     */
    function withdrawTo(
        address _token,
        address _to,
        uint256 _quantity
    )
        external;

    /*
     * Increment quantity owned of a token for a given address. Can
     * only be called by authorized core contracts.
     *
     * @param  _token           The address of the ERC20 token
     * @param  _owner           The address of the token owner
     * @param  _quantity        The number of tokens to attribute to owner
     */
    function incrementTokenOwner(
        address _token,
        address _owner,
        uint256 _quantity
    )
        external;

    /*
     * Decrement quantity owned of a token for a given address. Can only
     * be called by authorized core contracts.
     *
     * @param  _token           The address of the ERC20 token
     * @param  _owner           The address of the token owner
     * @param  _quantity        The number of tokens to deattribute to owner
     */
    function decrementTokenOwner(
        address _token,
        address _owner,
        uint256 _quantity
    )
        external;

    /**
     * Transfers tokens associated with one account to another account in the vault
     *
     * @param  _token          Address of token being transferred
     * @param  _from           Address token being transferred from
     * @param  _to             Address token being transferred to
     * @param  _quantity       Amount of tokens being transferred
     */

    function transferBalance(
        address _token,
        address _from,
        address _to,
        uint256 _quantity
    )
        external;


    /*
     * Withdraws user's unassociated tokens to user account. Can only be
     * called by authorized core contracts.
     *
     * @param  _tokens          The addresses of the ERC20 tokens
     * @param  _owner           The address of the token owner
     * @param  _quantities      The numbers of tokens to attribute to owner
     */
    function batchWithdrawTo(
        address[] calldata _tokens,
        address _to,
        uint256[] calldata _quantities
    )
        external;

    /*
     * Increment quantites owned of a collection of tokens for a given address. Can
     * only be called by authorized core contracts.
     *
     * @param  _tokens          The addresses of the ERC20 tokens
     * @param  _owner           The address of the token owner
     * @param  _quantities      The numbers of tokens to attribute to owner
     */
    function batchIncrementTokenOwner(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

    /*
     * Decrements quantites owned of a collection of tokens for a given address. Can
     * only be called by authorized core contracts.
     *
     * @param  _tokens          The addresses of the ERC20 tokens
     * @param  _owner           The address of the token owner
     * @param  _quantities      The numbers of tokens to attribute to owner
     */
    function batchDecrementTokenOwner(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

   /**
     * Transfers tokens associated with one account to another account in the vault
     *
     * @param  _tokens           Addresses of tokens being transferred
     * @param  _from             Address tokens being transferred from
     * @param  _to               Address tokens being transferred to
     * @param  _quantities       Amounts of tokens being transferred
     */
    function batchTransferBalance(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external;

    /*
     * Get balance of particular contract for owner.
     *
     * @param  _token    The address of the ERC20 token
     * @param  _owner    The address of the token owner
     */
    function getOwnerBalance(
        address _token,
        address _owner
    )
        external
        view
        returns (uint256);
}

// File: contracts/lib/CommonMath.sol

/*
    Copyright 2018 Set Labs Inc.

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



library CommonMath {
    using SafeMath for uint256;

    /**
     * Calculates and returns the maximum value for a uint256
     *
     * @return  The maximum value for uint256
     */
    function maxUInt256()
        internal
        pure
        returns (uint256)
    {
        return 2 ** 256 - 1;
    }

    /**
    * @dev Performs the power on a specified value, reverts on overflow.
    */
    function safePower(
        uint256 a,
        uint256 pow
    )
        internal
        pure
        returns (uint256)
    {
        require(a > 0);

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++){
            uint256 previousResult = result;

            // Using safemath multiplication prevents overflows
            result = previousResult.mul(a);
        }

        return result;
    }

    /**
     * Checks for rounding errors and returns value of potential partial amounts of a principal
     *
     * @param  _principal       Number fractional amount is derived from
     * @param  _numerator       Numerator of fraction
     * @param  _denominator     Denominator of fraction
     * @return uint256          Fractional amount of principal calculated
     */
    function getPartialAmount(
        uint256 _principal,
        uint256 _numerator,
        uint256 _denominator
    )
        internal
        pure
        returns (uint256)
    {
        // Get remainder of partial amount (if 0 not a partial amount)
        uint256 remainder = mulmod(_principal, _numerator, _denominator);

        // Return if not a partial amount
        if (remainder == 0) {
            return _principal.mul(_numerator).div(_denominator);
        }

        // Calculate error percentage
        uint256 errPercentageTimes1000000 = remainder.mul(1000000).div(_numerator.mul(_principal));

        // Require error percentage is less than 0.1%.
        require(
            errPercentageTimes1000000 < 1000,
            "CommonMath.getPartialAmount: Rounding error exceeds bounds"
        );

        return _principal.mul(_numerator).div(_denominator);
    }

}

// File: contracts/core/lib/CoreIssuanceLibrary.sol

/*
    Copyright 2018 Set Labs Inc.

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
pragma experimental "ABIEncoderV2";





/**
 * @title CoreIssuanceLibrary
 * @author Set Protocol
 *
 * This library contains functions for calculating deposit, withdrawal,and transfer quantities
 */
library CoreIssuanceLibrary {

    using SafeMath for uint256;

    /**
     * Calculate the quantities required to deposit and decrement during issuance. Takes into account
     * the tokens an owner already has in the vault.
     *
     * @param _components                           Addresses of components
     * @param _componentQuantities                  Component quantities to increment and withdraw
     * @param _owner                                Address to deposit and decrement quantities from
     * @param _vault                                Address to vault
     * @return uint256[] decrementQuantities        Quantities to decrement from vault
     * @return uint256[] depositQuantities          Quantities to deposit into the vault
     */
    function calculateDepositAndDecrementQuantities(
        address[] calldata _components,
        uint256[] calldata _componentQuantities,
        address _owner,
        address _vault
    )
        external
        view
        returns (
            uint256[] memory /* decrementQuantities */,
            uint256[] memory /* depositQuantities */
        )
    {
        uint256 componentCount = _components.length;
        uint256[] memory decrementTokenOwnerValues = new uint256[](componentCount);
        uint256[] memory depositQuantities = new uint256[](componentCount);

        for (uint256 i = 0; i < componentCount; i++) {
            // Fetch component quantity in vault
            uint256 vaultBalance = IVault(_vault).getOwnerBalance(
                _components[i],
                _owner
            );

            // If the vault holds enough components, decrement the full amount
            if (vaultBalance >= _componentQuantities[i]) {
                decrementTokenOwnerValues[i] = _componentQuantities[i];
            } else {
                // User has less than required amount, decrement the vault by full balance
                if (vaultBalance > 0) {
                    decrementTokenOwnerValues[i] = vaultBalance;
                }

                depositQuantities[i] = _componentQuantities[i].sub(vaultBalance);
            }
        }

        return (
            decrementTokenOwnerValues,
            depositQuantities
        );
    }

    /**
     * Calculate the quantities required to withdraw and increment during redeem and withdraw. Takes into
     * account a bitmask exclusion parameter.
     *
     * @param _componentQuantities                  Component quantities to increment and withdraw
     * @param _toExclude                            Mask of indexes of tokens to exclude from withdrawing
     * @return uint256[] incrementQuantities        Quantities to increment in vault
     * @return uint256[] withdrawQuantities         Quantities to withdraw from vault
     */
    function calculateWithdrawAndIncrementQuantities(
        uint256[] calldata _componentQuantities,
        uint256 _toExclude
    )
        external
        pure
        returns (
            uint256[] memory /* incrementQuantities */,
            uint256[] memory /* withdrawQuantities */
        )
    {
        uint256 componentCount = _componentQuantities.length;
        uint256[] memory incrementTokenOwnerValues = new uint256[](componentCount);
        uint256[] memory withdrawToValues = new uint256[](componentCount);

        // Loop through and decrement vault balances for the set, withdrawing if requested
        for (uint256 i = 0; i < componentCount; i++) {
            // Calculate bit index of current component
            uint256 componentBitIndex = CommonMath.safePower(2, i);

            // Transfer to user unless component index is included in _toExclude
            if ((_toExclude & componentBitIndex) != 0) {
                incrementTokenOwnerValues[i] = _componentQuantities[i];
            } else {
                withdrawToValues[i] = _componentQuantities[i];
            }
        }

        return (
            incrementTokenOwnerValues,
            withdrawToValues
        );
    }

    /**
     * Calculate the required component quantities required for issuance or rdemption for a given
     * quantity of Set Tokens
     *
     * @param _componentUnits   The units of the component token
     * @param _naturalUnit      The natural unit of the Set token
     * @param _quantity         The number of tokens being redeem
     * @return uint256[]        Required quantities in base units of components
     */
    function calculateRequiredComponentQuantities(
        uint256[] calldata _componentUnits,
        uint256 _naturalUnit,
        uint256 _quantity
    )
        external
        pure
        returns (uint256[] memory)
    {
        require(
            _quantity.mod(_naturalUnit) == 0,
            "CoreIssuanceLibrary: Quantity must be a multiple of nat unit"
        );

        uint256[] memory tokenValues = new uint256[](_componentUnits.length);

        // Transfer the underlying tokens to the corresponding token balances
        for (uint256 i = 0; i < _componentUnits.length; i++) {
            tokenValues[i] = _quantity.div(_naturalUnit).mul(_componentUnits[i]);
        }

        return tokenValues;
    }

}
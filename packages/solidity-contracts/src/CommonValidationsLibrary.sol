/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

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


library CommonValidationsLibrary {

    /**
     * Ensures that an address array is not empty.
     *
     * @param  _addressArray       Address array input
     */    
    function validateNonEmpty(
        address[] calldata _addressArray
    )
        external
        pure
    {
        require(
            _addressArray.length > 0,
            "Address array length must be > 0"
        ); 
    }

    /**
     * Ensures that an address array and uint256 array are equal length
     *
     * @param  _addressArray       Address array input
     * @param  _uint256Array       Uint256 array input
     */    
    function validateEqualLength(
        address[] calldata _addressArray,
        uint256[] calldata _uint256Array
    )
        external
        pure
    {
        require(
            _addressArray.length == _uint256Array.length,
            "Input length mismatch"
        );
    }
}
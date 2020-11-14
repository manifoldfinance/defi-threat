/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

// hevm: flattened sources of src/fix.sol
pragma solidity >=0.4.23 >=0.5.0;

////// lib/ds-exec/src/exec.sol
// exec.sol - base contract used by anything that wants to do "untyped" calls

// Copyright (C) 2019 Maker

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

/* pragma solidity >=0.4.23; */

contract DSExec {
    function tryExec( address target, bytes memory data, uint value)
             internal
             returns (bool ok)
    {
        assembly {
            ok := call(gas, target, value, add(data, 0x20), mload(data), 0, 0)
        }
    }
    function exec( address target, bytes memory data, uint value)
             internal
    {
        if(!tryExec(target, data, value)) {
            revert("ds-exec-call-failed");
        }
    }

    // Convenience aliases
    function exec( address t, bytes memory c )
        internal
    {
        exec(t, c, 0);
    }
    function exec( address t, uint256 v )
        internal
    {
        bytes memory c; exec(t, c, v);
    }
    function tryExec( address t, bytes memory c )
        internal
        returns (bool)
    {
        return tryExec(t, c, 0);
    }
    function tryExec( address t, uint256 v )
        internal
        returns (bool)
    {
        bytes memory c; return tryExec(t, c, v);
    }
}

////// src/fix.sol
// fix.sol - change authorities

// Copyright (C) 2019 Mariano Conti, MakerDAO

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >=0.5.0; */

/* import "ds-exec/exec.sol"; */

contract Fix is DSExec {

    address constant public MOM    = 0xF2C5369cFFb8Ea6284452b0326e326DbFdCb867C; // SaiMom
    address constant public TOP    = 0x9b0ccf7C8994E19F39b2B4CF708e0A7DF65fA8a3; // SaiTop
    address constant public PIP    = 0x729D19f657BD0614b4985Cf1D82531c67569197B; // Pip
    address constant public PEP    = 0x5C1fc813d9c1B5ebb93889B3d63bA24984CA44B7; // Pep
    address constant public MKRUSD = 0x99041F808D598B782D5a3e498681C2452A31da08; // MKR/USD
    
    address constant public CHIEF  = 0x9eF05f7F6deB616fd37aC3c959a2dDD25A54E4F5; // New Chief
    
    bool public done;

    function cast() public {
        require(!done);

        bytes memory data = abi.encodeWithSignature("setAuthority(address)", CHIEF);
        
        exec(MOM, data, 0);
        exec(TOP, data, 0);
        
        exec(PIP, data, 0);
        exec(PEP, data, 0);
        
        exec(MKRUSD, data, 0);

        done = true;
    }
}
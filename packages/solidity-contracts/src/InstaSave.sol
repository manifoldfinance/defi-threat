/**
 * Source Code first verified at https://etherscan.io on Friday, May 3, 2019
 (UTC) */

pragma solidity ^0.5.0;

interface TubInterface {
    function open() external returns (bytes32);
    function join(uint) external;
    function exit(uint) external;
    function lock(bytes32, uint) external;
    function free(bytes32, uint) external;
    function draw(bytes32, uint) external;
    function wipe(bytes32, uint) external;
    function give(bytes32, address) external;
    function shut(bytes32) external;
    function cups(bytes32) external view returns (address, uint, uint, uint);
    function gem() external view returns (TokenInterface);
    function gov() external view returns (TokenInterface);
    function skr() external view returns (TokenInterface);
    function sai() external view returns (TokenInterface);
    function ink(bytes32) external view returns (uint);
    function tab(bytes32) external returns (uint);
    function rap(bytes32) external returns (uint);
    function per() external view returns (uint);
    function pep() external view returns (PepInterface);
}

interface PepInterface {
    function peek() external returns (bytes32, bool);
}


interface oracleInterface {
    function read() external view returns (bytes32);
}

interface UniswapExchange {
    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);
    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);
    function tokenToTokenSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint256 deadline,
        address tokenAddr
        ) external returns (uint256  tokensSold);
}


interface TokenInterface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function deposit() external payable;
    function withdraw(uint) external;
}

interface KyberInterface {
    function trade(
        address src,
        uint srcAmount,
        address dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
        ) external payable returns (uint);

    function getExpectedRate(
        address src,
        address dest,
        uint srcQty
        ) external view returns (uint, uint);
}


contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

}


contract Helpers is DSMath {

    /**
     * @dev get MakerDAO CDP engine
     */
    function getSaiTubAddress() public pure returns (address sai) {
        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;
    }

    /**
     * @dev get MakerDAO Oracle for ETH price
     */
    function getOracleAddress() public pure returns (address oracle) {
        oracle = 0x729D19f657BD0614b4985Cf1D82531c67569197B;
    }

    /**
     * @dev get uniswap MKR exchange
     */
    function getUniswapMKRExchange() public pure returns (address ume) {
        ume = 0x2C4Bd064b998838076fa341A83d007FC2FA50957;
    }

    /**
     * @dev get uniswap DAI exchange
     */
    function getUniswapDAIExchange() public pure returns (address ude) {
        ude = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;
    }

    /**
     * @dev get ethereum address for trade
     */
    function getAddressETH() public pure returns (address eth) {
        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    /**
     * @dev get ethereum address for trade
     */
    function getAddressDAI() public pure returns (address dai) {
        dai = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    }

    /**
     * @dev get kyber proxy address
     */
    function getAddressKyber() public pure returns (address kyber) {
        kyber = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    }

    /**
     * @dev get admin address
     */
    function getAddressAdmin() public pure returns (address payable admin) {
        admin = 0x7284a8451d9a0e7Dc62B3a71C0593eA2eC5c5638;
    }

    function getCDPStats(bytes32 cup) internal view returns (uint ethCol, uint daiDebt, uint usdPerEth) {
        TubInterface tub = TubInterface(getSaiTubAddress());
        usdPerEth = uint(oracleInterface(getOracleAddress()).read());
        (, uint pethCol, uint debt,) = tub.cups(cup);
        ethCol = rmul(pethCol, tub.per()); // get ETH col from PETH col
        daiDebt = debt;
    }

}


contract MakerHelpers is Helpers {

    event LogLock(uint cdpNum, uint amtETH, uint amtPETH, address owner);
    event LogFree(uint cdpNum, uint amtETH, uint amtPETH, address owner);
    event LogDraw(uint cdpNum, uint amtDAI, address owner);
    event LogWipe(uint cdpNum, uint daiAmt, uint mkrFee, uint daiFee, address owner);

    function setAllowance(TokenInterface _token, address _spender) internal {
        if (_token.allowance(address(this), _spender) != uint(-1)) {
            _token.approve(_spender, uint(-1));
        }
    }

    function lock(uint cdpNum, uint ethAmt) internal {
        if (ethAmt > 0) {
            bytes32 cup = bytes32(cdpNum);
            address tubAddr = getSaiTubAddress();

            TubInterface tub = TubInterface(tubAddr);
            TokenInterface weth = tub.gem();
            TokenInterface peth = tub.skr();

            (address lad,,,) = tub.cups(cup);
            require(lad == address(this), "cup-not-owned");

            weth.deposit.value(ethAmt)();

            uint ink = rdiv(ethAmt, tub.per());
            ink = rmul(ink, tub.per()) <= ethAmt ? ink : ink - 1;

            setAllowance(weth, tubAddr);
            tub.join(ink);

            setAllowance(peth, tubAddr);
            tub.lock(cup, ink);

            emit LogLock(
                cdpNum,
                ethAmt,
                ink,
                address(this)
            );
        }
    }

    function free(uint cdpNum, uint jam) internal {
        if (jam > 0) {
            bytes32 cup = bytes32(cdpNum);
            address tubAddr = getSaiTubAddress();

            TubInterface tub = TubInterface(tubAddr);
            TokenInterface peth = tub.skr();
            TokenInterface weth = tub.gem();

            uint ink = rdiv(jam, tub.per());
            ink = rmul(ink, tub.per()) <= jam ? ink : ink - 1;
            tub.free(cup, ink);

            setAllowance(peth, tubAddr);

            tub.exit(ink);
            uint freeJam = weth.balanceOf(address(this)); // withdraw possible previous stuck WETH as well
            weth.withdraw(freeJam);

            emit LogFree(
                cdpNum,
                freeJam,
                ink,
                address(this)
            );
        }
    }

    function draw(uint cdpNum, uint _wad) internal {
        bytes32 cup = bytes32(cdpNum);
        if (_wad > 0) {
            TubInterface tub = TubInterface(getSaiTubAddress());

            tub.draw(cup, _wad);

            emit LogDraw(cdpNum, _wad, address(this));
        }
    }

    function wipe(uint cdpNum, uint _wad) internal {
        if (_wad > 0) {
            TubInterface tub = TubInterface(getSaiTubAddress());
            UniswapExchange daiEx = UniswapExchange(getUniswapDAIExchange());
            UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());
            TokenInterface dai = tub.sai();
            TokenInterface mkr = tub.gov();

            bytes32 cup = bytes32(cdpNum);

            (address lad,,,) = tub.cups(cup);
            require(lad == address(this), "cup-not-owned");

            setAllowance(dai, getSaiTubAddress());
            setAllowance(mkr, getSaiTubAddress());
            setAllowance(dai, getUniswapDAIExchange());

            (bytes32 val, bool ok) = tub.pep().peek();

            // tub.rap(cup) = stability fee in $, tub.tab(cup) = total DAI debt
            uint mkrFee = wdiv(rmul(_wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val));
            // uint mkrFee = wdiv(rmul(_wad, rdiv(tub.rap(cup), add(tub.rap(cup), tub.tab(cup)))), uint(val));

            uint daiFeeAmt = daiEx.getTokenToEthOutputPrice(mkrEx.getEthToTokenOutputPrice(mkrFee));
            uint daiAmt = sub(_wad, daiFeeAmt);

            if (ok && val != 0) {
                daiEx.tokenToTokenSwapOutput(
                    mkrFee,
                    daiFeeAmt,
                    uint(999000000000000000000),
                    uint(1899063809), // 6th March 2030 GMT // no logic
                    address(mkr)
                );
            }

            tub.wipe(cup, daiAmt);

            emit LogWipe(
                cdpNum,
                _wad,
                mkrFee,
                daiFeeAmt,
                address(this)
            );

        }
    }

}


contract GetDetails is MakerHelpers {

    function getMax(uint cdpID) public view returns (uint maxColToFree, uint maxDaiToDraw, uint ethInUSD) {
        bytes32 cup = bytes32(cdpID);
        (uint ethCol, uint daiDebt, uint usdPerEth) = getCDPStats(cup);
        uint colToUSD = wmul(ethCol, usdPerEth) - 10;
        uint minColNeeded = wmul(daiDebt, 1500000000000000000) + 10;
        maxColToFree = wdiv(sub(colToUSD, minColNeeded), usdPerEth);
        uint maxDebtLimit = wdiv(colToUSD, 1500000000000000000) - 10;
        maxDaiToDraw = sub(maxDebtLimit, daiDebt);
        ethInUSD = usdPerEth;
    }

    function getSave(uint cdpID, uint ethToSwap) public view returns (uint finalEthCol, uint finalDaiDebt, uint finalColToUSD, bool canSave) {
        bytes32 cup = bytes32(cdpID);
        (uint ethCol, uint daiDebt, uint usdPerEth) = getCDPStats(cup);
        (finalEthCol, finalDaiDebt, finalColToUSD, canSave) = checkSave(
            ethCol,
            daiDebt,
            usdPerEth,
            ethToSwap
        );
    }

    function getLeverage(
        uint cdpID,
        uint daiToSwap
    ) public view returns (
        uint finalEthCol,
        uint finalDaiDebt,
        uint finalColToUSD,
        bool canLeverage
    )
    {
        bytes32 cup = bytes32(cdpID);
        (uint ethCol, uint daiDebt, uint usdPerEth) = getCDPStats(cup);
        (finalEthCol, finalDaiDebt, finalColToUSD, canLeverage) = checkLeverage(
            ethCol,
            daiDebt,
            usdPerEth,
            daiToSwap
        );
    }

    function checkSave(
        uint ethCol,
        uint daiDebt,
        uint usdPerEth,
        uint ethToSwap
    ) internal view returns
    (
        uint finalEthCol,
        uint finalDaiDebt,
        uint finalColToUSD,
        bool canSave
    )
    {
        uint colToUSD = wmul(ethCol, usdPerEth) - 10;
        uint minColNeeded = wmul(daiDebt, 1500000000000000000) + 10;
        uint colToFree = wdiv(sub(colToUSD, minColNeeded), usdPerEth);
        if (ethToSwap < colToFree) {
            colToFree = ethToSwap;
        }
        (uint expectedRate,) = KyberInterface(getAddressKyber()).getExpectedRate(getAddressETH(), getAddressDAI(), colToFree);
        expectedRate = wdiv(wmul(expectedRate, 99750000000000000000), 100000000000000000000);
        uint expectedDAI = wmul(colToFree, expectedRate);
        if (expectedDAI < daiDebt) {
            finalEthCol = sub(ethCol, colToFree);
            finalDaiDebt = sub(daiDebt, expectedDAI);
            finalColToUSD = wmul(finalEthCol, usdPerEth);
            canSave = true;
        } else {
            finalEthCol = 0;
            finalDaiDebt = 0;
            finalColToUSD = 0;
            canSave = false;
        }
    }

    function checkLeverage(
        uint ethCol,
        uint daiDebt,
        uint usdPerEth,
        uint daiToSwap
    ) internal view returns
    (
        uint finalEthCol,
        uint finalDaiDebt,
        uint finalColToUSD,
        bool canLeverage
    )
    {
        uint colToUSD = wmul(ethCol, usdPerEth) - 10;
        uint maxDebtLimit = wdiv(colToUSD, 1500000000000000000) - 10;
        uint debtToBorrow = sub(maxDebtLimit, daiDebt);
        if (daiToSwap < debtToBorrow) {
            debtToBorrow = daiToSwap;
        }
        (uint expectedRate,) = KyberInterface(getAddressKyber()).getExpectedRate(getAddressDAI(), getAddressETH(), debtToBorrow);
        expectedRate = wdiv(wmul(expectedRate, 99750000000000000000), 100000000000000000000);
        uint expectedETH = wmul(debtToBorrow, expectedRate);
        if (ethCol != 0) {
            finalEthCol = add(ethCol, expectedETH);
            finalDaiDebt = add(daiDebt, debtToBorrow);
            finalColToUSD = wmul(finalEthCol, usdPerEth);
            canLeverage = true;
        } else {
            finalEthCol = 0;
            finalDaiDebt = 0;
            finalColToUSD = 0;
            canLeverage = false;
        }
    }

}


contract Save is GetDetails {

    /**
     * @param what 2 for SAVE & 3 for LEVERAGE
     */
    event LogTrade(
        uint what, // 0 for BUY & 1 for SELL
        address src,
        uint srcAmt,
        address dest,
        uint destAmt,
        address beneficiary,
        uint minConversionRate,
        address affiliate
    );

    event LogSaveCDP(
        uint cdpID,
        uint srcETH,
        uint destDAI
    );

    event LogLeverageCDP(
        uint cdpID,
        uint srcDAI,
        uint destETH
    );


    function save(uint cdpID, uint colToSwap) public {
        bytes32 cup = bytes32(cdpID);
        (uint ethCol, uint daiDebt, uint usdPerEth) = getCDPStats(cup);
        uint colToFree = getColToFree(ethCol, daiDebt, usdPerEth);
        require(colToFree != 0, "no-collatral-to-free");
        if (colToSwap < colToFree) {
            colToFree = colToSwap;
        }
        uint thisBalance = address(this).balance;
        free(cdpID, colToFree);
        uint ethToSwap = wdiv(wmul(colToFree, 99750000000000000000), 100000000000000000000);
        getAddressAdmin().transfer(sub(colToFree, ethToSwap));
        uint destAmt = KyberInterface(getAddressKyber()).trade.value(ethToSwap)(
            getAddressETH(),
            ethToSwap,
            getAddressDAI(),
            address(this),
            daiDebt,
            0,
            getAddressAdmin()
        );
        wipe(cdpID, destAmt);

        if (thisBalance < address(this).balance) {
            uint balToLock = address(this).balance - thisBalance;
            lock(cdpID, balToLock);
        }

        emit LogSaveCDP(cdpID, ethToSwap, destAmt);

        emit LogTrade(
            0,
            getAddressETH(),
            colToFree,
            getAddressDAI(),
            destAmt,
            address(this),
            0,
            getAddressAdmin()
        );
    }

    function leverage(uint cdpID, uint daiToSwap) public {
        bytes32 cup = bytes32(cdpID);
        (uint ethCol, uint daiDebt, uint usdPerEth) = getCDPStats(cup);
        uint debtToBorrow = getDebtToBorrow(ethCol, daiDebt, usdPerEth);
        require(debtToBorrow != 0, "No-debt-to-borrow");
        if (daiToSwap < debtToBorrow) {
            debtToBorrow = daiToSwap;
        }
        draw(cdpID, debtToBorrow);
        setAllowance(TokenInterface(getAddressDAI()), getAddressKyber());
        uint destAmt = KyberInterface(getAddressKyber()).trade.value(0)(
            getAddressDAI(),
            debtToBorrow,
            getAddressETH(),
            address(this),
            2**255,
            0,
            getAddressAdmin()
        );
        uint ethToDeposit = wdiv(wmul(destAmt, 99750000000000000000), 100000000000000000000);
        getAddressAdmin().transfer(sub(destAmt, ethToDeposit));
        lock(cdpID, ethToDeposit);

        emit LogLeverageCDP(cdpID, debtToBorrow, destAmt);

        emit LogTrade(
            1,
            getAddressDAI(),
            debtToBorrow,
            getAddressETH(),
            destAmt,
            address(this),
            0,
            getAddressAdmin()
        );
    }

    function getColToFree(uint ethCol, uint daiDebt, uint usdPerEth) internal pure returns (uint colToFree) {
        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);
        uint minColNeeded = add(wmul(daiDebt, 1500000000000000000), 10);
        colToFree = sub(wdiv(sub(colToUSD, minColNeeded), usdPerEth), 10);
    }

    function getDebtToBorrow(uint ethCol, uint daiDebt, uint usdPerEth) internal pure returns (uint debtToBorrow) {
        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);
        uint maxDebtLimit = sub(wdiv(colToUSD, 1500000000000000000), 10);
        debtToBorrow = sub(maxDebtLimit, daiDebt);
    }

}


contract InstaSave is Save {

    uint public version;

    /**
     * @dev setting up variables on deployment
     * 1...2...3 versioning in each subsequent deployments
     */
    constructor(uint _version) public {
        version = _version;
    }

    function() external payable {}

}
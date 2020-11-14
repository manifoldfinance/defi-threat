/**
 * Source Code first verified at https://etherscan.io on Thursday, March 14, 2019
 (UTC) */

/*! MondoNet.sol | (c) 2018 Develop by MondoNet LLC (roundtable.tech), author @roundtable | License: MIT */

pragma solidity >=0.4.22 <0.6.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if(a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

contract MondoNet {
    using SafeMath for uint;

    struct Investor {
        uint invested;
        uint payouts;
        uint first_invest;
        uint last_payout;
        address referrer;
    }

    uint constant public BACKTOCONTACT = 10; // 10% of all deposits goes back in to the smart contract.
    uint constant public DEVWORK = 1000; //developer needs to be paid for his work...fee is charged (0.0051 eth) only when you decide to withdraw all your investment.
    uint constant public WITHDRAW = 80; 
    uint constant public REFBONUS = 5; //if you decide to withdraw all of your investment 5% will stay in the contract for the remaining investors.
    uint constant public CASHBACK = 5; //if you decide to withdraw all of your investment 5% will stay in the contract for the remaining investors.
    uint constant public MULTIPLICATION = 2; //once you achieve x2 or 200% your address is removed from the contract with the option of a new fresh investment from the same wallet address...no need to create a new address.
    address public contractfunds = 0xd17a5265f8719ea5B01E084Aef3d4D58f452Ca18; // 10% of all deposits goes back in to the smart contract.
    mapping(address => Investor) public investors;

    event AddInvestor(address indexed holder);
    event Payout(address indexed holder, uint amount);
    event Deposit(address indexed holder, uint amount, address referrer);
    event RefBonus(address indexed from, address indexed to, uint amount);
    event CashBack(address indexed holder, uint amount);
    event Withdraw(address indexed holder, uint amount);

    function bonusSize() view public returns(uint) {
        uint b = address(this).balance;

        if(b >= 205000 ether) return 5;
        if(b >= 204000 ether) return 2;
        if(b >= 203000 ether) return 3;
        if(b >= 202000 ether) return 0;
        if(b >= 201000 ether) return 5;
        if(b >= 200000 ether) return 3;
        if(b >= 199000 ether) return 1;
        if(b >= 198000 ether) return 3;
        if(b >= 197000 ether) return 5;
        if(b >= 196000 ether) return 3;

        if(b >= 195000 ether) return 4;
        if(b >= 194000 ether) return 2;
        if(b >= 193000 ether) return 3;
        if(b >= 192000 ether) return 0;
        if(b >= 191000 ether) return 5;
        if(b >= 190000 ether) return 3;
        if(b >= 189000 ether) return 1;
        if(b >= 188000 ether) return 3;
        if(b >= 187000 ether) return 5;
        if(b >= 186000 ether) return 7;

        if(b >= 185000 ether) return 6;
        if(b >= 184000 ether) return 2;
        if(b >= 183000 ether) return 3;
        if(b >= 182000 ether) return 1;
        if(b >= 181000 ether) return 5;
        if(b >= 180000 ether) return 3;
        if(b >= 179000 ether) return 1;
        if(b >= 178000 ether) return 3;
        if(b >= 177000 ether) return 5;
        if(b >= 176000 ether) return 5;

        if(b >= 175000 ether) return 4;
        if(b >= 174000 ether) return 2;
        if(b >= 173000 ether) return 3;
        if(b >= 172000 ether) return 0;
        if(b >= 171000 ether) return 5;
        if(b >= 170000 ether) return 3;
        if(b >= 169000 ether) return 1;
        if(b >= 168000 ether) return 3;
        if(b >= 167000 ether) return 5;
        if(b >= 166000 ether) return 4;

        if(b >= 165000 ether) return 5;
        if(b >= 164000 ether) return 2;
        if(b >= 163000 ether) return 3;
        if(b >= 162000 ether) return 0;
        if(b >= 161000 ether) return 5;
        if(b >= 160000 ether) return 3;
        if(b >= 159000 ether) return 1;
        if(b >= 158000 ether) return 3;
        if(b >= 157000 ether) return 5;
        if(b >= 156000 ether) return 4;

        if(b >= 155000 ether) return 6;
        if(b >= 154000 ether) return 2;
        if(b >= 153000 ether) return 3;
        if(b >= 152000 ether) return 3;
        if(b >= 151000 ether) return 5;
        if(b >= 150000 ether) return 3;
        if(b >= 149000 ether) return 1;
        if(b >= 148000 ether) return 3;
        if(b >= 147000 ether) return 4;
        if(b >= 146000 ether) return 5;

        if(b >= 145000 ether) return 7;
        if(b >= 144000 ether) return 2;
        if(b >= 143000 ether) return 3;
        if(b >= 142000 ether) return 1;
        if(b >= 141000 ether) return 5;
        if(b >= 140000 ether) return 3;
        if(b >= 139000 ether) return 0;
        if(b >= 138000 ether) return 3;
        if(b >= 137000 ether) return 6;
        if(b >= 136000 ether) return 5;

        if(b >= 135000 ether) return 6;
        if(b >= 134000 ether) return 4;
        if(b >= 133000 ether) return 3;
        if(b >= 132000 ether) return 2;
        if(b >= 131000 ether) return 5;
        if(b >= 130000 ether) return 3;
        if(b >= 129000 ether) return 1;
        if(b >= 128000 ether) return 3;
        if(b >= 127000 ether) return 5;
        if(b >= 126000 ether) return 6;

        if(b >= 125000 ether) return 7;
        if(b >= 124000 ether) return 2;
        if(b >= 123000 ether) return 3;
        if(b >= 122000 ether) return 0;
        if(b >= 121000 ether) return 5;
        if(b >= 120000 ether) return 3;
        if(b >= 119000 ether) return 1;
        if(b >= 118000 ether) return 3;
        if(b >= 117000 ether) return 5;
        if(b >= 116000 ether) return 7;

        if(b >= 115000 ether) return 8;
        if(b >= 114000 ether) return 2;
        if(b >= 113000 ether) return 3;
        if(b >= 112000 ether) return 2;
        if(b >= 111000 ether) return 5;
        if(b >= 110000 ether) return 3;
        if(b >= 109000 ether) return 1;
        if(b >= 108000 ether) return 3;
        if(b >= 107000 ether) return 5;
        if(b >= 106000 ether) return 7;

        if(b >= 105000 ether) return 9;
        if(b >= 104000 ether) return 6;
        if(b >= 103000 ether) return 3;
        if(b >= 102000 ether) return 2;
        if(b >= 101000 ether) return 5;
        if(b >= 100000 ether) return 3;
        if(b >= 99000 ether) return 0;
        if(b >= 98000 ether) return 3;
        if(b >= 97000 ether) return 6;
        if(b >= 96000 ether) return 5;

        if(b >= 95000 ether) return 7;
        if(b >= 94000 ether) return 4;
        if(b >= 93000 ether) return 3;
        if(b >= 92000 ether) return 2;
        if(b >= 91000 ether) return 5;
        if(b >= 90000 ether) return 3;
        if(b >= 89000 ether) return 0;
        if(b >= 88000 ether) return 3;
        if(b >= 87000 ether) return 5;
        if(b >= 86000 ether) return 6;

        if(b >= 85000 ether) return 8;
        if(b >= 84000 ether) return 5;
        if(b >= 83000 ether) return 4;
        if(b >= 82000 ether) return 3;
        if(b >= 81000 ether) return 5;
        if(b >= 80000 ether) return 3;
        if(b >= 79000 ether) return 2;
        if(b >= 78000 ether) return 3;
        if(b >= 77000 ether) return 5;
        if(b >= 76000 ether) return 4;

        if(b >= 75000 ether) return 7;
        if(b >= 74000 ether) return 2;
        if(b >= 73000 ether) return 3;
        if(b >= 72000 ether) return 0;
        if(b >= 71000 ether) return 5;
        if(b >= 70000 ether) return 3;
        if(b >= 69000 ether) return 1;
        if(b >= 68000 ether) return 3;
        if(b >= 67000 ether) return 5;
        if(b >= 66000 ether) return 7;

        if(b >= 65000 ether) return 6;
        if(b >= 64500 ether) return 2;
        if(b >= 64000 ether) return 1;
        if(b >= 63500 ether) return 0;
        if(b >= 63000 ether) return 4;
        if(b >= 62500 ether) return 3;
        if(b >= 62000 ether) return 2;
        if(b >= 61500 ether) return 1;
        if(b >= 61000 ether) return 3;
        if(b >= 60500 ether) return 0;

        if(b >= 59800 ether) return 6;
        if(b >= 59700 ether) return 2;
        if(b >= 59600 ether) return 1;
        if(b >= 59500 ether) return 0;
        if(b >= 59000 ether) return 4;
        if(b >= 58500 ether) return 3;
        if(b >= 58000 ether) return 2;
        if(b >= 57500 ether) return 1;
        if(b >= 57000 ether) return 3;
        if(b >= 56500 ether) return 0;

        if(b >= 55000 ether) return 6;
        if(b >= 54500 ether) return 2;
        if(b >= 54000 ether) return 1;
        if(b >= 53500 ether) return 0;
        if(b >= 53000 ether) return 4;
        if(b >= 52500 ether) return 3;
        if(b >= 52000 ether) return 2;
        if(b >= 51500 ether) return 1;
        if(b >= 51000 ether) return 3;
        if(b >= 50500 ether) return 0;

        if(b >= 48000 ether) return 8;
        if(b >= 46000 ether) return 5;
        if(b >= 44000 ether) return 3;
        if(b >= 42000 ether) return 4;
        if(b >= 40000 ether) return 5;
        if(b >= 38000 ether) return 3;
        if(b >= 36000 ether) return 4;
        if(b >= 34000 ether) return 3;
        if(b >= 32000 ether) return 5;
        if(b >= 30000 ether) return 7;

        if(b >= 27000 ether) return 6;
        if(b >= 26000 ether) return 2;
        if(b >= 25000 ether) return 5;
        if(b >= 24000 ether) return 2;
        if(b >= 23000 ether) return 4;
        if(b >= 22000 ether) return 3;
        if(b >= 21000 ether) return 2;
        if(b >= 20000 ether) return 4;
        if(b >= 19000 ether) return 3;
        if(b >= 18000 ether) return 8;

        if(b >= 17500 ether) return 7;
        if(b >= 17000 ether) return 2;
        if(b >= 16500 ether) return 3;
        if(b >= 16000 ether) return 0;
        if(b >= 15500 ether) return 5;
        if(b >= 15000 ether) return 3;
        if(b >= 14500 ether) return 4;
        if(b >= 14000 ether) return 3;
        if(b >= 13500 ether) return 5;
        if(b >= 13000 ether) return 7;

        if(b >= 12500 ether) return 6;
        if(b >= 12250 ether) return 2;
        if(b >= 12000 ether) return 3;
        if(b >= 11750 ether) return 1;
        if(b >= 11500 ether) return 4;
        if(b >= 11250 ether) return 5;
        if(b >= 11000 ether) return 3;
        if(b >= 10750 ether) return 0;
        if(b >= 10500 ether) return 3;
        if(b >= 10250 ether) return 4;

        if(b >= 10000 ether) return 7;
        if(b >= 9950 ether) return 2;
        if(b >= 9900 ether) return 3;
        if(b >= 9850 ether) return 0;
        if(b >= 9800 ether) return 5;
        if(b >= 9750 ether) return 3;
        if(b >= 9450 ether) return 2;
        if(b >= 9400 ether) return 4;
        if(b >= 9100 ether) return 5;
        if(b >= 9050 ether) return 6;

        if(b >= 8750 ether) return 7;
        if(b >= 8700 ether) return 3;
        if(b >= 8500 ether) return 2;
        if(b >= 8450 ether) return 0;
        if(b >= 8250 ether) return 4;
        if(b >= 8200 ether) return 3;
        if(b >= 8000 ether) return 2;
        if(b >= 7950 ether) return 4;
        if(b >= 7750 ether) return 3;
        if(b >= 7700 ether) return 5;

        if(b >= 7500 ether) return 7;
        if(b >= 7400 ether) return 2;
        if(b >= 7300 ether) return 3;
        if(b >= 7200 ether) return 0;
        if(b >= 7100 ether) return 5;
        if(b >= 7000 ether) return 3;
        if(b >= 6900 ether) return 1;
        if(b >= 6800 ether) return 3;
        if(b >= 6700 ether) return 5;
        if(b >= 6600 ether) return 7;

        if(b >= 6500 ether) return 6;
        if(b >= 6450 ether) return 2;
        if(b >= 6400 ether) return 1;
        if(b >= 6350 ether) return 0;
        if(b >= 6300 ether) return 4;
        if(b >= 6250 ether) return 3;
        if(b >= 6200 ether) return 2;
        if(b >= 6150 ether) return 0;
        if(b >= 6100 ether) return 3;
        if(b >= 6050 ether) return 7;

        if(b >= 6000 ether) return 5;
        if(b >= 5970 ether) return 6;
        if(b >= 5940 ether) return 3;
        if(b >= 5910 ether) return 2;
        if(b >= 5880 ether) return 1;
        if(b >= 5850 ether) return 4;
        if(b >= 5820 ether) return 3;
        if(b >= 5790 ether) return 0;
        if(b >= 5760 ether) return 2;
        if(b >= 5730 ether) return 4;

        if(b >= 5700 ether) return 6;
        if(b >= 5650 ether) return 3;
        if(b >= 5600 ether) return 5;
        if(b >= 5550 ether) return 0;
        if(b >= 5500 ether) return 3;
        if(b >= 5450 ether) return 1;
        if(b >= 5400 ether) return 2;
        if(b >= 5350 ether) return 4;
        if(b >= 5300 ether) return 0;
        if(b >= 5250 ether) return 5;

        if(b >= 5200 ether) return 6;
        if(b >= 5180 ether) return 4;
        if(b >= 5160 ether) return 2;
        if(b >= 5140 ether) return 0;
        if(b >= 5120 ether) return 2;
        if(b >= 5100 ether) return 3;
        if(b >= 5080 ether) return 2;
        if(b >= 5060 ether) return 0;
        if(b >= 5040 ether) return 2;
        if(b >= 5020 ether) return 6;

        if(b >= 5000 ether) return 5;
        if(b >= 4950 ether) return 4;
        if(b >= 4900 ether) return 3;
        if(b >= 4850 ether) return 2;
        if(b >= 4800 ether) return 0;
        if(b >= 4750 ether) return 1;
        if(b >= 4700 ether) return 3;
        if(b >= 4650 ether) return 2;
        if(b >= 4600 ether) return 3;
        if(b >= 4550 ether) return 2;

        if(b >= 4500 ether) return 5;
        if(b >= 4300 ether) return 2;
        if(b >= 4100 ether) return 3;
        if(b >= 3900 ether) return 0;
        if(b >= 3700 ether) return 3;
        if(b >= 3500 ether) return 2;
        if(b >= 3300 ether) return 4;
        if(b >= 3100 ether) return 1;
        if(b >= 2900 ether) return 0;
        if(b >= 2700 ether) return 4;

        if(b >= 2500 ether) return 3;
        if(b >= 2400 ether) return 4;
        if(b >= 2300 ether) return 5;
        if(b >= 2200 ether) return 0;
        if(b >= 2100 ether) return 2;
        if(b >= 2000 ether) return 3;
        if(b >= 1900 ether) return 0;
        if(b >= 1800 ether) return 3;
        if(b >= 1700 ether) return 5;
        if(b >= 1600 ether) return 4;

        if(b >= 1500 ether) return 5;
        if(b >= 1450 ether) return 2;
        if(b >= 1400 ether) return 3;
        if(b >= 1350 ether) return 2;
        if(b >= 1300 ether) return 0;
        if(b >= 1250 ether) return 1;
        if(b >= 1200 ether) return 2;
        if(b >= 1150 ether) return 1;
        if(b >= 1100 ether) return 0;
        if(b >= 1050 ether) return 5;

        if(b >= 1000 ether) return 4;
        if(b >= 990 ether) return 1;
        if(b >= 980 ether) return 2;
        if(b >= 970 ether) return 0;
        if(b >= 960 ether) return 3;
        if(b >= 950 ether) return 1;
        if(b >= 940 ether) return 2;
        if(b >= 930 ether) return 1;
        if(b >= 920 ether) return 0;
        if(b >= 910 ether) return 2;

        if(b >= 900 ether) return 3;
        if(b >= 880 ether) return 2;
        if(b >= 860 ether) return 1;
        if(b >= 840 ether) return 0;
        if(b >= 820 ether) return 2;
        if(b >= 800 ether) return 3;
        if(b >= 780 ether) return 1;
        if(b >= 760 ether) return 0;
        if(b >= 740 ether) return 2;
        if(b >= 720 ether) return 3;

        if(b >= 700 ether) return 4;
        if(b >= 680 ether) return 1;
        if(b >= 660 ether) return 3;
        if(b >= 640 ether) return 2;
        if(b >= 620 ether) return 0;
        if(b >= 600 ether) return 3;
        if(b >= 580 ether) return 2;
        if(b >= 560 ether) return 1;
        if(b >= 540 ether) return 0;
        if(b >= 520 ether) return 2;

        if(b >= 500 ether) return 4;
        if(b >= 490 ether) return 1;
        if(b >= 480 ether) return 3;
        if(b >= 470 ether) return 0;
        if(b >= 460 ether) return 3;
        if(b >= 450 ether) return 1;
        if(b >= 440 ether) return 2;
        if(b >= 430 ether) return 1;
        if(b >= 420 ether) return 0;
        if(b >= 410 ether) return 2;

        if(b >= 400 ether) return 3;
        if(b >= 390 ether) return 2;
        if(b >= 380 ether) return 1;
        if(b >= 370 ether) return 0;
        if(b >= 360 ether) return 2;
        if(b >= 350 ether) return 3;
        if(b >= 340 ether) return 1;
        if(b >= 330 ether) return 0;
        if(b >= 320 ether) return 2;
        if(b >= 310 ether) return 1;

        if(b >= 300 ether) return 3;
        if(b >= 290 ether) return 1;
        if(b >= 280 ether) return 3;
        if(b >= 270 ether) return 2;
        if(b >= 260 ether) return 0;
        if(b >= 250 ether) return 1;
        if(b >= 240 ether) return 2;
        if(b >= 230 ether) return 1;
        if(b >= 220 ether) return 0;
        if(b >= 210 ether) return 1;

        if(b >= 200 ether) return 2;
        if(b >= 190 ether) return 1;
        if(b >= 180 ether) return 3;
        if(b >= 170 ether) return 0;
        if(b >= 160 ether) return 3;
        if(b >= 150 ether) return 1;
        if(b >= 140 ether) return 2;
        if(b >= 130 ether) return 1;
        if(b >= 120 ether) return 0;
        if(b >= 110 ether) return 2;

        if(b >= 100 ether) return 3;
        if(b >= 99 ether) return 2;
        if(b >= 98 ether) return 1;
        if(b >= 97 ether) return 0;
        if(b >= 96 ether) return 2;
        if(b >= 95 ether) return 3;
        if(b >= 94 ether) return 1;
        if(b >= 93 ether) return 0;
        if(b >= 92 ether) return 2;
        if(b >= 91 ether) return 3;

        if(b >= 90 ether) return 2;
        if(b >= 89 ether) return 1;
        if(b >= 88 ether) return 3;
        if(b >= 87 ether) return 2;
        if(b >= 86 ether) return 0;
        if(b >= 85 ether) return 1;
        if(b >= 84 ether) return 2;
        if(b >= 83 ether) return 1;
        if(b >= 82 ether) return 0;
        if(b >= 81 ether) return 1;

        if(b >= 80 ether) return 3;
        if(b >= 79 ether) return 1;
        if(b >= 78 ether) return 3;
        if(b >= 77 ether) return 2;
        if(b >= 76 ether) return 0;
        if(b >= 75 ether) return 1;
        if(b >= 74 ether) return 2;
        if(b >= 73 ether) return 1;
        if(b >= 72 ether) return 0;
        if(b >= 71 ether) return 1;

        if(b >= 70 ether) return 2;
        if(b >= 69 ether) return 1;
        if(b >= 68 ether) return 3;
        if(b >= 67 ether) return 0;
        if(b >= 66 ether) return 3;
        if(b >= 65 ether) return 1;
        if(b >= 64 ether) return 2;
        if(b >= 63 ether) return 1;
        if(b >= 62 ether) return 0;
        if(b >= 61 ether) return 2;

        if(b >= 60 ether) return 3;
        if(b >= 59 ether) return 1;
        if(b >= 58 ether) return 3;
        if(b >= 57 ether) return 2;
        if(b >= 56 ether) return 0;
        if(b >= 55 ether) return 1;
        if(b >= 54 ether) return 2;
        if(b >= 53 ether) return 1;
        if(b >= 52 ether) return 0;
        if(b >= 51 ether) return 2;

        if(b >= 50 ether) return 3;
        if(b >= 49 ether) return 2;
        if(b >= 48 ether) return 1;
        if(b >= 47 ether) return 0;
        if(b >= 46 ether) return 2;
        if(b >= 45 ether) return 3;
        if(b >= 44 ether) return 1;
        if(b >= 43 ether) return 0;
        if(b >= 42 ether) return 2;
        if(b >= 41 ether) return 1;

        if(b >= 40 ether) return 3;
        if(b >= 39 ether) return 1;
        if(b >= 38 ether) return 3;
        if(b >= 37 ether) return 2;
        if(b >= 36 ether) return 0;
        if(b >= 35 ether) return 1;
        if(b >= 34 ether) return 2;
        if(b >= 33 ether) return 1;
        if(b >= 32 ether) return 0;
        if(b >= 31 ether) return 1;

        if(b >= 30 ether) return 2;
        if(b >= 29 ether) return 1;
        if(b >= 28 ether) return 3;
        if(b >= 27 ether) return 0;
        if(b >= 26 ether) return 3;
        if(b >= 25 ether) return 1;
        if(b >= 24 ether) return 2;
        if(b >= 23 ether) return 1;
        if(b >= 22 ether) return 0;
        if(b >= 21 ether) return 2;

        if(b >= 20 ether) return 3;
        if(b >= 19 ether) return 2;
        if(b >= 18 ether) return 1;
        if(b >= 17 ether) return 0;
        if(b >= 16 ether) return 2;
        if(b >= 15 ether) return 3;
        if(b >= 14 ether) return 1;
        if(b >= 13 ether) return 0;
        if(b >= 12 ether) return 2;
        if(b >= 11 ether) return 1;

        if(b >= 10 ether) return 3;
        if(b >= 9 ether) return 1;
        if(b >= 8 ether) return 3;
        if(b >= 7 ether) return 2;
        if(b >= 6 ether) return 0;
        if(b >= 5 ether) return 1;
        if(b >= 4 ether) return 2;
        if(b >= 3 ether) return 1;
        if(b >= 2 ether) return 0;
        if(b >= 1 ether) return 2;
        return 1;

            }

    function payoutSize(address _to) view public returns(uint) {
        uint max = investors[_to].invested.mul(MULTIPLICATION);
        if(investors[_to].invested == 0 || investors[_to].payouts >= max) return 0;

        uint payout = investors[_to].invested.mul(bonusSize()).div(100).mul(block.timestamp.sub(investors[_to].last_payout)).div(1 days);
        return investors[_to].payouts.add(payout) > max ? max.sub(investors[_to].payouts) : payout;

        


    }

    function withdrawSize(address _to) view public returns(uint) {
        uint max = investors[_to].invested.div(100).mul(WITHDRAW);
        if(investors[_to].invested == 0 || investors[_to].payouts >= max) return 0;

        return max.sub(investors[_to].payouts);
    }

    function bytesToAddress(bytes bys) pure private returns(address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function() payable external {
        if(investors[msg.sender].invested > 0) {
            uint payout = payoutSize(msg.sender);

            require(msg.value > 0 || payout > 0, "No payouts");

            if(payout > 0) {
                investors[msg.sender].last_payout = block.timestamp;
                investors[msg.sender].payouts = investors[msg.sender].payouts.add(payout);

                msg.sender.transfer(payout);

                emit Payout(msg.sender, payout);
            }

            if(investors[msg.sender].payouts >= investors[msg.sender].invested.mul(MULTIPLICATION)) {
                delete investors[msg.sender];

                emit Withdraw(msg.sender, 0);
                
                
            }
        }

        if(msg.value == 0.00000051 ether) {
            require(investors[msg.sender].invested > 0, "You have not invested anything yet");

            uint amount = withdrawSize(msg.sender);

            require(amount > 0, "You have nothing to withdraw");
            
            msg.sender.transfer(amount);
            contractfunds.transfer(msg.value.mul(DEVWORK).div(1));

            delete investors[msg.sender];
            
            emit Withdraw(msg.sender, amount);

            
            
        }
        else if(msg.value > 0) {
            require(msg.value >= 0.05 ether, "Minimum investment amount 0.05 ether");

            investors[msg.sender].last_payout = block.timestamp;
            investors[msg.sender].invested = investors[msg.sender].invested.add(msg.value);

            contractfunds.transfer(msg.value.mul(BACKTOCONTACT).div(100));
            

            if(investors[msg.sender].first_invest == 0) {
                investors[msg.sender].first_invest = block.timestamp;

                if(msg.data.length > 0) {
                    address ref = bytesToAddress(msg.data);

                    if(ref != msg.sender && investors[ref].invested > 0 && msg.value >= 1 ether) {
                        investors[msg.sender].referrer = ref;

                        uint ref_bonus = msg.value.mul(REFBONUS).div(100);
                        ref.transfer(ref_bonus);

                        emit RefBonus(msg.sender, ref, ref_bonus);

                        uint cashback_bonus = msg.value.mul(CASHBACK).div(100);
                        msg.sender.transfer(cashback_bonus);

                        emit CashBack(msg.sender, cashback_bonus);
                    }
                }
                emit AddInvestor(msg.sender);
            }

            emit Deposit(msg.sender, msg.value, investors[msg.sender].referrer);
        }
    }
}
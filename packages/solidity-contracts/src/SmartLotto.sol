/**
 * Source Code first verified at https://etherscan.io on Thursday, March 28, 2019
 (UTC) */

pragma solidity ^0.5.1;

/**
 *	Lottery 5 of 36 (Weekly)
 */
 
contract SmartLotto {
    
	// For safe math operations
    using SafeMath for uint;
    
    // Drawing time
    uint8 private constant DRAW_DOW = 4;            // Day of week
    uint8 private constant DRAW_HOUR = 11;          // Hour
    
    uint private constant DAY_IN_SECONDS = 86400;
	
	// Member struct
	struct Member {
		address payable addr;						// Address
		uint ticket;								// Ticket number
		uint8[5] numbers;                           // Selected numbers
		uint8 matchNumbers;                         // Match numbers
		uint prize;                                 // Winning prize
	}
	
	
	// Game struct
	struct Game {
		uint datetime;								// Game timestamp
		uint8[5] win_numbers;						// Winning numbers
		uint membersCounter;						// Members count
		uint totalFund;                             // Total prize fund
		uint8 status;                               // Game status: 0 - created, 1 - pleyed
		mapping(uint => Member) members;		    // Members list
	}
	
	mapping(uint => Game) public games;
	
	uint private CONTRACT_STARTED_DATE = 0;
	uint private constant TICKET_PRICE = 0.01 ether;
	uint private constant MAX_NUMBER = 36;						            // Максимально возможное число -> 36
	
	uint private constant PERCENT_FUND_JACKPOT = 15;                        // (%) Increase Jackpot
	uint private constant PERCENT_FUND_4 = 35;                              // (%) Fund 4 of 5
	uint private constant PERCENT_FUND_3 = 30;                              // (%) Fund 3 of 5
    uint private constant PERCENT_FUND_2 = 20;                              // (%) Fund 2 of 5
    
	uint public JACKPOT = 0;
	
	// Init params
	uint public GAME_NUM = 0;
	uint private constant return_jackpot_period = 25 weeks;
	uint private start_jackpot_amount = 0;
	
	uint private constant PERCENT_FUND_PR = 12;                             // (%) PR & ADV
	uint private FUND_PR = 0;                                               // Fund PR & ADV

	// Addresses
	address private constant ADDRESS_SERVICE = 0x203bF6B46508eD917c085F50F194F36b0a62EB02;
	address payable private constant ADDRESS_START_JACKPOT = 0x531d3Bd0400Ae601f26B335EfbD787415Aa5CB81;
	address payable private constant ADDRESS_PR = 0xCD66911b6f38FaAF5BFeE427b3Ceb7D18Dd09F78;
	
	// Events
	event NewMember(uint _gamenum, uint _ticket, address _addr, uint8 _n1, uint8 _n2, uint8 _n3, uint8 _n4, uint8 _n5);
	event NewGame(uint _gamenum);
	event UpdateFund(uint _fund);
	event UpdateJackpot(uint _jackpot);
	event WinNumbers(uint _gamenum, uint8 _n1, uint8 _n2, uint8 _n3, uint8 _n4, uint8 _n5);
	event WinPrize(uint _gamenum, uint _ticket, uint _prize, uint8 _match);

	// Entry point
	function() external payable {
	    
        // Select action
		if(msg.sender == ADDRESS_START_JACKPOT) {
			processStartingJackpot();
		} else {
			if(msg.sender == ADDRESS_SERVICE) {
				startGame();
			} else {
				processUserTicket();
			}
		}
		
    }
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// Starting Jackpot action
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	function processStartingJackpot() private {
		// If value > 0, increase starting Jackpot
		if(msg.value > 0) {
			JACKPOT += msg.value;
			start_jackpot_amount += msg.value;
			emit UpdateJackpot(JACKPOT);
		// Else, return starting Jackpot
		} else {
			if(start_jackpot_amount > 0){
				_returnStartJackpot();
			}
		}
		
	}
	
	// Return starting Jackpot after 6 months
	function _returnStartJackpot() private { 
		
		if(JACKPOT > start_jackpot_amount * 2 || (now - CONTRACT_STARTED_DATE) > return_jackpot_period) {
			
			if(JACKPOT > start_jackpot_amount) {
				ADDRESS_START_JACKPOT.transfer(start_jackpot_amount);
				JACKPOT = JACKPOT - start_jackpot_amount;
				start_jackpot_amount = 0;
			} else {
				ADDRESS_START_JACKPOT.transfer(JACKPOT);
				start_jackpot_amount = 0;
				JACKPOT = 0;
			}
			emit UpdateJackpot(JACKPOT);
			
		} 
		
	}
	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// Running a Game
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	function startGame() private {
	    
	    uint8 weekday = getWeekday(now);
		uint8 hour = getHour(now);
	    
		if(GAME_NUM == 0) {
		    GAME_NUM = 1;
		    games[GAME_NUM].datetime = now;
		    games[GAME_NUM].status = 1;
		    CONTRACT_STARTED_DATE = now;
		} else {
		    if(weekday == DRAW_DOW && hour == DRAW_HOUR) {

		        if(games[GAME_NUM].status == 1) {
		            processGame();
		        }

		    } else {
		        games[GAME_NUM].status = 1;
		    }
		    
		}
        
	}
	
	function processGame() private {
	    
	    uint8 mn = 0;
		uint winners5 = 0;
		uint winners4 = 0;
		uint winners3 = 0;
		uint winners2 = 0;

		uint fund4 = 0;
		uint fund3 = 0;
		uint fund2 = 0;
	    
	    // Generate winning numbers
	    for(uint8 i = 0; i < 5; i++) {
	        games[GAME_NUM].win_numbers[i] = random(i);
	    }

	    // Sort winning numbers array
	    games[GAME_NUM].win_numbers = sortNumbers(games[GAME_NUM].win_numbers);
	    
	    // Change dublicate numbers
	    for(uint8 i = 0; i < 4; i++) {
	        for(uint8 j = i+1; j < 5; j++) {
	            if(games[GAME_NUM].win_numbers[i] == games[GAME_NUM].win_numbers[j]) {
	                games[GAME_NUM].win_numbers[j]++;
	            }
	        }
	    }
	    
	    uint8[5] memory win_numbers;
	    win_numbers = games[GAME_NUM].win_numbers;
	    emit WinNumbers(GAME_NUM, win_numbers[0], win_numbers[1], win_numbers[2], win_numbers[3], win_numbers[4]);
	    
	    if(games[GAME_NUM].membersCounter > 0) {
	    
	        // Pocess tickets list
	        for(uint i = 1; i <= games[GAME_NUM].membersCounter; i++) {
	            
	            mn = findMatch(games[GAME_NUM].win_numbers, games[GAME_NUM].members[i].numbers);
				games[GAME_NUM].members[i].matchNumbers = mn;
				
				if(mn == 5) {
					winners5++;
				}
				if(mn == 4) {
					winners4++;
				}
				if(mn == 3) {
					winners3++;
				}
				if(mn == 2) {
					winners2++;
				}
				
	        }
	        
	        // Fund calculate
	        JACKPOT = JACKPOT + games[GAME_NUM].totalFund * PERCENT_FUND_JACKPOT / 100;
			fund4 = games[GAME_NUM].totalFund * PERCENT_FUND_4 / 100;
			fund3 = games[GAME_NUM].totalFund * PERCENT_FUND_3 / 100;
			fund2 = games[GAME_NUM].totalFund * PERCENT_FUND_2 / 100;
			
			if(winners4 == 0) {
			    JACKPOT = JACKPOT + fund4;
			}
			if(winners3 == 0) {
			    JACKPOT = JACKPOT + fund3;
			}
			if(winners2 == 0) {
			    JACKPOT = JACKPOT + fund2;
			}
            
			for(uint i = 1; i <= games[GAME_NUM].membersCounter; i++) {
			    
			    if(games[GAME_NUM].members[i].matchNumbers == 5) {
			        games[GAME_NUM].members[i].prize = JACKPOT / winners5;
			        games[GAME_NUM].members[i].addr.transfer(games[GAME_NUM].members[i].prize);
			        emit WinPrize(GAME_NUM, games[GAME_NUM].members[i].ticket, games[GAME_NUM].members[i].prize, 5);
			    }
			    
			    if(games[GAME_NUM].members[i].matchNumbers == 4) {
			        games[GAME_NUM].members[i].prize = fund4 / winners4;
			        games[GAME_NUM].members[i].addr.transfer(games[GAME_NUM].members[i].prize);
			        emit WinPrize(GAME_NUM, games[GAME_NUM].members[i].ticket, games[GAME_NUM].members[i].prize, 4);
			    }
			    
			    if(games[GAME_NUM].members[i].matchNumbers == 3) {
			        games[GAME_NUM].members[i].prize = fund3 / winners3;
			        games[GAME_NUM].members[i].addr.transfer(games[GAME_NUM].members[i].prize);
			        emit WinPrize(GAME_NUM, games[GAME_NUM].members[i].ticket, games[GAME_NUM].members[i].prize, 3);
			    }
			    
			    if(games[GAME_NUM].members[i].matchNumbers == 2) {
			        games[GAME_NUM].members[i].prize = fund2 / winners2;
			        games[GAME_NUM].members[i].addr.transfer(games[GAME_NUM].members[i].prize);
			        emit WinPrize(GAME_NUM, games[GAME_NUM].members[i].ticket, games[GAME_NUM].members[i].prize, 2);
			    }
			    
			    if(games[GAME_NUM].members[i].matchNumbers == 1) {
			        emit WinPrize(GAME_NUM, games[GAME_NUM].members[i].ticket, games[GAME_NUM].members[i].prize, 1);
			    }
			    
			}
			
			// If exist Jackpot winners, init JACPOT
			if(winners5 != 0) {
			    JACKPOT = 0;
			    start_jackpot_amount = 0;
			}
			
	    }
	    
	    emit UpdateJackpot(JACKPOT);
	    
	    // Init next Game
	    GAME_NUM++;
	    games[GAME_NUM].datetime = now;
	    games[GAME_NUM].status = 0;
	    emit NewGame(GAME_NUM);
	    
	    // Transfer
	    ADDRESS_PR.transfer(FUND_PR);
	    FUND_PR = 0;
	    
	}
	
	// Find match numbers function
	function findMatch(uint8[5] memory arr1, uint8[5] memory arr2) private pure returns (uint8) {
	    
	    uint8 cnt = 0;
	    
	    for(uint8 i = 0; i < 5; i++) {
	        for(uint8 j = 0; j < 5; j++) {
	            if(arr1[i] == arr2[j]) {
	                cnt++;
	                break;
	            }
	        }
	    }
	    
	    return cnt;

	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// Buy ticket process
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	function processUserTicket() private {
		
		uint8 weekday = getWeekday(now);
		uint8 hour = getHour(now);
		
		if( GAME_NUM > 0 && games[GAME_NUM].status == 1 && 
		    (weekday != DRAW_DOW || (weekday == DRAW_DOW && (hour < (DRAW_HOUR - 1) || hour > (DRAW_HOUR + 2)))) ) {

		    if(msg.value == TICKET_PRICE) {
			    createTicket();
		    } else {
			    if(msg.value < TICKET_PRICE) {
				    FUND_PR = FUND_PR + msg.value.mul(PERCENT_FUND_PR).div(100);
				    games[GAME_NUM].totalFund = games[GAME_NUM].totalFund + msg.value.mul(100 - PERCENT_FUND_PR).div(100);
				    emit UpdateFund(games[GAME_NUM].totalFund);
			    } else {
				    msg.sender.transfer(msg.value.sub(TICKET_PRICE));
				    createTicket();
			    }
		    }
		
		} else {
		     msg.sender.transfer(msg.value);
		}
		
	}
	
	function createTicket() private {
		
		bool err = false;
		uint8[5] memory numbers;
		
		// Calculate funds
		FUND_PR = FUND_PR + TICKET_PRICE.mul(PERCENT_FUND_PR).div(100);
		games[GAME_NUM].totalFund = games[GAME_NUM].totalFund + TICKET_PRICE.mul(100 - PERCENT_FUND_PR).div(100);
		emit UpdateFund(games[GAME_NUM].totalFund);
		
		// Parse and check msg.DATA
		(err, numbers) = ParseCheckData();
		
		uint mbrCnt;
		
		// If error DATA, generate random ticket numbers
		if(err) {
		    
		    // Generate numbers
	        for(uint8 i = 0; i < 5; i++) {
	            numbers[i] = random(i);
	        }

	        // Sort ticket numbers array
	        numbers = sortNumbers(numbers);
	    
	        // Change dublicate numbers
	        for(uint8 i = 0; i < 4; i++) {
	            for(uint8 j = i+1; j < 5; j++) {
	                if(numbers[i] == numbers[j]) {
	                    numbers[j]++;
	                }
	            }
	        }
	        
		}

	    // Increase member counter
	    games[GAME_NUM].membersCounter++;
	    mbrCnt = games[GAME_NUM].membersCounter;

	    // Save member
	    games[GAME_NUM].members[mbrCnt].addr = msg.sender;
	    games[GAME_NUM].members[mbrCnt].ticket = mbrCnt;
	    games[GAME_NUM].members[mbrCnt].numbers = numbers;
	    games[GAME_NUM].members[mbrCnt].matchNumbers = 0;
		    
	    emit NewMember(GAME_NUM, mbrCnt, msg.sender, numbers[0], numbers[1], numbers[2], numbers[3], numbers[4]);

	}
	
	
	// Parse and check msg.DATA function
	function ParseCheckData() private view returns (bool, uint8[5] memory) {
	    
	    bool err = false;
	    uint8[5] memory numbers;
	    
	    // Check 5 numbers entered
	    if(msg.data.length == 5) {
	        
	        // Parse DATA string
		    for(uint8 i = 0; i < msg.data.length; i++) {
		        numbers[i] = uint8(msg.data[i]);
		    }
		    
		    // Check range: 1 - MAX_NUMBER
		    for(uint8 i = 0; i < numbers.length; i++) {
		        if(numbers[i] < 1 || numbers[i] > MAX_NUMBER) {
		            err = true;
		            break;
		        }
		    }
		    
		    // Check dublicate numbers
		    if(!err) {
		    
		        for(uint8 i = 0; i < numbers.length-1; i++) {
		            for(uint8 j = i+1; j < numbers.length; j++) {
		                if(numbers[i] == numbers[j]) {
		                    err = true;
		                    break;
		                }
		            }
		            if(err) {
		                break;
		            }
		        }
		        
		    }
		    
	    } else {
	        err = true;
	    }

	    return (err, numbers);

	}
	
	// Sort array of number function
	function sortNumbers(uint8[5] memory arrNumbers) private pure returns (uint8[5] memory) {
	    
	    uint8 temp;
	    
	    for(uint8 i = 0; i < arrNumbers.length - 1; i++) {
            for(uint j = 0; j < arrNumbers.length - i - 1; j++)
                if (arrNumbers[j] > arrNumbers[j + 1]) {
                    temp = arrNumbers[j];
                    arrNumbers[j] = arrNumbers[j + 1];
                    arrNumbers[j + 1] = temp;
                }    
	    }
        
        return arrNumbers;
        
	}
	
	// Contract address balance
    function getBalance() public view returns(uint) {
        uint balance = address(this).balance;
		return balance;
	}
	
	// Generate random number
	function random(uint8 num) internal view returns (uint8) {
	    
        return uint8(uint(blockhash(block.number - 1 - num*2)) % MAX_NUMBER + 1);
        
    } 
    
    function getHour(uint timestamp) private pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }
    
    function getWeekday(uint timestamp) private pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }
	
	
	// API
	
	// i - Game number
	function getGameInfo(uint i) public view returns (uint, uint, uint, uint8, uint8, uint8, uint8, uint8, uint8) {
	    Game memory game = games[i];
	    return (game.datetime, game.totalFund, game.membersCounter, game.win_numbers[0], game.win_numbers[1], game.win_numbers[2], game.win_numbers[3], game.win_numbers[4], game.status);
	}
	
	// i - Game number, j - Ticket number
	function getMemberInfo(uint i, uint j) public view returns (address, uint, uint8, uint8, uint8, uint8, uint8, uint8, uint) {
	    Member memory mbr = games[i].members[j];
	    return (mbr.addr, mbr.ticket, mbr.matchNumbers, mbr.numbers[0], mbr.numbers[1], mbr.numbers[2], mbr.numbers[3], mbr.numbers[4], mbr.prize);
	}

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}
/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

/**
 * @title SettingInterface
 */
interface SettingInterface {
	function uintSettings(bytes32 name) external constant returns (uint256);
	function boolSettings(bytes32 name) external constant returns (bool);
	function isActive() external constant returns (bool);
	function canBet(uint256 rewardValue, uint256 betValue, uint256 playerNumber, uint256 houseEdge) external constant returns (bool);
	function isExchangeAllowed(address playerAddress, uint256 tokenAmount) external constant returns (bool);

	/******************************************/
	/*          SPINWIN ONLY METHODS          */
	/******************************************/
	function spinwinSetUintSetting(bytes32 name, uint256 value) external;
	function spinwinIncrementUintSetting(bytes32 name) external;
	function spinwinSetBoolSetting(bytes32 name, bool value) external;
	function spinwinAddFunds(uint256 amount) external;
	function spinwinUpdateTokenToWeiExchangeRate() external;
	function spinwinRollDice(uint256 betValue) external;
	function spinwinUpdateWinMetric(uint256 playerProfit) external;
	function spinwinUpdateLoseMetric(uint256 betValue, uint256 tokenRewardValue) external;
	function spinwinUpdateLotteryContributionMetric(uint256 lotteryContribution) external;
	function spinwinUpdateExchangeMetric(uint256 exchangeAmount) external;

	/******************************************/
	/*      SPINLOTTERY ONLY METHODS          */
	/******************************************/
	function spinlotterySetUintSetting(bytes32 name, uint256 value) external;
	function spinlotteryIncrementUintSetting(bytes32 name) external;
	function spinlotterySetBoolSetting(bytes32 name, bool value) external;
	function spinlotteryUpdateTokenToWeiExchangeRate() external;
	function spinlotterySetMinBankroll(uint256 _minBankroll) external returns (bool);
}

/**
 * @title LotteryInterface
 */
interface LotteryInterface {
	function claimReward(address playerAddress, uint256 tokenAmount) external returns (bool);
	function calculateLotteryContributionPercentage() external constant returns (uint256);
	function getNumLottery() external constant returns (uint256);
	function isActive() external constant returns (bool);
	function getCurrentTicketMultiplierHonor() external constant returns (uint256);
	function getCurrentLotteryTargetBalance() external constant returns (uint256, uint256);
}

/**
 * @title SpinWinLibrary
 */
library SpinWinLibrary {
	using SafeMath for uint256;

	uint256 constant public PERCENTAGE_DIVISOR = 10 ** 6;   // 1000000 = 100%
	uint256 constant public HOUSE_EDGE_DIVISOR = 1000;
	uint256 constant public CURRENCY_DIVISOR = 10**18;
	uint256 constant public TWO_DECIMALS = 100;

	/**
	 * @dev Calculate winning ETH when player wins
	 * @param betValue The amount of ETH for this bet
	 * @param playerNumber The number that player chose
	 * @param houseEdge The house edge for this bet
	 * @return The amount of ETH to be sent to player if he/she wins
	 */
	function calculateWinningReward(uint256 betValue, uint256 playerNumber, uint256 houseEdge) public pure returns (uint256) {
		return ((betValue.mul(100-(playerNumber.sub(1)))).div(playerNumber.sub(1))).mul(houseEdge).div(HOUSE_EDGE_DIVISOR);

	}

	/**
	 * @dev Calculates token reward amount when player loses
	 * @param settingAddress The GameSetting contract address
	 * @param betValue The amount of ETH for this bet
	 * @param playerNumber The number that player chose
	 * @param houseEdge The house edge for this bet
	 * @return The amount of token to be sent to player if he/she loses
	 */
	function calculateTokenReward(address settingAddress, uint256 betValue, uint256 playerNumber, uint256 houseEdge) public constant returns (uint256) {
		uint256 weiLost = SettingInterface(settingAddress).uintSettings('totalWeiLostHonor').add(betValue.div(2));
		uint256 ratio = _getTokenRatio(weiLost);

		/*
		 * Let base = betValue * ratio
		 * We know that _ratio is in two decimals so we need to divide it by TWO_DECIMALS
		 * base = (betValue * ratio)/TWO_DECIMALS
		 */
		uint256 base = betValue.mul(ratio).div(TWO_DECIMALS);

		/*
		 * edgeMod = base * (houseEdge% * (2 - houseEdge%) * spinEdgeModifier)
		 */
		uint256 edgeMod = _calculateEdgeMod(settingAddress, base, houseEdge);

		/*
		 * houseMod = base *  (((minBankrollHonor - replacedBank)/minBankrollHonor)*spinBankModifier) * edgeOn
		 */
		uint256 houseMod = _calculateHouseMod(settingAddress, base, houseEdge);

		/*
		 * numberMod =  base * ((1 + ((100 - playerNumber)/100))*spinNumberModifier) * edgeOn;
		 */
		uint256 numberMod = _calculateNumberMod(settingAddress, base, playerNumber, houseEdge);

		return edgeMod.add(houseMod).add(numberMod);
	}

	/**
	 * @dev Generates random number between 1-divisor
	 * @param settingAddress The GameSetting contract address
	 * @param betBlockNumber The bet block number
	 * @param extraData Data to be included in keccak256 for security purposes
	 * @param divisor The upper bound of the random number
	 * @return Return integer from 1-divisor
	 */
	function generateRandomNumber(address settingAddress, uint256 betBlockNumber, uint256 extraData, uint256 divisor) public constant returns (uint256) {
		uint256 blockNumberDifference = block.number.sub(betBlockNumber);
		uint256 maxBlockSecurityCount = SettingInterface(settingAddress).uintSettings('maxBlockSecurityCount');
		uint256 blockSecurityCount = SettingInterface(settingAddress).uintSettings('blockSecurityCount');
		if (blockNumberDifference < SettingInterface(settingAddress).uintSettings('maxBlockSecurityCount').sub(blockSecurityCount)) {
			uint256 targetBlockNumber = betBlockNumber.add(blockSecurityCount);
		} else {
			targetBlockNumber = betBlockNumber.add(maxBlockSecurityCount.mul(blockNumberDifference.div(maxBlockSecurityCount))).add(blockSecurityCount);
		}
		uint256 randomNumber = 0;
		for (uint256 i = 1; i < blockSecurityCount; i++) {
			randomNumber = ((uint256(keccak256(abi.encodePacked(randomNumber, blockhash(targetBlockNumber.sub(i)), extraData)))%divisor).add(1));
		}
		return randomNumber;
	}

	/**
	 * @dev Calculate clear bet block reward
	 * @param settingAddress The GameSetting contract address
	 * @param lotteryAddress The lottery contract address
	 * @return The num of blocks reward for clearing bet
	 */
	function calculateClearBetBlocksReward(address settingAddress, address lotteryAddress) public constant returns (uint256) {
		uint256 weiLost = SettingInterface(settingAddress).uintSettings('totalWeiLostHonor');

		// Calculate 1 Wei to SPIN Rate
		uint256 weiToSpinRate = _getTokenRatio(weiLost); // in decimals

		/*
		 * Calculate 1 SPIN to Wei Rate
		 * Inverse of weiToSpinRate
		 * so spinToWeiRate = 1 / weiToSpinRate
		 * but weiToSpinRate is in decimals
		 * spinToWeiRate = 1 / (weiToSpinRate / TWO_DECIMALS)
		 * spinToWeiRate = TWO_DECIMALS / weiToSpinRate
		 * Mult by CURRENCY_DIVISOR/CURRENCY_DIVISOR to account for the decimals
		 * spinToWeiRate = (CURRENCY_DIVISOR/CURRENCY_DIVISOR) * (TWO_DECIMALS / weiToSpinRate)
		 * Take out the division by CURRENCY_DIVISOR for now and include it in the later calculation
		 * spinToWeiRate = (CURRENCY_DIVISOR * TWO_DECIMALS) / weiToSpinRate
		 */
		uint256 spinToWeiRate = SettingInterface(settingAddress).uintSettings('spinToWeiRate');
		if (weiToSpinRate > 0) {
			spinToWeiRate = (CURRENCY_DIVISOR.mul(TWO_DECIMALS)).div(weiToSpinRate); // in decimals
		}

		// Calculate 1 Spin to Block Rate
		uint256 spinToBlockRate = LotteryInterface(lotteryAddress).getCurrentTicketMultiplierHonor(); // in decimals

		/*
		 * Calculate 1 Block to Spin Rate
		 * Inverse of spinToBlockRate
		 * so blockToSpinRate = 1 / spinToBlockRate
		 * but spinToBlockRate is in decimals
		 * blockToSpinRate = 1 / (spinToBlockRate / TWO_DECIMALS)
		 * blockToSpinRate = TWO_DECIMALS / spinToBlockRate
		 * Mult by CURRENCY_DIVISOR/CURRENCY_DIVISOR to account for two decimals
		 * blockToSpinRate = (CURRENCY_DIVISOR/CURRENCY_DIVISOR) * (TWO_DECIMALS / spinToBlockRate)
		 * Take out the division by CURRENCY_DIVISOR for now and include it in the later calculation
		 * blockToSpinRate = (CURRENCY_DIVISOR * TWO_DECIMALS) / spinToBlockRate
		 */
		uint256 blockToSpinRate = SettingInterface(settingAddress).uintSettings('blockToSpinRate');
		if (spinToBlockRate > 0) {
			blockToSpinRate = (CURRENCY_DIVISOR.mul(TWO_DECIMALS)).div(spinToBlockRate); // in decimals
		}

		/*
		 * Calculate block to wei Rate
		 * blockToWeiRate = blockToSpinRate * spinToWeiRate
		 * since blockToSpinRate and spinToWeiRate are in decimals (from prev calculation)
		 * need to include the division by CURRENCY_DIVISOR
		 * blockToWeiRate = (blockToSpinRate/CURRENCY_DIVISOR)  * (spinToWeiRate/CURRENCY_DIVISOR)
		 * But since we need to account for decimals
		 * Mult the math about with CURRENCY_DIVISOR/CURRENCY_DIVISOR
		 * blockToWeiRate = (CURRENCY_DIVISOR/CURRENCY_DIVISOR) * (blockToSpinRate/CURRENCY_DIVISOR)  * (spinToWeiRate/CURRENCY_DIVISOR)
		 * Take out one division by CURRENCY_DIVISOR for now and include it in the later calculation
		 * blockToWeiRate = (blockToSpinRate * spinToWeiRate) / CURRENCY_DIVISOR
		 */
		uint256 blockToWeiRate = (blockToSpinRate.mul(spinToWeiRate)).div(CURRENCY_DIVISOR); // in decimals

		// Calculate wei cost to clear a bet
		uint256 weiCost = SettingInterface(settingAddress).uintSettings('gasForClearingBet').mul(SettingInterface(settingAddress).uintSettings('gasPrice'));

		/*
		 * numBlocks = weiCost / blockToWeiRate
		 * But since blockToWeiRate is in decimals, need to divide by CURRENCY_DIVISOR
		 * numBlocks = weiCost / (blockToWeiRate / CURRENCY_DIVISOR)
		 * numBlocks = (weiCost * CURRENCY_DIVISOR)/blockToWeiRate
		 */
		if (blockToWeiRate == 0) {
			blockToWeiRate = SettingInterface(settingAddress).uintSettings('blockToWeiRate');
		}
		return (weiCost.mul(CURRENCY_DIVISOR)).div(blockToWeiRate);
	}

	/**
	 * @dev Calculate how much we should contribute to the lottery
	 * @param settingAddress The GameSetting contract address
	 * @param lotteryAddress The lottery contract address
	 * @param betValue The bet value
	 * @return The lottery contribution amount
	 */
	function calculateLotteryContribution(address settingAddress, address lotteryAddress, uint256 betValue) public constant returns (uint256) {
		uint256 lotteryContribution = (betValue.mul(LotteryInterface(lotteryAddress).calculateLotteryContributionPercentage())).div(TWO_DECIMALS);

		// Check if this contribution will make lottery balance > current lottery target X multiple
		uint256 currentLotteryTarget;
		uint256 currentLotteryBankroll;
		(currentLotteryTarget, currentLotteryBankroll) = LotteryInterface(lotteryAddress).getCurrentLotteryTargetBalance();
		uint256 lotteryTargetMultiplier = SettingInterface(settingAddress).uintSettings('lotteryTargetMultiplier');
		if (currentLotteryBankroll.add(lotteryContribution) > currentLotteryTarget.mul(lotteryTargetMultiplier).div(TWO_DECIMALS)) {
			lotteryContribution = (currentLotteryTarget.mul(lotteryTargetMultiplier).div(TWO_DECIMALS)).sub(currentLotteryBankroll);
		}
		return lotteryContribution;
	}

	/**
	 * @dev Calculate the exchange values
	 * @param settingAddress The GameSetting contract address
	 * @param tokenAmount The amount of token to be exchanged
	 * @return The converted wei value
	 * @return The amount of wei to be received
	 * @return The amount of token to be refunded (if contractBalance < weiValue)
	 * @return The amount of token to be burned
	 */
	function calculateExchangeTokenValue(address settingAddress, uint256 tokenAmount) public constant returns (uint256, uint256, uint256, uint256) {
		uint256 tokenToWeiExchangeRateHonor = SettingInterface(settingAddress).uintSettings('tokenToWeiExchangeRateHonor');
		// From GameSetting.sol, we know that tokenToWeiExchangeRate is ETH in 36 decimals or WEI in 18 decimals
		// So we need to divide tokenToWeiExchangeRateHonor by CURRENCY_DIVISOR
		uint256 weiValue = (tokenToWeiExchangeRateHonor.mul(tokenAmount)).div(CURRENCY_DIVISOR).div(CURRENCY_DIVISOR);
		uint256 contractExchangeBalance = SettingInterface(settingAddress).uintSettings('contractBalance').sub(SettingInterface(settingAddress).uintSettings('tokenExchangeMinBankroll')); // This is the maximum exchange ETH value that we can send to the player
		if (contractExchangeBalance >= weiValue) {
			uint256 sendWei = weiValue;
			uint256 tokenRemainder = 0;
			uint256 burnToken = tokenAmount;
		} else {
			sendWei = contractExchangeBalance;
			tokenRemainder = (weiValue.sub(contractExchangeBalance)).mul(CURRENCY_DIVISOR).mul(CURRENCY_DIVISOR).div(tokenToWeiExchangeRateHonor);
			burnToken = tokenAmount.sub(tokenRemainder);
		}
		return (weiValue, sendWei, tokenRemainder, burnToken);
	}


	/******************************************/
	/*           PRIVATE METHODS              */
	/******************************************/

	/**
	 * @dev Gets token ratio based on weiLost
	 * @param weiLost The wei lost value
	 * @return Return token ratio (ratio is in two decimals, needs to be divided with TWO_DECIMALS in calculation)
	 */
	function _getTokenRatio(uint256 weiLost) private pure returns (uint256) {
		uint256 ethLost = weiLost.div(CURRENCY_DIVISOR);
		/**
		 * We value players who are early in the game, that's why we reward them with more SPIN
		 */
		if (ethLost >= 0 && ethLost <= 10) {
			// Case 1: 0 ETH >= ethLost < 10 ETH
			uint256 start = 1;                                  // start: 0 ETH
			uint256 end = 10;                                   // end: 10 ETH
			uint256 startRatio = 199000 * TWO_DECIMALS;         // start ratio: 199,000
			uint256 endRatio = 1000 * TWO_DECIMALS;             // end ratio: 1,000
		} else if (ethLost > 10 && ethLost <= 1000) {
			// Case 2: 10 ETH >= ethLost < 1000 ETH
			start = 10;                                         // start: 10 ETH
			end = 1000;                                         // end: 1,000 ETH
			startRatio = 1000 * TWO_DECIMALS;                   // start ratio: 1,000
			endRatio = 100 * TWO_DECIMALS;                      // end ratio: 100
		} else if (ethLost > 1000 && ethLost <= 10000) {
			// Case 3: 1,000 ETH >= ethLost < 10,000 ETH
			start = 1000;                                       // start: 1,000 ETH
			end = 10000;                                        // end: 10,000 ETH
			startRatio = 100 * TWO_DECIMALS;                    // start ratio: 100
			endRatio = 20 * TWO_DECIMALS;                       // end ratio: 20
		} else if (ethLost > 10000 && ethLost <= 100000) {
			// Case 4: 10,000 ETH >= ethLost < 100,000 ETH
			start = 10000;                                      // start: 10,000 ETH
			end = 100000;                                       // end: 100,000 ETH
			startRatio = 20 * TWO_DECIMALS;                     // start ratio: 20
			endRatio = 10 * TWO_DECIMALS;                       // end ratio: 10
		} else if (ethLost > 100000 && ethLost <= 1000000) {
			// Case 5: 100,000 ETH >= ethLost < 1,000,000 ETH
			start = 100000;                                     // start: 100,000 ETH
			end = 1000000;                                      // end: 1,000,000 ETH
			startRatio = 10 * TWO_DECIMALS;                     // start ratio: 10
			endRatio = 2 * TWO_DECIMALS;                        // end ratio: 2
		} else if (ethLost > 1000000 && ethLost <= 10000000) {
			// Case 6: 1,000,000 ETH >= ethLost < 10,000,000 ETH
			start = 1000000;                                    // start: 1,000,000 ETH
			end = 10000000;                                     // end: 10,000,000 ETH
			startRatio = 2 * TWO_DECIMALS;                      // start ratio: 2
			endRatio = 40;                                      // end ratio: 0.4
		} else if (ethLost > 10000000 && ethLost <= 100000000) {
			// Case 7: 10,000,000 ETH >= ethLost < 100,000,000 ETH
			start = 10000000;                                   // start: 10,000,000 ETH
			end = 100000000;                                    // end: 100,000,000 ETH
			startRatio = 40;                                    // start ratio: 0.4
			endRatio = 20;                                      // end ratio: 0.2
		} else if (ethLost > 100000000 && ethLost <= 1000000000) {
			// Case 8: 100,000,000 ETH >= ethLost < 1,000,000,000 ETH
			start = 100000000;                                  // start: 100,000,000 ETH
			end = 1000000000;                                   // end: 1,000,000,000 ETH
			startRatio = 20;                                    // start ratio: 0.2
			endRatio = 10;                                      // end ratio: 0.1
		} else {
			// Case 9: ethLost >= 1,000,000,000 ETH
			uint256 ratio = 10; // ratio: 0.1
		}

		// Calculate the ratio if necessary
		// Also, prevent division by 0
		if (ratio == 0 && (end - start) > 0) {
			/*
			 * To prevent negative value for calculating ethLost-start
			 * if ethLost = 0, set ethLost = start
			 */
			if (ethLost == 0) {
				ethLost = start;
			}
			/*
			 * ratio = ((startRatio - endRatio) * (1-((ethLost - start)/(end-start)))) + endRatio;
			 * Let temp = (1-((ethLost - start)/(end-start)))
			 * So, ratio = ((startRatio - endRatio) * temp) + endRatio;
			 *
			 * Mult by TWO_DECIMALS/TWO_DECIMALS to account for two decimals
			 * temp = (TWO_DECIMALS * ((1-((ethLost - start)/(end-start)))))/TWO_DECIMALS
			 * temp = (TWO_DECIMALS - ((TWO_DECIMALS*(ethLost-start))/(end-start)))/TWO_DECIMALS
			 * Take out the TWO_DECIMALS for now and include it in the later calculation
			 * temp = TWO_DECIMALS - ((TWO_DECIMALS*(ethLost-start))/(end-start))
			 */
			uint256 temp = TWO_DECIMALS.sub(TWO_DECIMALS.mul(ethLost.sub(start)).div(end.sub(start)));
			ratio = ((startRatio.sub(endRatio)).mul(temp).div(TWO_DECIMALS)).add(endRatio);
		}
		return ratio;
	}

	/**
	 * @dev Helper function to help calculates edge modifier for token reward
	 */
	function _calculateEdgeMod(address settingAddress, uint256 base, uint256 houseEdge) private constant returns (uint256) {
		/*
		 * edgeMod = base * (houseEdge% * (2 - houseEdge%) * spinEdgeModifier)
		 * we know houseEdge is the inverse of houseEdge%
		 * so 0 houseEdge is 100%, and 1000 houseEdge is 0%
		 * Therefore, houseEdge% = (HOUSE_EDGE_DIVISOR - houseEdge)/HOUSE_EDGE_DIVISOR
		 *
		 * edgeMod = base * ( ((HOUSE_EDGE_DIVISOR - houseEdge)/HOUSE_EDGE_DIVISOR) * ( 2 - ((HOUSE_EDGE_DIVISOR - houseEdge)/HOUSE_EDGE_DIVISOR)) * spinEdgeModifier)
		 * edgeMod = base * ( ((HOUSE_EDGE_DIVISOR - houseEdge)/HOUSE_EDGE_DIVISOR) * ( 2*(HOUSE_EDGE_DIVISOR/HOUSE_EDGE_DIVISOR) - ((HOUSE_EDGE_DIVISOR - houseEdge)/HOUSE_EDGE_DIVISOR)) * spinEdgeModifier)
		 * edgeMod = base * ( ((HOUSE_EDGE_DIVISOR - houseEdge)/HOUSE_EDGE_DIVISOR) * ( (2*HOUSE_EDGE_DIVISOR - HOUSE_EDGE_DIVISOR + houseEdge)/HOUSE_EDGE_DIVISOR) * spinEdgeModifier)
		 * edgeMod = base * ( ((HOUSE_EDGE_DIVISOR - houseEdge)/HOUSE_EDGE_DIVISOR) * ( (HOUSE_EDGE_DIVISOR + houseEdge)/HOUSE_EDGE_DIVISOR) * spinEdgeModifier)
		 * spinEdgeModifier is also in two decimals, so we need to divide it by TWO_DECIMALS
		 * edgeMod = base * ( ((HOUSE_EDGE_DIVISOR - houseEdge)/HOUSE_EDGE_DIVISOR) * ( (HOUSE_EDGE_DIVISOR + houseEdge)/HOUSE_EDGE_DIVISOR) * (spinEdgeModifier/TWO_DECIMALS))
		 * We multiply first than divide
		 * edgeMod = (((base * (HOUSE_EDGE_DIVISOR - houseEdge) * (HOUSE_EDGE_DIVISOR + houseEdge) * spinEdgeModifier)/HOUSE_EDGE_DIVISOR)/HOUSE_EDGE_DIVISOR)/TWO_DECIMALS
		 */
		return (base.mul(HOUSE_EDGE_DIVISOR.sub(houseEdge)).mul(HOUSE_EDGE_DIVISOR.add(houseEdge)).mul(SettingInterface(settingAddress).uintSettings('spinEdgeModifier'))).div(HOUSE_EDGE_DIVISOR).div(HOUSE_EDGE_DIVISOR).div(TWO_DECIMALS);
	}

	/**
	 * @dev Helper function to help calculates house modifier for token reward
	 */
	function _calculateHouseMod(address settingAddress, uint256 base, uint256 houseEdge) private constant returns (uint256) {
		uint256 replacedBank = (SettingInterface(settingAddress).uintSettings('contractBalanceHonor') >= SettingInterface(settingAddress).uintSettings('minBankrollHonor')) ? SettingInterface(settingAddress).uintSettings('minBankrollHonor') : SettingInterface(settingAddress).uintSettings('contractBalanceHonor');

		/*
		 * we know houseEdge is the inverse of houseEdge%
		 * so 0 houseEdge is 100%, and 1000 houseEdge is 0%
		 */
		uint256 edgeOn = (houseEdge == 1000) ? 0 : 1;

		/*
		 * this will cap the multiple at the spinEdgeModifier value. NOTE: the 2 - houseEdge% addition. This curves the edge.
		 * houseMod = base *  (((minBankrollHonor - replacedBank)/minBankrollHonor)*spinBankModifier) * edgeOn
		 * spinBankModifier is also in two decimals, so we need to divide it by TWO_DECIMALS
		 * houseMod = base *  ( ((minBankrollHonor - replacedBank) / minBankrollHonor) * (spinBankModifier/TWO_DECIMALS) ) * edgeOn
		 * We multiply first than divide
		 * houseMod = ((base * (minBankrollHonor - replacedBank) * spinBankModifier * edgeOn)/minBankrollHonor)/TWO_DECIMALS
		 */
		uint256 dividend = (base.mul(SettingInterface(settingAddress).uintSettings('minBankrollHonor').sub(replacedBank)).mul(SettingInterface(settingAddress).uintSettings('spinBankModifier')).mul(edgeOn));
		return dividend.div(SettingInterface(settingAddress).uintSettings('minBankrollHonor')).div(TWO_DECIMALS);
	}

	/**
	 * @dev Helper function to help calculates number modifier for token reward
	 */
	function _calculateNumberMod(address settingAddress, uint256 base, uint256 playerNumber, uint256 houseEdge) private constant returns (uint256) {
		/*
		 * we know houseEdge is the inverse of houseEdge%
		 * so 0 houseEdge is 100%, and 1000 houseEdge is 0%
		 */
		uint256 edgeOn = (houseEdge == 1000) ? 0 : 1;

		/*
		 * numberMod = base * ((1 + (100 - playerNumber)/100)*spinNumberModifier) * edgeOn
		 * Let temp2 = (1 + (100 - playerNumber)/100)
		 * Mult by TWO_DECIMALS/TWO_DECIMALS to account for two decimals
		 * temp2 = (TWO_DECIMALS * ((1+((100 - playerNumber)/100))))/TWO_DECIMALS
		 * temp2 = (TWO_DECIMALS + ((TWO_DECIMALS*(100-playerNumber))/100))/TWO_DECIMALS
		 * Take out the TWO_DECIMALS for now and include it in the later calculation
		 * temp2 = TWO_DECIMALS + ((TWO_DECIMALS*(100-playerNumber))/100)
		 *
		 * numberMod = base * (temp2/TWO_DECIMALS)*spinNumberModifier * edgeOn
		 * spinNumberModifier is also in two decimals, so we need to divide it by TWO_DECIMALS
		 * numberMod = base * (((temp2/TWO_DECIMALS)*spinNumberModifier)/TWO_DECIMALS) * edgeOn
		 * We multiply first then divide
		 * numberMod = ((base * temp2 * spinNumberModifier*edgeOn)/TWO_DECIMALS)/TWO_DECIMALS
		 */
		uint256 temp2 = TWO_DECIMALS.add(TWO_DECIMALS.mul(100 - playerNumber).div(100));
		return (base.mul(temp2).mul(SettingInterface(settingAddress).uintSettings('spinNumberModifier')).mul(edgeOn)).div(TWO_DECIMALS).div(TWO_DECIMALS);
	}
}
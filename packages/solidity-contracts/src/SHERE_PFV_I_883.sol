/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFV_I_883		"	;
		string	public		symbol =	"	SHERE_PFV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		748289622343488000000000000					;	
										
		event Transfer(address indexed from, address indexed to, uint256 value);								
										
		function SimpleERC20Token() public {								
			balanceOf[msg.sender] = totalSupply;							
			emit Transfer(address(0), msg.sender, totalSupply);							
		}								
										
		function transfer(address to, uint256 value) public returns (bool success) {								
			require(balanceOf[msg.sender] >= value);							
										
			balanceOf[msg.sender] -= value;  // deduct from sender's balance							
			balanceOf[to] += value;          // add to recipient's balance							
			emit Transfer(msg.sender, to, value);							
			return true;							
		}								
										
		event Approval(address indexed owner, address indexed spender, uint256 value);								
										
		mapping(address => mapping(address => uint256)) public allowance;								
										
		function approve(address spender, uint256 value)								
			public							
			returns (bool success)							
		{								
			allowance[msg.sender][spender] = value;							
			emit Approval(msg.sender, spender, value);							
			return true;							
		}								
										
		function transferFrom(address from, address to, uint256 value)								
			public							
			returns (bool success)							
		{								
			require(value <= balanceOf[from]);							
			require(value <= allowance[from][msg.sender]);							
										
			balanceOf[from] -= value;							
			balanceOf[to] += value;							
			allowance[from][msg.sender] -= value;							
			emit Transfer(from, to, value);							
			return true;							
		}								
//	}									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 1 à 10									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < SHERE_PFV_I_metadata_line_1_____AEROFLOT_20220505 >									
	//        < 7s9JBwkeALiyZFiztmZweL4bMzzhZb1T7D7td2H38gm4KuxaLy3u8dc4xCT7Sy80 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000022756309.883599100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000022B92F >									
	//     < SHERE_PFV_I_metadata_line_2_____AEROFLOT_ORG_20220505 >									
	//        < N9ZS6R7cUUh61w2Av9r9t80gaF68wLkt65z5XcePcorTF3G37OCaVj609645h086 >									
	//        <  u =="0.000000000000000001" : ] 000000022756309.883599100000000000 ; 000000041384834.221777200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000022B92F3F25F3 >									
	//     < SHERE_PFV_I_metadata_line_3_____AURORA_20220505 >									
	//        < k24sM7NidcIm2VW4DnxpoEpRR0BrdJCS8V28avh3VJSeYN4gJ3758j1hV0IXUPv1 >									
	//        <  u =="0.000000000000000001" : ] 000000041384834.221777200000000000 ; 000000063084246.893634300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003F25F3604249 >									
	//     < SHERE_PFV_I_metadata_line_4_____AURORA_ORG_20220505 >									
	//        < xL2N69Lv64cbotd59Y5lbFE09bsL77HjXOc96324E3i494CZf1Difg1r026qgG4k >									
	//        <  u =="0.000000000000000001" : ] 000000063084246.893634300000000000 ; 000000082748366.121434300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006042497E4395 >									
	//     < SHERE_PFV_I_metadata_line_5_____RUSSIA _20220505 >									
	//        < r9I01HJcH4f4pYrARgb6cIYeHZHFtbj8ir5RS2D2439xQ66kqGrzCgJSwOB3l54l >									
	//        <  u =="0.000000000000000001" : ] 000000082748366.121434300000000000 ; 000000098676125.272336800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007E439596915D >									
	//     < SHERE_PFV_I_metadata_line_6_____RUSSIA _ORG_20220505 >									
	//        < ryo4b2j2c54Lp38fhKW7a859U49hmilwKH57BT4nEWmIy1SQRK4j4cJaZ6lEn9Zq >									
	//        <  u =="0.000000000000000001" : ] 000000098676125.272336800000000000 ; 000000120335144.671501000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000096915DB79DEA >									
	//     < SHERE_PFV_I_metadata_line_7_____VICTORIA_20220505 >									
	//        < O66DeewYBYOYZi74h1QX63ii4CgAJ4muIl29488197UXwBTss456i94w4YqazOGE >									
	//        <  u =="0.000000000000000001" : ] 000000120335144.671501000000000000 ; 000000136797328.042516000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B79DEAD0BC75 >									
	//     < SHERE_PFV_I_metadata_line_8_____VICTORIA_ORG_20220505 >									
	//        < 2rZsX8zke21cH6LrpOfDucAx3wz7I09sa2OMpI21Yvw92zYm4M4u25CmHi88nX20 >									
	//        <  u =="0.000000000000000001" : ] 000000136797328.042516000000000000 ; 000000157011801.167848000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D0BC75EF94BC >									
	//     < SHERE_PFV_I_metadata_line_9_____DOBROLET_20220505 >									
	//        < DqqurR47wIKW427i80k1CFnO6EO6JG4mm4V8q9qlZ1f6varJT1jE4D8qM4CbXiNX >									
	//        <  u =="0.000000000000000001" : ] 000000157011801.167848000000000000 ; 000000178536738.459961000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EF94BC1106CEA >									
	//     < SHERE_PFV_I_metadata_line_10_____DOBROLET_ORG_20220505 >									
	//        < LUu5Ob5BVD8mKM1d8009R9e5PpgFr1i0FBqhy06aa99MWOI81Crpli28Dsmqo5UH >									
	//        <  u =="0.000000000000000001" : ] 000000178536738.459961000000000000 ; 000000198664495.618562000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001106CEA12F2352 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 11 à 20									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < SHERE_PFV_I_metadata_line_11_____AEROFLOT_RUSSIAN_AIRLINES_20220505 >									
	//        < tfrj66U3IrNA9BVb5x31V2jqq4Lg2H6zoB9l93C3AqubL0TJ81FGKDvkcNTy6Kv6 >									
	//        <  u =="0.000000000000000001" : ] 000000198664495.618562000000000000 ; 000000212440899.186987000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012F235214428BA >									
	//     < SHERE_PFV_I_metadata_line_12_____AEROFLOT_RUSSIAN_AIRLINES_ORG_20220505 >									
	//        < 4AQ7sKFgP7iOLMt27R1jYPjNQ0k30W4DF94F8aZiqMviyaD73UfoLFJ3p7raN1Py >									
	//        <  u =="0.000000000000000001" : ] 000000212440899.186987000000000000 ; 000000233388881.241509000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014428BA1641F88 >									
	//     < SHERE_PFV_I_metadata_line_13_____OTDELSTROY_INVEST_20220505 >									
	//        < C7YTurNFcSfxcH8C1zJuGw4Lu8m291bMyz3VC344bKKb9yt8zT1XgRRhl2CDf1gR >									
	//        <  u =="0.000000000000000001" : ] 000000233388881.241509000000000000 ; 000000247075821.966164000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001641F8817901FE >									
	//     < SHERE_PFV_I_metadata_line_14_____OTDELSTROY_INVEST_ORG_20220505 >									
	//        < 8yZ7qyjO0v8b3H5njrW7p17jLwblsqkLC3P7nZpb7ZMQjZmZ6N9QYCL1703cbQVP >									
	//        <  u =="0.000000000000000001" : ] 000000247075821.966164000000000000 ; 000000265735850.052838000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017901FE1957B11 >									
	//     < SHERE_PFV_I_metadata_line_15_____POBEDA_AIRLINES_20220505 >									
	//        < XgvtoNs6qv71A0W7A82l6r3n6Zfe2Axp2MfN8gWfQ3rEqBfhhHGL5IiIl662JGbN >									
	//        <  u =="0.000000000000000001" : ] 000000265735850.052838000000000000 ; 000000283255386.510205000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001957B111B036A3 >									
	//     < SHERE_PFV_I_metadata_line_16_____POBEDA_AIRLINES_ORG_20220505 >									
	//        < OiT540R7ynhtr94Le5JeWeaFz1k1GC1yP6xzW1BQu027Unb4mbZv7U5oqm2x6v2v >									
	//        <  u =="0.000000000000000001" : ] 000000283255386.510205000000000000 ; 000000302039413.858717000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B036A31CCE025 >									
	//     < SHERE_PFV_I_metadata_line_17_____DAROFAN_20220505 >									
	//        < k9h42bBf2R84ekqJ66UmF1Bxt11663Ub21a5aNUuTJfKjr0WsdDOZEh9pvtrQytl >									
	//        <  u =="0.000000000000000001" : ] 000000302039413.858717000000000000 ; 000000315493960.769319000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CCE0251E167D4 >									
	//     < SHERE_PFV_I_metadata_line_18_____DAROFAN_ORG_20220505 >									
	//        < BCf84Feg3CtUNmjgcL0fjil3lNmWBJ62Yh263xLiCs0oC233fK4mfQiga3N3WnAE >									
	//        <  u =="0.000000000000000001" : ] 000000315493960.769319000000000000 ; 000000332929343.279986000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E167D41FC0286 >									
	//     < SHERE_PFV_I_metadata_line_19_____TERMINAL_20220505 >									
	//        < MAa85RCMYYqIXiH9b2MznHV0V0941bvOz9c1kFN6LwWFYmJoMErQyo3V9k19i2d8 >									
	//        <  u =="0.000000000000000001" : ] 000000332929343.279986000000000000 ; 000000358556634.909113000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FC02862231D2F >									
	//     < SHERE_PFV_I_metadata_line_20_____TERMINAL_ORG_20220505 >									
	//        < nx8L969szK92Gg9y14EO19GmqYc1gaZmwTn3jk9e0rCy4ykq26Kers8NKQAzcR4L >									
	//        <  u =="0.000000000000000001" : ] 000000358556634.909113000000000000 ; 000000374793699.191329000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002231D2F23BE3CA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 21 à 30									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < SHERE_PFV_I_metadata_line_21_____AEROFLOT_FINANCE_20220505 >									
	//        < m30C77yYb534QqDCUtShs90IKTp6o3O7hx36c2223gyLLm6551Y1Jih2pcL7G383 >									
	//        <  u =="0.000000000000000001" : ] 000000374793699.191329000000000000 ; 000000397093684.537463000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023BE3CA25DEAB8 >									
	//     < SHERE_PFV_I_metadata_line_22_____AEROFLOT_FINANCE_ORG_20220505 >									
	//        < 9PZ21jk1g04mcQYN9UX1ry492VeVMFmrYyvKElelp769m64US3Hz71Cxz5C5Z772 >									
	//        <  u =="0.000000000000000001" : ] 000000397093684.537463000000000000 ; 000000410869048.867257000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025DEAB8272EFB9 >									
	//     < SHERE_PFV_I_metadata_line_23_____SHEROTEL_20220505 >									
	//        < 8Ppb2lX0P574Y65wS94g81A50VXJG7rG8GWP5334nFr7Ou2ul6663254252304pA >									
	//        <  u =="0.000000000000000001" : ] 000000410869048.867257000000000000 ; 000000428575997.785035000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000272EFB928DF480 >									
	//     < SHERE_PFV_I_metadata_line_24_____SHEROTEL_ORG_20220505 >									
	//        < V2YeNC5RAhEeW5f0sw700bT524Z7zH2TnyO5X43Z8fQk068Q8DG3NefaGUck204R >									
	//        <  u =="0.000000000000000001" : ] 000000428575997.785035000000000000 ; 000000443099973.877838000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028DF4802A41DED >									
	//     < SHERE_PFV_I_metadata_line_25_____DALAVIA_KHABAROVSK_20220505 >									
	//        < 8gS7Cn78d0EN7Qy7TkONYGX6U2yrFEPnxOAZQW67VLyV0r5c7U25zRIy7keKPeZS >									
	//        <  u =="0.000000000000000001" : ] 000000443099973.877838000000000000 ; 000000466822243.315476000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A41DED2C85070 >									
	//     < SHERE_PFV_I_metadata_line_26_____DALAVIA_KHABAROVSK_ORG_20220505 >									
	//        < 0801kqDJzhjHP6Gtc4Wgv9T02J86ds0Hs0lXn00Sl7I2FZ7Pe44lRWga694woJXC >									
	//        <  u =="0.000000000000000001" : ] 000000466822243.315476000000000000 ; 000000481904460.047845000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C850702DF53EE >									
	//     < SHERE_PFV_I_metadata_line_27_____AEROFLOT_AVIATION_SCHOOL_20220505 >									
	//        < sS30w7caV89ez491766vU9FdnaeEAHKx7mIk25y1iL7Q6W7pXOS6aSPp7M1PsVfp >									
	//        <  u =="0.000000000000000001" : ] 000000481904460.047845000000000000 ; 000000498081595.046453000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DF53EE2F80320 >									
	//     < SHERE_PFV_I_metadata_line_28_____AEROFLOT_AVIATION_SCHOOL_ORG_20220505 >									
	//        < m52rsRo9JhwKC6rA18XnQGaM54v4H976c8AxSY4Nz3vhMhb67k5PwID6PqdV2nio >									
	//        <  u =="0.000000000000000001" : ] 000000498081595.046453000000000000 ; 000000517076652.365854000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F80320314FF11 >									
	//     < SHERE_PFV_I_metadata_line_29_____A_TECHNICS_20220505 >									
	//        < e1UG60nj446sznaePpfe5JrEx5JJjojMv3TW01fOd3EFyTxbTj80o2lx80eh1Qqn >									
	//        <  u =="0.000000000000000001" : ] 000000517076652.365854000000000000 ; 000000533476754.248004000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000314FF1132E055B >									
	//     < SHERE_PFV_I_metadata_line_30_____A_TECHNICS_ORG_20220505 >									
	//        < 100g7foJT3L2RKEY7Gn42AZ79F16kk61X9s9999QHTcn40iPcTmQ00RQCcdl6854 >									
	//        <  u =="0.000000000000000001" : ] 000000533476754.248004000000000000 ; 000000546756039.790132000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032E055B3424894 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 31 à 40									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < SHERE_PFV_I_metadata_line_31_____AEROMAR_20220505 >									
	//        < Vicm0ZD4y8dw1pD5lI8vgM302AZqB8WW8C4XKmJw1cX5fH25MwqBJxaqM4iHrjSi >									
	//        <  u =="0.000000000000000001" : ] 000000546756039.790132000000000000 ; 000000572088635.259280000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003424894368F020 >									
	//     < SHERE_PFV_I_metadata_line_32_____AEROMAR_ORG_20220505 >									
	//        < 623zcMBJne1si40R311uP4Q34s60ohgFgib0uDgV5u7opcV7wwJ6Dbsl4z5rKKxk >									
	//        <  u =="0.000000000000000001" : ] 000000572088635.259280000000000000 ; 000000592899140.664875000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000368F020388B13A >									
	//     < SHERE_PFV_I_metadata_line_33_____BUDGET_CARRIER_20220505 >									
	//        < Rz5Hn0kRCbUbB4982IwMHFa3nv681jPCvr78pCB7nwjHuWti28m784A4cHo272b4 >									
	//        <  u =="0.000000000000000001" : ] 000000592899140.664875000000000000 ; 000000615782123.762430000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000388B13A3AB9BE4 >									
	//     < SHERE_PFV_I_metadata_line_34_____BUDGET_CARRIER_ORG_20220505 >									
	//        < XafC60fsMAz36LSL2IS8ApyBgam21BMKz3DOva1tj9202mna7ZVM4m6m05Qo2q1B >									
	//        <  u =="0.000000000000000001" : ] 000000615782123.762430000000000000 ; 000000634720317.391647000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AB9BE43C881A0 >									
	//     < SHERE_PFV_I_metadata_line_35_____NATUSANA_20220505 >									
	//        < 5pyfG98ph82YXJ8Un5905XxTWGduTqoIZ2ZoFD8WXf9N53A06Nm92X85lk740ui1 >									
	//        <  u =="0.000000000000000001" : ] 000000634720317.391647000000000000 ; 000000656268064.142345000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C881A03E962B6 >									
	//     < SHERE_PFV_I_metadata_line_36_____NATUSANA_ORG_20220505 >									
	//        < cByKevJ1ncTs3TZyYK4GNi63h70Z8s307o03V5Bfi5oL4y4eF7yt8pqd2ug17g35 >									
	//        <  u =="0.000000000000000001" : ] 000000656268064.142345000000000000 ; 000000671002876.290494000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E962B63FFDE80 >									
	//     < SHERE_PFV_I_metadata_line_37_____AEROFLOT_PENSIONS_20220505 >									
	//        < kXfjgBlY2mrz5Gq4k9Ll5TUmOH4gObOSD2xwq18nP1AtF0SVSRf4TKukWTaVZXP2 >									
	//        <  u =="0.000000000000000001" : ] 000000671002876.290494000000000000 ; 000000693718177.671522000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FFDE8042287AA >									
	//     < SHERE_PFV_I_metadata_line_38_____AEROFLOT_MUTU_20220505 >									
	//        < tcd5ypyUeigK8bF3V7KcvVxpCvj4k155f1wb3O20Jd7Lxhwh23Z4SIr94Xt6uB7f >									
	//        <  u =="0.000000000000000001" : ] 000000693718177.671522000000000000 ; 000000713864367.279263000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042287AA4414545 >									
	//     < SHERE_PFV_I_metadata_line_39_____AEROFLOT_CAPITAL_20220505 >									
	//        < yPNubY9w72fu4pghGuh807H4yInScycu15tle2D18GIBemmkgWuLI16uBpE8VQFd >									
	//        <  u =="0.000000000000000001" : ] 000000713864367.279263000000000000 ; 000000734228108.770683000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000441454546057DB >									
	//     < SHERE_PFV_I_metadata_line_40_____AEROFLOT_HOLDINGS_20220505 >									
	//        < WuI35nhbbPvLX6yI9Alp5TO3ZRIqk9Yh779abyt20Tu2Au2ZlI58Ul04mTQsjbu2 >									
	//        <  u =="0.000000000000000001" : ] 000000734228108.770683000000000000 ; 000000748289622.343488000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046057DB475CCA2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
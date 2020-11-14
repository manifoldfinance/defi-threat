/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFIII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFIII_II_883		"	;
		string	public		symbol =	"	SHERE_PFIII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1146203476099360000000000000					;	
										
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
	//     < SHERE_PFIII_II_metadata_line_1_____RUSSIAN_REINSURANCE_COMPANY_20240505 >									
	//        < M3Ecs6D99P0skTx8qZp3X0778izc7W32T18i4XBceQD3oZ9zg24drco8FCx0ZmvY >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000024579126.427658600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000258139 >									
	//     < SHERE_PFIII_II_metadata_line_2_____ERGO_20240505 >									
	//        < 5Dqlyww6pkvWXN235iZ1X921Khe5MqKbzVl9x8G1cfG60hes1r1M7f1KqK6uWht0 >									
	//        <  u =="0.000000000000000001" : ] 000000024579126.427658600000000000 ; 000000053852935.642600700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000258139522C4E >									
	//     < SHERE_PFIII_II_metadata_line_3_____AIG_20240505 >									
	//        < 3msusJQ2XRXRgba1u16zFsSOd31i7S8NC5mu8KmCSRTE804kjx6xh4FM587ZC3MJ >									
	//        <  u =="0.000000000000000001" : ] 000000053852935.642600700000000000 ; 000000080910578.336331600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000522C4E7B75B2 >									
	//     < SHERE_PFIII_II_metadata_line_4_____MARSH_MCLENNAN_RISK_CAPITAL_HOLDINGS_20240505 >									
	//        < 3USv20rAi7KYN0Qld0u7skSD9uQsICWpKZd4LZ0Fp6IzVPL9UM7Gozi7xCD92k4H >									
	//        <  u =="0.000000000000000001" : ] 000000080910578.336331600000000000 ; 000000108321071.944506000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007B75B2A548EB >									
	//     < SHERE_PFIII_II_metadata_line_5_____RUSSIAN_NATIONAL_REINSURANCE_COMPANY_RNRC_20240505 >									
	//        < 4U4aVoDgWI4A3yu47701XF88zOusXTG9QZG965E4RtjH4QqYR7V8B55Y1E71cY7r >									
	//        <  u =="0.000000000000000001" : ] 000000108321071.944506000000000000 ; 000000153787733.835704000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A548EBEAA955 >									
	//     < SHERE_PFIII_II_metadata_line_6_____ALFASTRAKHOVANIE_GROUP_20240505 >									
	//        < 8urrKh80ZalSpnfg3F4tKx3uY30za6vI8Ud45P0Ho7k883r38nkgDBK4TuM7m9s6 >									
	//        <  u =="0.000000000000000001" : ] 000000153787733.835704000000000000 ; 000000181520919.242842000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EAA955114FA9C >									
	//     < SHERE_PFIII_II_metadata_line_7_____ALFA_GROUP_20240505 >									
	//        < CB2g2qkwY4j0xl7FpwNxTJv7M850hWlQlNHtIkM0x0x77R6A1i3PAx2V53N0DC6H >									
	//        <  u =="0.000000000000000001" : ] 000000181520919.242842000000000000 ; 000000198088974.782136000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000114FA9C12E4281 >									
	//     < SHERE_PFIII_II_metadata_line_8_____INGOSSTRAKH_20240505 >									
	//        < ddiOUTK26X02z8lT4wzB0vIlKYC15OHnm86570qQ0PL76AIQ5g9lE7ho3UDmBKJq >									
	//        <  u =="0.000000000000000001" : ] 000000198088974.782136000000000000 ; 000000215890798.570091000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012E42811496C58 >									
	//     < SHERE_PFIII_II_metadata_line_9_____ROSGOSSTRAKH_INSURANCE_COMPANY_20240505 >									
	//        < X4ZFjj8KOnw0OI4DRvIR0xLIfRxm6pO5KPDnK7q44Be2rKZC39kWxaCdKiuqG6WB >									
	//        <  u =="0.000000000000000001" : ] 000000215890798.570091000000000000 ; 000000234537760.728136000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001496C58165E050 >									
	//     < SHERE_PFIII_II_metadata_line_10_____SCOR_SE_20240505 >									
	//        < G43e5kCKaZZ4K1KjH1eCnbn94cFg8diI67D60o68Uvoby5R9SdLxxoEfW8Su8AED >									
	//        <  u =="0.000000000000000001" : ] 000000234537760.728136000000000000 ; 000000256182698.702399000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000165E050186E75E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIII_II_metadata_line_11_____HANNOVERRE_20240505 >									
	//        < 09CPp8ETTIL16Hp2XA6XB3FXC17Y2O9WnKr633UkZPt6np0DSjG32L8R67fixjxN >									
	//        <  u =="0.000000000000000001" : ] 000000256182698.702399000000000000 ; 000000293139080.700229000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000186E75E1BF4B74 >									
	//     < SHERE_PFIII_II_metadata_line_12_____SWISS_RE_20240505 >									
	//        < Q5GfUcR5zNE6W35Qn0EO12211NHj0wc4l0nrtNLhwOFols2x99jX6p8lWtYGO900 >									
	//        <  u =="0.000000000000000001" : ] 000000293139080.700229000000000000 ; 000000337565069.323790000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BF4B74203155B >									
	//     < SHERE_PFIII_II_metadata_line_13_____MUNICH_RE_20240505 >									
	//        < 5DrTbcWyIuskgblsuiKh8lo9BEgsR6MnPJ79d755V206RJcX1TD4Po8064nXGkW7 >									
	//        <  u =="0.000000000000000001" : ] 000000337565069.323790000000000000 ; 000000380194937.237438000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000203155B24421A6 >									
	//     < SHERE_PFIII_II_metadata_line_14_____GEN_RE_20240505 >									
	//        < JpBcqEjFIuaPg8597533L23zO5Z4yi7fd4O3B6SPlpKBF3j4C4037h6GS5Z2z4fg >									
	//        <  u =="0.000000000000000001" : ] 000000380194937.237438000000000000 ; 000000398698159.305198000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024421A62605D78 >									
	//     < SHERE_PFIII_II_metadata_line_15_____PARTNER_RE_20240505 >									
	//        < FlRM8zxAbnmlGQ6Cnw623Pet5rFoab3zafvtaU1r65M3hH0hG5LTSRe2hMm8d2yE >									
	//        <  u =="0.000000000000000001" : ] 000000398698159.305198000000000000 ; 000000418051239.391586000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002605D7827DE544 >									
	//     < SHERE_PFIII_II_metadata_line_16_____EXOR_20240505 >									
	//        < w98ae2YwIV7d7VjDb7txLKSo89YBekgs1N0QONeOk642WQTg73M80j1jte8aJrd0 >									
	//        <  u =="0.000000000000000001" : ] 000000418051239.391586000000000000 ; 000000436325988.661472000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027DE544299C7D7 >									
	//     < SHERE_PFIII_II_metadata_line_17_____XL_CATLIN_RE_20240505 >									
	//        < 4R69UAN1s69fNtN3jpK0Hm15TU2Y3o5xUXEAJs9i556LX4QwJW908448B5dafmnB >									
	//        <  u =="0.000000000000000001" : ] 000000436325988.661472000000000000 ; 000000459124375.248599000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000299C7D72BC9176 >									
	//     < SHERE_PFIII_II_metadata_line_18_____SOGAZ_20240505 >									
	//        < 76G4HAndmXYQ2E1D89141ZKma5Mm7bekL4TK2hE2DqZa64hHr6O224yF2GY05LpS >									
	//        <  u =="0.000000000000000001" : ] 000000459124375.248599000000000000 ; 000000502402072.382145000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BC91762FE9ACF >									
	//     < SHERE_PFIII_II_metadata_line_19_____GAZPROM_20240505 >									
	//        < 64nlx0F1W4tsWuNKKdqP0085BPk5nAQ83OVhe0lD8c1WjhgmfGgJT7iMq4O8O44c >									
	//        <  u =="0.000000000000000001" : ] 000000502402072.382145000000000000 ; 000000534753461.514429000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FE9ACF32FF812 >									
	//     < SHERE_PFIII_II_metadata_line_20_____VTB INSURANCE_20240505 >									
	//        < c4csYg1x9oeck6dKqqKlS9NI2aqe4z2k069T789cC9XGtw5F0GHRhi6vTo55tD0W >									
	//        <  u =="0.000000000000000001" : ] 000000534753461.514429000000000000 ; 000000553608306.651254000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032FF81234CBD3F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIII_II_metadata_line_21_____WILLIS_LIMITED_20240505 >									
	//        < ldlR318Fm0l1XHit1OX6048nhEJu8G4zv5xURtDyZUypmCv61GR0dkgkaVh9x7RU >									
	//        <  u =="0.000000000000000001" : ] 000000553608306.651254000000000000 ; 000000593632666.999994000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034CBD3F389CFC3 >									
	//     < SHERE_PFIII_II_metadata_line_22_____GUY_CARPENTER_LIMITED_20240505 >									
	//        < 0l818q9mj3vSGB12308yl0r6NK8i3847W66o8G62q02pxVtrB7O595k7W3Rh83hz >									
	//        <  u =="0.000000000000000001" : ] 000000593632666.999994000000000000 ; 000000615535216.665571000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000389CFC33AB3B72 >									
	//     < SHERE_PFIII_II_metadata_line_23_____AON_BENFIELD_20240505 >									
	//        < 29a94sLwvFoBL4QPN8B7121782hUd9YHL9Tu47qIOIjnJ92RnIi6vu14HbaA0Xx7 >									
	//        <  u =="0.000000000000000001" : ] 000000615535216.665571000000000000 ; 000000656165546.673648000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AB3B723E93AAB >									
	//     < SHERE_PFIII_II_metadata_line_24_____WILLIS_CIS_20240505 >									
	//        < njC4tJcM5OCc69efhJ8vU3wb9j193ABAPy2a7QS6oJx475gD6gvW679gnk4c1bL5 >									
	//        <  u =="0.000000000000000001" : ] 000000656165546.673648000000000000 ; 000000700300591.418436000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E93AAB42C92EB >									
	//     < SHERE_PFIII_II_metadata_line_25_____POLISH_RE_20240505 >									
	//        < EhQp54GIud6j4q818gVjl442r3i0RBxpB2258wFgM4i2HqY7gh2kxb30iSM9lHOH >									
	//        <  u =="0.000000000000000001" : ] 000000700300591.418436000000000000 ; 000000716268358.242332000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042C92EB444F054 >									
	//     < SHERE_PFIII_II_metadata_line_26_____TRUST_RE_20240505 >									
	//        < xIgWYo6kW2E6Hz20ywUJKRJ5Iw37uKY9mkcx1gL1s1OgZQ1D4x0LMDuKON57PaDK >									
	//        <  u =="0.000000000000000001" : ] 000000716268358.242332000000000000 ; 000000733124002.407412000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000444F05445EA890 >									
	//     < SHERE_PFIII_II_metadata_line_27_____MALAKUT_20240505 >									
	//        < DRWBH1b6e5N78MOXvkN6jlHKZ5JIz61Me2lDQ66kis2Y3vOl6OZdR91yEvOXB8Wz >									
	//        <  u =="0.000000000000000001" : ] 000000733124002.407412000000000000 ; 000000754707608.558715000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045EA89047F97A9 >									
	//     < SHERE_PFIII_II_metadata_line_28_____SCOR_RUS_20240505 >									
	//        < 0IIm4CBVh7s4MqJssj4e0RXucEQvCQ8skYif1cLJ2tHQhuB4KetvyfFg2PLGDr1Y >									
	//        <  u =="0.000000000000000001" : ] 000000754707608.558715000000000000 ; 000000790937570.978232000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047F97A94B6DFFD >									
	//     < SHERE_PFIII_II_metadata_line_29_____AFM_20240505 >									
	//        < wcDTP0zF9HR8H8m037Z0HOkHJuaPrbxI508IHtK77E4hQc6Nk3bO68oF87QbuWJB >									
	//        <  u =="0.000000000000000001" : ] 000000790937570.978232000000000000 ; 000000826566043.016434000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B6DFFD4ED3D5C >									
	//     < SHERE_PFIII_II_metadata_line_30_____SBERBANK_INSURANCE_20240505 >									
	//        < 5JC3l886163c4H14jz7M4l2Z6bmCe1J2FMdy9VM90hj0e7Z4235w74VyLz3rg787 >									
	//        <  u =="0.000000000000000001" : ] 000000826566043.016434000000000000 ; 000000850998836.303728000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004ED3D5C512856C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIII_II_metadata_line_31_____Societe_Financiere_Sberbank_20240505 >									
	//        < GM8YStFMKo4XT6cS1zyePrc7205Xjh92OLzuIuduGhSmLc3YGjS128gxUl7qXSuW >									
	//        <  u =="0.000000000000000001" : ] 000000850998836.303728000000000000 ; 000000868095511.941720000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000512856C52C9BCF >									
	//     < SHERE_PFIII_II_metadata_line_32_____ENERGOGARANT_20240505 >									
	//        < Yz43eY7j02Bl2THK1lvMsnxUtv2S6C8wXT00x2jln4XRGHN38B22KBf7O1YI8eBL >									
	//        <  u =="0.000000000000000001" : ] 000000868095511.941720000000000000 ; 000000906629630.206067000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052C9BCF5676833 >									
	//     < SHERE_PFIII_II_metadata_line_33_____RSHB_INSURANCE_20240505 >									
	//        < Z4pPy7ZJvWR2o31T55B6QbSU5y7c2SOhLQxuQt50buJ6FCYt7fky3Lr52p0E9Awo >									
	//        <  u =="0.000000000000000001" : ] 000000906629630.206067000000000000 ; 000000943451008.165415000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000567683359F978D >									
	//     < SHERE_PFIII_II_metadata_line_34_____EURASIA_20240505 >									
	//        < 568IhU5HKpeuW995oxPGdutqIPk28396CTy33Dwri62BR736qMn328DBRFn5W7oj >									
	//        <  u =="0.000000000000000001" : ] 000000943451008.165415000000000000 ; 000000980503477.058372000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000059F978D5D8212C >									
	//     < SHERE_PFIII_II_metadata_line_35_____BELARUS_RE_20240505 >									
	//        < ktInYimg19D7GleSob2512aeXB9XdrrHME11Hx7PX7pVCBWejFMd7yi7wEpP7rb7 >									
	//        <  u =="0.000000000000000001" : ] 000000980503477.058372000000000000 ; 000001003755855.325640000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D8212C5FB9C22 >									
	//     < SHERE_PFIII_II_metadata_line_36_____RT_INSURANCE_20240505 >									
	//        < X0eIm1bleP1S777SqcF4EmKsUp91gb5PyKYfwEOJp13X5XCmn4R0F7J2KuG28McA >									
	//        <  u =="0.000000000000000001" : ] 000001003755855.325640000000000000 ; 000001033872004.092870000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005FB9C226299040 >									
	//     < SHERE_PFIII_II_metadata_line_37_____ASPEN_20240505 >									
	//        < D6h0R1ljB3v8bl121t4L0Qouhb7GrFk0RuVJ53i6Ja61GR6xtGC0WSVxoeeuGCmy >									
	//        <  u =="0.000000000000000001" : ] 000001033872004.092870000000000000 ; 000001081499057.808220000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000062990406723C92 >									
	//     < SHERE_PFIII_II_metadata_line_38_____LOL_I_20240505 >									
	//        < pdCF7GD9c3ER680d5dGppXo5OV940Tenj5f566YjQ8Bct8q0xv6DP3jpYMK1fbxi >									
	//        <  u =="0.000000000000000001" : ] 000001081499057.808220000000000000 ; 000001097229236.077110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006723C9268A3D2C >									
	//     < SHERE_PFIII_II_metadata_line_39_____LOL_4472_20240505 >									
	//        < AgNiB5B46r9BS5bfn8nMZRV5c1r8qjW0Jbw4zXqU413a1Q1vvw709PP88n4C9m38 >									
	//        <  u =="0.000000000000000001" : ] 000001097229236.077110000000000000 ; 000001120907472.014970000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000068A3D2C6AE5E7B >									
	//     < SHERE_PFIII_II_metadata_line_40_____LOL_1183_20240505 >									
	//        < IoW4sMu6S8RE8zhkE2370xxRVvvai9p1dCFK1VeuKu2d4TwttH1lD05n5Cz2T76J >									
	//        <  u =="0.000000000000000001" : ] 000001120907472.014970000000000000 ; 000001146203476.099360000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006AE5E7B6D4F7BC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
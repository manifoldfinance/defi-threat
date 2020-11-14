/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	BANK_III_PFI_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	BANK_III_PFI_883		"	;
		string	public		symbol =	"	BANK_III_PFI_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		416540085732862000000000000					;	
										
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
	//     < BANK_III_PFI_metadata_line_1_____PITTSBURG BANK_20220508 >									
	//        < nR432GF3n17mgxIKfGp11qmS2T0I4v5rAH33xh8Lr04MKIZ9t2nC32YrBpEzxg5o >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010340856.460174600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000FC766 >									
	//     < BANK_III_PFI_metadata_line_2_____BANK OF AMERICA_20220508 >									
	//        < nWF5Z2FP5556W4h0l4A6PUxl9Qj30F1gYwGKu7mNT2TNX97A6WAlCS6634a5qBk5 >									
	//        <  u =="0.000000000000000001" : ] 000000010340856.460174600000000000 ; 000000020821683.358015800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000FC7661FC578 >									
	//     < BANK_III_PFI_metadata_line_3_____WELLS FARGO_20220508 >									
	//        < x40kz1749oBB7IWjVg8t0KJcMJV6DPJbpS8u3o33JJ8zHQZfKlGKS32IE7eWA692 >									
	//        <  u =="0.000000000000000001" : ] 000000020821683.358015800000000000 ; 000000031256076.332988600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001FC5782FB168 >									
	//     < BANK_III_PFI_metadata_line_4_____MORGAN STANLEY_20220508 >									
	//        < 8R7gvYVnb19fX015t94x44Cc5uw2F48Y6CV0OJ1ppPP9yQeOg90XZ9d609c84rr6 >									
	//        <  u =="0.000000000000000001" : ] 000000031256076.332988600000000000 ; 000000041575930.826763400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002FB1683F7099 >									
	//     < BANK_III_PFI_metadata_line_5_____LEHAN BROTHERS AB_20220508 >									
	//        < DYB5Per7MOkCldl9pK9No04Is4rfpgQ39xl8O55Zh7224F01O4PTClY0o2JMp9D1 >									
	//        <  u =="0.000000000000000001" : ] 000000041575930.826763400000000000 ; 000000052087630.971689800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003F70994F7ABB >									
	//     < BANK_III_PFI_metadata_line_6_____BARCLAYS_20220508 >									
	//        < xpaynDlCQUQ1lqS74ulLFLL2JXPogtJ5rqCP8w82q64MA90YDV771b58Dp562Oyd >									
	//        <  u =="0.000000000000000001" : ] 000000052087630.971689800000000000 ; 000000062497479.045450100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004F7ABB5F5D14 >									
	//     < BANK_III_PFI_metadata_line_7_____GLDMAN SACHS_20220508 >									
	//        < RT03IAgBuS9KGr90NpbIkXEyIqF27YhUGrAb9qs4OvVuv5em015130dF5VRTzU53 >									
	//        <  u =="0.000000000000000001" : ] 000000062497479.045450100000000000 ; 000000072913000.735099700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F5D146F41A4 >									
	//     < BANK_III_PFI_metadata_line_8_____JPMORGAN_20220508 >									
	//        < 1S33p631F7EW6Ir95wRpV0BrW6pC84E3OWe8a905HL5SfCMa1ah7Njy1k8IIf20G >									
	//        <  u =="0.000000000000000001" : ] 000000072913000.735099700000000000 ; 000000083196432.027440400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006F41A47EF29B >									
	//     < BANK_III_PFI_metadata_line_9_____WACHOVIA_20220508 >									
	//        < K92eVB39Mk5qe18ca30PsdC3ZGP1I2hd4wD6m2r4xG8kec6tZhIG3qN0YqV62gtV >									
	//        <  u =="0.000000000000000001" : ] 000000083196432.027440400000000000 ; 000000093493508.021213000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007EF29B8EA8E7 >									
	//     < BANK_III_PFI_metadata_line_10_____CITIBANK_20220508 >									
	//        < 3NK61jJrOnI5H7VprN40PZlq8NS8kc1rO1v9qSg9o5qHiu5u03OhQiy1I5Bq1z0l >									
	//        <  u =="0.000000000000000001" : ] 000000093493508.021213000000000000 ; 000000103806929.912883000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008EA8E79E6595 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_III_PFI_metadata_line_11_____WASHINGTON MUTUAL_20220508 >									
	//        < s55fI7n682Ai1a3Pd4dy9nqmy2Mx6ssF79450OOupHtIUqrc9l4gS5pU0Cfw2AXU >									
	//        <  u =="0.000000000000000001" : ] 000000103806929.912883000000000000 ; 000000114326926.544941000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009E6595AE72F5 >									
	//     < BANK_III_PFI_metadata_line_12_____SUN TRUST BANKS_20220508 >									
	//        < XV091RRuiZnucDc870Obzgu8QihgHLtuzL469Y2J4Vet3U2hVZDzAAsZ7JL3o4Rd >									
	//        <  u =="0.000000000000000001" : ] 000000114326926.544941000000000000 ; 000000124841013.774560000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AE72F5BE7E05 >									
	//     < BANK_III_PFI_metadata_line_13_____US BANCORP_20220508 >									
	//        < Q8SvR0Lab1t6711qKYaPisCSkp4e7c49roM5BON0d087Wy01vr902bJu686gKN71 >									
	//        <  u =="0.000000000000000001" : ] 000000124841013.774560000000000000 ; 000000135174126.612838000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BE7E05CE4265 >									
	//     < BANK_III_PFI_metadata_line_14_____REGIONS BANK_20220508 >									
	//        < NbRtQI81r698JhWG18Eot05orx1GRCH07IfC6VpGdIG6XHO80TUnxQ2ev0E4U4DA >									
	//        <  u =="0.000000000000000001" : ] 000000135174126.612838000000000000 ; 000000145677351.743342000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CE4265DE4937 >									
	//     < BANK_III_PFI_metadata_line_15_____FEDERAL RESERVE BANK_20220508 >									
	//        < L98xhahZD7MdwwAzzcF8SCPB9S223x1xOOI6R42KySpkC3T97Ao11FMdwe8x14JG >									
	//        <  u =="0.000000000000000001" : ] 000000145677351.743342000000000000 ; 000000156209465.736526000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DE4937EE5B53 >									
	//     < BANK_III_PFI_metadata_line_16_____BRANCH BANKING AND TRUST COMPANY_20220508 >									
	//        < 8TwCCYM35aMEoA4Z31yZHuKyvmkg1VL6RWCSGFP49Ou6ETr7f72tvA6idTRAS48I >									
	//        <  u =="0.000000000000000001" : ] 000000156209465.736526000000000000 ; 000000166647519.136898000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000EE5B53FE48B0 >									
	//     < BANK_III_PFI_metadata_line_17_____NATIONAL CITI BANK_20220508 >									
	//        < g7qD4Qf0Pp89bqCg3oZgox20X4JXt6xb1n7a54E6W1x6B9sUUBMK17oj0dYl58cq >									
	//        <  u =="0.000000000000000001" : ] 000000166647519.136898000000000000 ; 000000176974646.875494000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FE48B010E0AB9 >									
	//     < BANK_III_PFI_metadata_line_18_____HSBC BANK USA_20220508 >									
	//        < EyQy5amm4Gt4K5mKU74cj8W51vSt822a1HE1T9QuN3DSRQaZ18103QAVvL24zENC >									
	//        <  u =="0.000000000000000001" : ] 000000176974646.875494000000000000 ; 000000187376326.086447000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010E0AB911DE9E1 >									
	//     < BANK_III_PFI_metadata_line_19_____WORLD SAVINGS BANKS_FSB_20220508 >									
	//        < 88yr6A6zQ47Q2n376nBIaEggTPOqnv67J6g9VXv3I1Dmx31Q3555rcE8K6iPdiM6 >									
	//        <  u =="0.000000000000000001" : ] 000000187376326.086447000000000000 ; 000000197818824.138529000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011DE9E112DD8FA >									
	//     < BANK_III_PFI_metadata_line_20_____COUNTRYWIDE BANK_20220508 >									
	//        < akaYG6nMtbnFwodkfEQgvimNNpQZ1PHN3LM0uUpw2J33JZ652TiExftM60iS9Qe0 >									
	//        <  u =="0.000000000000000001" : ] 000000197818824.138529000000000000 ; 000000208121154.154829000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012DD8FA13D9153 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_III_PFI_metadata_line_21_____PNC BANK_PITTSBURG_II_20220508 >									
	//        < v09wuUVnj4Amg4AgdUfx871Pgo2rDPiDqNHulyAIYG7VY437c13a0CZ7Ou3sW3uM >									
	//        <  u =="0.000000000000000001" : ] 000000208121154.154829000000000000 ; 000000218535247.152894000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013D915314D7555 >									
	//     < BANK_III_PFI_metadata_line_22_____KEYBANK_20220508 >									
	//        < 8rBzpHt97D2dmg4W393deEYpU6acu98sXqieNZ38P3pNol5q3U9cwUp39YFZkp07 >									
	//        <  u =="0.000000000000000001" : ] 000000218535247.152894000000000000 ; 000000228893489.001407000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014D755515D4385 >									
	//     < BANK_III_PFI_metadata_line_23_____ING BANK_FSB_20220508 >									
	//        < q71g4Gcnc4tX5WuMkcka65V3aZ8277q11W8dUE052Mzu05kkUUM4Cr5MifEzIxA3 >									
	//        <  u =="0.000000000000000001" : ] 000000228893489.001407000000000000 ; 000000239259090.945853000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015D438516D1495 >									
	//     < BANK_III_PFI_metadata_line_24_____MERRILL LYNCH BANK USA_20220508 >									
	//        < Zi8T73ZX8N6KgfdOnMH4l6EdY5HF22S6tua7p1985XEiB7T45309osjLhY5Sv465 >									
	//        <  u =="0.000000000000000001" : ] 000000239259090.945853000000000000 ; 000000249663839.178693000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016D149517CF4F0 >									
	//     < BANK_III_PFI_metadata_line_25_____SOVEREIGN BANK_20220508 >									
	//        < 3Dqsut8tW9RQ223TZ099P661927F8GNeWIVBUN56Fvma73OsOJkqU327kw3zyxuO >									
	//        <  u =="0.000000000000000001" : ] 000000249663839.178693000000000000 ; 000000260160626.680347000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017CF4F018CF93F >									
	//     < BANK_III_PFI_metadata_line_26_____COMERICA BANK_20220508 >									
	//        < 7k2Rwr8S968WP50j6WehDh2jU2Zipa1O454fpOJq5ZbOZJcY50Nh9lDWrPH229RW >									
	//        <  u =="0.000000000000000001" : ] 000000260160626.680347000000000000 ; 000000270559078.586974000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018CF93F19CD724 >									
	//     < BANK_III_PFI_metadata_line_27_____UNION BANK OF CALIFORNIA_20220508 >									
	//        < QMX2ukfblvFlC4GlLJbI9K5fTuul8Nz6d6FI5bccHr4meJb8rRbwL1s9TPVATst0 >									
	//        <  u =="0.000000000000000001" : ] 000000270559078.586974000000000000 ; 000000280833083.088751000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019CD7241AC846C >									
	//     < BANK_III_PFI_metadata_line_28_____ING BANK_20220508 >									
	//        < x9V5c80WSqvU27xB5jOqQ2N4d3s27K8pl5bmiP3s3QGfeQ332ufMDF6BD6235Y69 >									
	//        <  u =="0.000000000000000001" : ] 000000280833083.088751000000000000 ; 000000291370572.064881000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AC846C1BC98A1 >									
	//     < BANK_III_PFI_metadata_line_29_____DEKA BANK_20220508 >									
	//        < c7Sjeyak8r5Z162q6aokKwc7618yP8GTDJdhf17kMhQ6BtKLDtM6UQ8LlwnmCjNw >									
	//        <  u =="0.000000000000000001" : ] 000000291370572.064881000000000000 ; 000000301793814.031114000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BC98A11CC8035 >									
	//     < BANK_III_PFI_metadata_line_30_____BNPPARIBAS_20220508 >									
	//        < 2Zo56D9xA2PDAc85qOMtMo6Z9Q91MxwyHI35MDQMYV19Nai0MGyb42gZWi4d7Ku8 >									
	//        <  u =="0.000000000000000001" : ] 000000301793814.031114000000000000 ; 000000312285166.370636000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CC80351DC8265 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_III_PFI_metadata_line_31_____SOCIETE GENERALE  _20220508 >									
	//        < 6sdxyBke3J208qs5Y6HF8u5rA24cXExLv95cRo005A9gFvtuv9jLxZa2994ATr3e >									
	//        <  u =="0.000000000000000001" : ] 000000312285166.370636000000000000 ; 000000322739688.527736000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DC82651EC7631 >									
	//     < BANK_III_PFI_metadata_line_32_____CREDIT_AGRICOLE_SA_20220508 >									
	//        < 4KlwG9dj97o8Qho4d6q7a288hozKk0cHaQy42c1jc3VH3HLA3CQfnPC6D16XYlX9 >									
	//        <  u =="0.000000000000000001" : ] 000000322739688.527736000000000000 ; 000000333216793.325309000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EC76311FC72CF >									
	//     < BANK_III_PFI_metadata_line_33_____CREDIT_MUTUEL_20220508 >									
	//        < QN98fr9oa3b75l8AI7agqPM0YW57JQwrU27IzftrB46dSsP80zVAijZ3wmu4Qj9B >									
	//        <  u =="0.000000000000000001" : ] 000000333216793.325309000000000000 ; 000000343552340.043677000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FC72CF20C3822 >									
	//     < BANK_III_PFI_metadata_line_34_____DEXIA_20220508 >									
	//        < NiIqXQ528o8P62Z8Du060xMPhRVP74387WHVPE1j5qOxRnElTWS8cz6I7h9MA88t >									
	//        <  u =="0.000000000000000001" : ] 000000343552340.043677000000000000 ; 000000353901836.884896000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020C382221C02E8 >									
	//     < BANK_III_PFI_metadata_line_35_____CREDIT_INDUSTRIEL_COMMERCIAL_20220508 >									
	//        < QiX8qBtcpqbnpDlRWqDLUOPQoMxy985tW34kMPM6z8nIERk3I9DK0DR0r9hBsxL0 >									
	//        <  u =="0.000000000000000001" : ] 000000353901836.884896000000000000 ; 000000364429362.235802000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021C02E822C1338 >									
	//     < BANK_III_PFI_metadata_line_36_____SANTANDER_20220508 >									
	//        < vN7m9g85m9k1M8YHb7omQan428E9F3A1Y806H3xBBR0DPLaRn6T0um6INB30loG4 >									
	//        <  u =="0.000000000000000001" : ] 000000364429362.235802000000000000 ; 000000374841209.970805000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022C133823BF659 >									
	//     < BANK_III_PFI_metadata_line_37_____CREDIT_LYONNAIS_20220508 >									
	//        < Kx2vOXgPSGiOTdzXN84n7tMJwrb186pMencoOGCzxqral4jq2oP034MHFG41FnUN >									
	//        <  u =="0.000000000000000001" : ] 000000374841209.970805000000000000 ; 000000385358392.635883000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023BF65924C029F >									
	//     < BANK_III_PFI_metadata_line_38_____BANQUES_POPULAIRES_20220508 >									
	//        < UtD30qK75NDhC4l6VQF9x4Nh1dqzXoRZvGfAlfpymCR37xUk01GbvVvlsUktb99z >									
	//        <  u =="0.000000000000000001" : ] 000000385358392.635883000000000000 ; 000000395741158.521233000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024C029F25BDA64 >									
	//     < BANK_III_PFI_metadata_line_39_____CAISSES_D_EPARGNE_20220508 >									
	//        < 6F93u6bWYgy276R1W5IoUNEq8LoLPfIN8V327sdAL9xZZyqZZy3Q64p3sI0lxE1P >									
	//        <  u =="0.000000000000000001" : ] 000000395741158.521233000000000000 ; 000000406098690.625339000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025BDA6426BA84D >									
	//     < BANK_III_PFI_metadata_line_40_____LAZARD_20220508 >									
	//        < hayU9EA55B7NhX4tVgIHZfz1p5oFG8v5tGN3nY4543c84P2rK25NlBu88D5I1Y0H >									
	//        <  u =="0.000000000000000001" : ] 000000406098690.625339000000000000 ; 000000416540085.732862000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026BA84D27B96F9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
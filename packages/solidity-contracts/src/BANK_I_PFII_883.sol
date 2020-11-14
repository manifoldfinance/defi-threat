/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	BANK_I_PFII_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	BANK_I_PFII_883		"	;
		string	public		symbol =	"	BANK_I_PFII_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		426336036009428000000000000					;	
										
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
	//     < BANK_I_PFII_metadata_line_1_____HEIDELBERG_Stadt_20240508 >									
	//        < 43Dd3gs43X8Yr4UNrM4Zy87ps421st85goKMXXJR5YPFfJ2sC0G54YJ8IQcO551l >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010499987.643315000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000010058F >									
	//     < BANK_I_PFII_metadata_line_2_____SAARBRUECKEN_Stadt_20240508 >									
	//        < Ohk8Sd0WMZt6P64aLth1Xq2gFEebF3bc5v6HmWz9S5rmzaL8vrc7M5W9n6t1T5dS >									
	//        <  u =="0.000000000000000001" : ] 000000010499987.643315000000000000 ; 000000020978969.380980900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000010058F2002E9 >									
	//     < BANK_I_PFII_metadata_line_3_____KAISERSLAUTERN_Stadt_20240508 >									
	//        < F97L212iuq90ZymJlH3G63018G4DyOhHm5r8F3R4Fq591e896i1u59y63032A5IM >									
	//        <  u =="0.000000000000000001" : ] 000000020978969.380980900000000000 ; 000000031604219.774978300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002002E9303966 >									
	//     < BANK_I_PFII_metadata_line_4_____KOBLENZ_Stadt_20240508 >									
	//        < iidb8ak6o4pPxhj5C258db24r300a6r0mXB2N0qT37tkosfhAwn8gwoLRU5Wdjk9 >									
	//        <  u =="0.000000000000000001" : ] 000000031604219.774978300000000000 ; 000000042154092.914003200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000303966405271 >									
	//     < BANK_I_PFII_metadata_line_5_____MAINZ_Stadt_20240508 >									
	//        < E8mP1krZGZW34y8A45VbNt0wFFEl08jyCz0A0F0PW23B7fi82l1j1J5cpWl6XsC2 >									
	//        <  u =="0.000000000000000001" : ] 000000042154092.914003200000000000 ; 000000052651728.214053600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000405271505715 >									
	//     < BANK_I_PFII_metadata_line_6_____RUESSELSHEIM_AM_MAIN_Stadt_20240508 >									
	//        < XJ48Cf662x76Ewbg98pNEdW8hO71NuD86q1M5shqERN3ATJIr6y61E5v2E5g6IJT >									
	//        <  u =="0.000000000000000001" : ] 000000052651728.214053600000000000 ; 000000063396074.301782300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000050571560BC17 >									
	//     < BANK_I_PFII_metadata_line_7_____INGELHEIM_AM_RHEIN_Stadt_20240508 >									
	//        < 9zHGa7QlAseT77X8f8H2cjbtP7HbcK1FTqrZPPKs61eWg25Kpe1n56V5x583cg4N >									
	//        <  u =="0.000000000000000001" : ] 000000063396074.301782300000000000 ; 000000074135343.412316600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000060BC17711F1E >									
	//     < BANK_I_PFII_metadata_line_8_____WIESBADEN_Stadt_20240508 >									
	//        < vZzMmvv2LqjaRiR3h2XsP9633bQVk4Guo36hoQEswjI6T3rz7CpF9005Dup5i1X7 >									
	//        <  u =="0.000000000000000001" : ] 000000074135343.412316600000000000 ; 000000085006769.968463900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000711F1E81B5C5 >									
	//     < BANK_I_PFII_metadata_line_9_____FRANKFURT_AM_MAIN_Stadt_20240508 >									
	//        < C3pBb57IYvG6BV6Ww4zjsXxj4085a3IL2yOij8B2ZVVTnJ7q8wreD9fJe39d70Pi >									
	//        <  u =="0.000000000000000001" : ] 000000085006769.968463900000000000 ; 000000095723059.210729000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000081B5C5920FD2 >									
	//     < BANK_I_PFII_metadata_line_10_____DARMSTADT_Stadt_20240508 >									
	//        < 5mF8l94SqsqWM8w0x1c3ngLXwmYF9Jsnl3V957I8azVK19Jxj5279MZ6y65ePhh1 >									
	//        <  u =="0.000000000000000001" : ] 000000095723059.210729000000000000 ; 000000106599573.624526000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000920FD2A2A875 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_I_PFII_metadata_line_11_____LUDWIGSHAFEN_Stadt_20240508 >									
	//        < VqXgtV1ow9UyYuRpOu0p4F6l0MOFDOcuCrh00vq9OCoigCL385mNh3565xsj4u4k >									
	//        <  u =="0.000000000000000001" : ] 000000106599573.624526000000000000 ; 000000117102485.519344000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A2A875B2AF29 >									
	//     < BANK_I_PFII_metadata_line_12_____MANNHEIM_Stadt_20240508 >									
	//        < 8K800ohS7h6GhF4c1NlUX86V4Oq2c8R19bbfWMllv2YT7mtYBB91D47OwF0kICZ6 >									
	//        <  u =="0.000000000000000001" : ] 000000117102485.519344000000000000 ; 000000127952236.265406000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B2AF29C33D58 >									
	//     < BANK_I_PFII_metadata_line_13_____KARLSRUHE_Stadt_20240508 >									
	//        < ttcWT13aA543r4k71V2x3f832V9GEt0kMIlHF60QEWn7XEL5HvRv7n2eGXz9GrkB >									
	//        <  u =="0.000000000000000001" : ] 000000127952236.265406000000000000 ; 000000138460062.202967000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C33D58D345F6 >									
	//     < BANK_I_PFII_metadata_line_14_____STUTTGART_Stadt_20240508 >									
	//        < 1QmeKFIndjPRI4hb0w5O0TDN9Pg5K5y8N3IcSjipd2u2Kw9y6yzU1Kd3jQuJGt9Z >									
	//        <  u =="0.000000000000000001" : ] 000000138460062.202967000000000000 ; 000000149116545.731953000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D345F6E388A7 >									
	//     < BANK_I_PFII_metadata_line_15_____AUGSBURG_Stadt_20240508 >									
	//        < 8839A523gwSvCN22WIJRrz62BbPsy6vb1esUL1mTWRg2i9B7G4J9gitr7Grqd0q8 >									
	//        <  u =="0.000000000000000001" : ] 000000149116545.731953000000000000 ; 000000159674085.377698000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E388A7F3A4B1 >									
	//     < BANK_I_PFII_metadata_line_16_____INGOLSTADT_Stadt_20240508 >									
	//        < olzphLa7o69JLrxkg64iDE5rR6DANJh6l3N3rM42z3G5lQ99q42Y7W6RcEab21Xo >									
	//        <  u =="0.000000000000000001" : ] 000000159674085.377698000000000000 ; 000000170453554.732433000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F3A4B1104176B >									
	//     < BANK_I_PFII_metadata_line_17_____NUERNBERG_Stadt_20240508 >									
	//        < b2Sjl3sof7w0I67u0uNeQU82650dCPHHCmf941lN5x9s0n6EdJ3dL5iBsXlwb4JS >									
	//        <  u =="0.000000000000000001" : ] 000000170453554.732433000000000000 ; 000000181123200.198803000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000104176B1145F40 >									
	//     < BANK_I_PFII_metadata_line_18_____REGENSBURG_Stadt_20240508 >									
	//        < FW0aYnb4Mia509X3up79AlnHnOuw875cQPi0M810p5p76Gx6a7E4MjG5U0aH2Vgk >									
	//        <  u =="0.000000000000000001" : ] 000000181123200.198803000000000000 ; 000000191642320.628372000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001145F401246C48 >									
	//     < BANK_I_PFII_metadata_line_19_____HANNOVER_Stadt_20240508 >									
	//        < 09iB1EFbYsEUSSI6G46EfNlkOphr28tQXc9ZkOcmAB1c9yhPo155g3ksSVO170Z3 >									
	//        <  u =="0.000000000000000001" : ] 000000191642320.628372000000000000 ; 000000202494884.854692000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001246C48134FB90 >									
	//     < BANK_I_PFII_metadata_line_20_____AACHEN_Stadt_20240508 >									
	//        < iW78kAtS4rfGn95v5gQ69FsisFESLYW3j195IVgt1P1Q4i40TCXoP3Q9jU312410 >									
	//        <  u =="0.000000000000000001" : ] 000000202494884.854692000000000000 ; 000000213377646.206647000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000134FB9014596A5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_I_PFII_metadata_line_21_____KOELN_Stadt_20240508 >									
	//        < 3l2Od05nKS9dgpv9F2eDZPLby665X8UqmQ9voB7YKg7C4eZD2Exg3WaMyCrwg32N >									
	//        <  u =="0.000000000000000001" : ] 000000213377646.206647000000000000 ; 000000223995726.360233000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014596A5155CA55 >									
	//     < BANK_I_PFII_metadata_line_22_____DUESSELDORF_Stadt_20240508 >									
	//        < cNY36E4rd128Z3h76lh4E9S7Zwoy9ex8WGM51cg6uLlwc29Yoi2U84wXFVLK5su7 >									
	//        <  u =="0.000000000000000001" : ] 000000223995726.360233000000000000 ; 000000234653404.170055000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000155CA551660D7C >									
	//     < BANK_I_PFII_metadata_line_23_____BONN_Stadt_20240508 >									
	//        < MPJ5sTd8CDVRSJmL52Iqd1P388gnJ390RR2Amxz95vpJ8V3Z4G421F3U8ZpSqf0i >									
	//        <  u =="0.000000000000000001" : ] 000000234653404.170055000000000000 ; 000000245125246.499932000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001660D7C176080D >									
	//     < BANK_I_PFII_metadata_line_24_____DUISBURG_Stadt_20240508 >									
	//        < 0j8VEAMj7n8ERJOZB5GzP83CR17B69uUyS7goBqiknc58915AkNWRZ969i41NpV4 >									
	//        <  u =="0.000000000000000001" : ] 000000245125246.499932000000000000 ; 000000255852465.415043000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000176080D186665F >									
	//     < BANK_I_PFII_metadata_line_25_____WUPPERTAL_Stadt_20240508 >									
	//        < 903XzrUzsses6ie5Zh54grJ655GW4hSTAzj8ZxIiCMvLmShXx38Ai7p6k91I5422 >									
	//        <  u =="0.000000000000000001" : ] 000000255852465.415043000000000000 ; 000000266371573.348798000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000186665F1967365 >									
	//     < BANK_I_PFII_metadata_line_26_____ESSEN_Stadt_20240508 >									
	//        < yvD3O0lSQ69V2ihjiB3m7n9t1z9S3a49OB3o8yBJKI66q5bn26MCHZZXSgGJ1VAV >									
	//        <  u =="0.000000000000000001" : ] 000000266371573.348798000000000000 ; 000000277248841.265313000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019673651A70C54 >									
	//     < BANK_I_PFII_metadata_line_27_____DORTMUND_Stadt_20240508 >									
	//        < Y6Q3oULnHy7822961fiq52wMmbtmlXneAs718ZQ99T2gmS2cnjI23SmpwxfftO02 >									
	//        <  u =="0.000000000000000001" : ] 000000277248841.265313000000000000 ; 000000287773351.101088000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A70C541B71B77 >									
	//     < BANK_I_PFII_metadata_line_28_____MUENSTER_Stadt_20240508 >									
	//        < h7L451c8OWrJk1Z6XQ75XFreiQrA87fFxG0OmXT8soEEN3H3nClc7MrQGoN97z8w >									
	//        <  u =="0.000000000000000001" : ] 000000287773351.101088000000000000 ; 000000298259963.820819000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B71B771C71BCC >									
	//     < BANK_I_PFII_metadata_line_29_____MOENCHENGLADBACH_Stadt_20240508 >									
	//        < Q1BBLSby75gTN5GegHq98HK1PbbyI2RJGKCFE5L0aTS6e2lQFAPgXWV674i2wBzL >									
	//        <  u =="0.000000000000000001" : ] 000000298259963.820819000000000000 ; 000000308904701.230223000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C71BCC1D759E6 >									
	//     < BANK_I_PFII_metadata_line_30_____WORMS_Stadt_20240508 >									
	//        < ki98rEmxf6j54e1lh8mHieh3Bq8n68r1aDi9j5991d7mnN9cN9z713wkzVGYyhpL >									
	//        <  u =="0.000000000000000001" : ] 000000308904701.230223000000000000 ; 000000319633332.337666000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D759E61E7B8C5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_I_PFII_metadata_line_31_____SPEYER_Stadt_20240508 >									
	//        < wpDs0290r5MtqhD2O1ZF7DTlsP67oDDms6CsxNY9LrfXyUzrAS30BZ3Xs9hIv9tY >									
	//        <  u =="0.000000000000000001" : ] 000000319633332.337666000000000000 ; 000000330103506.357197000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E7B8C51F7B2AF >									
	//     < BANK_I_PFII_metadata_line_32_____BADEN_BADEN_Stadt_20240508 >									
	//        < vTD17nI7N607E4XscR2Bh1ZJJBL8rsL4LL5x3P5g3Q1Ece9a3F361E18W1d7J2LY >									
	//        <  u =="0.000000000000000001" : ] 000000330103506.357197000000000000 ; 000000340688890.812936000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F7B2AF207D999 >									
	//     < BANK_I_PFII_metadata_line_33_____OFFENBURG_Stadt_20240508 >									
	//        < 4e5tWGTERdvb92R9fe4r09GbCyEl3L7Gj5Eiw6BiJ114AulM9274G6oIriI68mW6 >									
	//        <  u =="0.000000000000000001" : ] 000000340688890.812936000000000000 ; 000000351341378.751619000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000207D9992181ABA >									
	//     < BANK_I_PFII_metadata_line_34_____FREIBURG_AM_BREISGAU_Stadt_20240508 >									
	//        < 01A74Yh46g7BuMd7U39IkzhUZa1RExwpk5X05328303nEe8m94p9Yx3GwCSIw3zS >									
	//        <  u =="0.000000000000000001" : ] 000000351341378.751619000000000000 ; 000000361955879.170145000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002181ABA2284D04 >									
	//     < BANK_I_PFII_metadata_line_35_____KEMPTEN_Stadt_20240508 >									
	//        < D1bN9jeqLIEE9ejAUfmmj04m9k1cJ8a1po19q92kla1KWo57XZi1ER0zCG3Rje0A >									
	//        <  u =="0.000000000000000001" : ] 000000361955879.170145000000000000 ; 000000372547479.575543000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002284D04238765C >									
	//     < BANK_I_PFII_metadata_line_36_____ULM_Stadt_20240508 >									
	//        < xDiJhGfdTvbkNpSWe52G4Ghvb2F3t9QF6w0hfK2i008Nb66osJy11M32a6SK33LP >									
	//        <  u =="0.000000000000000001" : ] 000000372547479.575543000000000000 ; 000000383347154.764285000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000238765C248F0FB >									
	//     < BANK_I_PFII_metadata_line_37_____RAVENSBURG_Stadt_20240508 >									
	//        < 1KCo8u3QJUk6sy85nwA07YhSsS2XZ0y30snbs42ycX2mXni4T81RNk961NlT7gFO >									
	//        <  u =="0.000000000000000001" : ] 000000383347154.764285000000000000 ; 000000393971393.271722000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000248F0FB2592713 >									
	//     < BANK_I_PFII_metadata_line_38_____FRIEDRICHSHAFEN_Stadt_20240508 >									
	//        < 2N8LN2599AbF6LOvK6F8uggy7Z2k17H2XmxEqV3Z978NxPwE0Xy1lW359H6AvqUK >									
	//        <  u =="0.000000000000000001" : ] 000000393971393.271722000000000000 ; 000000404882772.362140000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002592713269CD55 >									
	//     < BANK_I_PFII_metadata_line_39_____KONSTANZ_Stadt_20240508 >									
	//        < Ml8F35I9I1mad8r26WM6Lr71X2Wpjj9s8i886z2imH57My97PnX4G4Q4bE9MTHcU >									
	//        <  u =="0.000000000000000001" : ] 000000404882772.362140000000000000 ; 000000415741552.225652000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000269CD5527A5F0B >									
	//     < BANK_I_PFII_metadata_line_40_____A40_20240508 >									
	//        < xgwb4ZjwEles913xJKK3l6Rf87WMUJ6YU1aTG3RuLz3njgg023M3zTqq3qupi8NG >									
	//        <  u =="0.000000000000000001" : ] 000000415741552.225652000000000000 ; 000000426336036.009428000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A5F0B28A8984 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
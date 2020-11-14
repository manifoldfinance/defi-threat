/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	BANK_III_PFIII_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	BANK_III_PFIII_883		"	;
		string	public		symbol =	"	BANK_III_PFIII_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		439201543085926000000000000					;	
										
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
	//     < BANK_III_PFIII_metadata_line_1_____PITTSBURG BANK_20260508 >									
	//        < DU98SbaXwv7u6xOeFiVX2kzfno7F29gh5PW7wW34R0FD386CIxanhac5065DZ2fp >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010832852.905601300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000010913E >									
	//     < BANK_III_PFIII_metadata_line_2_____BANK OF AMERICA_20260508 >									
	//        < 6yL3RY6KIrciA6swhEUQ7153k9Y1v51704cy6Ip8PRh4WI0TMJ3V1lS97l7alnRV >									
	//        <  u =="0.000000000000000001" : ] 000000010832852.905601300000000000 ; 000000021654261.089122400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000010913E20A656 >									
	//     < BANK_III_PFIII_metadata_line_3_____WELLS FARGO_20260508 >									
	//        < nUN8Oh5y0K4Y9deyr928SU17T93bS397ikL77T3aev202NP8BG4JfwYuYo43IM3p >									
	//        <  u =="0.000000000000000001" : ] 000000021654261.089122400000000000 ; 000000032759731.698903400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000020A656310103 >									
	//     < BANK_III_PFIII_metadata_line_4_____MORGAN STANLEY_20260508 >									
	//        < W6023y8323R3srrx467UK49726Xht679uQ58iqGYHh133s5gByBhu8ySfiul32e9 >									
	//        <  u =="0.000000000000000001" : ] 000000032759731.698903400000000000 ; 000000043600607.257665900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000310103415496 >									
	//     < BANK_III_PFIII_metadata_line_5_____LEHAN BROTHERS AB_20260508 >									
	//        < F8um08mD15w4PAPy24dW9QA7L7WkDBqDh3pu038va6bzhjkzhpYo24P475DqCvg3 >									
	//        <  u =="0.000000000000000001" : ] 000000043600607.257665900000000000 ; 000000054710909.594309000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000041549651AA21 >									
	//     < BANK_III_PFIII_metadata_line_6_____BARCLAYS_20260508 >									
	//        < Vsr0rkZn95ettGCGTP8dHXHKODN7Odpd8isl6qa9IMU33LR8z9i3p5Vx0hn7rd84 >									
	//        <  u =="0.000000000000000001" : ] 000000054710909.594309000000000000 ; 000000065884331.732601100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000051AA216230A3 >									
	//     < BANK_III_PFIII_metadata_line_7_____GLDMAN SACHS_20260508 >									
	//        < 4PQ280jOj8K89Lo3j74Ol57Jo9LG49EZ41O73y0jqIfMIL8hfpQJ92NK1nfx3Xsf >									
	//        <  u =="0.000000000000000001" : ] 000000065884331.732601100000000000 ; 000000076875649.076077400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006230A372CBC1 >									
	//     < BANK_III_PFIII_metadata_line_8_____JPMORGAN_20260508 >									
	//        < Fp39247w9gl1N73S18ybRrC33K1ce2sJJKaQK0E8EfWbalcr15TjmL8K04fTwHTA >									
	//        <  u =="0.000000000000000001" : ] 000000076875649.076077400000000000 ; 000000088127672.256142800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000072CBC182F810 >									
	//     < BANK_III_PFIII_metadata_line_9_____WACHOVIA_20260508 >									
	//        < eP6R25WUiAtN20EadndYi3C2KHZ2O7HRN00XbT778QIIJ2cFq9cjmh4mYLfV82lv >									
	//        <  u =="0.000000000000000001" : ] 000000088127672.256142800000000000 ; 000000099067180.805202900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000082F810931564 >									
	//     < BANK_III_PFIII_metadata_line_10_____CITIBANK_20260508 >									
	//        < S5u5VNDN526UB3lW962xn2By3o5A924P2dobz95g0O99a290R68x0KW6fhBVZk6d >									
	//        <  u =="0.000000000000000001" : ] 000000099067180.805202900000000000 ; 000000109985119.122206000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000931564A37735 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_III_PFIII_metadata_line_11_____WASHINGTON MUTUAL_20260508 >									
	//        < lze8e4s0WuHY58tUrB7G6sl7P7T9q2RsZwNeIzV4ot0cpaidnwY6wWZR4xl78ZNz >									
	//        <  u =="0.000000000000000001" : ] 000000109985119.122206000000000000 ; 000000121307214.546719000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A37735B42111 >									
	//     < BANK_III_PFIII_metadata_line_12_____SUN TRUST BANKS_20260508 >									
	//        < 24UXPIoeK0vDI06r51M16dd0LJrz1gg1TRco17z2929Mu2Ly0xbIsCkQGus9RsH9 >									
	//        <  u =="0.000000000000000001" : ] 000000121307214.546719000000000000 ; 000000132418287.613854000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B42111C4B87F >									
	//     < BANK_III_PFIII_metadata_line_13_____US BANCORP_20260508 >									
	//        < lt026c1AG6n020y761adL03i5jL8P645On4IBvy2Jbj59K56ofMmmD17xbaqk6nC >									
	//        <  u =="0.000000000000000001" : ] 000000132418287.613854000000000000 ; 000000143672041.095432000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C4B87FD52CC0 >									
	//     < BANK_III_PFIII_metadata_line_14_____REGIONS BANK_20260508 >									
	//        < 0bi1nEF91Ror3M3Y9JSW8ETOFZDF41Iw23CDpvaJZ4lgTJi8TOv60pwnHFlLf7eO >									
	//        <  u =="0.000000000000000001" : ] 000000143672041.095432000000000000 ; 000000154332378.640904000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D52CC0E5A08B >									
	//     < BANK_III_PFIII_metadata_line_15_____FEDERAL RESERVE BANK_20260508 >									
	//        < 04lN3xJ27Hzb3TpZ469kRAT26NH4a7G1YLo9iN10dalbSlUOlFfxs7LtoXQ9HbZx >									
	//        <  u =="0.000000000000000001" : ] 000000154332378.640904000000000000 ; 000000165392796.161006000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E5A08BF630B6 >									
	//     < BANK_III_PFIII_metadata_line_16_____BRANCH BANKING AND TRUST COMPANY_20260508 >									
	//        < IGXc9Id2LI3nIgDw8368S6mfF4H2yh4LWXQvEmawEwKRA0BWhoMgUjJCj85k1IoJ >									
	//        <  u =="0.000000000000000001" : ] 000000165392796.161006000000000000 ; 000000176258309.894472000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F630B61069785 >									
	//     < BANK_III_PFIII_metadata_line_17_____NATIONAL CITI BANK_20260508 >									
	//        < WBHIcGYdnql52e6ag4207EU3YBIPtQ0f95ONFsMCDbhV4YfSEL5Az2Pfcn7b8Z9M >									
	//        <  u =="0.000000000000000001" : ] 000000176258309.894472000000000000 ; 000000187381227.018648000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010697851171D5C >									
	//     < BANK_III_PFIII_metadata_line_18_____HSBC BANK USA_20260508 >									
	//        < hlag92hxELe55OZC0XgXlsuyjy3C68W6OPg0E1KQxRnv15Yu9o3Y8WUega942j9Q >									
	//        <  u =="0.000000000000000001" : ] 000000187381227.018648000000000000 ; 000000198226342.435245000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001171D5C1276624 >									
	//     < BANK_III_PFIII_metadata_line_19_____WORLD SAVINGS BANKS_FSB_20260508 >									
	//        < o94jjRVxXMSWUSUp66v93V4OA7QZHF7TCxI9X7L2F8t50P7GkOfUUNvbS6hS5dj0 >									
	//        <  u =="0.000000000000000001" : ] 000000198226342.435245000000000000 ; 000000209140622.360158000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001276624137A762 >									
	//     < BANK_III_PFIII_metadata_line_20_____COUNTRYWIDE BANK_20260508 >									
	//        < cv253Z69y1LD1NoMyEeS8KC3P9JZzsYV7ej06chh8Qt0Zr9AHT9ZGyvfystyO5II >									
	//        <  u =="0.000000000000000001" : ] 000000209140622.360158000000000000 ; 000000220080413.658264000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000137A7621484A90 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_III_PFIII_metadata_line_21_____PNC BANK_PITTSBURG_II_20260508 >									
	//        < 194pQs820jg11nxAW5ivxRwSeUT6egd9Iz25sIun4EHSNzep6ym4xfa7cXcZuJoM >									
	//        <  u =="0.000000000000000001" : ] 000000220080413.658264000000000000 ; 000000231187153.302760000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001484A901589541 >									
	//     < BANK_III_PFIII_metadata_line_22_____KEYBANK_20260508 >									
	//        < 45VcV6Vrz2w1C1xk90g7r30D1xtZOWQn6mNmhCU6uet6459uQU0OLB0lt3O1Iks6 >									
	//        <  u =="0.000000000000000001" : ] 000000231187153.302760000000000000 ; 000000241845515.227048000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001589541168DEF8 >									
	//     < BANK_III_PFIII_metadata_line_23_____ING BANK_FSB_20260508 >									
	//        < H919izxWj3gTyszE0pWP409lC7TJi92341gtLblKcWKzovch0Pwvpgi7t9BfyAp5 >									
	//        <  u =="0.000000000000000001" : ] 000000241845515.227048000000000000 ; 000000253000709.532030000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000168DEF81796FE2 >									
	//     < BANK_III_PFIII_metadata_line_24_____MERRILL LYNCH BANK USA_20260508 >									
	//        < o8RJ9r84iIWH1e33HG3XzY5S26i20fz05Oxb4VQEz99l3GXUW9Kv556a9WTZxz4G >									
	//        <  u =="0.000000000000000001" : ] 000000253000709.532030000000000000 ; 000000263760290.312798000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001796FE2189E9BF >									
	//     < BANK_III_PFIII_metadata_line_25_____SOVEREIGN BANK_20260508 >									
	//        < 8341dQo35fYEby9Pv9vXq8Eg5IAJGuHbW9QL5mlUdRNtr0904BmK807t144uCUl2 >									
	//        <  u =="0.000000000000000001" : ] 000000263760290.312798000000000000 ; 000000274833492.538875000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000189E9BF19A16C0 >									
	//     < BANK_III_PFIII_metadata_line_26_____COMERICA BANK_20260508 >									
	//        < ukDuQlGYaS3QC0KULx0B9Xk4l73gn6gCSQKz1u2tfcQ7dv2SQpj0rA0e2X7f3wd0 >									
	//        <  u =="0.000000000000000001" : ] 000000274833492.538875000000000000 ; 000000285742145.813909000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019A16C01AA44E0 >									
	//     < BANK_III_PFIII_metadata_line_27_____UNION BANK OF CALIFORNIA_20260508 >									
	//        < tR9kNb55ByVA60GG75F4H8gd949I4t268hfjzgrE8QwpN76D6Y86470665CDj6uH >									
	//        <  u =="0.000000000000000001" : ] 000000285742145.813909000000000000 ; 000000296593380.804750000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AA44E01BA907B >									
	//     < BANK_III_PFIII_metadata_line_28_____ING BANK_20260508 >									
	//        < Y68HrvU3yLfs3tKxnivh69kT48JSgjQo58FB8tR4C9IDjC2qyIT80161P786jTVI >									
	//        <  u =="0.000000000000000001" : ] 000000296593380.804750000000000000 ; 000000307455562.293656000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BA907B1CB0D5C >									
	//     < BANK_III_PFIII_metadata_line_29_____DEKA BANK_20260508 >									
	//        < rB132027Dn884e3E00N80961dEjhq71a5S50GbfkVZxzVUji2pWW9qOIV3Q87t84 >									
	//        <  u =="0.000000000000000001" : ] 000000307455562.293656000000000000 ; 000000318568850.508379000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CB0D5C1DB3618 >									
	//     < BANK_III_PFIII_metadata_line_30_____BNPPARIBAS_20260508 >									
	//        < QzNUXH5w6yMH4aOeSq9pK03qwqBTW22V1q0phGcU726DFY0klV97uF3S0h0tdaj0 >									
	//        <  u =="0.000000000000000001" : ] 000000318568850.508379000000000000 ; 000000329364837.660600000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DB36181EB8866 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_III_PFIII_metadata_line_31_____SOCIETE GENERALE  _20260508 >									
	//        < nXK7QN0EHGwCeor8AAePAgdBN4jf1fXmt5v771MqZ3Z4L5CoNyLhm1YQU8C06j5D >									
	//        <  u =="0.000000000000000001" : ] 000000329364837.660600000000000000 ; 000000340625134.889432000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EB88661FBDAFC >									
	//     < BANK_III_PFIII_metadata_line_32_____CREDIT_AGRICOLE_SA_20260508 >									
	//        < 3iU0pHBMa56VD08288WIuiYCiw84l2zM2VKd4KI64hYh74NXrT8OO4Tds10d6VD9 >									
	//        <  u =="0.000000000000000001" : ] 000000340625134.889432000000000000 ; 000000351415110.622187000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FBDAFC20C1905 >									
	//     < BANK_III_PFIII_metadata_line_33_____CREDIT_MUTUEL_20260508 >									
	//        < 4T8Z8577gicb9vcF1RI8E1p9OM9GqzyGm1pOpbXZrCCad1fNvA60HfDrZ3EP75Q6 >									
	//        <  u =="0.000000000000000001" : ] 000000351415110.622187000000000000 ; 000000362647803.871323000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020C190521C6953 >									
	//     < BANK_III_PFIII_metadata_line_34_____DEXIA_20260508 >									
	//        < 8F7z9mTgM5lYYHZj9WC416f6aD83a95B5MEFD7zAhErTVRGzNaWfvbaw41lea0S7 >									
	//        <  u =="0.000000000000000001" : ] 000000362647803.871323000000000000 ; 000000373410232.898122000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021C695322CFE3E >									
	//     < BANK_III_PFIII_metadata_line_35_____CREDIT_INDUSTRIEL_COMMERCIAL_20260508 >									
	//        < Xf0Wm7cB16vQohVHEM14SPNV80tY8R19M4gRMlbXVt6PaiG8oVkM28r97nZ8Sx97 >									
	//        <  u =="0.000000000000000001" : ] 000000373410232.898122000000000000 ; 000000384308555.880306000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022CFE3E23DA8C0 >									
	//     < BANK_III_PFIII_metadata_line_36_____SANTANDER_20260508 >									
	//        < l30I5WJZtEX5GzBT96TRjqi1uQe4pTxlcfSY1i6HVhliXy6lT3W0U20tj2lVH48j >									
	//        <  u =="0.000000000000000001" : ] 000000384308555.880306000000000000 ; 000000395359785.155537000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023DA8C024DEC3C >									
	//     < BANK_III_PFIII_metadata_line_37_____CREDIT_LYONNAIS_20260508 >									
	//        < zRwKvHirQOnrL88Tt0g7Q2KL93VUF4M1VycxSWH7RgAjbqr12wH56hV8L9dTSv7M >									
	//        <  u =="0.000000000000000001" : ] 000000395359785.155537000000000000 ; 000000406642878.440244000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024DEC3C25E7918 >									
	//     < BANK_III_PFIII_metadata_line_38_____BANQUES_POPULAIRES_20260508 >									
	//        < 5hOJzbJ293jp563j683e2WKrd61KbffulSCHY8k37179k52soLqJbM8343wm2Soj >									
	//        <  u =="0.000000000000000001" : ] 000000406642878.440244000000000000 ; 000000417436730.925981000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025E791826E8F68 >									
	//     < BANK_III_PFIII_metadata_line_39_____CAISSES_D_EPARGNE_20260508 >									
	//        < 411Ai2kpMChk7MJ77o9jhpJaqM2308oXoQ5BUkx4OwfKSwF7Bc2pm7Fk20Ml7hpH >									
	//        <  u =="0.000000000000000001" : ] 000000417436730.925981000000000000 ; 000000428379573.136908000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026E8F6827EC730 >									
	//     < BANK_III_PFIII_metadata_line_40_____LAZARD_20260508 >									
	//        < Vv6gZ82Ufiey7Bx0b4NqheoS12r6h60hZZ1t9Ixr67yp9yH89EE953wS4AT2X2nr >									
	//        <  u =="0.000000000000000001" : ] 000000428379573.136908000000000000 ; 000000439201543.085926000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027EC73028F0A40 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
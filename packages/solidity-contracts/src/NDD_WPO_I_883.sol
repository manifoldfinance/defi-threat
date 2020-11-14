/**
 * Source Code first verified at https://etherscan.io on Friday, March 29, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	NDD_WPO_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_WPO_I_883		"	;
		string	public		symbol =	"	NDD_WPO_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		14361998474065300000000000000					;	
										
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
	//     < NDD_WPO_I_metadata_line_1_____6938413225 Lab_x >									
	//        < Ch8bAyBpl1Q88dGE5F5y4228c891tsR0JA9g2wCVYpR2YErJz4LUBWJ56hFy8COg >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_WPO_I_metadata_line_2_____9781285179 Lab_y >									
	//        < FtMk2S9lEB7K3rMTU3m3YauHU3Ju5TfZ32R243H2rvPoiWGV5nBem75Alxn2xMLr >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_WPO_I_metadata_line_3_____2305931084 Lab_100 >									
	//        < cLF1tLxwfy0U857e1hlms8RMav8eX83P3jvd91pAY2bAEGtyB6pzGAyBnqAthVx2 >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000030775023.680447400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802EF57E >									
	//     < NDD_WPO_I_metadata_line_4_____2336106424 Lab_110 >									
	//        < I112CCR20qXuTel2Va94h49E3p1B2dQ895KwTl62EBj4UdRl7h76k9Tuir7AOyM7 >									
	//        <  u =="0.000000000000000001" : ] 000000030775023.680447400000000000 ; 000000042277400.877023100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002EF57E40829C >									
	//     < NDD_WPO_I_metadata_line_5_____2302995628 Lab_410/401 >									
	//        < gM3KIQw6V5HdN2g4PaSa28uRJHUPXrqUPu4DuhJn5g8dC2GOU7602381Q0Mf1uTA >									
	//        <  u =="0.000000000000000001" : ] 000000042277400.877023100000000000 ; 000000058286909.663325800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000040829C58F053 >									
	//     < NDD_WPO_I_metadata_line_6_____1177871193 Lab_810/801 >									
	//        < UB4b13UD15E9f5U8Z5Gb4pG3sHbQ71q4gq29LOPOZvf23VlenjdQUcr9nvlcQen4 >									
	//        <  u =="0.000000000000000001" : ] 000000058286909.663325800000000000 ; 000000080305927.235931500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000058F0537A8981 >									
	//     < NDD_WPO_I_metadata_line_7_____2360571371 Lab_410_3Y1Y >									
	//        < uRUCPlG6Na2DG78Iwly8z2xSyWmxSUqb56E24b5nfg688VRd15Hd69Sa01i9N0SC >									
	//        <  u =="0.000000000000000001" : ] 000000080305927.235931500000000000 ; 000000109234553.104016000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007A8981A6ADBF >									
	//     < NDD_WPO_I_metadata_line_8_____2333944175 Lab_410_5Y1Y >									
	//        < 6gTGa8L4897js2hNmypBznUSLdM6WGFuoZr5d2dgVRYMfR6qIVCkp6cEK0nh4DHb >									
	//        <  u =="0.000000000000000001" : ] 000000109234553.104016000000000000 ; 000000170614646.378964000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000A6ADBF1045659 >									
	//     < NDD_WPO_I_metadata_line_9_____2357011486 Lab_410_7Y1Y >									
	//        < Uz4WsPD5J6eavjaYb37JCVIOi9EaJFmr4gvbTzxWoY4So0M00MOy3n6sSTskW0a4 >									
	//        <  u =="0.000000000000000001" : ] 000000170614646.378964000000000000 ; 000000331200379.290253000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010456591F95F26 >									
	//     < NDD_WPO_I_metadata_line_10_____2349320802 Lab_810_3Y1Y >									
	//        < 97T4n9Pf3O7d1aNSMPX9IGqk2gseb4Tyol39Tey2g4k3t5i7dA2s0zBTkwe2R904 >									
	//        <  u =="0.000000000000000001" : ] 000000331200379.290253000000000000 ; 000000391934799.774427000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F95F262560B88 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_WPO_I_metadata_line_11_____1109473397 Lab_810_5Y1Y >									
	//        < 3nnoy265xVk41Uz0I7D0vJWRaAFIAv952l4xyL50IBVtKm73lcmiDQ8HERqGEXyE >									
	//        <  u =="0.000000000000000001" : ] 000000391934799.774427000000000000 ; 000000743894537.941454000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002560B8846F17CE >									
	//     < NDD_WPO_I_metadata_line_12_____1136946763 Lab_810_7Y1Y >									
	//        < cbDq61xZx1l7BHtTv2tj4BDma4eNq70Jt93Dm7X2C22OFME82LW2rcy92wMjK2s2 >									
	//        <  u =="0.000000000000000001" : ] 000000743894537.941454000000000000 ; 000002919393879.916440000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000046F17CE1166A43C >									
	//     < NDD_WPO_I_metadata_line_13_____2370723856 ro_Lab_110_3Y_1.00 >									
	//        < 2uLK0Wlgu5493xpJO5EfMLq67osx6QLQK7ImWKauHLIXDeVQw3W5e6Bev2eJGCr7 >									
	//        <  u =="0.000000000000000001" : ] 000002919393879.916440000000000000 ; 000002940498267.467610000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000001166A43C1186D823 >									
	//     < NDD_WPO_I_metadata_line_14_____2377733157 ro_Lab_110_5Y_1.00 >									
	//        < WqHz2lN009RXhh66XN60T1EYX8587TDU1XtN8SG9xOLjuPx8OHKJ92L166EFvKu7 >									
	//        <  u =="0.000000000000000001" : ] 000002940498267.467610000000000000 ; 000002965646714.301980000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000001186D82311AD37BF >									
	//     < NDD_WPO_I_metadata_line_15_____2386350653 ro_Lab_110_5Y_1.10 >									
	//        < uCin3lrv3OMxdlNU1USjF7BKvJU5Jjv62FGkZ5T00bKtT330AS0yj32mTe8P4O61 >									
	//        <  u =="0.000000000000000001" : ] 000002965646714.301980000000000000 ; 000002991767561.113150000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000011AD37BF11D51334 >									
	//     < NDD_WPO_I_metadata_line_16_____2335739207 ro_Lab_110_7Y_1.00 >									
	//        < IWKTHFKH1MudkNVg8J7F7rDe6VOYn5hS6536Usp1Pk1RT01JwzsKMeyt1obIRD2a >									
	//        <  u =="0.000000000000000001" : ] 000002991767561.113150000000000000 ; 000003022245609.630570000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000011D51334120394B1 >									
	//     < NDD_WPO_I_metadata_line_17_____2308301996 ro_Lab_210_3Y_1.00 >									
	//        < 375z52869efmLYOWZs3jcA3r87BD0V4VuK2RnQwh13ee2rh41WB0BMxk04E2eiUm >									
	//        <  u =="0.000000000000000001" : ] 000003022245609.630570000000000000 ; 000003033679009.297720000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000120394B1121506DD >									
	//     < NDD_WPO_I_metadata_line_18_____2306387764 ro_Lab_210_5Y_1.00 >									
	//        < W0h4L533G8pVdT4M965Fe4EQ2ItCRaC35y9deR7XCxpA21exVqGcEi5ZI0kL94MS >									
	//        <  u =="0.000000000000000001" : ] 000003033679009.297720000000000000 ; 000003047686209.922170000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000121506DD122A666D >									
	//     < NDD_WPO_I_metadata_line_19_____2307878945 ro_Lab_210_5Y_1.10 >									
	//        < 0wRHo5ChdLHXLGhQlkt7B9j1OIn17Axm74P4Lac760Eq7OiwAVv472kM70oth1tL >									
	//        <  u =="0.000000000000000001" : ] 000003047686209.922170000000000000 ; 000003060565766.315970000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000122A666D123E0D81 >									
	//     < NDD_WPO_I_metadata_line_20_____2398186189 ro_Lab_210_7Y_1.00 >									
	//        < s8408H2J4Cmfm69m4K315q9dLnoLha71KhSFG84oqk20f25X13oY0QAu46vqDocC >									
	//        <  u =="0.000000000000000001" : ] 000003060565766.315970000000000000 ; 000003080865867.232110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000123E0D81125D073B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_WPO_I_metadata_line_21_____2307291005 ro_Lab_310_3Y_1.00 >									
	//        < fk1287J77H6S64CR02Tm1N5BsJej5Y483V1dp217d0BscpnAVH8FddHKTrgKlwUa >									
	//        <  u =="0.000000000000000001" : ] 000003080865867.232110000000000000 ; 000003092708808.098520000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000125D073B126F1961 >									
	//     < NDD_WPO_I_metadata_line_22_____2398082268 ro_Lab_310_5Y_1.00 >									
	//        < 1b10dmEvWCu0kXBzP50W186t46Lkv05Z7ppjRqNYl5UhR382Uu4sTs0m7rw6x4YA >									
	//        <  u =="0.000000000000000001" : ] 000003092708808.098520000000000000 ; 000003108847412.857590000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000126F19611287B985 >									
	//     < NDD_WPO_I_metadata_line_23_____2306887002 ro_Lab_310_5Y_1.10 >									
	//        < 0ztN7mqmt5UdQvh56o5tBKvPT40nc15VTG48CF3C16NBV97i5Fsi8jSk7J11t6Bd >									
	//        <  u =="0.000000000000000001" : ] 000003108847412.857590000000000000 ; 000003122731194.007580000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000001287B985129CE8DF >									
	//     < NDD_WPO_I_metadata_line_24_____2379919859 ro_Lab_310_7Y_1.00 >									
	//        < Uwq6unTfs4mf5Y5xSWFMf70WE2d46AN7xYoHDXpzfsxqXy23223k3G6nqG6RWKz6 >									
	//        <  u =="0.000000000000000001" : ] 000003122731194.007580000000000000 ; 000003152334905.283890000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000129CE8DF12CA14D3 >									
	//     < NDD_WPO_I_metadata_line_25_____2305867658 ro_Lab_410_3Y_1.00 >									
	//        < I6d3jnL07lRlE73XOoce362OZEQ7jmau9AJMva9YJu6t908hHMxQFaQ9x9LiRxJk >									
	//        <  u =="0.000000000000000001" : ] 000003152334905.283890000000000000 ; 000003164658380.288350000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000012CA14D312DCE2AE >									
	//     < NDD_WPO_I_metadata_line_26_____2389901653 ro_Lab_410_5Y_1.00 >									
	//        < A58o2c3ilUvEDt4Oh05p08v8paD227qi8fRUaRRsf9Em45MAG5kQ3209ah9J6dou >									
	//        <  u =="0.000000000000000001" : ] 000003164658380.288350000000000000 ; 000003183741415.258670000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000012DCE2AE12FA00FE >									
	//     < NDD_WPO_I_metadata_line_27_____2304479669 ro_Lab_410_5Y_1.10 >									
	//        < 364FZj41855z8ep8982fL2bocoU75Uw5mfBGe9XfIg51v3cztbeh1vG0yZ80P4sH >									
	//        <  u =="0.000000000000000001" : ] 000003183741415.258670000000000000 ; 000003199015921.757920000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000012FA00FE13114F98 >									
	//     < NDD_WPO_I_metadata_line_28_____2374072459 ro_Lab_410_7Y_1.00 >									
	//        < jrC3Y2a6cE5LlT9JMlcg1PjBNLPL5CC54k460p2a05NNeH7ub0V4G17f6Y5n08wz >									
	//        <  u =="0.000000000000000001" : ] 000003199015921.757920000000000000 ; 000003244238202.109910000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000013114F981356508C >									
	//     < NDD_WPO_I_metadata_line_29_____2395974887 ro_Lab_810_3Y_1.00 >									
	//        < 097C34457cK9dh7961VXg07G35AY3hVt7DZh2R2Iq59dtF2wd3Vtn9U11lLfdcoU >									
	//        <  u =="0.000000000000000001" : ] 000003244238202.109910000000000000 ; 000003259099820.241950000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000001356508C136CFDDE >									
	//     < NDD_WPO_I_metadata_line_30_____2333639033 ro_Lab_810_5Y_1.00 >									
	//        < 41PfD7JCz7m9NmwWbNjGx1qr0Ts1Cqzv86u92RhrB7eo2vJc59FPocyycyl2Yc0l >									
	//        <  u =="0.000000000000000001" : ] 000003259099820.241950000000000000 ; 000003319733596.021030000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000136CFDDE13C982F0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_WPO_I_metadata_line_31_____2370562342 ro_Lab_810_5Y_1.10 >									
	//        < 1nVetxfLZd2H5SS2hXhqF5ZdNadCV6okt631I60804c0r6WDk7N194XfN2Z7a467 >									
	//        <  u =="0.000000000000000001" : ] 000003319733596.021030000000000000 ; 000003354769811.573900000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000013C982F013FEF8F5 >									
	//     < NDD_WPO_I_metadata_line_32_____2313201691 ro_Lab_810_7Y_1.00 >									
	//        < s0igM65nhuS8x2Tv1U7q3f2Cx49yCC8vAeYEU7A9o5UVzB8mpKMKeT8pOXR6ggNR >									
	//        <  u =="0.000000000000000001" : ] 000003354769811.573900000000000000 ; 000003811415404.127030000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000013FEF8F516B7C224 >									
	//     < NDD_WPO_I_metadata_line_33_____2379793388 ro_Lab_411_3Y_1.00 >									
	//        < 9y99AN711u681CmnL1g289525JQIisaJOR4Z602ypf5ASpmfdDeE6ePy8Ubs5209 >									
	//        <  u =="0.000000000000000001" : ] 000003811415404.127030000000000000 ; 000003827090814.603060000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000016B7C22416CFAD59 >									
	//     < NDD_WPO_I_metadata_line_34_____2383832498 ro_Lab_411_5Y_1.00 >									
	//        < XL7tKvvfYd8VRXjk789Ar5jOVf26WobsgTgrvg6b7p4QcfL34f56j7aVsU5PRX8S >									
	//        <  u =="0.000000000000000001" : ] 000003827090814.603060000000000000 ; 000003877845740.731130000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000016CFAD59171D1F7E >									
	//     < NDD_WPO_I_metadata_line_35_____2374475665 ro_Lab_411_5Y_1.10 >									
	//        < j0samu1N5MkEPcJP5MhJR4Kx2Xg4Zoudmt9gCZW0pF0l7pS3L21wisU5ODh7Y75u >									
	//        <  u =="0.000000000000000001" : ] 000003877845740.731130000000000000 ; 000003908174621.122980000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000171D1F7E174B66B6 >									
	//     < NDD_WPO_I_metadata_line_36_____2313061614 ro_Lab_411_7Y_1.00 >									
	//        < 4gO9CMqIC7Ce3Z9V34rG0Qu1rjKg9CfT7494KI9UoS83TCmAYmzYsbsAhDpaeBTl >									
	//        <  u =="0.000000000000000001" : ] 000003908174621.122980000000000000 ; 000004354732021.031110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000174B66B619F4CB32 >									
	//     < NDD_WPO_I_metadata_line_37_____2383330997 ro_Lab_811_3Y_1.00 >									
	//        < c72z3Aj5GN75YsuLq67V9pyxCUzbhIwjdcT0NWl8l6AZxY4maQ1a88H1GeB2ScOV >									
	//        <  u =="0.000000000000000001" : ] 000004354732021.031110000000000000 ; 000004381259354.021890000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000019F4CB321A1D456F >									
	//     < NDD_WPO_I_metadata_line_38_____1109692800 ro_Lab_811_5Y_1.00 >									
	//        < 08Pn5iuwHPqlSLZG9gTYW1c8A23dynd8mg5P74I51VQp4JcoR2Mo2Inj75p8ToIv >									
	//        <  u =="0.000000000000000001" : ] 000004381259354.021890000000000000 ; 000004728534535.544740000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000001A1D456F1C2F2BCE >									
	//     < NDD_WPO_I_metadata_line_39_____2392521527 ro_Lab_811_5Y_1.10 >									
	//        < 87hm6B30SL5673dsm5tgK64UQJ15iL7RuyoN74BSmZMax87n2ZROQQzlGOT5r1kp >									
	//        <  u =="0.000000000000000001" : ] 000004728534535.544740000000000000 ; 000004900048868.072400000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000001C2F2BCE1D34E197 >									
	//     < NDD_WPO_I_metadata_line_40_____1116364858 ro_Lab_811_7Y_1.00 >									
	//        < eb993q0U73P01Ej2KtlB4hh1Tqn71gXJyFi8RbPYntgq6sz1rO8XCQwc85Cq2V71 >									
	//        <  u =="0.000000000000000001" : ] 000004900048868.072400000000000000 ; 000014361998474.065300000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000001D34E197559AABA7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
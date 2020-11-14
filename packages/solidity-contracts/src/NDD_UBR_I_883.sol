/**
 * Source Code first verified at https://etherscan.io on Friday, March 29, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	NDD_UBR_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_UBR_I_883		"	;
		string	public		symbol =	"	NDD_UBR_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		7850358149730020000000000000					;	
										
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
	//     < NDD_UBR_I_metadata_line_1_____6938413225 Lab_x >									
	//        < VDPg7o9FLWQ2Q1PdnOsBG7XK31O6oSQM6kg6MJbI69466T8jHVpsLjg0GJCEXa7Y >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_UBR_I_metadata_line_2_____9781285179 Lab_y >									
	//        < IlhC200Pc1Ytzjn6At5WilYu40ODTEY0D4vwKuIZHlMoFooQ5XoGz3j8B55Lvj29 >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_UBR_I_metadata_line_3_____2305752577 Lab_100 >									
	//        < cIr47RO5J45krJFt1Ro8mKHd0uo8G82344z17l982TFdB6BOYWh0q4X1f2e2isj2 >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000030723622.035422700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802EE16A >									
	//     < NDD_UBR_I_metadata_line_4_____2389593638 Lab_110 >									
	//        < tcxh9Dp4f914ZWDY760q22b6tDwK2fy3A69VFr7Bl78iJlR6213cen9cu7Z2BaO2 >									
	//        <  u =="0.000000000000000001" : ] 000000030723622.035422700000000000 ; 000000042067781.782617800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002EE16A4030BA >									
	//     < NDD_UBR_I_metadata_line_5_____2353921981 Lab_410/401 >									
	//        < ogC3rHtG0GMC8lxQ6WzLRfzg7dm44s1CjsdCxO5245s94slhbN61udzYhM05X5xh >									
	//        <  u =="0.000000000000000001" : ] 000000042067781.782617800000000000 ; 000000057444420.771398400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004030BA57A73A >									
	//     < NDD_UBR_I_metadata_line_6_____1105537190 Lab_810/801 >									
	//        < 867EtuuR3YdlM8Q832Mp1zKt5FZF9Q22k6eaA3qr3I7UJ3d0l8o7X7hCGP0oyZ07 >									
	//        <  u =="0.000000000000000001" : ] 000000057444420.771398400000000000 ; 000000078197698.748959600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000057A73A7751FA >									
	//     < NDD_UBR_I_metadata_line_7_____2384899895 Lab_410_3Y1Y >									
	//        < TQ77y9gtyjEd1jo268vr3SCdgp8DR4U8I92534ex42GNX20QkSIjR0IXzvq50J9z >									
	//        <  u =="0.000000000000000001" : ] 000000078197698.748959600000000000 ; 000000103425025.854175000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007751FA9DD067 >									
	//     < NDD_UBR_I_metadata_line_8_____2358446042 Lab_410_5Y1Y >									
	//        < BM1615z6MeHeWU473zia2HZ0laFh7wpl1qb1ZC1sA01fWLky9qQ7Z9797YvLFKgH >									
	//        <  u =="0.000000000000000001" : ] 000000103425025.854175000000000000 ; 000000171796787.663174000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000009DD067106241F >									
	//     < NDD_UBR_I_metadata_line_9_____2357288457 Lab_410_7Y1Y >									
	//        < 37atH5ebpAwdz5Bt5NjsQ2aFcHAB42yEXClq5CwiaH9XtDrQqrYM8i52Ze5Je7mq >									
	//        <  u =="0.000000000000000001" : ] 000000171796787.663174000000000000 ; 000000333875068.504687000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000106241F1FD73F3 >									
	//     < NDD_UBR_I_metadata_line_10_____2314238363 Lab_810_3Y1Y >									
	//        < yMCl4Q0R739Ju9SZ0XObLA7Gg0OPJ8y0VOAEBW7jDG49F9w60MV6utTJEArcjsQC >									
	//        <  u =="0.000000000000000001" : ] 000000333875068.504687000000000000 ; 000000383008397.542487000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FD73F32486CA8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_UBR_I_metadata_line_11_____2346792120 Lab_810_5Y1Y >									
	//        < b7n346UVcXT45hhG06nImthPa9s31VadOeKcXQ64jp93emOLp3iH0CNdjupmI73l >									
	//        <  u =="0.000000000000000001" : ] 000000383008397.542487000000000000 ; 000000600682004.683431000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002486CA83949168 >									
	//     < NDD_UBR_I_metadata_line_12_____1123170650 Lab_810_7Y1Y >									
	//        < qa1j1qt7k7DqbDY6WI1vU3k3nBV48JM2NfI97E1WJb7Bthex0z352uG4vt76GD4p >									
	//        <  u =="0.000000000000000001" : ] 000000600682004.683431000000000000 ; 000001910118616.226260000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003949168B629C16 >									
	//     < NDD_UBR_I_metadata_line_13_____2371670348 ro_Lab_110_3Y_1.00 >									
	//        < 09C5q8nRyIzpmlm0UbFNm0DFU187BEalSo9FM46DZdm6ROi4VCyt006zW0XrSm4K >									
	//        <  u =="0.000000000000000001" : ] 000001910118616.226260000000000000 ; 000001930755673.109090000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B629C16B82196F >									
	//     < NDD_UBR_I_metadata_line_14_____2377928707 ro_Lab_110_5Y_1.00 >									
	//        < 5dak9zi3q9gfX92VQd2leGsRBbPor1raoZoD33I2D98e7vKzAVHDCS3zL6B3e4s6 >									
	//        <  u =="0.000000000000000001" : ] 000001930755673.109090000000000000 ; 000001956438911.954030000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B82196FBA949F3 >									
	//     < NDD_UBR_I_metadata_line_15_____2386167674 ro_Lab_110_5Y_1.10 >									
	//        < zg8l2vU3818g552aEdVg2tXX16nBTkk50Tc4YA7yNKwCd0JXKnO7awLAut22694P >									
	//        <  u =="0.000000000000000001" : ] 000001956438911.954030000000000000 ; 000001983093917.070350000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000BA949F3BD1F610 >									
	//     < NDD_UBR_I_metadata_line_16_____2335693676 ro_Lab_110_7Y_1.00 >									
	//        < ZvEF4DpysYbtGc2bc9OJ15kCn4QpMaGIyDk49tDW5lmwHNq91lKJ024v0N2F5B3w >									
	//        <  u =="0.000000000000000001" : ] 000001983093917.070350000000000000 ; 000002013633729.673030000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000BD1F610C008FAD >									
	//     < NDD_UBR_I_metadata_line_17_____2308759671 ro_Lab_210_3Y_1.00 >									
	//        < xgK5yNpKq6ge90Tk27P0am32f9r0O012QYd2VKSgTTYkqF7lzXzp416BXUBSG6d7 >									
	//        <  u =="0.000000000000000001" : ] 000002013633729.673030000000000000 ; 000002024957565.358630000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C008FADC11D70D >									
	//     < NDD_UBR_I_metadata_line_18_____2305641089 ro_Lab_210_5Y_1.00 >									
	//        < KI9S334h5l0gg5Et5910uACLqI4LoSV8h68A95AV2gp6Qb43n6mGgxm10fIxvW2x >									
	//        <  u =="0.000000000000000001" : ] 000002024957565.358630000000000000 ; 000002039227404.454680000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C11D70DC279D34 >									
	//     < NDD_UBR_I_metadata_line_19_____2307637375 ro_Lab_210_5Y_1.10 >									
	//        < f1C628wHk1cuvu3eq5sY0D48dS0HCs0N8xRGv22FMy23sIt8oRxRQick41wMl74g >									
	//        <  u =="0.000000000000000001" : ] 000002039227404.454680000000000000 ; 000002052230567.881720000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C279D34C3B7491 >									
	//     < NDD_UBR_I_metadata_line_20_____2398159093 ro_Lab_210_7Y_1.00 >									
	//        < UYLuZQ6FL609o1y6XhDsS82qAAfra2LK2O7587ih700B76FkoB2Oc51lVjb394wg >									
	//        <  u =="0.000000000000000001" : ] 000002052230567.881720000000000000 ; 000002072587068.238330000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C3B7491C5A8453 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_UBR_I_metadata_line_21_____2307763201 ro_Lab_310_3Y_1.00 >									
	//        < 3RKMb3Ory3aF3jiyTcC22AYYri8u8UDy6qTo3OZ7k543GKswEAx7CO3M29C5OpQ9 >									
	//        <  u =="0.000000000000000001" : ] 000002072587068.238330000000000000 ; 000002084237752.745480000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C5A8453C6C4B5F >									
	//     < NDD_UBR_I_metadata_line_22_____2398900229 ro_Lab_310_5Y_1.00 >									
	//        < nTOKK6CUohU04vc70T69KWTa403B12FMtYjXo4Ew55t3XKh7o64nCe9eHpRjxaWx >									
	//        <  u =="0.000000000000000001" : ] 000002084237752.745480000000000000 ; 000002100934119.942440000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C6C4B5FC85C564 >									
	//     < NDD_UBR_I_metadata_line_23_____2305785832 ro_Lab_310_5Y_1.10 >									
	//        < fPeTW88WAVpNUsGHd4kLF33QN91571e0z7nszc1nRVVeK0tI6n5tF13rnMzTeMrK >									
	//        <  u =="0.000000000000000001" : ] 000002100934119.942440000000000000 ; 000002115081072.113380000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C85C564C9B5B8B >									
	//     < NDD_UBR_I_metadata_line_24_____2379466748 ro_Lab_310_7Y_1.00 >									
	//        < k8Ydd7WZzDr3fDPXYxesoNB51T67JE4FwRzO9by9444FZKgLUMRiRAhLYSlm2lD4 >									
	//        <  u =="0.000000000000000001" : ] 000002115081072.113380000000000000 ; 000002144830857.821820000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C9B5B8BCC8C08E >									
	//     < NDD_UBR_I_metadata_line_25_____2306852274 ro_Lab_410_3Y_1.00 >									
	//        < qgzU1BIU2FgOQzza2cvyXPXsX4UKyJ2KI511iip96Mb1W8J2hCyGfJKN3JJ5Fy13 >									
	//        <  u =="0.000000000000000001" : ] 000002144830857.821820000000000000 ; 000002156857935.283810000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000CC8C08ECDB1AA2 >									
	//     < NDD_UBR_I_metadata_line_26_____2395370757 ro_Lab_410_5Y_1.00 >									
	//        < W7pVIKeDL76EqQGhCEt1nsvW27gcFlaM4VDQMSplnZYcrSEHgH73w2adqLEbdNvH >									
	//        <  u =="0.000000000000000001" : ] 000002156857935.283810000000000000 ; 000002176963242.885850000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000CDB1AA2CF9C844 >									
	//     < NDD_UBR_I_metadata_line_27_____2399547869 ro_Lab_410_5Y_1.10 >									
	//        < 24Iekh5f8X7SywK4Q7yqpQ03bvx7Lrp6UTo9dEhCT7v9iCu6m9Rva28klGU3ccMY >									
	//        <  u =="0.000000000000000001" : ] 000002176963242.885850000000000000 ; 000002192721327.961350000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000CF9C844D11D3C5 >									
	//     < NDD_UBR_I_metadata_line_28_____2374787624 ro_Lab_410_7Y_1.00 >									
	//        < Znu0i8MyFtWUhv4X6EG2V6czhARRiFKgadJNJ5Uh7F8Z3Rz1cnVgF2h1ChqY4471 >									
	//        <  u =="0.000000000000000001" : ] 000002192721327.961350000000000000 ; 000002238263863.494620000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000D11D3C5D5751D2 >									
	//     < NDD_UBR_I_metadata_line_29_____2397147504 ro_Lab_810_3Y_1.00 >									
	//        < DWcmK1UCAmsCJ9B0540S5M4T4XFJqjQC3m772Fh9H8C7T7sd3dY6jhicl9Ne0qDT >									
	//        <  u =="0.000000000000000001" : ] 000002238263863.494620000000000000 ; 000002252201413.590630000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000D5751D2D6C962D >									
	//     < NDD_UBR_I_metadata_line_30_____2334372075 ro_Lab_810_5Y_1.00 >									
	//        < 2SlcS54MqSzD1y8RPym7Ns91IthDYgh54LW0XWifx4C3P4kCPP796B3myCbtiU1x >									
	//        <  u =="0.000000000000000001" : ] 000002252201413.590630000000000000 ; 000002293811144.882970000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000D6C962DDAC13FA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_UBR_I_metadata_line_31_____2386098461 ro_Lab_810_5Y_1.10 >									
	//        < QlWI7hKHRxTD45dN2SiNgc5rcyZ9rmIYU5dYc0BBV4Z6V63XA5dnFn0D0OGOLUV3 >									
	//        <  u =="0.000000000000000001" : ] 000002293811144.882970000000000000 ; 000002319784646.567860000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000DAC13FADD3B5E1 >									
	//     < NDD_UBR_I_metadata_line_32_____2320792042 ro_Lab_810_7Y_1.00 >									
	//        < YiipP1mpSCRccs4zFA67J9mG8gtesjVYS43F99Y4d5z7V97vtb8KtC6uD4bpc1T2 >									
	//        <  u =="0.000000000000000001" : ] 000002319784646.567860000000000000 ; 000002602219056.574100000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000DD3B5E1F82ABD2 >									
	//     < NDD_UBR_I_metadata_line_33_____2396336880 ro_Lab_411_3Y_1.00 >									
	//        < zOz54JYBgZky4V5m648dAs9lG9M5178Hq0VhRG5HZBMxx97Jh47O828cven5REzP >									
	//        <  u =="0.000000000000000001" : ] 000002602219056.574100000000000000 ; 000002616431951.250210000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000F82ABD2F985BBB >									
	//     < NDD_UBR_I_metadata_line_34_____2384333324 ro_Lab_411_5Y_1.00 >									
	//        < ZMDJArC683Q86595cWHbi2XDoH8qI926iBuDqBvZyARuDt8o0Y4WQb9NJ2OXG3d1 >									
	//        <  u =="0.000000000000000001" : ] 000002616431951.250210000000000000 ; 000002663705583.771210000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000F985BBBFE07DFE >									
	//     < NDD_UBR_I_metadata_line_35_____2375598105 ro_Lab_411_5Y_1.10 >									
	//        < 2Jh58fEAh9hjZi389LOSx683F4qQ8L9NQ71d4yv5nBi9OD8W63G8ygP78d23jNE7 >									
	//        <  u =="0.000000000000000001" : ] 000002663705583.771210000000000000 ; 000002692376149.397790000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000FE07DFE100C3D6F >									
	//     < NDD_UBR_I_metadata_line_36_____2352148762 ro_Lab_411_7Y_1.00 >									
	//        < hxQo615NMln3XMbDMjco5a89xzbY3A8Y9yU2Q9Gz9ddR3722l44Huc061x8TdSXX >									
	//        <  u =="0.000000000000000001" : ] 000002692376149.397790000000000000 ; 000002904441800.145360000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000100C3D6F114FD394 >									
	//     < NDD_UBR_I_metadata_line_37_____2334589634 ro_Lab_811_3Y_1.00 >									
	//        < L01hm7771dLT2bFT6GxwksJSq3DRBhO57C6T8Bo1O8iY3G436O4X30V15Gt6U9PC >									
	//        <  u =="0.000000000000000001" : ] 000002904441800.145360000000000000 ; 000002927683418.892490000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000114FD39411734A56 >									
	//     < NDD_UBR_I_metadata_line_38_____2391195716 ro_Lab_811_5Y_1.00 >									
	//        < WZPc2Zi8246JUifUn045k4TMHd17gB7GkmNB15549F6K8dX6EAul2tHFm332Sb3h >									
	//        <  u =="0.000000000000000001" : ] 000002927683418.892490000000000000 ; 000003104548082.330690000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000011734A5612812A18 >									
	//     < NDD_UBR_I_metadata_line_39_____2351669685 ro_Lab_811_5Y_1.10 >									
	//        < B2G7VCit2n55g790coz143SwoS9Sz37c1XTWv37Vz3hpooyuRT15j41JMIK0Hw9I >									
	//        <  u =="0.000000000000000001" : ] 000003104548082.330690000000000000 ; 000003194974217.395510000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000012812A18130B24CE >									
	//     < NDD_UBR_I_metadata_line_40_____1162557820 ro_Lab_811_7Y_1.00 >									
	//        < hn9sW0QUxiRiJT24LX6D07y0b814zJXlV1H300v0RfjiNrNAsyk7PeL3z1irtk7i >									
	//        <  u =="0.000000000000000001" : ] 000003194974217.395510000000000000 ; 000007850358149.730020000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000130B24CE2ECAB227 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	BANK_IV_PFIII_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	BANK_IV_PFIII_883		"	;
		string	public		symbol =	"	BANK_IV_PFIII_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		437259067042976000000000000					;	
										
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
	//     < BANK_IV_PFIII_metadata_line_1_____AGRICULTURAL DEVELOPMENT BANK OF CHINA_20260508 >									
	//        < W21OAQa4Bu6UjBXkk8s1vc4T2Ap0Z9j6lvWR683nnP2eo54zN3yQ61X00p1v810P >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010783181.592286500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000010742E >									
	//     < BANK_IV_PFIII_metadata_line_2_____CHINA DEVELOMENT BANK_20260508 >									
	//        < 34prJoZ2dQiXya45h4f7F4Fxc8lH93Bm6b7rJSlhQy1VDmcX362ID3mBsSf6th1I >									
	//        <  u =="0.000000000000000001" : ] 000000010783181.592286500000000000 ; 000000022044587.846776300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000010742E21A32B >									
	//     < BANK_IV_PFIII_metadata_line_3_____EXIM BANK OF CHINA_20260508 >									
	//        < jz7z4Pt4uD1jlTL60G02ZLia5NeJiZB5ypKldCr618qRWKl5J40D4W1oi0390a41 >									
	//        <  u =="0.000000000000000001" : ] 000000022044587.846776300000000000 ; 000000033209526.799744800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000021A32B32AC79 >									
	//     < BANK_IV_PFIII_metadata_line_4_____CHINA MERCHANT BANK_20260508 >									
	//        < 50E6yp3ZKw7No0o2D048uPmTiD0v5HcQLljjHM0vp73IA2Uv361K4UEg2P7oL90c >									
	//        <  u =="0.000000000000000001" : ] 000000033209526.799744800000000000 ; 000000044075257.001588500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000032AC794340E6 >									
	//     < BANK_IV_PFIII_metadata_line_5_____SHANGHAI PUDONG DEVELOPMENT BANK_20260508 >									
	//        < nvw2X66PDlR4P1Kg2U90hK44oGq6lWeTmSwQqY733D97O9F2U64mx0s5vw4GFC0n >									
	//        <  u =="0.000000000000000001" : ] 000000044075257.001588500000000000 ; 000000055097793.481378100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004340E6541293 >									
	//     < BANK_IV_PFIII_metadata_line_6_____INDUSTRIAL BANK_20260508 >									
	//        < l7Ap3lhndFa79dHDQ3iN1y49pT89aKz7qKC70Wzxjm9095votm88QZ9WREPNM8SB >									
	//        <  u =="0.000000000000000001" : ] 000000055097793.481378100000000000 ; 000000066186904.147157700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000054129364FE42 >									
	//     < BANK_IV_PFIII_metadata_line_7_____CHINA CITIC BANK_20260508 >									
	//        < LWYKU7c78Vsyk479GPz67ZrbMgITrnUQ3C3u8lE0x5DEq2es2daEY4T2r73BFU0Y >									
	//        <  u =="0.000000000000000001" : ] 000000066186904.147157700000000000 ; 000000077387300.092915400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000064FE4276156A >									
	//     < BANK_IV_PFIII_metadata_line_8_____CHINA MINSHENG BANK_20260508 >									
	//        < j74E4O8n8Ky5wNghIeKfaE40dHpIQJoF4E14q2589tY7y28SlrEtp8x0QnxlDaGx >									
	//        <  u =="0.000000000000000001" : ] 000000077387300.092915400000000000 ; 000000088251161.873500400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000076156A86A91C >									
	//     < BANK_IV_PFIII_metadata_line_9_____CHINA EVERBRIGHT BANK_20260508 >									
	//        < Ljdz5D9W1l80We15mufxLuZG9319Ta0GUts8H66h4tYcS2H3XjhISnzaDCTy8jjK >									
	//        <  u =="0.000000000000000001" : ] 000000088251161.873500400000000000 ; 000000098991574.632236100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000086A91C970C95 >									
	//     < BANK_IV_PFIII_metadata_line_10_____PING AN BANK_20260508 >									
	//        < xY7Ynidm88Ov2lS8lina6bu02Q28F13YDf37E9vsdXLudkzn9424cngV6x90rqm9 >									
	//        <  u =="0.000000000000000001" : ] 000000098991574.632236100000000000 ; 000000109863774.283931000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000970C95A7A389 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_IV_PFIII_metadata_line_11_____HUAXIA BANK_20260508 >									
	//        < p2mBI7ZgWkcR6X8PyNj9NmR8C1c5qmKeokU0u0BRU3Sw2u687Kw1Bx8NjQES488i >									
	//        <  u =="0.000000000000000001" : ] 000000109863774.283931000000000000 ; 000000120673966.623743000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A7A389B82245 >									
	//     < BANK_IV_PFIII_metadata_line_12_____CHINA GUANGFA BANK_20260508 >									
	//        < 1Elo165r7s15MKO4g8d5qe5acIMCdri5o8tN1Pr3bd84i70dal1V48Qgi53SSAD2 >									
	//        <  u =="0.000000000000000001" : ] 000000120673966.623743000000000000 ; 000000131329398.966221000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B82245C8648C >									
	//     < BANK_IV_PFIII_metadata_line_13_____CHINA BOHAI BANK_20260508 >									
	//        < 41014ieVQ4JThjESsrSzjB3y7n7G1fyla2WAlSLFl12Z6RFz5p3bbvP7Ia4lH2T2 >									
	//        <  u =="0.000000000000000001" : ] 000000131329398.966221000000000000 ; 000000142557589.835561000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C8648CD9868F >									
	//     < BANK_IV_PFIII_metadata_line_14_____HENGFENG BANK_EVERGROWING BANK_20260508 >									
	//        < 2eY282j906p0OBV94Zrf40F8uc2hCh3vFg2801zV0r3X8d9NQ81Z8HD92v71g2lH >									
	//        <  u =="0.000000000000000001" : ] 000000142557589.835561000000000000 ; 000000153322628.395974000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D9868FE9F3A7 >									
	//     < BANK_IV_PFIII_metadata_line_15_____BANK OF BEIJING_20260508 >									
	//        < IO15e9VsqG5U9NuWAExJu004bw6VBNG5c43G83w6aZ2J9Y4hfsRMI4LroTK08yLX >									
	//        <  u =="0.000000000000000001" : ] 000000153322628.395974000000000000 ; 000000164087316.501781000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E9F3A7FA609C >									
	//     < BANK_IV_PFIII_metadata_line_16_____BANK OF SHANGHAI_20260508 >									
	//        < 5o0Zhu4CFGIpLv46el10s5i4eljDc5icne5oO7c6Mafnd0i781YnQ48jH9NE43A5 >									
	//        <  u =="0.000000000000000001" : ] 000000164087316.501781000000000000 ; 000000174953480.403129000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FA609C10AF534 >									
	//     < BANK_IV_PFIII_metadata_line_17_____BANK OF JIANGSU_20260508 >									
	//        < OAzr95Z0GvFl11th2PUhK0XV8e4a2fqd4qJb5h21m82E26b3j2s7QN126BekocCq >									
	//        <  u =="0.000000000000000001" : ] 000000174953480.403129000000000000 ; 000000185605731.128125000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010AF53411B363D >									
	//     < BANK_IV_PFIII_metadata_line_18_____BANK OF NINGBO_20260508 >									
	//        < p6282ggf06a0Z0kHjSpDUz81IvrfSt3p0UL9hQAZDSbXWMKyfZzxgz5bLX9fe4DO >									
	//        <  u =="0.000000000000000001" : ] 000000185605731.128125000000000000 ; 000000196860954.073433000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011B363D12C62CF >									
	//     < BANK_IV_PFIII_metadata_line_19_____BANK OF DALIAN_20260508 >									
	//        < xXBCwd75IXUG67n9bp77HkBL4C648Yle5N8ny2Srlwb9O8RGjBWdXo94JsBwnbqA >									
	//        <  u =="0.000000000000000001" : ] 000000196860954.073433000000000000 ; 000000207685117.394239000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012C62CF13CE700 >									
	//     < BANK_IV_PFIII_metadata_line_20_____BANK OF TAIZHOU_20260508 >									
	//        < 9vyYqAObGZbopTA3G7gxZuEiY10715EHqroBWdxgWzz4p0yHPhLbQRymGjeg6420 >									
	//        <  u =="0.000000000000000001" : ] 000000207685117.394239000000000000 ; 000000218731493.518824000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013CE70014DC1FD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_IV_PFIII_metadata_line_21_____BANK OF TIANJIN_20260508 >									
	//        < 897Vm69v544uk9ljVx4f6U0j9KTOI79Sy6zRuz47dBO795fClKVnx5zAN42cfRmB >									
	//        <  u =="0.000000000000000001" : ] 000000218731493.518824000000000000 ; 000000229579958.459693000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014DC1FD15E4FAC >									
	//     < BANK_IV_PFIII_metadata_line_22_____WIAMEN INTERNATIONAL BANK_20260508 >									
	//        < 68Nsjt4X83vWw7eQMKc8r4006Y1D3Vil84knRTArHc18j2g221o6tlz35CIgwB6x >									
	//        <  u =="0.000000000000000001" : ] 000000229579958.459693000000000000 ; 000000240480353.914030000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015E4FAC16EF1A3 >									
	//     < BANK_IV_PFIII_metadata_line_23_____TAI_AN BANK_20260508 >									
	//        < MN4xGTtt0WOvGthz525mnzB3ALvv6EpSIuqm04gO3p24Td2DL42Kv9gXo9jeGIk0 >									
	//        <  u =="0.000000000000000001" : ] 000000240480353.914030000000000000 ; 000000251736247.739310000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016EF1A31801E79 >									
	//     < BANK_IV_PFIII_metadata_line_24_____SHENGJING BANK_SHENYANG_20260508 >									
	//        < 35Y1t0bwN9mj63qQF3l7ZbNOQLwbkn1T9F98438l4X8jT8Fr4Ej4Frm513Evw90n >									
	//        <  u =="0.000000000000000001" : ] 000000251736247.739310000000000000 ; 000000263007893.069428000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001801E791915175 >									
	//     < BANK_IV_PFIII_metadata_line_25_____HARBIN BANK_20260508 >									
	//        < 9h4kPAiYJ4N5q2cd4yxfceyc97Ay4N9792Av247Y5Amk8fn7osKW5O1wW1wzOX11 >									
	//        <  u =="0.000000000000000001" : ] 000000263007893.069428000000000000 ; 000000274135975.232486000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019151751A24C5E >									
	//     < BANK_IV_PFIII_metadata_line_26_____BANK OF JILIN_20260508 >									
	//        < D8wI4J4fszOjdN8F35vlG2Og8l2Lb41150xh8Q0UJD1b80a6V3eq8Ldg4NZ0907C >									
	//        <  u =="0.000000000000000001" : ] 000000274135975.232486000000000000 ; 000000284816897.257899000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A24C5E1B2989A >									
	//     < BANK_IV_PFIII_metadata_line_27_____WEBANK_CHINA_20260508 >									
	//        < z94DSSDEiuQ7874wuqQp5iTJ7hiG2J846c7fhz6gS8T8ANQW2YB1S527orSjt9Re >									
	//        <  u =="0.000000000000000001" : ] 000000284816897.257899000000000000 ; 000000295686754.595106000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B2989A1C32EA3 >									
	//     < BANK_IV_PFIII_metadata_line_28_____MYBANK_HANGZHOU_20260508 >									
	//        < 6tVlO79OgytzR436JGV5yvU2RCdpFyp0rLU537104cL0K8MhKkPy6T7oQ43E7tA3 >									
	//        <  u =="0.000000000000000001" : ] 000000295686754.595106000000000000 ; 000000306573061.639301000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C32EA31D3CB1A >									
	//     < BANK_IV_PFIII_metadata_line_29_____SHANGHAI HUARUI BANK_20260508 >									
	//        < h85ni84120kJQz4S4JZ2213J8fIcpk31mlaFHR1TgR0pz9II0YHmOXze6CcM6eM4 >									
	//        <  u =="0.000000000000000001" : ] 000000306573061.639301000000000000 ; 000000317890774.206285000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D3CB1A1E51015 >									
	//     < BANK_IV_PFIII_metadata_line_30_____WENZHOU MINSHANG BANK_20260508 >									
	//        < Vc1dwyDb279X7Ew7eP0u2W1xse1cEt47O6oQgRN3Ao763504x6DM8D49Xn368Xa3 >									
	//        <  u =="0.000000000000000001" : ] 000000317890774.206285000000000000 ; 000000328625105.381678000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E510151F5712F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_IV_PFIII_metadata_line_31_____BANK OF KUNLUN_20260508 >									
	//        < G5v6c9YCMR9eb51Fo8Sb9D744Ik80eb029IfpfdYBau6ew7MiGVqb0tNHtC30H45 >									
	//        <  u =="0.000000000000000001" : ] 000000328625105.381678000000000000 ; 000000339771360.501680000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F5712F2067330 >									
	//     < BANK_IV_PFIII_metadata_line_32_____SILIBANK_20260508 >									
	//        < b5fT4KODZ0t24Z1ruiY1DnW2bwCwDasrKUe32mw15aCWCiWxmjHn9O62WJq0bSJ8 >									
	//        <  u =="0.000000000000000001" : ] 000000339771360.501680000000000000 ; 000000351072182.713355000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002067330217B192 >									
	//     < BANK_IV_PFIII_metadata_line_33_____AGRICULTURAL BANK OF CHINA_20260508 >									
	//        < h5hBz65TBFk0sVTBzAZ4IQM5jW33Vz1cHmmQ4M5ujHt9SA98n5r1w1F24Q8Z2i2u >									
	//        <  u =="0.000000000000000001" : ] 000000351072182.713355000000000000 ; 000000361814616.871978000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000217B19222815D6 >									
	//     < BANK_IV_PFIII_metadata_line_34_____CIC_CHINA INVESTMENT CORP_20260508 >									
	//        < 7JG6tTM3zn8mq7gaBr9P1vN6ULVpF4U5CTHc7PP1Fpbr5V9AM55q3oHo7088wUqT >									
	//        <  u =="0.000000000000000001" : ] 000000361814616.871978000000000000 ; 000000372580902.235290000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022815D6238836A >									
	//     < BANK_IV_PFIII_metadata_line_35_____BANK OF CHINA_20260508 >									
	//        < Eoh6jnv6z9YimSy4dNHb641g9z1fhyFBmV8ra66qWv52rS267FxFpZw9230GzX3l >									
	//        <  u =="0.000000000000000001" : ] 000000372580902.235290000000000000 ; 000000383331569.746084000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000238836A248EAE5 >									
	//     < BANK_IV_PFIII_metadata_line_36_____PEOPLE BANK OF CHINA_20260508 >									
	//        < wZlYQAyvPNfBG5BV1bWXxTQAYS38773p12o53N2i086168QLZSHtcGA9h9QvS3S1 >									
	//        <  u =="0.000000000000000001" : ] 000000383331569.746084000000000000 ; 000000393998721.599141000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000248EAE525931C0 >									
	//     < BANK_IV_PFIII_metadata_line_37_____ICBC_INDUSTRIAL AND COMMERCIAL BANK OF CHINA_20260508 >									
	//        < ZtunB0CegfVYY99CeySZ1HX9359r7P37DhrXwORo0VbtuaU2t9ClgstGlO338ok9 >									
	//        <  u =="0.000000000000000001" : ] 000000393998721.599141000000000000 ; 000000405188191.684659000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025931C026A44A3 >									
	//     < BANK_IV_PFIII_metadata_line_38_____CHINA CONSTRUCTION BANK_20260508 >									
	//        < 35X4sLdm6yXd96geb617vt29a19q77S22Q1tIZnjjNfB5K2Fk55181jf6xl2uRFv >									
	//        <  u =="0.000000000000000001" : ] 000000405188191.684659000000000000 ; 000000415862078.671004000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026A44A327A8E20 >									
	//     < BANK_IV_PFIII_metadata_line_39_____BANK OF COMMUNICATION_20260508 >									
	//        < 06wbhttc738Jx01AsqbFa4E9EWtomB422f04GEyd9tHE9ncZRgnJt0fchJPmYaRH >									
	//        <  u =="0.000000000000000001" : ] 000000415862078.671004000000000000 ; 000000426525157.614919000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A8E2028AD364 >									
	//     < BANK_IV_PFIII_metadata_line_40_____POSTAL SAVINGS BANK OF CHINA_20260508 >									
	//        < t2AQF02VGzk3pY84krY9fC0kL0e5V1287wCjKe983Z8Q9sRojn9I9o42512SCg3U >									
	//        <  u =="0.000000000000000001" : ] 000000426525157.614919000000000000 ; 000000437259067.042976000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028AD36429B3453 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
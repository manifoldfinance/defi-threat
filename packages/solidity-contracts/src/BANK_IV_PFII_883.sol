/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	BANK_IV_PFII_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	BANK_IV_PFII_883		"	;
		string	public		symbol =	"	BANK_IV_PFII_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		426401924563853000000000000					;	
										
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
	//     < BANK_IV_PFII_metadata_line_1_____AGRICULTURAL DEVELOPMENT BANK OF CHINA_20240508 >									
	//        < 097f3Why018u0mt9n9KBusKTR8446mRT8c51XSYAe5c8NZ9Wtc5kxisBmTIcFU0Y >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010811605.769000600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000107F49 >									
	//     < BANK_IV_PFII_metadata_line_2_____CHINA DEVELOMENT BANK_20240508 >									
	//        < 4GB8j3PAE7AM43PEG2rTTVYmKq9JLQmvXkrj98987uO23s0MvGR0c01mZioJaTOg >									
	//        <  u =="0.000000000000000001" : ] 000000010811605.769000600000000000 ; 000000021305333.732310400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000107F49208265 >									
	//     < BANK_IV_PFII_metadata_line_3_____EXIM BANK OF CHINA_20240508 >									
	//        < 3Bq8cgT0VEhdJ5YQ4o80R5wgpw4q35d6sgNl3FIL0fA869iJQKA2354AGjPPLJ5j >									
	//        <  u =="0.000000000000000001" : ] 000000021305333.732310400000000000 ; 000000031998526.308036900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000020826530D36D >									
	//     < BANK_IV_PFII_metadata_line_4_____CHINA MERCHANT BANK_20240508 >									
	//        < 0BWJi4H4Y6zHfhw9s7M2Q8vX5i6lZe7ByC6vZ7DKoo3k9Byn1umJPSVqsu7OSG6l >									
	//        <  u =="0.000000000000000001" : ] 000000031998526.308036900000000000 ; 000000042719493.166993800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000030D36D412F4D >									
	//     < BANK_IV_PFII_metadata_line_5_____SHANGHAI PUDONG DEVELOPMENT BANK_20240508 >									
	//        < X8a9L94INMbvRi3tP1HsuO8eqPWSW27V715uY2gDVf8r6HLa9q6w01WB0GnsgcFP >									
	//        <  u =="0.000000000000000001" : ] 000000042719493.166993800000000000 ; 000000053541020.289347400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000412F4D51B276 >									
	//     < BANK_IV_PFII_metadata_line_6_____INDUSTRIAL BANK_20240508 >									
	//        < 57To08NLH7Pj4Qn8tpW73Fi8jeujZAV1Ig1Jhb4hoq8c50BkEQ7V7T1wmLxDV611 >									
	//        <  u =="0.000000000000000001" : ] 000000053541020.289347400000000000 ; 000000064246047.672038700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000051B27662081D >									
	//     < BANK_IV_PFII_metadata_line_7_____CHINA CITIC BANK_20240508 >									
	//        < EDgU3Emh0LnPLGpL1rk00L0x3j96D71rXU88xoX148739l9muLhs8s69cg5fTcBH >									
	//        <  u =="0.000000000000000001" : ] 000000064246047.672038700000000000 ; 000000075017616.257377800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000062081D7277C2 >									
	//     < BANK_IV_PFII_metadata_line_8_____CHINA MINSHENG BANK_20240508 >									
	//        < LDU62k8jqzwBcYuLLAa3QAmLnHcd0o1ayqVW09lHtnaUSOt4JOCGeS1RfgKy0008 >									
	//        <  u =="0.000000000000000001" : ] 000000075017616.257377800000000000 ; 000000085489604.885801900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007277C2827260 >									
	//     < BANK_IV_PFII_metadata_line_9_____CHINA EVERBRIGHT BANK_20240508 >									
	//        < 950IIXGf8ta9ZmDjO18c3n0R4xjX13TDU80o7L5uqkIWIx5KL1DMB10Q6KtIBMlp >									
	//        <  u =="0.000000000000000001" : ] 000000085489604.885801900000000000 ; 000000095975821.850357900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000082726092728E >									
	//     < BANK_IV_PFII_metadata_line_10_____PING AN BANK_20240508 >									
	//        < yRG6G5DuUA1M31fDmWU7E3v29ZQjnRQ69eW5665aT58T3G5UZS4y99U9CdiQh4Ui >									
	//        <  u =="0.000000000000000001" : ] 000000095975821.850357900000000000 ; 000000106848240.592424000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000092728EA30998 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_IV_PFII_metadata_line_11_____HUAXIA BANK_20240508 >									
	//        < 8rL0FpyUMnDA5825a6KYWQe5p8MHXcTJf99ebPG05U6hXYN2ZYU7lKnG0HBnUIpk >									
	//        <  u =="0.000000000000000001" : ] 000000106848240.592424000000000000 ; 000000117561535.431945000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A30998B3627A >									
	//     < BANK_IV_PFII_metadata_line_12_____CHINA GUANGFA BANK_20240508 >									
	//        < Q32068LD0X7LjJPAf21pcjcIuRlFA96e6M7x0QyuF34ryGm99G7QIKkPlVeaTYar >									
	//        <  u =="0.000000000000000001" : ] 000000117561535.431945000000000000 ; 000000128088436.811144000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B3627AC3728C >									
	//     < BANK_IV_PFII_metadata_line_13_____CHINA BOHAI BANK_20240508 >									
	//        < VF2esu69wa5K4gS4mM4vs88M848W00531TzuJQMi9Hp81VLITk8IOBBhvXfbMrZr >									
	//        <  u =="0.000000000000000001" : ] 000000128088436.811144000000000000 ; 000000138865710.364514000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C3728CD3E46B >									
	//     < BANK_IV_PFII_metadata_line_14_____HENGFENG BANK_EVERGROWING BANK_20240508 >									
	//        < 5pc91m4683dtbfMQi5eOn36HO05gD8ojulmn1XT094NRvlrKPtnI679XVxLMg0L4 >									
	//        <  u =="0.000000000000000001" : ] 000000138865710.364514000000000000 ; 000000149556508.120338000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D3E46BE43483 >									
	//     < BANK_IV_PFII_metadata_line_15_____BANK OF BEIJING_20240508 >									
	//        < F8D6DM56FuD4sug8vTL0nt1x50tB918T983tBR0xesv1V6G7Vip93tH9M2SOJtW3 >									
	//        <  u =="0.000000000000000001" : ] 000000149556508.120338000000000000 ; 000000160317019.700722000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E43483F49FD6 >									
	//     < BANK_IV_PFII_metadata_line_16_____BANK OF SHANGHAI_20240508 >									
	//        < A0F0Lue3Z5Y51FjuvQGFob32xr568pp5kX0gp5zhe0UcOzefDZOgQ4k3DJZhmY0t >									
	//        <  u =="0.000000000000000001" : ] 000000160317019.700722000000000000 ; 000000171121306.386258000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F49FD61051C43 >									
	//     < BANK_IV_PFII_metadata_line_17_____BANK OF JIANGSU_20240508 >									
	//        < Pr0PW394l21289M5tjdX5v34OohKRq7pCo3xZEmS5Vhs2rHBAk93Q0v9W7U830V2 >									
	//        <  u =="0.000000000000000001" : ] 000000171121306.386258000000000000 ; 000000181899944.840797000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001051C431158EAA >									
	//     < BANK_IV_PFII_metadata_line_18_____BANK OF NINGBO_20240508 >									
	//        < 3axqccFVcy3A1H7cT1j48N1aI3foWqQDLK5qdAUEbPKdb04dN975KN161I8l9tmU >									
	//        <  u =="0.000000000000000001" : ] 000000181899944.840797000000000000 ; 000000192448218.003346000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001158EAA125A716 >									
	//     < BANK_IV_PFII_metadata_line_19_____BANK OF DALIAN_20240508 >									
	//        < B39z46xYEaLSX22LvTFTr2ADt4cplLg76Ym5JHV82xHSl5kFg00ROl9n4kMwks1d >									
	//        <  u =="0.000000000000000001" : ] 000000192448218.003346000000000000 ; 000000203095793.051792000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000125A716135E64B >									
	//     < BANK_IV_PFII_metadata_line_20_____BANK OF TAIZHOU_20240508 >									
	//        < jd53aWYX9penvlU0EqCSf6Bp7849mbhXH0T8sTel600OA38Zm1BoszWpq3SMGD4n >									
	//        <  u =="0.000000000000000001" : ] 000000203095793.051792000000000000 ; 000000213618376.320926000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000135E64B145F4AE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_IV_PFII_metadata_line_21_____BANK OF TIANJIN_20240508 >									
	//        < nfMTD3c97bsgNnBE2fy725L1Q28qKhL7zdpfEThfnIqT0kFG2423IK40lR5DMN3k >									
	//        <  u =="0.000000000000000001" : ] 000000213618376.320926000000000000 ; 000000224258548.388819000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000145F4AE15630FF >									
	//     < BANK_IV_PFII_metadata_line_22_____WIAMEN INTERNATIONAL BANK_20240508 >									
	//        < 9E14053zlnec12AH98RQ5sLcn66251f81DHRSw5AF2182eppT8qdLFOMjlC30GI8 >									
	//        <  u =="0.000000000000000001" : ] 000000224258548.388819000000000000 ; 000000234956019.476122000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015630FF16683B2 >									
	//     < BANK_IV_PFII_metadata_line_23_____TAI_AN BANK_20240508 >									
	//        < 6Hw1UN1KvMBg9Oz659FxHv36k6LH3mL9920nBH8J9O50503M5KuJsewQpe7c9w24 >									
	//        <  u =="0.000000000000000001" : ] 000000234956019.476122000000000000 ; 000000245517475.530211000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016683B2176A144 >									
	//     < BANK_IV_PFII_metadata_line_24_____SHENGJING BANK_SHENYANG_20240508 >									
	//        < mxnU7o4TzGfK3Dhq8Sr5H7dvj00iuAZI575dUf8J59iAvU9Op3sro5B2Fv0ZV0oe >									
	//        <  u =="0.000000000000000001" : ] 000000245517475.530211000000000000 ; 000000255985349.228029000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000176A1441869A47 >									
	//     < BANK_IV_PFII_metadata_line_25_____HARBIN BANK_20240508 >									
	//        < eI4p0B74ADUinEBZ3q2v63Wj7oD68v86Ihg56uK2n2b3w0h98vn1a2hzFEiUy5lc >									
	//        <  u =="0.000000000000000001" : ] 000000255985349.228029000000000000 ; 000000266515395.541486000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001869A47196AB94 >									
	//     < BANK_IV_PFII_metadata_line_26_____BANK OF JILIN_20240508 >									
	//        < xSV4V7RxkqGNoPJ0LZe0CqWe3WBQU3215u6nJOqmGhVp8igkt83l83M9Y098p8mM >									
	//        <  u =="0.000000000000000001" : ] 000000266515395.541486000000000000 ; 000000277149274.768863000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000196AB941A6E56F >									
	//     < BANK_IV_PFII_metadata_line_27_____WEBANK_CHINA_20240508 >									
	//        < F93B2wdp0IfVp2Z924U45HArjp3bf5l99Gx6qq89X7jN47Q3J29qu9KU1xnTe02T >									
	//        <  u =="0.000000000000000001" : ] 000000277149274.768863000000000000 ; 000000287673215.303212000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A6E56F1B6F45A >									
	//     < BANK_IV_PFII_metadata_line_28_____MYBANK_HANGZHOU_20240508 >									
	//        < 24A5h29nkMTd9mpL6b14IU6S0wPq196z6t0fS1MjtY559Y5w8vLh6QsjMCZprOWB >									
	//        <  u =="0.000000000000000001" : ] 000000287673215.303212000000000000 ; 000000298499562.245313000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B6F45A1C77964 >									
	//     < BANK_IV_PFII_metadata_line_29_____SHANGHAI HUARUI BANK_20240508 >									
	//        < aXuFx01fu3Dk51lXHt1bt4z3Y0irbtScyi9YoOfPNWg5fpbCcFVoHYJBnP7g29S6 >									
	//        <  u =="0.000000000000000001" : ] 000000298499562.245313000000000000 ; 000000309122894.423969000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C779641D7AF21 >									
	//     < BANK_IV_PFII_metadata_line_30_____WENZHOU MINSHANG BANK_20240508 >									
	//        < 84eJop6Vi5YqoUxcpJk3jXE8vZv6fju3E18yNdQs3e9qShQl04jt9gS871v1z79D >									
	//        <  u =="0.000000000000000001" : ] 000000309122894.423969000000000000 ; 000000319945427.131766000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D7AF211E832AF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_IV_PFII_metadata_line_31_____BANK OF KUNLUN_20240508 >									
	//        < K6enmxKfh1qoYJacFgirQmgJ5Ct4K6GL7L5Q3rXBFfFgE9CHb5L7ST39zFSq0491 >									
	//        <  u =="0.000000000000000001" : ] 000000319945427.131766000000000000 ; 000000330675335.687333000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E832AF1F8920E >									
	//     < BANK_IV_PFII_metadata_line_32_____SILIBANK_20240508 >									
	//        < 8ke118OQ0scN4r0GR84pIRT5ID0AI1j57Yg6Ufg4d00D54DxU052JbcMrh52n49E >									
	//        <  u =="0.000000000000000001" : ] 000000330675335.687333000000000000 ; 000000341355936.527916000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F8920E208DE2A >									
	//     < BANK_IV_PFII_metadata_line_33_____AGRICULTURAL BANK OF CHINA_20240508 >									
	//        < d58Uv84GyQ20YIY56McG0FjMvw1AvZ76mr9nlHzCw7CRzmzX9Gk2vQup3aI2bp41 >									
	//        <  u =="0.000000000000000001" : ] 000000341355936.527916000000000000 ; 000000352167298.547420000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000208DE2A2195D5A >									
	//     < BANK_IV_PFII_metadata_line_34_____CIC_CHINA INVESTMENT CORP_20240508 >									
	//        < 1593R2606tblLe7gWAp4aspv5a15RzF9379ZT956XJu63t8CN1wYvNiYhO3l7QF6 >									
	//        <  u =="0.000000000000000001" : ] 000000352167298.547420000000000000 ; 000000362717732.715685000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002195D5A229769D >									
	//     < BANK_IV_PFII_metadata_line_35_____BANK OF CHINA_20240508 >									
	//        < A8OGh88j0K2M8bz2ytyzv292ll3YXBhbQ18t0spUB85K37f2437eU0eoZJupZtOA >									
	//        <  u =="0.000000000000000001" : ] 000000362717732.715685000000000000 ; 000000373325089.664297000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000229769D239A61D >									
	//     < BANK_IV_PFII_metadata_line_36_____PEOPLE BANK OF CHINA_20240508 >									
	//        < yz39Y70kFK57pS5GSi6s0F1640mWzloG0Et53519sDt7ly5Bcz83T83Mpxcc72eQ >									
	//        <  u =="0.000000000000000001" : ] 000000373325089.664297000000000000 ; 000000383955070.915717000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000239A61D249DE73 >									
	//     < BANK_IV_PFII_metadata_line_37_____ICBC_INDUSTRIAL AND COMMERCIAL BANK OF CHINA_20240508 >									
	//        < Di406IL1VsGl6RjGEy08ERc6E80W2b5S7Z345Cao5ezGr9du4inuWgoO7vCt7ra2 >									
	//        <  u =="0.000000000000000001" : ] 000000383955070.915717000000000000 ; 000000394554159.877437000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000249DE7325A0AB8 >									
	//     < BANK_IV_PFII_metadata_line_38_____CHINA CONSTRUCTION BANK_20240508 >									
	//        < vYup64q5OtcG95wCKqicZGmT8YgvKmY02S4ln8qr7lX45tUah13Tx8G3NaByd6nc >									
	//        <  u =="0.000000000000000001" : ] 000000394554159.877437000000000000 ; 000000405023728.564545000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025A0AB826A0465 >									
	//     < BANK_IV_PFII_metadata_line_39_____BANK OF COMMUNICATION_20240508 >									
	//        < 2Zc0oY3Yqy1dlszmIOU4Gms9z4B9hWw9xIF6726kJGI87N7HLX76iy24fog8a7vQ >									
	//        <  u =="0.000000000000000001" : ] 000000405023728.564545000000000000 ; 000000415867975.736694000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026A046527A906E >									
	//     < BANK_IV_PFII_metadata_line_40_____POSTAL SAVINGS BANK OF CHINA_20240508 >									
	//        < WxfG9w6Ys7zrWQVL9Ru8i8NB59438q6Hw9P24Iq3KgUTh6Qt5sr0214jg2Szh8s4 >									
	//        <  u =="0.000000000000000001" : ] 000000415867975.736694000000000000 ; 000000426401924.563853000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A906E28AA340 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
/**
 * Source Code first verified at https://etherscan.io on Friday, March 22, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFIII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFIII_III_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFIII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		960045161637506000000000000					;	
										
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
	//     < CHEMCHINA_PFIII_III_metadata_line_1_____Hangzhou_Hairui_Chemical_Limited_20260321 >									
	//        < 2AVduU6Zs1S36tyi0A173BaKb70mCH77K9Vw7SzNFcGOsG5R8XnF1AooRwP2qs32 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000023316870.287486200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000239427 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_2_____Hangzhou_Huajin_Pharmaceutical_Co_Limited_20260321 >									
	//        < 1Q7g768eufHwbK9L5Dc3e2cVUz30vXYwuY9t694RT38zV50G88M5lmi6CKLwdpZl >									
	//        <  u =="0.000000000000000001" : ] 000000023316870.287486200000000000 ; 000000043785242.665289400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000023942742CF9C >									
	//     < CHEMCHINA_PFIII_III_metadata_line_3_____Hangzhou_J_H_Chemical_Co__Limited_20260321 >									
	//        < l1E9N67XOw0QoEB51kSty9j7I0zu6M3Qz7WZy3AXiH0zKd44Q3094T7hbYHMkiRI >									
	//        <  u =="0.000000000000000001" : ] 000000043785242.665289400000000000 ; 000000063806282.945332400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000042CF9C615C54 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_4_____Hangzhou_J_H_Chemical_Co__Limited_20260321 >									
	//        < FsN8Sq4KOkdDO1fOJ9kASvd5zAxM39VC64jHRMg0yPy44HUwYd7ry50IOCOs59zC >									
	//        <  u =="0.000000000000000001" : ] 000000063806282.945332400000000000 ; 000000092509037.984074700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000615C548D2858 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_5_____HANGZHOU_KEYINGCHEM_Co_Limited_20260321 >									
	//        < C5gRb6DNjAwCwmKV02Qk7A5VC2lnIAf1CZ83Oyx90CR2XF4zp35x13C4hDXK68Uo >									
	//        <  u =="0.000000000000000001" : ] 000000092509037.984074700000000000 ; 000000123247945.950195000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008D2858BC0FBB >									
	//     < CHEMCHINA_PFIII_III_metadata_line_6_____HANGZHOU_MEITE_CHEMICAL_Co_LimitedHANGZHOU_MEITE_INDUSTRY_Co_Limited_20260321 >									
	//        < 1IHL88eRqA4SMy0E18LV7Q92u09rChqix0ppFK29AWBS8jz4j5767j1xE3O2nLG0 >									
	//        <  u =="0.000000000000000001" : ] 000000123247945.950195000000000000 ; 000000155919048.974928000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BC0FBBEDE9E1 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_7_____Hangzhou_Ocean_chemical_Co_Limited_20260321 >									
	//        < 2Jz77WMTcU8WWs7a1vG0CJ11t797s64rMDV9g5787Cy888o0T6P4uzuSs8GFMLV3 >									
	//        <  u =="0.000000000000000001" : ] 000000155919048.974928000000000000 ; 000000176141121.644129000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EDE9E110CC520 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_8_____Hangzhou_Pharma___Chem_Co_Limited_20260321 >									
	//        < g2beeKl69aTp0h7f0GV8hHo00vp8PV4mO8JeW0J7nUypvK8yrV6ID8o8L92n8Qc3 >									
	//        <  u =="0.000000000000000001" : ] 000000176141121.644129000000000000 ; 000000197685235.750600000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010CC52012DA4CC >									
	//     < CHEMCHINA_PFIII_III_metadata_line_9_____Hangzhou_Tino_Bio_Tech_Co_Limited_20260321 >									
	//        < Rj3QpzRFXN0e8rpjjqSba6fHsBRBvv8sF66XqoRu04OOZ12cW70654cLa8j1J5Am >									
	//        <  u =="0.000000000000000001" : ] 000000197685235.750600000000000000 ; 000000215732560.344367000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012DA4CC1492E88 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_10_____Hangzhou_Trylead_Chemical_Technology_Co_Limited_20260321 >									
	//        < L671FJhjw5HuUU9yu0kuicBDzgH6jJlhH5Wet6zIjO81lkaQQp7428x2l3gc4ZJz >									
	//        <  u =="0.000000000000000001" : ] 000000215732560.344367000000000000 ; 000000237143508.157440000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001492E88169DA2F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIII_III_metadata_line_11_____Hangzhou_Verychem_Science_And_Technology_org_20260321 >									
	//        < 1W654EDDPnJqDpG7oNZ666uhTmh30cR18rbjc0ina11FnNR00b7h4lh3dimDFmqP >									
	//        <  u =="0.000000000000000001" : ] 000000237143508.157440000000000000 ; 000000265914525.551244000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000169DA2F195C0DD >									
	//     < CHEMCHINA_PFIII_III_metadata_line_12_____Hangzhou_Verychem_Science_And_Technology_Co__Limited_20260321 >									
	//        < vda9lbDaQVIx067l8ww3jT72CMDXZjhx1l8vMyan7001C690mD2GuR00a8690o0H >									
	//        <  u =="0.000000000000000001" : ] 000000265914525.551244000000000000 ; 000000290182390.168211000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000195C0DD1BAC87F >									
	//     < CHEMCHINA_PFIII_III_metadata_line_13_____Hangzhou_Yuhao_Chemical_Technology_Co_Limited_20260321 >									
	//        < 5fB7buKPP76aAU4a8yu4f1t2G6q3F0vcgLeFu7l4XIj0i16DHj9L8IA3hTv0d6yh >									
	//        <  u =="0.000000000000000001" : ] 000000290182390.168211000000000000 ; 000000315375869.898505000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BAC87F1E139B3 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_14_____HANGZHOU_ZHIXIN_CHEMICAL_Co__Limited_20260321 >									
	//        < kVQWe4bFBK2Wvm66CWW9yE863WjFw63166ijws169wWJftCmQBA8I46zscue79b3 >									
	//        <  u =="0.000000000000000001" : ] 000000315375869.898505000000000000 ; 000000338968725.533752000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E139B320539A9 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_15_____Hangzhou_zhongqi_chem_Co_Limited_20260321 >									
	//        < IzvLlK721s4wZ0hl475Bcil42Ez3LLCekomS8znlOv0w51sUDbzp66Vxbico65U3 >									
	//        <  u =="0.000000000000000001" : ] 000000338968725.533752000000000000 ; 000000357686921.813433000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020539A9221C974 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_16_____HEBEI_AOGE_CHEMICAL_Co__Limited_20260321 >									
	//        < SDwQ23XssX9To526Uwv2l1G18n3JMb3l9zHv75lC3o2351W4icHKcik35j3lIPrD >									
	//        <  u =="0.000000000000000001" : ] 000000357686921.813433000000000000 ; 000000377885423.503384000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000221C9742409B7E >									
	//     < CHEMCHINA_PFIII_III_metadata_line_17_____HEBEI_DAPENG_PHARM_CHEM_Co__Limited_20260321 >									
	//        < 2ipid1e2pGTR23JJREZapNv33EJYcIrJhpTiNgP2zxC9qGoYq9f1qdSvsPaSh7gj >									
	//        <  u =="0.000000000000000001" : ] 000000377885423.503384000000000000 ; 000000396434055.124420000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002409B7E25CE90E >									
	//     < CHEMCHINA_PFIII_III_metadata_line_18_____Hebei_Guantang_Pharmatech_20260321 >									
	//        < N01p6SrIu5INlY6r9t5bI1BcKRwy84OWCVZ9qT6In8w4yrP1g0L8p8BJfL6w7lhF >									
	//        <  u =="0.000000000000000001" : ] 000000396434055.124420000000000000 ; 000000419278725.282249000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025CE90E27FC4C1 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_19_____Hefei_Hirisun_Pharmatech_org_20260321 >									
	//        < AlzEk4e71j6qe707gTUcZJVPlv222utj24vVt1os4180JzmR5A11t5m5cm1661iw >									
	//        <  u =="0.000000000000000001" : ] 000000419278725.282249000000000000 ; 000000443290652.417251000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027FC4C12A46869 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_20_____Hefei_Hirisun_Pharmatech_Co_Limited_20260321 >									
	//        < qP7gB0iBaMdFis9pR9L70udz11McJnIh7VYVYPVKLw4UigIRzWzBpqsX4y5WV62G >									
	//        <  u =="0.000000000000000001" : ] 000000443290652.417251000000000000 ; 000000461578994.058316000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A468692C0504B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIII_III_metadata_line_21_____HENAN_YUCHEN_FINE_CHEMICAL_Co_Limited_20260321 >									
	//        < r3C13OtHjEmL7Y8w63EZw97ikQaGWY6Zz3iFTymU7lbM36lX625moIihCPC22Ef3 >									
	//        <  u =="0.000000000000000001" : ] 000000461578994.058316000000000000 ; 000000482355362.333413000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C0504B2E00410 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_22_____Hi_Tech_Chemistry_Corp_20260321 >									
	//        < fCn2z30D8k0EDi061PXR6RFpn6wajnJ04TJdRV29U0t0x0zrA6S2OAJjtqn8318C >									
	//        <  u =="0.000000000000000001" : ] 000000482355362.333413000000000000 ; 000000512337588.891164000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E0041030DC3DF >									
	//     < CHEMCHINA_PFIII_III_metadata_line_23_____Hongding_International_Chemical_Industry__Nantong__co___ltd_20260321 >									
	//        < rFbhre6P7k4wV2250e2KPZwy1u51wbuLz27lwOPESolx3V3jv9maSFX90J743Ag8 >									
	//        <  u =="0.000000000000000001" : ] 000000512337588.891164000000000000 ; 000000539337527.113399000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030DC3DF336F6B9 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_24_____Hunan_Chemfish_pharmaceutical_Co_Limited_20260321 >									
	//        < fBS2u6U5PQO7ptFtHcRSiF0c9wu5PNa59lZ4RU8gMA55B798C75aZqJ5arcuhdA1 >									
	//        <  u =="0.000000000000000001" : ] 000000539337527.113399000000000000 ; 000000567564491.078816000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000336F6B936208E1 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_25_____IFFECT_CHEMPHAR_Co__Limited_20260321 >									
	//        < 04D8ox2D5Ng28V4d63d19b81by9h628qSLitIlTaLHN1OufQOVUE93j6Smt4Eqwz >									
	//        <  u =="0.000000000000000001" : ] 000000567564491.078816000000000000 ; 000000591633783.405589000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036208E1386C2F2 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_26_____Jiangsu_Guotai_International_Group_Co_Limited_20260321 >									
	//        < sjl264W1TCGsZ6xA43pwRa78tWIHrx325N2I9Ko5zz3OXHMz00dcM345RpOB40qN >									
	//        <  u =="0.000000000000000001" : ] 000000591633783.405589000000000000 ; 000000624611073.968743000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000386C2F23B914B3 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_27_____JIANGXI_TIME_CHEMICAL_Co_Limited_20260321 >									
	//        < P31mhk7B7S3sN886vU72D3Xn13XUOGTruwVyP34AVlh7GDZPWn7rZwd6vW51a6Xd >									
	//        <  u =="0.000000000000000001" : ] 000000624611073.968743000000000000 ; 000000646419055.828692000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B914B33DA5B72 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_28_____Jianshi_Yuantong_Bioengineering_Co_Limited_20260321 >									
	//        < 0ULfYoFA0fxj92E6u5ew9WA9Zf8yHyl5HI5VU3EYoSmAT9rdU7mKbO5Ez0mZh3C8 >									
	//        <  u =="0.000000000000000001" : ] 000000646419055.828692000000000000 ; 000000675548805.072676000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DA5B72406CE41 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_29_____Jiaxing_Nanyang_Wanshixing_Chemical_Co__Limited_20260321 >									
	//        < P1ZV6Fbc0ho8e6VdJ2etrE5XLo63094aks1NKTB7vfosVL4clkApe4fB1N71Cd0S >									
	//        <  u =="0.000000000000000001" : ] 000000675548805.072676000000000000 ; 000000702273970.831498000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000406CE4142F95C5 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_30_____Jinan_TaiFei_Science_Technology_Co_Limited_20260321 >									
	//        < k6Yw8VYIeCDiei8fyra039YdEkh218LxuynO2hvy97D6U26dZUfo2R5agFBknZud >									
	//        <  u =="0.000000000000000001" : ] 000000702273970.831498000000000000 ; 000000732013914.201187000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042F95C545CF6EF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIII_III_metadata_line_31_____Jinan_YSPharma_Biotechnology_Co_Limited_20260321 >									
	//        < k8JIDFcw8bAGp9B2x67b38B9QN5bodL1TgEn238c4hghH8jX3Bg7pX2C4ilO7bWs >									
	//        <  u =="0.000000000000000001" : ] 000000732013914.201187000000000000 ; 000000750548907.180150000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045CF6EF4793F2B >									
	//     < CHEMCHINA_PFIII_III_metadata_line_32_____JINCHANG_HOLDING_org_20260321 >									
	//        < 1zR3a540jxD56844n2GnyfO31wb49Qknj37Tz9h65t5VAL480hT3Oom9rPoy4plq >									
	//        <  u =="0.000000000000000001" : ] 000000750548907.180150000000000000 ; 000000772666489.519947000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004793F2B49AFED9 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_33_____JINCHANG_HOLDING_LIMITED_20260321 >									
	//        < Fy3Q1gfNEMunKc67KU19W0Tn9m8xXgVUTMnTDwAVaupVzr2L9613Ra1XMAeuNU7L >									
	//        <  u =="0.000000000000000001" : ] 000000772666489.519947000000000000 ; 000000795561481.757490000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049AFED94BDEE34 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_34_____Jinhua_huayi_chemical_Co__Limited_20260321 >									
	//        < P7qXcU6a45Da2JcJ6H09YVKZYSh0XVtyk17us5X2S84l21h7k5Z20j5m8reU5b4H >									
	//        <  u =="0.000000000000000001" : ] 000000795561481.757490000000000000 ; 000000819229712.446765000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BDEE344E20B9B >									
	//     < CHEMCHINA_PFIII_III_metadata_line_35_____Jinhua_Qianjiang_Fine_Chemical_Co_Limited_20260321 >									
	//        < p6PoRgWkAw62XrgL1nImN9SJ889R37B5MP79Gd99fgpm8mS6CK5YiN7vLAmSRaEi >									
	//        <  u =="0.000000000000000001" : ] 000000819229712.446765000000000000 ; 000000845645650.084142000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E20B9B50A5A55 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_36_____Jinjiangchem_Corporation_20260321 >									
	//        < HzGXhLz2UyIcSxqw51W9Op3626av8Bg62KVgFkWEcIc0NI6b397RC5p9D7FrQEAb >									
	//        <  u =="0.000000000000000001" : ] 000000845645650.084142000000000000 ; 000000865714725.218171000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050A5A55528F9D1 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_37_____Jiurui_Biology___Chemistry_Co_Limited_20260321 >									
	//        < M5PbzV2U6h93L326sGvkUGGAM64HKM3wNI7JdVp0kyjdMvgyQ02U2J6F001w3wg4 >									
	//        <  u =="0.000000000000000001" : ] 000000865714725.218171000000000000 ; 000000892204234.956589000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000528F9D15516547 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_38_____Jlight_Chemicals_org_20260321 >									
	//        < 7cO9HtcJz2Tb4mu6y18M8UE25eolK2WoWE3hAY4ZEAlanPxTn0f43CW5zO134H6a >									
	//        <  u =="0.000000000000000001" : ] 000000892204234.956589000000000000 ; 000000913719157.931334000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005516547572398C >									
	//     < CHEMCHINA_PFIII_III_metadata_line_39_____Jlight_Chemicals_Company_20260321 >									
	//        < 2JTr1Gg6yxR9phtVPPG699s83bPBBI2FiR7Twtv1918xuzitli5kW376345f74TF >									
	//        <  u =="0.000000000000000001" : ] 000000913719157.931334000000000000 ; 000000937207709.745002000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000572398C59610C3 >									
	//     < CHEMCHINA_PFIII_III_metadata_line_40_____JQC_China_Pharmaceutical_Co_Limited_20260321 >									
	//        < 4l580514jn9KHMwe5FV19vjgmX090dLxoe337MCeo2V470m85HTHqre5771J61FA >									
	//        <  u =="0.000000000000000001" : ] 000000937207709.745002000000000000 ; 000000960045161.637506000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000059610C35B8E9A4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
/**
 * Source Code first verified at https://etherscan.io on Saturday, March 23, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFVII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFVII_III_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFVII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1111698414476450000000000000					;	
										
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
	//     < CHEMCHINA_PFVII_III_metadata_line_1_____Taizhou_Creating_Chemical_Co_Limited_20260321 >									
	//        < g15Tj0Ir9aT9GL26vxA4ZM3dl8GPl4Hm5tl64oM92XPp4ID8isIzy5v4bQD8cZ08 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000037341219.298275900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000038FA6A >									
	//     < CHEMCHINA_PFVII_III_metadata_line_2_____Tetrahedron_Scientific_Inc_20260321 >									
	//        < mICb9IIzqz6x8tGYQcJLG8kz7drh7lp00C5MJ1jHFS38YMOqLaZWhOc5BJh1pNWp >									
	//        <  u =="0.000000000000000001" : ] 000000037341219.298275900000000000 ; 000000060248914.794551500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000038FA6A5BEEBB >									
	//     < CHEMCHINA_PFVII_III_metadata_line_3_____Tianjin_Boai_NKY_International_Limited_20260321 >									
	//        < 51X7fBB6Z531YvTFYEvFm0KIao0OyDZ4L5te30z0J8sEd4R1cKVSHeBmdKI1I7JF >									
	//        <  u =="0.000000000000000001" : ] 000000060248914.794551500000000000 ; 000000093436409.386181000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005BEEBB8E9299 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_4_____Tianjin_Boron_PharmaTech_Co__Limited_20260321 >									
	//        < J5zQUd96pCrG27O7F1ju7j86LhHswujBApr4UzJP91J6oSO3c192Logg0w0V99ju >									
	//        <  u =="0.000000000000000001" : ] 000000093436409.386181000000000000 ; 000000119329086.293249000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008E9299B614ED >									
	//     < CHEMCHINA_PFVII_III_metadata_line_5_____TianJin_HuiQuan_Chemical_Industry_Co_Limited_20260321 >									
	//        < v85o6RQ2HKnFyjLEZK1N4D5p5pv7fFTbFI9sF8S3Q4LD1X62uzvFak4616s2Z9HC >									
	//        <  u =="0.000000000000000001" : ] 000000119329086.293249000000000000 ; 000000144841747.396994000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B614EDDD02CF >									
	//     < CHEMCHINA_PFVII_III_metadata_line_6_____Tianjin_McEIT_Co_Limited_20260321 >									
	//        < 313T2h9az6gw064cdoYzJIlJM4SFup8f2w7jX08ucLYt7P9UFBs0COn4tJ0f2k1T >									
	//        <  u =="0.000000000000000001" : ] 000000144841747.396994000000000000 ; 000000165102274.002683000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DD02CFFBED13 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_7_____Tianjin_Norland_Biotech_org_20260321 >									
	//        < 3N7MWs2hvYN0421Dn591n7H3rKn1k0J9fev0uFG8xhlTa0onQ6dqE8l8TyY01J1B >									
	//        <  u =="0.000000000000000001" : ] 000000165102274.002683000000000000 ; 000000205036590.103095000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FBED13138DC6B >									
	//     < CHEMCHINA_PFVII_III_metadata_line_8_____Tianjin_Norland_Biotech_Co_Limited_20260321 >									
	//        < 73hCU5bz4k96z8S185oM3dIcA1599G6m09IdnQmqDFzqJ98pb3Ut6979o78hN2cu >									
	//        <  u =="0.000000000000000001" : ] 000000205036590.103095000000000000 ; 000000229243458.023889000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000138DC6B15DCC3A >									
	//     < CHEMCHINA_PFVII_III_metadata_line_9_____Tianjin_Tiandingren_Technology_Co_Limited_20260321 >									
	//        < T23X3qOMc554oAM66hkEeth7H8RAN3zt05j6eb8M926Cj31kl8FJs0RF2A7vRcFr >									
	//        <  u =="0.000000000000000001" : ] 000000229243458.023889000000000000 ; 000000267194989.095047000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015DCC3A197B50B >									
	//     < CHEMCHINA_PFVII_III_metadata_line_10_____TOP_FINE_CHEM_20260321 >									
	//        < ACEB4JHijy2a31N8QyE439hI47VEjK0HXCLbY21Bi5Cm0uXYf8IBKie5o4U1gsUS >									
	//        <  u =="0.000000000000000001" : ] 000000267194989.095047000000000000 ; 000000289927020.590213000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000197B50B1BA64BE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVII_III_metadata_line_11_____Trust_We_Co__Limited_20260321 >									
	//        < xv9oo4As28ro2OjF3tV3GKrms8vR4OY5C1861x476296D3RX1eP9HufTOEbrbYWk >									
	//        <  u =="0.000000000000000001" : ] 000000289927020.590213000000000000 ; 000000324559833.320909000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BA64BE1EF3D2F >									
	//     < CHEMCHINA_PFVII_III_metadata_line_12_____Unispec_Chemicals_Co__20260321 >									
	//        < pk8BRZ1EUuQF6nqakelIdJ77w69Hdq54C1221q96aVO1wM5DEzyfpeEyovvb1fe5 >									
	//        <  u =="0.000000000000000001" : ] 000000324559833.320909000000000000 ; 000000361353578.849440000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EF3D2F22761BE >									
	//     < CHEMCHINA_PFVII_III_metadata_line_13_____Varnor_Chemical_Co_Limited_20260321 >									
	//        < VwyKWLf5DkOfkJG0wI57leMjbIRd9h4r67m50DB11ys5t09Gsl5s4Z0f5uxC80iK >									
	//        <  u =="0.000000000000000001" : ] 000000361353578.849440000000000000 ; 000000400518000.925832000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022761BE2632458 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_14_____VEGSCI,_inc__20260321 >									
	//        < 5b5RLfq6Xz3sXUkbZLoHDHm3AZbZM25QUC8c3Ba7vnAP2pcoI20y3hfmdk1356Hv >									
	//        <  u =="0.000000000000000001" : ] 000000400518000.925832000000000000 ; 000000427187092.874072000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000263245828BD5F5 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_15_____Vesino_Industrial_Co__Limited_20260321 >									
	//        < Fs6yd3dxPR907672z7iq532NxG37Tdr87Um87lkyg755nw6Pmna5o9g0ft5lZOO8 >									
	//        <  u =="0.000000000000000001" : ] 000000427187092.874072000000000000 ; 000000449857362.078717000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028BD5F52AE6D88 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_16_____Volant_Chem_org_20260321 >									
	//        < eeO1h7b77s5n1inT02e7IYd9Smdh7XpI69HJ44JsRxr1iJA4b4YRHzm2Iom51523 >									
	//        <  u =="0.000000000000000001" : ] 000000449857362.078717000000000000 ; 000000476504845.064343000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AE6D882D716B5 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_17_____Volant_Chem_Corp__20260321 >									
	//        < 8XFjIXr8A3s7J61NDUWAZjAbH0KKAvGn2ZZ6xjAqTAE3QA55O8ScNjs979pr96Jb >									
	//        <  u =="0.000000000000000001" : ] 000000476504845.064343000000000000 ; 000000501292827.305260000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D716B52FCE983 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_18_____Win_Win_chemical_Co_Limited_20260321 >									
	//        < aV4D9oc3tkD9EbemxHnSL21P0lna6Fv2tW2t3Fd7Ha0R3296yokCZK99Ne4orIyJ >									
	//        <  u =="0.000000000000000001" : ] 000000501292827.305260000000000000 ; 000000524453520.136198000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FCE98332040A8 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_19_____WJF_Chemicals_Co__20260321 >									
	//        < Q7a7zW7GZ2s5Bptkyl5EAxxb733q8X8RT42OswX51pDjScn539s3dm5bMNGxlBUk >									
	//        <  u =="0.000000000000000001" : ] 000000524453520.136198000000000000 ; 000000554963913.873396000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032040A834ECEC7 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_20_____Wuhan_Bright_Chemical_Co__Limited_20260321 >									
	//        < 57M5X6zLI806630p551cP2653Jr88aaNqd147yxUm46u0k7z29C97W0fTq0BA10C >									
	//        <  u =="0.000000000000000001" : ] 000000554963913.873396000000000000 ; 000000577502096.526163000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034ECEC737132C2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVII_III_metadata_line_21_____Wuhan_Yuancheng_Chemical_Manufactory_org_20260321 >									
	//        < XOwW5i6hfzis2cq7z1ctIRypRDft1t72ZWa2Gqko6X7918J7l3ZaP5sq5yHm57HV >									
	//        <  u =="0.000000000000000001" : ] 000000577502096.526163000000000000 ; 000000600894207.791464000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037132C2394E44D >									
	//     < CHEMCHINA_PFVII_III_metadata_line_22_____Wuhan_Yuancheng_Chemical_Manufactory_20260321 >									
	//        < Z2997TBRz8lb2M55t7Hh4478JfNUm4QMAHzFBr55AlBu9E9990emNE8bDbO50p45 >									
	//        <  u =="0.000000000000000001" : ] 000000600894207.791464000000000000 ; 000000630084131.449974000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000394E44D3C16E9D >									
	//     < CHEMCHINA_PFVII_III_metadata_line_23_____Wuhu_Foman_Biopharma_Co_Limited_20260321 >									
	//        < ZOHpAWBc8f9bRsn1p6p06dA2P51MnHsDza309sX5G4z7OC2jU33EDy5v8TBnXeYq >									
	//        <  u =="0.000000000000000001" : ] 000000630084131.449974000000000000 ; 000000662511544.677151000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C16E9D3F2E992 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_24_____Xi_an_Caijing_Opto_Electrical_Science___Technology_Co__Limited_20260321 >									
	//        < A2tBtieeDhh9jN6aK5Ti0oNCWN2hu28PiDyU23BJ72W81WD1IH2KU767r1iRcvWn >									
	//        <  u =="0.000000000000000001" : ] 000000662511544.677151000000000000 ; 000000688450609.630029000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F2E99241A7E05 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_25_____XIAMEN_EQUATION_CHEMICAL_org_20260321 >									
	//        < F0z21p80VtGgLb1QQ41BNZEn33cLqg0u5de2gjrtLT4bg2TJ3A58TOy7xFpYLKOD >									
	//        <  u =="0.000000000000000001" : ] 000000688450609.630029000000000000 ; 000000718858888.683267000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041A7E05448E441 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_26_____XIAMEN_EQUATION_CHEMICAL_Co_Limited_20260321 >									
	//        < Scc6I756ojQz3r12u5FB8ba5ii4fOIV46SQnYms2l1Z901VPDOo3Q6AjMQ0fe4Xo >									
	//        <  u =="0.000000000000000001" : ] 000000718858888.683267000000000000 ; 000000753577264.915395000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000448E44147DDE1E >									
	//     < CHEMCHINA_PFVII_III_metadata_line_27_____Yacoo_Chemical_Reagent_Co_Limited_20260321 >									
	//        < CZBHELxDvug11YVP43o3m5W9sH32M3iMN12XcS7hmL3Dj9gn9drt72Ksyq1Mj1dw >									
	//        <  u =="0.000000000000000001" : ] 000000753577264.915395000000000000 ; 000000793522649.460104000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047DDE1E4BAD1C9 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_28_____Yantai_Taroke_Bio_engineering_Co_Limited_20260321 >									
	//        < T2sA7p9V78rH2Koxgi635MfKOP14Avdp53B4J9qkmrav4T4X0GATBHmlK8gJQ87z >									
	//        <  u =="0.000000000000000001" : ] 000000793522649.460104000000000000 ; 000000813374296.085849000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BAD1C94D91C56 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_29_____Zehao_Industry_Co__Limited_20260321 >									
	//        < 60tEEEU45HEAk1pZ2lsWhr723C3xA3FR6HM05jT6Q42q20RMtH5i54pS3rOQ0c6m >									
	//        <  u =="0.000000000000000001" : ] 000000813374296.085849000000000000 ; 000000839584964.317110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004D91C565011AE0 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_30_____Zeroschem_org_20260321 >									
	//        < pg92bDmtUK6UN0mUlswmxw7N7i6h861E14HlYBY422QUyzm0ATXTJaQpT9t1r2P4 >									
	//        <  u =="0.000000000000000001" : ] 000000839584964.317110000000000000 ; 000000863583967.499377000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005011AE0525B97D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVII_III_metadata_line_31_____Zeroschem_Co_Limited_20260321 >									
	//        < 8c9TBgdwYpFPF537lux8uwc2kyrGeP2F27McrbL3APnP3o6uDSmTqkFhpFLCrCmi >									
	//        <  u =="0.000000000000000001" : ] 000000863583967.499377000000000000 ; 000000883560290.034386000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000525B97D54434BD >									
	//     < CHEMCHINA_PFVII_III_metadata_line_32_____ZHANGJIAGANG_HUACHANG_PHARMACEUTICAL_Co__Limited_20260321 >									
	//        < oL62KH0pfLiLCcS524XE1PmKUhLTW54MA8Bn31edEmov1euTmDL87ylBU0S09Dp4 >									
	//        <  u =="0.000000000000000001" : ] 000000883560290.034386000000000000 ; 000000910513417.154828000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000054434BD56D554E >									
	//     < CHEMCHINA_PFVII_III_metadata_line_33_____Zheda_Panaco_Chemical_Engineering_Co___Ltd___ZhedaChem__20260321 >									
	//        < 756EtUM7mH1ycwx3Vatd4317WeOcg3wu9LL65H1i0FhJ3av36YMuhaWE7zkeclJh >									
	//        <  u =="0.000000000000000001" : ] 000000910513417.154828000000000000 ; 000000939778089.218477000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000056D554E599FCD1 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_34_____Zhejiang_J_C_Biological_Technology_Co_Limited_20260321 >									
	//        < by386w42y0ptUnZ1KOJo2R01a3zC7gj681dXLUmA7kivvlh43806dsSUI49hduAj >									
	//        <  u =="0.000000000000000001" : ] 000000939778089.218477000000000000 ; 000000966161422.280793000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000599FCD15C23ECE >									
	//     < CHEMCHINA_PFVII_III_metadata_line_35_____Zhengzhou_Meitong_Pharmaceutical_Technology_20260321 >									
	//        < 996psFIco8D3wZCmlBavqOwVvq0Ti35I068Gg38QfoB46RobkXkTxAUkXMHC7Q58 >									
	//        <  u =="0.000000000000000001" : ] 000000966161422.280793000000000000 ; 000000987566021.712821000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C23ECE5E2E7FA >									
	//     < CHEMCHINA_PFVII_III_metadata_line_36_____ZHIWE_ChemTech_org_20260321 >									
	//        < 3xS9b38ljBpHE7q3R39BEKNqL7y0oba79Hh9c736Qwh6T64wmDAc16cDY1sEaLUQ >									
	//        <  u =="0.000000000000000001" : ] 000000987566021.712821000000000000 ; 000001010835240.735920000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E2E7FA6066984 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_37_____ZHIWE_ChemTech_Co_Limited_20260321 >									
	//        < Qg6Mso2p9HlM9vzr4rNzBFLqcOqB44sARcj46EN1fl5L5gmhFrk4tanMaL4CLL8L >									
	//        <  u =="0.000000000000000001" : ] 000001010835240.735920000000000000 ; 000001046933990.693000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000606698463D7E97 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_38_____Zhongtian_Kosen_Corporation_Limited_20260321 >									
	//        < At0NP8P9iCSeeoaf7F4yU1EDSwKdI34BZ4Z4Pe4TKvF4225yyp88b08B0bZhcy4h >									
	//        <  u =="0.000000000000000001" : ] 000001046933990.693000000000000000 ; 000001067766466.757260000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000063D7E9765D4847 >									
	//     < CHEMCHINA_PFVII_III_metadata_line_39_____Zibo_Honors_chemical_Co_Limited_20260321 >									
	//        < rGiu2QIi3g7VgwLv5uJ3gNfqrJ7v3x7ht1B1rx8fbcGGe9W17ff0KNEpAh1872d2 >									
	//        <  u =="0.000000000000000001" : ] 000001067766466.757260000000000000 ; 000001088136943.247190000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000065D484767C5D7E >									
	//     < CHEMCHINA_PFVII_III_metadata_line_40_____Zouping_Mingxing_Chemical_Co__Limited_20260321 >									
	//        < TWL0L6T8YlllRjo3J9OYrH1s69TG34S99i7X8Spe05Z9l0Y3YFZAWs0Fqx14hq1f >									
	//        <  u =="0.000000000000000001" : ] 000001088136943.247190000000000000 ; 000001111698414.476450000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000067C5D7E6A05131 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
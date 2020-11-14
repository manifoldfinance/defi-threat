/**
 * Source Code first verified at https://etherscan.io on Friday, March 22, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFII_III_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1233471162710430000000000000					;	
										
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
	//     < CHEMCHINA_PFII_III_metadata_line_1_____CHANGZHOU_WUJIN_LINCHUAN_CHEMICAL_Co_Limited_20260321 >									
	//        < 90inv6k06vpKywSfuJ99VU5qD48l2Rt0V19c4i60Ccb3GartvDo2Dr67zGy1P59u >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000028828776.266181900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002BFD3E >									
	//     < CHEMCHINA_PFII_III_metadata_line_2_____Chem_Stone_Co__Limited_20260321 >									
	//        < C639QNO430wzv1R1A2QHquo3pd0woH47o771XIYLl7BH733y7jgCwb9lFp5sOdm1 >									
	//        <  u =="0.000000000000000001" : ] 000000028828776.266181900000000000 ; 000000054710198.219915200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002BFD3E537B2C >									
	//     < CHEMCHINA_PFII_III_metadata_line_3_____Chemleader_Biomedical_Co_Limited_20260321 >									
	//        < saGKT78eLnH1JavPkwVZ0K1L41oC8bD620fPrY2r17EeyZ6MLWc3CJoEF3vHgQja >									
	//        <  u =="0.000000000000000001" : ] 000000054710198.219915200000000000 ; 000000078410385.399819100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000537B2C77A50F >									
	//     < CHEMCHINA_PFII_III_metadata_line_4_____Chemner_Pharma_20260321 >									
	//        < lB355RS4uh4VZ5Zk9F6rMz1AAqS9z6HoRm5T0w5ALaOGPa98b3qTNX84vsRgHnfs >									
	//        <  u =="0.000000000000000001" : ] 000000078410385.399819100000000000 ; 000000098703985.305163400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000077A50F969C3F >									
	//     < CHEMCHINA_PFII_III_metadata_line_5_____Chemtour_Biotech__Suzhou__org_20260321 >									
	//        < ax8iAxb4Gu0YMwy80o5WxquC8EG1RvNZ08Zk32tM5jxzxXUh2raCJl8y84g5dEho >									
	//        <  u =="0.000000000000000001" : ] 000000098703985.305163400000000000 ; 000000123580423.736262000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000969C3FBC919A >									
	//     < CHEMCHINA_PFII_III_metadata_line_6_____Chemtour_Biotech__Suzhou__Co__Ltd_20260321 >									
	//        < BOZo1vY3wqHj72Mp6wzyL4D70856MCk88UpR9lwQ99jK7tyZ0O0X3d537p5dDtBH >									
	//        <  u =="0.000000000000000001" : ] 000000123580423.736262000000000000 ; 000000152628942.944829000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BC919AE8E4AE >									
	//     < CHEMCHINA_PFII_III_metadata_line_7_____Chemvon_Biotechnology_Co__Limited_20260321 >									
	//        < lsQwJjD8b61I9hJKx3WoWc59QMp559Z4BLWudv0s3TKhp2Yh1uLbDKnJh6XO7720 >									
	//        <  u =="0.000000000000000001" : ] 000000152628942.944829000000000000 ; 000000173214715.957492000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E8E4AE1084E00 >									
	//     < CHEMCHINA_PFII_III_metadata_line_8_____Chengdu_Aslee_Biopharmaceuticals,_inc__20260321 >									
	//        < i66DKrWqI0DV550V34B5Zp8hImO1b00CA5HGcKoKajj13YS6Sxj2R4ZMZyxrUK13 >									
	//        <  u =="0.000000000000000001" : ] 000000173214715.957492000000000000 ; 000000213990912.771307000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001084E001468633 >									
	//     < CHEMCHINA_PFII_III_metadata_line_9_____Chuxiong_Yunzhi_Phytopharmaceutical_Co_Limited_20260321 >									
	//        < CL39PRRUp8H09ZQPB1k231Zv5jdADczo7Uq93VxoHYs9oUD1J1sMrzJ2n8sb7ihG >									
	//        <  u =="0.000000000000000001" : ] 000000213990912.771307000000000000 ; 000000236255451.388892000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014686331687F49 >									
	//     < CHEMCHINA_PFII_III_metadata_line_10_____Conier_Chem_Pharma__Limited_20260321 >									
	//        < 2y2l4Zyq16KrL68zFarA8EBFWlKPzub9srnV2Wjx624bg5wuvpkPoAeT5iU3tXG6 >									
	//        <  u =="0.000000000000000001" : ] 000000236255451.388892000000000000 ; 000000271522148.537003000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001687F4919E4F57 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFII_III_metadata_line_11_____Cool_Pharm_Ltd_20260321 >									
	//        < I33LL2449666bDpPTHqA0ZoyNiTNqEMtzObaREfvu0TT1lEE5XvzOWB1lTh0V5E6 >									
	//        <  u =="0.000000000000000001" : ] 000000271522148.537003000000000000 ; 000000298389822.405030000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019E4F571C74E86 >									
	//     < CHEMCHINA_PFII_III_metadata_line_12_____Coresyn_Pharmatech_Co__Limited_20260321 >									
	//        < G11iqs5klLAsr14s69MycBxYgXn8fVYoGO7WD1D2w1W7h6LV353756yyefY7zhJs >									
	//        <  u =="0.000000000000000001" : ] 000000298389822.405030000000000000 ; 000000337805610.142901000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C74E862037351 >									
	//     < CHEMCHINA_PFII_III_metadata_line_13_____Dalian_Join_King_Fine_Chemical_org_20260321 >									
	//        < 2fFU3I4LyVo9z5s6m8Olk9dF8AVhrD9g0GTRQRaCo87525SlqSM70J37OeP0WuMw >									
	//        <  u =="0.000000000000000001" : ] 000000337805610.142901000000000000 ; 000000371937024.847605000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000203735123787E6 >									
	//     < CHEMCHINA_PFII_III_metadata_line_14_____Dalian_Join_King_Fine_Chemical_Co_Limited_20260321 >									
	//        < 2p5aZi203bJm7Lf8AKhFFB75f664L7dV22lMHh45QL09161RzMv6Vfv5Utk8o9k2 >									
	//        <  u =="0.000000000000000001" : ] 000000371937024.847605000000000000 ; 000000396838562.938544000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023787E625D8710 >									
	//     < CHEMCHINA_PFII_III_metadata_line_15_____Dalian_Richfortune_Chemicals_Co_Limited_20260321 >									
	//        < x32Kl53H0wLHUC8Z55hsNqO88pgSN34SQlW7ctGmb52Jr7515q6uCtlChd6768FP >									
	//        <  u =="0.000000000000000001" : ] 000000396838562.938544000000000000 ; 000000430224959.851389000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025D871029078A0 >									
	//     < CHEMCHINA_PFII_III_metadata_line_16_____Daming_Changda_Co_Limited__LLBCHEM__20260321 >									
	//        < 478mLl5Atzw0PlH2pobeHZ1I0550K2Pv0pm7rKAtzDnRjgmSSjKttC89x3cYF1pp >									
	//        <  u =="0.000000000000000001" : ] 000000430224959.851389000000000000 ; 000000463983042.405403000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029078A02C3FB60 >									
	//     < CHEMCHINA_PFII_III_metadata_line_17_____DATO_Chemicals_Co_Limited_20260321 >									
	//        < G17MZ6J8k3E7hOWdLFcKmn87jIGTJ9c84oiA9UF59I1vSGpE47gTXZ8drLLw5a9m >									
	//        <  u =="0.000000000000000001" : ] 000000463983042.405403000000000000 ; 000000494576450.282974000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C3FB602F2A9ED >									
	//     < CHEMCHINA_PFII_III_metadata_line_18_____DC_Chemicals_20260321 >									
	//        < 5VAiDN5t7X9lj9Z6JD5M9FgK2xk5lM6uc7F50R3E551X9PFa91c2BzjQYh3iUxB9 >									
	//        <  u =="0.000000000000000001" : ] 000000494576450.282974000000000000 ; 000000531483843.462587000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F2A9ED32AFAE0 >									
	//     < CHEMCHINA_PFII_III_metadata_line_19_____Depont_Molecular_Co_Limited_20260321 >									
	//        < 5GW1Z5Gs45u3EUOZ1qg1AI66OZA86z4yC2eab3J18Vh0hcbV2xjq8SC4ZKw1Tmu2 >									
	//        <  u =="0.000000000000000001" : ] 000000531483843.462587000000000000 ; 000000571035765.002583000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032AFAE036754D9 >									
	//     < CHEMCHINA_PFII_III_metadata_line_20_____DSL_Chemicals_Co_Ltd_20260321 >									
	//        < 8hyfD6bZ9ng9vr2X3A9pOHjqdqZOEh21A6WO06W1JwhGgNH9CwrdOb136O4mN8XR >									
	//        <  u =="0.000000000000000001" : ] 000000571035765.002583000000000000 ; 000000610557638.515528000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036754D93A3A314 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFII_III_metadata_line_21_____Elsa_Biotechnology_org_20260321 >									
	//        < 3GyBK5S56PGPxzWWp3P9rU696dR43z9I153072Nwk6z2k0Yagx89G62dMY1B85I1 >									
	//        <  u =="0.000000000000000001" : ] 000000610557638.515528000000000000 ; 000000647436682.130835000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A3A3143DBE8F4 >									
	//     < CHEMCHINA_PFII_III_metadata_line_22_____Elsa_Biotechnology_Co_Limited_20260321 >									
	//        < 7gy21U9bN7XTnZDgAOXHq2G22aCR6d4h961NKc874mSDtFK7r2yTTX9N5C1s30Uv >									
	//        <  u =="0.000000000000000001" : ] 000000647436682.130835000000000000 ; 000000683536687.913348000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DBE8F4412FE85 >									
	//     < CHEMCHINA_PFII_III_metadata_line_23_____Enze_Chemicals_Co_Limited_20260321 >									
	//        < 5d1LA685AcPBYH7r3g7Bl8D4s2VU84D9i9cS3KLa4x6W0Xj3chah0f4jiENc33aW >									
	//        <  u =="0.000000000000000001" : ] 000000683536687.913348000000000000 ; 000000714103411.586029000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000412FE85441A2A5 >									
	//     < CHEMCHINA_PFII_III_metadata_line_24_____EOS_Med_Chem_20260321 >									
	//        < WYr2JWGnOIleMs6q09tzK7hcz6z6G83gfZ3e8963M4PwR7AOtO9qaitchSHU9D0f >									
	//        <  u =="0.000000000000000001" : ] 000000714103411.586029000000000000 ; 000000740748556.299094000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000441A2A546A4AE8 >									
	//     < CHEMCHINA_PFII_III_metadata_line_25_____EOS_Med_Chem_20260321 >									
	//        < 377MLWVf6Rp604899QJ26uFfw9Sh0lRbIIYgW17bh3l7c9mG23l888xAG4IcKZw9 >									
	//        <  u =="0.000000000000000001" : ] 000000740748556.299094000000000000 ; 000000761416331.716395000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046A4AE8489D441 >									
	//     < CHEMCHINA_PFII_III_metadata_line_26_____ETA_ChemTech_Co_Ltd_20260321 >									
	//        < 1hK731zrr8pM3X52cXELrD3i2E8UmbvzJmmq2YWA5Z92w919CQiNJXO7pu5FE0S8 >									
	//        <  u =="0.000000000000000001" : ] 000000761416331.716395000000000000 ; 000000790456256.116042000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000489D4414B623FA >									
	//     < CHEMCHINA_PFII_III_metadata_line_27_____FEIMING_CHEMICAL_LIMITED_20260321 >									
	//        < D79H04w6nkGWVAkJ7zv4WX656b97V3vvl2CRBZkShqi0aHQ4ak8kkKrPXCJaaOk1 >									
	//        <  u =="0.000000000000000001" : ] 000000790456256.116042000000000000 ; 000000828709478.825214000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B623FA4F082A4 >									
	//     < CHEMCHINA_PFII_III_metadata_line_28_____FINETECH_INDUSTRY_LIMITED_20260321 >									
	//        < 8Q90Xf2liNgk4En7m39Od3AA895tCuLr8FTP9MxkDV5Yjsz06zKX6IlapPfy7Y8W >									
	//        <  u =="0.000000000000000001" : ] 000000828709478.825214000000000000 ; 000000869525017.163127000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004F082A452ECA36 >									
	//     < CHEMCHINA_PFII_III_metadata_line_29_____Finetech_Industry_Limited_20260321 >									
	//        < Yp9Ab562I2wr9lq8Ttm7XtJ48KeD98R97KI93Qb8S0OeoO5v99Favd2FOYiD5St5 >									
	//        <  u =="0.000000000000000001" : ] 000000869525017.163127000000000000 ; 000000906849388.298491000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052ECA36567BE0B >									
	//     < CHEMCHINA_PFII_III_metadata_line_30_____Fluoropharm_org_20260321 >									
	//        < uXI2tJI7xf6hZ82LHm3199T35Tqvq8zw18n3EAhl742918xqhHZ377kO5OVZ7We8 >									
	//        <  u =="0.000000000000000001" : ] 000000906849388.298491000000000000 ; 000000942093128.459681000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000567BE0B59D8521 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFII_III_metadata_line_31_____Fluoropharm_Co_Limited_20260321 >									
	//        < 96Czi3gK1g831N4hX0VreSJt0mmZ4OTi6Qn7i7LU714w1Z344PrXDMPHne3Mf7C0 >									
	//        <  u =="0.000000000000000001" : ] 000000942093128.459681000000000000 ; 000000966362793.623932000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000059D85215C28D77 >									
	//     < CHEMCHINA_PFII_III_metadata_line_32_____Fond_Chemical_Co_Limited_20260321 >									
	//        < 7k2f1h2i6TSUmiu6XqHyq9HND90hTsYk0d670N2I9IAL4z2l3A2gCRLGdAp72EUO >									
	//        <  u =="0.000000000000000001" : ] 000000966362793.623932000000000000 ; 000000986269415.126458000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C28D775E0ED7E >									
	//     < CHEMCHINA_PFII_III_metadata_line_33_____Gansu_Research_Institute_of_Chemical_Industry_20260321 >									
	//        < N5ak837JewyNyKVNSCJB9472s262m52r7JIW3vOyKEyq29R8GCBnMcdXi5TFe7P7 >									
	//        <  u =="0.000000000000000001" : ] 000000986269415.126458000000000000 ; 000001012621491.947880000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E0ED7E6092345 >									
	//     < CHEMCHINA_PFII_III_metadata_line_34_____GL_Biochem__Shanghai__Ltd__20260321 >									
	//        < 2BjwD9FYALI1ec44oA29XnS32oW9l8G1qWUb5s72944Br1dja81mSArMo42s1uul >									
	//        <  u =="0.000000000000000001" : ] 000001012621491.947880000000000000 ; 000001050963779.238490000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006092345643A4BA >									
	//     < CHEMCHINA_PFII_III_metadata_line_35_____Guangzhou_Topwork_Chemical_Co__Limited_20260321 >									
	//        < AuPqPNpdMo0gCtE7Ph9E3325b0nP6NfP55vpRO6is4i8xxQG0W558Xzgg9w00Ru8 >									
	//        <  u =="0.000000000000000001" : ] 000001050963779.238490000000000000 ; 000001070951039.987690000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000643A4BA6622440 >									
	//     < CHEMCHINA_PFII_III_metadata_line_36_____Hallochem_Pharma_Co_Limited_20260321 >									
	//        < nF5RqErwV05huis3PVaVutw9DB71SVi245ZmNjIfy9KI92Mv3QP7pY0IcA9c6B77 >									
	//        <  u =="0.000000000000000001" : ] 000001070951039.987690000000000000 ; 000001101778732.521560000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000066224406912E51 >									
	//     < CHEMCHINA_PFII_III_metadata_line_37_____Hanghzou_Fly_Source_Chemical_Co_Limited_20260321 >									
	//        < Z9dDUR2Urz0I5rqgPnR0NdxooqCq2VIPUg92LAv4qg6Z182bT7lb427z42fiAFmG >									
	//        <  u =="0.000000000000000001" : ] 000001101778732.521560000000000000 ; 000001132446349.283150000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006912E516BFF9DB >									
	//     < CHEMCHINA_PFII_III_metadata_line_38_____Hangzhou_Best_Chemicals_Co__Limited_20260321 >									
	//        < kT5AmrOHPr7pBIQ5jTW78EBzI1iq1395Jp9MA4x3Y0AJSsAk7gWt3sxX1a8rS451 >									
	//        <  u =="0.000000000000000001" : ] 000001132446349.283150000000000000 ; 000001162839467.026950000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006BFF9DB6EE5A2B >									
	//     < CHEMCHINA_PFII_III_metadata_line_39_____Hangzhou_Dayangchem_Co__Limited_20260321 >									
	//        < 780934dZ775p8uTOiMs9pM0p1z321p2FZ010ciPM8S6N79KY8k64MOZqT9ew7gA6 >									
	//        <  u =="0.000000000000000001" : ] 000001162839467.026950000000000000 ; 000001197409918.788960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006EE5A2B7231A40 >									
	//     < CHEMCHINA_PFII_III_metadata_line_40_____Hangzhou_Dayangchem_org_20260321 >									
	//        < 6U019BV0D221vlyYwZt00y237lsir091Orb1h91l9Fp0o1awG4f8kETOw4e0ehFY >									
	//        <  u =="0.000000000000000001" : ] 000001197409918.788960000000000000 ; 000001233471162.710430000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007231A4075A20AC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
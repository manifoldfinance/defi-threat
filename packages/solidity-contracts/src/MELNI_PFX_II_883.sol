/**
 * Source Code first verified at https://etherscan.io on Monday, March 18, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
										
	contract	MELNI_PFX_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	MELNI_PFX_II_883		"	;
		string	public		symbol =	"	MELNI_PFX_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		724220230077302000000000000					;	
										
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
	//     < MELNI_PFX_II_metadata_line_1_____A_Melnichenko_pp_org_20240316 >									
	//        < 57Dt1DIql2U09EgvNK291XsjMr26M08DI50X6miMsId6HcG4mIe4BoiOBu8d0U1r >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000019406005.853491200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002036AF >									
	//     < MELNI_PFX_II_metadata_line_2_____ASY_admin_org_20240316 >									
	//        < y8LqvBDVh6Td0aN0R7Z2AKfi9Pw63iuxAh541q3jyP2oOl14gTH4pf1t4eOeFF6r >									
	//        <  u =="0.000000000000000001" : ] 000000019406005.853491200000000000 ; 000000040552669.259792300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002036AF3A3B40 >									
	//     < MELNI_PFX_II_metadata_line_3_____AMY_admin_org_20240316 >									
	//        < xMM5B7s0JE7W4AqcXGB15be0yLr5x66fj4QgsA1T9DD7yDWqCgtJxNySlKP58CgP >									
	//        <  u =="0.000000000000000001" : ] 000000040552669.259792300000000000 ; 000000056774714.239772500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003A3B40534BF6 >									
	//     < MELNI_PFX_II_metadata_line_4_____ASY_infra_org_20240316 >									
	//        < 60x92FjNAL1xYR21i7HYndhfYIiq98LkCNPwSCZ1Kt0vueoM9dGBmUTw6KzNJq3y >									
	//        <  u =="0.000000000000000001" : ] 000000056774714.239772500000000000 ; 000000080532885.390695100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000534BF672AC51 >									
	//     < MELNI_PFX_II_metadata_line_5_____AMY_infra_org_20240316 >									
	//        < AZyh4VXXP28Yvwrg4us0J5y6T2wyMYX192LW1Qv498720ZaXosG6xZ4u6T1uf75H >									
	//        <  u =="0.000000000000000001" : ] 000000080532885.390695100000000000 ; 000000094259901.383446400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000072AC51945103 >									
	//     < MELNI_PFX_II_metadata_line_6_____Donalink_Holding_Limited_chy_AB_20240316 >									
	//        < oqnNeNFX47g8mcOzM3aLeYZMDiNMS8zyXEGci3u82Q73Ng3DGmMC5fr8Wzsmmz71 >									
	//        <  u =="0.000000000000000001" : ] 000000094259901.383446400000000000 ; 000000112664205.451924000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000945103B5C94E >									
	//     < MELNI_PFX_II_metadata_line_7_____Donalink_Holding_org_russ_PL_20240316 >									
	//        < fMImn73SVjyfLLd9g2gZos22ZGdY2177YwE3ewuk7TQRIn9132BhcK1WS1dz6k4O >									
	//        <  u =="0.000000000000000001" : ] 000000112664205.451924000000000000 ; 000000128419774.155238000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B5C94EDA2D33 >									
	//     < MELNI_PFX_II_metadata_line_8_____Russky_Vlad_RSO_admin_org_20240316 >									
	//        < 6XCuNDAAgUQGDH42wVHMF02SxqrQ09qzDMKJS0dWP1j257fy304Tqjr9dMDPHulX >									
	//        <  u =="0.000000000000000001" : ] 000000128419774.155238000000000000 ; 000000142305425.194933000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DA2D33EF3B03 >									
	//     < MELNI_PFX_II_metadata_line_9_____RVR_ITB_garantia_org_20240316 >									
	//        < q4076r3xCFKB8PDCjH3aSFg78GoIypYO0OQMzpvlQid2hmHQ0b5rQemYy2O5XYTi >									
	//        <  u =="0.000000000000000001" : ] 000000142305425.194933000000000000 ; 000000162383982.760306000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EF3B0310B2D65 >									
	//     < MELNI_PFX_II_metadata_line_10_____RVR_ITN3_garantia_org_20240316 >									
	//        < qBq6F9677JnMZ28s11u5Qt52hgQr8IZHcd56KhNsYIFu1C8b2uIfOjOjtVeHqBA3 >									
	//        <  u =="0.000000000000000001" : ] 000000162383982.760306000000000000 ; 000000179883289.240947000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010B2D6512BAC2C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < MELNI_PFX_II_metadata_line_11_____RVR_LeChiffre_garantia_org_20240316 >									
	//        < afi29aVDCDS181111EnnE9MvrC6pvtq0N2d6TIdj7yXRu7g9o5YNdn5tr5JNDSX8 >									
	//        <  u =="0.000000000000000001" : ] 000000179883289.240947000000000000 ; 000000202528059.899482000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012BAC2C13F8CAA >									
	//     < MELNI_PFX_II_metadata_line_12_____Far_East_Dev_Corp_20240316 >									
	//        < 88ajaV1NRzq97ewUgG6oencwxrb90Q492q765Tx2lOhFyKAoMS714wAJ8HUQHG8h >									
	//        <  u =="0.000000000000000001" : ] 000000202528059.899482000000000000 ; 000000219971198.140812000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013F8CAA15F80D4 >									
	//     < MELNI_PFX_II_metadata_line_13_____Trans_Baïkal_geo_org_20240316 >									
	//        < 2BeF9Gn0NE072x9s6HzG0Aglh3rzHht9j5Mr7466nhLB9Xhf6i14840iseIAYh8L >									
	//        <  u =="0.000000000000000001" : ] 000000219971198.140812000000000000 ; 000000237595099.622106000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015F80D417867EC >									
	//     < MELNI_PFX_II_metadata_line_14_____Khabarovsk_geo_org_20240316 >									
	//        < pd5GA9p5q8X8qglm8jg28W2x3Hc1thl8kGl6Q55UnD3dnj6xI5mpaMepAoK0TTsz >									
	//        <  u =="0.000000000000000001" : ] 000000237595099.622106000000000000 ; 000000250379130.807423000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017867EC196802A >									
	//     < MELNI_PFX_II_metadata_line_15_____Primorsky_geo_org_20240316 >									
	//        < ept6HGL7WHN7Fy1PshPoJ8HOJyurOzj72dScs2WlsBSiSgM9r5IGd75b28OyVx51 >									
	//        <  u =="0.000000000000000001" : ] 000000250379130.807423000000000000 ; 000000264210318.726109000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000196802A1AE760A >									
	//     < MELNI_PFX_II_metadata_line_16_____Vanino_infra_org_20240316 >									
	//        < 0a51AxMkEBLLSmk7PpL8RUZDGb2DYrh8QEZXK3ukm22URaVf49848qkd5PtlWu87 >									
	//        <  u =="0.000000000000000001" : ] 000000264210318.726109000000000000 ; 000000278791637.358843000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AE760A1D48683 >									
	//     < MELNI_PFX_II_metadata_line_17_____Nakhodka_infra_org_20240316 >									
	//        < HrQZrfuoX9sqw64j1OOd3F6CV2WLa7y2x2Sr3v32wAK2tw3j9AcLi6F5e1744Oji >									
	//        <  u =="0.000000000000000001" : ] 000000278791637.358843000000000000 ; 000000300280150.207020000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D486831F66B68 >									
	//     < MELNI_PFX_II_metadata_line_18_____Primorsky_meta_infra_org_20240316 >									
	//        < ZgsR9QCZz98faB2tsyq029m7h8A11W2z3vQrE3jmd251t33h760gIlerP04pB77e >									
	//        <  u =="0.000000000000000001" : ] 000000300280150.207020000000000000 ; 000000324626735.975302000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F66B68213B8AB >									
	//     < MELNI_PFX_II_metadata_line_19_____Siberian_Coal_Energy_Company_SUEK_20240316 >									
	//        < 7V63x0uSlpLwTP3En8lVr69NHH1IxNJ139pbW19LquG5n6NdWVI76wl32vSRC5ym >									
	//        <  u =="0.000000000000000001" : ] 000000324626735.975302000000000000 ; 000000343525787.815127000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000213B8AB22AF193 >									
	//     < MELNI_PFX_II_metadata_line_20_____Siberian_Generating_Company_SGC_20240316 >									
	//        < 2Pea2Hsl853N1H1T0K93201huBv5fe448oT61lT80up72tTf7lQrmjLxe0t536LJ >									
	//        <  u =="0.000000000000000001" : ] 000000343525787.815127000000000000 ; 000000362073551.769290000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022AF193245A639 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < MELNI_PFX_II_metadata_line_21_____Yenisei_Territorial_Generating_Company_TGC_20240316 >									
	//        < 7bs1B0ijK3bBbNjeRU07rKho7wqCaCOS3mE3wYa06w2H857p5ynl93r46455r826 >									
	//        <  u =="0.000000000000000001" : ] 000000362073551.769290000000000000 ; 000000383035249.997319000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000245A63925BAD54 >									
	//     < MELNI_PFX_II_metadata_line_22_____AIM_Capital_SE_20240316 >									
	//        < 0tlWYjT5eDcEH8kV9Cb1O5HVIL4gl9T35epxI5JIUXEa3aK9Gtcw04N12igG6Zn9 >									
	//        <  u =="0.000000000000000001" : ] 000000383035249.997319000000000000 ; 000000405581870.357283000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025BAD542722899 >									
	//     < MELNI_PFX_II_metadata_line_23_____Eurochem_group_evrokhim_20240316 >									
	//        < k2f6kFVdaaB6s7nvKe48S5YuT0e9GD43B99XALSC3t7NheD4XAm96sA0dpK3hmB4 >									
	//        <  u =="0.000000000000000001" : ] 000000405581870.357283000000000000 ; 000000423441957.088032000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027228992962E67 >									
	//     < MELNI_PFX_II_metadata_line_24_____Kovdor_org_20240316 >									
	//        < XB87dR9zD44Vv9090cu7WbO9pZPegIc0hJ3OX67kSLR6Rb89fwn1ur6g8p43ox2l >									
	//        <  u =="0.000000000000000001" : ] 000000423441957.088032000000000000 ; 000000446618726.839150000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002962E672B6E413 >									
	//     < MELNI_PFX_II_metadata_line_25_____OJSC_Murmansk_Commercial_Seaport_20240316 >									
	//        < w77I4G3BcG8mblWC2g70O8uOK1y7m6O6zHf3Mj7Ykf1B9W5r8of3OqE9EfAAxl91 >									
	//        <  u =="0.000000000000000001" : ] 000000446618726.839150000000000000 ; 000000464282022.013930000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B6E4132CC4D79 >									
	//     < MELNI_PFX_II_metadata_line_26_____BASF_Antwerpen_AB_20240316 >									
	//        < 2f53nYFHTW7ISU8Q7zP2PasH6lzsO6412EpFPy52h39cyck2DtW4cr62ZlA7r2my >									
	//        <  u =="0.000000000000000001" : ] 000000464282022.013930000000000000 ; 000000478478116.461011000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CC4D792EE7B73 >									
	//     < MELNI_PFX_II_metadata_line_27_____Eurochem_Antwerpen_20240316 >									
	//        < VmalQd6cBD976YaEy4x42L3KcYuc8k8Ob42527JSQa7E4j1H4326H4FjA3M6zO81 >									
	//        <  u =="0.000000000000000001" : ] 000000478478116.461011000000000000 ; 000000498106900.694949000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EE7B73302CCDF >									
	//     < MELNI_PFX_II_metadata_line_28_____Eurochem_Agro_20240316 >									
	//        < PP2R5ur7rQnmgm9fBQC72Vkm5igYKN5hG9Qq8O22T4JalMD2rPPi525aPc64JWaY >									
	//        <  u =="0.000000000000000001" : ] 000000498106900.694949000000000000 ; 000000513764322.350680000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000302CCDF323E362 >									
	//     < MELNI_PFX_II_metadata_line_29_____Mannheimer_KplusS_AB_20240316 >									
	//        < t7cBlKEMUfWK7t6332y477F68WU0izyw2yot3O58lRjUU968BOGHeRl6sriGXhq2 >									
	//        <  u =="0.000000000000000001" : ] 000000513764322.350680000000000000 ; 000000527981052.092278000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000323E36234283AC >									
	//     < MELNI_PFX_II_metadata_line_30_____Iamali_Severneft_Ourengoi_20240316 >									
	//        < hvQGcotz7ZX5l65H0PCOSI2w58FEeYs5T6G7Spn9qhiqbWJI80y7r43KE9Q6vPK6 >									
	//        <  u =="0.000000000000000001" : ] 000000527981052.092278000000000000 ; 000000551291388.154514000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034283AC361C656 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < MELNI_PFX_II_metadata_line_31_____Djambouli_SORL_kazakhe_Sary_Tas_20240316 >									
	//        < 9oNEftgA0Ojo28xf1Yo0m1c2610h7Z75M837SNu1y98BrhiR5tWvX0VIHwXY3Q6c >									
	//        <  u =="0.000000000000000001" : ] 000000551291388.154514000000000000 ; 000000564618560.187119000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000361C6563773667 >									
	//     < MELNI_PFX_II_metadata_line_32_____Tyance_org_20240316 >									
	//        < 35vj33i1ZcSP7fkRfFdzVnsi3znJu1b9H0YiQ37pg1V2vrun1eAC4OO5vP081T1k >									
	//        <  u =="0.000000000000000001" : ] 000000564618560.187119000000000000 ; 000000582211441.245447000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003773667392C58E >									
	//     < MELNI_PFX_II_metadata_line_33_____Tyance_Climat_org_20240316 >									
	//        < WBgCzxg1bRSLAd838N7y29Vl22nlmT8ST6c94qDuda4X4v6MqvH2h2m0PPL39zEK >									
	//        <  u =="0.000000000000000001" : ] 000000582211441.245447000000000000 ; 000000596873005.145637000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000392C58E3ACE099 >									
	//     < MELNI_PFX_II_metadata_line_34_____Rospotrebnadzor_org_20240316 >									
	//        < mgMnr1HUnxd5Vc782Vu8A26RRZ64X09WoksyF50c9Fq56hID9147vOGBOd79AobS >									
	//        <  u =="0.000000000000000001" : ] 000000596873005.145637000000000000 ; 000000614077301.080040000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003ACE0993D14043 >									
	//     < MELNI_PFX_II_metadata_line_35_____Kinguissepp_Eurochem_infra_org_20240316 >									
	//        < BvCSzc99HBd6DaBhlEmHbAp2D9AA753gkt6omSuYyMS5TxYoF9a8F295IZLHUmc6 >									
	//        <  u =="0.000000000000000001" : ] 000000614077301.080040000000000000 ; 000000636608142.193741000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D140433E7EF64 >									
	//     < MELNI_PFX_II_metadata_line_36_____Louga_EUrochem_infra_org_20240316 >									
	//        < Q7OXIvW5ihbadOH0QMDu5jmq5C5651H0gqlcExOSCt3qz0Khs7E5Rk0zCP3X7oNd >									
	//        <  u =="0.000000000000000001" : ] 000000636608142.193741000000000000 ; 000000652369137.414488000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E7EF644062E18 >									
	//     < MELNI_PFX_II_metadata_line_37_____Finnish_Environment_Institute_org_20240316 >									
	//        < 6H4h5820G5Yt8967gVIvIPpxeJt1kOsL2t5uI4EZWTX09W5SY39Plj8v0g422M8Z >									
	//        <  u =="0.000000000000000001" : ] 000000652369137.414488000000000000 ; 000000671245908.891589000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004062E1842008EB >									
	//     < MELNI_PFX_II_metadata_line_38_____Helcom_org_20240316 >									
	//        < jbl665i0v7m9593H5bjV2R2Jub5KO9Qh5cSO4fA0u0xW7Bil2fRE1LU1QQ3Wi7Tk >									
	//        <  u =="0.000000000000000001" : ] 000000671245908.891589000000000000 ; 000000685744311.227042000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042008EB437DAA0 >									
	//     < MELNI_PFX_II_metadata_line_39_____Eurochem_Baltic_geo_org_20240316 >									
	//        < Jgm6yuhiJqP88jX4awwO86Bze0JEc96Jl5Zv0t04XXYaQ1JmaC1EhaMvL6Jz9O4s >									
	//        <  u =="0.000000000000000001" : ] 000000685744311.227042000000000000 ; 000000702859560.990012000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000437DAA0451DCC3 >									
	//     < MELNI_PFX_II_metadata_line_40_____John_Nurminen_Stiftung_org_20240316 >									
	//        < 0jc7Xwk7xsJiSqQwFdamLWlBo0P76uYrl85koPcDd9H18h6530UN65UFwoOUc7kI >									
	//        <  u =="0.000000000000000001" : ] 000000702859560.990012000000000000 ; 000000724220230.077302000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000451DCC34769FB1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
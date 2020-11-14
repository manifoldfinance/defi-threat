/**
 * Source Code first verified at https://etherscan.io on Saturday, March 23, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFV_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFV_III_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFV_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1049417559213730000000000000					;	
										
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
	//     < CHEMCHINA_PFV_III_metadata_line_1_____Psyclo_Peptide,_inc__20260321 >									
	//        < D7w7878W2XbaYFd26QHoP4w8GIOfVUTQI90RZToZt010mtFE53gXHg0UV8hfMLe9 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000026753902.786040500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000028D2BE >									
	//     < CHEMCHINA_PFV_III_metadata_line_2_____Purestar_Chem_Enterprise_Co_Limited_20260321 >									
	//        < uY73i2jXsjbdK74ylu5514mwQc4bXEfh4143PTYfzVh4OY1E79HVue5oPe4Kgrz6 >									
	//        <  u =="0.000000000000000001" : ] 000000026753902.786040500000000000 ; 000000048488157.744927100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000028D2BE49FCB0 >									
	//     < CHEMCHINA_PFV_III_metadata_line_3_____Puyer_BioPharma_20260321 >									
	//        < 7R8t475gdqdPu4Q0MZRAUUZFSgprL1447tQ2K921c9J5awAB9x0ob0HpeH9hpXC3 >									
	//        <  u =="0.000000000000000001" : ] 000000048488157.744927100000000000 ; 000000079239609.801618400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000049FCB078E8F9 >									
	//     < CHEMCHINA_PFV_III_metadata_line_4_____Qi_Chem_org_20260321 >									
	//        < v98GgkW7575Rgw1f08KJ86Nn69i7tHZ71jJzA470s7P3A6LoPG6OL7Nj082JapxF >									
	//        <  u =="0.000000000000000001" : ] 000000079239609.801618400000000000 ; 000000112507678.291400000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000078E8F9ABAC50 >									
	//     < CHEMCHINA_PFV_III_metadata_line_5_____Qi_Chem_Co_Limited_20260321 >									
	//        < K839UWw356B3W10v1HgaM3ZeE5MDBMu1X80gNLNl2iedplL1Pv2J83KdHmrtsWZm >									
	//        <  u =="0.000000000000000001" : ] 000000112507678.291400000000000000 ; 000000136837916.242280000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000ABAC50D0CC50 >									
	//     < CHEMCHINA_PFV_III_metadata_line_6_____Qingdao_Yimingxiang_Fine_Chemical_Technology_Co_Limited_20260321 >									
	//        < OXy6qN4cDWCYa2cXcRv7v0DqMV6YLZi66ElsTTySgqJEGjFlw8E26eyi4UuZz59U >									
	//        <  u =="0.000000000000000001" : ] 000000136837916.242280000000000000 ; 000000166306299.382079000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D0CC50FDC366 >									
	//     < CHEMCHINA_PFV_III_metadata_line_7_____Qinmu_fine_chemical_Co_Limited_20260321 >									
	//        < 60W7QMD7vK4SYiBJuED8Vne2HjIz111zYVTazfAr2qiWvH1f9PoaWWNHf062c1GE >									
	//        <  u =="0.000000000000000001" : ] 000000166306299.382079000000000000 ; 000000186847048.676320000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FDC36611D1B21 >									
	//     < CHEMCHINA_PFV_III_metadata_line_8_____Quzhou_Ruiyuan_Chemical_Co_Limited_20260321 >									
	//        < 937Fk487hhGhMfbSh9xT6514rTlF57V4HBzm81PmX5bUquG976Op2EKbo45E9e96 >									
	//        <  u =="0.000000000000000001" : ] 000000186847048.676320000000000000 ; 000000209498663.204088000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011D1B2113FAB6A >									
	//     < CHEMCHINA_PFV_III_metadata_line_9_____RennoTech_Co__Limited_20260321 >									
	//        < Tvo8mdvBgc9JGW75jyyboq9waNieLF501I2jcXM00Z5Ac0gJe94Ol2i8Y066EAE0 >									
	//        <  u =="0.000000000000000001" : ] 000000209498663.204088000000000000 ; 000000231646886.147290000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013FAB6A1617711 >									
	//     < CHEMCHINA_PFV_III_metadata_line_10_____Richap_Chem_20260321 >									
	//        < 462ZxevQjKVmxdbxeeO6lg9M0JeluOz3DS9VxbEU26K599Z77qER70XR1CxS5ORy >									
	//        <  u =="0.000000000000000001" : ] 000000231646886.147290000000000000 ; 000000260202155.854705000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000161771118D0978 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFV_III_metadata_line_11_____Ronas_Chemicals_org_20260321 >									
	//        < 3j15fWNnYM9gAImzk2JpBiG87I9cY1iJ3Mmf66mzDE0l1y09DChz0Uim5E3T2iAW >									
	//        <  u =="0.000000000000000001" : ] 000000260202155.854705000000000000 ; 000000284620734.806845000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018D09781B24BF9 >									
	//     < CHEMCHINA_PFV_III_metadata_line_12_____Ronas_Chemicals_Ind_Co_Limited_20260321 >									
	//        < 6Xf0aP92p59z8H8jnyFYAhx52L2hE7eoAyEwky5c506DV0rWTO96kO2t803jTQyx >									
	//        <  u =="0.000000000000000001" : ] 000000284620734.806845000000000000 ; 000000318062836.437625000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B24BF91E5534C >									
	//     < CHEMCHINA_PFV_III_metadata_line_13_____Rudong_Zhenfeng_Yiyang_Chemical_Co__Limited_20260321 >									
	//        < RqkP0KXfkpfW7iV3Fn3m008pA3SDA3Uk64SnjFgQIGfsmDXpl6085asakE0y6zAy >									
	//        <  u =="0.000000000000000001" : ] 000000318062836.437625000000000000 ; 000000343696181.851391000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E5534C20C7052 >									
	//     < CHEMCHINA_PFV_III_metadata_line_14_____SAGECHEM_LIMITED_20260321 >									
	//        < 30rT0Yh3zmbUMbzd3R88lKWN0KlfpQu7n7au0ZjCsIU3FvZ339P7AHz7O5T8q9PF >									
	//        <  u =="0.000000000000000001" : ] 000000343696181.851391000000000000 ; 000000364418077.696269000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020C705222C0ED0 >									
	//     < CHEMCHINA_PFV_III_metadata_line_15_____Shandong_Changsheng_New_Flame_Retardant_Co__Limited_20260321 >									
	//        < RFJDcWZ17g4NM61Zg5a90g44yLTqoFVlHfYMR0iZEX0vjsIR1a3BS7AXUp8IiIEJ >									
	//        <  u =="0.000000000000000001" : ] 000000364418077.696269000000000000 ; 000000390915640.792181000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022C0ED02547D6C >									
	//     < CHEMCHINA_PFV_III_metadata_line_16_____Shandong_Shengda_Technology_Co__Limited_20260321 >									
	//        < w1vS40oXHMiBWir3q7D37XO1bgHv6JhDac0PhM3UnzUTvtr99686XaSP41s7TwZM >									
	//        <  u =="0.000000000000000001" : ] 000000390915640.792181000000000000 ; 000000413308360.678012000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002547D6C276A894 >									
	//     < CHEMCHINA_PFV_III_metadata_line_17_____Shangfluoro_20260321 >									
	//        < 6q3Uul5AmVpBwd800R4Z1RfwFdhQpG0eEnAx74CeORI2orMo6168cxC6H75uWF9e >									
	//        <  u =="0.000000000000000001" : ] 000000413308360.678012000000000000 ; 000000434151751.221942000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000276A8942967687 >									
	//     < CHEMCHINA_PFV_III_metadata_line_18_____Shanghai_Activated_Carbon_Co__Limited_20260321 >									
	//        < 4I02Eabk4UBQYU45tMddHGL7TEPbXs9ITWA0BuuBRwY6xmF3GF65T61TtWIl7rD4 >									
	//        <  u =="0.000000000000000001" : ] 000000434151751.221942000000000000 ; 000000463390507.398979000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029676872C313EB >									
	//     < CHEMCHINA_PFV_III_metadata_line_19_____Shanghai_AQ_BioPharma_org_20260321 >									
	//        < TX4qi4497bW2g1fpXPK5C0MQrG97krI4x0KBB9Nt6vSdo6p53pUL48O2glt9Y342 >									
	//        <  u =="0.000000000000000001" : ] 000000463390507.398979000000000000 ; 000000484913231.343461000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C313EB2E3EB3B >									
	//     < CHEMCHINA_PFV_III_metadata_line_20_____Shanghai_AQ_BioPharma_20260321 >									
	//        < 58oK11Ni5laqW1o9Edb60hvH76BLrtXfl7sDTnXsWGNmt8UrpsPq96KozFmCr09i >									
	//        <  u =="0.000000000000000001" : ] 000000484913231.343461000000000000 ; 000000513498613.547007000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E3EB3B30F8965 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFV_III_metadata_line_21_____SHANGHAI_ARCADIA_BIOTECHNOLOGY_Limited_20260321 >									
	//        < 5PY8fwtUViUY275M3ZY2Whj502KV2aGsX06rLasMlat7s0199kKTKtAItc6V73k0 >									
	//        <  u =="0.000000000000000001" : ] 000000513498613.547007000000000000 ; 000000538854753.635520000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030F89653363A23 >									
	//     < CHEMCHINA_PFV_III_metadata_line_22_____Shanghai_BenRo_Chemical_Co_Limited_20260321 >									
	//        < f8aRbrkG3XiOg0X225893O0PYO1I7p5rBLaH1m12S9DLj8i8yyqqb534M0QboCm7 >									
	//        <  u =="0.000000000000000001" : ] 000000538854753.635520000000000000 ; 000000561765006.179058000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003363A233592F75 >									
	//     < CHEMCHINA_PFV_III_metadata_line_23_____Shanghai_Brothchem_Bio_Tech_Co_Limited_20260321 >									
	//        < egcM4l9jy9m7F3t137n8G7Rrn72W4JdQvpRG1pRufL6Pj8gZM2Yw1yE4VjBDl609 >									
	//        <  u =="0.000000000000000001" : ] 000000561765006.179058000000000000 ; 000000583365805.535326000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003592F7537A2545 >									
	//     < CHEMCHINA_PFV_III_metadata_line_24_____SHANGHAI_CHEMHERE_Co_Limited_20260321 >									
	//        < 6DLEnbcQ3W14id5JYu67c0981pYp66s7dam1w82OLWttpo6Q4V2KwJ5g9r38lC3T >									
	//        <  u =="0.000000000000000001" : ] 000000583365805.535326000000000000 ; 000000609897021.465080000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037A25453A2A106 >									
	//     < CHEMCHINA_PFV_III_metadata_line_25_____Shanghai_ChemVia_Co_Limited_20260321 >									
	//        < rESTz2t78BzU91C2lUu7a5bIQC6KBexwhyvNY7jO4nHG4mirE1418eURR2Ig2tR3 >									
	//        <  u =="0.000000000000000001" : ] 000000609897021.465080000000000000 ; 000000633276857.664512000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A2A1063C64DC6 >									
	//     < CHEMCHINA_PFV_III_metadata_line_26_____Shanghai_Coming_Hi_Technology_Co__Limited_20260321 >									
	//        < IyRj0Uk39Fc2Yf648l8hb09903m6du2dAD99Si77jdyoEl9WX47Mvq068Z1Y8ART >									
	//        <  u =="0.000000000000000001" : ] 000000633276857.664512000000000000 ; 000000667168082.061572000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C64DC63FA0488 >									
	//     < CHEMCHINA_PFV_III_metadata_line_27_____Shanghai_EachChem_org_20260321 >									
	//        < 9H9o8k1d68iUmSUKlmphFjIf3J6k8fy8sDt2z05M4M08Xqcdno3Mbm41iCQn8A8d >									
	//        <  u =="0.000000000000000001" : ] 000000667168082.061572000000000000 ; 000000690063403.197465000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FA048841CF404 >									
	//     < CHEMCHINA_PFV_III_metadata_line_28_____Shanghai_EachChem_Co__Limited_20260321 >									
	//        < 3I0d6lr38vqwCkQ464c5l3poP819J1SVEnDDnrYruk3Z6K9UWX8a65zJ7HM46YG1 >									
	//        <  u =="0.000000000000000001" : ] 000000690063403.197465000000000000 ; 000000711576623.998260000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041CF40443DC79E >									
	//     < CHEMCHINA_PFV_III_metadata_line_29_____Shanghai_FChemicals_Technology_Co_Limited_20260321 >									
	//        < 781F2HbUMYHffpMUf8Ip4FLln4794jTO6YY1yJQloqu2eUw01ic0RHlFZ6yv3b37 >									
	//        <  u =="0.000000000000000001" : ] 000000711576623.998260000000000000 ; 000000734555962.225336000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043DC79E460D7EC >									
	//     < CHEMCHINA_PFV_III_metadata_line_30_____Shanghai_Fuxin_Pharmaceutical_Co__Limited_20260321 >									
	//        < f2s1RCsoKElnipPcVqLo7Y1Xi0qwcQ66rSdG6h12rFnToX0gJXz0JkSHXYlAIkgh >									
	//        <  u =="0.000000000000000001" : ] 000000734555962.225336000000000000 ; 000000766932431.909562000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000460D7EC4923EFB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFV_III_metadata_line_31_____Shanghai_Goldenmall_biotechnology_Co__Limited_20260321 >									
	//        < Oxv3T09268V9073ntS19Z8xXrr9hyj2gVmuRY6JXCcgwRYb25R2AmA54vFnztf74 >									
	//        <  u =="0.000000000000000001" : ] 000000766932431.909562000000000000 ; 000000794597951.886643000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004923EFB4BC75D3 >									
	//     < CHEMCHINA_PFV_III_metadata_line_32_____Shanghai_Hope_Chem_Co__Limited_20260321 >									
	//        < 117ekMHRHF9w30JKwK60781GsEO5jZh649i53U8b7xgSJr5q4dQ4UyV9gnKhgo2v >									
	//        <  u =="0.000000000000000001" : ] 000000794597951.886643000000000000 ; 000000828205910.751683000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BC75D34EFBDEF >									
	//     < CHEMCHINA_PFV_III_metadata_line_33_____SHANGHAI_IMMENSE_CHEMICAL_org_20260321 >									
	//        < 1FErQb6wIt14F8ro33iS20OtmBrcD61rdQgb8zdY8dk937V7n755bE3y8747vcIW >									
	//        <  u =="0.000000000000000001" : ] 000000828205910.751683000000000000 ; 000000851524207.081024000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004EFBDEF51352A5 >									
	//     < CHEMCHINA_PFV_III_metadata_line_34_____SHANGHAI_IMMENSE_CHEMICAL_Co_Limited_20260321 >									
	//        < CER7HKAZ9xmj1BIC99U7qzEJ5HKJk3oaCM62RTVTPVeB0qMnf5xtk7oCn5PmFFFC >									
	//        <  u =="0.000000000000000001" : ] 000000851524207.081024000000000000 ; 000000877813159.745108000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051352A553B6FC4 >									
	//     < CHEMCHINA_PFV_III_metadata_line_35_____Shanghai_MC_Pharmatech_Co_Limited_20260321 >									
	//        < W0P9j1R1s64K5X3l0ihvQQdPlDmV8UyI5Uju47YGvkI8zHhJ4A63qA0MB8Pjl77y >									
	//        <  u =="0.000000000000000001" : ] 000000877813159.745108000000000000 ; 000000905452095.189771000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053B6FC45659C3A >									
	//     < CHEMCHINA_PFV_III_metadata_line_36_____Shanghai_Mintchem_Development_Co_Limited_20260321 >									
	//        < M7ROzl625rfDkp7wyJRnK54BJnYm0plr96L4iC2I7OB40uqbmwB0cg4kGp5P01fx >									
	//        <  u =="0.000000000000000001" : ] 000000905452095.189771000000000000 ; 000000928198577.404112000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005659C3A5885192 >									
	//     < CHEMCHINA_PFV_III_metadata_line_37_____Shanghai_NuoCheng_Pharmaceutical_Co_Limited_20260321 >									
	//        < dV9bf4gA795m2gwzu66ZBjs1JiXh2rb3LDIlsrFce4KkoHI967fuZLkJx634JN37 >									
	//        <  u =="0.000000000000000001" : ] 000000928198577.404112000000000000 ; 000000956999165.530417000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058851925B443CD >									
	//     < CHEMCHINA_PFV_III_metadata_line_38_____Shanghai_Oripharm_Co_Limited_20260321 >									
	//        < 837I0E062FOe30SqSws13Skq543N50Otxr5xGWv3H50pcLjnEvBkee5cwLo5LGK9 >									
	//        <  u =="0.000000000000000001" : ] 000000956999165.530417000000000000 ; 000000981311426.116820000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005B443CD5D95CC7 >									
	//     < CHEMCHINA_PFV_III_metadata_line_39_____Shanghai_PI_Chemicals_org_20260321 >									
	//        < z7d64P5Gu8Vp4MtDoBNJia21wg6P0ZKU1ugj5R4LDZr1kWWwsaC13SIOMbsLerLh >									
	//        <  u =="0.000000000000000001" : ] 000000981311426.116820000000000000 ; 000001016570593.890650000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005D95CC760F29E3 >									
	//     < CHEMCHINA_PFV_III_metadata_line_40_____Shanghai_PI_Chemicals_Ltd_20260321 >									
	//        < D96mlCDz3aQrU2v09MRtU8kN8WWlE3r2NZd84y8SPh449xO20hA7A0rYse9s1bF8 >									
	//        <  u =="0.000000000000000001" : ] 000001016570593.890650000000000000 ; 000001049417559.213730000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000060F29E364148BC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
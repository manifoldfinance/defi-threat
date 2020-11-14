/**
 * Source Code first verified at https://etherscan.io on Saturday, March 23, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFV_I_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		582396634707317000000000000					;	
										
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
	//     < CHEMCHINA_PFV_I_metadata_line_1_____Psyclo_Peptide,_inc__20220321 >									
	//        < FQsOHaDrFozszQWLg6oWB0AALG43Wj88GlfbW2vv0B8FHYRUMih3a7DAJn7HR3cj >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000012687280.484705800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000135BF8 >									
	//     < CHEMCHINA_PFV_I_metadata_line_2_____Purestar_Chem_Enterprise_Co_Limited_20220321 >									
	//        < sd5l8Bw4oQWq1NxU0PrM0mx5mFb79wuoP70YV2a1RV8Y0pH3K0AJW044C0w2vNZX >									
	//        <  u =="0.000000000000000001" : ] 000000012687280.484705800000000000 ; 000000026612941.699154300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000135BF8289BAE >									
	//     < CHEMCHINA_PFV_I_metadata_line_3_____Puyer_BioPharma_20220321 >									
	//        < vGd7e376dFJn1t6mQb485a8K89K6Zb9M9CIDw4oyO7lnnnUg8Hd0JV6bk2Z6p5hg >									
	//        <  u =="0.000000000000000001" : ] 000000026612941.699154300000000000 ; 000000042332817.320977100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000289BAE409842 >									
	//     < CHEMCHINA_PFV_I_metadata_line_4_____Qi_Chem_org_20220321 >									
	//        < G59igtikNg6P9E7ICqc5WdiCum52hfBO4LJC17q7LPMB52zBE9Y07w36sEL3cwT1 >									
	//        <  u =="0.000000000000000001" : ] 000000042332817.320977100000000000 ; 000000057657131.335292600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000040984257FA51 >									
	//     < CHEMCHINA_PFV_I_metadata_line_5_____Qi_Chem_Co_Limited_20220321 >									
	//        < bP7I9pmDm03AIPPsEO22N42Jm91X0Zvo6c63R22e69W1D37LdzP6SwuqfUwwL15t >									
	//        <  u =="0.000000000000000001" : ] 000000057657131.335292600000000000 ; 000000072275385.062122700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000057FA516E4893 >									
	//     < CHEMCHINA_PFV_I_metadata_line_6_____Qingdao_Yimingxiang_Fine_Chemical_Technology_Co_Limited_20220321 >									
	//        < qbUVsW7O7Ur13vLLv0s1q5vY8qUHi9US7dJs5Km29tM7x1Wq39C8z3CO8jnsJzTS >									
	//        <  u =="0.000000000000000001" : ] 000000072275385.062122700000000000 ; 000000085819141.624657800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006E489382F31A >									
	//     < CHEMCHINA_PFV_I_metadata_line_7_____Qinmu_fine_chemical_Co_Limited_20220321 >									
	//        < 2H1S843tm2lJsdf02tv28cwvNdX8EH22s74bzm7wv8KfhM9U566tSPMsVz2c22S2 >									
	//        <  u =="0.000000000000000001" : ] 000000085819141.624657800000000000 ; 000000102140288.835947000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000082F31A9BDA8D >									
	//     < CHEMCHINA_PFV_I_metadata_line_8_____Quzhou_Ruiyuan_Chemical_Co_Limited_20220321 >									
	//        < p256H65BWYchD698s5KCaizVSI198qbjn6CxW1Lxav4p9v49AmplArYdSxOw7jOx >									
	//        <  u =="0.000000000000000001" : ] 000000102140288.835947000000000000 ; 000000117002268.333052000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009BDA8DB28803 >									
	//     < CHEMCHINA_PFV_I_metadata_line_9_____RennoTech_Co__Limited_20220321 >									
	//        < 0U15h43E1PYGLC5noixyQw444qwD9ZsGSBUYAkrwa14046LdRXB2FEe9lRIBYbFP >									
	//        <  u =="0.000000000000000001" : ] 000000117002268.333052000000000000 ; 000000131002667.726318000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B28803C7E4EB >									
	//     < CHEMCHINA_PFV_I_metadata_line_10_____Richap_Chem_20220321 >									
	//        < 9s40Dj28ba68UZ137D2fDR7k6dpuVW5l1Ns4kMIWDJ309qP3254fayGUUxr6g8Xo >									
	//        <  u =="0.000000000000000001" : ] 000000131002667.726318000000000000 ; 000000146338973.105678000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C7E4EBDF4BA9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFV_I_metadata_line_11_____Ronas_Chemicals_org_20220321 >									
	//        < aiLvJJsl6umxT0dWc5Sd56jmxiq87wIORRqQveI79TtbU60v1a2A78r8oI83S0ex >									
	//        <  u =="0.000000000000000001" : ] 000000146338973.105678000000000000 ; 000000160811819.523261000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DF4BA9F5611E >									
	//     < CHEMCHINA_PFV_I_metadata_line_12_____Ronas_Chemicals_Ind_Co_Limited_20220321 >									
	//        < 52R2TtM7YJFq5FznXGu0Zw4X2W88MLdCvU6y74c4wO2q1PXjmP0a9D3Z2y3SBu92 >									
	//        <  u =="0.000000000000000001" : ] 000000160811819.523261000000000000 ; 000000174740111.639772000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F5611E10AA1DB >									
	//     < CHEMCHINA_PFV_I_metadata_line_13_____Rudong_Zhenfeng_Yiyang_Chemical_Co__Limited_20220321 >									
	//        < b0V1LN63gijr5IW1jLYi7blYe557LbYixMad1jcUm5BNC814R6npgN71068lpc1e >									
	//        <  u =="0.000000000000000001" : ] 000000174740111.639772000000000000 ; 000000190958860.921973000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010AA1DB123614E >									
	//     < CHEMCHINA_PFV_I_metadata_line_14_____SAGECHEM_LIMITED_20220321 >									
	//        < N74Eu671hE0ah76lT8nAbPAd6C24J5Ae9gD6ktF33iRQ1xN23KtlXVMp2BHa2AkE >									
	//        <  u =="0.000000000000000001" : ] 000000190958860.921973000000000000 ; 000000203867059.452268000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000123614E1371392 >									
	//     < CHEMCHINA_PFV_I_metadata_line_15_____Shandong_Changsheng_New_Flame_Retardant_Co__Limited_20220321 >									
	//        < 3HE4ReuLqSUAwlx49cMM2juhIk7KkxccG66IfljWY9w6U7p7FKt9mxt62VB8sI7h >									
	//        <  u =="0.000000000000000001" : ] 000000203867059.452268000000000000 ; 000000216290401.935140000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000137139214A0870 >									
	//     < CHEMCHINA_PFV_I_metadata_line_16_____Shandong_Shengda_Technology_Co__Limited_20220321 >									
	//        < i2vr98zmH4836225iVzu2bu90A62XekO5E3i0Hno9D0G481eGqnv0BTH3L3Vh7E7 >									
	//        <  u =="0.000000000000000001" : ] 000000216290401.935140000000000000 ; 000000231303487.199610000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014A0870160F0ED >									
	//     < CHEMCHINA_PFV_I_metadata_line_17_____Shangfluoro_20220321 >									
	//        < xvv8tDAfsRXlQgZ7hEMO770gi2ODOfO9j3c9XJc1O7Rg4GQZ45Ls5JIDD95Rv8zb >									
	//        <  u =="0.000000000000000001" : ] 000000231303487.199610000000000000 ; 000000244879642.673970000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000160F0ED175A81C >									
	//     < CHEMCHINA_PFV_I_metadata_line_18_____Shanghai_Activated_Carbon_Co__Limited_20220321 >									
	//        < lPE2i3x8Cl1jQ7n9vazb49zY9K2jUl7oA645DlYGI02Y4H5Uqv69EJOz4L5ZAk43 >									
	//        <  u =="0.000000000000000001" : ] 000000244879642.673970000000000000 ; 000000257666080.211440000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000175A81C1892AD0 >									
	//     < CHEMCHINA_PFV_I_metadata_line_19_____Shanghai_AQ_BioPharma_org_20220321 >									
	//        < S4XR2wcomIaNP28g9b4xCZUPC18Xt264g6zT6Df91HX0InO81c1397zSWx7uglnz >									
	//        <  u =="0.000000000000000001" : ] 000000257666080.211440000000000000 ; 000000271850515.754955000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001892AD019ECF9C >									
	//     < CHEMCHINA_PFV_I_metadata_line_20_____Shanghai_AQ_BioPharma_20220321 >									
	//        < G4eSnxP894Mgi5bwJCI6PKVxR8QjVN8Ev8lnBtnY0YLgQ7DE7jX8Dfb43vT19X58 >									
	//        <  u =="0.000000000000000001" : ] 000000271850515.754955000000000000 ; 000000285648610.399524000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019ECF9C1B3DD7D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFV_I_metadata_line_21_____SHANGHAI_ARCADIA_BIOTECHNOLOGY_Limited_20220321 >									
	//        < e3fu9Zv3ttF8IQPoCdyJlFXg0FTJkVqbS7pdWaMt7Cpq14qRNW2T7lRSMf6Bj2us >									
	//        <  u =="0.000000000000000001" : ] 000000285648610.399524000000000000 ; 000000301315325.745031000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B3DD7D1CBC54D >									
	//     < CHEMCHINA_PFV_I_metadata_line_22_____Shanghai_BenRo_Chemical_Co_Limited_20220321 >									
	//        < wd2FIhv7R9I6XtTP3HAf7NSitbDeTxjB3QJ4oCg3EY4rMCWh0Fwi76D5L40fhaT9 >									
	//        <  u =="0.000000000000000001" : ] 000000301315325.745031000000000000 ; 000000317575158.281941000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CBC54D1E494CC >									
	//     < CHEMCHINA_PFV_I_metadata_line_23_____Shanghai_Brothchem_Bio_Tech_Co_Limited_20220321 >									
	//        < TEct5RB8ol4POw0tQo9Z695LJwz5ua68i16j730l6Zwrc1V0K7q0WnQSo63B95yH >									
	//        <  u =="0.000000000000000001" : ] 000000317575158.281941000000000000 ; 000000330427101.555708000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E494CC1F83116 >									
	//     < CHEMCHINA_PFV_I_metadata_line_24_____SHANGHAI_CHEMHERE_Co_Limited_20220321 >									
	//        < Fptu962tXEmx81eJ8149VGP9vsR01mDhKI5awH9p8c2TxChCr112JNIKw9yC8cR6 >									
	//        <  u =="0.000000000000000001" : ] 000000330427101.555708000000000000 ; 000000343727431.763373000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F8311620C7C87 >									
	//     < CHEMCHINA_PFV_I_metadata_line_25_____Shanghai_ChemVia_Co_Limited_20220321 >									
	//        < 67845Oe3alF76NVTsS7lXZBds2OGjsPoQ3p7L003LSxs8Wjv0sVNc6B97CU9Hg0f >									
	//        <  u =="0.000000000000000001" : ] 000000343727431.763373000000000000 ; 000000358935332.337438000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020C7C87223B11D >									
	//     < CHEMCHINA_PFV_I_metadata_line_26_____Shanghai_Coming_Hi_Technology_Co__Limited_20220321 >									
	//        < 0bjT10pEV32460a2qVva30NS0gyiSWx9m65fvdLd8L3ce4WO4iywMhbwu1SA1L16 >									
	//        <  u =="0.000000000000000001" : ] 000000358935332.337438000000000000 ; 000000371984697.707438000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000223B11D2379A86 >									
	//     < CHEMCHINA_PFV_I_metadata_line_27_____Shanghai_EachChem_org_20220321 >									
	//        < 6NZ2sXcmLUe9XLcF6VJbiO6R8N5Qxd20PyBZ4f3jTsE85dhp8UCmD0YijCOo358q >									
	//        <  u =="0.000000000000000001" : ] 000000371984697.707438000000000000 ; 000000385341865.633839000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002379A8624BFC2B >									
	//     < CHEMCHINA_PFV_I_metadata_line_28_____Shanghai_EachChem_Co__Limited_20220321 >									
	//        < Um0lvOcLXl6eyG2286AJTVa3cCEJQINb5AE2K8DGSag2DrTG1Mq79TX9Je0d8eoD >									
	//        <  u =="0.000000000000000001" : ] 000000385341865.633839000000000000 ; 000000401716420.981362000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024BFC2B264F87A >									
	//     < CHEMCHINA_PFV_I_metadata_line_29_____Shanghai_FChemicals_Technology_Co_Limited_20220321 >									
	//        < 0Lhg2z0TZkSTAy4rba8NqfE1fvy06jDcq250jZOj60gO9kFWH8HFFEzUl0m4I9uE >									
	//        <  u =="0.000000000000000001" : ] 000000401716420.981362000000000000 ; 000000417410816.612135000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000264F87A27CEB1A >									
	//     < CHEMCHINA_PFV_I_metadata_line_30_____Shanghai_Fuxin_Pharmaceutical_Co__Limited_20220321 >									
	//        < jYftK73Wh89Jgl6L9B39qVZLKWk7Ariu7A3V487KBY7qdhn15t17F6VGG7saSTIf >									
	//        <  u =="0.000000000000000001" : ] 000000417410816.612135000000000000 ; 000000432911028.873049000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027CEB1A29491DF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFV_I_metadata_line_31_____Shanghai_Goldenmall_biotechnology_Co__Limited_20220321 >									
	//        < OR92bC3T6bN9JGlA1k1tiuJ33J3gN3NXft0H036YU41QCxdRn56J55LGasvvmhR6 >									
	//        <  u =="0.000000000000000001" : ] 000000432911028.873049000000000000 ; 000000446612864.381720000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029491DF2A97A26 >									
	//     < CHEMCHINA_PFV_I_metadata_line_32_____Shanghai_Hope_Chem_Co__Limited_20220321 >									
	//        < uFY2Z731xNKcX032SK44904Ur8ri3l71T94fWN1w6b716d9hej18ctq2ulTaukoL >									
	//        <  u =="0.000000000000000001" : ] 000000446612864.381720000000000000 ; 000000462034239.545134000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A97A262C10220 >									
	//     < CHEMCHINA_PFV_I_metadata_line_33_____SHANGHAI_IMMENSE_CHEMICAL_org_20220321 >									
	//        < 5H94r4BlUo8MkwyL041dX1L5XcRPZRhDsA4Lzu1G1Y3J4wZI5523Akk6P9UkyP40 >									
	//        <  u =="0.000000000000000001" : ] 000000462034239.545134000000000000 ; 000000477971940.848281000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C102202D953CA >									
	//     < CHEMCHINA_PFV_I_metadata_line_34_____SHANGHAI_IMMENSE_CHEMICAL_Co_Limited_20220321 >									
	//        < n6Wz6gV1LMl0vaXs0y1U1PkWc9FBPT0M38T98g1NW4W373i929lMOstrxgDjjDqc >									
	//        <  u =="0.000000000000000001" : ] 000000477971940.848281000000000000 ; 000000493365124.264153000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D953CA2F0D0C0 >									
	//     < CHEMCHINA_PFV_I_metadata_line_35_____Shanghai_MC_Pharmatech_Co_Limited_20220321 >									
	//        < iS5TgyP7NFaVL2dMNFfHX32nu2ZVzyk9814WgK1dOTunn83N8ak296cb6pPaMtk8 >									
	//        <  u =="0.000000000000000001" : ] 000000493365124.264153000000000000 ; 000000509401766.535883000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F0D0C03094911 >									
	//     < CHEMCHINA_PFV_I_metadata_line_36_____Shanghai_Mintchem_Development_Co_Limited_20220321 >									
	//        < BAROSFpv6GMXe0RQXYOdN336IOtU63KOkL2296q76au7mV2T4J84uY5QKgyC90q1 >									
	//        <  u =="0.000000000000000001" : ] 000000509401766.535883000000000000 ; 000000524853567.841833000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003094911320DCED >									
	//     < CHEMCHINA_PFV_I_metadata_line_37_____Shanghai_NuoCheng_Pharmaceutical_Co_Limited_20220321 >									
	//        < aP9FwfEGj3FyqgT4S8lrNXPUjbA53zL6Mr2GT2ZdiWlF7USDvNSW40m3BJytpGhR >									
	//        <  u =="0.000000000000000001" : ] 000000524853567.841833000000000000 ; 000000540284048.783581000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000320DCED3386875 >									
	//     < CHEMCHINA_PFV_I_metadata_line_38_____Shanghai_Oripharm_Co_Limited_20220321 >									
	//        < 7o3qi246gsa2qweJPPProfIs2I0tY5032rInqG937120e4Abgiw9oAM6jm4C79Mu >									
	//        <  u =="0.000000000000000001" : ] 000000540284048.783581000000000000 ; 000000553570067.086267000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000338687534CAE4F >									
	//     < CHEMCHINA_PFV_I_metadata_line_39_____Shanghai_PI_Chemicals_org_20220321 >									
	//        < xPkK1p29c4t71ZDr4tNRrg9Wj9c377ie0EVgfe60v33dvFz0hN408n47Ft50oLl4 >									
	//        <  u =="0.000000000000000001" : ] 000000553570067.086267000000000000 ; 000000567014236.252487000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034CAE4F36131F0 >									
	//     < CHEMCHINA_PFV_I_metadata_line_40_____Shanghai_PI_Chemicals_Ltd_20220321 >									
	//        < dTOx38QE4F6zc1QkH0C0Uy85mnS7U7c5zVTexYOboPj9qe0LVAPQ4Y5J8C3HS788 >									
	//        <  u =="0.000000000000000001" : ] 000000567014236.252487000000000000 ; 000000582396634.707317000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036131F0378AAAF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
/**
 * Source Code first verified at https://etherscan.io on Friday, March 22, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFIV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFIV_II_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFIV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		790364326592371000000000000					;	
										
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
	//     < CHEMCHINA_PFIV_II_metadata_line_1_____Kaifute__Tianjin__Chemical_Co___Ltd__20240321 >									
	//        < aGXRVcdHKn920cD866qR1fj2171KOtI9mjE5Me8bT2RfA3DzR7d45OJ47D60e426 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000022733021.651728500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000022B016 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_2_____Kaiyuan_Chemicals_Co__Limited_20240321 >									
	//        < 6tMoC3ocA4VLGg05EMRIPdsMZ855V97KFhTc29coyS5F0M07qoNF490190MUTIlZ >									
	//        <  u =="0.000000000000000001" : ] 000000022733021.651728500000000000 ; 000000046147517.097687300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000022B016466A60 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_3_____Kinbester_org_20240321 >									
	//        < Q1tNYt9Ac9hIY31CURBZh0YpS1w5q6RnBHEr33c4h10YvAqZ1yDKit059wex90Z3 >									
	//        <  u =="0.000000000000000001" : ] 000000046147517.097687300000000000 ; 000000069723288.964322100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000466A606A63A9 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_4_____Kinbester_Co_Limited_20240321 >									
	//        < L8T054PzIu6ez02gM8L16rj5NF0XFrV66ruTbc0nWYx7K2vDooaXMeVNYQ8602GV >									
	//        <  u =="0.000000000000000001" : ] 000000069723288.964322100000000000 ; 000000091260612.070754300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006A63A98B40AD >									
	//     < CHEMCHINA_PFIV_II_metadata_line_5_____Kinfon_Pharmachem_Co_Limited_20240321 >									
	//        < bGBDLh407St8LC0DEI6SDRoCwjMDuYy19oLaU3IOcK05a5LW846I64m20lJICd1D >									
	//        <  u =="0.000000000000000001" : ] 000000091260612.070754300000000000 ; 000000112314234.914509000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008B40ADAB60BF >									
	//     < CHEMCHINA_PFIV_II_metadata_line_6_____King_Scientific_20240321 >									
	//        < Af43alF8z6sV7HciKPbNRf874LUkEJFv29Z9iNgAwAL38526fSX7lq7HDp7QTke4 >									
	//        <  u =="0.000000000000000001" : ] 000000112314234.914509000000000000 ; 000000128423464.099916000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AB60BFC3F56A >									
	//     < CHEMCHINA_PFIV_II_metadata_line_7_____Kingreat_Chemistry_Company_Limited_20240321 >									
	//        < FiezP3Aaoa43k6ZUH600sSUlXt675OuV6rP2i2CGW75xRmhXUxy3T3F94EcVB9aI >									
	//        <  u =="0.000000000000000001" : ] 000000128423464.099916000000000000 ; 000000152710712.542737000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C3F56AE9049F >									
	//     < CHEMCHINA_PFIV_II_metadata_line_8_____Labseeker_org_20240321 >									
	//        < KpeEO9E7GqZ8MN6fRs18Q9W333A2BLVpS7Y0imhLi84i7D0N6R590Z1WkyivUsC6 >									
	//        <  u =="0.000000000000000001" : ] 000000152710712.542737000000000000 ; 000000167976684.136403000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E9049F1004FE4 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_9_____Labseeker_20240321 >									
	//        < y71E9M7mgDP1roaDd04h0f0JNJ2WjCK0S9e5iV45Ws2uHe31k8GF4eRK2cAi41Nc >									
	//        <  u =="0.000000000000000001" : ] 000000167976684.136403000000000000 ; 000000183742363.205281000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001004FE41185E5C >									
	//     < CHEMCHINA_PFIV_II_metadata_line_10_____Langfang_Beixin_Chemical_Company_Limited_20240321 >									
	//        < dV04YTJ9y52dj709k932FaWg61oF96Botr7G1231G33e9304LuzXT0hrkB5TuHnI >									
	//        <  u =="0.000000000000000001" : ] 000000183742363.205281000000000000 ; 000000207777804.392665000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001185E5C13D0B34 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIV_II_metadata_line_11_____Leap_Labchem_Co_Limited_20240321 >									
	//        < 1pOcwMK97er1166rU3x4wXoGfWkR1EzKaxcz0i6nR1R9605j4147NXBx281ezNWc >									
	//        <  u =="0.000000000000000001" : ] 000000207777804.392665000000000000 ; 000000223732513.277489000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013D0B341556383 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_12_____Leap_Labchem_Co_Limited_20240321 >									
	//        < BrCgx8ntA0dxlD6871Nqtw5Jc81RAa60bvK89h33yi93RH8A9eWxCI7o1PN4kRX8 >									
	//        <  u =="0.000000000000000001" : ] 000000223732513.277489000000000000 ; 000000243987361.116315000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015563831744B90 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_13_____LON_CHEMICAL_org_20240321 >									
	//        < tUH30H4oes1vki29IPv1H0QO7RpN5xF9mv43y8f21726cEOzQyc368hV1C89Cvly >									
	//        <  u =="0.000000000000000001" : ] 000000243987361.116315000000000000 ; 000000266283328.584776000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001744B9019650ED >									
	//     < CHEMCHINA_PFIV_II_metadata_line_14_____LON_CHEMICAL_20240321 >									
	//        < 3vw26r1i7Lkqzy0OFrhq81hX6SP6mTSz9ozn4I9RD276HGH5Bx0Hev6aw7N28XI6 >									
	//        <  u =="0.000000000000000001" : ] 000000266283328.584776000000000000 ; 000000282577016.559096000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019650ED1AF2DA6 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_15_____LVYU_Chemical_Co__Limited_20240321 >									
	//        < F24a08394x8lRhWPbFnMCsYkPodQ1e0BPRJ5h7HXWu65EXw6Rr5Kf4Vl0Dmw2E3A >									
	//        <  u =="0.000000000000000001" : ] 000000282577016.559096000000000000 ; 000000299459534.410813000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AF2DA61C8F061 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_16_____MASCOT_I_E__Co_Limited_20240321 >									
	//        < LD21HL1qX57W8RRpWtb1IW6QcX7Nw5H01LAfhIw7zmIE1kTqwKTbl7xAGY0D201t >									
	//        <  u =="0.000000000000000001" : ] 000000299459534.410813000000000000 ; 000000319261288.991790000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C8F0611E72771 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_17_____NANCHANG_LONGDING_TECHNOLOGY_DEVELOPMENT_Co_Limited_20240321 >									
	//        < yuubbIL2spy574z7vkHOp1V749908i9Pw2AJ12e7H5X2iH7uqE88d6KC7GBHSIpa >									
	//        <  u =="0.000000000000000001" : ] 000000319261288.991790000000000000 ; 000000343980619.639932000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E7277120CDF6E >									
	//     < CHEMCHINA_PFIV_II_metadata_line_18_____Nanjing_BoomKing_Industrial_Co_Limited_20240321 >									
	//        < 59NWKBmv3y79yN5Q5xG1qG8N87aCW95t28gr09ch89LN2BMH4F28tgn3Ch19hXk3 >									
	//        <  u =="0.000000000000000001" : ] 000000343980619.639932000000000000 ; 000000365880286.916655000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020CDF6E22E49FD >									
	//     < CHEMCHINA_PFIV_II_metadata_line_19_____Nanjing_Boyuan_Pharmatech_Co_Limited_20240321 >									
	//        < WTBPx4ai45VWILbs9c7huKWvZUhC376la57HqkOqDFf2DLXmG2BiBa02cK9QB26Q >									
	//        <  u =="0.000000000000000001" : ] 000000365880286.916655000000000000 ; 000000384151267.861343000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022E49FD24A2B17 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_20_____Nanjing_Chemlin_Chemical_Industry_org_20240321 >									
	//        < s2sP8G724C95xzk5VOmYhZiWEdrCjLEwAki633IVY3D9GFfCoYlr1Q6gG6b6799v >									
	//        <  u =="0.000000000000000001" : ] 000000384151267.861343000000000000 ; 000000404532485.923938000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024A2B172694481 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIV_II_metadata_line_21_____Nanjing_Chemlin_Chemical_Industry_Co_Limited_20240321 >									
	//        < biB7Kgt4cb9AkE6rFSmja4029kr6jjl8LRtSFHT829b0neD0no2v7InnkszN29Cf >									
	//        <  u =="0.000000000000000001" : ] 000000404532485.923938000000000000 ; 000000426040231.382505000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000269448128A15F7 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_22_____Nanjing_Chemlin_Chemical_Industry_Co_Limited_20240321 >									
	//        < ne670aAbK8XY8XhX5BnE7MwX7Fo971eS9uN728zBo0cmz71FxfBo48LcOCuXh0A1 >									
	//        <  u =="0.000000000000000001" : ] 000000426040231.382505000000000000 ; 000000444221120.971216000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028A15F72A5D3E0 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_23_____Nanjing_Fubang_Chemical_Co_Limited_20240321 >									
	//        < 3tGnU0HX4Zof2XNI8x06V5AAM5LmoC9a7nX1xF9z9Tu253a7Wx03jB6y2ZxpD5f3 >									
	//        <  u =="0.000000000000000001" : ] 000000444221120.971216000000000000 ; 000000460386817.361472000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A5D3E02BE7E9A >									
	//     < CHEMCHINA_PFIV_II_metadata_line_24_____Nanjing_Legend_Pharmaceutical___Chemical_Co__Limited_20240321 >									
	//        < JVxja3PND1xuRdGuUx9YLbMwYoi2U97naOFW11b1N506D6KJMd6KIboJ711am5za >									
	//        <  u =="0.000000000000000001" : ] 000000460386817.361472000000000000 ; 000000481682187.999571000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BE7E9A2DEFD1B >									
	//     < CHEMCHINA_PFIV_II_metadata_line_25_____Nanjing_Raymon_Biotech_Co_Limited_20240321 >									
	//        < 5Yx0f0mK34k0Y33tLa1k5kPQ1I7rsw3168MW44X8ir37TSr63rz5X7KGV1me0Xok >									
	//        <  u =="0.000000000000000001" : ] 000000481682187.999571000000000000 ; 000000502314745.158586000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DEFD1B2FE78B3 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_26_____Nantong_Baihua_Bio_Pharmaceutical_Co_Limited_20240321 >									
	//        < wqH58u93zcIOvEM6I2Pw59pt39Kn1F8eLgTa2ImRKHe90pz5tbH2dKjRr2a94SsP >									
	//        <  u =="0.000000000000000001" : ] 000000502314745.158586000000000000 ; 000000524589203.432437000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FE78B332075A8 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_27_____Nantong_Qihai_Chemicals_org_20240321 >									
	//        < g7c4BE0T1Wsb328zyq29Yc9D93otqK9FGetPtWY64UNXdGyZev4G696Ic237Oc82 >									
	//        <  u =="0.000000000000000001" : ] 000000524589203.432437000000000000 ; 000000546865264.427089000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032075A8342733E >									
	//     < CHEMCHINA_PFIV_II_metadata_line_28_____Nantong_Qihai_Chemicals_Co_Limited_20240321 >									
	//        < 7u02vYjjDJ5kl5GlPYjZ9bTK4e6Ll8C4VDc1vNWsiBVI6n8bcz4Rq8E5QJ0r5QK0 >									
	//        <  u =="0.000000000000000001" : ] 000000546865264.427089000000000000 ; 000000570080351.782015000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000342733E365DFA3 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_29_____Nebula_Chemicals_Co_Limited_20240321 >									
	//        < 0oW0b4575sUTATN643ZoO64448P1ET5tuSavQSc2qc9wi9107D4oYn0szoch5qF5 >									
	//        <  u =="0.000000000000000001" : ] 000000570080351.782015000000000000 ; 000000590212363.192097000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000365DFA338497B4 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_30_____Neostar_United_Industrial_Co__Limited_20240321 >									
	//        < rKlc5zbPaIflYGZcDkP20c8O7H3l2SSstpu41YJhzPOP8eG08LFep7o2587G2IkR >									
	//        <  u =="0.000000000000000001" : ] 000000590212363.192097000000000000 ; 000000607363125.943443000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038497B439EC339 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIV_II_metadata_line_31_____Nextpeptide_inc__20240321 >									
	//        < Enjowp7m96F6iUvOS3Vp626pXz8ILI34DvAwOIa1VJUkScs1O8o3lnUr1mA007D6 >									
	//        <  u =="0.000000000000000001" : ] 000000607363125.943443000000000000 ; 000000623132696.712699000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039EC3393B6D336 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_32_____Ningbo_Nuobai_Pharmaceutical_Co_Limited_20240321 >									
	//        < 3ow4sq7Q79iw22L7oZe27KFX1tF5OeZ8hE19Ikc4HmhXqWwEJCIm6E7pZ0yKB9Cq >									
	//        <  u =="0.000000000000000001" : ] 000000623132696.712699000000000000 ; 000000646256962.974498000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B6D3363DA1C20 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_33_____NINGBO_V_P_CHEMISTRY_20240321 >									
	//        < vthHwuLCxrti7G92ETM8DQ7N0T4UJYDYN325505SSm208YQMrvh7HHzY5LDCu55J >									
	//        <  u =="0.000000000000000001" : ] 000000646256962.974498000000000000 ; 000000662056384.358154000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DA1C203F237C6 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_34_____NovoChemy_Limited_20240321 >									
	//        < OC17P1dImL0Y7V9TMamh1z0B7B809U3UI9xheyGp9ZmZM48923aSoXpjoHdXjzPi >									
	//        <  u =="0.000000000000000001" : ] 000000662056384.358154000000000000 ; 000000677898364.493509000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F237C640A640C >									
	//     < CHEMCHINA_PFIV_II_metadata_line_35_____Novolite_Chemicals_org_20240321 >									
	//        < X73XKI7ElCXMezqEMo3N34dcRKUCf290cZkpy6Sdneahy97D0i63k70ucZm53cfx >									
	//        <  u =="0.000000000000000001" : ] 000000677898364.493509000000000000 ; 000000693887363.061517000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040A640C422C9C0 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_36_____Novolite_Chemicals_Co_Limited_20240321 >									
	//        < VoFqfkH6qyQ1tMVEJB7b5fB3xE31426TnhjuXoTGuRhaQ3j815HtztCa84240HTW >									
	//        <  u =="0.000000000000000001" : ] 000000693887363.061517000000000000 ; 000000709930410.800282000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000422C9C043B4491 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_37_____Onichem_Specialities_Co__Limited_20240321 >									
	//        < 1leK4qr7ZucUz2kyzt9WgUc33gsjaa242oiF4bXD271P329jWFflzgYq926y3kCW >									
	//        <  u =="0.000000000000000001" : ] 000000709930410.800282000000000000 ; 000000726903995.605736000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043B44914552AE0 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_38_____Orichem_international_Limited_20240321 >									
	//        < zwF0wE34tQ5yp4ZIy4R7BVyMAQ17MN8c325uw6Hno3CgJ7EwRJfZ8lzta39zO0tx >									
	//        <  u =="0.000000000000000001" : ] 000000726903995.605736000000000000 ; 000000744290821.178131000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004552AE046FB29A >									
	//     < CHEMCHINA_PFIV_II_metadata_line_39_____PHARMACORE_Co_Limited_20240321 >									
	//        < 6xqrbxy1iAf05438UyB0ve0B9A17V6UJrrDG581cm7X5D2dy95WVm7ml5HtH5s0b >									
	//        <  u =="0.000000000000000001" : ] 000000744290821.178131000000000000 ; 000000765584329.097058000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046FB29A4903061 >									
	//     < CHEMCHINA_PFIV_II_metadata_line_40_____Pharmasi_Chemicals_Company_Limited_20240321 >									
	//        < 92dz2gR3fbtk27H4NTZfl46Bk16R6QX4oW3w5H9lVWTle5qX7zTVEE9oE2sN3UFb >									
	//        <  u =="0.000000000000000001" : ] 000000765584329.097058000000000000 ; 000000790364326.592371000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049030614B60011 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
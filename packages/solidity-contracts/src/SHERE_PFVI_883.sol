/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFVI_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFVI_883		"	;
		string	public		symbol =	"	SHERE_PFVI_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		800055920700000000000000000					;	
										
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
	//     < SHERE_PFVI_metadata_line_1_____A42_20190506 >									
	//        < tOEoUpR8N5VKO10ko457jubE66mTdfa8G37k6M5bSp61A2696tJ4nSs807NnJUgY >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000020042730.700000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001E9531 >									
	//     < SHERE_PFVI_metadata_line_2_____A43_20190506 >									
	//        < Ih8Tx67gVWTzWqwc20b1NTf5dX1r7OXyRMVz6P4vWgfY3Va3QA7275g9wa948Km6 >									
	//        <  u =="0.000000000000000001" : ] 000000020042730.700000000000000000 ; 000000040106657.200000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E95313D32AA >									
	//     < SHERE_PFVI_metadata_line_3_____A44_20190506 >									
	//        < 0pH0fG84Uj3n3lTCzWx33T24680U0FI7L2888S80kZeB50V6xT2SQ5fbZ43Gddhw >									
	//        <  u =="0.000000000000000001" : ] 000000040106657.200000000000000000 ; 000000060152200.200000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003D32AA5BC8F4 >									
	//     < SHERE_PFVI_metadata_line_4_____A45_20190506 >									
	//        < 0600TayzDdLdH48D7k7bV6QPAgH09wnm5dAQFOLm6Y1126Qb34mDhHYs6goQJui5 >									
	//        <  u =="0.000000000000000001" : ] 000000060152200.200000000000000000 ; 000000080164721.400000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005BC8F47A5258 >									
	//     < SHERE_PFVI_metadata_line_5_____A46_20190506 >									
	//        < 7n4l1qz75gIFHBMZm19HM8J14HVZpIw52Ox95PI3LuTlDF4eu8D269wjm184pG2p >									
	//        <  u =="0.000000000000000001" : ] 000000080164721.400000000000000000 ; 000000100240921.900000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007A525898F49C >									
	//     < SHERE_PFVI_metadata_line_6_____A47_20190506 >									
	//        < b275Rpe8vjzT52714L3o8jE639M4NFmxjDJqDe30Pk9Dj23C89FU6J389fq5057o >									
	//        <  u =="0.000000000000000001" : ] 000000100240921.900000000000000000 ; 000000120156013.900000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000098F49CB757F1 >									
	//     < SHERE_PFVI_metadata_line_7_____A48_20190506 >									
	//        < 25nXJXCm3GzV3Ilx6DwI9I558lccBqLA70ckX3Ha7f98whdS63j37HEM1d3980SU >									
	//        <  u =="0.000000000000000001" : ] 000000120156013.900000000000000000 ; 000000140139015.200000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B757F1D5D5CE >									
	//     < SHERE_PFVI_metadata_line_8_____A49_20190506 >									
	//        < FVwVxYh4MSM8dQh362YSlNiiEZgxeDy472pmXa6ugngN90QF6MkyJNF900HX6zSb >									
	//        <  u =="0.000000000000000001" : ] 000000140139015.200000000000000000 ; 000000160139820.300000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D5D5CEF45A9E >									
	//     < SHERE_PFVI_metadata_line_9_____A50_20190506 >									
	//        < ogM9R600843Wv4U4VxH4i04nHqZruN6P4JBfmBff57ua4mzl4MpPk5iM8Aeo60aB >									
	//        <  u =="0.000000000000000001" : ] 000000160139820.300000000000000000 ; 000000180238138.700000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F45A9E1130586 >									
	//     < SHERE_PFVI_metadata_line_10_____A51_20190506 >									
	//        < U7FcuSdK4KtKY9SKq2YF3z4x2h7fa44u9lEjWJt48w2Aa095g0jarkIp1uVxncvm >									
	//        <  u =="0.000000000000000001" : ] 000000180238138.700000000000000000 ; 000000200263124.900000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000113058613193C8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFVI_metadata_line_11_____A52_20190506 >									
	//        < 2OUUu8UOBx8C6NZq9rr4173Fn81d9ih07O8ghbFqUkcK88R6bvK88n1Kb1EKTe8J >									
	//        <  u =="0.000000000000000001" : ] 000000200263124.900000000000000000 ; 000000220295382.100000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013193C815024E2 >									
	//     < SHERE_PFVI_metadata_line_12_____A53_20190506 >									
	//        < eRv58wDrSE60DD9pnRBfJmNh031du1aJGY4dtzhXbVIyZJJ1DLoJ7b6ViRkBYWIP >									
	//        <  u =="0.000000000000000001" : ] 000000220295382.100000000000000000 ; 000000240344333.900000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015024E216EBC81 >									
	//     < SHERE_PFVI_metadata_line_13_____A54_20190506 >									
	//        < 61b79B81qSkGZA984b99RI4t22Dv416kBAXp00Y15U51rzKCPZpO2TwOOXJ7BcGS >									
	//        <  u =="0.000000000000000001" : ] 000000240344333.900000000000000000 ; 000000260377562.800000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016EBC8118D4DFC >									
	//     < SHERE_PFVI_metadata_line_14_____A55_20190506 >									
	//        < 8I4AhQ3SpoegSe1M6jAIf1B5Xp59m68d7xEXG06G5Fx6a6Q6Z1dD1G995e0c3bMS >									
	//        <  u =="0.000000000000000001" : ] 000000260377562.800000000000000000 ; 000000280329925.400000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018D4DFC1ABBFE1 >									
	//     < SHERE_PFVI_metadata_line_15_____A56_20190506 >									
	//        < f15S9za2aD6Z3BH5lirqF54WKaI0HHu48Kk7C0h49HE4IlBuHSE9yk48D1D8fImy >									
	//        <  u =="0.000000000000000001" : ] 000000280329925.400000000000000000 ; 000000300266910.700000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001ABBFE11CA2BC3 >									
	//     < SHERE_PFVI_metadata_line_16_____A57_20190506 >									
	//        < tqln4axv95lbD7eR5fBiJ4l5nzq6rZ5RqQ5jF2LpU4C8Kcv72G749iJq2B0Lzv3l >									
	//        <  u =="0.000000000000000001" : ] 000000300266910.700000000000000000 ; 000000320188465.000000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CA2BC31E8919F >									
	//     < SHERE_PFVI_metadata_line_17_____A58_20190506 >									
	//        < JPPGE7jZzQrr6070k0r7FN566ER4SwGily8uNOlA2BP5U59mPw4jldUbECzky8t4 >									
	//        <  u =="0.000000000000000001" : ] 000000320188465.000000000000000000 ; 000000340160545.800000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E8919F2070B37 >									
	//     < SHERE_PFVI_metadata_line_18_____A59_20190506 >									
	//        < L0hL6WilbUofk5HK8Xq8u7KDoyjncirp9Z5kg8ojTxPNPE8930HcJ03qJa3tL5VC >									
	//        <  u =="0.000000000000000001" : ] 000000340160545.800000000000000000 ; 000000360176549.200000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002070B3722595F7 >									
	//     < SHERE_PFVI_metadata_line_19_____A60_20190506 >									
	//        < 3553Q5SM2Po4u1f6eQ2K8q61C6UFlRDh39sW34uH5irFI5jF777ZI5KvO3V2L292 >									
	//        <  u =="0.000000000000000001" : ] 000000360176549.200000000000000000 ; 000000380137793.000000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022595F72440B53 >									
	//     < SHERE_PFVI_metadata_line_20_____A61_20190506 >									
	//        < 0M8XPmN2G32PgE5f4Ha2DwCt90Ab48L19e44No850q0ujM2N8lk75rdg5pBXns70 >									
	//        <  u =="0.000000000000000001" : ] 000000380137793.000000000000000000 ; 000000400041927.800000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002440B532626A61 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFVI_metadata_line_21_____A62_20190506 >									
	//        < 7RC377bcS7Ul18840kvwM4j7234tV0133n4AvnCw5VqsSz9sRf52cL1v68X4Y73X >									
	//        <  u =="0.000000000000000001" : ] 000000400041927.800000000000000000 ; 000000419953465.600000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002626A61280CC53 >									
	//     < SHERE_PFVI_metadata_line_22_____A63_20190506 >									
	//        < u7Hz06DfFKzQ313Gb0TQ4zLqPEuR66GlKD0qf1Z18G9tBuQ7gW577K7gcw3R8jGF >									
	//        <  u =="0.000000000000000001" : ] 000000419953465.600000000000000000 ; 000000440022272.800000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000280CC5329F6BB3 >									
	//     < SHERE_PFVI_metadata_line_23_____A64_20190506 >									
	//        < Zw8jSx0J9jl4nUU5plJBjxTgGe5h5mqyW6Qknq19ux1h77Z9Ea35INK864dcI9Ve >									
	//        <  u =="0.000000000000000001" : ] 000000440022272.800000000000000000 ; 000000460024189.100000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029F6BB32BDF0F3 >									
	//     < SHERE_PFVI_metadata_line_24_____A65_20190506 >									
	//        < I0XzC7mO2QS27h367W7bS45lSMr3lLGL4MmtLcb5DhnH00nEXMzt0718X45r9qi2 >									
	//        <  u =="0.000000000000000001" : ] 000000460024189.100000000000000000 ; 000000479972795.700000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BDF0F32DC6160 >									
	//     < SHERE_PFVI_metadata_line_25_____A66_20190506 >									
	//        < FO626Eo0nG9hsi6L0c1wQa35j380wBuznTg541N7DK7hnRnUvSuP7zR576Np9Ce5 >									
	//        <  u =="0.000000000000000001" : ] 000000479972795.700000000000000000 ; 000000500034428.700000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DC61602FAFDF3 >									
	//     < SHERE_PFVI_metadata_line_26_____A67_20190506 >									
	//        < 7fAJTPhlpOFXHb11J4Hp5YRy2CX0k9QzzIAb8JLkr12K3u00awxfX3nUmWJg3GDd >									
	//        <  u =="0.000000000000000001" : ] 000000500034428.700000000000000000 ; 000000520078293.600000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FAFDF33199395 >									
	//     < SHERE_PFVI_metadata_line_27_____A68_20190506 >									
	//        < eD0R9zPX5KKT086IyAoM0qfKOZ6InZRbnL6Rb0g6F1k8gnzid76a7hkm76BP04SP >									
	//        <  u =="0.000000000000000001" : ] 000000520078293.600000000000000000 ; 000000540073689.300000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031993953381649 >									
	//     < SHERE_PFVI_metadata_line_28_____A69_20190506 >									
	//        < DDRidurmeV2577YpLyrkad91kke0U4rg1Z53r6oC7japo8hwQHOLpCEAnZ1u1d3U >									
	//        <  u =="0.000000000000000001" : ] 000000540073689.300000000000000000 ; 000000560019680.800000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000338164935685B0 >									
	//     < SHERE_PFVI_metadata_line_29_____A70_20190506 >									
	//        < X7fq3UND39dDS3E0mYw2kar4L00a41H4Rs79749v63wpf33it9sr7zMzQs435C5e >									
	//        <  u =="0.000000000000000001" : ] 000000560019680.800000000000000000 ; 000000580037011.700000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035685B037510F5 >									
	//     < SHERE_PFVI_metadata_line_30_____A71_20190506 >									
	//        < 59ggRpiaL3s0yLlD7L74fj63PFA398l6dlyhI9qOApR6oF6r2BP9a2K71M1awFeT >									
	//        <  u =="0.000000000000000001" : ] 000000580037011.700000000000000000 ; 000000599972178.400000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037510F53937C22 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFVI_metadata_line_31_____A72_20190506 >									
	//        < 9TzqnKdtEH8l5VRlSjDx2X40qp3O7NoXgdye6Awe9a232B4do9krwv46zn86H4Vw >									
	//        <  u =="0.000000000000000001" : ] 000000599972178.400000000000000000 ; 000000619966111.700000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003937C223B1FE43 >									
	//     < SHERE_PFVI_metadata_line_32_____A73_20190506 >									
	//        < R1QeWqKycP73m2FuWG9D5225h1eP3cA11SMM0DIbOTA9ZQW1uquy9yTOYEI8zJpE >									
	//        <  u =="0.000000000000000001" : ] 000000619966111.700000000000000000 ; 000000639934151.400000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B1FE433D07647 >									
	//     < SHERE_PFVI_metadata_line_33_____A74_20190506 >									
	//        < DZqmT4MP4t0knNR314ljF3O6ganIqdZ28Yp5V67l0jtNeTipmnhGtcNLQdu3vS41 >									
	//        <  u =="0.000000000000000001" : ] 000000639934151.400000000000000000 ; 000000659994348.500000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D076473EF124B >									
	//     < SHERE_PFVI_metadata_line_34_____A_20190506 >									
	//        < 9cAQm34XI7Io9BYa6iG9hKJ1TtKXcz54BypmbsSjf75li3OXGeK6DG3P9b10OHVn >									
	//        <  u =="0.000000000000000001" : ] 000000659994348.500000000000000000 ; 000000679925486.200000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EF124B40D7BE5 >									
	//     < SHERE_PFVI_metadata_line_35_____A_20190506 >									
	//        < GD21bjO4360NFyT1I6Q1a4OR07k1wod1N2P3nXjN7Zfz9Rl90J8Z0fcyOYsvF0hS >									
	//        <  u =="0.000000000000000001" : ] 000000679925486.200000000000000000 ; 000000699957929.700000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040D7BE542C0D11 >									
	//     < SHERE_PFVI_metadata_line_36_____A_20190506 >									
	//        < 2EgX1CF1OeUzJhBO1SQR313EYOcDhpDS4B7545f4SNW6PsMxA9BEL0mnxc3Q06a2 >									
	//        <  u =="0.000000000000000001" : ] 000000699957929.700000000000000000 ; 000000719992043.900000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042C0D1144A9EE4 >									
	//     < SHERE_PFVI_metadata_line_37_____A_20190506 >									
	//        < ZKGj1WuO8eWE3tWPp2P0Z8R243ov88P5U3CG5Xm7L6r9slhj371M5c3fW8mTcM2m >									
	//        <  u =="0.000000000000000001" : ] 000000719992043.900000000000000000 ; 000000739965043.900000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044A9EE446918D8 >									
	//     < SHERE_PFVI_metadata_line_38_____A_20190506 >									
	//        < 2s76zr87EesO5w07CQUSrrgA1Y2r7R2l10I4Vtjuf2IVxNSn9SeUgB64dudbycxe >									
	//        <  u =="0.000000000000000001" : ] 000000739965043.900000000000000000 ; 000000759916664.100000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046918D84878A72 >									
	//     < SHERE_PFVI_metadata_line_39_____A_20190506 >									
	//        < ZMCeQk08614251wSC542R2HWxJzL90fI73c4A9bRWxw23j3J086z5t2T6XH8zQOI >									
	//        <  u =="0.000000000000000001" : ] 000000759916664.100000000000000000 ; 000000779993385.100000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004878A724A62CEB >									
	//     < SHERE_PFVI_metadata_line_40_____A41_20190506 >									
	//        < 1617q09dbKIhrKgcAs52d8Uz2hT6X2NyDM8wTQGFJ5m6Jdm6R114iM1v276a2Pyv >									
	//        <  u =="0.000000000000000001" : ] 000000779993385.100000000000000000 ; 000000800055920.700000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A62CEB4C4C9D8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
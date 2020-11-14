/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFI_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFI_III_883		"	;
		string	public		symbol =	"	SHERE_PFI_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1657456069112910000000000000					;	
										
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
	//     < SHERE_PFI_III_metadata_line_1_____UNITED_AIRCRAFT_CORPORATION_20220505 >									
	//        < 0CL4X9Al7NFE0ip51nPowvQW9k0bAU7C0ElaXKm9rO6YGfkpC9Xds5j27Yr8dnLE >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000036450010.251685700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000379E49 >									
	//     < SHERE_PFI_III_metadata_line_2_____China_Russia Commercial Aircraft International Corporation Co_20220505 >									
	//        < 2Nu6Pa9isuql593zs686zwn0VR3W9G7SEzBcnh1J8o1Ctj8aMip5PvE088T6l8aF >									
	//        <  u =="0.000000000000000001" : ] 000000036450010.251685700000000000 ; 000000075812461.555480500000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000379E4973AE3E >									
	//     < SHERE_PFI_III_metadata_line_3_____CHINA_RUSSIA_ORG_20220505 >									
	//        < an42oH53KnrJOE3Cvi1w7LZagodEhkB045X5E6LK11w0dbP6kHn9hB700vRQH767 >									
	//        <  u =="0.000000000000000001" : ] 000000075812461.555480500000000000 ; 000000118915259.999796000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000073AE3EB57346 >									
	//     < SHERE_PFI_III_metadata_line_4_____Mutilrole Transport Aircraft Limited_20220505 >									
	//        < ju8yIOldq8Hv70a7RzamQIt1NFZVN5kL3CRwUPpkdcRgDvzDDAWpsg05wTYhm25m >									
	//        <  u =="0.000000000000000001" : ] 000000118915259.999796000000000000 ; 000000175457854.941766000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000B5734610BBA39 >									
	//     < SHERE_PFI_III_metadata_line_5_____SuperJet International_20220505 >									
	//        < k401h5f6LXc3zO3RxdL41Ptq1hrzqdXf008N0e8cV368t67bZPf01MLOyPsJbc3h >									
	//        <  u =="0.000000000000000001" : ] 000000175457854.941766000000000000 ; 000000202447364.641750000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010BBA39134E900 >									
	//     < SHERE_PFI_III_metadata_line_6_____SUPERJET_ORG_20220505 >									
	//        < xY34zkyc2yIDFx00G479S21G1A6Kt2F1z3vz06G33U3Ad9H0H97LkS1xw00zQ1c8 >									
	//        <  u =="0.000000000000000001" : ] 000000202447364.641750000000000000 ; 000000264630887.389494000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000134E900193CB71 >									
	//     < SHERE_PFI_III_metadata_line_7_____JSC KAPO-Composit_20220505 >									
	//        < gN8Q1t34z8Z21020aMCHTc48JWd40bj4WMhC6mYC9bsDVDqYBHaSxCwZ95Kd6n5u >									
	//        <  u =="0.000000000000000001" : ] 000000264630887.389494000000000000 ; 000000354172287.633427000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000193CB7121C6C8D >									
	//     < SHERE_PFI_III_metadata_line_8_____JSC Aviastar_SP_20220505 >									
	//        < C1Uu0OfPG9DRF1079vgo4m6zH3DQHV4WC21Q65cvG1csG787RU66F687tt7S16ad >									
	//        <  u =="0.000000000000000001" : ] 000000354172287.633427000000000000 ; 000000373144140.639515000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021C6C8D2395F6E >									
	//     < SHERE_PFI_III_metadata_line_9_____JSC AeroKompozit_20220505 >									
	//        < wY00i77uNk2Cw6kIw793a8bOUadxb1ccLOa6JNYB401CkuN039gu0AJ188bFO2nu >									
	//        <  u =="0.000000000000000001" : ] 000000373144140.639515000000000000 ; 000000422749869.247176000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002395F6E28510AB >									
	//     < SHERE_PFI_III_metadata_line_10_____JSC AeroComposit_Ulyanovsk_20220505 >									
	//        < MwDQhzs1uk987wCtE4FU5i3ZZjr259i6sTrVYj914c4P0NO9ydnrP5O60axK6sBp >									
	//        <  u =="0.000000000000000001" : ] 000000422749869.247176000000000000 ; 000000476902998.472096000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028510AB2D7B23C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFI_III_metadata_line_11_____JSC Sukhoi Civil Aircraft_20220505 >									
	//        < 0x6tY5x0CS0YpXWVXSy39GP0J2LEJZy39s5smJ4287vPyw3KKZ1F7uX52soRZGTi >									
	//        <  u =="0.000000000000000001" : ] 000000476902998.472096000000000000 ; 000000500711154.832426000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D7B23C2FC064B >									
	//     < SHERE_PFI_III_metadata_line_12_____SUKHOIL_CIVIL_ORG_20220505 >									
	//        < j0yyku8N8miaqcMWwBy79yCiO0rAS7XOwGriZQ4N5f4s974MEtAOf66cJj7z7DvZ >									
	//        <  u =="0.000000000000000001" : ] 000000500711154.832426000000000000 ; 000000548284014.771504000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FC064B3449D71 >									
	//     < SHERE_PFI_III_metadata_line_13_____JSC Flight Research Institute_20220505 >									
	//        < FJUz6rZo485u594fl2ezYvcPv1GbExnOjy68cDzP2s50w3Z0e3y9yJ1EOrcf5EOz >									
	//        <  u =="0.000000000000000001" : ] 000000548284014.771504000000000000 ; 000000579936561.353230000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003449D71374E9B8 >									
	//     < SHERE_PFI_III_metadata_line_14_____JSC UAC_Transport Aircraft_20220505 >									
	//        < TPbdWgTMg49s19H9905bUR0s9ZD9nVnS8981J73qwcVC9U72zVA2Dt5J3iI5CFWJ >									
	//        <  u =="0.000000000000000001" : ] 000000579936561.353230000000000000 ; 000000618922849.946245000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000374E9B83B066BD >									
	//     < SHERE_PFI_III_metadata_line_15_____JSC Russian Aircraft Corporation MiG_20220505 >									
	//        < op7Cnbk2EgXSqkQYe3pYrXnW3942GH3AT3807Ke61B4OUhos6w3FakXO296o0o7e >									
	//        <  u =="0.000000000000000001" : ] 000000618922849.946245000000000000 ; 000000640170431.892057000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B066BD3D0D293 >									
	//     < SHERE_PFI_III_metadata_line_16_____MIG_ORG_20220505 >									
	//        < 9yTEW3zJ37H813xU28ew3XY4kFn76TFg2mYIH5MS44H69nDbUrZkrC4X51P27cS7 >									
	//        <  u =="0.000000000000000001" : ] 000000640170431.892057000000000000 ; 000000702533934.398100000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D0D29342FFB51 >									
	//     < SHERE_PFI_III_metadata_line_17_____OJSC Experimental Machine-Building Plant_20220505 >									
	//        < edAfPRhLj9R939eJ610K1o319c50cC1f1Zv45VC6M2616mN40JqdzXrKywxzcj34 >									
	//        <  u =="0.000000000000000001" : ] 000000702533934.398100000000000000 ; 000000778124861.148335000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042FFB514A35306 >									
	//     < SHERE_PFI_III_metadata_line_18_____Irkutsk Aviation Plant_20220505 >									
	//        < 3b8X7d0Df7Dlw575Mt7C7EC2AFG9NrFT7auQp4kzmur737H7A3mell8iZNV8a5NE >									
	//        <  u =="0.000000000000000001" : ] 000000778124861.148335000000000000 ; 000000823204574.142722000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A353064E81C49 >									
	//     < SHERE_PFI_III_metadata_line_19_____Gorbunov Kazan Aviation Plant_20220505 >									
	//        < u5Qt98P92MpqCxCISou1c04v9oNirskg8b9ie3YR6TGHcoyH37waZWVkHZqS6I41 >									
	//        <  u =="0.000000000000000001" : ] 000000823204574.142722000000000000 ; 000000843295653.530397000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E81C49506C45D >									
	//     < SHERE_PFI_III_metadata_line_20_____Komsomolsk_on_Amur Aircraft Plant_20220505 >									
	//        < 6EA47re2B4a8s6EDlG1e2fJe3rC3H3E5GYwm9HPlfk0f6FVfR8dpWy1q7xCBf5FV >									
	//        <  u =="0.000000000000000001" : ] 000000843295653.530397000000000000 ; 000000861623708.270357000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000506C45D522BBC3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFI_III_metadata_line_21_____Nizhny Novgorod aircraft building plant Sokol_20220505 >									
	//        < GFzchx5FQLUJ4U1KNZ9plX31P092giQjvck8yxLSe1eZFPE335yl78qvPGSQenu8 >									
	//        <  u =="0.000000000000000001" : ] 000000861623708.270357000000000000 ; 000000903028229.497633000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000522BBC3561E967 >									
	//     < SHERE_PFI_III_metadata_line_22_____NIZHNY_ORG_20220505 >									
	//        < 3d7Z16jtNIsNrh9p5lBPGMWHKm3P1GqC7o9s2kRH2Mb85WED2GK18H7ChO8ljWNI >									
	//        <  u =="0.000000000000000001" : ] 000000903028229.497633000000000000 ; 000000922204977.995006000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000561E96757F2C52 >									
	//     < SHERE_PFI_III_metadata_line_23_____Novosibirsk Aircraft Plant_20220505 >									
	//        < 06a9AAHNgmT8sB3u211M81656gtMFSEZ4qP8MdxPS28No6290e2eIAj93euhZcc8 >									
	//        <  u =="0.000000000000000001" : ] 000000922204977.995006000000000000 ; 000000956062590.579998000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057F2C525B2D5F3 >									
	//     < SHERE_PFI_III_metadata_line_24_____NOVO_ORG_20220505 >									
	//        < K6k7bXrsMGzxsacqn2IWk2UtwS0y97h7e1i8U1g5vNAEz7niRTq527UM8692139B >									
	//        <  u =="0.000000000000000001" : ] 000000956062590.579998000000000000 ; 000001017363212.637110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005B2D5F36105F81 >									
	//     < SHERE_PFI_III_metadata_line_25_____UAC Health_20220505 >									
	//        < 4I9i8LbJ2y433y5Spp3021qv8wkDPrrsH5XdL1pxr132Bygl5nM8nPvoY53dY8aF >									
	//        <  u =="0.000000000000000001" : ] 000001017363212.637110000000000000 ; 000001053242438.358550000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006105F816471ED4 >									
	//     < SHERE_PFI_III_metadata_line_26_____UAC_HEALTH_ORG_20220505 >									
	//        < SO6INkIF9z57CS4v7Lmzh1y46JUa4s5RCS8dBhT850U5L9y96210K302157H2ds8 >									
	//        <  u =="0.000000000000000001" : ] 000001053242438.358550000000000000 ; 000001072083872.337130000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006471ED4663DEC3 >									
	//     < SHERE_PFI_III_metadata_line_27_____JSC Ilyushin Finance Co_20220505 >									
	//        < 9Ye5OTe78ylEG2Q90eU8Y644Q42bGlKUID3F14QXpop6eodEHq16cg2jflgs8uAR >									
	//        <  u =="0.000000000000000001" : ] 000001072083872.337130000000000000 ; 000001117550438.227370000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000663DEC36A93F24 >									
	//     < SHERE_PFI_III_metadata_line_28_____OJSC Experimental Design Bureau_20220505 >									
	//        < jl6e49T7cc4R67SSP6E65j8OoupZ05ejc5H22gyPN5amJa9gDjmvU4UYt6KYnDGb >									
	//        <  u =="0.000000000000000001" : ] 000001117550438.227370000000000000 ; 000001168218079.398330000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006A93F246F68F30 >									
	//     < SHERE_PFI_III_metadata_line_29_____LLC UAC_I_20220505 >									
	//        < g6e0ci56tq3pvj35efo37YR96sHK3lu1rzWXhV8P93OhnC11ncA8s7VFoRj59cOy >									
	//        <  u =="0.000000000000000001" : ] 000001168218079.398330000000000000 ; 000001202575759.008660000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006F68F3072AFC28 >									
	//     < SHERE_PFI_III_metadata_line_30_____LLC UAC_II_20220505 >									
	//        < k4MFA1kVYRPrI9kLZnqaiRp7fK7sC272Gg77s69HDTJyga5OvrCEU21f10P6682k >									
	//        <  u =="0.000000000000000001" : ] 000001202575759.008660000000000000 ; 000001248980826.358780000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000072AFC28771CB23 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFI_III_metadata_line_31_____LLC UAC_III_20220505 >									
	//        < 1Zyc7eu2RbP2Hgh59mFr3szZW4Tv807U3J9Qr7RCP466U528VeZW0YielE425tKg >									
	//        <  u =="0.000000000000000001" : ] 000001248980826.358780000000000000 ; 000001293418697.356040000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000771CB237B599AE >									
	//     < SHERE_PFI_III_metadata_line_32_____JSC Ilyushin Aviation Complex_20220505 >									
	//        < g3m2HUuH09KP24gK69F0K6g7w66R4gSKP4V30D8F3SY2FwmHe8q2Z3GZ6Cb3A3z7 >									
	//        <  u =="0.000000000000000001" : ] 000001293418697.356040000000000000 ; 000001329926860.161190000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007B599AE7ED4EAE >									
	//     < SHERE_PFI_III_metadata_line_33_____PJSC Voronezh Aircraft Manufacturing Company_20220505 >									
	//        < KKmgs6h05ti8ww65281WhEbrOd7stwnn0FtKkkH4WMa4V0Kywcn9P4R4I2MfJ2QF >									
	//        <  u =="0.000000000000000001" : ] 000001329926860.161190000000000000 ; 000001378021859.968020000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007ED4EAE836B1CA >									
	//     < SHERE_PFI_III_metadata_line_34_____JSC Aviation Holding Company Sukhoi_20220505 >									
	//        < Xp8uClmosTKy88A31rxa376M5o9SyQk7dwK3Uk28kaRDxy1ajkx3T02SRTRGnx9h >									
	//        <  u =="0.000000000000000001" : ] 000001378021859.968020000000000000 ; 000001401266313.202510000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000836B1CA85A29A7 >									
	//     < SHERE_PFI_III_metadata_line_35_____SUKHOI_ORG_20220505 >									
	//        < odz3Q7zvxX37N3560k75z4TFAT85xl24rPIVO8TF8C6OQaC98OVrPfL8LeJk05uD >									
	//        <  u =="0.000000000000000001" : ] 000001401266313.202510000000000000 ; 000001484940062.833540000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000085A29A78D9D6B6 >									
	//     < SHERE_PFI_III_metadata_line_36_____PJSC Scientific and Production Corporation Irkut_20220505 >									
	//        < 8q04RmR5VEq6K985qQBI5OWaF41hk51q6QkTF6YH6lNC5l1i829C6DH713IzkE1o >									
	//        <  u =="0.000000000000000001" : ] 000001484940062.833540000000000000 ; 000001506440702.467060000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008D9D6B68FAA566 >									
	//     < SHERE_PFI_III_metadata_line_37_____PJSC Taganrog Aviation Scientific_Technical Complex_20220505 >									
	//        < RbrMFG0eSI1wJ0mw2rlo02Rtezq4AN7pUB6A9UzG4a9Z0EmsP09V0N5Ug64zoMPi >									
	//        <  u =="0.000000000000000001" : ] 000001506440702.467060000000000000 ; 000001525376935.223760000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008FAA5669178A5E >									
	//     < SHERE_PFI_III_metadata_line_38_____PJSC Tupolev_20220505 >									
	//        < 3LMM8596XsL5eHUWdLafjy8wH1Us79rXxk42kzGf4w249V32T64qKj1QLcPsMpLC >									
	//        <  u =="0.000000000000000001" : ] 000001525376935.223760000000000000 ; 000001602401106.245780000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009178A5E98D11EF >									
	//     < SHERE_PFI_III_metadata_line_39_____TUPOLEV_ORG_20220505 >									
	//        < Qovp6856LV6u96i8I7K7OrDFx387Ev5mwnIv00J5yLfZ3sbCMk7dVb7bcg8T59r5 >									
	//        <  u =="0.000000000000000001" : ] 000001602401106.245780000000000000 ; 000001621658223.327960000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000098D11EF9AA743E >									
	//     < SHERE_PFI_III_metadata_line_40_____The industrial complex N1_20220505 >									
	//        < u7coP3GqasTq5952XaCe74QJ0V7WcYBv4E14sA54201f1RrUWUaGiI4FCsbi116j >									
	//        <  u =="0.000000000000000001" : ] 000001621658223.327960000000000000 ; 000001657456069.112910000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009AA743E9E113C7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
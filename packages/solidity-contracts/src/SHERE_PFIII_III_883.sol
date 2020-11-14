/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFIII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFIII_III_883		"	;
		string	public		symbol =	"	SHERE_PFIII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1864492808887740000000000000					;	
										
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
	//     < SHERE_PFIII_III_metadata_line_1_____RUSSIAN_REINSURANCE_COMPANY_20260505 >									
	//        < suTWV88gAp9C1Cr8mrEt3W3L4f10872WP2E5b3BPHegZ5C582m3l0Bql8vg0091Q >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000034792693.530401300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000003516E5 >									
	//     < SHERE_PFIII_III_metadata_line_2_____ERGO_20260505 >									
	//        < VFYRg6aegk0Xbl61cf90FKKfRBcahL6aB0pJaNUDOBBClBJ71v8l6F0RQk4d3uS8 >									
	//        <  u =="0.000000000000000001" : ] 000000034792693.530401300000000000 ; 000000066403107.295402300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003516E56552B7 >									
	//     < SHERE_PFIII_III_metadata_line_3_____AIG_20260505 >									
	//        < M517R0O0155CGIJm7QDjvZSJLi7eN2j15PrhIv0d1B8b9LsAj920b6za4Ne8sf4E >									
	//        <  u =="0.000000000000000001" : ] 000000066403107.295402300000000000 ; 000000085124999.806035800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006552B781E3F4 >									
	//     < SHERE_PFIII_III_metadata_line_4_____MARSH_MCLENNAN_RISK_CAPITAL_HOLDINGS_20260505 >									
	//        < bJ4l6F9X63h9p7v0sgI3RK6hyz92oUtyX93o3x6LSiDU55A7dCTMl0dzRYiPZlXy >									
	//        <  u =="0.000000000000000001" : ] 000000085124999.806035800000000000 ; 000000124979643.436818000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000081E3F4BEB42C >									
	//     < SHERE_PFIII_III_metadata_line_5_____RUSSIAN_NATIONAL_REINSURANCE_COMPANY_RNRC_20260505 >									
	//        < bOVFO2Zgu29MGSPU7S077K952r6lZ7FO0DYKfi385uALLO5UO7H5v4NL8dvNH01I >									
	//        <  u =="0.000000000000000001" : ] 000000124979643.436818000000000000 ; 000000165313628.063531000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BEB42CFC3FA3 >									
	//     < SHERE_PFIII_III_metadata_line_6_____ALFASTRAKHOVANIE_GROUP_20260505 >									
	//        < ClDL3X40pZ5uFUMUYTgR7IrG7BX6r8a3qkV5W51SgFtP3ih38121276evw7f17oz >									
	//        <  u =="0.000000000000000001" : ] 000000165313628.063531000000000000 ; 000000196535347.224430000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FC3FA312BE39F >									
	//     < SHERE_PFIII_III_metadata_line_7_____ALFA_GROUP_20260505 >									
	//        < 61Vo5Zt8Y5UsMZ94qg19u4MI2qbudIQ5CdpxSTCjD3X2cXGHpP1VyE5uSNf838Wu >									
	//        <  u =="0.000000000000000001" : ] 000000196535347.224430000000000000 ; 000000262255082.202745000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012BE39F1902B64 >									
	//     < SHERE_PFIII_III_metadata_line_8_____INGOSSTRAKH_20260505 >									
	//        < 0dpj32p6PEt7TL5B6hR80lnTMpj42DfQ4p2C4qNloZ8AJf72TM0F4TR57Nb5MLGx >									
	//        <  u =="0.000000000000000001" : ] 000000262255082.202745000000000000 ; 000000342923441.108905000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001902B6420B4278 >									
	//     < SHERE_PFIII_III_metadata_line_9_____ROSGOSSTRAKH_INSURANCE_COMPANY_20260505 >									
	//        < K3FMiC14bg4EOeEH1xk2m5Us5m0k5K3r9bGxyWn1KKvxbjf1nO5743BzM5UInL0G >									
	//        <  u =="0.000000000000000001" : ] 000000342923441.108905000000000000 ; 000000368938491.900234000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020B4278232F499 >									
	//     < SHERE_PFIII_III_metadata_line_10_____SCOR_SE_20260505 >									
	//        < eNa30p12yW6PI4gxvYW89925xe93kUKwpn6S659HS5fn5NgRJ6g6ci6GRHiFSDYX >									
	//        <  u =="0.000000000000000001" : ] 000000368938491.900234000000000000 ; 000000415900595.159996000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000232F49927A9D2C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIII_III_metadata_line_11_____HANNOVERRE_20260505 >									
	//        < 3VVnVCajIqm46AFEz9H757Z0X4CwnGqBKdC380a4h35rn87fkZo59SSST60p1m0z >									
	//        <  u =="0.000000000000000001" : ] 000000415900595.159996000000000000 ; 000000474164209.690885000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027A9D2C2D38465 >									
	//     < SHERE_PFIII_III_metadata_line_12_____SWISS_RE_20260505 >									
	//        < U9KH13KEMz749GLs599nXMJTiAbP1HwDmnvGiBVW21Ltnx6CGD9Q2xEyoo7w167w >									
	//        <  u =="0.000000000000000001" : ] 000000474164209.690885000000000000 ; 000000569174984.796105000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D384653647DFA >									
	//     < SHERE_PFIII_III_metadata_line_13_____MUNICH_RE_20260505 >									
	//        < 17kG1s4O4M91ZOBLsTF8NpWkr0Y9w581Gh48gh7jiaG365B0HGstn7APfD8ft7kD >									
	//        <  u =="0.000000000000000001" : ] 000000569174984.796105000000000000 ; 000000605772004.738011000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003647DFA39C55B0 >									
	//     < SHERE_PFIII_III_metadata_line_14_____GEN_RE_20260505 >									
	//        < p6pP08GN9hDqL6o68QxNOUt5DHBwW22zMI20V4i81TdK465Fz1LcwL5A37Btb713 >									
	//        <  u =="0.000000000000000001" : ] 000000605772004.738011000000000000 ; 000000690161753.629153000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039C55B041D1A6F >									
	//     < SHERE_PFIII_III_metadata_line_15_____PARTNER_RE_20260505 >									
	//        < k90BlT73aR6wPIg1nN6S8eKm9JJM8yGZTz6dNF1K4qgZ9BCIOddHoar9o0Fpuokh >									
	//        <  u =="0.000000000000000001" : ] 000000690161753.629153000000000000 ; 000000776693006.516563000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041D1A6F4A123B5 >									
	//     < SHERE_PFIII_III_metadata_line_16_____EXOR_20260505 >									
	//        < 0TfQyGnSRoG3VrFsTL9BobvOG0DAo7978ZN8i06SS603Qdet0wnHKt1M37Ingr0l >									
	//        <  u =="0.000000000000000001" : ] 000000776693006.516563000000000000 ; 000000797154869.979194000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A123B54C05C9F >									
	//     < SHERE_PFIII_III_metadata_line_17_____XL_CATLIN_RE_20260505 >									
	//        < Naxd8wzG44oiG7inQ1QWzA7M7AFWf70iQNGBc28464opyAy1DW111V9b8070Bvoa >									
	//        <  u =="0.000000000000000001" : ] 000000797154869.979194000000000000 ; 000000819224801.744156000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C05C9F4E209B0 >									
	//     < SHERE_PFIII_III_metadata_line_18_____SOGAZ_20260505 >									
	//        < o39ILlyPf7VPQE9h0hMVzBxJcoY901XFV9q63Y1lZAXpGT2x03t7NDZJIbkjo62S >									
	//        <  u =="0.000000000000000001" : ] 000000819224801.744156000000000000 ; 000000862529165.151709000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E209B05241D75 >									
	//     < SHERE_PFIII_III_metadata_line_19_____GAZPROM_20260505 >									
	//        < k71b2uGH42UMz248liRW1ZCxDhHSeHJ5VXn4dmq3Cdj9127bqGg3hgZ63Mme2xE6 >									
	//        <  u =="0.000000000000000001" : ] 000000862529165.151709000000000000 ; 000000934083026.375017000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005241D755914C2F >									
	//     < SHERE_PFIII_III_metadata_line_20_____VTB INSURANCE_20260505 >									
	//        < Q8V7u6NM4O6HDWD28F41j5rdp1lX1IoMO2414k5U5S4p2q3VLK958biggvS9L4dd >									
	//        <  u =="0.000000000000000001" : ] 000000934083026.375017000000000000 ; 000000971857619.428674000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005914C2F5CAEFE2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIII_III_metadata_line_21_____WILLIS_LIMITED_20260505 >									
	//        < EP6f810bftWdXC7wsS5C855ymE8TMZ3jenV76qoL3V0g7x552y7971M9Auua8403 >									
	//        <  u =="0.000000000000000001" : ] 000000971857619.428674000000000000 ; 000001046553096.531410000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005CAEFE263CE9CE >									
	//     < SHERE_PFIII_III_metadata_line_22_____GUY_CARPENTER_LIMITED_20260505 >									
	//        < GK0JXy7Gf43S84S7PA470v2lkQy6hbr74Jf34dRn63YkOvq00ENhmlrtmM9l6Y5g >									
	//        <  u =="0.000000000000000001" : ] 000001046553096.531410000000000000 ; 000001120679803.152390000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000063CE9CE6AE058C >									
	//     < SHERE_PFIII_III_metadata_line_23_____AON_BENFIELD_20260505 >									
	//        < MY4814XIgBAg5uGlVTC3vpQUtq3hRJCZQ7KZLlBEHaA14b3E5sk76S6596S11mmS >									
	//        <  u =="0.000000000000000001" : ] 000001120679803.152390000000000000 ; 000001170592011.665610000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006AE058C6FA2E81 >									
	//     < SHERE_PFIII_III_metadata_line_24_____WILLIS_CIS_20260505 >									
	//        < jo9361kRUFN55hua6l2v03HCO40w8cJ31aPWI62y6dH4N734iN6pBIuN84re1ntZ >									
	//        <  u =="0.000000000000000001" : ] 000001170592011.665610000000000000 ; 000001196478129.659860000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006FA2E81721AE45 >									
	//     < SHERE_PFIII_III_metadata_line_25_____POLISH_RE_20260505 >									
	//        < KEj4QC0BnyQdch0EMxh3l9WY3H6LbU3WI8qqkvqZyj35mS8yCq0q89ELKJ71T81M >									
	//        <  u =="0.000000000000000001" : ] 000001196478129.659860000000000000 ; 000001224547634.562210000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000721AE4574C82EB >									
	//     < SHERE_PFIII_III_metadata_line_26_____TRUST_RE_20260505 >									
	//        < 57GSG6wdViYR2hTv9igL2qSus82mYcY4J1Ko70XSmL52WZXcpejSTvBrJ9g6xo54 >									
	//        <  u =="0.000000000000000001" : ] 000001224547634.562210000000000000 ; 000001262867683.340990000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000074C82EB786FBB0 >									
	//     < SHERE_PFIII_III_metadata_line_27_____MALAKUT_20260505 >									
	//        < EwFi2PrYZkOA979NeiA99K3C64B8hVQdYCCsqh2SUxBygmWJvDb3R3Ub115JFgno >									
	//        <  u =="0.000000000000000001" : ] 000001262867683.340990000000000000 ; 000001339956833.601970000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000786FBB07FC9CA3 >									
	//     < SHERE_PFIII_III_metadata_line_28_____SCOR_RUS_20260505 >									
	//        < Sohh8mj4UA84O3p4NXRBsI0BDzg1ydl9COc4lyl4Ob3a19cxKt3O5963XE0UTH5i >									
	//        <  u =="0.000000000000000001" : ] 000001339956833.601970000000000000 ; 000001362951028.715200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007FC9CA381FB2BF >									
	//     < SHERE_PFIII_III_metadata_line_29_____AFM_20260505 >									
	//        < tQj45C4UkzP9YsGXMRQjwU2w9CU1k04gsh4892016yBjwX0Y2DKyD7Jx7GFqthbg >									
	//        <  u =="0.000000000000000001" : ] 000001362951028.715200000000000000 ; 000001386195978.140200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000081FB2BF8432ACE >									
	//     < SHERE_PFIII_III_metadata_line_30_____SBERBANK_INSURANCE_20260505 >									
	//        < a48lIe3AP4NoEZ4648712Vr691cmD077l19Bk948gtadSeK26W90i4QAvyLAKPrT >									
	//        <  u =="0.000000000000000001" : ] 000001386195978.140200000000000000 ; 000001412246636.827920000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008432ACE86AEAD8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIII_III_metadata_line_31_____Societe_Financiere_Sberbank_20260505 >									
	//        < pG00dNNGe8UaRnHD25X51yb8620CpwAKR7BZd45wWU8t2WO55nVrdXJHboEIgGy3 >									
	//        <  u =="0.000000000000000001" : ] 000001412246636.827920000000000000 ; 000001454922615.849970000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000086AEAD88AC0926 >									
	//     < SHERE_PFIII_III_metadata_line_32_____ENERGOGARANT_20260505 >									
	//        < 5711VqgH9T173GZKJTm6677lUlF90fq9LY193wp7XZCl57b6S6y0q3sOX9K375TY >									
	//        <  u =="0.000000000000000001" : ] 000001454922615.849970000000000000 ; 000001482952723.963110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008AC09268D6CE68 >									
	//     < SHERE_PFIII_III_metadata_line_33_____RSHB_INSURANCE_20260505 >									
	//        < 5P885033X2u83gG563a56J0Ftn6KLvmr90G74y0pnNDyB3j59x250lANtGdF8Xtu >									
	//        <  u =="0.000000000000000001" : ] 000001482952723.963110000000000000 ; 000001514912430.002090000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008D6CE6890792AB >									
	//     < SHERE_PFIII_III_metadata_line_34_____EURASIA_20260505 >									
	//        < 4aXT86TYG1nh6GIzAv6B3Y7DC7OSJ8q4QuszsLzmN1X12258qph3GbCwodBuUR3T >									
	//        <  u =="0.000000000000000001" : ] 000001514912430.002090000000000000 ; 000001591074426.058400000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000090792AB97BC973 >									
	//     < SHERE_PFIII_III_metadata_line_35_____BELARUS_RE_20260505 >									
	//        < LJPfD6k46K6TU3si19cA6p73rVD60ECYCR34rMX1xokq8187NDe82Drc3VXt9664 >									
	//        <  u =="0.000000000000000001" : ] 000001591074426.058400000000000000 ; 000001647729743.902010000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000097BC9739D23C6E >									
	//     < SHERE_PFIII_III_metadata_line_36_____RT_INSURANCE_20260505 >									
	//        < 1Sf0c0H6YowTLZlVZi6IySI6mumUkQw02w755vnV32nwE95xbr55v2YiopKkm2Pm >									
	//        <  u =="0.000000000000000001" : ] 000001647729743.902010000000000000 ; 000001670189099.257330000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009D23C6E9F4819E >									
	//     < SHERE_PFIII_III_metadata_line_37_____ASPEN_20260505 >									
	//        < GlacQ2Ssr7IWffecc82vkArR6nvDlTze58N0R7o4E7Z4k8JMXc79hkeJc5v10xms >									
	//        <  u =="0.000000000000000001" : ] 000001670189099.257330000000000000 ; 000001738523625.581440000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009F4819EA5CC6CB >									
	//     < SHERE_PFIII_III_metadata_line_38_____LOL_I_20260505 >									
	//        < 1P820Y5z63y2hy9VOD2r8Vb6YcI8VSiaEu89PaJ54P7rPrPhlpT1LM48tQGDBNK4 >									
	//        <  u =="0.000000000000000001" : ] 000001738523625.581440000000000000 ; 000001817890294.844600000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A5CC6CBAD5E165 >									
	//     < SHERE_PFIII_III_metadata_line_39_____LOL_4472_20260505 >									
	//        < XFjev26fuf2aeoS28n4EA9Y5v959bMp3B5jJgHgEnuhQzs7VY449TTdU43846lEC >									
	//        <  u =="0.000000000000000001" : ] 000001817890294.844600000000000000 ; 000001839875785.662510000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000AD5E165AF76D7B >									
	//     < SHERE_PFIII_III_metadata_line_40_____LOL_1183_20260505 >									
	//        < J84Y0NhqCHBB9yp2u35c5NJCMx7c61YLh12BadtC6Kz1y6a3mDewo7SxY7u26w3x >									
	//        <  u =="0.000000000000000001" : ] 000001839875785.662510000000000000 ; 000001864492808.887740000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000AF76D7BB1CFD81 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
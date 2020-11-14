/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFI_I_883		"	;
		string	public		symbol =	"	SHERE_PFI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		760409854824080000000000000					;	
										
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
	//     < SHERE_PFI_I_metadata_line_1_____UNITED_AIRCRAFT_CORPORATION_20220505 >									
	//        < Z9SVqAIv0XB98LuNOaOlujd4LlIInRhP3y08DyipKiKvWBB2D97L6387xaKh4iZ1 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016314620.208489600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000018E4E6 >									
	//     < SHERE_PFI_I_metadata_line_2_____China_Russia Commercial Aircraft International Corporation Co_20220505 >									
	//        < jws3An69Sw8159ivTJc567G6MW34Ow48PSi7mbpc8JUYov8H6ArTNsg78e2B7Irc >									
	//        <  u =="0.000000000000000001" : ] 000000016314620.208489600000000000 ; 000000031599101.034061800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000018E4E6303766 >									
	//     < SHERE_PFI_I_metadata_line_3_____CHINA_RUSSIA_ORG_20220505 >									
	//        < qHw3FcXjibOAlHV958R9U4B3X9WZ3PrdEn02FGNC48No68LWDc9674mw0xixJE09 >									
	//        <  u =="0.000000000000000001" : ] 000000031599101.034061800000000000 ; 000000052408392.273994500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003037664FF807 >									
	//     < SHERE_PFI_I_metadata_line_4_____Mutilrole Transport Aircraft Limited_20220505 >									
	//        < OM0MLLgT7tEMI66KNCfh2066Bh530lXglRjjRyHqOH0J9Dg9J9dmZGY21fzFtFK4 >									
	//        <  u =="0.000000000000000001" : ] 000000052408392.273994500000000000 ; 000000073178514.260795200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004FF8076FA95B >									
	//     < SHERE_PFI_I_metadata_line_5_____SuperJet International_20220505 >									
	//        < B54Ri9619PS93l2Qaaq1lssbAjuiFrUsGHTQHX09Jr4Y3351823su97E9cuL5gCv >									
	//        <  u =="0.000000000000000001" : ] 000000073178514.260795200000000000 ; 000000097531356.785904100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006FA95B94D230 >									
	//     < SHERE_PFI_I_metadata_line_6_____SUPERJET_ORG_20220505 >									
	//        < 166gCQ737Z7JY8P9GXO337TE2NkZfU4443xkjJ7iG0qhkm9q78FbC3L6jBwp5lVC >									
	//        <  u =="0.000000000000000001" : ] 000000097531356.785904100000000000 ; 000000123309338.877607000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000094D230BC27B6 >									
	//     < SHERE_PFI_I_metadata_line_7_____JSC KAPO-Composit_20220505 >									
	//        < uc1InvOVgd10M9HgXv8LQ0DOGQsc7X57s5tPs9y4K51h043E3z9Zz88l4lK2z4oD >									
	//        <  u =="0.000000000000000001" : ] 000000123309338.877607000000000000 ; 000000147656344.877140000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BC27B6E14E42 >									
	//     < SHERE_PFI_I_metadata_line_8_____JSC Aviastar_SP_20220505 >									
	//        < gr40tl08Ivd35yo2ssy0y2Xk5GDwI471018X30wvx35IB404c0aoc3vrslBBXJwg >									
	//        <  u =="0.000000000000000001" : ] 000000147656344.877140000000000000 ; 000000161193191.200320000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E14E42F5F617 >									
	//     < SHERE_PFI_I_metadata_line_9_____JSC AeroKompozit_20220505 >									
	//        < 1hZC50ISj6EY67J4ElR9sv25p1H52K7nP44Y8HlCNR33JGNd5QEwn13rh6gQYFe5 >									
	//        <  u =="0.000000000000000001" : ] 000000161193191.200320000000000000 ; 000000183768814.349172000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F5F61711868B1 >									
	//     < SHERE_PFI_I_metadata_line_10_____JSC AeroComposit_Ulyanovsk_20220505 >									
	//        < 30Xg75lL5vzDMi2IxJm8Nh2uEFBJM7094zHB10f959E51AKQR8WJqFnoj5phF9Nq >									
	//        <  u =="0.000000000000000001" : ] 000000183768814.349172000000000000 ; 000000201732110.019320000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011868B1133D19B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFI_I_metadata_line_11_____JSC Sukhoi Civil Aircraft_20220505 >									
	//        < DYfF3Sdp9f2F8tYZS6Q9RIzy541B16RUm1lBwH5387BLnf08x8p44omcn8D2OF9n >									
	//        <  u =="0.000000000000000001" : ] 000000201732110.019320000000000000 ; 000000219671530.046855000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000133D19B14F3131 >									
	//     < SHERE_PFI_I_metadata_line_12_____SUKHOIL_CIVIL_ORG_20220505 >									
	//        < NeAs2gpawHzJlj3zxBPvSUtL448P2Y59I3FGhiX0N8CRHXIE1ottEru55E3442G0 >									
	//        <  u =="0.000000000000000001" : ] 000000219671530.046855000000000000 ; 000000233656591.292098000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014F3131164881B >									
	//     < SHERE_PFI_I_metadata_line_13_____JSC Flight Research Institute_20220505 >									
	//        < jn0Z5SbCJZmnYR2CO4afIowZ2T71Ys2DD0i3RFDG68FPO9gXizSU59nDtbG7t8oG >									
	//        <  u =="0.000000000000000001" : ] 000000233656591.292098000000000000 ; 000000255056942.393019000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000164881B1852F9E >									
	//     < SHERE_PFI_I_metadata_line_14_____JSC UAC_Transport Aircraft_20220505 >									
	//        < 2DbqaKu5ZMD58WiBjQpjdQeouLIY85vvn7A3hQ6UMT8HGGv7sw0W5Bf5O60012dn >									
	//        <  u =="0.000000000000000001" : ] 000000255056942.393019000000000000 ; 000000273063798.287001000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001852F9E1A0A98C >									
	//     < SHERE_PFI_I_metadata_line_15_____JSC Russian Aircraft Corporation MiG_20220505 >									
	//        < 1I8dT2pvW9D8iAB17XPK09W8Ma3xT4j20ysm7d1VpK04esSQ8cZL3aHXI7Pi9jpS >									
	//        <  u =="0.000000000000000001" : ] 000000273063798.287001000000000000 ; 000000295922237.773931000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A0A98C1C38AA0 >									
	//     < SHERE_PFI_I_metadata_line_16_____MIG_ORG_20220505 >									
	//        < ed78Fj6KjiT8y3EvXF5wTSl3AnRL6HkzFpKSxlANJL8Dj77ibEEj5o6Dgpg0lOR9 >									
	//        <  u =="0.000000000000000001" : ] 000000295922237.773931000000000000 ; 000000319140014.286075000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C38AA01E6F811 >									
	//     < SHERE_PFI_I_metadata_line_17_____OJSC Experimental Machine-Building Plant_20220505 >									
	//        < 7h03TCR37h6OofvBsNEhK9pO175SHsn86BXFwAtz548QK979w048867L2PL8fmLO >									
	//        <  u =="0.000000000000000001" : ] 000000319140014.286075000000000000 ; 000000332886601.942977000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E6F8111FBF1D4 >									
	//     < SHERE_PFI_I_metadata_line_18_____Irkutsk Aviation Plant_20220505 >									
	//        < WT7sN4z4T3z80EbwsgTYanmc9fffydFplYcM64A6C7Yku4KIw3oM3lTw0M3Vi7be >									
	//        <  u =="0.000000000000000001" : ] 000000332886601.942977000000000000 ; 000000352592629.455048000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FBF1D421A037F >									
	//     < SHERE_PFI_I_metadata_line_19_____Gorbunov Kazan Aviation Plant_20220505 >									
	//        < 8VZ70a98c68KeW59u4Y9SaidJBkiNynkCJ4eY118DS066pA6O9U8O313p07cUwnx >									
	//        <  u =="0.000000000000000001" : ] 000000352592629.455048000000000000 ; 000000366317936.493846000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021A037F22EF4F2 >									
	//     < SHERE_PFI_I_metadata_line_20_____Komsomolsk_on_Amur Aircraft Plant_20220505 >									
	//        < hEh47I0SsWZ6tS2z13PgfE1Ps30R69z9K0f40EN2j4QUN7l0m8sr5bQIM0Y9vr06 >									
	//        <  u =="0.000000000000000001" : ] 000000366317936.493846000000000000 ; 000000384617391.131204000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022EF4F224AE12B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFI_I_metadata_line_21_____Nizhny Novgorod aircraft building plant Sokol_20220505 >									
	//        < T3493ecqWmX0L33u93NR2q885Pvt5N6B950P65OQ0DR0IKis0IIF8L6oF9XYa3l0 >									
	//        <  u =="0.000000000000000001" : ] 000000384617391.131204000000000000 ; 000000401384896.700640000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024AE12B26476FA >									
	//     < SHERE_PFI_I_metadata_line_22_____NIZHNY_ORG_20220505 >									
	//        < 8e7n289Ld519d56c3U79U8631G5OF8UEkNz4N1xIVXFkYid1WunylY9M5k589wFF >									
	//        <  u =="0.000000000000000001" : ] 000000401384896.700640000000000000 ; 000000427184112.283439000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026476FA28BD4CB >									
	//     < SHERE_PFI_I_metadata_line_23_____Novosibirsk Aircraft Plant_20220505 >									
	//        < TI858WrtGQy8kQ2Ea0p2z7ucfrT8X63y58C4U6j3SPDVoxW3183ZiSOfL6g5p8A0 >									
	//        <  u =="0.000000000000000001" : ] 000000427184112.283439000000000000 ; 000000447653726.085796000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028BD4CB2AB10BD >									
	//     < SHERE_PFI_I_metadata_line_24_____NOVO_ORG_20220505 >									
	//        < cG2KifXzKyqI4pB8IU6688PcU2jj4T4e2ipwFJz5vP1D2lZS6qWdf7L3ak2l1G90 >									
	//        <  u =="0.000000000000000001" : ] 000000447653726.085796000000000000 ; 000000471441857.117643000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AB10BD2CF5CFA >									
	//     < SHERE_PFI_I_metadata_line_25_____UAC Health_20220505 >									
	//        < sH9X9XoOoFhEK3908ZR19i9KB92kmNG9wSt1I4kYADP9m7i67Q9oKSe8KNHVaY0E >									
	//        <  u =="0.000000000000000001" : ] 000000471441857.117643000000000000 ; 000000492863523.213590000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CF5CFA2F00CD0 >									
	//     < SHERE_PFI_I_metadata_line_26_____UAC_HEALTH_ORG_20220505 >									
	//        < DT236ml1f9PdE1N7g7C9UK7G1y4LW795VAHqJz0bB84R9iWNN5v8EV9JTnRr4de1 >									
	//        <  u =="0.000000000000000001" : ] 000000492863523.213590000000000000 ; 000000505873886.617085000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F00CD0303E6FD >									
	//     < SHERE_PFI_I_metadata_line_27_____JSC Ilyushin Finance Co_20220505 >									
	//        < o270CxuL378MMV7j9SeG0s5Walrvk40KOy5s8lvyz7jWdukgn2BU9n2tIUy8DH2G >									
	//        <  u =="0.000000000000000001" : ] 000000505873886.617085000000000000 ; 000000521624318.487517000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000303E6FD31BEF80 >									
	//     < SHERE_PFI_I_metadata_line_28_____OJSC Experimental Design Bureau_20220505 >									
	//        < AJP5JoxbW1is23hK1TEvM2ZE58LLL64vnsm4NHJ6HuQmby93TpQ6893HVx9mP3L4 >									
	//        <  u =="0.000000000000000001" : ] 000000521624318.487517000000000000 ; 000000543420459.847022000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031BEF8033D319E >									
	//     < SHERE_PFI_I_metadata_line_29_____LLC UAC_I_20220505 >									
	//        < NVgBhh88JwZ2VrM604rTxMUZq19pqVOSVy4b48AY6Ely6e008ZxUR4ZNpiY2VBPl >									
	//        <  u =="0.000000000000000001" : ] 000000543420459.847022000000000000 ; 000000557496350.412038000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033D319E352AC03 >									
	//     < SHERE_PFI_I_metadata_line_30_____LLC UAC_II_20220505 >									
	//        < o94ScS4xD3g6JX2v0gOZQR4S0392r4VRV0rJN0uhu7cq2qQi8Pm1NhVm6aQ6vbJG >									
	//        <  u =="0.000000000000000001" : ] 000000557496350.412038000000000000 ; 000000579533798.094798000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000352AC033744C64 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFI_I_metadata_line_31_____LLC UAC_III_20220505 >									
	//        < z6eFJi204ZTaP45tFRTg5YYIsk1ad296dd7ddU0M05W90NXK2Vz7X85n9oA8Tq4M >									
	//        <  u =="0.000000000000000001" : ] 000000579533798.094798000000000000 ; 000000599112081.736126000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003744C643922C28 >									
	//     < SHERE_PFI_I_metadata_line_32_____JSC Ilyushin Aviation Complex_20220505 >									
	//        < v80IJzXALqNS2w4G657Io9iWBNpw112LPEbLIx7Oajq1Zd2lNyoE9hXFaffh7df8 >									
	//        <  u =="0.000000000000000001" : ] 000000599112081.736126000000000000 ; 000000612467254.005769000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003922C283A68D05 >									
	//     < SHERE_PFI_I_metadata_line_33_____PJSC Voronezh Aircraft Manufacturing Company_20220505 >									
	//        < Fs2yoTjXZ1OGt32pL4jkP0J5fW1Ttv4Ha9zlFh71Dnsi56PPy068UkASH1d8Bsp3 >									
	//        <  u =="0.000000000000000001" : ] 000000612467254.005769000000000000 ; 000000635895557.973699000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A68D053CA4CB4 >									
	//     < SHERE_PFI_I_metadata_line_34_____JSC Aviation Holding Company Sukhoi_20220505 >									
	//        < 11w6ro4WElo9Ri0y69S8RmHTH4KfqaiaKNUtZHikkTfFqHi37E8Q3j6p21Iu3JSK >									
	//        <  u =="0.000000000000000001" : ] 000000635895557.973699000000000000 ; 000000653503711.374216000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CA4CB43E52AE3 >									
	//     < SHERE_PFI_I_metadata_line_35_____SUKHOI_ORG_20220505 >									
	//        < 1eArzm23x0cofyc1cGNUW5ic2ljHDdm45Au5B9OciCyF9i9ZC9uX9VOW1DsCRPHh >									
	//        <  u =="0.000000000000000001" : ] 000000653503711.374216000000000000 ; 000000667471262.009799000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E52AE33FA7AF6 >									
	//     < SHERE_PFI_I_metadata_line_36_____PJSC Scientific and Production Corporation Irkut_20220505 >									
	//        < PQyCczJB0Iujrr1948AncV5Hd6304ui7j3TGni20F1Q4G6bL0y5yW3jH31F4jcxo >									
	//        <  u =="0.000000000000000001" : ] 000000667471262.009799000000000000 ; 000000685822852.130394000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FA7AF64167B8D >									
	//     < SHERE_PFI_I_metadata_line_37_____PJSC Taganrog Aviation Scientific_Technical Complex_20220505 >									
	//        < yFVW9G51FX25n6zg5iCzt2n08w6J4l36Y4m3VwsCBxkeqFbCLRrQ05A9aHB3Oo48 >									
	//        <  u =="0.000000000000000001" : ] 000000685822852.130394000000000000 ; 000000701364013.975384000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004167B8D42E3251 >									
	//     < SHERE_PFI_I_metadata_line_38_____PJSC Tupolev_20220505 >									
	//        < lSIdKk9nviEUbX9aT8nNK44847kM1yaEreBT3233PY1YyLV0P8Qv18927CToWHv7 >									
	//        <  u =="0.000000000000000001" : ] 000000701364013.975384000000000000 ; 000000723139500.306681000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042E325144F6C5E >									
	//     < SHERE_PFI_I_metadata_line_39_____TUPOLEV_ORG_20220505 >									
	//        < kSq60J5ntwy8r1k9Z60lV1Ar57o9Fi9In6c5I66ZhQ0GNko98fo5cEc9U6Hp5816 >									
	//        <  u =="0.000000000000000001" : ] 000000723139500.306681000000000000 ; 000000747375419.731354000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044F6C5E4746786 >									
	//     < SHERE_PFI_I_metadata_line_40_____The industrial complex N1_20220505 >									
	//        < gc41fxXy4hQA0EK7Aa76id78v2yKD9TC9T6hAL9L91qt6QkA4825t51R1Yb5jzzB >									
	//        <  u =="0.000000000000000001" : ] 000000747375419.731354000000000000 ; 000000760409854.824080000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047467864884B19 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFVII_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFVII_883		"	;
		string	public		symbol =	"	SHERE_PFVII_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		799835093800000000000000000					;	
										
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
	//     < SHERE_PFVII_metadata_line_1_____A1_20190506 >									
	//        < hp7DQrz9v5WYU1Ppxf87uPB7a3R8whvR6D0v5m70ut0826TKT30WStUj770Cg4bH >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000019975764.800000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001E7B08 >									
	//     < SHERE_PFVII_metadata_line_2_____A2_20190506 >									
	//        < l8lZa48S0X2gvtn9z2DR9IY7b67dmPCn8w9HXu4t54Gx6d2dbh65LX8XDAUkS6Qn >									
	//        <  u =="0.000000000000000001" : ] 000000019975764.800000000000000000 ; 000000039887496.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E7B083CDD0E >									
	//     < SHERE_PFVII_metadata_line_3_____A3_20190506 >									
	//        < hEmER6yxaI5r8ehdl0s6wKzEijGWDMd3v7pp2HrUYh92x705UEU6dP60qUkBJ8D1 >									
	//        <  u =="0.000000000000000001" : ] 000000039887496.000000000000000000 ; 000000059952468.300000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003CDD0E5B7AEF >									
	//     < SHERE_PFVII_metadata_line_4_____A4_20190506 >									
	//        < mRPvmEn02lhS8rCX8oM1Ad16q70Ff429qRFJEs1fmK3oZ6gFgOMOcKWuvgbnElj1 >									
	//        <  u =="0.000000000000000001" : ] 000000059952468.300000000000000000 ; 000000079959647.200000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005B7AEF7A023D >									
	//     < SHERE_PFVII_metadata_line_5_____A5_20190506 >									
	//        < wANRk4jRc6eIh4dtmA7guAaMLWLTcLvuQjjg4fjNhnGgtmLh61bZg9kH1wu2T0TI >									
	//        <  u =="0.000000000000000001" : ] 000000079959647.200000000000000000 ; 000000099943920.200000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007A023D988098 >									
	//     < SHERE_PFVII_metadata_line_6_____A6_20190506 >									
	//        < FB68mJ3FCi6cIuh35NH907f714n1M0kypquoBBct6Qbi5A0a5Dn7N6Y4u9A117D3 >									
	//        <  u =="0.000000000000000001" : ] 000000099943920.200000000000000000 ; 000000119854939.400000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000988098B6E256 >									
	//     < SHERE_PFVII_metadata_line_7_____A7_20190506 >									
	//        < cCZbuf1dYP8C6w4z0OyRlFkzzQf3c5q3V748180pI0e5mEBAgH5iF934aFzr6841 >									
	//        <  u =="0.000000000000000001" : ] 000000119854939.400000000000000000 ; 000000139902621.900000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B6E256D57976 >									
	//     < SHERE_PFVII_metadata_line_8_____A8_20190506 >									
	//        < RSb1pB48jfp0ZRWzQ8lNbC8o0U8uN7pLQ7SXj9l54Z0V5hkt0AX266Qa7123M3AG >									
	//        <  u =="0.000000000000000001" : ] 000000139902621.900000000000000000 ; 000000159957165.800000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D57976F41345 >									
	//     < SHERE_PFVII_metadata_line_9_____A9_20190506 >									
	//        < YHcKS7hOhP4gew0Tlj7Uf0UiS8Oo1KG5oU3C4Kn9Wh62PiR3J8E5G349WlnG4DVd >									
	//        <  u =="0.000000000000000001" : ] 000000159957165.800000000000000000 ; 000000179892862.500000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F413451127EA6 >									
	//     < SHERE_PFVII_metadata_line_10_____A10_20190506 >									
	//        < RI8kUlnY1I3GBcw4sIJvioQX69Ee3H818547wsXE27VB4Hm2Afm01I14IC2yJ74v >									
	//        <  u =="0.000000000000000001" : ] 000000179892862.500000000000000000 ; 000000199990894.100000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001127EA61312971 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFVII_metadata_line_11_____A11_20190506 >									
	//        < 21HDH47oZ32Oro5718A8W9fzwWzByNNt3U61h3oPV0cGm906iC8f4qp347zZQWZ7 >									
	//        <  u =="0.000000000000000001" : ] 000000199990894.100000000000000000 ; 000000220043149.400000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000131297114FC25B >									
	//     < SHERE_PFVII_metadata_line_12_____A12_20190506 >									
	//        < Of7acihVt7BKyh654nPzVZ1Wcpx30z0KqIINWA4Du3O9u721Q2No4H9Wnop9OWL0 >									
	//        <  u =="0.000000000000000001" : ] 000000220043149.400000000000000000 ; 000000239995904.000000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014FC25B16E3466 >									
	//     < SHERE_PFVII_metadata_line_13_____A13_20190506 >									
	//        < hTl8oIVBl96bWeH8Qr3Tp0eWfG17AS9ID9KW6aZdmo6fTy24g7Ctkjug93aGKvCd >									
	//        <  u =="0.000000000000000001" : ] 000000239995904.000000000000000000 ; 000000259933648.300000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016E346618CA095 >									
	//     < SHERE_PFVII_metadata_line_14_____A14_20190506 >									
	//        < 7IZIO18Gdz69PnelD0q5xkZ9WjSQ8P020490kxMr974P1VM1C7tSBW0JRm93Orh6 >									
	//        <  u =="0.000000000000000001" : ] 000000259933648.300000000000000000 ; 000000280001290.900000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018CA0951AB3F81 >									
	//     < SHERE_PFVII_metadata_line_15_____A15_20190506 >									
	//        < NUz75FguI9csepc1hHZOgo8D3636vs1Z7tr94G6sT9H3Xr3OTZHucHerg0NxeGm6 >									
	//        <  u =="0.000000000000000001" : ] 000000280001290.900000000000000000 ; 000000299918707.300000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AB3F811C9A3BF >									
	//     < SHERE_PFVII_metadata_line_16_____A16_20190506 >									
	//        < 71mOur7CsGmyvhw12w8dg0t4N5uUt90g17QaijX959OC0112zk6XYvt4mYaP15n7 >									
	//        <  u =="0.000000000000000001" : ] 000000299918707.300000000000000000 ; 000000319975355.400000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C9A3BF1E83E60 >									
	//     < SHERE_PFVII_metadata_line_17_____A17_20190506 >									
	//        < cG2fn3FkrgDZuOGpOz462y6eJDFMtqdnL3fgpy5Fn6Ix97KbOE97MI0YdTx3bB61 >									
	//        <  u =="0.000000000000000001" : ] 000000319975355.400000000000000000 ; 000000339986427.400000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E83E60206C733 >									
	//     < SHERE_PFVII_metadata_line_18_____A18_20190506 >									
	//        < taglI215ESv00C8tHv457PrguT2Q979HOlFsC03jjo31NkU9Jl1RjF7vQ6wNXolA >									
	//        <  u =="0.000000000000000001" : ] 000000339986427.400000000000000000 ; 000000360003815.600000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000206C733225527E >									
	//     < SHERE_PFVII_metadata_line_19_____A19_20190506 >									
	//        < HsSBd1CI9inAIW31Vg1Cc5SoXaKW1i0JzqzQ1Xc0V594ZTmm7rjn8NUS1K4RM3TO >									
	//        <  u =="0.000000000000000001" : ] 000000360003815.600000000000000000 ; 000000380002125.700000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000225527E243D655 >									
	//     < SHERE_PFVII_metadata_line_20_____A20_20190506 >									
	//        < 7tS0zUKt1G1zP5ZIafT4nl70pxP4909GU1lRa6l3ngGGC6zFUv62A7G13ooSfe2V >									
	//        <  u =="0.000000000000000001" : ] 000000380002125.700000000000000000 ; 000000400033035.100000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000243D65526266E8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFVII_metadata_line_21_____A21_20190506 >									
	//        < IbuotDixxtUHo8P9Kk21Pz7mjCHstN08EAgl688nr38WYBw4ceeHnlGMC4wP49on >									
	//        <  u =="0.000000000000000001" : ] 000000400033035.100000000000000000 ; 000000420026087.900000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026266E8280E8B1 >									
	//     < SHERE_PFVII_metadata_line_22_____A22_20190506 >									
	//        < O92li21AXtc9IV8dQGzh0j1Rhg92Qf9ZASYbtkn3TvLaFXS6DJMjGsCa8e7D0cqe >									
	//        <  u =="0.000000000000000001" : ] 000000420026087.900000000000000000 ; 000000439947338.700000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000280E8B129F4E6E >									
	//     < SHERE_PFVII_metadata_line_23_____A23_20190506 >									
	//        < ek3y86aQ1SYA8dLdoUHho3Bzaof16243IpeO761X18p6lu8A0C59S8yZGd8CUarc >									
	//        <  u =="0.000000000000000001" : ] 000000439947338.700000000000000000 ; 000000459922106.400000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029F4E6E2BDC913 >									
	//     < SHERE_PFVII_metadata_line_24_____A24_20190506 >									
	//        < 2k5u9JUrOOg01tFqgzw60ijEf0Hi7ETsEor4c2byBhyi4Xt62A6cvaIxfP6nlF2n >									
	//        <  u =="0.000000000000000001" : ] 000000459922106.400000000000000000 ; 000000479824575.000000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BDC9132DC277A >									
	//     < SHERE_PFVII_metadata_line_25_____A25_20190506 >									
	//        < wHVH7D62x642Pf11qGaSR95hpw1hbCyQ3IF1Lx78U8NPoBpY919IdU9xPL7Zd29u >									
	//        <  u =="0.000000000000000001" : ] 000000479824575.000000000000000000 ; 000000499886101.400000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DC277A2FAC402 >									
	//     < SHERE_PFVII_metadata_line_26_____A26_20190506 >									
	//        < 410Yd9GopHBdbj2wPS6O63K0k2548zi9rx41E7KvG523h7r1vrvo9mMqP1934UwU >									
	//        <  u =="0.000000000000000001" : ] 000000499886101.400000000000000000 ; 000000519966185.500000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FAC40231967CB >									
	//     < SHERE_PFVII_metadata_line_27_____A27_20190506 >									
	//        < 1obWRh9b9Ux93DIr2r04sRp3Kxn3Rq253mbwoW62W0oC16Qf9ri2P6Al2t78153j >									
	//        <  u =="0.000000000000000001" : ] 000000519966185.500000000000000000 ; 000000540042809.100000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031967CB3380A39 >									
	//     < SHERE_PFVII_metadata_line_28_____A28_20190506 >									
	//        < 3m69c1JMZs6irg1228UfeLEzv10Az47sokns2i04kQ8tC9lMDMD7PoiZO10LQ5b7 >									
	//        <  u =="0.000000000000000001" : ] 000000540042809.100000000000000000 ; 000000559960245.900000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003380A393566E79 >									
	//     < SHERE_PFVII_metadata_line_29_____A29_20190506 >									
	//        < t1GC6KfT6Y5u1asPSaiAQ46KkLmpq00hU2Nd8809L78jn96719rP8Z91R8cGxBWN >									
	//        <  u =="0.000000000000000001" : ] 000000559960245.900000000000000000 ; 000000579902847.100000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003566E79374DC8D >									
	//     < SHERE_PFVII_metadata_line_30_____A30_20190506 >									
	//        < o646LIC6M675wNy36mILS6KDNn58380fCQC3515FF5Imx46DB92712WyJZtY9b57 >									
	//        <  u =="0.000000000000000001" : ] 000000579902847.100000000000000000 ; 000000599876793.600000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000374DC8D39356DF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFVII_metadata_line_31_____A31_20190506 >									
	//        < 09i0Rlxz85y89e4y2vPDCjrmv4Kjp0V27n2oYXOoycW66WenrwOJIUy7q77a7sQu >									
	//        <  u =="0.000000000000000001" : ] 000000599876793.600000000000000000 ; 000000619883889.900000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039356DF3B1DE25 >									
	//     < SHERE_PFVII_metadata_line_32_____A32_20190506 >									
	//        < h3w2j1P5c4824lk2C0h2KzIeULZLgfFG2D02ccO7JbMddwcgNMHj1jg7fB75w65W >									
	//        <  u =="0.000000000000000001" : ] 000000619883889.900000000000000000 ; 000000639953822.300000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B1DE253D07DF6 >									
	//     < SHERE_PFVII_metadata_line_33_____A33_20190506 >									
	//        < D5hP4Ee8qZ96Ft42aw7Fs2mIIMV758745paNTPC246iyObPUSWLKiAUhuq3fVooj >									
	//        <  u =="0.000000000000000001" : ] 000000639953822.300000000000000000 ; 000000659910261.100000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D07DF63EEF172 >									
	//     < SHERE_PFVII_metadata_line_34_____A34_20190506 >									
	//        < jaD9v6qpET5c90c726KzEkSi672Jt4lqgI63FT3o368FF1BW7E4NA7P7B0aQoQs3 >									
	//        <  u =="0.000000000000000001" : ] 000000659910261.100000000000000000 ; 000000679866506.100000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EEF17240D64DB >									
	//     < SHERE_PFVII_metadata_line_35_____A35_20190506 >									
	//        < QS4CoM8UxFQq8TfzdDJLLE57UMbPfU11739Fq6yI2itrkwz94egzfq1vlB7D2CJ6 >									
	//        <  u =="0.000000000000000001" : ] 000000679866506.100000000000000000 ; 000000699908225.300000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040D64DB42BF9A7 >									
	//     < SHERE_PFVII_metadata_line_36_____A36_20190506 >									
	//        < Hyliz0Ede4mEuoBn9uK882T5ap1i098oB2xnMydbuoX654H4Zz0D6yXt544lRqkd >									
	//        <  u =="0.000000000000000001" : ] 000000699908225.300000000000000000 ; 000000719891262.700000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042BF9A744A7786 >									
	//     < SHERE_PFVII_metadata_line_37_____A37_20190506 >									
	//        < p98zcTnUiT53ze654235963vIA9qNH63yUN2uFqL56YH8TQ7Ft9iqQzu4329l0wR >									
	//        <  u =="0.000000000000000001" : ] 000000719891262.700000000000000000 ; 000000739793322.900000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044A7786468D5C4 >									
	//     < SHERE_PFVII_metadata_line_38_____A38_20190506 >									
	//        < 4DOBQfikaRnI6SKF6GFKKF8288es6rA3k197W779p6A2976K0pBOqefBMy7J3H97 >									
	//        <  u =="0.000000000000000001" : ] 000000739793322.900000000000000000 ; 000000759822127.200000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000468D5C44876585 >									
	//     < SHERE_PFVII_metadata_line_39_____A39_20190506 >									
	//        < u7T851FQo82Fxu5lu8R2hi42Uy8HS79d4aDJ0d3Jd9SZLiwp4N13miJ3TXmUP8Nk >									
	//        <  u =="0.000000000000000001" : ] 000000759822127.200000000000000000 ; 000000779843428.800000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048765854A5F257 >									
	//     < SHERE_PFVII_metadata_line_40_____A40_20190506 >									
	//        < yoQQBzq0Fg738cgK29o4q641Wf30gX69bhIzZBR4O2hg55C7jxE4Y6qu913y8Mq5 >									
	//        <  u =="0.000000000000000001" : ] 000000779843428.800000000000000000 ; 000000799835093.800000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A5F2574C47395 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
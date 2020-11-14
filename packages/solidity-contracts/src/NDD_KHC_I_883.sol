/**
 * Source Code first verified at https://etherscan.io on Sunday, March 17, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	NDD_KHC_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_KHC_I_883		"	;
		string	public		symbol =	"	NDD_KHC_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1407435608253240000000000000					;	
										
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
	//     < NDD_KHC_I_metadata_line_1_____6938413225 Lab_x >									
	//        < drBnz1t7Ic2GK0Cqeud4uA4fK168ZMym52783AKa9cN1W1v6MP11GcssiFsauJ2O >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000003D5E13 >									
	//     < NDD_KHC_I_metadata_line_2_____9781285179 Lab_y >									
	//        < 1O6K2OD215CXn76B2Vt6713cHd7ftU32gTRJ6SUBOZPqU6LL9D2rC31b3Kh1aP5J >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003D5E137AB8A4 >									
	//     < NDD_KHC_I_metadata_line_3_____2350035723 Lab_100 >									
	//        < 1IUJEi7n4F4sKifeI82duXg1mgJ308WjrKNK9sg10t9DxWL95kc7phx0nRA1z1V9 >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000032200000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007AB8A4B81CF0 >									
	//     < NDD_KHC_I_metadata_line_4_____8345745311 Lab_110 >									
	//        < 4lf638tKs74zE90K820ul2jFzLBY6c15WChw8lq41905Ky5Ks9P3wjqdK1Mura8K >									
	//        <  u =="0.000000000000000001" : ] 000000032200000.000000000000000000 ; 000000046086245.300000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B81CF0F56F0E >									
	//     < NDD_KHC_I_metadata_line_5_____5159809609 Lab_410/401 >									
	//        < 0I2vJ79IDoG95Nk2yQ3w32a7Rr56UbR51ar6r1N1M8M5V5179SF6xiPj19ij6xDe >									
	//        <  u =="0.000000000000000001" : ] 000000046086245.300000000000000000 ; 000000071631226.500000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F56F0E132E0DF >									
	//     < NDD_KHC_I_metadata_line_6_____9881267411 Lab_810/801 >									
	//        < hmrEWmK1v7n5KW79PIQdMJ1Q3Kpq0tvN4Ln5q6s6SuYj6OyOZ2K38tJH2U9z50gD >									
	//        <  u =="0.000000000000000001" : ] 000000071631226.500000000000000000 ; 000000112721188.900000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000132E0DF170316B >									
	//     < NDD_KHC_I_metadata_line_7_____5159809609 Lab_410_3Y1Y >									
	//        < F20xUAaDOkLM2iY0wEq7f8n7UA7RkH6g0MUKTn988493z9Qbkyo7cv9Lq0b3H431 >									
	//        <  u =="0.000000000000000001" : ] 000000112721188.900000000000000000 ; 000000279413958.399999000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000170316B1AD9670 >									
	//     < NDD_KHC_I_metadata_line_8_____9881267423 Lab_410_5Y1Y >									
	//        < DMp246Ajs350jUOVd0J4wl719i1C92876q65I7K7N2GS4f60bF4LnBkm2fmwhl66 >									
	//        <  u =="0.000000000000000001" : ] 000000279413958.399999000000000000 ; 000000289413958.399999000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AD96701EAEDB5 >									
	//     < NDD_KHC_I_metadata_line_9_____2323232323 Lab_410_7Y1Y >									
	//        < K6Jw1885B83TQlfnXgWVKE1d1441rIauz66xF01p50K3iQJK9Kg60719dPFY0pVC >									
	//        <  u =="0.000000000000000001" : ] 000000289413958.399999000000000000 ; 000000299413958.399999000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EAEDB52283A86 >									
	//     < NDD_KHC_I_metadata_line_10_____2323232323 Lab_810_3Y1Y >									
	//        < UIpw4j5N9Cxy7PL7G68T90bOtc666bHOgDQFDAH2KgBd846bq6428k20Tf9OXSHT >									
	//        <  u =="0.000000000000000001" : ] 000000299413958.399999000000000000 ; 000000993170724.189964000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002283A86265966F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_KHC_I_metadata_line_11_____2331073380 Lab_810_5Y1Y >									
	//        < oseOo3KE99ZyFOVPh00528guOU2gyp729ysL0cCx73coAO86Kmj4oL1gR3H80fBg >									
	//        <  u =="0.000000000000000001" : ] 000000993170724.189964000000000000 ; 000001003170724.189960000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000265966F2A2EC5E >									
	//     < NDD_KHC_I_metadata_line_12_____2389358431 Lab_810_7Y1Y >									
	//        < wDaHwKA9cI0HTQq3NEtqxPNwCfJE3V7Wd16vZs6vwjG7EabS59xVi7u6bn94c5A9 >									
	//        <  u =="0.000000000000000001" : ] 000001003170724.189960000000000000 ; 000001013170724.189960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A2EC5E2E05E9C >									
	//     < NDD_KHC_I_metadata_line_13_____2323232323 ro_Lab_110_3Y_1.00 >									
	//        < YKj38qJkndZvfmWaL9xM1659sefth5MKfepX70Kd62gh0YekxqNX68Q7zj565922 >									
	//        <  u =="0.000000000000000001" : ] 000001013170724.189960000000000000 ; 000001044971232.330190000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E05E9C31DB5E0 >									
	//     < NDD_KHC_I_metadata_line_14_____2323232323 ro_Lab_110_5Y_1.00 >									
	//        < 7qxYL97HTfo1E6Dw9xvG6CQGy82PRy1Cyb8O9E5uuXh81pC4lPV1W8JHCTj8T9Y0 >									
	//        <  u =="0.000000000000000001" : ] 000001044971232.330190000000000000 ; 000001054971232.330190000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031DB5E035B2178 >									
	//     < NDD_KHC_I_metadata_line_15_____2323232323 ro_Lab_110_5Y_1.10 >									
	//        < 952PZ2BC4sH2n1V1UIRx3fxh0DzG6UklLBBTI69GOXsfV95DduG5Tbe99Cv2Jg42 >									
	//        <  u =="0.000000000000000001" : ] 000001054971232.330190000000000000 ; 000001064971232.330190000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035B2178398996D >									
	//     < NDD_KHC_I_metadata_line_16_____2323232323 ro_Lab_110_7Y_1.00 >									
	//        < 4lX06ihiEG3CevYQm451Jw3uW498tZSvLZiZ1ju20ao7e3988ZtHfhJzsb69gPv4 >									
	//        <  u =="0.000000000000000001" : ] 000001064971232.330190000000000000 ; 000001074971232.330190000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000398996D3D604AF >									
	//     < NDD_KHC_I_metadata_line_17_____2323232323 ro_Lab_210_3Y_1.00 >									
	//        < rTqUU5vFQZ4gm9d5MT3WtMGLKx3wB4w52Pdj3lrrWo1Mk1n52a3C93tyvP39fTBW >									
	//        <  u =="0.000000000000000001" : ] 000001074971232.330190000000000000 ; 000001089466823.629580000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D604AF41368D7 >									
	//     < NDD_KHC_I_metadata_line_18_____2323232323 ro_Lab_210_5Y_1.00 >									
	//        < G7fMbA651VzVkxRL5DEjb3emLGSZP4I4p96sk5rPrf25D0s9cDEGN6Jx6InQ8086 >									
	//        <  u =="0.000000000000000001" : ] 000001089466823.629580000000000000 ; 000001099466823.629580000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041368D7450CDDB >									
	//     < NDD_KHC_I_metadata_line_19_____2323232323 ro_Lab_210_5Y_1.10 >									
	//        < KEJPL8kkq2mVDcpfFUIb9hHby2N7Pq42cd6Agn5vTlN9PbzDZBcU50LrYsmJOsHV >									
	//        <  u =="0.000000000000000001" : ] 000001099466823.629580000000000000 ; 000001109466823.629580000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000450CDDB48E348A >									
	//     < NDD_KHC_I_metadata_line_20_____2323232323 ro_Lab_210_7Y_1.00 >									
	//        < m7vYhji1E0pmZ0qyJ25rC86RRF14HMJj4nfoV4KlJ267ZnLTDrZa92n2Wkmd7MwF >									
	//        <  u =="0.000000000000000001" : ] 000001109466823.629580000000000000 ; 000001119466823.629580000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048E348A4CBA7F7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_KHC_I_metadata_line_21_____2386281206 ro_Lab_310_3Y_1.00 >									
	//        < 6F80AK25PL57CGAnDa2rneGzH4vxaA4723rz84qn2ascpWj3P9F5Rwq45d0YP9sZ >									
	//        <  u =="0.000000000000000001" : ] 000001119466823.629580000000000000 ; 000001137570573.435270000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004CBA7F7508EB1F >									
	//     < NDD_KHC_I_metadata_line_22_____2334594893 ro_Lab_310_5Y_1.00 >									
	//        < 0585798A1a64vMYBquU1e8Gxiu1I01gbrUizD5jq7WAs8e67oJ9sQP3EQf772nhe >									
	//        <  u =="0.000000000000000001" : ] 000001137570573.435270000000000000 ; 000001147570573.435270000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000508EB1F5462EA7 >									
	//     < NDD_KHC_I_metadata_line_23_____2346942038 ro_Lab_310_5Y_1.10 >									
	//        < 3j2hjlTbJg2EX8ealWG2x6aC681opVG3mM5So2KSYxWZ4Q1CRW7xkB61iZH17oYh >									
	//        <  u =="0.000000000000000001" : ] 000001147570573.435270000000000000 ; 000001157570573.435270000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005462EA758381BA >									
	//     < NDD_KHC_I_metadata_line_24_____2323232323 ro_Lab_310_7Y_1.00 >									
	//        < BQw14Od2e6aBFlOo2489tMS2y4GbO9FH9PT6vaaI999bke6k7pDWWGOavD172545 >									
	//        <  u =="0.000000000000000001" : ] 000001157570573.435270000000000000 ; 000001167570573.435270000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058381BA5C0F839 >									
	//     < NDD_KHC_I_metadata_line_25_____2323232323 ro_Lab_410_3Y_1.00 >									
	//        < JjFwSE5M2uk57f32295a7Fih79i0442WoOR99t0K0641wK2weE684WTA0n0qjx4A >									
	//        <  u =="0.000000000000000001" : ] 000001167570573.435270000000000000 ; 000001190805425.412580000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C0F8395FE472C >									
	//     < NDD_KHC_I_metadata_line_26_____2323232323 ro_Lab_410_5Y_1.00 >									
	//        < 6CHNP5X10Bdl9fZ0TrlF950z5bngDX7r327DYKg7AHg3h4fZ5H22WAqD5GeiMgbi >									
	//        <  u =="0.000000000000000001" : ] 000001190805425.412580000000000000 ; 000001200805425.412580000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005FE472C63BB336 >									
	//     < NDD_KHC_I_metadata_line_27_____2323232323 ro_Lab_410_5Y_1.10 >									
	//        < ZeRDlaVv6RiMUN3FSlPCl9jLK5AEJJu4VRfG7R4Cs819F1mvu76mPxZ74wNw6HeS >									
	//        <  u =="0.000000000000000001" : ] 000001200805425.412580000000000000 ; 000001210805425.412580000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000063BB33667906A0 >									
	//     < NDD_KHC_I_metadata_line_28_____2323232323 ro_Lab_410_7Y_1.00 >									
	//        < KWfo871s0Se6p2JyBZoxqNJtjH5l0Ijs34gKsPH1v9Bfi0tyePk9jF59Hd0O1EqM >									
	//        <  u =="0.000000000000000001" : ] 000001210805425.412580000000000000 ; 000001220805425.412580000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000067906A06B662B3 >									
	//     < NDD_KHC_I_metadata_line_29_____2323232323 ro_Lab_810_3Y_1.00 >									
	//        < V4k205WQJZ2Dscr0pEU0FEB7D9ATpCO5GpYy9v3ai59B445DSTNhyw0L8rkmdEgr >									
	//        <  u =="0.000000000000000001" : ] 000001220805425.412580000000000000 ; 000001284890927.980840000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006B662B36F3A625 >									
	//     < NDD_KHC_I_metadata_line_30_____2323232323 ro_Lab_810_5Y_1.00 >									
	//        < mQD4y7JdwN8z7nO216CUylB778jD8tC47b8eAdP9Q7qAK5H4ApseWkPGyeRGYb1o >									
	//        <  u =="0.000000000000000001" : ] 000001284890927.980840000000000000 ; 000001294890927.980840000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006F3A625730F26D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_KHC_I_metadata_line_31_____2323232323 ro_Lab_810_5Y_1.10 >									
	//        < 0Qwpb6vRSyrK69p425jrQ6D5DGqV3bOMZz9CCu0nf5o7L2mVJ816Ai7v5YXE0DSb >									
	//        <  u =="0.000000000000000001" : ] 000001294890927.980840000000000000 ; 000001304890927.980840000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000730F26D76E5047 >									
	//     < NDD_KHC_I_metadata_line_32_____2323232323 ro_Lab_810_7Y_1.00 >									
	//        < V1w565R6vR6smzOQToh6kS6Q4u3hDWw307UjReU0A300lIHNz9jS3JpW91WGrqAI >									
	//        <  u =="0.000000000000000001" : ] 000001304890927.980840000000000000 ; 000001314890927.980840000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000076E50477ABA5D6 >									
	//     < NDD_KHC_I_metadata_line_33_____2323232323 ro_Lab_411_3Y_1.00 >									
	//        < PHt9oosKpd1rP22qZjeqNT8Y9080M15rX3csMD20b7SeY8S54912m3617NQ41An4 >									
	//        <  u =="0.000000000000000001" : ] 000001314890927.980840000000000000 ; 000001325695983.549000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007ABA5D67E9059E >									
	//     < NDD_KHC_I_metadata_line_34_____2323232323 ro_Lab_411_5Y_1.00 >									
	//        < magi2Y0cN4OpSD77rYlMW6UCF0uNhimGSiQkbV8Wm0532eP0O76yfBn5YHRvW1r6 >									
	//        <  u =="0.000000000000000001" : ] 000001325695983.549000000000000000 ; 000001337192776.470920000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007E9059E82657EF >									
	//     < NDD_KHC_I_metadata_line_35_____2323232323 ro_Lab_411_5Y_1.10 >									
	//        < dghw5S7a72h9Uk117316n8Z96hs22k42735TIlmPXEKqveLXVn0k0ruHDhRLY5q7 >									
	//        <  u =="0.000000000000000001" : ] 000001337192776.470920000000000000 ; 000001348893240.353200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000082657EF863ADE0 >									
	//     < NDD_KHC_I_metadata_line_36_____2323232323 ro_Lab_411_7Y_1.00 >									
	//        < 2Vdd3Mr9n64mC76oN9n6hUo3HHyJcE1Nrk40NPXZ1b50y2fS3i6GBW2aUi9ccYF1 >									
	//        <  u =="0.000000000000000001" : ] 000001348893240.353200000000000000 ; 000001361163268.117040000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000863ADE08A0F0D0 >									
	//     < NDD_KHC_I_metadata_line_37_____2323232323 ro_Lab_811_3Y_1.00 >									
	//        < 0760h5872y0x3g5sGjHx8v2YKo1P9u8nY7AlxR85SHaw05JG717eCXqU96X01580 >									
	//        <  u =="0.000000000000000001" : ] 000001361163268.117040000000000000 ; 000001371968323.685200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008A0F0D08DE58F4 >									
	//     < NDD_KHC_I_metadata_line_38_____2323232323 ro_Lab_811_5Y_1.00 >									
	//        < 9QXtj2c5K4j119eHGRAYzDa0n7g4nEqT3Wb2UiNxDt7T47VX8D8NSIbrRu9lnV4k >									
	//        <  u =="0.000000000000000001" : ] 000001371968323.685200000000000000 ; 000001383465116.607110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008DE58F491BAF8C >									
	//     < NDD_KHC_I_metadata_line_39_____2323232323 ro_Lab_811_5Y_1.10 >									
	//        < 4dN2Xz35eH7td27eK2pft355dn67W2Foold7l7quZyJ6778Ijox6U13o5r0hKuZZ >									
	//        <  u =="0.000000000000000001" : ] 000001383465116.607110000000000000 ; 000001395165580.489400000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000091BAF8C9592943 >									
	//     < NDD_KHC_I_metadata_line_40_____2323232323 ro_Lab_811_7Y_1.00 >									
	//        < LyhUQqlC1N85WYTD4p9nwfF47cfuT8z0L7ftO8tK9LhUsJPs48BdT8Mykg9F2a7a >									
	//        <  u =="0.000000000000000001" : ] 000001395165580.489400000000000000 ; 000001407435608.253240000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000095929439966D01 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
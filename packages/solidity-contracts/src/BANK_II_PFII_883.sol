/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	BANK_II_PFII_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	BANK_II_PFII_883		"	;
		string	public		symbol =	"	BANK_II_PFII_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		427084638464841000000000000					;	
										
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
	//     < BANK_II_PFII_metadata_line_1_____GEBR_ALEXANDER_20240508 >									
	//        < oZcZNAV46a9aNA3t8D6kGLXy6HJ2aRY96A6B7YM6cgTnjgp1B6k4EdcyAtS6a2A5 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010579626.473694500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001024AB >									
	//     < BANK_II_PFII_metadata_line_2_____SCHOTT _GLASWERKE_AG_20240508 >									
	//        < tcj44yAnFx1x0t0n3J8K15BixvRK7X1SWirfx4phMm0ar71pI4Xub8VnQ7TBC4S4 >									
	//        <  u =="0.000000000000000001" : ] 000000010579626.473694500000000000 ; 000000021128613.496086700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001024AB203D5D >									
	//     < BANK_II_PFII_metadata_line_3_____MAINZ_HAUPTBAHNHOF_20240508 >									
	//        < joPh3ymyBzAdf805vi9hCYcO24NK343POs6p476FOluycqRj8C4KG77Q6Jztr46X >									
	//        <  u =="0.000000000000000001" : ] 000000021128613.496086700000000000 ; 000000031630929.984611700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000203D5D3043D5 >									
	//     < BANK_II_PFII_metadata_line_4_____PORT_DOUANIER_ET_FLUVIAL_DE_MAYENCE_20240508 >									
	//        < hc0Cio4PO2y51aHfc7t4Ag1YEjEq96oGLJt9Xn4jOPOra7GH8sXfxIXvQ883irjD >									
	//        <  u =="0.000000000000000001" : ] 000000031630929.984611700000000000 ; 000000042109872.273076800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003043D540412B >									
	//     < BANK_II_PFII_metadata_line_5_____WERNER_MERTZ_20240508 >									
	//        < 21GcKfr2poOWHjSQU430O512I3wk11XqtjELIfAzH5394Q74ImUJVe1mrm6286g0 >									
	//        <  u =="0.000000000000000001" : ] 000000042109872.273076800000000000 ; 000000052954738.312379500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000040412B50CD72 >									
	//     < BANK_II_PFII_metadata_line_6_____JF_HILLEBRAND_20240508 >									
	//        < 5UEKQm0Tzj4X3mptRv61sE4tSB0z8q9II4r2gyaXFjhM3xUyC4BZ92itzhQJts4F >									
	//        <  u =="0.000000000000000001" : ] 000000052954738.312379500000000000 ; 000000063633690.135356000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000050CD726118E9 >									
	//     < BANK_II_PFII_metadata_line_7_____TRANS_OCEAN_20240508 >									
	//        < 9o70L6Y549wW45o1n7gI5jKDE2Lt957ZdOTWr705fAS1dXB57oyux5oV1A9VMh74 >									
	//        <  u =="0.000000000000000001" : ] 000000063633690.135356000000000000 ; 000000074518012.733878300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006118E971B499 >									
	//     < BANK_II_PFII_metadata_line_8_____SATELLITE_LOGISTICS_GROUP_20240508 >									
	//        < DXm428kim42AVix10BbA26KuesW374Ruqo0vciO93j4AJXx99ljOIJJ4i87HWjCA >									
	//        <  u =="0.000000000000000001" : ] 000000074518012.733878300000000000 ; 000000085240312.351783700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000071B4998210FF >									
	//     < BANK_II_PFII_metadata_line_9_____JF_HILLEBRAND_GROUP_20240508 >									
	//        < 10MAJJHngGM6ZMcU5TPgDHlnAnU8IJtoN3I63Gi99m4iQEoBL4DKE9Cs98587Jv0 >									
	//        <  u =="0.000000000000000001" : ] 000000085240312.351783700000000000 ; 000000095788622.563125200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008210FF92296E >									
	//     < BANK_II_PFII_metadata_line_10_____ARCHER_DANIELS_MIDLAND_20240508 >									
	//        < wJZ90K7jFT8H063Q7uhp5PBhtlvG5or230A4n12JK2ns55pYu94t5Xmi96zdc4bl >									
	//        <  u =="0.000000000000000001" : ] 000000095788622.563125200000000000 ; 000000106426559.567259000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000092296EA264E0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_II_PFII_metadata_line_11_____WEPA_20240508 >									
	//        < E520k24TPHQR03Vr6ut0Rw7OcwBD1GKAM1EDShZ3ca41MSmavFz959WqaK99eFiL >									
	//        <  u =="0.000000000000000001" : ] 000000106426559.567259000000000000 ; 000000117136712.773849000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A264E0B2BC87 >									
	//     < BANK_II_PFII_metadata_line_12_____IBM_CORP_20240508 >									
	//        < 03h2LIL9Z8D7yo7jbgfnJ75k6j58bH59ie1Ji8F49fd2MrCk810E79fC9N478Oo2 >									
	//        <  u =="0.000000000000000001" : ] 000000117136712.773849000000000000 ; 000000127649887.058313000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B2BC87C2C73D >									
	//     < BANK_II_PFII_metadata_line_13_____NOVO_NORDISK_20240508 >									
	//        < 8H78788FW240nU5svs28B3hgsV7xC4f85i3Gf4Gm1sr4fwXpfbT3aT443psL6z4H >									
	//        <  u =="0.000000000000000001" : ] 000000127649887.058313000000000000 ; 000000138122254.929238000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C2C73DD2C201 >									
	//     < BANK_II_PFII_metadata_line_14_____COFACE_20240508 >									
	//        < 31a4hKO94L0gX3SF5A372Ln1E9ET6BfMY75k72c7UQKf6tQRw1GI6D6CVI75fa2n >									
	//        <  u =="0.000000000000000001" : ] 000000138122254.929238000000000000 ; 000000148949945.100015000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D2C201E34793 >									
	//     < BANK_II_PFII_metadata_line_15_____MOGUNTIA_20240508 >									
	//        < 1jiC8XdHnn348y0SyBTtrY9LD3bdMh0pH4NI284ualhN01OLR6Rfc856B04r639X >									
	//        <  u =="0.000000000000000001" : ] 000000148949945.100015000000000000 ; 000000159611767.421113000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E34793F38C59 >									
	//     < BANK_II_PFII_metadata_line_16_____DITSCH_20240508 >									
	//        < o8vX74Rlyh6G1W4416DzwX67Tw1zvL5goWf8K7J3d0pGYEks6J6jmwzmudktotO9 >									
	//        <  u =="0.000000000000000001" : ] 000000159611767.421113000000000000 ; 000000170454238.174689000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F38C5910417B0 >									
	//     < BANK_II_PFII_metadata_line_17_____GRANDS_CHAIS_DE_FRANCE_20240508 >									
	//        < 1S1vb65dKab85KZaLk615hdmXOhnP8occbI1CrL707aJKGMmL7Jooy0J780isX7B >									
	//        <  u =="0.000000000000000001" : ] 000000170454238.174689000000000000 ; 000000181355442.013944000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010417B0114B9F8 >									
	//     < BANK_II_PFII_metadata_line_18_____Zweites Deutsches Fernsehen_ZDF_20240508 >									
	//        < paA5FhfoZ6G3FtIcHZa9HNhW6zzzQQd60270D6jT5nP58bA2U1j1Yn9i4Z2KmsW7 >									
	//        <  u =="0.000000000000000001" : ] 000000181355442.013944000000000000 ; 000000192144391.503728000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000114B9F81253067 >									
	//     < BANK_II_PFII_metadata_line_19_____3SAT_20240508 >									
	//        < FINdOlkg1CRXcwR10nEs2TfPH7d24S7ldnbKci6ZY79U5YQAggb2MZUYI8i2Z7vp >									
	//        <  u =="0.000000000000000001" : ] 000000192144391.503728000000000000 ; 000000202798414.730836000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012530671357221 >									
	//     < BANK_II_PFII_metadata_line_20_____Südwestrundfunk_SWR_20240508 >									
	//        < H3w84m3P3y62fwuihn4IKa7JfolJW59gLLb7v342W269bw8nusjDa7197gYc896T >									
	//        <  u =="0.000000000000000001" : ] 000000202798414.730836000000000000 ; 000000213484200.578919000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001357221145C044 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_II_PFII_metadata_line_21_____SCHOTT_MUSIC_20240508 >									
	//        < tHrhVPHm8J7gXJaFwC32c89tHPx2mPSmlmQcK2kO1q1C8v0j6QKp81bAR0aXn5SN >									
	//        <  u =="0.000000000000000001" : ] 000000213484200.578919000000000000 ; 000000224061956.221901000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000145C044155E434 >									
	//     < BANK_II_PFII_metadata_line_22_____Verlagsgruppe Rhein Main_20240508 >									
	//        < 2oPVbG38KwXuTC3q6911l6Cb646LaY3iCq7vyTpPCe0REeJ6Z8dO3pie5dJAjJ3G >									
	//        <  u =="0.000000000000000001" : ] 000000224061956.221901000000000000 ; 000000234550144.290312000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000155E434165E526 >									
	//     < BANK_II_PFII_metadata_line_23_____Philipp von Zabern_20240508 >									
	//        < OE343Yl052jw5LqFt11q7U59LaQjWB7aSkVFbn6Ot2Vhi11Q91Nw1Tl6xgqRKREF >									
	//        <  u =="0.000000000000000001" : ] 000000234550144.290312000000000000 ; 000000245376886.567906000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000165E5261766A59 >									
	//     < BANK_II_PFII_metadata_line_24_____De Dietrich Process Systems_GMBH_20240508 >									
	//        < 65cAi21fBHB19ViVfxndWK5Yl64UbbX1HqJA764wrV58r1ja30a8zy1au6vMbaHs >									
	//        <  u =="0.000000000000000001" : ] 000000245376886.567906000000000000 ; 000000255851366.672951000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001766A5918665F1 >									
	//     < BANK_II_PFII_metadata_line_25_____FIRST_SOLAR_GMBH_20240508 >									
	//        < RV8uz2q1drpI8B1p5LBM392AhT1c89mz5974IVKs9HuTA7IKSTaoi342c24Wl18r >									
	//        <  u =="0.000000000000000001" : ] 000000255851366.672951000000000000 ; 000000266662458.870083000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018665F1196E506 >									
	//     < BANK_II_PFII_metadata_line_26_____BIONTECH_SE_20240508 >									
	//        < 55c511chLC0jdwzyiIQC3VdIi6HICM66YD6slmJ9m2wq09T22E4456mRHX97MAeu >									
	//        <  u =="0.000000000000000001" : ] 000000266662458.870083000000000000 ; 000000277254690.140822000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000196E5061A70E9D >									
	//     < BANK_II_PFII_metadata_line_27_____UNI_MAINZ_20240508 >									
	//        < AZ57vOuAhmK2888Rv62J32D8zh38F02207Ep2Kp8mxUq658xdRw84445y0613Z6z >									
	//        <  u =="0.000000000000000001" : ] 000000277254690.140822000000000000 ; 000000288013859.862400000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A70E9D1B7796A >									
	//     < BANK_II_PFII_metadata_line_28_____Mainz Institute of Microtechnology_20240508 >									
	//        < ewzzO4JTmTqwoThciyJ7wjzZIAxs0998cW8KS8f16B9fTwExR0l3R4h157qDVfIH >									
	//        <  u =="0.000000000000000001" : ] 000000288013859.862400000000000000 ; 000000298581781.393457000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B7796A1C79982 >									
	//     < BANK_II_PFII_metadata_line_29_____Matthias_Grünewald_Verlag_20240508 >									
	//        < Qy7Tvtz45J4edw8u38yp07XDnXTVWidqj9qe5y41Iy0tXKP4TMaabo9LhgzCGxEr >									
	//        <  u =="0.000000000000000001" : ] 000000298581781.393457000000000000 ; 000000309374759.395449000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C799821D81184 >									
	//     < BANK_II_PFII_metadata_line_30_____PEDIA_PRESS_20240508 >									
	//        < 0acXJipvOT2EcdD2tA6b8ZC6mOJ7yM86bx61T1gTW5776yOvQS57Pomv9LBJ5EMA >									
	//        <  u =="0.000000000000000001" : ] 000000309374759.395449000000000000 ; 000000320222247.931052000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D811841E89ED1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_II_PFII_metadata_line_31_____Boehringer Ingelheim_20240508 >									
	//        < 42uq92082wvtp9xZ8Fj3xed2QnNka76kaD7a0pwy7o5I38q0XPt35Rwxr3G4714d >									
	//        <  u =="0.000000000000000001" : ] 000000320222247.931052000000000000 ; 000000330725163.986010000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E89ED11F8A584 >									
	//     < BANK_II_PFII_metadata_line_32_____MIDAS_PHARMA_20240508 >									
	//        < nypwmxz4N4bT49Z6QeIZ44nIhiNAQexB7XFQzOGAkwMUOhn23lzB1H2vjiOU0A2Y >									
	//        <  u =="0.000000000000000001" : ] 000000330725163.986010000000000000 ; 000000341553780.268315000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F8A5842092B72 >									
	//     < BANK_II_PFII_metadata_line_33_____MIDAS_PHARMA_POLSKA_20240508 >									
	//        < Ko181eDP01COIufbM5XI1XJFL1W5A98bzczVkF1AM8chE4V7yzJfcjloGmlL2gca >									
	//        <  u =="0.000000000000000001" : ] 000000341553780.268315000000000000 ; 000000352380863.545366000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002092B72219B0C6 >									
	//     < BANK_II_PFII_metadata_line_34_____CMS_PHARMA_20240508 >									
	//        < nM9yQE65v27BP0R4M4feiZR57Kg24jH24mFH6qIji2WpCEDbFHhXk0QQZSLdEAj2 >									
	//        <  u =="0.000000000000000001" : ] 000000352380863.545366000000000000 ; 000000362983326.882763000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000219B0C6229DE5D >									
	//     < BANK_II_PFII_metadata_line_35_____CAIGOS_GMBH_20240508 >									
	//        < 79VUm0zP7YS3rdkXHutgjTmN9A9tm0a72JWDb38HdQi7O2y8r0KqncJ988VP18hA >									
	//        <  u =="0.000000000000000001" : ] 000000362983326.882763000000000000 ; 000000373885195.584688000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000229DE5D23A80E8 >									
	//     < BANK_II_PFII_metadata_line_36_____Altes E_Werk der Rheinhessische Energie_und Wasserversorgungs_GmbH_20240508 >									
	//        < V0HW4I9cm8Ouh2QpOiINL15Y4YU7FQr3O2k33AJp2jKH691SAtNL90r0qqOt8Nyx >									
	//        <  u =="0.000000000000000001" : ] 000000373885195.584688000000000000 ; 000000384509720.120705000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023A80E824AB71C >									
	//     < BANK_II_PFII_metadata_line_37_____THUEGA_AG_20240508 >									
	//        < hBi641Qu9RDd33DSek2J5GM6tN1n57JIJdE16fmJ9x292WjgGYV18Dm5E0iH4Jlp >									
	//        <  u =="0.000000000000000001" : ] 000000384509720.120705000000000000 ; 000000395216717.116941000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024AB71C25B0D88 >									
	//     < BANK_II_PFII_metadata_line_38_____Verbandsgemeinde Heidesheim am Rhein_20240508 >									
	//        < hhV05yoz1I4guvl7Ffs57KL4rBTHnR2Yk8L6avek5MKN0Zn0u6r2DNp6ChwbQIVI >									
	//        <  u =="0.000000000000000001" : ] 000000395216717.116941000000000000 ; 000000405688350.896395000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025B0D8826B0803 >									
	//     < BANK_II_PFII_metadata_line_39_____Stadtwerke Ingelheim_AB_20240508 >									
	//        < Y5NCg6A3X49YYG811dPGW5M96425WpvO79s73O2IbtxHkNRMck93ts68YYH5Ebsq >									
	//        <  u =="0.000000000000000001" : ] 000000405688350.896395000000000000 ; 000000416427857.690942000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026B080327B6B22 >									
	//     < BANK_II_PFII_metadata_line_40_____rhenag Rheinische Energie AG_KOELN_20240508 >									
	//        < I2zMz83icTqO15RaK5pmkl88t9GQ5ok0KeP9Rzge3ivb2pib2301G0a9znZ1nNkf >									
	//        <  u =="0.000000000000000001" : ] 000000416427857.690942000000000000 ; 000000427084638.464842000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027B6B2228BADF0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
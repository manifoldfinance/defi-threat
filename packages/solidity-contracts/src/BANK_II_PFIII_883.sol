/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	BANK_II_PFIII_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	BANK_II_PFIII_883		"	;
		string	public		symbol =	"	BANK_II_PFIII_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		439095964093327000000000000					;	
										
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
	//     < BANK_II_PFIII_metadata_line_1_____GEBR_ALEXANDER_20260508 >									
	//        < C9tb9c71ba7Y5cmJEVu76J3420d1n78Vz93f33oh83z80aV5RS6W2mbQW35hH917 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010729874.909194700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000105F5B >									
	//     < BANK_II_PFIII_metadata_line_2_____SCHOTT _GLASWERKE_AG_20260508 >									
	//        < Vd7M6J4Yoqptyy4U48Ar4P5LXZzRKdxQN3i07K4NW0wH8qxr3c81Mnh0BtXXp00P >									
	//        <  u =="0.000000000000000001" : ] 000000010729874.909194700000000000 ; 000000021863238.519883400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000105F5B215C54 >									
	//     < BANK_II_PFIII_metadata_line_3_____MAINZ_HAUPTBAHNHOF_20260508 >									
	//        < 83A9b1i0oRfDsZG4vRMl3Dknq6J1XTOSuI7QGKfEz4xP98c2BRY436SNM4sU6R1H >									
	//        <  u =="0.000000000000000001" : ] 000000021863238.519883400000000000 ; 000000032910883.225757900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000215C543237D0 >									
	//     < BANK_II_PFIII_metadata_line_4_____PORT_DOUANIER_ET_FLUVIAL_DE_MAYENCE_20260508 >									
	//        < PjMxpu8yFDsYZT7isLQSQYb4X31926C45369034ixYYw0dBR9SVy2z4DdcnSh7yC >									
	//        <  u =="0.000000000000000001" : ] 000000032910883.225757900000000000 ; 000000044220541.513087900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003237D04379A6 >									
	//     < BANK_II_PFIII_metadata_line_5_____WERNER_MERTZ_20260508 >									
	//        < Jx0pQCaqeiV5F7b7PtdkPF7LbWIvYhGF932eD98fpG32g1Ujb2MSHwUXh179B3Xe >									
	//        <  u =="0.000000000000000001" : ] 000000044220541.513087900000000000 ; 000000055111170.666548400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004379A65417CD >									
	//     < BANK_II_PFIII_metadata_line_6_____JF_HILLEBRAND_20260508 >									
	//        < getKoC9C6sckSaw3d9zkqFfwBma3QPGkUY5ZuAlF7ayottI6hlEJH9J3W2ju7416 >									
	//        <  u =="0.000000000000000001" : ] 000000055111170.666548400000000000 ; 000000065972179.239507600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005417CD64AA62 >									
	//     < BANK_II_PFIII_metadata_line_7_____TRANS_OCEAN_20260508 >									
	//        < QoH6hm508q5dP2v99tyd6cNJyfK6VQK3H234r12j9DqM6J3vmArx69A0F2ihK7Hw >									
	//        <  u =="0.000000000000000001" : ] 000000065972179.239507600000000000 ; 000000077047239.446817000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000064AA62759094 >									
	//     < BANK_II_PFIII_metadata_line_8_____SATELLITE_LOGISTICS_GROUP_20260508 >									
	//        < 3QNNRJUe6faR55Ck0vGFI0s013oy3B9lQfCrY6HXDMPEHyEdX4T13hJMc91MOqJ1 >									
	//        <  u =="0.000000000000000001" : ] 000000077047239.446817000000000000 ; 000000087745404.141002700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000075909485E38C >									
	//     < BANK_II_PFIII_metadata_line_9_____JF_HILLEBRAND_GROUP_20260508 >									
	//        < zugLG33326pjmImUP9UgVFS7D2bU41E303IPM03u5i4mPhWEQW4F9o06sw6oTlp1 >									
	//        <  u =="0.000000000000000001" : ] 000000087745404.141002700000000000 ; 000000098785158.073178900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000085E38C96BBF4 >									
	//     < BANK_II_PFIII_metadata_line_10_____ARCHER_DANIELS_MIDLAND_20260508 >									
	//        < Lbs0biLk1dRJlM4Tw2oEHk1R27aQuu8J1IgMvqXPXG0WXzqdGVz8ny5yX848I6Xg >									
	//        <  u =="0.000000000000000001" : ] 000000098785158.073178900000000000 ; 000000109789711.366605000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000096BBF4A7869B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_II_PFIII_metadata_line_11_____WEPA_20260508 >									
	//        < 8Nlv0BztC18WV013t82EpILRAml1v6wv7l3T4qx8py14bAD0xm0s5olc22YHOmJ1 >									
	//        <  u =="0.000000000000000001" : ] 000000109789711.366605000000000000 ; 000000120629831.538021000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A7869BB81107 >									
	//     < BANK_II_PFIII_metadata_line_12_____IBM_CORP_20260508 >									
	//        < 0esbCWwgjL9BM9LqV5avvYqW262fne7xhp5HvY553TeAse49RzT6O6QAvc55AV32 >									
	//        <  u =="0.000000000000000001" : ] 000000120629831.538021000000000000 ; 000000131582156.268063000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B81107C8C748 >									
	//     < BANK_II_PFIII_metadata_line_13_____NOVO_NORDISK_20260508 >									
	//        < rE4A0bWHfdX4C8Ce2Gn3k11b8YKyF2ot9kewbOW0EO53J1XFsq11G2582rkp344A >									
	//        <  u =="0.000000000000000001" : ] 000000131582156.268063000000000000 ; 000000142271667.742138000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C8C748D916DF >									
	//     < BANK_II_PFIII_metadata_line_14_____COFACE_20260508 >									
	//        < 2kMhH3M3281t1RFgg73J180WsJWN65A7HlQfcoTei4vVc0r1O2LU5EuFh9F6k600 >									
	//        <  u =="0.000000000000000001" : ] 000000142271667.742138000000000000 ; 000000153559039.202774000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D916DFEA5000 >									
	//     < BANK_II_PFIII_metadata_line_15_____MOGUNTIA_20260508 >									
	//        < q7KE6F3ojqFAeRQvNy3Duq25icYN10AiQ3MSQGZ9wL5AwwB2K2aWZdQKc65Dc4mR >									
	//        <  u =="0.000000000000000001" : ] 000000153559039.202774000000000000 ; 000000164410829.777966000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000EA5000FADEFB >									
	//     < BANK_II_PFIII_metadata_line_16_____DITSCH_20260508 >									
	//        < 0BqP1Mze668kuEF49MzJxDTlMo7619BNChn0zWx9VX7Q60Pg9dZ7nHn5GEvDbGFP >									
	//        <  u =="0.000000000000000001" : ] 000000164410829.777966000000000000 ; 000000175295840.476115000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FADEFB10B7AF0 >									
	//     < BANK_II_PFIII_metadata_line_17_____GRANDS_CHAIS_DE_FRANCE_20260508 >									
	//        < 0i5cje5DYzDAE8dkjLzjkAw477J99U2LacNL8n1MhAn4AHw9T3H2hSg9HWJYa9X3 >									
	//        <  u =="0.000000000000000001" : ] 000000175295840.476115000000000000 ; 000000186064460.199121000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010B7AF011BE96E >									
	//     < BANK_II_PFIII_metadata_line_18_____Zweites Deutsches Fernsehen_ZDF_20260508 >									
	//        < YP4oL8rHl3Il2t75Y4oQuGXBzbBtgfsic0i2AR7xQW23E9hl7I8O7BNwGo326I4B >									
	//        <  u =="0.000000000000000001" : ] 000000186064460.199121000000000000 ; 000000197122527.395693000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011BE96E12CC8FD >									
	//     < BANK_II_PFIII_metadata_line_19_____3SAT_20260508 >									
	//        < nC8gbj3On4SQ00gwJa1T33hEcQ3p1yug1j4e9et5jI9M2A7007YVweIzSt67NuBO >									
	//        <  u =="0.000000000000000001" : ] 000000197122527.395693000000000000 ; 000000208087873.586923000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012CC8FD13D8453 >									
	//     < BANK_II_PFIII_metadata_line_20_____Südwestrundfunk_SWR_20260508 >									
	//        < sMRdP5R1aVXfX0p10H7Mv0Zt62D3f2UfdK734C03cqE97Vk2nkxaQwYI45COog2l >									
	//        <  u =="0.000000000000000001" : ] 000000208087873.586923000000000000 ; 000000219313737.712080000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013D845314EA56E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_II_PFIII_metadata_line_21_____SCHOTT_MUSIC_20260508 >									
	//        < L06xWX2pAb7It5L5k5BNIPI6jwaO1B0K79L8J317lN26hn9pjWlA4dNMmz3kL0B7 >									
	//        <  u =="0.000000000000000001" : ] 000000219313737.712080000000000000 ; 000000230236109.313353000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014EA56E15F4FFB >									
	//     < BANK_II_PFIII_metadata_line_22_____Verlagsgruppe Rhein Main_20260508 >									
	//        < u63Q9OoNIpPS0Wr37x802V3KLEKNgT25PsKmlbfwPsvV6DXyDD64s0Ya0BG48i5p >									
	//        <  u =="0.000000000000000001" : ] 000000230236109.313353000000000000 ; 000000241135819.684068000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015F4FFB16FF1AE >									
	//     < BANK_II_PFIII_metadata_line_23_____Philipp von Zabern_20260508 >									
	//        < QUQYE698w1XyVOX9hiaT8p61g65FL40z2pYDf2MsrM27bvKDb5jhf838Whp9AzBI >									
	//        <  u =="0.000000000000000001" : ] 000000241135819.684068000000000000 ; 000000252091396.643792000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016FF1AE180A934 >									
	//     < BANK_II_PFIII_metadata_line_24_____De Dietrich Process Systems_GMBH_20260508 >									
	//        < 73ZU396zU1GbK1GXQ0k371G0kZVQf49jvHzP0feXR866ZGDYin1f2eU475Q8SMv1 >									
	//        <  u =="0.000000000000000001" : ] 000000252091396.643792000000000000 ; 000000263303575.362326000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000180A934191C4F6 >									
	//     < BANK_II_PFIII_metadata_line_25_____FIRST_SOLAR_GMBH_20260508 >									
	//        < qtcS1srZ9alTff960NUHvskQJL3Plkl345sDyT05CR4mALXuY8mxfwZ4MhVmn3hn >									
	//        <  u =="0.000000000000000001" : ] 000000263303575.362326000000000000 ; 000000274509742.127549000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000191C4F61A2DE5E >									
	//     < BANK_II_PFIII_metadata_line_26_____BIONTECH_SE_20260508 >									
	//        < iyRQ6aKVUAhu6Se64o7ij5m1Qx8A9G1rrPRc9JTD6o02egVFRZ6g2X71tILp7FNu >									
	//        <  u =="0.000000000000000001" : ] 000000274509742.127549000000000000 ; 000000285751602.649494000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A2DE5E1B405B8 >									
	//     < BANK_II_PFIII_metadata_line_27_____UNI_MAINZ_20260508 >									
	//        < 5JJ6N4h0vf4ExrPB2Wh6pTR70519Fa0WHM8oU52KjRl9l0psrB6P3BR0HPwGe5Wo >									
	//        <  u =="0.000000000000000001" : ] 000000285751602.649494000000000000 ; 000000296469964.209311000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B405B81C46094 >									
	//     < BANK_II_PFIII_metadata_line_28_____Mainz Institute of Microtechnology_20260508 >									
	//        < r4SHJ6Id3oG1dc01UVeoGrrj5sHmKY1lFg7SUPYOYBK9ic7ByAngs1tKuPgc8Z2m >									
	//        <  u =="0.000000000000000001" : ] 000000296469964.209311000000000000 ; 000000307165268.547102000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C460941D4B26F >									
	//     < BANK_II_PFIII_metadata_line_29_____Matthias_Grünewald_Verlag_20260508 >									
	//        < 2nPzV6M3f3SytM2H27uMXx3z3Yqi32s65jwZyu5Ti36KX8Z92t1Lnc9e9nfwlsVJ >									
	//        <  u =="0.000000000000000001" : ] 000000307165268.547102000000000000 ; 000000318140329.270543000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D4B26F1E57191 >									
	//     < BANK_II_PFIII_metadata_line_30_____PEDIA_PRESS_20260508 >									
	//        < ucP8mVC15TKz8ww7gQF4LNLXdSOu57xVIcN4J2Qr1q6qxn73EyO6ynLqdk7bc0Dd >									
	//        <  u =="0.000000000000000001" : ] 000000318140329.270543000000000000 ; 000000328968660.148232000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E571911F5F762 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_II_PFIII_metadata_line_31_____Boehringer Ingelheim_20260508 >									
	//        < t4Q79Rx563Fj69A2Lmb6H8pp1qw1k165I06Ab7G1C19alhmCf1lUWp5LS236h838 >									
	//        <  u =="0.000000000000000001" : ] 000000328968660.148232000000000000 ; 000000340288533.601374000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F5F7622073D35 >									
	//     < BANK_II_PFIII_metadata_line_32_____MIDAS_PHARMA_20260508 >									
	//        < GeFRl9PCo6RR625LgWT1UpVK6a8m524QYrG9WyKa7dmp9U8k2oDl7qhrK6tI72o4 >									
	//        <  u =="0.000000000000000001" : ] 000000340288533.601374000000000000 ; 000000351232079.100075000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002073D35217F008 >									
	//     < BANK_II_PFIII_metadata_line_33_____MIDAS_PHARMA_POLSKA_20260508 >									
	//        < c9Ga4Ec7pj7617SWUW83CHLeINn9Qqt9T8Y31w91BFvV03OnA4yum5vZQsIwnjR6 >									
	//        <  u =="0.000000000000000001" : ] 000000351232079.100075000000000000 ; 000000361928976.316670000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000217F0082284282 >									
	//     < BANK_II_PFIII_metadata_line_34_____CMS_PHARMA_20260508 >									
	//        < watmOIIvILM5CH2e0v59fCv71emswA7Zp6i6mpCh7Yn0v7IZIL8226Svhoo7vOrL >									
	//        <  u =="0.000000000000000001" : ] 000000361928976.316670000000000000 ; 000000373162102.642842000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022842822396672 >									
	//     < BANK_II_PFIII_metadata_line_35_____CAIGOS_GMBH_20260508 >									
	//        < D9ajEj7KsKOUMq599F0xub70m38t0qUl31g6JiJ0yP9e8HXNYJ2mS8PpS8pJfJ5T >									
	//        <  u =="0.000000000000000001" : ] 000000373162102.642842000000000000 ; 000000384041826.192125000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000239667224A0057 >									
	//     < BANK_II_PFIII_metadata_line_36_____Altes E_Werk der Rheinhessische Energie_und Wasserversorgungs_GmbH_20260508 >									
	//        < 2jeSd87cyu4vh4fZg53fYsst9fpuv8J6Zl0u0gPbf136NpY3PP5GH8FavW9cT1PY >									
	//        <  u =="0.000000000000000001" : ] 000000384041826.192125000000000000 ; 000000395126002.933732000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024A005725AEA18 >									
	//     < BANK_II_PFIII_metadata_line_37_____THUEGA_AG_20260508 >									
	//        < 9UU69375n7728T1qr1ir8FzBe8d794fP9HB6K3pq79n3621p3F0TUb2D8F8693p0 >									
	//        <  u =="0.000000000000000001" : ] 000000395126002.933732000000000000 ; 000000405824549.602227000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025AEA1826B3D37 >									
	//     < BANK_II_PFIII_metadata_line_38_____Verbandsgemeinde Heidesheim am Rhein_20260508 >									
	//        < 54J81B8brZTJUygCPoevJpKc8wJ6sf5vU3ymzU8062D5jZS3F80a4qpt6cERgHzz >									
	//        <  u =="0.000000000000000001" : ] 000000405824549.602227000000000000 ; 000000416944060.797144000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026B3D3727C34C6 >									
	//     < BANK_II_PFIII_metadata_line_39_____Stadtwerke Ingelheim_AB_20260508 >									
	//        < KJLbY0N11j9Urg43ErIqTE767A7ZuDBja8hAa2z9wqh66PX2ATLBBaUwKDwJVDX6 >									
	//        <  u =="0.000000000000000001" : ] 000000416944060.797144000000000000 ; 000000428031099.627910000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027C34C628D1FA6 >									
	//     < BANK_II_PFIII_metadata_line_40_____rhenag Rheinische Energie AG_KOELN_20260508 >									
	//        < cLscj98RgT21kPF733p23h5eQ03v2zr7qHDn9KC1l9krbJ3EMa3V9I03Dp60jabs >									
	//        <  u =="0.000000000000000001" : ] 000000428031099.627910000000000000 ; 000000439095964.093327000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028D1FA629E01DC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
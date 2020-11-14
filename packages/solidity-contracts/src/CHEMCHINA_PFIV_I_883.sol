/**
 * Source Code first verified at https://etherscan.io on Friday, March 22, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFIV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFIV_I_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFIV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		582378823553285000000000000					;	
										
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
	//     < CHEMCHINA_PFIV_I_metadata_line_1_____Kaifute__Tianjin__Chemical_Co___Ltd__20220321 >									
	//        < 09CN5klv7xWP3IFGx2bsyNZ934Fql8BT563a6EfSsRlEUYg367j0MJ87K9Atu8aF >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000013513688.112834700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000149EC9 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_2_____Kaiyuan_Chemicals_Co__Limited_20220321 >									
	//        < jOGOCe6z1o2k4KwWsD2cxz7EzDWd9Uv3As86vuLowXPj7F6lAwA7kqUH8YBU24Z8 >									
	//        <  u =="0.000000000000000001" : ] 000000013513688.112834700000000000 ; 000000029285012.485496900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000149EC92CAF75 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_3_____Kinbester_org_20220321 >									
	//        < PHV28HonNIf0sRaAZ4011pL9xnECeHghnz6T0XT8EdS9cX0nNsJUL8ghT4MmVhka >									
	//        <  u =="0.000000000000000001" : ] 000000029285012.485496900000000000 ; 000000043894152.627250700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002CAF7542FA27 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_4_____Kinbester_Co_Limited_20220321 >									
	//        < n43cvsIztz2P8EqZmBN5V3F7z04V3p343225Ygq25HXqTTSyCCv2eV000vS44427 >									
	//        <  u =="0.000000000000000001" : ] 000000043894152.627250700000000000 ; 000000057566746.703826600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000042FA2757D703 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_5_____Kinfon_Pharmachem_Co_Limited_20220321 >									
	//        < 3Rtpe7ZA8SgL29WFY7Mh8FN6K951886oaz4O604M6h24Tfi1Hlnr2099OELHB10P >									
	//        <  u =="0.000000000000000001" : ] 000000057566746.703826600000000000 ; 000000072997620.634451000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000057D7036F62B2 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_6_____King_Scientific_20220321 >									
	//        < 859xVk3X7427kTL13o20is76v2Q4acx4Yfg16Lfe93m9ZR9SvqO4nttGe0y6Xy0M >									
	//        <  u =="0.000000000000000001" : ] 000000072997620.634451000000000000 ; 000000086328412.475527800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006F62B283BA09 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_7_____Kingreat_Chemistry_Company_Limited_20220321 >									
	//        < rGCC24wV6UAV7bLhrPSn9WhHq3o082oSay8D867aAgeB49Dd971VU0JE14MFq992 >									
	//        <  u =="0.000000000000000001" : ] 000000086328412.475527800000000000 ; 000000099416314.580296800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000083BA0997B27F >									
	//     < CHEMCHINA_PFIV_I_metadata_line_8_____Labseeker_org_20220321 >									
	//        < 51aO2YkbU81k78C55eW2Oq7oBA7ne8UrpxvA559keX2TqqZj1Yu7Hp21KP4IGv8T >									
	//        <  u =="0.000000000000000001" : ] 000000099416314.580296800000000000 ; 000000113841150.117675000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000097B27FADB533 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_9_____Labseeker_20220321 >									
	//        < vQuyH6055nPmn6Nxem46G3Trcf0z982rro1RiZ4d24pXeEyMgBDw37X8lp8yXr5t >									
	//        <  u =="0.000000000000000001" : ] 000000113841150.117675000000000000 ; 000000129057499.542320000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000ADB533C4ED16 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_10_____Langfang_Beixin_Chemical_Company_Limited_20220321 >									
	//        < XcCy47yx5kB8o1GUb64n4exPG2ipk69vXG0XWl55r2u59JAZG8L8ncs303VUH5vK >									
	//        <  u =="0.000000000000000001" : ] 000000129057499.542320000000000000 ; 000000143730790.586656000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C4ED16DB50D7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIV_I_metadata_line_11_____Leap_Labchem_Co_Limited_20220321 >									
	//        < rj8B03SCZPzOe2Gyn8Ysn1k2Af5716q353FSrLIa7wG3VO76TvBlpDUdaU62YzWY >									
	//        <  u =="0.000000000000000001" : ] 000000143730790.586656000000000000 ; 000000157134635.972637000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DB50D7EFC4B8 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_12_____Leap_Labchem_Co_Limited_20220321 >									
	//        < wmyfHLLbn8c0Pd5P9TQY4OBf3sE47yhmV1qOTF2CAYra7w6BEkO9e81PQZSGT320 >									
	//        <  u =="0.000000000000000001" : ] 000000157134635.972637000000000000 ; 000000171770495.163879000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EFC4B810619DA >									
	//     < CHEMCHINA_PFIV_I_metadata_line_13_____LON_CHEMICAL_org_20220321 >									
	//        < k7oRAkxt9r5NQ7TM022kG68s73HgSK437Q9xB96xrFML5yy6n8OEfX5gj0p1oM4F >									
	//        <  u =="0.000000000000000001" : ] 000000171770495.163879000000000000 ; 000000187848008.645123000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010619DA11EA221 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_14_____LON_CHEMICAL_20220321 >									
	//        < dF8z22rUgq0So4I9W5i40YT689bH134yEKvpM6HySt5zJZH0CB872otIjs2lw2X8 >									
	//        <  u =="0.000000000000000001" : ] 000000187848008.645123000000000000 ; 000000202348313.957375000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011EA221134C24F >									
	//     < CHEMCHINA_PFIV_I_metadata_line_15_____LVYU_Chemical_Co__Limited_20220321 >									
	//        < mkFpszljZ711C8jvTDhg55E5dYX7l408T07N9KF8Zc4OQ8OgW29h77f5QhaLgWtu >									
	//        <  u =="0.000000000000000001" : ] 000000202348313.957375000000000000 ; 000000217634968.326150000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000134C24F14C15A9 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_16_____MASCOT_I_E__Co_Limited_20220321 >									
	//        < 12iRQK4uW60coB2vw12VKbRVsUuGZ551bDY0Bn2qjXm53DJS9zGPAjr01D693YUN >									
	//        <  u =="0.000000000000000001" : ] 000000217634968.326150000000000000 ; 000000233113314.720612000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014C15A9163B3E3 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_17_____NANCHANG_LONGDING_TECHNOLOGY_DEVELOPMENT_Co_Limited_20220321 >									
	//        < 2bh9JEFFXwpy8mys2qN0lvU4RZ8h3CEdE6undHm6KB13mYIKP36C9lrX1bTALGP1 >									
	//        <  u =="0.000000000000000001" : ] 000000233113314.720612000000000000 ; 000000246595814.228104000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000163B3E3178467D >									
	//     < CHEMCHINA_PFIV_I_metadata_line_18_____Nanjing_BoomKing_Industrial_Co_Limited_20220321 >									
	//        < Ta3rJvxMyH76JZnI2W6c9l1XG7JM8fhgM0HTXcWo8kbzmWHk8K8zOHx5c9p9M4Mr >									
	//        <  u =="0.000000000000000001" : ] 000000246595814.228104000000000000 ; 000000262776555.736689000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000178467D190F718 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_19_____Nanjing_Boyuan_Pharmatech_Co_Limited_20220321 >									
	//        < 20JA6UZMhlmzkIH8bPH4mw626Dk44ExB3xjEVq5VcR5OlT4z7r93CMA2V1l8O84f >									
	//        <  u =="0.000000000000000001" : ] 000000262776555.736689000000000000 ; 000000277588268.016817000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000190F7181A790EB >									
	//     < CHEMCHINA_PFIV_I_metadata_line_20_____Nanjing_Chemlin_Chemical_Industry_org_20220321 >									
	//        < 0uY7Ff3T3IQkKu2Tnf5Z6WK3fBcYeknbB9d07Dv2ri03i7crU1V7caJGQxs9pqi0 >									
	//        <  u =="0.000000000000000001" : ] 000000277588268.016817000000000000 ; 000000290485086.015711000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A790EB1BB3EBD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIV_I_metadata_line_21_____Nanjing_Chemlin_Chemical_Industry_Co_Limited_20220321 >									
	//        < u07E5LUy7jEA0DB25aSV9A0LX7sq24K6tedrpQS4R4XwsK7310198IJ5B2G2qrLZ >									
	//        <  u =="0.000000000000000001" : ] 000000290485086.015711000000000000 ; 000000306400409.183230000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BB3EBD1D387A9 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_22_____Nanjing_Chemlin_Chemical_Industry_Co_Limited_20220321 >									
	//        < POgGdXbMmrr9ge4Ileq6plXm32Cj9q8w0m0pnVRt5L1Bdx99ctfJ9687877vpSRh >									
	//        <  u =="0.000000000000000001" : ] 000000306400409.183230000000000000 ; 000000321488070.126643000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D387A91EA8D47 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_23_____Nanjing_Fubang_Chemical_Co_Limited_20220321 >									
	//        < Zm4wFM76NzubMlch45vGaF01jN005ewu2m0m9ZGF7VZYtEbm1ao0BdLZ437C8YMp >									
	//        <  u =="0.000000000000000001" : ] 000000321488070.126643000000000000 ; 000000337346008.085204000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EA8D47202BFC9 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_24_____Nanjing_Legend_Pharmaceutical___Chemical_Co__Limited_20220321 >									
	//        < QRWEBQ6MUF8Su434lnmt2D92V0K0Sr2o9u3mxkwDmw8oYrAQYcbwB39AGGG5dTau >									
	//        <  u =="0.000000000000000001" : ] 000000337346008.085204000000000000 ; 000000351136755.734276000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000202BFC9217CACC >									
	//     < CHEMCHINA_PFIV_I_metadata_line_25_____Nanjing_Raymon_Biotech_Co_Limited_20220321 >									
	//        < WD9H3e39zi180N3DC1OGEqHX6E6Obf9j5ECv2A5NIYv0qUKAa7k85Duypr1g8oaq >									
	//        <  u =="0.000000000000000001" : ] 000000351136755.734276000000000000 ; 000000367333338.244561000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000217CACC2308196 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_26_____Nantong_Baihua_Bio_Pharmaceutical_Co_Limited_20220321 >									
	//        < rw2OHtM1UVdZF8E37dTHt74aT8cACPP1E4pqf9cHy3L83EV8djcBzS35V574Ry3z >									
	//        <  u =="0.000000000000000001" : ] 000000367333338.244561000000000000 ; 000000381652814.607694000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023081962465B21 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_27_____Nantong_Qihai_Chemicals_org_20220321 >									
	//        < V75f6doHTdy2fyAE9jSa1X9C3RiVQ18e26Z41N5RmF1mK7icBcas2SKXV005393V >									
	//        <  u =="0.000000000000000001" : ] 000000381652814.607694000000000000 ; 000000394657347.902426000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002465B2125A3307 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_28_____Nantong_Qihai_Chemicals_Co_Limited_20220321 >									
	//        < tjVuWLg2KWt1nS45jlL8J2I65379U2H1DjiCk6M127ZPj0b7e5Cs91g5rFSafGnv >									
	//        <  u =="0.000000000000000001" : ] 000000394657347.902426000000000000 ; 000000407429604.167784000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025A330726DB030 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_29_____Nebula_Chemicals_Co_Limited_20220321 >									
	//        < 1W19lW3thF0h0CP608B1sOCdq2eBBBDR04BZ59y8OETIcF68T27Ys1EvEPvVT6Fm >									
	//        <  u =="0.000000000000000001" : ] 000000407429604.167784000000000000 ; 000000421342660.956319000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026DB030282EAFA >									
	//     < CHEMCHINA_PFIV_I_metadata_line_30_____Neostar_United_Industrial_Co__Limited_20220321 >									
	//        < UyQG83f4QfeZDX00vBG875bFWOcL5wE3rcty43s5XLdLavTzGeDS2UqpH61Sf4OB >									
	//        <  u =="0.000000000000000001" : ] 000000421342660.956319000000000000 ; 000000437515963.462755000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000282EAFA29B98AC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIV_I_metadata_line_31_____Nextpeptide_inc__20220321 >									
	//        < IJMnrhMKc7991Bv6Cy87GQD9vbUx69EZ827nn2U4AoMEWHIjoApI69o0vF5B3TuY >									
	//        <  u =="0.000000000000000001" : ] 000000437515963.462755000000000000 ; 000000453779401.513349000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029B98AC2B46994 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_32_____Ningbo_Nuobai_Pharmaceutical_Co_Limited_20220321 >									
	//        < y10NY419JJodaAEdE2K2HNIrDvnX6w2x8L61y9j8pV6s7WX5cRA6fN9V248X42ym >									
	//        <  u =="0.000000000000000001" : ] 000000453779401.513349000000000000 ; 000000466549625.828026000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B469942C7E5F3 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_33_____NINGBO_V_P_CHEMISTRY_20220321 >									
	//        < h1fO35TyvGW1Yz4Cu8WGYExBPgGt7xiM6q0To8BTM3OM097AJjl7XIJ82KUOtzO8 >									
	//        <  u =="0.000000000000000001" : ] 000000466549625.828026000000000000 ; 000000481861439.012530000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C7E5F32DF4320 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_34_____NovoChemy_Limited_20220321 >									
	//        < Fi501pELlYr619W67MbImf3O7qWDwV6kM1733OtNjVE09yjbxMaFxCH7roQ6YTu6 >									
	//        <  u =="0.000000000000000001" : ] 000000481861439.012530000000000000 ; 000000497889352.791589000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DF43202F7B807 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_35_____Novolite_Chemicals_org_20220321 >									
	//        < T9h39zfnMXuvW14jT7h2f144we3WSx0g448q9UBveHVSQ28KCzx3yji0BTEG5NNO >									
	//        <  u =="0.000000000000000001" : ] 000000497889352.791589000000000000 ; 000000512948243.747656000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F7B80730EB268 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_36_____Novolite_Chemicals_Co_Limited_20220321 >									
	//        < P30842Kn9Rcv26I1Cuc8AVVhXPhn9P3VE70p7JJ9LZdyFnM3COThSnlq0F3fCUt9 >									
	//        <  u =="0.000000000000000001" : ] 000000512948243.747656000000000000 ; 000000525822850.112319000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030EB268322578D >									
	//     < CHEMCHINA_PFIV_I_metadata_line_37_____Onichem_Specialities_Co__Limited_20220321 >									
	//        < 3DUt3Vap7I6x90Br1wx2xv0s91jhLWCa7tVuCXt3BN2365HS4Uu5sy8zw1YY8g99 >									
	//        <  u =="0.000000000000000001" : ] 000000525822850.112319000000000000 ; 000000539467447.115573000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000322578D3372979 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_38_____Orichem_international_Limited_20220321 >									
	//        < bW0Y96eW68gamW7oVPzQ8rs6hw4M0P6M7opX29Lj3NG2zafV9Otb610817q62371 >									
	//        <  u =="0.000000000000000001" : ] 000000539467447.115573000000000000 ; 000000553818756.114362000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000337297934D0F74 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_39_____PHARMACORE_Co_Limited_20220321 >									
	//        < f9d9HoyJ4EDkVa9AM7IQ8TBvX1Q5wqdS71qPnfBexpsRrzMXoueOE307e7y58mJI >									
	//        <  u =="0.000000000000000001" : ] 000000553818756.114362000000000000 ; 000000566666449.343251000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034D0F74360AA15 >									
	//     < CHEMCHINA_PFIV_I_metadata_line_40_____Pharmasi_Chemicals_Company_Limited_20220321 >									
	//        < 9vM1qr7XzwmUNWi3aoS9pTg4KzM4YFql1UorzOfoseLIPBx6cOo7Q0v5qQYx9Bw4 >									
	//        <  u =="0.000000000000000001" : ] 000000566666449.343251000000000000 ; 000000582378823.553285000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000360AA15378A3BA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
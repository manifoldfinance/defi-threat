/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFV_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFV_III_883		"	;
		string	public		symbol =	"	SHERE_PFV_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		2180230364645770000000000000					;	
										
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
	//     < SHERE_PFV_III_metadata_line_1_____AEROFLOT_20260505 >									
	//        < Ro3R1q75P67nG1gIJaTYAc7k6Ka87002DcfkE9bLih7oQeNc8tX5Yjt2y7PT9183 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000022510352.379132400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000022591B >									
	//     < SHERE_PFV_III_metadata_line_2_____AEROFLOT_ORG_20260505 >									
	//        < 53Z6s3rZQ9z1z5Wy1F8MXj02sv3cZC5S3V5kEt2seIL83vq8869aQ099fP8NYpY2 >									
	//        <  u =="0.000000000000000001" : ] 000000022510352.379132400000000000 ; 000000093918896.472936900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000022591B8F4F12 >									
	//     < SHERE_PFV_III_metadata_line_3_____AURORA_20260505 >									
	//        < Aznx4MUhuqw03UeLnnXVaC8YTqv7DHwi277REU5JnD8b7sqK59RG6VJujlHs4o5S >									
	//        <  u =="0.000000000000000001" : ] 000000093918896.472936900000000000 ; 000000135891472.035204000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008F4F12CF5A9B >									
	//     < SHERE_PFV_III_metadata_line_4_____AURORA_ORG_20260505 >									
	//        < IqEi1x81YdLGsMZ548Ex9L4OBjbFx6cuvWNF1n0T87Ezl474aIrC8jn95QU9SAVK >									
	//        <  u =="0.000000000000000001" : ] 000000135891472.035204000000000000 ; 000000173757927.690071000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000CF5A9B1092231 >									
	//     < SHERE_PFV_III_metadata_line_5_____RUSSIA _20260505 >									
	//        < o197Sz5PKayhuYC4Ef9j7a08m9N3ZvYt7NX6YDFB8NIZH81XzXS516KeV07EGTte >									
	//        <  u =="0.000000000000000001" : ] 000000173757927.690071000000000000 ; 000000211634761.397782000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001092231142EDD4 >									
	//     < SHERE_PFV_III_metadata_line_6_____RUSSIA _ORG_20260505 >									
	//        < 9EE08J3R2IG36PEfX16txs57tWxAWeaVaM1l4jCsRs42yGSxE8i1a728f2MTpIFp >									
	//        <  u =="0.000000000000000001" : ] 000000211634761.397782000000000000 ; 000000233277490.998442000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000142EDD4163F405 >									
	//     < SHERE_PFV_III_metadata_line_7_____VICTORIA_20260505 >									
	//        < A7w9vr2q9r4kc8PD4nqOYl2yOSqtg33J68JbCnPc6q6WV3VvFURbwh1USZsVz2dr >									
	//        <  u =="0.000000000000000001" : ] 000000233277490.998442000000000000 ; 000000270422232.235415000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000163F40519CA1AF >									
	//     < SHERE_PFV_III_metadata_line_8_____VICTORIA_ORG_20260505 >									
	//        < wYDft67SO9b2Aw6cRHDpo92mo9tG14wrIzPjnlU56eNCt36C1YC2J356MT226Mn1 >									
	//        <  u =="0.000000000000000001" : ] 000000270422232.235415000000000000 ; 000000290848397.443690000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019CA1AF1BBCCA8 >									
	//     < SHERE_PFV_III_metadata_line_9_____DOBROLET_20260505 >									
	//        < mo70Ny0M4e7Zyr10K90LuuiZsM8WtjDD6Sy9670a25Y8W9G2orD04DqQ604CJ65p >									
	//        <  u =="0.000000000000000001" : ] 000000290848397.443690000000000000 ; 000000373616188.106494000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BBCCA823A17D3 >									
	//     < SHERE_PFV_III_metadata_line_10_____DOBROLET_ORG_20260505 >									
	//        < 082f9wKz0EVuDQ1uZ0zVQ2QviJ3k5262Jrc0BL13T6eNr0bmhFeNi4YbLYCc9Z0l >									
	//        <  u =="0.000000000000000001" : ] 000000373616188.106494000000000000 ; 000000417679012.380924000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023A17D327D53DD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFV_III_metadata_line_11_____AEROFLOT_RUSSIAN_AIRLINES_20260505 >									
	//        < BfEX2E99XJz0Ni5AZu153O1e1rBnh0Rlbp8Fcm4fpd1078b6HIIX5N237wk4MxJo >									
	//        <  u =="0.000000000000000001" : ] 000000417679012.380924000000000000 ; 000000489640194.340117000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027D53DD2EB21B3 >									
	//     < SHERE_PFV_III_metadata_line_12_____AEROFLOT_RUSSIAN_AIRLINES_ORG_20260505 >									
	//        < PDI2j39cvr3vJG48tjY72gg2TfYrPSvFhi1tcmVb5WOHw8xPD771OX3HyS30642s >									
	//        <  u =="0.000000000000000001" : ] 000000489640194.340117000000000000 ; 000000568572650.793115000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EB21B336392B1 >									
	//     < SHERE_PFV_III_metadata_line_13_____OTDELSTROY_INVEST_20260505 >									
	//        < xAnod6Qv62zQbi8HIk5x6b1n6wcEUyXBuYTq0JZqVcmCTPc0t4XUI2c533loaal5 >									
	//        <  u =="0.000000000000000001" : ] 000000568572650.793115000000000000 ; 000000663635062.541374000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036392B13F4A072 >									
	//     < SHERE_PFV_III_metadata_line_14_____OTDELSTROY_INVEST_ORG_20260505 >									
	//        < a9OEQCpH7dw56hoCG1MSEX1OS8L8XyXuH2m4VH841aEvujVU97So098iXd9p5u7a >									
	//        <  u =="0.000000000000000001" : ] 000000663635062.541374000000000000 ; 000000683064184.641016000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F4A07241245F2 >									
	//     < SHERE_PFV_III_metadata_line_15_____POBEDA_AIRLINES_20260505 >									
	//        < Tqs62VyW6a15X8OoU5phPwkh70YU82g1mf9f9f583Jc1Sbaf8C930Vld5q4dD5zs >									
	//        <  u =="0.000000000000000001" : ] 000000683064184.641016000000000000 ; 000000701682589.867595000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041245F242EAEC3 >									
	//     < SHERE_PFV_III_metadata_line_16_____POBEDA_AIRLINES_ORG_20260505 >									
	//        < lDL33lM0qMN15tRQZa9zL596Pyb4fUZRug2dV8a4JRJ8N20tNz7UnsQW60AG055H >									
	//        <  u =="0.000000000000000001" : ] 000000701682589.867595000000000000 ; 000000724016270.426867000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042EAEC3450C2DB >									
	//     < SHERE_PFV_III_metadata_line_17_____DAROFAN_20260505 >									
	//        < 062IuzZIk2QhJ9zRi1k12eE2I387P6jBWmRhi68VR8NXe8p2tQPkPSV8VwZTm4O4 >									
	//        <  u =="0.000000000000000001" : ] 000000724016270.426867000000000000 ; 000000793056571.086909000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000450C2DB4BA1BB9 >									
	//     < SHERE_PFV_III_metadata_line_18_____DAROFAN_ORG_20260505 >									
	//        < MhihHU435vTHzwwogcDfakShpgf6Owz67D7dyQfZJ8F1j9feXiXP2DWIiDwXLwHP >									
	//        <  u =="0.000000000000000001" : ] 000000793056571.086909000000000000 ; 000000851135876.800447000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BA1BB9512BAF4 >									
	//     < SHERE_PFV_III_metadata_line_19_____TERMINAL_20260505 >									
	//        < 0T03d5r9BBZ05BNRK4gLsL3Qu5hTcXt5555B2dcOyEHg5x8YmKywHRsr7oWz2c9k >									
	//        <  u =="0.000000000000000001" : ] 000000851135876.800447000000000000 ; 000000937055459.328835000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000512BAF4595D54A >									
	//     < SHERE_PFV_III_metadata_line_20_____TERMINAL_ORG_20260505 >									
	//        < GPHD4o798Z8rhytzXiarm6BTfD92tAN4M9K2v7NIYVfMu2gLN2Ry97lc0IXXs7DD >									
	//        <  u =="0.000000000000000001" : ] 000000937055459.328835000000000000 ; 000001031488769.396060000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000595D54A625ED4D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFV_III_metadata_line_21_____AEROFLOT_FINANCE_20260505 >									
	//        < 9N2u2ApWiTg9d92qSf5817Rh5KbOQ2WhQFE6gl6u13ljx648j31m5TyPEd2LRS86 >									
	//        <  u =="0.000000000000000001" : ] 000001031488769.396060000000000000 ; 000001096635491.922850000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000625ED4D689553D >									
	//     < SHERE_PFV_III_metadata_line_22_____AEROFLOT_FINANCE_ORG_20260505 >									
	//        < v3h59MLT37985NNEOjF5o02j9WO9kIxndT54kTCnF975P6w98E26Za0sqiC5OwDB >									
	//        <  u =="0.000000000000000001" : ] 000001096635491.922850000000000000 ; 000001130130053.662150000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000689553D6BC710D >									
	//     < SHERE_PFV_III_metadata_line_23_____SHEROTEL_20260505 >									
	//        < vPw8p044UuyaK5Mnn7b65i83oSeLz0oAqkPN7GTEINkk8CVd8Gsr381Bgw8YEuim >									
	//        <  u =="0.000000000000000001" : ] 000001130130053.662150000000000000 ; 000001163330701.288890000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006BC710D6EF1A0E >									
	//     < SHERE_PFV_III_metadata_line_24_____SHEROTEL_ORG_20260505 >									
	//        < 9Oww1fRDBFYzaB1q4rlmPNIPOk202Zv7WY5FhJwmq9wYup8PRnazKIYyCCJjY2Pa >									
	//        <  u =="0.000000000000000001" : ] 000001163330701.288890000000000000 ; 000001185900234.224180000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006EF1A0E7118A47 >									
	//     < SHERE_PFV_III_metadata_line_25_____DALAVIA_KHABAROVSK_20260505 >									
	//        < 0IUfLv88hh0qT4qRX9FDBUQ2dmZjp260miCbagjhM3Iv3JnqbMLnlivAyeR2Gw7T >									
	//        <  u =="0.000000000000000001" : ] 000001185900234.224180000000000000 ; 000001258226164.001290000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007118A4777FE698 >									
	//     < SHERE_PFV_III_metadata_line_26_____DALAVIA_KHABAROVSK_ORG_20260505 >									
	//        < tyg9DC27UBI5MBvPuw93flIUhw99gg77xSzvpaRFI542OxA42t9FSpOTw766djlE >									
	//        <  u =="0.000000000000000001" : ] 000001258226164.001290000000000000 ; 000001289861647.674410000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000077FE6987B02C35 >									
	//     < SHERE_PFV_III_metadata_line_27_____AEROFLOT_AVIATION_SCHOOL_20260505 >									
	//        < dHJlwuRL524iEl1Rlrn207tpVvEkR6ZqVWnlfc8TIti5j0QwoV7A4d772TQVIyTl >									
	//        <  u =="0.000000000000000001" : ] 000001289861647.674410000000000000 ; 000001338920151.563370000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007B02C357FB07AF >									
	//     < SHERE_PFV_III_metadata_line_28_____AEROFLOT_AVIATION_SCHOOL_ORG_20260505 >									
	//        < G7qWz5b29I680BjbikHUk89fQ2qVu86y6Z0woN351z92b3Drlw1yt68L7iw6e6bE >									
	//        <  u =="0.000000000000000001" : ] 000001338920151.563370000000000000 ; 000001418033719.106940000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007FB07AF873BF6C >									
	//     < SHERE_PFV_III_metadata_line_29_____A_TECHNICS_20260505 >									
	//        < ErclExcA3ELf9bszGiJrkplytS1Ku9o0WhT5k1k53hQ68wWdP5Yr8oT7uaFjbjkA >									
	//        <  u =="0.000000000000000001" : ] 000001418033719.106940000000000000 ; 000001479431735.454200000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000873BF6C8D16F06 >									
	//     < SHERE_PFV_III_metadata_line_30_____A_TECHNICS_ORG_20260505 >									
	//        < 179d0g91ji60f5ut86E7F0F1lE1Z3GT489eAF7Lg0cMFm9ytN7oILjx7Hsm20N2b >									
	//        <  u =="0.000000000000000001" : ] 000001479431735.454200000000000000 ; 000001562785224.777300000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008D16F069509EFA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFV_III_metadata_line_31_____AEROMAR_20260505 >									
	//        < uCZ0jOjq3vFK6ZHO7CSqWOO8cJBz4jy71596mjCZ19B3270W0La33ql4PY666EnT >									
	//        <  u =="0.000000000000000001" : ] 000001562785224.777300000000000000 ; 000001658088142.550230000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009509EFA9E20AAE >									
	//     < SHERE_PFV_III_metadata_line_32_____AEROMAR_ORG_20260505 >									
	//        < 1hEa1xv01P3VrBC169e28J4HFX9vKk2cHQ67jhJ7s1zDiA82uW8o745sN9A3gEa0 >									
	//        <  u =="0.000000000000000001" : ] 000001658088142.550230000000000000 ; 000001742184709.360960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009E20AAEA625CE7 >									
	//     < SHERE_PFV_III_metadata_line_33_____BUDGET_CARRIER_20260505 >									
	//        < LaJ360ckGAEC34u9rP7CFR00aS2257bIK73ypV4vWm45Rl3S9LfEj73PzVQIa4t0 >									
	//        <  u =="0.000000000000000001" : ] 000001742184709.360960000000000000 ; 000001773856045.346690000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A625CE7A92B085 >									
	//     < SHERE_PFV_III_metadata_line_34_____BUDGET_CARRIER_ORG_20260505 >									
	//        < 57xMp3H3K71766C4jbw8oNfE4Mz1s1Uk4o4oJuygu4Ndj2km2Mt5041xlU21X310 >									
	//        <  u =="0.000000000000000001" : ] 000001773856045.346690000000000000 ; 000001804878702.967550000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A92B085AC206BE >									
	//     < SHERE_PFV_III_metadata_line_35_____NATUSANA_20260505 >									
	//        < x0yWpB0C8Owo8kP0S6J282GGFTcNewZ73Z05DKW02484Ng834271g39g2ptnrBm9 >									
	//        <  u =="0.000000000000000001" : ] 000001804878702.967550000000000000 ; 000001862734051.880670000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000AC206BEB1A4E7D >									
	//     < SHERE_PFV_III_metadata_line_36_____NATUSANA_ORG_20260505 >									
	//        < 7xjM4lhmhJ8z1g6heTBy08Kk46GuyF4ebbCyu3A77nA4c4HG5kPUskJuSzKeu46M >									
	//        <  u =="0.000000000000000001" : ] 000001862734051.880670000000000000 ; 000001955223409.232720000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B1A4E7DBA76F25 >									
	//     < SHERE_PFV_III_metadata_line_37_____AEROFLOT_PENSIONS_20260505 >									
	//        < v6b5V3ZbG6Ay7ciaO648yDDG09Be50838E8RnCcHmo92838jGvrkjhC7D6y789UW >									
	//        <  u =="0.000000000000000001" : ] 000001955223409.232720000000000000 ; 000001985566610.038620000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000BA76F25BD5BBF5 >									
	//     < SHERE_PFV_III_metadata_line_38_____AEROFLOT_MUTU_20260505 >									
	//        < SpU5zm598nLFMqis0aER0b0Bq2PCC21zC38YQgJX7Jm6n5vW7ziwg1xEMOzxyJr5 >									
	//        <  u =="0.000000000000000001" : ] 000001985566610.038620000000000000 ; 000002040627338.794850000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000BD5BBF5C29C00E >									
	//     < SHERE_PFV_III_metadata_line_39_____AEROFLOT_CAPITAL_20260505 >									
	//        < CLPc0YY8r5Ecqag6oOltmGA2vde1lV0WEFhG2NkTM0T2Gx5m9QVFzrKSszM5vnZU >									
	//        <  u =="0.000000000000000001" : ] 000002040627338.794850000000000000 ; 000002104779766.573850000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C29C00EC8BA399 >									
	//     < SHERE_PFV_III_metadata_line_40_____AEROFLOT_HOLDINGS_20260505 >									
	//        < QBHxdm388QdQhOS31wALsfq6Bb7z1vq5DlCWf5rWt98Ja2rZar821PYu7raJsgHy >									
	//        <  u =="0.000000000000000001" : ] 000002104779766.573850000000000000 ; 000002180230364.645770000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000C8BA399CFEC47C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
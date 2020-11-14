/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFV_II_883		"	;
		string	public		symbol =	"	SHERE_PFV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1224678853849720000000000000					;	
										
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
	//     < SHERE_PFV_II_metadata_line_1_____AEROFLOT_20240505 >									
	//        < KCh954kuwbXD1EgVO2h744bGkK6eUP6z0zizKeYTAOdcuCIV5Z9cVsN6yRUq6NiK >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000045430588.864348200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000455253 >									
	//     < SHERE_PFV_II_metadata_line_2_____AEROFLOT_ORG_20240505 >									
	//        < 5Ps080d2z8H1Tt3Y79a48anwCXfYTEU2jd9GsWELn5E9Zn8a2ZQ360SQeS7HQX6m >									
	//        <  u =="0.000000000000000001" : ] 000000045430588.864348200000000000 ; 000000088010033.066337700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000455253864AEB >									
	//     < SHERE_PFV_II_metadata_line_3_____AURORA_20240505 >									
	//        < ri7pP5e86B0M7eOgRqO8JX7DCqKA1D54S0zl0WQ732FkPp1D4BQ7ymqi91onMi4B >									
	//        <  u =="0.000000000000000001" : ] 000000088010033.066337700000000000 ; 000000109662046.904612000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000864AEBA754BD >									
	//     < SHERE_PFV_II_metadata_line_4_____AURORA_ORG_20240505 >									
	//        < Kz1qj89Gomu6xx4pzQSTWtcY1F6071VygzkBWSzTQ7bf61ABG9Lb2JF3Xre7s3oQ >									
	//        <  u =="0.000000000000000001" : ] 000000109662046.904612000000000000 ; 000000148057672.478141000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A754BDE1EB07 >									
	//     < SHERE_PFV_II_metadata_line_5_____RUSSIA _20240505 >									
	//        < wmwDr88MaIHO24kQoHiCMymoaRdwW98BV144J4Ap11J5Jd0HJ7sTI2QRXwe18TLx >									
	//        <  u =="0.000000000000000001" : ] 000000148057672.478141000000000000 ; 000000181473010.635004000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E1EB07114E7E5 >									
	//     < SHERE_PFV_II_metadata_line_6_____RUSSIA _ORG_20240505 >									
	//        < dqA7M8di8D8s4RvNr78jNKymY81711WmTIA5uopS2a8NQbwfft53cOIW03c3gDF4 >									
	//        <  u =="0.000000000000000001" : ] 000000181473010.635004000000000000 ; 000000206632643.228198000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000114E7E513B4BE0 >									
	//     < SHERE_PFV_II_metadata_line_7_____VICTORIA_20240505 >									
	//        < ab5oekSq8H0Dw94X3I9jRrYi46Y0Y6pN91QGy031vi6V2hxvDcE4kyX19NiC9nAp >									
	//        <  u =="0.000000000000000001" : ] 000000206632643.228198000000000000 ; 000000232444083.804062000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013B4BE0162AE78 >									
	//     < SHERE_PFV_II_metadata_line_8_____VICTORIA_ORG_20240505 >									
	//        < R1Tuc0nqcuQXSy8in7EFkw98xmr13B75Ld9vECiUvuy8azqvDySg8C876T58M1yo >									
	//        <  u =="0.000000000000000001" : ] 000000232444083.804062000000000000 ; 000000269023575.886126000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000162AE7819A7F56 >									
	//     < SHERE_PFV_II_metadata_line_9_____DOBROLET_20240505 >									
	//        < 8VCO434r70ml9SVY7w906Q56bg0z5z296esy80ZMY2IS1pg6yISTtQZ5vuF48759 >									
	//        <  u =="0.000000000000000001" : ] 000000269023575.886126000000000000 ; 000000311858219.828827000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019A7F561DBDB9E >									
	//     < SHERE_PFV_II_metadata_line_10_____DOBROLET_ORG_20240505 >									
	//        < I095WNl28VM02ghXlECE1E9HH09ytbPq2TEylECgvmV4Rq340BAAZlnPauEvLt27 >									
	//        <  u =="0.000000000000000001" : ] 000000311858219.828827000000000000 ; 000000343002350.663919000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DBDB9E20B614B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFV_II_metadata_line_11_____AEROFLOT_RUSSIAN_AIRLINES_20240505 >									
	//        < a0KosYbbrz3tJ45769EltBGyNDMn614Q30Se5rO4Br4p131C9w8tJjkhEGcCL5cR >									
	//        <  u =="0.000000000000000001" : ] 000000343002350.663919000000000000 ; 000000369469074.983487000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020B614B233C3DB >									
	//     < SHERE_PFV_II_metadata_line_12_____AEROFLOT_RUSSIAN_AIRLINES_ORG_20240505 >									
	//        < i9iLlZLPjTpHN26uMPG96555uzbFEVOu40yyNzm1QlhQ9Wi4PUp9q5eA4Ou73I1C >									
	//        <  u =="0.000000000000000001" : ] 000000369469074.983487000000000000 ; 000000393487355.344285000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000233C3DB2586A00 >									
	//     < SHERE_PFV_II_metadata_line_13_____OTDELSTROY_INVEST_20240505 >									
	//        < sh8P9vZ77oRGQP5dd2w5r2f3E82EtFwvO1ceUP9eq6IG572pg7FpcYd28I5U5H7x >									
	//        <  u =="0.000000000000000001" : ] 000000393487355.344285000000000000 ; 000000411229173.058322000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002586A002737C65 >									
	//     < SHERE_PFV_II_metadata_line_14_____OTDELSTROY_INVEST_ORG_20240505 >									
	//        < ah1ZNxnrMmc7gCSzF93mFs1StFV5Jqo3ICRs0O5l2X77Z391pBtGwwm72Iz75M23 >									
	//        <  u =="0.000000000000000001" : ] 000000411229173.058322000000000000 ; 000000439953338.365687000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002737C6529F50C6 >									
	//     < SHERE_PFV_II_metadata_line_15_____POBEDA_AIRLINES_20240505 >									
	//        < 12tTe92ijYtyN4d9bW9D9H066y1djVxXbW3Z610YGl078wVk52d3Wt4gqG48Ub3j >									
	//        <  u =="0.000000000000000001" : ] 000000439953338.365687000000000000 ; 000000458017037.647362000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029F50C62BAE0E8 >									
	//     < SHERE_PFV_II_metadata_line_16_____POBEDA_AIRLINES_ORG_20240505 >									
	//        < Jn06y11K8eS3d8luXHu11J4ID13doZ4Re4km2hr82fYXW3gIG01249929DvhoZjW >									
	//        <  u =="0.000000000000000001" : ] 000000458017037.647362000000000000 ; 000000495465345.143929000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BAE0E82F40527 >									
	//     < SHERE_PFV_II_metadata_line_17_____DAROFAN_20240505 >									
	//        < 9SrT99eg6VgqApY2EdrWy7Wb0m3TzcrGUwc87tUmvNT5qm8XA0h7Y9Cx2GZDkrqD >									
	//        <  u =="0.000000000000000001" : ] 000000495465345.143929000000000000 ; 000000544358136.334661000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F4052733E9FE6 >									
	//     < SHERE_PFV_II_metadata_line_18_____DAROFAN_ORG_20240505 >									
	//        < 7lsLMi5A6MRqx7ETvA92mXp6dj8aQFxQi5sukW6t2oV8C85OA38CELFtEuk176XW >									
	//        <  u =="0.000000000000000001" : ] 000000544358136.334661000000000000 ; 000000566780737.815768000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033E9FE6360D6BA >									
	//     < SHERE_PFV_II_metadata_line_19_____TERMINAL_20240505 >									
	//        < 7v5X9djruCNApTbP7KQYdFNeC8BQWl7GZSak9Ov6a2IwP2Vj56by067XDOu2p0gQ >									
	//        <  u =="0.000000000000000001" : ] 000000566780737.815768000000000000 ; 000000594497683.684072000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000360D6BA38B21A8 >									
	//     < SHERE_PFV_II_metadata_line_20_____TERMINAL_ORG_20240505 >									
	//        < 10T74xP9RN1rhp77e74A7T7vWnK5Porz8E36YCu7rkL97rhv4phZMV460v7KVSYr >									
	//        <  u =="0.000000000000000001" : ] 000000594497683.684072000000000000 ; 000000611289837.729700000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038B21A83A4C118 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFV_II_metadata_line_21_____AEROFLOT_FINANCE_20240505 >									
	//        < 07ji7t04ODw30eFurV2tCFDtYcAqu2YLV6Y4bcJ3MxX1f8U8Hm39iHEQn6tQ6ZRx >									
	//        <  u =="0.000000000000000001" : ] 000000611289837.729700000000000000 ; 000000643138020.154189000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A4C1183D559CA >									
	//     < SHERE_PFV_II_metadata_line_22_____AEROFLOT_FINANCE_ORG_20240505 >									
	//        < 157JJ44v75H6fh51vL88DT26J6V85R0IRz1Kio3E012Xr05uXeTcn6ZkHG7URx0A >									
	//        <  u =="0.000000000000000001" : ] 000000643138020.154189000000000000 ; 000000662420349.253619000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D559CA3F2C5F3 >									
	//     < SHERE_PFV_II_metadata_line_23_____SHEROTEL_20240505 >									
	//        < PVdR4DIunJZhkM58rMDjy9G6L352cy24Y0V8COqhsfFPhL0rVUoC4jmf7eQ61n67 >									
	//        <  u =="0.000000000000000001" : ] 000000662420349.253619000000000000 ; 000000688068615.712313000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F2C5F3419E8CE >									
	//     < SHERE_PFV_II_metadata_line_24_____SHEROTEL_ORG_20240505 >									
	//        < 5OR993Ad5j32m8Y5R9D7232C4u9YHnt36IGY57jf4jDCYA4g80mGi0G15xixasUX >									
	//        <  u =="0.000000000000000001" : ] 000000688068615.712313000000000000 ; 000000710136459.357915000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000419E8CE43B950E >									
	//     < SHERE_PFV_II_metadata_line_25_____DALAVIA_KHABAROVSK_20240505 >									
	//        < N8ubUKC46s5IHcUnpEALR4waEQ1C63r5FGm8gqlAm4LCJ8javPTzwx8lVZ4KView >									
	//        <  u =="0.000000000000000001" : ] 000000710136459.357915000000000000 ; 000000758346836.887476000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043B950E485253C >									
	//     < SHERE_PFV_II_metadata_line_26_____DALAVIA_KHABAROVSK_ORG_20240505 >									
	//        < 7HQuxYNf6GEXpj8l0p1ta8Oy6Sy35nGdkt1rRAbrcAyFDZ8N2wiV827j0AOJ39z4 >									
	//        <  u =="0.000000000000000001" : ] 000000758346836.887476000000000000 ; 000000788731590.220372000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000485253C4B38247 >									
	//     < SHERE_PFV_II_metadata_line_27_____AEROFLOT_AVIATION_SCHOOL_20240505 >									
	//        < 1M37i89q915N9l6Xu8F6U6Pl3esk0LVVmQc1QrOWuOC16055b0XL1uhx9051X0Wp >									
	//        <  u =="0.000000000000000001" : ] 000000788731590.220372000000000000 ; 000000834958885.991526000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B382474FA0BD1 >									
	//     < SHERE_PFV_II_metadata_line_28_____AEROFLOT_AVIATION_SCHOOL_ORG_20240505 >									
	//        < hCyxs5G412So0X31qc216jn07vmahh8X28w5NnIjGa0Zr0y6pH82Dix02QetcE2s >									
	//        <  u =="0.000000000000000001" : ] 000000834958885.991526000000000000 ; 000000879910363.367961000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004FA0BD153EA2FC >									
	//     < SHERE_PFV_II_metadata_line_29_____A_TECHNICS_20240505 >									
	//        < IWDd0o12OEFc277Y90lIjSiNAi7Cq8N5b8RJJbM1YA2i96o4ehx6qJ6y62jw8NPL >									
	//        <  u =="0.000000000000000001" : ] 000000879910363.367961000000000000 ; 000000926776109.154482000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000053EA2FC58625EB >									
	//     < SHERE_PFV_II_metadata_line_30_____A_TECHNICS_ORG_20240505 >									
	//        < 38Dz9Vqye81S18L3V6W1r3CuSQmfSNM8qBA73kxR5uobyJ7yBZZ3y2JxR1aJIDYS >									
	//        <  u =="0.000000000000000001" : ] 000000926776109.154482000000000000 ; 000000969034922.155496000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058625EB5C6A144 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFV_II_metadata_line_31_____AEROMAR_20240505 >									
	//        < N2ossY20KG1DU49r0qbm84vq3ITlQ0o7YycfhS8wD9BQFNrZg5z51OeS599gx1Q4 >									
	//        <  u =="0.000000000000000001" : ] 000000969034922.155496000000000000 ; 000000990427630.725584000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C6A1445E745CB >									
	//     < SHERE_PFV_II_metadata_line_32_____AEROMAR_ORG_20240505 >									
	//        < aN1R96P0lcHB4W0elGLjgQd222Gu3GzOzrd7Qgwl1J96pd3qfaAe8ooAr3ZzY4FD >									
	//        <  u =="0.000000000000000001" : ] 000000990427630.725584000000000000 ; 000001020729473.824740000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E745CB6158273 >									
	//     < SHERE_PFV_II_metadata_line_33_____BUDGET_CARRIER_20240505 >									
	//        < gN299321xIQ9HN2jF8AD13kyw9ITkAuF7I9Tv0nrma8fa1Rs08bs7Ax246qG2CQJ >									
	//        <  u =="0.000000000000000001" : ] 000001020729473.824740000000000000 ; 000001056029386.357780000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000615827364B5F7B >									
	//     < SHERE_PFV_II_metadata_line_34_____BUDGET_CARRIER_ORG_20240505 >									
	//        < QsAJq24Xmq4HXgyTF0q6OQg3x5AINfKHb1V6PofWRBdbD7d0Cg0t620TQbh1DO16 >									
	//        <  u =="0.000000000000000001" : ] 000001056029386.357780000000000000 ; 000001072789505.150670000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000064B5F7B664F267 >									
	//     < SHERE_PFV_II_metadata_line_35_____NATUSANA_20240505 >									
	//        < N46qA87n48Qv9IkA78PYg0DX3O8ET9460JO8snKchVza87zmce3Dupbu0x0l2gzm >									
	//        <  u =="0.000000000000000001" : ] 000001072789505.150670000000000000 ; 000001112623002.602250000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000664F2676A1BA5C >									
	//     < SHERE_PFV_II_metadata_line_36_____NATUSANA_ORG_20240505 >									
	//        < j90TnqE9vp3F0D7Z8a867yeX0W7dK97PQdc6Jl8IE7XAvw2Nw2C32B4t5nIZxj7h >									
	//        <  u =="0.000000000000000001" : ] 000001112623002.602250000000000000 ; 000001142540396.551030000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006A1BA5C6CF60D8 >									
	//     < SHERE_PFV_II_metadata_line_37_____AEROFLOT_PENSIONS_20240505 >									
	//        < D1m84vx27Z97CGY69WeI5B018B8i2r69TB7oCLE2xmoP8d0NZ8PPN79Fb8O1S5la >									
	//        <  u =="0.000000000000000001" : ] 000001142540396.551030000000000000 ; 000001160616144.550330000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006CF60D86EAF5AE >									
	//     < SHERE_PFV_II_metadata_line_38_____AEROFLOT_MUTU_20240505 >									
	//        < z2R8YwZvy6RBdwMqe3X4dx5i03WyM6YGlBP245g38fDOaPvkCL7Kx9c8MzKwDV3H >									
	//        <  u =="0.000000000000000001" : ] 000001160616144.550330000000000000 ; 000001184876919.723560000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006EAF5AE70FFA8C >									
	//     < SHERE_PFV_II_metadata_line_39_____AEROFLOT_CAPITAL_20240505 >									
	//        < PzIz4Px8EA5I4n2JusDAmz4cwT7DLQ0Dz2M8vHw30h45PIS7rFF8sNm08xvts24e >									
	//        <  u =="0.000000000000000001" : ] 000001184876919.723560000000000000 ; 000001204109851.429820000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000070FFA8C72D5369 >									
	//     < SHERE_PFV_II_metadata_line_40_____AEROFLOT_HOLDINGS_20240505 >									
	//        < J099KUE1n23MGK314TPjNOcsCza68EPXp0H5MB7kPjUUO4vG9b70MMlxmAja3Fsu >									
	//        <  u =="0.000000000000000001" : ] 000001204109851.429820000000000000 ; 000001224678853.849720000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000072D536974CB62D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
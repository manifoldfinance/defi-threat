/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFIV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFIV_I_883		"	;
		string	public		symbol =	"	SHERE_PFIV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		772344232462985000000000000					;	
										
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
	//     < SHERE_PFIV_I_metadata_line_1_____SHEREMETYEVO_AIRPORT_20220505 >									
	//        < hxmhYYPla6ye3ocHYyZRme8o40IW8Kp305JO02qea3nCIRP84c6mX5HzVVP0HuvF >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015459826.421490300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001796FF >									
	//     < SHERE_PFIV_I_metadata_line_2_____SHEREMETYEVO_INTERNATIONAL_AIRPORT_20220505 >									
	//        < Did5IhdbLDCn17tp74D2i8wN4E1j1m1buq1v08KmpfI1vF4ui9KLi85Ldy2JO16o >									
	//        <  u =="0.000000000000000001" : ] 000000015459826.421490300000000000 ; 000000029508638.660921700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001796FF2D06D0 >									
	//     < SHERE_PFIV_I_metadata_line_3_____SHEREMETYEVO_HOLDING_LLC_20220505 >									
	//        < plguCfltiS843d449plyJg3LOhXFR6S1yJXDgki5puP2G7oDAsqyv11MtecWN8QA >									
	//        <  u =="0.000000000000000001" : ] 000000029508638.660921700000000000 ; 000000048221141.038157600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002D06D0499462 >									
	//     < SHERE_PFIV_I_metadata_line_4_____TPS_AVIA_PONOMARENKO_ORG_20220505 >									
	//        < 9rOsnb4YbP5PnMBt8P5jb22gnG055Z2wa70Gx063az6vLh1kC4764ghG50FlJmOh >									
	//        <  u =="0.000000000000000001" : ] 000000048221141.038157600000000000 ; 000000064282628.347680000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000499462621667 >									
	//     < SHERE_PFIV_I_metadata_line_5_____TPS_AVIA_SKOROBOGATKO_ORG_20220505 >									
	//        < a0muH5q49YKF6lVH628yDzbzWhicOuhPcP3smyhpDFV83V68pq76v03n2XKDqvYR >									
	//        <  u =="0.000000000000000001" : ] 000000064282628.347680000000000000 ; 000000083555357.737330700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006216677F7ED0 >									
	//     < SHERE_PFIV_I_metadata_line_6_____TPS_AVIA_ROTENBERG_ORG_20220505 >									
	//        < 69qi2G0V6L473S7oL2y1Io5L0ZCIfsBaz67l04935D5h78f3kEABuWw4vF6CZGyt >									
	//        <  u =="0.000000000000000001" : ] 000000083555357.737330700000000000 ; 000000104994320.948579000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007F7ED0A03568 >									
	//     < SHERE_PFIV_I_metadata_line_7_____ROSIMUSHCHESTVO_20220505 >									
	//        < EdWh1NjVnUG89B916minQlPUbYx85oXJMf1DSPSFkGd8n0pg17Ka017rZH0TXq58 >									
	//        <  u =="0.000000000000000001" : ] 000000104994320.948579000000000000 ; 000000120674010.117540000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A03568B82249 >									
	//     < SHERE_PFIV_I_metadata_line_8_____VEB_CAPITAL_LLC_20220505 >									
	//        < 29Z886zD9to4Ifpu0q0jv1h5HL7oT65i742O8Dw39Ni8813ZN13Q5diF5PGp8VIq >									
	//        <  u =="0.000000000000000001" : ] 000000120674010.117540000000000000 ; 000000143397821.616526000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B82249DACEC6 >									
	//     < SHERE_PFIV_I_metadata_line_9_____FRAPORT_20220505 >									
	//        < c2bKhbZe7bCb1lW889drS7E0k6E6oXxK3d128D64e3V0jz4s2VE0MKl6N82Ko5Ff >									
	//        <  u =="0.000000000000000001" : ] 000000143397821.616526000000000000 ; 000000163486666.986294000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DACEC6F975FB >									
	//     < SHERE_PFIV_I_metadata_line_10_____CHANGI_20220505 >									
	//        < Rjewn641dB3z40U7i4hR3gz6i6SF8GJw8aeS8c1YJByFaE8E3p1Di6GlhG1MNt8o >									
	//        <  u =="0.000000000000000001" : ] 000000163486666.986294000000000000 ; 000000180031864.355861000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F975FB112B4F2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIV_I_metadata_line_11_____NORTHERN_CAPITAL_GATEWAY_20220505 >									
	//        < bCq8qSUM1jMtmue76Jp535f8vjCIhI47nN7yP6i0FM7rpVewEt0V3GMQ1xmeeXNv >									
	//        <  u =="0.000000000000000001" : ] 000000180031864.355861000000000000 ; 000000195663939.170242000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000112B4F212A8F3A >									
	//     < SHERE_PFIV_I_metadata_line_12_____BASEL_AERO_20220505 >									
	//        < hMvt53Tki6kaSRN7N4RY42vtUc8DDVc55r7WK1n8tTXh5348cLhwcR5Ain94G3HL >									
	//        <  u =="0.000000000000000001" : ] 000000195663939.170242000000000000 ; 000000221717134.307426000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012A8F3A1525041 >									
	//     < SHERE_PFIV_I_metadata_line_13_____SOGAZ_20220505 >									
	//        < 69GKv3R3I0S8w5ZD98Eq6xkV7OzmO7Voq2827MS5yy5d232pJ4bgY4sf28jJ1Q4E >									
	//        <  u =="0.000000000000000001" : ] 000000221717134.307426000000000000 ; 000000243436174.268722000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015250411737441 >									
	//     < SHERE_PFIV_I_metadata_line_14_____NOVI_SAD_20220505 >									
	//        < y80Hl3HGg3GQ5N4uC351gjRDC1PD3wA1u6BI61Bn5fa88jrBo39fwOi5s8d1OO6P >									
	//        <  u =="0.000000000000000001" : ] 000000243436174.268722000000000000 ; 000000261563094.229608000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000173744118F1D15 >									
	//     < SHERE_PFIV_I_metadata_line_15_____INSURANCE_COMPANY_ALROSA_20220505 >									
	//        < le8mb9J798BPrQP7008oQ7W6K3bLu2S7y609x5C40GcZ31MlPg7zt0f5O197Bkjp >									
	//        <  u =="0.000000000000000001" : ] 000000261563094.229608000000000000 ; 000000287515498.769467000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018F1D151B6B6BE >									
	//     < SHERE_PFIV_I_metadata_line_16_____IC_AL_SO_20220505 >									
	//        < heed4lFllFu3pLGv4Gyn3eow294U8mNw40E09KvyUdgfAoQD31LAeA62I1Y78iHb >									
	//        <  u =="0.000000000000000001" : ] 000000287515498.769467000000000000 ; 000000304779538.693647000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B6B6BE1D10E82 >									
	//     < SHERE_PFIV_I_metadata_line_17_____PIPELINE_INSURANCE_COMPANY_20220505 >									
	//        < R8M9t8VHxj0L708Bg4FD4tB3Z5dc4B1V24mDKh3GriyQXR9vLH4ou5Wv5r146422 >									
	//        <  u =="0.000000000000000001" : ] 000000304779538.693647000000000000 ; 000000324893593.383799000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D10E821EFBF8F >									
	//     < SHERE_PFIV_I_metadata_line_18_____SOGAZ_MED_20220505 >									
	//        < ftwt6zdhue27Zlp0vMif4p2E63uL36uL4p17JP897qQV6Jy7Xxf9HqPybjMo5Vm3 >									
	//        <  u =="0.000000000000000001" : ] 000000324893593.383799000000000000 ; 000000339791069.663990000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EFBF8F2067AE3 >									
	//     < SHERE_PFIV_I_metadata_line_19_____IC_TRANSNEFT_20220505 >									
	//        < niKprF45DvDbfhqxyR6h3SOvjpLa5c1U8ww1nEIdHf5D8USdykCtPZJ60Jxe6sHd >									
	//        <  u =="0.000000000000000001" : ] 000000339791069.663990000000000000 ; 000000355134139.695846000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002067AE321DE446 >									
	//     < SHERE_PFIV_I_metadata_line_20_____SHEKSNA_20220505 >									
	//        < t53p59B662b5830RKHQ6111q622pp4Dih6OR7ACY0hk51V1LMOS63Sg41oY552E9 >									
	//        <  u =="0.000000000000000001" : ] 000000355134139.695846000000000000 ; 000000377616247.211689000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021DE4462403259 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIV_I_metadata_line_21_____Akcionarsko Drustvo Zaosiguranje_20220505 >									
	//        < l694qTwTq494vK305w4058d83860nVVJps5SdWfK0Y1CzQ178GTZc9Qjr533o9dl >									
	//        <  u =="0.000000000000000001" : ] 000000377616247.211689000000000000 ; 000000402532954.137969000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002403259266376F >									
	//     < SHERE_PFIV_I_metadata_line_22_____SOGAZ_LIFE_20220505 >									
	//        < f87cSls2CW8e6yWFeigk8A60QlqoIlk9DBS9wArBV1tfyYIy0qN46914BzRPeDbC >									
	//        <  u =="0.000000000000000001" : ] 000000402532954.137969000000000000 ; 000000416585914.116185000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000266376F27BA8DF >									
	//     < SHERE_PFIV_I_metadata_line_23_____SOGAZ_SERBIA_20220505 >									
	//        < h9sd2QLZNVu4qO0rk4z7jao9nWnX3N3cx5R65v3l5qkk0gYBAIHsNb6W4cl6d27n >									
	//        <  u =="0.000000000000000001" : ] 000000416585914.116185000000000000 ; 000000431377008.541078000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027BA8DF2923AA5 >									
	//     < SHERE_PFIV_I_metadata_line_24_____ZHASO_20220505 >									
	//        < 9C0N09h63t5q79UfdkYE7Y9Bo289uNmsfI0YPtiaRxcH0MydCuUxT8a4bhn5a1dU >									
	//        <  u =="0.000000000000000001" : ] 000000431377008.541078000000000000 ; 000000453891134.213825000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002923AA52B49539 >									
	//     < SHERE_PFIV_I_metadata_line_25_____VTB_INSURANCE_ORG_20220505 >									
	//        < v7Ct3x81c6s5pD0ZIQN57uX1n1T258f219vDQCm430uASS665mffrcMTPCj1Wyfg >									
	//        <  u =="0.000000000000000001" : ] 000000453891134.213825000000000000 ; 000000469102460.457027000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B495392CBCB26 >									
	//     < SHERE_PFIV_I_metadata_line_26_____Vympel_Vostok_20220505 >									
	//        < 02rm8a2sezf9Q11WN2a4dpMauJFHgNs4kXkh31Cc724Em8g4uBhdQKyxtKT0p8y4 >									
	//        <  u =="0.000000000000000001" : ] 000000469102460.457027000000000000 ; 000000482275102.054014000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CBCB262DFE4B6 >									
	//     < SHERE_PFIV_I_metadata_line_27_____Oblatsnaya_Meditsinskaya_Strakho__20220505 >									
	//        < vbAH54T9rT56Ogt3ie8I3Jqj7Uf1hv9jtm2H3gOH5QOQT23Si74VYQ2aUrxNeqFQ >									
	//        <  u =="0.000000000000000001" : ] 000000482275102.054014000000000000 ; 000000506585958.571653000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DFE4B6304FD24 >									
	//     < SHERE_PFIV_I_metadata_line_28_____Medika_Tomsk_20220505 >									
	//        < 26gceI9L12gz5i59T60p87YHz88U7LNP8gbeoR7O3685MalzpPN2rd21LmL3CKPc >									
	//        <  u =="0.000000000000000001" : ] 000000506585958.571653000000000000 ; 000000526565753.641832000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000304FD2432379BF >									
	//     < SHERE_PFIV_I_metadata_line_29_____Medical_Insurance_Company_20220505 >									
	//        < rW8l7BTZu31C52zG7ZV27O0ySBa8BIMsS7nA04KQ31g7532dXhJOkDrSLS4388Dv >									
	//        <  u =="0.000000000000000001" : ] 000000526565753.641832000000000000 ; 000000543157722.173196000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032379BF33CCAFC >									
	//     < SHERE_PFIV_I_metadata_line_30_____MSK_MED_20220505 >									
	//        < FWEK1S1M8j79EfJF9Cr6mvt93F23t5qLHy1hu91K3RpG939BSr3U88Ja8L1tGk5d >									
	//        <  u =="0.000000000000000001" : ] 000000543157722.173196000000000000 ; 000000560115409.342238000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033CCAFC356AB15 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIV_I_metadata_line_31_____SG_MSK_20220505 >									
	//        < Bso2gIQnXCLC0Yl8jI1VxoWB1J9Q8535UlRU931u1OuGt3ZQ9Hu4jLEX6vbw5Z64 >									
	//        <  u =="0.000000000000000001" : ] 000000560115409.342238000000000000 ; 000000585933755.591592000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000356AB1537E1060 >									
	//     < SHERE_PFIV_I_metadata_line_32_____ROSNO_MS_20220505 >									
	//        < lDNi2T2Qm2r5RUT2yeJurD2lfD2YRwVo29F57EM3yqqVEw1OGDmcvQ6YK9rb7GYz >									
	//        <  u =="0.000000000000000001" : ] 000000585933755.591592000000000000 ; 000000606421562.292568000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037E106039D536C >									
	//     < SHERE_PFIV_I_metadata_line_33_____VTB_Life_Insurance_20220505 >									
	//        < 1PdAsD5Rodx84vF5wRt5Fui5Z7HZ9H6pFZ5eXVPFePo0moTMIv12L5yI9h76cESy >									
	//        <  u =="0.000000000000000001" : ] 000000606421562.292568000000000000 ; 000000631945216.334815000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039D536C3C4459A >									
	//     < SHERE_PFIV_I_metadata_line_34_____Company_Moskovsko__20220505 >									
	//        < 94146XG5YOSw4NbKb43758td0F085qcz56LYdz2yo865m2ohnnQUnxj41UbMSaRe >									
	//        <  u =="0.000000000000000001" : ] 000000631945216.334815000000000000 ; 000000647952537.846618000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C4459A3DCB276 >									
	//     < SHERE_PFIV_I_metadata_line_35_____VTB_Meditsinskoye_Strakho__20220505 >									
	//        < 9RNj0Y85MkrmKU18W0wJaadOyjVZ4dk1OTn6NcSJ3W65hnpZdvJY75Dm06b2e4h9 >									
	//        <  u =="0.000000000000000001" : ] 000000647952537.846618000000000000 ; 000000664026567.204881000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DCB2763F53961 >									
	//     < SHERE_PFIV_I_metadata_line_36_____SPASSKIYE_VOROTA_INSURANCE_GROUP_20220505 >									
	//        < grC2VoC0ESlJ74fFXSt2Thao994mx9tot5ZY8xR7oT5gP6NXD2X7B6Io89OaOU79 >									
	//        <  u =="0.000000000000000001" : ] 000000664026567.204881000000000000 ; 000000684224586.677002000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F539614140B3B >									
	//     < SHERE_PFIV_I_metadata_line_37_____CASCO_MED_INS_20220505 >									
	//        < j38y6175UicW2PVwM74c98fagus2ePS0qjV0KzGn3J4V3vZilyH516b0TNxTFRLZ >									
	//        <  u =="0.000000000000000001" : ] 000000684224586.677002000000000000 ; 000000707651695.215350000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004140B3B437CA72 >									
	//     < SHERE_PFIV_I_metadata_line_38_____SMK_NOVOLIPETSKAYA_20220505 >									
	//        < w497S7fMutDmVn2oXjpzcdJTddA8r55YGMI0dB166E66Y4YRtFs7bK60WEqMI06K >									
	//        <  u =="0.000000000000000001" : ] 000000707651695.215350000000000000 ; 000000729213749.931369000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000437CA72458B11F >									
	//     < SHERE_PFIV_I_metadata_line_39_____MOSKOVSKOE_PERETRAKHOVOCHNOE_OBSHESTVO_20220505 >									
	//        < ilK0S3nhrD8p6263H171wu0V0bhE6R5DuUh2D1PG1olRewx9YN42FX1OQ9rY7Gw7 >									
	//        <  u =="0.000000000000000001" : ] 000000729213749.931369000000000000 ; 000000748724415.916780000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000458B11F476767A >									
	//     < SHERE_PFIV_I_metadata_line_40_____RESO_20220505 >									
	//        < wBZO859By34M5yu0Ij8843I7O440Tb1B5A93AEV1PqWN4u4803AXEShAfNul7027 >									
	//        <  u =="0.000000000000000001" : ] 000000748724415.916780000000000000 ; 000000772344232.462985000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000476767A49A80F7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
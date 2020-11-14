/**
 * Source Code first verified at https://etherscan.io on Friday, March 22, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFIII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFIII_II_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFIII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		747213157706227000000000000					;	
										
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
	//     < CHEMCHINA_PFIII_II_metadata_line_1_____Hangzhou_Hairui_Chemical_Limited_20240321 >									
	//        < V86oparpfoZa4p952sg4B04BA5v5iS12N4NpXYUeWh5opC8tTWFB0zUafC1Eh6vp >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000020069273.643270800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001E9F8F >									
	//     < CHEMCHINA_PFIII_II_metadata_line_2_____Hangzhou_Huajin_Pharmaceutical_Co_Limited_20240321 >									
	//        < K0SN0JdG8C67iTfHZ9ASuf05bH6OY3iJMjt632GyrHO276vLeVHVMqsjwfxFGQxg >									
	//        <  u =="0.000000000000000001" : ] 000000020069273.643270800000000000 ; 000000036437888.275046300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E9F8F37998D >									
	//     < CHEMCHINA_PFIII_II_metadata_line_3_____Hangzhou_J_H_Chemical_Co__Limited_20240321 >									
	//        < 5I5igx24q2ys5P550877PpaFB69x012VX85470Jf1ntO4Y154tnLLJYv4H3dz9E0 >									
	//        <  u =="0.000000000000000001" : ] 000000036437888.275046300000000000 ; 000000056368771.329677400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000037998D56030D >									
	//     < CHEMCHINA_PFIII_II_metadata_line_4_____Hangzhou_J_H_Chemical_Co__Limited_20240321 >									
	//        < W071HvGW4203Z5A1raPd2x6ueJXwynbAoL140x4933Ot8Yv0572nOoY9akOW6gs5 >									
	//        <  u =="0.000000000000000001" : ] 000000056368771.329677400000000000 ; 000000071676040.242978400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000056030D6D5E74 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_5_____HANGZHOU_KEYINGCHEM_Co_Limited_20240321 >									
	//        < 5784YS6Z51IIf8m93Nt11VSLrG9EBL7kD7qv2B2gq0ZPifnWgK0890tj15cQewGl >									
	//        <  u =="0.000000000000000001" : ] 000000071676040.242978400000000000 ; 000000088644813.477184000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006D5E748742E1 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_6_____HANGZHOU_MEITE_CHEMICAL_Co_LimitedHANGZHOU_MEITE_INDUSTRY_Co_Limited_20240321 >									
	//        < t11Y0eK8HO3BLAN4E8ZW29e83Okd9lW7RCv3vg983jUFse92tdC5I1H0pe5ciIq6 >									
	//        <  u =="0.000000000000000001" : ] 000000088644813.477184000000000000 ; 000000104832472.276592000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008742E19FF62F >									
	//     < CHEMCHINA_PFIII_II_metadata_line_7_____Hangzhou_Ocean_chemical_Co_Limited_20240321 >									
	//        < rO0DiR0f4QETfU0GG98UD4KJPJt37OgoBbx6uHcBIrOD9hZD6DhySK47kf78GBUA >									
	//        <  u =="0.000000000000000001" : ] 000000104832472.276592000000000000 ; 000000124086304.800521000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009FF62FBD5736 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_8_____Hangzhou_Pharma___Chem_Co_Limited_20240321 >									
	//        < w2szusx4r8S73n25eT8oS3spX41rOU34G4sPx1LprHc6HWL6dy3hj221SX31fL0u >									
	//        <  u =="0.000000000000000001" : ] 000000124086304.800521000000000000 ; 000000144037406.421933000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BD5736DBC89D >									
	//     < CHEMCHINA_PFIII_II_metadata_line_9_____Hangzhou_Tino_Bio_Tech_Co_Limited_20240321 >									
	//        < eItCoGR10Ccjf03lJT90Qn82OJ2336pm7Wi4l9634JDCCsb99iiiTUIg4qZNEere >									
	//        <  u =="0.000000000000000001" : ] 000000144037406.421933000000000000 ; 000000160446719.868704000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DBC89DF4D280 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_10_____Hangzhou_Trylead_Chemical_Technology_Co_Limited_20240321 >									
	//        < hH4DeFSsjgB6QSHOmB71dOsi56b6dF8cHjevTFF06gjZ5zC5OFnZhKVJ2g8Oz32h >									
	//        <  u =="0.000000000000000001" : ] 000000160446719.868704000000000000 ; 000000176070669.242659000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F4D28010CA99B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIII_II_metadata_line_11_____Hangzhou_Verychem_Science_And_Technology_org_20240321 >									
	//        < 3uVQjR9w160ViNss9oVMXl4e6C734o9ol53DeB2VeQWw9n9uLyBvt7K3TA3MLSfJ >									
	//        <  u =="0.000000000000000001" : ] 000000176070669.242659000000000000 ; 000000192818733.893931000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010CA99B12637D1 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_12_____Hangzhou_Verychem_Science_And_Technology_Co__Limited_20240321 >									
	//        < BIOV2z8Tf8rwhtsrkkW89KkvRcU4BsD6HNn1y6i20s2y90ODYIO5TTvzYaq70sFN >									
	//        <  u =="0.000000000000000001" : ] 000000192818733.893931000000000000 ; 000000214695897.336704000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012637D11479996 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_13_____Hangzhou_Yuhao_Chemical_Technology_Co_Limited_20240321 >									
	//        < 5q29UYs4I7j9CP0oLt38I0GhKPn64q35j7AN7728F5Hjf03GoL7km4HZxp9bOkPM >									
	//        <  u =="0.000000000000000001" : ] 000000214695897.336704000000000000 ; 000000231290884.316889000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001479996160EC00 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_14_____HANGZHOU_ZHIXIN_CHEMICAL_Co__Limited_20240321 >									
	//        < 66R3y1e9P7eV6L7h7j5w19Z5kwWrL5Z1Gd11bWjT78mDzvVX0yI23ouP6vqn00vR >									
	//        <  u =="0.000000000000000001" : ] 000000231290884.316889000000000000 ; 000000246546791.045795000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000160EC001783357 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_15_____Hangzhou_zhongqi_chem_Co_Limited_20240321 >									
	//        < Ed1ZCb1W0jqeuk1d824P8rZTO91z8mIN2QcwP2VchoEop2bAqO18wwGzD8AXuFUk >									
	//        <  u =="0.000000000000000001" : ] 000000246546791.045795000000000000 ; 000000263192191.200488000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017833571919973 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_16_____HEBEI_AOGE_CHEMICAL_Co__Limited_20240321 >									
	//        < EM99E4WZ0l1Yp7V1RerjBELVFY1xSR8m0e469cF59sYAEJ309w58linq69dPmArp >									
	//        <  u =="0.000000000000000001" : ] 000000263192191.200488000000000000 ; 000000282053505.523925000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019199731AE6127 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_17_____HEBEI_DAPENG_PHARM_CHEM_Co__Limited_20240321 >									
	//        < Dbw6t6Mb094X9dt58VL3Z11bbfMiZPQ018RVJ1AryJePPk1nxRc2l62G87x7XZi8 >									
	//        <  u =="0.000000000000000001" : ] 000000282053505.523925000000000000 ; 000000304882413.738365000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AE61271D136B1 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_18_____Hebei_Guantang_Pharmatech_20240321 >									
	//        < FKpWXwa3G9g04CI232Ii882iXqINCb13XJvhs97fwe5d92sXc3r3QHnm1QJL7gF1 >									
	//        <  u =="0.000000000000000001" : ] 000000304882413.738365000000000000 ; 000000321757496.762174000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D136B11EAF686 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_19_____Hefei_Hirisun_Pharmatech_org_20240321 >									
	//        < 9y64Y239YVQL0lfOv6nclnyI2OwA8Twk2a8KwQr1ZLb17x4DP67EcpPJ1UM2ryBc >									
	//        <  u =="0.000000000000000001" : ] 000000321757496.762174000000000000 ; 000000337643594.958560000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EAF6862033407 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_20_____Hefei_Hirisun_Pharmatech_Co_Limited_20240321 >									
	//        < 9AtrPHO79bc7nC2XF9w102Fh4muy84z2041k8AqdZ6fpAB32xCpvr29dF58A71dR >									
	//        <  u =="0.000000000000000001" : ] 000000337643594.958560000000000000 ; 000000354456052.082205000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000203340721CDB65 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIII_II_metadata_line_21_____HENAN_YUCHEN_FINE_CHEMICAL_Co_Limited_20240321 >									
	//        < A8MAhg79Gwz1NMSEOVP13ibNYxlCu28LjA4F4vQ2l0fr2UltNiiH4okL0RyZKljo >									
	//        <  u =="0.000000000000000001" : ] 000000354456052.082205000000000000 ; 000000370933166.262794000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021CDB65235FFC5 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_22_____Hi_Tech_Chemistry_Corp_20240321 >									
	//        < e383UEK2HMg8WacQgo0b6J0I89h01Jd3Mi51c1IQ6ZBJ3x7R0qC6IbaaPvfM17Da >									
	//        <  u =="0.000000000000000001" : ] 000000370933166.262794000000000000 ; 000000387559595.606314000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000235FFC524F5E78 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_23_____Hongding_International_Chemical_Industry__Nantong__co___ltd_20240321 >									
	//        < Sy96P17N5pJfwJZ9WHES2XsX1sUHy69TcVp1zl583bpN5uExbZmMzFmsLRQjz8NB >									
	//        <  u =="0.000000000000000001" : ] 000000387559595.606314000000000000 ; 000000407801318.961494000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024F5E7826E4164 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_24_____Hunan_Chemfish_pharmaceutical_Co_Limited_20240321 >									
	//        < 1m3fh0r654zNdx3fj8YY2ho24dE7235J5srP3rbHD292on7H19uLVwi146Yum0h8 >									
	//        <  u =="0.000000000000000001" : ] 000000407801318.961494000000000000 ; 000000423067543.051414000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026E41642858CC2 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_25_____IFFECT_CHEMPHAR_Co__Limited_20240321 >									
	//        < DqQQKOY3rJBKnI2Jf5k6O000khhJz3dTh7p37ct439GrZAF12k0pUMN8rJ4wyywD >									
	//        <  u =="0.000000000000000001" : ] 000000423067543.051414000000000000 ; 000000445315175.861334000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002858CC22A77F3E >									
	//     < CHEMCHINA_PFIII_II_metadata_line_26_____Jiangsu_Guotai_International_Group_Co_Limited_20240321 >									
	//        < 6Mm9L18dxZ876oQnRjqE0366llvgiSbo8e2Syp9Wks349aen1kG115CCNY5CACEd >									
	//        <  u =="0.000000000000000001" : ] 000000445315175.861334000000000000 ; 000000461260527.188843000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A77F3E2BFD3E5 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_27_____JIANGXI_TIME_CHEMICAL_Co_Limited_20240321 >									
	//        < pdsBPEidkI4htqy70s53iU7TAb11806HNS5h8TSca34z99Pc42t3dlI8ulVL9mUd >									
	//        <  u =="0.000000000000000001" : ] 000000461260527.188843000000000000 ; 000000478956228.641951000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BFD3E52DAD447 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_28_____Jianshi_Yuantong_Bioengineering_Co_Limited_20240321 >									
	//        < l9r16K66jGw5zUYoQyZBZ5veG4LNDcM609918C9f7YmsGexFocZiB27kyWd88X82 >									
	//        <  u =="0.000000000000000001" : ] 000000478956228.641951000000000000 ; 000000498195179.467902000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DAD4472F82F7E >									
	//     < CHEMCHINA_PFIII_II_metadata_line_29_____Jiaxing_Nanyang_Wanshixing_Chemical_Co__Limited_20240321 >									
	//        < 22IwBD84PxjOy6561j08xyuHJFji214mn33DMkm76y4g3YFtUlq51V6tZ7zZHXD0 >									
	//        <  u =="0.000000000000000001" : ] 000000498195179.467902000000000000 ; 000000520654760.763606000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F82F7E31A74C4 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_30_____Jinan_TaiFei_Science_Technology_Co_Limited_20240321 >									
	//        < FyMWWX5h0lh1DVAZ4SvUmgJcBii9Umq61kqlwOiQ0u0Sas4fc59BLI67GJdF8kw2 >									
	//        <  u =="0.000000000000000001" : ] 000000520654760.763606000000000000 ; 000000542689254.193936000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031A74C433C13FD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFIII_II_metadata_line_31_____Jinan_YSPharma_Biotechnology_Co_Limited_20240321 >									
	//        < 80fJv5OwFRk9ozOD596Pgx42ou8cS3XpEDop5XA2l0vDST8FV75SMKMpQqrM959c >									
	//        <  u =="0.000000000000000001" : ] 000000542689254.193936000000000000 ; 000000566251825.295021000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033C13FD360081F >									
	//     < CHEMCHINA_PFIII_II_metadata_line_32_____JINCHANG_HOLDING_org_20240321 >									
	//        < 17Ns6N0CN1FEmssoO3vJ6LL59EhOx8jmK2GCbky7DkmLsluDdGRUmkajTw42s2E9 >									
	//        <  u =="0.000000000000000001" : ] 000000566251825.295021000000000000 ; 000000584870501.262919000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000360081F37C710A >									
	//     < CHEMCHINA_PFIII_II_metadata_line_33_____JINCHANG_HOLDING_LIMITED_20240321 >									
	//        < Q2GrrRV04KXET8aR9Ka7veQp3NAOszZ97b3H2rC70vM9yUgL6YPh9kHzC7IhTbhY >									
	//        <  u =="0.000000000000000001" : ] 000000584870501.262919000000000000 ; 000000601784757.147180000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037C710A396402C >									
	//     < CHEMCHINA_PFIII_II_metadata_line_34_____Jinhua_huayi_chemical_Co__Limited_20240321 >									
	//        < DWJxke1wG40yYx0tZXnA6VN5ey747kTX54E2Ker2d11ZDZg2NiTq1aBCcEmsn3Z1 >									
	//        <  u =="0.000000000000000001" : ] 000000601784757.147180000000000000 ; 000000622404319.084943000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000396402C3B5B6B0 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_35_____Jinhua_Qianjiang_Fine_Chemical_Co_Limited_20240321 >									
	//        < fcCCpf65Gi1I7A0T5efNvVZu4v83t9l9nH56ePRa08y6YJbx647eR4zN4Z0IHqzR >									
	//        <  u =="0.000000000000000001" : ] 000000622404319.084943000000000000 ; 000000639092873.789564000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B5B6B03CF2DA7 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_36_____Jinjiangchem_Corporation_20240321 >									
	//        < jmB6Iu1vB57mRxPbBZ6jJ035wyfn171zJSbwYL5Og6rdR2TVpqNF7akdcIJSh8U6 >									
	//        <  u =="0.000000000000000001" : ] 000000639092873.789564000000000000 ; 000000662682641.131641000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CF2DA73F32C68 >									
	//     < CHEMCHINA_PFIII_II_metadata_line_37_____Jiurui_Biology___Chemistry_Co_Limited_20240321 >									
	//        < 2q7Z39qg3n5w71cD8qqU1GL2yZRRPrb12P8k1JEr2aW1fnsU9456k84u417O4W1L >									
	//        <  u =="0.000000000000000001" : ] 000000662682641.131641000000000000 ; 000000685099977.385929000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F32C68415612E >									
	//     < CHEMCHINA_PFIII_II_metadata_line_38_____Jlight_Chemicals_org_20240321 >									
	//        < 3NFnrhKtu18651y4rlhx66MGL8t49H3q21c7Z67LNvpq029PV69285B2wrwX0P9Q >									
	//        <  u =="0.000000000000000001" : ] 000000685099977.385929000000000000 ; 000000705409072.714680000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000415612E4345E6B >									
	//     < CHEMCHINA_PFIII_II_metadata_line_39_____Jlight_Chemicals_Company_20240321 >									
	//        < 9crnEs4u1PwixN81D6EKYjnVQp8cxRNI35CRZbLrlmdZ7WwBReDJk9EUn727atn5 >									
	//        <  u =="0.000000000000000001" : ] 000000705409072.714680000000000000 ; 000000723511469.328837000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004345E6B44FFDAB >									
	//     < CHEMCHINA_PFIII_II_metadata_line_40_____JQC_China_Pharmaceutical_Co_Limited_20240321 >									
	//        < 105sWn7FS7uxMPvw3qp5UCtUq1753nwd451uFmYtowpCiR54oKgJy2BM09vgt2aF >									
	//        <  u =="0.000000000000000001" : ] 000000723511469.328837000000000000 ; 000000747213157.706228000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044FFDAB4742824 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	BANK_IV_PFI_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	BANK_IV_PFI_883		"	;
		string	public		symbol =	"	BANK_IV_PFI_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		417212953933922000000000000					;	
										
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
	//     < BANK_IV_PFI_metadata_line_1_____AGRICULTURAL DEVELOPMENT BANK OF CHINA_20220508 >									
	//        < 5MixI7JRQ90f0ZqJq15JV1vebVkolE497z5R74tIb3jf2eeQFZTiaXZA3CA49RPi >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010374052.886285400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000FD45D >									
	//     < BANK_IV_PFI_metadata_line_2_____CHINA DEVELOMENT BANK_20220508 >									
	//        < Tg9H6oKq57v7xkN78h4mRB2xK1WCx069ESb012M22UaKBExGB0X4c70buLAkeLp3 >									
	//        <  u =="0.000000000000000001" : ] 000000010374052.886285400000000000 ; 000000020870506.367522900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000FD45D1FD88B >									
	//     < BANK_IV_PFI_metadata_line_3_____EXIM BANK OF CHINA_20220508 >									
	//        < Lcm6VeS1tv29eJMb242tE3BF560y0DAsYyX20AE8qWL2M69omzAnUM5nuq9hrlN2 >									
	//        <  u =="0.000000000000000001" : ] 000000020870506.367522900000000000 ; 000000031184694.787244400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001FD88B2F9585 >									
	//     < BANK_IV_PFI_metadata_line_4_____CHINA MERCHANT BANK_20220508 >									
	//        < cj4c6o8ypWniCC75J0Nw5wWB818YoT6SUYV0dL5Nf669r9r9OwSc2cC213W8862f >									
	//        <  u =="0.000000000000000001" : ] 000000031184694.787244400000000000 ; 000000041598198.160617100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002F95853F794C >									
	//     < BANK_IV_PFI_metadata_line_5_____SHANGHAI PUDONG DEVELOPMENT BANK_20220508 >									
	//        < 9879143OF2uNa6c8IBC7w18xnAn0S2YN1517lpThA0Rtp2yn5THR2LrWUsyRkZh9 >									
	//        <  u =="0.000000000000000001" : ] 000000041598198.160617100000000000 ; 000000052147063.401884200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003F794C4F91F2 >									
	//     < BANK_IV_PFI_metadata_line_6_____INDUSTRIAL BANK_20220508 >									
	//        < gCDrpYIVRVE75oGsPtMGyO71L4LlF4O8y55fH6mtsmBBbg9Y2l7Np1Emk01Y31rP >									
	//        <  u =="0.000000000000000001" : ] 000000052147063.401884200000000000 ; 000000062595913.850933600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004F91F25F8387 >									
	//     < BANK_IV_PFI_metadata_line_7_____CHINA CITIC BANK_20220508 >									
	//        < 72TrB3p48wSbybWhq280GHlV28HPN74E3SYAl788ads6mH437Vx8MeF05b9a4qd4 >									
	//        <  u =="0.000000000000000001" : ] 000000062595913.850933600000000000 ; 000000072945288.526597000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F83876F4E41 >									
	//     < BANK_IV_PFI_metadata_line_8_____CHINA MINSHENG BANK_20220508 >									
	//        < OYChWam0eOcY4s5Y2K891cw591t0h8oqP6it3VQ705j563OOVdGKPQZ4y4Kbx7Ad >									
	//        <  u =="0.000000000000000001" : ] 000000072945288.526597000000000000 ; 000000083452388.907668200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006F4E417F5697 >									
	//     < BANK_IV_PFI_metadata_line_9_____CHINA EVERBRIGHT BANK_20220508 >									
	//        < wKl3KQKO58m2rKl3H363n3lS94djP7yOJZvs2863P773CrbQE98KD4duOR6h953B >									
	//        <  u =="0.000000000000000001" : ] 000000083452388.907668200000000000 ; 000000093882122.321613600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007F56978F40B4 >									
	//     < BANK_IV_PFI_metadata_line_10_____PING AN BANK_20220508 >									
	//        < s35NdctEaIBwdIKf508AC4l7f9VAC8Ph4TaSZXPoYRX37qP62T9eXjE7v5t0yPKf >									
	//        <  u =="0.000000000000000001" : ] 000000093882122.321613600000000000 ; 000000104361971.409608000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008F40B49F3E65 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_IV_PFI_metadata_line_11_____HUAXIA BANK_20220508 >									
	//        < i5ya2N405YzN4EjeP7W3d42lH8560jkPqnzpNPlGBpy44JaabfTlr11618nZM0vd >									
	//        <  u =="0.000000000000000001" : ] 000000104361971.409608000000000000 ; 000000114847617.671870000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009F3E65AF3E5A >									
	//     < BANK_IV_PFI_metadata_line_12_____CHINA GUANGFA BANK_20220508 >									
	//        < SC16QNfJx9wt3KoErGomY9cS6KoD2dl1Seti1F4eBq88So9p0Fv93Xs4kSJkJWXx >									
	//        <  u =="0.000000000000000001" : ] 000000114847617.671870000000000000 ; 000000125309315.437473000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AF3E5ABF34F4 >									
	//     < BANK_IV_PFI_metadata_line_13_____CHINA BOHAI BANK_20220508 >									
	//        < 731Jie06wl0MqL08100g562KD98861H1vf69JcMfM6U40tPOp2oYZtAhjYC704b5 >									
	//        <  u =="0.000000000000000001" : ] 000000125309315.437473000000000000 ; 000000135788053.690898000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BF34F4CF3235 >									
	//     < BANK_IV_PFI_metadata_line_14_____HENGFENG BANK_EVERGROWING BANK_20220508 >									
	//        < 3QvBDH602d971w19y73C5ck6EcrH27fZUR2nL363vKMVwnXpp3DA6jke3hXL3aRR >									
	//        <  u =="0.000000000000000001" : ] 000000135788053.690898000000000000 ; 000000146232349.597915000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CF3235DF2203 >									
	//     < BANK_IV_PFI_metadata_line_15_____BANK OF BEIJING_20220508 >									
	//        < 1NnoC36t68qNIraGV1Zkp29UW6ee3Hd9QZ97jV71zvdN2vM84989ZUH6454ZLY1r >									
	//        <  u =="0.000000000000000001" : ] 000000146232349.597915000000000000 ; 000000156708863.013677000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DF2203EF1E66 >									
	//     < BANK_IV_PFI_metadata_line_16_____BANK OF SHANGHAI_20220508 >									
	//        < H7T55A1UKBd3D0UFMi0ML624nf0ID7qDFDqbMJhtj12s84hz06v0tDI2EO732464 >									
	//        <  u =="0.000000000000000001" : ] 000000156708863.013677000000000000 ; 000000167083421.946494000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000EF1E66FEF2F6 >									
	//     < BANK_IV_PFI_metadata_line_17_____BANK OF JIANGSU_20220508 >									
	//        < UWn6rYgvS8NQVd0CEGKACQL7hJDe1eNp92nrck38671x5pkDrD8fenGh2Nh9sZf3 >									
	//        <  u =="0.000000000000000001" : ] 000000167083421.946494000000000000 ; 000000177582692.204125000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FEF2F610EF83D >									
	//     < BANK_IV_PFI_metadata_line_18_____BANK OF NINGBO_20220508 >									
	//        < zbnxuFtJ89m1og2sUWCc4BtGCl1cdlJ42E30xp8YbokAvg1sn810W7X2lEJmGTjn >									
	//        <  u =="0.000000000000000001" : ] 000000177582692.204125000000000000 ; 000000187912042.280712000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010EF83D11EBB24 >									
	//     < BANK_IV_PFI_metadata_line_19_____BANK OF DALIAN_20220508 >									
	//        < 7LzdctvjYY7Xo1PjQn9awK090gWLNj1D531414fvp14976go1q6O4QsCQ68BuOBp >									
	//        <  u =="0.000000000000000001" : ] 000000187912042.280712000000000000 ; 000000198393432.553404000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011EBB2412EB96F >									
	//     < BANK_IV_PFI_metadata_line_20_____BANK OF TAIZHOU_20220508 >									
	//        < v0X722VbVxkKrsbmq40xDTQ0kMeX2d304T43W0GX4Vz3470K9g25F4tV1uxH1ry3 >									
	//        <  u =="0.000000000000000001" : ] 000000198393432.553404000000000000 ; 000000208728813.668722000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012EB96F13E7EB1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_IV_PFI_metadata_line_21_____BANK OF TIANJIN_20220508 >									
	//        < q28frfqvn9JNXIIMcUukRlmtsipB56t7I4Bbb3192ZKOyIM8KmBLTa8m552TW30E >									
	//        <  u =="0.000000000000000001" : ] 000000208728813.668722000000000000 ; 000000219232131.794078000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013E7EB114E858D >									
	//     < BANK_IV_PFI_metadata_line_22_____WIAMEN INTERNATIONAL BANK_20220508 >									
	//        < 0k1pazm1HTsS40vL26Jb7sh9D3N1WWzmQ1mj3ygH8zOT97tsC3qM009fQ7YAxy41 >									
	//        <  u =="0.000000000000000001" : ] 000000219232131.794078000000000000 ; 000000229680808.944925000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014E858D15E7711 >									
	//     < BANK_IV_PFI_metadata_line_23_____TAI_AN BANK_20220508 >									
	//        < RXG2ECN0uvdLJjfERx525lHyCaSK0GNOT0KqMT69NBz0gXOCMgQ3OFF5B329CeT0 >									
	//        <  u =="0.000000000000000001" : ] 000000229680808.944925000000000000 ; 000000240144292.545249000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015E771116E6E5D >									
	//     < BANK_IV_PFI_metadata_line_24_____SHENGJING BANK_SHENYANG_20220508 >									
	//        < IDhA08gNY46e5uUG113q4jSzyK7i3R7Q3rxf7EKkQq6iVVQkp5kh48W8dh2l7M06 >									
	//        <  u =="0.000000000000000001" : ] 000000240144292.545249000000000000 ; 000000250678118.072535000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016E6E5D17E8124 >									
	//     < BANK_IV_PFI_metadata_line_25_____HARBIN BANK_20220508 >									
	//        < pUi9LRg8b7jfrBjwtuo9rrH0UX6b3D3j3yDEFKi1cbsSpYVtmOzh8975foMQ302r >									
	//        <  u =="0.000000000000000001" : ] 000000250678118.072535000000000000 ; 000000261147517.773991000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017E812418E7AC0 >									
	//     < BANK_IV_PFI_metadata_line_26_____BANK OF JILIN_20220508 >									
	//        < E0yQ32KiPF6e4L0VgI1n9inOA65516WTjlijqa1kd0xIcQF8Hl136cT0mxuoM1t5 >									
	//        <  u =="0.000000000000000001" : ] 000000261147517.773991000000000000 ; 000000271561444.331049000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018E7AC019E5EB0 >									
	//     < BANK_IV_PFI_metadata_line_27_____WEBANK_CHINA_20220508 >									
	//        < 46z4ToIo0X53rEfGrZ77q6Bzi5gL947RT6o55qH0u22C641nKKiBM4PfU7NSB8wI >									
	//        <  u =="0.000000000000000001" : ] 000000271561444.331049000000000000 ; 000000282041702.921748000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019E5EB01AE5C8A >									
	//     < BANK_IV_PFI_metadata_line_28_____MYBANK_HANGZHOU_20220508 >									
	//        < O1p9l9s3QVj0f7Ooo2k1R1SgIvShJ2Wq94ryJ7V8rEh3369I9jTrhCMC6833Uh7B >									
	//        <  u =="0.000000000000000001" : ] 000000282041702.921748000000000000 ; 000000292460059.879918000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AE5C8A1BE4236 >									
	//     < BANK_IV_PFI_metadata_line_29_____SHANGHAI HUARUI BANK_20220508 >									
	//        < 0G47V8O9RF1QjVMtg9K8UxkXNSYi91P678z1mFb6Bk7058NiPfVKZ5oHDHR14amf >									
	//        <  u =="0.000000000000000001" : ] 000000292460059.879918000000000000 ; 000000302890593.035102000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BE42361CE2CA3 >									
	//     < BANK_IV_PFI_metadata_line_30_____WENZHOU MINSHANG BANK_20220508 >									
	//        < 1b3eHx1iSA7xsfoXpRGjPIBKgWha0Rm4UrU541kCvq5Vh3GY82C0r0DUOL1UIyfS >									
	//        <  u =="0.000000000000000001" : ] 000000302890593.035102000000000000 ; 000000313205910.032079000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CE2CA31DDEA0F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_IV_PFI_metadata_line_31_____BANK OF KUNLUN_20220508 >									
	//        < Ms7n4d66SKexJRN7G3q3XilxFqq8560Xq27720JfO4lptP816LLEXQRs3U06dFr0 >									
	//        <  u =="0.000000000000000001" : ] 000000313205910.032079000000000000 ; 000000323695150.649529000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DDEA0F1EDEB6B >									
	//     < BANK_IV_PFI_metadata_line_32_____SILIBANK_20220508 >									
	//        < SW025lUG7CMOYunHO3IjcpGLH9nG0BBOChsK856Cmm46I6h6l76lE96Y8m3414OK >									
	//        <  u =="0.000000000000000001" : ] 000000323695150.649529000000000000 ; 000000334059401.594430000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EDEB6B1FDBBF4 >									
	//     < BANK_IV_PFI_metadata_line_33_____AGRICULTURAL BANK OF CHINA_20220508 >									
	//        < j8iPX8QP5CQje0568JlI4415S2DjTuB5os7sPfVpZ5s56Kr006252WE8961sXCUP >									
	//        <  u =="0.000000000000000001" : ] 000000334059401.594430000000000000 ; 000000344413999.552061000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FDBBF420D88B8 >									
	//     < BANK_IV_PFI_metadata_line_34_____CIC_CHINA INVESTMENT CORP_20220508 >									
	//        < lnGiVaE25Q1jwjwTWgu3Cq696rNTH1Sr94tJl9D5LDdcLTeqH4GQf1h1EH5dn234 >									
	//        <  u =="0.000000000000000001" : ] 000000344413999.552061000000000000 ; 000000354874766.142361000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020D88B821D7EF5 >									
	//     < BANK_IV_PFI_metadata_line_35_____BANK OF CHINA_20220508 >									
	//        < jTWFRR147513bG0w4J8EeUThLapUo8mt4327O6lAAd274712Cg8OZ699R5jQF1K4 >									
	//        <  u =="0.000000000000000001" : ] 000000354874766.142361000000000000 ; 000000365212771.354041000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021D7EF522D453D >									
	//     < BANK_IV_PFI_metadata_line_36_____PEOPLE BANK OF CHINA_20220508 >									
	//        < Bk7Mk103a9Dpdwr013K4dR07Au8FSfAY9laBRrAg94v1eg6t6m5TbM37bWuu9K9A >									
	//        <  u =="0.000000000000000001" : ] 000000365212771.354041000000000000 ; 000000375515642.111018000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022D453D23CFDCC >									
	//     < BANK_IV_PFI_metadata_line_37_____ICBC_INDUSTRIAL AND COMMERCIAL BANK OF CHINA_20220508 >									
	//        < 2kixL1jF3xYO223gX9je066A8084D0OP68alF3K5aQK7PYhO0h54f6q47mIHvtHm >									
	//        <  u =="0.000000000000000001" : ] 000000375515642.111018000000000000 ; 000000385890989.353231000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023CFDCC24CD2AB >									
	//     < BANK_IV_PFI_metadata_line_38_____CHINA CONSTRUCTION BANK_20220508 >									
	//        < cYtsuOLl95OX9ZS6d5HyYjz5XO57EGVJX5kW2lvX4VTVi4PME8MBb2AS4NY8ZXqi >									
	//        <  u =="0.000000000000000001" : ] 000000385890989.353231000000000000 ; 000000396394323.597751000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024CD2AB25CD988 >									
	//     < BANK_IV_PFI_metadata_line_39_____BANK OF COMMUNICATION_20220508 >									
	//        < TvK5T62dXJ9XYtPd54TtVz3qLOWe9LNH31Z69IzqlV5N5Oa7P25VBT3nqirx4YaK >									
	//        <  u =="0.000000000000000001" : ] 000000396394323.597751000000000000 ; 000000406681297.995441000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025CD98826C8BE2 >									
	//     < BANK_IV_PFI_metadata_line_40_____POSTAL SAVINGS BANK OF CHINA_20220508 >									
	//        < 25eyfU1Dt4BJ8I5iGJaG28OQ1983Iw12OM23jADrOoI42NuzKxe2JBWyhc6oV934 >									
	//        <  u =="0.000000000000000001" : ] 000000406681297.995441000000000000 ; 000000417212953.933922000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026C8BE227C9DCF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
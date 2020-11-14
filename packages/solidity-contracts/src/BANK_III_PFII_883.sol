/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	BANK_III_PFII_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	BANK_III_PFII_883		"	;
		string	public		symbol =	"	BANK_III_PFII_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		429287043125237000000000000					;	
										
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
	//     < BANK_III_PFII_metadata_line_1_____PITTSBURG BANK_20240508 >									
	//        < eNBoRtLrFjRzCg8ptN2FO05HZSMxibgYdtJXblHG0VTnFT966w50DR682FY167Be >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010857582.540636600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000010913E >									
	//     < BANK_III_PFII_metadata_line_2_____BANK OF AMERICA_20240508 >									
	//        < lKbyjOfTaZ7fgKWVf7K6fRm95Eu2L02GE69i5UU8Z8k7fXvsI4z6Jx4ZywqSUMu6 >									
	//        <  u =="0.000000000000000001" : ] 000000010857582.540636600000000000 ; 000000021397338.288872800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000010913E20A656 >									
	//     < BANK_III_PFII_metadata_line_3_____WELLS FARGO_20240508 >									
	//        < 7EBr48x4wE786545aT9vP15v9ZOEDp51SWgIPgq49o3ywJ8HQF558O0TX24oY56j >									
	//        <  u =="0.000000000000000001" : ] 000000021397338.288872800000000000 ; 000000032115232.007492600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000020A656310103 >									
	//     < BANK_III_PFII_metadata_line_4_____MORGAN STANLEY_20240508 >									
	//        < 28xuTXq8C2P37d7532cE98zW9mf174hM3f2Q3NMd244D8GP93BwK0Gv96DS43uDf >									
	//        <  u =="0.000000000000000001" : ] 000000032115232.007492600000000000 ; 000000042814935.492246300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000310103415496 >									
	//     < BANK_III_PFII_metadata_line_5_____LEHAN BROTHERS AB_20240508 >									
	//        < 2uHTAby1cU9ihXf5Ocmd108K8fY7ssGh9Q3795X0941vefWsVn2SJg1A980RelhO >									
	//        <  u =="0.000000000000000001" : ] 000000042814935.492246300000000000 ; 000000053519691.481747900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000041549651AA21 >									
	//     < BANK_III_PFII_metadata_line_6_____BARCLAYS_20240508 >									
	//        < mgJ78t60Z36Yn9oHk05BUGulkk5kPE8B4uWMZ4r435QT88jL2a84ktT4bUN9M3ba >									
	//        <  u =="0.000000000000000001" : ] 000000053519691.481747900000000000 ; 000000064349786.050335100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000051AA216230A3 >									
	//     < BANK_III_PFII_metadata_line_7_____GLDMAN SACHS_20240508 >									
	//        < 3Arou4q1k628Tq9H5r4y8k1a5Yt8tkuJueR98K2Uu1NX8L8L5H19jCNygsW9Uc8e >									
	//        <  u =="0.000000000000000001" : ] 000000064349786.050335100000000000 ; 000000075232650.659466400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006230A372CBC1 >									
	//     < BANK_III_PFII_metadata_line_8_____JPMORGAN_20240508 >									
	//        < hZn80C2WP16B0PcBAMYZbE2SuL10ddYzHwOc2Y8c8RY28vZp3655SLCJj7i638ii >									
	//        <  u =="0.000000000000000001" : ] 000000075232650.659466400000000000 ; 000000085831844.910093100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000072CBC182F810 >									
	//     < BANK_III_PFII_metadata_line_9_____WACHOVIA_20240508 >									
	//        < rV5zh6I4C2J8k44Z2Lia7r63vm1f9wzqcK4jSOJGuBQ6XGZ4661YAkjqIA22z22g >									
	//        <  u =="0.000000000000000001" : ] 000000085831844.910093100000000000 ; 000000096392683.578771600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000082F810931564 >									
	//     < BANK_III_PFII_metadata_line_10_____CITIBANK_20240508 >									
	//        < 4jnr0Bfx0IH82GBw7Gus3q8208XPPe7PmJbmJn9uVr0cwMy479kr1c3iJh6sjQbR >									
	//        <  u =="0.000000000000000001" : ] 000000096392683.578771600000000000 ; 000000107128847.832229000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000931564A37735 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_III_PFII_metadata_line_11_____WASHINGTON MUTUAL_20240508 >									
	//        < gtpU0A8znW15uV4VFKydcFD1X6Y75Kik97O043ZcPe27aSw46176QTSFK4ly907s >									
	//        <  u =="0.000000000000000001" : ] 000000107128847.832229000000000000 ; 000000118049452.089677000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A37735B42111 >									
	//     < BANK_III_PFII_metadata_line_12_____SUN TRUST BANKS_20240508 >									
	//        < L3PTe8tcpqgV93030cyVw8J8VXjyn5xhcS11E7RW6U82QFAD9O12hQufcvR0257Q >									
	//        <  u =="0.000000000000000001" : ] 000000118049452.089677000000000000 ; 000000128922872.179010000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B42111C4B87F >									
	//     < BANK_III_PFII_metadata_line_13_____US BANCORP_20240508 >									
	//        < q284L2Q2z0a17fZ4n239eszECyzlm760XK557W1ANz52A26qTOR93YdV4C4CXQ19 >									
	//        <  u =="0.000000000000000001" : ] 000000128922872.179010000000000000 ; 000000139706243.998945000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C4B87FD52CC0 >									
	//     < BANK_III_PFII_metadata_line_14_____REGIONS BANK_20240508 >									
	//        < Hsrz2TE3LWvg1dXTyspQM495jr66T2HtN4872IMoyCu4nR6OB8vREVcL2s4jeuKp >									
	//        <  u =="0.000000000000000001" : ] 000000139706243.998945000000000000 ; 000000150488426.745639000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D52CC0E5A08B >									
	//     < BANK_III_PFII_metadata_line_15_____FEDERAL RESERVE BANK_20240508 >									
	//        < 35HVLHh3m9jIr8O7F1u021qB8rF42bC4ERJ21DT578a1X4v3jmkvGaIhj641iviq >									
	//        <  u =="0.000000000000000001" : ] 000000150488426.745639000000000000 ; 000000161343256.164819000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E5A08BF630B6 >									
	//     < BANK_III_PFII_metadata_line_16_____BRANCH BANKING AND TRUST COMPANY_20240508 >									
	//        < L8D2Bo3M3Eg2uNjXVoUP1ZE3Pk46YhKDBaD7rr1J792k2GtbSmLRscTY97iAyU2a >									
	//        <  u =="0.000000000000000001" : ] 000000161343256.164819000000000000 ; 000000172092212.851038000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F630B61069785 >									
	//     < BANK_III_PFII_metadata_line_17_____NATIONAL CITI BANK_20240508 >									
	//        < 6ZKuTBLF85zp1oY5Wa1f3g0PW3RtYo2W22dLpQB5ibFB06R05341JpJ1Sl2oawiT >									
	//        <  u =="0.000000000000000001" : ] 000000172092212.851038000000000000 ; 000000182920597.865955000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010697851171D5C >									
	//     < BANK_III_PFII_metadata_line_18_____HSBC BANK USA_20240508 >									
	//        < jn6449124iS896ZsR3Dm4JjYwUJ4zn77XY09G9M327Mbblk2MlVxO4DFwKKJ3zh8 >									
	//        <  u =="0.000000000000000001" : ] 000000182920597.865955000000000000 ; 000000193592684.924767000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001171D5C1276624 >									
	//     < BANK_III_PFII_metadata_line_19_____WORLD SAVINGS BANKS_FSB_20240508 >									
	//        < PuBP0T3g03La347nQ747V0v8rp61APov55m2U0SXwW9A6jl818KSccdfVSMDJKN3 >									
	//        <  u =="0.000000000000000001" : ] 000000193592684.924767000000000000 ; 000000204245459.500299000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001276624137A762 >									
	//     < BANK_III_PFII_metadata_line_20_____COUNTRYWIDE BANK_20240508 >									
	//        < vhE537YnbnCAgU48PAY73CFa19XN886V7LHO7whx1aWKqGSNR48Vhx9847SZs8kO >									
	//        <  u =="0.000000000000000001" : ] 000000204245459.500299000000000000 ; 000000215148962.369990000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000137A7621484A90 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_III_PFII_metadata_line_21_____PNC BANK_PITTSBURG_II_20240508 >									
	//        < 7ghRyNKZUNHvaEuDavs7W7132hEVc7A7ynB1r2zzK7g93fY05ro98F4j8E9qBgdZ >									
	//        <  u =="0.000000000000000001" : ] 000000215148962.369990000000000000 ; 000000225825927.104916000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001484A901589541 >									
	//     < BANK_III_PFII_metadata_line_22_____KEYBANK_20240508 >									
	//        < g3m7r2008Fi09XdID6YWcli2dQes8ud7mk2a0y5j2j6ee5bCemO3HCJpX0r29SIV >									
	//        <  u =="0.000000000000000001" : ] 000000225825927.104916000000000000 ; 000000236500395.094014000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001589541168DEF8 >									
	//     < BANK_III_PFII_metadata_line_23_____ING BANK_FSB_20240508 >									
	//        < kB2R34R29d7vhFL6NM2aOzr876C6C1Ns4eHdm2R0ga6L5F29WZ8Mx63ksTci0Iz2 >									
	//        <  u =="0.000000000000000001" : ] 000000236500395.094014000000000000 ; 000000247357139.785075000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000168DEF81796FE2 >									
	//     < BANK_III_PFII_metadata_line_24_____MERRILL LYNCH BANK USA_20240508 >									
	//        < At9OHHl21DK9gZKXFVhgcOiXO29m45N6InpD41lbgbgJn6NmV6YJJWBT6R922k9v >									
	//        <  u =="0.000000000000000001" : ] 000000247357139.785075000000000000 ; 000000258154871.607467000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001796FE2189E9BF >									
	//     < BANK_III_PFII_metadata_line_25_____SOVEREIGN BANK_20240508 >									
	//        < 4ycao96q78cA2V6FxVVxM58nlzm0w121jtLSoy164H76K69UQgcl9tRok97nLwcJ >									
	//        <  u =="0.000000000000000001" : ] 000000258154871.607467000000000000 ; 000000268755843.323985000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000189E9BF19A16C0 >									
	//     < BANK_III_PFII_metadata_line_26_____COMERICA BANK_20240508 >									
	//        < iTt6Y8ioZmn0j7UBKM54IGM8IMh7v40Vem438ka6k9xRd5tuBfaxtEby6dfi261B >									
	//        <  u =="0.000000000000000001" : ] 000000268755843.323985000000000000 ; 000000279359676.879072000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019A16C01AA44E0 >									
	//     < BANK_III_PFII_metadata_line_27_____UNION BANK OF CALIFORNIA_20240508 >									
	//        < p49QE25H21lX7q114o00My5y1fy5666yTDHZi3uneiUVR3A6t310cgUuDK0qdKUx >									
	//        <  u =="0.000000000000000001" : ] 000000279359676.879072000000000000 ; 000000290038989.687210000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AA44E01BA907B >									
	//     < BANK_III_PFII_metadata_line_28_____ING BANK_20240508 >									
	//        < NqE3P6Q4SjM4c5jcUz63v1SG0Z39duYcUI6CZ5n4nyQ527n2NMdlLBh4kx7xF092 >									
	//        <  u =="0.000000000000000001" : ] 000000290038989.687210000000000000 ; 000000300844443.457165000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BA907B1CB0D5C >									
	//     < BANK_III_PFII_metadata_line_29_____DEKA BANK_20240508 >									
	//        < gzjq7FwsH3XsV01hSv57cH5Z5xt27mH0wlf7D0i7QXZukx1R422U3GdHjr9wQQ9H >									
	//        <  u =="0.000000000000000001" : ] 000000300844443.457165000000000000 ; 000000311434475.991359000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CB0D5C1DB3618 >									
	//     < BANK_III_PFII_metadata_line_30_____BNPPARIBAS_20240508 >									
	//        < DcQ3sHLHhD3XEsZ41TXG496MjO5Nc7T3s18Q6w0nK6bX849n7zZwhy70BntY9vtb >									
	//        <  u =="0.000000000000000001" : ] 000000311434475.991359000000000000 ; 000000322130939.719198000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DB36181EB8866 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < BANK_III_PFII_metadata_line_31_____SOCIETE GENERALE  _20240508 >									
	//        < bF80IrnJI76arLhrtM247D43aCQEugXfBst1tlvoF9xU2mn55Jf2T2avwc61kJo6 >									
	//        <  u =="0.000000000000000001" : ] 000000322130939.719198000000000000 ; 000000332828115.820151000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EB88661FBDAFC >									
	//     < BANK_III_PFII_metadata_line_32_____CREDIT_AGRICOLE_SA_20240508 >									
	//        < AS9SDBG05SKyJ05s25VCvak4118f463ymxr22hBORNXC3J28xqyk638SRFf8ww1G >									
	//        <  u =="0.000000000000000001" : ] 000000332828115.820151000000000000 ; 000000343472688.709208000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FBDAFC20C1905 >									
	//     < BANK_III_PFII_metadata_line_33_____CREDIT_MUTUEL_20240508 >									
	//        < 2GVoS9756lS95fP9xlHetRR1550742fzs10N69ssUY83M58A7KRAhTwdLl1E9Ca9 >									
	//        <  u =="0.000000000000000001" : ] 000000343472688.709208000000000000 ; 000000354164028.163167000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020C190521C6953 >									
	//     < BANK_III_PFII_metadata_line_34_____DEXIA_20240508 >									
	//        < U20n7Rcv9h56zItwD069lI6UUOap8jQ331xsJbXVwQPk11iv8wu8tg713anJ6up5 >									
	//        <  u =="0.000000000000000001" : ] 000000354164028.163167000000000000 ; 000000365031021.239166000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021C695322CFE3E >									
	//     < BANK_III_PFII_metadata_line_35_____CREDIT_INDUSTRIEL_COMMERCIAL_20240508 >									
	//        < Hd1H50jZ1bh34mDFit5z3FVxa12l0e6FY7u1x62PIV7D23wH8rbDxF069v80uLTR >									
	//        <  u =="0.000000000000000001" : ] 000000365031021.239166000000000000 ; 000000375953275.861300000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022CFE3E23DA8C0 >									
	//     < BANK_III_PFII_metadata_line_36_____SANTANDER_20240508 >									
	//        < xBv91qo07O5n8Zw58ibN84nAd398B6Mu3HP64Q91eV2Kg4FN47jN4whVdie00D0g >									
	//        <  u =="0.000000000000000001" : ] 000000375953275.861300000000000000 ; 000000386611802.359538000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023DA8C024DEC3C >									
	//     < BANK_III_PFII_metadata_line_37_____CREDIT_LYONNAIS_20240508 >									
	//        < re6lfbgx3RK613oje9isCY0rk11gr7VeBlE44qJY9yMIfA6H4SUlk2lxZROj6iZU >									
	//        <  u =="0.000000000000000001" : ] 000000386611802.359538000000000000 ; 000000397458158.597481000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024DEC3C25E7918 >									
	//     < BANK_III_PFII_metadata_line_38_____BANQUES_POPULAIRES_20240508 >									
	//        < HU4DpmFD3Y84IlSXIxbch33T3BflR83XU0Se09kp6H8pbg6660vFdAhNA62p3Kki >									
	//        <  u =="0.000000000000000001" : ] 000000397458158.597481000000000000 ; 000000408001038.358112000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025E791826E8F68 >									
	//     < BANK_III_PFII_metadata_line_39_____CAISSES_D_EPARGNE_20240508 >									
	//        < t2695s4Qw0a75ua4IbxV8y5n6NsyxWoL4o9dL58BXMt69r8f1dRyBfaC9PpPf58q >									
	//        <  u =="0.000000000000000001" : ] 000000408001038.358112000000000000 ; 000000418629597.340467000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026E8F6827EC730 >									
	//     < BANK_III_PFII_metadata_line_40_____LAZARD_20240508 >									
	//        < iYszqIC01Q539k0PJS53oi8CWI9W2LORr9y9M04cGsdoR4O20uFJML2l2g4b9406 >									
	//        <  u =="0.000000000000000001" : ] 000000418629597.340467000000000000 ; 000000429287043.125237000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027EC73028F0A40 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
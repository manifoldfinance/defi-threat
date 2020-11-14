/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFIV_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFIV_III_883		"	;
		string	public		symbol =	"	SHERE_PFIV_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1827925061033140000000000000					;	
										
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
	//     < SHERE_PFIV_III_metadata_line_1_____SHEREMETYEVO_AIRPORT_20260505 >									
	//        < v5o8wZZSlhyF861E0mGi0COWpQb5s2aNS2e0ha7MF8SrKqe4FAU9h1GR1Z1BczBm >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000031788649.320781500000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000308171 >									
	//     < SHERE_PFIV_III_metadata_line_2_____SHEREMETYEVO_INTERNATIONAL_AIRPORT_20260505 >									
	//        < v818GDEP0589fXqXK2W2ks6nAfy5LlhwH4BrVCfGccjE4cBZl358lLTLc74UQ5eE >									
	//        <  u =="0.000000000000000001" : ] 000000031788649.320781500000000000 ; 000000086093216.053513200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000308171835E2A >									
	//     < SHERE_PFIV_III_metadata_line_3_____SHEREMETYEVO_HOLDING_LLC_20260505 >									
	//        < Qf9kc0X3XI5sVJr5f50o8u46zzv6nl28y7fOtHoP4w90LhTYC1oc83YkmNTO0CR8 >									
	//        <  u =="0.000000000000000001" : ] 000000086093216.053513200000000000 ; 000000124279893.613134000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000835E2ABDA2D5 >									
	//     < SHERE_PFIV_III_metadata_line_4_____TPS_AVIA_PONOMARENKO_ORG_20260505 >									
	//        < kVMK36K9BGL7941PpSxVSfPZ0p8bp24361U71vkubAC71UW45To9GGQud7r3AFq7 >									
	//        <  u =="0.000000000000000001" : ] 000000124279893.613134000000000000 ; 000000191601968.141649000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000BDA2D51245C85 >									
	//     < SHERE_PFIV_III_metadata_line_5_____TPS_AVIA_SKOROBOGATKO_ORG_20260505 >									
	//        < 88K4Y74GvkXh0BgxY9pNhlk6HB30496SDK10i0ofWd283S9pO9o0VRew2n1B51af >									
	//        <  u =="0.000000000000000001" : ] 000000191601968.141649000000000000 ; 000000241540007.597447000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001245C851708F91 >									
	//     < SHERE_PFIV_III_metadata_line_6_____TPS_AVIA_ROTENBERG_ORG_20260505 >									
	//        < MDy6FNj02dtm7fWSBX0qtyYE2bvu2GI9hPl399HQCI1y7ypbN3qJg9aKq8YBE9f2 >									
	//        <  u =="0.000000000000000001" : ] 000000241540007.597447000000000000 ; 000000272462457.093749000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001708F9119FBEA6 >									
	//     < SHERE_PFIV_III_metadata_line_7_____ROSIMUSHCHESTVO_20260505 >									
	//        < Ic7wxM2Qt1CAeW3H65A1AXy96gtsnJKnHB8vr4Mq9p59FyzPc8GRTbcV6AOcvaUz >									
	//        <  u =="0.000000000000000001" : ] 000000272462457.093749000000000000 ; 000000323993390.611867000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019FBEA61EE5FEB >									
	//     < SHERE_PFIV_III_metadata_line_8_____VEB_CAPITAL_LLC_20260505 >									
	//        < C831P7285E9aEpDV4tc0l3sZwPNyiyS7WZQUUu3rSWh9qjE873E6t06eVvXL2j6Q >									
	//        <  u =="0.000000000000000001" : ] 000000323993390.611867000000000000 ; 000000349376721.344945000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EE5FEB2151B48 >									
	//     < SHERE_PFIV_III_metadata_line_9_____FRAPORT_20260505 >									
	//        < mIKV38x94m4u63Sw91agfU5yN0JNh0NZLZ360Zgq9sXD220PTI9JAisC812779C2 >									
	//        <  u =="0.000000000000000001" : ] 000000349376721.344945000000000000 ; 000000369440833.302454000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002151B48233B8D3 >									
	//     < SHERE_PFIV_III_metadata_line_10_____CHANGI_20260505 >									
	//        < 665jM33z9tO8YSgXixJT89595XFKP5Zx68eMfJ2DeKtSgSFE05zu9uGgSJ8dR0h1 >									
	//        <  u =="0.000000000000000001" : ] 000000369440833.302454000000000000 ; 000000397544405.056692000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000233B8D325E9AC9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIV_III_metadata_line_11_____NORTHERN_CAPITAL_GATEWAY_20260505 >									
	//        < 4hLLdaEO23e0VBI088k16BsZlQnoh2fwLtTcG7oJV86fP0G8B17yea69NPYNSTbM >									
	//        <  u =="0.000000000000000001" : ] 000000397544405.056692000000000000 ; 000000420748531.367677000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025E9AC928202E5 >									
	//     < SHERE_PFIV_III_metadata_line_12_____BASEL_AERO_20260505 >									
	//        < sETVli270rcuMFRJ81RzZS9Q1G6775UAmwJc79j6Hc930n7Fa9aY04xp2TII680y >									
	//        <  u =="0.000000000000000001" : ] 000000420748531.367677000000000000 ; 000000486357557.145890000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028202E52E61F6C >									
	//     < SHERE_PFIV_III_metadata_line_13_____SOGAZ_20260505 >									
	//        < 7tIhunH1u8YU41dLDKTO7Vg3slEKa1ZUNF47kwpY36122Nyqv4Z5X9ELWvojap0U >									
	//        <  u =="0.000000000000000001" : ] 000000486357557.145890000000000000 ; 000000523075745.596949000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E61F6C31E2677 >									
	//     < SHERE_PFIV_III_metadata_line_14_____NOVI_SAD_20260505 >									
	//        < 35AFSP4Q7BKSM2W2xvpF8Fv4D40H7KmlA4kvMc324jm6TKaU4L0hbc4FEU23Kd8r >									
	//        <  u =="0.000000000000000001" : ] 000000523075745.596949000000000000 ; 000000572825750.979551000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031E267736A100F >									
	//     < SHERE_PFIV_III_metadata_line_15_____INSURANCE_COMPANY_ALROSA_20260505 >									
	//        < MhV4k7n48ak4p31XKd100wiBOK217r56oXL8Vtn63iZvsi0m9mXG8O04Y080V2Q0 >									
	//        <  u =="0.000000000000000001" : ] 000000572825750.979551000000000000 ; 000000621107157.786066000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036A100F3B3BBFC >									
	//     < SHERE_PFIV_III_metadata_line_16_____IC_AL_SO_20260505 >									
	//        < 5JpFkL6qP0u9wUf66X88k4OC3J9Aw2aCVAcl2LDhcEV6uYcqP736997Y17afY6mV >									
	//        <  u =="0.000000000000000001" : ] 000000621107157.786066000000000000 ; 000000639398503.773530000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B3BBFC3CFA50A >									
	//     < SHERE_PFIV_III_metadata_line_17_____PIPELINE_INSURANCE_COMPANY_20260505 >									
	//        < 1rPM4YGo4q74Fr3h81b6ePQrAx75k238gliS36X3xuvb4C6376c0s52vrw1xDZ1J >									
	//        <  u =="0.000000000000000001" : ] 000000639398503.773530000000000000 ; 000000704599959.434800000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CFA50A433225C >									
	//     < SHERE_PFIV_III_metadata_line_18_____SOGAZ_MED_20260505 >									
	//        < Ixj7DyWk87gnCCX5vp1l0JdqmrcHxlz631P7M7F2eks37Qq2tmn1s5WZdwIhdEA2 >									
	//        <  u =="0.000000000000000001" : ] 000000704599959.434800000000000000 ; 000000732463815.728719000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000433225C45DA6AE >									
	//     < SHERE_PFIV_III_metadata_line_19_____IC_TRANSNEFT_20260505 >									
	//        < lohw75G147ktIxS2J2C85dN97aUoTRT8B3dr7sH7l274yWcdUUODZ7oO3lsbdWwl >									
	//        <  u =="0.000000000000000001" : ] 000000732463815.728719000000000000 ; 000000753608805.268278000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045DA6AE47DEA71 >									
	//     < SHERE_PFIV_III_metadata_line_20_____SHEKSNA_20260505 >									
	//        < 1MSCeC5eu3de41u682yZ0G74U6XKl4iC1AK8zXce51GXuD22Od2D8tyBPEpCXVOY >									
	//        <  u =="0.000000000000000001" : ] 000000753608805.268278000000000000 ; 000000842793473.315053000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047DEA715060033 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIV_III_metadata_line_21_____Akcionarsko Drustvo Zaosiguranje_20260505 >									
	//        < in5ko6ZA2Ux157PyYM6V6BSpMIw7r79GK4CYFp94OK6J0S066H5o2Dy210j0VV57 >									
	//        <  u =="0.000000000000000001" : ] 000000842793473.315053000000000000 ; 000000867760599.713769000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000506003352C18FC >									
	//     < SHERE_PFIV_III_metadata_line_22_____SOGAZ_LIFE_20260505 >									
	//        < 3O44NRA4O7Rn6B7w4ghaMpHMRXD4t7gj3VLLfM82zV7QQkc805yD03uSJx39LJIy >									
	//        <  u =="0.000000000000000001" : ] 000000867760599.713769000000000000 ; 000000895067630.698074000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052C18FC555C3CB >									
	//     < SHERE_PFIV_III_metadata_line_23_____SOGAZ_SERBIA_20260505 >									
	//        < 1TkYIce92rC6o22190kVSAHEqZx7ND6viq4I3Z9gB6CsuUSx24Q727nJa3yKlbg6 >									
	//        <  u =="0.000000000000000001" : ] 000000895067630.698074000000000000 ; 000000921868940.914353000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000555C3CB57EA90E >									
	//     < SHERE_PFIV_III_metadata_line_24_____ZHASO_20260505 >									
	//        < HNGQ4US9T66gnphrG76Q7fz0fe18AJy265wk15BQO5FDevhjM8Hf948F0anylPi7 >									
	//        <  u =="0.000000000000000001" : ] 000000921868940.914353000000000000 ; 000000968489918.742412000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057EA90E5C5CC60 >									
	//     < SHERE_PFIV_III_metadata_line_25_____VTB_INSURANCE_ORG_20260505 >									
	//        < qRPA2BLvsK1257t4WHsFpwQ8IZaLF1oYnxGNxBZ9o2ObRmCgxN0T8jELvrwmD47u >									
	//        <  u =="0.000000000000000001" : ] 000000968489918.742412000000000000 ; 000001019095073.648170000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C5CC606130403 >									
	//     < SHERE_PFIV_III_metadata_line_26_____Vympel_Vostok_20260505 >									
	//        < I767XtllA21aX6fjpOyOvNs7xjBo5UgA9Op2JlblZ8GagSbRc2UG0vlVGMefANvl >									
	//        <  u =="0.000000000000000001" : ] 000001019095073.648170000000000000 ; 000001064159202.064700000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006130403657C730 >									
	//     < SHERE_PFIV_III_metadata_line_27_____Oblatsnaya_Meditsinskaya_Strakho__20260505 >									
	//        < lQYXVIHGz2AC22uU6RQZO1EBheX8PA51npUHKTakSmMj9Kyvlf99Vk00Un383fWW >									
	//        <  u =="0.000000000000000001" : ] 000001064159202.064700000000000000 ; 000001109210927.186800000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000657C73069C8585 >									
	//     < SHERE_PFIV_III_metadata_line_28_____Medika_Tomsk_20260505 >									
	//        < h28DN4p446nGNB2fT9Ak07BxV3rC87t2B56lC9C7d3jmge2S4y1D9Q4xeKVv2mhJ >									
	//        <  u =="0.000000000000000001" : ] 000001109210927.186800000000000000 ; 000001174423511.605880000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000069C8585700072F >									
	//     < SHERE_PFIV_III_metadata_line_29_____Medical_Insurance_Company_20260505 >									
	//        < gi2G2c4hhPU55XT7A4zIH6043HJDhZ9kvT41K6IiSLc3oIYKpfFLZjqG39aXw154 >									
	//        <  u =="0.000000000000000001" : ] 000001174423511.605880000000000000 ; 000001237383469.046330000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000700072F76018EB >									
	//     < SHERE_PFIV_III_metadata_line_30_____MSK_MED_20260505 >									
	//        < S5nB3lnOUQXpZsJO3snM382R1ceb66S0ve36wa421au06O649ekrCDvsm4yaup9L >									
	//        <  u =="0.000000000000000001" : ] 000001237383469.046330000000000000 ; 000001261881997.143200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000076018EB7857AA8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFIV_III_metadata_line_31_____SG_MSK_20260505 >									
	//        < E2MmmdS77cD1Ruuo3n2O4Q2iePZA8XTz6IJdWYt31064UQKkX9y8K6n3I2Ms6L50 >									
	//        <  u =="0.000000000000000001" : ] 000001261881997.143200000000000000 ; 000001353531853.971640000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007857AA88115361 >									
	//     < SHERE_PFIV_III_metadata_line_32_____ROSNO_MS_20260505 >									
	//        < h83R41k5649lL2dKfGij6mSscDhtHC5EOfdsl188sROAwi535DiOjJbNxreO0m7M >									
	//        <  u =="0.000000000000000001" : ] 000001353531853.971640000000000000 ; 000001410432493.469590000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000081153618682631 >									
	//     < SHERE_PFIV_III_metadata_line_33_____VTB_Life_Insurance_20260505 >									
	//        < uGIMjPOkye88ZPzgUabyWT1yCZy0M0np9qmHJFb9VWwr7KtpF3350uvJu18FaP95 >									
	//        <  u =="0.000000000000000001" : ] 000001410432493.469590000000000000 ; 000001489195467.548820000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000086826318E054FB >									
	//     < SHERE_PFIV_III_metadata_line_34_____Company_Moskovsko__20260505 >									
	//        < 93809G9ua0d120XD2YzvVDOsj4nZhLe759Hj7lgi52LA2h5Mux2Ez036GdoeKqe1 >									
	//        <  u =="0.000000000000000001" : ] 000001489195467.548820000000000000 ; 000001514933573.801260000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008E054FB9079AED >									
	//     < SHERE_PFIV_III_metadata_line_35_____VTB_Meditsinskoye_Strakho__20260505 >									
	//        < J3t7VR4uPzeuGakKcqUlDJ82nmX01VDSB08RtBG0D49YPw2v6rRVJNpVxfr63Ro3 >									
	//        <  u =="0.000000000000000001" : ] 000001514933573.801260000000000000 ; 000001545029520.479650000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009079AED9358728 >									
	//     < SHERE_PFIV_III_metadata_line_36_____SPASSKIYE_VOROTA_INSURANCE_GROUP_20260505 >									
	//        < UL74X0mpAcrlk721vo7p9Z1ym8Tk0Ut4ru4YZ072jYHIK0Tbs8C8BT2gLm02DlXb >									
	//        <  u =="0.000000000000000001" : ] 000001545029520.479650000000000000 ; 000001630146138.876820000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000093587289B767D6 >									
	//     < SHERE_PFIV_III_metadata_line_37_____CASCO_MED_INS_20260505 >									
	//        < C3tluI6rm8h94JFuhQFeb0fcZ6rPJEK56N2em8YM1XE6DnE30LCKTPIEEK6Jjfw0 >									
	//        <  u =="0.000000000000000001" : ] 000001630146138.876820000000000000 ; 000001666378577.855020000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009B767D69EEB122 >									
	//     < SHERE_PFIV_III_metadata_line_38_____SMK_NOVOLIPETSKAYA_20260505 >									
	//        < p3PW820vPcTo5v9i6Ts26Uk156r3uEOgFZWcwYU0u2J88Oz7EuoC3pk369b83SV6 >									
	//        <  u =="0.000000000000000001" : ] 000001666378577.855020000000000000 ; 000001740943441.103290000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009EEB122A607808 >									
	//     < SHERE_PFIV_III_metadata_line_39_____MOSKOVSKOE_PERETRAKHOVOCHNOE_OBSHESTVO_20260505 >									
	//        < 5vtbs2L6lYp0G0dvPbAJcN47a863K1K22WtvDUIiWX3t8KEh3yv7D39oBKr3T78M >									
	//        <  u =="0.000000000000000001" : ] 000001740943441.103290000000000000 ; 000001767569670.438950000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A607808A8918E7 >									
	//     < SHERE_PFIV_III_metadata_line_40_____RESO_20260505 >									
	//        < m6W7I8QLEyhSTzypB3Eqdz9bAU0817cwnCZ40QfAPk2O0Ijm8w1oKrELq0W4bq8b >									
	//        <  u =="0.000000000000000001" : ] 000001767569670.438950000000000000 ; 000001827925061.033140000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A8918E7AE5313A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
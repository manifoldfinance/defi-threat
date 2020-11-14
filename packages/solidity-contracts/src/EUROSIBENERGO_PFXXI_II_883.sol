/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 27, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
									
contract	EUROSIBENERGO_PFXXI_II_883				{				
									
	mapping (address => uint256) public balanceOf;								
									
	string	public		name =	"	EUROSIBENERGO_PFXXI_II_883		"	;
	string	public		symbol =	"	EUROSIBENERGO_PFXXI_II_IMTD		"	;
	uint8	public		decimals =		18			;
									
	uint256 public totalSupply =		1067296706080140000000000000					;	
									
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
//     < EUROSIBENERGO_PFXXI_II_metadata_line_1_____Irkutskenergo_JSC_20240321 >									
//        < 7vorjeG35WPLCWj0Y1440ks0ebqeEQMnzPCI2z5VSs22nmEfj2Sao206G7AJwcKZ >									
//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000032267646.371695600000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000000000000313C8D >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_2_____Irkutskenergo_PCI_20240321 >									
//        < ifB4FzER2JKAua658041XE9uABu0uVI4D36gR0o4g2G399aA0AW34xHp1Tjp9On6 >									
//        <  u =="0.000000000000000001" : ] 000000032267646.371695600000000000 ; 000000064967457.696304800000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000000313C8D6321EA >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_3_____Irkutskenergo_PCI_Bratsk_20240321 >									
//        < MZnP4iM5o1AU5nVl2Yf1drWngpXi83y92DB02K1avB94xFPh718JxhpU354aWpwO >									
//        <  u =="0.000000000000000001" : ] 000000064967457.696304800000000000 ; 000000091988354.680387900000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000006321EA8C5CF3 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_4_____Irkutskenergo_PCI_Ust_Ilimsk_20240321 >									
//        < bizk9q4XDyATrJWkTesnJU5GCSc8co6yHO1qMSJukle0De8XmTv8Ces3w5hDC0v5 >									
//        <  u =="0.000000000000000001" : ] 000000091988354.680387900000000000 ; 000000120299537.146481000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000008C5CF3B79002 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_5_____Irkutskenergo_Bratsk_org_spe_20240321 >									
//        < Pnrog5sWnsDCr6YBX01H76X94PLqz3l4nB5xS30442f84Fe4p3OMjoMK61c6coyx >									
//        <  u =="0.000000000000000001" : ] 000000120299537.146481000000000000 ; 000000156044466.906852000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000000B79002EE1ADF >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_6_____Irkutskenergo_Ust_Ilimsk_org_spe_20240321 >									
//        < l4H6BY5U85poRVG37682Bs73Jl1SK7282lY0J4W1py594SlefS2e15Y0Lcvv2bp9 >									
//        <  u =="0.000000000000000001" : ] 000000156044466.906852000000000000 ; 000000183560702.964399000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000EE1ADF1181766 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_7_____Oui_Energo_Limited_s_China_Yangtze_Power_Company_20240321 >									
//        < 6Bn8U12hZCX4CMPc2O9MGGxUa0ZS7pv0d39jv9mN49zGZdOf7076Q6b4AgbAB7Am >									
//        <  u =="0.000000000000000001" : ] 000000183560702.964399000000000000 ; 000000208545282.267371000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000118176613E3700 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_8_____China_Yangtze_Power_Company_limited_20240321 >									
//        < Iq6NGB7NUDB1u7SgF41Uq9Mj9By2xr0bI54l068T7SYdNm28miOY1T05nPh7i57C >									
//        <  u =="0.000000000000000001" : ] 000000208545282.267371000000000000 ; 000000242071276.991109000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000013E37001715F18 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_9_____Three_Gorges_Electric_Power_Company_Limited_20240321 >									
//        < 4N1G58g5alJjJd9SnLR0SuXh8889H6M3huhSPAm8VplDt5frlsqI59FjOMbKAug5 >									
//        <  u =="0.000000000000000001" : ] 000000242071276.991109000000000000 ; 000000266822212.521806000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001715F18197236D >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_10_____Beijing_Yangtze_Power_Innovative_Investment_Management_Company_Limited_20240321 >									
//        < WAvkqBUS5OXH9HdVTdoq2Q6311zGM89K3Nqv55ccr0ShQW4nX6a0laNYLc84q3Zd >									
//        <  u =="0.000000000000000001" : ] 000000266822212.521806000000000000 ; 000000290782450.535679000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000197236D1BBB2E5 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < EUROSIBENERGO_PFXXI_II_metadata_line_11_____Three_Gorges_Jinsha_River_Chuanyun_Hydropower_Development_Company_Limited_20240321 >									
//        < q272RaTuvHCdTq42DknG0mmmui97tHlzQax0Q5973J1G039dw6PWkkKL47wWMcaL >									
//        <  u =="0.000000000000000001" : ] 000000290782450.535679000000000000 ; 000000318249436.324908000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001BBB2E51E59C30 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_12_____Changdian_Capital_Holding_Company_Limited_20240321 >									
//        < GRd82jB0TBr1Pi49L7mz985VKI7lXo32NONNQT4c4TfejL7uBf7lf03NCz33zsTR >									
//        <  u =="0.000000000000000001" : ] 000000318249436.324908000000000000 ; 000000346318085.053310000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001E59C302107081 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_13_____Eurosibenergo_OJSC_20240321 >									
//        < QDOg062VGuTTHRSCB98rw03DNHvcOtw7nv33IunrXDE5zQQroH973mscdxPnXr74 >									
//        <  u =="0.000000000000000001" : ] 000000346318085.053310000000000000 ; 000000365762724.846158000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000210708122E1C10 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_14_____Baikalenergo_JSC_20240321 >									
//        < Jm8a8roiQn1O6jm8cP620ZXZL8x91i0yBNK7XkJlfABYj7cbs6W41W583OUAQnPn >									
//        <  u =="0.000000000000000001" : ] 000000365762724.846158000000000000 ; 000000395743287.130081000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000022E1C1025BDB39 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_15_____Sayanogorsk_Teploseti_20240321 >									
//        < CmF72mknSTO2be8U8wb85UcfLa2vA6Q6BUy1kCx2Z2WYLX1laQLY4MvUNt1ART58 >									
//        <  u =="0.000000000000000001" : ] 000000395743287.130081000000000000 ; 000000424487381.941898000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000025BDB39287B762 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_16_____China_Yangtze_Power_International_Hong_Kong_Company_Limited_20240321 >									
//        < 4jPw9LT2u72Sz5UnX6ftg7IvrTBbAE8A2Q38dhw5Eod8YGVi2b7dLJoWrW71R6f4 >									
//        <  u =="0.000000000000000001" : ] 000000424487381.941898000000000000 ; 000000451710176.837997000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000287B7622B1414A >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_17_____Fujian_Electric_Distribution_Sale_COmpany_Limited_20240321 >									
//        < L8Y6o2rM5wxb363Y050MHP9wVCcfGX974EOQ5t5g18mF1T0dP4511LEMgwTNKRS7 >									
//        <  u =="0.000000000000000001" : ] 000000451710176.837997000000000000 ; 000000486149975.432702000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000002B1414A2E5CE56 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_18_____Bohai_Ferry_Group_20240321 >									
//        < 7n62N02ZFf1w215lmZ19D4y2S647VG9S32rPYQ0JTMKwx70Wm7vi4q1d6dAcKKA4 >									
//        <  u =="0.000000000000000001" : ] 000000486149975.432702000000000000 ; 000000514601124.186520000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000002E5CE563113810 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_19_____Eurosibenergo_OJSC_20240321 >									
//        < 095b8Wl3XfUH7O1oV323KN1l9k1YIMr6qBH466F48u7EiQ6h66YFN9Vn9yk46AbD >									
//        <  u =="0.000000000000000001" : ] 000000514601124.186520000000000000 ; 000000537692528.650708000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000031138103347425 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_20_____Krasnoyarskaya_HPP_20240321 >									
//        < oJ54pis6F96hSrrlFKLlaAS43cEVSTYol6ll444myQG6oCxBb5y709QpUGpP1Q52 >									
//        <  u =="0.000000000000000001" : ] 000000537692528.650708000000000000 ; 000000561095932.094213000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000033474253582A19 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < EUROSIBENERGO_PFXXI_II_metadata_line_21_____ERA_Group_OJSC_20240321 >									
//        < f2lKa31dEYv2cvlikSlw287T90VFy0EnPlKt8N9wxomURz6azjl91C569XoM80bD >									
//        <  u =="0.000000000000000001" : ] 000000561095932.094213000000000000 ; 000000591385214.501297000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000003582A1938661D9 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_22_____Russky_Kremny_LLC_20240321 >									
//        < oBeL3Da4z8bypre1C65EJN4zN99hgwK15zbGYTO7L07TK8r5nWiX6qGt1ZL1B2x2 >									
//        <  u =="0.000000000000000001" : ] 000000591385214.501297000000000000 ; 000000615113840.208197000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000038661D93AA96D8 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_23_____Avtozavodskaya_org_spe_20240321 >									
//        < P04RdIO20L4ShaA6zFs9sW70RN2ODssMMy5n5dCj3f5ORB50gt8eOjCBw2vXarSb >									
//        <  u =="0.000000000000000001" : ] 000000615113840.208197000000000000 ; 000000643585175.579072000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000003AA96D83D60876 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_24_____Irkutsk_Electric_Grid_Company_20240321 >									
//        < My4ZJdP8aD0n06O2110EqM5H0cu9B47k77NCtlQ35ta50F7Kbj97Alh4gtG5Of3Y >									
//        <  u =="0.000000000000000001" : ] 000000643585175.579072000000000000 ; 000000664943486.492450000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000003D608763F69F8D >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_25_____Eurosibenergo_OJSC_20240321 >									
//        < d219ma4n71q0Yx4F37NfPWrCn8S3H41R2vHgeBGDv7Le62r3vz8tyqB36Bv5k2a6 >									
//        <  u =="0.000000000000000001" : ] 000000664943486.492450000000000000 ; 000000689531042.887379000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000003F69F8D41C2410 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_26_____Eurosibenergo_LLC_distributed_generation_20240321 >									
//        < 8vx5626mt2D3tZ3l28C4jy2eUWA8SvsNG7cBBFM4uh0BRO04gAP9e3EG29xcq2Wv >									
//        <  u =="0.000000000000000001" : ] 000000689531042.887379000000000000 ; 000000712025453.972248000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000041C241043E76F1 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_27_____Generatsiya_OOO_20240321 >									
//        < 4Ypatjj9l3DNZPFqX0rk6n8a4xkPT0871e0laQH88mrD5TPqo6lhRYAB7mY7JDy1 >									
//        <  u =="0.000000000000000001" : ] 000000712025453.972248000000000000 ; 000000737465518.593716000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000043E76F14654878 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_28_____Eurosibenergo_LLC_distributed_gen_NIZHEGORODSKIY_20240321 >									
//        < pP36dQ076Fp30I41Siiex6T6m3d6r2Bw44Y0Jk1SaUu0JojKuDjV4ij2z71Tx4K2 >									
//        <  u =="0.000000000000000001" : ] 000000737465518.593716000000000000 ; 000000768830329.900089000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000046548784952459 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_29_____Angara_Yenisei_org_spe_20240321 >									
//        < igkF795N1k25Ng8PfnHYpS3gZ0xYw9ZB269750k85W2y7t1GdWhkq8FtZuCp6O90 >									
//        <  u =="0.000000000000000001" : ] 000000768830329.900089000000000000 ; 000000791960217.748539000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000049524594B86F76 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_30_____Yuzhno_Yeniseisk_org_spe_20240321 >									
//        < e8z0tGzD27qNxA420ciLFlh0Cqk27wPeVvp2hV7c8dsE3tayr47qZl48Q19ko30Z >									
//        <  u =="0.000000000000000001" : ] 000000791960217.748539000000000000 ; 000000829914811.828960000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000004B86F764F25979 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < EUROSIBENERGO_PFXXI_II_metadata_line_31_____Teploseti_LLC_20240321 >									
//        < kPeEJvN5fQP29406N1Hd9V15NiPw8H1Q086o7X13vmfgA6gXE904OPK69RBxM6x0 >									
//        <  u =="0.000000000000000001" : ] 000000829914811.828960000000000000 ; 000000854918985.906999000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000004F2597951880BB >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_32_____Eurosibenergo_Engineering_LLC_20240321 >									
//        < RKsr3DC3smRceq0TLo41Pji65khPiDes2VyKcrZ3eJK6ADenx7q6MOgl6813wKqg >									
//        <  u =="0.000000000000000001" : ] 000000854918985.906999000000000000 ; 000000873375690.246058000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000051880BB534AA61 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_33_____EurosibPower_Engineering_20240321 >									
//        < Qq7vpk2Mi30V6gGgRBWgcHIJsJ4dT7gC1FYj1p93bsDKiOHfOWjj7Znmh8TLY95p >									
//        <  u =="0.000000000000000001" : ] 000000873375690.246058000000000000 ; 000000908653756.427090000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000534AA6156A7EE0 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_34_____Eurosibenergo_hydrogeneration_LLC_20240321 >									
//        < Lo1TXDHc9E1tl5duY6TL9Vh48Xy7sQI543O9vv8Ah9RWLzFR11vTsNXq6ITZLcDt >									
//        <  u =="0.000000000000000001" : ] 000000908653756.427090000000000000 ; 000000937310600.217824000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000056A7EE059638F4 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_35_____Mostootryad_org_spe_20240321 >									
//        < O7814XxhIf942tjDRZM3W8dbsEivYLnwyYayxLH9vV5x7eLTy0bxNMu45A06IYmO >									
//        <  u =="0.000000000000000001" : ] 000000937310600.217824000000000000 ; 000000961439038.467975000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000059638F45BB0A20 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_36_____Irkutskenergoremont_CJSC_20240321 >									
//        < D4BBVfF3a2KBzIFZjL5v5qP12219zbFajLK1k219548B7JejAkhmA7L8VMJ6uVTp >									
//        <  u =="0.000000000000000001" : ] 000000961439038.467975000000000000 ; 000000982639774.409360000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000005BB0A205DB63A9 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_37_____Irkutsk_Energy_Retail_20240321 >									
//        < DgOv63f5FNyoQPM12rJdLyTLWhO3R71Pr460vt62aS01ZP4hmG695f81kJ63n5Ij >									
//        <  u =="0.000000000000000001" : ] 000000982639774.409360000000000000 ; 000001002722560.777030000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000005DB63A95FA0880 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_38_____Iirkutskenergo_PCI_Irkutsk_20240321 >									
//        < g8G03x63gZkE0P74mw2y3761SKPu930J16TM477QWAEyvpOOh9JWF6q658TSVz0U >									
//        <  u =="0.000000000000000001" : ] 000001002722560.777030000000000000 ; 000001027360966.716990000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000005FA088061FA0E1 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_39_____Iirkutskenergo_Irkutsk_org_spe_20240321 >									
//        < b2O6vQk00s3LPdX19tyr1veLeLqSD8y4Ro5V70Ble6PsCA8dt4YH1FA9Wwy3R56X >									
//        <  u =="0.000000000000000001" : ] 000001027360966.716990000000000000 ; 000001045788636.762810000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000061FA0E163BBF30 >									
//     < EUROSIBENERGO_PFXXI_II_metadata_line_40_____Monchegorskaya_org_spe_20240321 >									
//        < o25aR5S2rmXZ6kHOfr2x0KiNViNL6QbUvANy4623WHb8b5yVEhYaeFPqc6Y4bzux >									
//        <  u =="0.000000000000000001" : ] 000001045788636.762810000000000000 ; 000001067296706.080140000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000063BBF3065C90C7 >									
									
}
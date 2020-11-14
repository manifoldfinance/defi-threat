/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 		^0.4.21	;						
										
	contract	SHERE_PFI_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	SHERE_PFI_II_883		"	;
		string	public		symbol =	"	SHERE_PFI_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1334947877391940000000000000					;	
										
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
	//     < SHERE_PFI_II_metadata_line_1_____UNITED_AIRCRAFT_CORPORATION_20220505 >									
	//        < 63JVh07EM0b075r985UqP639I83C6NwA9x1Bovkk108LqxiAb9J1wpGcRdQF6c72 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000034780256.788034500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000035120A >									
	//     < SHERE_PFI_II_metadata_line_2_____China_Russia Commercial Aircraft International Corporation Co_20220505 >									
	//        < Ng7CHWvK36c7Y8R8xUv2tCJQyjY5WTI5y6VZFAJDpyqX7jcGaW702j77v0VQ7SG6 >									
	//        <  u =="0.000000000000000001" : ] 000000034780256.788034500000000000 ; 000000054790009.291546900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000035120A539A59 >									
	//     < SHERE_PFI_II_metadata_line_3_____CHINA_RUSSIA_ORG_20220505 >									
	//        < s81KhS39I37CWp27NCf68Y53zu9u1q9T4a75uYCGfXt59QOgd8lZOkT6s6ML5e47 >									
	//        <  u =="0.000000000000000001" : ] 000000054790009.291546900000000000 ; 000000101309064.063707000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000539A599A95DA >									
	//     < SHERE_PFI_II_metadata_line_4_____Mutilrole Transport Aircraft Limited_20220505 >									
	//        < N5h0xec6SP1WfP4ScmM0i53l72Bg70xuDlUr8LsqGBzxE7TKnS77hbB087hpfw38 >									
	//        <  u =="0.000000000000000001" : ] 000000101309064.063707000000000000 ; 000000143827758.809600000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009A95DADB76B8 >									
	//     < SHERE_PFI_II_metadata_line_5_____SuperJet International_20220505 >									
	//        < 0109jnw3vu06160WBzbG5EJ7J7H2b3ZgG9Tvb0Oc59ds22lDJyRpQ7MX32oJVM15 >									
	//        <  u =="0.000000000000000001" : ] 000000143827758.809600000000000000 ; 000000161932073.419812000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DB76B8F716B7 >									
	//     < SHERE_PFI_II_metadata_line_6_____SUPERJET_ORG_20220505 >									
	//        < MMOAQ0F7V6B72KCu2VGIKEmN0AQ6KZCA3Msi2LnO5vad4HKtEj3rVKkH280m1BnF >									
	//        <  u =="0.000000000000000001" : ] 000000161932073.419812000000000000 ; 000000209999691.895549000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F716B71406F21 >									
	//     < SHERE_PFI_II_metadata_line_7_____JSC KAPO-Composit_20220505 >									
	//        < 6UZIn7Nmdg0U7jJ9HF80SRiXKsC6zXZdqDCPE1u485ch7Y2QNmO650UP32261b8l >									
	//        <  u =="0.000000000000000001" : ] 000000209999691.895549000000000000 ; 000000234342485.651263000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001406F211659409 >									
	//     < SHERE_PFI_II_metadata_line_8_____JSC Aviastar_SP_20220505 >									
	//        < 2v6Hd5V88aFVJ1M0kSF9R2Z4v3F06NFQp941Y9D321fkl2h38bR7R24R24Y6S4jv >									
	//        <  u =="0.000000000000000001" : ] 000000234342485.651263000000000000 ; 000000252132796.244780000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001659409180B960 >									
	//     < SHERE_PFI_II_metadata_line_9_____JSC AeroKompozit_20220505 >									
	//        < 5Nm7YdB7srNv4fU4894X1Lup13V57Gb37n8nLItl4r77B5X8N649M40840tuRbOC >									
	//        <  u =="0.000000000000000001" : ] 000000252132796.244780000000000000 ; 000000283338276.460156000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000180B9601B05704 >									
	//     < SHERE_PFI_II_metadata_line_10_____JSC AeroComposit_Ulyanovsk_20220505 >									
	//        < 4YVagp6e7vn221JiZfRxBR6QPg4Ss3qE6D2X435vaS7z6PVntUG3Qw4T17i39p7M >									
	//        <  u =="0.000000000000000001" : ] 000000283338276.460156000000000000 ; 000000309603666.969801000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B057041D86AEF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFI_II_metadata_line_11_____JSC Sukhoi Civil Aircraft_20220505 >									
	//        < e2415JCO92m8gXDKzr1ft31A44A9C97NkwL3oYN3ynb71s6hfhb88ltJ1Cl4H3i6 >									
	//        <  u =="0.000000000000000001" : ] 000000309603666.969801000000000000 ; 000000334897947.169207000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D86AEF1FF0383 >									
	//     < SHERE_PFI_II_metadata_line_12_____SUKHOIL_CIVIL_ORG_20220505 >									
	//        < B33qGr9o7wVPGFudIADcZ458S9H7X7fZmgdL7MeIKvdU3dEcLEUO79iaTh1T303l >									
	//        <  u =="0.000000000000000001" : ] 000000334897947.169207000000000000 ; 000000354393629.061480000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FF038321CC303 >									
	//     < SHERE_PFI_II_metadata_line_13_____JSC Flight Research Institute_20220505 >									
	//        < fqf66ij2gX35V8F1IPeSnxEO2eH202vns15R15iB15KNkXK4HYD3x75i8iev8Z3N >									
	//        <  u =="0.000000000000000001" : ] 000000354393629.061480000000000000 ; 000000402208874.878552000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021CC303265B8D7 >									
	//     < SHERE_PFI_II_metadata_line_14_____JSC UAC_Transport Aircraft_20220505 >									
	//        < 12z0N3Ec9G9WBv79lL7wV4q1H9zCoaEIh9Fka0qb6trnOP1px1Y6HB78zE5ppFBl >									
	//        <  u =="0.000000000000000001" : ] 000000402208874.878552000000000000 ; 000000437195322.630678000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000265B8D729B1B6C >									
	//     < SHERE_PFI_II_metadata_line_15_____JSC Russian Aircraft Corporation MiG_20220505 >									
	//        < OBiLdV6MzjU30oMnu2P44LB4OO6d0M4RzE66d2srhGOtSgL12mgnM85o1wH311H5 >									
	//        <  u =="0.000000000000000001" : ] 000000437195322.630678000000000000 ; 000000481828809.303780000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029B1B6C2DF3661 >									
	//     < SHERE_PFI_II_metadata_line_16_____MIG_ORG_20220505 >									
	//        < qzCY2Q6nhbN2X2ufSABEj2WZh1nx9f30Utg3MB2swXRH59C9HCPj6c8OVZSWBT9d >									
	//        <  u =="0.000000000000000001" : ] 000000481828809.303780000000000000 ; 000000521322220.518034000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DF366131B797E >									
	//     < SHERE_PFI_II_metadata_line_17_____OJSC Experimental Machine-Building Plant_20220505 >									
	//        < eVL08T46p38wAx4M4JU1r4x2b46235LwpB83QJBX6LG3Da6odNgicBwfal22m17K >									
	//        <  u =="0.000000000000000001" : ] 000000521322220.518034000000000000 ; 000000546828738.376159000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031B797E34264FA >									
	//     < SHERE_PFI_II_metadata_line_18_____Irkutsk Aviation Plant_20220505 >									
	//        < w52cwIwxPy4md958gmw94I7Q6n56PsYuwcTzV7Ga23Xl0r90fWpB4Zr8YRmwB97B >									
	//        <  u =="0.000000000000000001" : ] 000000546828738.376159000000000000 ; 000000571407644.074480000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034264FA367E61C >									
	//     < SHERE_PFI_II_metadata_line_19_____Gorbunov Kazan Aviation Plant_20220505 >									
	//        < AcvHCdx1WIsZrEe7351eW3h620z3E8BQeWUhaG887e671k402ztELk2r41gdqmyr >									
	//        <  u =="0.000000000000000001" : ] 000000571407644.074480000000000000 ; 000000612495912.509460000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000367E61C3A69837 >									
	//     < SHERE_PFI_II_metadata_line_20_____Komsomolsk_on_Amur Aircraft Plant_20220505 >									
	//        < 8K9L86zwzMhnIIw9M4037MJXihHD05C43GIs0z36D9d6N6Z8pFLl5x4NrTRl0s4C >									
	//        <  u =="0.000000000000000001" : ] 000000612495912.509460000000000000 ; 000000629414177.931892000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A698373C068EA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFI_II_metadata_line_21_____Nizhny Novgorod aircraft building plant Sokol_20220505 >									
	//        < ESFI3vEosmjg30dUNCHUrS6rj5Wn0lIR7C6Oiqr3H1orsjH9BXv0d5ffmmi09Wdf >									
	//        <  u =="0.000000000000000001" : ] 000000629414177.931892000000000000 ; 000000655351931.575444000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C068EA3E7FCD9 >									
	//     < SHERE_PFI_II_metadata_line_22_____NIZHNY_ORG_20220505 >									
	//        < 46QDhScViUB75Q2lFc4FxteMSX4EgqlJImI5w0Tq7afZwdX990oSlRh7138JW0ms >									
	//        <  u =="0.000000000000000001" : ] 000000655351931.575444000000000000 ; 000000685217099.758002000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E7FCD94158EEE >									
	//     < SHERE_PFI_II_metadata_line_23_____Novosibirsk Aircraft Plant_20220505 >									
	//        < lezwYd9zk1iA0XDn6wZGY6HTU0t7Hw6sh0JXXu9LwM57khJf8NLi3IM4MwY6t641 >									
	//        <  u =="0.000000000000000001" : ] 000000685217099.758002000000000000 ; 000000718865755.257209000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004158EEE448E6F0 >									
	//     < SHERE_PFI_II_metadata_line_24_____NOVO_ORG_20220505 >									
	//        < NyRojb270HjP391sP019U122z06P6Q1rC0d82YFL0xky0Q281T593NSX5LDb637p >									
	//        <  u =="0.000000000000000001" : ] 000000718865755.257209000000000000 ; 000000766363266.772994000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000448E6F049160A7 >									
	//     < SHERE_PFI_II_metadata_line_25_____UAC Health_20220505 >									
	//        < fkYVafV1bA2MueMuQ91xYzYWS45k9mG2dz9ECONKPslfqH3YukPMTam0OX3192Y9 >									
	//        <  u =="0.000000000000000001" : ] 000000766363266.772994000000000000 ; 000000815025030.378353000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049160A74DBA127 >									
	//     < SHERE_PFI_II_metadata_line_26_____UAC_HEALTH_ORG_20220505 >									
	//        < 5PoWZBC0xe5z0DhD61Gzp9y9QBCq5818a3S6aji298d949861ZK06w77y4v2LZMq >									
	//        <  u =="0.000000000000000001" : ] 000000815025030.378353000000000000 ; 000000837120910.877878000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004DBA1274FD585B >									
	//     < SHERE_PFI_II_metadata_line_27_____JSC Ilyushin Finance Co_20220505 >									
	//        < W6I67AM9w177vimxYwf2b8Rzh19a19Jy6k4OADvoK9uFB0hY6SJ1VGZ4g2x4XpRe >									
	//        <  u =="0.000000000000000001" : ] 000000837120910.877878000000000000 ; 000000885332708.645289000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004FD585B546E917 >									
	//     < SHERE_PFI_II_metadata_line_28_____OJSC Experimental Design Bureau_20220505 >									
	//        < Mx0L97Jp3Yy0kDHz9TCqz0wg09rNiTtW2Yw62XHHFctM6fnvTv3u4GFfliA7MUXd >									
	//        <  u =="0.000000000000000001" : ] 000000885332708.645289000000000000 ; 000000920244642.284319000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000546E91757C2E90 >									
	//     < SHERE_PFI_II_metadata_line_29_____LLC UAC_I_20220505 >									
	//        < s02SvziVyq211HVqQ9HUGM9i1aVpJ9A0KgFDjU8e83WyzHO9ZdlghvgC5j1R9sEm >									
	//        <  u =="0.000000000000000001" : ] 000000920244642.284319000000000000 ; 000000949349072.521692000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057C2E905A8977B >									
	//     < SHERE_PFI_II_metadata_line_30_____LLC UAC_II_20220505 >									
	//        < RssS7WJGCCx1APTi9uji3k6kZv16B5g9bBKV7RYLy9A1zP2w8g2246Twcy4zSS9z >									
	//        <  u =="0.000000000000000001" : ] 000000949349072.521692000000000000 ; 000000975169173.787316000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A8977B5CFFD75 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < SHERE_PFI_II_metadata_line_31_____LLC UAC_III_20220505 >									
	//        < RXWDAjWz53uVSAC8x202oODiwNOL4013RePEHB33X25ZMfZNYk83ZXn5k0fKcO0t >									
	//        <  u =="0.000000000000000001" : ] 000000975169173.787316000000000000 ; 000001004176290.532850000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005CFFD755FC405D >									
	//     < SHERE_PFI_II_metadata_line_32_____JSC Ilyushin Aviation Complex_20220505 >									
	//        < 30Qs1rW48dHUOZ5vcFx787tq715dj2OstK7i5z8WP2DR55o725aRD6G12NYW7X0A >									
	//        <  u =="0.000000000000000001" : ] 000001004176290.532850000000000000 ; 000001040643102.247080000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005FC405D633E536 >									
	//     < SHERE_PFI_II_metadata_line_33_____PJSC Voronezh Aircraft Manufacturing Company_20220505 >									
	//        < diK97Rb06t2pM2J29SKPVRZXIbR02J8kE6MtRhSiy0Wyp6iAU96x794i44424PFB >									
	//        <  u =="0.000000000000000001" : ] 000001040643102.247080000000000000 ; 000001085931464.257100000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000633E536678FFFA >									
	//     < SHERE_PFI_II_metadata_line_34_____JSC Aviation Holding Company Sukhoi_20220505 >									
	//        < R6awNN81iCqd7js170W7cOK0Ta4A68kKvezc9U1qo72527YfTT2ZLT6e662V8uZ0 >									
	//        <  u =="0.000000000000000001" : ] 000001085931464.257100000000000000 ; 000001126684018.639250000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000678FFFA6B72EF2 >									
	//     < SHERE_PFI_II_metadata_line_35_____SUKHOI_ORG_20220505 >									
	//        < q14o0SqLolwJ9pDdLkNiVFhHrmL4890HwrFcyx54g8KH4O153E30GSq9Q322GrE9 >									
	//        <  u =="0.000000000000000001" : ] 000001126684018.639250000000000000 ; 000001160844949.700840000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006B72EF26EB4F0F >									
	//     < SHERE_PFI_II_metadata_line_36_____PJSC Scientific and Production Corporation Irkut_20220505 >									
	//        < 274qEL421Bo4L4wp7Fz5622r9UwK1m2lKVb9m1C9NL1JV3Ab2sZ9gEP8Af2qq16Q >									
	//        <  u =="0.000000000000000001" : ] 000001160844949.700840000000000000 ; 000001180892284.060830000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006EB4F0F709E60C >									
	//     < SHERE_PFI_II_metadata_line_37_____PJSC Taganrog Aviation Scientific_Technical Complex_20220505 >									
	//        < 1bT8Hfzxxx61L8BB2k7czkI7PkXwH0H9hm9LXE1O3bG78OrR1wsDEya7ayONhLoQ >									
	//        <  u =="0.000000000000000001" : ] 000001180892284.060830000000000000 ; 000001217935847.552890000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000709E60C7426C31 >									
	//     < SHERE_PFI_II_metadata_line_38_____PJSC Tupolev_20220505 >									
	//        < OG65X17DXvXZ3Xyc9m2iq58Xx7VBiwGvu36pmo9jDV0dpPn0AmIJAqGwYWG99j3A >									
	//        <  u =="0.000000000000000001" : ] 000001217935847.552890000000000000 ; 000001254989033.571190000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007426C3177AF617 >									
	//     < SHERE_PFI_II_metadata_line_39_____TUPOLEV_ORG_20220505 >									
	//        < g9La9lqSY0cHfqWnc6G1O80l9xLLmbcDzDaUxu232QurVTDXYbN1bPqivPqsqdtF >									
	//        <  u =="0.000000000000000001" : ] 000001254989033.571190000000000000 ; 000001297487027.224740000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000077AF6177BBCEDF >									
	//     < SHERE_PFI_II_metadata_line_40_____The industrial complex N1_20220505 >									
	//        < 3s1iY1AXH0a0s3GVq7ir2u9whUyvr94vJgRkiF0Q7X35Ouzx2gN9EjwC4m0d53aY >									
	//        <  u =="0.000000000000000001" : ] 000001297487027.224740000000000000 ; 000001334947877.391940000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007BBCEDF7F4F804 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
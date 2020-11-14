/**
 * Source Code first verified at https://etherscan.io on Saturday, March 23, 2019
 (UTC) */

pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFV_II_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		761071890098368000000000000					;	
										
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
	//     < CHEMCHINA_PFV_II_metadata_line_1_____Psyclo_Peptide,_inc__20240321 >									
	//        < H9NLH7be4xv978YbuY0GtZ0WkBtX2921k5WWDq3Bfq9pDb6XHtHk3NB2Kb2IcqNG >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000022143971.113411000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000021C9FD >									
	//     < CHEMCHINA_PFV_II_metadata_line_2_____Purestar_Chem_Enterprise_Co_Limited_20240321 >									
	//        < dcI633eMsLOqn2S2z5nc7Z72Zgof80A89gh6xOIldXL3zLP236Y5Yt1BltCHmj3V >									
	//        <  u =="0.000000000000000001" : ] 000000022143971.113411000000000000 ; 000000039697668.106307900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000021C9FD3C92E7 >									
	//     < CHEMCHINA_PFV_II_metadata_line_3_____Puyer_BioPharma_20240321 >									
	//        < 21F39mwL0m8a0UiYfyrkxJZ8A41o8C6pp65wp2xhZmuV81BzmTX9MCh6579DWm62 >									
	//        <  u =="0.000000000000000001" : ] 000000039697668.106307900000000000 ; 000000056134398.387238800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003C92E755A780 >									
	//     < CHEMCHINA_PFV_II_metadata_line_4_____Qi_Chem_org_20240321 >									
	//        < I9ag27Bi1Cp8E2A15liCyq36Vq7Eq32EvrOa297Esdi1o4461603wi5czV7kjAb1 >									
	//        <  u =="0.000000000000000001" : ] 000000056134398.387238800000000000 ; 000000071900266.733177300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000055A7806DB60B >									
	//     < CHEMCHINA_PFV_II_metadata_line_5_____Qi_Chem_Co_Limited_20240321 >									
	//        < 0EJ7oCRwYIF28F37lk0fxfk25ZaUySCS1BA41d85xR0fFxo0ceItm8ZGAyNp4rr4 >									
	//        <  u =="0.000000000000000001" : ] 000000071900266.733177300000000000 ; 000000093947680.924639600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006DB60B8F5A50 >									
	//     < CHEMCHINA_PFV_II_metadata_line_6_____Qingdao_Yimingxiang_Fine_Chemical_Technology_Co_Limited_20240321 >									
	//        < PGQmZnif03N5haAc8YTluMG7Tbp88jm8dyo1mO1q186siYpb3iF3X0NoHHT9d328 >									
	//        <  u =="0.000000000000000001" : ] 000000093947680.924639600000000000 ; 000000109977040.237435000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008F5A50A7CFC8 >									
	//     < CHEMCHINA_PFV_II_metadata_line_7_____Qinmu_fine_chemical_Co_Limited_20240321 >									
	//        < 3ZZAC23ORqayHL1PsNc76BG5IhIfa31g9HiW749k1R41WB24HWRtXwbxwInJJUrC >									
	//        <  u =="0.000000000000000001" : ] 000000109977040.237435000000000000 ; 000000132331538.286043000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A7CFC8C9EC02 >									
	//     < CHEMCHINA_PFV_II_metadata_line_8_____Quzhou_Ruiyuan_Chemical_Co_Limited_20240321 >									
	//        < 8nJ5yzOXFWLwmiuw4iP5SwD4fSnvqfCm6KAB6TGKF0G25rDHE2GMy2tDc8H54Abk >									
	//        <  u =="0.000000000000000001" : ] 000000132331538.286043000000000000 ; 000000152007740.376851000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C9EC02E7F206 >									
	//     < CHEMCHINA_PFV_II_metadata_line_9_____RennoTech_Co__Limited_20240321 >									
	//        < V9q5Hx27708NGVW848VB9S5dsJK2132uD8rGh9j7c2uE47W4o5yT7N1a515Bt7s9 >									
	//        <  u =="0.000000000000000001" : ] 000000152007740.376851000000000000 ; 000000168056767.468498000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E7F2061006F2D >									
	//     < CHEMCHINA_PFV_II_metadata_line_10_____Richap_Chem_20240321 >									
	//        < Md9B3wV0zsZ2KX19hT9W8XZ1NQa2OYLI3Ldk623G9kn75CA2s7D8h944Oj9ZvYb7 >									
	//        <  u =="0.000000000000000001" : ] 000000168056767.468498000000000000 ; 000000187563049.500217000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001006F2D11E32D1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFV_II_metadata_line_11_____Ronas_Chemicals_org_20240321 >									
	//        < uaRMCDvijm2Kaco4tPpIL4ZVwpc1L5PY9owxQe1rbOo92774wFpLL39LwE629L3V >									
	//        <  u =="0.000000000000000001" : ] 000000187563049.500217000000000000 ; 000000204059085.398294000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011E32D11375E95 >									
	//     < CHEMCHINA_PFV_II_metadata_line_12_____Ronas_Chemicals_Ind_Co_Limited_20240321 >									
	//        < ahWkG2zA3dKU8Z44f6m4ZBZd323mL9wTnw4McPm2ZuS8bX2720d5Hw71Sz5F4rt5 >									
	//        <  u =="0.000000000000000001" : ] 000000204059085.398294000000000000 ; 000000219821620.430895000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001375E9514F6BD2 >									
	//     < CHEMCHINA_PFV_II_metadata_line_13_____Rudong_Zhenfeng_Yiyang_Chemical_Co__Limited_20240321 >									
	//        < HJ46LlxQf019Zr69Ms7N26O9jm7BSzxzsXpX8u7w32agw5hwR9Y2q973XsnDI0K7 >									
	//        <  u =="0.000000000000000001" : ] 000000219821620.430895000000000000 ; 000000239541520.130789000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014F6BD216D82E8 >									
	//     < CHEMCHINA_PFV_II_metadata_line_14_____SAGECHEM_LIMITED_20240321 >									
	//        < whi0JMM89P65jHGQXi0mkpBNc9oYXjfAiR89I08KvZeh6BZQNsS59N6GFtxi3D6F >									
	//        <  u =="0.000000000000000001" : ] 000000239541520.130789000000000000 ; 000000262696236.601152000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016D82E8190D7B8 >									
	//     < CHEMCHINA_PFV_II_metadata_line_15_____Shandong_Changsheng_New_Flame_Retardant_Co__Limited_20240321 >									
	//        < h4uid1sekUhm9H15HP52P3SwzDbPR2k03020U5RnPL2f43nlgw0Rpg30439M0L3i >									
	//        <  u =="0.000000000000000001" : ] 000000262696236.601152000000000000 ; 000000282314835.520504000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000190D7B81AEC73C >									
	//     < CHEMCHINA_PFV_II_metadata_line_16_____Shandong_Shengda_Technology_Co__Limited_20240321 >									
	//        < Cdeo01TnY8SIYIOC7s6p7vJJ4sM8nj4IpxKgr6oHZ2R54XnhS0I0lqfR7e0PBN7G >									
	//        <  u =="0.000000000000000001" : ] 000000282314835.520504000000000000 ; 000000297885496.686793000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AEC73C1C68986 >									
	//     < CHEMCHINA_PFV_II_metadata_line_17_____Shangfluoro_20240321 >									
	//        < oz4utkAR8I26wMA7205Wf9SZ04fpXp0VfQ8CaChFG7bFADU23Yi8fGtKdtcRG4QC >									
	//        <  u =="0.000000000000000001" : ] 000000297885496.686793000000000000 ; 000000318796241.246835000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C689861E671C8 >									
	//     < CHEMCHINA_PFV_II_metadata_line_18_____Shanghai_Activated_Carbon_Co__Limited_20240321 >									
	//        < h7OWhBUOz1d4Zf1w34bmbL2065XZQkgT1m31lCAwha5Z9lllwQFb4Q724iL2VzHa >									
	//        <  u =="0.000000000000000001" : ] 000000318796241.246835000000000000 ; 000000339145329.587660000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E671C82057EA5 >									
	//     < CHEMCHINA_PFV_II_metadata_line_19_____Shanghai_AQ_BioPharma_org_20240321 >									
	//        < KHN11gVod92WnLIFKCha5a8BTW2F188T4LwGPCiEO48S2645W2mw9w90V3505pPP >									
	//        <  u =="0.000000000000000001" : ] 000000339145329.587660000000000000 ; 000000359509252.250557000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002057EA5224914D >									
	//     < CHEMCHINA_PFV_II_metadata_line_20_____Shanghai_AQ_BioPharma_20240321 >									
	//        < 56s223I1wpO8b2J1xHL2IO64n4xi27W5yTcdA2gAybtS517rPo7k3hrXKQQzBl16 >									
	//        <  u =="0.000000000000000001" : ] 000000359509252.250557000000000000 ; 000000374958308.586380000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000224914D23C2417 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFV_II_metadata_line_21_____SHANGHAI_ARCADIA_BIOTECHNOLOGY_Limited_20240321 >									
	//        < 37sDy4N2UyS17WbymD6NiGxBZ1BhafeS694G3BP4Ru54VC7y7U886iiiZBJHd7Ry >									
	//        <  u =="0.000000000000000001" : ] 000000374958308.586380000000000000 ; 000000397734448.413791000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023C241725EE505 >									
	//     < CHEMCHINA_PFV_II_metadata_line_22_____Shanghai_BenRo_Chemical_Co_Limited_20240321 >									
	//        < mJs54W8gJ1bVkE4egO9c7BY438OPLLawBFt83582MF5P94Hf1l5vB6wx9W1i7642 >									
	//        <  u =="0.000000000000000001" : ] 000000397734448.413791000000000000 ; 000000417232086.186174000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025EE50527CA549 >									
	//     < CHEMCHINA_PFV_II_metadata_line_23_____Shanghai_Brothchem_Bio_Tech_Co_Limited_20240321 >									
	//        < G42Do4q8kaACi50dFXN20P1nv6I8oCsTWoEX8HkC70y5DYg63rv46D3GA5eQu0M9 >									
	//        <  u =="0.000000000000000001" : ] 000000417232086.186174000000000000 ; 000000436729185.713357000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027CA54929A6557 >									
	//     < CHEMCHINA_PFV_II_metadata_line_24_____SHANGHAI_CHEMHERE_Co_Limited_20240321 >									
	//        < x3j1E2eC2U5235ay3c8h3Tkv61yb2HZEJAs9v0u2Tftx9aGDGhEaY127lhZElpaX >									
	//        <  u =="0.000000000000000001" : ] 000000436729185.713357000000000000 ; 000000456032457.713491000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029A65572B7D9AE >									
	//     < CHEMCHINA_PFV_II_metadata_line_25_____Shanghai_ChemVia_Co_Limited_20240321 >									
	//        < 5secPe3Zj49J59IVH61l2e66btSFTfXN8O408ir7ft2nx511a585cFYK26Z6769x >									
	//        <  u =="0.000000000000000001" : ] 000000456032457.713491000000000000 ; 000000477626565.889791000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B7D9AE2D8CCE1 >									
	//     < CHEMCHINA_PFV_II_metadata_line_26_____Shanghai_Coming_Hi_Technology_Co__Limited_20240321 >									
	//        < Z6U2k0zLKKPMHoojW60Qd0n2HsOh6k3f9iXYZvkwba6e4l9F3z641tmJ08hawJKT >									
	//        <  u =="0.000000000000000001" : ] 000000477626565.889791000000000000 ; 000000495101278.987175000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D8CCE12F376F0 >									
	//     < CHEMCHINA_PFV_II_metadata_line_27_____Shanghai_EachChem_org_20240321 >									
	//        < 5480dx3Z1aba2Jsv1eg9doDiwq139TLecP2o49Ri51JrudfB1KAI4Zof46b82325 >									
	//        <  u =="0.000000000000000001" : ] 000000495101278.987175000000000000 ; 000000510954674.488569000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F376F030BA7AB >									
	//     < CHEMCHINA_PFV_II_metadata_line_28_____Shanghai_EachChem_Co__Limited_20240321 >									
	//        < Rw05C5xlA76DY33Lx0gZS97Esqepg378z7Hf154d5gGdC8e0RS7NPVN6TOuV70gE >									
	//        <  u =="0.000000000000000001" : ] 000000510954674.488569000000000000 ; 000000530030268.242221000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030BA7AB328C313 >									
	//     < CHEMCHINA_PFV_II_metadata_line_29_____Shanghai_FChemicals_Technology_Co_Limited_20240321 >									
	//        < kGGRv65jHgcs2GAC5t2osS3yQV54CWiSI62Y4Q3ebTfm53y87W25kc0JFWvqv6ik >									
	//        <  u =="0.000000000000000001" : ] 000000530030268.242221000000000000 ; 000000547391321.741659000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000328C31334340BC >									
	//     < CHEMCHINA_PFV_II_metadata_line_30_____Shanghai_Fuxin_Pharmaceutical_Co__Limited_20240321 >									
	//        < eL16E2M9ieSmb3xsem30jrQ3mysdECSfvHS9MhQ6uyWomnftJB8Haw0f4YgtTAlV >									
	//        <  u =="0.000000000000000001" : ] 000000547391321.741659000000000000 ; 000000566355604.698612000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034340BC36030A8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFV_II_metadata_line_31_____Shanghai_Goldenmall_biotechnology_Co__Limited_20240321 >									
	//        < w5zydE3Wx22Yeg7y8s38EB6btaG9G0WbshM4Q90718ijudA86305A3G2z3Btl36G >									
	//        <  u =="0.000000000000000001" : ] 000000566355604.698612000000000000 ; 000000587389398.728934000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036030A838048FC >									
	//     < CHEMCHINA_PFV_II_metadata_line_32_____Shanghai_Hope_Chem_Co__Limited_20240321 >									
	//        < L7SYbXQkYr6WqR51FX248DuY4nHiBL395XecpS5u85L1DsUc4EavJIa5zT6M3ozN >									
	//        <  u =="0.000000000000000001" : ] 000000587389398.728934000000000000 ; 000000606155054.413661000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038048FC39CEB51 >									
	//     < CHEMCHINA_PFV_II_metadata_line_33_____SHANGHAI_IMMENSE_CHEMICAL_org_20240321 >									
	//        < 5ZpoJ07k6kT71MGquW098ZFe8u46W9c9FycaPfqjYs6lEOGmLuaxsPtvkf0neT3K >									
	//        <  u =="0.000000000000000001" : ] 000000606155054.413661000000000000 ; 000000626043903.633975000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039CEB513BB4466 >									
	//     < CHEMCHINA_PFV_II_metadata_line_34_____SHANGHAI_IMMENSE_CHEMICAL_Co_Limited_20240321 >									
	//        < Ypm13g51IA3UY50luTIr0vpDcWUVO9M1vWBLRGDYVzldq3XIzoRABlXztqCP4XL7 >									
	//        <  u =="0.000000000000000001" : ] 000000626043903.633975000000000000 ; 000000643457625.153250000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BB44663D5D6A3 >									
	//     < CHEMCHINA_PFV_II_metadata_line_35_____Shanghai_MC_Pharmatech_Co_Limited_20240321 >									
	//        < 343lo3x75sL1FQ5sMXxL6jo9SAf643lo2qWAZKQ6R9zQ5D9Ndy20pyLP28GVRQ0x >									
	//        <  u =="0.000000000000000001" : ] 000000643457625.153250000000000000 ; 000000661866434.812117000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D5D6A33F1ED93 >									
	//     < CHEMCHINA_PFV_II_metadata_line_36_____Shanghai_Mintchem_Development_Co_Limited_20240321 >									
	//        < xZ6VK8Rzs2253BHJVVEm36j2H5ev378eGdaoMD2oRgvPv97CW4CTIk67IwYzGaBk >									
	//        <  u =="0.000000000000000001" : ] 000000661866434.812117000000000000 ; 000000683153598.564640000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F1ED9341268E0 >									
	//     < CHEMCHINA_PFV_II_metadata_line_37_____Shanghai_NuoCheng_Pharmaceutical_Co_Limited_20240321 >									
	//        < OZ0u1dV7fKj27TnO5qnQv2QeuLD86hkrOFwX5k75dEDaZIc95YsDI4C559xJa6O5 >									
	//        <  u =="0.000000000000000001" : ] 000000683153598.564640000000000000 ; 000000706383417.547105000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041268E0435DB06 >									
	//     < CHEMCHINA_PFV_II_metadata_line_38_____Shanghai_Oripharm_Co_Limited_20240321 >									
	//        < nS8erhOYrOMJSArIWwwSnE77PX63FhR2DT0TuT32Rd7r4iSs5067UMv21tv7m4JQ >									
	//        <  u =="0.000000000000000001" : ] 000000706383417.547105000000000000 ; 000000723929903.590223000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000435DB06450A11E >									
	//     < CHEMCHINA_PFV_II_metadata_line_39_____Shanghai_PI_Chemicals_org_20240321 >									
	//        < XK1j5h5kdfzbJh40XI8WaXxV8cuCSl3dG43W8oG72cUZ1Hbe8nD5HcK8LOC4qO1G >									
	//        <  u =="0.000000000000000001" : ] 000000723929903.590223000000000000 ; 000000742137319.405950000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000450A11E46C6964 >									
	//     < CHEMCHINA_PFV_II_metadata_line_40_____Shanghai_PI_Chemicals_Ltd_20240321 >									
	//        < b6j6bjat1L92A1190mf60w2H9YO275a4c77AJ7523Icql21i6aTb3c9r9I0g26V0 >									
	//        <  u =="0.000000000000000001" : ] 000000742137319.405950000000000000 ; 000000761071890.098368000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046C69644894DB5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}
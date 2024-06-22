# Decentralized Finance Threat Matrix

- **[v3.0.3 (v2022.08.23-303) (current release)](https://github.com/manifoldfinance/defi-threat/blob/master/v3.0.3.md)**
- [v3.0.2 (v2022.06.13-302) (previous release)](https://github.com/manifoldfinance/defi-threat/blob/master/src/v3.0.2.tsv)

## Advisories 

We are now publishing Security Advisories [https://github.com/manifoldfinance/defi-threat/security/advisories](https://github.com/manifoldfinance/defi-threat/security/advisories)

[Link to the latest published ones here](https://github.com/manifoldfinance/defi-threat/security/advisories?state=published)

### Changes

v3.0.3
New attack: Secret Size Attack
New Category: Interchain, id: 006

v3.0.2
New attacks such as: <br>
Ex Post/Ex Ante Reorg (On-Chain),  <br>
Compiler not Optimizing errors (Solidity),  <br>
BGP Routing Hijacking (Off-chain) and more.

## Abstract

This work is inspired by [attack.mitre.org](https://attack.mitre.org). Please
use attack for "normal" InfoSec/Dev/Sys security check-listing, this is meant to
be specialized towards the unique issues brought about in blockchain/cryptocurrency applications (i.e. protocols).

### Repository Structure

- libtx: transaction library with example transactions from hacks in a UML format

- src: Source of the latest DeFi Threat Mapping and Matrix. Provided in `.mediawiki` and `.tsv` formats.

## v4 Draft of Threat Matrix

| **Market Attacks**              	| **Economic Attacks**                            	| **Off-Chain Attacks**                      	| **On-Chain Attacks**                    	| **Solidity-Specific Attacks**                     	|
|---------------------------------	|-------------------------------------------------	|--------------------------------------------	|-----------------------------------------	|---------------------------------------------------	|
| Front-Running                   	| In Arrears Liability                            	| Price Feed                                 	| Timestamp Dependence                    	| Integer Overflow and Underflow                    	|
| Coordinated Attack              	| Insufficient Gas Griefing                       	| Quote Stuffing                             	| Admin Key Exploits                      	| DoS with (Unexpected) Revert                      	|
| Liquidity Pocket                	| Token Inflation                                 	| Spoofing                                   	| Timelock Exploits                       	| DoS with Block Gas Limit                          	|
| Quote Stuffing                  	| Circulating Supply Attack                       	| Credential Access                          	| Lateral Movements                       	| Arithmetic Over/Under Flows                       	|
| Wash Trading                    	| Gas Griefing (DoS)                              	| Reentrancy                                 	| Multi-Sig Key Exploits                  	| Forcibly Sending Ether to a Contract              	|
| Ramping The Market              	| Network Congestion (uDoS)                       	| Privilege Escalation                       	| Miner Cartel Attacks                    	| Delegatecall                                      	|
| Cornering The Market            	| Liquidity Squeeze                               	| Credential Access                          	| Finality Exploits                       	| Entropy Illusion                                  	|
| Churning                        	| Governance Cartels                              	| Encryption Protections                     	| Honeypot Attacks                        	| Short Address/Parameter Attack                    	|
| Flash Loans                     	| Interlocking Directorate                        	| Phishing                                   	| Red Queen Attacks                       	| Uninitialized Storage Pointers                    	|
| Aggregated Transactions         	| Governance Attack                               	| Unicode Exploits                           	| Sole Block Synchronization              	| Floating Points and Numerical Precision           	|
| Bulge Bracket Transactions      	| Slippage Exploit                                	| API                                        	| Transaction Pool                        	| Right-To-Left-Override Control Character (U+202E) 	|
| Layering                        	| Safety Check Exploits                           	| DNS Attacks                                	| Performance Fee Minting                 	| Delegatecall to Untrusted Callee                  	|
| Spoofing                        	| Circulating Supply Dump                         	| Transaction Pool                           	| Front-Running                           	| Requirement Violation                             	|
| Order Book                      	| Flash "Straddle"                                	| Checksum Address                           	| Sandwich Attacks                        	| Shadowing State Variables                         	|
| Market Index Calculation Attack 	| Structuring                                     	| Siphon Funds                               	| Second System Effector                  	| Transaction Order Dependence                      	|
| Flash Crash                     	| Stalking Horse                                  	| Influencer Attacks                         	| Backrunning                             	| Assert Violation                                  	|
| Repo                            	| Like Asset Price Divergence                     	| Synthetic Mint Spread                      	| Block Producer Cartel                   	| Uninitialized Storage Pointer                     	|
| Excessive Leverage              	| Reserve Asset Liquidity Manipulation            	| Syscall Exploit                            	| Unlimited Permissions on Token Approval 	| Unprotected Ether Withdrawal                      	|
| Breaking the "Buck"             	| Stable Reserve Asset Manipulation               	| Container Privilege Escalation             	| Naked Call                              	| Floating Pragma                                   	|
| Fake News                       	| Price Induced Oracle Volatility                 	| Keyctl Misuse (syscall)                    	| Block Constructor Cartel                	| Outdated Compiler Version                         	|
| Nested Bot                      	| Fake Token Trading Pair                         	| Supply Chain Dependency                    	| Malicious Airdrop                       	| Function Default Visibility                       	|
| Audience of Bots                	| Volume Manipulation by Re-circulating Flashloan 	| Compiled Output Destructuring Const Values 	| Oracle HALT by MultiSig                 	| msg.sender                                        	|
| Arbitrage Exploit               	| Persistent De-Peg Instability                   	| Browser in the Browser Attack              	| Ex Ante Reorg                           	| Wallet Balance                                    	|
| Cascading Loan Failure          	| Unexpected Fee on Transfer                      	| Man in the Blotter                         	| Ex Post Reorg                           	| Compiler Optimizer Not Optimizing                 	|
|                                 	|                                                 	| BGP Routing                                	| Nonstandard Proxy Implementation        	| Math Operations Differ in Certain Pragmas         	|
|                                 	|                                                 	| IP4/IP6 Misconfiguration                   	| Tyranny of the Majority                 	| Uninitialized Contract                            	|

## v3 Threat Matrix

> version v3.0.3/2022.08

| _001_ 	| _002_ 	| _003_ 	| _004_ 	| _005_ 	|
|---	|---	|---	|---	|---	|
| **Market Attacks** 	| **Economic Attack** 	| **Off-Chain** 	| **On-Chain** 	| **Solidity** 	|
| Front-Running 	| In Arrears liability 	| Price Feed 	| Timestamp Dependence 	| Integer Overflow and Underflow 	|
| Coordinated Attack 	| Insufficient gas griefing 	| Quote Stuffing 	| Admin Key 	| DoS with (Unexpected) revert 	|
| Liquidity Pocket 	| Token Inflation 	| Spoofing 	| Timelock 	| DoS with Block Gas Limit 	|
| Quote Stuffing 	| Circulating Supply Attack 	| Credential Access 	| Lateral Movements 	| Arithmetic Over/Under Flows 	|
| Wash Trading 	| Gas Griefing (DoS) 	| Reentrancy 	| Multi-Sig Keys 	| Forcibly Sending Ether to a Contract 	|
| Ramping The Market 	| Network Congestion (uDoS) 	| Privilage Esclation 	| Miner Cartel 	| Delegatecall 	|
| Cornering The Market 	| Liquidity Squeeze 	| Credential Access 	| Finality 	| Entropy Illusion 	|
| Churning 	| Governance Cartels 	| Encryption Protections 	| Honeypot 	| Short Address/Parameter Attack 	|
| Flash Loans 	| Interlocking Directorate 	| Phishing 	| Red Queen 	| Uninitialised Storage Pointers 	|
| Aggregated Transactions 	| Governance Attack 	| Unicode Exploits 	| Sole block synchronization 	| Floating Points and Numerical Precision 	|
| Bulge Bracket Transactions 	| Slippage Exploit 	| API 	| Transaction Pool 	| Right-To-Left-Override control character (U+202E) 	|
| Layering 	| Safety Check Exploits 	| DNS Attacks 	| Performance Fee Minting 	| Delegatecall to Untrusted Callee 	|
| Spoofing 	| Circulating Supply Dump 	| Transaction Pool 	| Front-Running 	| Requirement Violation 	|
| Order Book 	| Flash "Straddle" 	| Checksum Address 	| Sandwhiching 	| Shadowing State Variables 	|
| Market Index Calculation Attack 	| Structuring 	| Siphon Funds 	| Second System Effector 	| Transaction Order Dependence 	|
| Flash Crash 	| Stalking Horse 	| Influencers' 	| Backrunning 	| Assert Violation 	|
| Repo 	| Like Asset Price Divergance 	| Synthetic Mint Spread 	| Block Producer Cartel 	| Uninitialized Storage Pointer 	|
| Excessive Leverage 	| Reserve Asset Liquidity Manipulation 	| Syscall Exploit 	| Unlimited Permissions on Token Approval 	| Unprotected Ether Withdrawal 	|
| Breaking the "Buck" 	| Stable Reserve Asset Manipulation 	| Container Priv. Esclation 	| Naked Call 	| Floating Pragma 	|
| "Fake" News 	| Price Induced Oracle Volatility 	| Keyctl missuse (syscall) 	| Block Constructor Cartel 	| Outdated Compiler Version 	|
| Nested Bot 	| Fake Token Trading Pair 	| Supply Chain Dependency  	| MaliciousAirdrop  	| Function Default Visibility 	|
| Audience of Bots 	| Volume Manipulation by re-circulating flashloan 	| Compiled output destructuring const values 	| Oracle HALT by MultiSig 	| msg.sender 	|
| Arb. Exploit 	| Persistant de-peg instability  	| Browser in the Browser attack 	| Ex Ante Reorg 	| Wallet Balance 	|
| Cascading Loan Failure 	| Unexpected Fee on Transfer  	| Man in the Blotter 	| Ex Post Reorg 	| Compiler Optimizer not Optimizing 	|
|  	|  	| BGP Routing 	| Nonstandard Proxy Implementation 	| Math operations differ in certain pragmas 	|
|  	|  	| IP4/IP6 misconfiguration 	| Tyranny of the Majority 	| Uninitialized Contract 	|
|  	|  	|  	| Secret Size Attack  	|  	|


### v2 Matrix 

> For Reference use only!

| **Protocol / Interaction Based** | **Blockchain Transaction Based** | **Non-Blockchain Sources** | **Blockchain Sources**     | **SWC Registry (Solidity Exploits)**                    |
| -------------------------------- | -------------------------------- | -------------------------- | -------------------------- | ------------------------------------------------------- |
| Market Attacks                   | Economic Attack                  | Off\-Chain                 | On\-Chain                  | Solidity                                                |
| Front\-Running                   | Front\-Running                   | Price Feed                 | Timestamp Dependence       | Integer Overflow and Underflow                          |
| Coordinated Attack               | Insufficient gas griefing        | Quote Stuffing             | Admin Key                  | DoS with \(Unexpected\) revert                          |
| Liquidity Pocket                 | Token Inflation                  | Spoofing                   | Timelock                   | DoS with Block Gas Limit                                |
| Quote Stuffing                   | Circulating Supply Attack        | Credential Access          | Lateral Movements          | Arithmetic Over/Under Flows                             |
| Wash Trading                     | Gas Griefing \(DoS\)             | Reentrancy                 | Multi\-Sig Keys            | Forcibly Sending Ether to a Contract                    |
| Ramping The Market               | Network Congestion \(uDoS\)      | Privilege Escalation       | Miner Cartel               | Delegatecall                                            |
| Cornering The Market             | Liquidity Squeeze                | Credential Access          | Finality                   | Entropy Illusion                                        |
| Churning                         | Smurfing                         | Encryption Protections     |                            | Short Address/Parameter Attack                          |
| Flash Loans                      |                                  | Phishing                   |                            | Uninitialised Storage Pointers                          |
| Aggregated Transactions          |                                  | Unicode Exploits           |                            | Floating Points and Numerical Precision                 |
| Bulge Bracket Transactions       |                                  | API                        |                            | Right\-To\-Left\-Override control character \(U\+202E\) |
| Layering                         | Blockchain Transaction Based     | DNS Attacks                |                            | Delegatecall to Untrusted Callee                        |
| Spoofing                         | Governance Attack                | Transaction Pool           | Transaction Pool           | Requirement Violation                                   |
| Order Book                       | Interlocking Directorate         | Checksum Address           |                            | Shadowing State Variables                               |
| Market Index Calculation Attack  | Governance Cartels               | Siphon Funds               |                            | Transaction Order Dependence                            |
| Flash Crash                      |                                  |                            |                            | Assert Violation                                        |
| Repo                             | Stalking Horse                   | Synthetic Mint Spread      | Sole block synchronization | Uninitialized Storage Pointer                           |
| Excessive Leverage               |                                  | Syscall Exploit            |                            | Unprotected Ether Withdrawal                            |
| Breaking the "Buck"              |                                  | Container Priv\. Esclation |                            | Floating Pragma                                         |
| "Fake" News                      |                                  | Keyctl missuse \(syscall\) |                            | Outdated Compiler Version                               |
| Nested Bot                       |                                  |                            |                            | Function Default Visibility                             |
| Audience of Bots                 |                                  | Influencers'               |                            |                                                         |
| Arb\. Exploit                    |                                  |                            |                            |                                                         |
| Slippage Exploit                 |                                  |                            |                            |                                                         |
| Safety Check Exploits            |                                  |                            |                            |                                                         |
| Circulating Supply Dump          |                                  |                            |                            |                                                         |
| Governance Cartel                |                                  |                            |                            |                                                         |
| Flash "Straddle"                 |                                  |                            |                            |                                                         |
| Structuring                      |                                  |                            |                            |                                                         |
|                                  |                                  |                            |                            |                                                         |
| Back\-Running                    |                                  |                            |                            |                                                         |


## UML Diagrams of Real World Attacks 

### Example: Fake Trading Volume on UniswapV2

![](https://d.pr/i/5vsXd4.jpeg)

## Contributions and Acknowledgements

Ali Atiia   <br />
John Mardlin   <br />
Raul Jack   <br />
samczsun   <br />
Sam Bacha  <br />
James Zaki  <br />

### v1 Sheet

[DeFi Sec Matrix Sheet](https://docs.google.com/spreadsheets/d/1St4BXWpeZdcDaH5Z4nnODrerFAxfdZ4OuHofI-EbKGc/edit?usp=sharing)

### v2 Sheet

[DeFi Sec Page](https://docs.google.com/spreadsheets/d/e/2PACX-1vR5UnBx4M9sg43fO76eWetena1L-4zo82lqsJuMR3uuZPe7luRnakG8jZPG0YbnSDtUOY5nVgSdwpc1/pubhtml)

- Updates to the Sheet can be found in in the 'legend' section

## License

Software Components under Mozilla Public License 2.0 <br />

CVE/SWC are licensed under their respective author's licenses. <br />

Everything else is under CC-2.5-NC-ND. If you would like an exemption to this license pleasae
contact: <sam@manifoldfinance.com>

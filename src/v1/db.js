module.exports = {
  swc: [
    ("id": "CVE-2018-13077"),
    ("title": "Integer Overflow or Wraparound"),
    ("description": "The mintToken function of a smart contract implementation for CTB, an Ethereum token, has an integer overflow that allows the owner of the contract to set the balance of an arbitrary user to any value.\n"),
    ("references": [
      "https://github.com/VenusADLab/EtherTokens/blob/master/CTB/CTB.md"
    ]),
    ("credits": "VenusADLab"),
    ("vulnerability_type": {
      cwe: "CWE-190",
      swc: "SWC-101",
    }),
  ],
  class: [
    ("severity": 7.5),
    ("affected": {
      contractName: "CTB",
      address: "0xb57E2EC276460a993393cA1bB2BdAe6c8170c73A",
    }),
  ],
  signature: [
    {
      signature: "f2dea3f6ecb1397e9005efbd42dc90aa",
    },
  ],
};

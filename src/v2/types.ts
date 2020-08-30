export interface DefiInfo {
  readonly chainId: number;
  readonly affected contract:  string[];
  readonly affected address:  string[];
  readonly title: string;
  readonly decimals: number;
  readonly symbol: string;
  readonly URI?: string;
  readonly tags?: string[];
  readonly id: number; 
  readonly description: string;
  readonly severity: number;
  readonly signature: 
}


export interface Severity {
  readonly major: number;
  readonly minor: number;
  readonly patch: number;
}

export interface Tags {
  readonly [tagId: string]: {
    readonly name: string;
    readonly description: string;
  };
}

export interface DefiThreatList {
  readonly name: string;
  readonly timestamp: string;
  readonly version: Version;
  readonly contracts: Contracts[];
  readonly keywords?: string[];
  readonly tags?: Tags;
  readonly URI?: string;
}
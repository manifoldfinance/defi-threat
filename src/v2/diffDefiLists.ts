import { DefiInfo } from './types';

export type DefiInfoChangeKey = Exclude<
  keyof DefiInfo,
  'address' | 'chainId'
>;
export type DefiInfoChanges = Array<DefiInfoChangeKey>;

/**
 * compares two Defi info key values
 * this subset of full deep equal functionality does not work on objects or object arrays
 * @param a comparison item a
 * @param b comparison item b
 */
function compareDefiInfoProperty(a: unknown, b: unknown): boolean {
  if (a === b) return true;
  if (typeof a !== typeof b) return false;
  if (Array.isArray(a) && Array.isArray(b)) {
    return a.every((el, i) => b[i] === el);
  }
  return false;
}

/**
 * Differences between a base list and an updated list.
 */
export interface DefiListDiff {
  /**
   * Defis from updated with chainId/address not present in base list
   */
  readonly added: DefiInfo[];
  /**
   * Defis from base with chainId/address not present in the updated list
   */
  readonly removed: DefiInfo[];
  /**
   * The Defi info that changed
   */
  readonly changed: {
    [chainId: number]: {
      [address: string]: DefiInfoChanges;
    };
  };
}

/**
 * Computes the diff of a Defi list where the first argument is the base and the second argument is the updated list.
 * @param base base list
 * @param update updated list
 */
export function diffDefiLists(
  base: DefiInfo[],
  update: DefiInfo[]
): DefiListDiff {
  const indexedBase = base.reduce<{
    [chainId: number]: { [address: string]: DefiInfo };
  }>((memo, DefiInfo) => {
    if (!memo[DefiInfo.chainId]) memo[DefiInfo.chainId] = {};
    memo[DefiInfo.chainId][DefiInfo.address] = DefiInfo;
    return memo;
  }, {});

  const newListUpdates = update.reduce<{
    added: DefiInfo[];
    changed: {
      [chainId: number]: {
        [address: string]: DefiInfoChanges;
      };
    };
    index: {
      [chainId: number]: {
        [address: string]: true;
      };
    };
  }>(
    (memo, DefiInfo) => {
      const baseDefi = indexedBase[DefiInfo.chainId]?.[DefiInfo.address];
      if (!baseDefi) {
        memo.added.push(DefiInfo);
      } else {
        const changes: DefiInfoChanges = Object.keys(DefiInfo)
          .filter(
            (s): s is DefiInfoChangeKey => s !== 'address' && s !== 'chainId'
          )
          .filter(s => {
            return !compareDefiInfoProperty(DefiInfo[s], baseDefi[s]);
          });
        if (changes.length > 0) {
          if (!memo.changed[DefiInfo.chainId]) {
            memo.changed[DefiInfo.chainId] = {};
          }
          memo.changed[DefiInfo.chainId][DefiInfo.address] = changes;
        }
      }

      if (!memo.index[DefiInfo.chainId]) {
        memo.index[DefiInfo.chainId] = {
          [DefiInfo.address]: true,
        };
      } else {
        memo.index[DefiInfo.chainId][DefiInfo.address] = true;
      }

      return memo;
    },
    { added: [], changed: {}, index: {} }
  );

  const removed = base.reduce<DefiInfo[]>((list, curr) => {
    if (
      !newListUpdates.index[curr.chainId] ||
      !newListUpdates.index[curr.chainId][curr.address]
    ) {
      list.push(curr);
    }
    return list;
  }, []);

  return {
    added: newListUpdates.added,
    changed: newListUpdates.changed,
    removed,
  };
}
/**
 * Enum describing types of severity differences
 */
import { Severity } from './types'

export enum SeverityUpgrade {
  NONE,
  PATCH,
  MINOR,
  MAJOR,
}

/**
 * Return the upgrade type from the base severity to the update severity.
 * Note that downgrades and equivalent severitys are both treated as `NONE`.
 * @param base base list
 * @param update update to the list
 */
export function getSeverityUpgrade(base: Severity, update: Severity): SeverityUpgrade {
  if (update.major > base.major) {
    return SeverityUpgrade.MAJOR
  }
  if (update.major < base.major) {
    return SeverityUpgrade.NONE
  }
  if (update.minor > base.minor) {
    return SeverityUpgrade.MINOR
  }
  if (update.minor < base.minor) {
    return SeverityUpgrade.NONE
  }
  return update.patch > base.patch ? SeverityUpgrade.PATCH : SeverityUpgrade.NONE
}

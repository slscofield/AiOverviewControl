#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WIDGET="$ROOT/AiOverviewControlWidget.qml"

# Used percentages drive the UI; normalized remaining percentages remain
# available as a separate internal field.
jq -e '
  [
    ({usedPercent:0, remainingPercent:(100 - 0)}),
    ({usedPercent:100, remainingPercent:(100 - 100)}),
    ({usedPercent:91, remainingPercent:(100 - 91)}),
    ({used:1342, limit:8000, remaining:(8000 - 1342), usedPercent:(1342 / 8000 * 100), remainingPercent:((8000 - 1342) / 8000 * 100)})
  ]
  | .[0].usedPercent == 0
    and .[1].usedPercent == 100
    and .[2].usedPercent == 91
    and .[3].remaining == 6658
    and (.[3].usedPercent > 16 and .[3].usedPercent < 18)
    and (.[3].remainingPercent > 83 and .[3].remainingPercent < 84)
' >/dev/null <<< '{}'

grep -q 'function remainingPercentFor' "$WIDGET"
grep -q 'function usedPercentFor' "$WIDGET"
grep -q 'return `${Math.round(pillPercentFor(provider))}%`;' "$WIDGET"
grep -q 'Math.round(pillPercent)}% .*window.used' "$WIDGET"
grep -q 'if (percent >= 80)' "$WIDGET"
grep -q 'if (percent >= 60)' "$WIDGET"
grep -q 'providerUsedPercent(successfulProviders\[i\]) > 0' "$WIDGET"
grep -q 'usedPercentFor(provider.provider, windowData)' "$WIDGET"
grep -q 'p: historyPercent(entry)' "$WIDGET"
grep -q 'layeredUsageWindow(provider, best || primaryUsageWindow(provider))' "$WIDGET"
grep -q 'return usage.primary || primaryUsageWindow(provider)' "$WIDGET"
grep -q 'if (!windowData || windowData.unavailable)' "$WIDGET"
grep -q 'const percent = Math.round(Number(windowData.usedPercent || 0));' "$WIDGET"
grep -q 'const delta = historyPercent(history\[history.length - 1\])' "$WIDGET"

echo 'Quota percentage normalization and presentation contracts: OK'

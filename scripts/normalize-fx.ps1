param(
  [string]$Root = "$PSScriptRoot/../Src"
)

$ErrorActionPreference = 'Stop'

function Normalize-Whitespace([string]$path) {
  $pattern = "[\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000\u200B\uFEFF]"
  $raw = Get-Content -Path $path -Raw -Encoding UTF8
  if ([string]::IsNullOrEmpty($raw)) { return $false }
  if (-not [regex]::IsMatch($raw, $pattern)) { return $false }
  $new = [regex]::Replace($raw, $pattern, ' ')
  if ($new -ne $raw) {
    Set-Content -Path $path -Value $new -Encoding UTF8
    return $true
  }
  return $false
}

$files = Get-ChildItem -Path $Root -Recurse -File -Include *.fx.yaml,*.pa.yaml
$count = 0
foreach ($f in $files) {
  if (Normalize-Whitespace -path $f.FullName) {
    Write-Host "Normalized: $($f.FullName)"
    $count++
  }
}
Write-Host "Total files normalized: $count"


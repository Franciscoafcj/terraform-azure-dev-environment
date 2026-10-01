param([string]$Terraform = "terraform", [string]$Bash = "bash")
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
$temp = Join-Path ([IO.Path]::GetTempPath()) ("terraform-bootstrap-test-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $temp | Out-Null
try {
  $template = (Join-Path $repo "modules/compute/scripts/user_data.sh").Replace("\","/")
  $name = 'D''Angelo "Dev" $(touch /tmp/terraform-injection-test)'
  $nameB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($name))
  $expression = 'templatefile("' + $template + '", {admin_username = "azuredev", git_user_name_b64 = "' + $nameB64 + '", git_user_email_b64 = "ZGV2QGV4YW1wbGUuY29t"})'
  $result = $expression | & $Terraform "-chdir=$temp" console -no-color
  if ($LASTEXITCODE -ne 0) { throw "Terraform template rendering failed" }
  $rendered = ($result -join "`n") -replace '^<<-?EOT\r?\n', '' -replace '\r?\nEOT$', ''
  $file = Join-Path $temp "rendered.sh"
  [IO.File]::WriteAllText($file, $rendered, [Text.UTF8Encoding]::new($false))
  & $Bash -n $file.Replace("\","/")
  if ($LASTEXITCODE -ne 0) { throw "Rendered Bash syntax is invalid" }
  # Execute only inert identity assignments, never package/system commands.
  $assignments = ($rendered -split "`n" | Where-Object { $_ -match '^(ADMIN_USER|GIT_NAME|GIT_EMAIL|USER_DIR)=' }) -join "`n"
  $probe = Join-Path $temp "identity.sh"
  [IO.File]::WriteAllText($probe, ($assignments + "`n" + 'printf ''%s'' "$GIT_NAME"'), [Text.UTF8Encoding]::new($false))
  $actual = & $Bash -l $probe.Replace("\","/")
  if ($LASTEXITCODE -ne 0 -or ($actual -join "`n") -cne $name) { throw "Git identity did not round-trip safely" }
  if ($rendered.Contains('$$(')) { throw "Invalid command substitution remains" }
  if ($rendered -match 'set -[a-z]*x|echo.*CODE_SERVER_PASSWORD') { throw "Password could leak to logs" }
  Write-Output "PASS: rendered Bash syntax, hostile Git identity round-trip, no xtrace or password echo."
} finally {
  if ((Split-Path $temp -Leaf) -like "terraform-bootstrap-test-*") {
    Remove-Item -LiteralPath $temp -Recurse -Force
  }
}

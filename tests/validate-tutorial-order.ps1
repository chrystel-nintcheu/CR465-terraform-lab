. "$PSScriptRoot/../scripts/common.ps1"

Set-Location (Get-RepoRoot)

$requiredScripts = @(
  'scripts/check-prereqs.ps1',
  'scripts/apply.ps1',
  'scripts/destroy.ps1',
  'scripts/reset.ps1',
  'scripts/student.ps1',
  'scripts/teacher.ps1'
)

foreach ($script in $requiredScripts) {
  if (-not (Test-Path $script)) {
    throw "Missing tutorial runner: $script"
  }
}

$terraformFiles = @('terraform/versions.tf', 'terraform/variables.tf', 'terraform/main.tf', 'terraform/outputs.tf')
foreach ($path in $terraformFiles) {
  if (-not (Test-Path $path)) {
    throw "Missing Terraform file: $path"
  }
}

# Provider check: must use todoroff/multipass, must NOT use null_resource or local-exec
$versions = Get-Content 'terraform/versions.tf' -Raw
if ($versions -notmatch 'todoroff/multipass') {
  throw 'versions.tf must declare todoroff/multipass as the provider.'
}

$mainTf = Get-Content 'terraform/main.tf' -Raw
foreach ($forbidden in @('null_resource', 'local-exec', 'multipass-launch', 'multipass-destroy')) {
  if ($mainTf -match [regex]::Escape($forbidden)) {
    throw "main.tf must not contain '$forbidden' - use multipass_instance resource instead."
  }
}
foreach ($required in @('multipass_instance', 'multipass_alias', 'templatefile', 'cloud_init')) {
  if ($mainTf -notmatch [regex]::Escape($required)) {
    throw "main.tf is missing required token: $required"
  }
}

$outputsTf = Get-Content 'terraform/outputs.tf' -Raw
if ($outputsTf -notmatch 'ipv4') {
  throw 'outputs.tf must expose the ipv4 output from multipass_instance.'
}
if ($outputsTf -notmatch 'multipass_instance') {
  throw 'outputs.tf must reference multipass_instance, not a variable.'
}

$gitbookFiles = @(
  'gitbook/README.md',
  'gitbook/SUMMARY.md',
  'gitbook/en/step-01-contract.md',
  'gitbook/en/step-02-smallest-terraform-target.md',
  'gitbook/en/step-03-isolated-cloud-init.md',
  'gitbook/en/step-04-wrappers-and-reset.md',
  'gitbook/en/step-05-full-sequence.md',
  'gitbook/en/step-06-docs-and-gitbook.md',
  'gitbook/en/step-07-staged-validation.md',
  'gitbook/en/step-08-hardening.md',
  'gitbook/fr/etape-01-contrat.md',
  'gitbook/fr/etape-02-cible-terraform-minimale.md',
  'gitbook/fr/etape-03-cloud-init-isole.md',
  'gitbook/fr/etape-04-wrappers-et-reset.md',
  'gitbook/fr/etape-05-sequence-complete.md',
  'gitbook/fr/etape-06-docs-et-gitbook.md',
  'gitbook/fr/etape-07-validation-par-paliers.md',
  'gitbook/fr/etape-08-durcissement.md'
)

foreach ($path in $gitbookFiles) {
  if (-not (Test-Path $path)) {
    throw "Missing GitBook page: $path"
  }
}

$summary = Get-Content 'gitbook/SUMMARY.md' -Raw
foreach ($token in @('English', 'Français', 'Step 1: Contract', 'Étape 1 : Contrat', 'Step 8: Hardening', 'Étape 8 : Durcissement')) {
  if ($summary -notmatch [regex]::Escape($token)) {
    throw "Missing GitBook summary token: $token"
  }
}

$pageChecks = @(
  @{ Path = 'gitbook/en/step-01-contract.md'; Tokens = @('## ', 'Verification', 'Recovery') },
  @{ Path = 'gitbook/en/step-02-smallest-terraform-target.md'; Tokens = @('## ', 'Verification', 'Recovery') },
  @{ Path = 'gitbook/en/step-03-isolated-cloud-init.md'; Tokens = @('## ', 'Verification', 'Recovery') },
  @{ Path = 'gitbook/en/step-04-wrappers-and-reset.md'; Tokens = @('## ', 'Verification', 'Recovery') },
  @{ Path = 'gitbook/en/step-05-full-sequence.md'; Tokens = @('## ', 'Verification', 'Recovery') },
  @{ Path = 'gitbook/en/step-06-docs-and-gitbook.md'; Tokens = @('## ', 'Verification', 'Recovery') },
  @{ Path = 'gitbook/en/step-07-staged-validation.md'; Tokens = @('## ', 'Verification', 'Recovery') },
  @{ Path = 'gitbook/en/step-08-hardening.md'; Tokens = @('## ', 'Verification', 'Recovery') },
  @{ Path = 'gitbook/fr/etape-01-contrat.md'; Tokens = @('## ', 'Vérification', 'Récupération') },
  @{ Path = 'gitbook/fr/etape-02-cible-terraform-minimale.md'; Tokens = @('## ', 'Vérification', 'Récupération') },
  @{ Path = 'gitbook/fr/etape-03-cloud-init-isole.md'; Tokens = @('## ', 'Vérification', 'Récupération') },
  @{ Path = 'gitbook/fr/etape-04-wrappers-et-reset.md'; Tokens = @('## ', 'Vérification', 'Récupération') },
  @{ Path = 'gitbook/fr/etape-05-sequence-complete.md'; Tokens = @('## ', 'Vérification', 'Récupération') },
  @{ Path = 'gitbook/fr/etape-06-docs-et-gitbook.md'; Tokens = @('## ', 'Vérification', 'Récupération') },
  @{ Path = 'gitbook/fr/etape-07-validation-par-paliers.md'; Tokens = @('## ', 'Vérification', 'Récupération') },
  @{ Path = 'gitbook/fr/etape-08-durcissement.md'; Tokens = @('## ', 'Vérification', 'Récupération') }
)

foreach ($pageCheck in $pageChecks) {
  $content = Get-Content $pageCheck.Path -Raw
  foreach ($token in $pageCheck.Tokens) {
    if ($content -notmatch [regex]::Escape($token)) {
      throw "Missing section token '$token' in $($pageCheck.Path)"
    }
  }
}

# GitBook pages must not reference deleted scripts
$deletedScripts = @('terraform-init.ps1', 'terraform-validate.ps1', 'terraform-plan.ps1', 'multipass-launch.ps1', 'multipass-destroy.ps1')
Get-ChildItem -Recurse gitbook/ -Filter '*.md' | ForEach-Object {
  $pageContent = Get-Content $_.FullName -Raw
  foreach ($deleted in $deletedScripts) {
    if ($pageContent -match [regex]::Escape($deleted)) {
      throw "GitBook page '$($_.Name)' references deleted script '$deleted'."
    }
  }
}

# Step 2 pages must explain todoroff/multipass and multipass_instance
foreach ($step2page in @('gitbook/en/step-02-smallest-terraform-target.md', 'gitbook/fr/etape-02-cible-terraform-minimale.md')) {
  $c = Get-Content $step2page -Raw
  foreach ($tok in @('todoroff/multipass', 'multipass_instance', 'ipv4')) {
    if ($c -notmatch [regex]::Escape($tok)) {
      throw "$step2page must mention '$tok'."
    }
  }
}

$cloudInit = Get-Content 'cloud-init/user-data.yaml.tftpl' -Raw
foreach ($token in @('package_update:', 'write_files:', 'runcmd:', '${hostname}', '${lab_stage}')) {
  if ($cloudInit -notmatch [regex]::Escape($token)) {
    throw "Missing cloud-init token: $token"
  }
}

Write-Host 'Tutorial order validation passed.'

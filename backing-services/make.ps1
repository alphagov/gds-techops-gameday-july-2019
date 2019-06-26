#requires -version 3
<#
.SYNOPSIS
  Makefile in PowerShell
.DESCRIPTION
  Script to make/test/run the firebreakq1faas project
.PARAMETER clean
    '-clean' Cleans the directory
.PARAMETER test
    '-test' Uses tox to test the project
.PARAMETER build
    '-build' Builds the files in .target and generates a zip
.PARAMETER deploy
    '-deploy' Deploys the project to terraform
.PARAMETER plandeploy
    '-plandeploy' Tests the terraform deploy
.PARAMETER run
    '-run' Runs the flask project locally on port 5000
.NOTES
  Version:        0.1
  Author:         Ollie - GDS
  Creation Date:  16/05/19
  Purpose/Change: Make PowerShell script

.EXAMPLE
  ./make.ps1 -clean     cleans the folder
.EXAMPLE
  ./make.ps1 -run       run the flask project locally
.EXAMPLE
  ./make.ps1 -test      run tox against the project
#>

#---------------------[Parameters]--------------------

param(
  [switch]$clean = $false,
  [switch]$test = $false,
  [switch]$build = $false,
  [switch]$deploy = $false,
  [switch]$plandeploy = $false,
  [switch]$run = $false
)

#-------------------[Initialisations]-----------------

$PWD = Split-Path -parent $PSCommandPath
cd $PWD

#Set Error Action to Silently Continue
#$ErrorActionPreference = "SilentlyContinue"

$TARGET_DIR = ".target"

#---------------------[Execution]---------------------

if ($run) {
  $build = $true
}

if (!$deploy -and !$build -and !$clean -and !$test -and !$plandeploy -and !$run) {
  $build = $true
}

if ($clean) {
  Remove-Item -Recurse -Force .target, *.egg-info, .tox, venv, *.zip
  Remove-Item -Recurse -Force .pytest_cache, htmlcov, **/__pycache__, **/*.pyc
}

if ($test) {
  $TEST_OUTPUT = tox 5>&1

  if ($TEST_OUTPUT -like "*commands failed*") {
    Write-Host -ForegroundColor Red "Tests failed."
    $TEST_OUTPUT
    exit
  } else {
    Write-Host -ForegroundColor Green "Tests passed!"
  }
}

if ($build) {

  if (Test-Path $TARGET_DIR) { Remove-Item $TARGET_DIR -Force -Recurse }
  New-Item -ItemType "directory" $TARGET_DIR/

  Copy-Item -Recurse src/*.py ./$TARGET_DIR/
  Copy-Item -Recurse src/templates/ ./$TARGET_DIR/templates/
  Copy-Item -Recurse src/assets/ ./$TARGET_DIR/assets/

  pip3 install -r requirements.txt -t $TARGET_DIR

  if (!$run) {
    $ZIPFILE = ".\gge.zip"
    if (Test-Path $ZIPFILE) { Remove-Item $ZIPFILE -Force }
    Compress-Archive .\$TARGET_DIR\* -DestinationPath $ZIPFILE
  }
}

if ($run) {
  python3 $TARGET_DIR/game_play.py
}

if ($plandeploy) {
  "Not yet implemented."
  #cd environment/
  #terraform plan
  #cd ../
}

if ($deploy) {
  "Not yet implemented."
  #cd environment/
  #terraform apply
  #cd ../
}

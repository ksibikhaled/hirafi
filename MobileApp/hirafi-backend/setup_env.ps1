# Setup Environment for Hirafi Backend
$toolsDir = Join-Path $PSScriptRoot ".tools"
$jdkBin = Join-Path $toolsDir "jdk-17.0.10+7\bin"
$mavenBin = Join-Path $toolsDir "apache-maven-3.9.6\bin"

Write-Host "Configuring Java 17 and Maven for this session..." -ForegroundColor Cyan

$env:JAVA_HOME = Join-Path $toolsDir "jdk-17.0.10+7"
$env:Path = "$jdkBin;$mavenBin;" + $env:Path

Write-Host "Success! Current versions:" -ForegroundColor Green
java -version
mvn -version

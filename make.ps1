#!/usr/bin/env pwsh

[CmdletBinding()]

Param([Parameter(Mandatory=$False,Position=1)] [string]$command)

$ErrorActionPreference = "Stop"
$command = If ($command) { $command } Else { "lint" }

Write-Output $("make target:    '{0}'" -f $command);
Write-Output $("current user:   '{0}'" -f $env:UserName);
# Write-Output $("node            '{0}'" -f $(node -v));
# Write-Output $("npm             '{0}'" -f $(npm -v --no-update-notifier));
Write-Output $("git             '{0}'" -f $(git --version));

$originalDirectory = $PWD;
$topLevel = git rev-parse --show-toplevel;
$workingDir = $($topLevel)  # Join-Path -Path $topLevel -ChildPath "src";
Import-Module $(Join-Path -Path $topLevel -ChildPath ".\build\Tasks.psm1");
Write-Output "Working directory = $workingDir";

Try
{
	Set-Location $workingDir;

	If ($command -imatch "clean")
	{
		Write-Output "Starting Clear-Files"
		Clear-Python;
		Clear-Files;
		Write-Output "Done Clear-Files"
	}

	If ($command -imatch "^install$")
	{
		Write-Output "Starting Invoke-Pip";
		Invoke-Install;
		Write-Output "Done with Invoke-Pip";
	}

	If ($command -imatch "lint|^install$")
	{
		Write-Output "Starting Invoke-Lint"
		Invoke-Lint;
		Write-Output "Done Invoke-Lint"
  }
}
Catch
{
	Write-Output "Error: $_.Exception.Message";
	Write-Error "Error: $_.Exception.Message";
	Exit 1;
}
Finally
{
	Set-Location $originalDirectory;
	Write-Output "Done!";
	Exit 0;
}

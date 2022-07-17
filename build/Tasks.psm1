Function Invoke-Pip
{
  .\.venv\Scripts\activate.ps1
  pip install -r requirements
}

Function Clear-Python
{
  .\.venv\Scripts\activate.ps1
  # Forced delete should only be at least on specific sub paths
  Remove-Item ".\.venv" -Force -Recurse
  pip3 cache purge
}

Function Invoke-Install
{
	If (-not (Test-Path ".\.venv"))
	{
		Write-Output "Setting up virtual environment.";
		mkdir .venv
		python3 -m venv ./.venv
	}

    .\.venv\Scripts\activate.ps1
    pip3 install -r requirements_cuda.txt --extra-index-url https://download.pytorch.org/whl/cu113
	pip3 install -r requirements.txt
}

Function Invoke-Lint
{
	$orig = $PWD;
	Try
	{
		Set-Location $(git rev-parse --show-toplevel);

		# Check for conflicts
		$conflicts = $(git grep "^<<<<<\|^=====\|^>>>>>" -- *.cs *.csproj *.config *.py);

		If (![string]::IsNullOrWhitespace($conflicts))
		{
			Write-Error "Aborting. Avoid committed conflicts. $conflicts.";
			return;
		}
		Write-Output "Verified no committed merge conflicts";

		# Check for origin files  
		$mergeLeft = $(git ls-files *.orig);

		if (![string]::IsNullOrWhitespace($mergeLeft))
		{
			$formatted = "$mergeLeft".replace(" ", "`r`n - ");
			Write-Error "Found:`r`n - $formatted`r`nAborting. Committing '*.orig' files not allowed";
			return;
		}
		Write-Output "Verified no diff-files";

		Write-Output "**pyflakes***";
		.\.venv\Scripts\activate.ps1
		pyflakes examples | select-string -notmatch "imported but unused$"

		Write-Output "**pycodestyle***";
		pycodestyle --first examples

		Write-Output "**pylint***";
	    pylint examples

		Write-Output "**radon***";
		radon cc -a -nc -e "venv/*" ./

		Write-Output "**black***";
	    black examples/**.py
	}
	Finally
	{
		Set-Location $orig;
	}
}

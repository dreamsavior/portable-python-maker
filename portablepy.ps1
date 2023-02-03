param ($source, $destination, $pythonVersion)

if (!$source) {
    $source = 'https://www.python.org/ftp/python/3.9.10/python-3.9.10-embed-amd64.zip'
}

if (!$pythonVersion) {
    $source -match '.+\/python-(\d+)\.(\d+)\..+'
    $Matches
    $pythonVersion = "python$($Matches[1])$($Matches[2])"
}

if (!$destination) {
    $destination = '.\'
}

# Fixes an error if the user doesn't put a backslash at the end of the url
$destination += "\"


"You're installing $($pythonVersion) into $($destination)"


# Destination to save the file
$package = "$($destination)embedpython.zip"

#Download the file
"Downloading package from $($source)"
Invoke-WebRequest -Uri $source -OutFile $package
Expand-Archive -Path $package -DestinationPath $destination

Expand-Archive -Path "$($destination)$($pythonVersion).zip" -DestinationPath "$($destination)$($pythonVersion)"

"Writing $($pythonVersion)._pth"

".\$($pythonVersion)
.\Scripts
.

import site
" | Out-File -FilePath "$($destination)$($pythonVersion)._pth" -encoding ASCII 


"Writing sitecustomize.py"

"import sys, os
sys.path = []
path = os.getcwd()
sys.path.append('')
sys.path.append(os.path.join(path, `"$($pythonVersion)`"))
sys.path.append(os.path.join(path, `"Scripts`"))
sys.path.append(path)
sys.path.append(os.path.join(path, `"lib`", `"site-packages`"))
" | Out-File -FilePath "$($destination)sitecustomize.py" -encoding ASCII 

"Creating DLLs dir"
mkdir "$($destination)DLLs"


"Installing PIP"
"You will see some warning about the $($destination)Scripts folder not on your SYSTEM PATH. That is NORMAL!"
Invoke-WebRequest -OutFile "$($destination)get-pip.py" "https://bootstrap.pypa.io/get-pip.py"
& "$($destination)python.exe" "$($destination)get-pip.py"

"Cleaning up"
Remove-Item -Path $package -Confirm:$false -Force
Remove-Item -Path "$($destination)$($pythonVersion).zip" -Confirm:$false -Force
Remove-Item -Path "$($destination)get-pip.py" -Confirm:$false -Force

"Done!

INFO:
You can install module by running .\python.exe -m pip YOURMODULE

Always use full path or relative path with with . or .. (e.g. .\python.exe) to run your portable python.
Otherwise, you may trigger the python that has been installed on your system (if any) instead.

TO DO:
You can now remove this .ps1 file manually!"

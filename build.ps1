#------------------------------- vimr.ps1 -------------------------------
$content = (Get-Content -Path "./vimrrc.vim" -Raw).TrimEnd()

$scriptContent = @"
`$tempFile = New-TemporaryFile
`$tempFilePath = `$tempFile.FullName
Set-Content -Path `$tempFilePath -Value @"
$content
`"@  -NoNewline

vim --clean -c "source `$tempFilePath"
"@

$scriptPath = "vimr.ps1"
Set-Content -Path $scriptPath -Value $scriptContent -NoNewline

#------------------------------- vimr.sh -------------------------------
$scriptContent = @"
#!/bin/bash

tmpfile=`$(mktemp -p /tmp vimr.XXXXXX)
cat << EOF > "`$tmpfile"
$content
EOF

vim --clean  -c "source `$tmpfile"
"@

$scriptPath = "vimr.sh"
Set-Content -Path $scriptPath -Value $scriptContent -NoNewline

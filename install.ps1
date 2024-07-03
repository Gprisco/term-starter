if (Test-Path -Path $env:LOCALAPPDATA\nvim) {
    rm -fo -r $env:LOCALAPPDATA\nvim
} 

cp -r .\.config\nvim\ $env:LOCALAPPDATA\

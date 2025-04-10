# Perguntas ao usuário
$discos = Read-Host "Digite as letras dos discos separados por vírgula (ex: C,D,E)"
$palavraChave = Read-Host "Digite parte do nome do arquivo ou pasta que deseja buscar"
$extensoesInput = Read-Host "Digite as extensões desejadas separadas por vírgula (ex: png,jpg ou * para todas, ou 'pasta' para somente pastas)"

# Prepara os discos
$listaDiscos = $discos.Split(",") | ForEach-Object { "${_}:\\" }

# Prepara as extensões (em minúsculo, com ponto)
$extensoes = @()
if ($extensoesInput -ne "*" -and $extensoesInput -ne "pasta") {
    $extensoes = $extensoesInput.Split(",") | ForEach-Object { ".$($_.ToLower())" }
}

# Faz a busca
$listaDiscos | ForEach-Object {
    Get-ChildItem -Path $_ -Recurse -Force -ErrorAction SilentlyContinue
} | Where-Object {
    $_.Name -match $palavraChave -and (
        ($extensoesInput -eq "*") -or
        ($extensoesInput -eq "pasta" -and $_.PSIsContainer) -or
        ($extensoes -contains $_.Extension.ToLower())
    )
} | ForEach-Object {
    $_.FullName
}

# Pausa no final
Read-Host -Prompt "Pressione Enter para sair"

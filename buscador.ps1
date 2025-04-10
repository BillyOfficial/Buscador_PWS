# Perguntas ao usuario
$discos = Read-Host "Digite as letras dos discos separados por virgula (ex: C,D,E)"
$palavraChave = Read-Host "Digite parte do nome do arquivo ou pasta que deseja buscar"
$extensoesInput = Read-Host "Digite as extensoes desejadas separadas por virgula (ex: png,jpg ou * para todas, ou 'pasta' para somente pastas)"

# Prepara os discos
$listaDiscos = $discos.Split(",") | ForEach-Object { "${_}:\\" }

# Prepara as extensoes
$extensoes = @()
if ($extensoesInput -ne "*" -and $extensoesInput -ne "pasta") {
    $extensoes = $extensoesInput.Split(",") | ForEach-Object { ".$($_.ToLower())" }
}

# Faz a busca e guarda os resultados
$resultados = $listaDiscos | ForEach-Object {
    Get-ChildItem -Path $_ -Recurse -Force -ErrorAction SilentlyContinue
} | Where-Object {
    $_.Name -match $palavraChave -and (
        ($extensoesInput -eq "*") -or
        ($extensoesInput -eq "pasta" -and $_.PSIsContainer) -or
        ($extensoes -contains $_.Extension.ToLower())
    )
} | Select-Object -ExpandProperty FullName

# Lista os resultados com numero
for ($i = 0; $i -lt $resultados.Count; $i++) {
    Write-Host "$($i+1)) $($resultados[$i])"
}

# Se houver resultados, permite selecionar para abrir
if ($resultados.Count -gt 0) {
    $escolha = Read-Host "Digite o numero do caminho que deseja abrir ou pressione Enter para sair"

    if ($escolha -match '^\d+$' -and $escolha -ge 1 -and $escolha -le $resultados.Count) {
        $caminhoSelecionado = $resultados[$escolha - 1]
        Start-Process $caminhoSelecionado
    } else {
        Write-Host "Saindo..."
    }
} else {
    Write-Host "Nenhum resultado encontrado."
}

Read-Host -Prompt "Pressione Enter para sair"

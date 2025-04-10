# Perguntas ao usuario
$discos = Read-Host "Digite as letras dos discos separados por virgula (ex: C,D,E)"
$palavraChave = Read-Host "Digite parte do nome do arquivo ou pasta que deseja buscar"
$extensoesInput = Read-Host "Digite as extensoes desejadas separadas por virgula (ex: txt, jpg, exe, 'pasta' para buscar apenas pastas, ou * para todos os tipos de arquivo)"

# Prepara os discos
$listaDiscos = $discos.Split(",") | ForEach-Object { "${_}:\\" }

# Prepara as extensoes
$extensoes = @()
if ($extensoesInput -ne "*" -and $extensoesInput -ne "pasta") {
    $extensoes = $extensoesInput.Split(",") | ForEach-Object { ".$($_.ToLower())" }
}

# Listas para resultados e erros
$itensEncontrados = @()
$erros = @()

# Busca nos discos
foreach ($disco in $listaDiscos) {
    $itens = Get-ChildItem -Path $disco -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable err
    if ($err) {
        $erros += "Erro ao acessar ${disco}: $($err[0].Exception.Message)"
    }
    
    $filtrados = $itens | Where-Object {
        $_ -and $_.Name -like "*$palavraChave*" -and (    
            $extensoesInput -eq "*" -or
            ($extensoesInput -eq "pasta" -and $_.PSIsContainer) -or
            ($extensoes -contains $_.Extension.ToLower())
        )
    }
    
    $itensEncontrados += $filtrados
}

# Exibir resultados encontrados
if ($itensEncontrados.Count -gt 0) {
    Write-Host "`n=== Resultados encontrados ===" -ForegroundColor Green
    for ($i = 0; $i -lt $itensEncontrados.Count; $i++) {
        Write-Host "$($i+1)) $($itensEncontrados[$i].FullName)" -ForegroundColor Green
    }

    # Exibir erros logo após os resultados
    if ($erros.Count -gt 0) {
        Write-Host "`n=== Caminhos com erro durante a busca ===" -ForegroundColor Red
        $erros | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    }
    
    # Permitir abrir vários itens até o usuário sair
    while ($true) {
        $escolha = Read-Host "`nDigite o numero do caminho que deseja abrir ou pressione Enter para sair"
        $escolha = $escolha.Trim()
        if ([string]::IsNullOrWhiteSpace($escolha)) {
            break
        }
        elseif ($escolha -match '^\d+$') {
            $num = [int]$escolha
            if ($num -ge 1 -and $num -le $itensEncontrados.Count) {
                $itemSelecionado = $itensEncontrados[$num - 1]
                $caminhoSelecionado = $itemSelecionado.FullName
                try {
                    if ($itemSelecionado.PSIsContainer) {
                        Start-Process $caminhoSelecionado
                    }
                    else {
                        # Se for arquivo, se a extensão for .jpg ou .jpeg, tenta abrir com mspaint.exe
                        if ($itemSelecionado.Extension -match '^\.jpe?g$') {
                            Start-Process "mspaint.exe" -ArgumentList "`"$caminhoSelecionado`""
                        }
                        else {
                            Invoke-Item $caminhoSelecionado
                        }
                    }
                    Write-Host "`n✅ Caminho aberto com sucesso." -ForegroundColor Green
                } catch {
                    Write-Host "`n❌ Erro ao tentar abrir o caminho:" -ForegroundColor Red
                    Write-Host $_.Exception.Message -ForegroundColor Red
                }
            }
            else {
                Write-Host "`nNúmero inválido. Tente novamente." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "`nNúmero inválido. Tente novamente." -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "`nNenhum resultado encontrado." -ForegroundColor Yellow
    
    # Exibir erros mesmo sem resultados
    if ($erros.Count -gt 0) {
        Write-Host "`n=== Caminhos com erro durante a busca ===" -ForegroundColor Red
        $erros | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    }
}

Read-Host -Prompt "`nPressione Enter para sair"

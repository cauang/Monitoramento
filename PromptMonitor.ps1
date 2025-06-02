# Configurações do e-mail


$remetente = "cauangomes.b@gmail.com"
$destinatario = "cauangomes.b@gmail.com"
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$senha = ConvertTo-SecureString "lgqupvmuahdaykoh" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($remetente, $senha)


function EnviarEmail($assunto, $mensagem) {
    Send-MailMessage -From $remetente -To $destinatario -Subject $assunto -Body $mensagem `
        -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $cred -BodyAsHtml:$false -Encoding UTF8
}


# Exportando C# aq para pegar e armazenar a posição do cursor

Add-Type @"
using System;
using System.Runtime.InteropServices;

public struct POINT {
    public int X;
    public int Y;
}

public class Cursor {
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);
}
"@

function Get-CursorPos {
    $point = New-Object POINT
    [Cursor]::GetCursorPos([ref]$point) | Out-Null
    return "$($point.X),$($point.Y)"
}

# Verificando aq a latência com a internet
function TestarLatencia {
    param (
        [string]$hostPing = "google.com",
        [int]$maxLatenciaMs = 200
    )

    $resultados = Test-Connection -ComputerName $hostPing -Count 4 -ErrorAction SilentlyContinue

    if (-not $resultados) {
        return @($false, "Sem resposta do host $hostPing.")
    }

    $latencias = $resultados | Select-Object -ExpandProperty ResponseTime
    $media = ($latencias | Measure-Object -Average).Average

    if ($media -gt $maxLatenciaMs) {
        return @($false, "Latencia média alta: $([math]::Round($media,2)) ms para $hostPing.")
    }

    return @($true, "Latencia OK: $([math]::Round($media,2)) ms para $hostPing.")
}

# Variáveis iniciais
$ultimaPosicao = Get-CursorPos
$tempoSemMover = 0
$limiteInatividade = 180 
$alertaCursorEnviado = $false
$inativo = $false

$hostPing = "google.com"
$maxLatencia = 94 
$alertaRedeEnviado = $false

while ($true) {
    Start-Sleep -Seconds 1

    # Verifica cursor
    $posAtual = Get-CursorPos

    if ($posAtual -eq $ultimaPosicao) {
        $tempoSemMover++
    } else {
        if ($inativo) {
            EnviarEmail "Cursor voltou a se mover" "O cursor voltou a se mover apos ficar parado por $tempoSemMover segundos."
            $inativo = $false
        }
        $tempoSemMover = 0
        $alertaCursorEnviado = $false
        $ultimaPosicao = $posAtual
    }

    if (-not $alertaCursorEnviado -and $tempoSemMover -ge $limiteInatividade) {
        EnviarEmail "Alerta: Cursor parado na VM" "O cursor nao se moveu por mais de $limiteInatividade segundos. Pode haver inatividade ou travamento."
        $alertaCursorEnviado = $true
        $inativo = $true
    }

    # Verifica latência a cada 60 segundos 

    if ((Get-Date).Second -eq 0) {
        $resultado = TestarLatencia -hostPing $hostPing -maxLatenciaMs $maxLatencia
        $ok = $resultado[0]
        $msg = $resultado[1]

        if (-not $ok -and -not $alertaRedeEnviado) {
            EnviarEmail "Alerta: Instabilidade na rede" $msg
            $alertaRedeEnviado = $true
        } elseif ($ok -and $alertaRedeEnviado) {
            EnviarEmail "Rede normalizada" "A latencia da rede voltou ao normal: $msg"
            $alertaRedeEnviado = $false
        }
    }
}

$funcName={
    param ([System.ConsoleKeyInfo] $key,$arg) 

    function Init-Histo {
        if ($null -eq $global:__HISTO_SEARCH) {
            $global:__HISTO_SEARCH = $null
            $global:__HISTO_FILTERED = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $global:__HISTO_SEARCH, [ref] $null)
        }
        if ($null -eq $global:__HISTO_LIST) {
            $global:__HISTO_LIST = (Get-Content (Get-PSReadlineOption).HistorySavePath)
            [array]::Reverse($global:__HISTO_LIST)
        }
        if ($null -eq $global:__HISTO_FILTERED)
        {
            if ("" -eq $global:__HISTO_SEARCH) {
                $global:__HISTO_FILTERED = $global:__HISTO_LIST
            } else {
                $global:__HISTO_FILTERED = $global:__HISTO_LIST | Where-Object { $_.ToLower().Contains($global:__HISTO_SEARCH.ToLower()) }
                if ($null -eq $global:__HISTO_FILTERED) {
                    $global:__HISTO_FILTERED = @()
                }
            }
        }
    }
    function HistoBackToOrigin {
        [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
        if ($null -ne $global:__HISTO_SEARCH) {
            if ($global:__HISTO_FILTERED.Count -ne 0) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($global:__HISTO_SEARCH)
            }
            $global:__HISTO_SEARCH = $null
        }
        $global:__HISTO_CURRENT_POS = $null
    }
    function HistoForward {
        param ()
        
        Init-Histo
        if ($global:__HISTO_FILTERED.Count -eq 0) {
            return
        }
        elseif ($null -eq $global:__HISTO_CURRENT_POS) {
            $global:__HISTO_CURRENT_POS = 0
        }
        elseif ($global:__HISTO_CURRENT_POS -lt $global:__HISTO_FILTERED.Count) {
            $global:__HISTO_CURRENT_POS = $global:__HISTO_CURRENT_POS + 1
        }
        [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($global:__HISTO_FILTERED[$global:__HISTO_CURRENT_POS])
    }
    function HistoBackward {
        param ()
        Init-Histo
        if ($null -eq $global:__HISTO_CURRENT_POS) {
            return
        }
        elseif ($global:__HISTO_CURRENT_POS -gt 0) {
            $global:__HISTO_CURRENT_POS = $global:__HISTO_CURRENT_POS - 1
        }
        elseif ($global:__HISTO_CURRENT_POS -eq 0) {
            HistoBackToOrigin
            return
        }
        [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($global:__HISTO_FILTERED[$global:__HISTO_CURRENT_POS])
    }
    
    if (($key.Modifiers -eq 0) -and ($key.Key -eq [System.ConsoleKey]::UpArrow)) {
        HistoForward 
    }
    elseif (($key.Modifiers -eq 0) -and ($key.Key -eq [System.ConsoleKey]::DownArrow)) {
        HistoBackward 
    }
    elseif (($key.Modifiers -eq [System.ConsoleModifiers]::Control) -and ($key.Key -eq [System.ConsoleKey]::C)) {
        $global:__HISTO_SEARCH = $null
        $global:__HISTO_CURRENT_POS = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::CopyOrCancelLine()
    }
    elseif (($key.Modifiers -eq 0) -and $key.Key -eq [System.ConsoleKey]::Enter) {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        $global:__HISTO_SEARCH = $null
        $global:__HISTO_LIST = $null
        $global:__HISTO_FILTERED = $null
        $global:__HISTO_CURRENT_POS = $null
    }
    elseif (($key.Modifiers -eq 0) -and $key.Key -eq [System.ConsoleKey]::Escape) {
        HistoBackToOrigin
    }
}
$global:__HISTO_LIST = $null
$global:__HISTO_FILTERED = $null
$global:__HISTO_SEARCH = $null
$global:__HISTO_CURRENT_POS = $null

Set-PSReadLineKeyHandler -Chord UpArrow,DownArrow,Ctrl+c,Enter,Escape -ScriptBlock $funcName

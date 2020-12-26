#requires -module PANSIES
using namespace PoshCode.Pansies

$e = [char]27

function Show-Spinner {
    <#
        .SYNOPSIS
            Shows idling animations in the console
        .DESCRIPTION
            Shows idling animations in the console

            The spinners.json came from cli-spinners
            https://github.com/sindresorhus/cli-spinners/blob/07c83e7b9d8a08080d71ac8bda2115c83501d9d6/spinners.json

            You can preview them on jsfiddle https://jsfiddle.net/sindresorhus/2eLtsbey/embedded/result/
    #>
    [CmdletBinding(DefaultParameterSetName = "NamedSpinner")]
    param(
        # The name of an existing spinner from spinners.json
        [Parameter(ParameterSetName = "NamedSpinner", Position = 0)]
        [string]$SpinnerName = "dots",

        # Frames for a spinner are an array of strings, each representing a frame which is drawn over the top of the previous frame
        [Parameter(ParameterSetName = "ManualSpinner", Mandatory, Position = 0)]
        [string[]]$Frames,

        # Interval is the number of seconds
        [Parameter(ParameterSetName = "ManualSpinner")]
        [int]$Interval = 80,

        # A label to display next to the spinner (defaults to nothing)
        [string]$Label = "",

        # Number of seconds to show the spinner for. Defaults to 10 seconds
        [int]$Duration = 10,

        # An array of colors to use (if you specify 2 colors, a gradient between them the length of the Frames will be used)
        [RGbColor[]]$Colors
    )
    $Sw = [System.Diagnostics.Stopwatch]::new()
    $Sw.Start()
    $Duration *= 1000

    if ($SpinnerName) {
        $spinners = Get-Content $PSScriptRoot\spinners.json | ConvertFrom-Json -AsHashtable
        $spinner  = $spinners[$SpinnerName]
        $Interval = $spinner["interval"]
        $Frames   = $spinner["frames"]
    }
    if (!$Colors) {
        $Colors = @($Host.UI.RawUI.ForegroundColor) * $Frames.Count
    } elseif ($Colors.Count -eq 1) {
        $Colors = @($Colors) * $Frames.Count
    } elseif ($Frames.Count -gt $Colors.Count) {
        $Colors = @($Colors[0..($Colors.Length - 2)]) + @(Get-Gradient $Colors[-2] $Colors[-1] -Count ($Frames.Count - ($Colors.Length - 2)))
    }

    $i = 0;
    $Frames = $Frames.ForEach{ "$e[u" + $Colors[$i++].ToVtEscapeSequence() + $_ + " " + $Label }
    Write-Host "$e[s" -NoNewline

    do {
        foreach($frame in $Frames) {
            Write-Host $Frame -NoNewline
            Start-Sleep -Milliseconds $Interval
        }
    } while ($Sw.ElapsedMilliseconds -lt $Duration)

    Write-Host ("$e[u" + (" " * ($Frame.Length + $Label.Length + 1)) + "$e[u")
    $Sw.Stop()
}
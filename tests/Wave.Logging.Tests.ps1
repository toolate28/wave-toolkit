Import-Module "$PSScriptRoot/../tools/Wave.Logging.psm1" -Force

Describe "Wave.Logging Collect-SpiralLogs" {
    It "runs without throwing and creates a TSV with <=8 columns" {
        $result = Test-CollectSpiralLogs
        $result | Should -BeTrue
    }
}

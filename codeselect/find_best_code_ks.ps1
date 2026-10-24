param (
    [double]$p = 0.0714285714285714,
    [int] $encode = 8, #96 bit for "Hello World!"
    [double]$z = 3 # 3 for 99.865% chance of a correct message
)

$tables = foreach ($d in 4, 6, 8, 10, 12, 14, 16, 18) {
    @{
        d     = $d
        table = Import-Csv ".\lookup_tables\d$d.csv" -Delimiter ';'
    }
}

$variancesingle = $p * (1-$p)
$bests1 = [PSCustomObject]@{n = $null; d = $null; w = $null; data = $null; tdata = $null }
$bestvalue = [double]::MinValue
                
#search cs1 in all distance tables
for ($s = 0; $s -lt $tables.length; $s++) {
    $cs1 = [PSCustomObject]@{n = $null; w = $null;d = $null; size = $null; data = $null; tdata = $null}
    $stable = $tables[$s].table
    $cs1.d = [int] $tables[$s].d
    #search through every w for the current subword distance table
    for($k = 0; $k -lt $stable.length; $k++) {
        $cs1.n = $([int] $stable[$k].n)
        #search through every n for the current w
        for ($l = 0; $l -lt 35; $l++) {
            if ($stable[$k].$l -ne '' -and $stable[$k].$l -ne $null) {
                $cs1.tdata = $([Math]::Log($([int]$stable[$k].$l),2))
                $cs1.data = $([Math]::floor($cs1.tdata))
                $cs1.w = $l

                $smaxerror = ($cs1.d/2-1)
                $sexpected = $cs1.n * $p

                $variancetotal = $cs1.n * $variancesingle
                $stdev = [Math]::Sqrt($variancetotal)
                $t3 = $z * $stdev + $p * $cs1.n
                $compare_d_3 = 2*[Math]::ceiling($t3) + 2

                #ensure we can encode enough data
                $i = 1
                while (($i * $cs1.data) -lt $encode) { $i++ }

                if ($cs1.d -ge $compare_d_3) {

                    #we are certain our candidate encodes the data and error correction is fulfilled, so we focus on coderate
                    $evalrate = 5*($encode/($cs1.n*$i))
                    #even higher error correction capability is encouraged but not required
                    $everr = 0.006*($smaxerror / $t3)

                    $cvalue = $evalrate+$everr

                    if($cvalue -gt $bestvalue) {
                        $bestvalue = $cvalue
                        $bests1.n = $cs1.n
                        $bests1.d = $cs1.d
                        $bests1.w = $cs1.w
                        $bests1.data = $cs1.data
                        $bests1.tdata = $cs1.tdata

                        # Write-Host "$evalrate - rate`n$everr - error"
                        # Write-host "S1: A`($($cs1.n),$($cs1.d),$($cs1.w)`)"
                    }
                }
            }
        }
    }
}
if ($bests1.n -eq $null) { 
    $bests1.n = 0
    $bests1.d = 0
    $bests1.w = 0
    $bests1.data = 0
    return [PSCustomObject]@{s1 = $bests1; totalcoderate = 0; value = $bestvalue; theoreticalcoderate = 0 }
} 
else {
    #Write-Host "`n$encode <= $([Math]::ceiling($encode/$bests1.data)) * $($bests1.data)"
    #Write-host "A`($($bests1.n),$($bests1.d),$($bests1.w)`), total coderate: $($bests1.data/$bests1.n)"
    return [PSCustomObject]@{s1 = $bests1; totalcoderate = $($bests1.data/$bests1.n); value = $bestvalue.toString("0.000"); theoreticalcoderate = $($bests1.tdata/$bests1.n) }
}
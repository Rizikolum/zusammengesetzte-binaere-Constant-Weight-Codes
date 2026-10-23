$cnt = 5000
$cntinner = 5000
$experiments = $cnt * $cntinner

#$rng_eval = @()
$rng_mean = 0
for ($i = 0; $i -lt $cnt; $i++) {
    $rng = [System.Random]::new($i)
    for ($j = 0; $j -lt $cntinner; $j++) {
        $rng_mean += $rng.NextDouble()
    }
}
$rng_mean = $rng_mean / ($cnt*$cntinner)
Write-Host "Durchschnitt für $experiments Ziehungen: $rng_mean"

$rng_var = 0
for ($i = 0; $i -lt $cnt; $i++) {
    $rng = [System.Random]::new($i)
    for ($j = 0; $j -lt $cntinner; $j++) {
        $rng_nextDouble = $rng.NextDouble()
        $rng_var += [Math]::Pow(($rng_nextDouble-$rng_mean),2)
    }
}
$rng_var = 1/$experiments*$rng_var
$rng_stdev = [Math]::Sqrt($rng_var)
$rng_stderr = $rng_stdev / [Math]::Sqrt($experiments)

$critval = 1.96
$lo = $rng_mean - $critval * $rng_stderr
$hi = $rng_mean + $critval * $rng_stderr

Write-host "Varianz: $rng_var, Standardabweichung: $rng_stdev, Standardfehler: $rng_stderr"
Write-host "$lo <= 0.5 <= $hi = $($rng_mean -ge $lo -and $rng_mean -le $hi)"


############################################################################################################
# Durchschnitt für 25000000 Ziehungen: 0.500024006744686                                                   #
# Varianz: 0.0833494119316484, Standardabweichung: 0.288702982200822, Standardfehler: 5.77405964401645E-05 #
# 0.499910835175663 <= 0.5 <= 0.500137178313709 = True                                                     #
############################################################################################################
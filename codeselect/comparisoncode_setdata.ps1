param(
    #[int] $payloadlength=96,
    #[double] $p = 3/43
    $payloadlength=32,
    $p = 0.01,
    $zbase = 1.64
)
$z = $zbase # can be reduced if no lowerbound is found

$variancesingle = $p * (1-$p)
$comparisoncode_3_l = ''
$comparisoncode_3_u = ''
$c3_l = $null
$c3_u = $null

$codelength_l = $payloadlength + [Math]::Ceiling($payloadlength * $p)
while ($comparisoncode_3_l.capacity -lt $payloadlength) {
    $variancetotal_l = $codelength_l * $variancesingle
    $stdev_l = [Math]::Sqrt($variancetotal_l)

    $t3_l = $z * $stdev_l + $p * $codelength_l
    $compare_d_3_l = 2*[Math]::ceiling($t3_l) + 2
    $comparisoncode_3_l = .\codeselect\lowerbound -n $codelength_l -ee $([Math]::ceiling($t3_l))
    $codelength_l++
    if ($comparisoncode_3_l.lowerbound -eq '0') {
        if($z -eq $zbase) { # tries lowering the expected error count once
            $z = 0
            $codelength_l--
        } else { break } # skips if called the second time
    }
    if ($codelength_l -gt (50*$payloadlength)) { #forces a stop if the only options would be coderates below 0,1
        $comparisoncode_3_l = ''
        break
    }
}
$codelength_u = $payloadlength + [Math]::Ceiling($payloadlength * $p)
while ($comparisoncode_3_u.capacity -lt $payloadlength) {
    $variancetotal_u = $codelength_u * $variancesingle
    $stdev_u = [Math]::Sqrt($variancetotal_u)

    $t3_u = $zbase * $stdev_u + $p * $codelength_u
    $compare_d_3_u = 2*[Math]::ceiling($t3_u) + 2
    $comparisoncode_3_u = .\codeselect\upperbound -n $codelength_u -ee $([Math]::ceiling($t3_u))
    $codelength_u++
    if ($codelength_u -gt (50*$payloadlength)) { #forces a stop if the only options would be coderates below 0,1
        $comparisoncode_3_u = ''
        break
    }
}

$codelength_l -= 1
$coderate_l = $(([Math]::floor($comparisoncode_3_l.capacity)/$codelength_l).toString("0.000"))
if ($coderate_l -ne "0,000"){
    if ($z -ne $zbase) { $coderate_l += '*'}
    $c3_l = [PSCustomObject]@{n = $codelength_l; d=$compare_d_3_l; w=$([Math]::Ceiling($codelength_l/2)); e = $t3_l; capacity = $([Math]::floor($comparisoncode_3_l.capacity)); Redundancy = $($codelength_l-[Math]::floor($comparisoncode_3_l.capacity)); Coderate=$coderate_l}
}

$codelength_u -= 1
$coderate_u = $(([Math]::floor($comparisoncode_3_u.capacity)/$codelength_u).toString("0.000"))
if ($coderate_u -ne "0,000") {
    $c3_u = [PSCustomObject]@{n = $codelength_u; d=$compare_d_3_u; w=$([Math]::Ceiling($codelength_u/2)); e = $t3_u; capacity = $([Math]::floor($comparisoncode_3_u.capacity)); Redundancy = $($codelength_u-[Math]::floor($comparisoncode_3_u.capacity)); Coderate=$coderate_u}
}

return [PSCustomObject]@{
    lowerbound = $c3_l
    upperbound = $c3_u
}
param(
        [int]$n = 96,
        [int]$ee = 3,
        [int]$w = 0
)
if ($w -eq 0) { $w = [Math]::ceiling($n/2) }
Add-Type -AssemblyName System.Numerics

# returns x!
function factorial {
    param([int] $x = 10)
    if ($x -eq 0) { return 1}
    [System.Numerics.BigInteger]$factorial = $x
    for ($i = $x-1; $i -gt 1; $i--) { $factorial *= $i }
    return $factorial
}

# returns n over w
function binom {
    param (
    [long]$n = 16,
    [long]$w = 8
    )
    return $((factorial $n)/((factorial $w) * $(factorial $($n-$w))))
}

#hammingbound
[System.Numerics.BigInteger] $divisor = 0
for ($i = 0; $i -le $ee; $i++) { $divisor += $(binom -n $n -w $i) }

try{
    [System.Numerics.BigInteger] $upperbound = [Math]::pow(2,$n) / $divisor

    $upperbound_capacity = [Math]::Log($upperbound,2)
    $upperbound_redundancy = $n - $upperbound_capacity

    #johnsonbound
    $johnsondividend = binom -n $n -w $w
    [System.Numerics.BigInteger] $johnsondivisor = 0
    for ($i = 0; $i -le $ee; $i++) { $johnsondivisor += $($(binom -n $w -w $i)*$(binom -n $($n-$w) -w $i)) }

    $johnsonbound =  $johnsondividend / $johnsondivisor
    return [PSCustomObject]@{upperbound = $upperbound; capacity = $upperbound_capacity; redundancy = $upperbound_redundancy}
} catch {
    return [PSCustomObject]@{upperbound = -1; capacity = -1; redundancy = -1}
}
param(
[String] $c = "11111222223333344444555556666677777888889999900000",
[int] $m = 10
)
[String] $ci = ''
$k = $c.length / $m
$i = -$k
$j = 0

while ($i -le $c.length)
{
    $i += $k
    if ($i -ge $c.length) {
        $j++
        if ($j -eq $k) { break }
        $i = $j  
    }
    $ci += [String] $c[$i]
}
return $ci
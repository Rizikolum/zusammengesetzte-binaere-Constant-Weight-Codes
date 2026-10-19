cls
foreach ($p in 0.01, (3/42), 0.1) {
    foreach ($n in 8, 16, 32, 64, 128, 256) {
        Write-Host "n = $n, p = $p"

        $compare = .\comparison_codes\comparisoncode_setdata.ps1 -codelength $n -p $p
        #Lowerbound
        if ($compare.lowerbound.n -ne $null) {
            $l = "A($($compare.lowerbound.n),$($compare.lowerbound.d),$($compare.lowerbound.w)), usable Coderate: $($compare.lowerbound.Coderate) "
        } else { $l = "/" }

        Write-Host "Lowerbound: $l"

        #KS
        $ks = .\KS\find_best_code_ks.ps1 -p $p -encode $n -z 3
        if ($ks.s1.n -ne 0) {
            Write-host "KS:`t`t`tA($($ks.s1.n),$($ks.s1.d),$($ks.s1.w)) usable Coderate: $($ks.totalcoderate.toString("0.000")), Score: $($ks.value) "#$($ks.theoreticalcoderate.toString("0.000"))
        }

        #SWTC
        $swtc = .\SWTC\find_best_code_swtc.ps1 -p $p -encode $n -z 3
        if ($swtc.s1.n -ne 0) {
            Write-host "SWTC:`t`tCW($($swtc.cw.n),$($swtc.cw.d),$($swtc.cw.w)), S1($($swtc.s1.n),$($swtc.s1.d),$($swtc.s1.w)), S2($($swtc.s2.n),$($swtc.s2.d),$($swtc.s2.w)) usable Coderate: $($swtc.totalcoderate.toString("0.000")), Score: $($swtc.value)"# $($swtc.theoreticalcoderate.toString("0.000"))
        }
            
        #Upperbound
                if ($compare.upperbound.n -ne $null) {
            $u = "A($($compare.upperbound.n),$($compare.upperbound.d),$($compare.upperbound.w)), usable Coderate: $($compare.upperbound.Coderate) "
        }  else { $u = "/" }

        Write-Host "Upperbound: $u`n"

        $l = $null
        $u = $null
    }
}
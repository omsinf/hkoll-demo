Param(
    [Parameter(Mandatory = $true)]
    [string]$divId
)

# Important: Run this script from the root of hkoll-demo
$ROOT = Get-Location
"[OK] Root set: $ROOT"

# Select the executable according to detected operating system
$HkollExe = If ($IsLinux) { "$ROOT/hkoll/bins/linux/Hkoll-1.10.2" }
ElseIf ($IsMacOS) { "$ROOT/hkoll/bins/macos/Hkoll-1.8.1" }
ElseIf ($IsWindows) { "$ROOT/hkoll/bins/windows/Hkoll-1.10.2.exe" }

If (Test-Path -Path $HkollExe -PathType Leaf) { "[OK] Found executable: $HkollExe" }
Else { "[FAIL] Did not find executable: $HkollExe'"; "Are you running this script from the correct path?"; Exit }

$ConfigFile = "$ROOT/hkoll/Configs.yaml"
$HkollOutput = "$ROOT/output/collated.xml"
$SaxonOutput = "$ROOT/output/collated.html"

# Run Hkoll from /hkoll/bins to make the relative paths work"
Push-Location -path $ROOT/hkoll/bins
& $HkollExe --config-file $ConfigFile --out-path $HkollOutput --div $divId --dev
$HkollSuccess = $?
Pop-Location
If ($HkollSuccess) {
    "[OK] Hkoll exited successfully."
}
Else { "[FAIL] Hkoll exited with error."; Exit }

& java -cp $Env:SAXON_JAR net.sf.saxon.Transform -t -xi `
    -s:$HkollOutput `
    -xsl:$ROOT/xsl/simple.xsl `
    -o:$SaxonOutput

If ($?) {
    "[OK] Saxon exited successfully. Find the HTML here: $SaxonOutput"
}
Else {
    "[FAIL] Something went wrong. Check paths and file names and consider error messages to find the problem."
}

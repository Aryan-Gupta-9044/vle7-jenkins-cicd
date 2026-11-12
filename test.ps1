$html = Get-Content app/index.html -Raw
if ($html -match "VLE 7" -and $html -match "Jenkins CI/CD") {
    Write-Output "Application test passed"
    exit 0
}
Write-Error "Application test failed"
exit 1

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$phpExe = 'C:\xampp\php\php.exe'

if (-not (Test-Path $phpExe)) {
    Write-Host "PHP non trouvé : $phpExe"
    Write-Host 'Installe XAMPP ou modifie le chemin dans ce script.'
    exit 1
}

Write-Host 'Démarrage du backend PHP sur http://localhost:3000 ...'
Start-Process powershell -ArgumentList '-NoExit','-Command',"cd `"$projectRoot`"; & `"$phpExe`" -S localhost:3000 router.php"

Start-Sleep -Seconds 3

Set-Location "$projectRoot\mobile_app"
Write-Host 'Démarrage de l\'application Flutter...'
flutter clean
flutter pub get
flutter run -d 2201117TG

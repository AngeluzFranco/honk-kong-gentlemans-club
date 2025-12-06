# Scripts para ejecutar tests de integración

# Ejecutar todos los tests de integración
function Run-AllIntegrationTests {
    Write-Host "🧪 Ejecutando todos los tests de integración..." -ForegroundColor Cyan
    flutter test integration_test/ -d emulator-5554
}

# Ejecutar solo test del flujo principal
function Run-AppTest {
    Write-Host "🧪 Ejecutando test del flujo principal completo..." -ForegroundColor Cyan
    flutter test integration_test/app_test.dart -d emulator-5554
}

# Ejecutar solo tests de autenticación
function Run-AuthTests {
    Write-Host "🧪 Ejecutando tests de autenticación..." -ForegroundColor Cyan
    flutter test integration_test/auth_flow_test.dart -d emulator-5554
}

# Ejecutar solo tests CRUD de vehículos
function Run-VehicleTests {
    Write-Host "🧪 Ejecutando tests CRUD de vehículos..." -ForegroundColor Cyan
    flutter test integration_test/vehicle_crud_test.dart -d emulator-5554
}

# Ejecutar test básico
function Run-BasicTest {
    Write-Host "🧪 Ejecutando test básico..." -ForegroundColor Cyan
    flutter test integration_test/basic_test.dart -d emulator-5554
}

# Ejecutar tests unitarios
function Run-UnitTests {
    Write-Host "🧪 Ejecutando tests unitarios..." -ForegroundColor Cyan
    flutter test test/models/
}

# Ejecutar todos los tests (unitarios + integración)
function Run-AllTests {
    Write-Host "🧪 Ejecutando tests unitarios..." -ForegroundColor Cyan
    flutter test test/models/
    
    Write-Host "`n🧪 Ejecutando tests de integración..." -ForegroundColor Cyan
    flutter test integration_test/ -d emulator-5554
}

# Verificar análisis de código
function Run-Analysis {
    Write-Host "🔍 Analizando código..." -ForegroundColor Cyan
    flutter analyze
}

# Ejecutar todo (análisis + tests)
function Run-FullCheck {
    Write-Host "🔍 Ejecutando análisis completo..." -ForegroundColor Cyan
    flutter analyze
    
    Write-Host "`n🧪 Ejecutando tests unitarios..." -ForegroundColor Cyan
    flutter test test/models/
    
    Write-Host "`n🧪 Ejecutando tests de integración..." -ForegroundColor Cyan
    flutter test integration_test/ -d emulator-5554
}

# Mostrar ayuda
function Show-TestHelp {
    Write-Host "`n📋 Comandos disponibles para tests:" -ForegroundColor Yellow
    Write-Host "  Run-AllIntegrationTests  - Ejecutar todos los tests de integración" -ForegroundColor White
    Write-Host "  Run-BasicTest           - Ejecutar test básico (diagnóstico)" -ForegroundColor White
    Write-Host "  Run-AppTest             - Ejecutar test del flujo principal" -ForegroundColor White
    Write-Host "  Run-AuthTests           - Ejecutar tests de autenticación" -ForegroundColor White
    Write-Host "  Run-VehicleTests        - Ejecutar tests CRUD de vehículos" -ForegroundColor White
    Write-Host "  Run-UnitTests           - Ejecutar tests unitarios" -ForegroundColor White
    Write-Host "  Run-AllTests            - Ejecutar todos los tests" -ForegroundColor White
    Write-Host "  Run-Analysis            - Ejecutar análisis de código" -ForegroundColor White
    Write-Host "  Run-FullCheck           - Análisis + todos los tests" -ForegroundColor White
    Write-Host "`n⚠️  IMPORTANTE: El emulador debe estar corriendo (emulator-5554)" -ForegroundColor Yellow
    Write-Host "`n💡 Ejemplo:" -ForegroundColor Yellow
    Write-Host "  PS> Run-BasicTest       # Test simple para verificar que todo funciona" -ForegroundColor Gray
    Write-Host "  PS> Run-UnitTests       # Rápido, no requiere emulador" -ForegroundColor Gray
    Write-Host "  PS> Run-AuthTests       # Requiere emulador Android`n" -ForegroundColor Gray
}

# Mostrar ayuda al cargar
Show-TestHelp

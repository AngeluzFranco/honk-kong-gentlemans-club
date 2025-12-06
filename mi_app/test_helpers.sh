#!/bin/bash
# Scripts para ejecutar tests de integración (Linux/Mac)

# Colores
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
WHITE='\033[0;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Ejecutar todos los tests de integración
run_all_integration_tests() {
    echo -e "${CYAN}🧪 Ejecutando todos los tests de integración...${NC}"
    flutter test integration_test/
}

# Ejecutar solo test del flujo principal
run_app_test() {
    echo -e "${CYAN}🧪 Ejecutando test del flujo principal completo...${NC}"
    flutter test integration_test/app_test.dart
}

# Ejecutar solo tests de autenticación
run_auth_tests() {
    echo -e "${CYAN}🧪 Ejecutando tests de autenticación...${NC}"
    flutter test integration_test/auth_flow_test.dart
}

# Ejecutar solo tests CRUD de vehículos
run_vehicle_tests() {
    echo -e "${CYAN}🧪 Ejecutando tests CRUD de vehículos...${NC}"
    flutter test integration_test/vehicle_crud_test.dart
}

# Ejecutar tests unitarios
run_unit_tests() {
    echo -e "${CYAN}🧪 Ejecutando tests unitarios...${NC}"
    flutter test test/models/
}

# Ejecutar todos los tests (unitarios + integración)
run_all_tests() {
    echo -e "${CYAN}🧪 Ejecutando tests unitarios...${NC}"
    flutter test test/models/
    
    echo -e "\n${CYAN}🧪 Ejecutando tests de integración...${NC}"
    flutter test integration_test/
}

# Verificar análisis de código
run_analysis() {
    echo -e "${CYAN}🔍 Analizando código...${NC}"
    flutter analyze
}

# Ejecutar todo (análisis + tests)
run_full_check() {
    echo -e "${CYAN}🔍 Ejecutando análisis completo...${NC}"
    flutter analyze
    
    echo -e "\n${CYAN}🧪 Ejecutando tests unitarios...${NC}"
    flutter test test/models/
    
    echo -e "\n${CYAN}🧪 Ejecutando tests de integración...${NC}"
    flutter test integration_test/
}

# Mostrar ayuda
show_help() {
    echo -e "\n${YELLOW}📋 Comandos disponibles para tests:${NC}"
    echo -e "  ${WHITE}./test_helpers.sh all-integration  - Ejecutar todos los tests de integración${NC}"
    echo -e "  ${WHITE}./test_helpers.sh app              - Ejecutar test del flujo principal${NC}"
    echo -e "  ${WHITE}./test_helpers.sh auth             - Ejecutar tests de autenticación${NC}"
    echo -e "  ${WHITE}./test_helpers.sh vehicle          - Ejecutar tests CRUD de vehículos${NC}"
    echo -e "  ${WHITE}./test_helpers.sh unit             - Ejecutar tests unitarios${NC}"
    echo -e "  ${WHITE}./test_helpers.sh all              - Ejecutar todos los tests${NC}"
    echo -e "  ${WHITE}./test_helpers.sh analyze          - Ejecutar análisis de código${NC}"
    echo -e "  ${WHITE}./test_helpers.sh full             - Análisis + todos los tests${NC}"
    echo -e "\n${YELLOW}💡 Ejemplo:${NC}"
    echo -e "  ${GRAY}$ ./test_helpers.sh auth${NC}\n"
}

# Main
case "$1" in
    all-integration)
        run_all_integration_tests
        ;;
    app)
        run_app_test
        ;;
    auth)
        run_auth_tests
        ;;
    vehicle)
        run_vehicle_tests
        ;;
    unit)
        run_unit_tests
        ;;
    all)
        run_all_tests
        ;;
    analyze)
        run_analysis
        ;;
    full)
        run_full_check
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo -e "${YELLOW}⚠️  Comando desconocido: $1${NC}"
        show_help
        exit 1
        ;;
esac

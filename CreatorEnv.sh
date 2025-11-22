#!/usr/bin/env bash
#CreatorEnv
set -euo pipefail

# === Константы ===
LOGFILE="${HOME}/setup_CreatorEnv.log"
MINICONDA_DIR="${HOME}/miniconda3"
MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
PROJECT_NAME=""
PYTHON_VERSION=""
ROCM_VERSION=""
INSTALL_METHOD=""
PYTORCH_ROCM_URL=""
LANGUAGE="ru"  # По умолчанию русский
PROJECT_DIR=""
REPO_URL=""
REPO_NAME=""
SETUP_MODE=""
REPO_ACTION=""

# === Вспомогательные функции ===
log() {
    echo "🚀 $1" | tee -a "$LOGFILE"
}

error() {
    echo "❌ $1" >&2
    exit 1
}

warning() {
    echo "⚠️  $1" >&2
}

success() {
    echo "✅ $1"
}

# === Переводы ===
translate() {
    local key="$1"

    case "$LANGUAGE" in
        ru)
            case "$key" in
                welcome) echo "🚀 Создание изолированного окружения Conda с выбранной версией Python, Pytorch ROCm" ;;
                architecture_error) echo "Скрипт рассчитан на x86_64. Найдена архитектура: $arch" ;;
                required_tools_missing) echo "Утилита $tool не найдена. Устанавливаем..." ;;
                conda_already_installed) echo "Miniconda уже установлена в $MINICONDA_DIR" ;;
                conda_available_in_path) echo "Conda доступна в PATH, установка пропущена." ;;
                conda_installing) echo "Miniconda не найдена. Начинаем установку..." ;;
                downloading_miniconda) echo "Скачиваем установщик Miniconda из $MINICONDA_URL в $TMP_SH..." ;;
                miniconda_download_failed) echo "Не удалось скачать установщик Miniconda." ;;
                making_executable) echo "Делаем установщик исполняемым и создаем целевую директорю." ;;
                running_miniconda_install) echo "Запуск установки Miniconda в $MINICONDA_DIR, используя чистый интерпретатор Bash..." ;;
                miniconda_install_failed) echo "Ошибка при выполнении установщика Miniconda. Проверьте лог-файл!" ;;
                miniconda_not_installed) echo "Miniconda не была установлена в $MINICONDA_DIR. Проверьте лог-файл." ;;
                conda_initialized) echo "Miniconda успешно установлена." ;;
                python_selection) echo "🐍 Выберите версию Python:" ;;
                method_selection) echo "🔧 Выберите метод установки ROCm:" ;;
                wheel_method) echo "  [1] Установка с сайта repo.radeon ROCm wheel-файлов (в папку rocm_wheel)" ;;
                torch_selection) echo "🚀 Выбрана установка из сайта repo.radeon" ;;
                torch_version_selection) echo "📦 Выберите версию ROCm:" ;;
                rocm_versions_fetching) echo "🌐 Получение доступных версий ROCm с ${ROOT_INDEX}..." ;;
                no_rocm_versions_found) echo "Не найдено версий ROCm ≥ 6.3 в ${ROOT_INDEX}" ;;
                checking_compatibility) echo "🔍 Проверка совместимости wheel-файлов для Python $PYTHON_VERSION:" ;;
                select_rocm_version) echo "🔢 Выберите версию ROCm:" ;;
                project_name_input) echo "📁 Введите имя проекта (пример: comfy_project):" ;;
                setup_mode_selection) echo "🔧 Выберите режим установки:" ;;
                install_comfyui) echo "  [1] Установить ComfyUI (включая окружение и пакеты)" ;;
                create_env_only) echo "  [2] Создать окружение с выбранными параметрами (без ComfyUI)" ;;
                repo_action_selection) echo "🔧 Выберите дальнейшее действие:" ;;
                install_repo_with_deps) echo "  [1] Установить окружение и репозиторий с зависимостями" ;;
                create_env_only_no_repo) echo "  [2] Установить только окружение (без репозитория)" ;;
                repo_url_input) echo "🌐 Введите URL репозитория (пример: https://github.com/user/project.git):" ;;
                summary_title) echo "📋 Резюме установки:" ;;
                confirm_installation) echo "❓ Продолжить установку с этими параметрами? (y/n):" ;;
                creating_conda_env) echo "🔧 Создаём conda-окружение: ${PROJECT_NAME} (python=$PYTHON_VERSION)" ;;
                installing_pytorch) echo "📥 Устанавливаем PyTorch из wheel файлов repo.radeon..." ;;
                cloning_comfyui) echo "📥 Клонируем ComfyUI..." ;;
                removing_requirements) echo "Удаляем зависимости из requirements.txt" ;;
                installing_manager) echo "📥 Устанавливаем ComfyUI-Manager..." ;;
                creating_run_script) echo "🔧 Создаём скрипт запуска ComfyUI..." ;;
                cloning_repo) echo "📥 Клонируем репозиторий: $REPO_URL" ;;
                installing_dependencies) echo "📥 Устанавливаем зависимости из requirements.txt" ;;
                disabling_autoactivate) echo "Отключаем автоматическую активацию Conda..." ;;
                installation_complete) echo "🎉 Установка завершена!" ;;
                run_script_created) echo "🔧 Скрипт запуска создан: ${PROJECT_DIR}/ComfyUI/run.sh" ;;
                project_ready) echo "✅ Окружение создано и готово для использования." ;;
                invalid_input) echo "❌ Некорректный ввод: $input" ;;
                empty_project_name) echo "❌ Имя проекта не может быть пустым" ;;
                empty_repo_url) echo "❌ URL репозитория не может быть пустым" ;;
                lang_selection) echo "🌐 Выберите язык интерфейса:" ;;
                lang_ru) echo "  [1] Русский" ;;
                lang_en) echo "  [2] English" ;;
                lang_invalid) echo "❌ Некорректный выбор языка: $lang_input" ;;
                * ) echo "$key" ;; # Если перевод не найден, возвращаем ключ как есть
            esac
            ;;
        en)
            case "$key" in
                welcome) echo "🚀 Create an isolated Conda environment with a selected Python version, Pytorch ROCm" ;;
                architecture_error) echo "The script is designed for x86_64. Found architecture: $arch" ;;
                required_tools_missing) echo "Required tool $tool not found. Installing..." ;;
                conda_already_installed) echo "Miniconda already installed at $MINICONDA_DIR" ;;
                conda_available_in_path) echo "Conda available in PATH, installation skipped." ;;
                conda_installing) echo "Miniconda not found. Starting installation..." ;;
                downloading_miniconda) echo "Downloading Miniconda installer from $MINICONDA_URL to $TMP_SH..." ;;
                miniconda_download_failed) echo "Failed to download Miniconda installer." ;;
                making_executable) echo "Making installer executable and creating target directory." ;;
                running_miniconda_install) echo "Running Miniconda installation in $MINICONDA_DIR using clean Bash interpreter..." ;;
                miniconda_install_failed) echo "Error during Miniconda installer execution. Check log file!" ;;
                miniconda_not_installed) echo "Miniconda was not installed in $MINICONDA_DIR. Check log file." ;;
                conda_initialized) echo "Miniconda successfully installed." ;;
                python_selection) echo "🐍 Select Python version:" ;;
                method_selection) echo "🔧 Select ROCm installation method:" ;;
                wheel_method) echo "  [1] Installation from repo.radeon ROCm wheel files (to rocm_wheel folder)" ;;
                torch_selection) echo "🚀 Selected installation from repo.radeon" ;;
                torch_version_selection) echo "📦 Select ROCm version:" ;;
                rocm_versions_fetching) echo "🌐 Fetching available ROCm versions from ${ROOT_INDEX}..." ;;
                no_rocm_versions_found) echo "No ROCm ≥ 6.3 versions found in ${ROOT_INDEX}" ;;
                checking_compatibility) echo "🔍 Checking wheel compatibility for Python $PYTHON_VERSION:" ;;
                select_rocm_version) echo "🔢 Select ROCm version:" ;;
                project_name_input) echo "📁 Enter project name (example: comfy_project):" ;;
                setup_mode_selection) echo "🔧 Select installation mode:" ;;
                install_comfyui) echo "  [1] Install ComfyUI (including environment and packages)" ;;
                create_env_only) echo "  [2] Create environment with selected parameters only (no ComfyUI)" ;;
                repo_action_selection) echo "🔧 Select further action:" ;;
                install_repo_with_deps) echo "  [1] Install environment and repository with dependencies" ;;
                create_env_only_no_repo) echo "  [2] Install only environment (no repository)" ;;
                repo_url_input) echo "🌐 Enter repository URL (example: https://github.com/user/project.git):" ;;
                summary_title) echo "📋 Installation Summary:" ;;
                confirm_installation) echo "❓ Continue with this configuration? (y/n):" ;;
                creating_conda_env) echo "🔧 Creating conda environment: ${PROJECT_NAME} (python=$PYTHON_VERSION)" ;;
                installing_pytorch) echo "📥 Installing PyTorch from repo.radeon wheel files..." ;;
                cloning_comfyui) echo "📥 Cloning ComfyUI..." ;;
                removing_requirements) echo "Removing dependencies from requirements.txt" ;;
                installing_manager) echo "📥 Installing ComfyUI-Manager..." ;;
                creating_run_script) echo "🔧 Creating ComfyUI run script..." ;;
                cloning_repo) echo "📥 Cloning repository: $REPO_URL" ;;
                installing_dependencies) echo "📥 Installing dependencies from requirements.txt" ;;
                disabling_autoactivate) echo "Disabling automatic Conda activation..." ;;
                installation_complete) echo "🎉 Installation completed!" ;;
                run_script_created) echo "🔧 Run script created: ${PROJECT_DIR}/ComfyUI/run.sh" ;;
                project_ready) echo "✅ Environment created and ready for use." ;;
                invalid_input) echo "❌ Invalid input: $input" ;;
                empty_project_name) echo "❌ Project name cannot be empty" ;;
                empty_repo_url) echo "❌ Repository URL cannot be empty" ;;
                lang_selection) echo "🌐 Select interface language:" ;;
                lang_ru) echo "  [1] Русский" ;;
                lang_en) echo "  [2] English" ;;
                lang_invalid) echo "❌ Invalid language selection: $lang_input" ;;
                * ) echo "$key" ;; # Если перевод не найден, возвращаем ключ как есть
            esac
            ;;
        *)
            echo "$key"
            ;;
    esac
}

# === Основные функции ===
check_architecture() {
    local arch=$(uname -m)
    if [ "$arch" != "x86_64" ]; then
        error "$(translate architecture_error)"
    fi
}

detect_package_manager() {
    if command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        error "Не найден ни один пакетный менеджер (dnf, apt или zypper)"
    fi
}

install_required_tools() {
    local REQUIRED_TOOLS=(curl grep wget git sudo sort uniq sed awk find)
    local PACKAGE_MANAGER=$(detect_package_manager)

    log "Обнаружен пакетный менеджер: $PACKAGE_MANAGER"

    for tool in "${REQUIRED_TOOLS[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log "$(translate required_tools_missing)"

            case "$PACKAGE_MANAGER" in
                "dnf")
                    sudo dnf install -y "$tool"
                    ;;
                "apt")
                    sudo apt update -y
                    sudo apt install -y "$tool"
                    ;;
                "zypper")
                    sudo zypper refresh
                    sudo zypper install -y "$tool"
                    ;;
            esac

            success "$tool установлен."
        else
            success "$tool уже установлен."
        fi
    done
}

install_miniconda() {
    if [ -d "$MINICONDA_DIR" ]; then
        success "Miniconda уже установлена в $MINICONDA_DIR"
        export PATH="$MINICONDA_DIR/bin:$PATH"
        log "Обновляем Conda..."
        conda update conda --yes --quiet || log "Предупреждение: не удалось обновить Conda."
    elif command -v conda &> /dev/null; then
        success "Conda доступна в PATH, установка пропущена."
    else
        log "$(translate conda_installing)"

        local TMP_SH="${HOME}/miniconda_installer.sh"

        log "$(translate downloading_miniconda)"
        wget -q "$MINICONDA_URL" -O "$TMP_SH"

        if [ ! -f "$TMP_SH" ]; then
            error "$(translate miniconda_download_failed)"
        fi

        log "$(translate making_executable)"
        chmod +x "$TMP_SH" || error "Не удалось сделать установщик Miniconda исполняемым."
        mkdir -p "$MINICONDA_DIR" || error "Не удалось создать директорию $MINICONDA_DIR"

        log "$(translate running_miniconda_install)"

        # Принимаем лицензию автоматически и используем опцию -u для обновления
        echo "yes" | /bin/bash --noprofile "$TMP_SH" -b -u -p "$MINICONDA_DIR" || error "$(translate miniconda_install_failed)"

        rm -f "$TMP_SH"

        if [ ! -d "$MINICONDA_DIR" ]; then
            error "$(translate miniconda_not_installed)"
        fi

        success "$(translate conda_initialized)"
    fi

    export PATH="$MINICONDA_DIR/bin:$PATH"

    # Инициализация conda в текущем сеансе
    if [ -f "$MINICONDA_DIR/etc/profile.d/conda.sh" ]; then
        source "$MINICONDA_DIR/etc/profile.d/conda.sh"
    fi

    # Проверяем, что conda доступна
    if ! command -v conda &> /dev/null; then
        error "Conda не может быть инициализирована. Проверьте установку."
    fi

    # Принимаем Terms of Service для стандартных каналов
    log "Принимаем Terms of Service для стандартных каналов..."
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

    # Активируем базовое окружение
    conda activate base 2>/dev/null || log "Предупреждение: Не удалось активировать базовое окружение."

    # Добавляем автоматическую инициализацию для текущего сеанса
    CONDA_INIT_LINE1="export PATH=\"$MINICONDA_DIR/bin:\$PATH\""
    CONDA_INIT_LINE2="source $MINICONDA_DIR/etc/profile.d/conda.sh"

    if ! grep -qF "$CONDA_INIT_LINE1" ~/.bashrc; then
        echo "$CONDA_INIT_LINE1" >> ~/.bashrc
    fi

    if ! grep -qF "$CONDA_INIT_LINE2" ~/.bashrc; then
        echo "$CONDA_INIT_LINE2" >> ~/.bashrc
    fi
}

select_language() {
    log "$(translate lang_selection)"
    echo "$(translate lang_ru)"
    echo "$(translate lang_en)"

    while true; do
        read -rp "🔢 Enter language number: " LANG_INPUT
        if [[ "$LANG_INPUT" =~ ^[12]$ ]]; then
            LANGUAGE="${LANG_INPUT}"
            break
        else
            echo "$(translate lang_invalid)"
        fi
    done

    case "$LANGUAGE" in
        1) LANGUAGE="ru" ;;
        2) LANGUAGE="en" ;;
    esac
}

select_python_version() {
    local PYTHON_MENU=("3.9" "3.10" "3.11" "3.12" "3.13")

    log "$(translate python_selection)"
    for i in "${!PYTHON_MENU[@]}"; do
        echo "  [$((i+1))] Python ${PYTHON_MENU[$i]}"
    done

    while true; do
        read -rp "🔢 Enter Python version number: " PYTHON_INDEX
        if ! [[ "$PYTHON_INDEX" =~ ^[1-9][0-9]*$ ]] || (( PYTHON_INDEX < 1 || PYTHON_INDEX > ${#PYTHON_MENU[@]} )); then
            echo "$(translate invalid_input)"
        else
            break
        fi
    done

    PYTHON_VERSION="${PYTHON_MENU[$((PYTHON_INDEX-1))]}"
    PY_TAG="${PYTHON_VERSION//./}"
}

select_install_method() {
    log "$(translate method_selection)"
    echo "$(translate wheel_method)"

    while true; do
        read -rp "🔢 Enter installation method number: " INSTALL_METHOD
        if [[ "$INSTALL_METHOD" =~ ^[1]$ ]]; then
            break
        else
            echo "$(translate invalid_input)"
        fi
    done

    if [ "$INSTALL_METHOD" = "1" ]; then
        log "$(translate torch_selection)"
    fi
}

get_rocm_versions() {
    local ROOT_INDEX="https://repo.radeon.com/rocm/manylinux/"
    log "$(translate rocm_versions_fetching)"

    local RAW_HTML
    RAW_HTML=$(curl -s -L "$ROOT_INDEX" || true)

    mapfile -t ROCM_OPTIONS < <(
        printf "%s\n" "$RAW_HTML" \
            | grep -oE 'href="rocm-rel-[0-9]+\.[0-9]+(\.[0-9]+)?/' \
            | sed 's/href="rocm-rel-//' | sed 's|/||' \
            | sort -Vr \
            | awk -F. -v min_major=6 -v min_minor=3 \
                '($1>min_major) || ($1==min_major && $2>=min_minor)'
    )

    if [ "${#ROCM_OPTIONS[@]}" -eq 0 ]; then
        warning "$(translate no_rocm_versions_found)"
        log "Нет доступных версий ROCm ≥ 6.3. Продолжаем с выбором из меню..."
        select_compatible_rocm_version
    else
        check_rocm_compatibility "${ROCM_OPTIONS[@]}"
    fi
}

check_rocm_compatibility() {
    local ROCM_OPTIONS=("$@")

    log "$(translate checking_compatibility)"
    printf "%-10s | %-6s | %-10s | %-10s | %-20s\n" "ROCm" "torch" "torchvision" "torchaudio" "pytorch_triton_rocm"
    printf -- "---------------------------------------------------------------\n"

    declare -A ROCM_COMPATIBLE
    for version in "${ROCM_OPTIONS[@]}"; do
        local base_url="https://repo.radeon.com/rocm/manylinux/rocm-rel-${version}/"
        local status=()

        for pkg in torch torchvision torchaudio pytorch_triton_rocm; do
            local cp_tag="cp${PY_TAG}-cp${PY_TAG}"

            # Обработка специфики ROCm 7.0+
            if [[ "$version" =~ ^7\. ]]; then
                # Для ROCm 7.0.2+ используется triton вместо pytorch_triton_rocm
                if [[ "$version" =~ ^7\.0\.2 ]] || [[ "$version" > "7.0.2" ]]; then
                    if [ "$pkg" = "pytorch_triton_rocm" ]; then
                        # Для ROCm 7.0.2+ используем triton вместо pytorch_triton_rocm
                        local pattern="triton-[^\"']*+rocm${version}[^\"']*${cp_tag}[^\"']*linux_x86_64\\.whl"
                    else
                        local pattern="${pkg}-[^\"']*+rocm${version}[^\"']*${cp_tag}[^\"']*linux_x86_64\\.whl"
                    fi
                else
                    # Для ROCm 7.0.0 и 7.0.1 используем старое имя pytorch_triton_rocm
                    if [ "$pkg" = "pytorch_triton_rocm" ]; then
                        local pattern="${pkg}-[^\"']*+rocm${version}[^\"']*${cp_tag}[^\"']*linux_x86_64\\.whl"
                    else
                        local pattern="${pkg}-[^\"']*+rocm${version}[^\"']*${cp_tag}[^\"']*linux_x86_64\\.whl"
                    fi
                fi
            else
                local pattern="${pkg}-[^\"']*+rocm${version}[^\"']*${cp_tag}[^\"']*linux_x86_64\\.whl"
            fi

            local file=$(curl -s -L "${base_url}" | grep -oE "${pattern}" | sort -V | tail -n 1 || true)

            if [ -z "$file" ]; then
                status+=("❌")
            else
                status+=("✅")
            fi
        done

        printf "%-10s | %-6s | %-10s | %-10s | %-20s\n" "$version" "${status[@]}"

        if [[ "${status[*]}" =~ "❌" ]]; then
            ROCM_COMPATIBLE["$version"]="incomplete"
        else
            ROCM_COMPATIBLE["$version"]="complete"
        fi
    done

    # Выбираем только совместимые версии для передачи в select_compatible_rocm_version
    local COMPATIBLE_LIST=()
    for version in "${ROCM_OPTIONS[@]}"; do
        if [ "${ROCM_COMPATIBLE[$version]}" == "complete" ]; then
            COMPATIBLE_LIST+=("$version")
        fi
    done

    if [ ${#COMPATIBLE_LIST[@]} -gt 0 ]; then
        select_compatible_rocm_version "${COMPATIBLE_LIST[@]}"
    else
        warning "No compatible ROCm versions found with Python $PYTHON_VERSION"
        error "Не найдено подходящих версий ROCm для выбранного Python."
    fi
}

select_compatible_rocm_version() {
    local ROCM_OPTIONS=("$@")

    log "$(translate select_rocm_version)"

    if [ ${#ROCM_OPTIONS[@]} -eq 0 ]; then
        error "No compatible ROCm versions found for Python $PYTHON_VERSION"
    fi

    local i=1
    declare -A VERSION_MAP
    for version in $(printf '%s\n' "${ROCM_OPTIONS[@]}" | sort -Vr); do
        echo "  [$i] ROCm $version ✅ (all packages found)"
        VERSION_MAP["$i"]="$version"
        i=$((i+1))
    done

    while true; do
        read -rp "🔢 Enter ROCm version number: " ROCM_INDEX
        if [[ "$ROCM_INDEX" =~ ^[1-9][0-9]*$ ]] && (( ROCM_INDEX >= 1 && ROCM_INDEX <= ${#ROCM_OPTIONS[@]} )); then
            ROCM_VERSION="${VERSION_MAP[$ROCM_INDEX]}"
            break
        else
            echo "$(translate invalid_input)"
        fi
    done

    log "Selected ROCm version: $ROCM_VERSION"
}

get_project_name() {
    while true; do
        read -rp "$(translate project_name_input): " PROJECT_NAME
        if [ -n "${PROJECT_NAME}" ]; then
            break
        else
            echo "$(translate empty_project_name)"
        fi
    done

    PROJECT_DIR="${HOME}/${PROJECT_NAME}"
}

select_setup_mode() {
    log "$(translate setup_mode_selection)"
    echo "$(translate install_comfyui)"
    echo "$(translate create_env_only)"

    while true; do
        read -rp "🔢 Enter setup mode number: " SETUP_MODE
        if [[ "$SETUP_MODE" =~ ^[12]$ ]]; then
            break
        else
            echo "$(translate invalid_input)"
        fi
    done

    if [ "$SETUP_MODE" = "2" ]; then
        select_repo_action
    fi
}

select_repo_action() {
    log "$(translate repo_action_selection)"
    echo "$(translate install_repo_with_deps)"
    echo "$(translate create_env_only_no_repo)"

    while true; do
        read -rp "🔢 Enter action number: " REPO_ACTION
        if [[ "$REPO_ACTION" =~ ^[12]$ ]]; then
            break
        else
            echo "$(translate invalid_input)"
        fi
    done

    if [ "$REPO_ACTION" = "1" ]; then
        get_repo_url
    fi
}

get_repo_url() {
    read -rp "$(translate repo_url_input): " REPO_URL
    if [ -z "$REPO_URL" ]; then
        error "$(translate empty_repo_url)"
    fi
    REPO_NAME=$(basename "$REPO_URL" .git)
}

show_summary() {
    log "$(translate summary_title)"
    echo "  🗂️ Project:        ${PROJECT_NAME}"
    echo "  🐍 Python:        $PYTHON_VERSION"

    if [ "$INSTALL_METHOD" = "1" ]; then
        echo "  🔧 ROCm:          $ROCM_VERSION"
        echo "  📦 Installation method: ROCm wheel files"
    fi

    echo "  📁 Project folder: $PROJECT_DIR"
    echo "  🧠 Setup mode: $(if [ "$SETUP_MODE" = "1" ]; then echo "ComfyUI + environment"; else echo "Environment only"; fi)"

    if [ "$SETUP_MODE" = "2" ]; then
        echo "  📦 Further action: $(if [ "$REPO_ACTION" = "1" ]; then echo "Install repository with dependencies"; else echo "Environment only"; fi)"
    fi

    read -rp "$(translate confirm_installation)" CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "Installation cancelled."
        exit 0
    fi
}

create_conda_env() {
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"

    log "$(translate creating_conda_env)"
    conda create -y -n "${PROJECT_NAME}" python="$PYTHON_VERSION"

    # Проверка совместимости библиотек для ROCm 7.x
    if [ "$INSTALL_METHOD" = "1" ] && [[ "$ROCM_VERSION" =~ ^7 ]]; then
        log "🔧 For ROCm 7.x requires updated libstdc++"
        conda run -n "${PROJECT_NAME}" --no-capture-output conda install -c conda-forge libstdcxx-ng -y
    fi

    # Обновляем pip в новом окружении
    PIP_CMD="conda run -n ${PROJECT_NAME} --no-capture-output python -m pip"
    $PIP_CMD install --upgrade pip wheel setuptools
}

install_pytorch() {
    if [ "$INSTALL_METHOD" = "1" ]; then
        log "$(translate installing_pytorch)"
        install_from_wheels
    fi
}

install_from_wheels() {
    local ROOT_INDEX="https://repo.radeon.com/rocm/manylinux/"
    local ROCM_VERSION="${ROCM_VERSION}"
    local CANDIDATES=("rocm-rel-${ROCM_VERSION}")
    local WHEEL_DIR="${HOME}/rocm_wheels"
    mkdir -p "$WHEEL_DIR"

    # Функция сравнения версий
    version_ge() {
        local v1="$1" v2="$2"
        if [[ "$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | head -n1)" == "$v2" ]]; then
            return 0
        else
            return 1
        fi
    }

    download_from_base() {
        local pkg="$1"
        local base_url="$2"
        local cp_tag="cp${PY_TAG}-cp${PY_TAG}"
        local pattern

        # Определяем шаблон
        if version_ge "$ROCM_VERSION" "7.0.2"; then
            if [ "$pkg" = "pytorch_triton_rocm" ]; then
                # Ищем `triton` для ROCm 7.0.2+
                pattern="triton-[^\"']*+rocm${ROCM_VERSION}[^\"']*${cp_tag}[^\"']*linux_x86_64\\.whl"
            else
                pattern="${pkg}-[^\"']*+rocm${ROCM_VERSION}[^\"']*${cp_tag}[^\"']*linux_x86_64\\.whl"
            fi
        else
            pattern="${pkg}-[^\"']*+rocm${ROCM_VERSION}[^\"']*${cp_tag}[^\"']*linux_x86_64\\.whl"
        fi

        local raw_file
        raw_file=$(curl -s -L "${base_url}" | grep -oE "${pattern}" | grep -v "dev" | sort -V | tail -n 1 || true)

        if [ -z "$raw_file" ]; then
            return 1
        fi

        # Декодируем URL-кодированные символы (например %2B -> +)
        local file=$(echo "$raw_file" | sed 's/%2B/+/g')

        local filepath="${WHEEL_DIR}/${file}"
        if [ -f "$filepath" ]; then
            echo "$filepath"
            return 0
        fi

        # Скачиваем с декодированным URL
        curl -s -L "${base_url}${file}" -o "$filepath"
        echo "$filepath"
        return 0
    }

    declare -A FOUND_WHEELS

    for rel in "${CANDIDATES[@]}"; do
        local base_url="${ROOT_INDEX}${rel}/"

        for pkg in torch torchvision torchaudio pytorch_triton_rocm; do
            if [ -n "${FOUND_WHEELS[$pkg]:-}" ]; then
                continue
            fi

            local actual_pkg="$pkg"
            if version_ge "$ROCM_VERSION" "7.0.2" && [ "$pkg" = "pytorch_triton_rocm" ]; then
                actual_pkg="triton"
            fi

            if filepath=$(download_from_base "$actual_pkg" "$base_url"); then
                FOUND_WHEELS["$pkg"]="$filepath"
            fi
        done

        # Для ROCm ≥ 7.0.2 — убедимся, что `triton` найден (если нужен)
        if version_ge "$ROCM_VERSION" "7.0.2"; then
            if [ -z "${FOUND_WHEELS[triton]:-}" ]; then
                if filepath=$(download_from_base "triton" "$base_url"); then
                    FOUND_WHEELS["triton"]="$filepath"
                fi
            fi
        fi
    done

    # Определим список обязательных пакетов
    local REQUIRED_PKGS=(torch torchvision torchaudio)
    if version_ge "$ROCM_VERSION" "7.0.2"; then
        REQUIRED_PKGS+=(triton)
    else
        REQUIRED_PKGS+=(pytorch_triton_rocm)
    fi

    # Проверка на отсутствующие
    local MISSING=()
    for pkg in "${REQUIRED_PKGS[@]}"; do
        if [ -z "${FOUND_WHEELS[$pkg]:-}" ]; then
            MISSING+=("$pkg")
        fi
    done

    if [ ${#MISSING[@]} -gt 0 ]; then
        echo "⚠️ Not found wheel files for: ${MISSING[*]}"
    fi

    # Установка
    local INSTALLED_PKGS=()
    for pkg in "${REQUIRED_PKGS[@]}"; do
        if [[ " ${INSTALLED_PKGS[*]} " =~ " $pkg " ]]; then
            continue
        fi

        local whl="${FOUND_WHEELS[$pkg]:-}"
        if [ -n "$whl" ]; then
            echo "📥 Installing $pkg from $(basename "$whl")"
            if [ "$pkg" = "pytorch_triton_rocm" ] && [ -n "${FOUND_WHEELS[triton]:-}" ]; then
                echo "   Skipping pytorch_triton_rocm, since triton found"
                continue
            fi
            conda run -n "${PROJECT_NAME}" --no-capture-output python -m pip install --no-deps "$whl"
            INSTALLED_PKGS+=("$pkg")
        else
            echo "⚠️ Skipping $pkg (wheel not found)"
        fi
    done
}

install_comfyui() {
    if [ ! -d "${PROJECT_DIR}/ComfyUI" ]; then
        log "$(translate cloning_comfyui)"
        git clone https://github.com/comfyanonymous/ComfyUI.git "${PROJECT_DIR}/ComfyUI"
    else
        (cd "${PROJECT_DIR}/ComfyUI" && git pull --ff-only) || true
    fi

    cd "${PROJECT_DIR}/ComfyUI"

    # Удаляем зависимости из requirements.txt
    sed -i.bak -E '/^(torch|torchaudio|torchvision)([<>=~!0-9.]*)?$/s/^/# /' requirements.txt
    conda run -n "${PROJECT_NAME}" --no-capture-output python -m pip install -r requirements.txt || true

    # Установка ComfyUI-Manager
    local CUSTOM_NODES_DIR="${PROJECT_DIR}/ComfyUI/custom_nodes"
    mkdir -p "$CUSTOM_NODES_DIR"

    if [ ! -d "${CUSTOM_NODES_DIR}/ComfyUI-Manager" ]; then
        log "$(translate installing_manager)"
        git clone https://github.com/Comfy-Org/ComfyUI-Manager.git "${CUSTOM_NODES_DIR}/ComfyUI-Manager" || true
    else
        (cd "${CUSTOM_NODES_DIR}/ComfyUI-Manager" && git pull --ff-only) || true
    fi

    cd "${CUSTOM_NODES_DIR}/ComfyUI-Manager"
    conda run -n "${PROJECT_NAME}" --no-capture-output python -m pip install -r requirements.txt || true

    # Создание скрипта запуска
    log "$(translate creating_run_script)"

    cat > "${PROJECT_DIR}/ComfyUI/run.sh" << EOF
#!/bin/bash
source ~/miniconda3/etc/profile.d/conda.sh
conda activate ${PROJECT_NAME}
cd "${HOME}/${PROJECT_NAME}/ComfyUI"

#export PYTORCH_TUNABLEOP_ENABLED=1
#export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
#export MIOPEN_FIND_MODE=2
python main.py --use-pytorch-cross-attention --async-offload --bf16-unet --reserve-vram 2
EOF

    chmod +x "${PROJECT_DIR}/ComfyUI/run.sh"
}

install_repository() {
    log "$(translate cloning_repo)"
    git clone "$REPO_URL"
    cd "$REPO_NAME" || exit

    # Установка зависимостей
    if [ -f requirements.txt ]; then
        log "$(translate installing_dependencies)"
        conda run -n "${PROJECT_NAME}" --no-capture-output python -m pip install -r requirements.txt
    elif [ -f setup.py ]; then
        log "📥 Installing dependencies from setup.py"
        conda run -n "${PROJECT_NAME}" --no-capture-output python -m pip install .
    elif [ -f pyproject.toml ]; then
        log "📥 Installing dependencies from pyproject.toml"
        conda run -n "${PROJECT_NAME}" --no-capture-output python -m pip install .
    else
        warning "Dependencies file not found."
    fi

    success "Repository and dependencies installed."
}

disable_conda_autoactivate() {
    log "$(translate disabling_autoactivate)"
    conda config --set auto_activate false || true
}

# === Основная функция запуска ===
main() {
    # Перенаправление вывода в лог
    exec > >(tee -a "$LOGFILE") 2>&1

    select_language

    log "$(translate welcome)"

    check_architecture
    install_required_tools
    install_miniconda
    select_python_version
    select_install_method

    if [ "$INSTALL_METHOD" = "1" ]; then
        get_rocm_versions
    fi

    get_project_name
    select_setup_mode

    show_summary
    create_conda_env
    install_pytorch

    if [ "$SETUP_MODE" = "1" ]; then
        install_comfyui
    elif [ "$SETUP_MODE" = "2" ] && [ "$REPO_ACTION" = "1" ]; then
        install_repository
    fi

    disable_conda_autoactivate

    log "$(translate installation_complete)"

    if [ "$SETUP_MODE" = "1" ]; then
        echo "🔧 Run script created: ${PROJECT_DIR}/ComfyUI/run.sh"
        echo "🚀 To run ComfyUI, execute:"
        echo "    cd ${PROJECT_DIR}/ComfyUI && ./run.sh"
    elif [ "$SETUP_MODE" = "2" ] && [ "$REPO_ACTION" = "1" ]; then
        echo "✅ Repository installed: $REPO_NAME"
        echo "🚀 To run project, execute:" conda activate ${PROJECT_NAME}
    else
        echo "$(translate project_ready)"
    fi
}

# Запуск скрипта
main "$@"

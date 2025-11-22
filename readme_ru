CreatorEnv - это автоматизированный скрипт для создания изолированного окружения Conda с выбранной версией Python, ROCm на GPU AMD. Установки ComfyUI с поддержкой ROCm PyTorch.

## Требования

- x86_64 архитектура
- только для AMD GPU
- Linux  -  Ubuntu, Debian; RHEL; openSUSE
- должен быть установлен ROCm и AMDGPU
- Проверте ROCm на совместимость с вашим Linux:
  https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html#supported-distributions
- Доступ к интернет
- Права sudo для установки необходимых инструментов

  Протестировано на AMD Radeon 7900XTX, Ubuntu 24.04, установлен ROCm 7.1 и AMDGPU. Rocky linux 9, openSUSE 15.6 в VM

## Основные этапы:
1. Проверка архитектуры — только x86_64.
2. Установка необходимых утилит (curl, git и т.д.) через пакетный менеджер (apt, dnf, zypper).
3. Установка Miniconda
4. Создание Conda-окружения с версией Python 3.9 - 3.13, Pytorch ROCm 6.3 - 7.x:
   - установка с сайта (https://repo.radeon.com/rocm/manylinux/) — использование wheel-файлов.
   - автоматически проверяет совместимость пакетов (`torch`, `torchaudio`, etc.) по версиям ROCm
5. Имя проекта — создается директория с этим именем и окружением.
6. Режим установки:
   - Установить ComfyUI в окружение
   - Создать окружение с выбором Git-репозитория с зависимостями (`requirements.txt`, `setup.py` или `pyproject.toml`)
   - Создать пустое окружение
7. Отключение автоматической активации Conda.


 Установка:
1. Скачайте скрипт:

git clone https://github.com/eepoort-dev/CreatorEnv/CreatorEnv.sh

2. Сделайте скрипт исполняемым, запустите скрипт:

chmod +x CreatorEnv.sh
./CreatorEnv.sh


 Пример структуры для comfy_project:

  ~/comfy_project/
├── ComfyUI/               # Клон ComfyUI
│   ├── run.sh             # скрипт запуска
│   └── ...                # Исходники и зависимости ComfyUI
├── rocm_wheels/           # Папка с загруженными wheel-файлами ROCm
└── setup_CreatorEnv.log   # Лог выполнения установки


  для работы с ComfyUI запустите: run.sh
  редактируйте файл run.sh для ваших потребностей.

  для активации пустого окружения или с клонированым репозиторием: conda activate your_project
  для деактивации окружения conda: закройте консоль или conda deactivate


##⚠️ Важные замечания

  Все действия установки записываются в лог-файл `~/setup_CreatorEnv.log` для мониторинга процесса.

  Папка rocm_wheels — это локальная директория для хранения wheel-файлов ROCm. Скрипт использует её для:
  Скачивания и кэширования последних пакетов (torch, torchvision, torchaudio, triton)
  Установки без повторной загрузки, если файлы уже есть.

  Если вам нужны самые последние пакеты, для обновления просто удалите папку rocm_wheels

  Пример:

~/rocm_wheels/
├── torch-2.1.0+rocm7.1-cp311-cp311-linux_x86_64.whl
├── torchvision-0.16.0+rocm7.1-cp311-cp311-linux_x86_64.whl
├── torchaudio-2.1.0+rocm7.1-cp311-cp311-linux_x86_64.whl
└── triton-2.1.0+rocm7.1-cp311-cp311-linux_x86_64.whl


  Для удаления проекта: 1.удалите папку проекта:    ~/your_project
                        2.удалите папку окружения:  ~/miniconda3/envs/your_project

  Создано с использованием вайб кодинга

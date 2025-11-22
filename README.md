CreatorEnv - is an automated script for creating an isolated Conda environment with a selected Python version, ROCm on AMD GPUs. It installs ComfyUI with support for ROCm PyTorch.

## Requirements

- x86_64 architecture
- Only for AMD GPU
- Linux - Ubuntu, Debian; RHEL; openSUSE
- ROCm and AMDGPU must be installed
- Check ROCm compatibility with your Linux:
  https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html#supported-distributions
- Internet access
- Sudo permissions to install required tools

Tested on AMD Radeon 7900XTX, Ubuntu 24.04, ROCm 7.1 and AMDGPU installed. Rocky Linux 9, openSUSE 15.6 in VM

## Main Steps:
1. Architecture check - only x86_64.
2. Installation of required utilities (curl, git, etc.) via package manager (apt, dnf, zypper).
3. Installation of Miniconda
4. Creating Conda environment with Python version 3.9 - 3.13, PyTorch ROCm 6.3 - 7.x:
   - installation from the website (https://repo.radeon.com/rocm/manylinux/) — using wheel files.
   - automatically checks package compatibility (`torch`, `torchaudio`, etc.) by ROCm versions
5. Project name — creates a directory with this name and environment.
6. Installation mode:
   - Install ComfyUI in the environment
   - Create environment with Git repository dependencies (`requirements.txt`, `setup.py` or `pyproject.toml`)
   - Create empty environment
7. Disabling automatic Conda activation.

## Installation:
1. Download the script:

```bash
wget https://github.com/eepoort-dev/CreatorEnv/CreatorEnv.sh
```

2. Make the script executable, run the script:

```bash
chmod +x CreatorEnv.sh
./CreatorEnv.sh
```

## Example project structure for comfy_project:

```
~/comfy_project/
├── ComfyUI/               # ComfyUI clone
│   ├── run.sh             # Run script
│   └── ...                # ComfyUI sources and dependencies
├── rocm_wheels/           # Folder with downloaded ROCm wheel files
└── setup_CreatorEnv.log   # Installation log file
```

To work with ComfyUI, run: `run.sh`
Edit the `run.sh` file according to your needs.

To activate empty environment or cloned repository: `conda activate your_project`
To deactivate environment: close terminal or `conda deactivate`

## ⚠️ Important Notes

All installation actions are recorded in the log file `~/setup_CreatorEnv.log` for process monitoring.

The `rocm_wheels` folder is a local directory for storing ROCm wheel files. The script uses it to:
- Download and cache the latest packages (torch, torchvision, torchaudio, triton)
- Install without re-downloading if files already exist

If you need the most recent packages, simply delete the `rocm_wheels` folder to update.

Example:

```
~/rocm_wheels/
├── torch-2.1.0+rocm7.1-cp311-cp311-linux_x86_64.whl
├── torchvision-0.16.0+rocm7.1-cp311-cp311-linux_x86_64.whl
├── torchaudio-2.1.0+rocm7.1-cp311-cp311-linux_x86_64.whl
└── triton-2.1.0+rocm7.1-cp311-cp311-linux_x86_64.whl
```

## To remove the project:
1. Delete the project folder: `~/your_project`
2. Delete the environment folder: `~/miniconda3/envs/your_project`

Created with vibes and coding

Easy iPXE Building from source code
===================================
*   [Easy iPXE Building from source code](#easy-ipxe-building-from-source-code)
    *   [You need Docker installed for this project!](#you-need-docker-installed-for-this-project)
*   [If you need working iPXE with Wi-Fi over WPA2-PSK go to this branch](#if-you-need-working-ipxe-with-wi-fi-over-wpa2-psk-go-to-this-branch)
*   [Step 1: Download the project.](#step-1-download-the-project)
*   [Step 2: Edit files](#step-2-edit-files)
    *   [You can change the commands to edit config files, add/or remove packages, files, etc.](#you-can-change-the-commands-to-edit-config-files-addor-remove-packages-files-etc)
*   [Using Local iPXE Source (Optional)](#using-local-ipxe-source-optional)
    *   [Intel I225-V Support](#intel-i225-v-support)
*   [Step 3: Build the project](#step-3-build-the-project)
*   [Build Outputs (`builds/` folder)](#build-outputs-builds-folder)
*   [License](#license)

### You need Docker installed for this project!

This project simplifies building iPXE from source using Docker. It includes a script (`renew.sh`) to automate the build process for both Legacy BIOS and EFI systems.

**Note:** The `renew.sh` script now supports a `--clean` argument. Run `./renew.sh --clean` to perform a clean build, removing previous compilation artifacts. Otherwise, it will attempt an incremental build.

# If you need working iPXE with Wi-Fi over WPA2-PSK go to [this branch](https://github.com/sebaxakerhtc/ipxe-simple/tree/Wi-Fi)!

## Step 1: Download the project.

You can use git command or simply download it from github

## Step 2: Edit files

### You can change the commands to edit config files, add/or remove packages, files, etc.
- a. You can comment out "make efi" commands to save your time if you don't need them.
- b. You can comment out settings "sed -i..." if you don't need them.
- c. You can edit/add/or remove batch files.
- d. Replace the content of EFI.ipxe and Legacy.ipxe script with yours.
- e. etc.

## Using Local iPXE Source (Optional)
If you want to use a local copy of iPXE source instead of downloading it during build:

1. Place your iPXE source in the `ipxe/` directory
2. The `renew.sh` script has been modified to use this local directory instead of downloading from the internet
3. This is especially useful if you've made custom modifications to the iPXE source code, such as adding driver support for specific network cards like Intel I225-V

### Intel I225-V Support
Support for the Intel I225-V Ethernet Controller has been added to the local iPXE source. The PCI ID `0x8086:0x15f3` has been added to the `intel_nics` array in `/home/oriol/ipxe-simple/ipxe/src/drivers/net/intel.c`.

## Step 3: Build the project

Navigate to the project directory (where the Dockerfile and other project files are located).

First, build the Docker image which contains the necessary build environment:

```bash
docker build -t sebaxakerhtc/ipxe-simple .
```

This command builds the Docker image named `sebaxakerhtc/ipxe-simple` using the `Dockerfile` in the current directory. It installs dependencies but does *not* compile the iPXE images yet.

Next, run the build script inside a container using the image you just built. This command mounts your local directories into the container so the script can access the source/config and output the results directly to your host machine:

```bash
docker run --rm --name ipxe-builder \
  -v ./builds:/builds \
  -v ./config-backup:/config-backup \
  -v ./ipxe:/ipxe \
  sebaxakerhtc/ipxe-simple \
  ./renew.sh
```

This command does the following:
- `--rm`: Automatically removes the container when the script finishes.
- `--name ipxe-builder`: Assigns a temporary name to the container.
- `-v ./builds:/builds`: Mounts your local `./builds` directory to `/builds` inside the container. The compiled iPXE images will appear here.
- `-v ./config-backup:/config-backup`: Mounts your local config backup.
- `-v ./ipxe:/ipxe`: Mounts your local iPXE source directory (if you are using one).
- `sebaxakerhtc/ipxe-simple`: Specifies the Docker image to use.
- `./renew.sh`: The command to run inside the container (the build script).

The script will execute, compiling the iPXE images. Because the `./builds` directory is mounted as a volume, the resulting build artifacts will appear directly in the `builds` folder on your host machine.

## Build Outputs (`builds/` folder)

The `renew.sh` script generates various iPXE boot files in the `builds/` directory, catering to different boot environments:

*   **EFI Boot Files (`.efi`):**
    *   `bootx64.efi`: Standard EFI application for 64-bit systems.
    *   `bootia32.efi`: Standard EFI application for 32-bit systems (IA32).
    *   `snponly-x64.efi`: EFI application for 64-bit systems, using only the Simple Network Protocol (SNP) driver. Useful on systems where standard drivers fail but SNP works.
    *   `snponly-x86.efi`: EFI application for 32-bit systems, using only the SNP driver.

*   **ISO Images (`.iso`):**
    *   `ipxe-efi-x64.iso`: Bootable ISO image for 64-bit EFI systems.
    *   `ipxe-efi-x86.iso`: Bootable ISO image for 32-bit EFI systems.
    *   `ipxe.iso`: Bootable ISO image, typically for Legacy BIOS systems.

*   **USB Images (`.usb`):**
    *   `ipxe-efi-x64.usb`: Bootable USB image for 64-bit EFI systems.
    *   `ipxe-efi-x86.usb`: Bootable USB image for 32-bit EFI systems.
    *   `ipxe.usb`: Bootable USB image, typically for Legacy BIOS systems.

*   **Legacy PXE Files:**
    *   `ipxe.pxe`: Basic PXE boot file for Legacy BIOS.
    *   `ipxe.kpxe`: PXE boot file with embedded script capabilities for Legacy BIOS.
    *   `ipxe.kkpxe`, `ipxe.kkkpxe`: Variants of `.kpxe`, potentially with different driver sets or features (less common).
    *   `undionly.kpxe`: A common PXE boot file using the universal UNDI network driver for Legacy BIOS.

*   **Other Formats:**
    *   `ipxe.dsk`: Floppy disk image for Legacy BIOS systems.
    *   `ipxe.lkrn`: Linux kernel format image, bootable by some Linux bootloaders (e.g., SYSLINUX) on Legacy BIOS systems.

## License
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

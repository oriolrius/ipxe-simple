#!/bin/bash
# Define base directories
IPXE_SRC_DIR="/ipxe/src"
CONFIG_DIR="/config-backup"
OUTPUT_DIR="/builds"

# Check for --clean argument
CLEAN_BUILD=false
if [[ "$1" == "--clean" ]]; then
  CLEAN_BUILD=true
  echo "Clean build requested."
fi

# Ensure output directory exists
mkdir -p ${OUTPUT_DIR}

# Restore original config files
echo "Restoring original config files"
cp ${CONFIG_DIR}/general.h ${IPXE_SRC_DIR}/config/
cp ${CONFIG_DIR}/console.h ${IPXE_SRC_DIR}/config/
cp ${CONFIG_DIR}/branding.h ${IPXE_SRC_DIR}/config/

# Restore original ipxe scripts
echo "Restoring original ipxe scripts"
cp ${CONFIG_DIR}/Legacy.ipxe ${IPXE_SRC_DIR}/
cp ${CONFIG_DIR}/EFI.ipxe ${IPXE_SRC_DIR}/

# Clean previous builds if requested
if [ "$CLEAN_BUILD" = true ]; then
  echo "Cleaning previous builds"
  make clean -C ${IPXE_SRC_DIR}
fi

# --- Build Legacy Images ---
echo "SETTINGS Legacy"
echo "Editing general.h"
sed -i 's/\/\/#define\ IMAGE_PXE/#define\ IMAGE_PXE/' ${IPXE_SRC_DIR}/config/general.h
sed -i 's/\/\/#define\ IMAGE_BZIMAGE/#define\ IMAGE_BZIMAGE/' ${IPXE_SRC_DIR}/config/general.h
sed -i 's/#define\ IMAGE_EFI/\/\/#define\ IMAGE_EFI/' ${IPXE_SRC_DIR}/config/general.h
echo "Editing console.h"
sed -i 's/\/\/#define\ CONSOLE_PCBIOS/#define\ CONSOLE_PCBIOS/' ${IPXE_SRC_DIR}/config/console.h
sed -i 's/#define\tCONSOLE_EFI/\/\/#undef\tCONSOLE_EFI/' ${IPXE_SRC_DIR}/config/console.h
echo "Creating Legacy Images"
make bin/ipxe.dsk EMBED=Legacy.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin/ipxe.dsk ${OUTPUT_DIR}/
make bin/ipxe.iso EMBED=Legacy.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin/ipxe.iso ${OUTPUT_DIR}/
make bin/ipxe.usb EMBED=Legacy.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin/ipxe.usb ${OUTPUT_DIR}/
make bin/ipxe.lkrn EMBED=Legacy.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin/ipxe.lkrn ${OUTPUT_DIR}/
make bin/ipxe.pxe EMBED=Legacy.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin/ipxe.pxe ${OUTPUT_DIR}/
make bin/ipxe.kpxe EMBED=Legacy.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin/ipxe.kpxe ${OUTPUT_DIR}/
make bin/ipxe.kkpxe EMBED=Legacy.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin/ipxe.kkpxe ${OUTPUT_DIR}/
make bin/ipxe.kkkpxe EMBED=Legacy.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin/ipxe.kkkpxe ${OUTPUT_DIR}/
make bin/undionly.kpxe EMBED=Legacy.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin/undionly.kpxe ${OUTPUT_DIR}/

# --- Build EFI Images ---
echo "SETTINGS EFI"
echo "Editing general.h"
sed -i 's/#define\ IMAGE_PXE/\/\/#define\ IMAGE_PXE/' ${IPXE_SRC_DIR}/config/general.h
sed -i 's/#define\ IMAGE_BZIMAGE/\/\/#define\ IMAGE_BZIMAGE/' ${IPXE_SRC_DIR}/config/general.h
sed -i 's/\/\/#define\tIMAGE_EFI/#define\ IMAGE_EFI/' ${IPXE_SRC_DIR}/config/general.h
echo "Editing console.h"
sed -i 's/#define\ CONSOLE_PCBIOS/\/\/#define\ CONSOLE_PCBIOS/' ${IPXE_SRC_DIR}/config/console.h
sed -i 's/\/\/#undef\tCONSOLE_EFI/#define\tCONSOLE_EFI/' ${IPXE_SRC_DIR}/config/console.h
echo "Creating EFI Images"
make bin-x86_64-efi/ipxe.efi EMBED=EFI.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin-x86_64-efi/ipxe.efi ${OUTPUT_DIR}/bootx64.efi
make bin-i386-efi/ipxe.efi EMBED=EFI.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin-i386-efi/ipxe.efi ${OUTPUT_DIR}/bootia32.efi
make bin-x86_64-efi/snponly.efi EMBED=EFI.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin-x86_64-efi/snponly.efi ${OUTPUT_DIR}/snponly-x64.efi
make bin-i386-efi/snponly.efi EMBED=EFI.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin-i386-efi/snponly.efi ${OUTPUT_DIR}/snponly-x86.efi
make bin-x86_64-efi/ipxe.iso EMBED=EFI.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin-x86_64-efi/ipxe.iso ${OUTPUT_DIR}/ipxe-efi-x64.iso
make bin-i386-efi/ipxe.iso EMBED=EFI.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin-i386-efi/ipxe.iso ${OUTPUT_DIR}/ipxe-efi-x86.iso
make bin-x86_64-efi/ipxe.usb EMBED=EFI.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin-x86_64-efi/ipxe.usb ${OUTPUT_DIR}/ipxe-efi-x64.usb
make bin-i386-efi/ipxe.usb EMBED=EFI.ipxe -C ${IPXE_SRC_DIR} && mv ${IPXE_SRC_DIR}/bin-i386-efi/ipxe.usb ${OUTPUT_DIR}/ipxe-efi-x86.usb

echo "Build process finished. Files are in ${OUTPUT_DIR}"

# Restore original config files again to leave the source clean
echo "Restoring original config files post-build"
cp ${CONFIG_DIR}/general.h ${IPXE_SRC_DIR}/config/
cp ${CONFIG_DIR}/console.h ${IPXE_SRC_DIR}/config/
cp ${CONFIG_DIR}/branding.h ${IPXE_SRC_DIR}/config/

#!/bin/bash

# Скрипт для массового переименования всех ryazhahand/ryazhahand/RYZHAND в ryazhahand/ryazhahand/ryazhahand
# Использование: ./rename_all.sh

echo "Starting mass rename of RYZHAND to RYZHAND..."

# Найти все файлы (кроме бинарных и build директории)
find . -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" -o -name "*.c" -o -name "*.mk" -o -name "*.json" -o -name "*.md" -o -name "*.ini" -o -name "*.py" -o -name "*.sh" \) \
    ! -path "./build/*" \
    ! -path "./.git/*" \
    ! -path "./out/*" \
    ! -name "*.ovl" \
    ! -name "*.elf" \
    ! -name "*.nacp" \
    | while read file; do
    if [ -f "$file" ]; then
        # RYZHAND -> RYZHAND
        sed -i 's/ryazhahand/ryazhahand/g' "$file"
        
        # RYZHAND -> Ryzhand
        sed -i 's/ryazhahand/ryazhahand/g' "$file"
        
        # RYZHAND -> ryazhahand
        sed -i 's/ryazhahand/ryazhahand/g' "$file"
        
        # Ryz -> Ryz (только если не часть другого слова)
        sed -i 's/\bRyz\b/Ryz/g' "$file"
        
        # Ryz -> ryz (только если не часть другого слова)
        sed -i 's/\bryz\b/ryz/g' "$file"
        
        # Ryz -> RYZ (только если не часть другого слова)
        sed -i 's/\bRYZ\b/RYZ/g' "$file"
        
        echo "Processed: $file"
    fi
done

echo "Mass rename completed!"


#!/bin/bash

set -eu

cd $WORKON_HOME

# Delete Dead symlinks
gfind . -type l -xtype l -delete

for file in * ; do 
    if [[ -d "$file" && ! -L "$file" ]]; then
        echo "Recreating virtualenv for $file"
        virtualenv $file
    fi; 
done

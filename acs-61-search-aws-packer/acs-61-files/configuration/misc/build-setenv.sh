#!/bin/sh
LDFLAGS="-L@@ansible_alfresco_root_dir@@/common/lib $LDFLAGS"
export LDFLAGS
CFLAGS="-I@@ansible_alfresco_root_dir@@/common/include $CFLAGS"
export CFLAGS
CXXFLAGS="-I@@ansible_alfresco_root_dir@@/common/include $CXXFLAGS"
export CXXFLAGS
            
PKG_CONFIG_PATH="@@ansible_alfresco_root_dir@@/common/lib/pkgconfig"
export PKG_CONFIG_PATH


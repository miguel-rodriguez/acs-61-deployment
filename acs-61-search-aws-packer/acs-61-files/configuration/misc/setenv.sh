#!/bin/sh
echo $LD_LIBRARY_PATH | egrep "@@ansible_alfresco_root_dir@@/common" > /dev/null
if [ $? -ne 0 ] ; then
PATH="@@ansible_alfresco_root_dir@@/common/alfresco-pdf-renderer:@@ansible_alfresco_root_dir@@/java/bin:@@ansible_alfresco_root_dir@@/common/bin:$PATH"
export PATH
LD_LIBRARY_PATH="@@ansible_alfresco_root_dir@@/common/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
fi

TERMINFO=@@ansible_alfresco_root_dir@@/common/share/terminfo
export TERMINFO
##### ALFRESCO_PDF_RENDERER ENV #####
ALFRESCO_PDF_RENDERER_VAR="@@ansible_alfresco_root_dir@@/common/alfresco-pdf-renderer"
export ALFRESCO_PDF_RENDERER_VAR

##### IMAGEMAGICK ENV #####
MAGICK_HOME="@@ansible_alfresco_root_dir@@/common"
export MAGICK_HOME
MAGICK_CONFIGURE_PATH="@@ansible_alfresco_root_dir@@/common/lib/ImageMagick-7.0.5/config-Q16HDRI"
export MAGICK_CONFIGURE_PATH
MAGICK_CODER_MODULE_PATH="@@ansible_alfresco_root_dir@@/common/lib/ImageMagick-7.0.5/modules-Q16HDRI/coders"
export MAGICK_CODER_MODULE_PATH

##### JAVA ENV #####
JAVA_HOME=@@ansible_alfresco_root_dir@@/java
export JAVA_HOME

##### SSL ENV #####
SSL_CERT_FILE=@@ansible_alfresco_root_dir@@/common/openssl/certs/curl-ca-bundle.crt
export SSL_CERT_FILE
OPENSSL_CONF=@@ansible_alfresco_root_dir@@/common/openssl/openssl.cnf
export OPENSSL_CONF
OPENSSL_ENGINES=@@ansible_alfresco_root_dir@@/common/lib/engines
export OPENSSL_ENGINES


. @@ansible_alfresco_root_dir@@/scripts/build-setenv.sh

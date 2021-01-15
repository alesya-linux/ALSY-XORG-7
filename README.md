# ALSY-XORG-7

Здесь находятся скрипты сборки Xorg-Server-1.20.10  
  
вместе со всем необходимым,  
  
шрифтами (Xorg-Font),  

встроенными приложениями (Xorg-App),  

библиотеками (Xorg-Lib),  

драйверами ввода (Xorg Input Drivers),  

драйверами видео карт (Xorg Video Drivers)  

и зависимостями такими как например:  

mesa-20.3.2,  

freetype-2.10.4,  

fontconfig-2.13.1,  

harfbuzz-2.7.4,  

libdrm-2.4.104,  

libunwind-1.5.0,  

libpng-1.6.37,  

zlib-1.2.11 и другими, чтобы узнать подробнее  

смотри списки установки в папке .APP_LISTING:  

1. XORG-7.md5  
2. app-7.md5  
3. font-7.md5  

# Для установки в систему Linux, необходимо выполнить команды:

1. ./config.sh
2. make
3. su -c "make install"

# Префикс установки указывается в файле config.sh

1. export XORG_PREFIX="/usr/src/tools/XORG-7"

# Требования к ПО

1. ОС Linux GNU
2. glibc >= 2.19
3. gcc >= 4.7
4. binutils >= 2.19
4. python2 > 2.7
5. python3 > 3
6. Ninja v1.5 or newer

﻿# ALSY-XORG-7

* Здесь находятся скрипты которые помогают выполнить
  полностью автоматическую сборку для X Window system,
  в систему будет установлен Xorg-Server-1.20.10 
  вместе со всем необходимым, 
  шрифтами (Xorg-Font),
  встроенными приложениями (Xorg-App),
  библиотеками (Xorg-Lib), 
  драйверами ввода (Xorg Input Drivers),
  драйверами видео карт (Xorg Video Drivers) 
  и зависимостями 
  * такими как например:
    mesa-20.3.2, 
    freetype-2.10.4,  
    fontconfig-2.13.1, 
    harfbuzz-2.7.4, 
    libdrm-2.4.104, 
    libunwind-1.5.0, 
    libpng-1.6.37,  
    zlib-1.2.11 
    и другими, чтобы узнать подробнее 
    смотри списки установки в папке .APP_LISTING:  
      1. XORG-7.md5 
      2. app-7.md5 
      3. font-7.md5  

* Для установки в систему Linux, необходимо выполнить команду:
  1. ./config.sh                              
  2. make         
  3. sudo make install
  или
  1. ./config.sh --prefix=/usr/{you_new_dir}
  2. make
  3. su -c "make install"

* Префикс установки по умолчанию, указывается в файле config.sh
  
  1. export XORG_PREFIX="/usr/src/tools/XORG-7"
  
  Внимание:
  Не нужно указывать в качестве префикса существующие и\или системные директории 
  такие как /bin; /usr; /lib64 и т.д. лучше всего создать новую папку и 
  установить в качестве префикса. 
  
  Так же можно предварительно смонтировать диск на эту новую папку, 
  тогда установка будет выполнена на конкретный диск 
  который потом уже можно будет смонтировать на любую папку. 

* Все установочные пакеты можно предварительно скачать по ссылке:
  
  https://files.webmoney.ru/files/Gc8IkfkB
  
  Распакуйте в папку APP_PACKAGE и они будут браться от туда, 
  если в данной папке, не будет нужного пакета, он будет скачен командой wget

* Требования к ПО (для выполнения установки)
  1. ОС Linux GNU
  2. glibc >= 2.19
  3. gcc >= 4.7
  4. binutils >= 2.19
  4. python2 > 2.7
  5. python3 > 3.0
  6. Ninja v1.5 or newer
  7. GNU Wget >= 1.14
  8. GNU Make >= 4.3
  9. GNU libtool >= 2.4.6
  10. GNU Autoconf >= 2.7
  11. pkg-config >= 0.29
  12. GNU Awk >= 3.1.8
  13. GNU sed version 4.2.1 or newer
 
* Зависимости установленного XORG-7
  1. glibc - той версии которая использовалась при выполнении скриптов установки

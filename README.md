﻿# ALSY-XORG-7

* Здесь находятся скрипты которые помогают выполнить  
  полностью автоматическую сборку для X Window System.
  
* В систему будет установлен Xorg-Server-1.20.10   
  вместе со всем необходимым:
    +  шрифтами (Xorg-Font)
    +  встроенными приложениями (Xorg-App)
    +  библиотеками (Xorg-Lib)
    +  драйверами ввода (Xorg Input Drivers)
    +  драйверами видео карт (Xorg Video Drivers)
    +  зависимостями такими как например:  
        mesa-21.2.5, freetype-2.10.4, fontconfig-2.13.1,  
        harfbuzz-3.1.1, libdrm-2.4.108, libunwind-1.5.0,  
        libpng-1.6.37, zlib-1.2.11 и другими  
    +  чтобы узнать подробнее,  
       смотри списки установки в папке .APP_LISTING:  
       (XORG-7.md5, app-7.md5, font-7.md5 и т.д.)  
       
* Для установки в систему Linux, необходимо выполнить команду:

  +  ./config.sh                              
  +  make         
  +  sudo make install

* Альтернативный вариант установки:

  +  ./config.sh --prefix=/usr/{you_new_dir}
  +  make
  +  su -c "make install"

* Префикс установки по умолчанию, указывается в файле config.sh
  
  +  export XORG_PREFIX="/usr/src/tools/XORG-7"
  
  +  Внимание: Не нужно указывать в качестве префикса  
               существующие и\или системные директории  
               такие как /bin; /usr; /lib64 и т.д. 
  +  Лучше всего создать новую папку и установить в качестве префикса.  
  
  +  Так же можно предварительно смонтировать диск на эту новую папку,  
     тогда установка будет выполнена на конкретный диск  
     который потом уже можно будет смонтировать на любую папку.  
    
* Все установочные пакеты можно предварительно скачать по ссылке:
    
  +  FILELINK:    https://files.webmoney.ru/files/XVXEh5ga
  +  FILENAME:    APP_PACKAGE.zip  
  +  FILESIZE:    167.8 MB
  +  FILEMD5SUM:  3f7ae2688da54c5c2f3c7de68d2b111c  
  
  + Распакуйте в папку APP_PACKAGE,  
  если в данной папке, не будет нужного пакета,  
  он будет скачен командой wget  
  
* Требования к ПО (для выполнения установки)
  +  ОС Linux GNU
  +  GNU libc (glibc) >= 2.19
  +  GNU Compiler Collection (gcc) >= 4.7
  +  GNU binutils >= 2.19
  +  Python2 > 2.7
  +  Python3 > 3.0
  +  Ninja v1.5 or newer
  +  GNU Wget >= 1.14
  +  GNU Make >= 4.3
  +  GNU libtool >= 2.4.6
  +  GNU Autoconf >= 2.7
  +  pkg-config >= 0.29
  +  GNU Awk >= 3.1.8
  +  GNU sed version 4.2.1 or newer
  +  GNU coreutils >= 8.21
  +  CMAKE >= 3.21 (https://cmake.org/download/) - for source code https://github.com/Kitware/CMake/tags
  +  sudo > 1.8 (https://www.sudo.ws/getting/download/)
 
* Зависимости установленного XORG-7
  +  glibc - той версии которая использовалась при выполнении скриптов установки
  (при переходе на обновленную версию glibc, например была 2.24 стала 2.35 проблем не обнаружено, 
   но проблемы могут возникнуть с высокой вероятностью при переходе на более низкую версию.)

* Установка модулей для Python
  + Для примера:
  + sudo python3 -m pip install -U pip
  + sudo python3 -m pip install -U ninja
  + sudo python3 -m pip install -U meson
  + sudo python3 -m pip install -U pyaml

* Установка модулей Perl
  + Для примера:
  + sudo perl -MCPAN -e 'install XML::Parser'
  + sudo perl -MCPAN -e 'install YAML::XS'

* Если у вас чистый Python3 без модуля pip и setuptools (https://pypi.org/)
  + Сначала скачиваем исходники setuptools потом pip
  + 1 Распаковываем setuptools
  + 2 Находясь внутри вып команду: 
  + python3 setup.py build
  + sudo python3 setup.py install
  + Затем п.1. п.2. выполняем так же для pip

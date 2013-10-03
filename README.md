Nookige
====

Nookige is a bash script that converts all images in a directory
and subdirectories into a single PDF file. Though designed as a
solution for the Nook Simple Touch e-Book reader, it is a general
purpose image-to-pdf convert tool.


Nookige provides the following functionality:

 - Grayscale conversion.
 - Trimming.
 - Resize to fit an e-Book's 6" screen.
 - Automatic rotation of images.

License and disclaimer
----------------------
Copyright (C) 2012, 2013 Luis Ortega Pérez de Villar <luiorpe1@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Nookige is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE. See the GNU General Public License for more details.

Requirements
------------

This tool requires the Bash shell, as it uses Bash specific features.


Usage examples
--------------

> nookige.sh dir1
Create a pdf file with all images found in dir1, recursively.

> nookige.sh -g -t -r dir1
Create a pdf file with all images found in dir1, recursively.
Convert images to grayscale, trim borders and resize to fit in
an e-Book screen.
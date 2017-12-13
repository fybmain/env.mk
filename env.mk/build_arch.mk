# THIS FILE IS PART OF env.mk PROJECT
# Copyright (C) 2017 Ben Feng <fybmain@gmail.com>

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.

# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
# USA


ENV_MK_UNAME_RAW=$(shell uname -o|sed -E 's/^(.*)$$/\L\1\E/')

ENV_MK_PARSE_UNAME=$(strip \
            $(if $(findstring msys,$1),mingw, \
            $(if $(findstring mingw,$1),mingw, \
            $(if $(findstring cygwin,$1),cygwin, \
	    linux))))

ENV_MK_BUILD_ARCH_AUTO=$(call ENV_MK_PARSE_UNAME,$(ENV_MK_UNAME_RAW))

ifndef BUILD_ARCH
BUILD_ARCH=$(ENV_MK_BUILD_ARCH_AUTO)
else ifneq ($(BUILD_ARCH),$(ENV_MK_BUILD_ARCH_AUTO))
$(warning BUILD_ARCH has been set to '$(BUILD_ARCH)', but the result of auto detection is '$(ENV_MK_BUILD_ARCH_AUTO)')
endif


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


function ENV_MK_SHELL_VAR_UNSET(){
	export -n ${1}
	unset ${1}
}

function ENV_MK_SHELL_VAR_RECOVER(){
	if [ ! -v ${2} ];then return;fi
	export ${1}="${!2}"
	ENV_MK_SHELL_VAR_UNSET ${2}
}

function ENV_MK_DEACTIVATE_DO(){
	ENV_MK_SHELL_VAR_RECOVER PS1 ENV_MK_SHELL_OLDPS1
	ENV_MK_SHELL_VAR_RECOVER PATH ENV_MK_SHELL_OLDPATH
	hash -r

	ENV_MK_SHELL_VAR_UNSET ENV_MK_ENV_MK_ABSPATH_SHELL
	ENV_MK_SHELL_VAR_UNSET ENV_MK_PRJ_ABSPATH_SHELL
	ENV_MK_SHELL_VAR_UNSET ENV_MK

	echo -E "env.mk is deactivated."
}

function ENV_MK_DEACTIVATE(){
	if [ ! -v ENV_MK ];then
		echo -e "\033[1;31mError: ENV_MK is not set.\033[0m"
		echo -E "Did you activate env.mk in this shell?"
		echo -E "Leaving everything unchanged."
		return
	fi

	local REQUIRE_VARS="ENV_MK_SHELL_OLDPATH"
	for var in ${REQUIRE_VARS}
	do
		if [ ! -v "${var}" ];then
			echo -e "\033[1;31mError: ${var} is not set.\033[0m"
			echo -E "This is not scientific. There might be some programs conflicting with env.mk ."
			echo -E "Leaving everything unchanged."
			return
		fi
	done

	ENV_MK_DEACTIVATE_DO
}

ENV_MK_DEACTIVATE


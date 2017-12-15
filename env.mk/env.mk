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


ifndef ENV_MK_INCLUDED
ENV_MK_INCLUDED:=true

ifndef ENV_MK_ACTIVATED
$(info Required env.mk is not activated)
$(info Please run make in an environment with env.mk activated)
$(error )
endif

shell_escape='$(subst ','\'',$1)'
make_word_escape=$(shell echo -E $(call shell_escape,$1)|sed 's/!/!e/g;s/ /!s/g;s/\t/!t/g;s/\n/!n/g;s/\r/!r/g;s/,/!c/g')
make_word_deescape=$(shell echo -E $(call shell_escape,$1)|sed 's/!c/,/g;s/!r/\r/g;s/!n/\n/g;s/!t/\t/g;s/!s/ /g;s/!e/!/g')
make_word_deescape_include=$(shell echo -E $(call shell_escape,$1)|sed 's/!c/,/g;s/!r/\r/g;s/!n/\n/g;s/!t/\t/g;s/!s/\\ /g;s/!e/!/g')

path_drop_tail_slash=$(if $(filter %/,$1),$(call path_drop_tail_slash,$(patsubst %/,%,$1)),$1)
word_common_prefix=$(shell echo -E $(call shell_escape,$1) $(call shell_escape,$2)|sed -E 's/^(.*).* \1.*$$/\1/')
ENV_MK_REL_PATH_IN=$(shell echo -E $(call shell_escape,$1)|sed -E 's:/+:/:g;s:^(.*)/(.*) \1/+(.*)$$:\2\n\3:;h;s/^(.*)\n.*$$/ \1 /;s:/:  :g;s: [^ ]+ :../:g;s/ //g;G;s:^(.*)\n.*\n(.*)$$:\1\2:;s:/*$$::')
rel_path=$(call ENV_MK_REL_PATH_IN,$(abspath $1)/ $(abspath $2)/)

ENV_MK_INCLUDE_MAKEFILE_IN=$(eval $1 $(call make_word_deescape_include,$2))
include_makefile=$(call ENV_MK_INCLUDE_MAKEFILE_IN,include,$1)
-include_makefile=$(call ENV_MK_INCLUDE_MAKEFILE_IN,-include,$1)
sinclude_makefile=$(call ENV_MK_INCLUDE_MAKEFILE_IN,sinclude,$1)

define ENV_MK_REQUIRE_VAR_TMPL=
ifndef $1
$$(info The variable $1 is unset)
$$(info Maybe there is some programs conflicting with env.mk)
$$(error )
endif
endef
ENV_MK_REQUIRE_VAR=$(eval $(call ENV_MK_REQUIRE_VAR_TMPL,$1))

ENV_MK_ABSPWD:=$(call make_word_escape,$(shell pwd -L))
$(call ENV_MK_REQUIRE_VAR,ENV_MK_PRJ_ABSPATH_SHELL)
ENV_MK_PRJ_ABSPATH:=$(call make_word_escape,$(ENV_MK_PRJ_ABSPATH_SHELL))
$(call ENV_MK_REQUIRE_VAR,ENV_MK_ENV_MK_ABSPATH_SHELL)
ENV_MK_ENV_MK_ABSPATH:=$(call make_word_escape,$(ENV_MK_ENV_MK_ABSPATH_SHELL))

ifeq (,$(filter $(ENV_MK_PRJ_ABSPATH)/%,$(ENV_MK_ABSPWD)/))
$(info When using env.mk, the working directory must be under the project directory)
$(error )
endif

define ENV_MK_REL_PATH_WITH_CHECK_TMPL=
$1:=$$(call rel_path,$2,$3)
ifneq ($$(abspath $3),$$(abspath $2/$$($1)))
$$(info Error while calculating $1 (the relative path of $$(call make_word_deescape,$3)))
$$(info Relative to: $$(call make_word_deescape,$2))
$$(info Wrong answer: $$(call make_word_deescape,$$($1)))
#$$(error )
endif
endef
ENV_MK_REL_PATH_WITH_CHECK=$(eval $(call ENV_MK_REL_PATH_WITH_CHECK_TMPL,$1,$2,$3))

$(call ENV_MK_REL_PATH_WITH_CHECK,ENV_MK_PWD,$$(ENV_MK_PRJ_ABSPATH),$$(ENV_MK_ABSPWD))
$(call ENV_MK_REL_PATH_WITH_CHECK,ENV_MK_PRJ_PATH,$$(ENV_MK_ABSPWD),$$(ENV_MK_PRJ_ABSPATH))
$(call ENV_MK_REL_PATH_WITH_CHECK,ENV_MK_ENV_MK_PATH,$$(ENV_MK_ABSPWD),$$(ENV_MK_ENV_MK_ABSPATH))

ENV_MK_EXEC_HOOK=$(eval $(value $1))
ENV_MK_EXEC_HOOK_LIST=$(foreach hook,$1,$(call ENV_MK_EXEC_HOOK,$(hook)))

ENV_MK_COMPONENT:=config util
ENV_MK_COMPONENT+=makeflags build_arch

undefine ENV_MK_COMP_INIT_AFTER_HOOK
$(foreach f,$(ENV_MK_COMPONENT),$(call include_makefile,$(ENV_MK_ENV_MK_PATH)/$(f).mk))
$(call ENV_MK_EXEC_HOOK_LIST,$(ENV_MK_COMP_INIT_AFTER_HOOK))

ENV_MK_ADDON_INC=$(shell find $(call shell_escape,$(call make_word_deescape,$(ENV_MK_ENV_MK_PATH))/addon) -wholename $(call shell_escape,$(ENV_MK_ADDON_INC_PATH)) -printf '%P ')
undefine ENV_MK_ADDON_INIT_AFTER_HOOK
$(foreach f,$(ENV_MK_ADDON_INC),$(call include_makefile,$(ENV_MK_ENV_MK_PATH)$(call make_word_escape,/addon/$(f))))
$(call ENV_MK_EXEC_HOOK_LIST,$(ENV_MK_ADDON_INIT_AFTER_HOOK))

ENV_MK_WD_INC=$(call -include_makefile,$1$(ENV_MK_WD_INC_NAME))$(if $1,$(call ENV_MK_WD_INC,$(patsubst %../,%,$1)),)
$(call ENV_MK_WD_INC,$(if $(ENV_MK_PRJ_PATH),$(ENV_MK_PRJ_PATH)/,))

endif

unexport ENV_MK_INCLUDED


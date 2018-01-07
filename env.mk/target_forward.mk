ENV_MK_MASTER_MAKEFILE_IN=$(if $(filter $(ENV_MK_PRJ_ABSPATH)/%,$1/),$(if $(wildcard $(call make_word_deescape_include,$1/$(ENV_MK_MASTER_MAKEFILE_NAME))),$1/$(ENV_MK_MASTER_MAKEFILE_NAME),$(call ENV_MK_MASTER_MAKEFILE_IN,$(call path_drop_tail_slash,$(dir $1)))),)
ENV_MK_MASTER_MAKEFILE=$(or $(abspath $(call ENV_MK_MASTER_MAKEFILE_IN,$(abspath $1))),$(error Cannot find a master makefile because '$1' is not under the project directory))

define ENV_MK_MAKE_TARGET_FORWARD_TMPL=
$1: FORCE
	$(info Forwarding target '$1' to '$(call make_word_deescape,$3)')
	$(MAKE) -C $(dir $2) -f $(notdir $2) $(call rel_path,$(dir $3),$1)

endef

ENV_MK_MAKE_TARGET_FORWARD_IN=$(eval $(call ENV_MK_MAKE_TARGET_FORWARD_TMPL,$1,$(call rel_path,$(ENV_MK_ABSPWD),$2),$2))
make_target_forward=$(foreach t,$1,$(call ENV_MK_MAKE_TARGET_FORWARD_IN,$(t),$(call ENV_MK_MASTER_MAKEFILE,$(t))))

ENV_MK_TARGET_FORWARD_COMP_INIT_HOOK_1=$(if $(filter $(dir $2),$(call path_drop_tail_slash,$(ENV_MK_ABSPWD))/),,$(call ENV_MK_MAKE_TARGET_FORWARD_IN,$1,$2))
ENV_MK_TARGET_FORWARD_COMP_INIT_HOOK_2=$(call ENV_MK_TARGET_FORWARD_COMP_INIT_HOOK_1,$1,$(call ENV_MK_MASTER_MAKEFILE,$1))
define ENV_MK_TARGET_FORWARD_COMP_INIT_HOOK=
ifeq (true,$(ENV_MK_FORWARD_CMDGOALS))
$(foreach goal,$(MAKECMDGOALS),$(call ENV_MK_TARGET_FORWARD_COMP_INIT_HOOK_2,$(goal)))
endif
endef
ENV_MK_COMP_INIT_AFTER_HOOK+=ENV_MK_TARGET_FORWARD_COMP_INIT_HOOK


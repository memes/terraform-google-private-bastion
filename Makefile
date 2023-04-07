# Helper to ensure code is ready for tagging
# 1. Tag is a valid semver with v prefix (e.g. v1.0.0)
# 1. Git tree is clean
# 2. Each module is using a Terraform registry source and the version matches
#    the tag to be applied
# if all those pass, tag HEAD with version

.PHONY: pre-release.%
pre-release.%:
	@echo '$*' | grep -Eq '^v(?:[0-9]+\.){2}[0-9]+$$' || \
		(echo "Tag doesn't meet requirements"; exit 1)
	@test "$(shell git status --porcelain | wc -l | grep -Eo '[0-9]+')" == "0" || \
		(echo "Git tree is unclean"; exit 1)
	@find examples -type f -name main.tf -print0 | \
		xargs -0 awk 'BEGIN{m=0;s=0;v=0}; /module "bastion"/ {m=1}; m==1 && /source[ \t]*=[ \t]*"memes\/private-bastion\/google/ {s++}; m==1 && /version[ \t]*=[ \t]*"$(subst .,\.,$(*:v%=%))"/ {v=1}; END{if (s==0) { printf "%s has incorrect source", FILENAME}; if (v==0) { printf "%s has incorrect version\n", FILENAME}; if (s==0 || v==0) { exit 1}}'
	@echo 'Source is ready to release $*'

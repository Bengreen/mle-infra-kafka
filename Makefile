ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ifndef CI_TOOLS
$(error You must set the varaible CI_TOOLS to point to where you have checked out the k8s-ci-tools)
endif
include $(CI_TOOLS)/Makefile.mk



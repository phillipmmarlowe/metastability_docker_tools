# Defines for tool mounting - conatins mounted volumes for Fabric-to-Silicon, VCS, etc.
MET_TOOLS_DOCKERFILE   ?= ./Dockerfile_base
MET_USER_DOCKERFILE    ?= ./Dockerfile_user
LM_LICENSE_FILE        ?= 27000@license.soe.ucsc.edu
# YOSYSHQ_LICENSE        ?= /home/$(USER)/tabbycad-acad-DustinRichmond-240615.lic
H_YOSYSHQ_LICENSE_HOME ?= /soe/pmarlowe/tabbycad-acad-DustinRichmond-240911.lic
C_YOSYSHQ_LICENSE_HOME ?= /home/$(USER)/tabbycad-acad-DustinRichmond-240911.lic
# Tools
H_VCS_HOME           ?= /opt/synopsys/vcs/V-2023.12-SP2
C_VCS_HOME           ?= /opt/synopsys/vcs/V-2023.12-SP2
# YOSYS stuff
H_TABBY_HOME         ?= /mada/software/tabby
C_TABBY_HOME         ?= /opt/tabby
# H_YOSYS_HOME         ?= /mada/software/tabby/bin/yosys
# C_YOSYS_HOME         ?= /opt/tabby/bin/yosys
H_VPR_HOME           ?= /opt/vtr-verilog-to-routing
C_VPR_HOME           ?= /opt/vtr-verilog-to-routing
# Cadence stuff
# H_MADA_HOME          ?= /mada/software
# C_MADA_HOME          ?= /opt/software
H_MADA_HOME          ?= /mada
C_MADA_HOME          ?= /mada
# Asap7 PDK
H_ASAP7_HOME         ?= /soe/pmarlowe/asap7
C_ASAP7_HOME         ?= /opt/asap7
# Mill
H_MILL_HOME          ?= /soe/pmarlowe/mill
C_MILL_HOME          ?= /opt/mill
# QRC/LEC/VOLTUS_TEMPUS
H_SSV231_HOME         ?= /mada/software/cadence/SSV231
C_SSV231_HOME         ?= /opt/SSV231


F_TO_S_BUILD_SCRIPT  ?= ./test.sh
H_HOME_MOUNT         ?= $(HOME)/Fabric-to-Silicon
C_HOME_MOUNT         ?= /home/$(USER)/Fabric-to-Silicon
GID                  ?= $(shell id -g)
UID                  ?= $(shell echo $$UID)
UNAME                ?= $(shell echo $$USER)

default: build_cad_tools build_user run_script run_stop

build: build_cad_tools build_user

cli: run_stop build_cad_tools build_user run_cli

cli_ns: build_cad_tools build_user run_cli

exit: run_stop

all: build_cad_tools build_user run_script run_stop

# --no-cache \

build_cad_tools:
	docker build -f ${MET_TOOLS_DOCKERFILE} \
		--tag metastability_tools:base \
		--build-arg LM_LICENSE_FILE=$(LM_LICENSE_FILE) \
		--build-arg YOSYSHQ_LICENSE=$(C_YOSYSHQ_LICENSE_HOME) \
		--build-arg VCS_HOME=$(C_VCS_HOME) \
		--build-arg TABBY_HOME=$(C_TABBY_HOME) \
		--build-arg VPR_HOME=$(C_VPR_HOME) \
		--build-arg MILL_HOME=$(C_MILL_HOME) \
		--build-arg SSV231_HOME=$(C_SSV231_HOME) \
		--no-cache \
		--progress=plain . 2>&1 | tee build_base.log

# Remove LM License file and yosyshq args (not necessary I believe) (removed)
# --build-arg LM_LICENSE_FILE=$(LM_LICENSE_FILE) 
# --build-arg YOSYSHQ_LICENSE=$(YOSYSHQ_LICENSE) 

build_user:
	docker build -f ${MET_USER_DOCKERFILE} \
		--tag metastability_$(UNAME) \
		--build-arg UNAME=$(UNAME) \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID)\
		--no-cache \
		--progress=plain . 2>&1 | tee build_user.log

run_script:
	docker run -dit --name MET_TOOLS \
		-e F2S_PATH=$(C_HOME_MOUNT) \
		-v $(H_HOME_MOUNT):$(C_HOME_MOUNT) \
		-v $(H_VCS_HOME):$(C_VCS_HOME):ro \
		-v $(H_TABBY_HOME):$(C_TABBY_HOME):ro \
		-v $(H_YOSYSHQ_LICENSE_HOME):$(C_YOSYSHQ_LICENSE_HOME):ro \
		-v $(H_VPR_HOME):$(C_VPR_HOME):ro \
		-v $(H_MADA_HOME):$(C_MADA_HOME):ro \
		-v $(H_ASAP7_HOME):$(C_ASAP7_HOME):ro \
		-v $(H_MILL_HOME):$(C_MILL_HOME):ro \
		-v $(H_SSV231_HOME):$(C_SSV231_HOME):ro \
		metastability_$(USER):latest /bin/bash
	docker exec -i MET_TOOLS \
		/bin/bash < ${F_TO_S_BUILD_SCRIPT}
	

run_cli:
	docker run -dit --name MET_TOOLS \
		-v $(H_HOME_MOUNT):$(C_HOME_MOUNT) \
		-v $(H_VCS_HOME):$(C_VCS_HOME):ro \
		-v $(H_TABBY_HOME):$(C_TABBY_HOME):ro \
		-v $(H_YOSYSHQ_LICENSE_HOME):$(C_YOSYSHQ_LICENSE_HOME):ro \
		-v $(H_VPR_HOME):$(C_VPR_HOME):ro \
		-v $(H_MADA_HOME):$(C_MADA_HOME):ro \
		-v $(H_ASAP7_HOME):$(C_ASAP7_HOME):ro \
		-v $(H_MILL_HOME):$(C_MILL_HOME):ro \
		-v $(H_SSV231_HOME):$(C_SSV231_HOME):ro \
		metastability_$(USER):latest /bin/bash
# "docker attach MET_TOOLS" for CLI interface in container

run_stop:
	docker stop MET_TOOLS
	docker rm MET_TOOLS
#!/usr/bin/env bash
echo "Beginning complete F2S flow (except verification)"

# Begin simple F2S flow test (simple_fpga_add_test)
cd Fabric-to-Silicon || echo "Failed to navigate to F2S"

cd fpga_cad_flow || echo "Failed to navigate to fpga_cad_flow"

#source vpr_env.sh || echo "Failed to source vpr_env.sh"

cd example_designs/simple_fpga_add_test || echo "Failed to navigate to test application directory"

source design.sh || echo "Failed to source design.sh"

cd yosys || echo "Failed to navigate to yosys directory"
make synth || echo "Failed to run make synth"

cd ../vpr_pnr || echo "Failed to navigate to vpr_pnr directory"
make vpr || echo "Failed to run make vpr"
make genfasm || echo "Failed to run make genfasm"

cd ../../../../fabric_gen/ || echo "Failed to navigate to fabric_gen directory"

# For simple add test
export RRXML=$HOME/Fabric-to-Silicon/fpga_cad_flow/example_designs/simple_fpga_add_test/vpr_pnr/rr.xml || echo "Failed to export RRXML"

# In case mill error occurs, run following two commands in fabric_gen directory of
# F-to-S to resolve error, seems to do the trick  

# mill clean

# mill __.compile

# Getting weird mill error when below command is executed

make gen_fabric $RRXML || echo "Failed to run make gen_fabric"

export FASM=$HOME/Fabric-to-Silicon/fpga_cad_flow/example_designs/simple_fpga_add_test/vpr_pnr/add.fasm || echo "Failed to export FASM"

make gen_bitstream $RRXML $FASM || echo "Failed to run gen_bitstream"

cd ../physical_design/simple_fpga || echo "Failed to navigate to physical_design"

source scripts/cadence_asap7_template.bash || echo "Failed to source cadence_asap7_template"

source scripts/design.sh || echo "Failed to source design"

make synth || echo "Failed to run synth"

make pnr || echo "Failed to run pnr"

echo "All commands executed successfully."
#touch ${F2S_PATH}/test_success.txt

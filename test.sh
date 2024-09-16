#!/usr/bin/env bash
echo "I'm alive!"

# Begin simple F2S flow test (simple_fpga_add_test)
cd ${F2S_PATH}

cd fpga_cad_flow || { echo "Failed to navigate to fpga_cad_flow"; exit 1; }

#source vpr_env.sh || { echo "Failed to source vpr_env.sh"; exit 1; }

cd example_designs/simple_fpga_add_test || { echo "Failed to navigate to test application directory"; exit 1; }

source design.sh || { echo "Failed to source design.sh"; exit 1; }

cd yosys || { echo "Failed to navigate to yosys directory"; exit 1; }
make synth || { echo "Failed to run make synth"; exit 1; }

cd ../vpr_pnr || { echo "Failed to navigate to vpr_pnr directory"; exit 1; }
make vpr || { echo "Failed to run make vpr"; exit 1; }
make genfasm || { echo "Failed to run make genfasm"; exit 1; }

cd ../../../../fabric_gen/ || { echo "Failed to navigate to fabric_gen directory"; exit 1; }

# For simple add test
export RRXML=$HOME/Fabric-to-Silicon/fpga_cad_flow/example_designs/simple_fpga_add_test/vpr_pnr/rr.xml || { echo "Failed to export RRXML"; exit 1; }

mill clean

mill __.compile

# Getting weird mill error when below command is executed

make gen_fabric $RRXML || { echo "Failed to run make gen_fabric"; exit 1; }

export FASM=$HOME/Fabric-to-Silicon/fpga_cad_flow/example_designs/simple_fpga_add_test/vpr_pnr/add.fasm || { echo "Failed to export FASM"; exit 1; }

make gen_bitstream $RRXML $FASM || { echo "Failed to run gen_bitstream"; exit 1; }

cd ../physical_design/simple_fpga || { echo "Failed to navigate to physical_design"; exit 1; }

source scripts/cadence_asap7_template.bash || { echo "Failed to source cadence_asap7_template"; exit 1; }

source scripts/design.sh || { echo "Failed to source design"; exit 1; }

make synth || { echo "Failed to run synth"; exit 1; }

make pnr || { echo "Failed to run pnr"; exit 1; }

echo "All commands executed successfully."
touch ${F2S_PATH}/test_success.txt

variable dispScriptFile [file normalize [info script]]

proc getScriptDirectory {} {
    variable dispScriptFile
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

set sdir [getScriptDirectory]
cd [getScriptDirectory]

# KORAK#1: Definisanje direktorijuma u kojima ce biti smesteni projekat i konfiguracioni fajl
set resultDir ..\/..\/result\/Deskew
set releaseDir ..\/..\/release\/Deskew
file mkdir $resultDir
file mkdir $releaseDir
create_project pkg_dskw ..\/..\/result\/Deskew -part xc7z010clg400-1 -force


# KORAK#2: Ukljucivanje svih izvornih fajlova u projekat
add_files -norecurse ..\/hdl\/Deskew.sv
add_files -norecurse ..\/hdl\/memory_submodul.sv
add_files -norecurse ..\/hdl\/Deskew_v1_0_S00_AXI.v
add_files -norecurse ..\/hdl\/Deskew_v1_0.v
add_files -fileset constrs_1 ..\/xdc\/Deskew.xdc
update_compile_order -fileset sources_1

# KORAK#3: Pokretanje procesa sinteze
launch_runs synth_1
wait_on_run synth_1
puts "*****************************************************"
puts "* Sinteza zavrsena! *"
puts "*****************************************************"

# KORAK#4: Pokretanje procesa implementacije i generisanja konfiguracionog fajla
#set_property STEPS.WRITE_BITSTREAM.TCL.PRE [pwd]\/pre_write_bitstream.tcl [get_runs impl_1]
#launch_runs impl_1 -to_step write_bitstream
#wait_on_run impl_1
#puts "*******************************************************"
#puts "* Implementacija zavrsena! *"
#puts "*******************************************************"

# KORAK#5: Kopiranje konfiguracionog fajla u release folder
#file copy -force ..\/..\/result\/Deskew\/pkg_dskw.runs\/impl_1\/Deskew_v1_0.bit ..\/..\/release\/Deskew\/Deskew.bit 

# KORAK#6: Pakovanje Jezgra
update_compile_order -fileset sources_1
ipx::package_project -root_dir ..\/..\/ -vendor xilinx.com -library user -taxonomy /UserIP -force

set_property vendor FTN [ipx::current_core]
set_property name Deskew [ipx::current_core]
set_property display_name Deskew_axi_v1_0 [ipx::current_core]
set_property description {Obrada slike cifre pre klasifikacije} [ipx::current_core]
set_property vendor_display_name FTN [ipx::current_core]
set_property company_url http://www.ftn.uns.ac.rs [ipx::current_core]

set_property supported_families {zynq Production} [ipx::current_core]

ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "C_S00_AXI_DATA_WIDTH" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "C_S00_AXI_ADDR_WIDTH" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "ADDRESS" -component [ipx::current_core]]
set_property widget {textEdit} [ipgui::get_guiparamspec -name "WIDTH" -component [ipx::current_core] ]
set_property value_validation_type range_long [ipx::get_user_parameters WIDTH -of_objects [ipx::current_core]]
set_property value_validation_range_minimum 16 [ipx::get_user_parameters WIDTH -of_objects [ipx::current_core]]
set_property value_validation_range_maximum 32 [ipx::get_user_parameters WIDTH -of_objects [ipx::current_core]]

ipx::infer_bus_interface done_interrupt xilinx.com:signal:interrupt_rtl:1.0 [ipx::current_core]

set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  ..\/..\/ [current_project]
update_ip_catalog
ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core {..\/..\/FTN_user_Deskew_1.0.zip} [ipx::current_core]
close_project

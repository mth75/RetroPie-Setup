#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mess-trs-80"
rp_module_desc="MESS emulator (Tandy TRS-80, Model 3) - MESS Port for libretro"
rp_module_help="ROM Extensions: .zip .cas .dsk .dmk\n\n
Put games in:\n
$romdir/trs-80\n\n
Put BIOS files in $biosdir:\n
trs80.zip,trs80m3.zip,trsdos.zip (i used MultiDos)\n\n
For disk mode, on first run the floppy disk will not work.\n
It must be enabled with SCRLCK, TAB, Machine Configuration, Floppy Disk Drive, On, RESET, SCRLCK again."

rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame/master/LICENSE.md"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-mess-trs-80() {
	_mess=$(dirname "$md_inst")/lr-mess/mess_libretro.so
	if [ ! -f "$_mess" ]; then
		printMsgs dialog "cannot find '$_mess' !\n\nplease install 'lr-mess' package."
		exit 1
	fi
}

function sources_lr-mess-trs-80() {
	true
}

function build_lr-mess-trs-80() {
	true
}

function install_lr-mess-trs-80()  {
	true
}

function configure_lr-mess-trs-80() {
	_mess=$(dirname "$md_inst")/lr-mess/mess_libretro.so
	_retroarch_bin="$rootdir/emulators/retroarch/bin/retroarch"
	_system="trs-80"
	_config="$configdir/$_system/retroarch.cfg"
	_add_config="$_config.add"
	_custom_coreconfig="$configdir/$_system/custom-core-options.cfg"
	_script="$configdir/$_system/run_mess.sh"

	# create retroarch configuration
	ensureSystemretroconfig "$_system"

	# ensure it works without softlists, using a custom per-fake-core config
    iniConfig " = " "\"" "$_custom_coreconfig"
    iniSet "mame_softlists_enable" "disabled"
	iniSet "mame_softlists_auto_media" "disabled"
	iniSet "mame_boot_from_cli" "disabled"

	# this will get loaded too via --append_config
	iniConfig " = " "\"" "$_add_config"
	iniSet "core_options_path" "$_custom_coreconfig"
	#iniSet "save_on_exit" "false"

	# setup rom folder
	mkRomDir "$_system"

	# copy the juicy script which will do the all the hard work to the fake-core config folder
	cp "$scriptdir/scriptmodules/run_mess.sh" "$_script"
	chmod 755 "$_script"

	# add the emulators.cfg as normal, pointing to the above script
	addEmulator 0 "$md_id-cass" "$_system" "$_script $_retroarch_bin $_mess $_config trs80m3 $biosdir -flop1 %ROM%"
	addEmulator 1 "$md_id-disk" "$_system" "$_script $_retroarch_bin $_mess $_config trs80m3 $biosdir -flop1 $biosdir/trsdos.zip -flop2 %ROM%"

	# add system to es_systems.cfg as normal
	addSystem "$_system" "Tandy TRS-80" ".zip .cas .dsk .dmk"
}

{ avr ? true, arm ? true, teensy ? true }:

let
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/62b2bf3f8e8c38964dac53d34c17081e7042eb31.tar.gz";
    sha256 = "1gbl2ydnwl0vaf03dgvwd1c6vh15j4padp1h317papj9pxsrgyny";
  };
  pkgs = import nixpkgs {};

in

  with pkgs;
  let
    avrpkgs = pkgsCross.avr.buildPackages;
    avr_libc = avrpkgs.libcCross;
    avr_incflags = [
      "-isystem ${avr_libc}/avr/include"
      "-B${avr_libc}/avr/lib/avr5"
      "-L${avr_libc}/avr/lib/avr5"
      "-B${avr_libc}/avr/lib/avr35"
      "-L${avr_libc}/avr/lib/avr35"
      "-B${avr_libc}/avr/lib/avr51"
      "-L${avr_libc}/avr/lib/avr51"
    ];

  in stdenv.mkDerivation {
    name = "qmk-firmware";

    buildInputs = [ dfu-programmer dfu-util diffutils git python3 ]
      ++ lib.optional avr [ avrpkgs.binutils avrpkgs.gcc avr_libc avrdude ]
      ++ lib.optional arm [ gcc-arm-embedded ]
      ++ lib.optional teensy [ teensy-loader-cli ];

    AVR_CFLAGS = lib.optional avr avr_incflags;
    AVR_ASFLAGS = lib.optional avr avr_incflags;
  }

cite about-alias
about-alias 'development aliases'

alias m='LOADADDR=0x80800000 make -j16 uImage dtbs'
alias m2='m 2> errors.err'
alias c='cp arch/arm/boot/uImage arch/arm/boot/dts/*.dtb /media/mturquette/165A-3C60/ && sync'

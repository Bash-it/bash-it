cite about-alias
about-alias 'development aliases'

alias m='LOADADDR=0x80800000 make -j16 zImage dtbs'
alias m2='m 2> errors.err'
#alias c='cp arch/arm/boot/uImage arch/arm/boot/dts/omap4-panda-es.dtb /media/mturquette/boot/ && sync'
alias c='cp arch/arm/boot/zImage arch/arm/boot/dts/omap4-panda-es.dtb /var/lib/tftpboot/ && sync'
#alias t='cp arch/arm/boot/uImage arch/arm/boot/dts/omap4-panda-es.dtb /var/lib/tftpboot/ && sync'

# function p() defined in ~/.bash_it/custom/zzz.bash
alias pp='p 1'

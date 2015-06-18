# PS3-OtherOS
A mirror of glevand's PS3 OtherOS tools


Tutorial from glevand (outdated)
================================

NOTICE: All my tools should beep. If you don't get beep during one of the steps below
           then stop doing anything and contact me. I will help.
           OtherOS++ support: irc.gitbrew.org (ssl) #otheros
    
   ALL PS3 MODELS ARE SUPPORTED !!!
    
    1. Install my latest CFW
    2. When installation is finished, reboot in Recovery Mode (not the Backup/Restore in XMB) and choose "Restore PS3 System"
    3. Now your GameOS should use only the half of your HDD
       (Currently working on a better approach)
    4. Run setup_flash_for_otheros.pkg (for all PS3 models)
    5. Reboot (It's important to shut down and turn on your PS3)
    6. Store dtbImage.ps3.bin on USB drive, plug it in and run install_otheros.pkg
       (NAND owners should use dtbImage.ps3.bin.minimal, rename it to dtbImage.ps3.bin).
       Try different USB ports if you don't get any beeps.
    7. Run boot_otheros.pkg
    8. Run reboot.pkg (use the package, not manually reboot!)
    9. You should be in petitboot now.
       Exit from CUI to shell or switch to another virtual console.
   10. Run script create_hdd_region.sh
   11. Reboot and boot petitboot again
   12. You should see now new HDD device on petitboot, /dev/ps3dd.
       That's your OtherOS HDD region.
       Don't touch any other HDD regions if you don't know what you are doing. Use only ps3dd
       device for your Linux installation. Use parted to partition it and create GPT partition
       table on ps3dd. GPT is supported by both, Linux and FreeBSD.
    
   Be warned, if you damage your GameOS HDD region, GameOS will reformat HDD and
   remove your Linux HDD region in the process. You have to do the above steps again.
   Don't mess with GameOS HDD region and GameOS won't mess with your OtherOS HDD region.

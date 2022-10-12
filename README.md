# RiaZ-Loader
A small demoscene created in 16 bits assembly. Made in a rush for Haxhom's bootsector testing. A MBR that uses over 2 sectors of memory. The picture ones, there is a tutorial on my channel on how to do it. Video explaining in how to do it:

https://www.youtube.com/watch?v=6hN3q62ttes

# How it works
The bootloader tries to find the code starting with the address 0x8000, where our bootloader resides. Its like telling "if you don't find this address", you don't load anything. Doing this we can make sure that we have our payload on, and with that, customize a little what we want the payload do.

Bootloader can work also reading any 16 bits kernel/payload (RAW data) if it fits in sector number and address. Make sure it maps correctly the video memory and others,
and you are ready to go. 

In RiaZ\Pictures> You will find some pictures, the error ones, the main payload screen, and the "scrolling chess board".

# Building instructions
You must have NASM first of all, any version of it will work fine. You compile first the payload binary doing the following:

`nasm -fbin payload.asm -o output.bin`

You later compile the bootloader, its named `bootldr.asm`, which is the small piece of code which will load the first 5 sectors into memory
to do the magic. The size of the payload is arround 5 sectors, even though it could be smaller. You do the same.

`nasm -fbin bootldr.asm -o mbr.bin`

In case that `incbin` drops an error, put then the entire path where `output.bin` is located, and it should work.

# Testing

If you use QEMU: `qemu-system-i386 mbr.bin`

If you are crazy or you have a proper testing environment:

*If you plan to use a VM or a physical ones*: Overwrite manually the first sectors from the disk with HXD on the PhysicalDrive0 drive.
For educational purposes.

12/10/2022

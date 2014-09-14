# Description

A commandline tool for converting impute2 haplotype files into mach format. Written in D.

# Compile and install

    ldc2 impute2machhap.d

Then copy the binary file `impute2machhap` to any folder in your PATH, for example:

    sudo cp impute2machhap /usr/local/bin/


# Examples

Get help:

    impute2machhap

Convert sample file provided:

    impute2machhap --file chr22.gen --outdir mach

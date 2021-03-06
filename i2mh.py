#!/usr/bin/env python3

import argparse
import os, tempfile, shutil, subprocess, re
# import pdb

parser = argparse.ArgumentParser(
description="Convert impute2 haplotype files to mach format. \n©2014 Kaiyin Zhong"
)
parser.add_argument("files", nargs="+", help="Files to be converted (ending with _haps.gz)")
parser.add_argument("--outdir", "-o", help="Output directory")
parser.add_argument("--debug", "-d", action="store_true", help="Debugging mode")
args = parser.parse_args()

# pdb.set_trace()
if args.outdir == None:
    raise Exception("An output directory is required.")

pat = re.compile(r"_haps\.gz$")
try:
    tmpDir = tempfile.mkdtemp()
    if args.debug:
        print("Temp folder: %s" % tmpDir)
    for inFile in args.files:
        print("Converting %s" % inFile)
        prefix = pat.sub("", inFile)

        # deal with _haps.gz files
        inFileUnzip = prefix + "_haps"
        fileDir, fileNamePrefix = os.path.split(prefix)
        fileDir, fileName       = os.path.split(inFile)
        fileDir, fileNameUnzip  = os.path.split(inFileUnzip)
        copiedFilePrefix        = os.path.join(tmpDir, fileNamePrefix)
        copiedFile              = os.path.join(tmpDir, fileName)
        copiedFileUnzip         = os.path.join(tmpDir, fileNameUnzip)
        shutil.copy2(inFile, tmpDir)

        # deal with _samples files
        sampleFile = prefix + "_samples"
        shutil.copy2(sampleFile, tmpDir)
        fileDir, sampleName     = os.path.split(sampleFile)
        copiedSample            = os.path.join(tmpDir, sampleName)


        subprocess.call(["gunzip", copiedFile])
        if args.debug:
            subprocess.call(["ls", "-l", tmpDir])
        subprocess.call(["impute2machhap", "--file", copiedFilePrefix, "--outdir", args.outdir])
        os.remove(copiedFileUnzip)
        os.remove(copiedSample)
finally:
    shutil.rmtree(tmpDir)


import std.stdio;
import std.array;
import std.string;
import std.getopt;
import std.path;
import std.file;

string fstem;
string outdir;

int main(string[] args) {
    /* string fstem = "chr22.gen"; */

    string helpmsg = `
impute2machhap: Convert impute2 haplotype output to mach format.
                © Kaiyin Zhong 2014

Usage: impute2machhap --file IMPUTE2_FILE_STEM [--outdir OUTPUT_DIR]
       impute2machhap

Options:
    --file      The filepath of input impute2 file without the "_haps" ending.
                e.g. for a file named "xxx.yyy_haps", you should give "xxx.yyy"
    --outdir    Output directory, default to current directory.

                Without any args, print this help message.
        `;



    getopt(args, "file", &fstem, "outdir", &outdir);
    if(fstem == "") {
        writeln(helpmsg);
        return 0;
    }
    if(outdir == "") {
        outdir = getcwd();
    }
    if(!exists(outdir)) {
        mkdir(outdir);
    }


    string samplesFile = (fstem ~ "_samples").idup;
    string hapsFile = (fstem ~ "_haps").idup;

    File imputeSamples = File(samplesFile, "r");

    // get the FID->IID row
    string tmp;
    tmp = imputeSamples.readln();
    tmp = imputeSamples.readln();
    string[] fidiid;
    foreach(line; imputeSamples.byLine) {
        auto cols = split(line);
        auto ids = cols[0 .. 2];
        string combinedLine = (ids[0] ~ "->" ~ ids[1]).idup;
        string[] combinedLineRepeat = [combinedLine, combinedLine];
        fidiid ~= combinedLineRepeat;
    }

    // get the HAPL01 / HAPL02 row
    string[] hapl;
    for(int i=0; i<fidiid.length; i++) {
        if(i % 2 == 0) {
            hapl ~= "HAPL01";
        }
        else {
            hapl ~= "HAPL02";
        }
    }

    string[][] outputLines;
    outputLines ~= fidiid;
    outputLines ~= hapl;

    // read and translate haplotype data
    File imputeHaps = File(hapsFile, "r");
    string[] snps;
    foreach(line; imputeHaps.byLine) {
        auto cols = split(line);
        string snp = ("M\t" ~ cols[1]).idup;
        snps ~= snp;

        string refGen = (cols[3]).idup;
        string mutGen = (cols[4]).idup;
        /* writeln("Ref     : ", refGen); */
        /* writeln("Mutation: ", mutGen); */
        auto genCols = (cols[5 .. $]);
        string[] genColsTrans;

        if(refGen.length == 1 && mutGen.length == 1) {
            foreach(gen; genCols) {
                string newGen = gen.idup == "0" ? refGen : mutGen;
                genColsTrans ~= newGen;
            }
        }
        else if(refGen.length > 1 && mutGen.length == 1) {
            foreach(gen; genCols) {
                string newGen = gen.idup == "0" ? "R" : "D";
                genColsTrans ~= newGen;
            }
        }
        else {
            foreach(gen; genCols) {
                string newGen = gen.idup == "0" ? "R" : "I";
                genColsTrans ~= newGen;
            }
        }
        outputLines ~= genColsTrans;
    }

    // transpose output matrix
    auto nsnp = outputLines.length;
    auto nindiv = outputLines[0].length;
    string[][] outputTrans = new string[][](nindiv, nsnp);
    /* writeln("nsnp: ", nsnp); */
    /* writeln("nindiv: ", nindiv); */
    for(int i=0; i<nsnp; i++) {
        for(int j=0; j<nindiv; j++) {
            outputTrans[j][i] = outputLines[i][j];
        }
    }

    /* writeln(outputTrans); */
    /* writeln(outputLines); */

    string[] outputStrings;
    foreach(row; outputTrans) {
        string s1 = row[0 .. 2].join(" ");
        string s2 = row[2 .. $].join("");
        string line = s1 ~ " " ~  s2;
        outputStrings ~= line;
    }
    string machOutput = outputStrings.join("\n");
    string machOut = (outdir ~ "/" ~ baseName(fstem) ~ ".mach.out");
    File machfh = File(machOut, "w");
    machfh.write(machOutput);


    // write SNP list to file
    string snpsString = snps.join("\n");
    string snpsOut = (outdir ~ "/" ~ baseName(fstem) ~ ".data.dat");
    File snpsfh = File(snpsOut, "w");
    snpsfh.write(snpsString);

    return 0;
}


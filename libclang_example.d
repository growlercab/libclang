import std.stdio;
import std.getopt;
import std.string;

import deimos.clang.index;

immutable string usage = `
Usage: libclang-example --hdr=<header.h> -- [compiler flags]


`;

CXIndex index;

void main(string[] args)
{
    string hdrFile;
    auto compileArgs = ["-c".toStringz, "-x\0".toStringz, "cpp\0".toStringz];

    auto helpOpt = getopt(args, "h|hdr", "Header file to parse", &hdrFile);
    if(helpOpt.helpWanted) {
        defaultGetoptPrinter(usage, helpOpt.options);
        return;
    }
    writefln("Processing file '%s'", hdrFile);
    if(args.length > 0) {
        writeln("Using compiler args:\n----");
        foreach(a; compileArgs) {
            writeln("\t", a);
        }
        writeln("----");
    }
    writeln;

    // Create an index
    auto index = clang_createIndex(0, 0);

    // Create a translation unit
    auto transUnit = clang_parseTranslationUnit(index, 
            hdrFile.toStringz, 
            compileArgs.ptr,  // The compiler agrs from the cmd-line
            compileArgs.length, 
            null, // No unsaved file
            0, // 0 unsaved files
           CXTranslationUnit_Flags.CXTranslationUnit_None); // no options
    

    // Get a cursor
    auto cursor = clang_getTranslationUnitCursor(transUnit);

    // Visit the nodes.
    clang_visitChildren(cursor, 
            vistor, // Our callback
            null); // No data

}

extern(C) static CXChildVisitResult visitor(CXCursor cursor, CXCursor parent, CXClientData clientData)
{    
    import std.string;
    CXSourceLocation loc = clang_getCursorLocation(cursor);

    CXFile file;
    uint line, column, offset;
    clang_getFileLocation(loc, &file, &line, &column, &offset);
    writefln("Visiting %s(%s,%s %s)", clang_getFileName(file).fromStrinz, line, column, offset);    

}

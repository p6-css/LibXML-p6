use v6;
#  -- DO NOT EDIT --
# generated by: etc/generator.p6 

unit module LibXML::Native::Gen::schematron;
# XML Schemastron implementation:
#    interface to the XML Schematron validity checking. 
use LibXML::Native::Defs :LIB, :xmlCharP;

enum xmlSchematronValidOptions is export (
    XML_SCHEMATRON_OUT_BUFFER => 512,
    XML_SCHEMATRON_OUT_ERROR => 8,
    XML_SCHEMATRON_OUT_FILE => 256,
    XML_SCHEMATRON_OUT_IO => 1024,
    XML_SCHEMATRON_OUT_QUIET => 1,
    XML_SCHEMATRON_OUT_TEXT => 2,
    XML_SCHEMATRON_OUT_XML => 4,
)

class xmlSchematron is repr('CPointer') {
    method Free() is native(LIB) is symbol('xmlSchematronFree') {*};
    method NewValidCtxt(int32 $options --> xmlSchematronValidCtxt) is native(LIB) is symbol('xmlSchematronNewValidCtxt') {*};
}

class xmlSchematronParserCtxt is repr('CPointer') {
    sub xmlSchematronNewMemParserCtxt(Str $buffer, int32 $size --> xmlSchematronParserCtxt) is native(LIB) is export {*};
    sub xmlSchematronNewParserCtxt(Str $URL --> xmlSchematronParserCtxt) is native(LIB) is export {*};

    method Free() is native(LIB) is symbol('xmlSchematronFreeParserCtxt') {*};
    method Parse( --> xmlSchematron) is native(LIB) is symbol('xmlSchematronParse') {*};
}

class xmlSchematronValidCtxt is repr('CPointer') {
    method Free() is native(LIB) is symbol('xmlSchematronFreeValidCtxt') {*};
    method SetValidStructuredErrors(xmlStructuredErrorFunc $serror, Pointer $ctx) is native(LIB) is symbol('xmlSchematronSetValidStructuredErrors') {*};
    method ValidateDoc(xmlDoc $instance --> int32) is native(LIB) is symbol('xmlSchematronValidateDoc') {*};
}

use v6;
#  -- DO NOT EDIT --
# generated by: etc/generator.p6 

unit module LibXML::Native::Gen::xmlschemas;
# incomplete XML Schemas structure implementation:
#    interface to the XML Schemas handling and schema validity checking, it is incomplete right now. 
use LibXML::Native::Defs :LIB, :xmlCharP;

enum xmlSchemaValidError is export (
    XML_SCHEMAS_ERR_ => 24,
    XML_SCHEMAS_ERR_ATTRINVALID => 21,
    XML_SCHEMAS_ERR_ATTRUNKNOWN => 20,
    XML_SCHEMAS_ERR_CONSTRUCT => 17,
    XML_SCHEMAS_ERR_ELEMCONT => 10,
    XML_SCHEMAS_ERR_EXTRACONTENT => 13,
    XML_SCHEMAS_ERR_FACET => 23,
    XML_SCHEMAS_ERR_HAVEDEFAULT => 11,
    XML_SCHEMAS_ERR_INTERNAL => 18,
    XML_SCHEMAS_ERR_INVALIDATTR => 14,
    XML_SCHEMAS_ERR_INVALIDELEM => 15,
    XML_SCHEMAS_ERR_ISABSTRACT => 8,
    XML_SCHEMAS_ERR_MISSING => 4,
    XML_SCHEMAS_ERR_NOROLLBACK => 7,
    XML_SCHEMAS_ERR_NOROOT => 1,
    XML_SCHEMAS_ERR_NOTDETERMINIST => 16,
    XML_SCHEMAS_ERR_NOTEMPTY => 9,
    XML_SCHEMAS_ERR_NOTNILLABLE => 12,
    XML_SCHEMAS_ERR_NOTSIMPLE => 19,
    XML_SCHEMAS_ERR_NOTTOPLEVEL => 3,
    XML_SCHEMAS_ERR_NOTYPE => 6,
    XML_SCHEMAS_ERR_OK => 0,
    XML_SCHEMAS_ERR_UNDECLAREDELEM => 2,
    XML_SCHEMAS_ERR_VALUE => 22,
    XML_SCHEMAS_ERR_WRONGELEM => 5,
    XML_SCHEMAS_ERR_XXX => 25,
)

enum xmlSchemaValidOption is export (
    XML_SCHEMA_VAL_VC_I_CREATE => 1,
)

class xmlSchema is repr('CStruct') {
    has xmlCharP $.name; # schema name
    has xmlCharP $.targetNamespace; # the target namespace
    has xmlCharP $.version;
    has xmlCharP $.id; # Obsolete
    has xmlDoc $.doc;
    has xmlSchemaAnnot $.annot;
    has int32 $.flags;
    has xmlHashTable $.typeDecl;
    has xmlHashTable $.attrDecl;
    has xmlHashTable $.attrgrpDecl;
    has xmlHashTable $.elemDecl;
    has xmlHashTable $.notaDecl;
    has xmlHashTable $.schemasImports;
    has Pointer $._private; # unused by the library for users or bindings
    has xmlHashTable $.groupDecl;
    has xmlDict $.dict;
    has Pointer $.includes; # the includes, this is opaque for now
    has int32 $.preserve; # whether to free the document
    has int32 $.counter; # used to give ononymous components unique names
    has xmlHashTable $.idcDef; # All identity-constraint defs.
    has Pointer $.volatiles; # Obsolete
    method Free() is native(LIB) is symbol('xmlSchemaFree') {*};
    method NewValidCtxt( --> xmlSchemaValidCtxt) is native(LIB) is symbol('xmlSchemaNewValidCtxt') {*};
}

class xmlSchemaParserCtxt is repr('CPointer') {
    sub xmlSchemaNewMemParserCtxt(Str $buffer, int32 $size --> xmlSchemaParserCtxt) is native(LIB) is export {*};
    sub xmlSchemaNewParserCtxt(Str $URL --> xmlSchemaParserCtxt) is native(LIB) is export {*};

    method Free() is native(LIB) is symbol('xmlSchemaFreeParserCtxt') {*};
    method GetParserErrors(xmlSchemaValidityErrorFunc * $err, xmlSchemaValidityWarningFunc * $warn, void ** $ctx --> int32) is native(LIB) is symbol('xmlSchemaGetParserErrors') {*};
    method Parse( --> xmlSchema) is native(LIB) is symbol('xmlSchemaParse') {*};
    method SetParserErrors(xmlSchemaValidityErrorFunc $err, xmlSchemaValidityWarningFunc $warn, Pointer $ctx) is native(LIB) is symbol('xmlSchemaSetParserErrors') {*};
    method SetParserStructuredErrors(xmlStructuredErrorFunc $serror, Pointer $ctx) is native(LIB) is symbol('xmlSchemaSetParserStructuredErrors') {*};
}

class xmlSchemaSAXPlugStruct is repr('CPointer') {
}

class xmlSchemaValidCtxt is repr('CPointer') {
    method Free() is native(LIB) is symbol('xmlSchemaFreeValidCtxt') {*};
    method GetValidErrors(xmlSchemaValidityErrorFunc * $err, xmlSchemaValidityWarningFunc * $warn, void ** $ctx --> int32) is native(LIB) is symbol('xmlSchemaGetValidErrors') {*};
    method IsValid( --> int32) is native(LIB) is symbol('xmlSchemaIsValid') {*};
    method SAXPlug(xmlSAXHandlerPtr * $sax, void ** $user_data --> xmlSchemaSAXPlug) is native(LIB) is symbol('xmlSchemaSAXPlug') {*};
    method SetValidErrors(xmlSchemaValidityErrorFunc $err, xmlSchemaValidityWarningFunc $warn, Pointer $ctx) is native(LIB) is symbol('xmlSchemaSetValidErrors') {*};
    method SetValidOptions(int32 $options --> int32) is native(LIB) is symbol('xmlSchemaSetValidOptions') {*};
    method SetValidStructuredErrors(xmlStructuredErrorFunc $serror, Pointer $ctx) is native(LIB) is symbol('xmlSchemaSetValidStructuredErrors') {*};
    method GetOptions( --> int32) is native(LIB) is symbol('xmlSchemaValidCtxtGetOptions') {*};
    method GetParserCtxt( --> xmlParserCtxt) is native(LIB) is symbol('xmlSchemaValidCtxtGetParserCtxt') {*};
    method ValidateDoc(xmlDoc $doc --> int32) is native(LIB) is symbol('xmlSchemaValidateDoc') {*};
    method ValidateFile(Str $filename, int32 $options --> int32) is native(LIB) is symbol('xmlSchemaValidateFile') {*};
    method ValidateOneElement(xmlNode $elem --> int32) is native(LIB) is symbol('xmlSchemaValidateOneElement') {*};
    method ValidateSetFilename(Str $filename) is native(LIB) is symbol('xmlSchemaValidateSetFilename') {*};
    method ValidateSetLocator(xmlSchemaValidityLocatorFunc $f, Pointer $ctxt) is native(LIB) is symbol('xmlSchemaValidateSetLocator') {*};
    method ValidateStream(xmlParserInputBuffer $input, xmlCharEncoding $enc, xmlSAXHandler $sax, Pointer $user_data --> int32) is native(LIB) is symbol('xmlSchemaValidateStream') {*};
}

sub xmlSchemaDump(FILE * $output, xmlSchema $schema) is native(LIB) is export {*};
sub xmlSchemaSAXUnplug(xmlSchemaSAXPlug $plug --> int32) is native(LIB) is export {*};

use v6;
#  -- DO NOT EDIT --
# generated by: etc/generator.p6 

unit module LibXML::Native::Gen::entities;
# interface for the XML entities handling:
#    this module provides some of the entity API needed for the parser and applications. 
use LibXML::Native::Defs :LIB, :xmlCharP;

enum xmlEntityType is export (
    XML_EXTERNAL_GENERAL_PARSED_ENTITY => 2,
    XML_EXTERNAL_GENERAL_UNPARSED_ENTITY => 3,
    XML_EXTERNAL_PARAMETER_ENTITY => 5,
    XML_INTERNAL_GENERAL_ENTITY => 1,
    XML_INTERNAL_PARAMETER_ENTITY => 4,
    XML_INTERNAL_PREDEFINED_ENTITY => 6,
)

class xmlEntitiesTable is repr('CPointer') {
    sub xmlCreateEntitiesTable( --> xmlEntitiesTable) is native(LIB) is export {*};

    method Copy( --> xmlEntitiesTable) is native(LIB) is symbol('xmlCopyEntitiesTable') {*};
    method Free() is native(LIB) is symbol('xmlFreeEntitiesTable') {*};
}

sub xmlCleanupPredefinedEntities() is native(LIB) is export {*};
sub xmlEncodeSpecialChars(const xmlDoc * $doc, xmlCharP $input --> xmlCharP) is native(LIB) is export {*};
sub xmlInitializePredefinedEntities() is native(LIB) is export {*};

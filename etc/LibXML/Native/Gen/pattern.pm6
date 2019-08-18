use v6;
#  -- DO NOT EDIT --
# generated by: etc/generator.p6 

unit module LibXML::Native::Gen::pattern;
# pattern expression handling:
#    allows to compile and test pattern expressions for nodes either in a tree or based on a parser state. 
use LibXML::Native::Defs :LIB, :xmlCharP;

enum xmlPatternFlags is export (
    XML_PATTERN_DEFAULT => 0,
    XML_PATTERN_XPATH => 1,
    XML_PATTERN_XSFIELD => 4,
    XML_PATTERN_XSSEL => 2,
)

class xmlPattern is repr('CPointer') {
    sub xmlPatterncompile(xmlCharP $pattern, xmlDict * $dict, int32 $flags, const xmlChar ** $namespaces --> xmlPattern) is native(LIB) is export {*};

    method Free() is native(LIB) is symbol('xmlFreePattern') {*};
    method FreePatternList() is native(LIB) is symbol('xmlFreePatternList') {*};
    method FromRoot( --> int32) is native(LIB) is symbol('xmlPatternFromRoot') {*};
    method GetStreamCtxt( --> xmlStreamCtxt) is native(LIB) is symbol('xmlPatternGetStreamCtxt') {*};
    method Match(xmlNode $node --> int32) is native(LIB) is symbol('xmlPatternMatch') {*};
    method MaxDepth( --> int32) is native(LIB) is symbol('xmlPatternMaxDepth') {*};
    method MinDepth( --> int32) is native(LIB) is symbol('xmlPatternMinDepth') {*};
    method Streamable( --> int32) is native(LIB) is symbol('xmlPatternStreamable') {*};
}

class xmlStreamCtxt is repr('CPointer') {
    method Free() is native(LIB) is symbol('xmlFreeStreamCtxt') {*};
    method Pop( --> int32) is native(LIB) is symbol('xmlStreamPop') {*};
    method Push(xmlCharP $name, xmlCharP $ns --> int32) is native(LIB) is symbol('xmlStreamPush') {*};
    method PushAttr(xmlCharP $name, xmlCharP $ns --> int32) is native(LIB) is symbol('xmlStreamPushAttr') {*};
    method PushNode(xmlCharP $name, xmlCharP $ns, int32 $nodeType --> int32) is native(LIB) is symbol('xmlStreamPushNode') {*};
    method WantsAnyNode( --> int32) is native(LIB) is symbol('xmlStreamWantsAnyNode') {*};
}

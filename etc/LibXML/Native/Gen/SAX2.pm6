use v6;
#  -- DO NOT EDIT --
# generated by: etc/generator.p6 

unit module LibXML::Native::Gen::SAX2;
# SAX2 parser interface used to build the DOM tree:
#    those are the default SAX2 interfaces used by the library when building DOM tree. 
use LibXML::Native::Defs :LIB, :xmlCharP;

sub docbDefaultSAXHandlerInit() is native(LIB) is export {*};
sub htmlDefaultSAXHandlerInit() is native(LIB) is export {*};
sub xmlDefaultSAXHandlerInit() is native(LIB) is export {*};
sub xmlSAX2AttributeDecl(Pointer $ctx, xmlCharP $elem, xmlCharP $fullname, int32 $type, int32 $def, xmlCharP $defaultValue, xmlEnumeration $tree) is native(LIB) is export {*};
sub xmlSAX2CDataBlock(Pointer $ctx, xmlCharP $value, int32 $len) is native(LIB) is export {*};
sub xmlSAX2Characters(Pointer $ctx, xmlCharP $ch, int32 $len) is native(LIB) is export {*};
sub xmlSAX2Comment(Pointer $ctx, xmlCharP $value) is native(LIB) is export {*};
sub xmlSAX2ElementDecl(Pointer $ctx, xmlCharP $name, int32 $type, xmlElementContent $content) is native(LIB) is export {*};
sub xmlSAX2EndDocument(Pointer $ctx) is native(LIB) is export {*};
sub xmlSAX2EndElement(Pointer $ctx, xmlCharP $name) is native(LIB) is export {*};
sub xmlSAX2EndElementNs(Pointer $ctx, xmlCharP $localname, xmlCharP $prefix, xmlCharP $URI) is native(LIB) is export {*};
sub xmlSAX2EntityDecl(Pointer $ctx, xmlCharP $name, int32 $type, xmlCharP $publicId, xmlCharP $systemId, xmlCharP $content) is native(LIB) is export {*};
sub xmlSAX2ExternalSubset(Pointer $ctx, xmlCharP $name, xmlCharP $ExternalID, xmlCharP $SystemID) is native(LIB) is export {*};
sub xmlSAX2GetColumnNumber(Pointer $ctx --> int32) is native(LIB) is export {*};
sub xmlSAX2GetLineNumber(Pointer $ctx --> int32) is native(LIB) is export {*};
sub xmlSAX2GetPublicId(Pointer $ctx --> xmlCharP) is native(LIB) is export {*};
sub xmlSAX2GetSystemId(Pointer $ctx --> xmlCharP) is native(LIB) is export {*};
sub xmlSAX2HasExternalSubset(Pointer $ctx --> int32) is native(LIB) is export {*};
sub xmlSAX2HasInternalSubset(Pointer $ctx --> int32) is native(LIB) is export {*};
sub xmlSAX2IgnorableWhitespace(Pointer $ctx, xmlCharP $ch, int32 $len) is native(LIB) is export {*};
sub xmlSAX2InitDefaultSAXHandler(xmlSAXHandler * $hdlr, int32 $warning) is native(LIB) is export {*};
sub xmlSAX2InitDocbDefaultSAXHandler(xmlSAXHandler * $hdlr) is native(LIB) is export {*};
sub xmlSAX2InitHtmlDefaultSAXHandler(xmlSAXHandler * $hdlr) is native(LIB) is export {*};
sub xmlSAX2InternalSubset(Pointer $ctx, xmlCharP $name, xmlCharP $ExternalID, xmlCharP $SystemID) is native(LIB) is export {*};
sub xmlSAX2IsStandalone(Pointer $ctx --> int32) is native(LIB) is export {*};
sub xmlSAX2NotationDecl(Pointer $ctx, xmlCharP $name, xmlCharP $publicId, xmlCharP $systemId) is native(LIB) is export {*};
sub xmlSAX2ProcessingInstruction(Pointer $ctx, xmlCharP $target, xmlCharP $data) is native(LIB) is export {*};
sub xmlSAX2Reference(Pointer $ctx, xmlCharP $name) is native(LIB) is export {*};
sub xmlSAX2SetDocumentLocator(Pointer $ctx, xmlSAXLocator $loc) is native(LIB) is export {*};
sub xmlSAX2StartDocument(Pointer $ctx) is native(LIB) is export {*};
sub xmlSAX2StartElement(Pointer $ctx, xmlCharP $fullname, const xmlChar ** $atts) is native(LIB) is export {*};
sub xmlSAX2StartElementNs(Pointer $ctx, xmlCharP $localname, xmlCharP $prefix, xmlCharP $URI, int32 $nb_namespaces, const xmlChar ** $namespaces, int32 $nb_attributes, int32 $nb_defaulted, const xmlChar ** $attributes) is native(LIB) is export {*};
sub xmlSAX2UnparsedEntityDecl(Pointer $ctx, xmlCharP $name, xmlCharP $publicId, xmlCharP $systemId, xmlCharP $notationName) is native(LIB) is export {*};
sub xmlSAXDefaultVersion(int32 $version --> int32) is native(LIB) is export {*};
sub xmlSAXVersion(xmlSAXHandler * $hdlr, int32 $version --> int32) is native(LIB) is export {*};

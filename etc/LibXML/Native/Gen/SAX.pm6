use v6;
#  -- DO NOT EDIT --
# generated by: etc/generator.p6 

unit module LibXML::Native::Gen::SAX;
# Old SAX version 1 handler, deprecated:
#    DEPRECATED set of SAX version 1 interfaces used to build the DOM tree. 
use LibXML::Native::Defs :LIB, :xmlCharP;

sub attribute(Pointer $ctx, xmlCharP $fullname, xmlCharP $value) is native(LIB) is export {*};
sub attributeDecl(Pointer $ctx, xmlCharP $elem, xmlCharP $fullname, int32 $type, int32 $def, xmlCharP $defaultValue, xmlEnumeration $tree) is native(LIB) is export {*};
sub cdataBlock(Pointer $ctx, xmlCharP $value, int32 $len) is native(LIB) is export {*};
sub characters(Pointer $ctx, xmlCharP $ch, int32 $len) is native(LIB) is export {*};
sub checkNamespace(Pointer $ctx, xmlCharP $namespace --> int32) is native(LIB) is export {*};
sub comment(Pointer $ctx, xmlCharP $value) is native(LIB) is export {*};
sub elementDecl(Pointer $ctx, xmlCharP $name, int32 $type, xmlElementContent $content) is native(LIB) is export {*};
sub endDocument(Pointer $ctx) is native(LIB) is export {*};
sub endElement(Pointer $ctx, xmlCharP $name) is native(LIB) is export {*};
sub entityDecl(Pointer $ctx, xmlCharP $name, int32 $type, xmlCharP $publicId, xmlCharP $systemId, xmlCharP $content) is native(LIB) is export {*};
sub externalSubset(Pointer $ctx, xmlCharP $name, xmlCharP $ExternalID, xmlCharP $SystemID) is native(LIB) is export {*};
sub getColumnNumber(Pointer $ctx --> int32) is native(LIB) is export {*};
sub getLineNumber(Pointer $ctx --> int32) is native(LIB) is export {*};
sub getPublicId(Pointer $ctx --> xmlCharP) is native(LIB) is export {*};
sub getSystemId(Pointer $ctx --> xmlCharP) is native(LIB) is export {*};
sub globalNamespace(Pointer $ctx, xmlCharP $href, xmlCharP $prefix) is native(LIB) is export {*};
sub hasExternalSubset(Pointer $ctx --> int32) is native(LIB) is export {*};
sub hasInternalSubset(Pointer $ctx --> int32) is native(LIB) is export {*};
sub ignorableWhitespace(Pointer $ctx, xmlCharP $ch, int32 $len) is native(LIB) is export {*};
sub initdocbDefaultSAXHandler(xmlSAXHandlerV1 * $hdlr) is native(LIB) is export {*};
sub inithtmlDefaultSAXHandler(xmlSAXHandlerV1 * $hdlr) is native(LIB) is export {*};
sub initxmlDefaultSAXHandler(xmlSAXHandlerV1 * $hdlr, int32 $warning) is native(LIB) is export {*};
sub internalSubset(Pointer $ctx, xmlCharP $name, xmlCharP $ExternalID, xmlCharP $SystemID) is native(LIB) is export {*};
sub isStandalone(Pointer $ctx --> int32) is native(LIB) is export {*};
sub namespaceDecl(Pointer $ctx, xmlCharP $href, xmlCharP $prefix) is native(LIB) is export {*};
sub notationDecl(Pointer $ctx, xmlCharP $name, xmlCharP $publicId, xmlCharP $systemId) is native(LIB) is export {*};
sub processingInstruction(Pointer $ctx, xmlCharP $target, xmlCharP $data) is native(LIB) is export {*};
sub reference(Pointer $ctx, xmlCharP $name) is native(LIB) is export {*};
sub setDocumentLocator(Pointer $ctx, xmlSAXLocator $loc) is native(LIB) is export {*};
sub setNamespace(Pointer $ctx, xmlCharP $name) is native(LIB) is export {*};
sub startDocument(Pointer $ctx) is native(LIB) is export {*};
sub startElement(Pointer $ctx, xmlCharP $fullname, const xmlChar ** $atts) is native(LIB) is export {*};
sub unparsedEntityDecl(Pointer $ctx, xmlCharP $name, xmlCharP $publicId, xmlCharP $systemId, xmlCharP $notationName) is native(LIB) is export {*};
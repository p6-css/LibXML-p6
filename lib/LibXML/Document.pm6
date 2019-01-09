use v6;
unit class LibXML::Document;

use LibXML::Native;
use LibXML::Enums;
use LibXML::Config;
use NativeCall;

constant config = LibXML::Config;

has parserCtxt $.ctx;
has xmlDoc $.struct is required handles<encoding root-element>;

method Str(Bool() $format = False) is default {
    my Pointer[uint8] $p .= new;
    my int32 $len;
    my Bool $copied;

    if config.skip-xml-declaration {
        my \skip-dtd = config.skip-dtd;
        $!struct.child-nodes.grep({ !(skip-dtd && .type == XML_DTD_NODE) }).map(*.Str).join;
    }
    else {
        my xmlDoc $doc = $!struct;
        if $doc.internal-dtd && config.skip-dtd {
            $doc .= copy();
            $doc.xmlUnlinkNode($_) with $doc.internal-dtd;
            $copied = True;
        }

        if $format {
            $doc.xmlDocDumpFormatMemoryEnc($p, $len, 'UTF-8', +$format);
        }
        else {
            $doc.xmlDocDumpMemoryEnc($p, $len, 'UTF-8');
        }

        $doc.free if $copied;
        nativecast(str, $p);
    }

}

submethod DESTROY {
    .free with $!ctx // $!struct;
    $!ctx = Nil;
    $!struct = Nil;
}

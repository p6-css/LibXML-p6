unit module LibXML::Types;

use XML::Grammar;

subset Prefix of Str is export(:Prefix) where Str:U | /^<XML::Grammar::pident>$/;
subset NCName of Str is export(:NCName) where {!$_ || $_ ~~ /^<XML::Grammar::pident>$/}
subset QName of Str is export(:QName) where Str:U|/^<XML::Grammar::name>$/;

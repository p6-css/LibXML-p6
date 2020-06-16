use v6;
use LibXML::Item :box-class, :ast-to-xml;
use LibXML::_DomNode;

#| Abstract base class of LibXML Nodes
unit class LibXML::Node
    is repr('CPointer')
    is LibXML::Item
    does LibXML::_DomNode;

=begin pod

    =head2 Synopsis

        use LibXML::Node;
        my LibXML::Node $node;

        # -- Property Methods -- #
        my Str $name = $node.nodeName;
        $node.nodeName = $newName;
        my Bool $same = $node.isSameNode( $other-node );
        my Str $key = $node.unique-key;
        my Str $content = $node.nodeValue;
        $content = $node.textContent;
        my UInt $type = $node.nodeType;
        my Str $uri = $node.getBaseURI();
        $node.setBaseURI($uri);
        my Str $path = $node.nodePath();
        my UInt $lineno = $node.line-number();

        # -- Navigation Methods -- #
        $parent = $node.parentNode;
        my LibXML::Node $next = $node.nextSibling();
        $next = $node.nextNonBlankSibling();
        my LibXML::Node $prev = $node.previousSibling();
        $prev = $node.previousNonBlankSibling();
        my Bool $is-parent = $node.hasChildNodes();
        $child = $node.firstChild;
        $child = $node.lastChild;
        $other-node = $node.getOwner;
        my LibXML::Node @kids = $node.childNodes();
        @kids = $node.nonBlankChildNodes();

        # -- DOM Manipulation Methods -- #
        $node.unbindNode();
        $node.doc = $doc; # -OR- $node.setOwnerDoc($doc);
        my LibXML::Node $child = $node.removeChild( $node );
        $oldNode = $node.replaceChild( $newNode, $oldNode );
        $childNode = $node.appendChild( $childNode );
        $node = $parent.addNewChild( $nsURI, $name );
        $node.replaceNode($newNode);
        $node.addSibling($newNode);
        $newnode = $node.cloneNode( :deep );
        $node.insertBefore( $newNode, $refNode );
        $node.insertAfter( $newNode, $refNode );
        $node.removeChildNodes();
        $node.ownerDocument = $doc;

        # -- Searching Methods -- #
        #    * XPath *
        my LibXML::Node @found = $node.findnodes( $xpath-expression );
        my LibXML::Node::Set $results = $node.find( $xpath-expression );
        print $node.findvalue( $xpath-expression );
        my Bool $found = $node.exists( $xpath-expression );
        $found = $xpath-expression ~~ $node;
        my LibXML::Node $item = $node.first( $xpath-expression );
        $item = $node.last( $xpath-expression );
        #    * CSS selectors *
        $node.query-handler = CSS::Selector::To::XPath.new; # setup a query selector handler
        $item = $node.querySelector($css-selector); # first match
        $results = $node.querySelectorAll($css-selector); # all matches

        # -- Serialization Methods -- #
        my Str $xml = $node.Str(:format);
        my Str $xml-c14 = $node.Str: :C14N;
        $xml-c14 = $node.Str: :C14N, :comments, :xpath($expression), :exclusive;
        $xml-c14 = $node.Str :C14N, :v1_1, :xpath($expression);
        $xml = $doc.serialize(:format);
        # -- Binary serialization/encoding
        my blob8 $buf = $node.Blob(:format, :enc<UTF-8>);
        # -- Data  serialization -- #
        use LibXML::Item :ast-to-xml;
        my $node-data = $node.ast;
        my LibXML::Node $node2 = ast-to-xml($node-data);

        # -- Namespace Methods -- #
        my LibXML::Namespace @ns = $node.getNamespaces;
        my Str $localname = $node.localname;
        my Str $prefix = $node.prefix;
        my Str $uri = $node.namespaceURI();
        $uri = $node.lookupNamespaceURI( $prefix );
        $prefix = $node.lookupNamespacePrefix( $URI );
        $node.normalize;

        # -- Positional interface -- #
        $node.push: LibXML::Element.new: :name<A>;
        $node.push: LibXML::Element.new: :name<B>;
        say $node[1].Str; # <B/>
        $node[1] = LibXML::Element.new: :name<C>;
        say $node.values.map(*.Str).join(':');  # <A/>:<C/>
        $node.pop;  # remove last child

        # -- Associative interface -- #
        say $node.keys; # A B text() ..
        for $node<A> { ... }; # all '<A>..</A>' child nodes
        for $node<text()> { ... }; # text nodes

    =head2 Description

    LibXML::Node defines functions that are common to all Node Types. An
    LibXML::Node should never be created standalone, but as an instance of a high
    level class such as L<LibXML::Element> or L<LibXML::Text>. The class itself should
    provide only common functionality. In LibXML each node is part either of a
    document or a document-fragment. Because of this there is no node without a
    parent.

    Many methods listed here are extensively documented in the DOM Level 3 specification (L<http://www.w3.org/TR/DOM-Level-3-Core/>). Please refer to the specification for extensive documentation.
=end pod
use Method::Also;
use NativeCall;

use LibXML::Raw;
use LibXML::Config;
use LibXML::Enums;
use LibXML::Namespace;
use LibXML::XPath::Expression;
use LibXML::Types :NCName, :QName;
use LibXML::Item :dom-native;

constant config = LibXML::Config;
my subset NameVal of Pair is export(:NameVal) where .key ~~ QName:D && .value ~~ Str:D;
enum <SkipBlanks KeepBlanks>;
my subset XPathExpr where LibXML::XPath::Expression|Str|Any:U;

########################################################################
=head2 Property Methods

method raw handles<
    domCheck domFailure
    getNodeName getNodeValue
    lookupNamespacePrefix lookupNamespaceURI
    normalize nodePath
    setNamespaceDeclURI setNamespaceDeclPrefix setNodeName setNodeValue string-value
    type
    lock unlock
    unique-key ast-key xpath-key
> { ... }

method native is DEPRECATED<raw> { self.raw }

submethod DESTROY {
    self.raw.Unreference;
}

multi method box(anyNode:D $_) {
    .Reference;
    nativecast(box-class(.type), $_);
}

method getName { self.getNodeName }

#| Gets or sets the node name
method nodeName is rw is also<name tag tagName> returns Str {
    Proxy.new(
        FETCH => sub ($) { self.getNodeName },
        STORE => sub ($, QName $_) { self.setNodeName($_) },
    );
}

=begin pod
    =para This method is aware of namespaces and returns the
full name of the current node (C<prefix:localname>). 

    It also returns the correct DOM names for node types with
    constant names, namely: `#text`, `#cdata-section`, `#comment`, `#document`,
`#document-fragment`.

    =head3 method setNodeName

        method setNodeName(QName $new-name)
        # -Or-
        $.nodeName = $new-name

    In very limited situations, it is useful to change a nodes name. In the DOM
    specification this should throw an error. This Function is aware of namespaces.

    =head3 method unique-key

        method unique-key() returns Str

    This function is not specified for any DOM level. It returns a key guaranteed
    to be unique for this node, and to always be the same value for this node. In
    other words, two node objects return the same key if and only if isSameNode
    indicates that they are the same node.

    The returned key value is useful as a key in hashes.

    =head3 method nodePath

        method nodePath() returns Str

    This function is not specified for any DOM level: It returns a canonical
    structure based XPath for a given node.

=end pod

#| True if both objects refer to the same native structure
method isSameNode(LibXML::Item $other) is also<isSame> returns Bool {
    self.raw.isSameNode($other.raw);
}
method isEqual(|c) is DEPRECATED<isSameNode> { $.isSameNode(|c) }

#| Get or set the value of a node
method nodeValue is rw is also<value> returns Str {
    Proxy.new(
        FETCH => sub ($) { self.getNodeValue },
        STORE => sub ($, Str() $_) { self.setNodeValue($_) },
    );
}
=para If the node has any content (such as stored in a C<text node>) it
    can get requested through this function.
=para I<NOTE:> Element Nodes have no content per definition. To get the
    text value of an element use textContent() instead!

#| this function returns the content of all text nodes in the descendants of the given node as specified in DOM.
method textContent is also<text to-literal> returns Str {
    self.string-value;
}

#| Return a numeric value representing the node type of this node.
method nodeType returns UInt { self.type }
=para The module L<LibXML::Enums> by default exports enumerated constants
    `XML_*_NODE` and `XML_*_DECL` for the node and declaration types.

#| Gets the base URI
method getBaseURI returns Str { self.raw.GetBase }
=para Searches for the base URL of the node. The method should work on both XML and
    HTML documents even if base mechanisms for these are completely different. It
    returns the base as defined in RFC 2396 sections "5.1.1. Base URI within
    Document Content" and "5.1.2. Base URI from the Encapsulating Entity". However
    it does not return the document base (5.1.3), use method C<URI> of L<LibXML::Document> for this. 

#| Sets the base URI
method setBaseURI(Str $uri) { self.raw.SetBase($uri) }
=para This method only does something useful for an element node in an XML document.
    It sets the xml:base attribute on the node to $strURI, which effectively sets
    the base URI of the node to the same value. 
=para Note: For HTML documents this behaves as if the document was XML which may not
    be desired, since it does not effectively set the base URI of the node. See RFC
    2396 appendix D for an example of how base URI can be specified in HTML. 

method baseURI is rw is also<URI> {
    Proxy.new(
        FETCH => { self.getBaseURI },
        STORE => sub ($, Str() $uri) { self.setBaseURI($uri) }
    );
}

#| Return the source line number where the tag was found
method line-number returns UInt  { self.raw.GetLineNo }
=para If a node is added to the document the line number is 0. Problems may occur, if
    a node from one document is passed to another one.
=para IMPORTANT: Due to limitations in the libxml2 library line numbers greater than
    65535 will be returned as 65535. Please see L<http://bugzilla.gnome.org/show_bug.cgi?id=325533> for more details. 
=para Note: line-number() is special to LibXML and not part of the DOM specification.

########################################################################
=head2 Navigation Methods

#| Returns the objects parent node
method parent is also<ownerElement getOwnerElement parentNode> returns LibXML::Node is dom-native {...}

#| Returns the next sibling if any.
method nextSibling returns LibXML::Node is dom-native {...}

#| Returns the next non-blank sibling if any.
method nextNonBlankSibling returns LibXML::Node is dom-native {...}
=para A node is blank if it is a Text or CDATA node consisting of whitespace
    only. This method is not defined by DOM.

#| Analogous to getNextSibling(). Returns the previous sibling if any.
method previousSibling returns LibXML::Node is dom-native {...}

#| Returns the previous non-blank sibling, if any
method previousNonBlankSibling returns LibXML::Node is dom-native {...}
=para A node is blank if it is a Text or CDATA node consisting of whitespace
    only. This method is not defined by DOM.

#| Return the first child node, if any
method firstChild is also<getFirstChild> returns LibXML::Node is dom-native {...}

#| Return the last child node, if any
method lastChild is also<getLastChild> returns LibXML::Node is dom-native {...}

method firstNonBlankChild returns LibXML::Node is dom-native {...}
method lastNonBlankChild returns LibXML::Node is dom-native {...}
method prev returns LibXML::Node is dom-native {...}

#| Returns True if the current node has child nodes, False otherwise.
method hasChildNodes returns Bool {
    ? self.raw.hasChildNodes();
}

multi method first(Bool :$blank = True) {
    $blank ?? $.firstChild !! $.firstNonBlankChild;
}
multi method first($expr, |c) { $.xpath-context.first($expr, |c) }
multi method last(Bool :$blank = True) {
    $blank ?? $.lastChild !! $.lastNonBlankChild;
}
multi method last($expr, |c) { $.xpath-context.last($expr, |c) }

#| Appends text directly to a node
method appendText(Str:D $text) is also<appendTextNode> {
    self.raw.appendText($text);
}
=para Applicable to Element, Text, CData, Entity, EntityRef, PI, Comment,
    and DocumentFragment nodes.

method doc is rw is also<ownerDocument> {
    Proxy.new(
        FETCH => {
            self.getOwnerDocument;
        },
        STORE => sub ($, LibXML::Node $doc) {
            self.setOwnerDocument($doc);
        },
    );
}
=begin pod
ownerDocument

      method ownerDocument is rw returns LibXML::Document
      my LibXML::Document $doc = $node.ownerDocument;

Gets or sets the owner document for the node
=end pod


method getOwnerDocument is also<get-doc> returns LibXML::Node {
    my \doc-class = box-class(XML_DOCUMENT_NODE);
    do with self {
        with .raw.doc -> xmlDoc $raw {
            doc-class.box($raw);
        }
    } // doc-class;
}

submethod TWEAK(:$native) {
    die 'new(:$native) option is obselete. Please use :$raw'
        with $native;

    die "no content" unless nativecast(Pointer, self).defined
}

#| Transfers a node to another document
method setOwnerDocument( LibXML::Node $doc) {
    $doc.adoptNode(self);
    $doc;
}
=para This method unbinds the node first, if it is already bound to another document.
=para Calling `$node.setOwnerDocument($doc)` is equivalent to calling $doc.adoptNode($node)`.
    Because of this it has the same limitations with Entity References as adoptNode().

#| Get the root (owner) node
method getOwner returns LibXML::Node is dom-native<root> {...}
=para This function returns the root node that the current node is associated with.
    In most cases this will be a document node or a document fragment node.

method childNodes(Bool :$blank = True) is also<getChildnodes children nodes> handles <AT-POS ASSIGN-POS elems List list values map grep push pop> {
    iterate-list(self, LibXML::Node, :$blank);
}
=begin pod
    =head3 method childNodes

        method childNodes(Bool :$blank = True) returns LibXML::Node::List

    =para
    Get child nodes of a node

    I<childNodes> implements a more intuitive interface to the childnodes of the current node. It
    enables you to pass all children directly to a C<map> or C<grep>.

    Note that child nodes are iterable:

        for $elem.childNodes { ... }

    They also directly support a number of update operations, including 'push' (add an element), 'pop' (remove last element) and ASSIGN-POS, e.g.:

        $elem.childNodes[3] = LibXML::TextNode.new('p', 'replacement text for 4th child');

=end pod

method nonBlankChildNodes {
    iterate-list(self, LibXML::Node, :!blank);
}
=begin pod
    =head3 method nonBlankChildNodes

        method nonBlankChildNodes() returns LibXML::Node::List

    Get non-blank child nodes of a node
 
    This equivalent to I<childNodes(:!blank)>. It returns only non-blank nodes (where a node is blank if it is a Text or
    CDATA node consisting of whitespace only). This method is not defined by DOM.
=end pod

########################################################################
=head2 DOM Manipulation Methods

#| Unbinds the Node from its siblings and Parent, but not from the Document it belongs to.
method unbindNode is also<remove unlink unlinkNode> returns LibXML::Node {
    self.raw.Unlink;
    self;
}
=para If the node is not inserted into the DOM afterwards, it will be
    lost after the program terminates.

#| Unbind a child node from its parent
method removeChild(LibXML::Node:D $node --> LibXML::Node) {
    $node.keep: self.raw.removeChild($node.raw);
}
=para Fails if `$node` is not a child of this object

#| Replaces the `$old` node with the `$new` node.
method replaceChild(LibXML::Node $new, LibXML::Node $old --> LibXML::Node) {
    $old.keep: self.raw.replaceChild($new.raw, $old.raw),
}
=para The returned C<$old> node is unbound.
=para This function differs from the DOM L2 specification, in the case, if the new node is not part of the document, the
    node will be imported first.

#| Adds a child to this nodes children (alias addChild)
method appendChild(LibXML::Item:D $new) is also<add addChild> returns LibXML::Item {
    $new.keep: self.raw.appendChild($new.raw);
}
=para Fails, if the new childnode is already a child
    of this node. This method differs from the DOM L2 specification, in the case, if the new
    node is not part of the document, the node will be imported first.

method addNewChild(Str $uri, QName $name --> LibXML::Node) {
    LibXML::Node.box: self.raw.addNewChild($uri, $name);
}
=begin pod
    =head3 method addNewChild

        method addNewChild(
            Str $uri,
            QName $name
        ) returns LibXML::Element

    Vivify and add a new child element.

    Similar to C<addChild()>, this function uses low level libxml2 functionality to provide faster
    interface for DOM building. I<addNewChild()> uses C<xmlNewChild()> to create a new node on a given parent element.

    addNewChild() has two parameters $nsURI and $name, where $nsURI is an
    (optional) namespace URI. $name is the fully qualified element name;
    addNewChild() will determine the correct prefix if necessary.

    The function returns the newly created node.

    This function is very useful for DOM building, where a created node can be
    directly associated with its parent. I<NOTE> this function is not part of the DOM specification and its use may limit your
    code to Raku or Perl.
=end pod

#| Replace a node
method replaceNode(LibXML::Node:D $new --> LibXML::Node) {
    self.keep: self.raw.replaceNode($new.raw); 
}
=para This function is very similar to replaceChild(), but it replaces the node
    itself rather than a childnode. This is useful if a node found by any XPath
    function, should be replaced.

#| Add an additional node to the end of a nodelist
method addSibling(LibXML::Node:D $new --> LibXML::Node) {
    &?ROUTINE.returns.box(self.raw.addSibling($new.raw));
}

#| Copy a node
method cloneNode(LibXML::Node:D: Bool() :$deep = False --> LibXML::Node) is also<clone> {
    &?ROUTINE.returns.box: self.raw.cloneNode($deep);
}
=para When $deep is True the function will copy all child nodes as well.
    Otherwise the current node will be copied. Note that in case of
    element, attributes are copied even if $deep is not True. 

#| Inserts $new before $ref.
method insertBefore(LibXML::Node:D $new, LibXML::Node $ref? --> LibXML::Node) {
    my anyNode $ref-raw = .raw with $ref;
    $new.keep: self.raw.insertBefore($new.raw, $ref-raw);
}
=para If `$ref` is undefined, the newNode will be set as the new last child of the parent node.
    This function differs from the DOM L2 specification, in the case, if the new
    node is not part of the document, the node will be imported first,
    automatically.
=para Note, that the reference node has to be a direct child of the node the function
    is called on. Also, `$new` is not allowed to be an ancestor of the new
    parent node.

#| Inserts $new after $ref.
method insertAfter(LibXML::Node:D $new, LibXML::Node $ref? --> LibXML::Node) {
    my anyNode $ref-raw = .raw with $ref;
    $new.keep: self.raw.insertAfter($new.raw, $ref-raw);
}
=para If C<$refNode> is undefined, the newNode will be set as the new
    last child of the parent node.

method removeChildNodes(--> LibXML::Node) {
    &?ROUTINE.returns.box: self.raw.removeChildNodes();
}
=begin pod
    =head3 method removeChildNodes

        method removeChildNodes() returns LibXML::DocumentFragment

    Remove all child nodes, which are returned as a L<LibXML::DocumentFragment>
    This function is not specified for any DOM level: It removes all childnodes
    from a node in a single step.
=end pod

########################################################################
=head2 Searching Methods

method xpath-context handles<find findnodes findvalue exists> {
    state $ ||= { require LibXML::XPath::Context; True };
    LibXML::XPath::Context.new: :node(self);
}
=begin pod
    =head3 method findnodes

        multi method findnodes(Str $xpath-expr,
                               LibXML::Node $ref-node?,
                               Bool :$deref) returns LibXML::Node::Set 
        multi method findnodes(LibXML::XPath::Expression:D $xpath-expr,
                               LibXML::Node $ref-node?,
                               Bool :$deref) returns LibXML::Node::Set
        # Examples:
        my LibXML::Node @nodes = $node.findnodes( $xpath-expr );
        my LibXML::Node::Set $nodes = $node.findnodes( $xpath-expr, :deref );
        for $node.findnodes($xpath-expr) {...}

    I<findnodes> evaluates the XPath expression (XPath 1.0) on the current node and returns the
    resulting node set as an array; returning an L<LibXML::Node::Set> object.

    The XPath expression can be passed either as a string, or as a L<LibXML::XPath::Expression> object.

    The `:deref` option has an effect on associatve indexing:

        my $humps = $node.findnodes("dromedaries/species")<species/humps>;
        my $humps = $node.findnodes("dromedaries/species", :deref)<humps>;

    It indexes element child nodes and attributes. This option is used by the `AT-KEY` method (see below).

    I<NOTE ON NAMESPACES AND XPATH>:

    A common mistake about XPath is to assume that node tests consisting of an
    element name with no prefix match elements in the default namespace. This
    assumption is wrong - by XPath specification, such node tests can only match
    elements that are in no (i.e. null) namespace. 

    So, for example, one cannot match the root element of an XHTML document with C<$node.find('/html')> since C<'/html'> would only match if the root element `<html>` had no namespace, but all XHTML elements belong to the namespace
    http://www.w3.org/1999/xhtml. (Note that C<xmlns="..."> namespace declarations can also be specified in a DTD, which makes the
    situation even worse, since the XML document looks as if there was no default
    namespace). 

    There are several possible ways to deal with namespaces in XPath: 

        =begin item
        The recommended way is to define a document
        independent prefix-to-namespace mapping. For example: 

          $node.xpath-context.registerNs('x', 'http://www.w3.org/1999/xhtml');
          $node.find('/x:html');

        =end item
        =begin item
        Another possibility is to use prefixes declared in the queried document (if
        known). If the document declares a prefix for the namespace in question (and
        the context node is in the scope of the declaration), C<LibXML> allows you to use the prefix in the XPath expression, e.g.: 

          $node.find('/xhtml:html');

        =end item

    =head3 method find

      multi method find( Str $xpath ) returns Any
      multi method find( LibXML::XPath::Expression:D $xpath ) returns Any

    I<find> evaluates the XPath 1.0 expression using the current node as the context of the
    expression, and returns the result depending on what type of result the XPath
    expression had. For example, the XPath "1 * 3 + 52" results in a L<Numeric> object being returned. Other expressions might return an L<Bool> object, or a L<Str> object.

    The XPath expression can be passed either as a string, or as a L<LibXML::XPath::Expression> object.

    See also L<LibXML::XPathContext>.find.

    =head3 method findvalue

      multi method findvalue( Str $xpath ) returns Str
      multi method findvalue( LibXML::XPath::Expression:D $xpath ) returns Str

    I<findvalue> is equivalent to:

      $node.find( $xpath ).to-literal;

    That is, it returns the literal value of the results. This enables you to
    ensure that you get a string back from your search, allowing certain shortcuts.
    This could be used as the equivalent of XSLT's <xsl:value-of
    select="some_xpath"/>.

    See also L<LibXML::XPathContext>.findvalue.

    The xpath expression can be passed either as a string, or as a L<LibXML::XPath::Expression> object.

    =head3 method first

        multi method first(Bool :$blank=True) returns LibXML::Node
        multi method first(Str $xpath-expr) returns LibXML::Node
        multi method first(LibXML::XPath::Expression:D $xpath-expr) returns LibXML::Node
        # Examples
        my $child = $node.first;          # first child
        my $child = $node.first: :!blank; # first non-blank child
        my $descendant = $node.first($xpath-expr);

    This node returns the first child node, or descendant node that matches an optional XPath expression.

    =head3 method last

        multi method last(Bool :$blank=True) returns LibXML::Node
        multi method last(Str $xpath-expr) returns LibXML::Node
        multi method last(LibXML::XPath::Expression:D $xpath-expr) returns LibXML::Node
        # Examples
        my $child = $node.last;          # last child
        my $child = $node.last: :!blank; # last non-blank child
        my $descendant = $node.last($xpath-expr);

    This node returns the last child node, or descendant node that matches an optional XPath expression.

    =head3 method exists

        multi method exists(Str $xpath-expr) returns Bool
        multi method exist(LibXML::XPath::Expression:D $xpath-expr) returns Bool

    This method behaves like I<findnodes>, except that it only returns a boolean value (True if the expression matches a
    node, False otherwise) and may be faster than I<findnodes>, because the XPath evaluation may stop early on the first match.

    For XPath expressions that do not return node-set, the method returns True if
    the returned value is a non-zero number or a non-empty string.

    =head3 xpath-context

        method xpath-context() returns LibXML::XPath::Context

    Gets the L<LibXML::XPath::Context> object that is used for xpath queries (including `find()`, `findvalue()`, `exists()` and some `AT-KEY` queries.

      $node.xpath-context.set-options: :suppress-warnings, :suppress-errors;

    =head3 methods query-handler, querySelector, querySelectorAll

    These methods provide pluggable support for CSS (or other 3rd party) Query Selectors. See https://www.w3.org/TR/selectors-api/#DOM-LEVEL-2-STYLE. For example,
    to use the L<CSS::Selector::To::XPath> (module available separately).

        use CSS::Selector::To::XPath;
        $doc.query-handler = CSS::Selector::To::XPath.new;
        my $result-query = "#score>tbody>tr>td:nth-of-type(2)"
        my $results = $doc.querySelectorAll($result-query);
        my $first-result = $doc.querySelector($result-query);

    See L<LibXML::XPath::Context> for more details.
=end pod

sub iterate-list($parent, $of, Bool :$properties, Bool :$blank = True) is export(:iterate-list) {
    # follow a chain of .next links.
    state $ ||= { require LibXML::Node::List; True; }
    LibXML::Node::List.new: :$of, :$properties, :$blank, :$parent;
}

sub iterate-set($of, xmlNodeSet $raw, Bool :$deref) is export(:iterate-set) {
    # iterate through a set of nodes
    state $ ||= { require LibXML::Node::Set; True; }
    LibXML::Node::Set.new( :$raw, :$of, :$deref )
}

multi method ACCEPTS(LibXML::Node:D: LibXML::XPath::Expression:D $expr) {
    $.xpath-context.exists($expr);
}

multi method ACCEPTS(LibXML::Node:D: Str:D $expr) {
    $.xpath-context.exists($expr);
}

########################################################################
=head2 Serialization Methods

#| serialize to a string; canonicalized as per C14N specification
method canonicalize(
    Bool() :$comments,
    Bool() :$exclusive = False,
    Version :$v = v1.0,
    XPathExpr :$xpath is copy,
    :$selector = self,
    :@prefix,
    UInt :$mode = $v >= v1.1
         ?? XML_C14N_1_1
         !! ($exclusive ?? XML_C14N_EXCLUSIVE_1_0 !! XML_C14N_1_0),
    --> Str
) {
    my Str $rv;
    my CArray[Str] $prefix .= new: |@prefix, Str;

    with self {
        unless .nodeType ~~ XML_DOCUMENT_NODE|XML_HTML_DOCUMENT_NODE|XML_DOCB_DOCUMENT_NODE {
            ## due to how c14n is implemented, the nodeset it receives must
            ## include child nodes; ie, child nodes aren't assumed to be rendered.
            ## so we use an xpath expression to find all of the child nodes.
            state $AllNodes //= LibXML::XPath::Expression.new: expr => '(. | .//node() | .//@* | .//namespace::*)';
            state $NonCommentNodes //= LibXML::XPath::Expression.new: expr => '(. | .//node() | .//@* | .//namespace::*)[not(self::comment())]';
            $xpath //= $comments ?? $AllNodes !! $NonCommentNodes;
        }

        my $nodes = $selector.findnodes($_)
            with $xpath;

        $rv := self.raw.xml6_node_to_str_C14N(
            +$comments, $mode, $prefix,
            do with $nodes { .raw } else { xmlNodeSet },
        );

        die $_ with .domFailure;
    }
    $rv;
}
=begin pod
    =para
    The canonicalize  method is similar to Str(). Instead of simply serializing the
    document tree, it transforms it as it is specified in the XML-C14N
    Specification (see L<http://www.w3.org/TR/xml-c14n>). Such transformation is known as canonicalization.

    If :$comments is False or not specified, the result-document will not contain any
    comments that exist in the original document. To include comments into the
    canonized document, :$comments has to be set to True.

    The parameter :$xpath defines the nodeset of nodes that should be
    visible in the resulting document. This can be used to filter out some nodes.
    One has to note, that only the nodes that are part of the nodeset, will be
    included into the result-document. Their child-nodes will not exist in the
    resulting document, unless they are part of the nodeset defined by the xpath
    expression. 

    If :$xpath is omitted or empty, Str: :C14N will include all nodes
    in the given sub-tree, using the following XPath expressions: with comments 
      =begin code :lang<xpath>
      (. | .//node() | .//@* | .//namespace::*)
      =end code
    and without comments 
      =begin code :lang<xpath>
      (. | .//node() | .//@* | .//namespace::*)[not(self::comment())]
      =end code

    An optional parameter :$selector can be used to pass an L<LibXML::XPathContext> object defining the context for evaluation of $xpath-expression. This is useful
    for mapping namespace prefixes used in the XPath expression to namespace URIs.
    Note, however, that $node will be used as the context node for the evaluation,
    not the context node of :$selector. 

    :v(v1.1) can be passed to specify v1.1 of the C14N specification. The `:$eclusve` flag is not applicable to this level.
=end pod

proto method Str(|) is also<serialize> handles <Int Num> {*}
multi method Str(:$C14N! where .so, |c) {
    self.canonicalize(|c);
}
=begin pod
    =head3 multi method Str :C14N

        multi method Str(Bool :C14N!, *%opts) returns Str

    `$node.Str( :C14N, |%opts)` is equivalent to `$node.canonicalize(|%opts)`
=end pod

multi method Str(|c) is also<gist> is default {
    my $options = output-options(|c);
    self.raw.Str(:$options);
}
=begin pod
    =head3 multi method Str() returns Str

        method Str(Bool :$format, Bool :$tag-expansion) returns Str;

    This method is similar to the method C<Str> of a L<LibXML::Document> but for a single node. It returns a string consisting of XML serialization of
    the given node and all its descendants.
=end pod

=begin pod
    =head3 method serialize

        method serialize(*%opts) returns Str

    An alias for Str. This function name was added to be more consistent
    with libxml2.
=end pod

method Blob(Str :$enc, |c) {
    my $options = output-options(|c);
    self.raw.Blob(:$enc, :$options);
}
=begin pod
    =head3 method Blob() returns Blob

        method Blob(
            xmlEncodingStr :$enc = 'UTF-8',
            Bool :$format,
            Bool :$tag-expansion
        ) returns Blob;

   Returns a binary representation  of the XML
   node and its descendants encoded as `:$enc`.
=end pod

#| Data serialization
method ast returns Pair { self.ast-key => self.nodeValue }
=begin pod
    =para
    This method performs a deep data-serialization of the node. The L<LibXML::Item> X<ast-to-xml()> function can then be used to create a deep copy of the node;

        use LibXML::Item :ast-to-xml;
        my $ast = $node.ast;
        my LibXML::Node $copy = ast-to-xml($ast);

=end pod

multi method save(IO::Handle :$io!, Bool :$format = False) {
    $io.write: self.Blob(:$format);
}

multi method save(IO() :io($path)!, |c) {
    my IO::Handle $io = $path.open(:bin, :w);
    $.save(:$io, |c);
    $io;
}

multi method save(IO() :file($io)!, |c) {
    $.save(:$io, |c).close;
}

sub output-options(UInt :$options is copy = 0,
                   Bool :$format,
                   Bool :$skip-xml-declaration = config.skip-xml-declaration,
                   Bool :$tag-expansion = config.tag-expansion,
                   # **DEPRECATED**
                   Bool :$skip-decl, Bool :$expand,
                  ) is export(:output-options) {

    warn ':skip-decl option is deprecated, please use :skip-xml-declaration'
        with $skip-decl;
    warn ':expand option is deprecated, please use :tag-expansion'
        with $expand;
    $options +|= XML_SAVE_FORMAT
        if $format;
    $options +|= XML_SAVE_NO_DECL
        if $skip-xml-declaration;
    $options +|= XML_SAVE_NO_EMPTY
       if $tag-expansion;

    $options;
}

method protect(&action) {
    self.lock // die "couldn't get lock";
    my $rv = try { &action(); }
    self.unlock;
    die $_ with $!;
    $rv;
}

########################################################################
=head2 Namespace Methods

#| Returns the local name of a tag.
method localname returns Str { self.raw.name.subst(/^.*':'/,'') }
=para This is the part after the colon.

#| Returns the prefix of a tag
method prefix    returns Str { do with self.raw.ns {.prefix} // Str }
=para This is the part before the colon.

method addNamespace(Str $uri, NCName $prefix?) {
    $.setNamespace($uri, $prefix, :!activate);
}
method setNamespace(Str $uri, NCName $prefix?, Bool :$activate = True) {
    ? self.raw.setNamespace($uri, $prefix, :$activate);
}
method clearNamespace {
    ? self.raw.setNamespace(Str, Str);
}
method localNS(--> LibXML::Namespace) is dom-native {...}
method getNamespaces is also<namespaces> {
    iterate-list(self, LibXML::Namespace);
}
=begin pod
    =head3 method getNamespaces

        method getNamespaces returns LibXML::Node::List
        my LibXML::Namespace @ns = $node.getNamespaces;

    If a node has any namespaces defined, this function will return these
    namespaces. Note, that this will not return all namespaces that are in scope,
    but only the ones declared explicitly for that node.

    Although getNamespaces is available for all nodes, it only makes sense if used
    with element nodes.
=end pod

#| Returns the URI of the current namespace.
method namespaceURI(--> Str) is also<getNamespaceURI> { do with self.raw.ns {.href} // Str }

# handled by native method
=begin pod
    =head3 method lookupNamespaceURI

      method lookupNamespaceURI( NCName $prefix ) returns Str;

    Find a namespace URI by its prefix starting at the current node.

    =head3 method lookupNamespacePrefix

      method lookupNamespacePrefix( Str $URI ) returns NCName;

    Find a namespace prefix by its URI starting at the current node.

    I<NOTE> Only the namespace URIs are meant to be unique. The prefix is only document
    related. Also the document might have more than a single prefix defined for a
    namespace.

    =head3 method normalize

        method normalize() returns Str

    This function normalizes adjacent text nodes. This function is not as strict as
    libxml2's xmlTextMerge() function, since it will not free a node that is still
    referenced by Raku.

=end pod

########################################################################
=head2 Associative Interface

=begin pod
  =head3 methods AT-KEY, keys

      say $node.AT-KEY("species");
      #-OR-
      say $node<species>;

      say $node<species>.keys; # (disposition text() @name humps)
      say $node<species/humps>;
      say $node<species><humps>;

  This is a lightweight associative interface, based on xpath expressions. `$node.AT-KEY($foo)` is equivalent to `$node.findnodes($foo, :deref)`.                                                   

=end pod

multi method AT-KEY(NCName:D $tag) {
    # special case to handle default namespaces without a prefix.
    # https://stackoverflow.com/questions/16717211/
    iterate-set(LibXML::Node, self.raw.getChildrenByLocalName($tag), :deref);
}
multi method AT-KEY(Str:D $xpath) is default {
    $.xpath-context.AT-KEY($xpath);
}

method DELETE-KEY(Str:D $xpath) {
    my $unlinked = $.xpath-context.AT-KEY($xpath);
    .unlink for $unlinked.list;
    $unlinked;
}

method Hash(|c) handles <keys pairs kv> { $.childNodes(|c).Hash }

=begin pod

=head2 Copyright

2001-2007, AxKit.com Ltd.

2002-2006, Christian Glahn.

2006-2009, Petr Pajas.

=head2 License

This program is free software; you can redistribute it and/or modify it under
the terms of the Artistic License 2.0 L<http://www.perlfoundation.org/artistic_license_2_0>.

=end pod

// Small subset of E4X (ActionScript XML) on top of the DOM.
'use strict';

function XML(src) {
  if (!(this instanceof XML)) return new XML(src);
  if (src instanceof XML) {
    this.$node = src.$node;
    return;
  }
  if (typeof Node !== 'undefined' && src instanceof Node) {
    this.$node = src;
    return;
  }
  const s = src == null ? '' : String(src);
  const doc = new DOMParser().parseFromString(s, 'text/xml');
  const err = doc.getElementsByTagName('parsererror')[0];
  if (err) console.warn('XML parse error', err.textContent, s.slice(0, 200));
  this.$node = doc.documentElement;
}
XML.$fq = 'XML';
XML.ignoreWhitespace = true;
XML.ignoreComments = true;

function $xmlWrap(n) {
  return n ? new XML(n) : null;
}
function $xmlChildNodes(n) {
  const out = [];
  if (!n || !n.childNodes) return out;
  for (const c of Array.from(n.childNodes)) {
    if (c.nodeType === 1) out.push(c);
    else if (c.nodeType === 3 || c.nodeType === 4) {
      if (XML.ignoreWhitespace && !c.nodeValue.trim()) continue;
      out.push(c);
    }
  }
  return out;
}

(function (P) {
  P.name = function () {
    const n = this.$node;
    if (!n) return null;
    if (n.nodeType === 1) return n.localName || n.nodeName;
    if (n.nodeType === 2) return n.name;
    return null;
  };
  P.localName = P.name;
  P.nodeKind = function () {
    const t = this.$node ? this.$node.nodeType : 0;
    return t === 1 ? 'element' : t === 2 ? 'attribute' : (t === 3 || t === 4) ? 'text' : t === 8 ? 'comment' : 'processing-instruction';
  };
  P.children = function () { return new XMLList($xmlChildNodes(this.$node).map($xmlWrap)); };
  P.elements = function (name = '*') {
    return new XMLList($xmlChildNodes(this.$node).filter((c) => c.nodeType === 1 && (name === '*' || c.localName === name)).map($xmlWrap));
  };
  P.child = function (name) { return this.elements(name); };
  P.text = function () {
    return new XMLList($xmlChildNodes(this.$node).filter((c) => c.nodeType === 3 || c.nodeType === 4).map($xmlWrap));
  };
  P.attributes = function () {
    const n = this.$node;
    if (!n || !n.attributes) return new XMLList([]);
    return new XMLList(Array.from(n.attributes).map($xmlWrap));
  };
  P.attribute = function (name) {
    const n = this.$node;
    if (!n || n.nodeType !== 1 || !n.hasAttribute(name)) return new XMLList([]);
    return new XMLList([new XML(n.getAttributeNode(name))]);
  };
  // x.@name
  P.attr = function (name) {
    const n = this.$node;
    if (!n || n.nodeType !== 1) return '';
    const v = n.getAttribute(name);
    return v == null ? '' : v;
  };
  P.hasSimpleContent = function () {
    const n = this.$node;
    if (!n || n.nodeType !== 1) return true;
    return !Array.from(n.childNodes).some((c) => c.nodeType === 1);
  };
  P.hasComplexContent = function () { return !this.hasSimpleContent(); };
  P.parent = function () {
    const p = this.$node && this.$node.parentNode;
    return p && p.nodeType === 1 ? new XML(p) : undefined;
  };
  P.length = function () { return 1; };
  P.toString = function () {
    const n = this.$node;
    if (!n) return '';
    if (n.nodeType === 2) return n.value;
    if (n.nodeType === 3 || n.nodeType === 4) return n.nodeValue;
    if (this.hasSimpleContent()) return n.textContent;
    return this.toXMLString();
  };
  P.valueOf = function () { return this.toString(); };
  P.toXMLString = function () {
    const n = this.$node;
    if (!n) return '';
    if (n.nodeType === 3 || n.nodeType === 4) return n.nodeValue;
    if (n.nodeType === 2) return n.value;
    return new XMLSerializer().serializeToString(n);
  };
  P.appendChild = function (x) {
    const node = x instanceof XML ? x.$node : new XML(x).$node;
    const doc = this.$node.ownerDocument;
    this.$node.appendChild(doc.importNode(node, true));
    return this;
  };
  P.copy = function () { return new XML(this.$node.cloneNode(true)); };
})(XML.prototype);

function XMLList(items) {
  this.$items = items || [];
  for (let i = 0; i < this.$items.length; i++) this[i] = this.$items[i];
}
XMLList.$fq = 'XMLList';
(function (P) {
  P.length = function () { return this.$items.length; };
  P.toArray = function () { return this.$items.slice(); };
  P[Symbol.iterator] = function () { return this.$items[Symbol.iterator](); };
  P.toString = function () {
    if (this.$items.length === 1) return this.$items[0].toString();
    if (this.$items.every((x) => x.hasSimpleContent())) return this.$items.map((x) => x.toString()).join('');
    return this.toXMLString();
  };
  P.valueOf = function () { return this.toString(); };
  P.toXMLString = function () { return this.$items.map((x) => x.toXMLString()).join('\n'); };
  P.children = function () {
    let out = [];
    for (const x of this.$items) out = out.concat(x.children().$items);
    return new XMLList(out);
  };
  P.elements = function (name) {
    let out = [];
    for (const x of this.$items) out = out.concat(x.elements(name).$items);
    return new XMLList(out);
  };
  P.attr = function (name) { return this.$items.length ? this.$items[0].attr(name) : ''; };
  P.name = function () { return this.$items.length ? this.$items[0].name() : null; };
  P.nodeKind = function () { return this.$items.length ? this.$items[0].nodeKind() : 'element'; };
})(XMLList.prototype);

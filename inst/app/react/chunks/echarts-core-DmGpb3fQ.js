import { r as e } from "./rolldown-runtime-Cb76FRpK.js";
//#region node_modules/tslib/tslib.es6.js
var t = function(e, n) {
	return t = Object.setPrototypeOf || { __proto__: [] } instanceof Array && function(e, t) {
		e.__proto__ = t;
	} || function(e, t) {
		for (var n in t) Object.prototype.hasOwnProperty.call(t, n) && (e[n] = t[n]);
	}, t(e, n);
};
function n(e, n) {
	if (typeof n != "function" && n !== null) throw TypeError("Class extends value " + String(n) + " is not a constructor or null");
	t(e, n);
	function r() {
		this.constructor = e;
	}
	e.prototype = n === null ? Object.create(n) : (r.prototype = n.prototype, new r());
}
//#endregion
//#region node_modules/zrender/lib/core/env.js
var r = function() {
	function e() {
		this.firefox = !1, this.ie = !1, this.edge = !1, this.newEdge = !1, this.weChat = !1;
	}
	return e;
}(), i = new (function() {
	function e() {
		this.browser = new r(), this.node = !1, this.wxa = !1, this.worker = !1, this.svgSupported = !1, this.touchEventsSupported = !1, this.pointerEventsSupported = !1, this.domSupported = !1, this.transformSupported = !1, this.transform3dSupported = !1, this.hasGlobalWindow = typeof window < "u";
	}
	return e;
}())();
typeof wx == "object" && typeof wx.getSystemInfoSync == "function" ? (i.wxa = !0, i.touchEventsSupported = !0) : typeof document > "u" && typeof self < "u" ? i.worker = !0 : !i.hasGlobalWindow || "Deno" in window || typeof navigator < "u" && typeof navigator.userAgent == "string" && navigator.userAgent.indexOf("Node.js") > -1 ? (i.node = !0, i.svgSupported = !0) : a(navigator.userAgent, i);
function a(e, t) {
	var n = t.browser, r = e.match(/Firefox\/([\d.]+)/), i = e.match(/MSIE\s([\d.]+)/) || e.match(/Trident\/.+?rv:(([\d.]+))/), a = e.match(/Edge?\/([\d.]+)/), o = /micromessenger/i.test(e);
	if (r && (n.firefox = !0, n.version = r[1]), i && (n.ie = !0, n.version = i[1]), a && (n.edge = !0, n.version = a[1], n.newEdge = +a[1].split(".")[0] > 18), o && (n.weChat = !0), t.svgSupported = typeof SVGRect < "u", t.touchEventsSupported = "ontouchstart" in window && !n.ie && !n.edge, t.pointerEventsSupported = "onpointerdown" in window && (n.edge || n.ie && +n.version >= 11), t.domSupported = typeof document < "u") {
		var s = document.documentElement.style;
		t.transform3dSupported = (n.ie && "transition" in s || n.edge || "WebKitCSSMatrix" in window && "m11" in new WebKitCSSMatrix() || "MozPerspective" in s) && !("OTransition" in s), t.transformSupported = t.transform3dSupported || n.ie && +n.version >= 9;
	}
}
var o = "12px sans-serif", s = 20, c = 100, l = "007LLmW'55;N0500LLLLLLLLLL00NNNLzWW\\\\WQb\\0FWLg\\bWb\\WQ\\WrWWQ000CL5LLFLL0LL**F*gLLLL5F0LF\\FFF5.5N";
function u(e) {
	var t = {};
	if (typeof JSON > "u") return t;
	for (var n = 0; n < e.length; n++) {
		var r = String.fromCharCode(n + 32);
		t[r] = (e.charCodeAt(n) - s) / c;
	}
	return t;
}
var d = u(l), f = {
	createCanvas: function() {
		return typeof document < "u" && document.createElement("canvas");
	},
	measureText: (function() {
		var e, t;
		return function(n, r) {
			if (!e) {
				var i = f.createCanvas();
				e = i && i.getContext("2d");
			}
			if (e) return t !== r && (t = e.font = r || "12px sans-serif"), e.measureText(n);
			n ||= "", r ||= "12px sans-serif";
			var a = /((?:\d+)?\.?\d*)px/.exec(r), o = a && +a[1] || 12, s = 0;
			if (r.indexOf("mono") >= 0) s = o * n.length;
			else for (var c = 0; c < n.length; c++) {
				var l = d[n[c]];
				s += l == null ? o : l * o;
			}
			return { width: s };
		};
	})(),
	loadImage: function(e, t, n) {
		var r = new Image();
		return r.onload = t, r.onerror = n, r.src = e, r;
	},
	getTime: function() {
		return Date.now ? Date.now() : +/* @__PURE__ */ new Date();
	}
};
function p(e) {
	for (var t in f) f.hasOwnProperty(t) && e[t] && (f[t] = e[t]);
}
//#endregion
//#region node_modules/zrender/lib/core/util.js
var m = /* @__PURE__ */ e({
	EPSILON: () => Ie,
	HashMap: () => Ae,
	RADIAN_TO_DEGREE: () => Fe,
	assert: () => Se,
	assignProps: () => te,
	bind: () => z,
	clone: () => A,
	concatArray: () => je,
	createCanvas: () => ne,
	createHashMap: () => K,
	createObject: () => Me,
	curry: () => B,
	defaults: () => N,
	disableUserSelect: () => Ne,
	each: () => I,
	eqNaN: () => _e,
	extend: () => M,
	filter: () => oe,
	find: () => se,
	guid: () => O,
	hasOwn: () => q,
	indexOf: () => P,
	inherits: () => re,
	isArray: () => V,
	isArrayLike: () => ie,
	isBuiltInObject: () => de,
	isDom: () => pe,
	isFunction: () => H,
	isGradientObject: () => me,
	isImagePatternObject: () => he,
	isNumber: () => ue,
	isObject: () => W,
	isPrimitive: () => Ee,
	isRegExp: () => ge,
	isString: () => U,
	isStringSafe: () => le,
	isTypedArray: () => fe,
	keys: () => R,
	logError: () => k,
	map: () => L,
	merge: () => j,
	mergeAll: () => ee,
	mixin: () => F,
	noop: () => Pe,
	normalizeCssArray: () => xe,
	reduce: () => ae,
	retrieve: () => ve,
	retrieve2: () => G,
	retrieve3: () => ye,
	setAsPrimitive: () => Te,
	slice: () => be,
	trim: () => Ce
}), h = ae([
	"Function",
	"RegExp",
	"Date",
	"Error",
	"CanvasGradient",
	"CanvasPattern",
	"Image",
	"Canvas"
], function(e, t) {
	return e["[object " + t + "]"] = !0, e;
}, {}), g = ae([
	"Int8",
	"Uint8",
	"Uint8Clamped",
	"Int16",
	"Uint16",
	"Int32",
	"Uint32",
	"Float32",
	"Float64"
], function(e, t) {
	return e["[object " + t + "Array]"] = !0, e;
}, {}), _ = Object.prototype.toString, v = Array.prototype, y = v.forEach, b = v.filter, x = v.slice, S = v.map, C = function() {}.constructor, w = C ? C.prototype : null, T = "__proto__", E = 2311, D = 2 ** 53 - 1;
function O() {
	return E >= D && (E = 0), E++;
}
function k() {
	var e = [...arguments];
	typeof console < "u" && console.error.apply(console, e);
}
function A(e) {
	if (typeof e != "object" || !e) return e;
	var t = e, n = _.call(e);
	if (n === "[object Array]") {
		if (!Ee(e)) {
			t = [];
			for (var r = 0, i = e.length; r < i; r++) t[r] = A(e[r]);
		}
	} else if (g[n]) {
		if (!Ee(e)) {
			var a = e.constructor;
			if (a.from) t = a.from(e);
			else {
				t = new a(e.length);
				for (var r = 0, i = e.length; r < i; r++) t[r] = e[r];
			}
		}
	} else if (!h[n] && !Ee(e) && !pe(e)) for (var o in t = {}, e) e.hasOwnProperty(o) && o !== T && (t[o] = A(e[o]));
	return t;
}
function j(e, t, n) {
	if (!W(t) || !W(e)) return n ? A(t) : e;
	for (var r in t) if (t.hasOwnProperty(r) && r !== T) {
		var i = e[r], a = t[r];
		W(a) && W(i) && !V(a) && !V(i) && !pe(a) && !pe(i) && !de(a) && !de(i) && !Ee(a) && !Ee(i) ? j(i, a, n) : (n || !(r in e)) && (e[r] = A(t[r]));
	}
	return e;
}
function ee(e, t) {
	for (var n = e[0], r = 1, i = e.length; r < i; r++) n = j(n, e[r], t);
	return n;
}
function M(e, t) {
	if (Object.assign) Object.assign(e, t);
	else for (var n in t) t.hasOwnProperty(n) && n !== T && (e[n] = t[n]);
	return e;
}
function te(e, t, n) {
	e ||= {};
	for (var r = 0; r < n.length; r++) {
		var i = n[r];
		e[i] = t[i];
	}
	return e;
}
function N(e, t, n) {
	for (var r = R(t), i = 0, a = r.length; i < a; i++) {
		var o = r[i];
		(n ? t[o] != null : e[o] == null) && (e[o] = t[o]);
	}
	return e;
}
var ne = f.createCanvas;
function P(e, t) {
	if (e) {
		if (e.indexOf) return e.indexOf(t);
		for (var n = 0, r = e.length; n < r; n++) if (e[n] === t) return n;
	}
	return -1;
}
function re(e, t) {
	var n = e.prototype;
	function r() {}
	for (var i in r.prototype = t.prototype, e.prototype = new r(), n) n.hasOwnProperty(i) && (e.prototype[i] = n[i]);
	e.prototype.constructor = e, e.superClass = t;
}
function F(e, t, n) {
	if (e = "prototype" in e ? e.prototype : e, t = "prototype" in t ? t.prototype : t, Object.getOwnPropertyNames) for (var r = Object.getOwnPropertyNames(t), i = 0; i < r.length; i++) {
		var a = r[i];
		a !== "constructor" && (n ? t[a] != null : e[a] == null) && (e[a] = t[a]);
	}
	else N(e, t, n);
}
function ie(e) {
	return !e || typeof e == "string" ? !1 : typeof e.length == "number";
}
function I(e, t, n) {
	if (e && t) {
		if (e.forEach && e.forEach === y) e.forEach(t, n);
		else if (e.length === +e.length) for (var r = 0, i = e.length; r < i; r++) t.call(n, e[r], r, e);
		else for (var a in e) e.hasOwnProperty(a) && t.call(n, e[a], a, e);
	}
}
function L(e, t, n) {
	if (!e) return [];
	if (!t) return be(e);
	if (e.map && e.map === S) return e.map(t, n);
	for (var r = [], i = 0, a = e.length; i < a; i++) r.push(t.call(n, e[i], i, e));
	return r;
}
function ae(e, t, n, r) {
	if (e && t) {
		for (var i = 0, a = e.length; i < a; i++) n = t.call(r, n, e[i], i, e);
		return n;
	}
}
function oe(e, t, n) {
	if (!e) return [];
	if (!t) return be(e);
	if (e.filter && e.filter === b) return e.filter(t, n);
	for (var r = [], i = 0, a = e.length; i < a; i++) t.call(n, e[i], i, e) && r.push(e[i]);
	return r;
}
function se(e, t, n) {
	if (e && t) {
		for (var r = 0, i = e.length; r < i; r++) if (t.call(n, e[r], r, e)) return e[r];
	}
}
function R(e) {
	if (!e) return [];
	if (Object.keys) return Object.keys(e);
	var t = [];
	for (var n in e) e.hasOwnProperty(n) && t.push(n);
	return t;
}
function ce(e, t) {
	var n = [...arguments].slice(2);
	return function() {
		return e.apply(t, n.concat(x.call(arguments)));
	};
}
var z = w && H(w.bind) ? w.call.bind(w.bind) : ce;
function B(e) {
	var t = [...arguments].slice(1);
	return function() {
		return e.apply(this, t.concat(x.call(arguments)));
	};
}
function V(e) {
	return Array.isArray ? Array.isArray(e) : _.call(e) === "[object Array]";
}
function H(e) {
	return typeof e == "function";
}
function U(e) {
	return typeof e == "string";
}
function le(e) {
	return _.call(e) === "[object String]";
}
function ue(e) {
	return typeof e == "number";
}
function W(e) {
	var t = typeof e;
	return t === "function" || !!e && t === "object";
}
function de(e) {
	return !!h[_.call(e)];
}
function fe(e) {
	return !!g[_.call(e)];
}
function pe(e) {
	return typeof e == "object" && typeof e.nodeType == "number" && typeof e.ownerDocument == "object";
}
function me(e) {
	return e.colorStops != null;
}
function he(e) {
	return e.image != null;
}
function ge(e) {
	return _.call(e) === "[object RegExp]";
}
function _e(e) {
	return e !== e;
}
function ve() {
	for (var e = [...arguments], t = 0, n = e.length; t < n; t++) if (e[t] != null) return e[t];
}
function G(e, t) {
	return e ?? t;
}
function ye(e, t, n) {
	return e ?? t ?? n;
}
function be(e) {
	var t = [...arguments].slice(1);
	return x.apply(e, t);
}
function xe(e) {
	if (typeof e == "number") return [
		e,
		e,
		e,
		e
	];
	var t = e.length;
	return t === 2 ? [
		e[0],
		e[1],
		e[0],
		e[1]
	] : t === 3 ? [
		e[0],
		e[1],
		e[2],
		e[1]
	] : e;
}
function Se(e, t) {
	if (!e) throw Error(t);
}
function Ce(e) {
	return e == null ? null : typeof e.trim == "function" ? e.trim() : e.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, "");
}
var we = "__ec_primitive__";
function Te(e) {
	e[we] = !0;
}
function Ee(e) {
	return e[we];
}
var De = function() {
	function e() {
		this.data = {};
	}
	return e.prototype.delete = function(e) {
		var t = this.has(e);
		return t && delete this.data[e], t;
	}, e.prototype.has = function(e) {
		return this.data.hasOwnProperty(e);
	}, e.prototype.get = function(e) {
		return this.data[e];
	}, e.prototype.set = function(e, t) {
		return this.data[e] = t, this;
	}, e.prototype.keys = function() {
		return R(this.data);
	}, e.prototype.forEach = function(e) {
		var t = this.data;
		for (var n in t) t.hasOwnProperty(n) && e(t[n], n);
	}, e;
}(), Oe = typeof Map == "function";
function ke() {
	return Oe ? /* @__PURE__ */ new Map() : new De();
}
var Ae = function() {
	function e(t) {
		var n = V(t);
		this.data = ke();
		var r = this;
		t instanceof e ? t.each(i) : t && I(t, i);
		function i(e, t) {
			n ? r.set(e, t) : r.set(t, e);
		}
	}
	return e.prototype.hasKey = function(e) {
		return this.data.has(e);
	}, e.prototype.get = function(e) {
		return this.data.get(e);
	}, e.prototype.set = function(e, t) {
		return this.data.set(e, t), t;
	}, e.prototype.each = function(e, t) {
		this.data.forEach(function(n, r) {
			e.call(t, n, r);
		});
	}, e.prototype.keys = function() {
		var e = this.data.keys();
		return Oe ? Array.from(e) : e;
	}, e.prototype.removeKey = function(e) {
		this.data.delete(e);
	}, e;
}();
function K(e) {
	return new Ae(e);
}
function je(e, t) {
	for (var n = new e.constructor(e.length + t.length), r = 0; r < e.length; r++) n[r] = e[r];
	for (var i = e.length, r = 0; r < t.length; r++) n[r + i] = t[r];
	return n;
}
function Me(e, t) {
	var n;
	if (Object.create) n = Object.create(e);
	else {
		var r = function() {};
		r.prototype = e, n = new r();
	}
	return t && M(n, t), n;
}
function Ne(e) {
	var t = e.style;
	t.webkitUserSelect = "none", t.userSelect = "none", t.webkitTapHighlightColor = "rgba(0,0,0,0)", t["-webkit-touch-callout"] = "none";
}
function q(e, t) {
	return e.hasOwnProperty(t);
}
function Pe() {}
var Fe = 180 / Math.PI, Ie = 2 ** -52 || 2 ** -52, Le = /* @__PURE__ */ e({
	add: () => He,
	applyTransform: () => ot,
	clone: () => Be,
	copy: () => ze,
	create: () => Re,
	dist: () => tt,
	distSquare: () => rt,
	distance: () => et,
	distanceSquare: () => nt,
	div: () => Xe,
	dot: () => Ze,
	len: () => Ge,
	lenSquare: () => qe,
	length: () => Ke,
	lengthSquare: () => Je,
	lerp: () => at,
	max: () => ct,
	min: () => st,
	mul: () => Ye,
	negate: () => it,
	normalize: () => $e,
	scale: () => Qe,
	scaleAndAdd: () => Ue,
	set: () => Ve,
	sub: () => We
});
function Re(e, t) {
	return e ??= 0, t ??= 0, [e, t];
}
function ze(e, t) {
	return e[0] = t[0], e[1] = t[1], e;
}
function Be(e) {
	return [e[0], e[1]];
}
function Ve(e, t, n) {
	return e[0] = t, e[1] = n, e;
}
function He(e, t, n) {
	return e[0] = t[0] + n[0], e[1] = t[1] + n[1], e;
}
function Ue(e, t, n, r) {
	return e[0] = t[0] + n[0] * r, e[1] = t[1] + n[1] * r, e;
}
function We(e, t, n) {
	return e[0] = t[0] - n[0], e[1] = t[1] - n[1], e;
}
function Ge(e) {
	return Math.sqrt(qe(e));
}
var Ke = Ge;
function qe(e) {
	return e[0] * e[0] + e[1] * e[1];
}
var Je = qe;
function Ye(e, t, n) {
	return e[0] = t[0] * n[0], e[1] = t[1] * n[1], e;
}
function Xe(e, t, n) {
	return e[0] = t[0] / n[0], e[1] = t[1] / n[1], e;
}
function Ze(e, t) {
	return e[0] * t[0] + e[1] * t[1];
}
function Qe(e, t, n) {
	return e[0] = t[0] * n, e[1] = t[1] * n, e;
}
function $e(e, t) {
	var n = Ge(t);
	return n === 0 ? (e[0] = 0, e[1] = 0) : (e[0] = t[0] / n, e[1] = t[1] / n), e;
}
function et(e, t) {
	return Math.sqrt((e[0] - t[0]) * (e[0] - t[0]) + (e[1] - t[1]) * (e[1] - t[1]));
}
var tt = et;
function nt(e, t) {
	return (e[0] - t[0]) * (e[0] - t[0]) + (e[1] - t[1]) * (e[1] - t[1]);
}
var rt = nt;
function it(e, t) {
	return e[0] = -t[0], e[1] = -t[1], e;
}
function at(e, t, n, r) {
	return e[0] = t[0] + r * (n[0] - t[0]), e[1] = t[1] + r * (n[1] - t[1]), e;
}
function ot(e, t, n) {
	var r = t[0], i = t[1];
	return e[0] = n[0] * r + n[2] * i + n[4], e[1] = n[1] * r + n[3] * i + n[5], e;
}
function st(e, t, n) {
	return e[0] = Math.min(t[0], n[0]), e[1] = Math.min(t[1], n[1]), e;
}
function ct(e, t, n) {
	return e[0] = Math.max(t[0], n[0]), e[1] = Math.max(t[1], n[1]), e;
}
//#endregion
//#region node_modules/zrender/lib/mixin/Draggable.js
var lt = function() {
	function e(e, t) {
		this.target = e, this.topTarget = t && t.topTarget;
	}
	return e;
}(), ut = function() {
	function e(e) {
		this.handler = e, e.on("mousedown", this._dragStart, this), e.on("mousemove", this._drag, this), e.on("mouseup", this._dragEnd, this);
	}
	return e.prototype._dragStart = function(e) {
		for (var t = e.target; t && !t.draggable;) t = t.parent || t.__hostTarget;
		t && (this._draggingTarget = t, t.dragging = !0, this._x = e.offsetX, this._y = e.offsetY, this.handler.dispatchToElement(new lt(t, e), "dragstart", e.event));
	}, e.prototype._drag = function(e) {
		var t = this._draggingTarget;
		if (t) {
			var n = e.offsetX, r = e.offsetY, i = n - this._x, a = r - this._y;
			this._x = n, this._y = r, t.drift(i, a, e), this.handler.dispatchToElement(new lt(t, e), "drag", e.event);
			var o = this.handler.findHover(n, r, t).target, s = this._dropTarget;
			this._dropTarget = o, t !== o && (s && o !== s && this.handler.dispatchToElement(new lt(s, e), "dragleave", e.event), o && o !== s && this.handler.dispatchToElement(new lt(o, e), "dragenter", e.event));
		}
	}, e.prototype._dragEnd = function(e) {
		var t = this._draggingTarget;
		t && (t.dragging = !1), this.handler.dispatchToElement(new lt(t, e), "dragend", e.event), this._dropTarget && this.handler.dispatchToElement(new lt(this._dropTarget, e), "drop", e.event), this._draggingTarget = null, this._dropTarget = null;
	}, e;
}(), dt = function() {
	function e(e) {
		e && (this._$eventProcessor = e);
	}
	return e.prototype.on = function(e, t, n, r) {
		this._$handlers ||= {};
		var i = this._$handlers;
		if (typeof t == "function" && (r = n, n = t, t = null), !n || !e) return this;
		var a = this._$eventProcessor;
		t != null && a && a.normalizeQuery && (t = a.normalizeQuery(t)), i[e] || (i[e] = []);
		for (var o = 0; o < i[e].length; o++) if (i[e][o].h === n) return this;
		var s = {
			h: n,
			query: t,
			ctx: r || this,
			callAtLast: n.zrEventfulCallAtLast
		}, c = i[e].length - 1, l = i[e][c];
		return l && l.callAtLast ? i[e].splice(c, 0, s) : i[e].push(s), this;
	}, e.prototype.isSilent = function(e) {
		var t = this._$handlers;
		return !t || !t[e] || !t[e].length;
	}, e.prototype.off = function(e, t) {
		var n = this._$handlers;
		if (!n) return this;
		if (!e) return this._$handlers = {}, this;
		if (t) {
			if (n[e]) {
				for (var r = [], i = 0, a = n[e].length; i < a; i++) n[e][i].h !== t && r.push(n[e][i]);
				n[e] = r;
			}
			n[e] && n[e].length === 0 && delete n[e];
		} else delete n[e];
		return this;
	}, e.prototype.trigger = function(e) {
		var t = [...arguments].slice(1);
		if (!this._$handlers) return this;
		var n = this._$handlers[e], r = this._$eventProcessor;
		if (n) for (var i = t.length, a = n.length, o = 0; o < a; o++) {
			var s = n[o];
			if (!(r && r.filter && s.query != null && !r.filter(e, s.query))) switch (i) {
				case 0:
					s.h.call(s.ctx);
					break;
				case 1:
					s.h.call(s.ctx, t[0]);
					break;
				case 2:
					s.h.call(s.ctx, t[0], t[1]);
					break;
				default: s.h.apply(s.ctx, t);
			}
		}
		return r && r.afterTrigger && r.afterTrigger(e), this;
	}, e.prototype.triggerWithContext = function(e) {
		var t = [...arguments].slice(1);
		if (!this._$handlers) return this;
		var n = this._$handlers[e], r = this._$eventProcessor;
		if (n) for (var i = t.length, a = t[i - 1], o = n.length, s = 0; s < o; s++) {
			var c = n[s];
			if (!(r && r.filter && c.query != null && !r.filter(e, c.query))) switch (i) {
				case 0:
					c.h.call(a);
					break;
				case 1:
					c.h.call(a, t[0]);
					break;
				case 2:
					c.h.call(a, t[0], t[1]);
					break;
				default: c.h.apply(a, t.slice(1, i - 1));
			}
		}
		return r && r.afterTrigger && r.afterTrigger(e), this;
	}, e;
}(), ft = Math.log(2);
function pt(e, t, n, r, i, a) {
	var o = r + "-" + i, s = e.length;
	if (a.hasOwnProperty(o)) return a[o];
	if (t === 1) {
		var c = Math.round(Math.log((1 << s) - 1 & ~i) / ft);
		return e[n][c];
	}
	for (var l = r | 1 << n, u = n + 1; r & 1 << u;) u++;
	for (var d = 0, f = 0, p = 0; f < s; f++) {
		var m = 1 << f;
		m & i || (d += (p % 2 ? -1 : 1) * e[n][f] * pt(e, t - 1, u, l, i | m, a), p++);
	}
	return a[o] = d, d;
}
function mt(e, t) {
	var n = [
		[
			e[0],
			e[1],
			1,
			0,
			0,
			0,
			-t[0] * e[0],
			-t[0] * e[1]
		],
		[
			0,
			0,
			0,
			e[0],
			e[1],
			1,
			-t[1] * e[0],
			-t[1] * e[1]
		],
		[
			e[2],
			e[3],
			1,
			0,
			0,
			0,
			-t[2] * e[2],
			-t[2] * e[3]
		],
		[
			0,
			0,
			0,
			e[2],
			e[3],
			1,
			-t[3] * e[2],
			-t[3] * e[3]
		],
		[
			e[4],
			e[5],
			1,
			0,
			0,
			0,
			-t[4] * e[4],
			-t[4] * e[5]
		],
		[
			0,
			0,
			0,
			e[4],
			e[5],
			1,
			-t[5] * e[4],
			-t[5] * e[5]
		],
		[
			e[6],
			e[7],
			1,
			0,
			0,
			0,
			-t[6] * e[6],
			-t[6] * e[7]
		],
		[
			0,
			0,
			0,
			e[6],
			e[7],
			1,
			-t[7] * e[6],
			-t[7] * e[7]
		]
	], r = {}, i = pt(n, 8, 0, 0, 0, r);
	if (i !== 0) {
		for (var a = [], o = 0; o < 8; o++) for (var s = 0; s < 8; s++) a[s] ?? (a[s] = 0), a[s] += ((o + s) % 2 ? -1 : 1) * pt(n, 7, +(o === 0), 1 << o, 1 << s, r) / i * t[o];
		return function(e, t, n) {
			var r = t * a[6] + n * a[7] + 1;
			e[0] = (t * a[0] + n * a[1] + a[2]) / r, e[1] = (t * a[3] + n * a[4] + a[5]) / r;
		};
	}
}
//#endregion
//#region node_modules/zrender/lib/core/dom.js
var ht = "___zrEVENTSAVED", gt = [];
function _t(e, t, n, r, i) {
	return yt(gt, t, r, i, !0) && yt(e, n, gt[0], gt[1]);
}
function vt(e, t) {
	e && n(e), t && n(t);
	function n(e) {
		var t = e[ht];
		t && (t.clearMarkers && t.clearMarkers(), delete e[ht]);
	}
}
function yt(e, t, n, r, a) {
	if (t.getBoundingClientRect && i.domSupported && !St(t)) {
		var o = t[ht] || (t[ht] = {}), s = xt(bt(t, o), o, a);
		if (s) return s(e, n, r), !0;
	}
	return !1;
}
function bt(e, t) {
	var n = t.markers;
	if (n) return n;
	n = t.markers = [];
	for (var r = ["left", "right"], i = ["top", "bottom"], a = 0; a < 4; a++) {
		var o = document.createElement("div"), s = o.style, c = a % 2, l = (a >> 1) % 2;
		s.cssText = [
			"position: absolute",
			"visibility: hidden",
			"padding: 0",
			"margin: 0",
			"border-width: 0",
			"user-select: none",
			"width:0",
			"height:0",
			r[c] + ":0",
			i[l] + ":0",
			r[1 - c] + ":auto",
			i[1 - l] + ":auto",
			""
		].join("!important;"), e.appendChild(o), n.push(o);
	}
	return t.clearMarkers = function() {
		I(n, function(e) {
			e.parentNode && e.parentNode.removeChild(e);
		});
	}, n;
}
function xt(e, t, n) {
	for (var r = n ? "invTrans" : "trans", i = t[r], a = t.srcCoords, o = [], s = [], c = !0, l = 0; l < 4; l++) {
		var u = e[l].getBoundingClientRect(), d = 2 * l, f = u.left, p = u.top;
		o.push(f, p), c = c && a && f === a[d] && p === a[d + 1], s.push(e[l].offsetLeft, e[l].offsetTop);
	}
	return c && i ? i : (t.srcCoords = o, t[r] = n ? mt(s, o) : mt(o, s));
}
function St(e) {
	return e.nodeName.toUpperCase() === "CANVAS";
}
var Ct = /([&<>"'])/g, wt = {
	"&": "&amp;",
	"<": "&lt;",
	">": "&gt;",
	"\"": "&quot;",
	"'": "&#39;"
};
function Tt(e) {
	return e == null ? "" : (e + "").replace(Ct, function(e, t) {
		return wt[t];
	});
}
//#endregion
//#region node_modules/zrender/lib/core/event.js
var Et = /^(?:mouse|pointer|contextmenu|drag|drop)|click/, Dt = [], Ot = i.browser.firefox && +i.browser.version.split(".")[0] < 39;
function kt(e, t, n, r) {
	return n ||= {}, r ? At(e, t, n) : Ot && t.layerX != null && t.layerX !== t.offsetX ? (n.zrX = t.layerX, n.zrY = t.layerY) : t.offsetX == null ? At(e, t, n) : (n.zrX = t.offsetX, n.zrY = t.offsetY), n;
}
function At(e, t, n) {
	if (i.domSupported && e.getBoundingClientRect) {
		var r = t.clientX, a = t.clientY;
		if (St(e)) {
			var o = e.getBoundingClientRect();
			n.zrX = r - o.left, n.zrY = a - o.top;
			return;
		}
		if (yt(Dt, e, r, a)) {
			n.zrX = Dt[0], n.zrY = Dt[1];
			return;
		}
	}
	n.zrX = n.zrY = 0;
}
function jt(e) {
	return e || window.event;
}
function Mt(e, t, n) {
	if (t = jt(t), t.zrX != null) return t;
	var r = t.type;
	if (r && r.indexOf("touch") >= 0) {
		var i = r === "touchend" ? t.changedTouches[0] : t.targetTouches[0];
		i && kt(e, i, t, n);
	} else {
		kt(e, t, t, n);
		var a = Nt(t);
		t.zrDelta = a ? a / 120 : -(t.detail || 0) / 3;
	}
	var o = t.button;
	return t.which == null && o !== void 0 && Et.test(t.type) && (t.which = o & 1 ? 1 : o & 2 ? 3 : o & 4 ? 2 : 0), t;
}
function Nt(e) {
	var t = e.wheelDelta;
	if (t) return t;
	var n = e.deltaX, r = e.deltaY;
	if (n == null || r == null) return t;
	var i = Math.abs(r === 0 ? n : r), a = r > 0 ? -1 : r < 0 ? 1 : n > 0 ? -1 : 1;
	return 3 * i * a;
}
function Pt(e, t, n, r) {
	e.addEventListener(t, n, r);
}
function Ft(e, t, n, r) {
	e.removeEventListener(t, n, r);
}
var It = function(e) {
	e.preventDefault(), e.stopPropagation(), e.cancelBubble = !0;
};
function Lt(e) {
	return e.which === 2 || e.which === 3;
}
//#endregion
//#region node_modules/zrender/lib/core/GestureMgr.js
var Rt = function() {
	function e() {
		this._track = [];
	}
	return e.prototype.recognize = function(e, t, n) {
		return this._doTrack(e, t, n), this._recognize(e);
	}, e.prototype.clear = function() {
		return this._track.length = 0, this;
	}, e.prototype._doTrack = function(e, t, n) {
		var r = e.touches;
		if (r) {
			for (var i = {
				points: [],
				touches: [],
				target: t,
				event: e
			}, a = 0, o = r.length; a < o; a++) {
				var s = r[a], c = kt(n, s, {});
				i.points.push([c.zrX, c.zrY]), i.touches.push(s);
			}
			this._track.push(i);
		}
	}, e.prototype._recognize = function(e) {
		for (var t in Vt) if (Vt.hasOwnProperty(t)) {
			var n = Vt[t](this._track, e);
			if (n) return n;
		}
	}, e;
}();
function zt(e) {
	var t = e[1][0] - e[0][0], n = e[1][1] - e[0][1];
	return Math.sqrt(t * t + n * n);
}
function Bt(e) {
	return [(e[0][0] + e[1][0]) / 2, (e[0][1] + e[1][1]) / 2];
}
var Vt = { pinch: function(e, t) {
	var n = e.length;
	if (n) {
		var r = (e[n - 1] || {}).points, i = (e[n - 2] || {}).points || r;
		if (i && i.length > 1 && r && r.length > 1) {
			var a = zt(r) / zt(i);
			!isFinite(a) && (a = 1), t.pinchScale = a;
			var o = Bt(r);
			return t.pinchX = o[0], t.pinchY = o[1], {
				type: "pinch",
				target: e[0].target,
				event: t
			};
		}
	}
} }, Ht = /* @__PURE__ */ e({
	clone: () => Zt,
	copy: () => Gt,
	create: () => Ut,
	identity: () => Wt,
	invert: () => Xt,
	mul: () => Kt,
	rotate: () => Jt,
	scale: () => Yt,
	translate: () => qt
});
function Ut() {
	return [
		1,
		0,
		0,
		1,
		0,
		0
	];
}
function Wt(e) {
	return e[0] = 1, e[1] = 0, e[2] = 0, e[3] = 1, e[4] = 0, e[5] = 0, e;
}
function Gt(e, t) {
	return e[0] = t[0], e[1] = t[1], e[2] = t[2], e[3] = t[3], e[4] = t[4], e[5] = t[5], e;
}
function Kt(e, t, n) {
	var r = t[0] * n[0] + t[2] * n[1], i = t[1] * n[0] + t[3] * n[1], a = t[0] * n[2] + t[2] * n[3], o = t[1] * n[2] + t[3] * n[3], s = t[0] * n[4] + t[2] * n[5] + t[4], c = t[1] * n[4] + t[3] * n[5] + t[5];
	return e[0] = r, e[1] = i, e[2] = a, e[3] = o, e[4] = s, e[5] = c, e;
}
function qt(e, t, n) {
	return e[0] = t[0], e[1] = t[1], e[2] = t[2], e[3] = t[3], e[4] = t[4] + n[0], e[5] = t[5] + n[1], e;
}
function Jt(e, t, n, r) {
	r === void 0 && (r = [0, 0]);
	var i = t[0], a = t[2], o = t[4], s = t[1], c = t[3], l = t[5], u = Math.sin(n), d = Math.cos(n);
	return e[0] = i * d + s * u, e[1] = -i * u + s * d, e[2] = a * d + c * u, e[3] = -a * u + d * c, e[4] = d * (o - r[0]) + u * (l - r[1]) + r[0], e[5] = d * (l - r[1]) - u * (o - r[0]) + r[1], e;
}
function Yt(e, t, n) {
	var r = n[0], i = n[1];
	return e[0] = t[0] * r, e[1] = t[1] * i, e[2] = t[2] * r, e[3] = t[3] * i, e[4] = t[4] * r, e[5] = t[5] * i, e;
}
function Xt(e, t) {
	var n = t[0], r = t[2], i = t[4], a = t[1], o = t[3], s = t[5], c = n * o - a * r;
	return c ? (c = 1 / c, e[0] = o * c, e[1] = -a * c, e[2] = -r * c, e[3] = n * c, e[4] = (r * s - o * i) * c, e[5] = (a * i - n * s) * c, e) : null;
}
function Zt(e) {
	var t = Ut();
	return Gt(t, e), t;
}
//#endregion
//#region node_modules/zrender/lib/core/Point.js
var J = function() {
	function e(e, t) {
		this.x = e || 0, this.y = t || 0;
	}
	return e.prototype.copy = function(e) {
		return this.x = e.x, this.y = e.y, this;
	}, e.prototype.clone = function() {
		return new e(this.x, this.y);
	}, e.prototype.set = function(e, t) {
		return this.x = e, this.y = t, this;
	}, e.prototype.equal = function(e) {
		return e.x === this.x && e.y === this.y;
	}, e.prototype.add = function(e) {
		return this.x += e.x, this.y += e.y, this;
	}, e.prototype.scale = function(e) {
		this.x *= e, this.y *= e;
	}, e.prototype.scaleAndAdd = function(e, t) {
		this.x += e.x * t, this.y += e.y * t;
	}, e.prototype.sub = function(e) {
		return this.x -= e.x, this.y -= e.y, this;
	}, e.prototype.dot = function(e) {
		return this.x * e.x + this.y * e.y;
	}, e.prototype.len = function() {
		return Math.sqrt(this.x * this.x + this.y * this.y);
	}, e.prototype.lenSquare = function() {
		return this.x * this.x + this.y * this.y;
	}, e.prototype.normalize = function() {
		var e = this.len();
		return this.x /= e, this.y /= e, this;
	}, e.prototype.distance = function(e) {
		var t = this.x - e.x, n = this.y - e.y;
		return Math.sqrt(t * t + n * n);
	}, e.prototype.distanceSquare = function(e) {
		var t = this.x - e.x, n = this.y - e.y;
		return t * t + n * n;
	}, e.prototype.negate = function() {
		return this.x = -this.x, this.y = -this.y, this;
	}, e.prototype.transform = function(e) {
		if (e) {
			var t = this.x, n = this.y;
			return this.x = e[0] * t + e[2] * n + e[4], this.y = e[1] * t + e[3] * n + e[5], this;
		}
	}, e.prototype.toArray = function(e) {
		return e[0] = this.x, e[1] = this.y, e;
	}, e.prototype.fromArray = function(e) {
		this.x = e[0], this.y = e[1];
	}, e.set = function(e, t, n) {
		e.x = t, e.y = n;
	}, e.copy = function(e, t) {
		e.x = t.x, e.y = t.y;
	}, e.len = function(e) {
		return Math.sqrt(e.x * e.x + e.y * e.y);
	}, e.lenSquare = function(e) {
		return e.x * e.x + e.y * e.y;
	}, e.dot = function(e, t) {
		return e.x * t.x + e.y * t.y;
	}, e.add = function(e, t, n) {
		e.x = t.x + n.x, e.y = t.y + n.y;
	}, e.sub = function(e, t, n) {
		e.x = t.x - n.x, e.y = t.y - n.y;
	}, e.scale = function(e, t, n) {
		e.x = t.x * n, e.y = t.y * n;
	}, e.scaleAndAdd = function(e, t, n, r) {
		e.x = t.x + n.x * r, e.y = t.y + n.y * r;
	}, e.lerp = function(e, t, n, r) {
		var i = 1 - r;
		e.x = i * t.x + r * n.x, e.y = i * t.y + r * n.y;
	}, e;
}(), Qt = Math.min, $t = Math.max, en = Math.abs, tn = ["x", "y"], nn = ["width", "height"], rn = new J(), an = new J(), on = new J(), sn = new J(), cn = Sn(), ln = cn.minTv, un = cn.maxTv, dn = [0, 0], Y = function() {
	function e(e, t, n, r) {
		pn(this, e, t, n, r);
	}
	return e.set = function(e, t, n, r, i) {
		return r < 0 && (t += r, r = -r), i < 0 && (n += i, i = -i), e.x = t, e.y = n, e.width = r, e.height = i, e;
	}, e.prototype.union = function(e) {
		var t = Qt(e.x, this.x), n = Qt(e.y, this.y);
		this.width = isFinite(this.x) && isFinite(this.width) ? $t(e.x + e.width, this.x + this.width) - t : e.width, this.height = isFinite(this.y) && isFinite(this.height) ? $t(e.y + e.height, this.y + this.height) - n : e.height, this.x = t, this.y = n;
	}, e.prototype.applyTransform = function(t) {
		e.applyTransform(this, this, t);
	}, e.prototype.calculateTransform = function(e) {
		return hn(Ut(), this, e);
	}, e.prototype.intersect = function(t, n, r) {
		return e.intersect(this, t, n, r);
	}, e.intersect = function(t, n, r, i) {
		r && J.set(r, 0, 0);
		var a = i && i.outIntersectRect || null, o = i && i.clamp;
		if (a && (a.x = a.y = a.width = a.height = NaN), !t || !n) return !1;
		t instanceof e || (t = pn(vn, t.x, t.y, t.width, t.height)), n instanceof e || (n = pn(yn, n.x, n.y, n.width, n.height));
		var s = !!r;
		cn.reset(i, s);
		var c = cn.touchThreshold, l = t.x + c, u = t.x + t.width - c, d = t.y + c, f = t.y + t.height - c, p = n.x + c, m = n.x + n.width - c, h = n.y + c, g = n.y + n.height - c;
		if (l > u || d > f || p > m || h > g) return !1;
		var _ = !(u < p || m < l || f < h || g < d);
		return (s || a) && (dn[0] = Infinity, dn[1] = 0, xn(l, u, p, m, 0, s, a, o), xn(d, f, h, g, 1, s, a, o), s && J.copy(r, _ ? cn.useDir ? cn.dirMinTv : ln : un)), _;
	}, e.contain = function(e, t, n) {
		return t >= e.x && t <= e.x + e.width && n >= e.y && n <= e.y + e.height;
	}, e.prototype.contain = function(t, n) {
		return e.contain(this, t, n);
	}, e.prototype.clone = function() {
		return new e(this.x, this.y, this.width, this.height);
	}, e.prototype.copy = function(e) {
		mn(this, e);
	}, e.prototype.plain = function() {
		return {
			x: this.x,
			y: this.y,
			width: this.width,
			height: this.height
		};
	}, e.prototype.isFinite = function() {
		return isFinite(this.x) && isFinite(this.y) && isFinite(this.width) && isFinite(this.height);
	}, e.prototype.isZero = function() {
		return this.width === 0 || this.height === 0;
	}, e.create = function(t) {
		return new e(t ? t.x : 0, t ? t.y : 0, t ? t.width : 0, t ? t.height : 0);
	}, e.copy = function(e, t) {
		return e.x = t.x, e.y = t.y, e.width = t.width, e.height = t.height, e;
	}, e.applyTransform = function(e, t, n) {
		if (!n) e !== t && mn(e, t);
		else if (n[1] < 1e-5 && n[1] > -1e-5 && n[2] < 1e-5 && n[2] > -1e-5) {
			var r = n[0], i = n[3], a = n[4], o = n[5];
			e.x = t.x * r + a, e.y = t.y * i + o, e.width = t.width * r, e.height = t.height * i, e.width < 0 && (e.x += e.width, e.width = -e.width), e.height < 0 && (e.y += e.height, e.height = -e.height);
		} else {
			rn.x = on.x = t.x, rn.y = sn.y = t.y, an.x = sn.x = t.x + t.width, an.y = on.y = t.y + t.height, rn.transform(n), sn.transform(n), an.transform(n), on.transform(n), e.x = Qt(rn.x, an.x, on.x, sn.x), e.y = Qt(rn.y, an.y, on.y, sn.y);
			var s = $t(rn.x, an.x, on.x, sn.x), c = $t(rn.y, an.y, on.y, sn.y);
			e.width = s - e.x, e.height = c - e.y;
		}
	}, e.calculateTransform = function(e, t, n) {
		var r = n.width / t.width, i = n.height / t.height;
		return e = Wt(e || []), qt(e, e, Ve(bn, -t.x, -t.y)), Yt(e, e, Ve(bn, r, i)), qt(e, e, Ve(bn, n.x, n.y)), e;
	}, e;
}(), fn = Y.create, pn = Y.set, mn = Y.copy, hn = Y.calculateTransform, gn = Y.applyTransform, _n = Y.contain, vn = new Y(0, 0, 0, 0), yn = new Y(0, 0, 0, 0), bn = [];
function xn(e, t, n, r, i, a, o, s) {
	var c = en(t - n), l = en(r - e), u = Qt(c, l), d = tn[i], f = tn[1 - i], p = nn[i];
	t < n || r < e ? c < l ? (a && (un[d] = -c), s && (o[d] = t, o[p] = 0)) : (a && (un[d] = l), s && (o[d] = e, o[p] = 0)) : (o && (o[d] = $t(e, n), o[p] = Qt(t, r) - o[d]), a && (u < dn[0] || cn.useDir) && (dn[0] = Qt(u, dn[0]), (c < l || !cn.bidirectional) && (ln[d] = c, ln[f] = 0, cn.useDir && cn.calcDirMTV()), (c >= l || !cn.bidirectional) && (ln[d] = -l, ln[f] = 0, cn.useDir && cn.calcDirMTV())));
}
function Sn() {
	var e = 0, t = new J(), n = new J(), r = {
		minTv: new J(),
		maxTv: new J(),
		useDir: !1,
		dirMinTv: new J(),
		touchThreshold: 0,
		bidirectional: !0,
		negativeSize: !1,
		reset: function(i, a) {
			r.touchThreshold = 0, i && i.touchThreshold != null && (r.touchThreshold = $t(0, i.touchThreshold)), r.negativeSize = !1, a && (r.minTv.set(Infinity, Infinity), r.maxTv.set(0, 0), r.useDir = !1, i && i.direction != null && (r.useDir = !0, r.dirMinTv.copy(r.minTv), n.copy(r.minTv), e = i.direction, r.bidirectional = i.bidirectional == null || !!i.bidirectional, r.bidirectional || t.set(Math.cos(e), Math.sin(e))));
		},
		calcDirMTV: function() {
			var a = r.minTv, o = r.dirMinTv, s = a.y * a.y + a.x * a.x, c = Math.sin(e), l = Math.cos(e), u = c * a.y + l * a.x;
			i(u) ? i(a.x) && i(a.y) && o.set(0, 0) : (n.x = s * l / u, n.y = s * c / u, i(n.x) && i(n.y) ? o.set(0, 0) : (r.bidirectional || t.dot(n) > 0) && n.len() < o.len() && o.copy(n));
		}
	};
	function i(e) {
		return en(e) < 1e-10;
	}
	return r;
}
//#endregion
//#region node_modules/zrender/lib/Handler.js
var Cn = "silent";
function wn(e, t, n) {
	return {
		type: e,
		event: n,
		target: t.target,
		topTarget: t.topTarget,
		cancelBubble: !1,
		offsetX: n.zrX,
		offsetY: n.zrY,
		gestureEvent: n.gestureEvent,
		pinchX: n.pinchX,
		pinchY: n.pinchY,
		pinchScale: n.pinchScale,
		wheelDelta: n.zrDelta,
		zrByTouch: n.zrByTouch,
		which: n.which,
		stop: Tn
	};
}
function Tn() {
	It(this.event);
}
var En = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t.handler = null, t;
	}
	return t.prototype.dispose = function() {}, t.prototype.setCursor = function() {}, t;
}(dt), Dn = function() {
	function e(e, t) {
		this.x = e, this.y = t;
	}
	return e;
}(), On = [
	"click",
	"dblclick",
	"mousewheel",
	"mouseout",
	"mouseup",
	"mousedown",
	"mousemove",
	"contextmenu"
], kn = new Y(0, 0, 0, 0), An = function(e) {
	n(t, e);
	function t(t, n, r, i, a) {
		var o = e.call(this) || this;
		return o._hovered = new Dn(0, 0), o.storage = t, o.painter = n, o.painterRoot = i, o._pointerSize = a, r ||= new En(), o.proxy = null, o.setHandlerProxy(r), o._draggingMgr = new ut(o), o;
	}
	return t.prototype.setHandlerProxy = function(e) {
		this.proxy && this.proxy.dispose(), e && (I(On, function(t) {
			e.on && e.on(t, this[t], this);
		}, this), e.handler = this), this.proxy = e;
	}, t.prototype.mousemove = function(e) {
		var t = e.zrX, n = e.zrY, r = Nn(this, t, n), i = this._hovered, a = i.target;
		a && !a.__zr && (i = this.findHover(i.x, i.y), a = i.target);
		var o = this._hovered = r ? new Dn(t, n) : this.findHover(t, n), s = o.target, c = this.proxy;
		c.setCursor && c.setCursor(s ? s.cursor : "default"), a && s !== a && this.dispatchToElement(i, "mouseout", e), this.dispatchToElement(o, "mousemove", e), s && s !== a && this.dispatchToElement(o, "mouseover", e);
	}, t.prototype.mouseout = function(e) {
		var t = e.zrEventControl;
		t !== "only_globalout" && this.dispatchToElement(this._hovered, "mouseout", e), t !== "no_globalout" && this.trigger("globalout", {
			type: "globalout",
			event: e
		});
	}, t.prototype.resize = function() {
		this._hovered = new Dn(0, 0);
	}, t.prototype.dispatch = function(e, t) {
		var n = this[e];
		n && n.call(this, t);
	}, t.prototype.dispose = function() {
		this.proxy.dispose(), this.storage = null, this.proxy = null, this.painter = null;
	}, t.prototype.setCursorStyle = function(e) {
		var t = this.proxy;
		t.setCursor && t.setCursor(e);
	}, t.prototype.dispatchToElement = function(e, t, n) {
		e ||= {};
		var r = e.target;
		if (!(r && r.silent)) {
			for (var i = "on" + t, a = wn(t, e, n); r && (r[i] && (a.cancelBubble = !!r[i].call(r, a)), r.trigger(t, a), r = r.__hostTarget ? r.__hostTarget : r.parent, !a.cancelBubble););
			a.cancelBubble || (this.trigger(t, a), this.painter && this.painter.eachOtherLayer && this.painter.eachOtherLayer(function(e) {
				typeof e[i] == "function" && e[i].call(e, a), e.trigger && e.trigger(t, a);
			}));
		}
	}, t.prototype.findHover = function(e, t, n) {
		var r = this.storage.getDisplayList(), i = new Dn(e, t);
		if (Mn(r, i, e, t, n), this._pointerSize && !i.target) {
			for (var a = [], o = this._pointerSize, s = o / 2, c = new Y(e - s, t - s, o, o), l = r.length - 1; l >= 0; l--) {
				var u = r[l];
				u !== n && !u.ignore && !u.ignoreCoarsePointer && (!u.parent || !u.parent.ignoreCoarsePointer) && (kn.copy(u.getBoundingRect()), u.transform && kn.applyTransform(u.transform), kn.intersect(c) && a.push(u));
			}
			if (a.length) {
				for (var d = 4, f = Math.PI / 12, p = Math.PI * 2, m = 0; m < s; m += d) for (var h = 0; h < p; h += f) if (Mn(a, i, e + m * Math.cos(h), t + m * Math.sin(h), n), i.target) return i;
			}
		}
		return i;
	}, t.prototype.processGesture = function(e, t) {
		this._gestureMgr ||= new Rt();
		var n = this._gestureMgr;
		t === "start" && n.clear();
		var r = n.recognize(e, this.findHover(e.zrX, e.zrY, null).target, this.proxy.dom);
		if (t === "end" && n.clear(), r) {
			var i = r.type;
			e.gestureEvent = i;
			var a = new Dn();
			a.target = r.target, this.dispatchToElement(a, i, r.event);
		}
	}, t;
}(dt);
I([
	"click",
	"mousedown",
	"mouseup",
	"mousewheel",
	"dblclick",
	"contextmenu"
], function(e) {
	An.prototype[e] = function(t) {
		var n = t.zrX, r = t.zrY, i = Nn(this, n, r), a, o;
		if ((e !== "mouseup" || !i) && (a = this.findHover(n, r), o = a.target), e === "mousedown") this._downEl = o, this._downPoint = [t.zrX, t.zrY], this._upEl = o;
		else if (e === "mouseup") this._upEl = o;
		else if (e === "click") {
			if (this._downEl !== this._upEl || !this._downPoint || tt(this._downPoint, [t.zrX, t.zrY]) > 4) return;
			this._downPoint = null;
		}
		this.dispatchToElement(a, e, t);
	};
});
function jn(e, t, n) {
	if (e[e.rectHover ? "rectContain" : "contain"](t, n)) {
		for (var r = e, i = void 0, a = !1; r;) {
			if (r.ignoreClip && (a = !0), !a) {
				var o = r.getClipPath();
				if (o && !o.contain(t, n)) return !1;
			}
			r.silent && (i = !0);
			var s = r.__hostTarget;
			r = s ? r.ignoreHostSilent ? null : s : r.parent;
		}
		return !i || Cn;
	}
	return !1;
}
function Mn(e, t, n, r, i) {
	for (var a = e.length - 1; a >= 0; a--) {
		var o = e[a], s = void 0;
		if (o !== i && !o.ignore && (s = jn(o, n, r)) && (!t.topTarget && (t.topTarget = o), s !== Cn)) {
			t.target = o;
			break;
		}
	}
}
function Nn(e, t, n) {
	var r = e.painter;
	return t < 0 || t > r.getWidth() || n < 0 || n > r.getHeight();
}
//#endregion
//#region node_modules/zrender/lib/core/timsort.js
var Pn = 32, Fn = 7;
function In(e) {
	for (var t = 0; e >= Pn;) t |= e & 1, e >>= 1;
	return e + t;
}
function Ln(e, t, n, r) {
	var i = t + 1;
	if (i === n) return 1;
	if (r(e[i++], e[t]) < 0) {
		for (; i < n && r(e[i], e[i - 1]) < 0;) i++;
		Rn(e, t, i);
	} else for (; i < n && r(e[i], e[i - 1]) >= 0;) i++;
	return i - t;
}
function Rn(e, t, n) {
	for (n--; t < n;) {
		var r = e[t];
		e[t++] = e[n], e[n--] = r;
	}
}
function zn(e, t, n, r, i) {
	for (r === t && r++; r < n; r++) {
		for (var a = e[r], o = t, s = r, c; o < s;) c = o + s >>> 1, i(a, e[c]) < 0 ? s = c : o = c + 1;
		var l = r - o;
		switch (l) {
			case 3: e[o + 3] = e[o + 2];
			case 2: e[o + 2] = e[o + 1];
			case 1:
				e[o + 1] = e[o];
				break;
			default: for (; l > 0;) e[o + l] = e[o + l - 1], l--;
		}
		e[o] = a;
	}
}
function Bn(e, t, n, r, i, a) {
	var o = 0, s = 0, c = 1;
	if (a(e, t[n + i]) > 0) {
		for (s = r - i; c < s && a(e, t[n + i + c]) > 0;) o = c, c = (c << 1) + 1, c <= 0 && (c = s);
		c > s && (c = s), o += i, c += i;
	} else {
		for (s = i + 1; c < s && a(e, t[n + i - c]) <= 0;) o = c, c = (c << 1) + 1, c <= 0 && (c = s);
		c > s && (c = s);
		var l = o;
		o = i - c, c = i - l;
	}
	for (o++; o < c;) {
		var u = o + (c - o >>> 1);
		a(e, t[n + u]) > 0 ? o = u + 1 : c = u;
	}
	return c;
}
function Vn(e, t, n, r, i, a) {
	var o = 0, s = 0, c = 1;
	if (a(e, t[n + i]) < 0) {
		for (s = i + 1; c < s && a(e, t[n + i - c]) < 0;) o = c, c = (c << 1) + 1, c <= 0 && (c = s);
		c > s && (c = s);
		var l = o;
		o = i - c, c = i - l;
	} else {
		for (s = r - i; c < s && a(e, t[n + i + c]) >= 0;) o = c, c = (c << 1) + 1, c <= 0 && (c = s);
		c > s && (c = s), o += i, c += i;
	}
	for (o++; o < c;) {
		var u = o + (c - o >>> 1);
		a(e, t[n + u]) < 0 ? c = u : o = u + 1;
	}
	return c;
}
function Hn(e, t) {
	var n = Fn, r, i, a = 0, o = [];
	r = [], i = [];
	function s(e, t) {
		r[a] = e, i[a] = t, a += 1;
	}
	function c() {
		for (; a > 1;) {
			var e = a - 2;
			if (e >= 1 && i[e - 1] <= i[e] + i[e + 1] || e >= 2 && i[e - 2] <= i[e] + i[e - 1]) i[e - 1] < i[e + 1] && e--;
			else if (i[e] > i[e + 1]) break;
			u(e);
		}
	}
	function l() {
		for (; a > 1;) {
			var e = a - 2;
			e > 0 && i[e - 1] < i[e + 1] && e--, u(e);
		}
	}
	function u(n) {
		var o = r[n], s = i[n], c = r[n + 1], l = i[n + 1];
		i[n] = s + l, n === a - 3 && (r[n + 1] = r[n + 2], i[n + 1] = i[n + 2]), a--;
		var u = Vn(e[c], e, o, s, 0, t);
		o += u, s -= u, s !== 0 && (l = Bn(e[o + s - 1], e, c, l, l - 1, t), l !== 0 && (s <= l ? d(o, s, c, l) : f(o, s, c, l)));
	}
	function d(r, i, a, s) {
		var c = 0;
		for (c = 0; c < i; c++) o[c] = e[r + c];
		var l = 0, u = a, d = r;
		if (e[d++] = e[u++], --s === 0) for (c = 0; c < i; c++) e[d + c] = o[l + c];
		else if (i === 1) {
			for (c = 0; c < s; c++) e[d + c] = e[u + c];
			e[d + s] = o[l];
		} else {
			for (var f = n, p, m, h;;) {
				p = 0, m = 0, h = !1;
				do
					if (t(e[u], o[l]) < 0) {
						if (e[d++] = e[u++], m++, p = 0, --s === 0) {
							h = !0;
							break;
						}
					} else if (e[d++] = o[l++], p++, m = 0, --i === 1) {
						h = !0;
						break;
					}
				while ((p | m) < f);
				if (h) break;
				do {
					if (p = Vn(e[u], o, l, i, 0, t), p !== 0) {
						for (c = 0; c < p; c++) e[d + c] = o[l + c];
						if (d += p, l += p, i -= p, i <= 1) {
							h = !0;
							break;
						}
					}
					if (e[d++] = e[u++], --s === 0) {
						h = !0;
						break;
					}
					if (m = Bn(o[l], e, u, s, 0, t), m !== 0) {
						for (c = 0; c < m; c++) e[d + c] = e[u + c];
						if (d += m, u += m, s -= m, s === 0) {
							h = !0;
							break;
						}
					}
					if (e[d++] = o[l++], --i === 1) {
						h = !0;
						break;
					}
					f--;
				} while (p >= Fn || m >= Fn);
				if (h) break;
				f < 0 && (f = 0), f += 2;
			}
			if (n = f, n < 1 && (n = 1), i === 1) {
				for (c = 0; c < s; c++) e[d + c] = e[u + c];
				e[d + s] = o[l];
			} else if (i === 0) throw Error();
			else for (c = 0; c < i; c++) e[d + c] = o[l + c];
		}
	}
	function f(r, i, a, s) {
		var c = 0;
		for (c = 0; c < s; c++) o[c] = e[a + c];
		var l = r + i - 1, u = s - 1, d = a + s - 1, f = 0, p = 0;
		if (e[d--] = e[l--], --i === 0) for (f = d - (s - 1), c = 0; c < s; c++) e[f + c] = o[c];
		else if (s === 1) {
			for (d -= i, l -= i, p = d + 1, f = l + 1, c = i - 1; c >= 0; c--) e[p + c] = e[f + c];
			e[d] = o[u];
		} else {
			for (var m = n;;) {
				var h = 0, g = 0, _ = !1;
				do
					if (t(o[u], e[l]) < 0) {
						if (e[d--] = e[l--], h++, g = 0, --i === 0) {
							_ = !0;
							break;
						}
					} else if (e[d--] = o[u--], g++, h = 0, --s === 1) {
						_ = !0;
						break;
					}
				while ((h | g) < m);
				if (_) break;
				do {
					if (h = i - Vn(o[u], e, r, i, i - 1, t), h !== 0) {
						for (d -= h, l -= h, i -= h, p = d + 1, f = l + 1, c = h - 1; c >= 0; c--) e[p + c] = e[f + c];
						if (i === 0) {
							_ = !0;
							break;
						}
					}
					if (e[d--] = o[u--], --s === 1) {
						_ = !0;
						break;
					}
					if (g = s - Bn(e[l], o, 0, s, s - 1, t), g !== 0) {
						for (d -= g, u -= g, s -= g, p = d + 1, f = u + 1, c = 0; c < g; c++) e[p + c] = o[f + c];
						if (s <= 1) {
							_ = !0;
							break;
						}
					}
					if (e[d--] = e[l--], --i === 0) {
						_ = !0;
						break;
					}
					m--;
				} while (h >= Fn || g >= Fn);
				if (_) break;
				m < 0 && (m = 0), m += 2;
			}
			if (n = m, n < 1 && (n = 1), s === 1) {
				for (d -= i, l -= i, p = d + 1, f = l + 1, c = i - 1; c >= 0; c--) e[p + c] = e[f + c];
				e[d] = o[u];
			} else if (s === 0) throw Error();
			else for (f = d - (s - 1), c = 0; c < s; c++) e[f + c] = o[c];
		}
	}
	return {
		mergeRuns: c,
		forceMergeRuns: l,
		pushRun: s
	};
}
function Un(e, t, n, r) {
	n ||= 0, r ||= e.length;
	var i = r - n;
	if (!(i < 2)) {
		var a = 0;
		if (i < Pn) a = Ln(e, n, r, t), zn(e, n, r, n + a, t);
		else {
			var o = Hn(e, t), s = In(i);
			do {
				if (a = Ln(e, n, r, t), a < s) {
					var c = i;
					c > s && (c = s), zn(e, n, n + c, n + a, t), a = c;
				}
				o.pushRun(n, a), o.mergeRuns(), i -= a, n += a;
			} while (i !== 0);
			o.forceMergeRuns();
		}
	}
}
//#endregion
//#region node_modules/zrender/lib/Storage.js
var Wn = !1;
function Gn() {
	Wn || (Wn = !0, console.warn("z / z2 / zlevel of displayable is invalid, which may cause unexpected errors"));
}
function Kn(e, t) {
	return e.zlevel === t.zlevel ? e.z === t.z ? e.z2 - t.z2 : e.z - t.z : e.zlevel - t.zlevel;
}
var qn = function() {
	function e() {
		this._roots = [], this._displayList = [], this._displayListLen = 0, this.displayableSortFunc = Kn;
	}
	return e.prototype.traverse = function(e, t) {
		for (var n = 0; n < this._roots.length; n++) this._roots[n].traverse(e, t);
	}, e.prototype.getDisplayList = function(e, t) {
		t ||= !1;
		var n = this._displayList;
		return (e || !n.length) && this.updateDisplayList(t), n;
	}, e.prototype.updateDisplayList = function(e) {
		this._displayListLen = 0;
		for (var t = this._roots, n = this._displayList, r = 0, i = t.length; r < i; r++) this._updateAndAddDisplayable(t[r], null, e);
		n.length = this._displayListLen, Un(n, Kn);
	}, e.prototype._updateAndAddDisplayable = function(e, t, n) {
		if (!e.ignore || n) {
			e.beforeUpdate(), e.update(), e.afterUpdate();
			var r = e.getClipPath(), i = t && t.length, a = 0, o = e.__clipPaths;
			if (!e.ignoreClip && (i || r)) {
				if (o ||= e.__clipPaths = [], i) for (var s = 0; s < t.length; s++) o[a++] = t[s];
				for (var c = r, l = e; c;) c.parent = l, c.updateTransform(), o[a++] = c, l = c, c = c.getClipPath();
			}
			if (o && (o.length = a), e.childrenRef) {
				for (var u = e.childrenRef(), d = 0; d < u.length; d++) {
					var f = u[d];
					e.__dirty && (f.__dirty |= 1), this._updateAndAddDisplayable(f, o, n);
				}
				e.__dirty = 0;
			} else {
				var p = e;
				isNaN(p.z) && (Gn(), p.z = 0), isNaN(p.z2) && (Gn(), p.z2 = 0), isNaN(p.zlevel) && (Gn(), p.zlevel = 0), this._displayList[this._displayListLen++] = p;
			}
			var m = e.getDecalElement && e.getDecalElement();
			m && this._updateAndAddDisplayable(m, o, n);
			var h = e.getTextGuideLine();
			h && this._updateAndAddDisplayable(h, o, n);
			var g = e.getTextContent();
			g && this._updateAndAddDisplayable(g, o, n);
		}
	}, e.prototype.addRoot = function(e) {
		e.__zr && e.__zr.storage === this || this._roots.push(e);
	}, e.prototype.delRoot = function(e) {
		if (e instanceof Array) for (var t = 0, n = e.length; t < n; t++) this.delRoot(e[t]);
		else {
			var r = P(this._roots, e);
			r >= 0 && this._roots.splice(r, 1);
		}
	}, e.prototype.delAllRoots = function() {
		this._roots = [], this._displayList = [], this._displayListLen = 0;
	}, e.prototype.getRoots = function() {
		return this._roots;
	}, e.prototype.dispose = function() {
		this._displayList = null, this._roots = null;
	}, e;
}(), Jn = i.hasGlobalWindow && (window.requestAnimationFrame && window.requestAnimationFrame.bind(window) || window.msRequestAnimationFrame && window.msRequestAnimationFrame.bind(window) || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame) || function(e) {
	return setTimeout(e, 16);
}, Yn = {
	linear: function(e) {
		return e;
	},
	quadraticIn: function(e) {
		return e * e;
	},
	quadraticOut: function(e) {
		return e * (2 - e);
	},
	quadraticInOut: function(e) {
		return (e *= 2) < 1 ? .5 * e * e : -.5 * (--e * (e - 2) - 1);
	},
	cubicIn: function(e) {
		return e * e * e;
	},
	cubicOut: function(e) {
		return --e * e * e + 1;
	},
	cubicInOut: function(e) {
		return (e *= 2) < 1 ? .5 * e * e * e : .5 * ((e -= 2) * e * e + 2);
	},
	quarticIn: function(e) {
		return e * e * e * e;
	},
	quarticOut: function(e) {
		return 1 - --e * e * e * e;
	},
	quarticInOut: function(e) {
		return (e *= 2) < 1 ? .5 * e * e * e * e : -.5 * ((e -= 2) * e * e * e - 2);
	},
	quinticIn: function(e) {
		return e * e * e * e * e;
	},
	quinticOut: function(e) {
		return --e * e * e * e * e + 1;
	},
	quinticInOut: function(e) {
		return (e *= 2) < 1 ? .5 * e * e * e * e * e : .5 * ((e -= 2) * e * e * e * e + 2);
	},
	sinusoidalIn: function(e) {
		return 1 - Math.cos(e * Math.PI / 2);
	},
	sinusoidalOut: function(e) {
		return Math.sin(e * Math.PI / 2);
	},
	sinusoidalInOut: function(e) {
		return .5 * (1 - Math.cos(Math.PI * e));
	},
	exponentialIn: function(e) {
		return e === 0 ? 0 : 1024 ** (e - 1);
	},
	exponentialOut: function(e) {
		return e === 1 ? 1 : 1 - 2 ** (-10 * e);
	},
	exponentialInOut: function(e) {
		return e === 0 ? 0 : e === 1 ? 1 : (e *= 2) < 1 ? .5 * 1024 ** (e - 1) : .5 * (-(2 ** (-10 * (e - 1))) + 2);
	},
	circularIn: function(e) {
		return 1 - Math.sqrt(1 - e * e);
	},
	circularOut: function(e) {
		return Math.sqrt(1 - --e * e);
	},
	circularInOut: function(e) {
		return (e *= 2) < 1 ? -.5 * (Math.sqrt(1 - e * e) - 1) : .5 * (Math.sqrt(1 - (e -= 2) * e) + 1);
	},
	elasticIn: function(e) {
		var t, n = .1, r = .4;
		return e === 0 ? 0 : e === 1 ? 1 : (!n || n < 1 ? (n = 1, t = r / 4) : t = r * Math.asin(1 / n) / (2 * Math.PI), -(n * 2 ** (10 * --e) * Math.sin((e - t) * (2 * Math.PI) / r)));
	},
	elasticOut: function(e) {
		var t, n = .1, r = .4;
		return e === 0 ? 0 : e === 1 ? 1 : (!n || n < 1 ? (n = 1, t = r / 4) : t = r * Math.asin(1 / n) / (2 * Math.PI), n * 2 ** (-10 * e) * Math.sin((e - t) * (2 * Math.PI) / r) + 1);
	},
	elasticInOut: function(e) {
		var t, n = .1, r = .4;
		return e === 0 ? 0 : e === 1 ? 1 : (!n || n < 1 ? (n = 1, t = r / 4) : t = r * Math.asin(1 / n) / (2 * Math.PI), (e *= 2) < 1 ? -.5 * (n * 2 ** (10 * --e) * Math.sin((e - t) * (2 * Math.PI) / r)) : n * 2 ** (-10 * --e) * Math.sin((e - t) * (2 * Math.PI) / r) * .5 + 1);
	},
	backIn: function(e) {
		var t = 1.70158;
		return e * e * ((t + 1) * e - t);
	},
	backOut: function(e) {
		var t = 1.70158;
		return --e * e * ((t + 1) * e + t) + 1;
	},
	backInOut: function(e) {
		var t = 2.5949095;
		return (e *= 2) < 1 ? .5 * (e * e * ((t + 1) * e - t)) : .5 * ((e -= 2) * e * ((t + 1) * e + t) + 2);
	},
	bounceIn: function(e) {
		return 1 - Yn.bounceOut(1 - e);
	},
	bounceOut: function(e) {
		return e < 1 / 2.75 ? 7.5625 * e * e : e < 2 / 2.75 ? 7.5625 * (e -= 1.5 / 2.75) * e + .75 : e < 2.5 / 2.75 ? 7.5625 * (e -= 2.25 / 2.75) * e + .9375 : 7.5625 * (e -= 2.625 / 2.75) * e + .984375;
	},
	bounceInOut: function(e) {
		return e < .5 ? Yn.bounceIn(e * 2) * .5 : Yn.bounceOut(e * 2 - 1) * .5 + .5;
	}
}, Xn = Math.pow, Zn = Math.sqrt, Qn = 1e-8, $n = 1e-4, er = Zn(3), tr = 1 / 3, nr = Re(), rr = Re(), ir = Re();
function ar(e) {
	return e > -Qn && e < Qn;
}
function or(e) {
	return e > Qn || e < -Qn;
}
function sr(e, t, n, r, i) {
	var a = 1 - i;
	return a * a * (a * e + 3 * i * t) + i * i * (i * r + 3 * a * n);
}
function cr(e, t, n, r, i) {
	var a = 1 - i;
	return 3 * (((t - e) * a + 2 * (n - t) * i) * a + (r - n) * i * i);
}
function lr(e, t, n, r, i, a) {
	var o = r + 3 * (t - n) - e, s = 3 * (n - t * 2 + e), c = 3 * (t - e), l = e - i, u = s * s - 3 * o * c, d = s * c - 9 * o * l, f = c * c - 3 * s * l, p = 0;
	if (ar(u) && ar(d)) {
		if (ar(s)) a[0] = 0;
		else {
			var m = -c / s;
			m >= 0 && m <= 1 && (a[p++] = m);
		}
	} else {
		var h = d * d - 4 * u * f;
		if (ar(h)) {
			var g = d / u, m = -s / o + g, _ = -g / 2;
			m >= 0 && m <= 1 && (a[p++] = m), _ >= 0 && _ <= 1 && (a[p++] = _);
		} else if (h > 0) {
			var v = Zn(h), y = u * s + 1.5 * o * (-d + v), b = u * s + 1.5 * o * (-d - v);
			y = y < 0 ? -Xn(-y, tr) : Xn(y, tr), b = b < 0 ? -Xn(-b, tr) : Xn(b, tr);
			var m = (-s - (y + b)) / (3 * o);
			m >= 0 && m <= 1 && (a[p++] = m);
		} else {
			var x = (2 * u * s - 3 * o * d) / (2 * Zn(u * u * u)), S = Math.acos(x) / 3, C = Zn(u), w = Math.cos(S), m = (-s - 2 * C * w) / (3 * o), _ = (-s + C * (w + er * Math.sin(S))) / (3 * o), T = (-s + C * (w - er * Math.sin(S))) / (3 * o);
			m >= 0 && m <= 1 && (a[p++] = m), _ >= 0 && _ <= 1 && (a[p++] = _), T >= 0 && T <= 1 && (a[p++] = T);
		}
	}
	return p;
}
function ur(e, t, n, r, i) {
	var a = 6 * n - 12 * t + 6 * e, o = 9 * t + 3 * r - 3 * e - 9 * n, s = 3 * t - 3 * e, c = 0;
	if (ar(o)) {
		if (or(a)) {
			var l = -s / a;
			l >= 0 && l <= 1 && (i[c++] = l);
		}
	} else {
		var u = a * a - 4 * o * s;
		if (ar(u)) i[0] = -a / (2 * o);
		else if (u > 0) {
			var d = Zn(u), l = (-a + d) / (2 * o), f = (-a - d) / (2 * o);
			l >= 0 && l <= 1 && (i[c++] = l), f >= 0 && f <= 1 && (i[c++] = f);
		}
	}
	return c;
}
function dr(e, t, n, r, i, a) {
	var o = (t - e) * i + e, s = (n - t) * i + t, c = (r - n) * i + n, l = (s - o) * i + o, u = (c - s) * i + s, d = (u - l) * i + l;
	a[0] = e, a[1] = o, a[2] = l, a[3] = d, a[4] = d, a[5] = u, a[6] = c, a[7] = r;
}
function fr(e, t, n, r, i, a, o, s, c, l, u) {
	var d, f = .005, p = Infinity, m, h, g, _;
	nr[0] = c, nr[1] = l;
	for (var v = 0; v < 1; v += .05) rr[0] = sr(e, n, i, o, v), rr[1] = sr(t, r, a, s, v), g = rt(nr, rr), g < p && (d = v, p = g);
	p = Infinity;
	for (var y = 0; y < 32 && !(f < $n); y++) m = d - f, h = d + f, rr[0] = sr(e, n, i, o, m), rr[1] = sr(t, r, a, s, m), g = rt(rr, nr), m >= 0 && g < p ? (d = m, p = g) : (ir[0] = sr(e, n, i, o, h), ir[1] = sr(t, r, a, s, h), _ = rt(ir, nr), h <= 1 && _ < p ? (d = h, p = _) : f *= .5);
	return u && (u[0] = sr(e, n, i, o, d), u[1] = sr(t, r, a, s, d)), Zn(p);
}
function pr(e, t, n, r, i, a, o, s, c) {
	for (var l = e, u = t, d = 0, f = 1 / c, p = 1; p <= c; p++) {
		var m = p * f, h = sr(e, n, i, o, m), g = sr(t, r, a, s, m), _ = h - l, v = g - u;
		d += Math.sqrt(_ * _ + v * v), l = h, u = g;
	}
	return d;
}
function mr(e, t, n, r) {
	var i = 1 - r;
	return i * (i * e + 2 * r * t) + r * r * n;
}
function hr(e, t, n, r) {
	return 2 * ((1 - r) * (t - e) + r * (n - t));
}
function gr(e, t, n, r, i) {
	var a = e - 2 * t + n, o = 2 * (t - e), s = e - r, c = 0;
	if (ar(a)) {
		if (or(o)) {
			var l = -s / o;
			l >= 0 && l <= 1 && (i[c++] = l);
		}
	} else {
		var u = o * o - 4 * a * s;
		if (ar(u)) {
			var l = -o / (2 * a);
			l >= 0 && l <= 1 && (i[c++] = l);
		} else if (u > 0) {
			var d = Zn(u), l = (-o + d) / (2 * a), f = (-o - d) / (2 * a);
			l >= 0 && l <= 1 && (i[c++] = l), f >= 0 && f <= 1 && (i[c++] = f);
		}
	}
	return c;
}
function _r(e, t, n) {
	var r = e + n - 2 * t;
	return r === 0 ? .5 : (e - t) / r;
}
function vr(e, t, n, r, i) {
	var a = (t - e) * r + e, o = (n - t) * r + t, s = (o - a) * r + a;
	i[0] = e, i[1] = a, i[2] = s, i[3] = s, i[4] = o, i[5] = n;
}
function yr(e, t, n, r, i, a, o, s, c) {
	var l, u = .005, d = Infinity;
	nr[0] = o, nr[1] = s;
	for (var f = 0; f < 1; f += .05) {
		rr[0] = mr(e, n, i, f), rr[1] = mr(t, r, a, f);
		var p = rt(nr, rr);
		p < d && (l = f, d = p);
	}
	d = Infinity;
	for (var m = 0; m < 32 && !(u < $n); m++) {
		var h = l - u, g = l + u;
		rr[0] = mr(e, n, i, h), rr[1] = mr(t, r, a, h);
		var p = rt(rr, nr);
		if (h >= 0 && p < d) l = h, d = p;
		else {
			ir[0] = mr(e, n, i, g), ir[1] = mr(t, r, a, g);
			var _ = rt(ir, nr);
			g <= 1 && _ < d ? (l = g, d = _) : u *= .5;
		}
	}
	return c && (c[0] = mr(e, n, i, l), c[1] = mr(t, r, a, l)), Zn(d);
}
function br(e, t, n, r, i, a, o) {
	for (var s = e, c = t, l = 0, u = 1 / o, d = 1; d <= o; d++) {
		var f = d * u, p = mr(e, n, i, f), m = mr(t, r, a, f), h = p - s, g = m - c;
		l += Math.sqrt(h * h + g * g), s = p, c = m;
	}
	return l;
}
//#endregion
//#region node_modules/zrender/lib/animation/cubicEasing.js
var xr = /cubic-bezier\(([0-9,\.e ]+)\)/;
function Sr(e) {
	var t = e && xr.exec(e);
	if (t) {
		var n = t[1].split(","), r = +Ce(n[0]), i = +Ce(n[1]), a = +Ce(n[2]), o = +Ce(n[3]);
		if (isNaN(r + i + a + o)) return;
		var s = [];
		return function(e) {
			return e <= 0 ? 0 : e >= 1 ? 1 : lr(0, r, a, 1, e, s) && sr(0, i, o, 1, s[0]);
		};
	}
}
//#endregion
//#region node_modules/zrender/lib/animation/Clip.js
var Cr = function() {
	function e(e) {
		this._inited = !1, this._startTime = 0, this._pausedTime = 0, this._paused = !1, this._life = e.life || 1e3, this._delay = e.delay || 0, this.loop = e.loop || !1, this.onframe = e.onframe || Pe, this.ondestroy = e.ondestroy || Pe, this.onrestart = e.onrestart || Pe, e.easing && this.setEasing(e.easing);
	}
	return e.prototype.step = function(e, t) {
		if (this._inited ||= (this._startTime = e + this._delay, !0), this._paused) this._pausedTime += t;
		else {
			var n = this._life, r = e - this._startTime - this._pausedTime, i = r / n;
			i < 0 && (i = 0), i = Math.min(i, 1);
			var a = this.easingFunc, o = a ? a(i) : i;
			if (this.onframe(o), i === 1) {
				if (this.loop) {
					var s = r % n;
					this._startTime = e - s, this._pausedTime = 0, this.onrestart();
				} else return !0;
			}
			return !1;
		}
	}, e.prototype.pause = function() {
		this._paused = !0;
	}, e.prototype.resume = function() {
		this._paused = !1;
	}, e.prototype.setEasing = function(e) {
		this.easing = e, this.easingFunc = H(e) ? e : Yn[e] || Sr(e);
	}, e;
}(), wr = function() {
	function e(e) {
		this.value = e;
	}
	return e;
}(), Tr = function() {
	function e() {
		this._len = 0;
	}
	return e.prototype.insert = function(e) {
		var t = new wr(e);
		return this.insertEntry(t), t;
	}, e.prototype.insertEntry = function(e) {
		this.head ? (this.tail.next = e, e.prev = this.tail, e.next = null, this.tail = e) : this.head = this.tail = e, this._len++;
	}, e.prototype.remove = function(e) {
		var t = e.prev, n = e.next;
		t ? t.next = n : this.head = n, n ? n.prev = t : this.tail = t, e.next = e.prev = null, this._len--;
	}, e.prototype.len = function() {
		return this._len;
	}, e.prototype.clear = function() {
		this.head = this.tail = null, this._len = 0;
	}, e;
}(), Er = function() {
	function e(e) {
		this._list = new Tr(), this._maxSize = 10, this._map = {}, this._maxSize = e;
	}
	return e.prototype.put = function(e, t) {
		var n = this._list, r = this._map, i = null;
		if (r[e] == null) {
			var a = n.len(), o = this._lastRemovedEntry;
			if (a >= this._maxSize && a > 0) {
				var s = n.head;
				n.remove(s), delete r[s.key], i = s.value, this._lastRemovedEntry = s;
			}
			o ? o.value = t : o = new wr(t), o.key = e, n.insertEntry(o), r[e] = o;
		}
		return i;
	}, e.prototype.get = function(e) {
		var t = this._map[e], n = this._list;
		if (t != null) return t !== n.tail && (n.remove(t), n.insertEntry(t)), t.value;
	}, e.prototype.clear = function() {
		this._list.clear(), this._map = {};
	}, e.prototype.len = function() {
		return this._list.len();
	}, e;
}(), Dr = /* @__PURE__ */ e({
	fastLerp: () => Kr,
	fastMapToColor: () => qr,
	lerp: () => Jr,
	lift: () => Wr,
	liftColor: () => ni,
	lum: () => $r,
	mapToColor: () => Yr,
	modifyAlpha: () => Zr,
	modifyHSL: () => Xr,
	parse: () => Vr,
	parseCssFloat: () => Nr,
	parseCssInt: () => Mr,
	random: () => ei,
	stringify: () => Qr,
	toHex: () => Gr
}), Or = {
	transparent: [
		0,
		0,
		0,
		0
	],
	aliceblue: [
		240,
		248,
		255,
		1
	],
	antiquewhite: [
		250,
		235,
		215,
		1
	],
	aqua: [
		0,
		255,
		255,
		1
	],
	aquamarine: [
		127,
		255,
		212,
		1
	],
	azure: [
		240,
		255,
		255,
		1
	],
	beige: [
		245,
		245,
		220,
		1
	],
	bisque: [
		255,
		228,
		196,
		1
	],
	black: [
		0,
		0,
		0,
		1
	],
	blanchedalmond: [
		255,
		235,
		205,
		1
	],
	blue: [
		0,
		0,
		255,
		1
	],
	blueviolet: [
		138,
		43,
		226,
		1
	],
	brown: [
		165,
		42,
		42,
		1
	],
	burlywood: [
		222,
		184,
		135,
		1
	],
	cadetblue: [
		95,
		158,
		160,
		1
	],
	chartreuse: [
		127,
		255,
		0,
		1
	],
	chocolate: [
		210,
		105,
		30,
		1
	],
	coral: [
		255,
		127,
		80,
		1
	],
	cornflowerblue: [
		100,
		149,
		237,
		1
	],
	cornsilk: [
		255,
		248,
		220,
		1
	],
	crimson: [
		220,
		20,
		60,
		1
	],
	cyan: [
		0,
		255,
		255,
		1
	],
	darkblue: [
		0,
		0,
		139,
		1
	],
	darkcyan: [
		0,
		139,
		139,
		1
	],
	darkgoldenrod: [
		184,
		134,
		11,
		1
	],
	darkgray: [
		169,
		169,
		169,
		1
	],
	darkgreen: [
		0,
		100,
		0,
		1
	],
	darkgrey: [
		169,
		169,
		169,
		1
	],
	darkkhaki: [
		189,
		183,
		107,
		1
	],
	darkmagenta: [
		139,
		0,
		139,
		1
	],
	darkolivegreen: [
		85,
		107,
		47,
		1
	],
	darkorange: [
		255,
		140,
		0,
		1
	],
	darkorchid: [
		153,
		50,
		204,
		1
	],
	darkred: [
		139,
		0,
		0,
		1
	],
	darksalmon: [
		233,
		150,
		122,
		1
	],
	darkseagreen: [
		143,
		188,
		143,
		1
	],
	darkslateblue: [
		72,
		61,
		139,
		1
	],
	darkslategray: [
		47,
		79,
		79,
		1
	],
	darkslategrey: [
		47,
		79,
		79,
		1
	],
	darkturquoise: [
		0,
		206,
		209,
		1
	],
	darkviolet: [
		148,
		0,
		211,
		1
	],
	deeppink: [
		255,
		20,
		147,
		1
	],
	deepskyblue: [
		0,
		191,
		255,
		1
	],
	dimgray: [
		105,
		105,
		105,
		1
	],
	dimgrey: [
		105,
		105,
		105,
		1
	],
	dodgerblue: [
		30,
		144,
		255,
		1
	],
	firebrick: [
		178,
		34,
		34,
		1
	],
	floralwhite: [
		255,
		250,
		240,
		1
	],
	forestgreen: [
		34,
		139,
		34,
		1
	],
	fuchsia: [
		255,
		0,
		255,
		1
	],
	gainsboro: [
		220,
		220,
		220,
		1
	],
	ghostwhite: [
		248,
		248,
		255,
		1
	],
	gold: [
		255,
		215,
		0,
		1
	],
	goldenrod: [
		218,
		165,
		32,
		1
	],
	gray: [
		128,
		128,
		128,
		1
	],
	green: [
		0,
		128,
		0,
		1
	],
	greenyellow: [
		173,
		255,
		47,
		1
	],
	grey: [
		128,
		128,
		128,
		1
	],
	honeydew: [
		240,
		255,
		240,
		1
	],
	hotpink: [
		255,
		105,
		180,
		1
	],
	indianred: [
		205,
		92,
		92,
		1
	],
	indigo: [
		75,
		0,
		130,
		1
	],
	ivory: [
		255,
		255,
		240,
		1
	],
	khaki: [
		240,
		230,
		140,
		1
	],
	lavender: [
		230,
		230,
		250,
		1
	],
	lavenderblush: [
		255,
		240,
		245,
		1
	],
	lawngreen: [
		124,
		252,
		0,
		1
	],
	lemonchiffon: [
		255,
		250,
		205,
		1
	],
	lightblue: [
		173,
		216,
		230,
		1
	],
	lightcoral: [
		240,
		128,
		128,
		1
	],
	lightcyan: [
		224,
		255,
		255,
		1
	],
	lightgoldenrodyellow: [
		250,
		250,
		210,
		1
	],
	lightgray: [
		211,
		211,
		211,
		1
	],
	lightgreen: [
		144,
		238,
		144,
		1
	],
	lightgrey: [
		211,
		211,
		211,
		1
	],
	lightpink: [
		255,
		182,
		193,
		1
	],
	lightsalmon: [
		255,
		160,
		122,
		1
	],
	lightseagreen: [
		32,
		178,
		170,
		1
	],
	lightskyblue: [
		135,
		206,
		250,
		1
	],
	lightslategray: [
		119,
		136,
		153,
		1
	],
	lightslategrey: [
		119,
		136,
		153,
		1
	],
	lightsteelblue: [
		176,
		196,
		222,
		1
	],
	lightyellow: [
		255,
		255,
		224,
		1
	],
	lime: [
		0,
		255,
		0,
		1
	],
	limegreen: [
		50,
		205,
		50,
		1
	],
	linen: [
		250,
		240,
		230,
		1
	],
	magenta: [
		255,
		0,
		255,
		1
	],
	maroon: [
		128,
		0,
		0,
		1
	],
	mediumaquamarine: [
		102,
		205,
		170,
		1
	],
	mediumblue: [
		0,
		0,
		205,
		1
	],
	mediumorchid: [
		186,
		85,
		211,
		1
	],
	mediumpurple: [
		147,
		112,
		219,
		1
	],
	mediumseagreen: [
		60,
		179,
		113,
		1
	],
	mediumslateblue: [
		123,
		104,
		238,
		1
	],
	mediumspringgreen: [
		0,
		250,
		154,
		1
	],
	mediumturquoise: [
		72,
		209,
		204,
		1
	],
	mediumvioletred: [
		199,
		21,
		133,
		1
	],
	midnightblue: [
		25,
		25,
		112,
		1
	],
	mintcream: [
		245,
		255,
		250,
		1
	],
	mistyrose: [
		255,
		228,
		225,
		1
	],
	moccasin: [
		255,
		228,
		181,
		1
	],
	navajowhite: [
		255,
		222,
		173,
		1
	],
	navy: [
		0,
		0,
		128,
		1
	],
	oldlace: [
		253,
		245,
		230,
		1
	],
	olive: [
		128,
		128,
		0,
		1
	],
	olivedrab: [
		107,
		142,
		35,
		1
	],
	orange: [
		255,
		165,
		0,
		1
	],
	orangered: [
		255,
		69,
		0,
		1
	],
	orchid: [
		218,
		112,
		214,
		1
	],
	palegoldenrod: [
		238,
		232,
		170,
		1
	],
	palegreen: [
		152,
		251,
		152,
		1
	],
	paleturquoise: [
		175,
		238,
		238,
		1
	],
	palevioletred: [
		219,
		112,
		147,
		1
	],
	papayawhip: [
		255,
		239,
		213,
		1
	],
	peachpuff: [
		255,
		218,
		185,
		1
	],
	peru: [
		205,
		133,
		63,
		1
	],
	pink: [
		255,
		192,
		203,
		1
	],
	plum: [
		221,
		160,
		221,
		1
	],
	powderblue: [
		176,
		224,
		230,
		1
	],
	purple: [
		128,
		0,
		128,
		1
	],
	red: [
		255,
		0,
		0,
		1
	],
	rosybrown: [
		188,
		143,
		143,
		1
	],
	royalblue: [
		65,
		105,
		225,
		1
	],
	saddlebrown: [
		139,
		69,
		19,
		1
	],
	salmon: [
		250,
		128,
		114,
		1
	],
	sandybrown: [
		244,
		164,
		96,
		1
	],
	seagreen: [
		46,
		139,
		87,
		1
	],
	seashell: [
		255,
		245,
		238,
		1
	],
	sienna: [
		160,
		82,
		45,
		1
	],
	silver: [
		192,
		192,
		192,
		1
	],
	skyblue: [
		135,
		206,
		235,
		1
	],
	slateblue: [
		106,
		90,
		205,
		1
	],
	slategray: [
		112,
		128,
		144,
		1
	],
	slategrey: [
		112,
		128,
		144,
		1
	],
	snow: [
		255,
		250,
		250,
		1
	],
	springgreen: [
		0,
		255,
		127,
		1
	],
	steelblue: [
		70,
		130,
		180,
		1
	],
	tan: [
		210,
		180,
		140,
		1
	],
	teal: [
		0,
		128,
		128,
		1
	],
	thistle: [
		216,
		191,
		216,
		1
	],
	tomato: [
		255,
		99,
		71,
		1
	],
	turquoise: [
		64,
		224,
		208,
		1
	],
	violet: [
		238,
		130,
		238,
		1
	],
	wheat: [
		245,
		222,
		179,
		1
	],
	white: [
		255,
		255,
		255,
		1
	],
	whitesmoke: [
		245,
		245,
		245,
		1
	],
	yellow: [
		255,
		255,
		0,
		1
	],
	yellowgreen: [
		154,
		205,
		50,
		1
	]
};
function kr(e) {
	return e = Math.round(e), e < 0 ? 0 : e > 255 ? 255 : e;
}
function Ar(e) {
	return e = Math.round(e), e < 0 ? 0 : e > 360 ? 360 : e;
}
function jr(e) {
	return e < 0 ? 0 : e > 1 ? 1 : e;
}
function Mr(e) {
	var t = e;
	return t.length && t.charAt(t.length - 1) === "%" ? kr(parseFloat(t) / 100 * 255) : kr(parseInt(t, 10));
}
function Nr(e) {
	var t = e;
	return t.length && t.charAt(t.length - 1) === "%" ? jr(parseFloat(t) / 100) : jr(parseFloat(t));
}
function Pr(e, t, n) {
	return n < 0 ? n += 1 : n > 1 && --n, n * 6 < 1 ? e + (t - e) * n * 6 : n * 2 < 1 ? t : n * 3 < 2 ? e + (t - e) * (2 / 3 - n) * 6 : e;
}
function Fr(e, t, n) {
	return e + (t - e) * n;
}
function Ir(e, t, n, r, i) {
	return e[0] = t, e[1] = n, e[2] = r, e[3] = i, e;
}
function Lr(e, t) {
	return e[0] = t[0], e[1] = t[1], e[2] = t[2], e[3] = t[3], e;
}
var Rr = new Er(20), zr = null;
function Br(e, t) {
	zr && Lr(zr, t), zr = Rr.put(e, zr || t.slice());
}
function Vr(e, t) {
	if (e) {
		t ||= [];
		var n = Rr.get(e);
		if (n) return Lr(t, n);
		e += "";
		var r = e.replace(/ /g, "").toLowerCase();
		if (r in Or) return Lr(t, Or[r]), Br(e, t), t;
		var i = r.length;
		if (r.charAt(0) === "#") {
			if (i === 4 || i === 5) {
				var a = parseInt(r.slice(1, 4), 16);
				if (!(a >= 0 && a <= 4095)) {
					Ir(t, 0, 0, 0, 1);
					return;
				}
				return Ir(t, (a & 3840) >> 4 | (a & 3840) >> 8, a & 240 | (a & 240) >> 4, a & 15 | (a & 15) << 4, i === 5 ? parseInt(r.slice(4), 16) / 15 : 1), Br(e, t), t;
			}
			if (i === 7 || i === 9) {
				var a = parseInt(r.slice(1, 7), 16);
				if (!(a >= 0 && a <= 16777215)) {
					Ir(t, 0, 0, 0, 1);
					return;
				}
				return Ir(t, (a & 16711680) >> 16, (a & 65280) >> 8, a & 255, i === 9 ? parseInt(r.slice(7), 16) / 255 : 1), Br(e, t), t;
			}
		} else {
			var o = r.indexOf("("), s = r.indexOf(")");
			if (o !== -1 && s + 1 === i) {
				var c = r.substr(0, o), l = r.substr(o + 1, s - (o + 1)).split(","), u = 1;
				switch (c) {
					case "rgba":
						if (l.length !== 4) return l.length === 3 ? Ir(t, +l[0], +l[1], +l[2], 1) : Ir(t, 0, 0, 0, 1);
						u = Nr(l.pop());
					case "rgb":
						if (l.length >= 3) return Ir(t, Mr(l[0]), Mr(l[1]), Mr(l[2]), l.length === 3 ? u : Nr(l[3])), Br(e, t), t;
						Ir(t, 0, 0, 0, 1);
						return;
					case "hsla":
						if (l.length !== 4) {
							Ir(t, 0, 0, 0, 1);
							return;
						}
						return l[3] = Nr(l[3]), Hr(l, t), Br(e, t), t;
					case "hsl":
						if (l.length !== 3) {
							Ir(t, 0, 0, 0, 1);
							return;
						}
						return Hr(l, t), Br(e, t), t;
					default: return;
				}
			}
			Ir(t, 0, 0, 0, 1);
		}
	}
}
function Hr(e, t) {
	var n = (parseFloat(e[0]) % 360 + 360) % 360 / 360, r = Nr(e[1]), i = Nr(e[2]), a = i <= .5 ? i * (r + 1) : i + r - i * r, o = i * 2 - a;
	return t ||= [], Ir(t, kr(Pr(o, a, n + 1 / 3) * 255), kr(Pr(o, a, n) * 255), kr(Pr(o, a, n - 1 / 3) * 255), 1), e.length === 4 && (t[3] = e[3]), t;
}
function Ur(e) {
	if (e) {
		var t = e[0] / 255, n = e[1] / 255, r = e[2] / 255, i = Math.min(t, n, r), a = Math.max(t, n, r), o = a - i, s = (a + i) / 2, c, l;
		if (o === 0) c = 0, l = 0;
		else {
			l = s < .5 ? o / (a + i) : o / (2 - a - i);
			var u = ((a - t) / 6 + o / 2) / o, d = ((a - n) / 6 + o / 2) / o, f = ((a - r) / 6 + o / 2) / o;
			t === a ? c = f - d : n === a ? c = 1 / 3 + u - f : r === a && (c = 2 / 3 + d - u), c < 0 && (c += 1), c > 1 && --c;
		}
		var p = [
			c * 360,
			l,
			s
		];
		return e[3] != null && p.push(e[3]), p;
	}
}
function Wr(e, t) {
	var n = Vr(e);
	if (n) {
		for (var r = 0; r < 3; r++) t < 0 ? n[r] = n[r] * (1 - t) | 0 : n[r] = (255 - n[r]) * t + n[r] | 0, n[r] > 255 ? n[r] = 255 : n[r] < 0 && (n[r] = 0);
		return Qr(n, n.length === 4 ? "rgba" : "rgb");
	}
}
function Gr(e) {
	var t = Vr(e);
	if (t) return ((1 << 24) + (t[0] << 16) + (t[1] << 8) + +t[2]).toString(16).slice(1);
}
function Kr(e, t, n) {
	if (t && t.length && e >= 0 && e <= 1) {
		n ||= [];
		var r = e * (t.length - 1), i = Math.floor(r), a = Math.ceil(r), o = t[i], s = t[a], c = r - i;
		return n[0] = kr(Fr(o[0], s[0], c)), n[1] = kr(Fr(o[1], s[1], c)), n[2] = kr(Fr(o[2], s[2], c)), n[3] = jr(Fr(o[3], s[3], c)), n;
	}
}
var qr = Kr;
function Jr(e, t, n) {
	if (t && t.length && e >= 0 && e <= 1) {
		var r = e * (t.length - 1), i = Math.floor(r), a = Math.ceil(r), o = Vr(t[i]), s = Vr(t[a]), c = r - i, l = Qr([
			kr(Fr(o[0], s[0], c)),
			kr(Fr(o[1], s[1], c)),
			kr(Fr(o[2], s[2], c)),
			jr(Fr(o[3], s[3], c))
		], "rgba");
		return n ? {
			color: l,
			leftIndex: i,
			rightIndex: a,
			value: r
		} : l;
	}
}
var Yr = Jr;
function Xr(e, t, n, r) {
	var i = Vr(e);
	if (e) return i = Ur(i), t != null && (i[0] = Ar(H(t) ? t(i[0]) : t)), n != null && (i[1] = Nr(H(n) ? n(i[1]) : n)), r != null && (i[2] = Nr(H(r) ? r(i[2]) : r)), Qr(Hr(i), "rgba");
}
function Zr(e, t) {
	var n = Vr(e);
	if (n && t != null) return n[3] = jr(t), Qr(n, "rgba");
}
function Qr(e, t) {
	if (e && e.length) {
		var n = e[0] + "," + e[1] + "," + e[2];
		return (t === "rgba" || t === "hsva" || t === "hsla") && (n += "," + e[3]), t + "(" + n + ")";
	}
}
function $r(e, t) {
	var n = Vr(e);
	return n ? (.299 * n[0] + .587 * n[1] + .114 * n[2]) * n[3] / 255 + (1 - n[3]) * t : 0;
}
function ei() {
	return Qr([
		Math.round(Math.random() * 255),
		Math.round(Math.random() * 255),
		Math.round(Math.random() * 255)
	], "rgb");
}
var ti = new Er(100);
function ni(e) {
	if (U(e)) {
		var t = ti.get(e);
		return t || (t = Wr(e, -.1), ti.put(e, t)), t;
	}
	if (me(e)) {
		var n = M({}, e);
		return n.colorStops = L(e.colorStops, function(e) {
			return {
				offset: e.offset,
				color: Wr(e.color, -.1)
			};
		}), n;
	}
	return e;
}
//#endregion
//#region node_modules/zrender/lib/svg/helper.js
function ri(e) {
	return e.type === "linear";
}
function ii(e) {
	return e.type === "radial";
}
(function() {
	return typeof Buffer < "u" && typeof Buffer.from == "function" ? function(e) {
		return Buffer.from(e).toString("base64");
	} : typeof btoa == "function" && typeof unescape == "function" && typeof encodeURIComponent == "function" ? function(e) {
		return btoa(unescape(encodeURIComponent(e)));
	} : function(e) {
		return null;
	};
})();
//#endregion
//#region node_modules/zrender/lib/animation/Animator.js
var ai = Array.prototype.slice;
function oi(e, t, n) {
	return (t - e) * n + e;
}
function si(e, t, n, r) {
	for (var i = t.length, a = 0; a < i; a++) e[a] = oi(t[a], n[a], r);
	return e;
}
function ci(e, t, n, r) {
	for (var i = t.length, a = i && t[0].length, o = 0; o < i; o++) {
		e[o] || (e[o] = []);
		for (var s = 0; s < a; s++) e[o][s] = oi(t[o][s], n[o][s], r);
	}
	return e;
}
function li(e, t, n, r) {
	for (var i = t.length, a = 0; a < i; a++) e[a] = t[a] + n[a] * r;
	return e;
}
function ui(e, t, n, r) {
	for (var i = t.length, a = i && t[0].length, o = 0; o < i; o++) {
		e[o] || (e[o] = []);
		for (var s = 0; s < a; s++) e[o][s] = t[o][s] + n[o][s] * r;
	}
	return e;
}
function di(e, t) {
	for (var n = e.length, r = t.length, i = n > r ? t : e, a = Math.min(n, r), o = i[a - 1] || {
		color: [
			0,
			0,
			0,
			0
		],
		offset: 0
	}, s = a; s < Math.max(n, r); s++) i.push({
		offset: o.offset,
		color: o.color.slice()
	});
}
function fi(e, t, n) {
	var r = e, i = t;
	if (r.push && i.push) {
		var a = r.length, o = i.length;
		if (a !== o) {
			if (a > o) r.length = o;
			else for (var s = a; s < o; s++) r.push(n === 1 ? i[s] : ai.call(i[s]));
		}
		for (var c = r[0] && r[0].length, s = 0; s < r.length; s++) if (n === 1) isNaN(r[s]) && (r[s] = i[s]);
		else for (var l = 0; l < c; l++) isNaN(r[s][l]) && (r[s][l] = i[s][l]);
	}
}
function pi(e) {
	if (ie(e)) {
		var t = e.length;
		if (ie(e[0])) {
			for (var n = [], r = 0; r < t; r++) n.push(ai.call(e[r]));
			return n;
		}
		return ai.call(e);
	}
	return e;
}
function mi(e) {
	return e[0] = Math.floor(e[0]) || 0, e[1] = Math.floor(e[1]) || 0, e[2] = Math.floor(e[2]) || 0, e[3] = e[3] == null ? 1 : e[3], "rgba(" + e.join(",") + ")";
}
function hi(e) {
	return ie(e && e[0]) ? 2 : 1;
}
var gi = 0, _i = 1, vi = 2, yi = 3, bi = 4, xi = 5, Si = 6;
function Ci(e) {
	return e === bi || e === xi;
}
function wi(e) {
	return e === _i || e === vi;
}
var Ti = [
	0,
	0,
	0,
	0
], Ei = function() {
	function e(e) {
		this.keyframes = [], this.discrete = !1, this._invalid = !1, this._needsSort = !1, this._lastFr = 0, this._lastFrP = 0, this.propName = e;
	}
	return e.prototype.isFinished = function() {
		return this._finished;
	}, e.prototype.setFinished = function() {
		this._finished = !0, this._additiveTrack && this._additiveTrack.setFinished();
	}, e.prototype.needsAnimate = function() {
		return this.keyframes.length >= 1;
	}, e.prototype.getAdditiveTrack = function() {
		return this._additiveTrack;
	}, e.prototype.addKeyframe = function(e, t, n) {
		this._needsSort = !0;
		var r = this.keyframes, i = r.length, a = !1, o = Si, s = t;
		if (ie(t)) {
			var c = hi(t);
			o = c, (c === 1 && !ue(t[0]) || c === 2 && !ue(t[0][0])) && (a = !0);
		} else if (ue(t) && !_e(t)) o = gi;
		else if (U(t)) {
			if (!isNaN(+t)) o = gi;
			else {
				var l = Vr(t);
				l && (s = l, o = yi);
			}
		} else if (me(t)) {
			var u = M({}, s);
			u.colorStops = L(t.colorStops, function(e) {
				return {
					offset: e.offset,
					color: Vr(e.color)
				};
			}), ri(t) ? o = bi : ii(t) && (o = xi), s = u;
		}
		i === 0 ? this.valType = o : (o !== this.valType || o === Si) && (a = !0), this.discrete = this.discrete || a;
		var d = {
			time: e,
			value: s,
			rawValue: t,
			percent: 0
		};
		return n && (d.easing = n, d.easingFunc = H(n) ? n : Yn[n] || Sr(n)), r.push(d), d;
	}, e.prototype.prepare = function(e, t) {
		var n = this.keyframes;
		this._needsSort && n.sort(function(e, t) {
			return e.time - t.time;
		});
		for (var r = this.valType, i = n.length, a = n[i - 1], o = this.discrete, s = wi(r), c = Ci(r), l = 0; l < i; l++) {
			var u = n[l], d = u.value, f = a.value;
			u.percent = u.time / e, o || (s && l !== i - 1 ? fi(d, f, r) : c && di(d.colorStops, f.colorStops));
		}
		if (!o && r !== xi && t && this.needsAnimate() && t.needsAnimate() && r === t.valType && !t._finished) {
			this._additiveTrack = t;
			for (var p = n[0].value, l = 0; l < i; l++) r === gi ? n[l].additiveValue = n[l].value - p : r === yi ? n[l].additiveValue = li([], n[l].value, p, -1) : wi(r) && (n[l].additiveValue = r === _i ? li([], n[l].value, p, -1) : ui([], n[l].value, p, -1));
		}
	}, e.prototype.step = function(e, t) {
		if (!this._finished) {
			this._additiveTrack && this._additiveTrack._finished && (this._additiveTrack = null);
			var n = this._additiveTrack != null, r = n ? "additiveValue" : "value", i = this.valType, a = this.keyframes, o = a.length, s = this.propName, c = i === yi, l, u = this._lastFr, d = Math.min, f, p;
			if (o === 1) f = p = a[0];
			else {
				if (t < 0) l = 0;
				else if (t < this._lastFrP) {
					for (l = d(u + 1, o - 1); l >= 0 && !(a[l].percent <= t); l--);
					l = d(l, o - 2);
				} else {
					for (l = u; l < o && !(a[l].percent > t); l++);
					l = d(l - 1, o - 2);
				}
				p = a[l + 1], f = a[l];
			}
			if (f && p) {
				this._lastFr = l, this._lastFrP = t;
				var m = p.percent - f.percent, h = m === 0 ? 1 : d((t - f.percent) / m, 1);
				p.easingFunc && (h = p.easingFunc(h));
				var g = n ? this._additiveValue : c ? Ti : e[s];
				if ((wi(i) || c) && !g && (g = this._additiveValue = []), this.discrete) e[s] = h < 1 ? f.rawValue : p.rawValue;
				else if (wi(i)) i === _i ? si(g, f[r], p[r], h) : ci(g, f[r], p[r], h);
				else if (Ci(i)) {
					var _ = f[r], v = p[r], y = i === bi;
					e[s] = {
						type: y ? "linear" : "radial",
						x: oi(_.x, v.x, h),
						y: oi(_.y, v.y, h),
						colorStops: L(_.colorStops, function(e, t) {
							var n = v.colorStops[t];
							return {
								offset: oi(e.offset, n.offset, h),
								color: mi(si([], e.color, n.color, h))
							};
						}),
						global: v.global
					}, y ? (e[s].x2 = oi(_.x2, v.x2, h), e[s].y2 = oi(_.y2, v.y2, h)) : e[s].r = oi(_.r, v.r, h);
				} else if (c) si(g, f[r], p[r], h), n || (e[s] = mi(g));
				else {
					var b = oi(f[r], p[r], h);
					n ? this._additiveValue = b : e[s] = b;
				}
				n && this._addToTarget(e);
			}
		}
	}, e.prototype._addToTarget = function(e) {
		var t = this.valType, n = this.propName, r = this._additiveValue;
		t === gi ? e[n] = e[n] + r : t === yi ? (Vr(e[n], Ti), li(Ti, Ti, r, 1), e[n] = mi(Ti)) : t === _i ? li(e[n], e[n], r, 1) : t === vi && ui(e[n], e[n], r, 1);
	}, e;
}(), Di = function() {
	function e(e, t, n, r) {
		this._tracks = {}, this._trackKeys = [], this._maxTime = 0, this._started = 0, this._clip = null, this._target = e, this._loop = t, t && r ? k("Can' use additive animation on looped animation.") : (this._additiveAnimators = r, this._allowDiscrete = n);
	}
	return e.prototype.getMaxTime = function() {
		return this._maxTime;
	}, e.prototype.getDelay = function() {
		return this._delay;
	}, e.prototype.getLoop = function() {
		return this._loop;
	}, e.prototype.getTarget = function() {
		return this._target;
	}, e.prototype.changeTarget = function(e) {
		this._target = e;
	}, e.prototype.when = function(e, t, n) {
		return this.whenWithKeys(e, t, R(t), n);
	}, e.prototype.whenWithKeys = function(e, t, n, r) {
		for (var i = this._tracks, a = 0; a < n.length; a++) {
			var o = n[a], s = i[o];
			if (!s) {
				s = i[o] = new Ei(o);
				var c = void 0, l = this._getAdditiveTrack(o);
				if (l) {
					var u = l.keyframes, d = u[u.length - 1];
					c = d && d.value, l.valType === yi && c && (c = mi(c));
				} else c = this._target[o];
				if (c == null) continue;
				e > 0 && s.addKeyframe(0, pi(c), r), this._trackKeys.push(o);
			}
			s.addKeyframe(e, pi(t[o]), r);
		}
		return this._maxTime = Math.max(this._maxTime, e), this;
	}, e.prototype.pause = function() {
		this._clip.pause(), this._paused = !0;
	}, e.prototype.resume = function() {
		this._clip.resume(), this._paused = !1;
	}, e.prototype.isPaused = function() {
		return !!this._paused;
	}, e.prototype.duration = function(e) {
		return this._maxTime = e, this._force = !0, this;
	}, e.prototype._doneCallback = function() {
		this._setTracksFinished(), this._clip = null;
		var e = this._doneCbs;
		if (e) for (var t = e.length, n = 0; n < t; n++) e[n].call(this);
	}, e.prototype._abortedCallback = function() {
		this._setTracksFinished();
		var e = this.animation, t = this._abortedCbs;
		if (e && e.removeClip(this._clip), this._clip = null, t) for (var n = 0; n < t.length; n++) t[n].call(this);
	}, e.prototype._setTracksFinished = function() {
		for (var e = this._tracks, t = this._trackKeys, n = 0; n < t.length; n++) e[t[n]].setFinished();
	}, e.prototype._getAdditiveTrack = function(e) {
		var t, n = this._additiveAnimators;
		if (n) for (var r = 0; r < n.length; r++) {
			var i = n[r].getTrack(e);
			i && (t = i);
		}
		return t;
	}, e.prototype.start = function(e) {
		if (!(this._started > 0)) {
			this._started = 1;
			for (var t = this, n = [], r = this._maxTime || 0, i = 0; i < this._trackKeys.length; i++) {
				var a = this._trackKeys[i], o = this._tracks[a], s = this._getAdditiveTrack(a), c = o.keyframes, l = c.length;
				if (o.prepare(r, s), o.needsAnimate()) {
					if (!this._allowDiscrete && o.discrete) {
						var u = c[l - 1];
						u && (t._target[o.propName] = u.rawValue), o.setFinished();
					} else n.push(o);
				}
			}
			if (n.length || this._force) {
				var d = new Cr({
					life: r,
					loop: this._loop,
					delay: this._delay || 0,
					onframe: function(e) {
						t._started = 2;
						var r = t._additiveAnimators;
						if (r) {
							for (var i = !1, a = 0; a < r.length; a++) if (r[a]._clip) {
								i = !0;
								break;
							}
							i || (t._additiveAnimators = null);
						}
						for (var a = 0; a < n.length; a++) n[a].step(t._target, e);
						var o = t._onframeCbs;
						if (o) for (var a = 0; a < o.length; a++) o[a](t._target, e);
					},
					ondestroy: function() {
						t._doneCallback();
					}
				});
				this._clip = d, this.animation && this.animation.addClip(d), e && d.setEasing(e);
			} else this._doneCallback();
			return this;
		}
	}, e.prototype.stop = function(e) {
		if (this._clip) {
			var t = this._clip;
			e && t.onframe(1), this._abortedCallback();
		}
	}, e.prototype.delay = function(e) {
		return this._delay = e, this;
	}, e.prototype.during = function(e) {
		return e && (this._onframeCbs ||= [], this._onframeCbs.push(e)), this;
	}, e.prototype.done = function(e) {
		return e && (this._doneCbs ||= [], this._doneCbs.push(e)), this;
	}, e.prototype.aborted = function(e) {
		return e && (this._abortedCbs ||= [], this._abortedCbs.push(e)), this;
	}, e.prototype.getClip = function() {
		return this._clip;
	}, e.prototype.getTrack = function(e) {
		return this._tracks[e];
	}, e.prototype.getTracks = function() {
		var e = this;
		return L(this._trackKeys, function(t) {
			return e._tracks[t];
		});
	}, e.prototype.stopTracks = function(e, t) {
		if (!e.length || !this._clip) return !0;
		for (var n = this._tracks, r = this._trackKeys, i = 0; i < e.length; i++) {
			var a = n[e[i]];
			a && !a.isFinished() && (t ? a.step(this._target, 1) : this._started === 1 && a.step(this._target, 0), a.setFinished());
		}
		for (var o = !0, i = 0; i < r.length; i++) if (!n[r[i]].isFinished()) {
			o = !1;
			break;
		}
		return o && this._abortedCallback(), o;
	}, e.prototype.saveTo = function(e, t, n) {
		if (e) {
			t ||= this._trackKeys;
			for (var r = 0; r < t.length; r++) {
				var i = t[r], a = this._tracks[i];
				if (a && !a.isFinished()) {
					var o = a.keyframes, s = o[n ? 0 : o.length - 1];
					s && (e[i] = pi(s.rawValue));
				}
			}
		}
	}, e.prototype.__changeFinalValue = function(e, t) {
		t ||= R(e);
		for (var n = 0; n < t.length; n++) {
			var r = t[n], i = this._tracks[r];
			if (i) {
				var a = i.keyframes;
				if (a.length > 1) {
					var o = a.pop();
					i.addKeyframe(o.time, e[r]), i.prepare(this._maxTime, i.getAdditiveTrack());
				}
			}
		}
	}, e;
}();
//#endregion
//#region node_modules/zrender/lib/animation/Animation.js
function Oi() {
	return (/* @__PURE__ */ new Date()).getTime();
}
var ki = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this) || this;
		return n._running = !1, n._time = 0, n._pausedTime = 0, n._pauseStart = 0, n._paused = !1, t ||= {}, n.stage = t.stage || {}, n;
	}
	return t.prototype.addClip = function(e) {
		e.animation && this.removeClip(e), this._head ? (this._tail.next = e, e.prev = this._tail, e.next = null, this._tail = e) : this._head = this._tail = e, e.animation = this;
	}, t.prototype.addAnimator = function(e) {
		e.animation = this;
		var t = e.getClip();
		t && this.addClip(t);
	}, t.prototype.removeClip = function(e) {
		if (e.animation) {
			var t = e.prev, n = e.next;
			t ? t.next = n : this._head = n, n ? n.prev = t : this._tail = t, e.next = e.prev = e.animation = null;
		}
	}, t.prototype.removeAnimator = function(e) {
		var t = e.getClip();
		t && this.removeClip(t), e.animation = null;
	}, t.prototype.update = function(e) {
		for (var t = Oi() - this._pausedTime, n = t - this._time, r = this._head; r;) {
			var i = r.next;
			r.step(t, n) && (r.ondestroy(), this.removeClip(r)), r = i;
		}
		this._time = t, e || (this.trigger("frame", n), this.stage.update && this.stage.update());
	}, t.prototype._startLoop = function() {
		var e = this;
		this._running = !0;
		function t() {
			e._running && (Jn(t), !e._paused && e.update());
		}
		Jn(t);
	}, t.prototype.start = function() {
		this._running || (this._time = Oi(), this._pausedTime = 0, this._startLoop());
	}, t.prototype.stop = function() {
		this._running = !1;
	}, t.prototype.pause = function() {
		this._paused ||= (this._pauseStart = Oi(), !0);
	}, t.prototype.resume = function() {
		this._paused &&= (this._pausedTime += Oi() - this._pauseStart, !1);
	}, t.prototype.clear = function() {
		for (var e = this._head; e;) {
			var t = e.next;
			e.prev = e.next = e.animation = null, e = t;
		}
		this._head = this._tail = null;
	}, t.prototype.isFinished = function() {
		return this._head == null;
	}, t.prototype.animate = function(e, t) {
		t ||= {}, this.start();
		var n = new Di(e, t.loop);
		return this.addAnimator(n), n;
	}, t;
}(dt), Ai = 300, ji = i.domSupported, Mi = (function() {
	var e = [
		"click",
		"dblclick",
		"mousewheel",
		"wheel",
		"mouseout",
		"mouseup",
		"mousedown",
		"mousemove",
		"contextmenu"
	], t = [
		"touchstart",
		"touchend",
		"touchmove"
	], n = {
		pointerdown: 1,
		pointerup: 1,
		pointermove: 1,
		pointerout: 1
	};
	return {
		mouse: e,
		touch: t,
		pointer: L(e, function(e) {
			var t = e.replace("mouse", "pointer");
			return n.hasOwnProperty(t) ? t : e;
		})
	};
})(), Ni = {
	mouse: ["mousemove", "mouseup"],
	pointer: ["pointermove", "pointerup"]
}, Pi = !1;
function Fi(e) {
	var t = e.pointerType;
	return t === "pen" || t === "touch";
}
function Ii(e) {
	e.touching = !0, e.touchTimer != null && (clearTimeout(e.touchTimer), e.touchTimer = null), e.touchTimer = setTimeout(function() {
		e.touching = !1, e.touchTimer = null;
	}, 700);
}
function Li(e) {
	e && (e.zrByTouch = !0);
}
function Ri(e, t) {
	return Mt(e.dom, new Bi(e, t), !0);
}
function zi(e, t) {
	for (var n = t, r = !1; n && n.nodeType !== 9 && !(r = n.domBelongToZr || n !== t && n === e.painterRoot);) n = n.parentNode;
	return r;
}
var Bi = function() {
	function e(e, t) {
		this.stopPropagation = Pe, this.stopImmediatePropagation = Pe, this.preventDefault = Pe, this.type = t.type, this.target = this.currentTarget = e.dom, this.pointerType = t.pointerType, this.clientX = t.clientX, this.clientY = t.clientY;
	}
	return e;
}(), Vi = {
	mousedown: function(e) {
		e = Mt(this.dom, e), this.__mayPointerCapture = [e.zrX, e.zrY], this.trigger("mousedown", e);
	},
	mousemove: function(e) {
		e = Mt(this.dom, e);
		var t = this.__mayPointerCapture;
		t && (e.zrX !== t[0] || e.zrY !== t[1]) && this.__togglePointerCapture(!0), this.trigger("mousemove", e);
	},
	mouseup: function(e) {
		e = Mt(this.dom, e), this.__togglePointerCapture(!1), this.trigger("mouseup", e);
	},
	mouseout: function(e) {
		e = Mt(this.dom, e);
		var t = e.toElement || e.relatedTarget;
		zi(this, t) || (this.__pointerCapturing && (e.zrEventControl = "no_globalout"), this.trigger("mouseout", e));
	},
	wheel: function(e) {
		Pi = !0, e = Mt(this.dom, e), this.trigger("mousewheel", e);
	},
	mousewheel: function(e) {
		Pi || (e = Mt(this.dom, e), this.trigger("mousewheel", e));
	},
	touchstart: function(e) {
		e = Mt(this.dom, e), Li(e), this.__lastTouchMoment = /* @__PURE__ */ new Date(), this.handler.processGesture(e, "start"), Vi.mousemove.call(this, e), Vi.mousedown.call(this, e);
	},
	touchmove: function(e) {
		e = Mt(this.dom, e), Li(e), this.handler.processGesture(e, "change"), Vi.mousemove.call(this, e);
	},
	touchend: function(e) {
		e = Mt(this.dom, e), Li(e), this.handler.processGesture(e, "end"), Vi.mouseup.call(this, e), +/* @__PURE__ */ new Date() - this.__lastTouchMoment < Ai && Vi.click.call(this, e);
	},
	pointerdown: function(e) {
		Vi.mousedown.call(this, e);
	},
	pointermove: function(e) {
		Fi(e) || Vi.mousemove.call(this, e);
	},
	pointerup: function(e) {
		Vi.mouseup.call(this, e);
	},
	pointerout: function(e) {
		Fi(e) || Vi.mouseout.call(this, e);
	}
};
I([
	"click",
	"dblclick",
	"contextmenu"
], function(e) {
	Vi[e] = function(t) {
		t = Mt(this.dom, t), this.trigger(e, t);
	};
});
var Hi = {
	pointermove: function(e) {
		Fi(e) || Hi.mousemove.call(this, e);
	},
	pointerup: function(e) {
		Hi.mouseup.call(this, e);
	},
	mousemove: function(e) {
		this.trigger("mousemove", e);
	},
	mouseup: function(e) {
		var t = this.__pointerCapturing;
		this.__togglePointerCapture(!1), this.trigger("mouseup", e), t && (e.zrEventControl = "only_globalout", this.trigger("mouseout", e));
	}
};
function Ui(e, t) {
	var n = t.domHandlers;
	i.pointerEventsSupported ? I(Mi.pointer, function(r) {
		Gi(t, r, function(t) {
			n[r].call(e, t);
		});
	}) : (i.touchEventsSupported && I(Mi.touch, function(r) {
		Gi(t, r, function(i) {
			n[r].call(e, i), Ii(t);
		});
	}), I(Mi.mouse, function(r) {
		Gi(t, r, function(i) {
			i = jt(i), t.touching || n[r].call(e, i);
		});
	}));
}
function Wi(e, t) {
	i.pointerEventsSupported ? I(Ni.pointer, n) : i.touchEventsSupported || I(Ni.mouse, n);
	function n(n) {
		function r(r) {
			r = jt(r), zi(e, r.target) || (r = Ri(e, r), t.domHandlers[n].call(e, r));
		}
		Gi(t, n, r, { capture: !0 });
	}
}
function Gi(e, t, n, r) {
	e.mounted[t] = n, e.listenerOpts[t] = r, Pt(e.domTarget, t, n, r);
}
function Ki(e) {
	var t = e.mounted;
	for (var n in t) t.hasOwnProperty(n) && Ft(e.domTarget, n, t[n], e.listenerOpts[n]);
	e.mounted = {};
}
var qi = function() {
	function e(e, t) {
		this.mounted = {}, this.listenerOpts = {}, this.touching = !1, this.domTarget = e, this.domHandlers = t;
	}
	return e;
}(), Ji = function(e) {
	n(t, e);
	function t(t, n) {
		var r = e.call(this) || this;
		return r.__pointerCapturing = !1, r.dom = t, r.painterRoot = n, r._localHandlerScope = new qi(t, Vi), ji && (r._globalHandlerScope = new qi(document, Hi)), Ui(r, r._localHandlerScope), r;
	}
	return t.prototype.dispose = function() {
		Ki(this._localHandlerScope), ji && Ki(this._globalHandlerScope);
	}, t.prototype.setCursor = function(e) {
		this.dom.style && (this.dom.style.cursor = e || "default");
	}, t.prototype.__togglePointerCapture = function(e) {
		if (this.__mayPointerCapture = null, ji && +this.__pointerCapturing ^ e) {
			this.__pointerCapturing = e;
			var t = this._globalHandlerScope;
			e ? Wi(this, t) : Ki(t);
		}
	}, t;
}(dt), Yi = 1;
i.hasGlobalWindow && (Yi = Math.max(window.devicePixelRatio || window.screen && window.screen.deviceXDPI / window.screen.logicalXDPI || 1, 1));
var Xi = Yi, Zi = .4, Qi = "#333", $i = "#ccc", ea = "#eee", ta = Wt, na = 5e-5;
function ra(e) {
	return e > na || e < -na;
}
var ia = [], aa = [], oa = Ut(), sa = Math.abs, ca = function() {
	function e() {}
	return e.prototype.getLocalTransform = function(e) {
		return la(this, e);
	}, e.prototype.setPosition = function(e) {
		this.x = e[0], this.y = e[1];
	}, e.prototype.setScale = function(e) {
		this.scaleX = e[0], this.scaleY = e[1];
	}, e.prototype.setSkew = function(e) {
		this.skewX = e[0], this.skewY = e[1];
	}, e.prototype.setOrigin = function(e) {
		this.originX = e[0], this.originY = e[1];
	}, e.prototype.needLocalTransform = function() {
		return ra(this.rotation) || ra(this.x) || ra(this.y) || ra(this.scaleX - 1) || ra(this.scaleY - 1) || ra(this.skewX) || ra(this.skewY);
	}, e.prototype.updateTransform = function() {
		var e = this.parent && this.parent.transform, t = this.needLocalTransform(), n = this.transform;
		t || e ? (n ||= Ut(), t ? this.getLocalTransform(n) : ta(n), e && (t ? Kt(n, e, n) : Gt(n, e)), this.transform = n, this._resolveGlobalScaleRatio(n), this.invTransform = this.invTransform || Ut(), Xt(this.invTransform, n)) : n && (ta(n), this.invTransform = null);
	}, e.prototype._resolveGlobalScaleRatio = function(e) {
		var t = this.globalScaleRatio;
		if (t != null && t !== 1) {
			this.getGlobalScale(ia);
			var n = ia[0] < 0 ? -1 : 1, r = ia[1] < 0 ? -1 : 1, i = ((ia[0] - n) * t + n) / ia[0] || 0, a = ((ia[1] - r) * t + r) / ia[1] || 0;
			e[0] *= i, e[1] *= i, e[2] *= a, e[3] *= a;
		}
	}, e.prototype.getComputedTransform = function() {
		for (var e = this, t = []; e;) t.push(e), e = e.parent;
		for (; e = t.pop();) e.updateTransform();
		return this.transform;
	}, e.prototype.setLocalTransform = function(e) {
		if (e) {
			var t = e[0] * e[0] + e[1] * e[1], n = e[2] * e[2] + e[3] * e[3], r = Math.atan2(e[1], e[0]), i = Math.PI / 2 + r - Math.atan2(e[3], e[2]);
			n = Math.sqrt(n) * Math.cos(i), t = Math.sqrt(t), this.skewX = i, this.skewY = 0, this.rotation = -r, this.x = +e[4], this.y = +e[5], this.scaleX = t, this.scaleY = n, this.originX = 0, this.originY = 0;
		}
	}, e.prototype.decomposeTransform = function() {
		if (this.transform) {
			var e = this.parent, t = this.transform;
			e && e.transform && (e.invTransform = e.invTransform || Ut(), Kt(aa, e.invTransform, t), t = aa);
			var n = this.originX, r = this.originY;
			(n || r) && (oa[4] = n, oa[5] = r, Kt(aa, t, oa), aa[4] -= n, aa[5] -= r, t = aa), this.setLocalTransform(t);
		}
	}, e.prototype.getGlobalScale = function(e) {
		var t = this.transform;
		return e ||= [], t ? (e[0] = Math.sqrt(t[0] * t[0] + t[1] * t[1]), e[1] = Math.sqrt(t[2] * t[2] + t[3] * t[3]), t[0] < 0 && (e[0] = -e[0]), t[3] < 0 && (e[1] = -e[1]), e) : (e[0] = 1, e[1] = 1, e);
	}, e.prototype.transformCoordToLocal = function(e, t) {
		var n = [e, t], r = this.invTransform;
		return r && ot(n, n, r), n;
	}, e.prototype.transformCoordToGlobal = function(e, t) {
		var n = [e, t], r = this.transform;
		return r && ot(n, n, r), n;
	}, e.prototype.getLineScale = function() {
		var e = this.transform;
		return e && sa(e[0] - 1) > 1e-10 && sa(e[3] - 1) > 1e-10 ? Math.sqrt(sa(e[0] * e[3] - e[2] * e[1])) : 1;
	}, e.prototype.copyTransform = function(e) {
		fa(this, e);
	}, e.getLocalTransform = function(e, t) {
		t ||= [];
		var n = e.originX || 0, r = e.originY || 0, i = e.scaleX, a = e.scaleY, o = e.anchorX, s = e.anchorY, c = e.rotation || 0, l = e.x, u = e.y, d = e.skewX ? Math.tan(e.skewX) : 0, f = e.skewY ? Math.tan(-e.skewY) : 0;
		if (n || r || o || s) {
			var p = n + o, m = r + s;
			t[4] = -p * i - d * m * a, t[5] = -m * a - f * p * i;
		} else t[4] = t[5] = 0;
		return t[0] = i, t[3] = a, t[1] = f * i, t[2] = d * a, c && Jt(t, t, c), t[4] += n + l, t[5] += r + u, t;
	}, e.initDefaultProps = (function() {
		var t = e.prototype;
		t.scaleX = t.scaleY = t.globalScaleRatio = 1, t.x = t.y = t.originX = t.originY = t.skewX = t.skewY = t.rotation = t.anchorX = t.anchorY = 0;
	})(), e;
}(), la = ca.getLocalTransform;
function ua() {
	return new ca();
}
var da = [
	"x",
	"y",
	"originX",
	"originY",
	"anchorX",
	"anchorY",
	"rotation",
	"scaleX",
	"scaleY",
	"skewX",
	"skewY"
];
function fa(e, t) {
	return te(e, t, da);
}
//#endregion
//#region node_modules/zrender/lib/contain/text.js
function pa(e) {
	ma ||= new Er(100), e ||= "12px sans-serif";
	var t = ma.get(e);
	return t || (t = {
		font: e,
		strWidthCache: new Er(500),
		asciiWidthMap: null,
		asciiWidthMapTried: !1,
		stWideCharWidth: f.measureText("国", e).width,
		asciiCharWidth: f.measureText("a", e).width
	}, ma.put(e, t)), t;
}
var ma;
function ha(e) {
	if (!(ga >= _a)) {
		e ||= "12px sans-serif";
		for (var t = [], n = +/* @__PURE__ */ new Date(), r = 0; r <= 127; r++) t[r] = f.measureText(String.fromCharCode(r), e).width;
		var i = +/* @__PURE__ */ new Date() - n;
		return i > 16 ? ga = _a : i > 2 && ga++, t;
	}
}
var ga = 0, _a = 5;
function va(e, t) {
	return e.asciiWidthMapTried ||= (e.asciiWidthMap = ha(e.font), !0), 0 <= t && t <= 127 ? e.asciiWidthMap == null ? e.asciiCharWidth : e.asciiWidthMap[t] : e.stWideCharWidth;
}
function ya(e, t) {
	var n = e.strWidthCache, r = n.get(t);
	return r ?? (r = f.measureText(t, e.font).width, n.put(t, r)), r;
}
function ba(e, t, n, r) {
	var i = ya(pa(t), e), a = wa(t);
	return new Y(Sa(0, i, n), Ca(0, a, r), i, a);
}
function xa(e, t, n, r) {
	var i = ((e || "") + "").split("\n");
	if (i.length === 1) return ba(i[0], t, n, r);
	for (var a = new Y(0, 0, 0, 0), o = 0; o < i.length; o++) {
		var s = ba(i[o], t, n, r);
		o === 0 ? a.copy(s) : a.union(s);
	}
	return a;
}
function Sa(e, t, n, r) {
	return n === "right" ? r ? e += t : e -= t : n === "center" && (r ? e += t / 2 : e -= t / 2), e;
}
function Ca(e, t, n, r) {
	return n === "middle" ? r ? e += t / 2 : e -= t / 2 : n === "bottom" && (r ? e += t : e -= t), e;
}
function wa(e) {
	return pa(e).stWideCharWidth;
}
function Ta(e, t) {
	return typeof e == "string" ? e.lastIndexOf("%") >= 0 ? parseFloat(e) / 100 * t : parseFloat(e) : e;
}
function Ea(e, t, n) {
	var r = t.position || "inside", i = t.distance == null ? 5 : t.distance, a = n.height, o = n.width, s = a / 2, c = n.x, l = n.y, u = "left", d = "top";
	if (r instanceof Array) c += Ta(r[0], n.width), l += Ta(r[1], n.height), u = null, d = null;
	else switch (r) {
		case "left":
			c -= i, l += s, u = "right", d = "middle";
			break;
		case "right":
			c += i + o, l += s, d = "middle";
			break;
		case "top":
			c += o / 2, l -= i, u = "center", d = "bottom";
			break;
		case "bottom":
			c += o / 2, l += a + i, u = "center";
			break;
		case "inside":
			c += o / 2, l += s, u = "center", d = "middle";
			break;
		case "insideLeft":
			c += i, l += s, d = "middle";
			break;
		case "insideRight":
			c += o - i, l += s, u = "right", d = "middle";
			break;
		case "insideTop":
			c += o / 2, l += i, u = "center";
			break;
		case "insideBottom":
			c += o / 2, l += a - i, u = "center", d = "bottom";
			break;
		case "insideTopLeft":
			c += i, l += i;
			break;
		case "insideTopRight":
			c += o - i, l += i, u = "right";
			break;
		case "insideBottomLeft":
			c += i, l += a - i, d = "bottom";
			break;
		case "insideBottomRight": c += o - i, l += a - i, u = "right", d = "bottom";
	}
	return e ||= {}, e.x = c, e.y = l, e.align = u, e.verticalAlign = d, e;
}
//#endregion
//#region node_modules/zrender/lib/Element.js
var Da = "__zr_normal__", Oa = da.concat(["ignore"]), ka = ae(da, function(e, t) {
	return e[t] = !0, e;
}, { ignore: !1 }), Aa = {}, ja = new Y(0, 0, 0, 0), Ma = [], Na = function() {
	function e(e) {
		this.id = O(), this.animators = [], this.currentStates = [], this.states = {}, this._init(e);
	}
	return e.prototype._init = function(e) {
		this.attr(e);
	}, e.prototype.drift = function(e, t, n) {
		switch (this.draggable) {
			case "horizontal":
				t = 0;
				break;
			case "vertical": e = 0;
		}
		var r = this.transform;
		r ||= this.transform = [
			1,
			0,
			0,
			1,
			0,
			0
		], r[4] += e, r[5] += t, this.decomposeTransform(), this.markRedraw();
	}, e.prototype.beforeUpdate = function() {}, e.prototype.afterUpdate = function() {}, e.prototype.update = function() {
		this.updateTransform(), this.__dirty && this.updateInnerText();
	}, e.prototype.updateInnerText = function(e) {
		var t = this._textContent;
		if (t && (!t.ignore || e)) {
			this.textConfig ||= {};
			var n = this.textConfig, r = n.local, i = t.innerTransformable, a = void 0, o = void 0, s = !1;
			i.parent = r ? this : null;
			var c = !1;
			i.copyTransform(t);
			var l = n.position != null, u = n.autoOverflowArea, d = void 0;
			if ((u || l) && (d = ja, n.layoutRect ? d.copy(n.layoutRect) : d.copy(this.getBoundingRect()), r || d.applyTransform(this.transform)), l) {
				this.calculateTextPosition ? this.calculateTextPosition(Aa, n, d) : Ea(Aa, n, d), i.x = Aa.x, i.y = Aa.y, a = Aa.align, o = Aa.verticalAlign;
				var f = n.origin;
				if (f && n.rotation != null) {
					var p = void 0, m = void 0;
					f === "center" ? (p = d.width * .5, m = d.height * .5) : (p = Ta(f[0], d.width), m = Ta(f[1], d.height)), c = !0, i.originX = -i.x + p + (r ? 0 : d.x), i.originY = -i.y + m + (r ? 0 : d.y);
				}
			}
			n.rotation != null && (i.rotation = n.rotation);
			var h = n.offset;
			h && (i.x += h[0], i.y += h[1], c || (i.originX = -h[0], i.originY = -h[1]));
			var g = this._innerTextDefaultStyle ||= {};
			if (u) {
				var _ = g.overflowRect = g.overflowRect || new Y(0, 0, 0, 0);
				i.getLocalTransform(Ma), Xt(Ma, Ma), Y.copy(_, d), _.applyTransform(Ma);
			} else g.overflowRect = null;
			var v = n.inside == null ? typeof n.position == "string" && n.position.indexOf("inside") >= 0 : n.inside, y = void 0, b = void 0, x = void 0;
			v && this.canBeInsideText() ? (y = n.insideFill, b = n.insideStroke, (y == null || y === "auto") && (y = this.getInsideTextFill()), (b == null || b === "auto") && (b = this.getInsideTextStroke(y), x = !0)) : (y = n.outsideFill, b = n.outsideStroke, (y == null || y === "auto") && (y = this.getOutsideFill()), (b == null || b === "auto") && (b = this.getOutsideStroke(y), x = !0)), y ||= "#000", (y !== g.fill || b !== g.stroke || x !== g.autoStroke || a !== g.align || o !== g.verticalAlign) && (s = !0, g.fill = y, g.stroke = b, g.autoStroke = x, g.align = a, g.verticalAlign = o, t.setDefaultTextStyle(g)), t.__dirty |= 1, s && t.dirtyStyle(!0);
		}
	}, e.prototype.canBeInsideText = function() {
		return !0;
	}, e.prototype.getInsideTextFill = function() {
		return "#fff";
	}, e.prototype.getInsideTextStroke = function(e) {
		return "#000";
	}, e.prototype.getOutsideFill = function() {
		return this.__zr && this.__zr.isDarkMode() ? $i : Qi;
	}, e.prototype.getOutsideStroke = function(e) {
		var t = this.__zr && this.__zr.getBackgroundColor(), n = typeof t == "string" && Vr(t);
		n ||= [
			255,
			255,
			255,
			1
		];
		for (var r = n[3], i = this.__zr.isDarkMode(), a = 0; a < 3; a++) n[a] = n[a] * r + (i ? 0 : 255) * (1 - r);
		return n[3] = 1, Qr(n, "rgba");
	}, e.prototype.traverse = function(e, t) {}, e.prototype.attrKV = function(e, t) {
		e === "textConfig" ? this.setTextConfig(t) : e === "textContent" ? this.setTextContent(t) : e === "clipPath" ? this.setClipPath(t) : e === "extra" ? (this.extra = this.extra || {}, M(this.extra, t)) : this[e] = t;
	}, e.prototype.hide = function() {
		this.ignore = !0, this.markRedraw();
	}, e.prototype.show = function() {
		this.ignore = !1, this.markRedraw();
	}, e.prototype.attr = function(e, t) {
		if (typeof e == "string") this.attrKV(e, t);
		else if (W(e)) for (var n = R(e), r = 0; r < n.length; r++) {
			var i = n[r];
			this.attrKV(i, e[i]);
		}
		return this.markRedraw(), this;
	}, e.prototype.saveCurrentToNormalState = function(e) {
		this._innerSaveToNormal(e);
		for (var t = this._normalState, n = 0; n < this.animators.length; n++) {
			var r = this.animators[n], i = r.__fromStateTransition;
			if (!(r.getLoop() || i && i !== "__zr_normal__")) {
				var a = r.targetName, o = a ? t[a] : t;
				r.saveTo(o);
			}
		}
	}, e.prototype._innerSaveToNormal = function(e) {
		var t = this._normalState;
		t ||= this._normalState = {}, e.textConfig && !t.textConfig && (t.textConfig = this.textConfig), this._savePrimaryToNormal(e, t, Oa);
	}, e.prototype._savePrimaryToNormal = function(e, t, n) {
		for (var r = 0; r < n.length; r++) {
			var i = n[r];
			e[i] != null && !(i in t) && (t[i] = this[i]);
		}
	}, e.prototype.hasState = function() {
		return this.currentStates.length > 0;
	}, e.prototype.getState = function(e) {
		return this.states[e];
	}, e.prototype.ensureState = function(e) {
		var t = this.states;
		return t[e] || (t[e] = {}), t[e];
	}, e.prototype.clearStates = function(e) {
		this.useState(Da, !1, e);
	}, e.prototype.useState = function(e, t, n, r) {
		var i = e === Da;
		if (this.hasState() || !i) {
			var a = this.currentStates, o = this.stateTransition;
			if (!(P(a, e) >= 0 && (t || a.length === 1))) {
				var s;
				if (this.stateProxy && !i && (s = this.stateProxy(e)), s ||= this.states && this.states[e], !s && !i) k("State " + e + " not exists.");
				else {
					i || this.saveCurrentToNormalState(s);
					var c = this._textContent, l = Va(this, c, s, r);
					l && !this.__inHover && (this.__inHover = l), this._applyStateObj(e, s, this._normalState, t, Ua(this, n, o), o);
					var u = this._textGuide;
					return c && c.useState(e, t, n, !!l), u && u.useState(e, t, n, !!l), i ? (this.currentStates = [], this._normalState = {}) : t ? this.currentStates.push(e) : this.currentStates = [e], this._updateAnimationTargets(), this.markRedraw(), !l && this.__inHover && (this.__inHover = 0, this.__dirty &= -2), s;
				}
			}
		}
	}, e.prototype.useStates = function(e, t, n) {
		if (!e.length) this.clearStates();
		else {
			var r = [], i = this.currentStates, a = e.length, o = a === i.length;
			if (o) {
				for (var s = 0; s < a; s++) if (e[s] !== i[s]) {
					o = !1;
					break;
				}
			}
			if (o) return;
			for (var s = 0; s < a; s++) {
				var c = e[s], l = void 0;
				this.stateProxy && (l = this.stateProxy(c, e)), l ||= this.states[c], l && r.push(l);
			}
			var u = r[a - 1], d = this._textContent, f = Va(this, d, u, n);
			f && !this.__inHover && (this.__inHover = f);
			var p = this._mergeStates(r), m = this.stateTransition;
			this.saveCurrentToNormalState(p), this._applyStateObj(e.join(","), p, this._normalState, !1, Ua(this, t, m), m);
			var h = this._textGuide;
			d && d.useStates(e, t, !!f), h && h.useStates(e, t, !!f), this._updateAnimationTargets(), this.currentStates = e.slice(), this.markRedraw(), !f && this.__inHover && (this.__inHover = 0, this.__dirty &= -2);
		}
	}, e.prototype.isSilent = function() {
		for (var e = this; e;) {
			if (e.silent) return !0;
			var t = e.__hostTarget;
			e = t ? e.ignoreHostSilent ? null : t : e.parent;
		}
		return !1;
	}, e.prototype._updateAnimationTargets = function() {
		for (var e = 0; e < this.animators.length; e++) {
			var t = this.animators[e];
			t.targetName && t.changeTarget(this[t.targetName]);
		}
	}, e.prototype.removeState = function(e) {
		var t = P(this.currentStates, e);
		if (t >= 0) {
			var n = this.currentStates.slice();
			n.splice(t, 1), this.useStates(n);
		}
	}, e.prototype.replaceState = function(e, t, n) {
		var r = this.currentStates.slice(), i = P(r, e), a = P(r, t) >= 0;
		i >= 0 ? a ? r.splice(i, 1) : r[i] = t : n && !a && r.push(t), this.useStates(r);
	}, e.prototype.toggleState = function(e, t) {
		t ? this.useState(e, !0) : this.removeState(e);
	}, e.prototype._mergeStates = function(e) {
		for (var t = {}, n, r = 0; r < e.length; r++) {
			var i = e[r];
			M(t, i), i.textConfig && (n ||= {}, M(n, i.textConfig));
		}
		return n && (t.textConfig = n), t;
	}, e.prototype._applyStateObj = function(e, t, n, r, i, a) {
		if (this.__inHover !== 1) {
			var o = !(t && r);
			t && t.textConfig ? (this.textConfig = M({}, r ? this.textConfig : n.textConfig), M(this.textConfig, t.textConfig)) : o && n.textConfig && (this.textConfig = n.textConfig);
			for (var s = {}, c = !1, l = 0; l < Oa.length; l++) {
				var u = Oa[l], d = i && ka[u];
				t && t[u] != null ? d ? (c = !0, s[u] = t[u]) : this[u] = t[u] : o && n[u] != null && (d ? (c = !0, s[u] = n[u]) : this[u] = n[u]);
			}
			if (!i) for (var l = 0; l < this.animators.length; l++) {
				var f = this.animators[l], p = f.targetName;
				f.getLoop() || f.__changeFinalValue(p ? (t || n)[p] : t || n);
			}
			c && this._transitionState(e, s, a);
		}
	}, e.prototype._attachComponent = function(e) {
		if ((!e.__zr || e.__hostTarget) && e !== this) {
			var t = this.__zr;
			t && e.addSelfToZr(t), e.__zr = t, e.__hostTarget = this;
		}
	}, e.prototype._detachComponent = function(e) {
		e.__zr && e.removeSelfFromZr(e.__zr), e.__zr = null, e.__hostTarget = null;
	}, e.prototype.getClipPath = function() {
		return this._clipPath;
	}, e.prototype.setClipPath = function(e) {
		this._clipPath && this._clipPath !== e && this.removeClipPath(), this._attachComponent(e), this._clipPath = e, this.markRedraw();
	}, e.prototype.removeClipPath = function() {
		var e = this._clipPath;
		e && (this._detachComponent(e), this._clipPath = null, this.markRedraw());
	}, e.prototype.getTextContent = function() {
		return this._textContent;
	}, e.prototype.setTextContent = function(e) {
		var t = this._textContent;
		t !== e && (t && t !== e && this.removeTextContent(), e.innerTransformable = new ca(), this._attachComponent(e), this._textContent = e, this.markRedraw());
	}, e.prototype.setTextConfig = function(e) {
		this.textConfig ||= {}, M(this.textConfig, e), this.markRedraw();
	}, e.prototype.removeTextConfig = function() {
		this.textConfig = null, this.markRedraw();
	}, e.prototype.removeTextContent = function() {
		var e = this._textContent;
		e && (e.innerTransformable = null, this._detachComponent(e), this._textContent = null, this._innerTextDefaultStyle = null, this.markRedraw());
	}, e.prototype.getTextGuideLine = function() {
		return this._textGuide;
	}, e.prototype.setTextGuideLine = function(e) {
		this._textGuide && this._textGuide !== e && this.removeTextGuideLine(), this._attachComponent(e), this._textGuide = e, this.markRedraw();
	}, e.prototype.removeTextGuideLine = function() {
		var e = this._textGuide;
		e && (this._detachComponent(e), this._textGuide = null, this.markRedraw());
	}, e.prototype.markRedraw = function() {
		this.__dirty |= 1;
		var e = this.__zr;
		e && (this.__inHover ? e.refreshHover() : e.refresh()), this.__hostTarget && this.__hostTarget.markRedraw();
	}, e.prototype.dirty = function() {
		this.markRedraw();
	}, e.prototype.addSelfToZr = function(e) {
		if (this.__zr !== e) {
			this.__zr = e;
			var t = this.animators;
			if (t) for (var n = 0; n < t.length; n++) e.animation.addAnimator(t[n]);
			this._clipPath && this._clipPath.addSelfToZr(e), this._textContent && this._textContent.addSelfToZr(e), this._textGuide && this._textGuide.addSelfToZr(e);
		}
	}, e.prototype.removeSelfFromZr = function(e) {
		if (this.__zr) {
			this.__zr = null;
			var t = this.animators;
			if (t) for (var n = 0; n < t.length; n++) e.animation.removeAnimator(t[n]);
			this._clipPath && this._clipPath.removeSelfFromZr(e), this._textContent && this._textContent.removeSelfFromZr(e), this._textGuide && this._textGuide.removeSelfFromZr(e);
		}
	}, e.prototype.animate = function(e, t, n) {
		var r = new Di(e ? this[e] : this, t, n);
		return e && (r.targetName = e), this.addAnimator(r, e), r;
	}, e.prototype.addAnimator = function(e, t) {
		var n = this.__zr, r = this;
		e.during(function() {
			r.updateDuringAnimation(t);
		}).done(function() {
			var t = r.animators, n = P(t, e);
			n >= 0 && t.splice(n, 1);
		}), this.animators.push(e), n && n.animation.addAnimator(e), n && n.wakeUp();
	}, e.prototype.updateDuringAnimation = function(e) {
		this.markRedraw();
	}, e.prototype.stopAnimation = function(e, t) {
		for (var n = this.animators, r = n.length, i = [], a = 0; a < r; a++) {
			var o = n[a];
			!e || e === o.scope ? o.stop(t) : i.push(o);
		}
		return this.animators = i, this;
	}, e.prototype.animateTo = function(e, t, n) {
		Pa(this, e, t, n);
	}, e.prototype.animateFrom = function(e, t, n) {
		Pa(this, e, t, n, !0);
	}, e.prototype._transitionState = function(e, t, n, r) {
		for (var i = Pa(this, t, n, r), a = 0; a < i.length; a++) i[a].__fromStateTransition = e;
	}, e.prototype.getBoundingRect = function() {
		return null;
	}, e.prototype.getPaintRect = function() {
		return null;
	}, e.initDefaultProps = (function() {
		var t = e.prototype;
		t.type = "element", t.name = "", t.ignore = t.silent = t.ignoreHostSilent = t.isGroup = t.draggable = t.dragging = t.ignoreClip = !1, t.__inHover = 0, t.__dirty = 1;
		function n(e, n, r, i) {
			Object.defineProperty(t, e, {
				get: function() {
					if (!this[n]) {
						var e = this[n] = [];
						a(this, e);
					}
					return this[n];
				},
				set: function(e) {
					this[r] = e[0], this[i] = e[1], this[n] = e, a(this, e);
				}
			});
			function a(e, t) {
				Object.defineProperty(t, 0, {
					get: function() {
						return e[r];
					},
					set: function(t) {
						e[r] = t;
					}
				}), Object.defineProperty(t, 1, {
					get: function() {
						return e[i];
					},
					set: function(t) {
						e[i] = t;
					}
				});
			}
		}
		Object.defineProperty && (n("position", "_legacyPos", "x", "y"), n("scale", "_legacyScale", "scaleX", "scaleY"), n("origin", "_legacyOrigin", "originX", "originY"));
	})(), e;
}();
F(Na, dt), F(Na, ca);
function Pa(e, t, n, r, i) {
	n ||= {};
	var a = [];
	Ba(e, "", e, t, n, r, a, i);
	var o = a.length, s = !1, c = n.done, l = n.aborted, u = function() {
		s = !0, o--, o <= 0 && (s ? c && c() : l && l());
	}, d = function() {
		o--, o <= 0 && (s ? c && c() : l && l());
	};
	o || c && c(), a.length > 0 && n.during && a[0].during(function(e, t) {
		n.during(t);
	});
	for (var f = 0; f < a.length; f++) {
		var p = a[f];
		u && p.done(u), d && p.aborted(d), n.force && p.duration(n.duration), p.start(n.easing);
	}
	return a;
}
function Fa(e, t, n) {
	for (var r = 0; r < n; r++) e[r] = t[r];
}
function Ia(e) {
	return ie(e[0]);
}
function La(e, t, n) {
	if (ie(t[n])) {
		if (ie(e[n]) || (e[n] = []), fe(t[n])) {
			var r = t[n].length;
			e[n].length !== r && (e[n] = new t[n].constructor(r), Fa(e[n], t[n], r));
		} else {
			var i = t[n], a = e[n], o = i.length;
			if (Ia(i)) for (var s = i[0].length, c = 0; c < o; c++) a[c] ? Fa(a[c], i[c], s) : a[c] = Array.prototype.slice.call(i[c]);
			else Fa(a, i, o);
			a.length = i.length;
		}
	} else e[n] = t[n];
}
function Ra(e, t) {
	return e === t || ie(e) && ie(t) && za(e, t);
}
function za(e, t) {
	var n = e.length;
	if (n !== t.length) return !1;
	for (var r = 0; r < n; r++) if (e[r] !== t[r]) return !1;
	return !0;
}
function Ba(e, t, n, r, i, a, o, s) {
	for (var c = R(r), l = i.duration, u = i.delay, d = i.additive, f = i.setToFinal, p = !W(a), m = e.animators, h = [], g = 0; g < c.length; g++) {
		var _ = c[g], v = r[_];
		if (v != null && n[_] != null && (p || a[_])) {
			if (W(v) && !ie(v) && !me(v)) {
				if (t) {
					s || (n[_] = v, e.updateDuringAnimation(t));
					continue;
				}
				Ba(e, _, n[_], v, i, a && a[_], o, s);
			} else h.push(_);
		} else s || (n[_] = v, e.updateDuringAnimation(t), h.push(_));
	}
	var y = h.length;
	if (!d && y) for (var b = 0; b < m.length; b++) {
		var x = m[b];
		if (x.targetName === t && x.stopTracks(h)) {
			var S = P(m, x);
			m.splice(S, 1);
		}
	}
	if (i.force || (h = oe(h, function(e) {
		return !Ra(r[e], n[e]);
	}), y = h.length), y > 0 || i.force && !o.length) {
		var C = void 0, w = void 0, T = void 0;
		if (s) {
			w = {}, f && (C = {});
			for (var b = 0; b < y; b++) {
				var _ = h[b];
				w[_] = n[_], f ? C[_] = r[_] : n[_] = r[_];
			}
		} else if (f) {
			T = {};
			for (var b = 0; b < y; b++) {
				var _ = h[b];
				T[_] = pi(n[_]), La(n, r, _);
			}
		}
		var x = new Di(n, !1, !1, d ? oe(m, function(e) {
			return e.targetName === t;
		}) : null);
		x.targetName = t, i.scope && (x.scope = i.scope), f && C && x.whenWithKeys(0, C, h), T && x.whenWithKeys(0, T, h), x.whenWithKeys(l ?? 500, s ? w : r, h).delay(u || 0), e.addAnimator(x, t), o.push(x);
	}
}
function Va(e, t, n, r) {
	return !(n && n.hoverLayer || r) || Ha(e) || t && Ha(t) ? 0 : 1;
}
function Ha(e) {
	return e.type === "text" || e.type === "tspan";
}
function Ua(e, t, n) {
	return !t && !e.__inHover && n && n.duration > 0;
}
//#endregion
//#region node_modules/zrender/lib/graphic/Group.js
var Wa = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this) || this;
		return n.isGroup = !0, n._children = [], n.attr(t), n;
	}
	return t.prototype.childrenRef = function() {
		return this._children;
	}, t.prototype.children = function() {
		return this._children.slice();
	}, t.prototype.childAt = function(e) {
		return this._children[e];
	}, t.prototype.childOfName = function(e) {
		for (var t = this._children, n = 0; n < t.length; n++) if (t[n].name === e) return t[n];
	}, t.prototype.childCount = function() {
		return this._children.length;
	}, t.prototype.add = function(e) {
		return e && e !== this && e.parent !== this && (this._children.push(e), this._doAdd(e)), this;
	}, t.prototype.addBefore = function(e, t) {
		if (e && e !== this && e.parent !== this && t && t.parent === this) {
			var n = this._children, r = n.indexOf(t);
			r >= 0 && (n.splice(r, 0, e), this._doAdd(e));
		}
		return this;
	}, t.prototype.replace = function(e, t) {
		var n = P(this._children, e);
		return n >= 0 && this.replaceAt(t, n), this;
	}, t.prototype.replaceAt = function(e, t) {
		var n = this._children, r = n[t];
		if (e && e !== this && e.parent !== this && e !== r) {
			n[t] = e, r.parent = null;
			var i = this.__zr;
			i && r.removeSelfFromZr(i), this._doAdd(e);
		}
		return this;
	}, t.prototype._doAdd = function(e) {
		e.parent && e.parent.remove(e), e.parent = this;
		var t = this.__zr;
		t && t !== e.__zr && e.addSelfToZr(t), t && t.refresh();
	}, t.prototype.remove = function(e) {
		var t = this.__zr, n = this._children, r = P(n, e);
		return r < 0 || (n.splice(r, 1), e.parent = null, t && e.removeSelfFromZr(t), t && t.refresh()), this;
	}, t.prototype.removeAll = function() {
		for (var e = this._children, t = this.__zr, n = 0; n < e.length; n++) {
			var r = e[n];
			t && r.removeSelfFromZr(t), r.parent = null;
		}
		return e.length = 0, this;
	}, t.prototype.eachChild = function(e, t) {
		for (var n = this._children, r = 0; r < n.length; r++) {
			var i = n[r];
			e.call(t, i, r);
		}
		return this;
	}, t.prototype.traverse = function(e, t) {
		for (var n = 0; n < this._children.length; n++) {
			var r = this._children[n], i = e.call(t, r);
			r.isGroup && !i && r.traverse(e, t);
		}
		return this;
	}, t.prototype.addSelfToZr = function(t) {
		e.prototype.addSelfToZr.call(this, t);
		for (var n = 0; n < this._children.length; n++) this._children[n].addSelfToZr(t);
	}, t.prototype.removeSelfFromZr = function(t) {
		e.prototype.removeSelfFromZr.call(this, t);
		for (var n = 0; n < this._children.length; n++) this._children[n].removeSelfFromZr(t);
	}, t.prototype.getBoundingRect = function(e) {
		for (var t = new Y(0, 0, 0, 0), n = e || this._children, r = [], i = null, a = 0; a < n.length; a++) {
			var o = n[a];
			if (!(o.ignore || o.invisible)) {
				var s = o.getBoundingRect(), c = o.getLocalTransform(r);
				c ? (Y.applyTransform(t, s, c), i ||= t.clone(), i.union(t)) : (i ||= s.clone(), i.union(s));
			}
		}
		return i || t;
	}, t;
}(Na);
Wa.prototype.type = "group";
//#endregion
//#region node_modules/zrender/lib/zrender.js
var Ga = /* @__PURE__ */ e({
	dispose: () => Qa,
	disposeAll: () => $a,
	getElementSSRData: () => ro,
	getInstance: () => eo,
	init: () => Za,
	registerPainter: () => to,
	registerSSRDataGetter: () => io,
	version: () => ao
}), Ka = {}, qa = {};
function Ja(e) {
	delete qa[e];
}
function Ya(e) {
	if (!e) return !1;
	if (typeof e == "string") return $r(e, 1) < Zi;
	if (e.colorStops) {
		for (var t = e.colorStops, n = 0, r = t.length, i = 0; i < r; i++) n += $r(t[i].color, 1);
		return n /= r, n < Zi;
	}
	return !1;
}
var Xa = function() {
	function e(e, t, n) {
		var r = this;
		this._sleepAfterStill = 10, this._stillFrameAccum = 0, this._needsRefresh = !0, this._needsRefreshHover = !1, this._darkMode = !1, n ||= {}, this.dom = t, this.id = e;
		var a = new qn(), o = n.renderer || "canvas";
		Ka[o] || (o = R(Ka)[0]), n.useDirtyRect = n.useDirtyRect != null && n.useDirtyRect;
		var s = new Ka[o](t, a, n, e), c = n.ssr || s.ssrOnly;
		this.storage = a, this.painter = s;
		var l = !i.node && !i.worker && !c ? new Ji(s.getViewportRoot(), s.root) : null, u = n.useCoarsePointer, d = u == null || u === "auto" ? i.touchEventsSupported : !!u, f = 44, p;
		d && (p = G(n.pointerSize, f)), this.handler = new An(a, s, l, s.root, p), this.animation = new ki({ stage: { update: c ? null : function() {
			return r._flush(!1);
		} } }), c || this.animation.start();
	}
	return e.prototype.add = function(e) {
		!this._disposed && e && (this.storage.addRoot(e), e.addSelfToZr(this), this.refresh());
	}, e.prototype.remove = function(e) {
		!this._disposed && e && (this.storage.delRoot(e), e.removeSelfFromZr(this), this.refresh());
	}, e.prototype.configLayer = function(e, t) {
		this._disposed || (this.painter.configLayer && this.painter.configLayer(e, t), this.refresh());
	}, e.prototype.setBackgroundColor = function(e) {
		this._disposed || (this.painter.setBackgroundColor && this.painter.setBackgroundColor(e), this.refresh(), this._backgroundColor = e, this._darkMode = Ya(e));
	}, e.prototype.getBackgroundColor = function() {
		return this._backgroundColor;
	}, e.prototype.setDarkMode = function(e) {
		this._darkMode = e;
	}, e.prototype.isDarkMode = function() {
		return this._darkMode;
	}, e.prototype.refreshImmediately = function(e) {
		this._disposed || this._refresh({
			animUpdate: !e,
			refresh: !0,
			refreshHover: !1
		});
	}, e.prototype._refresh = function(e) {
		e.animUpdate && this.animation.update(!0), this._needsRefresh = this._needsRefreshHover = !1, this.painter.refresh({
			refresh: e.refresh,
			refreshHover: e.refreshHover
		}), this._needsRefresh = this._needsRefreshHover = !1;
	}, e.prototype.refresh = function() {
		this._disposed || (this._needsRefresh = !0, this.animation.start());
	}, e.prototype.flush = function() {
		this._disposed || this._flush(!0);
	}, e.prototype._flush = function(e) {
		var t, n = Oi(), r = this._needsRefresh, i = this._needsRefreshHover;
		(r || i) && (t = !0, this._refresh({
			animUpdate: e,
			refresh: r,
			refreshHover: i
		}));
		var a = Oi();
		t ? (this._stillFrameAccum = 0, this.trigger("rendered", { elapsedTime: a - n })) : this._sleepAfterStill > 0 && (this._stillFrameAccum++, this._stillFrameAccum > this._sleepAfterStill && this.animation.stop());
	}, e.prototype.setSleepAfterStill = function(e) {
		this._sleepAfterStill = e;
	}, e.prototype.wakeUp = function() {
		this._disposed || (this.animation.start(), this._stillFrameAccum = 0);
	}, e.prototype.refreshHover = function() {
		this._needsRefreshHover = !0;
	}, e.prototype.refreshHoverImmediately = function() {
		this._disposed || this._refresh({
			animUpdate: !1,
			refresh: !1,
			refreshHover: !0
		});
	}, e.prototype.resize = function(e) {
		this._disposed || (e ||= {}, this.painter.resize(e.width, e.height), this.handler.resize());
	}, e.prototype.clearAnimation = function() {
		this._disposed || this.animation.clear();
	}, e.prototype.getWidth = function() {
		if (!this._disposed) return this.painter.getWidth();
	}, e.prototype.getHeight = function() {
		if (!this._disposed) return this.painter.getHeight();
	}, e.prototype.setCursorStyle = function(e) {
		this._disposed || this.handler.setCursorStyle(e);
	}, e.prototype.findHover = function(e, t) {
		if (!this._disposed) return this.handler.findHover(e, t);
	}, e.prototype.on = function(e, t, n) {
		return this._disposed || this.handler.on(e, t, n), this;
	}, e.prototype.off = function(e, t) {
		this._disposed || this.handler.off(e, t);
	}, e.prototype.trigger = function(e, t) {
		this._disposed || this.handler.trigger(e, t);
	}, e.prototype.clear = function() {
		if (!this._disposed) {
			for (var e = this.storage.getRoots(), t = 0; t < e.length; t++) e[t] instanceof Wa && e[t].removeSelfFromZr(this);
			this.storage.delAllRoots(), this.painter.clear();
		}
	}, e.prototype.dispose = function() {
		this._disposed || (this.animation.stop(), this.clear(), this.storage.dispose(), this.painter.dispose(), this.handler.dispose(), this.animation = this.storage = this.painter = this.handler = null, this._disposed = !0, Ja(this.id));
	}, e;
}();
function Za(e, t) {
	var n = new Xa(O(), e, t);
	return qa[n.id] = n, n;
}
function Qa(e) {
	e.dispose();
}
function $a() {
	for (var e in qa) qa.hasOwnProperty(e) && qa[e].dispose();
	qa = {};
}
function eo(e) {
	return qa[e];
}
function to(e, t) {
	Ka[e] = t;
}
var no;
function ro(e) {
	if (typeof no == "function") return no(e);
}
function io(e) {
	no = e;
}
var ao = "6.1.0", oo = 1e-4, so = 20;
function co(e) {
	return e.replace(/^\s+|\s+$/g, "");
}
var lo = Math.min, uo = Math.max, fo = Math.abs, po = Math.round, mo = Math.floor, ho = Math.ceil, go = Math.pow, _o = Math.log, vo = Math.LN10, yo = Math.PI, bo = Math.random;
function xo(e, t, n, r) {
	var i = t[0], a = t[1], o = n[0], s = n[1], c = a - i, l = s - o;
	if (c === 0) return l === 0 ? o : (o + s) / 2;
	if (r) {
		if (c > 0) {
			if (e <= i) return o;
			if (e >= a) return s;
		} else if (e >= i) return o;
		else if (e <= a) return s;
	} else {
		if (e === i) return o;
		if (e === a) return s;
	}
	return (e - i) / c * l + o;
}
var So = Co;
function Co(e, t, n) {
	switch (e) {
		case "center":
		case "middle":
			e = "50%";
			break;
		case "left":
		case "top":
			e = "0%";
			break;
		case "right":
		case "bottom": e = "100%";
	}
	return wo(e, t, n);
}
function wo(e, t, n) {
	return U(e) ? To(e) ? parseFloat(e) / 100 * t + (n || 0) : parseFloat(e) : e == null ? NaN : +e;
}
function To(e) {
	return !!co(e).match(/%$/);
}
function Eo(e, t, n) {
	return isNaN(t) ? n ? "" + e : +e : (t = lo(uo(0, t), so), e = (+e).toFixed(t), n ? e : +e);
}
function Do(e, t, n) {
	return t ??= 10, Eo(e, t, n);
}
function Oo(e) {
	return e.sort(function(e, t) {
		return e - t;
	}), e;
}
function ko(e) {
	if (e = +e, isNaN(e)) return 0;
	if (e > 1e-14) {
		for (var t = 1, n = 0; n < 15; n++, t *= 10) if (po(e * t) / t === e) return n;
	}
	return Ao(e);
}
function Ao(e) {
	var t = e.toString().toLowerCase(), n = t.indexOf("e"), r = n > 0 ? +t.slice(n + 1) : 0, i = n > 0 ? n : t.length, a = t.indexOf(".");
	return uo(0, (a < 0 ? 0 : i - 1 - a) - r);
}
function jo(e, t) {
	var n = mo(_o(e[1] - e[0]) / vo), r = po(_o(fo(t[1] - t[0])) / vo), i = lo(uo(-n + r, 0), so);
	return isFinite(i) ? i : so;
}
function Mo(e, t, n) {
	var r = fo(e[1] - e[0]);
	if (!isFinite(r) || r === 0) return NaN;
	var i = _o(2 * fo(n || 1) * fo(r)) / vo, a = _o(fo(t)) / vo, o = uo(0, ho(-i + a));
	return isFinite(o) || (o = NaN), o;
}
function No(e, t, n) {
	return e[t] && Po(e, n)[t] || 0;
}
function Po(e, t) {
	var n = ae(e, function(e, t) {
		return e + (isNaN(t) ? 0 : t);
	}, 0);
	if (n === 0) return [];
	for (var r = go(10, t), i = L(e, function(e) {
		return (isNaN(e) ? 0 : e) / n * r * 100;
	}), a = r * 100, o = L(i, function(e) {
		return mo(e);
	}), s = ae(o, function(e, t) {
		return e + t;
	}, 0), c = L(i, function(e, t) {
		return e - o[t];
	}); s < a;) {
		for (var l = -Infinity, u = null, d = 0, f = c.length; d < f; ++d) c[d] > l && (l = c[d], u = d);
		++o[u], c[u] = 0, ++s;
	}
	return L(o, function(e) {
		return e / r;
	});
}
function Fo(e, t) {
	var n = uo(ko(e), ko(t)), r = e + t;
	return n > so ? r : Eo(r, n);
}
var Io = go(2, 53) - 1;
function Lo(e) {
	var t = yo * 2;
	return (e % t + t) % t;
}
function Ro(e) {
	return e > -oo && e < oo;
}
var zo = /^(?:(\d{4})(?:[-\/](\d{1,2})(?:[-\/](\d{1,2})(?:[T ](\d{1,2})(?::(\d{1,2})(?::(\d{1,2})(?:[.,](\d+))?)?)?(Z|[\+\-]\d\d:?\d\d)?)?)?)?)?$/;
function Bo(e) {
	if (e instanceof Date) return e;
	if (U(e)) {
		var t = zo.exec(e);
		if (!t) return /* @__PURE__ */ new Date(NaN);
		if (t[8]) {
			var n = +t[4] || 0;
			return t[8].toUpperCase() !== "Z" && (n -= +t[8].slice(0, 3)), new Date(Date.UTC(+t[1], (t[2] || 1) - 1, +t[3] || 1, n, +(t[5] || 0), +t[6] || 0, t[7] ? +t[7].substring(0, 3) : 0));
		}
		return new Date(+t[1], (t[2] || 1) - 1, +t[3] || 1, +t[4] || 0, +(t[5] || 0), +t[6] || 0, t[7] ? +t[7].substring(0, 3) : 0);
	}
	return e == null ? /* @__PURE__ */ new Date(NaN) : new Date(po(e));
}
function Vo(e) {
	return go(10, Ho(e));
}
function Ho(e) {
	if (e === 0) return 0;
	var t = mo(_o(e) / vo);
	return e / go(10, t) >= 10 && t++, t;
}
function Uo(e, t) {
	var n = Ho(e), r = go(10, n), i = e / r;
	return e = (t === 2 ? 1 : t ? i < 1.5 ? 1 : i < 2.5 ? 2 : i < 4 ? 3 : i < 7 ? 5 : 10 : i < 1 ? 1 : i < 2 ? 2 : i < 3 ? 3 : i < 5 ? 5 : 10) * r, Eo(e, -n);
}
function Wo(e, t) {
	var n = (e.length - 1) * t + 1, r = mo(n), i = +e[r - 1], a = n - r;
	return a ? i + a * (e[r] - i) : i;
}
function Go(e) {
	e.sort(function(e, t) {
		return s(e, t, 0) ? -1 : 1;
	});
	for (var t = -Infinity, n = 1, r = 0; r < e.length;) {
		for (var i = e[r].interval, a = e[r].close, o = 0; o < 2; o++) i[o] <= t && (i[o] = t, a[o] = o ? 1 : 1 - n), t = i[o], n = a[o];
		i[0] === i[1] && a[0] * a[1] !== 1 ? e.splice(r, 1) : r++;
	}
	return e;
	function s(e, t, n) {
		return e.interval[n] < t.interval[n] || e.interval[n] === t.interval[n] && (e.close[n] - t.close[n] === (n ? -1 : 1) || !n && s(e, t, 1));
	}
}
function Ko(e) {
	var t = parseFloat(e);
	return t == e && (t !== 0 || !U(e) || e.indexOf("x") <= 0) ? t : NaN;
}
function qo(e) {
	return !isNaN(Ko(e));
}
function Jo() {
	return po(bo() * 9);
}
function Yo(e, t) {
	return t === 0 ? e : Yo(t, e % t);
}
function Xo(e, t) {
	return e == null ? t : t == null ? e : e * t / Yo(e, t);
}
function Zo(e) {
	return e != null && isFinite(e);
}
//#endregion
//#region node_modules/echarts/lib/util/log.js
var Qo = "[ECharts] ", $o = {}, es = typeof console < "u" && console.warn && console.log;
function ts(e, t, n) {
	if (es) {
		if (n) {
			if ($o[t]) return;
			$o[t] = !0;
		}
		console[e](Qo + t);
	}
}
function ns(e, t) {
	ts("error", e, t);
}
function rs(e) {
	throw Error(e);
}
//#endregion
//#region node_modules/echarts/lib/util/model.js
function is(e, t, n) {
	return (t - e) * n + e;
}
var as = "series\0", os = "\0_ec_\0";
function ss(e) {
	return e instanceof Array ? e : e == null ? [] : [e];
}
function cs(e, t, n) {
	if (e) {
		e[t] = e[t] || {}, e.emphasis = e.emphasis || {}, e.emphasis[t] = e.emphasis[t] || {};
		for (var r = 0, i = n.length; r < i; r++) {
			var a = n[r];
			!e.emphasis[t].hasOwnProperty(a) && e[t].hasOwnProperty(a) && (e.emphasis[t][a] = e[t][a]);
		}
	}
}
var ls = /* @__PURE__ */ "fontStyle.fontWeight.fontSize.fontFamily.rich.tag.color.textBorderColor.textBorderWidth.width.height.lineHeight.align.verticalAlign.baseline.shadowColor.shadowBlur.shadowOffsetX.shadowOffsetY.textShadowColor.textShadowBlur.textShadowOffsetX.textShadowOffsetY.backgroundColor.borderColor.borderWidth.borderRadius.padding".split(".");
function us(e) {
	return W(e) && !V(e) && !(e instanceof Date) ? e.value : e;
}
function ds(e) {
	return W(e) && !(e instanceof Array);
}
function fs(e, t, n) {
	var r = n === "normalMerge", i = n === "replaceMerge", a = n === "replaceAll";
	e ||= [], t = (t || []).slice();
	var o = K();
	I(t, function(e, n) {
		W(e) || (t[n] = null);
	});
	var s = ps(e, o, n);
	return (r || i) && ms(s, e, o, t), r && hs(s, t), r || i ? gs(s, t, i) : a && _s(s, t), vs(s), s;
}
function ps(e, t, n) {
	var r = [];
	if (n === "replaceAll") return r;
	for (var i = 0; i < e.length; i++) {
		var a = e[i];
		a && a.id != null && t.set(a.id, i), r.push({
			existing: n === "replaceMerge" || Cs(a) ? null : a,
			newOption: null,
			keyInfo: null,
			brandNew: null
		});
	}
	return r;
}
function ms(e, t, n, r) {
	I(r, function(i, a) {
		if (i && i.id != null) {
			var o = bs(i.id), s = n.get(o);
			if (s != null) {
				var c = e[s];
				Se(!c.newOption, "Duplicated option on id \"" + o + "\"."), c.newOption = i, c.existing = t[s], r[a] = null;
			}
		}
	});
}
function hs(e, t) {
	I(t, function(n, r) {
		if (n && n.name != null) for (var i = 0; i < e.length; i++) {
			var a = e[i].existing;
			if (!e[i].newOption && a && (a.id == null || n.id == null) && !Cs(n) && !Cs(a) && ys("name", a, n)) {
				e[i].newOption = n, t[r] = null;
				return;
			}
		}
	});
}
function gs(e, t, n) {
	I(t, function(t) {
		if (t) {
			for (var r, i = 0; (r = e[i]) && (r.newOption || Cs(r.existing) || r.existing && t.id != null && !ys("id", t, r.existing));) i++;
			r ? (r.newOption = t, r.brandNew = n) : e.push({
				newOption: t,
				brandNew: n,
				existing: null,
				keyInfo: null
			}), i++;
		}
	});
}
function _s(e, t) {
	I(t, function(t) {
		e.push({
			newOption: t,
			brandNew: !0,
			existing: null,
			keyInfo: null
		});
	});
}
function vs(e) {
	var t = K();
	I(e, function(e) {
		var n = e.existing;
		n && t.set(n.id, e);
	}), I(e, function(e) {
		var n = e.newOption;
		Se(!n || n.id == null || !t.get(n.id) || t.get(n.id) === e, "id duplicates: " + (n && n.id)), n && n.id != null && t.set(n.id, e), !e.keyInfo && (e.keyInfo = {});
	}), I(e, function(e, n) {
		var r = e.existing, i = e.newOption, a = e.keyInfo;
		if (W(i)) {
			if (a.name = i.name == null ? r ? r.name : as + n : bs(i.name), r) a.id = bs(r.id);
			else if (i.id != null) a.id = bs(i.id);
			else {
				var o = 0;
				do
					a.id = "\0" + a.name + "\0" + o++;
				while (t.get(a.id));
			}
			t.set(a.id, e);
		}
	});
}
function ys(e, t, n) {
	var r = xs(t[e], null), i = xs(n[e], null);
	return r != null && i != null && r === i;
}
function bs(e) {
	return xs(e, "");
}
function xs(e, t) {
	return e == null ? t : U(e) ? e : ue(e) || le(e) ? e + "" : t;
}
function Ss(e) {
	var t = e.name;
	return !!(t && t.indexOf(as));
}
function Cs(e) {
	return e && e.id != null && bs(e.id).indexOf(os) === 0;
}
function ws(e, t, n) {
	I(e, function(e) {
		var r = e.newOption;
		W(r) && (e.keyInfo.mainType = t, e.keyInfo.subType = Ts(t, r, e.existing, n));
	});
}
function Ts(e, t, n, r) {
	return t.type ? t.type : n ? n.subType : r.determineSubType(e, t);
}
function Es(e, t) {
	var n = {}, r = {};
	return i(e || [], n), i(t || [], r, n), [a(n), a(r)];
	function i(e, t, n) {
		for (var r = 0, i = e.length; r < i; r++) {
			var a = xs(e[r].seriesId, null);
			if (a == null) return;
			for (var o = ss(e[r].dataIndex), s = n && n[a], c = 0, l = o.length; c < l; c++) {
				var u = o[c];
				s && s[u] ? s[u] = null : (t[a] || (t[a] = {}))[u] = 1;
			}
		}
	}
	function a(e, t) {
		var n = [];
		for (var r in e) if (e.hasOwnProperty(r) && e[r] != null) {
			if (t) n.push(+r);
			else {
				var i = a(e[r], !0);
				i.length && n.push({
					seriesId: r,
					dataIndex: i
				});
			}
		}
		return n;
	}
}
function Ds(e, t) {
	if (t.dataIndexInside != null) return t.dataIndexInside;
	if (t.dataIndex != null) return V(t.dataIndex) ? L(t.dataIndex, function(t) {
		return e.indexOfRawIndex(t);
	}) : e.indexOfRawIndex(t.dataIndex);
	if (t.name != null) return V(t.name) ? L(t.name, function(t) {
		return e.indexOfName(t);
	}) : e.indexOfName(t.name);
}
function X() {
	var e = "__ec_inner_" + Os++;
	return function(t) {
		return t[e] || (t[e] = {});
	};
}
var Os = Jo();
function ks(e, t, n) {
	var r = As(t, n), i = r.mainTypeSpecified, a = r.queryOptionMap, o = r.others, s = n ? n.defaultMainType : null;
	return !i && s && a.set(s, {}), a.each(function(t, r) {
		var i = Ns(e, r, t, {
			useDefault: s === r,
			enableAll: n && n.enableAll != null ? n.enableAll : !0,
			enableNone: n && n.enableNone != null ? n.enableNone : !0
		});
		o[r + "Models"] = i.models, o[r + "Model"] = i.models[0];
	}), o;
}
function As(e, t) {
	var n;
	if (U(e)) {
		var r = {};
		r[e + "Index"] = 0, n = r;
	} else n = e;
	var i = K(), a = {}, o = !1;
	return I(n, function(e, n) {
		if (n === "dataIndex" || n === "dataIndexInside") a[n] = e;
		else {
			var r = n.match(/^(\w+)(Index|Id|Name)$/) || [], s = r[1], c = (r[2] || "").toLowerCase();
			if (!(!s || !c || t && t.includeMainTypes && P(t.includeMainTypes, s) < 0)) {
				o ||= !!s;
				var l = i.get(s) || i.set(s, {});
				l[c] = e;
			}
		}
	}), {
		mainTypeSpecified: o,
		queryOptionMap: i,
		others: a
	};
}
var js = {
	useDefault: !0,
	enableAll: !1,
	enableNone: !1
}, Ms = {
	useDefault: !1,
	enableAll: !0,
	enableNone: !0
};
function Ns(e, t, n, r) {
	r ||= js;
	var i = n.index, a = n.id, o = n.name, s = {
		models: null,
		specified: i != null || a != null || o != null
	};
	if (!s.specified) {
		var c = void 0;
		return s.models = r.useDefault && (c = e.getComponent(t)) ? [c] : [], s;
	}
	if (i === "none" || i === !1) {
		if (r.enableNone) return s.models = [], s;
		i = -1;
	}
	return i === "all" && (i = r.enableAll ? a = o = null : -1), s.models = e.queryComponents({
		mainType: t,
		index: i,
		id: a,
		name: o
	}), s;
}
function Ps(e, t, n) {
	var r = {};
	r[t + "Id"] = e[t + "Id"], r[t + "Index"] = e[t + "Index"], r[t + "Name"] = e[t + "Name"];
	var i = {
		mainType: t,
		query: r
	};
	return n && (i.subType = n), i;
}
function Fs(e, t, n) {
	e.setAttribute ? e.setAttribute(t, n) : e[t] = n;
}
function Is(e, t) {
	return e.getAttribute ? e.getAttribute(t) : e[t];
}
function Ls(e) {
	return e === "auto" ? i.domSupported ? "html" : "richText" : e || "html";
}
function Rs(e, t, n, r, i) {
	var a = t == null || t === "auto";
	if (r == null) return r;
	if (ue(r)) {
		var o = is(n || 0, r, i);
		return Eo(o, a ? Math.max(ko(n || 0), ko(r)) : t);
	}
	if (U(r)) return i < 1 ? n : r;
	for (var s = [], c = n, l = r, u = Math.max(c ? c.length : 0, l.length), d = 0; d < u; ++d) {
		var f = e.getDimensionInfo(d);
		if (f && f.type === "ordinal") s[d] = (i < 1 && c ? c : l)[d];
		else {
			var p = c && c[d] ? c[d] : 0, m = l[d], o = is(p, m, i);
			s[d] = Eo(o, a ? Math.max(ko(p), ko(m)) : t);
		}
	}
	return s;
}
(function() {
	function e() {}
	return e.prototype.reset = function(e, t, n, r) {
		return this._list = e, this._step = r ||= 1, this._idx = t, this._end = n ?? (r > 0 ? e.length : 0), this.item = null, this.key = NaN, this;
	}, e.prototype.next = function() {
		return (this._step > 0 ? this._idx < this._end : this._idx >= this._end) && (this.item = this._list[this._idx], this.key = this._idx += this._step, !0);
	}, e;
})();
function zs() {
	return [Infinity, -Infinity];
}
function Bs(e, t) {
	Ws(t) && (t < e[0] && (e[0] = t), t > e[1] && (e[1] = t));
}
function Vs(e, t) {
	Ws(t) && t < e[0] && (e[0] = t);
}
function Hs(e, t) {
	Ws(t) && t > e[1] && (e[1] = t);
}
function Us(e, t) {
	Gs(t[0], t[1]) && (t[0] < e[0] && (e[0] = t[0]), t[1] > e[1] && (e[1] = t[1]));
}
function Ws(e) {
	return e != null && isFinite(e);
}
function Gs(e, t) {
	return Ws(e) && Ws(t) && e <= t;
}
function Ks(e) {
	var t = e[1] - e[0];
	return isFinite(t) && t >= 0;
}
function qs(e) {
	Gs(e[0], e[1]) && e[0] > e[1] && (e[0] = e[1]);
}
function Js() {
	var e = "__ec_once_" + Ys++;
	return function(t, n) {
		q(t, e) || (t[e] = 1, n());
	};
}
var Ys = Jo();
function Xs(e, t, n) {
	var r = K(), i = 0;
	I(e, function(a) {
		var o = t(a), s = r.get(o) || 0;
		n && n(a, s), !s && !n && (e[i++] = a), r.set(o, s + 1);
	}), n || (e.length = i);
}
function Zs(e) {
	return e.value + "";
}
function Qs(e) {
	return e + "";
}
function $s(e, t) {
	return G(t, !0) ? e.seriesIndex + 2 : 0;
}
function ec(e, t, n) {
	var r = e.getData().count();
	return {
		progressiveRender: n.progressiveEnabled && t.incrementalPrepareRender && r >= n.threshold,
		large: e.get("large") && r >= e.get("largeThreshold"),
		modDataCount: e.get("progressiveChunkMode") === "mod" ? e.getData().count() : null
	};
}
function tc(e, t) {
	return {
		seriesType: e,
		overallReset: t
	};
}
function nc(e) {
	return { overallReset: e };
}
//#endregion
//#region node_modules/echarts/lib/util/clazz.js
var rc = ".", ic = "___EC__COMPONENT__CONTAINER___", ac = "___EC__EXTENDED_CLASS___";
function oc(e) {
	var t = {
		main: "",
		sub: ""
	};
	if (e) {
		var n = e.split(rc);
		t.main = n[0] || "", t.sub = n[1] || "";
	}
	return t;
}
function sc(e) {
	Se(/^[a-zA-Z0-9_]+([.][a-zA-Z0-9_]+)?$/.test(e), "componentType \"" + e + "\" illegal");
}
function cc(e) {
	return !!(e && e[ac]);
}
function lc(e, t) {
	e.$constructor = e, e.extend = function(e) {
		var t = this, r;
		return uc(t) ? r = function(e) {
			n(t, e);
			function t() {
				return e.apply(this, arguments) || this;
			}
			return t;
		}(t) : (r = function() {
			(e.$constructor || t).apply(this, arguments);
		}, re(r, this)), M(r.prototype, e), r[ac] = !0, r.extend = this.extend, r.superCall = mc, r.superApply = hc, r.superClass = t, r;
	};
}
function uc(e) {
	return H(e) && /^class\s/.test(Function.prototype.toString.call(e));
}
function dc(e, t) {
	e.extend = t.extend;
}
var fc = Math.round(Math.random() * 10);
function pc(e) {
	var t = ["__\0is_clz", fc++].join("_");
	e.prototype[t] = !0, e.isInstance = function(e) {
		return !!(e && e[t]);
	};
}
function mc(e, t) {
	var n = [...arguments].slice(2);
	return this.superClass.prototype[t].apply(e, n);
}
function hc(e, t, n) {
	return this.superClass.prototype[t].apply(e, n);
}
function gc(e) {
	var t = {};
	e.registerClass = function(e) {
		var r = e.type || e.prototype.type;
		if (r) {
			sc(r), e.prototype.type = r;
			var i = oc(r);
			if (!i.sub) t[i.main] = e;
			else if (i.sub !== ic) {
				var a = n(i);
				a[i.sub] = e;
			}
		}
		return e;
	}, e.getClass = function(e, n, r) {
		var i = t[e];
		if (i && i[ic] && (i = n ? i[n] : null), r && !i) throw Error(n ? "Component " + e + "." + (n || "") + " is used but not imported." : e + ".type should be specified.");
		return i;
	}, e.getClassesByMainType = function(e) {
		var n = oc(e), r = [], i = t[n.main];
		return i && i[ic] ? I(i, function(e, t) {
			t !== ic && r.push(e);
		}) : r.push(i), r;
	}, e.hasClass = function(e) {
		return !!t[oc(e).main];
	}, e.getAllClassMainTypes = function() {
		var e = [];
		return I(t, function(t, n) {
			e.push(n);
		}), e;
	}, e.hasSubTypes = function(e) {
		var n = t[oc(e).main];
		return n && n[ic];
	};
	function n(e) {
		var n = t[e.main];
		return (!n || !n[ic]) && (n = t[e.main] = {}, n[ic] = !0), n;
	}
}
//#endregion
//#region node_modules/echarts/lib/model/mixin/makeStyleMapper.js
function _c(e, t) {
	for (var n = 0; n < e.length; n++) e[n][1] || (e[n][1] = e[n][0]);
	return t ||= !1, function(n, r, i) {
		for (var a = {}, o = 0; o < e.length; o++) {
			var s = e[o][1];
			if (!(r && P(r, s) >= 0 || i && P(i, s) < 0)) {
				var c = n.getShallow(s, t);
				c != null && (a[e[o][0]] = c);
			}
		}
		return a;
	};
}
var vc = _c([
	["fill", "color"],
	["shadowBlur"],
	["shadowOffsetX"],
	["shadowOffsetY"],
	["opacity"],
	["shadowColor"]
]), yc = function() {
	function e() {}
	return e.prototype.getAreaStyle = function(e, t) {
		return vc(this, e, t);
	}, e;
}(), bc = new Er(50);
function xc(e) {
	if (typeof e == "string") {
		var t = bc.get(e);
		return t && t.image;
	}
	return e;
}
function Sc(e, t, n, r, i) {
	if (!e) return t;
	if (typeof e == "string") {
		if (t && t.__zrImageSrc === e || !n) return t;
		var a = bc.get(e), o = {
			hostEl: n,
			cb: r,
			cbPayload: i
		};
		return a ? (t = a.image, !wc(t) && a.pending.push(o)) : (t = f.loadImage(e, Cc, Cc), t.__zrImageSrc = e, bc.put(e, t.__cachedImgObj = {
			image: t,
			pending: [o]
		})), t;
	}
	return e;
}
function Cc() {
	var e = this.__cachedImgObj;
	this.onload = this.onerror = this.__cachedImgObj = null;
	for (var t = 0; t < e.pending.length; t++) {
		var n = e.pending[t], r = n.cb;
		r && r(this, n.cbPayload), n.hostEl.dirty();
	}
	e.pending.length = 0;
}
function wc(e) {
	return e && e.width && e.height;
}
//#endregion
//#region node_modules/zrender/lib/graphic/helper/parseText.js
var Tc = /\{([a-zA-Z0-9_]+)\|([^}]*)\}/g;
function Ec(e, t, n, r, i) {
	var a = {};
	return Dc(a, e, t, n, r, i), a.text;
}
function Dc(e, t, n, r, i, a) {
	if (!n) e.text = "", e.isTruncated = !1;
	else {
		var o = (t + "").split("\n");
		a = Oc(n, r, i, a);
		for (var s = !1, c = {}, l = 0, u = o.length; l < u; l++) kc(c, o[l], a), o[l] = c.textLine, s ||= c.isTruncated;
		e.text = o.join("\n"), e.isTruncated = s;
	}
}
function Oc(e, t, n, r) {
	r ||= {};
	var i = M({}, r);
	n = G(n, "..."), i.maxIterations = G(r.maxIterations, 2);
	var a = i.minChar = G(r.minChar, 0), o = i.fontMeasureInfo = pa(t), s = o.asciiCharWidth;
	i.placeholder = G(r.placeholder, "");
	for (var c = e = Math.max(0, e - 1), l = 0; l < a && c >= s; l++) c -= s;
	var u = ya(o, n);
	return u > c && (n = "", u = 0), c = e - u, i.ellipsis = n, i.ellipsisWidth = u, i.contentWidth = c, i.containerWidth = e, i;
}
function kc(e, t, n) {
	var r = n.containerWidth, i = n.contentWidth, a = n.fontMeasureInfo;
	if (!r) e.textLine = "", e.isTruncated = !1;
	else {
		var o = ya(a, t);
		if (o <= r) e.textLine = t, e.isTruncated = !1;
		else {
			for (var s = 0;; s++) {
				if (o <= i || s >= n.maxIterations) {
					t += n.ellipsis;
					break;
				}
				var c = s === 0 ? Ac(t, i, a) : o > 0 ? Math.floor(t.length * i / o) : 0;
				t = t.substr(0, c), o = ya(a, t);
			}
			t === "" && (t = n.placeholder), e.textLine = t, e.isTruncated = !0;
		}
	}
}
function Ac(e, t, n) {
	for (var r = 0, i = 0, a = e.length; i < a && r < t; i++) r += va(n, e.charCodeAt(i));
	return i;
}
function jc(e, t, n, r) {
	var i = Wc(e), a = t.overflow, o = t.padding, s = o ? o[1] + o[3] : 0, c = o ? o[0] + o[2] : 0, l = t.font, u = a === "truncate", d = wa(l), f = G(t.lineHeight, d), p = t.lineOverflow === "truncate", m = !1, h = t.width;
	h == null && n != null && (h = n - s);
	var g = t.height;
	g == null && r != null && (g = r - c);
	var _ = h != null && (a === "break" || a === "breakAll") ? i ? Bc(i, t.font, h, a === "breakAll", 0).lines : [] : i ? i.split("\n") : [], v = _.length * f;
	if (g ??= v, v > g && p) {
		var y = Math.floor(g / f);
		m ||= _.length > y, _ = _.slice(0, y), v = _.length * f;
	}
	if (i && u && h != null) for (var b = Oc(h, l, t.ellipsis, {
		minChar: t.truncateMinChar,
		placeholder: t.placeholder
	}), x = {}, S = 0; S < _.length; S++) kc(x, _[S], b), _[S] = x.textLine, m ||= x.isTruncated;
	for (var C = g, w = 0, T = pa(l), S = 0; S < _.length; S++) w = Math.max(ya(T, _[S]), w);
	h ??= w;
	var E = h;
	return C += c, E += s, {
		lines: _,
		height: g,
		outerWidth: E,
		outerHeight: C,
		lineHeight: f,
		calculatedLineHeight: d,
		contentWidth: w,
		contentHeight: v,
		width: h,
		isTruncated: m
	};
}
var Mc = function() {
	function e() {}
	return e;
}(), Nc = function() {
	function e(e) {
		this.tokens = [], e && (this.tokens = e);
	}
	return e;
}(), Pc = function() {
	function e() {
		this.width = 0, this.height = 0, this.contentWidth = 0, this.contentHeight = 0, this.outerWidth = 0, this.outerHeight = 0, this.lines = [], this.isTruncated = !1;
	}
	return e;
}();
function Fc(e, t, n, r, i) {
	var a = new Pc(), o = Wc(e);
	if (!o) return a;
	var s = t.padding, c = s ? s[1] + s[3] : 0, l = s ? s[0] + s[2] : 0, u = t.width;
	u == null && n != null && (u = n - c);
	var d = t.height;
	d == null && r != null && (d = r - l);
	for (var f = t.overflow, p = (f === "break" || f === "breakAll") && u != null ? {
		width: u,
		accumWidth: 0,
		breakAll: f === "breakAll"
	} : null, m = Tc.lastIndex = 0, h; (h = Tc.exec(o)) != null;) {
		var g = h.index;
		g > m && Ic(a, o.substring(m, g), t, p), Ic(a, h[2], t, p, h[1]), m = Tc.lastIndex;
	}
	m < o.length && Ic(a, o.substring(m, o.length), t, p);
	var _ = [], v = 0, y = 0, b = f === "truncate", x = t.lineOverflow === "truncate", S = {};
	function C(e, t, n) {
		e.width = t, e.lineHeight = n, v += n, y = Math.max(y, t);
	}
	outer: for (var w = 0; w < a.lines.length; w++) {
		for (var T = a.lines[w], E = 0, D = 0, O = 0; O < T.tokens.length; O++) {
			var k = T.tokens[O], A = k.styleName && t.rich[k.styleName] || {}, j = k.textPadding = A.padding, ee = j ? j[1] + j[3] : 0, M = k.font = A.font || t.font;
			k.contentHeight = wa(M);
			var te = G(A.height, k.contentHeight);
			if (k.innerHeight = te, j && (te += j[0] + j[2]), k.height = te, k.lineHeight = ye(A.lineHeight, t.lineHeight, te), k.align = A && A.align || i, k.verticalAlign = A && A.verticalAlign || "middle", x && d != null && v + k.lineHeight > d) {
				var N = a.lines.length;
				O > 0 ? (T.tokens = T.tokens.slice(0, O), C(T, D, E), a.lines = a.lines.slice(0, w + 1)) : a.lines = a.lines.slice(0, w), a.isTruncated = a.isTruncated || a.lines.length < N;
				break outer;
			}
			var ne = A.width, P = ne == null || ne === "auto";
			if (typeof ne == "string" && ne.charAt(ne.length - 1) === "%") k.percentWidth = ne, _.push(k), k.contentWidth = ya(pa(M), k.text);
			else {
				if (P) {
					var re = A.backgroundColor, F = re && re.image;
					F && (F = xc(F), wc(F) && (k.width = Math.max(k.width, F.width * te / F.height)));
				}
				var ie = b && u != null ? u - D : null;
				ie != null && ie < k.width ? !P || ie < ee ? (k.text = "", k.width = k.contentWidth = 0) : (Dc(S, k.text, ie - ee, M, t.ellipsis, { minChar: t.truncateMinChar }), k.text = S.text, a.isTruncated = a.isTruncated || S.isTruncated, k.width = k.contentWidth = ya(pa(M), k.text)) : k.contentWidth = ya(pa(M), k.text);
			}
			k.width += ee, D += k.width, A && (E = Math.max(E, k.lineHeight));
		}
		C(T, D, E);
	}
	a.outerWidth = a.width = G(u, y), a.outerHeight = a.height = G(d, v), a.contentHeight = v, a.contentWidth = y, a.outerWidth += c, a.outerHeight += l;
	for (var w = 0; w < _.length; w++) {
		var k = _[w], I = k.percentWidth;
		k.width = parseInt(I, 10) / 100 * a.width;
	}
	return a;
}
function Ic(e, t, n, r, i) {
	var a = t === "", o = i && n.rich[i] || {}, s = e.lines, c = o.font || n.font, l = !1, u, d;
	if (r) {
		var f = o.padding, p = f ? f[1] + f[3] : 0;
		if (o.width != null && o.width !== "auto") {
			var m = Ta(o.width, r.width) + p;
			s.length > 0 && m + r.accumWidth > r.width && (u = t.split("\n"), l = !0), r.accumWidth = m;
		} else {
			var h = Bc(t, c, r.width, r.breakAll, r.accumWidth);
			r.accumWidth = h.accumWidth + p, d = h.linesWidths, u = h.lines;
		}
	}
	u ||= t.split("\n");
	for (var g = pa(c), _ = 0; _ < u.length; _++) {
		var v = u[_], y = new Mc();
		if (y.styleName = i, y.text = v, y.isLineHolder = !v && !a, y.width = typeof o.width == "number" ? o.width : d ? d[_] : ya(g, v), !_ && !l) {
			var b = (s[s.length - 1] || (s[0] = new Nc())).tokens, x = b.length;
			x === 1 && b[0].isLineHolder ? b[0] = y : (v || !x || a) && b.push(y);
		} else s.push(new Nc([y]));
	}
}
function Lc(e) {
	var t = e.charCodeAt(0);
	return t >= 32 && t <= 591 || t >= 880 && t <= 4351 || t >= 4608 && t <= 5119 || t >= 7680 && t <= 8303;
}
var Rc = ae(",&?/;] ".split(""), function(e, t) {
	return e[t] = !0, e;
}, {});
function zc(e) {
	return !Lc(e) || !!Rc[e];
}
function Bc(e, t, n, r, i) {
	for (var a = [], o = [], s = "", c = "", l = 0, u = 0, d = pa(t), f = 0; f < e.length; f++) {
		var p = e.charAt(f);
		if (p === "\n") c && (s += c, u += l), a.push(s), o.push(u), s = "", c = "", l = 0, u = 0;
		else {
			var m = va(d, p.charCodeAt(0)), h = !r && !zc(p);
			(a.length ? u + m > n : i + u + m > n) ? u ? (s || c) && (h ? (s || (s = c, c = "", l = 0, u = l), a.push(s), o.push(u - l), c += p, l += m, s = "", u = l) : (c && (s += c, c = "", l = 0), a.push(s), o.push(u), s = p, u = m)) : h ? (a.push(c), o.push(l), c = p, l = m) : (a.push(p), o.push(m)) : (u += m, h ? (c += p, l += m) : (c && (s += c, c = "", l = 0), s += p));
		}
	}
	return c && (s += c), s && (a.push(s), o.push(u)), a.length === 1 && (u += i), {
		accumWidth: u,
		lines: a,
		linesWidths: o
	};
}
function Vc(e, t, n, r, i, a) {
	if (e.baseX = n, e.baseY = r, e.outerWidth = e.outerHeight = null, t) {
		var o = t.width * 2, s = t.height * 2;
		Y.set(Hc, Sa(n, o, i), Ca(r, s, a), o, s), Y.intersect(t, Hc, null, Uc);
		var c = Uc.outIntersectRect;
		e.outerWidth = c.width, e.outerHeight = c.height, e.baseX = Sa(c.x, c.width, i, !0), e.baseY = Ca(c.y, c.height, a, !0);
	}
}
var Hc = new Y(0, 0, 0, 0), Uc = {
	outIntersectRect: {},
	clamp: !0
};
function Wc(e) {
	return e == null ? e = "" : e += "";
}
function Gc(e) {
	var t = Wc(e.text), n = e.font;
	return Kc(e, ya(pa(n), t), wa(n), null);
}
function Kc(e, t, n, r) {
	var i = new Y(Sa(e.x || 0, t, e.textAlign), Ca(e.y || 0, n, e.textBaseline), t, n), a = r ?? (qc(e) ? e.lineWidth : 0);
	return a > 0 && (i.x -= a / 2, i.y -= a / 2, i.width += a, i.height += a), i;
}
function qc(e) {
	var t = e.stroke;
	return t != null && t !== "none" && e.lineWidth > 0;
}
//#endregion
//#region node_modules/zrender/lib/graphic/Displayable.js
var Jc = "__zr_style_" + Math.round(Math.random() * 10), Yc = {
	shadowBlur: 0,
	shadowOffsetX: 0,
	shadowOffsetY: 0,
	shadowColor: "#000",
	opacity: 1,
	blend: "source-over"
}, Xc = { style: {
	shadowBlur: !0,
	shadowOffsetX: !0,
	shadowOffsetY: !0,
	shadowColor: !0,
	opacity: !0
} };
Yc[Jc] = !0;
var Zc = [
	"z",
	"z2",
	"invisible"
], Qc = ["invisible"], $c = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype._init = function(t) {
		for (var n = R(t), r = 0; r < n.length; r++) {
			var i = n[r];
			i === "style" ? this.useStyle(t[i]) : e.prototype.attrKV.call(this, i, t[i]);
		}
		this.style || this.useStyle({});
	}, t.prototype.beforeBrush = function(e) {}, t.prototype.afterBrush = function() {}, t.prototype.innerBeforeBrush = function() {}, t.prototype.innerAfterBrush = function() {}, t.prototype.shouldBePainted = function(e, t, n, r) {
		var i = this.transform;
		if (this.ignore || this.invisible || this.style.opacity === 0 || this.culling && nl(this, e, t) || i && !i[0] && !i[3]) return !1;
		if (n && this.__clipPaths && this.__clipPaths.length) {
			for (var a = 0; a < this.__clipPaths.length; ++a) if (this.__clipPaths[a].isZeroArea()) return !1;
		}
		if (r && this.parent) for (var o = this.parent; o;) {
			if (o.ignore) return !1;
			o = o.parent;
		}
		return !0;
	}, t.prototype.contain = function(e, t) {
		return this.rectContain(e, t);
	}, t.prototype.traverse = function(e, t) {
		e.call(t, this);
	}, t.prototype.rectContain = function(e, t) {
		var n = this.transformCoordToLocal(e, t);
		return this.getBoundingRect().contain(n[0], n[1]);
	}, t.prototype.getPaintRect = function() {
		var e = this._paintRect;
		if (!this._paintRect || this.__dirty) {
			var t = this.transform, n = this.getBoundingRect(), r = this.style, i = r.shadowBlur || 0, a = r.shadowOffsetX || 0, o = r.shadowOffsetY || 0;
			e = this._paintRect ||= new Y(0, 0, 0, 0), t ? Y.applyTransform(e, n, t) : e.copy(n), (i || a || o) && (e.width += i * 2 + Math.abs(a), e.height += i * 2 + Math.abs(o), e.x = Math.min(e.x, e.x + a - i), e.y = Math.min(e.y, e.y + o - i));
			var s = this.dirtyRectTolerance;
			e.isZero() || (e.x = Math.floor(e.x - s), e.y = Math.floor(e.y - s), e.width = Math.ceil(e.width + 1 + s * 2), e.height = Math.ceil(e.height + 1 + s * 2));
		}
		return e;
	}, t.prototype.setPrevPaintRect = function(e) {
		e ? (this._prevPaintRect = this._prevPaintRect || new Y(0, 0, 0, 0), this._prevPaintRect.copy(e)) : this._prevPaintRect = null;
	}, t.prototype.getPrevPaintRect = function() {
		return this._prevPaintRect;
	}, t.prototype.animateStyle = function(e) {
		return this.animate("style", e);
	}, t.prototype.updateDuringAnimation = function(e) {
		e === "style" ? this.dirtyStyle() : this.markRedraw();
	}, t.prototype.attrKV = function(t, n) {
		t === "style" ? this.style ? this.setStyle(n) : this.useStyle(n) : e.prototype.attrKV.call(this, t, n);
	}, t.prototype.setStyle = function(e, t) {
		return typeof e == "string" ? this.style[e] = t : M(this.style, e), this.dirtyStyle(), this;
	}, t.prototype.dirtyStyle = function(e) {
		e || this.markRedraw(), this.__dirty |= 2, this._rect &&= null;
	}, t.prototype.dirty = function() {
		this.dirtyStyle();
	}, t.prototype.styleChanged = function() {
		return !!(this.__dirty & 2);
	}, t.prototype.styleUpdated = function() {
		this.__dirty &= -3;
	}, t.prototype.createStyle = function(e) {
		return Me(Yc, e);
	}, t.prototype.useStyle = function(e) {
		e[Jc] || (e = this.createStyle(e)), this.style = e, this.dirtyStyle();
	}, t.prototype._useHoverStyle = function(e) {
		this.__hoverStyle = e;
	}, t.prototype.isStyleObject = function(e) {
		return e[Jc];
	}, t.prototype._innerSaveToNormal = function(t) {
		e.prototype._innerSaveToNormal.call(this, t);
		var n = this._normalState;
		t.style && !n.style && (n.style = this._mergeStyle(this.createStyle(), this.style)), this._savePrimaryToNormal(t, n, Zc);
	}, t.prototype._applyStateObj = function(t, n, r, i, a, o) {
		e.prototype._applyStateObj.call(this, t, n, r, i, a, o);
		var s = !(n && i), c = this.__inHover === 1, l;
		if (n && n.style ? a ? i ? l = n.style : (l = this._mergeStyle(this.createStyle(), r.style), this._mergeStyle(l, n.style)) : (l = this._mergeStyle(this.createStyle(), i ? this.style : r.style), this._mergeStyle(l, n.style)) : s && (l = r.style), l) {
			if (a) {
				var u = this.style;
				if (this.style = this.createStyle(s ? {} : u), s) for (var d = R(u), f = 0; f < d.length; f++) {
					var p = d[f];
					p in l && (l[p] = l[p], this.style[p] = u[p]);
				}
				for (var m = R(l), f = 0; f < m.length; f++) {
					var p = m[f];
					this.style[p] = this.style[p];
				}
				this._transitionState(t, { style: l }, o, this.getAnimationStyleProps());
			} else c ? this._useHoverStyle(l) : this.useStyle(l);
		}
		if (!c) for (var h = this.__inHover ? Qc : Zc, f = 0; f < h.length; f++) {
			var p = h[f];
			n && n[p] != null ? this[p] = n[p] : s && r[p] != null && (this[p] = r[p]);
		}
	}, t.prototype._mergeStates = function(t) {
		for (var n = e.prototype._mergeStates.call(this, t), r, i = 0; i < t.length; i++) {
			var a = t[i];
			a.style && (r ||= {}, this._mergeStyle(r, a.style));
		}
		return r && (n.style = r), n;
	}, t.prototype._mergeStyle = function(e, t) {
		return M(e, t), e;
	}, t.prototype.getAnimationStyleProps = function() {
		return Xc;
	}, t.initDefaultProps = (function() {
		var e = t.prototype;
		e.type = "displayable", e.invisible = !1, e.z = 0, e.z2 = 0, e.zlevel = 0, e.culling = !1, e.cursor = "pointer", e.rectHover = !1, e.incremental = 0, e._rect = null, e.dirtyRectTolerance = 0, e.__dirty = 3;
	})(), t;
}(Na), el = new Y(0, 0, 0, 0), tl = new Y(0, 0, 0, 0);
function nl(e, t, n) {
	return el.copy(e.getBoundingRect()), e.transform && el.applyTransform(e.transform), tl.width = t, tl.height = n, !el.intersect(tl);
}
//#endregion
//#region node_modules/zrender/lib/core/bbox.js
var rl = Math.min, il = Math.max, al = Math.sin, ol = Math.cos, sl = Math.PI * 2, cl = Re(), ll = Re(), ul = Re();
function dl(e, t, n, r, i, a) {
	i[0] = rl(e, n), i[1] = rl(t, r), a[0] = il(e, n), a[1] = il(t, r);
}
var fl = [], pl = [];
function ml(e, t, n, r, i, a, o, s, c, l) {
	var u = ur, d = sr, f = u(e, n, i, o, fl);
	c[0] = Infinity, c[1] = Infinity, l[0] = -Infinity, l[1] = -Infinity;
	for (var p = 0; p < f; p++) {
		var m = d(e, n, i, o, fl[p]);
		c[0] = rl(m, c[0]), l[0] = il(m, l[0]);
	}
	f = u(t, r, a, s, pl);
	for (var p = 0; p < f; p++) {
		var h = d(t, r, a, s, pl[p]);
		c[1] = rl(h, c[1]), l[1] = il(h, l[1]);
	}
	c[0] = rl(e, c[0]), l[0] = il(e, l[0]), c[0] = rl(o, c[0]), l[0] = il(o, l[0]), c[1] = rl(t, c[1]), l[1] = il(t, l[1]), c[1] = rl(s, c[1]), l[1] = il(s, l[1]);
}
function hl(e, t, n, r, i, a, o, s) {
	var c = _r, l = mr, u = il(rl(c(e, n, i), 1), 0), d = il(rl(c(t, r, a), 1), 0), f = l(e, n, i, u), p = l(t, r, a, d);
	o[0] = rl(e, i, f), o[1] = rl(t, a, p), s[0] = il(e, i, f), s[1] = il(t, a, p);
}
function gl(e, t, n, r, i, a, o, s, c) {
	var l = st, u = ct, d = Math.abs(i - a);
	if (d % sl < 1e-4 && d > 1e-4) s[0] = e - n, s[1] = t - r, c[0] = e + n, c[1] = t + r;
	else {
		if (cl[0] = ol(i) * n + e, cl[1] = al(i) * r + t, ll[0] = ol(a) * n + e, ll[1] = al(a) * r + t, l(s, cl, ll), u(c, cl, ll), i %= sl, i < 0 && (i += sl), a %= sl, a < 0 && (a += sl), i > a && !o ? a += sl : i < a && o && (i += sl), o) {
			var f = a;
			a = i, i = f;
		}
		for (var p = 0; p < a; p += Math.PI / 2) p > i && (ul[0] = ol(p) * n + e, ul[1] = al(p) * r + t, l(s, ul, s), u(c, ul, c));
	}
}
//#endregion
//#region node_modules/zrender/lib/core/PathProxy.js
var _l = {
	M: 1,
	L: 2,
	C: 3,
	Q: 4,
	A: 5,
	Z: 6,
	R: 7
}, vl = [], yl = [], bl = [], xl = [], Sl = [], Cl = [], wl = Math.min, Tl = Math.max, El = Math.cos, Dl = Math.sin, Ol = Math.abs, kl = Math.PI, Al = kl * 2, jl = typeof Float32Array < "u", Ml = [];
function Nl(e) {
	return Math.round(e / kl * 1e8) / 1e8 % 2 * kl;
}
function Pl(e, t) {
	var n = Nl(e[0]);
	n < 0 && (n += Al);
	var r = n - e[0], i = e[1];
	i += r, !t && i - n >= Al ? i = n + Al : t && n - i >= Al ? i = n - Al : !t && n > i ? i = n + (Al - Nl(n - i)) : t && n < i && (i = n - (Al - Nl(i - n))), e[0] = n, e[1] = i;
}
var Fl = function() {
	function e(e) {
		this.dpr = 1, this._xi = 0, this._yi = 0, this._x0 = 0, this._y0 = 0, this._len = 0, e && (this._saveData = !1), this._saveData && (this.data = []);
	}
	return e.prototype.increaseVersion = function() {
		this._version++;
	}, e.prototype.getVersion = function() {
		return this._version;
	}, e.prototype.setScale = function(e, t, n) {
		n ||= 0, n > 0 && (this._ux = Ol(n / Xi / e) || 0, this._uy = Ol(n / Xi / t) || 0);
	}, e.prototype.setDPR = function(e) {
		this.dpr = e;
	}, e.prototype.setContext = function(e) {
		this._ctx = e;
	}, e.prototype.getContext = function() {
		return this._ctx;
	}, e.prototype.beginPath = function() {
		return this._ctx && this._ctx.beginPath(), this.reset(), this;
	}, e.prototype.reset = function() {
		this._saveData && (this._len = 0), this._pathSegLen && (this._pathSegLen = null, this._pathLen = 0), this._version++;
	}, e.prototype.moveTo = function(e, t) {
		return this._drawPendingPt(), this.addData(_l.M, e, t), this._ctx && this._ctx.moveTo(e, t), this._x0 = e, this._y0 = t, this._xi = e, this._yi = t, this;
	}, e.prototype.lineTo = function(e, t) {
		var n = Ol(e - this._xi), r = Ol(t - this._yi), i = n > this._ux || r > this._uy;
		if (this.addData(_l.L, e, t), this._ctx && i && this._ctx.lineTo(e, t), i) this._xi = e, this._yi = t, this._pendingPtDist = 0;
		else {
			var a = n * n + r * r;
			a > this._pendingPtDist && (this._pendingPtX = e, this._pendingPtY = t, this._pendingPtDist = a);
		}
		return this;
	}, e.prototype.bezierCurveTo = function(e, t, n, r, i, a) {
		return this._drawPendingPt(), this.addData(_l.C, e, t, n, r, i, a), this._ctx && this._ctx.bezierCurveTo(e, t, n, r, i, a), this._xi = i, this._yi = a, this;
	}, e.prototype.quadraticCurveTo = function(e, t, n, r) {
		return this._drawPendingPt(), this.addData(_l.Q, e, t, n, r), this._ctx && this._ctx.quadraticCurveTo(e, t, n, r), this._xi = n, this._yi = r, this;
	}, e.prototype.arc = function(e, t, n, r, i, a) {
		this._drawPendingPt(), Ml[0] = r, Ml[1] = i, Pl(Ml, a), r = Ml[0], i = Ml[1];
		var o = i - r;
		return this.addData(_l.A, e, t, n, n, r, o, 0, +!a), this._ctx && this._ctx.arc(e, t, n, r, i, a), this._xi = El(i) * n + e, this._yi = Dl(i) * n + t, this;
	}, e.prototype.arcTo = function(e, t, n, r, i) {
		return this._drawPendingPt(), this._ctx && this._ctx.arcTo(e, t, n, r, i), this;
	}, e.prototype.rect = function(e, t, n, r) {
		return this._drawPendingPt(), this._ctx && this._ctx.rect(e, t, n, r), this.addData(_l.R, e, t, n, r), this;
	}, e.prototype.closePath = function() {
		this._drawPendingPt(), this.addData(_l.Z);
		var e = this._ctx, t = this._x0, n = this._y0;
		return e && e.closePath(), this._xi = t, this._yi = n, this;
	}, e.prototype.fill = function(e) {
		e && e.fill(), this.toStatic();
	}, e.prototype.stroke = function(e) {
		e && e.stroke(), this.toStatic();
	}, e.prototype.len = function() {
		return this._len;
	}, e.prototype.setData = function(e) {
		if (this._saveData) {
			var t = e.length;
			!(this.data && this.data.length === t) && jl && (this.data = new Float32Array(t));
			for (var n = 0; n < t; n++) this.data[n] = e[n];
			this._len = t;
		}
	}, e.prototype.appendPath = function(e) {
		if (this._saveData) {
			e instanceof Array || (e = [e]);
			for (var t = e.length, n = 0, r = this._len, i = 0; i < t; i++) n += e[i].len();
			var a = this.data;
			if (jl && (a instanceof Float32Array || !a) && (this.data = new Float32Array(r + n), r > 0 && a)) for (var o = 0; o < r; o++) this.data[o] = a[o];
			for (var i = 0; i < t; i++) for (var s = e[i].data, o = 0; o < s.length; o++) this.data[r++] = s[o];
			this._len = r;
		}
	}, e.prototype.addData = function(e, t, n, r, i, a, o, s, c) {
		if (this._saveData) {
			var l = this.data;
			this._len + arguments.length > l.length && (this._expandData(), l = this.data);
			for (var u = 0; u < arguments.length; u++) l[this._len++] = arguments[u];
		}
	}, e.prototype._drawPendingPt = function() {
		this._pendingPtDist > 0 && (this._ctx && this._ctx.lineTo(this._pendingPtX, this._pendingPtY), this._pendingPtDist = 0);
	}, e.prototype._expandData = function() {
		if (!(this.data instanceof Array)) {
			for (var e = [], t = 0; t < this._len; t++) e[t] = this.data[t];
			this.data = e;
		}
	}, e.prototype.toStatic = function() {
		if (this._saveData) {
			this._drawPendingPt();
			var e = this.data;
			e instanceof Array && (e.length = this._len, jl && this._len > 11 && (this.data = new Float32Array(e)));
		}
	}, e.prototype.getBoundingRect = function() {
		bl[0] = bl[1] = Sl[0] = Sl[1] = Number.MAX_VALUE, xl[0] = xl[1] = Cl[0] = Cl[1] = -Number.MAX_VALUE;
		for (var e = this.data, t = 0, n = 0, r = 0, i = 0, a = 0; a < this._len;) {
			var o = e[a++], s = a === 1;
			switch (s && (t = e[a], n = e[a + 1], r = t, i = n), o) {
				case _l.M:
					t = r = e[a++], n = i = e[a++], Sl[0] = r, Sl[1] = i, Cl[0] = r, Cl[1] = i;
					break;
				case _l.L:
					dl(t, n, e[a], e[a + 1], Sl, Cl), t = e[a++], n = e[a++];
					break;
				case _l.C:
					ml(t, n, e[a++], e[a++], e[a++], e[a++], e[a], e[a + 1], Sl, Cl), t = e[a++], n = e[a++];
					break;
				case _l.Q:
					hl(t, n, e[a++], e[a++], e[a], e[a + 1], Sl, Cl), t = e[a++], n = e[a++];
					break;
				case _l.A:
					var c = e[a++], l = e[a++], u = e[a++], d = e[a++], f = e[a++], p = e[a++] + f;
					a += 1;
					var m = !e[a++];
					s && (r = El(f) * u + c, i = Dl(f) * d + l), gl(c, l, u, d, f, p, m, Sl, Cl), t = El(p) * u + c, n = Dl(p) * d + l;
					break;
				case _l.R:
					r = t = e[a++], i = n = e[a++];
					var h = e[a++], g = e[a++];
					dl(r, i, r + h, i + g, Sl, Cl);
					break;
				case _l.Z: t = r, n = i;
			}
			st(bl, bl, Sl), ct(xl, xl, Cl);
		}
		return a === 0 && (bl[0] = bl[1] = xl[0] = xl[1] = 0), new Y(bl[0], bl[1], xl[0] - bl[0], xl[1] - bl[1]);
	}, e.prototype._calculateLength = function() {
		var e = this.data, t = this._len, n = this._ux, r = this._uy, i = 0, a = 0, o = 0, s = 0;
		this._pathSegLen ||= [];
		for (var c = this._pathSegLen, l = 0, u = 0, d = 0; d < t;) {
			var f = e[d++], p = d === 1;
			p && (i = e[d], a = e[d + 1], o = i, s = a);
			var m = -1;
			switch (f) {
				case _l.M:
					i = o = e[d++], a = s = e[d++];
					break;
				case _l.L:
					var h = e[d++], g = e[d++], _ = h - i, v = g - a;
					(Ol(_) > n || Ol(v) > r || d === t - 1) && (m = Math.sqrt(_ * _ + v * v), i = h, a = g);
					break;
				case _l.C:
					var y = e[d++], b = e[d++], h = e[d++], g = e[d++], x = e[d++], S = e[d++];
					m = pr(i, a, y, b, h, g, x, S, 10), i = x, a = S;
					break;
				case _l.Q:
					var y = e[d++], b = e[d++], h = e[d++], g = e[d++];
					m = br(i, a, y, b, h, g, 10), i = h, a = g;
					break;
				case _l.A:
					var C = e[d++], w = e[d++], T = e[d++], E = e[d++], D = e[d++], O = e[d++], k = O + D;
					d += 1, p && (o = El(D) * T + C, s = Dl(D) * E + w), m = Tl(T, E) * wl(Al, Math.abs(O)), i = El(k) * T + C, a = Dl(k) * E + w;
					break;
				case _l.R:
					o = i = e[d++], s = a = e[d++];
					var A = e[d++], j = e[d++];
					m = A * 2 + j * 2;
					break;
				case _l.Z:
					var _ = o - i, v = s - a;
					m = Math.sqrt(_ * _ + v * v), i = o, a = s;
			}
			m >= 0 && (c[u++] = m, l += m);
		}
		return this._pathLen = l, l;
	}, e.prototype.rebuildPath = function(e, t) {
		var n = this.data, r = this._ux, i = this._uy, a = this._len, o, s, c, l, u, d, f = t < 1, p, m, h = 0, g = 0, _, v = 0, y, b;
		if (!(f && (this._pathSegLen || this._calculateLength(), p = this._pathSegLen, m = this._pathLen, _ = t * m, !_))) lo: for (var x = 0; x < a;) {
			var S = n[x++], C = x === 1;
			switch (C && (c = n[x], l = n[x + 1], o = c, s = l), S !== _l.L && v > 0 && (e.lineTo(y, b), v = 0), S) {
				case _l.M:
					o = c = n[x++], s = l = n[x++], e.moveTo(c, l);
					break;
				case _l.L:
					u = n[x++], d = n[x++];
					var w = Ol(u - c), T = Ol(d - l);
					if (w > r || T > i) {
						if (f) {
							var E = p[g++];
							if (h + E > _) {
								var D = (_ - h) / E;
								e.lineTo(c * (1 - D) + u * D, l * (1 - D) + d * D);
								break lo;
							}
							h += E;
						}
						e.lineTo(u, d), c = u, l = d, v = 0;
					} else {
						var O = w * w + T * T;
						O > v && (y = u, b = d, v = O);
					}
					break;
				case _l.C:
					var k = n[x++], A = n[x++], j = n[x++], ee = n[x++], M = n[x++], te = n[x++];
					if (f) {
						var E = p[g++];
						if (h + E > _) {
							var D = (_ - h) / E;
							dr(c, k, j, M, D, vl), dr(l, A, ee, te, D, yl), e.bezierCurveTo(vl[1], yl[1], vl[2], yl[2], vl[3], yl[3]);
							break lo;
						}
						h += E;
					}
					e.bezierCurveTo(k, A, j, ee, M, te), c = M, l = te;
					break;
				case _l.Q:
					var k = n[x++], A = n[x++], j = n[x++], ee = n[x++];
					if (f) {
						var E = p[g++];
						if (h + E > _) {
							var D = (_ - h) / E;
							vr(c, k, j, D, vl), vr(l, A, ee, D, yl), e.quadraticCurveTo(vl[1], yl[1], vl[2], yl[2]);
							break lo;
						}
						h += E;
					}
					e.quadraticCurveTo(k, A, j, ee), c = j, l = ee;
					break;
				case _l.A:
					var N = n[x++], ne = n[x++], P = n[x++], re = n[x++], F = n[x++], ie = n[x++], I = n[x++], L = !n[x++], ae = P > re ? P : re, oe = Ol(P - re) > .001, se = F + ie, R = !1;
					if (f) {
						var E = p[g++];
						h + E > _ && (se = F + ie * (_ - h) / E, R = !0), h += E;
					}
					if (oe && e.ellipse ? e.ellipse(N, ne, P, re, I, F, se, L) : e.arc(N, ne, ae, F, se, L), R) break lo;
					C && (o = El(F) * P + N, s = Dl(F) * re + ne), c = El(se) * P + N, l = Dl(se) * re + ne;
					break;
				case _l.R:
					o = c = n[x], s = l = n[x + 1], u = n[x++], d = n[x++];
					var ce = n[x++], z = n[x++];
					if (f) {
						var E = p[g++];
						if (h + E > _) {
							var B = _ - h;
							e.moveTo(u, d), e.lineTo(u + wl(B, ce), d), B -= ce, B > 0 && e.lineTo(u + ce, d + wl(B, z)), B -= z, B > 0 && e.lineTo(u + Tl(ce - B, 0), d + z), B -= ce, B > 0 && e.lineTo(u, d + Tl(z - B, 0));
							break lo;
						}
						h += E;
					}
					e.rect(u, d, ce, z);
					break;
				case _l.Z:
					if (f) {
						var E = p[g++];
						if (h + E > _) {
							var D = (_ - h) / E;
							e.lineTo(c * (1 - D) + o * D, l * (1 - D) + s * D);
							break lo;
						}
						h += E;
					}
					e.closePath(), c = o, l = s;
			}
		}
	}, e.prototype.clone = function() {
		var t = new e(), n = this.data;
		return t.data = n.slice ? n.slice() : Array.prototype.slice.call(n), t._len = this._len, t;
	}, e.prototype.canSave = function() {
		return !!this._saveData;
	}, e.CMD = _l, e.initDefaultProps = (function() {
		var t = e.prototype;
		t._saveData = !0, t._ux = 0, t._uy = 0, t._pendingPtDist = 0, t._version = 0;
	})(), e;
}();
//#endregion
//#region node_modules/zrender/lib/contain/line.js
function Il(e, t, n, r, i, a, o) {
	if (i === 0) return !1;
	var s = i, c = 0, l = e;
	if (o > t + s && o > r + s || o < t - s && o < r - s || a > e + s && a > n + s || a < e - s && a < n - s) return !1;
	if (e !== n) c = (t - r) / (e - n), l = (e * r - n * t) / (e - n);
	else return Math.abs(a - e) <= s / 2;
	var u = c * a - o + l;
	return u * u / (c * c + 1) <= s / 2 * s / 2;
}
//#endregion
//#region node_modules/zrender/lib/contain/cubic.js
function Ll(e, t, n, r, i, a, o, s, c, l, u) {
	if (c === 0) return !1;
	var d = c;
	return u > t + d && u > r + d && u > a + d && u > s + d || u < t - d && u < r - d && u < a - d && u < s - d || l > e + d && l > n + d && l > i + d && l > o + d || l < e - d && l < n - d && l < i - d && l < o - d ? !1 : fr(e, t, n, r, i, a, o, s, l, u, null) <= d / 2;
}
//#endregion
//#region node_modules/zrender/lib/contain/quadratic.js
function Rl(e, t, n, r, i, a, o, s, c) {
	if (o === 0) return !1;
	var l = o;
	return c > t + l && c > r + l && c > a + l || c < t - l && c < r - l && c < a - l || s > e + l && s > n + l && s > i + l || s < e - l && s < n - l && s < i - l ? !1 : yr(e, t, n, r, i, a, s, c, null) <= l / 2;
}
//#endregion
//#region node_modules/zrender/lib/contain/util.js
var zl = Math.PI * 2;
function Bl(e) {
	return e %= zl, e < 0 && (e += zl), e;
}
//#endregion
//#region node_modules/zrender/lib/contain/arc.js
var Vl = Math.PI * 2;
function Hl(e, t, n, r, i, a, o, s, c) {
	if (o === 0) return !1;
	var l = o;
	s -= e, c -= t;
	var u = Math.sqrt(s * s + c * c);
	if (u - l > n || u + l < n) return !1;
	if (Math.abs(r - i) % Vl < 1e-4) return !0;
	if (a) {
		var d = r;
		r = Bl(i), i = Bl(d);
	} else r = Bl(r), i = Bl(i);
	r > i && (i += Vl);
	var f = Math.atan2(c, s);
	return f < 0 && (f += Vl), f >= r && f <= i || f + Vl >= r && f + Vl <= i;
}
//#endregion
//#region node_modules/zrender/lib/contain/windingLine.js
function Ul(e, t, n, r, i, a) {
	if (a > t && a > r || a < t && a < r || r === t) return 0;
	var o = (a - t) / (r - t), s = r < t ? 1 : -1;
	(o === 1 || o === 0) && (s = r < t ? .5 : -.5);
	var c = o * (n - e) + e;
	return c === i ? Infinity : c > i ? s : 0;
}
//#endregion
//#region node_modules/zrender/lib/contain/path.js
var Wl = Fl.CMD, Gl = Math.PI * 2, Kl = 1e-4;
function ql(e, t) {
	return Math.abs(e - t) < Kl;
}
var Jl = [
	-1,
	-1,
	-1
], Yl = [-1, -1];
function Xl() {
	var e = Yl[0];
	Yl[0] = Yl[1], Yl[1] = e;
}
function Zl(e, t, n, r, i, a, o, s, c, l) {
	if (l > t && l > r && l > a && l > s || l < t && l < r && l < a && l < s) return 0;
	var u = lr(t, r, a, s, l, Jl);
	if (u === 0) return 0;
	for (var d = 0, f = -1, p = void 0, m = void 0, h = 0; h < u; h++) {
		var g = Jl[h], _ = g === 0 || g === 1 ? .5 : 1;
		sr(e, n, i, o, g) < c || (f < 0 && (f = ur(t, r, a, s, Yl), Yl[1] < Yl[0] && f > 1 && Xl(), p = sr(t, r, a, s, Yl[0]), f > 1 && (m = sr(t, r, a, s, Yl[1]))), f === 2 ? g < Yl[0] ? d += p < t ? _ : -_ : g < Yl[1] ? d += m < p ? _ : -_ : d += s < m ? _ : -_ : g < Yl[0] ? d += p < t ? _ : -_ : d += s < p ? _ : -_);
	}
	return d;
}
function Ql(e, t, n, r, i, a, o, s) {
	if (s > t && s > r && s > a || s < t && s < r && s < a) return 0;
	var c = gr(t, r, a, s, Jl);
	if (c === 0) return 0;
	var l = _r(t, r, a);
	if (l >= 0 && l <= 1) {
		for (var u = 0, d = mr(t, r, a, l), f = 0; f < c; f++) {
			var p = Jl[f] === 0 || Jl[f] === 1 ? .5 : 1, m = mr(e, n, i, Jl[f]);
			m < o || (Jl[f] < l ? u += d < t ? p : -p : u += a < d ? p : -p);
		}
		return u;
	}
	var p = Jl[0] === 0 || Jl[0] === 1 ? .5 : 1, m = mr(e, n, i, Jl[0]);
	return m < o ? 0 : a < t ? p : -p;
}
function $l(e, t, n, r, i, a, o, s) {
	if (s -= t, s > n || s < -n) return 0;
	var c = Math.sqrt(n * n - s * s);
	Jl[0] = -c, Jl[1] = c;
	var l = Math.abs(r - i);
	if (l < 1e-4) return 0;
	if (l >= Gl - 1e-4) {
		r = 0, i = Gl;
		var u = a ? 1 : -1;
		return o >= Jl[0] + e && o <= Jl[1] + e ? u : 0;
	}
	if (r > i) {
		var d = r;
		r = i, i = d;
	}
	r < 0 && (r += Gl, i += Gl);
	for (var f = 0, p = 0; p < 2; p++) {
		var m = Jl[p];
		if (m + e > o) {
			var h = Math.atan2(s, m), u = a ? 1 : -1;
			h < 0 && (h = Gl + h), (h >= r && h <= i || h + Gl >= r && h + Gl <= i) && (h > Math.PI / 2 && h < Math.PI * 1.5 && (u = -u), f += u);
		}
	}
	return f;
}
function eu(e, t, n, r, i) {
	for (var a = e.data, o = e.len(), s = 0, c = 0, l = 0, u = 0, d = 0, f, p, m = 0; m < o;) {
		var h = a[m++], g = m === 1;
		switch (h === Wl.M && m > 1 && (n || (s += Ul(c, l, u, d, r, i))), g && (c = a[m], l = a[m + 1], u = c, d = l), h) {
			case Wl.M:
				u = a[m++], d = a[m++], c = u, l = d;
				break;
			case Wl.L:
				if (n) {
					if (Il(c, l, a[m], a[m + 1], t, r, i)) return !0;
				} else s += Ul(c, l, a[m], a[m + 1], r, i) || 0;
				c = a[m++], l = a[m++];
				break;
			case Wl.C:
				if (n) {
					if (Ll(c, l, a[m++], a[m++], a[m++], a[m++], a[m], a[m + 1], t, r, i)) return !0;
				} else s += Zl(c, l, a[m++], a[m++], a[m++], a[m++], a[m], a[m + 1], r, i) || 0;
				c = a[m++], l = a[m++];
				break;
			case Wl.Q:
				if (n) {
					if (Rl(c, l, a[m++], a[m++], a[m], a[m + 1], t, r, i)) return !0;
				} else s += Ql(c, l, a[m++], a[m++], a[m], a[m + 1], r, i) || 0;
				c = a[m++], l = a[m++];
				break;
			case Wl.A:
				var _ = a[m++], v = a[m++], y = a[m++], b = a[m++], x = a[m++], S = a[m++];
				m += 1;
				var C = !!(1 - a[m++]);
				f = Math.cos(x) * y + _, p = Math.sin(x) * b + v, g ? (u = f, d = p) : s += Ul(c, l, f, p, r, i);
				var w = (r - _) * b / y + _;
				if (n) {
					if (Hl(_, v, b, x, x + S, C, t, w, i)) return !0;
				} else s += $l(_, v, b, x, x + S, C, w, i);
				c = Math.cos(x + S) * y + _, l = Math.sin(x + S) * b + v;
				break;
			case Wl.R:
				u = c = a[m++], d = l = a[m++];
				var T = a[m++], E = a[m++];
				if (f = u + T, p = d + E, n) {
					if (Il(u, d, f, d, t, r, i) || Il(f, d, f, p, t, r, i) || Il(f, p, u, p, t, r, i) || Il(u, p, u, d, t, r, i)) return !0;
				} else s += Ul(f, d, f, p, r, i), s += Ul(u, p, u, d, r, i);
				break;
			case Wl.Z:
				if (n) {
					if (Il(c, l, u, d, t, r, i)) return !0;
				} else s += Ul(c, l, u, d, r, i);
				c = u, l = d;
		}
	}
	return !n && !ql(l, d) && (s += Ul(c, l, u, d, r, i) || 0), s !== 0;
}
function tu(e, t, n) {
	return eu(e, 0, !1, t, n);
}
function nu(e, t, n, r) {
	return eu(e, t, !0, n, r);
}
//#endregion
//#region node_modules/zrender/lib/graphic/Path.js
var ru = N({
	fill: "#000",
	stroke: null,
	strokePercent: 1,
	fillOpacity: 1,
	strokeOpacity: 1,
	lineDashOffset: 0,
	lineWidth: 1,
	lineCap: "butt",
	miterLimit: 10,
	strokeNoScale: !1,
	strokeFirst: !1
}, Yc), iu = { style: N({
	fill: !0,
	stroke: !0,
	strokePercent: !0,
	fillOpacity: !0,
	strokeOpacity: !0,
	lineDashOffset: !0,
	lineWidth: !0,
	miterLimit: !0
}, Xc.style) }, au = da.concat([
	"invisible",
	"culling",
	"z",
	"z2",
	"zlevel",
	"parent"
]), ou = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.update = function() {
		var n = this;
		e.prototype.update.call(this);
		var r = this.style;
		if (r.decal) {
			var i = this._decalEl = this._decalEl || new t();
			i.buildPath === t.prototype.buildPath && (i.buildPath = function(e) {
				n.buildPath(e, n.shape);
			}), i.silent = !0;
			var a = i.style;
			for (var o in r) a[o] !== r[o] && (a[o] = r[o]);
			a.fill = r.fill ? r.decal : null, a.decal = null, a.shadowColor = null, r.strokeFirst && (a.stroke = null);
			for (var s = 0; s < au.length; ++s) i[au[s]] = this[au[s]];
			i.__dirty |= 1;
		} else this._decalEl &&= null;
	}, t.prototype.getDecalElement = function() {
		return this._decalEl;
	}, t.prototype._init = function(t) {
		var n = R(t);
		this.shape = this.getDefaultShape();
		var r = this.getDefaultStyle();
		r && this.useStyle(r);
		for (var i = 0; i < n.length; i++) {
			var a = n[i], o = t[a];
			a === "style" ? this.style ? M(this.style, o) : this.useStyle(o) : a === "shape" ? M(this.shape, o) : e.prototype.attrKV.call(this, a, o);
		}
		this.style || this.useStyle({});
	}, t.prototype.getDefaultStyle = function() {
		return null;
	}, t.prototype.getDefaultShape = function() {
		return {};
	}, t.prototype.canBeInsideText = function() {
		return this.hasFill();
	}, t.prototype.getInsideTextFill = function() {
		var e = this.style.fill;
		if (e !== "none") {
			if (U(e)) {
				var t = $r(e, 0);
				return t > .5 ? Qi : t > .2 ? ea : $i;
			}
			if (e) return $i;
		}
		return Qi;
	}, t.prototype.getInsideTextStroke = function(e) {
		var t = this.style.fill;
		if (U(t)) {
			var n = this.__zr;
			if (!!(n && n.isDarkMode()) == $r(e, 0) < .4) return t;
		}
	}, t.prototype.buildPath = function(e, t, n) {}, t.prototype.pathUpdated = function() {
		this.__dirty &= -5;
	}, t.prototype.getUpdatedPathProxy = function(e) {
		return !this.path && this.createPathProxy(), this.path.beginPath(), this.buildPath(this.path, this.shape, e), this.path;
	}, t.prototype.createPathProxy = function() {
		this.path = new Fl(!1);
	}, t.prototype.hasStroke = function() {
		var e = this.style, t = e.stroke;
		return !(t == null || t === "none" || !(e.lineWidth > 0));
	}, t.prototype.hasFill = function() {
		var e = this.style.fill;
		return e != null && e !== "none";
	}, t.prototype.getBoundingRect = function() {
		var e = this._rect, t = this.style, n = !e;
		if (n) {
			var r = !1;
			this.path || (r = !0, this.createPathProxy());
			var i = this.path;
			(r || this.__dirty & 4) && (i.beginPath(), this.buildPath(i, this.shape, !1), this.pathUpdated()), e = i.getBoundingRect();
		}
		if (this._rect = e, this.hasStroke() && this.path && this.path.len() > 0) {
			var a = this._rectStroke ||= e.clone();
			if (this.__dirty || n) {
				a.copy(e);
				var o = t.strokeNoScale ? this.getLineScale() : 1, s = t.lineWidth;
				if (!this.hasFill()) {
					var c = this.strokeContainThreshold;
					s = Math.max(s, c ?? 4);
				}
				o > 1e-10 && (a.width += s / o, a.height += s / o, a.x -= s / o / 2, a.y -= s / o / 2);
			}
			return a;
		}
		return e;
	}, t.prototype.contain = function(e, t) {
		var n = this.transformCoordToLocal(e, t), r = this.getBoundingRect(), i = this.style;
		if (e = n[0], t = n[1], r.contain(e, t)) {
			var a = this.path;
			if (this.hasStroke()) {
				var o = i.lineWidth, s = i.strokeNoScale ? this.getLineScale() : 1;
				if (s > 1e-10 && (this.hasFill() || (o = Math.max(o, this.strokeContainThreshold)), nu(a, o / s, e, t))) return !0;
			}
			if (this.hasFill()) return tu(a, e, t);
		}
		return !1;
	}, t.prototype.dirtyShape = function() {
		this.__dirty |= 4, this._rect &&= null, this._decalEl && this._decalEl.dirtyShape(), this.markRedraw();
	}, t.prototype.dirty = function() {
		this.dirtyStyle(), this.dirtyShape();
	}, t.prototype.animateShape = function(e) {
		return this.animate("shape", e);
	}, t.prototype.updateDuringAnimation = function(e) {
		e === "style" ? this.dirtyStyle() : e === "shape" ? this.dirtyShape() : this.markRedraw();
	}, t.prototype.attrKV = function(t, n) {
		t === "shape" ? this.setShape(n) : e.prototype.attrKV.call(this, t, n);
	}, t.prototype.setShape = function(e, t) {
		var n = this.shape;
		return n ||= this.shape = {}, typeof e == "string" ? n[e] = t : M(n, e), this.dirtyShape(), this;
	}, t.prototype.shapeChanged = function() {
		return !!(this.__dirty & 4);
	}, t.prototype.createStyle = function(e) {
		return Me(ru, e);
	}, t.prototype._innerSaveToNormal = function(t) {
		e.prototype._innerSaveToNormal.call(this, t);
		var n = this._normalState;
		t.shape && !n.shape && (n.shape = M({}, this.shape));
	}, t.prototype._applyStateObj = function(t, n, r, i, a, o) {
		if (e.prototype._applyStateObj.call(this, t, n, r, i, a, o), this.__inHover !== 1) {
			var s = !(n && i), c;
			if (n && n.shape ? a ? i ? c = n.shape : (c = M({}, r.shape), M(c, n.shape)) : (c = M({}, i ? this.shape : r.shape), M(c, n.shape)) : s && (c = r.shape), c) {
				if (a) {
					this.shape = M({}, this.shape);
					for (var l = {}, u = R(c), d = 0; d < u.length; d++) {
						var f = u[d];
						typeof c[f] == "object" ? this.shape[f] = c[f] : l[f] = c[f];
					}
					this._transitionState(t, { shape: l }, o);
				} else this.shape = c, this.dirtyShape();
			}
		}
	}, t.prototype._mergeStates = function(t) {
		for (var n = e.prototype._mergeStates.call(this, t), r, i = 0; i < t.length; i++) {
			var a = t[i];
			a.shape && (r ||= {}, this._mergeStyle(r, a.shape));
		}
		return r && (n.shape = r), n;
	}, t.prototype.getAnimationStyleProps = function() {
		return iu;
	}, t.prototype.isZeroArea = function() {
		return !1;
	}, t.extend = function(e) {
		var r = function(t) {
			n(r, t);
			function r(n) {
				var r = t.call(this, n) || this;
				return e.init && e.init.call(r, n), r;
			}
			return r.prototype.getDefaultStyle = function() {
				return A(e.style);
			}, r.prototype.getDefaultShape = function() {
				return A(e.shape);
			}, r;
		}(t);
		for (var i in e) typeof e[i] == "function" && (r.prototype[i] = e[i]);
		return r;
	}, t.initDefaultProps = (function() {
		var e = t.prototype;
		e.type = "path", e.strokeContainThreshold = 5, e.segmentIgnoreThreshold = 0, e.subPixelOptimize = !1, e.autoBatch = !1, e.__dirty = 7;
	})(), t;
}($c), su = N({
	strokeFirst: !0,
	font: o,
	x: 0,
	y: 0,
	textAlign: "left",
	textBaseline: "top",
	miterLimit: 2
}, ru), cu = function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t.prototype.hasStroke = function() {
		return qc(this.style);
	}, t.prototype.hasFill = function() {
		var e = this.style.fill;
		return e != null && e !== "none";
	}, t.prototype.createStyle = function(e) {
		return Me(su, e);
	}, t.prototype.setBoundingRect = function(e) {
		this._rect = e;
	}, t.prototype.getBoundingRect = function() {
		return this._rect ||= Gc(this.style), this._rect;
	}, t.initDefaultProps = (function() {
		var e = t.prototype;
		e.dirtyRectTolerance = 10;
	})(), t;
}($c);
cu.prototype.type = "tspan";
//#endregion
//#region node_modules/zrender/lib/graphic/Image.js
var lu = N({
	x: 0,
	y: 0
}, Yc), uu = { style: N({
	x: !0,
	y: !0,
	width: !0,
	height: !0,
	sx: !0,
	sy: !0,
	sWidth: !0,
	sHeight: !0
}, Xc.style) };
function du(e) {
	return !!(e && typeof e != "string" && e.width && e.height);
}
var fu = function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t.prototype.createStyle = function(e) {
		return Me(lu, e);
	}, t.prototype._getSize = function(e) {
		var t = this.style, n = t[e];
		if (n != null) return n;
		var r = du(t.image) ? t.image : this.__image;
		if (!r) return 0;
		var i = e === "width" ? "height" : "width", a = t[i];
		return a == null ? r[e] : r[e] / r[i] * a;
	}, t.prototype.getWidth = function() {
		return this._getSize("width");
	}, t.prototype.getHeight = function() {
		return this._getSize("height");
	}, t.prototype.getAnimationStyleProps = function() {
		return uu;
	}, t.prototype.getBoundingRect = function() {
		var e = this.style;
		return this._rect ||= new Y(e.x || 0, e.y || 0, this.getWidth(), this.getHeight()), this._rect;
	}, t;
}($c);
fu.prototype.type = "image";
//#endregion
//#region node_modules/zrender/lib/graphic/helper/roundRect.js
function pu(e, t) {
	var n = t.x, r = t.y, i = t.width, a = t.height, o = t.r, s, c, l, u;
	i < 0 && (n += i, i = -i), a < 0 && (r += a, a = -a), typeof o == "number" ? s = c = l = u = o : o instanceof Array ? o.length === 1 ? s = c = l = u = o[0] : o.length === 2 ? (s = l = o[0], c = u = o[1]) : o.length === 3 ? (s = o[0], c = u = o[1], l = o[2]) : (s = o[0], c = o[1], l = o[2], u = o[3]) : s = c = l = u = 0;
	var d;
	s + c > i && (d = s + c, s *= i / d, c *= i / d), l + u > i && (d = l + u, l *= i / d, u *= i / d), c + l > a && (d = c + l, c *= a / d, l *= a / d), s + u > a && (d = s + u, s *= a / d, u *= a / d), e.moveTo(n + s, r), e.lineTo(n + i - c, r), c !== 0 && e.arc(n + i - c, r + c, c, -Math.PI / 2, 0), e.lineTo(n + i, r + a - l), l !== 0 && e.arc(n + i - l, r + a - l, l, 0, Math.PI / 2), e.lineTo(n + u, r + a), u !== 0 && e.arc(n + u, r + a - u, u, Math.PI / 2, Math.PI), e.lineTo(n, r + s), s !== 0 && e.arc(n + s, r + s, s, Math.PI, Math.PI * 1.5), e.closePath();
}
//#endregion
//#region node_modules/zrender/lib/graphic/helper/subPixelOptimize.js
var mu = Math.round;
function hu(e, t, n) {
	if (t) {
		var r = t.x1, i = t.x2, a = t.y1, o = t.y2;
		e.x1 = r, e.x2 = i, e.y1 = a, e.y2 = o;
		var s = n && n.lineWidth;
		return s && (mu(r * 2) === mu(i * 2) && (e.x1 = e.x2 = _u(r, s, !0)), mu(a * 2) === mu(o * 2) && (e.y1 = e.y2 = _u(a, s, !0))), e;
	}
}
function gu(e, t, n) {
	if (t) {
		var r = t.x, i = t.y, a = t.width, o = t.height;
		e.x = r, e.y = i, e.width = a, e.height = o;
		var s = n && n.lineWidth;
		return s && (e.x = _u(r, s, !0), e.y = _u(i, s, !0), e.width = Math.max(_u(r + a, s, !1) - e.x, a === 0 ? 0 : 1), e.height = Math.max(_u(i + o, s, !1) - e.y, o === 0 ? 0 : 1)), e;
	}
}
function _u(e, t, n) {
	if (!t) return e;
	var r = mu(e * 2);
	return (r + mu(t)) % 2 == 0 ? r / 2 : (r + (n ? 1 : -1)) / 2;
}
//#endregion
//#region node_modules/zrender/lib/graphic/shape/Rect.js
var vu = function() {
	function e() {
		this.x = 0, this.y = 0, this.width = 0, this.height = 0;
	}
	return e;
}(), yu = {}, bu = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.getDefaultShape = function() {
		return new vu();
	}, t.prototype.buildPath = function(e, t) {
		var n, r, i, a;
		if (this.subPixelOptimize) {
			var o = gu(yu, t, this.style);
			n = o.x, r = o.y, i = o.width, a = o.height, o.r = t.r, t = o;
		} else n = t.x, r = t.y, i = t.width, a = t.height;
		t.r ? pu(e, t) : e.rect(n, r, i, a);
	}, t.prototype.isZeroArea = function() {
		return !this.shape.width || !this.shape.height;
	}, t;
}(ou);
bu.prototype.type = "rect";
//#endregion
//#region node_modules/zrender/lib/graphic/Text.js
var xu = { fill: "#000" }, Su = 2, Cu = {}, wu = { style: N({
	fill: !0,
	stroke: !0,
	fillOpacity: !0,
	strokeOpacity: !0,
	lineWidth: !0,
	fontSize: !0,
	lineHeight: !0,
	width: !0,
	height: !0,
	textShadowColor: !0,
	textShadowBlur: !0,
	textShadowOffsetX: !0,
	textShadowOffsetY: !0,
	backgroundColor: !0,
	padding: !0,
	borderColor: !0,
	borderWidth: !0,
	borderRadius: !0
}, Xc.style) }, Tu = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this) || this;
		return n.type = "text", n._children = [], n._defaultStyle = xu, n.attr(t), n;
	}
	return t.prototype.childrenRef = function() {
		return this._children;
	}, t.prototype.update = function() {
		e.prototype.update.call(this), this.styleChanged() && this._updateSubTexts();
		for (var t = 0; t < this._children.length; t++) {
			var n = this._children[t];
			n.zlevel = this.zlevel, n.z = this.z, n.z2 = this.z2, n.culling = this.culling, n.cursor = this.cursor, n.invisible = this.invisible;
		}
	}, t.prototype.updateTransform = function() {
		var t = this.innerTransformable;
		t ? (t.updateTransform(), t.transform && (this.transform = t.transform)) : e.prototype.updateTransform.call(this);
	}, t.prototype.getLocalTransform = function(t) {
		var n = this.innerTransformable;
		return n ? n.getLocalTransform(t) : e.prototype.getLocalTransform.call(this, t);
	}, t.prototype.getComputedTransform = function() {
		return this.__hostTarget && (this.__hostTarget.getComputedTransform(), this.__hostTarget.updateInnerText(!0)), e.prototype.getComputedTransform.call(this);
	}, t.prototype._updateSubTexts = function() {
		this._childCursor = 0, Mu(this.style), this.style.rich ? this._updateRichTexts() : this._updatePlainTexts(), this._children.length = this._childCursor, this.styleUpdated();
	}, t.prototype.addSelfToZr = function(t) {
		e.prototype.addSelfToZr.call(this, t);
		for (var n = 0; n < this._children.length; n++) this._children[n].__zr = t;
	}, t.prototype.removeSelfFromZr = function(t) {
		e.prototype.removeSelfFromZr.call(this, t);
		for (var n = 0; n < this._children.length; n++) this._children[n].__zr = null;
	}, t.prototype.getBoundingRect = function() {
		if (this.styleChanged() && this._updateSubTexts(), !this._rect) {
			for (var e = new Y(0, 0, 0, 0), t = this._children, n = [], r = null, i = 0; i < t.length; i++) {
				var a = t[i], o = a.getBoundingRect(), s = a.getLocalTransform(n);
				s ? (e.copy(o), e.applyTransform(s), r ||= e.clone(), r.union(e)) : (r ||= o.clone(), r.union(o));
			}
			this._rect = r || e;
		}
		return this._rect;
	}, t.prototype.setDefaultTextStyle = function(e) {
		this._defaultStyle = e || xu;
	}, t.prototype.setTextContent = function(e) {}, t.prototype._mergeStyle = function(e, t) {
		if (!t) return e;
		var n = t.rich, r = e.rich || n && {};
		return M(e, t), n && r ? (this._mergeRich(r, n), e.rich = r) : r && (e.rich = r), e;
	}, t.prototype._mergeRich = function(e, t) {
		for (var n = R(t), r = 0; r < n.length; r++) {
			var i = n[r];
			e[i] = e[i] || {}, M(e[i], t[i]);
		}
	}, t.prototype.getAnimationStyleProps = function() {
		return wu;
	}, t.prototype._getOrCreateChild = function(e) {
		var t = this._children[this._childCursor];
		return (!t || !(t instanceof e)) && (t = new e()), this._children[this._childCursor++] = t, t.__zr = this.__zr, t.parent = this, t;
	}, t.prototype._updatePlainTexts = function() {
		var e = this.style, t = e.font || "12px sans-serif", n = e.padding, r = this._defaultStyle, i = e.x || 0, a = e.y || 0, o = e.align || r.align || "left", s = e.verticalAlign || r.verticalAlign || "top";
		Vc(Cu, r.overflowRect, i, a, o, s), i = Cu.baseX, a = Cu.baseY;
		var c = jc(Lu(e), e, Cu.outerWidth, Cu.outerHeight), l = Ru(e), u = !!e.backgroundColor, d = c.outerHeight, f = c.outerWidth, p = c.lines, m = c.lineHeight;
		this.isTruncated = !!c.isTruncated;
		var h = i, g = Ca(a, c.contentHeight, s);
		if (l || n) {
			var _ = Sa(i, f, o), v = Ca(a, d, s);
			l && this._renderBackground(e, e, _, v, f, d);
		}
		g += m / 2, n && (h = Iu(i, o, n), s === "top" ? g += n[0] : s === "bottom" && (g -= n[2]));
		for (var y = 0, b = !1, x = !1, S = Fu("fill" in e ? e.fill : (x = !0, r.fill)), C = Pu("stroke" in e ? e.stroke : !u && (!r.autoStroke || x) ? (y = Su, b = !0, r.stroke) : null), w = e.textShadowBlur > 0, T = 0; T < p.length; T++) {
			var E = this._getOrCreateChild(cu), D = E.createStyle();
			E.useStyle(D), D.text = p[T], D.x = h, D.y = g, o && (D.textAlign = o), D.textBaseline = "middle", D.opacity = e.opacity, D.strokeFirst = !0, w && (D.shadowBlur = e.textShadowBlur || 0, D.shadowColor = e.textShadowColor || "transparent", D.shadowOffsetX = e.textShadowOffsetX || 0, D.shadowOffsetY = e.textShadowOffsetY || 0), D.stroke = C, D.fill = S, C && (D.lineWidth = e.lineWidth || y, D.lineDash = e.lineDash, D.lineDashOffset = e.lineDashOffset || 0), D.font = t, Au(D, e), g += m, E.setBoundingRect(Kc(D, c.contentWidth, c.calculatedLineHeight, b ? 0 : null));
		}
	}, t.prototype._updateRichTexts = function() {
		var e = this.style, t = this._defaultStyle, n = e.align || t.align, r = e.verticalAlign || t.verticalAlign, i = e.x || 0, a = e.y || 0;
		Vc(Cu, t.overflowRect, i, a, n, r), i = Cu.baseX, a = Cu.baseY;
		var o = Fc(Lu(e), e, Cu.outerWidth, Cu.outerHeight, n), s = o.width, c = o.outerWidth, l = o.outerHeight, u = e.padding;
		this.isTruncated = !!o.isTruncated;
		var d = Sa(i, c, n), f = Ca(a, l, r), p = d, m = f;
		u && (p += u[3], m += u[0]);
		var h = p + s;
		Ru(e) && this._renderBackground(e, e, d, f, c, l);
		for (var g = !!e.backgroundColor, _ = 0; _ < o.lines.length; _++) {
			for (var v = o.lines[_], y = v.tokens, b = y.length, x = v.lineHeight, S = v.width, C = 0, w = p, T = h, E = b - 1, D = void 0; C < b && (D = y[C], !D.align || D.align === "left");) this._placeToken(D, e, x, m, w, "left", g), S -= D.width, w += D.width, C++;
			for (; E >= 0 && (D = y[E], D.align === "right");) this._placeToken(D, e, x, m, T, "right", g), S -= D.width, T -= D.width, E--;
			for (w += (s - (w - p) - (h - T) - S) / 2; C <= E;) D = y[C], this._placeToken(D, e, x, m, w + D.width / 2, "center", g), w += D.width, C++;
			m += x;
		}
	}, t.prototype._placeToken = function(e, t, n, r, i, a, o) {
		var s = t.rich[e.styleName] || {};
		s.text = e.text;
		var c = e.verticalAlign, l = r + n / 2;
		c === "top" ? l = r + e.height / 2 : c === "bottom" && (l = r + n - e.height / 2), !e.isLineHolder && Ru(s) && this._renderBackground(s, t, a === "right" ? i - e.width : a === "center" ? i - e.width / 2 : i, l - e.height / 2, e.width, e.height);
		var u = !!s.backgroundColor, d = e.textPadding;
		d && (i = Iu(i, a, d), l -= e.height / 2 - d[0] - e.innerHeight / 2);
		var f = this._getOrCreateChild(cu), p = f.createStyle();
		f.useStyle(p);
		var m = this._defaultStyle, h = !1, g = 0, _ = !1, v = Fu("fill" in s ? s.fill : "fill" in t ? t.fill : (h = !0, m.fill)), y = Pu("stroke" in s ? s.stroke : "stroke" in t ? t.stroke : !u && !o && (!m.autoStroke || h) ? (g = Su, _ = !0, m.stroke) : null), b = s.textShadowBlur > 0 || t.textShadowBlur > 0;
		p.text = e.text, p.x = i, p.y = l, b && (p.shadowBlur = s.textShadowBlur || t.textShadowBlur || 0, p.shadowColor = s.textShadowColor || t.textShadowColor || "transparent", p.shadowOffsetX = s.textShadowOffsetX || t.textShadowOffsetX || 0, p.shadowOffsetY = s.textShadowOffsetY || t.textShadowOffsetY || 0), p.textAlign = a, p.textBaseline = "middle", p.font = e.font || "12px sans-serif", p.opacity = ye(s.opacity, t.opacity, 1), Au(p, s), y && (p.lineWidth = ye(s.lineWidth, t.lineWidth, g), p.lineDash = G(s.lineDash, t.lineDash), p.lineDashOffset = t.lineDashOffset || 0, p.stroke = y), v && (p.fill = v), f.setBoundingRect(Kc(p, e.contentWidth, e.contentHeight, _ ? 0 : null));
	}, t.prototype._renderBackground = function(e, t, n, r, i, a) {
		var o = e.backgroundColor, s = e.borderWidth, c = e.borderColor, l = o && o.image, u = o && !l, d = e.borderRadius, f = this, p, m;
		if (u || e.lineHeight || s && c) {
			p = this._getOrCreateChild(bu), p.useStyle(p.createStyle()), p.style.fill = null;
			var h = p.shape;
			h.x = n, h.y = r, h.width = i, h.height = a, h.r = d, p.dirtyShape();
		}
		if (u) {
			var g = p.style;
			g.fill = o || null, g.fillOpacity = G(e.fillOpacity, 1);
		} else if (l) {
			m = this._getOrCreateChild(fu), m.onload = function() {
				f.dirtyStyle();
			};
			var _ = m.style;
			_.image = o.image, _.x = n, _.y = r, _.width = i, _.height = a;
		}
		if (s && c) {
			var g = p.style;
			g.lineWidth = s, g.stroke = c, g.strokeOpacity = G(e.strokeOpacity, 1), g.lineDash = e.borderDash, g.lineDashOffset = e.borderDashOffset || 0, p.strokeContainThreshold = 0, p.hasFill() && p.hasStroke() && (g.strokeFirst = !0, g.lineWidth *= 2);
		}
		var v = (p || m).style;
		v.shadowBlur = e.shadowBlur || 0, v.shadowColor = e.shadowColor || "transparent", v.shadowOffsetX = e.shadowOffsetX || 0, v.shadowOffsetY = e.shadowOffsetY || 0, v.opacity = ye(e.opacity, t.opacity, 1);
	}, t.makeFont = function(e) {
		var t = "";
		return ju(e) && (t = [
			e.fontStyle,
			e.fontWeight,
			ku(e.fontSize),
			e.fontFamily || "sans-serif"
		].join(" ")), t && Ce(t) || e.textFont || e.font;
	}, t;
}($c), Eu = {
	left: !0,
	right: 1,
	center: 1
}, Du = {
	top: 1,
	bottom: 1,
	middle: 1
}, Ou = [
	"fontStyle",
	"fontWeight",
	"fontSize",
	"fontFamily"
];
function ku(e) {
	return typeof e == "string" && (e.indexOf("px") !== -1 || e.indexOf("rem") !== -1 || e.indexOf("em") !== -1) ? e : isNaN(+e) ? "12px" : e + "px";
}
function Au(e, t) {
	for (var n = 0; n < Ou.length; n++) {
		var r = Ou[n], i = t[r];
		i != null && (e[r] = i);
	}
}
function ju(e) {
	return e.fontSize != null || e.fontFamily || e.fontWeight;
}
function Mu(e) {
	return Nu(e), I(e.rich, Nu), e;
}
function Nu(e) {
	if (e) {
		e.font = Tu.makeFont(e);
		var t = e.align;
		t === "middle" && (t = "center"), e.align = t == null || Eu[t] ? t : "left";
		var n = e.verticalAlign;
		n === "center" && (n = "middle"), e.verticalAlign = n == null || Du[n] ? n : "top", e.padding &&= xe(e.padding);
	}
}
function Pu(e, t) {
	return e == null || t <= 0 || e === "transparent" || e === "none" ? null : e.image || e.colorStops ? "#000" : e;
}
function Fu(e) {
	return e == null || e === "none" ? null : e.image || e.colorStops ? "#000" : e;
}
function Iu(e, t, n) {
	return t === "right" ? e - n[1] : t === "center" ? e + n[3] / 2 - n[1] / 2 : e + n[3];
}
function Lu(e) {
	var t = e.text;
	return t != null && (t += ""), t;
}
function Ru(e) {
	return !!(e.backgroundColor || e.lineHeight || e.borderWidth && e.borderColor);
}
//#endregion
//#region node_modules/echarts/lib/util/innerStore.js
var Z = X(), zu = function(e, t, n, r) {
	if (r) {
		var i = Z(r);
		i.dataIndex = n, i.dataType = t, i.seriesIndex = e, i.ssrType = "chart", r.type === "group" && r.traverse(function(r) {
			var i = Z(r);
			i.seriesIndex = e, i.dataIndex = n, i.dataType = t, i.ssrType = "chart";
		});
	}
}, Bu = K([
	"tooltip",
	"label",
	"itemName",
	"itemId",
	"itemGroupId",
	"itemChildGroupId",
	"seriesName"
]), Vu = "original", Hu = "arrayRows", Uu = "objectRows", Wu = "keyedColumns", Gu = "typedArray", Ku = "unknown", qu = "column", Ju = [
	"getDom",
	"getZr",
	"getWidth",
	"getHeight",
	"getDevicePixelRatio",
	"dispatchAction",
	"isSSR",
	"isDisposed",
	"on",
	"off",
	"getDataURL",
	"getConnectedDataURL",
	"getOption",
	"getId",
	"updateLabelLayout"
], Yu = function() {
	function e(e) {
		I(Ju, function(t) {
			this[t] = z(e[t], e);
		}, this);
	}
	return e;
}();
function Xu(e, t) {
	return t.mainType === "series" ? e.getViewOfSeriesModel(t) : e.getViewOfComponentModel(t);
}
//#endregion
//#region node_modules/echarts/lib/util/states.js
var Zu = 1, Qu = {}, $u = X(), ed = X(), td = [
	"emphasis",
	"blur",
	"select"
], nd = [
	"normal",
	"emphasis",
	"blur",
	"select"
], rd = "highlight", id = "downplay", ad = "select", od = "unselect", sd = "toggleSelect", cd = "selectchanged";
function ld(e) {
	return e != null && e !== "none";
}
function ud(e, t, n) {
	e.onHoverStateChange && (e.hoverState || 0) !== n && e.onHoverStateChange(t), e.hoverState = n;
}
function dd(e) {
	ud(e, "emphasis", 2);
}
function fd(e) {
	e.hoverState === 2 && ud(e, "normal", 0);
}
function pd(e) {
	ud(e, "blur", 1);
}
function md(e) {
	e.hoverState === 1 && ud(e, "normal", 0);
}
function hd(e) {
	e.selected = !0;
}
function gd(e) {
	e.selected = !1;
}
function _d(e, t, n) {
	t(e, n);
}
function vd(e, t, n) {
	_d(e, t, n), e.isGroup && e.traverse(function(e) {
		_d(e, t, n);
	});
}
function yd(e, t) {
	switch (t) {
		case "emphasis":
			e.hoverState = 2;
			break;
		case "normal":
			e.hoverState = 0;
			break;
		case "blur":
			e.hoverState = 1;
			break;
		case "select": e.selected = !0;
	}
}
function bd(e, t, n, r) {
	for (var i = e.style, a = {}, o = 0; o < t.length; o++) {
		var s = t[o];
		a[s] = i[s] ?? (r && r[s]);
	}
	for (var o = 0; o < e.animators.length; o++) {
		var c = e.animators[o];
		c.__fromStateTransition && c.__fromStateTransition.indexOf(n) < 0 && c.targetName === "style" && c.saveTo(a, t);
	}
	return a;
}
function xd(e, t, n, r) {
	var i = n && P(n, "select") >= 0, a = !1;
	if (e instanceof ou) {
		var o = $u(e), s = i && o.selectFill || o.normalFill, c = i && o.selectStroke || o.normalStroke;
		if (ld(s) || ld(c)) {
			r ||= {};
			var l = r.style || {};
			l.fill === "inherit" ? (a = !0, r = M({}, r), l = M({}, l), l.fill = s) : !ld(l.fill) && ld(s) ? (a = !0, r = M({}, r), l = M({}, l), l.fill = ni(s)) : !ld(l.stroke) && ld(c) && (a || (r = M({}, r), l = M({}, l)), l.stroke = ni(c)), r.style = l;
		}
	}
	if (r && r.z2 == null) {
		a || (r = M({}, r));
		var u = e.z2EmphasisLift;
		r.z2 = e.z2 + (u ?? 10);
	}
	return r;
}
function Sd(e, t, n) {
	if (n && n.z2 == null) {
		n = M({}, n);
		var r = e.z2SelectLift;
		n.z2 = e.z2 + (r ?? 9);
	}
	return n;
}
function Cd(e, t, n) {
	var r = P(e.currentStates, t) >= 0, i = e.style.opacity, a = r ? null : bd(e, ["opacity"], t, { opacity: 1 });
	n ||= {};
	var o = n.style || {};
	return o.opacity ?? (n = M({}, n), o = M({ opacity: r ? i : a.opacity * .1 }, o), n.style = o), n;
}
function wd(e, t) {
	var n = this.states[e];
	if (this.style) {
		if (e === "emphasis") return xd(this, e, t, n);
		if (e === "blur") return Cd(this, e, n);
		if (e === "select") return Sd(this, e, n);
	}
	return n;
}
function Td(e) {
	e.stateProxy = wd;
	var t = e.getTextContent(), n = e.getTextGuideLine();
	t && (t.stateProxy = wd), n && (n.stateProxy = wd);
}
function Ed(e, t) {
	!Pd(e, t) && !e.__highByOuter && vd(e, dd);
}
function Dd(e, t) {
	!Pd(e, t) && !e.__highByOuter && vd(e, fd);
}
function Od(e, t) {
	e.__highByOuter |= 1 << (t || 0), vd(e, dd);
}
function kd(e, t) {
	!(e.__highByOuter &= ~(1 << (t || 0))) && vd(e, fd);
}
function Ad(e) {
	vd(e, pd);
}
function jd(e) {
	vd(e, md);
}
function Md(e) {
	vd(e, hd);
}
function Nd(e) {
	vd(e, gd);
}
function Pd(e, t) {
	return e.__highDownSilentOnTouch && t.zrByTouch;
}
function Fd(e) {
	var t = e.getModel(), n = [], r = [];
	t.eachComponent(function(t, i) {
		var a = ed(i), o = Xu(e, i), s = t === "series";
		!s && r.push(o), a.isBlured && (o.group.traverse(function(e) {
			md(e);
		}), s && n.push(i)), a.isBlured = !1;
	}), I(r, function(e) {
		e && e.toggleBlurSeries && e.toggleBlurSeries(n, !1, t);
	});
}
function Id(e, t, n, r) {
	var i = r.getModel();
	n ||= "coordinateSystem";
	function a(e, t) {
		for (var n = 0; n < t.length; n++) {
			var r = e.getItemGraphicEl(t[n]);
			r && jd(r);
		}
	}
	if (e != null && t && t !== "none") {
		var o = i.getSeriesByIndex(e), s = o.coordinateSystem;
		s && s.master && (s = s.master);
		var c = [];
		i.eachSeries(function(e) {
			var i = o === e, l = e.coordinateSystem;
			if (l && l.master && (l = l.master), !(n === "series" && !i || n === "coordinateSystem" && !(l && s ? l === s : i) || t === "series" && i)) {
				if (r.getViewOfSeriesModel(e).group.traverse(function(e) {
					e.__highByOuter && i && t === "self" || pd(e);
				}), ie(t)) a(e.getData(), t);
				else if (W(t)) for (var u = R(t), d = 0; d < u.length; d++) a(e.getData(u[d]), t[u[d]]);
				c.push(e), ed(e).isBlured = !0;
			}
		}), i.eachComponent(function(e, t) {
			if (e !== "series") {
				var n = r.getViewOfComponentModel(t);
				n && n.toggleBlurSeries && n.toggleBlurSeries(c, !0, i);
			}
		});
	}
}
function Ld(e, t, n) {
	if (e != null && t != null) {
		var r = n.getModel().getComponent(e, t);
		if (r) {
			ed(r).isBlured = !0;
			var i = n.getViewOfComponentModel(r);
			i && i.focusBlurEnabled && i.group.traverse(function(e) {
				pd(e);
			});
		}
	}
}
function Rd(e, t, n) {
	var r = e.seriesIndex, i = e.getData(t.dataType);
	if (i) {
		var a = Ds(i, t);
		a = (V(a) ? a[0] : a) || 0;
		var o = i.getItemGraphicEl(a);
		if (!o) for (var s = i.count(), c = 0; !o && c < s;) o = i.getItemGraphicEl(c++);
		if (o) {
			var l = Z(o);
			Id(r, l.focus, l.blurScope, n);
		} else {
			var u = e.get(["emphasis", "focus"]), d = e.get(["emphasis", "blurScope"]);
			u != null && Id(r, u, d, n);
		}
	}
}
function zd(e, t, n, r) {
	var i = {
		focusSelf: !1,
		dispatchers: null
	};
	if (e == null || e === "series" || t == null || n == null) return i;
	var a = r.getModel().getComponent(e, t);
	if (!a) return i;
	var o = r.getViewOfComponentModel(a);
	if (!o || !o.findHighDownDispatchers) return i;
	for (var s = o.findHighDownDispatchers(n), c, l = 0; l < s.length; l++) if (Z(s[l]).focus === "self") {
		c = !0;
		break;
	}
	return {
		focusSelf: c,
		dispatchers: s
	};
}
function Bd(e, t, n) {
	var r = Z(e), i = zd(r.componentMainType, r.componentIndex, r.componentHighDownName, n), a = i.dispatchers, o = i.focusSelf;
	a ? (o && Ld(r.componentMainType, r.componentIndex, n), I(a, function(e) {
		return Ed(e, t);
	})) : (Id(r.seriesIndex, r.focus, r.blurScope, n), r.focus === "self" && Ld(r.componentMainType, r.componentIndex, n), Ed(e, t));
}
function Vd(e, t, n) {
	Fd(n);
	var r = Z(e), i = zd(r.componentMainType, r.componentIndex, r.componentHighDownName, n).dispatchers;
	i ? I(i, function(e) {
		return Dd(e, t);
	}) : Dd(e, t);
}
function Hd(e, t, n) {
	if (tf(t)) {
		var r = t.dataType, i = Ds(e.getData(r), t);
		V(i) || (i = [i]), e[t.type === "toggleSelect" ? "toggleSelect" : t.type === "select" ? "select" : "unselect"](i, r);
	}
}
function Ud(e) {
	I(e.getAllData(), function(t) {
		var n = t.data, r = t.type;
		n.eachItemGraphicEl(function(t, n) {
			e.isSelected(n, r) ? Md(t) : Nd(t);
		});
	});
}
function Wd(e) {
	var t = [];
	return e.eachSeries(function(e) {
		I(e.getAllData(), function(n) {
			n.data;
			var r = n.type, i = e.getSelectedDataIndices();
			if (i.length > 0) {
				var a = {
					dataIndex: i,
					seriesIndex: e.seriesIndex
				};
				r != null && (a.dataType = r), t.push(a);
			}
		});
	}), t;
}
function Gd(e, t, n) {
	Qd(e, !0), vd(e, Td), Jd(e, t, n);
}
function Kd(e) {
	Qd(e, !1);
}
function qd(e, t, n, r) {
	r ? Kd(e) : Gd(e, t, n);
}
function Jd(e, t, n) {
	var r = Z(e);
	t == null ? r.focus &&= null : (r.focus = t, r.blurScope = n);
}
var Yd = [
	"emphasis",
	"blur",
	"select"
], Xd = {
	itemStyle: "getItemStyle",
	lineStyle: "getLineStyle",
	areaStyle: "getAreaStyle"
};
function Zd(e, t, n, r) {
	n ||= "itemStyle";
	for (var i = 0; i < Yd.length; i++) {
		var a = Yd[i], o = t.getModel([a, n]), s = e.ensureState(a);
		s.style = r ? r(o) : o[Xd[n]]();
	}
}
function Qd(e, t) {
	var n = t === !1, r = e;
	e.highDownSilentOnTouch && (r.__highDownSilentOnTouch = e.highDownSilentOnTouch), (!n || r.__highDownDispatcher) && (r.__highByOuter = r.__highByOuter || 0, r.__highDownDispatcher = !n);
}
function $d(e) {
	return !!(e && e.__highDownDispatcher);
}
function ef(e) {
	var t = Qu[e];
	return t == null && Zu <= 32 && (t = Qu[e] = Zu++), t;
}
function tf(e) {
	var t = e.type;
	return t === "select" || t === "unselect" || t === "toggleSelect";
}
function nf(e) {
	var t = e.type;
	return t === "highlight" || t === "downplay";
}
function rf(e) {
	var t = $u(e);
	t.normalFill = e.style.fill, t.normalStroke = e.style.stroke;
	var n = e.states.select || {};
	t.selectFill = n.style && n.style.fill || null, t.selectStroke = n.style && n.style.stroke || null;
}
//#endregion
//#region node_modules/zrender/lib/tool/transformPath.js
var af = Fl.CMD, of = [
	[],
	[],
	[]
], sf = Math.sqrt, cf = Math.atan2;
function lf(e, t) {
	if (t) {
		var n = e.data, r = e.len(), i, a, o, s, c, l, u = af.M, d = af.C, f = af.L, p = af.R, m = af.A, h = af.Q;
		for (o = 0, s = 0; o < r;) {
			switch (i = n[o++], s = o, a = 0, i) {
				case u:
					a = 1;
					break;
				case f:
					a = 1;
					break;
				case d:
					a = 3;
					break;
				case h:
					a = 2;
					break;
				case m:
					var g = t[4], _ = t[5], v = sf(t[0] * t[0] + t[1] * t[1]), y = sf(t[2] * t[2] + t[3] * t[3]), b = cf(-t[1] / y, t[0] / v);
					n[o] *= v, n[o++] += g, n[o] *= y, n[o++] += _, n[o++] *= v, n[o++] *= y, n[o++] += b, n[o++] += b, o += 2, s = o;
					break;
				case p: l[0] = n[o++], l[1] = n[o++], ot(l, l, t), n[s++] = l[0], n[s++] = l[1], l[0] += n[o++], l[1] += n[o++], ot(l, l, t), n[s++] = l[0], n[s++] = l[1];
			}
			for (c = 0; c < a; c++) {
				var x = of[c];
				x[0] = n[o++], x[1] = n[o++], ot(x, x, t), n[s++] = x[0], n[s++] = x[1];
			}
		}
		e.increaseVersion();
	}
}
//#endregion
//#region node_modules/zrender/lib/tool/path.js
var uf = Math.sqrt, df = Math.sin, ff = Math.cos, pf = Math.PI;
function mf(e) {
	return Math.sqrt(e[0] * e[0] + e[1] * e[1]);
}
function hf(e, t) {
	return (e[0] * t[0] + e[1] * t[1]) / (mf(e) * mf(t));
}
function gf(e, t) {
	return (e[0] * t[1] < e[1] * t[0] ? -1 : 1) * Math.acos(hf(e, t));
}
function _f(e, t, n, r, i, a, o, s, c, l, u) {
	var d = pf / 180 * c, f = ff(d) * (e - n) / 2 + df(d) * (t - r) / 2, p = -1 * df(d) * (e - n) / 2 + ff(d) * (t - r) / 2, m = f * f / (o * o) + p * p / (s * s);
	m > 1 && (o *= uf(m), s *= uf(m));
	var h = (i === a ? -1 : 1) * uf((o * o * (s * s) - o * o * (p * p) - s * s * (f * f)) / (o * o * (p * p) + s * s * (f * f))) || 0, g = h * o * p / s, _ = h * -s * f / o, v = (e + n) / 2 + ff(d) * g - df(d) * _, y = (t + r) / 2 + df(d) * g + ff(d) * _, b = gf([1, 0], [(f - g) / o, (p - _) / s]), x = [(f - g) / o, (p - _) / s], S = [(-1 * f - g) / o, (-1 * p - _) / s], C = gf(x, S);
	if (hf(x, S) <= -1 && (C = pf), hf(x, S) >= 1 && (C = 0), C < 0) {
		var w = Math.round(C / pf * 1e6) / 1e6;
		C = pf * 2 + w % 2 * pf;
	}
	u.addData(l, v, y, o, s, b, C, d, a);
}
var vf = /([mlvhzcqtsa])([^mlvhzcqtsa]*)/gi, yf = /-?([0-9]*\.)?[0-9]+([eE]-?[0-9]+)?/g;
function bf(e) {
	var t = new Fl();
	if (!e) return t;
	var n = 0, r = 0, i = n, a = r, o, s = Fl.CMD, c = e.match(vf);
	if (!c) return t;
	for (var l = 0; l < c.length; l++) {
		for (var u = c[l], d = u.charAt(0), f = void 0, p = u.match(yf) || [], m = p.length, h = 0; h < m; h++) p[h] = parseFloat(p[h]);
		for (var g = 0; g < m;) {
			var _ = void 0, v = void 0, y = void 0, b = void 0, x = void 0, S = void 0, C = void 0, w = n, T = r, E = void 0, D = void 0;
			switch (d) {
				case "l":
					n += p[g++], r += p[g++], f = s.L, t.addData(f, n, r);
					break;
				case "L":
					n = p[g++], r = p[g++], f = s.L, t.addData(f, n, r);
					break;
				case "m":
					n += p[g++], r += p[g++], f = s.M, t.addData(f, n, r), i = n, a = r, d = "l";
					break;
				case "M":
					n = p[g++], r = p[g++], f = s.M, t.addData(f, n, r), i = n, a = r, d = "L";
					break;
				case "h":
					n += p[g++], f = s.L, t.addData(f, n, r);
					break;
				case "H":
					n = p[g++], f = s.L, t.addData(f, n, r);
					break;
				case "v":
					r += p[g++], f = s.L, t.addData(f, n, r);
					break;
				case "V":
					r = p[g++], f = s.L, t.addData(f, n, r);
					break;
				case "C":
					f = s.C, t.addData(f, p[g++], p[g++], p[g++], p[g++], p[g++], p[g++]), n = p[g - 2], r = p[g - 1];
					break;
				case "c":
					f = s.C, t.addData(f, p[g++] + n, p[g++] + r, p[g++] + n, p[g++] + r, p[g++] + n, p[g++] + r), n += p[g - 2], r += p[g - 1];
					break;
				case "S":
					_ = n, v = r, E = t.len(), D = t.data, o === s.C && (_ += n - D[E - 4], v += r - D[E - 3]), f = s.C, w = p[g++], T = p[g++], n = p[g++], r = p[g++], t.addData(f, _, v, w, T, n, r);
					break;
				case "s":
					_ = n, v = r, E = t.len(), D = t.data, o === s.C && (_ += n - D[E - 4], v += r - D[E - 3]), f = s.C, w = n + p[g++], T = r + p[g++], n += p[g++], r += p[g++], t.addData(f, _, v, w, T, n, r);
					break;
				case "Q":
					w = p[g++], T = p[g++], n = p[g++], r = p[g++], f = s.Q, t.addData(f, w, T, n, r);
					break;
				case "q":
					w = p[g++] + n, T = p[g++] + r, n += p[g++], r += p[g++], f = s.Q, t.addData(f, w, T, n, r);
					break;
				case "T":
					_ = n, v = r, E = t.len(), D = t.data, o === s.Q && (_ += n - D[E - 4], v += r - D[E - 3]), n = p[g++], r = p[g++], f = s.Q, t.addData(f, _, v, n, r);
					break;
				case "t":
					_ = n, v = r, E = t.len(), D = t.data, o === s.Q && (_ += n - D[E - 4], v += r - D[E - 3]), n += p[g++], r += p[g++], f = s.Q, t.addData(f, _, v, n, r);
					break;
				case "A":
					y = p[g++], b = p[g++], x = p[g++], S = p[g++], C = p[g++], w = n, T = r, n = p[g++], r = p[g++], f = s.A, _f(w, T, n, r, S, C, y, b, x, f, t);
					break;
				case "a": y = p[g++], b = p[g++], x = p[g++], S = p[g++], C = p[g++], w = n, T = r, n += p[g++], r += p[g++], f = s.A, _f(w, T, n, r, S, C, y, b, x, f, t);
			}
		}
		(d === "z" || d === "Z") && (f = s.Z, t.addData(f), n = i, r = a), o = f;
	}
	return t.toStatic(), t;
}
var xf = function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t.prototype.applyTransform = function(e) {}, t;
}(ou);
function Sf(e) {
	return e.setData != null;
}
function Cf(e, t) {
	var n = bf(e), r = M({}, t);
	return r.buildPath = function(e) {
		var t = Sf(e);
		if (t && e.canSave()) {
			e.appendPath(n);
			var r = e.getContext();
			r && e.rebuildPath(r, 1);
		} else {
			var r = t ? e.getContext() : e;
			r && n.rebuildPath(r, 1);
		}
	}, r.applyTransform = function(e) {
		lf(n, e), this.dirtyShape();
	}, r;
}
function wf(e, t) {
	return new xf(Cf(e, t));
}
function Tf(e, t) {
	var r = Cf(e, t);
	return function(e) {
		n(t, e);
		function t(t) {
			var n = e.call(this, t) || this;
			return n.applyTransform = r.applyTransform, n.buildPath = r.buildPath, n;
		}
		return t;
	}(xf);
}
function Ef(e, t) {
	for (var n = [], r = e.length, i = 0; i < r; i++) {
		var a = e[i];
		n.push(a.getUpdatedPathProxy(!0));
	}
	var o = new ou(t);
	return o.createPathProxy(), o.buildPath = function(e) {
		if (Sf(e)) {
			e.appendPath(n);
			var t = e.getContext();
			t && e.rebuildPath(t, 1);
		}
	}, o;
}
//#endregion
//#region node_modules/zrender/lib/graphic/shape/Circle.js
var Df = function() {
	function e() {
		this.cx = 0, this.cy = 0, this.r = 0;
	}
	return e;
}(), Of = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.getDefaultShape = function() {
		return new Df();
	}, t.prototype.buildPath = function(e, t) {
		e.moveTo(t.cx + t.r, t.cy), e.arc(t.cx, t.cy, t.r, 0, Math.PI * 2);
	}, t;
}(ou);
Of.prototype.type = "circle";
//#endregion
//#region node_modules/zrender/lib/graphic/shape/Ellipse.js
var kf = function() {
	function e() {
		this.cx = 0, this.cy = 0, this.rx = 0, this.ry = 0;
	}
	return e;
}(), Af = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.getDefaultShape = function() {
		return new kf();
	}, t.prototype.buildPath = function(e, t) {
		var n = .5522848, r = t.cx, i = t.cy, a = t.rx, o = t.ry, s = a * n, c = o * n;
		e.moveTo(r - a, i), e.bezierCurveTo(r - a, i - c, r - s, i - o, r, i - o), e.bezierCurveTo(r + s, i - o, r + a, i - c, r + a, i), e.bezierCurveTo(r + a, i + c, r + s, i + o, r, i + o), e.bezierCurveTo(r - s, i + o, r - a, i + c, r - a, i), e.closePath();
	}, t;
}(ou);
Af.prototype.type = "ellipse";
//#endregion
//#region node_modules/zrender/lib/graphic/helper/roundSector.js
var jf = Math.PI, Mf = jf * 2, Nf = Math.sin, Pf = Math.cos, Ff = Math.acos, If = Math.atan2, Lf = Math.abs, Rf = Math.sqrt, zf = Math.max, Bf = Math.min, Vf = 1e-4;
function Hf(e, t, n, r, i, a, o, s) {
	var c = n - e, l = r - t, u = o - i, d = s - a, f = d * c - u * l;
	if (!(f * f < Vf)) return f = (u * (t - a) - d * (e - i)) / f, [e + f * c, t + f * l];
}
function Uf(e, t, n, r, i, a, o) {
	var s = e - n, c = t - r, l = (o ? a : -a) / Rf(s * s + c * c), u = l * c, d = -l * s, f = e + u, p = t + d, m = n + u, h = r + d, g = (f + m) / 2, _ = (p + h) / 2, v = m - f, y = h - p, b = v * v + y * y, x = i - a, S = f * h - m * p, C = (y < 0 ? -1 : 1) * Rf(zf(0, x * x * b - S * S)), w = (S * y - v * C) / b, T = (-S * v - y * C) / b, E = (S * y + v * C) / b, D = (-S * v + y * C) / b, O = w - g, k = T - _, A = E - g, j = D - _;
	return O * O + k * k > A * A + j * j && (w = E, T = D), {
		cx: w,
		cy: T,
		x0: -u,
		y0: -d,
		x1: w * (i / x - 1),
		y1: T * (i / x - 1)
	};
}
function Wf(e) {
	var t;
	if (V(e)) {
		var n = e.length;
		if (!n) return e;
		t = n === 1 ? [
			e[0],
			e[0],
			0,
			0
		] : n === 2 ? [
			e[0],
			e[0],
			e[1],
			e[1]
		] : n === 3 ? e.concat(e[2]) : e;
	} else t = [
		e,
		e,
		e,
		e
	];
	return t;
}
function Gf(e, t) {
	var n, r = zf(t.r, 0), i = zf(t.r0 || 0, 0), a = r > 0;
	if (a || i > 0) {
		if (a || (r = i, i = 0), i > r) {
			var o = r;
			r = i, i = o;
		}
		var s = t.startAngle, c = t.endAngle;
		if (!(isNaN(s) || isNaN(c))) {
			var l = t.cx, u = t.cy, d = !!t.clockwise, f = Lf(c - s), p = f > Mf && f % Mf;
			if (p > Vf && (f = p), !(r > Vf)) e.moveTo(l, u);
			else if (f > Mf - Vf) e.moveTo(l + r * Pf(s), u + r * Nf(s)), e.arc(l, u, r, s, c, !d), i > Vf && (e.moveTo(l + i * Pf(c), u + i * Nf(c)), e.arc(l, u, i, c, s, d));
			else {
				var m = void 0, h = void 0, g = void 0, _ = void 0, v = void 0, y = void 0, b = void 0, x = void 0, S = void 0, C = void 0, w = void 0, T = void 0, E = void 0, D = void 0, O = void 0, k = void 0, A = r * Pf(s), j = r * Nf(s), ee = i * Pf(c), M = i * Nf(c), te = f > Vf;
				if (te) {
					var N = t.cornerRadius;
					N && (n = Wf(N), m = n[0], h = n[1], g = n[2], _ = n[3]);
					var ne = Lf(r - i) / 2;
					if (v = Bf(ne, g), y = Bf(ne, _), b = Bf(ne, m), x = Bf(ne, h), w = S = zf(v, y), T = C = zf(b, x), (S > Vf || C > Vf) && (E = r * Pf(c), D = r * Nf(c), O = i * Pf(s), k = i * Nf(s), f < jf)) {
						var P = Hf(A, j, O, k, E, D, ee, M);
						if (P) {
							var re = A - P[0], F = j - P[1], ie = E - P[0], I = D - P[1], L = 1 / Nf(Ff((re * ie + F * I) / (Rf(re * re + F * F) * Rf(ie * ie + I * I))) / 2), ae = Rf(P[0] * P[0] + P[1] * P[1]);
							w = Bf(S, (r - ae) / (L + 1)), T = Bf(C, (i - ae) / (L - 1));
						}
					}
				}
				if (!te) e.moveTo(l + A, u + j);
				else if (w > Vf) {
					var oe = Bf(g, w), se = Bf(_, w), R = Uf(O, k, A, j, r, oe, d), ce = Uf(E, D, ee, M, r, se, d);
					e.moveTo(l + R.cx + R.x0, u + R.cy + R.y0), w < S && oe === se ? e.arc(l + R.cx, u + R.cy, w, If(R.y0, R.x0), If(ce.y0, ce.x0), !d) : (oe > 0 && e.arc(l + R.cx, u + R.cy, oe, If(R.y0, R.x0), If(R.y1, R.x1), !d), e.arc(l, u, r, If(R.cy + R.y1, R.cx + R.x1), If(ce.cy + ce.y1, ce.cx + ce.x1), !d), se > 0 && e.arc(l + ce.cx, u + ce.cy, se, If(ce.y1, ce.x1), If(ce.y0, ce.x0), !d));
				} else e.moveTo(l + A, u + j), e.arc(l, u, r, s, c, !d);
				if (!(i > Vf) || !te) e.lineTo(l + ee, u + M);
				else if (T > Vf) {
					var oe = Bf(m, T), se = Bf(h, T), R = Uf(ee, M, E, D, i, -se, d), ce = Uf(A, j, O, k, i, -oe, d);
					e.lineTo(l + R.cx + R.x0, u + R.cy + R.y0), T < C && oe === se ? e.arc(l + R.cx, u + R.cy, T, If(R.y0, R.x0), If(ce.y0, ce.x0), !d) : (se > 0 && e.arc(l + R.cx, u + R.cy, se, If(R.y0, R.x0), If(R.y1, R.x1), !d), e.arc(l, u, i, If(R.cy + R.y1, R.cx + R.x1), If(ce.cy + ce.y1, ce.cx + ce.x1), d), oe > 0 && e.arc(l + ce.cx, u + ce.cy, oe, If(ce.y1, ce.x1), If(ce.y0, ce.x0), !d));
				} else e.lineTo(l + ee, u + M), e.arc(l, u, i, c, s, d);
			}
			e.closePath();
		}
	}
}
//#endregion
//#region node_modules/zrender/lib/graphic/shape/Sector.js
var Kf = function() {
	function e() {
		this.cx = 0, this.cy = 0, this.r0 = 0, this.r = 0, this.startAngle = 0, this.endAngle = Math.PI * 2, this.clockwise = !0, this.cornerRadius = 0;
	}
	return e;
}(), qf = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.getDefaultShape = function() {
		return new Kf();
	}, t.prototype.buildPath = function(e, t) {
		Gf(e, t);
	}, t.prototype.isZeroArea = function() {
		return this.shape.startAngle === this.shape.endAngle || this.shape.r === this.shape.r0;
	}, t;
}(ou);
qf.prototype.type = "sector";
//#endregion
//#region node_modules/zrender/lib/graphic/shape/Ring.js
var Jf = function() {
	function e() {
		this.cx = 0, this.cy = 0, this.r = 0, this.r0 = 0;
	}
	return e;
}(), Yf = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.getDefaultShape = function() {
		return new Jf();
	}, t.prototype.buildPath = function(e, t) {
		var n = t.cx, r = t.cy, i = Math.PI * 2;
		e.moveTo(n + t.r, r), e.arc(n, r, t.r, 0, i, !1), e.moveTo(n + t.r0, r), e.arc(n, r, t.r0, 0, i, !0);
	}, t;
}(ou);
Yf.prototype.type = "ring";
//#endregion
//#region node_modules/zrender/lib/graphic/helper/smoothBezier.js
function Xf(e, t, n, r) {
	var i = [], a = [], o = [], s = [], c, l, u, d;
	if (r) {
		u = [Infinity, Infinity], d = [-Infinity, -Infinity];
		for (var f = 0, p = e.length; f < p; f++) st(u, u, e[f]), ct(d, d, e[f]);
		st(u, u, r[0]), ct(d, d, r[1]);
	}
	for (var f = 0, p = e.length; f < p; f++) {
		var m = e[f];
		if (n) c = e[f ? f - 1 : p - 1], l = e[(f + 1) % p];
		else if (f === 0 || f === p - 1) {
			i.push(Be(e[f]));
			continue;
		} else c = e[f - 1], l = e[f + 1];
		We(a, l, c), Qe(a, a, t);
		var h = et(m, c), g = et(m, l), _ = h + g;
		_ !== 0 && (h /= _, g /= _), Qe(o, a, -h), Qe(s, a, g);
		var v = He([], m, o), y = He([], m, s);
		r && (ct(v, v, u), st(v, v, d), ct(y, y, u), st(y, y, d)), i.push(v), i.push(y);
	}
	return n && i.push(i.shift()), i;
}
//#endregion
//#region node_modules/zrender/lib/graphic/helper/poly.js
function Zf(e, t, n) {
	var r = t.smooth, i = t.points;
	if (i && i.length >= 2) {
		if (r) {
			var a = Xf(i, r, n, t.smoothConstraint);
			e.moveTo(i[0][0], i[0][1]);
			for (var o = i.length, s = 0; s < (n ? o : o - 1); s++) {
				var c = a[s * 2], l = a[s * 2 + 1], u = i[(s + 1) % o];
				e.bezierCurveTo(c[0], c[1], l[0], l[1], u[0], u[1]);
			}
		} else {
			e.moveTo(i[0][0], i[0][1]);
			for (var s = 1, d = i.length; s < d; s++) e.lineTo(i[s][0], i[s][1]);
		}
		n && e.closePath();
	}
}
//#endregion
//#region node_modules/zrender/lib/graphic/shape/Polygon.js
var Qf = function() {
	function e() {
		this.points = null, this.smooth = 0, this.smoothConstraint = null;
	}
	return e;
}(), $f = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.getDefaultShape = function() {
		return new Qf();
	}, t.prototype.buildPath = function(e, t) {
		Zf(e, t, !0);
	}, t;
}(ou);
$f.prototype.type = "polygon";
//#endregion
//#region node_modules/zrender/lib/graphic/shape/Polyline.js
var ep = function() {
	function e() {
		this.points = null, this.percent = 1, this.smooth = 0, this.smoothConstraint = null;
	}
	return e;
}(), tp = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.getDefaultStyle = function() {
		return {
			stroke: "#000",
			fill: null
		};
	}, t.prototype.getDefaultShape = function() {
		return new ep();
	}, t.prototype.buildPath = function(e, t) {
		Zf(e, t, !1);
	}, t;
}(ou);
tp.prototype.type = "polyline";
//#endregion
//#region node_modules/zrender/lib/graphic/shape/Line.js
var np = {}, rp = function() {
	function e() {
		this.x1 = 0, this.y1 = 0, this.x2 = 0, this.y2 = 0, this.percent = 1;
	}
	return e;
}(), ip = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.getDefaultStyle = function() {
		return {
			stroke: "#000",
			fill: null
		};
	}, t.prototype.getDefaultShape = function() {
		return new rp();
	}, t.prototype.buildPath = function(e, t) {
		var n, r, i, a;
		if (this.subPixelOptimize) {
			var o = hu(np, t, this.style);
			n = o.x1, r = o.y1, i = o.x2, a = o.y2;
		} else n = t.x1, r = t.y1, i = t.x2, a = t.y2;
		var s = t.percent;
		s !== 0 && (e.moveTo(n, r), s < 1 && (i = n * (1 - s) + i * s, a = r * (1 - s) + a * s), e.lineTo(i, a));
	}, t.prototype.pointAt = function(e) {
		var t = this.shape;
		return [t.x1 * (1 - e) + t.x2 * e, t.y1 * (1 - e) + t.y2 * e];
	}, t;
}(ou);
ip.prototype.type = "line";
//#endregion
//#region node_modules/zrender/lib/graphic/shape/BezierCurve.js
var ap = [], op = function() {
	function e() {
		this.x1 = 0, this.y1 = 0, this.x2 = 0, this.y2 = 0, this.cpx1 = 0, this.cpy1 = 0, this.percent = 1;
	}
	return e;
}();
function sp(e, t, n) {
	var r = e.cpx2, i = e.cpy2;
	return r != null || i != null ? [(n ? cr : sr)(e.x1, e.cpx1, e.cpx2, e.x2, t), (n ? cr : sr)(e.y1, e.cpy1, e.cpy2, e.y2, t)] : [(n ? hr : mr)(e.x1, e.cpx1, e.x2, t), (n ? hr : mr)(e.y1, e.cpy1, e.y2, t)];
}
var cp = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.getDefaultStyle = function() {
		return {
			stroke: "#000",
			fill: null
		};
	}, t.prototype.getDefaultShape = function() {
		return new op();
	}, t.prototype.buildPath = function(e, t) {
		var n = t.x1, r = t.y1, i = t.x2, a = t.y2, o = t.cpx1, s = t.cpy1, c = t.cpx2, l = t.cpy2, u = t.percent;
		u !== 0 && (e.moveTo(n, r), c == null || l == null ? (u < 1 && (vr(n, o, i, u, ap), o = ap[1], i = ap[2], vr(r, s, a, u, ap), s = ap[1], a = ap[2]), e.quadraticCurveTo(o, s, i, a)) : (u < 1 && (dr(n, o, c, i, u, ap), o = ap[1], c = ap[2], i = ap[3], dr(r, s, l, a, u, ap), s = ap[1], l = ap[2], a = ap[3]), e.bezierCurveTo(o, s, c, l, i, a)));
	}, t.prototype.pointAt = function(e) {
		return sp(this.shape, e, !1);
	}, t.prototype.tangentAt = function(e) {
		var t = sp(this.shape, e, !0);
		return $e(t, t);
	}, t;
}(ou);
cp.prototype.type = "bezier-curve";
//#endregion
//#region node_modules/zrender/lib/graphic/shape/Arc.js
var lp = function() {
	function e() {
		this.cx = 0, this.cy = 0, this.r = 0, this.startAngle = 0, this.endAngle = Math.PI * 2, this.clockwise = !0;
	}
	return e;
}(), up = function(e) {
	n(t, e);
	function t(t) {
		return e.call(this, t) || this;
	}
	return t.prototype.getDefaultStyle = function() {
		return {
			stroke: "#000",
			fill: null
		};
	}, t.prototype.getDefaultShape = function() {
		return new lp();
	}, t.prototype.buildPath = function(e, t) {
		var n = t.cx, r = t.cy, i = Math.max(t.r, 0), a = t.startAngle, o = t.endAngle, s = t.clockwise, c = Math.cos(a), l = Math.sin(a);
		e.moveTo(c * i + n, l * i + r), e.arc(n, r, i, a, o, !s);
	}, t;
}(ou);
up.prototype.type = "arc";
//#endregion
//#region node_modules/zrender/lib/graphic/CompoundPath.js
var dp = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t.type = "compound", t;
	}
	return t.prototype._updatePathDirty = function() {
		for (var e = this.shape.paths, t = this.shapeChanged(), n = 0; n < e.length; n++) t ||= e[n].shapeChanged();
		t && this.dirtyShape();
	}, t.prototype.beforeBrush = function() {
		this._updatePathDirty();
		for (var e = this.shape.paths || [], t = this.getGlobalScale(), n = 0; n < e.length; n++) e[n].path || e[n].createPathProxy(), e[n].path.setScale(t[0], t[1], e[n].segmentIgnoreThreshold);
	}, t.prototype.buildPath = function(e, t) {
		for (var n = t.paths || [], r = 0; r < n.length; r++) n[r].buildPath(e, n[r].shape, !0);
	}, t.prototype.afterBrush = function() {
		for (var e = this.shape.paths || [], t = 0; t < e.length; t++) e[t].pathUpdated();
	}, t.prototype.getBoundingRect = function() {
		return this._updatePathDirty.call(this), ou.prototype.getBoundingRect.call(this);
	}, t;
}(ou), fp = function() {
	function e(e) {
		this.colorStops = e || [];
	}
	return e.prototype.addColorStop = function(e, t) {
		this.colorStops.push({
			offset: e,
			color: t
		});
	}, e;
}(), pp = function(e) {
	n(t, e);
	function t(t, n, r, i, a, o) {
		var s = e.call(this, a) || this;
		return s.x = t ?? 0, s.y = n ?? 0, s.x2 = r ?? 1, s.y2 = i ?? 0, s.type = "linear", s.global = o || !1, s;
	}
	return t;
}(fp), mp = function(e) {
	n(t, e);
	function t(t, n, r, i, a) {
		var o = e.call(this, i) || this;
		return o.x = t ?? .5, o.y = n ?? .5, o.r = r ?? .5, o.type = "radial", o.global = a || !1, o;
	}
	return t;
}(fp), hp = Math.min, gp = Math.max, _p = Math.abs, vp = [0, 0], yp = [0, 0], bp = Sn(), xp = bp.minTv, Sp = bp.maxTv, Cp = function() {
	function e(e, t) {
		this._corners = [], this._axes = [], this._origin = [0, 0];
		for (var n = 0; n < 4; n++) this._corners[n] = new J();
		for (var n = 0; n < 2; n++) this._axes[n] = new J();
		e && this.fromBoundingRect(e, t);
	}
	return e.prototype.fromBoundingRect = function(e, t) {
		var n = this._corners, r = this._axes, i = e.x, a = e.y, o = i + e.width, s = a + e.height;
		if (n[0].set(i, a), n[1].set(o, a), n[2].set(o, s), n[3].set(i, s), t) for (var c = 0; c < 4; c++) n[c].transform(t);
		J.sub(r[0], n[1], n[0]), J.sub(r[1], n[3], n[0]), r[0].normalize(), r[1].normalize();
		for (var c = 0; c < 2; c++) this._origin[c] = r[c].dot(n[0]);
	}, e.prototype.intersect = function(e, t, n) {
		var r = !0, i = !t;
		return t && J.set(t, 0, 0), bp.reset(n, !i), !this._intersectCheckOneSide(this, e, i, 1) && (r = !1, i) || !this._intersectCheckOneSide(e, this, i, -1) && (r = !1, i) || !i && !bp.negativeSize && J.copy(t, r ? bp.useDir ? bp.dirMinTv : xp : Sp), r;
	}, e.prototype._intersectCheckOneSide = function(e, t, n, r) {
		for (var i = !0, a = 0; a < 2; a++) {
			var o = e._axes[a];
			if (e._getProjMinMaxOnAxis(a, e._corners, vp), e._getProjMinMaxOnAxis(a, t._corners, yp), bp.negativeSize || vp[1] < yp[0] || vp[0] > yp[1]) {
				if (i = !1, bp.negativeSize || n) return i;
				var s = _p(yp[0] - vp[1]), c = _p(vp[0] - yp[1]);
				hp(s, c) > Sp.len() && (s < c ? J.scale(Sp, o, -s * r) : J.scale(Sp, o, c * r));
			} else if (!n) {
				var s = _p(yp[0] - vp[1]), c = _p(vp[0] - yp[1]);
				(bp.useDir || hp(s, c) < xp.len()) && ((s < c || !bp.bidirectional) && (J.scale(xp, o, s * r), bp.useDir && bp.calcDirMTV()), (s >= c || !bp.bidirectional) && (J.scale(xp, o, -c * r), bp.useDir && bp.calcDirMTV()));
			}
		}
		return i;
	}, e.prototype._getProjMinMaxOnAxis = function(e, t, n) {
		for (var r = this._axes[e], i = this._origin, a = t[0].dot(r) + i[e], o = a, s = a, c = 1; c < t.length; c++) {
			var l = t[c].dot(r) + i[e];
			o = hp(l, o), s = gp(l, s);
		}
		n[0] = o + bp.touchThreshold, n[1] = s - bp.touchThreshold, bp.negativeSize = n[1] < n[0];
	}, e;
}(), wp = [], Tp = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t.notClear = !0, t.incremental = 1, t._displayables = [], t._temporaryDisplayables = [], t._cursor = 0, t;
	}
	return t.prototype.traverse = function(e, t) {
		e.call(t, this);
	}, t.prototype.useStyle = function() {
		this.style = {};
	}, t.prototype._useHoverStyle = function() {
		this.__hoverStyle = null;
	}, t.prototype.getCursor = function() {
		return this._cursor;
	}, t.prototype.innerAfterBrush = function() {
		this._cursor = this._displayables.length;
	}, t.prototype.clearDisplaybles = function() {
		this._displayables = [], this._temporaryDisplayables = [], this._cursor = 0, this.markRedraw(), this.notClear = !1;
	}, t.prototype.clearTemporalDisplayables = function() {
		this._temporaryDisplayables = [];
	}, t.prototype.addDisplayable = function(e, t) {
		t ? this._temporaryDisplayables.push(e) : this._displayables.push(e), this.markRedraw();
	}, t.prototype.addDisplayables = function(e, t) {
		t ||= !1;
		for (var n = 0; n < e.length; n++) this.addDisplayable(e[n], t);
	}, t.prototype.getDisplayables = function() {
		return this._displayables;
	}, t.prototype.getTemporalDisplayables = function() {
		return this._temporaryDisplayables;
	}, t.prototype.eachPendingDisplayable = function(e) {
		for (var t = this._cursor; t < this._displayables.length; t++) e && e(this._displayables[t]);
		for (var t = 0; t < this._temporaryDisplayables.length; t++) e && e(this._temporaryDisplayables[t]);
	}, t.prototype.update = function() {
		this.updateTransform();
		for (var e = this._cursor; e < this._displayables.length; e++) {
			var t = this._displayables[e];
			t.parent = this, t.update(), t.parent = null;
		}
		for (var e = 0; e < this._temporaryDisplayables.length; e++) {
			var t = this._temporaryDisplayables[e];
			t.parent = this, t.update(), t.parent = null;
		}
	}, t.prototype.getBoundingRect = function() {
		if (!this._rect) {
			for (var e = new Y(Infinity, Infinity, -Infinity, -Infinity), t = 0; t < this._displayables.length; t++) {
				var n = this._displayables[t], r = n.getBoundingRect().clone();
				n.needLocalTransform() && r.applyTransform(n.getLocalTransform(wp)), e.union(r);
			}
			this._rect = e;
		}
		return this._rect;
	}, t.prototype.contain = function(e, t) {
		var n = this.transformCoordToLocal(e, t);
		if (this.getBoundingRect().contain(n[0], n[1])) {
			for (var r = 0; r < this._displayables.length; r++) if (this._displayables[r].contain(e, t)) return !0;
		}
		return !1;
	}, t;
}($c), Ep = X();
function Dp(e, t, n, r, i) {
	var a;
	if (t && t.ecModel) {
		var o = t.ecModel.getUpdatePayload();
		a = o && o.animation;
	}
	var s = t && t.isAnimationEnabled(), c = e === "update";
	if (s) {
		var l = void 0, u = void 0, d = void 0;
		return r ? (l = G(r.duration, 200), u = G(r.easing, "cubicOut"), d = 0) : (l = t.getShallow(c ? "animationDurationUpdate" : "animationDuration"), u = t.getShallow(c ? "animationEasingUpdate" : "animationEasing"), d = t.getShallow(c ? "animationDelayUpdate" : "animationDelay")), a && (a.duration != null && (l = a.duration), a.easing != null && (u = a.easing), a.delay != null && (d = a.delay)), H(d) && (d = d(n, i)), H(l) && (l = l(n)), {
			duration: l || 0,
			delay: d,
			easing: u
		};
	}
	return null;
}
function Op(e, t, n, r, i, a, o) {
	var s = !1, c;
	H(i) ? (o = a, a = i, i = null) : W(i) && (a = i.cb, o = i.during, s = i.isFrom, c = i.removeOpt, i = i.dataIndex);
	var l = e === "leave";
	l || t.stopAnimation("leave");
	var u = Dp(e, r, i, l ? c || {} : null, r && r.getAnimationDelayParams ? r.getAnimationDelayParams(t, i) : null);
	if (u && u.duration > 0) {
		var d = u.duration, f = u.delay, p = u.easing, m = {
			duration: d,
			delay: f || 0,
			easing: p,
			done: a,
			force: !!a || !!o,
			setToFinal: !l,
			scope: e,
			during: o
		};
		s ? t.animateFrom(n, m) : t.animateTo(n, m);
	} else t.stopAnimation(), !s && t.attr(n), o && o(1), a && a();
}
function kp(e, t, n, r, i, a) {
	Op("update", e, t, n, r, i, a);
}
function Ap(e, t, n, r, i, a) {
	Op("enter", e, t, n, r, i, a);
}
function jp(e) {
	if (!e.__zr) return !0;
	for (var t = 0; t < e.animators.length; t++) if (e.animators[t].scope === "leave") return !0;
	return !1;
}
function Mp(e, t, n, r, i, a) {
	jp(e) || Op("leave", e, t, n, r, i, a);
}
function Np(e, t, n, r) {
	e.removeTextContent(), e.removeTextGuideLine(), Mp(e, { style: { opacity: 0 } }, t, n, r);
}
function Pp(e, t, n) {
	function r() {
		e.parent && e.parent.remove(e);
	}
	e.isGroup ? e.traverse(function(e) {
		e.isGroup || Np(e, t, n, r);
	}) : Np(e, t, n, r);
}
function Fp(e) {
	Ep(e).oldStyle = e.style;
}
//#endregion
//#region node_modules/echarts/lib/util/graphic.js
var Ip = /* @__PURE__ */ e({
	Arc: () => up,
	BezierCurve: () => cp,
	BoundingRect: () => Y,
	Circle: () => Of,
	CompoundPath: () => dp,
	Ellipse: () => Af,
	Group: () => Wa,
	HOVER_LAYER_FOR_INCREMENTAL: () => 2,
	HOVER_LAYER_FROM_THRESHOLD: () => 1,
	HOVER_LAYER_NO: () => 0,
	Image: () => fu,
	IncrementalDisplayable: () => Tp,
	Line: () => ip,
	LinearGradient: () => pp,
	OrientedBoundingRect: () => Cp,
	Path: () => ou,
	Point: () => J,
	Polygon: () => $f,
	Polyline: () => tp,
	RadialGradient: () => mp,
	Rect: () => bu,
	Ring: () => Yf,
	Sector: () => qf,
	Text: () => Tu,
	WH: () => zp,
	XY: () => Rp,
	applyTransform: () => em,
	calcZ2Range: () => Cm,
	clipPointsByRect: () => am,
	clipRectByRect: () => om,
	createIcon: () => sm,
	decomposeTransform: () => Dm,
	ensureCopyRect: () => bm,
	ensureCopyTransform: () => xm,
	expandOrShrinkRect: () => fm,
	extendPath: () => Hp,
	extendShape: () => Bp,
	getCurrentCanvasPainter: () => km,
	getShapeClass: () => Wp,
	getTransform: () => $p,
	groupTransition: () => im,
	initProps: () => Ap,
	isBoundingRectAxisAligned: () => vm,
	isElementRemoved: () => jp,
	lineLineIntersect: () => lm,
	linePolygonIntersect: () => cm,
	makeImage: () => Kp,
	makePath: () => Gp,
	mergePath: () => Jp,
	payloadDisableAnimation: () => Em,
	registerShape: () => Up,
	removeElement: () => Mp,
	removeElementWithFadeOut: () => Pp,
	resizePath: () => Yp,
	retrieveZInfo: () => Sm,
	setTooltipConfig: () => hm,
	subPixelOptimize: () => Qp,
	subPixelOptimizeLine: () => Xp,
	subPixelOptimizeRect: () => Zp,
	transformDirection: () => tm,
	traverseElements: () => _m,
	traverseUpdateZ: () => wm,
	updateProps: () => kp
}), Lp = {}, Rp = ["x", "y"], zp = ["width", "height"];
function Bp(e) {
	return ou.extend(e);
}
var Vp = Tf;
function Hp(e, t) {
	return Vp(e, t);
}
function Up(e, t) {
	Lp[e] = t;
}
function Wp(e) {
	if (Lp.hasOwnProperty(e)) return Lp[e];
}
function Gp(e, t, n, r) {
	var i = wf(e, t);
	return n && (r === "center" && (n = qp(n, i.getBoundingRect())), Yp(i, n)), i;
}
function Kp(e, t, n) {
	var r = new fu({
		style: {
			image: e,
			x: t.x,
			y: t.y,
			width: t.width,
			height: t.height
		},
		onload: function(e) {
			if (n === "center") {
				var i = {
					width: e.width,
					height: e.height
				};
				r.setStyle(qp(t, i));
			}
		}
	});
	return r;
}
function qp(e, t) {
	var n = t.width / t.height, r = e.height * n, i;
	r <= e.width ? i = e.height : (r = e.width, i = r / n);
	var a = e.x + e.width / 2, o = e.y + e.height / 2;
	return {
		x: a - r / 2,
		y: o - i / 2,
		width: r,
		height: i
	};
}
var Jp = Ef;
function Yp(e, t) {
	if (e.applyTransform) {
		var n = e.getBoundingRect().calculateTransform(t);
		e.applyTransform(n);
	}
}
function Xp(e, t) {
	return hu(e, e, { lineWidth: t }), e;
}
function Zp(e, t) {
	return gu(e, e, t), e;
}
var Qp = _u;
function $p(e, t) {
	for (var n = Wt([]); e && e !== t;) Kt(n, e.getLocalTransform(), n), e = e.parent;
	return n;
}
function em(e, t, n) {
	return t && !ie(t) && (t = ca.getLocalTransform(t)), n && (t = Xt([], t)), ot([], e, t);
}
function tm(e, t, n) {
	var r = t[4] === 0 || t[5] === 0 || t[0] === 0 ? 1 : fo(2 * t[4] / t[0]), i = t[4] === 0 || t[5] === 0 || t[2] === 0 ? 1 : fo(2 * t[4] / t[2]), a = [e === "left" ? -r : e === "right" ? r : 0, e === "top" ? -i : e === "bottom" ? i : 0];
	return a = em(a, t, n), fo(a[0]) > fo(a[1]) ? a[0] > 0 ? "right" : "left" : a[1] > 0 ? "bottom" : "top";
}
function nm(e) {
	return !e.isGroup;
}
function rm(e) {
	return e.shape != null;
}
function im(e, t, n) {
	if (!e || !t) return;
	function r(e) {
		var t = {};
		return e.traverse(function(e) {
			nm(e) && e.anid && (t[e.anid] = e);
		}), t;
	}
	function i(e) {
		var t = {
			x: e.x,
			y: e.y,
			rotation: e.rotation
		};
		return rm(e) && (t.shape = A(e.shape)), t;
	}
	var a = r(e);
	t.traverse(function(e) {
		if (nm(e) && e.anid) {
			var t = a[e.anid];
			if (t) {
				var r = i(e);
				e.attr(i(t)), kp(e, r, n, Z(e).dataIndex);
			}
		}
	});
}
function am(e, t) {
	return L(e, function(e) {
		var n = e[0];
		n = uo(n, t.x), n = lo(n, t.x + t.width);
		var r = e[1];
		return r = uo(r, t.y), r = lo(r, t.y + t.height), [n, r];
	});
}
function om(e, t) {
	var n = uo(e.x, t.x), r = lo(e.x + e.width, t.x + t.width), i = uo(e.y, t.y), a = lo(e.y + e.height, t.y + t.height);
	if (r >= n && a >= i) return {
		x: n,
		y: i,
		width: r - n,
		height: a - i
	};
}
function sm(e, t, n) {
	var r = M({ rectHover: !0 }, t), i = r.style = { strokeNoScale: !0 };
	if (n ||= {
		x: -1,
		y: -1,
		width: 2,
		height: 2
	}, e) return e.indexOf("image://") === 0 ? (i.image = e.slice(8), N(i, n), new fu(r)) : Gp(e.replace("path://", ""), r, n, "center");
}
function cm(e, t, n, r, i) {
	for (var a = 0, o = i[i.length - 1]; a < i.length; a++) {
		var s = i[a];
		if (lm(e, t, n, r, s[0], s[1], o[0], o[1])) return !0;
		o = s;
	}
}
function lm(e, t, n, r, i, a, o, s) {
	var c = n - e, l = r - t, u = o - i, d = s - a, f = um(u, d, c, l);
	if (dm(f)) return !1;
	var p = e - i, m = t - a, h = um(p, m, c, l) / f;
	if (h < 0 || h > 1) return !1;
	var g = um(p, m, u, d) / f;
	return !(g < 0 || g > 1);
}
function um(e, t, n, r) {
	return e * r - n * t;
}
function dm(e) {
	return e <= 1e-6 && e >= -1e-6;
}
function fm(e, t, n, r, i) {
	return t == null || (ue(t) ? pm[0] = pm[1] = pm[2] = pm[3] = t : (pm[0] = t[0], pm[1] = t[1], pm[2] = t[2], pm[3] = t[3]), r && (pm[0] = uo(0, pm[0]), pm[1] = uo(0, pm[1]), pm[2] = uo(0, pm[2]), pm[3] = uo(0, pm[3])), n && (pm[0] = -pm[0], pm[1] = -pm[1], pm[2] = -pm[2], pm[3] = -pm[3]), mm(e, pm, "x", "width", 3, 1, i && i[0] || 0), mm(e, pm, "y", "height", 0, 2, i && i[1] || 0)), e;
}
var pm = [
	0,
	0,
	0,
	0
];
function mm(e, t, n, r, i, a, o) {
	var s = t[a] + t[i], c = e[r];
	e[r] += s, o = uo(0, lo(o, c)), e[r] < o ? (e[r] = o, e[n] += t[i] >= 0 ? -t[i] : t[a] >= 0 ? c + t[a] : fo(s) > 1e-8 ? (c - o) * t[i] / s : 0) : e[n] -= t[i];
}
function hm(e) {
	var t = e.itemTooltipOption, n = e.componentModel, r = e.itemName, i = U(t) ? { formatter: t } : t, a = n.mainType, o = n.componentIndex, s = {
		componentType: a,
		name: r,
		$vars: ["name"]
	};
	s[a + "Index"] = o;
	var c = e.formatterParamsExtra;
	c && I(R(c), function(e) {
		q(s, e) || (s[e] = c[e], s.$vars.push(e));
	});
	var l = Z(e.el);
	l.componentMainType = a, l.componentIndex = o, l.tooltipConfig = {
		name: r,
		option: N({
			content: r,
			encodeHTMLContent: !0,
			formatterParams: s
		}, i)
	};
}
function gm(e, t) {
	var n;
	e.isGroup && (n = t(e)), n || e.traverse(t);
}
function _m(e, t) {
	if (e) {
		if (V(e)) for (var n = 0; n < e.length; n++) gm(e[n], t);
		else gm(e, t);
	}
}
function vm(e) {
	return !e || fo(e[1]) < ym && fo(e[2]) < ym || fo(e[0]) < ym && fo(e[3]) < ym;
}
var ym = 1e-5;
function bm(e, t) {
	return e ? Y.copy(e, t) : t.clone();
}
function xm(e, t) {
	return t ? Gt(e || Ut(), t) : void 0;
}
function Sm(e) {
	return {
		z: e.get("z") || 0,
		zlevel: e.get("zlevel") || 0
	};
}
function Cm(e) {
	var t = -Infinity, n = Infinity;
	gm(e, function(e) {
		r(e), r(e.getTextContent()), r(e.getTextGuideLine());
	});
	function r(e) {
		if (e && !e.isGroup) {
			var t = e.currentStates;
			if (t.length) for (var n = 0; n < t.length; n++) i(e.states[t[n]]);
			i(e);
		}
	}
	function i(e) {
		if (e) {
			var r = e.z2;
			r > t && (t = r), r < n && (n = r);
		}
	}
	return n > t && (n = t = 0), {
		min: n,
		max: t
	};
}
function wm(e, t, n) {
	Tm(e, t, n, -Infinity);
}
function Tm(e, t, n, r) {
	if (e.ignoreModelZ) return r;
	var i = e.getTextContent(), a = e.getTextGuideLine();
	if (e.isGroup) for (var o = e.childrenRef(), s = 0; s < o.length; s++) r = uo(Tm(o[s], t, n, r), r);
	else e.z = t, e.zlevel = n, r = uo(e.z2 || 0, r);
	if (i && (i.z = t, i.zlevel = n, isFinite(r) && (i.z2 = r + 2)), a) {
		var c = e.textGuideLineConfig;
		a.z = t, a.zlevel = n, isFinite(r) && (a.z2 = r + (c && c.showAbove ? 1 : -1));
	}
	return r;
}
function Em(e) {
	return e.animation = { duration: 0 }, e;
}
function Dm(e, t) {
	return t ? Gt(Om.transform, t) : Wt(Om.transform), Om.decomposeTransform(), fa(e, Om), e;
}
var Om = new ca();
Om.transform = Ut();
function km(e) {
	var t = e.getZr().painter;
	return t.getType() === "canvas" ? t : null;
}
Up("circle", Of), Up("ellipse", Af), Up("sector", qf), Up("ring", Yf), Up("polygon", $f), Up("polyline", tp), Up("rect", bu), Up("line", ip), Up("bezierCurve", cp), Up("arc", up);
//#endregion
//#region node_modules/echarts/lib/label/labelStyle.js
var Am = {};
function jm(e, t) {
	for (var n = 0; n < td.length; n++) {
		var r = td[n], i = t[r], a = e.ensureState(r);
		a.style = a.style || {}, a.style.text = i;
	}
	var o = e.currentStates.slice();
	e.clearStates(!0), e.setStyle({ text: t.normal }), e.useStates(o, !0);
}
function Mm(e, t, n) {
	var r = e.labelFetcher, i = e.labelDataIndex, a = e.labelDimIndex, o = t.normal, s;
	r && (s = r.getFormattedLabel(i, "normal", null, a, o && o.get("formatter"), n == null ? null : { interpolatedValue: n })), s ??= H(e.defaultText) ? e.defaultText(i, e, n) : e.defaultText;
	for (var c = { normal: s }, l = 0; l < td.length; l++) {
		var u = td[l], d = t[u];
		c[u] = G(r ? r.getFormattedLabel(i, u, null, a, d && d.get("formatter")) : null, s);
	}
	return c;
}
function Nm(e, t, n, r) {
	n ||= Am;
	for (var i = e instanceof Tu, a = !1, o = 0; o < nd.length; o++) {
		var s = t[nd[o]];
		if (s && s.getShallow("show")) {
			a = !0;
			break;
		}
	}
	var c = i ? e : e.getTextContent();
	if (a) {
		i || (c || (c = new Tu(), e.setTextContent(c)), e.stateProxy && (c.stateProxy = e.stateProxy));
		var l = Mm(n, t), u = t.normal, d = !!u.getShallow("show"), f = Fm(u, r && r.normal, n, !1, !i);
		f.text = l.normal, i || e.setTextConfig(Im(u, n, !1));
		for (var o = 0; o < td.length; o++) {
			var p = td[o], s = t[p];
			if (s) {
				var m = c.ensureState(p), h = !!G(s.getShallow("show"), d);
				if (h !== d && (m.ignore = !h), m.style = Fm(s, r && r[p], n, !0, !i), m.style.text = l[p], !i) {
					var g = e.ensureState(p);
					g.textConfig = Im(s, n, !0);
				}
			}
		}
		c.silent = !!u.getShallow("silent"), c.style.x != null && (f.x = c.style.x), c.style.y != null && (f.y = c.style.y), c.ignore = !d, c.useStyle(f), c.dirty(), n.enableTextSetter && (Wm(c).setLabelText = function(e) {
			var r = Mm(n, t, e);
			jm(c, r);
		});
	} else c && (c.ignore = !0);
	e.dirty();
}
function Pm(e, t) {
	t ||= "label";
	for (var n = { normal: e.getModel(t) }, r = 0; r < td.length; r++) {
		var i = td[r];
		n[i] = e.getModel([i, t]);
	}
	return n;
}
function Fm(e, t, n, r, i) {
	var a = {};
	return Lm(a, e, n, r, i), t && M(a, t), a;
}
function Im(e, t, n) {
	t ||= {};
	var r = {}, i, a = e.getShallow("rotate"), o = G(e.getShallow("distance"), n ? null : 5), s = e.getShallow("offset");
	return i = e.getShallow("position") || (n ? null : "inside"), i === "outside" && (i = t.defaultOutsidePosition || "top"), i != null && (r.position = i), s != null && (r.offset = s), a != null && (a *= Math.PI / 180, r.rotation = a), o != null && (r.distance = o), r.outsideFill = e.get("color") === "inherit" ? t.inheritColor || null : "auto", t.autoOverflowArea != null && (r.autoOverflowArea = t.autoOverflowArea), t.layoutRect != null && (r.layoutRect = t.layoutRect), r;
}
function Lm(e, t, n, r, i) {
	n ||= Am;
	var a = t.ecModel, o = a && a.option.textStyle, s = Rm(t), c;
	if (s) {
		c = {};
		var l = "richInheritPlainLabel", u = G(t.get(l), a ? a.get(l) : void 0);
		for (var d in s) if (s.hasOwnProperty(d)) {
			var f = t.getModel(["rich", d]);
			Hm(c[d] = {}, f, o, t, u, n, r, i, !1, !0);
		}
	}
	c && (e.rich = c);
	var p = t.get("overflow");
	p && (e.overflow = p);
	var m = t.get("lineOverflow");
	m && (e.lineOverflow = m);
	var h = e, g = t.get("minMargin");
	if (g != null) g = ue(g) ? g / 2 : 0, h.margin = [
		g,
		g,
		g,
		g
	], h.__marginType = qm.minMargin;
	else {
		var _ = t.get("textMargin");
		_ != null && (h.margin = xe(_), h.__marginType = qm.textMargin);
	}
	Hm(e, t, o, null, null, n, r, i, !0, !1);
}
function Rm(e) {
	for (var t; e && e !== e.ecModel;) {
		var n = (e.option || Am).rich;
		if (n) {
			t ||= {};
			for (var r = R(n), i = 0; i < r.length; i++) {
				var a = r[i];
				t[a] = 1;
			}
		}
		e = e.parentModel;
	}
	return t;
}
var zm = [
	"fontStyle",
	"fontWeight",
	"fontSize",
	"fontFamily",
	"textShadowColor",
	"textShadowBlur",
	"textShadowOffsetX",
	"textShadowOffsetY"
], Bm = [
	"align",
	"lineHeight",
	"width",
	"height",
	"tag",
	"verticalAlign",
	"ellipsis"
], Vm = [
	"padding",
	"borderWidth",
	"borderRadius",
	"borderDashOffset",
	"backgroundColor",
	"borderColor",
	"shadowColor",
	"shadowBlur",
	"shadowOffsetX",
	"shadowOffsetY"
];
function Hm(e, t, n, r, i, a, o, s, c, l) {
	n = !o && n || Am;
	var u = a && a.inheritColor, d = t.getShallow("color"), f = t.getShallow("textBorderColor"), p = G(t.getShallow("opacity"), n.opacity);
	(d === "inherit" || d === "auto") && (d = u || null), (f === "inherit" || f === "auto") && (f = u || null), s || (d ||= n.color, f ||= n.textBorderColor), d != null && (e.fill = d), f != null && (e.stroke = f);
	var m = G(t.getShallow("textBorderWidth"), n.textBorderWidth);
	m != null && (e.lineWidth = m);
	var h = G(t.getShallow("textBorderType"), n.textBorderType);
	h != null && (e.lineDash = h);
	var g = G(t.getShallow("textBorderDashOffset"), n.textBorderDashOffset);
	g != null && (e.lineDashOffset = g), !o && p == null && !l && (p = a && a.defaultOpacity), p != null && (e.opacity = p), !o && !s && e.fill == null && a.inheritColor && (e.fill = a.inheritColor);
	for (var _ = 0; _ < zm.length; _++) {
		var v = zm[_], y = i !== !1 && r ? ye(t.getShallow(v), r.getShallow(v), n[v]) : G(t.getShallow(v), n[v]);
		y != null && (e[v] = y);
	}
	for (var _ = 0; _ < Bm.length; _++) {
		var v = Bm[_], y = t.getShallow(v);
		y != null && (e[v] = y);
	}
	if (e.verticalAlign == null) {
		var b = t.getShallow("baseline");
		b != null && (e.verticalAlign = b);
	}
	if (!c || !a.disableBox) {
		for (var _ = 0; _ < Vm.length; _++) {
			var v = Vm[_], y = t.getShallow(v);
			y != null && (e[v] = y);
		}
		var x = t.getShallow("borderType");
		x != null && (e.borderDash = x), (e.backgroundColor === "auto" || e.backgroundColor === "inherit") && u && (e.backgroundColor = u), (e.borderColor === "auto" || e.borderColor === "inherit") && u && (e.borderColor = u);
	}
}
function Um(e, t) {
	var n = t && t.getModel("textStyle");
	return Ce([
		e.fontStyle || n && n.getShallow("fontStyle") || "",
		e.fontWeight || n && n.getShallow("fontWeight") || "",
		(e.fontSize || n && n.getShallow("fontSize") || 12) + "px",
		e.fontFamily || n && n.getShallow("fontFamily") || "sans-serif"
	].join(" "));
}
var Wm = X();
function Gm(e, t, n, r) {
	if (e) {
		var i = Wm(e);
		i.prevValue = i.value, i.value = n;
		var a = t.normal;
		i.valueAnimation = a.get("valueAnimation"), i.valueAnimation && (i.precision = a.get("precision"), i.defaultInterpolatedText = r, i.statesModels = t);
	}
}
function Km(e, t, n, r, i) {
	var a = Wm(e);
	if (!a.valueAnimation || a.prevValue === a.value) return;
	var o = a.defaultInterpolatedText, s = G(a.interpolatedValue, a.prevValue), c = a.value;
	function l(r) {
		var l = Rs(n, a.precision, s, c, r);
		a.interpolatedValue = r === 1 ? null : l, jm(e, Mm({
			labelDataIndex: t,
			labelFetcher: i,
			defaultText: o ? o(l) : l + ""
		}, a.statesModels, l));
	}
	e.percent = 0, (a.prevValue == null ? Ap : kp)(e, { percent: 1 }, r, t, null, l);
}
var qm = {
	minMargin: 1,
	textMargin: 2
}, Jm = ["textStyle", "color"], Ym = [
	"fontStyle",
	"fontWeight",
	"fontSize",
	"fontFamily",
	"padding",
	"lineHeight",
	"rich",
	"width",
	"height",
	"overflow"
], Xm = new Tu(), Zm = function() {
	function e() {}
	return e.prototype.getTextColor = function(e) {
		var t = this.ecModel;
		return this.getShallow("color") || (!e && t ? t.get(Jm) : null);
	}, e.prototype.getFont = function() {
		return Um({
			fontStyle: this.getShallow("fontStyle"),
			fontWeight: this.getShallow("fontWeight"),
			fontSize: this.getShallow("fontSize"),
			fontFamily: this.getShallow("fontFamily")
		}, this.ecModel);
	}, e.prototype.getTextRect = function(e) {
		for (var t = {
			text: e,
			verticalAlign: this.getShallow("verticalAlign") || this.getShallow("baseline")
		}, n = 0; n < Ym.length; n++) t[Ym[n]] = this.getShallow(Ym[n]);
		return Xm.useStyle(t), Xm.update(), Xm.getBoundingRect();
	}, e;
}(), Qm = [
	["lineWidth", "width"],
	["stroke", "color"],
	["opacity"],
	["shadowBlur"],
	["shadowOffsetX"],
	["shadowOffsetY"],
	["shadowColor"],
	["lineDash", "type"],
	["lineDashOffset", "dashOffset"],
	["lineCap", "cap"],
	["lineJoin", "join"],
	["miterLimit"]
], $m = _c(Qm), eh = function() {
	function e() {}
	return e.prototype.getLineStyle = function(e) {
		return $m(this, e);
	}, e;
}(), th = [
	["fill", "color"],
	["stroke", "borderColor"],
	["lineWidth", "borderWidth"],
	["opacity"],
	["shadowBlur"],
	["shadowOffsetX"],
	["shadowOffsetY"],
	["shadowColor"],
	["lineDash", "borderType"],
	["lineDashOffset", "borderDashOffset"],
	["lineCap", "borderCap"],
	["lineJoin", "borderJoin"],
	["miterLimit", "borderMiterLimit"]
], nh = _c(th), rh = function() {
	function e() {}
	return e.prototype.getItemStyle = function(e, t) {
		return nh(this, e, t);
	}, e;
}(), ih = function() {
	function e(e, t, n) {
		this.parentModel = t, this.ecModel = n, this.option = e;
	}
	return e.prototype.init = function(e, t, n) {}, e.prototype.mergeOption = function(e, t) {
		j(this.option, e, !0);
	}, e.prototype.get = function(e, t) {
		return e == null ? this.option : this._doGet(this.parsePath(e), !t && this.parentModel);
	}, e.prototype.getShallow = function(e, t) {
		var n = this.option, r = n == null ? n : n[e];
		if (r == null && !t) {
			var i = this.parentModel;
			i && (r = i.getShallow(e));
		}
		return r;
	}, e.prototype.getModel = function(t, n) {
		var r = t != null, i = r ? this.parsePath(t) : null, a = r ? this._doGet(i) : this.option;
		return n ||= this.parentModel && this.parentModel.getModel(this.resolveParentPath(i)), new e(a, n, this.ecModel);
	}, e.prototype.isEmpty = function() {
		return this.option == null;
	}, e.prototype.restoreData = function() {}, e.prototype.clone = function() {
		var e = this.constructor;
		return new e(A(this.option));
	}, e.prototype.parsePath = function(e) {
		return typeof e == "string" ? e.split(".") : e;
	}, e.prototype.resolveParentPath = function(e) {
		return e;
	}, e.prototype.isAnimationEnabled = function() {
		if (!i.node && this.option) {
			if (this.option.animation != null) return !!this.option.animation;
			if (this.parentModel) return this.parentModel.isAnimationEnabled();
		}
	}, e.prototype._doGet = function(e, t) {
		var n = this.option;
		if (!e) return n;
		for (var r = 0; r < e.length && !(e[r] && (n = n && typeof n == "object" ? n[e[r]] : null, n == null)); r++);
		return n == null && t && (n = t._doGet(this.resolveParentPath(e), t.parentModel)), n;
	}, e;
}();
lc(ih), pc(ih), F(ih, eh), F(ih, rh), F(ih, yc), F(ih, Zm);
//#endregion
//#region node_modules/echarts/lib/util/component.js
var ah = Math.round(Math.random() * 10);
function oh(e) {
	return [e || "", ah++].join("_");
}
function sh(e) {
	var t = {};
	e.registerSubTypeDefaulter = function(e, n) {
		var r = oc(e);
		t[r.main] = n;
	}, e.determineSubType = function(n, r) {
		var i = r.type;
		if (!i) {
			var a = oc(n).main;
			e.hasSubTypes(n) && t[a] && (i = t[a](r));
		}
		return i;
	};
}
function ch(e, t) {
	e.topologicalTravel = function(e, t, r, i) {
		if (!e.length) return;
		var a = n(t), o = a.graph, s = a.noEntryList, c = {};
		for (I(e, function(e) {
			c[e] = !0;
		}); s.length;) {
			var l = s.pop(), u = o[l], d = !!c[l];
			d && (r.call(i, l, u.originalDeps.slice()), delete c[l]), I(u.successor, d ? p : f);
		}
		I(c, function() {
			throw Error("");
		});
		function f(e) {
			o[e].entryCount--, o[e].entryCount === 0 && s.push(e);
		}
		function p(e) {
			c[e] = !0, f(e);
		}
	};
	function n(e) {
		var n = {}, a = [];
		return I(e, function(o) {
			var s = r(n, o), c = i(s.originalDeps = t(o), e);
			s.entryCount = c.length, s.entryCount === 0 && a.push(o), I(c, function(e) {
				P(s.predecessor, e) < 0 && s.predecessor.push(e);
				var t = r(n, e);
				P(t.successor, e) < 0 && t.successor.push(o);
			});
		}), {
			graph: n,
			noEntryList: a
		};
	}
	function r(e, t) {
		return e[t] || (e[t] = {
			predecessor: [],
			successor: []
		}), e[t];
	}
	function i(e, t) {
		var n = [];
		return I(e, function(e) {
			P(t, e) >= 0 && n.push(e);
		}), n;
	}
}
function lh(e, t) {
	return j(j({}, e, !0), t, !0);
}
//#endregion
//#region node_modules/echarts/lib/i18n/langEN.js
var uh = {
	time: {
		month: [
			"January",
			"February",
			"March",
			"April",
			"May",
			"June",
			"July",
			"August",
			"September",
			"October",
			"November",
			"December"
		],
		monthAbbr: [
			"Jan",
			"Feb",
			"Mar",
			"Apr",
			"May",
			"Jun",
			"Jul",
			"Aug",
			"Sep",
			"Oct",
			"Nov",
			"Dec"
		],
		dayOfWeek: [
			"Sunday",
			"Monday",
			"Tuesday",
			"Wednesday",
			"Thursday",
			"Friday",
			"Saturday"
		],
		dayOfWeekAbbr: [
			"Sun",
			"Mon",
			"Tue",
			"Wed",
			"Thu",
			"Fri",
			"Sat"
		]
	},
	legend: { selector: {
		all: "All",
		inverse: "Inv"
	} },
	toolbox: {
		brush: { title: {
			rect: "Box Select",
			polygon: "Lasso Select",
			lineX: "Horizontally Select",
			lineY: "Vertically Select",
			keep: "Keep Selections",
			clear: "Clear Selections"
		} },
		dataView: {
			title: "Data View",
			lang: [
				"Data View",
				"Close",
				"Refresh"
			]
		},
		dataZoom: { title: {
			zoom: "Zoom",
			back: "Zoom Reset"
		} },
		magicType: { title: {
			line: "Switch to Line Chart",
			bar: "Switch to Bar Chart",
			stack: "Stack",
			tiled: "Tile"
		} },
		restore: { title: "Restore" },
		saveAsImage: {
			title: "Save as Image",
			lang: ["Right Click to Save Image"]
		}
	},
	series: { typeNames: {
		pie: "Pie chart",
		bar: "Bar chart",
		line: "Line chart",
		scatter: "Scatter plot",
		effectScatter: "Ripple scatter plot",
		radar: "Radar chart",
		tree: "Tree",
		treemap: "Treemap",
		boxplot: "Boxplot",
		candlestick: "Candlestick",
		k: "K line chart",
		heatmap: "Heat map",
		map: "Map",
		parallel: "Parallel coordinate map",
		lines: "Line graph",
		graph: "Relationship graph",
		sankey: "Sankey diagram",
		funnel: "Funnel chart",
		gauge: "Gauge",
		pictorialBar: "Pictorial bar",
		themeRiver: "Theme River Map",
		sunburst: "Sunburst",
		custom: "Custom chart",
		chart: "Chart"
	} },
	aria: {
		general: {
			withTitle: "This is a chart about \"{title}\"",
			withoutTitle: "This is a chart"
		},
		series: {
			single: {
				prefix: "",
				withName: " with type {seriesType} named {seriesName}.",
				withoutName: " with type {seriesType}."
			},
			multiple: {
				prefix: ". It consists of {seriesCount} series count.",
				withName: " The {seriesId} series is a {seriesType} representing {seriesName}.",
				withoutName: " The {seriesId} series is a {seriesType}.",
				separator: {
					middle: "",
					end: ""
				}
			}
		},
		data: {
			allData: "The data is as follows: ",
			partialData: "The first {displayCnt} items are: ",
			withName: "the data for {name} is {value}",
			withoutName: "{value}",
			separator: {
				middle: ", ",
				end: ". "
			}
		}
	}
}, dh = {
	time: {
		month: [
			"一月",
			"二月",
			"三月",
			"四月",
			"五月",
			"六月",
			"七月",
			"八月",
			"九月",
			"十月",
			"十一月",
			"十二月"
		],
		monthAbbr: [
			"1月",
			"2月",
			"3月",
			"4月",
			"5月",
			"6月",
			"7月",
			"8月",
			"9月",
			"10月",
			"11月",
			"12月"
		],
		dayOfWeek: [
			"星期日",
			"星期一",
			"星期二",
			"星期三",
			"星期四",
			"星期五",
			"星期六"
		],
		dayOfWeekAbbr: [
			"日",
			"一",
			"二",
			"三",
			"四",
			"五",
			"六"
		]
	},
	legend: { selector: {
		all: "全选",
		inverse: "反选"
	} },
	toolbox: {
		brush: { title: {
			rect: "矩形选择",
			polygon: "圈选",
			lineX: "横向选择",
			lineY: "纵向选择",
			keep: "保持选择",
			clear: "清除选择"
		} },
		dataView: {
			title: "数据视图",
			lang: [
				"数据视图",
				"关闭",
				"刷新"
			]
		},
		dataZoom: { title: {
			zoom: "区域缩放",
			back: "区域缩放还原"
		} },
		magicType: { title: {
			line: "切换为折线图",
			bar: "切换为柱状图",
			stack: "切换为堆叠",
			tiled: "切换为平铺"
		} },
		restore: { title: "还原" },
		saveAsImage: {
			title: "保存为图片",
			lang: ["右键另存为图片"]
		}
	},
	series: { typeNames: {
		pie: "饼图",
		bar: "柱状图",
		line: "折线图",
		scatter: "散点图",
		effectScatter: "涟漪散点图",
		radar: "雷达图",
		tree: "树图",
		treemap: "矩形树图",
		boxplot: "箱型图",
		candlestick: "K线图",
		k: "K线图",
		heatmap: "热力图",
		map: "地图",
		parallel: "平行坐标图",
		lines: "线图",
		graph: "关系图",
		sankey: "桑基图",
		funnel: "漏斗图",
		gauge: "仪表盘图",
		pictorialBar: "象形柱图",
		themeRiver: "主题河流图",
		sunburst: "旭日图",
		custom: "自定义图表",
		chart: "图表"
	} },
	aria: {
		general: {
			withTitle: "这是一个关于“{title}”的图表。",
			withoutTitle: "这是一个图表，"
		},
		series: {
			single: {
				prefix: "",
				withName: "图表类型是{seriesType}，表示{seriesName}。",
				withoutName: "图表类型是{seriesType}。"
			},
			multiple: {
				prefix: "它由{seriesCount}个图表系列组成。",
				withName: "第{seriesId}个系列是一个表示{seriesName}的{seriesType}，",
				withoutName: "第{seriesId}个系列是一个{seriesType}，",
				separator: {
					middle: "；",
					end: "。"
				}
			}
		},
		data: {
			allData: "其数据是——",
			partialData: "其中，前{displayCnt}项是——",
			withName: "{name}的数据是{value}",
			withoutName: "{value}",
			separator: {
				middle: "，",
				end: ""
			}
		}
	}
}, fh = "ZH", ph = "EN", mh = ph, hh = {}, gh = {}, _h = i.domSupported ? function() {
	return (document.documentElement.lang || navigator.language || navigator.browserLanguage || mh).toUpperCase().indexOf(fh) > -1 ? fh : mh;
}() : mh;
function vh(e, t) {
	e = e.toUpperCase(), gh[e] = new ih(t), hh[e] = t;
}
function yh(e) {
	if (U(e)) {
		var t = hh[e.toUpperCase()] || {};
		return e === fh || e === ph ? A(t) : j(A(t), A(hh[mh]), !1);
	}
	return j(A(e), A(hh[mh]), !1);
}
function bh(e) {
	return gh[e];
}
function xh() {
	return gh[mh];
}
vh(ph, uh), vh(fh, dh);
//#endregion
//#region node_modules/echarts/lib/scale/break.js
var Sh = null;
function Ch() {
	return Sh;
}
function wh(e, t) {
	var n = Ch(), r = t.breakOption, i = t.breakParsed;
	return !i && n && (i = n.parseAxisBreakOption(r, e)), i;
}
function Th(e) {
	var t = e.brk;
	return t ? t.breaks : [];
}
function Eh(e) {
	var t = e.brk;
	return t ? t.hasBreaks() : !1;
}
//#endregion
//#region node_modules/echarts/lib/util/time.js
var Dh = 1e3, Oh = Dh * 60, kh = Oh * 60, Ah = kh * 24, jh = Ah * 365, Mh = {
	year: /({yyyy}|{yy})/,
	month: /({MMMM}|{MMM}|{MM}|{M})/,
	day: /({dd}|{d})/,
	hour: /({HH}|{H}|{hh}|{h})/,
	minute: /({mm}|{m})/,
	second: /({ss}|{s})/,
	millisecond: /({SSS}|{S})/
}, Nh = {
	year: "{yyyy}",
	month: "{MMM}",
	day: "{d}",
	hour: "{HH}:{mm}",
	minute: "{HH}:{mm}",
	second: "{HH}:{mm}:{ss}",
	millisecond: "{HH}:{mm}:{ss} {SSS}"
}, Ph = "{yyyy}-{MM}-{dd} {HH}:{mm}:{ss} {SSS}", Fh = "{yyyy}-{MM}-{dd}", Ih = {
	year: "{yyyy}",
	month: "{yyyy}-{MM}",
	day: Fh,
	hour: Fh + " " + Nh.hour,
	minute: Fh + " " + Nh.minute,
	second: Fh + " " + Nh.second,
	millisecond: Ph
}, Lh = [
	"year",
	"month",
	"day",
	"hour",
	"minute",
	"second",
	"millisecond"
], Rh = [
	"year",
	"half-year",
	"quarter",
	"month",
	"week",
	"half-week",
	"day",
	"half-day",
	"quarter-day",
	"hour",
	"minute",
	"second",
	"millisecond"
];
function zh(e) {
	return !U(e) && !H(e) ? Bh(e) : e;
}
function Bh(e) {
	e ||= {};
	var t = {}, n = !0;
	return I(Lh, function(t) {
		n &&= e[t] == null;
	}), I(Lh, function(r, i) {
		var a = e[r];
		t[r] = {};
		for (var o = null, s = i; s >= 0; s--) {
			var c = Lh[s], l = W(a) && !V(a) ? a[c] : a, u = void 0;
			V(l) ? (u = l.slice(), o = u[0] || "") : U(l) ? (o = l, u = [o]) : (o == null ? o = Nh[r] : Mh[c].test(o) || (o = t[c][c][0] + " " + o), u = [o], n && (u[1] = "{primary|" + o + "}")), t[r][c] = u;
		}
	}), t;
}
function Vh(e, t) {
	return e += "", "0000".substr(0, t - e.length) + e;
}
function Hh(e) {
	switch (e) {
		case "half-year":
		case "quarter": return "month";
		case "week":
		case "half-week": return "day";
		case "half-day":
		case "quarter-day": return "hour";
		default: return e;
	}
}
function Uh(e) {
	return e === Hh(e);
}
function Wh(e) {
	switch (e) {
		case "year":
		case "month": return "day";
		case "millisecond": return "millisecond";
		default: return "second";
	}
}
function Gh(e, t, n, r) {
	var i = Bo(e), a = i[Yh(n)](), o = i[Xh(n)]() + 1, s = Math.floor((o - 1) / 3) + 1, c = i[Zh(n)](), l = i["get" + (n ? "UTC" : "") + "Day"](), u = i[Qh(n)](), d = (u - 1) % 12 + 1, f = i[$h(n)](), p = i[eg(n)](), m = i[tg(n)](), h = u >= 12 ? "pm" : "am", g = h.toUpperCase(), _ = (r instanceof ih ? r : bh(r || _h) || xh()).getModel("time"), v = _.get("month"), y = _.get("monthAbbr"), b = _.get("dayOfWeek"), x = _.get("dayOfWeekAbbr");
	return (t || "").replace(/{a}/g, h + "").replace(/{A}/g, g + "").replace(/{yyyy}/g, a + "").replace(/{yy}/g, Vh(a % 100 + "", 2)).replace(/{Q}/g, s + "").replace(/{MMMM}/g, v[o - 1]).replace(/{MMM}/g, y[o - 1]).replace(/{MM}/g, Vh(o, 2)).replace(/{M}/g, o + "").replace(/{dd}/g, Vh(c, 2)).replace(/{d}/g, c + "").replace(/{eeee}/g, b[l]).replace(/{ee}/g, x[l]).replace(/{e}/g, l + "").replace(/{HH}/g, Vh(u, 2)).replace(/{H}/g, u + "").replace(/{hh}/g, Vh(d + "", 2)).replace(/{h}/g, d + "").replace(/{mm}/g, Vh(f, 2)).replace(/{m}/g, f + "").replace(/{ss}/g, Vh(p, 2)).replace(/{s}/g, p + "").replace(/{SSS}/g, Vh(m, 3)).replace(/{S}/g, m + "");
}
function Kh(e, t, n, r, i) {
	var a = null;
	if (U(n)) a = n;
	else if (H(n)) {
		var o = {
			time: e.time,
			level: e.time ? e.time.level : 0
		}, s = Ch();
		s && s.makeAxisLabelFormatterParamBreak(o, e.break), a = n(e.value, t, o);
	} else {
		var c = e.time;
		if (c) {
			var l = n[c.lowerTimeUnit][c.upperTimeUnit];
			a = l[Math.min(c.level, l.length - 1)] || "";
		} else {
			var u = qh(e.value, i);
			a = n[u][u][0];
		}
	}
	return Gh(new Date(e.value), a, i, r);
}
function qh(e, t) {
	var n = Bo(e), r = n[Xh(t)]() + 1, i = n[Zh(t)](), a = n[Qh(t)](), o = n[$h(t)](), s = n[eg(t)](), c = n[tg(t)]() === 0, l = c && s === 0, u = l && o === 0, d = u && a === 0, f = d && i === 1;
	return f && r === 1 ? "year" : f ? "month" : d ? "day" : u ? "hour" : l ? "minute" : c ? "second" : "millisecond";
}
function Jh(e, t, n) {
	switch (t) {
		case "year": e[rg(n)](0);
		case "month": e[ig(n)](1);
		case "day": e[ag(n)](0);
		case "hour": e[og(n)](0);
		case "minute": e[sg(n)](0);
		case "second": e[cg(n)](0);
	}
	return e;
}
function Yh(e) {
	return e ? "getUTCFullYear" : "getFullYear";
}
function Xh(e) {
	return e ? "getUTCMonth" : "getMonth";
}
function Zh(e) {
	return e ? "getUTCDate" : "getDate";
}
function Qh(e) {
	return e ? "getUTCHours" : "getHours";
}
function $h(e) {
	return e ? "getUTCMinutes" : "getMinutes";
}
function eg(e) {
	return e ? "getUTCSeconds" : "getSeconds";
}
function tg(e) {
	return e ? "getUTCMilliseconds" : "getMilliseconds";
}
function ng(e) {
	return e ? "setUTCFullYear" : "setFullYear";
}
function rg(e) {
	return e ? "setUTCMonth" : "setMonth";
}
function ig(e) {
	return e ? "setUTCDate" : "setDate";
}
function ag(e) {
	return e ? "setUTCHours" : "setHours";
}
function og(e) {
	return e ? "setUTCMinutes" : "setMinutes";
}
function sg(e) {
	return e ? "setUTCSeconds" : "setSeconds";
}
function cg(e) {
	return e ? "setUTCMilliseconds" : "setMilliseconds";
}
//#endregion
//#region node_modules/echarts/lib/legacy/getTextRect.js
function lg(e, t, n, r, i, a, o, s) {
	return new Tu({ style: {
		text: e,
		font: t,
		align: n,
		verticalAlign: r,
		padding: i,
		rich: a,
		overflow: o ? "truncate" : null,
		lineHeight: s
	} }).getBoundingRect();
}
//#endregion
//#region node_modules/echarts/lib/util/format.js
function ug(e) {
	if (!qo(e)) return U(e) ? e : "-";
	var t = (e + "").split(".");
	return t[0].replace(/(\d{1,3})(?=(?:\d{3})+(?!\d))/g, "$1,") + (t.length > 1 ? "." + t[1] : "");
}
function dg(e, t) {
	return e = (e || "").toLowerCase().replace(/-(.)/g, function(e, t) {
		return t.toUpperCase();
	}), t && e && (e = e.charAt(0).toUpperCase() + e.slice(1)), e;
}
var fg = xe;
function pg(e, t, n) {
	var r = "{yyyy}-{MM}-{dd} {HH}:{mm}:{ss}";
	function i(e) {
		return e && Ce(e) ? e : "-";
	}
	function a(e) {
		return Zo(e);
	}
	var o = t === "time", s = e instanceof Date;
	if (o || s) {
		var c = o ? Bo(e) : e;
		if (!isNaN(+c)) return Gh(c, r, n);
		if (s) return "-";
	}
	if (t === "ordinal") return le(e) ? i(e) : ue(e) && a(e) ? e + "" : "-";
	var l = Ko(e);
	return a(l) ? ug(l) : le(e) ? i(e) : typeof e == "boolean" ? e + "" : "-";
}
var mg = [
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g"
], hg = function(e, t) {
	return "{" + e + (t ?? "") + "}";
};
function gg(e, t, n) {
	V(t) || (t = [t]);
	var r = t.length;
	if (!r) return "";
	for (var i = t[0].$vars || [], a = 0; a < i.length; a++) {
		var o = mg[a];
		e = e.replace(hg(o), hg(o, 0));
	}
	for (var s = 0; s < r; s++) for (var c = 0; c < i.length; c++) {
		var l = t[s][i[c]];
		e = e.replace(hg(mg[c], s), n ? Tt(l) : l);
	}
	return e;
}
function _g(e, t) {
	var n = U(e) ? {
		color: e,
		extraCssText: t
	} : e || {}, r = n.color, i = n.type;
	t = n.extraCssText;
	var a = n.renderMode || "html";
	return r ? a === "html" ? i === "subItem" ? "<span style=\"display:inline-block;vertical-align:middle;margin-right:8px;margin-left:3px;border-radius:4px;width:4px;height:4px;background-color:" + Tt(r) + ";" + (t || "") + "\"></span>" : "<span style=\"display:inline-block;margin-right:4px;border-radius:10px;width:10px;height:10px;background-color:" + Tt(r) + ";" + (t || "") + "\"></span>" : {
		renderMode: a,
		content: "{" + (n.markerId || "markerX") + "|}  ",
		style: i === "subItem" ? {
			width: 4,
			height: 4,
			borderRadius: 2,
			backgroundColor: r
		} : {
			width: 10,
			height: 10,
			borderRadius: 5,
			backgroundColor: r
		}
	} : "";
}
function vg(e, t, n) {
	(e === "week" || e === "month" || e === "quarter" || e === "half-year" || e === "year") && (e = "MM-dd\nyyyy");
	var r = Bo(t), i = n ? "getUTC" : "get", a = r[i + "FullYear"](), o = r[i + "Month"]() + 1, s = r[i + "Date"](), c = r[i + "Hours"](), l = r[i + "Minutes"](), u = r[i + "Seconds"](), d = r[i + "Milliseconds"]();
	return e = e.replace("MM", Vh(o, 2)).replace("M", o).replace("yyyy", a).replace("yy", Vh(a % 100 + "", 2)).replace("dd", Vh(s, 2)).replace("d", s).replace("hh", Vh(c, 2)).replace("h", c).replace("mm", Vh(l, 2)).replace("m", l).replace("ss", Vh(u, 2)).replace("s", u).replace("SSS", Vh(d, 3)), e;
}
function yg(e) {
	return e && e.charAt(0).toUpperCase() + e.substr(1);
}
function bg(e, t) {
	return t ||= "transparent", U(e) ? e : W(e) && e.colorStops && (e.colorStops[0] || {}).color || t;
}
function xg(e, t) {
	if (t === "_blank" || t === "blank") {
		var n = window.open();
		n.opener = null, n.location.href = e;
	} else window.open(e, t);
}
//#endregion
//#region node_modules/echarts/lib/core/CoordinateSystem.js
var Sg = {}, Cg = {}, wg = function() {
	function e() {
		this._normalMasterList = [], this._nonSeriesBoxMasterList = [];
	}
	return e.prototype.create = function(e, t) {
		this._nonSeriesBoxMasterList = n(Sg, !0), this._normalMasterList = n(Cg, !1);
		function n(n, r) {
			var i = [];
			return I(n, function(n, r) {
				var a = n.create(e, t);
				i = i.concat(a || []);
			}), i;
		}
	}, e.prototype.update = function(e, t) {
		I(this._normalMasterList, function(n) {
			n.update && n.update(e, t);
		});
	}, e.prototype.getCoordinateSystems = function() {
		return this._normalMasterList.concat(this._nonSeriesBoxMasterList);
	}, e.register = function(e, t) {
		e === "matrix" || e === "calendar" ? Sg[e] = t : Cg[e] = t;
	}, e.get = function(e) {
		return Cg[e] || Sg[e];
	}, e;
}();
function Tg(e) {
	return !!Sg[e];
}
function Eg(e) {
	Dg.set(e.fullType, { getCoord2: void 0 }).getCoord2 = e.getCoord2;
}
var Dg = K();
function Og(e) {
	var t = e.getShallow("coord", !0), n = 1;
	if (t == null) {
		var r = Dg.get(e.type);
		r && r.getCoord2 && (n = 2, t = r.getCoord2(e));
	}
	return {
		coord: t,
		from: n
	};
}
function kg(e, t) {
	var n = e.getShallow("coordinateSystem"), r = e.getShallow("coordinateSystemUsage", !0), i = 0;
	if (n) {
		var a = e.mainType === "series";
		r ??= a ? "data" : "box", r === "data" ? (i = 1, a || (i = 0)) : r === "box" && (i = 2, !a && !Tg(n) && (i = 0));
	}
	return {
		coordSysType: n,
		kind: i
	};
}
function Ag(e) {
	var t = e.targetModel, n = e.coordSysType, r = e.coordSysProvider, i = e.isDefaultDataCoordSys;
	e.allowNotFound;
	var a = kg(t, !0), o = a.kind, s = a.coordSysType;
	if (i && o !== 1 && (o = 1, s = n), o === 0 || s !== n) return 0;
	var c = r(n, t);
	return c ? (o === 1 ? t.coordinateSystem = c : t.boxCoordinateSystem = c, o) : 0;
}
//#endregion
//#region node_modules/echarts/lib/util/layout.js
var jg = I, Mg = [
	"left",
	"right",
	"top",
	"bottom",
	"width",
	"height"
], Ng = [[
	"width",
	"left",
	"right"
], [
	"height",
	"top",
	"bottom"
]];
function Pg(e, t, n, r, i) {
	var a = 0, o = 0;
	r ??= Infinity, i ??= Infinity;
	var s = 0;
	t.eachChild(function(c, l) {
		var u = c.getBoundingRect(), d = t.childAt(l + 1), f = d && d.getBoundingRect(), p, m;
		if (e === "horizontal") {
			var h = u.width + (f ? -f.x + u.x : 0);
			p = a + h, p > r || c.newline ? (a = 0, p = h, o += s + n, s = u.height) : s = Math.max(s, u.height);
		} else {
			var g = u.height + (f ? -f.y + u.y : 0);
			m = o + g, m > i || c.newline ? (a += s + n, o = 0, m = g, s = u.width) : s = Math.max(s, u.width);
		}
		c.newline || (c.x = a, c.y = o, c.markRedraw(), e === "horizontal" ? a = p + n : o = m + n);
	});
}
var Fg = Pg;
B(Pg, "vertical"), B(Pg, "horizontal");
function Ig(e, t) {
	return {
		left: e.getShallow("left", t),
		top: e.getShallow("top", t),
		right: e.getShallow("right", t),
		bottom: e.getShallow("bottom", t),
		width: e.getShallow("width", t),
		height: e.getShallow("height", t)
	};
}
function Lg(e, t) {
	var n = Vg(e, t, { enableLayoutOnlyByCenter: !0 }), r = e.getBoxLayoutParams(), i, a;
	if (n.type === Bg.point) a = n.refPoint, i = zg(r, {
		width: t.getWidth(),
		height: t.getHeight()
	});
	else {
		var o = e.get("center"), s = V(o) ? o : [o, o];
		i = zg(r, n.refContainer), a = n.boxCoordFrom === 2 ? n.refPoint : [So(s[0], i.width) + i.x, So(s[1], i.height) + i.y];
	}
	return {
		viewRect: i,
		center: a
	};
}
function Rg(e, t) {
	var n = Lg(e, t), r = n.viewRect, i = n.center, a = e.get("radius");
	V(a) || (a = [0, a]);
	var o = So(r.width, t.getWidth()), s = So(r.height, t.getHeight()), c = Math.min(o, s), l = So(a[0], c / 2), u = So(a[1], c / 2);
	return {
		cx: i[0],
		cy: i[1],
		r0: l,
		r: u,
		viewRect: r
	};
}
function zg(e, t, n) {
	n = fg(n || 0);
	var r = t.width, i = t.height, a = So(e.left, r), o = So(e.top, i), s = So(e.right, r), c = So(e.bottom, i), l = So(e.width, r), u = So(e.height, i), d = n[2] + n[0], f = n[1] + n[3], p = e.aspect;
	switch (isNaN(l) && (l = r - s - f - a), isNaN(u) && (u = i - c - d - o), p != null && (isNaN(l) && isNaN(u) && (p > r / i ? l = r * .8 : u = i * .8), isNaN(l) && (l = p * u), isNaN(u) && (u = l / p)), isNaN(a) && (a = r - s - l - f), isNaN(o) && (o = i - c - u - d), e.left || e.right) {
		case "center":
			a = r / 2 - l / 2 - n[3];
			break;
		case "right": a = r - l - f;
	}
	switch (e.top || e.bottom) {
		case "middle":
		case "center":
			o = i / 2 - u / 2 - n[0];
			break;
		case "bottom": o = i - u - d;
	}
	a ||= 0, o ||= 0, isNaN(l) && (l = r - f - a - (s || 0)), isNaN(u) && (u = i - d - o - (c || 0));
	var m = new Y((t.x || 0) + a + n[3], (t.y || 0) + o + n[0], l, u);
	return m.margin = n, m;
}
var Bg = {
	rect: 1,
	point: 2
};
function Vg(e, t, n) {
	var r, i, a, o = e.boxCoordinateSystem, s;
	if (o) {
		var c = Og(e), l = c.coord, u = c.from;
		if (o.dataToLayout) {
			a = Bg.rect, s = u;
			var d = o.dataToLayout(l);
			r = d.contentRect || d.rect;
		} else n && n.enableLayoutOnlyByCenter && o.dataToPoint && (a = Bg.point, s = u, i = o.dataToPoint(l));
	}
	return a ??= Bg.rect, a === Bg.rect && (r ||= {
		x: 0,
		y: 0,
		width: t.getWidth(),
		height: t.getHeight()
	}, i = [r.x + r.width / 2, r.y + r.height / 2]), {
		type: a,
		refContainer: r,
		refPoint: i,
		boxCoordFrom: s
	};
}
function Hg(e, t, n, r, i, a) {
	var o = !i || !i.hv || i.hv[0], s = !i || !i.hv || i.hv[1], c = i && i.boundingMode || "all";
	if (a ||= e, a.x = e.x, a.y = e.y, !o && !s) return !1;
	var l;
	if (c === "raw") l = e.type === "group" ? new Y(0, 0, +t.width || 0, +t.height || 0) : e.getBoundingRect();
	else if (l = e.getBoundingRect(), e.needLocalTransform()) {
		var u = e.getLocalTransform();
		l = l.clone(), l.applyTransform(u);
	}
	var d = zg(N({
		width: l.width,
		height: l.height
	}, t), n, r), f = o ? d.x - l.x : 0, p = s ? d.y - l.y : 0;
	return c === "raw" ? (a.x = f, a.y = p) : (a.x += f, a.y += p), a === e && e.markRedraw(), !0;
}
function Ug(e) {
	var t = e.layoutMode || e.constructor.layoutMode;
	return W(t) ? t : t ? { type: t } : null;
}
function Wg(e, t, n) {
	var r = n && n.ignoreSize;
	!V(r) && (r = [r, r]);
	var i = o(Ng[0], 0), a = o(Ng[1], 1);
	c(Ng[0], e, i), c(Ng[1], e, a);
	function o(n, i) {
		var a = {}, o = 0, c = {}, l = 0, u = 2;
		if (jg(n, function(t) {
			c[t] = e[t];
		}), jg(n, function(e) {
			q(t, e) && (a[e] = c[e] = t[e]), s(a, e) && o++, s(c, e) && l++;
		}), r[i]) return s(t, n[1]) ? c[n[2]] = null : s(t, n[2]) && (c[n[1]] = null), c;
		if (l === u || !o) return c;
		if (o >= u) return a;
		for (var d = 0; d < n.length; d++) {
			var f = n[d];
			if (!q(a, f) && q(e, f)) {
				a[f] = e[f];
				break;
			}
		}
		return a;
	}
	function s(e, t) {
		return e[t] != null && e[t] !== "auto";
	}
	function c(e, t, n) {
		jg(e, function(e) {
			t[e] = n[e];
		});
	}
}
function Gg(e) {
	return Kg({}, e);
}
function Kg(e, t) {
	return t && e && jg(Mg, function(n) {
		q(t, n) && (e[n] = t[n]);
	}), e;
}
//#endregion
//#region node_modules/echarts/lib/model/Component.js
var qg = X(), Jg = function(e) {
	n(t, e);
	function t(t, n, r) {
		var i = e.call(this, t, n, r) || this;
		return i.uid = oh("ec_cpt_model"), i;
	}
	return t.prototype.init = function(e, t, n) {
		this.mergeDefaultAndTheme(e, n);
	}, t.prototype.mergeDefaultAndTheme = function(e, t) {
		var n = Ug(this), r = n ? Gg(e) : {};
		j(e, t.getTheme().get(this.mainType)), j(e, this.getDefaultOption()), n && Wg(e, r, n);
	}, t.prototype.mergeOption = function(e, t) {
		j(this.option, e, !0);
		var n = Ug(this);
		n && Wg(this.option, e, n);
	}, t.prototype.optionUpdated = function(e, t) {}, t.prototype.getDefaultOption = function() {
		var e = this.constructor;
		if (!cc(e)) return e.defaultOption;
		var t = qg(this);
		if (!t.defaultOption) {
			for (var n = [], r = e; r;) {
				var i = r.prototype.defaultOption;
				i && n.push(i), r = r.superClass;
			}
			for (var a = {}, o = n.length - 1; o >= 0; o--) a = j(a, n[o], !0);
			t.defaultOption = a;
		}
		return t.defaultOption;
	}, t.prototype.getReferringComponents = function(e, t) {
		var n = e + "Index", r = e + "Id";
		return Ns(this.ecModel, e, {
			index: this.get(n, !0),
			id: this.get(r, !0)
		}, t);
	}, t.prototype.getBoxLayoutParams = function() {
		return Ig(this, !1);
	}, t.prototype.getZLevelKey = function() {
		return "";
	}, t.prototype.setZLevel = function(e) {
		this.option.zlevel = e;
	}, t.protoInitialize = function() {
		var e = t.prototype;
		e.type = "component", e.id = "", e.name = "", e.mainType = "", e.subType = "", e.componentIndex = 0;
	}(), t;
}(ih);
dc(Jg, ih), gc(Jg), sh(Jg), ch(Jg, Yg);
function Yg(e) {
	var t = [];
	return I(Jg.getClassesByMainType(e), function(e) {
		t = t.concat(e.dependencies || e.prototype.dependencies || []);
	}), t = L(t, function(e) {
		return oc(e).main;
	}), e !== "dataset" && P(t, "dataset") <= 0 && t.unshift("dataset"), t;
}
//#endregion
//#region node_modules/echarts/lib/visual/tokens.js
var Q = {
	color: {},
	darkColor: {},
	size: {}
}, Xg = Q.color = {
	theme: [
		"#5070dd",
		"#b6d634",
		"#505372",
		"#ff994d",
		"#0ca8df",
		"#ffd10a",
		"#fb628b",
		"#785db0",
		"#3fbe95"
	],
	neutral00: "#fff",
	neutral05: "#f4f7fd",
	neutral10: "#e8ebf0",
	neutral15: "#dbdee4",
	neutral20: "#cfd2d7",
	neutral25: "#c3c5cb",
	neutral30: "#b7b9be",
	neutral35: "#aaacb2",
	neutral40: "#9ea0a5",
	neutral45: "#929399",
	neutral50: "#86878c",
	neutral55: "#797b7f",
	neutral60: "#6d6e73",
	neutral65: "#616266",
	neutral70: "#54555a",
	neutral75: "#48494d",
	neutral80: "#3c3c41",
	neutral85: "#303034",
	neutral90: "#232328",
	neutral95: "#17171b",
	neutral99: "#000",
	accent05: "#eff1f9",
	accent10: "#e0e4f2",
	accent15: "#d0d6ec",
	accent20: "#c0c9e6",
	accent25: "#b1bbdf",
	accent30: "#a1aed9",
	accent35: "#91a0d3",
	accent40: "#8292cc",
	accent45: "#7285c6",
	accent50: "#6578ba",
	accent55: "#5c6da9",
	accent60: "#536298",
	accent65: "#4a5787",
	accent70: "#404c76",
	accent75: "#374165",
	accent80: "#2e3654",
	accent85: "#252b43",
	accent90: "#1b2032",
	accent95: "#121521",
	transparent: "rgba(0,0,0,0)",
	highlight: "rgba(255,231,130,0.8)"
};
for (var Zg in M(Xg, {
	primary: Xg.neutral80,
	secondary: Xg.neutral70,
	tertiary: Xg.neutral60,
	quaternary: Xg.neutral50,
	disabled: Xg.neutral20,
	border: Xg.neutral30,
	borderTint: Xg.neutral20,
	borderShade: Xg.neutral40,
	background: Xg.neutral05,
	backgroundTint: "rgba(234,237,245,0.5)",
	backgroundTransparent: "rgba(255,255,255,0)",
	backgroundShade: Xg.neutral10,
	shadow: "rgba(0,0,0,0.2)",
	shadowTint: "rgba(129,130,136,0.2)",
	axisLine: Xg.neutral70,
	axisLineTint: Xg.neutral40,
	axisTick: Xg.neutral70,
	axisTickMinor: Xg.neutral60,
	axisLabel: Xg.neutral70,
	axisSplitLine: Xg.neutral15,
	axisMinorSplitLine: Xg.neutral05
}), Xg) if (Xg.hasOwnProperty(Zg)) {
	var Qg = Xg[Zg];
	Zg === "theme" ? Q.darkColor.theme = Xg.theme.slice() : Zg === "highlight" ? Q.darkColor.highlight = "rgba(255,231,130,0.4)" : Zg.indexOf("accent") === 0 ? Q.darkColor[Zg] = Xr(Qg, null, function(e) {
		return e * .5;
	}, function(e) {
		return Math.min(1, 1.3 - e);
	}) : Q.darkColor[Zg] = Xr(Qg, null, function(e) {
		return e * .9;
	}, function(e) {
		return 1 - e ** 1.5;
	});
}
Q.size = {
	xxs: 2,
	xs: 5,
	s: 10,
	m: 15,
	l: 20,
	xl: 30,
	xxl: 40,
	xxxl: 50
};
//#endregion
//#region node_modules/echarts/lib/model/globalDefault.js
var $g = "";
typeof navigator < "u" && ($g = navigator.platform || "");
var e_ = "rgba(0, 0, 0, 0.2)", t_ = Q.color.theme[0], n_ = Xr(t_, null, null, .9), r_ = {
	darkMode: "auto",
	colorBy: "series",
	color: Q.color.theme,
	gradientColor: [n_, t_],
	aria: { decal: { decals: [
		{
			color: e_,
			dashArrayX: [1, 0],
			dashArrayY: [2, 5],
			symbolSize: 1,
			rotation: Math.PI / 6
		},
		{
			color: e_,
			symbol: "circle",
			dashArrayX: [[8, 8], [
				0,
				8,
				8,
				0
			]],
			dashArrayY: [6, 0],
			symbolSize: .8
		},
		{
			color: e_,
			dashArrayX: [1, 0],
			dashArrayY: [4, 3],
			rotation: -Math.PI / 4
		},
		{
			color: e_,
			dashArrayX: [[6, 6], [
				0,
				6,
				6,
				0
			]],
			dashArrayY: [6, 0]
		},
		{
			color: e_,
			dashArrayX: [[1, 0], [1, 6]],
			dashArrayY: [
				1,
				0,
				6,
				0
			],
			rotation: Math.PI / 4
		},
		{
			color: e_,
			symbol: "triangle",
			dashArrayX: [[9, 9], [
				0,
				9,
				9,
				0
			]],
			dashArrayY: [7, 2],
			symbolSize: .75
		}
	] } },
	textStyle: {
		fontFamily: $g.match(/^Win/) ? "Microsoft YaHei" : "sans-serif",
		fontSize: 12,
		fontStyle: "normal",
		fontWeight: "normal"
	},
	blendMode: null,
	stateAnimation: {
		duration: 300,
		easing: "cubicOut"
	},
	animation: "auto",
	animationDuration: 1e3,
	animationDurationUpdate: 500,
	animationEasing: "cubicInOut",
	animationEasingUpdate: "cubicInOut",
	animationThreshold: 2e3,
	progressiveThreshold: 3e3,
	progressive: 400,
	hoverLayerThreshold: 3e3,
	useUTC: !1
}, i_ = {
	Must: 1,
	Might: 2,
	Not: 3
}, a_ = X();
function o_(e) {
	a_(e).datasetMap = K();
}
function s_(e, t, n) {
	var r = {}, i = l_(t);
	if (!i || !e) return r;
	var a = [], o = [], s = t.ecModel, c = a_(s).datasetMap, l = i.uid + "_" + n.seriesLayoutBy, u, d;
	e = e.slice(), I(e, function(t, n) {
		var i = W(t) ? t : e[n] = { name: t };
		i.type === "ordinal" && u == null && (u = n, d = m(i)), r[i.name] = [];
	});
	var f = c.get(l) || c.set(l, {
		categoryWayDim: d,
		valueWayDim: 0
	});
	I(e, function(e, t) {
		var n = e.name, i = m(e);
		if (u == null) {
			var s = f.valueWayDim;
			p(r[n], s, i), p(o, s, i), f.valueWayDim += i;
		} else if (u === t) p(r[n], 0, i), p(a, 0, i);
		else {
			var s = f.categoryWayDim;
			p(r[n], s, i), p(o, s, i), f.categoryWayDim += i;
		}
	});
	function p(e, t, n) {
		for (var r = 0; r < n; r++) e.push(t + r);
	}
	function m(e) {
		var t = e.dimsDef;
		return t ? t.length : 1;
	}
	return a.length && (r.itemName = a), o.length && (r.seriesName = o), r;
}
function c_(e, t, n) {
	var r = {};
	if (!l_(e)) return r;
	var i = t.sourceFormat, a = t.dimensionsDefine, o;
	(i === "objectRows" || i === "keyedColumns") && I(a, function(e, t) {
		(W(e) ? e.name : e) === "name" && (o = t);
	});
	var s = function() {
		for (var e = {}, r = {}, s = [], c = 0, l = Math.min(5, n); c < l; c++) {
			var u = f_(t.data, i, t.seriesLayoutBy, a, t.startIndex, c);
			s.push(u);
			var d = u === i_.Not;
			if (d && e.v == null && c !== o && (e.v = c), (e.n == null || e.n === e.v || !d && s[e.n] === i_.Not) && (e.n = c), f(e) && s[e.n] !== i_.Not) return e;
			d || (u === i_.Might && r.v == null && c !== o && (r.v = c), (r.n == null || r.n === r.v) && (r.n = c));
		}
		function f(e) {
			return e.v != null && e.n != null;
		}
		return f(e) ? e : f(r) ? r : null;
	}();
	if (s) {
		r.value = [s.v];
		var c = o ?? s.n;
		r.itemName = [c], r.seriesName = [c];
	}
	return r;
}
function l_(e) {
	if (!e.get("data", !0)) return Ns(e.ecModel, "dataset", {
		index: e.get("datasetIndex", !0),
		id: e.get("datasetId", !0)
	}, js).models[0];
}
function u_(e) {
	return !e.get("transform", !0) && !e.get("fromTransformResult", !0) ? [] : Ns(e.ecModel, "dataset", {
		index: e.get("fromDatasetIndex", !0),
		id: e.get("fromDatasetId", !0)
	}, js).models;
}
function d_(e, t) {
	return f_(e.data, e.sourceFormat, e.seriesLayoutBy, e.dimensionsDefine, e.startIndex, t);
}
function f_(e, t, n, r, i, a) {
	var o, s = 5;
	if (fe(e)) return i_.Not;
	var c, l;
	if (r) {
		var u = r[a];
		W(u) ? (c = u.name, l = u.type) : U(u) && (c = u);
	}
	if (l != null) return l === "ordinal" ? i_.Must : i_.Not;
	if (t === "arrayRows") {
		var d = e;
		if (n === "row") {
			for (var f = d[a], p = 0; p < (f || []).length && p < s; p++) if ((o = b(f[i + p])) != null) return o;
		} else for (var p = 0; p < d.length && p < s; p++) {
			var m = d[i + p];
			if (m && (o = b(m[a])) != null) return o;
		}
	} else if (t === "objectRows") {
		var h = e;
		if (!c) return i_.Not;
		for (var p = 0; p < h.length && p < s; p++) {
			var g = h[p];
			if (g && (o = b(g[c])) != null) return o;
		}
	} else if (t === "keyedColumns") {
		var _ = e;
		if (!c) return i_.Not;
		var f = _[c];
		if (!f || fe(f)) return i_.Not;
		for (var p = 0; p < f.length && p < s; p++) if ((o = b(f[p])) != null) return o;
	} else if (t === "original") for (var v = e, p = 0; p < v.length && p < s; p++) {
		var g = v[p], y = us(g);
		if (!V(y)) return i_.Not;
		if ((o = b(y[a])) != null) return o;
	}
	function b(e) {
		var t = U(e);
		if (e != null && isFinite(Number(e)) && e !== "") return t ? i_.Might : i_.Not;
		if (t && e !== "-") return i_.Must;
	}
	return i_.Not;
}
//#endregion
//#region node_modules/echarts/lib/model/internalComponentCreator.js
var p_ = K();
function m_(e, t, n) {
	var r = p_.get(t);
	if (!r) return n;
	var i = r(e);
	return i ? n.concat(i) : n;
}
//#endregion
//#region node_modules/echarts/lib/model/mixin/palette.js
var h_ = X(), g_ = X(), __ = function() {
	function e() {}
	return e.prototype.getColorFromPalette = function(e, t, n) {
		var r = ss(this.get("color", !0)), i = this.get("colorLayer", !0);
		return b_(this, h_, r, i, e, t, n);
	}, e.prototype.clearColorPalette = function() {
		x_(this, h_);
	}, e;
}();
function v_(e, t, n, r) {
	return b_(e, g_, ss(e.get([
		"aria",
		"decal",
		"decals"
	])), null, t, n, r);
}
function y_(e, t) {
	for (var n = e.length, r = 0; r < n; r++) if (e[r].length > t) return e[r];
	return e[n - 1];
}
function b_(e, t, n, r, i, a, o) {
	a ||= e;
	var s = t(a), c = s.paletteIdx || 0, l = s.paletteNameMap = s.paletteNameMap || {};
	if (l.hasOwnProperty(i)) return l[i];
	var u = o == null || !r ? n : y_(r, o);
	if (u ||= n, u && u.length) {
		var d = u[c];
		return i && (l[i] = d), s.paletteIdx = (c + 1) % u.length, d;
	}
}
function x_(e, t) {
	t(e).paletteIdx = 0, t(e).paletteNameMap = {};
}
//#endregion
//#region node_modules/echarts/lib/model/Global.js
var S_, C_, w_, T_ = "\0_ec_inner", E_ = 1, D_ = function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t.prototype.init = function(e, t, n, r, i, a) {
		r ||= {}, this.option = null, this._theme = new ih(r), this._locale = new ih(i), this._optionManager = a;
	}, t.prototype.setOption = function(e, t, n) {
		var r = M_(t);
		this._optionManager.setOption(e, n, r), this._resetOption(null, r);
	}, t.prototype.resetOption = function(e, t) {
		return this._resetOption(e, M_(t));
	}, t.prototype._resetOption = function(e, t) {
		var n = !1, r = this._optionManager;
		if (!e || e === "recreate") {
			var i = r.mountOption(e === "recreate");
			!this.option || e === "recreate" ? w_(this, i) : (this.restoreData(), this._mergeOption(i, t)), n = !0;
		}
		if ((e === "timeline" || e === "media") && this.restoreData(), !e || e === "recreate" || e === "timeline") {
			var a = r.getTimelineOption(this);
			a && (n = !0, this._mergeOption(a, t));
		}
		if (!e || e === "recreate" || e === "media") {
			var o = r.getMediaOption(this);
			o.length && I(o, function(e) {
				n = !0, this._mergeOption(e, t);
			}, this);
		}
		return n;
	}, t.prototype.mergeOption = function(e) {
		this._mergeOption(e, null);
	}, t.prototype._mergeOption = function(e, t) {
		var n = this.option, r = this._componentsMap, i = this._componentsCount, a = [], o = K(), s = t && t.replaceMergeMainTypeMap;
		o_(this), I(e, function(e, t) {
			e != null && (Jg.hasClass(t) ? t && (a.push(t), o.set(t, !0)) : n[t] = n[t] == null ? A(e) : j(n[t], e, !0));
		}), s && s.each(function(e, t) {
			Jg.hasClass(t) && !o.get(t) && (a.push(t), o.set(t, !0));
		}), Jg.topologicalTravel(a, Jg.getAllClassMainTypes(), c, this);
		function c(t) {
			var a = m_(this, t, ss(e[t])), o = r.get(t), c = fs(o, a, o ? s && s.get(t) ? "replaceMerge" : "normalMerge" : "replaceAll");
			ws(c, t, Jg), n[t] = null, r.set(t, null), i.set(t, 0);
			var l = [], u = [], d = 0, f;
			I(c, function(e, n) {
				var r = e.existing, i = e.newOption;
				if (!i) r && (r.mergeOption({}, this), r.optionUpdated({}, !1));
				else {
					var a = t === "series", o = Jg.getClass(t, e.keyInfo.subType, !a);
					if (!o) return;
					if (t === "tooltip") {
						if (f) return;
						f = !0;
					}
					if (r && r.constructor === o) r.name = e.keyInfo.name, r.mergeOption(i, this), r.optionUpdated(i, !1);
					else {
						var s = M({ componentIndex: n }, e.keyInfo);
						r = new o(i, this, this, s), M(r, s), e.brandNew && (r.__requireNewView = !0), r.init(i, this, this), r.optionUpdated(null, !0);
					}
				}
				r ? (l.push(r.option), u.push(r), d++) : (l.push(void 0), u.push(void 0));
			}, this), n[t] = l, r.set(t, u), i.set(t, d), t === "series" && S_(this);
		}
		this._seriesIndices || S_(this);
	}, t.prototype.getOption = function() {
		var e = A(this.option);
		return I(e, function(t, n) {
			if (Jg.hasClass(n)) {
				for (var r = ss(t), i = r.length, a = !1, o = i - 1; o >= 0; o--) r[o] && !Cs(r[o]) ? a = !0 : (r[o] = null, !a && i--);
				r.length = i, e[n] = r;
			}
		}), delete e[T_], e;
	}, t.prototype.setTheme = function(e) {
		this._theme = new ih(e), this._resetOption("recreate", null);
	}, t.prototype.getTheme = function() {
		return this._theme;
	}, t.prototype.getLocaleModel = function() {
		return this._locale;
	}, t.prototype.setUpdatePayload = function(e) {
		this._payload = e;
	}, t.prototype.getUpdatePayload = function() {
		return this._payload;
	}, t.prototype.getComponent = function(e, t) {
		var n = this._componentsMap.get(e);
		if (n) {
			var r = n[t || 0];
			if (r) return r;
			if (t == null) {
				for (var i = 0; i < n.length; i++) if (n[i]) return n[i];
			}
		}
	}, t.prototype.queryComponents = function(e) {
		var t = e.mainType;
		if (!t) return [];
		var n = e.index, r = e.id, i = e.name, a = this._componentsMap.get(t);
		if (!a || !a.length) return [];
		var o;
		return n == null ? o = r == null ? i == null ? oe(a, function(e) {
			return !!e;
		}) : A_("name", i, a) : A_("id", r, a) : (o = [], I(ss(n), function(e) {
			a[e] && o.push(a[e]);
		})), j_(o, e);
	}, t.prototype.findComponents = function(e) {
		var t = e.query, n = e.mainType, r = i(t);
		return a(j_(r ? this.queryComponents(r) : oe(this._componentsMap.get(n), function(e) {
			return !!e;
		}), e));
		function i(e) {
			var t = n + "Index", r = n + "Id", i = n + "Name";
			return e && (e[t] != null || e[r] != null || e[i] != null) ? {
				mainType: n,
				index: e[t],
				id: e[r],
				name: e[i]
			} : null;
		}
		function a(t) {
			return e.filter ? oe(t, e.filter) : t;
		}
	}, t.prototype.eachComponent = function(e, t, n) {
		var r = this._componentsMap;
		if (H(e)) {
			var i = t, a = e;
			r.each(function(e, t) {
				for (var n = 0; e && n < e.length; n++) {
					var r = e[n];
					r && a.call(i, t, r, r.componentIndex);
				}
			});
		} else for (var o = U(e) ? r.get(e) : W(e) ? this.findComponents(e) : null, s = 0; o && s < o.length; s++) {
			var c = o[s];
			c && t.call(n, c, c.componentIndex);
		}
	}, t.prototype.getSeriesByName = function(e) {
		var t = xs(e, null);
		return oe(this._componentsMap.get("series"), function(e) {
			return !!e && t != null && e.name === t;
		});
	}, t.prototype.getSeriesByIndex = function(e) {
		return this._componentsMap.get("series")[e];
	}, t.prototype.getSeriesByType = function(e) {
		return oe(this._componentsMap.get("series"), function(t) {
			return !!t && t.subType === e;
		});
	}, t.prototype.getSeries = function() {
		return oe(this._componentsMap.get("series"), function(e) {
			return !!e;
		});
	}, t.prototype.getSeriesCount = function() {
		return this._componentsCount.get("series");
	}, t.prototype.eachSeries = function(e, t) {
		C_(this), I(this._seriesIndices, function(n) {
			var r = this._componentsMap.get("series")[n];
			e.call(t, r, n);
		}, this);
	}, t.prototype.eachRawSeries = function(e, t) {
		I(this._componentsMap.get("series"), function(n) {
			n && e.call(t, n, n.componentIndex);
		});
	}, t.prototype.eachSeriesByType = function(e, t, n) {
		C_(this), I(this._seriesIndices, function(r) {
			var i = this._componentsMap.get("series")[r];
			i.subType === e && t.call(n, i, r);
		}, this);
	}, t.prototype.eachRawSeriesByType = function(e, t, n) {
		return I(this.getSeriesByType(e), t, n);
	}, t.prototype.isSeriesFiltered = function(e) {
		return C_(this), this._seriesIndicesMap.get(e.componentIndex) == null;
	}, t.prototype.getCurrentSeriesIndices = function() {
		return (this._seriesIndices || []).slice();
	}, t.prototype.filterSeries = function(e, t) {
		C_(this);
		var n = [];
		I(this._seriesIndices, function(r) {
			var i = this._componentsMap.get("series")[r];
			e.call(t, i, r) && n.push(r);
		}, this), this._seriesIndices = n, this._seriesIndicesMap = K(n);
	}, t.prototype.restoreData = function(e) {
		S_(this);
		var t = this._componentsMap, n = [];
		t.each(function(e, t) {
			Jg.hasClass(t) && n.push(t);
		}), Jg.topologicalTravel(n, Jg.getAllClassMainTypes(), function(n) {
			I(t.get(n), function(t) {
				t && (n !== "series" || !O_(t, e)) && t.restoreData();
			});
		});
	}, t.internalField = function() {
		S_ = function(e) {
			var t = e._seriesIndices = [];
			I(e._componentsMap.get("series"), function(e) {
				e && t.push(e.componentIndex);
			}), e._seriesIndicesMap = K(t);
		}, C_ = function(e) {}, w_ = function(e, t) {
			e.option = {}, e.option[T_] = E_, e._componentsMap = K({ series: [] }), e._componentsCount = K();
			var n = t.aria;
			W(n) && n.enabled == null && (n.enabled = !0), k_(t, e._theme.option), j(t, r_, !1), e._mergeOption(t, null);
		};
	}(), t;
}(ih);
function O_(e, t) {
	if (t) {
		var n = t.seriesIndex, r = t.seriesId, i = t.seriesName;
		return n != null && e.componentIndex !== n || r != null && e.id !== r || i != null && e.name !== i;
	}
}
function k_(e, t) {
	var n = e.color && !e.colorLayer;
	I(t, function(t, r) {
		r === "colorLayer" && n || r === "color" && e.color || Jg.hasClass(r) || (typeof t == "object" ? e[r] = e[r] ? j(e[r], t, !1) : A(t) : e[r] ?? (e[r] = t));
	});
}
function A_(e, t, n) {
	if (V(t)) {
		var r = K();
		return I(t, function(e) {
			e != null && xs(e, null) != null && r.set(e, !0);
		}), oe(n, function(t) {
			return t && r.get(t[e]);
		});
	}
	var i = xs(t, null);
	return oe(n, function(t) {
		return t && i != null && t[e] === i;
	});
}
function j_(e, t) {
	return t.hasOwnProperty("subType") ? oe(e, function(e) {
		return e && e.subType === t.subType;
	}) : e;
}
function M_(e) {
	var t = K();
	return e && I(ss(e.replaceMerge), function(e) {
		t.set(e, !0);
	}), { replaceMergeMainTypeMap: t };
}
F(D_, __);
//#endregion
//#region node_modules/echarts/lib/model/OptionManager.js
var N_ = /^(min|max)?(.+)$/, P_ = function() {
	function e(e) {
		this._timelineOptions = [], this._mediaList = [], this._currentMediaIndices = [], this._api = e;
	}
	return e.prototype.setOption = function(e, t, n) {
		e && (I(ss(e.series), function(e) {
			e && e.data && fe(e.data) && Te(e.data);
		}), I(ss(e.dataset), function(e) {
			e && e.source && fe(e.source) && Te(e.source);
		})), e = A(e);
		var r = this._optionBackup, i = F_(e, t, !r);
		this._newBaseOption = i.baseOption, r ? (i.timelineOptions.length && (r.timelineOptions = i.timelineOptions), i.mediaList.length && (r.mediaList = i.mediaList), i.mediaDefault && (r.mediaDefault = i.mediaDefault)) : this._optionBackup = i;
	}, e.prototype.mountOption = function(e) {
		var t = this._optionBackup;
		return this._timelineOptions = t.timelineOptions, this._mediaList = t.mediaList, this._mediaDefault = t.mediaDefault, this._currentMediaIndices = [], A(e ? t.baseOption : this._newBaseOption);
	}, e.prototype.getTimelineOption = function(e) {
		var t, n = this._timelineOptions;
		if (n.length) {
			var r = e.getComponent("timeline");
			r && (t = A(n[r.getCurrentIndex()]));
		}
		return t;
	}, e.prototype.getMediaOption = function(e) {
		var t = this._api.getWidth(), n = this._api.getHeight(), r = this._mediaList, i = this._mediaDefault, a = [], o = [];
		if (!r.length && !i) return o;
		for (var s = 0, c = r.length; s < c; s++) I_(r[s].query, t, n) && a.push(s);
		return !a.length && i && (a = [-1]), a.length && !R_(a, this._currentMediaIndices) && (o = L(a, function(e) {
			return A(e === -1 ? i.option : r[e].option);
		})), this._currentMediaIndices = a, o;
	}, e;
}();
function F_(e, t, n) {
	var r = [], i, a, o = e.baseOption, s = e.timeline, c = e.options, l = e.media, u = !!e.media, d = !!(c || s || o && o.timeline);
	o ? (a = o, a.timeline || (a.timeline = s)) : ((d || u) && (e.options = e.media = null), a = e), u && V(l) && I(l, function(e) {
		e && e.option && (e.query ? r.push(e) : i ||= e);
	}), f(a), I(c, function(e) {
		return f(e);
	}), I(r, function(e) {
		return f(e.option);
	});
	function f(e) {
		I(t, function(t) {
			t(e, n);
		});
	}
	return {
		baseOption: a,
		timelineOptions: c || [],
		mediaDefault: i,
		mediaList: r
	};
}
function I_(e, t, n) {
	var r = {
		width: t,
		height: n,
		aspectratio: t / n
	}, i = !0;
	return I(e, function(e, t) {
		var n = t.match(N_);
		if (n && n[1] && n[2]) {
			var a = n[1];
			L_(r[n[2].toLowerCase()], e, a) || (i = !1);
		}
	}), i;
}
function L_(e, t, n) {
	return n === "min" ? e >= t : n === "max" ? e <= t : e === t;
}
function R_(e, t) {
	return e.join(",") === t.join(",");
}
//#endregion
//#region node_modules/echarts/lib/preprocessor/helper/compatStyle.js
var z_ = I, B_ = W, V_ = [
	"areaStyle",
	"lineStyle",
	"nodeStyle",
	"linkStyle",
	"chordStyle",
	"label",
	"labelLine"
];
function H_(e) {
	var t = e && e.itemStyle;
	if (t) for (var n = 0, r = V_.length; n < r; n++) {
		var i = V_[n], a = t.normal, o = t.emphasis;
		a && a[i] && (e[i] = e[i] || {}, e[i].normal ? j(e[i].normal, a[i]) : e[i].normal = a[i], a[i] = null), o && o[i] && (e[i] = e[i] || {}, e[i].emphasis ? j(e[i].emphasis, o[i]) : e[i].emphasis = o[i], o[i] = null);
	}
}
function U_(e, t, n) {
	if (e && e[t] && (e[t].normal || e[t].emphasis)) {
		var r = e[t].normal, i = e[t].emphasis;
		r && (n ? (e[t].normal = e[t].emphasis = null, N(e[t], r)) : e[t] = r), i && (e.emphasis = e.emphasis || {}, e.emphasis[t] = i, i.focus && (e.emphasis.focus = i.focus), i.blurScope && (e.emphasis.blurScope = i.blurScope));
	}
}
function W_(e) {
	U_(e, "itemStyle"), U_(e, "lineStyle"), U_(e, "areaStyle"), U_(e, "label"), U_(e, "labelLine"), U_(e, "upperLabel"), U_(e, "edgeLabel");
}
function G_(e, t) {
	var n = B_(e) && e[t], r = B_(n) && n.textStyle;
	if (r) for (var i = 0, a = ls.length; i < a; i++) {
		var o = ls[i];
		r.hasOwnProperty(o) && (n[o] = r[o]);
	}
}
function K_(e) {
	e && (W_(e), G_(e, "label"), e.emphasis && G_(e.emphasis, "label"));
}
function q_(e) {
	if (B_(e)) {
		H_(e), W_(e), G_(e, "label"), G_(e, "upperLabel"), G_(e, "edgeLabel"), e.emphasis && (G_(e.emphasis, "label"), G_(e.emphasis, "upperLabel"), G_(e.emphasis, "edgeLabel"));
		var t = e.markPoint;
		t && (H_(t), K_(t));
		var n = e.markLine;
		n && (H_(n), K_(n));
		var r = e.markArea;
		r && K_(r);
		var i = e.data;
		if (e.type === "graph") {
			i ||= e.nodes;
			var a = e.links || e.edges;
			if (a && !fe(a)) for (var o = 0; o < a.length; o++) K_(a[o]);
			I(e.categories, function(e) {
				W_(e);
			});
		}
		if (i && !fe(i)) for (var o = 0; o < i.length; o++) K_(i[o]);
		if (t = e.markPoint, t && t.data) for (var s = t.data, o = 0; o < s.length; o++) K_(s[o]);
		if (n = e.markLine, n && n.data) for (var c = n.data, o = 0; o < c.length; o++) V(c[o]) ? (K_(c[o][0]), K_(c[o][1])) : K_(c[o]);
		e.type === "gauge" ? (G_(e, "axisLabel"), G_(e, "title"), G_(e, "detail")) : e.type === "treemap" ? (U_(e.breadcrumb, "itemStyle"), I(e.levels, function(e) {
			W_(e);
		})) : e.type === "tree" && W_(e.leaves);
	}
}
function J_(e) {
	return V(e) ? e : e ? [e] : [];
}
function Y_(e) {
	return (V(e) ? e[0] : e) || {};
}
function X_(e, t) {
	z_(J_(e.series), function(e) {
		B_(e) && q_(e);
	});
	var n = [
		"xAxis",
		"yAxis",
		"radiusAxis",
		"angleAxis",
		"singleAxis",
		"parallelAxis",
		"radar"
	];
	t && n.push("valueAxis", "categoryAxis", "logAxis", "timeAxis"), z_(n, function(t) {
		z_(J_(e[t]), function(e) {
			e && (G_(e, "axisLabel"), G_(e.axisPointer, "label"));
		});
	}), z_(J_(e.parallel), function(e) {
		var t = e && e.parallelAxisDefault;
		G_(t, "axisLabel"), G_(t && t.axisPointer, "label");
	}), z_(J_(e.calendar), function(e) {
		U_(e, "itemStyle"), G_(e, "dayLabel"), G_(e, "monthLabel"), G_(e, "yearLabel");
	}), z_(J_(e.radar), function(e) {
		G_(e, "name"), e.name && e.axisName == null && (e.axisName = e.name, delete e.name), e.nameGap != null && e.axisNameGap == null && (e.axisNameGap = e.nameGap, delete e.nameGap);
	}), z_(J_(e.geo), function(e) {
		B_(e) && (K_(e), z_(J_(e.regions), function(e) {
			K_(e);
		}));
	}), z_(J_(e.timeline), function(e) {
		K_(e), U_(e, "label"), U_(e, "itemStyle"), U_(e, "controlStyle", !0);
		var t = e.data;
		V(t) && I(t, function(e) {
			W(e) && (U_(e, "label"), U_(e, "itemStyle"));
		});
	}), z_(J_(e.toolbox), function(e) {
		U_(e, "iconStyle"), z_(e.feature, function(e) {
			U_(e, "iconStyle");
		});
	}), G_(Y_(e.axisPointer), "label"), G_(Y_(e.tooltip).axisPointer, "label");
}
//#endregion
//#region node_modules/echarts/lib/preprocessor/backwardCompat.js
function Z_(e, t) {
	for (var n = t.split(","), r = e, i = 0; i < n.length && (r &&= r[n[i]], r != null); i++);
	return r;
}
function Q_(e, t, n, r) {
	for (var i = t.split(","), a = e, o, s = 0; s < i.length - 1; s++) o = i[s], a[o] ?? (a[o] = {}), a = a[o];
	(r || a[i[s]] == null) && (a[i[s]] = n);
}
function $_(e) {
	e && I(ev, function(t) {
		t[0] in e && !(t[1] in e) && (e[t[1]] = e[t[0]]);
	});
}
var ev = [
	["x", "left"],
	["y", "top"],
	["x2", "right"],
	["y2", "bottom"]
], tv = [
	"grid",
	"geo",
	"parallel",
	"legend",
	"toolbox",
	"title",
	"visualMap",
	"dataZoom",
	"timeline"
], nv = [
	["borderRadius", "barBorderRadius"],
	["borderColor", "barBorderColor"],
	["borderWidth", "barBorderWidth"]
];
function rv(e) {
	var t = e && e.itemStyle;
	if (t) for (var n = 0; n < nv.length; n++) {
		var r = nv[n][1], i = nv[n][0];
		t[r] != null && (t[i] = t[r]);
	}
}
function iv(e) {
	e && e.alignTo === "edge" && e.margin != null && e.edgeDistance == null && (e.edgeDistance = e.margin);
}
function av(e) {
	e && e.downplay && !e.blur && (e.blur = e.downplay);
}
function ov(e) {
	e && e.focusNodeAdjacency != null && (e.emphasis = e.emphasis || {}, e.emphasis.focus ?? (e.emphasis.focus = "adjacency"));
}
function sv(e, t) {
	if (e) for (var n = 0; n < e.length; n++) t(e[n]), e[n] && sv(e[n].children, t);
}
function cv(e, t) {
	X_(e, t), e.series = ss(e.series), I(e.series, function(e) {
		if (W(e)) {
			var t = e.type;
			if (t === "line") e.clipOverflow != null && (e.clip = e.clipOverflow);
			else if (t === "pie" || t === "gauge") {
				e.clockWise != null && (e.clockwise = e.clockWise), iv(e.label);
				var n = e.data;
				if (n && !fe(n)) for (var r = 0; r < n.length; r++) iv(n[r]);
				e.hoverOffset != null && (e.emphasis = e.emphasis || {}, (e.emphasis.scaleSize = null) && (e.emphasis.scaleSize = e.hoverOffset));
			} else if (t === "gauge") {
				var i = Z_(e, "pointer.color");
				i != null && Q_(e, "itemStyle.color", i);
			} else if (t === "bar") {
				rv(e), rv(e.backgroundStyle), rv(e.emphasis);
				var n = e.data;
				if (n && !fe(n)) for (var r = 0; r < n.length; r++) typeof n[r] == "object" && (rv(n[r]), rv(n[r] && n[r].emphasis));
			} else if (t === "sunburst") {
				var a = e.highlightPolicy;
				a && (e.emphasis = e.emphasis || {}, e.emphasis.focus || (e.emphasis.focus = a)), av(e), sv(e.data, av);
			} else t === "graph" || t === "sankey" ? ov(e) : t === "map" && (e.mapType && !e.map && (e.map = e.mapType), e.mapLocation && N(e, e.mapLocation));
			e.hoverAnimation != null && (e.emphasis = e.emphasis || {}, e.emphasis && e.emphasis.scale == null && (e.emphasis.scale = e.hoverAnimation)), $_(e);
		}
	}), e.dataRange && (e.visualMap = e.dataRange), I(tv, function(t) {
		var n = e[t];
		n && (V(n) || (n = [n]), I(n, function(e) {
			$_(e);
		}));
	});
}
//#endregion
//#region node_modules/echarts/lib/processor/dataStack.js
var lv = nc(uv);
function uv(e) {
	var t = K();
	e.eachSeries(function(e) {
		var n = e.get("stack");
		if (n) {
			var r = t.get(n) || t.set(n, []), i = e.getData(), a = {
				stackResultDimension: i.getCalculationInfo("stackResultDimension"),
				stackedOverDimension: i.getCalculationInfo("stackedOverDimension"),
				stackedDimension: i.getCalculationInfo("stackedDimension"),
				stackedByDimension: i.getCalculationInfo("stackedByDimension"),
				isStackedByIndex: i.getCalculationInfo("isStackedByIndex"),
				data: i,
				seriesModel: e
			};
			if (!a.stackedDimension || !(a.isStackedByIndex || a.stackedByDimension)) return;
			r.push(a);
		}
	}), t.each(function(e) {
		e.length !== 0 && ((e[0].seriesModel.get("stackOrder") || "seriesAsc") === "seriesDesc" && e.reverse(), I(e, function(t, n) {
			t.data.setCalculationInfo("stackedOnSeries", n > 0 ? e[n - 1].seriesModel : null);
		}), dv(e));
	});
}
function dv(e) {
	I(e, function(t, n) {
		var r = [], i = [NaN, NaN], a = [t.stackResultDimension, t.stackedOverDimension], o = t.data, s = t.isStackedByIndex, c = t.seriesModel.get("stackStrategy") || "samesign";
		o.modify(a, function(a, l, u) {
			var d = o.get(t.stackedDimension, u);
			if (isNaN(d)) return i;
			var f, p;
			s ? p = o.getRawIndex(u) : f = o.get(t.stackedByDimension, u);
			for (var m = NaN, h = n - 1; h >= 0; h--) {
				var g = e[h];
				if (s || (p = g.data.rawIndexOf(g.stackedByDimension, f)), p >= 0) {
					var _ = g.data.getByRawIndex(g.stackResultDimension, p);
					if (c === "all" || c === "positive" && _ > 0 || c === "negative" && _ < 0 || c === "samesign" && d >= 0 && _ > 0 || c === "samesign" && d <= 0 && _ < 0) {
						d = Fo(d, _), m = _;
						break;
					}
				}
			}
			return r[0] = d, r[1] = m, r;
		});
	});
}
//#endregion
//#region node_modules/echarts/lib/data/Source.js
var fv = function() {
	function e(e) {
		this.data = e.data || (e.sourceFormat === "keyedColumns" ? {} : []), this.sourceFormat = e.sourceFormat || "unknown", this.seriesLayoutBy = e.seriesLayoutBy || "column", this.startIndex = e.startIndex || 0, this.dimensionsDetectedCount = e.dimensionsDetectedCount, this.metaRawOption = e.metaRawOption;
		var t = this.dimensionsDefine = e.dimensionsDefine;
		if (t) for (var n = 0; n < t.length; n++) {
			var r = t[n];
			r.type == null && d_(this, n) === i_.Must && (r.type = "ordinal");
		}
	}
	return e;
}();
function pv(e) {
	return e instanceof fv;
}
function mv(e, t, n) {
	n ||= _v(e);
	var r = t.seriesLayoutBy, i = vv(e, n, r, t.sourceHeader, t.dimensions);
	return new fv({
		data: e,
		sourceFormat: n,
		seriesLayoutBy: r,
		dimensionsDefine: i.dimensionsDefine,
		startIndex: i.startIndex,
		dimensionsDetectedCount: i.dimensionsDetectedCount,
		metaRawOption: A(t)
	});
}
function hv(e) {
	return new fv({
		data: e,
		sourceFormat: fe(e) ? Gu : Vu
	});
}
function gv(e) {
	return new fv({
		data: e.data,
		sourceFormat: e.sourceFormat,
		seriesLayoutBy: e.seriesLayoutBy,
		dimensionsDefine: A(e.dimensionsDefine),
		startIndex: e.startIndex,
		dimensionsDetectedCount: e.dimensionsDetectedCount
	});
}
function _v(e) {
	var t = Ku;
	if (fe(e)) t = Gu;
	else if (V(e)) {
		e.length === 0 && (t = Hu);
		for (var n = 0, r = e.length; n < r; n++) {
			var i = e[n];
			if (i != null) {
				if (V(i) || fe(i)) {
					t = Hu;
					break;
				}
				if (W(i)) {
					t = Uu;
					break;
				}
			}
		}
	} else if (W(e)) {
		for (var a in e) if (q(e, a) && ie(e[a])) {
			t = Wu;
			break;
		}
	}
	return t;
}
function vv(e, t, n, r, i) {
	var a, o;
	if (!e) return {
		dimensionsDefine: bv(i),
		startIndex: o,
		dimensionsDetectedCount: a
	};
	if (t === "arrayRows") {
		var s = e;
		r === "auto" || r == null ? xv(function(e) {
			e != null && e !== "-" && (U(e) ? o ??= 1 : o = 0);
		}, n, s, 10) : o = ue(r) ? r : +!!r, !i && o === 1 && (i = [], xv(function(e, t) {
			i[t] = e == null ? "" : e + "";
		}, n, s, Infinity)), a = i ? i.length : n === "row" ? s.length : s[0] ? s[0].length : null;
	} else if (t === "objectRows") i ||= yv(e);
	else if (t === "keyedColumns") i || (i = [], I(e, function(e, t) {
		i.push(t);
	}));
	else if (t === "original") {
		var c = us(e[0]);
		a = V(c) && c.length || 1;
	}
	return {
		startIndex: o,
		dimensionsDefine: bv(i),
		dimensionsDetectedCount: a
	};
}
function yv(e) {
	for (var t = 0, n; t < e.length && !(n = e[t++]););
	if (n) return R(n);
}
function bv(e) {
	if (e) {
		var t = K();
		return L(e, function(e, n) {
			e = W(e) ? e : { name: e };
			var r = {
				name: e.name,
				displayName: e.displayName,
				type: e.type
			};
			if (r.name == null) return r;
			r.name += "", r.displayName ??= r.name;
			var i = t.get(r.name);
			return i ? r.name += "-" + i.count++ : t.set(r.name, { count: 1 }), r;
		});
	}
}
function xv(e, t, n, r) {
	if (t === "row") for (var i = 0; i < n.length && i < r; i++) e(n[i] ? n[i][0] : null, i);
	else for (var a = n[0] || [], i = 0; i < a.length && i < r; i++) e(a[i], i);
}
function Sv(e) {
	var t = e.sourceFormat;
	return t === "objectRows" || t === "keyedColumns";
}
//#endregion
//#region node_modules/echarts/lib/data/helper/dataProvider.js
var Cv, wv, Tv, Ev, Dv, Ov, kv = function() {
	function e(e, t) {
		var n = pv(e) ? e : hv(e);
		this._source = n;
		var r = this._data = n.data, i = n.sourceFormat;
		n.seriesLayoutBy, i === "typedArray" && (this._offset = 0, this._dimSize = t, this._data = r), Ov(this, r, n);
	}
	return e.prototype.getSource = function() {
		return this._source;
	}, e.prototype.count = function() {
		return 0;
	}, e.prototype.getItem = function(e, t) {}, e.prototype.appendData = function(e) {}, e.prototype.clean = function() {}, e.protoInitialize = function() {
		var t = e.prototype;
		t.pure = !1, t.persistent = !0;
	}(), e.internalField = function() {
		var e;
		Ov = function(e, i, a) {
			var o = a.sourceFormat, s = a.seriesLayoutBy, c = a.startIndex, l = a.dimensionsDefine, u = Dv[Bv(o, s)];
			M(e, u), o === "typedArray" ? (e.getItem = t, e.count = r, e.fillStorage = n) : (e.getItem = z(Nv(o, s), null, i, c, l), e.count = z(Iv(o, s), null, i, c, l));
		};
		var t = function(e, t) {
			e -= this._offset, t ||= [];
			for (var n = this._data, r = this._dimSize, i = r * e, a = 0; a < r; a++) t[a] = n[i + a];
			return t;
		}, n = function(e, t, n, r) {
			for (var i = this._data, a = this._dimSize, o = 0; o < a; o++) {
				for (var s = r[o], c = s[0] == null ? Infinity : s[0], l = s[1] == null ? -Infinity : s[1], u = t - e, d = n[o], f = 0; f < u; f++) {
					var p = i[f * a + o];
					d[e + f] = p, p < c && (c = p), p > l && (l = p);
				}
				s[0] = c, s[1] = l;
			}
		}, r = function() {
			return this._data ? this._data.length / this._dimSize : 0;
		};
		Dv = (e = {}, e[Hu + "_" + qu] = {
			pure: !0,
			appendData: i
		}, e[Hu + "_row"] = {
			pure: !0,
			appendData: function() {
				throw Error("Do not support appendData when set seriesLayoutBy: \"row\".");
			}
		}, e[Uu] = {
			pure: !0,
			appendData: i
		}, e[Wu] = {
			pure: !0,
			appendData: function(e) {
				var t = this._data;
				I(e, function(e, n) {
					for (var r = t[n] || (t[n] = []), i = 0; i < (e || []).length; i++) r.push(e[i]);
				});
			}
		}, e[Vu] = { appendData: i }, e[Gu] = {
			persistent: !1,
			pure: !0,
			appendData: function(e) {
				this._data = e;
			},
			clean: function() {
				this._offset += this.count(), this._data = null;
			}
		}, e);
		function i(e) {
			for (var t = 0; t < e.length; t++) this._data.push(e[t]);
		}
	}(), e;
}(), Av = function(e) {
	V(e) || ns("series.data or dataset.source must be an array.");
};
Cv = {}, Cv[Hu + "_" + qu] = Av, Cv[Hu + "_row"] = Av, Cv[Uu] = Av, Cv[Wu] = function(e, t) {
	for (var n = 0; n < t.length; n++) t[n].name ?? ns("dimension name must not be null/undefined.");
}, Cv[Vu] = Av;
var jv = function(e, t, n, r) {
	return e[r];
}, Mv = (wv = {}, wv[Hu + "_" + qu] = function(e, t, n, r) {
	return e[r + t];
}, wv[Hu + "_row"] = function(e, t, n, r, i) {
	r += t;
	for (var a = i || [], o = e, s = 0; s < o.length; s++) {
		var c = o[s];
		a[s] = c ? c[r] : null;
	}
	return a;
}, wv[Uu] = jv, wv[Wu] = function(e, t, n, r, i) {
	for (var a = i || [], o = 0; o < n.length; o++) {
		var s = n[o].name, c = s == null ? null : e[s];
		a[o] = c ? c[r] : null;
	}
	return a;
}, wv[Vu] = jv, wv);
function Nv(e, t) {
	return Mv[Bv(e, t)];
}
var Pv = function(e, t, n) {
	return e.length;
}, Fv = (Tv = {}, Tv[Hu + "_" + qu] = function(e, t, n) {
	return Math.max(0, e.length - t);
}, Tv[Hu + "_row"] = function(e, t, n) {
	var r = e[0];
	return r ? Math.max(0, r.length - t) : 0;
}, Tv[Uu] = Pv, Tv[Wu] = function(e, t, n) {
	var r = n[0].name, i = r == null ? null : e[r];
	return i ? i.length : 0;
}, Tv[Vu] = Pv, Tv);
function Iv(e, t) {
	return Fv[Bv(e, t)];
}
var Lv = function(e, t, n) {
	return e[t];
}, Rv = (Ev = {}, Ev[Hu] = Lv, Ev[Uu] = function(e, t, n) {
	return e[n];
}, Ev[Wu] = Lv, Ev[Vu] = function(e, t, n) {
	var r = us(e);
	return r instanceof Array ? r[t] : r;
}, Ev[Gu] = Lv, Ev);
function zv(e) {
	return Rv[e];
}
function Bv(e, t) {
	return e === "arrayRows" ? e + "_" + t : e;
}
function Vv(e, t, n) {
	if (e) {
		var r = e.getRawDataItem(t);
		if (r != null) {
			var i = e.getStore(), a = i.getSource().sourceFormat;
			if (n != null) {
				var o = e.getDimensionIndex(n), s = i.getDimensionProperty(o);
				return zv(a)(r, o, s);
			}
			var c = r;
			return a === "original" && (c = us(r)), c;
		}
	}
}
//#endregion
//#region node_modules/echarts/lib/model/mixin/dataFormat.js
var Hv = /\{@(.+?)\}/g, Uv = function() {
	function e() {}
	return e.prototype.getDataParams = function(e, t) {
		var n = this.getData(t), r = this.getRawValue(e, t), i = n.getRawIndex(e), a = n.getName(e), o = n.getRawDataItem(e), s = n.getItemVisual(e, "style"), c = s && s[n.getItemVisual(e, "drawType") || "fill"], l = s && s.stroke, u = this.mainType, d = u === "series", f = n.userOutput && n.userOutput.get();
		return {
			componentType: u,
			componentSubType: this.subType,
			componentIndex: this.componentIndex,
			seriesType: d ? this.subType : null,
			seriesIndex: this.seriesIndex,
			seriesId: d ? this.id : null,
			seriesName: d ? this.name : null,
			name: a,
			dataIndex: i,
			data: o,
			dataType: t,
			value: r,
			color: c,
			borderColor: l,
			dimensionNames: f ? f.fullDimensions : null,
			encode: f ? f.encode : null,
			$vars: [
				"seriesName",
				"name",
				"value"
			]
		};
	}, e.prototype.getFormattedLabel = function(e, t, n, r, i, a) {
		t ||= "normal";
		var o = this.getData(n), s = this.getDataParams(e, n);
		if (a && (s.value = a.interpolatedValue), r != null && V(s.value) && (s.value = s.value[r]), i ||= o.getItemModel(e).get(t === "normal" ? ["label", "formatter"] : [
			t,
			"label",
			"formatter"
		]), H(i)) return s.status = t, s.dimensionIndex = r, i(s);
		if (U(i)) return gg(i, s).replace(Hv, function(t, n) {
			var r = n.length, i = n;
			i.charAt(0) === "[" && i.charAt(r - 1) === "]" && (i = +i.slice(1, r - 1));
			var s = Vv(o, e, i);
			if (a && V(a.interpolatedValue)) {
				var c = o.getDimensionIndex(i);
				c >= 0 && (s = a.interpolatedValue[c]);
			}
			return s == null ? "" : s + "";
		});
	}, e.prototype.getRawValue = function(e, t) {
		return Vv(this.getData(t), e);
	}, e.prototype.formatTooltip = function(e, t, n) {}, e;
}();
function Wv(e) {
	var t, n;
	return W(e) ? e.type && (n = e) : t = e, {
		text: t,
		frag: n
	};
}
//#endregion
//#region node_modules/echarts/lib/core/task.js
function Gv(e) {
	return new Kv(e);
}
var Kv = function() {
	function e(e) {
		e ||= {}, this._reset = e.reset, this._plan = e.plan, this._count = e.count, this._onDirty = e.onDirty, this._dirty = !0;
	}
	return e.prototype.perform = function(e) {
		var t = this._upstream, n = e && e.skip;
		if (this._dirty && t) {
			var r = this.context;
			r.data = r.outputData = t.context.outputData;
		}
		this.__pipeline && (this.__pipeline.currentTask = this);
		var i;
		this._plan && !n && (i = this._plan(this.context));
		var a = l(this._modBy), o = this._modDataCount || 0, s = l(e && e.modBy), c = e && e.modDataCount || 0;
		(a !== s || o !== c) && (i = "reset");
		function l(e) {
			return !(e >= 1) && (e = 1), e;
		}
		var u;
		(this._dirty || i === "reset") && (this._dirty = !1, u = this._doReset(n)), this._modBy = s, this._modDataCount = c;
		var d = e && e.step;
		if (this._dueEnd = t ? t._outputDueEnd : this._count ? this._count(this.context) : Infinity, this._progress) {
			var f = this._dueIndex, p = Math.min(d == null ? Infinity : this._dueIndex + d, this._dueEnd);
			if (!n && (u || f < p)) {
				var m = this._progress;
				if (V(m)) for (var h = 0; h < m.length; h++) this._doProgress(m[h], f, p, s, c);
				else this._doProgress(m, f, p, s, c);
			}
			this._dueIndex = p;
			var g = this._settedOutputEnd == null ? p : this._settedOutputEnd;
			this._outputDueEnd = g;
		} else this._dueIndex = this._outputDueEnd = this._settedOutputEnd == null ? this._dueEnd : this._settedOutputEnd;
		return this.unfinished();
	}, e.prototype.dirty = function() {
		this._dirty = !0, this._onDirty && this._onDirty(this.context);
	}, e.prototype._doProgress = function(e, t, n, r, i) {
		qv.reset(t, n, r, i), this._callingProgress = e, this._callingProgress({
			start: t,
			end: n,
			count: n - t,
			next: qv.next
		}, this.context);
	}, e.prototype._doReset = function(e) {
		this._dueIndex = this._outputDueEnd = this._dueEnd = 0, this._settedOutputEnd = null;
		var t, n;
		!e && this._reset && (t = this._reset(this.context), t && t.progress && (n = t.forceFirstProgress, t = t.progress), V(t) && !t.length && (t = null)), this._progress = t, this._modBy = this._modDataCount = null;
		var r = this._downstream;
		return r && r.dirty(), n;
	}, e.prototype.unfinished = function() {
		return this._progress && this._dueIndex < this._dueEnd;
	}, e.prototype.pipe = function(e) {
		(this._downstream !== e || this._dirty) && (this._downstream = e, e._upstream = this, e.dirty());
	}, e.prototype.dispose = function() {
		this._disposed ||= (this._upstream && (this._upstream._downstream = null), this._downstream && (this._downstream._upstream = null), this._dirty = !1, !0);
	}, e.prototype.getUpstream = function() {
		return this._upstream;
	}, e.prototype.getDownstream = function() {
		return this._downstream;
	}, e.prototype.setOutputEnd = function(e) {
		this._outputDueEnd = this._settedOutputEnd = e;
	}, e;
}(), qv = function() {
	var e, t, n, r, i, a = { reset: function(c, l, u, d) {
		t = c, e = l, n = u, r = d, i = Math.ceil(r / n), a.next = n > 1 && r > 0 ? s : o;
	} };
	return a;
	function o() {
		return t < e ? t++ : null;
	}
	function s() {
		var a = t % i * n + Math.ceil(t / i), o = t >= e ? null : a < r ? a : t;
		return t++, o;
	}
}();
//#endregion
//#region node_modules/echarts/lib/data/helper/dataValueHelper.js
function Jv(e, t) {
	var n = t && t.type;
	return n === "ordinal" ? e : (n === "time" && !ue(e) && e != null && e !== "-" && (e = +Bo(e)), e == null || e === "" ? NaN : Number(e));
}
K({
	number: function(e) {
		return parseFloat(e);
	},
	time: function(e) {
		return +Bo(e);
	},
	trim: function(e) {
		return U(e) ? Ce(e) : e;
	}
});
var Yv = {
	lt: function(e, t) {
		return e < t;
	},
	lte: function(e, t) {
		return e <= t;
	},
	gt: function(e, t) {
		return e > t;
	},
	gte: function(e, t) {
		return e >= t;
	}
};
(function() {
	function e(e, t) {
		ue(t) || rs(""), this._opFn = Yv[e], this._rvalFloat = Ko(t);
	}
	return e.prototype.evaluate = function(e) {
		return ue(e) ? this._opFn(e, this._rvalFloat) : this._opFn(Ko(e), this._rvalFloat);
	}, e;
})();
var Xv = function() {
	function e(e, t) {
		var n = e === "desc";
		this._resultLT = n ? 1 : -1, t ??= n ? "min" : "max", this._incomparable = t === "min" ? -Infinity : Infinity;
	}
	return e.prototype.evaluate = function(e, t) {
		var n = ue(e) ? e : Ko(e), r = ue(t) ? t : Ko(t), i = isNaN(n), a = isNaN(r);
		if (i && (n = this._incomparable), a && (r = this._incomparable), i && a) {
			var o = U(e), s = U(t);
			o && (n = s ? e : 0), s && (r = o ? t : 0);
		}
		return n < r ? this._resultLT : n > r ? -this._resultLT : 0;
	}, e;
}();
(function() {
	function e(e, t) {
		this._rval = t, this._isEQ = e, this._rvalTypeof = typeof t, this._rvalFloat = Ko(t);
	}
	return e.prototype.evaluate = function(e) {
		var t = e === this._rval;
		if (!t) {
			var n = typeof e;
			n !== this._rvalTypeof && (n === "number" || this._rvalTypeof === "number") && (t = Ko(e) === this._rvalFloat);
		}
		return this._isEQ ? t : !t;
	}, e;
})();
function Zv(e) {
	var t = "", n = -Infinity, r = -Infinity, i = Infinity, a = Infinity;
	return e && (e.g != null && (t += "G" + e.g, n = e.g), e.ge != null && (t += "GE" + e.ge, r = e.ge), e.l != null && (t += "L" + e.l, i = e.l), e.le != null && (t += "LE" + e.le, a = e.le)), {
		key: t,
		g: n,
		ge: r,
		l: i,
		le: a
	};
}
function Qv(e, t) {
	return t > e.g && t >= e.ge && t < e.l && t <= e.le;
}
//#endregion
//#region node_modules/echarts/lib/data/helper/transform.js
var $v = function() {
	function e() {}
	return e.prototype.getRawData = function() {
		throw Error("not supported");
	}, e.prototype.getRawDataItem = function(e) {
		throw Error("not supported");
	}, e.prototype.cloneRawData = function() {}, e.prototype.getDimensionInfo = function(e) {}, e.prototype.cloneAllDimensionInfo = function() {}, e.prototype.count = function() {}, e.prototype.retrieveValue = function(e, t) {}, e.prototype.retrieveValueFromItem = function(e, t) {}, e.prototype.convertValue = function(e, t) {
		return Jv(e, t);
	}, e;
}();
function ey(e, t) {
	var n = new $v(), r = e.data, i = n.sourceFormat = e.sourceFormat, a = e.startIndex;
	e.seriesLayoutBy !== "column" && rs("");
	var o = [], s = {}, c = e.dimensionsDefine;
	if (c) I(c, function(e, t) {
		var n = e.name, r = {
			index: t,
			name: n,
			displayName: e.displayName
		};
		o.push(r), n != null && (q(s, n) && rs(""), s[n] = r);
	});
	else for (var l = 0; l < e.dimensionsDetectedCount; l++) o.push({ index: l });
	var u = Nv(i, qu);
	t.__isBuiltIn && (n.getRawDataItem = function(e) {
		return u(r, a, o, e);
	}, n.getRawData = z(ty, null, e)), n.cloneRawData = z(ny, null, e), n.count = z(Iv(i, qu), null, r, a, o);
	var d = zv(i);
	n.retrieveValue = function(e, t) {
		return f(u(r, a, o, e), t);
	};
	var f = n.retrieveValueFromItem = function(e, t) {
		if (e != null) {
			var n = o[t];
			if (n) return d(e, t, n.name);
		}
	};
	return n.getDimensionInfo = z(ry, null, o, s), n.cloneAllDimensionInfo = z(iy, null, o), n;
}
function ty(e) {
	var t = e.sourceFormat;
	return ly(t) || rs(""), e.data;
}
function ny(e) {
	var t = e.sourceFormat, n = e.data;
	if (ly(t) || rs(""), t === "arrayRows") {
		for (var r = [], i = 0, a = n.length; i < a; i++) r.push(n[i].slice());
		return r;
	}
	if (t === "objectRows") {
		for (var r = [], i = 0, a = n.length; i < a; i++) r.push(M({}, n[i]));
		return r;
	}
}
function ry(e, t, n) {
	if (n != null) {
		if (ue(n) || !isNaN(n) && !q(t, n)) return e[n];
		if (q(t, n)) return t[n];
	}
}
function iy(e) {
	return A(e);
}
var ay = K();
function oy(e) {
	e = A(e);
	var t = e.type, n = "";
	t || rs(n);
	var r = t.split(":");
	r.length !== 2 && rs(n);
	var i = !1;
	r[0] === "echarts" && (t = r[1], i = !0), e.__isBuiltIn = i, ay.set(t, e);
}
function sy(e, t, n) {
	var r = ss(e), i = r.length;
	i || rs("");
	for (var a = 0, o = i; a < o; a++) {
		var s = r[a];
		t = cy(s, t, n, i === 1 ? null : a), a !== o - 1 && (t.length = Math.max(t.length, 1));
	}
	return t;
}
function cy(e, t, n, r) {
	var i = "";
	t.length || rs(i), W(e) || rs(i);
	var a = e.type, o = ay.get(a);
	o || rs(i);
	var s = L(t, function(e) {
		return ey(e, o);
	});
	return L(ss(o.transform({
		upstream: s[0],
		upstreamList: s,
		config: A(e.config)
	})), function(e, n) {
		var r = "";
		W(e) || rs(r), e.data || rs(r), ly(_v(e.data)) || rs(r);
		var i, a = t[0];
		if (a && n === 0 && !e.dimensions) {
			var o = a.startIndex;
			o && (e.data = a.data.slice(0, o).concat(e.data)), i = {
				seriesLayoutBy: qu,
				sourceHeader: o,
				dimensions: a.metaRawOption.dimensions
			};
		} else i = {
			seriesLayoutBy: qu,
			sourceHeader: 0,
			dimensions: e.dimensions
		};
		return mv(e.data, i, null);
	});
}
function ly(e) {
	return e === "arrayRows" || e === "objectRows";
}
//#endregion
//#region node_modules/echarts/lib/data/DataStore.js
var uy = typeof Uint32Array > "u" ? Array : Uint32Array, dy = typeof Uint16Array > "u" ? Array : Uint16Array, fy = typeof Int32Array > "u" ? Array : Int32Array, py = typeof Float64Array > "u" ? Array : Float64Array, my = {
	float: py,
	int: fy,
	ordinal: Array,
	number: Array,
	time: py
}, hy;
function gy(e) {
	return e > 65535 ? uy : dy;
}
function _y(e) {
	var t = e.constructor;
	return t === Array ? e.slice() : new t(e);
}
function vy(e, t, n, r, i) {
	var a = my[n || "float"];
	if (i) {
		var o = e[t], s = o && o.length;
		if (s !== r) {
			for (var c = new a(r), l = 0; l < s; l++) c[l] = o[l];
			e[t] = c;
		}
	} else e[t] = new a(r);
}
var yy = function() {
	function e() {
		this._chunks = [], this._rawExtent = [], this._extent = [], this._count = 0, this._rawCount = 0, this._calcDimNameToIdx = K();
	}
	return e.prototype.initData = function(e, t, n) {
		this._provider = e, this._chunks = [], this._indices = null, this.getRawIndex = this._getRawIdxIdentity;
		var r = e.getSource(), i = this.defaultDimValueGetter = hy[r.sourceFormat];
		this._dimValueGetter = n || i, this._rawExtent = [], Sv(r), this._dimensions = L(t, function(e) {
			return {
				type: e.type,
				property: e.property
			};
		}), this._initDataFromProvider(0, e.count());
	}, e.prototype.getProvider = function() {
		return this._provider;
	}, e.prototype.getSource = function() {
		return this._provider.getSource();
	}, e.prototype.ensureCalculationDimension = function(e, t) {
		var n = this._calcDimNameToIdx, r = this._dimensions, i = n.get(e);
		if (i != null) {
			if (r[i].type === t) return i;
		} else i = r.length;
		return r[i] = { type: t }, n.set(e, i), this._chunks[i] = new my[t || "float"](this._rawCount), this._rawExtent[i] = zs(), i;
	}, e.prototype.collectOrdinalMeta = function(e, t) {
		var n = this._chunks[e], r = this._dimensions[e], i = this._rawExtent, a = r.ordinalOffset || 0, o = n.length;
		a === 0 && (i[e] = zs());
		for (var s = i[e], c = a; c < o; c++) {
			var l = n[c] = t.parseAndCollect(n[c]);
			isNaN(l) || (s[0] = Math.min(l, s[0]), s[1] = Math.max(l, s[1]));
		}
		r.ordinalMeta = t, r.ordinalOffset = o, r.type = "ordinal";
	}, e.prototype.getOrdinalMeta = function(e) {
		return this._dimensions[e].ordinalMeta;
	}, e.prototype.getDimensionProperty = function(e) {
		var t = this._dimensions[e];
		return t && t.property;
	}, e.prototype.appendData = function(e) {
		var t = this._provider, n = this.count();
		t.appendData(e);
		var r = t.count();
		return t.persistent || (r += n), n < r && this._initDataFromProvider(n, r, !0), [n, r];
	}, e.prototype.appendValues = function(e, t) {
		for (var n = this._chunks, r = this._dimensions, i = r.length, a = this._rawExtent, o = this.count(), s = o + Math.max(e.length, t || 0), c = 0; c < i; c++) {
			var l = r[c];
			vy(n, c, l.type, s, !0);
		}
		for (var u = [], d = o; d < s; d++) for (var f = d - o, p = 0; p < i; p++) {
			var l = r[p], m = hy.arrayRows.call(this, e[f] || u, l.property, f, p);
			n[p][d] = m;
			var h = a[p];
			m < h[0] && (h[0] = m), m > h[1] && (h[1] = m);
		}
		return this._rawCount = this._count = s, {
			start: o,
			end: s
		};
	}, e.prototype._initDataFromProvider = function(e, t, n) {
		for (var r = this._provider, i = this._chunks, a = this._dimensions, o = a.length, s = this._rawExtent, c = L(a, function(e) {
			return e.property;
		}), l = 0; l < o; l++) {
			var u = a[l];
			s[l] || (s[l] = zs()), vy(i, l, u.type, t, n);
		}
		if (r.fillStorage) r.fillStorage(e, t, i, s);
		else for (var d = [], f = e; f < t; f++) {
			d = r.getItem(f, d);
			for (var p = 0; p < o; p++) {
				var m = i[p], h = this._dimValueGetter(d, c[p], f, p);
				m[f] = h;
				var g = s[p];
				h < g[0] && (g[0] = h), h > g[1] && (g[1] = h);
			}
		}
		!r.persistent && r.clean && r.clean(), this._rawCount = this._count = t, this._extent = [];
	}, e.prototype.count = function() {
		return this._count;
	}, e.prototype.get = function(e, t) {
		if (!(t >= 0 && t < this._count)) return NaN;
		var n = this._chunks[e];
		return n ? n[this.getRawIndex(t)] : NaN;
	}, e.prototype.getValues = function(e, t) {
		var n = [], r = [];
		if (t == null) {
			t = e, e = [];
			for (var i = 0; i < this._dimensions.length; i++) r.push(i);
		} else r = e;
		for (var i = 0, a = r.length; i < a; i++) n.push(this.get(r[i], t));
		return n;
	}, e.prototype.getByRawIndex = function(e, t) {
		if (!(t >= 0 && t < this._rawCount)) return NaN;
		var n = this._chunks[e];
		return n ? n[t] : NaN;
	}, e.prototype.getSum = function(e) {
		var t = this._chunks[e], n = 0;
		if (t) for (var r = 0, i = this.count(); r < i; r++) {
			var a = this.get(e, r);
			isNaN(a) || (n += a);
		}
		return n;
	}, e.prototype.getMedian = function(e) {
		var t = [];
		this.each([e], function(e) {
			isNaN(e) || t.push(e);
		}), Oo(t);
		var n = this.count();
		return n === 0 ? 0 : n % 2 == 1 ? t[(n - 1) / 2] : (t[n / 2] + t[n / 2 - 1]) / 2;
	}, e.prototype.indexOfRawIndex = function(e) {
		if (e >= this._rawCount || e < 0) return -1;
		if (!this._indices) return e;
		var t = this._indices, n = t[e];
		if (n != null && n < this._count && n === e) return e;
		for (var r = 0, i = this._count - 1; r <= i;) {
			var a = (r + i) / 2 | 0;
			if (t[a] < e) r = a + 1;
			else if (t[a] > e) i = a - 1;
			else return a;
		}
		return -1;
	}, e.prototype.getIndices = function() {
		var e, t = this._indices;
		if (t) {
			var n = t.constructor, r = this._count;
			if (n === Array) {
				e = new n(r);
				for (var i = 0; i < r; i++) e[i] = t[i];
			} else e = new n(t.buffer, 0, r);
		} else {
			var n = gy(this._rawCount);
			e = new n(this.count());
			for (var i = 0; i < e.length; i++) e[i] = i;
		}
		return e;
	}, e.prototype.filter = function(e, t) {
		if (!this._count) return this;
		for (var n = this.clone(), r = n.count(), i = new (gy(n._rawCount))(r), a = [], o = e.length, s = 0, c = e[0], l = n._chunks, u = 0; u < r; u++) {
			var d = void 0, f = n.getRawIndex(u);
			if (o === 0) d = t(u);
			else if (o === 1) {
				var p = l[c][f];
				d = t(p, u);
			} else {
				for (var m = 0; m < o; m++) a[m] = l[e[m]][f];
				a[m] = u, d = t.apply(null, a);
			}
			d && (i[s++] = f);
		}
		return s < r && (n._indices = i), n._count = s, n._extent = [], n._updateGetRawIdx(), n;
	}, e.prototype.selectRange = function(e) {
		var t = this.clone(), n = t._count;
		if (!n) return this;
		var r = R(e), i = r.length;
		if (!i) return this;
		var a = t.count(), o = new (gy(t._rawCount))(a), s = 0, c = r[0], l = e[c][0], u = e[c][1], d = t._chunks, f = !1;
		if (!t._indices) {
			var p = 0;
			if (i === 1) {
				for (var m = d[r[0]], h = 0; h < n; h++) {
					var g = m[h];
					(g >= l && g <= u || isNaN(g)) && (o[s++] = p), p++;
				}
				f = !0;
			} else if (i === 2) {
				for (var m = d[r[0]], _ = d[r[1]], v = e[r[1]][0], y = e[r[1]][1], h = 0; h < n; h++) {
					var g = m[h], b = _[h];
					(g >= l && g <= u || isNaN(g)) && (b >= v && b <= y || isNaN(b)) && (o[s++] = p), p++;
				}
				f = !0;
			}
		}
		if (!f) {
			if (i === 1) for (var h = 0; h < a; h++) {
				var x = t.getRawIndex(h), g = d[r[0]][x];
				(g >= l && g <= u || isNaN(g)) && (o[s++] = x);
			}
			else for (var h = 0; h < a; h++) {
				for (var S = !0, x = t.getRawIndex(h), C = 0; C < i; C++) {
					var w = r[C], g = d[w][x];
					(g < e[w][0] || g > e[w][1]) && (S = !1);
				}
				S && (o[s++] = t.getRawIndex(h));
			}
		}
		return s < a && (t._indices = o), t._count = s, t._extent = [], t._updateGetRawIdx(), t;
	}, e.prototype.map = function(e, t) {
		var n = this.clone(e);
		return this._updateDims(n, e, t), n;
	}, e.prototype.modify = function(e, t) {
		this._updateDims(this, e, t);
	}, e.prototype._updateDims = function(e, t, n) {
		for (var r = e._chunks, i = [], a = t.length, o = e.count(), s = [], c = e._rawExtent, l = 0; l < t.length; l++) c[t[l]] = zs();
		for (var u = 0; u < o; u++) {
			for (var d = e.getRawIndex(u), f = 0; f < a; f++) s[f] = r[t[f]][d];
			s[a] = u;
			var p = n && n.apply(null, s);
			if (p != null) {
				typeof p != "object" && (i[0] = p, p = i);
				for (var l = 0; l < p.length; l++) {
					var m = t[l], h = p[l], g = c[m], _ = r[m];
					_ && (_[d] = h), h < g[0] && (g[0] = h), h > g[1] && (g[1] = h);
				}
			}
		}
	}, e.prototype.lttbDownSample = function(e, t) {
		var n = this.clone([e], !0), r = n._chunks[e], i = this.count(), a = 0, o = Math.floor(1 / t), s = this.getRawIndex(0), c, l, u, d = new (gy(this._rawCount))(Math.min((Math.ceil(i / o) + 2) * 2, i));
		d[a++] = s;
		for (var f = 1; f < i - 1; f += o) {
			for (var p = Math.min(f + o, i - 1), m = Math.min(f + o * 2, i), h = (m + p) / 2, g = 0, _ = p; _ < m; _++) {
				var v = this.getRawIndex(_), y = r[v];
				isNaN(y) || (g += y);
			}
			g /= m - p;
			var b = f, x = Math.min(f + o, i), S = f - 1, C = r[s];
			c = -1, u = b;
			for (var w = -1, T = 0, _ = b; _ < x; _++) {
				var v = this.getRawIndex(_), y = r[v];
				isNaN(y) ? (T++, w < 0 && (w = v)) : (l = Math.abs((S - h) * (y - C) - (S - _) * (g - C)), l > c && (c = l, u = v));
			}
			T > 0 && T < x - b && (d[a++] = Math.min(w, u), u = Math.max(w, u)), d[a++] = u, s = u;
		}
		return d[a++] = this.getRawIndex(i - 1), n._count = a, n._indices = d, n.getRawIndex = this._getRawIdx, n;
	}, e.prototype.minmaxDownSample = function(e, t) {
		for (var n = this.clone([e], !0), r = n._chunks, i = Math.floor(1 / t), a = r[e], o = this.count(), s = new (gy(this._rawCount))(Math.ceil(o / i) * 2), c = 0, l = 0; l < o; l += i) {
			var u = l, d = a[this.getRawIndex(u)], f = l, p = a[this.getRawIndex(f)], m = i;
			l + i > o && (m = o - l);
			for (var h = 0; h < m; h++) {
				var g = a[this.getRawIndex(l + h)];
				g < d && (d = g, u = l + h), g > p && (p = g, f = l + h);
			}
			var _ = this.getRawIndex(u), v = this.getRawIndex(f);
			u < f ? (s[c++] = _, s[c++] = v) : (s[c++] = v, s[c++] = _);
		}
		return n._count = c, n._indices = s, n._updateGetRawIdx(), n;
	}, e.prototype.downSample = function(e, t, n, r) {
		for (var i = this.clone([e], !0), a = i._chunks, o = [], s = Math.floor(1 / t), c = a[e], l = this.count(), u = i._rawExtent[e] = zs(), d = new (gy(this._rawCount))(Math.ceil(l / s)), f = 0, p = 0; p < l; p += s) {
			s > l - p && (s = l - p, o.length = s);
			for (var m = 0; m < s; m++) {
				var h = this.getRawIndex(p + m);
				o[m] = c[h];
			}
			var g = n(o), _ = this.getRawIndex(Math.min(p + r(o, g) || 0, l - 1));
			c[_] = g, g < u[0] && (u[0] = g), g > u[1] && (u[1] = g), d[f++] = _;
		}
		return i._count = f, i._indices = d, i._updateGetRawIdx(), i;
	}, e.prototype.each = function(e, t) {
		if (this._count) for (var n = e.length, r = this._chunks, i = 0, a = this.count(); i < a; i++) {
			var o = this.getRawIndex(i);
			switch (n) {
				case 0:
					t(i);
					break;
				case 1:
					t(r[e[0]][o], i);
					break;
				case 2:
					t(r[e[0]][o], r[e[1]][o], i);
					break;
				default:
					for (var s = 0, c = []; s < n; s++) c[s] = r[e[s]][o];
					c[s] = i, t.apply(null, c);
			}
		}
	}, e.prototype.getDataExtent = function(e, t) {
		var n = this._chunks[e], r = zs();
		if (!n) return r;
		var i = this.count();
		if (!this._indices && !t) return this._rawExtent[e].slice();
		var a = this._extent, o = a[e] || (a[e] = {}), s = Zv(t), c = s.key, l = o[c];
		if (l) return l.slice();
		for (var u = r[0], d = r[1], f = 0; f < i; f++) {
			var p = n[this.getRawIndex(f)];
			(!t || Qv(s, p)) && (p < u && (u = p), p > d && (d = p));
		}
		return o[c] = [u, d];
	}, e.prototype.getRawDataItem = function(e) {
		var t = this.getRawIndex(e);
		if (this._provider.persistent) return this._provider.getItem(t);
		for (var n = [], r = this._chunks, i = 0; i < r.length; i++) n.push(r[i][t]);
		return n;
	}, e.prototype.clone = function(t, n) {
		var r = new e(), i = this._chunks, a = t && ae(t, function(e, t) {
			return e[t] = !0, e;
		}, {});
		if (a) for (var o = 0; o < i.length; o++) r._chunks[o] = a[o] ? _y(i[o]) : i[o];
		else r._chunks = i;
		return this._copyCommonProps(r), n || (r._indices = this._cloneIndices()), r._updateGetRawIdx(), r;
	}, e.prototype._copyCommonProps = function(e) {
		e._count = this._count, e._rawCount = this._rawCount, e._provider = this._provider, e._dimensions = this._dimensions, e._extent = A(this._extent), e._rawExtent = A(this._rawExtent);
	}, e.prototype._cloneIndices = function() {
		if (this._indices) {
			var e = this._indices.constructor, t = void 0;
			if (e === Array) {
				var n = this._indices.length;
				t = new e(n);
				for (var r = 0; r < n; r++) t[r] = this._indices[r];
			} else t = new e(this._indices);
			return t;
		}
		return null;
	}, e.prototype._getRawIdxIdentity = function(e) {
		return e;
	}, e.prototype._getRawIdx = function(e) {
		return e < this._count && e >= 0 ? this._indices[e] : -1;
	}, e.prototype._updateGetRawIdx = function() {
		this.getRawIndex = this._indices ? this._getRawIdx : this._getRawIdxIdentity;
	}, e.internalField = function() {
		function e(e, t, n, r) {
			return Jv(e[r], this._dimensions[r]);
		}
		hy = {
			arrayRows: e,
			objectRows: function(e, t, n, r) {
				return Jv(e[t], this._dimensions[r]);
			},
			keyedColumns: e,
			original: function(e, t, n, r) {
				var i = e && (e.value == null ? e : e.value);
				return Jv(i instanceof Array ? i[r] : i, this._dimensions[r]);
			},
			typedArray: function(e, t, n, r) {
				return e[r];
			}
		};
	}(), e;
}(), by = function() {
	function e(e) {
		this._sourceList = [], this._storeList = [], this._upstreamSignList = [], this._versionSignBase = 0, this._dirty = !0, this._sourceHost = e;
	}
	return e.prototype.dirty = function() {
		this._setLocalSource([], []), this._storeList = [], this._dirty = !0;
	}, e.prototype._setLocalSource = function(e, t) {
		this._sourceList = e, this._upstreamSignList = t, this._versionSignBase++, this._versionSignBase > 9e10 && (this._versionSignBase = 0);
	}, e.prototype._getVersionSign = function() {
		return this._sourceHost.uid + "_" + this._versionSignBase;
	}, e.prototype.prepareSource = function() {
		this._isDirty() && (this._createSource(), this._dirty = !1);
	}, e.prototype._createSource = function() {
		this._setLocalSource([], []);
		var e = this._sourceHost, t = this._getUpstreamSourceManagers(), n = !!t.length, r, i;
		if (xy(e)) {
			var a = e, o = void 0, s = void 0, c = void 0;
			if (n) {
				var l = t[0];
				l.prepareSource(), c = l.getSource(), o = c.data, s = c.sourceFormat, i = [l._getVersionSign()];
			} else o = a.get("data", !0), s = fe(o) ? Gu : Vu, i = [];
			var u = this._getSourceMetaRawOption() || {}, d = c && c.metaRawOption || {}, f = G(u.seriesLayoutBy, d.seriesLayoutBy) || null, p = G(u.sourceHeader, d.sourceHeader), m = G(u.dimensions, d.dimensions);
			r = f !== d.seriesLayoutBy || !!p != !!d.sourceHeader || m ? [mv(o, {
				seriesLayoutBy: f,
				sourceHeader: p,
				dimensions: m
			}, s)] : [];
		} else {
			var h = e;
			if (n) {
				var g = this._applyTransform(t);
				r = g.sourceList, i = g.upstreamSignList;
			} else r = [mv(h.get("source", !0), this._getSourceMetaRawOption(), null)], i = [];
		}
		this._setLocalSource(r, i);
	}, e.prototype._applyTransform = function(e) {
		var t = this._sourceHost, n = t.get("transform", !0), r = t.get("fromTransformResult", !0);
		r != null && e.length !== 1 && Sy("");
		var i, a = [], o = [];
		return I(e, function(e) {
			e.prepareSource();
			var t = e.getSource(r || 0);
			r != null && !t && Sy(""), a.push(t), o.push(e._getVersionSign());
		}), n ? i = sy(n, a, { datasetIndex: t.componentIndex }) : r != null && (i = [gv(a[0])]), {
			sourceList: i,
			upstreamSignList: o
		};
	}, e.prototype._isDirty = function() {
		if (this._dirty) return !0;
		for (var e = this._getUpstreamSourceManagers(), t = 0; t < e.length; t++) {
			var n = e[t];
			if (n._isDirty() || this._upstreamSignList[t] !== n._getVersionSign()) return !0;
		}
	}, e.prototype.getSource = function(e) {
		e ||= 0;
		var t = this._sourceList[e];
		if (!t) {
			var n = this._getUpstreamSourceManagers();
			return n[0] && n[0].getSource(e);
		}
		return t;
	}, e.prototype.getSharedDataStore = function(e) {
		var t = e.makeStoreSchema();
		return this._innerGetDataStore(t.dimensions, e.source, t.hash);
	}, e.prototype._innerGetDataStore = function(e, t, n) {
		var r = 0, i = this._storeList, a = i[r];
		a ||= i[r] = {};
		var o = a[n];
		if (!o) {
			var s = this._getUpstreamSourceManagers()[0];
			xy(this._sourceHost) && s ? o = s._innerGetDataStore(e, t, n) : (o = new yy(), o.initData(new kv(t, e.length), e)), a[n] = o;
		}
		return o;
	}, e.prototype._getUpstreamSourceManagers = function() {
		var e = this._sourceHost;
		if (xy(e)) {
			var t = l_(e);
			return t ? [t.getSourceManager()] : [];
		}
		return L(u_(e), function(e) {
			return e.getSourceManager();
		});
	}, e.prototype._getSourceMetaRawOption = function() {
		var e = this._sourceHost, t, n, r;
		if (xy(e)) t = e.get("seriesLayoutBy", !0), n = e.get("sourceHeader", !0), r = e.get("dimensions", !0);
		else if (!this._getUpstreamSourceManagers().length) {
			var i = e;
			t = i.get("seriesLayoutBy", !0), n = i.get("sourceHeader", !0), r = i.get("dimensions", !0);
		}
		return {
			seriesLayoutBy: t,
			sourceHeader: n,
			dimensions: r
		};
	}, e;
}();
function xy(e) {
	return e.mainType === "series";
}
function Sy(e) {
	throw Error(e);
}
//#endregion
//#region node_modules/echarts/lib/component/tooltip/tooltipMarkup.js
var Cy = "line-height:1";
function wy(e) {
	var t = e.lineHeight;
	return t == null ? Cy : "line-height:" + Tt(t + "") + "px";
}
function Ty(e, t) {
	var n = e.color || Q.color.tertiary, r = e.fontSize || 12, i = e.fontWeight || "400", a = e.color || Q.color.secondary, o = e.fontSize || 14, s = e.fontWeight || "900";
	return t === "html" ? {
		nameStyle: "font-size:" + Tt(r + "") + "px;color:" + Tt(n) + ";font-weight:" + Tt(i + ""),
		valueStyle: "font-size:" + Tt(o + "") + "px;color:" + Tt(a) + ";font-weight:" + Tt(s + "")
	} : {
		nameStyle: {
			fontSize: r,
			fill: n,
			fontWeight: i
		},
		valueStyle: {
			fontSize: o,
			fill: a,
			fontWeight: s
		}
	};
}
var Ey = [
	0,
	10,
	20,
	30
], Dy = [
	"",
	"\n",
	"\n\n",
	"\n\n\n"
];
function Oy(e, t) {
	return t.type = e, t;
}
function ky(e) {
	return e.type === "section";
}
function Ay(e) {
	return ky(e) ? My : Ny;
}
function jy(e) {
	if (ky(e)) {
		var t = 0, n = e.blocks.length, r = n > 1 || n > 0 && !e.noHeader;
		return I(e.blocks, function(e) {
			var n = jy(e);
			n >= t && (t = n + +(r && (!n || ky(e) && !e.noHeader)));
		}), t;
	}
	return 0;
}
function My(e, t, n, r) {
	var i = t.noHeader, a = Fy(jy(t)), o = [], s = t.blocks || [];
	Se(!s || V(s)), s ||= [];
	var c = e.orderMode;
	if (t.sortBlocks && c) {
		s = s.slice();
		var l = {
			valueAsc: "asc",
			valueDesc: "desc"
		};
		if (q(l, c)) {
			var u = new Xv(l[c], null);
			s.sort(function(e, t) {
				return u.evaluate(e.sortParam, t.sortParam);
			});
		} else c === "seriesDesc" && s.reverse();
	}
	I(s, function(n, i) {
		var s = t.valueFormatter, c = Ay(n)(s ? M(M({}, e), { valueFormatter: s }) : e, n, i > 0 ? a.html : 0, r);
		c != null && o.push(c);
	});
	var d = e.renderMode === "richText" ? o.join(a.richText) : Iy(r, o.join(""), i ? n : a.html);
	if (i) return d;
	var f = pg(t.header, "ordinal", e.useUTC), p = Ty(r, e.renderMode).nameStyle, m = wy(r);
	return e.renderMode === "richText" ? zy(e, f, p) + a.richText + d : Iy(r, "<div style=\"" + p + ";" + m + ";\">" + Tt(f) + "</div>" + d, n);
}
function Ny(e, t, n, r) {
	var i = e.renderMode, a = t.noName, o = t.noValue, s = !t.markerType, c = t.name, l = e.useUTC, u = t.valueFormatter || e.valueFormatter || function(e) {
		return e = V(e) ? e : [e], L(e, function(e, t) {
			return pg(e, V(p) ? p[t] : p, l);
		});
	};
	if (!(a && o)) {
		var d = s ? "" : e.markupStyleCreator.makeTooltipMarker(t.markerType, t.markerColor || Q.color.secondary, i), f = a ? "" : pg(c, "ordinal", l), p = t.valueType, m = o ? [] : u(t.value, t.rawDataIndex), h = !s || !a, g = !s && a, _ = Ty(r, i), v = _.nameStyle, y = _.valueStyle;
		return i === "richText" ? (s ? "" : d) + (a ? "" : zy(e, f, v)) + (o ? "" : By(e, m, h, g, y)) : Iy(r, (s ? "" : d) + (a ? "" : Ly(f, !s, v)) + (o ? "" : Ry(m, h, g, y)), n);
	}
}
function Py(e, t, n, r, i, a) {
	if (e) return Ay(e)({
		useUTC: i,
		renderMode: n,
		orderMode: r,
		markupStyleCreator: t,
		valueFormatter: e.valueFormatter
	}, e, 0, a);
}
function Fy(e) {
	return {
		html: Ey[e],
		richText: Dy[e]
	};
}
function Iy(e, t, n) {
	var r = "<div style=\"clear:both\"></div>", i = "margin: " + n + "px 0 0", a = wy(e);
	return "<div style=\"" + i + ";" + a + ";\">" + t + r + "</div>";
}
function Ly(e, t, n) {
	var r = t ? "margin-left:2px" : "";
	return "<span style=\"" + n + ";" + r + "\">" + Tt(e) + "</span>";
}
function Ry(e, t, n, r) {
	var i = t ? "float:right;margin-left:" + (n ? "10px" : "20px") : "";
	return e = V(e) ? e : [e], "<span style=\"" + i + ";" + r + "\">" + L(e, function(e) {
		return Tt(e);
	}).join("&nbsp;&nbsp;") + "</span>";
}
function zy(e, t, n) {
	return e.markupStyleCreator.wrapRichTextStyle(t, n);
}
function By(e, t, n, r, i) {
	var a = [i], o = r ? 10 : 20;
	return n && a.push({
		padding: [
			0,
			0,
			0,
			o
		],
		align: "right"
	}), e.markupStyleCreator.wrapRichTextStyle(V(t) ? t.join("  ") : t, a);
}
function Vy(e, t) {
	var n = e.getData().getItemVisual(t, "style")[e.visualDrawType];
	return bg(n);
}
function Hy(e, t) {
	return e.get("padding") ?? (t === "richText" ? [8, 10] : 10);
}
var Uy = function() {
	function e() {
		this.richTextStyles = {}, this._nextStyleNameId = Jo();
	}
	return e.prototype._generateStyleName = function() {
		return "__EC_aUTo_" + this._nextStyleNameId++;
	}, e.prototype.makeTooltipMarker = function(e, t, n) {
		var r = n === "richText" ? this._generateStyleName() : null, i = _g({
			color: t,
			type: e,
			renderMode: n,
			markerId: r
		});
		return U(i) ? i : (this.richTextStyles[r] = i.style, i.content);
	}, e.prototype.wrapRichTextStyle = function(e, t) {
		var n = {};
		V(t) ? I(t, function(e) {
			return M(n, e);
		}) : M(n, t);
		var r = this._generateStyleName();
		return this.richTextStyles[r] = n, "{" + r + "|" + e + "}";
	}, e;
}();
//#endregion
//#region node_modules/echarts/lib/component/tooltip/seriesFormatTooltip.js
function Wy(e) {
	var t = e.series, n = e.dataIndex, r = e.multipleSeries, i = t.getData(), a = i.mapDimensionsAll("defaultedTooltip"), o = a.length, s = t.getRawValue(n), c = V(s), l = Vy(t, n), u, d, f, p;
	if (o > 1 || c && !o) {
		var m = Gy(s, t, n, a, l);
		u = m.inlineValues, d = m.inlineValueTypes, f = m.blocks, p = m.inlineValues[0];
	} else if (o) {
		var h = i.getDimensionInfo(a[0]);
		p = u = Vv(i, n, a[0]), d = h.type;
	} else p = u = c ? s[0] : s;
	var g = Ss(t), _ = g && t.name || "", v = i.getName(n), y = r ? _ : v;
	return Oy("section", {
		header: _,
		noHeader: r || !g,
		sortParam: p,
		blocks: [Oy("nameValue", {
			markerType: "item",
			markerColor: l,
			name: y,
			noName: !Ce(y),
			value: u,
			valueType: d,
			rawDataIndex: i.getRawIndex(n)
		})].concat(f || [])
	});
}
function Gy(e, t, n, r, i) {
	var a = t.getData(), o = ae(e, function(e, t, n) {
		var r = a.getDimensionInfo(n);
		return e ||= r && r.tooltip !== !1 && r.displayName != null;
	}, !1), s = [], c = [], l = [];
	r.length ? I(r, function(e) {
		u(Vv(a, n, e), e);
	}) : I(e, u);
	function u(e, t) {
		var n = a.getDimensionInfo(t);
		n && n.otherDims.tooltip !== !1 && (o ? l.push(Oy("nameValue", {
			markerType: "subItem",
			markerColor: i,
			name: n.displayName,
			value: e,
			valueType: n.type
		})) : (s.push(e), c.push(n.type)));
	}
	return {
		inlineValues: s,
		inlineValueTypes: c,
		blocks: l
	};
}
//#endregion
//#region node_modules/echarts/lib/model/Series.js
var Ky = X();
function qy(e, t) {
	return e.getName(t) || e.getId(t);
}
var Jy = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t._selectedDataIndicesMap = {}, t;
	}
	return t.prototype.init = function(e, t, n) {
		this.seriesIndex = this.componentIndex, this.dataTask = Gv({
			count: Zy,
			reset: Qy
		}), this.dataTask.context = { model: this }, this.mergeDefaultAndTheme(e, n), (Ky(this).sourceManager = new by(this)).prepareSource();
		var r = this.getInitialData(e, n);
		eb(r, this), this.dataTask.context.data = r, Ky(this).dataBeforeProcessed = r, Yy(this), this._initSelectedMapFromData(r);
	}, t.prototype.mergeDefaultAndTheme = function(e, t) {
		var n = Ug(this), r = n ? Gg(e) : {}, i = this.subType;
		Jg.hasClass(i) && (i += "Series"), j(e, t.getTheme().get(this.subType)), j(e, this.getDefaultOption()), cs(e, "label", ["show"]), this.fillDataTextStyle(e.data), n && Wg(e, r, n);
	}, t.prototype.mergeOption = function(e, t) {
		e = j(this.option, e, !0), this.fillDataTextStyle(e.data);
		var n = Ug(this);
		n && Wg(this.option, e, n);
		var r = Ky(this).sourceManager;
		r.dirty(), r.prepareSource();
		var i = this.getInitialData(e, t);
		eb(i, this), this.dataTask.dirty(), this.dataTask.context.data = i, Ky(this).dataBeforeProcessed = i, Yy(this), this._initSelectedMapFromData(i);
	}, t.prototype.fillDataTextStyle = function(e) {
		if (e && !fe(e)) for (var t = ["show"], n = 0; n < e.length; n++) e[n] && e[n].label && cs(e[n], "label", t);
	}, t.prototype.getInitialData = function(e, t) {}, t.prototype.appendData = function(e) {
		this.getRawData().appendData(e.data);
	}, t.prototype.getData = function(e) {
		var t = nb(this);
		if (t) {
			var n = t.context.data;
			return e == null || !n.getLinkedData ? n : n.getLinkedData(e);
		}
		return Ky(this).data;
	}, t.prototype.getAllData = function() {
		var e = this.getData();
		return e && e.getLinkedDataAll ? e.getLinkedDataAll() : [{ data: e }];
	}, t.prototype.setData = function(e) {
		var t = nb(this);
		if (t) {
			var n = t.context;
			n.outputData = e, t !== this.dataTask && (n.data = e);
		}
		Ky(this).data = e;
	}, t.prototype.getEncode = function() {
		var e = this.get("encode", !0);
		if (e) return K(e);
	}, t.prototype.getSourceManager = function() {
		return Ky(this).sourceManager;
	}, t.prototype.getSource = function() {
		return this.getSourceManager().getSource();
	}, t.prototype.getRawData = function() {
		return Ky(this).dataBeforeProcessed;
	}, t.prototype.getColorBy = function() {
		return this.get("colorBy") || "series";
	}, t.prototype.isColorBySeries = function() {
		return this.getColorBy() === "series";
	}, t.prototype.getBaseAxis = function() {
		var e = this.coordinateSystem;
		return e && e.getBaseAxis && e.getBaseAxis();
	}, t.prototype.indicesOfNearest = function(e, t, n, r) {
		var i = this.getData(), a = this.coordinateSystem, o = a && a.getAxis(e);
		if (!a || !o) return [];
		var s = o.dataToCoord(n);
		r ??= Infinity;
		for (var c = [], l = Infinity, u = -1, d = 0, f = i.getDimensionIndex(t), p = i.getStore(), m = 0, h = p.count(); m < h; m++) {
			var g = p.get(f, m), _ = s - o.dataToCoord(g), v = Math.abs(_);
			v <= r && ((v < l || v === l && _ >= 0 && u < 0) && (l = v, u = _, d = 0), _ === u && (c[d++] = m));
		}
		return c.length = d, c;
	}, t.prototype.formatTooltip = function(e, t, n) {
		return Wy({
			series: this,
			dataIndex: e,
			multipleSeries: t
		});
	}, t.prototype.isAnimationEnabled = function() {
		var e = this.ecModel;
		if (i.node && !(e && e.ssr)) return !1;
		var t = this.getShallow("animation");
		return t && this.getData().count() > this.getShallow("animationThreshold") && (t = !1), !!t;
	}, t.prototype.restoreData = function() {
		this.dataTask.dirty();
	}, t.prototype.getColorFromPalette = function(e, t, n) {
		var r = this.ecModel, i = __.prototype.getColorFromPalette.call(this, e, t, n);
		return i ||= r.getColorFromPalette(e, t, n), i;
	}, t.prototype.coordDimToDataDim = function(e) {
		return this.getRawData().mapDimensionsAll(e);
	}, t.prototype.getProgressive = function() {
		return this.get("progressive");
	}, t.prototype.getProgressiveThreshold = function() {
		return this.get("progressiveThreshold");
	}, t.prototype.select = function(e, t) {
		this._innerSelect(this.getData(t), e);
	}, t.prototype.unselect = function(e, t) {
		var n = this.option.selectedMap;
		if (n) {
			var r = this.option.selectedMode, i = this.getData(t);
			if (r === "series" || n === "all") this.option.selectedMap = {}, this._selectedDataIndicesMap = {};
			else for (var a = 0; a < e.length; a++) {
				var o = e[a], s = qy(i, o);
				n[s] = !1, this._selectedDataIndicesMap[s] = -1;
			}
		}
	}, t.prototype.toggleSelect = function(e, t) {
		for (var n = [], r = 0; r < e.length; r++) n[0] = e[r], this.isSelected(e[r], t) ? this.unselect(n, t) : this.select(n, t);
	}, t.prototype.getSelectedDataIndices = function() {
		if (this.option.selectedMap === "all") return [].slice.call(this.getData().getIndices());
		for (var e = this._selectedDataIndicesMap, t = R(e), n = [], r = 0; r < t.length; r++) {
			var i = e[t[r]];
			i >= 0 && n.push(i);
		}
		return n;
	}, t.prototype.isSelected = function(e, t) {
		var n = this.option.selectedMap;
		if (!n) return !1;
		var r = this.getData(t);
		return (n === "all" || n[qy(r, e)]) && !r.getItemModel(e).get(["select", "disabled"]);
	}, t.prototype.isUniversalTransitionEnabled = function() {
		if (this.__universalTransitionEnabled) return !0;
		var e = this.option.universalTransition;
		return e ? e === !0 || e && e.enabled : !1;
	}, t.prototype._innerSelect = function(e, t) {
		var n, r, i = this.option, a = i.selectedMode, o = t.length;
		if (a && o) {
			if (a === "series") i.selectedMap = "all";
			else if (a === "multiple") {
				W(i.selectedMap) || (i.selectedMap = {});
				for (var s = i.selectedMap, c = 0; c < o; c++) {
					var l = t[c], u = qy(e, l);
					s[u] = !0, this._selectedDataIndicesMap[u] = e.getRawIndex(l);
				}
			} else if (a === "single" || a === !0) {
				var d = t[o - 1], u = qy(e, d);
				i.selectedMap = (n = {}, n[u] = !0, n), this._selectedDataIndicesMap = (r = {}, r[u] = e.getRawIndex(d), r);
			}
		}
	}, t.prototype._initSelectedMapFromData = function(e) {
		if (!this.option.selectedMap) {
			var t = [];
			e.hasItemOption && e.each(function(n) {
				var r = e.getRawDataItem(n);
				r && r.selected && t.push(n);
			}), t.length > 0 && this._innerSelect(e, t);
		}
	}, t.registerClass = function(e) {
		return Jg.registerClass(e);
	}, t.protoInitialize = function() {
		var e = t.prototype;
		e.type = "series.__base__", e.seriesIndex = 0, e.ignoreStyleOnData = !1, e.hasSymbolVisual = !1, e.defaultSymbol = "circle", e.visualStyleAccessPath = "itemStyle", e.visualDrawType = "fill";
	}(), t;
}(Jg);
F(Jy, Uv), F(Jy, __), dc(Jy, Jg);
function Yy(e) {
	var t = e.name;
	Ss(e) || (e.name = Xy(e) || t);
}
function Xy(e) {
	var t = e.getRawData(), n = t.mapDimensionsAll("seriesName"), r = [];
	return I(n, function(e) {
		var n = t.getDimensionInfo(e);
		n.displayName && r.push(n.displayName);
	}), r.join(" ");
}
function Zy(e) {
	return e.model.getRawData().count();
}
function Qy(e) {
	var t = e.model;
	return t.setData(t.getRawData().cloneShallow()), $y;
}
function $y(e, t) {
	t.outputData && e.end > t.outputData.count() && t.model.getRawData().cloneShallow(t.outputData);
}
function eb(e, t) {
	I(je(e.CHANGABLE_METHODS, e.DOWNSAMPLE_METHODS), function(n) {
		e.wrapMethod(n, B(tb, t));
	});
}
function tb(e, t) {
	var n = nb(e);
	return n && n.setOutputEnd((t || this).count()), t;
}
function nb(e) {
	var t = (e.ecModel || {}).scheduler, n = t && t.getPipeline(e.uid);
	if (n) {
		var r = n.currentTask;
		if (r) {
			var i = r.agentStubMap;
			i && (r = i.get(e.uid));
		}
		return r;
	}
}
//#endregion
//#region node_modules/echarts/lib/view/Component.js
var rb = function() {
	function e() {
		this.group = new Wa(), this.uid = oh("viewComponent");
	}
	return e.prototype.init = function(e, t) {}, e.prototype.render = function(e, t, n, r) {}, e.prototype.dispose = function(e, t) {}, e.prototype.updateView = function(e, t, n, r) {}, e.prototype.updateLayout = function(e, t, n, r) {}, e.prototype.updateVisual = function(e, t, n, r) {}, e.prototype.toggleBlurSeries = function(e, t, n) {}, e.prototype.eachRendered = function(e) {
		var t = this.group;
		t && t.traverse(e);
	}, e;
}();
lc(rb), gc(rb);
//#endregion
//#region node_modules/echarts/lib/chart/helper/createRenderPlanner.js
function ib() {
	var e = X();
	return function(t) {
		var n = e(t), r = t.pipelineContext, i = !!n.large, a = !!n.progressiveRender, o = n.large = !!(r && r.large), s = n.progressiveRender = !!(r && r.progressiveRender);
		return (i !== o || a !== s) && "reset";
	};
}
//#endregion
//#region node_modules/echarts/lib/view/Chart.js
var ab = X(), ob = ib(), sb = function() {
	function e() {
		this.group = new Wa(), this.uid = oh("viewChart"), this.renderTask = Gv({
			plan: ub,
			reset: db
		}), this.renderTask.context = { view: this };
	}
	return e.prototype.init = function(e, t) {}, e.prototype.render = function(e, t, n, r) {}, e.prototype.highlight = function(e, t, n, r) {
		var i = e.getData(r && r.dataType);
		i && lb(i, r, "emphasis");
	}, e.prototype.downplay = function(e, t, n, r) {
		var i = e.getData(r && r.dataType);
		i && lb(i, r, "normal");
	}, e.prototype.remove = function(e, t) {
		this.group.removeAll();
	}, e.prototype.dispose = function(e, t) {}, e.prototype.updateView = function(e, t, n, r) {
		this.render(e, t, n, r);
	}, e.prototype.updateVisual = function(e, t, n, r) {
		this.render(e, t, n, r);
	}, e.prototype.eachRendered = function(e) {
		_m(this.group, e);
	}, e.markUpdateMethod = function(e, t) {
		ab(e).updateMethod = t;
	}, e.protoInitialize = function() {
		var t = e.prototype;
		t.type = "chart";
	}(), e;
}();
function cb(e, t, n) {
	e && $d(e) && (t === "emphasis" ? Od : kd)(e, n);
}
function lb(e, t, n) {
	var r = Ds(e, t), i = t && t.highlightKey != null ? ef(t.highlightKey) : null;
	r == null ? e.eachItemGraphicEl(function(e) {
		cb(e, n, i);
	}) : I(ss(r), function(t) {
		cb(e.getItemGraphicEl(t), n, i);
	});
}
lc(sb, ["dispose"]), gc(sb);
function ub(e) {
	return ob(e.model);
}
function db(e) {
	var t = e.model, n = e.ecModel, r = e.api, i = e.payload, a = t.pipelineContext.progressiveRender, o = e.view, s = i && ab(i).updateMethod, c = a ? "incrementalPrepareRender" : s && o[s] ? s : "render";
	return c !== "render" && o[c](t, n, r, i), fb[c];
}
var fb = {
	incrementalPrepareRender: { progress: function(e, t) {
		t.view.incrementalRender(e, t.model, t.ecModel, t.api, t.payload);
	} },
	render: {
		forceFirstProgress: !0,
		progress: function(e, t) {
			t.view.render(t.model, t.ecModel, t.api, t.payload);
		}
	}
}, pb = "\0__throttleOriginMethod", mb = "\0__throttleRate", hb = "\0__throttleType";
function gb(e, t, n) {
	var r, i = 0, a = 0, o = null, s, c, l, u;
	t ||= 0;
	function d() {
		a = (/* @__PURE__ */ new Date()).getTime(), o = null, e.apply(c, l || []);
	}
	var f = function() {
		var e = [...arguments];
		r = (/* @__PURE__ */ new Date()).getTime(), c = this, l = e;
		var f = u || t, p = u || n;
		u = null, s = r - (p ? i : a) - f, clearTimeout(o), p ? o = setTimeout(d, f) : s >= 0 ? d() : o = setTimeout(d, -s), i = r;
	};
	return f.clear = function() {
		o &&= (clearTimeout(o), null);
	}, f.debounceNextCall = function(e) {
		u = e;
	}, f;
}
function _b(e, t, n, r) {
	var i = e[t];
	if (i) {
		var a = i[pb] || i, o = i[hb];
		if (i[mb] !== n || o !== r) {
			if (n == null || !r) return e[t] = a;
			i = e[t] = gb(a, n, r === "debounce"), i[pb] = a, i[hb] = r, i[mb] = n;
		}
		return i;
	}
}
function vb(e, t) {
	var n = e[t];
	n && n[pb] && (n.clear && n.clear(), e[t] = n[pb]);
}
//#endregion
//#region node_modules/echarts/lib/visual/style.js
var yb = X(), bb = {
	itemStyle: _c(th, !0),
	lineStyle: _c(Qm, !0)
}, xb = {
	lineStyle: "stroke",
	itemStyle: "fill"
};
function Sb(e, t) {
	return e.visualStyleMapper || bb[t] || (console.warn("Unknown style type '" + t + "'."), bb.itemStyle);
}
function Cb(e, t) {
	return e.visualDrawType || xb[t] || (console.warn("Unknown style type '" + t + "'."), "fill");
}
var wb = {
	createOnAllSeries: !0,
	performRawSeries: !0,
	reset: function(e, t) {
		var n = e.getData(), r = e.visualStyleAccessPath || "itemStyle", i = e.getModel(r), a = Sb(e, r)(i), o = i.getShallow("decal");
		o && (n.setVisual("decal", o), o.dirty = !0);
		var s = Cb(e, r), c = a[s], l = H(c) ? c : null, u = a.fill === "auto" || a.stroke === "auto";
		if (!a[s] || l || u) {
			var d = e.getColorFromPalette(e.name, null, t.getSeriesCount());
			a[s] || (a[s] = d, n.setVisual("colorFromPalette", !0)), a.fill = a.fill === "auto" || H(a.fill) ? d : a.fill, a.stroke = a.stroke === "auto" || H(a.stroke) ? d : a.stroke;
		}
		if (n.setVisual("style", a), n.setVisual("drawType", s), !t.isSeriesFiltered(e) && l) return n.setVisual("colorFromPalette", !1), { dataEach: function(t, n) {
			var r = e.getDataParams(n), i = M({}, a);
			i[s] = l(r), t.setItemVisual(n, "style", i);
		} };
	}
}, Tb = new ih(), Eb = {
	createOnAllSeries: !0,
	reset: function(e, t) {
		if (!e.ignoreStyleOnData) {
			var n = e.getData(), r = e.visualStyleAccessPath || "itemStyle", i = Sb(e, r), a = n.getVisual("drawType");
			return { dataEach: n.hasItemOption ? function(e, t) {
				var n = e.getRawDataItem(t);
				if (n && n[r]) {
					Tb.option = n[r];
					var o = i(Tb);
					M(e.ensureUniqueItemVisual(t, "style"), o), Tb.option.decal && (e.setItemVisual(t, "decal", Tb.option.decal), Tb.option.decal.dirty = !0), a in o && e.setItemVisual(t, "colorFromPalette", !1);
				}
			} : null };
		}
	}
}, Db = {
	performRawSeries: !0,
	overallReset: function(e) {
		var t = K();
		e.eachSeries(function(e) {
			if (!e.isColorBySeries()) {
				var n = e.type + "-" + e.getColorBy();
				yb(e).scope = t.get(n) || t.set(n, {});
			}
		}), e.eachSeries(function(e) {
			if (!e.isColorBySeries()) {
				var t = e.getRawData(), n = {}, r = e.getData(), i = yb(e).scope, a = Cb(e, e.visualStyleAccessPath || "itemStyle");
				r.each(function(e) {
					var t = r.getRawIndex(e);
					n[t] = e;
				}), t.each(function(o) {
					var s = n[o];
					if (r.getItemVisual(s, "colorFromPalette")) {
						var c = r.ensureUniqueItemVisual(s, "style"), l = t.getName(o) || o + "", u = t.count();
						c[a] = e.getColorFromPalette(l, i, u);
					}
				});
			}
		});
	}
}, Ob = Math.PI;
function kb(e, t) {
	t ||= {}, N(t, {
		text: "loading",
		textColor: Q.color.primary,
		fontSize: 12,
		fontWeight: "normal",
		fontStyle: "normal",
		fontFamily: "sans-serif",
		maskColor: "rgba(255,255,255,0.8)",
		showSpinner: !0,
		color: Q.color.theme[0],
		spinnerRadius: 10,
		lineWidth: 5,
		zlevel: 0
	});
	var n = new Wa(), r = new bu({
		style: { fill: t.maskColor },
		zlevel: t.zlevel,
		z: 1e4
	});
	n.add(r);
	var i = new Tu({
		style: {
			text: t.text,
			fill: t.textColor,
			fontSize: t.fontSize,
			fontWeight: t.fontWeight,
			fontStyle: t.fontStyle,
			fontFamily: t.fontFamily
		},
		zlevel: t.zlevel,
		z: 10001
	}), a = new bu({
		style: { fill: "none" },
		textContent: i,
		textConfig: {
			position: "right",
			distance: 10
		},
		zlevel: t.zlevel,
		z: 10001
	});
	n.add(a);
	var o;
	return t.showSpinner && (o = new up({
		shape: {
			startAngle: -Ob / 2,
			endAngle: -Ob / 2 + .1,
			r: t.spinnerRadius
		},
		style: {
			stroke: t.color,
			lineCap: "round",
			lineWidth: t.lineWidth
		},
		zlevel: t.zlevel,
		z: 10001
	}), o.animateShape(!0).when(1e3, { endAngle: Ob * 3 / 2 }).start("circularInOut"), o.animateShape(!0).when(1e3, { startAngle: Ob * 3 / 2 }).delay(300).start("circularInOut"), n.add(o)), n.resize = function() {
		var n = i.getBoundingRect().width, s = t.showSpinner ? t.spinnerRadius : 0, c = (e.getWidth() - s * 2 - (t.showSpinner && n ? 10 : 0) - n) / 2 - (t.showSpinner && n ? 0 : 5 + n / 2) + (t.showSpinner ? 0 : n / 2) + (n ? 0 : s), l = e.getHeight() / 2;
		t.showSpinner && o.setShape({
			cx: c,
			cy: l
		}), a.setShape({
			x: c - s,
			y: l - s,
			width: s * 2,
			height: s * 2
		}), r.setShape({
			x: 0,
			y: 0,
			width: e.getWidth(),
			height: e.getHeight()
		});
	}, n.resize(), n;
}
//#endregion
//#region node_modules/echarts/lib/core/Scheduler.js
var Ab = function() {
	function e(e, t, n, r) {
		this._stageTaskMap = K(), this.ecInstance = e, this.api = t, n = this._dataProcessorHandlers = n.slice(), r = this._visualHandlers = r.slice(), this._allHandlers = n.concat(r);
	}
	return e.prototype.restoreData = function(e, t) {
		e.restoreData(t), this._stageTaskMap.each(function(e) {
			var t = e.overallTask;
			t && t.dirty();
		});
	}, e.prototype.getPerformArgs = function(e, t) {
		if (e.__pipeline) {
			var n = this._pipelineMap.get(e.__pipeline.id), r = n.context, i = !t && n.progressiveEnabled && (!r || r.progressiveRender) && e.__idxInPipeline > n.blockIndex ? n.step : null, a = r && r.modDataCount;
			return {
				step: i,
				modBy: a == null ? null : Math.ceil(a / i),
				modDataCount: a
			};
		}
	}, e.prototype.getPipeline = function(e) {
		return this._pipelineMap.get(e);
	}, e.prototype.updateStreamModes = function(e, t) {
		var n = this._pipelineMap.get(e.uid);
		e.pipelineContext = n.context = e.__preparePipelineContext ? e.__preparePipelineContext(t, n) : ec(e, t, n);
	}, e.prototype.restorePipelines = function(e, t) {
		var n = this, r = n._pipelineMap = K();
		t.eachSeries(function(t) {
			var i = e.painter.type === "canvas" && t.getProgressive(), a = t.uid;
			r.set(a, {
				id: a,
				head: null,
				tail: null,
				threshold: t.getProgressiveThreshold(),
				progressiveEnabled: i && !(t.preventIncremental && t.preventIncremental()),
				blockIndex: -1,
				step: Math.round(i || 700),
				count: 0
			}), n._pipe(t, t.dataTask);
		});
	}, e.prototype.prepareStageTasks = function() {
		var e = this._stageTaskMap, t = this.api.getModel(), n = this.api;
		I(this._allHandlers, function(r) {
			var i = e.get(r.uid) || e.set(r.uid, {});
			Se(!(r.reset && r.overallReset), ""), r.reset && this._createSeriesStageTask(r, i, t, n), r.overallReset && this._createOverallStageTask(r, i, t, n);
		}, this);
	}, e.prototype.prepareView = function(e, t, n, r) {
		var i = e.renderTask, a = i.context;
		a.model = t, a.ecModel = n, a.api = r, i.__block = !e.incrementalPrepareRender, this._pipe(t, i);
	}, e.prototype.performDataProcessorTasks = function(e, t) {
		this._performStageTasks(this._dataProcessorHandlers, e, t, { block: !0 });
	}, e.prototype.performVisualTasks = function(e, t, n) {
		this._performStageTasks(this._visualHandlers, e, t, n);
	}, e.prototype._performStageTasks = function(e, t, n, r) {
		r ||= {};
		var i = !1, a = this;
		I(e, function(e, s) {
			if (!(r.visualType && r.visualType !== e.visualType)) {
				var c = a._stageTaskMap.get(e.uid), l = c.seriesTaskMap, u = c.overallTask;
				if (u) {
					var d, f = u.agentStubMap;
					f.each(function(e) {
						o(r, e) && (e.dirty(), d = !0);
					}), d && u.dirty(), a.updatePayload(u, n);
					var p = a.getPerformArgs(u, r.block);
					f.each(function(e) {
						e.perform(p);
					}), u.perform(p) && (i = !0);
				} else l && l.each(function(s, c) {
					o(r, s) && s.dirty();
					var l = a.getPerformArgs(s, r.block);
					l.skip = !e.performRawSeries && t.isSeriesFiltered(s.context.model), a.updatePayload(s, n), s.perform(l) && (i = !0);
				});
			}
		});
		function o(e, t) {
			return e.setDirty && (!e.dirtyMap || e.dirtyMap.get(t.__pipeline.id));
		}
		this.unfinished = i || this.unfinished;
	}, e.prototype.performSeriesTasks = function(e) {
		var t;
		e.eachSeries(function(e) {
			t = e.dataTask.perform() || t;
		}), this.unfinished = t || this.unfinished;
	}, e.prototype.plan = function() {
		this._pipelineMap.each(function(e) {
			var t = e.tail;
			do {
				if (t.__block) {
					e.blockIndex = t.__idxInPipeline;
					break;
				}
				t = t.getUpstream();
			} while (t);
		});
	}, e.prototype.updatePayload = function(e, t) {
		t !== "remain" && (e.context.payload = t);
	}, e.prototype._createSeriesStageTask = function(e, t, n, r) {
		var i = this, a = t.seriesTaskMap, o = t.seriesTaskMap = K(), s = e.seriesType, c = e.getTargetSeries;
		e.createOnAllSeries ? n.eachRawSeries(l) : s ? n.eachRawSeriesByType(s, l) : c && c(n, r).each(l);
		function l(t) {
			var s = t.uid, c = o.set(s, a && a.get(s) || Gv({
				plan: Fb,
				reset: Ib,
				count: zb
			}));
			c.context = {
				model: t,
				ecModel: n,
				api: r,
				useClearVisual: e.isVisual && !e.isLayout,
				plan: e.plan,
				reset: e.reset,
				scheduler: i
			}, i._pipe(t, c);
		}
	}, e.prototype._createOverallStageTask = function(e, t, n, r) {
		var i = this, a = t.overallTask = t.overallTask || Gv({ reset: jb });
		a.context = {
			ecModel: n,
			api: r,
			overallReset: e.overallReset,
			scheduler: i
		};
		var o = a.agentStubMap, s = a.agentStubMap = K(), c = e.seriesType, l = e.getTargetSeries, u = e.dirtyOnOverallProgress, d = !1;
		Se(!e.createOnAllSeries, ""), c ? n.eachRawSeriesByType(c, f) : l ? l(n, r).each(f) : I(n.getSeries(), f);
		function f(e) {
			var t = e.uid, n = s.set(t, o && o.get(t) || (d = !0, Gv({
				reset: Mb,
				onDirty: Pb
			})));
			n.context = {
				model: e,
				dirtyOnOverallProgress: u
			}, n.agent = a, n.__block = u, i._pipe(e, n);
		}
		d && a.dirty();
	}, e.prototype._pipe = function(e, t) {
		var n = e.uid, r = this._pipelineMap.get(n);
		!r.head && (r.head = t), r.tail && r.tail.pipe(t), r.tail = t, t.__idxInPipeline = r.count++, t.__pipeline = r;
	}, e.wrapStageHandler = function(e, t) {
		return H(e) && (e = {
			overallReset: e,
			seriesType: Bb(e)
		}), e.uid = oh("stageHandler"), t && (e.visualType = t), e;
	}, e;
}();
function jb(e) {
	e.overallReset(e.ecModel, e.api, e.payload);
}
function Mb(e) {
	return e.dirtyOnOverallProgress && Nb;
}
function Nb() {
	this.agent.dirty(), this.getDownstream().dirty();
}
function Pb() {
	this.agent && this.agent.dirty();
}
function Fb(e) {
	return e.plan ? e.plan(e.model, e.ecModel, e.api, e.payload) : null;
}
function Ib(e) {
	e.useClearVisual && e.data.clearAllVisual();
	var t = e.resetDefines = ss(e.reset(e.model, e.ecModel, e.api, e.payload));
	return t.length > 1 ? L(t, function(e, t) {
		return Rb(t);
	}) : Lb;
}
var Lb = Rb(0);
function Rb(e) {
	return function(t, n) {
		var r = n.data, i = n.resetDefines[e];
		if (i && i.dataEach) for (var a = t.start; a < t.end; a++) i.dataEach(r, a);
		else i && i.progress && i.progress(t, r);
	};
}
function zb(e) {
	return e.data.count();
}
function Bb(e) {
	Ub = null;
	try {
		e(Vb, Hb);
	} catch {}
	return Ub;
}
var Vb = {}, Hb = {}, Ub;
Wb(Vb, D_), Wb(Hb, Yu), Vb.eachSeriesByType = Vb.eachRawSeriesByType = function(e) {
	Ub = e;
}, Vb.eachComponent = function(e) {
	e.mainType === "series" && e.subType && (Ub = e.subType);
};
function Wb(e, t) {
	for (var n in t.prototype) e[n] = Pe;
}
//#endregion
//#region node_modules/echarts/lib/theme/dark.js
var $ = Q.darkColor, Gb = $.background, Kb = function() {
	return {
		axisLine: { lineStyle: { color: $.axisLine } },
		splitLine: { lineStyle: { color: $.axisSplitLine } },
		splitArea: { areaStyle: { color: [$.backgroundTint, $.backgroundTransparent] } },
		minorSplitLine: { lineStyle: { color: $.axisMinorSplitLine } },
		axisLabel: { color: $.axisLabel },
		axisName: {}
	};
}, qb = {
	label: { color: $.secondary },
	itemStyle: { borderColor: $.borderTint },
	dividerLineStyle: { color: $.border }
}, Jb = {
	darkMode: !0,
	color: $.theme,
	backgroundColor: Gb,
	axisPointer: {
		lineStyle: { color: $.border },
		crossStyle: { color: $.borderShade },
		label: { color: $.tertiary }
	},
	legend: {
		textStyle: { color: $.secondary },
		pageTextStyle: { color: $.tertiary }
	},
	textStyle: { color: $.secondary },
	title: {
		textStyle: { color: $.primary },
		subtextStyle: { color: $.quaternary }
	},
	toolbox: {
		iconStyle: { borderColor: $.accent50 },
		feature: { dataView: {
			backgroundColor: Gb,
			textColor: $.primary,
			textareaColor: $.background,
			textareaBorderColor: $.border,
			buttonColor: $.accent50,
			buttonTextColor: $.neutral00
		} }
	},
	tooltip: {
		backgroundColor: $.neutral20,
		defaultBorderColor: $.border,
		textStyle: { color: $.tertiary }
	},
	dataZoom: {
		borderColor: $.accent10,
		textStyle: { color: $.tertiary },
		brushStyle: { color: $.backgroundTint },
		handleStyle: {
			color: $.neutral00,
			borderColor: $.accent20
		},
		moveHandleStyle: { color: $.accent40 },
		emphasis: { handleStyle: { borderColor: $.accent50 } },
		dataBackground: {
			lineStyle: { color: $.accent30 },
			areaStyle: { color: $.accent20 }
		},
		selectedDataBackground: {
			lineStyle: { color: $.accent50 },
			areaStyle: { color: $.accent30 }
		}
	},
	visualMap: {
		textStyle: { color: $.secondary },
		handleStyle: { borderColor: $.neutral30 }
	},
	timeline: {
		lineStyle: { color: $.accent10 },
		label: { color: $.tertiary },
		controlStyle: {
			color: $.accent30,
			borderColor: $.accent30
		}
	},
	calendar: {
		itemStyle: {
			color: $.neutral00,
			borderColor: $.neutral20
		},
		dayLabel: { color: $.tertiary },
		monthLabel: { color: $.secondary },
		yearLabel: { color: $.secondary }
	},
	matrix: {
		x: qb,
		y: qb,
		backgroundColor: { borderColor: $.axisLine },
		body: { itemStyle: { borderColor: $.borderTint } }
	},
	timeAxis: Kb(),
	logAxis: Kb(),
	valueAxis: Kb(),
	categoryAxis: Kb(),
	line: { symbol: "circle" },
	graph: { color: $.theme },
	gauge: {
		title: { color: $.secondary },
		axisLine: { lineStyle: { color: [[1, $.neutral05]] } },
		axisLabel: { color: $.axisLabel },
		detail: { color: $.primary }
	},
	candlestick: { itemStyle: {
		color: "#f64e56",
		color0: "#54ea92",
		borderColor: "#f64e56",
		borderColor0: "#54ea92"
	} },
	funnel: { itemStyle: { borderColor: $.background } },
	radar: function() {
		var e = Kb();
		return e.axisName = { color: $.axisLabel }, e.axisLine.lineStyle.color = $.neutral20, e;
	}(),
	treemap: { breadcrumb: {
		itemStyle: {
			color: $.neutral20,
			textStyle: { color: $.secondary }
		},
		emphasis: { itemStyle: { color: $.neutral30 } }
	} },
	sunburst: { itemStyle: { borderColor: $.background } },
	map: {
		itemStyle: {
			borderColor: $.border,
			areaColor: $.neutral10
		},
		label: { color: $.tertiary },
		emphasis: {
			label: { color: $.primary },
			itemStyle: { areaColor: $.highlight }
		},
		select: {
			label: { color: $.primary },
			itemStyle: { areaColor: $.highlight }
		}
	},
	geo: {
		itemStyle: {
			borderColor: $.border,
			areaColor: $.neutral10
		},
		emphasis: {
			label: { color: $.primary },
			itemStyle: { areaColor: $.highlight }
		},
		select: {
			label: { color: $.primary },
			itemStyle: { color: $.highlight }
		}
	}
};
Jb.categoryAxis.splitLine.show = !1;
//#endregion
//#region node_modules/echarts/lib/util/ECEventProcessor.js
var Yb = function() {
	function e() {}
	return e.prototype.normalizeQuery = function(e) {
		var t = {}, n = {}, r = {};
		if (U(e)) {
			var i = oc(e);
			t.mainType = i.main || null, t.subType = i.sub || null;
		} else {
			var a = [
				"Index",
				"Name",
				"Id"
			], o = {
				name: 1,
				dataIndex: 1,
				dataType: 1
			};
			I(e, function(e, i) {
				for (var s = !1, c = 0; c < a.length; c++) {
					var l = a[c], u = i.lastIndexOf(l);
					if (u > 0 && u === i.length - l.length) {
						var d = i.slice(0, u);
						d !== "data" && (t.mainType = d, t[l.toLowerCase()] = e, s = !0);
					}
				}
				o.hasOwnProperty(i) && (n[i] = e, s = !0), s || (r[i] = e);
			});
		}
		return {
			cptQuery: t,
			dataQuery: n,
			otherQuery: r
		};
	}, e.prototype.filter = function(e, t) {
		var n = this.eventInfo;
		if (!n) return !0;
		var r = n.targetEl, i = n.packedEvent, a = n.model, o = n.view;
		if (!a || !o) return !0;
		var s = t.cptQuery, c = t.dataQuery;
		return l(s, a, "mainType") && l(s, a, "subType") && l(s, a, "index", "componentIndex") && l(s, a, "name") && l(s, a, "id") && l(c, i, "name") && l(c, i, "dataIndex") && l(c, i, "dataType") && (!o.filterForExposedEvent || o.filterForExposedEvent(e, t.otherQuery, r, i));
		function l(e, t, n, r) {
			return e[n] == null || t[r || n] === e[n];
		}
	}, e.prototype.afterTrigger = function() {
		this.eventInfo = null;
	}, e;
}(), Xb = [
	"symbol",
	"symbolSize",
	"symbolRotate",
	"symbolOffset"
], Zb = Xb.concat(["symbolKeepAspect"]), Qb = {
	createOnAllSeries: !0,
	performRawSeries: !0,
	reset: function(e, t) {
		var n = e.getData();
		if (e.legendIcon && n.setVisual("legendIcon", e.legendIcon), !e.hasSymbolVisual) return;
		for (var r = {}, i = {}, a = !1, o = 0; o < Xb.length; o++) {
			var s = Xb[o], c = e.get(s);
			H(c) ? (a = !0, i[s] = c) : r[s] = c;
		}
		if (r.symbol = r.symbol || e.defaultSymbol, n.setVisual(M({
			legendIcon: e.legendIcon || r.symbol,
			symbolKeepAspect: e.get("symbolKeepAspect")
		}, r)), t.isSeriesFiltered(e)) return;
		var l = R(i);
		function u(t, n) {
			for (var r = e.getRawValue(n), a = e.getDataParams(n), o = 0; o < l.length; o++) {
				var s = l[o];
				t.setItemVisual(n, s, i[s](r, a));
			}
		}
		return { dataEach: a ? u : null };
	}
}, $b = {
	createOnAllSeries: !0,
	performRawSeries: !0,
	reset: function(e, t) {
		if (!e.hasSymbolVisual || t.isSeriesFiltered(e)) return;
		var n = e.getData();
		function r(e, t) {
			for (var n = e.getItemModel(t), r = 0; r < Zb.length; r++) {
				var i = Zb[r], a = n.getShallow(i, !0);
				a != null && e.setItemVisual(t, i, a);
			}
		}
		return { dataEach: n.hasItemOption ? r : null };
	}
};
//#endregion
//#region node_modules/echarts/lib/visual/helper.js
function ex(e, t, n) {
	switch (n) {
		case "color": return e.getItemVisual(t, "style")[e.getVisual("drawType")];
		case "opacity": return e.getItemVisual(t, "style").opacity;
		case "symbol":
		case "symbolSize":
		case "liftZ": return e.getItemVisual(t, n);
	}
}
function tx(e, t) {
	switch (t) {
		case "color": return e.getVisual("style")[e.getVisual("drawType")];
		case "opacity": return e.getVisual("style").opacity;
		case "symbol":
		case "symbolSize":
		case "liftZ": return e.getVisual(t);
	}
}
function nx(e, t, n, r) {
	switch (n) {
		case "color":
			var i = e.ensureUniqueItemVisual(t, "style");
			i[e.getVisual("drawType")] = r, e.setItemVisual(t, "colorFromPalette", !1);
			break;
		case "opacity":
			e.ensureUniqueItemVisual(t, "style").opacity = r;
			break;
		case "symbol":
		case "symbolSize":
		case "liftZ": e.setItemVisual(t, n, r);
	}
}
//#endregion
//#region node_modules/echarts/lib/legacy/dataSelectAction.js
function rx(e, t) {
	function n(t, n) {
		var r = [];
		return t.eachComponent({
			mainType: "series",
			subType: e,
			query: n
		}, function(e) {
			r.push(e.seriesIndex);
		}), r;
	}
	I([
		[e + "ToggleSelect", "toggleSelect"],
		[e + "Select", "select"],
		[e + "UnSelect", "unselect"]
	], function(e) {
		t(e[0], function(t, r, i) {
			t = M({}, t), i.dispatchAction(M(t, {
				type: e[1],
				seriesIndex: n(r, t)
			}));
		});
	});
}
function ix(e, t, n, r, i) {
	var a = e + t;
	n.isSilent(a) || r.eachComponent({
		mainType: "series",
		subType: "pie"
	}, function(e) {
		for (var t = e.seriesIndex, r = e.option.selectedMap, o = i.selected, s = 0; s < o.length; s++) if (o[s].seriesIndex === t) {
			var c = e.getData(), l = Ds(c, i.fromActionPayload);
			n.trigger(a, {
				type: a,
				seriesId: e.id,
				name: V(l) ? c.getName(l[0]) : c.getName(l),
				selected: U(r) ? r : M({}, r)
			});
		}
	});
}
function ax(e, t, n) {
	e.on("selectchanged", function(e) {
		var r = n.getModel();
		e.isFromClick ? (ix("map", "selectchanged", t, r, e), ix("pie", "selectchanged", t, r, e)) : e.fromAction === "select" ? (ix("map", "selected", t, r, e), ix("pie", "selected", t, r, e)) : e.fromAction === "unselect" && (ix("map", "unselected", t, r, e), ix("pie", "unselected", t, r, e));
	});
}
//#endregion
//#region node_modules/echarts/lib/util/event.js
function ox(e, t, n) {
	for (var r; e && !(t(e) && (r = e, n));) e = e.__hostTarget || e.parent;
	return r;
}
//#endregion
//#region node_modules/echarts/lib/core/lifecycle.js
var sx = new dt(), cx = {};
function lx(e, t) {
	cx[e] = t;
}
function ux(e) {
	return cx[e];
}
//#endregion
//#region node_modules/echarts/lib/chart/custom/customSeriesRegister.js
var dx = {};
function fx(e, t) {
	dx[e] = t;
}
//#endregion
//#region node_modules/echarts/lib/util/cycleCache.js
var px = X();
function mx(e) {
	px(e).prepare = {};
}
function hx(e) {
	px(e).fullUpdate = {};
}
function gx(e) {
	return px(e).prepare;
}
function _x(e) {
	return px(e).fullUpdate;
}
//#endregion
//#region node_modules/zrender/lib/core/WeakMap.js
var vx = Math.round(Math.random() * 9), yx = typeof Object.defineProperty == "function", bx = function() {
	function e() {
		this._id = "__ec_inner_" + vx++;
	}
	return e.prototype.get = function(e) {
		return this._guard(e)[this._id];
	}, e.prototype.set = function(e, t) {
		var n = this._guard(e);
		return yx ? Object.defineProperty(n, this._id, {
			value: t,
			enumerable: !1,
			configurable: !0
		}) : n[this._id] = t, this;
	}, e.prototype.delete = function(e) {
		return this.has(e) ? (delete this._guard(e)[this._id], !0) : !1;
	}, e.prototype.has = function(e) {
		return !!this._guard(e)[this._id];
	}, e.prototype._guard = function(e) {
		if (e !== Object(e)) throw TypeError("Value of WeakMap is not a non-null object.");
		return e;
	}, e;
}(), xx = ou.extend({
	type: "triangle",
	shape: {
		cx: 0,
		cy: 0,
		width: 0,
		height: 0
	},
	buildPath: function(e, t) {
		var n = t.cx, r = t.cy, i = t.width / 2, a = t.height / 2;
		e.moveTo(n, r - a), e.lineTo(n + i, r + a), e.lineTo(n - i, r + a), e.closePath();
	}
}), Sx = {
	line: ip,
	rect: bu,
	roundRect: bu,
	square: bu,
	circle: Of,
	diamond: ou.extend({
		type: "diamond",
		shape: {
			cx: 0,
			cy: 0,
			width: 0,
			height: 0
		},
		buildPath: function(e, t) {
			var n = t.cx, r = t.cy, i = t.width / 2, a = t.height / 2;
			e.moveTo(n, r - a), e.lineTo(n + i, r), e.lineTo(n, r + a), e.lineTo(n - i, r), e.closePath();
		}
	}),
	pin: ou.extend({
		type: "pin",
		shape: {
			x: 0,
			y: 0,
			width: 0,
			height: 0
		},
		buildPath: function(e, t) {
			var n = t.x, r = t.y, i = t.width / 5 * 3, a = Math.max(i, t.height), o = i / 2, s = o * o / (a - o), c = r - a + o + s, l = Math.asin(s / o), u = Math.cos(l) * o, d = Math.sin(l), f = Math.cos(l), p = o * .6, m = o * .7;
			e.moveTo(n - u, c + s), e.arc(n, c, o, Math.PI - l, Math.PI * 2 + l), e.bezierCurveTo(n + u - d * p, c + s + f * p, n, r - m, n, r), e.bezierCurveTo(n, r - m, n - u + d * p, c + s + f * p, n - u, c + s), e.closePath();
		}
	}),
	arrow: ou.extend({
		type: "arrow",
		shape: {
			x: 0,
			y: 0,
			width: 0,
			height: 0
		},
		buildPath: function(e, t) {
			var n = t.height, r = t.width, i = t.x, a = t.y, o = r / 3 * 2;
			e.moveTo(i, a), e.lineTo(i + o, a + n), e.lineTo(i, a + n / 4 * 3), e.lineTo(i - o, a + n), e.lineTo(i, a), e.closePath();
		}
	}),
	triangle: xx
}, Cx = {
	line: function(e, t, n, r, i) {
		i.x1 = e, i.y1 = t + r / 2, i.x2 = e + n, i.y2 = t + r / 2;
	},
	rect: function(e, t, n, r, i) {
		i.x = e, i.y = t, i.width = n, i.height = r;
	},
	roundRect: function(e, t, n, r, i) {
		i.x = e, i.y = t, i.width = n, i.height = r, i.r = Math.min(n, r) / 4;
	},
	square: function(e, t, n, r, i) {
		var a = Math.min(n, r);
		i.x = e, i.y = t, i.width = a, i.height = a;
	},
	circle: function(e, t, n, r, i) {
		i.cx = e + n / 2, i.cy = t + r / 2, i.r = Math.min(n, r) / 2;
	},
	diamond: function(e, t, n, r, i) {
		i.cx = e + n / 2, i.cy = t + r / 2, i.width = n, i.height = r;
	},
	pin: function(e, t, n, r, i) {
		i.x = e + n / 2, i.y = t + r / 2, i.width = n, i.height = r;
	},
	arrow: function(e, t, n, r, i) {
		i.x = e + n / 2, i.y = t + r / 2, i.width = n, i.height = r;
	},
	triangle: function(e, t, n, r, i) {
		i.cx = e + n / 2, i.cy = t + r / 2, i.width = n, i.height = r;
	}
}, Tx = {};
I(Sx, function(e, t) {
	Tx[t] = new e();
});
var Ex = ou.extend({
	type: "symbol",
	shape: {
		symbolType: "",
		x: 0,
		y: 0,
		width: 0,
		height: 0
	},
	calculateTextPosition: function(e, t, n) {
		var r = Ea(e, t, n), i = this.shape;
		return i && i.symbolType === "pin" && t.position === "inside" && (r.y = n.y + n.height * .4), r;
	},
	buildPath: function(e, t, n) {
		var r = t.symbolType;
		if (r !== "none") {
			var i = Tx[r];
			i ||= (r = "rect", Tx[r]), Cx[r](t.x, t.y, t.width, t.height, i.shape), i.buildPath(e, i.shape, n);
		}
	}
});
function Dx(e, t) {
	if (this.type !== "image") {
		var n = this.style;
		this.__isEmptyBrush ? (n.stroke = e, n.fill = t || Q.color.neutral00, n.lineWidth = 2) : this.shape.symbolType === "line" ? n.stroke = e : n.fill = e, this.markRedraw();
	}
}
function Ox(e, t, n, r, i, a, o) {
	var s = e.indexOf("empty") === 0;
	s && (e = e.substr(5, 1).toLowerCase() + e.substr(6));
	var c = e.indexOf("image://") === 0 ? Kp(e.slice(8), new Y(t, n, r, i), o ? "center" : "cover") : e.indexOf("path://") === 0 ? Gp(e.slice(7), {}, new Y(t, n, r, i), o ? "center" : "cover") : new Ex({ shape: {
		symbolType: e,
		x: t,
		y: n,
		width: r,
		height: i
	} });
	return c.__isEmptyBrush = s, c.setColor = Dx, a && c.setColor(a), c;
}
function kx(e) {
	return V(e) || (e = [+e, +e]), [e[0] || 0, e[1] || 0];
}
function Ax(e, t) {
	if (e != null) return V(e) || (e = [e, e]), [So(e[0], t[0]) || 0, So(G(e[1], e[0]), t[1]) || 0];
}
//#endregion
//#region node_modules/zrender/lib/canvas/helper.js
function jx(e) {
	return isFinite(e);
}
function Mx(e, t, n) {
	var r = t.x == null ? 0 : t.x, i = t.x2 == null ? 1 : t.x2, a = t.y == null ? 0 : t.y, o = t.y2 == null ? 0 : t.y2;
	return t.global || (r = r * n.width + n.x, i = i * n.width + n.x, a = a * n.height + n.y, o = o * n.height + n.y), r = jx(r) ? r : 0, i = jx(i) ? i : 1, a = jx(a) ? a : 0, o = jx(o) ? o : 0, e.createLinearGradient(r, a, i, o);
}
function Nx(e, t, n) {
	var r = n.width, i = n.height, a = Math.min(r, i), o = t.x == null ? .5 : t.x, s = t.y == null ? .5 : t.y, c = t.r == null ? .5 : t.r;
	return t.global || (o = o * r + n.x, s = s * i + n.y, c *= a), o = jx(o) ? o : .5, s = jx(s) ? s : .5, c = c >= 0 && jx(c) ? c : .5, e.createRadialGradient(o, s, 0, o, s, c);
}
function Px(e, t, n) {
	for (var r = t.type === "radial" ? Nx(e, t, n) : Mx(e, t, n), i = t.colorStops, a = 0; a < i.length; a++) r.addColorStop(i[a].offset, i[a].color);
	return r;
}
function Fx(e, t) {
	if (e === t || !e && !t) return !1;
	if (!e || !t || e.length !== t.length) return !0;
	for (var n = 0; n < e.length; n++) if (e[n] !== t[n]) return !0;
	return !1;
}
function Ix(e) {
	return parseInt(e, 10);
}
function Lx(e, t, n) {
	var r = ["width", "height"][t], i = ["clientWidth", "clientHeight"][t], a = ["paddingLeft", "paddingTop"][t], o = ["paddingRight", "paddingBottom"][t];
	if (n[r] != null && n[r] !== "auto") return parseFloat(n[r]);
	var s = document.defaultView.getComputedStyle(e);
	return (e[i] || Ix(s[r]) || Ix(e.style[r])) - (Ix(s[a]) || 0) - (Ix(s[o]) || 0) || 0;
}
//#endregion
//#region node_modules/zrender/lib/canvas/dashStyle.js
function Rx(e, t) {
	return !e || e === "solid" || !(t > 0) ? null : e === "dashed" ? [4 * t, 2 * t] : e === "dotted" ? [t] : ue(e) ? [e] : V(e) ? e : null;
}
function zx(e) {
	var t = e.style, n = t.lineDash && t.lineWidth > 0 && Rx(t.lineDash, t.lineWidth), r = t.lineDashOffset;
	if (n) {
		var i = t.strokeNoScale && e.getLineScale ? e.getLineScale() : 1;
		i && i !== 1 && (n = L(n, function(e) {
			return e / i;
		}), r /= i);
	}
	return [n, r];
}
//#endregion
//#region node_modules/zrender/lib/canvas/graphic.js
var Bx = new Fl(!0);
function Vx(e) {
	var t = e.stroke;
	return !(t == null || t === "none" || !(e.lineWidth > 0));
}
function Hx(e) {
	return typeof e == "string" && e !== "none";
}
function Ux(e) {
	var t = e.fill;
	return t != null && t !== "none";
}
function Wx(e, t) {
	if (t.fillOpacity != null && t.fillOpacity !== 1) {
		var n = e.globalAlpha;
		e.globalAlpha = t.fillOpacity * t.opacity, e.fill(), e.globalAlpha = n;
	} else e.fill();
}
function Gx(e, t) {
	if (t.strokeOpacity != null && t.strokeOpacity !== 1) {
		var n = e.globalAlpha;
		e.globalAlpha = t.strokeOpacity * t.opacity, e.stroke(), e.globalAlpha = n;
	} else e.stroke();
}
function Kx(e, t, n) {
	var r = Sc(t.image, t.__image, n);
	if (wc(r)) {
		var i = e.createPattern(r, t.repeat || "repeat");
		if (typeof DOMMatrix == "function" && i && i.setTransform) {
			var a = new DOMMatrix();
			a.translateSelf(t.x || 0, t.y || 0), a.rotateSelf(0, 0, (t.rotation || 0) * Fe), a.scaleSelf(t.scaleX || 1, t.scaleY || 1), i.setTransform(a);
		}
		return i;
	}
}
function qx(e, t, n, r, i) {
	var a, o = Vx(n), s = Ux(n), c = n.strokePercent, l = c < 1, u = !t.path;
	(!t.silent || l) && u && t.createPathProxy();
	var d = t.path || Bx, f = t.__dirty;
	if (!r) {
		var p = n.fill, m = n.stroke, h = s && !!p.colorStops, g = o && !!m.colorStops, _ = s && !!p.image, v = o && !!m.image, y = void 0, b = void 0, x = void 0, S = void 0, C = void 0;
		(h || g) && (C = t.getBoundingRect()), h && (y = f ? Px(e, p, C) : t.__canvasFillGradient, t.__canvasFillGradient = y), g && (b = f ? Px(e, m, C) : t.__canvasStrokeGradient, t.__canvasStrokeGradient = b), _ && (x = f || !t.__canvasFillPattern ? Kx(e, p, t) : t.__canvasFillPattern, t.__canvasFillPattern = x), v && (S = f || !t.__canvasStrokePattern ? Kx(e, m, t) : t.__canvasStrokePattern, t.__canvasStrokePattern = S), h ? e.fillStyle = y : _ && (x ? e.fillStyle = x : s = !1), g ? e.strokeStyle = b : v && (S ? e.strokeStyle = S : o = !1);
	}
	var w = t.getGlobalScale();
	d.setScale(w[0], w[1], t.segmentIgnoreThreshold);
	var T, E;
	e.setLineDash && n.lineDash && (a = zx(t), T = a[0], E = a[1]);
	var D = !0;
	(u || f & 4) && (d.setDPR(e.dpr), l ? d.setContext(null) : (d.setContext(e), D = !1), d.reset(), t.buildPath(d, t.shape, r), d.toStatic(), t.pathUpdated()), D && d.rebuildPath(e, l ? c : 1), T && (e.setLineDash(T), e.lineDashOffset = E), r ? (i.batchFill = s, i.batchStroke = o) : n.strokeFirst ? (o && Gx(e, n), s && Wx(e, n)) : (s && Wx(e, n), o && Gx(e, n)), T && e.setLineDash([]);
}
function Jx(e, t, n) {
	var r = t.__image = Sc(n.image, t.__image, t, t.onload);
	if (r && wc(r)) {
		var i = n.x || 0, a = n.y || 0, o = t.getWidth(), s = t.getHeight(), c = r.width / r.height;
		if (o == null && s != null ? o = s * c : s == null && o != null ? s = o / c : o == null && s == null && (o = r.width, s = r.height), n.sWidth && n.sHeight) {
			var l = n.sx || 0, u = n.sy || 0;
			e.drawImage(r, l, u, n.sWidth, n.sHeight, i, a, o, s);
		} else if (n.sx && n.sy) {
			var l = n.sx, u = n.sy, d = o - l, f = s - u;
			e.drawImage(r, l, u, d, f, i, a, o, s);
		} else e.drawImage(r, i, a, o, s);
	}
}
function Yx(e, t, n) {
	var r, i = n.text;
	if (i != null && (i += ""), i) {
		e.font = n.font || "12px sans-serif", e.textAlign = n.textAlign, e.textBaseline = n.textBaseline;
		var a = void 0, o = void 0;
		e.setLineDash && n.lineDash && (r = zx(t), a = r[0], o = r[1]), a && (e.setLineDash(a), e.lineDashOffset = o), n.strokeFirst ? (Vx(n) && e.strokeText(i, n.x, n.y), Ux(n) && e.fillText(i, n.x, n.y)) : (Ux(n) && e.fillText(i, n.x, n.y), Vx(n) && e.strokeText(i, n.x, n.y)), a && e.setLineDash([]);
	}
}
var Xx = [
	"shadowBlur",
	"shadowOffsetX",
	"shadowOffsetY"
], Zx = [
	["lineCap", "butt"],
	["lineJoin", "miter"],
	["miterLimit", 10]
];
function Qx(e, t, n, r, i) {
	var a = !1;
	if (!r && (n ||= {}, t === n)) return !1;
	if (r || t.opacity !== n.opacity) {
		lS(e, i), a = !0;
		var o = Math.max(Math.min(t.opacity, 1), 0);
		e.globalAlpha = isNaN(o) ? Yc.opacity : o;
	}
	(r || t.blend !== n.blend) && (a ||= (lS(e, i), !0), e.globalCompositeOperation = t.blend || Yc.blend);
	for (var s = 0; s < Xx.length; s++) {
		var c = Xx[s];
		(r || t[c] !== n[c]) && (a ||= (lS(e, i), !0), e[c] = e.dpr * (t[c] || 0));
	}
	return (r || t.shadowColor !== n.shadowColor) && (a ||= (lS(e, i), !0), e.shadowColor = t.shadowColor || Yc.shadowColor), a;
}
function $x(e, t, n, r, i) {
	var a = t.style, o = r ? null : n && n.style || {};
	if (a === o) return !1;
	var s = Qx(e, a, o, r, i);
	if ((r || a.fill !== o.fill) && (s ||= (lS(e, i), !0), Hx(a.fill) && (e.fillStyle = a.fill)), (r || a.stroke !== o.stroke) && (s ||= (lS(e, i), !0), Hx(a.stroke) && (e.strokeStyle = a.stroke)), (r || a.opacity !== o.opacity) && (s ||= (lS(e, i), !0), e.globalAlpha = a.opacity == null ? 1 : a.opacity), t.hasStroke()) {
		var c = a.lineWidth / (a.strokeNoScale && t.getLineScale ? t.getLineScale() : 1);
		e.lineWidth !== c && (s ||= (lS(e, i), !0), e.lineWidth = c);
	}
	for (var l = 0; l < Zx.length; l++) {
		var u = Zx[l], d = u[0];
		(r || a[d] !== o[d]) && (s ||= (lS(e, i), !0), e[d] = a[d] || u[1]);
	}
	return s;
}
function eS(e, t, n, r, i) {
	return Qx(e, t.style, n && n.style, r, i);
}
function tS(e, t) {
	var n = t.transform, r = e.dpr || 1;
	n ? e.setTransform(r * n[0], r * n[1], r * n[2], r * n[3], r * n[4], r * n[5]) : e.setTransform(r, 0, 0, r, 0, 0);
}
function nS(e, t, n) {
	for (var r = !1, i = 0; i < e.length; i++) {
		var a = e[i];
		r ||= a.isZeroArea(), tS(t, a), t.beginPath(), a.buildPath(t, a.shape), t.clip();
	}
	n.allClipped = r;
}
function rS(e, t) {
	return e && t ? e[0] !== t[0] || e[1] !== t[1] || e[2] !== t[2] || e[3] !== t[3] || e[4] !== t[4] || e[5] !== t[5] : !(!e && !t);
}
var iS = 1, aS = 2, oS = 3, sS = 4;
function cS(e) {
	var t = Ux(e), n = Vx(e);
	return !(e.lineDash || !(+t ^ n) || t && typeof e.fill != "string" || n && typeof e.stroke != "string" || e.strokePercent < 1 || e.strokeOpacity < 1 || e.fillOpacity < 1);
}
function lS(e, t) {
	t.batchFill && (t.batchFill = !1, e.fill()), t.batchStroke && (t.batchStroke = !1, e.stroke());
}
function uS(e, t) {
	var n = {
		inHover: !1,
		viewWidth: 0,
		viewHeight: 0,
		beforeBrushParam: {}
	};
	dS(e, t, n), fS(e, n);
}
function dS(e, t, n) {
	var r = t.transform;
	if (!t.shouldBePainted(n.viewWidth, n.viewHeight, !1, !1)) t.__dirty &= -2, t.__isRendered = !1;
	else {
		var i = t.__clipPaths, a = n.prevElClipPaths, o = t.style, s = !1, c = !1;
		if ((!a || Fx(i, a)) && (a && (lS(e, n), e.restore(), c = s = !0, n.prevElClipPaths = null, n.allClipped = !1, n.prevEl = null), i && i.length && (lS(e, n), e.save(), nS(i, e, n), s = !0, n.prevElClipPaths = i)), n.allClipped) t.__dirty &= -2, t.__isRendered = !1;
		else {
			t.beforeBrush && t.beforeBrush(n.beforeBrushParam), t.innerBeforeBrush();
			var l = n.prevEl;
			l || (c = s = !0);
			var u = t instanceof ou && t.autoBatch && cS(o);
			s || rS(r, l.transform) ? (lS(e, n), tS(e, t)) : u || lS(e, n), t instanceof ou ? (n.lastDrawType !== iS && (c = !0, n.lastDrawType = iS), $x(e, t, l, c, n), (!u || !n.batchFill && !n.batchStroke) && e.beginPath(), qx(e, t, o, u, n)) : t instanceof cu ? (n.lastDrawType !== oS && (c = !0, n.lastDrawType = oS), $x(e, t, l, c, n), Yx(e, t, o)) : t instanceof fu ? (n.lastDrawType !== aS && (c = !0, n.lastDrawType = aS), eS(e, t, l, c, n), Jx(e, t, o)) : t.getTemporalDisplayables && (n.lastDrawType !== sS && (c = !0, n.lastDrawType = sS), pS(e, t, n)), t.innerAfterBrush(), t.afterBrush && (u && lS(e, n), t.afterBrush()), n.prevEl = t, t.__dirty = 0, t.__isRendered = !0;
		}
	}
}
function fS(e, t) {
	lS(e, t), t.prevElClipPaths && e.restore();
}
function pS(e, t, n) {
	var r = t.getDisplayables(), i = t.getTemporalDisplayables();
	e.save();
	for (var a = {
		prevElClipPaths: null,
		prevEl: null,
		allClipped: !1,
		viewWidth: n.viewWidth,
		viewHeight: n.viewHeight,
		inHover: n.inHover,
		beforeBrushParam: {}
	}, o = t.getCursor(), s = r.length; o < s; o++) {
		var c = r[o];
		c.beforeBrush && c.beforeBrush(n.beforeBrushParam), c.innerBeforeBrush(), dS(e, c, a), c.innerAfterBrush(), c.afterBrush && c.afterBrush(), a.prevEl = c;
	}
	fS(e, a);
	for (var l = 0, u = i.length; l < u; l++) {
		var c = i[l];
		c.beforeBrush && c.beforeBrush(n.beforeBrushParam), c.innerBeforeBrush(), dS(e, c, a), c.innerAfterBrush(), c.afterBrush && c.afterBrush(), a.prevEl = c;
	}
	fS(e, a), t.clearTemporalDisplayables(), t.notClear = !0, e.restore();
}
//#endregion
//#region node_modules/echarts/lib/util/decal.js
var mS = new bx(), hS = new Er(100), gS = [
	"symbol",
	"symbolSize",
	"symbolKeepAspect",
	"color",
	"backgroundColor",
	"dashArrayX",
	"dashArrayY",
	"maxTileWidth",
	"maxTileHeight"
];
function _S(e, t) {
	if (e === "none") return null;
	var n = t.getDevicePixelRatio(), r = t.getZr(), i = r.painter.type === "svg";
	e.dirty && mS.delete(e);
	var a = mS.get(e);
	if (a) return a;
	var o = N(e, {
		symbol: "rect",
		symbolSize: 1,
		symbolKeepAspect: !0,
		color: "rgba(0, 0, 0, 0.2)",
		backgroundColor: null,
		dashArrayX: 5,
		dashArrayY: 5,
		rotation: 0,
		maxTileWidth: 512,
		maxTileHeight: 512
	});
	o.backgroundColor === "none" && (o.backgroundColor = null);
	var s = { repeat: "repeat" };
	return c(s), s.rotation = o.rotation, s.scaleX = s.scaleY = i ? 1 : 1 / n, mS.set(e, s), e.dirty = !1, s;
	function c(e) {
		for (var t = [n], a = !0, s = 0; s < gS.length; ++s) {
			var c = o[gS[s]];
			if (c != null && !V(c) && !U(c) && !ue(c) && typeof c != "boolean") {
				a = !1;
				break;
			}
			t.push(c);
		}
		var l;
		if (a) {
			l = t.join(",") + (i ? "-svg" : "");
			var u = hS.get(l);
			u && (i ? e.svgElement = u : e.image = u);
		}
		var d = yS(o.dashArrayX), p = bS(o.dashArrayY), m = vS(o.symbol), h = xS(d), g = SS(p), _ = !i && f.createCanvas(), v = i && {
			tag: "g",
			attrs: {},
			key: "dcl",
			children: []
		}, y = x(), b;
		_ && (_.width = y.width * n, _.height = y.height * n, b = _.getContext("2d")), S(), a && hS.put(l, _ || v), e.image = _, e.svgElement = v, e.svgWidth = y.width, e.svgHeight = y.height;
		function x() {
			for (var e = 1, t = 0, n = h.length; t < n; ++t) e = Xo(e, h[t]);
			for (var r = 1, t = 0, n = m.length; t < n; ++t) r = Xo(r, m[t].length);
			e *= r;
			var i = g * h.length * m.length;
			return {
				width: Math.max(1, Math.min(e, o.maxTileWidth)),
				height: Math.max(1, Math.min(i, o.maxTileHeight))
			};
		}
		function S() {
			b && (b.clearRect(0, 0, _.width, _.height), o.backgroundColor && (b.fillStyle = o.backgroundColor, b.fillRect(0, 0, _.width, _.height)));
			for (var e = 0, t = 0; t < p.length; ++t) e += p[t];
			if (e <= 0) return;
			for (var a = -g, s = 0, c = 0, l = 0; a < y.height;) {
				if (s % 2 == 0) {
					for (var u = c / 2 % m.length, f = 0, h = 0, x = 0; f < y.width * 2;) {
						for (var S = 0, t = 0; t < d[l].length; ++t) S += d[l][t];
						if (S <= 0) break;
						if (h % 2 == 0) {
							var C = (1 - o.symbolSize) * .5, w = f + d[l][h] * C, T = a + p[s] * C, E = d[l][h] * o.symbolSize, D = p[s] * o.symbolSize, O = x / 2 % m[u].length;
							k(w, T, E, D, m[u][O]);
						}
						f += d[l][h], ++x, ++h, h === d[l].length && (h = 0);
					}
					++l, l === d.length && (l = 0);
				}
				a += p[s], ++c, ++s, s === p.length && (s = 0);
			}
			function k(e, t, a, s, c) {
				var l = i ? 1 : n, u = Ox(c, e * l, t * l, a * l, s * l, o.color, o.symbolKeepAspect);
				if (i) {
					var d = r.painter.renderOneToVNode(u);
					d && v.children.push(d);
				} else uS(b, u);
			}
		}
	}
}
function vS(e) {
	if (!e || e.length === 0) return [["rect"]];
	if (U(e)) return [[e]];
	for (var t = !0, n = 0; n < e.length; ++n) if (!U(e[n])) {
		t = !1;
		break;
	}
	if (t) return vS([e]);
	for (var r = [], n = 0; n < e.length; ++n) U(e[n]) ? r.push([e[n]]) : r.push(e[n]);
	return r;
}
function yS(e) {
	if (!e || e.length === 0) return [[0, 0]];
	if (ue(e)) {
		var t = Math.ceil(e);
		return [[t, t]];
	}
	for (var n = !0, r = 0; r < e.length; ++r) if (!ue(e[r])) {
		n = !1;
		break;
	}
	if (n) return yS([e]);
	for (var i = [], r = 0; r < e.length; ++r) if (ue(e[r])) {
		var t = Math.ceil(e[r]);
		i.push([t, t]);
	} else {
		var t = L(e[r], function(e) {
			return Math.ceil(e);
		});
		t.length % 2 == 1 ? i.push(t.concat(t)) : i.push(t);
	}
	return i;
}
function bS(e) {
	if (!e || typeof e == "object" && e.length === 0) return [0, 0];
	if (ue(e)) {
		var t = Math.ceil(e);
		return [t, t];
	}
	var n = L(e, function(e) {
		return Math.ceil(e);
	});
	return e.length % 2 ? n.concat(n) : n;
}
function xS(e) {
	return L(e, function(e) {
		return SS(e);
	});
}
function SS(e) {
	for (var t = 0, n = 0; n < e.length; ++n) t += e[n];
	return e.length % 2 == 1 ? t * 2 : t;
}
//#endregion
//#region node_modules/echarts/lib/visual/decal.js
var CS = nc(wS);
function wS(e, t) {
	e.eachRawSeries(function(n) {
		if (!e.isSeriesFiltered(n)) {
			var r = n.getData();
			r.hasItemVisual() && r.each(function(e) {
				var n = r.getItemVisual(e, "decal");
				if (n) {
					var i = r.ensureUniqueItemVisual(e, "style");
					i.decal = _S(n, t);
				}
			});
			var i = r.getVisual("decal");
			if (i) {
				var a = r.getVisual("style");
				a.decal = _S(i, t);
			}
		}
	});
}
//#endregion
//#region node_modules/echarts/lib/core/echarts.js
var TS = "6.1.0", ES = { zrender: "6.1.0" }, DS = 1, OS = 800, kS = 900, AS = 920, jS = 1e3, MS = 2e3, NS = 5e3, PS = 1e3, FS = 1100, IS = 2e3, LS = 3e3, RS = 4e3, zS = 4500, BS = 4600, VS = 5e3, HS = 6e3, US = 7e3, WS = {
	PROCESSOR: {
		SERIES_FILTER: OS,
		AXIS_STATISTICS: AS,
		FILTER: jS,
		STATISTIC: NS,
		STATISTICS: NS
	},
	VISUAL: {
		LAYOUT: PS,
		PROGRESSIVE_LAYOUT: FS,
		GLOBAL: IS,
		CHART: LS,
		POST_CHART_LAYOUT: BS,
		COMPONENT: RS,
		BRUSH: VS,
		CHART_ITEM: zS,
		ARIA: HS,
		DECAL: US
	}
}, GS = "__flagInMainProcess", KS = "__mainProcessVersion", qS = "__pendingUpdate", JS = "__needsUpdateStatus", YS = /^[a-zA-Z0-9_]+$/, XS = "__connectUpdateStatus", ZS = 0, QS = 1, $S = 2;
function eC(e) {
	return function() {
		var t = [...arguments];
		if (this.isDisposed()) this.id;
		else return nC(this, e, t);
	};
}
function tC(e) {
	return function() {
		var t = [...arguments];
		return nC(this, e, t);
	};
}
function nC(e, t, n) {
	return n[0] = n[0] && n[0].toLowerCase(), dt.prototype[t].apply(e, n);
}
var rC = function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t;
}(dt), iC = rC.prototype;
iC.on = tC("on"), iC.off = tC("off");
var aC, oC, sC, cC, lC, uC, dC, fC, pC, mC, hC, gC, _C, vC, yC, bC, xC, SC, CC, wC = function(e) {
	n(t, e);
	function t(t, n, r) {
		var i = e.call(this, new Yb()) || this;
		i._chartsViews = [], i._chartsMap = {}, i._componentsViews = [], i._componentsMap = {}, i._pendingActions = [], r ||= {}, i.__v_skip = !0, i._dom = t;
		var a = "canvas", o = "auto", s = !1;
		i[KS] = 1, r.ssr && io(function(e) {
			var t = Z(e), n = t.dataIndex;
			if (n != null) {
				var r = K();
				return r.set("series_index", t.seriesIndex), r.set("data_index", n), t.ssrType && r.set("ssr_type", t.ssrType), r;
			}
		});
		var c = i._zr = Za(t, {
			renderer: r.renderer || a,
			devicePixelRatio: r.devicePixelRatio,
			width: r.width,
			height: r.height,
			ssr: r.ssr,
			useDirtyRect: G(r.useDirtyRect, s),
			useCoarsePointer: G(r.useCoarsePointer, o),
			pointerSize: r.pointerSize
		});
		i._ssr = r.ssr, i._throttledZrFlush = gb(z(c.flush, c), 17), i._updateTheme(n), i._locale = yh(r.locale || _h), i._coordSysMgr = new wg();
		var l = i._api = yC(i);
		function u(e, t) {
			return e.__prio - t.__prio;
		}
		return Un(MC, u), Un(AC, u), i._scheduler = new Ab(i, l, AC, MC), i._messageCenter = new rC(), i._initEvents(), i.resize = z(i.resize, i), c.animation.on("frame", i._onframe, i), mC(c, i), hC(c, i), Te(i), i;
	}
	return t.prototype._onframe = function() {
		if (!this._disposed) {
			var e = this._scheduler, t = this._model, n = this._api;
			if (SC(this), this[qS]) {
				var r = this[qS].silent;
				this[GS] = !0, CC(this);
				try {
					aC(this), cC.update.call(this, null, this[qS].updateParams);
				} catch (e) {
					throw this[GS] = !1, this[qS] = null, e;
				}
				this._zr.flush(), this[GS] = !1, this[qS] = null, fC.call(this, r), pC.call(this, r);
			} else if (e.unfinished) {
				var i = DS;
				do {
					e.unfinished = !1;
					var a = f.getTime();
					e.performSeriesTasks(t), e.performDataProcessorTasks(t), uC(this, t), e.performVisualTasks(t), vC(this, this._model, n, "remain", {}), i -= f.getTime() - a;
				} while (i > 0 && e.unfinished);
				e.unfinished || this._zr.flush();
			}
		}
	}, t.prototype.getDom = function() {
		return this._dom;
	}, t.prototype.getId = function() {
		return this.id;
	}, t.prototype.getZr = function() {
		return this._zr;
	}, t.prototype.isSSR = function() {
		return this._ssr;
	}, t.prototype.setOption = function(e, t, n) {
		if (!this[GS]) {
			if (this._disposed) this.id;
			else {
				var r, i, a;
				if (W(t) && (n = t.lazyUpdate, r = t.silent, i = t.replaceMerge, a = t.transition, t = t.notMerge), this[GS] = !0, CC(this), !this._model || t) {
					var o = new P_(this._api), s = this._theme, c = this._model = new D_();
					c.scheduler = this._scheduler, c.ssr = this._ssr, c.init(null, null, null, s, this._locale, o);
				}
				this._model.setOption(e, { replaceMerge: i }, jC);
				var l = {
					seriesTransition: a,
					optionChanged: !0
				};
				if (n) this[qS] = {
					silent: r,
					updateParams: l
				}, this[GS] = !1, this.getZr().wakeUp();
				else {
					try {
						aC(this), cC.update.call(this, null, l);
					} catch (e) {
						throw this[qS] = null, this[GS] = !1, e;
					}
					this._ssr || this._zr.flush(), this[qS] = null, this[GS] = !1, fC.call(this, r), pC.call(this, r);
				}
			}
		}
	}, t.prototype.setTheme = function(e, t) {
		if (!this[GS]) {
			if (this._disposed) this.id;
			else {
				var n = this._model;
				if (n) {
					var r = t && t.silent, i = null;
					this[qS] && (r ??= this[qS].silent, i = this[qS].updateParams, this[qS] = null), this[GS] = !0, CC(this);
					try {
						this._updateTheme(e), n.setTheme(this._theme), aC(this), cC.update.call(this, { type: "setTheme" }, i);
					} catch (e) {
						throw this[GS] = !1, e;
					}
					this[GS] = !1, fC.call(this, r), pC.call(this, r);
				}
			}
		}
	}, t.prototype._updateTheme = function(e) {
		U(e) && (e = NC[e]), e && (e = A(e), e && cv(e, !0), this._theme = e);
	}, t.prototype.getModel = function() {
		return this._model;
	}, t.prototype.getOption = function() {
		return this._model && this._model.getOption();
	}, t.prototype.getWidth = function() {
		return this._zr.getWidth();
	}, t.prototype.getHeight = function() {
		return this._zr.getHeight();
	}, t.prototype.getDevicePixelRatio = function() {
		return this._zr.painter.dpr || i.hasGlobalWindow && window.devicePixelRatio || 1;
	}, t.prototype.getRenderedCanvas = function(e) {
		return this.renderToCanvas(e);
	}, t.prototype.renderToCanvas = function(e) {
		return e ||= {}, this._zr.painter.getRenderedCanvas({
			backgroundColor: e.backgroundColor || this._model.get("backgroundColor"),
			pixelRatio: e.pixelRatio || this.getDevicePixelRatio()
		});
	}, t.prototype.renderToSVGString = function(e) {
		return e ||= {}, this._zr.painter.renderToString({ useViewBox: e.useViewBox });
	}, t.prototype.getSvgDataURL = function() {
		var e = this._zr;
		return I(e.storage.getDisplayList(), function(e) {
			e.stopAnimation(null, !0);
		}), e.painter.toDataURL();
	}, t.prototype.getDataURL = function(e) {
		if (this._disposed) this.id;
		else {
			e ||= {};
			var t = e.excludeComponents, n = this._model, r = [], i = this;
			I(t, function(e) {
				n.eachComponent({ mainType: e }, function(e) {
					var t = i._componentsMap[e.__viewId];
					t.group.ignore || (r.push(t), t.group.ignore = !0);
				});
			});
			var a = this._zr.painter.getType() === "svg" ? this.getSvgDataURL() : this.renderToCanvas(e).toDataURL("image/" + (e && e.type || "png"));
			return I(r, function(e) {
				e.group.ignore = !1;
			}), a;
		}
	}, t.prototype.getConnectedDataURL = function(e) {
		if (this._disposed) this.id;
		else {
			var t = e.type === "svg", n = this.group, r = Math.min, i = Math.max, a = Infinity;
			if (IC[n]) {
				var o = a, s = a, c = -a, l = -a, u = [], d = e && e.pixelRatio || this.getDevicePixelRatio();
				I(FC, function(a, d) {
					if (a.group === n) {
						var f = t ? a.getZr().painter.getSvgDom().innerHTML : a.renderToCanvas(A(e)), p = a.getDom().getBoundingClientRect();
						o = r(p.left, o), s = r(p.top, s), c = i(p.right, c), l = i(p.bottom, l), u.push({
							dom: f,
							left: p.left,
							top: p.top
						});
					}
				}), o *= d, s *= d, c *= d, l *= d;
				var p = c - o, m = l - s, h = f.createCanvas(), g = Za(h, { renderer: t ? "svg" : "canvas" });
				if (g.resize({
					width: p,
					height: m
				}), t) {
					var _ = "";
					return I(u, function(e) {
						var t = e.left - o, n = e.top - s;
						_ += "<g transform=\"translate(" + t + "," + n + ")\">" + e.dom + "</g>";
					}), g.painter.getSvgRoot().innerHTML = _, e.connectedBackgroundColor && g.painter.setBackgroundColor(e.connectedBackgroundColor), g.refreshImmediately(), g.painter.toDataURL();
				}
				return e.connectedBackgroundColor && g.add(new bu({
					shape: {
						x: 0,
						y: 0,
						width: p,
						height: m
					},
					style: { fill: e.connectedBackgroundColor }
				})), I(u, function(e) {
					var t = new fu({ style: {
						x: e.left * d - o,
						y: e.top * d - s,
						image: e.dom
					} });
					g.add(t);
				}), g.refreshImmediately(), h.toDataURL("image/" + (e && e.type || "png"));
			}
			return this.getDataURL(e);
		}
	}, t.prototype.convertToPixel = function(e, t, n) {
		return lC(this, "convertToPixel", e, t, n);
	}, t.prototype.convertToLayout = function(e, t, n) {
		return lC(this, "convertToLayout", e, t, n);
	}, t.prototype.convertFromPixel = function(e, t, n) {
		return lC(this, "convertFromPixel", e, t, n);
	}, t.prototype.containPixel = function(e, t) {
		if (this._disposed) this.id;
		else {
			var n = this._model, r;
			return I(ks(n, e), function(e, n) {
				n.indexOf("Models") >= 0 && I(e, function(e) {
					var i = e.coordinateSystem;
					if (i && i.containPoint) r ||= !!i.containPoint(t);
					else if (n === "seriesModels") {
						var a = this._chartsMap[e.__viewId];
						a && a.containPoint && (r ||= a.containPoint(t, e));
					}
				}, this);
			}, this), !!r;
		}
	}, t.prototype.getVisual = function(e, t) {
		var n = this._model, r = ks(n, e, { defaultMainType: "series" }), i = r.seriesModel.getData(), a = r.hasOwnProperty("dataIndexInside") ? r.dataIndexInside : r.hasOwnProperty("dataIndex") ? i.indexOfRawIndex(r.dataIndex) : null;
		return a == null ? tx(i, t) : ex(i, a, t);
	}, t.prototype.getViewOfComponentModel = function(e) {
		return this._componentsMap[e.__viewId];
	}, t.prototype.getViewOfSeriesModel = function(e) {
		return this._chartsMap[e.__viewId];
	}, t.prototype._initEvents = function() {
		var e = this;
		I(EC, function(t) {
			var n = function(n) {
				var r = e.getModel(), i = n.target, a;
				if (t === "globalout" ? a = {} : i && ox(i, function(e) {
					var t = Z(e);
					if (t && t.dataIndex != null) {
						var n = t.dataModel || r.getSeriesByIndex(t.seriesIndex);
						return a = n && n.getDataParams(t.dataIndex, t.dataType, i) || {}, !0;
					}
					if (t.eventData) return a = M({}, t.eventData), !0;
				}, !0), a) {
					var o = a.componentType, s = a.componentIndex;
					(o === "markLine" || o === "markPoint" || o === "markArea") && (o = "series", s = a.seriesIndex);
					var c = o && s != null && r.getComponent(o, s), l = c && e[c.mainType === "series" ? "_chartsMap" : "_componentsMap"][c.__viewId];
					a.event = n, a.type = t, e._$eventProcessor.eventInfo = {
						targetEl: i,
						packedEvent: a,
						model: c,
						view: l
					}, e.trigger(t, a);
				}
			};
			n.zrEventfulCallAtLast = !0, e._zr.on(t, n, e);
		});
		var t = this._messageCenter;
		I(kC, function(n, r) {
			t.on(r, function(t) {
				e.trigger(r, t);
			});
		}), ax(t, this, this._api);
	}, t.prototype.isDisposed = function() {
		return this._disposed;
	}, t.prototype.clear = function() {
		this._disposed ? this.id : this.setOption({ series: [] }, !0);
	}, t.prototype.dispose = function() {
		if (this._disposed) this.id;
		else {
			this._disposed = !0, this.getDom() && Fs(this.getDom(), zC, "");
			var e = this, t = e._api, n = e._model;
			I(e._componentsViews, function(e) {
				e.dispose(n, t);
			}), I(e._chartsViews, function(e) {
				e.dispose(n, t);
			}), e._zr.dispose(), e._dom = e._model = e._chartsMap = e._componentsMap = e._chartsViews = e._componentsViews = e._scheduler = e._api = e._zr = e._throttledZrFlush = e._theme = e._coordSysMgr = e._messageCenter = null, delete FC[e.id];
		}
	}, t.prototype.resize = function(e) {
		if (!this[GS]) {
			if (this._disposed) this.id;
			else {
				this._zr.resize(e);
				var t = this._model;
				if (this._loadingFX && this._loadingFX.resize(), t) {
					var n = t.resetOption("media"), r = e && e.silent;
					this[qS] && (r ??= this[qS].silent, n = !0, this[qS] = null), this[GS] = !0, CC(this);
					try {
						n && aC(this), cC.update.call(this, {
							type: "resize",
							animation: M({ duration: 0 }, e && e.animation)
						});
					} catch (e) {
						throw this[GS] = !1, e;
					}
					this[GS] = !1, fC.call(this, r), pC.call(this, r);
				}
			}
		}
	}, t.prototype.showLoading = function(e, t) {
		if (this._disposed) this.id;
		else if (W(e) && (t = e, e = ""), e ||= "default", this.hideLoading(), PC[e]) {
			var n = PC[e](this._api, t), r = this._zr;
			this._loadingFX = n, r.add(n);
		}
	}, t.prototype.hideLoading = function() {
		this._disposed ? this.id : (this._loadingFX && this._zr.remove(this._loadingFX), this._loadingFX = null);
	}, t.prototype.makeActionFromEvent = function(e) {
		var t = M({}, e);
		return t.type = OC[e.type], t;
	}, t.prototype.dispatchAction = function(e, t) {
		if (this._disposed) this.id;
		else if (W(t) || (t = { silent: !!t }), DC[e.type] && this._model) {
			if (this[GS]) this._pendingActions.push(e);
			else {
				var n = t.silent;
				dC.call(this, e, n);
				var r = t.flush;
				r ? this._zr.flush() : r !== !1 && i.browser.weChat && this._throttledZrFlush(), fC.call(this, n), pC.call(this, n);
			}
		}
	}, t.prototype.updateLabelLayout = function() {
		sx.trigger("series:layoutlabels", this._model, this._api, { updatedSeries: [] });
	}, t.prototype.appendData = function(e) {
		if (this._disposed) this.id;
		else {
			var t = e.seriesIndex;
			this.getModel().getSeriesByIndex(t).appendData(e), this._scheduler.unfinished = !0, this.getZr().wakeUp();
		}
	}, t.internalField = function() {
		aC = function(e) {
			mx(e._model);
			var t = e._scheduler;
			t.restorePipelines(e._zr, e._model), t.prepareStageTasks(), oC(e, !0), oC(e, !1), t.plan();
		}, oC = function(e, t) {
			for (var n = e._model, r = e._scheduler, i = t ? e._componentsViews : e._chartsViews, a = t ? e._componentsMap : e._chartsMap, o = e._zr, s = e._api, c = 0; c < i.length; c++) i[c].__alive = !1;
			t ? n.eachComponent(function(e, t) {
				e !== "series" && l(t);
			}) : n.eachSeries(l);
			function l(e) {
				var c = e.__requireNewView;
				e.__requireNewView = !1;
				var l = "_ec_" + e.id + "_" + e.type, u = !c && a[l];
				if (!u) {
					var d = oc(e.type);
					u = new (t ? rb.getClass(d.main, d.sub) : sb.getClass(d.sub))(), u.init(n, s), a[l] = u, i.push(u), o.add(u.group);
				}
				e.__viewId = u.__id = l, u.__alive = !0, u.__model = e, u.group.__ecComponentInfo = {
					mainType: e.mainType,
					index: e.componentIndex
				}, !t && r.prepareView(u, e, n, s);
			}
			for (var c = 0; c < i.length;) {
				var u = i[c];
				u.__alive ? c++ : (!t && u.renderTask.dispose(), o.remove(u.group), u.dispose(n, s), i.splice(c, 1), a[u.__id] === u && delete a[u.__id], u.__id = u.group.__ecComponentInfo = null);
			}
		}, sC = function(e, t, n, r, i) {
			var a = e._model;
			if (a.setUpdatePayload(n), !r) {
				I([].concat(e._componentsViews, e._chartsViews), l);
				return;
			}
			var o = Ps(n, r, i), s = n.excludeSeriesId, c;
			s != null && (c = K(), I(ss(s), function(e) {
				var t = xs(e, null);
				t != null && c.set(t, !0);
			})), a && a.eachComponent(o, function(t) {
				if (!(c && c.get(t.id) != null)) {
					if (nf(n)) {
						if (t instanceof Jy) n.type === "highlight" && !n.notBlur && !t.get(["emphasis", "disabled"]) && Rd(t, n, e._api);
						else {
							var r = zd(t.mainType, t.componentIndex, n.name, e._api), i = r.focusSelf, a = r.dispatchers;
							n.type === "highlight" && i && !n.notBlur && Ld(t.mainType, t.componentIndex, e._api), a && I(a, function(e) {
								n.type === "highlight" ? Od(e) : kd(e);
							});
						}
					} else tf(n) && t instanceof Jy && (Hd(t, n, e._api), Ud(t), xC(e));
				}
			}, e), a && a.eachComponent(o, function(t) {
				c && c.get(t.id) != null || l(e[r === "series" ? "_chartsMap" : "_componentsMap"][t.__viewId]);
			}, e);
			function l(r) {
				r && r.__alive && r[t] && r[t](r.__model, a, e._api, n);
			}
		}, cC = {
			prepareAndUpdate: function(e) {
				aC(this), cC.update.call(this, e, e && { optionChanged: e.newOption != null });
			},
			update: function(e, n) {
				var r = this._model, i = this._api, a = this._zr, o = this._coordSysMgr, s = this._scheduler;
				if (r) {
					hx(r), r.setUpdatePayload(e), s.restoreData(r, e), s.performSeriesTasks(r), o.create(r, i), sx.trigger("coordsys:aftercreate", r, i), s.performDataProcessorTasks(r, e), uC(this, r), o.update(r, i), t(r), s.performVisualTasks(r, e);
					var c = r.get("backgroundColor") || "transparent";
					a.setBackgroundColor(c);
					var l = r.get("darkMode");
					l != null && l !== "auto" && a.setDarkMode(l), gC(this, r, i, e, n), sx.trigger("afterupdate", r, i);
				}
			},
			updateTransform: function(e) {
				var t = this, n = t._model, r = t._api;
				if (n) {
					n.setUpdatePayload(e);
					var i = [];
					n.eachComponent(function(a, o) {
						if (a !== "series") {
							var s = t.getViewOfComponentModel(o);
							if (s && s.__alive) {
								if (s.updateTransform) {
									var c = s.updateTransform(o, n, r, e);
									c && c.update && i.push(s);
								} else i.push(s);
							}
						}
					});
					var a = K();
					n.eachSeries(function(i) {
						var o = t._chartsMap[i.__viewId], s = i.pipelineContext;
						if (o.updateTransform && !s.progressiveRender) {
							var c = o.updateTransform(i, n, r, e);
							c && c.update && a.set(i.uid, 1);
						} else a.set(i.uid, 1);
					}), t._scheduler.performVisualTasks(n, e, {
						setDirty: !0,
						dirtyMap: a
					}), vC(t, n, r, e, {}, a), sx.trigger("afterupdate", n, r);
				}
			},
			updateView: function(e) {
				var n = this._model;
				n && (n.setUpdatePayload(e), sb.markUpdateMethod(e, "updateView"), t(n), this._scheduler.performVisualTasks(n, e, { setDirty: !0 }), gC(this, n, this._api, e, {}), sx.trigger("afterupdate", n, this._api));
			},
			updateVisual: function(e) {
				var n = this, r = this._model;
				r && (r.setUpdatePayload(e), r.eachSeries(function(e) {
					e.getData().clearAllVisual();
				}), sb.markUpdateMethod(e, "updateVisual"), t(r), this._scheduler.performVisualTasks(r, e, {
					visualType: "visual",
					setDirty: !0
				}), r.eachComponent(function(t, i) {
					if (t !== "series") {
						var a = n.getViewOfComponentModel(i);
						a && a.__alive && a.updateVisual(i, r, n._api, e);
					}
				}), r.eachSeries(function(t) {
					n._chartsMap[t.__viewId].updateVisual(t, r, n._api, e);
				}), sx.trigger("afterupdate", r, this._api));
			},
			updateLayout: function(e) {
				cC.update.call(this, e);
			}
		};
		function e(e, t, n, r, i) {
			if (e._disposed) e.id;
			else for (var a = e._model, o = e._coordSysMgr.getCoordinateSystems(), s, c = ks(a, n), l = 0; l < o.length; l++) {
				var u = o[l];
				if (u[t] && (s = u[t](a, c, r, i)) != null) return s;
			}
		}
		lC = e, uC = function(e, t) {
			var n = e._chartsMap, r = e._scheduler;
			t.eachSeries(function(e) {
				r.updateStreamModes(e, n[e.__viewId]);
			});
		}, dC = function(e, t) {
			var n = this, r = this.getModel(), i = e.type, a = e.escapeConnect, o = DC[i], s = (o.update || "update").split(":"), c = s.pop(), l = s[0] != null && oc(s[0]);
			this[GS] = !0, CC(this);
			var u = [e], d = !1;
			e.batch && (d = !0, u = L(e.batch, function(t) {
				return t = N(M({}, t), e), t.batch = null, t;
			}));
			var f = [], p, m = [], h = o.nonRefinedEventType, g = tf(e), _ = nf(e);
			if (_ && Fd(this._api), I(u, function(t) {
				var i = o.action(t, r, n._api);
				if (o.refineEvent ? m.push(i) : p = i, p ||= M({}, t), p.type = h, f.push(p), _) {
					var a = As(e), s = a.queryOptionMap, u = a.mainTypeSpecified ? s.keys()[0] : "series";
					sC(n, c, t, u), xC(n);
				} else g ? (sC(n, c, t, "series"), xC(n)) : l && sC(n, c, t, l.main, l.sub);
			}), c !== "none" && !_ && !g && !l) try {
				this[qS] ? (aC(this), cC.update.call(this, e), this[qS] = null) : cC[c].call(this, e);
			} catch (e) {
				throw this[GS] = !1, e;
			}
			if (p = d ? {
				type: h,
				escapeConnect: a,
				batch: f
			} : f[0], this[GS] = !1, !t) {
				var v = void 0;
				if (o.refineEvent) {
					var y = o.refineEvent(m, e, r, this._api).eventContent;
					Se(W(y)), v = N({ type: o.refinedEventType }, y), v.fromAction = e.type, v.fromActionPayload = e, v.escapeConnect = !0;
				}
				var b = this._messageCenter;
				b.trigger(p.type, p), v && b.trigger(v.type, v);
			}
		}, fC = function(e) {
			for (var t = this._pendingActions; t.length;) {
				var n = t.shift();
				dC.call(this, n, e);
			}
		}, pC = function(e) {
			!e && this.trigger("updated");
		}, mC = function(e, t) {
			e.on("rendered", function(n) {
				t.trigger("rendered", n), e.animation.isFinished() && !t[qS] && !t._scheduler.unfinished && !t._pendingActions.length ? t.trigger("finished") : e.refresh();
			});
		}, hC = function(e, t) {
			e.on("mouseover", function(e) {
				var n = e.target, r = ox(n, $d);
				r && (Bd(r, e, t._api), xC(t));
			}).on("mouseout", function(e) {
				var n = e.target, r = ox(n, $d);
				r && (Vd(r, e, t._api), xC(t));
			}).on("click", function(e) {
				var n = e.target, r = ox(n, function(e) {
					return Z(e).dataIndex != null;
				}, !0);
				if (r) {
					var i = r.selected ? "unselect" : "select", a = Z(r);
					t._api.dispatchAction({
						type: i,
						dataType: a.dataType,
						dataIndexInside: a.dataIndex,
						seriesIndex: a.seriesIndex,
						isFromClick: !0
					});
				}
			});
		};
		function t(e) {
			e.clearColorPalette(), e.eachSeries(function(e) {
				e.clearColorPalette();
			});
		}
		function r(e) {
			var t = [], n = [], r = !1;
			if (e.eachComponent(function(e, i) {
				var a = i.get("zlevel") || 0, o = i.get("z") || 0, s = i.getZLevelKey();
				r ||= !!s, (e === "series" ? n : t).push({
					zlevel: a,
					z: o,
					idx: i.componentIndex,
					type: e,
					key: s
				});
			}), r) {
				var i = t.concat(n), a, o;
				Un(i, function(e, t) {
					return e.zlevel === t.zlevel ? e.z - t.z : e.zlevel - t.zlevel;
				}), I(i, function(t) {
					var n = e.getComponent(t.type, t.idx), r = t.zlevel, i = t.key;
					a != null && (r = Math.max(a, r)), i ? (r === a && i !== o && r++, o = i) : o &&= (r === a && r++, ""), a = r, n.setZLevel(r);
				});
			}
		}
		gC = function(e, t, n, i, a) {
			r(t), _C(e, t, n, i, a), I(e._chartsViews, function(e) {
				e.__alive = !1;
			}), vC(e, t, n, i, a), I(e._chartsViews, function(e) {
				e.__alive || e.remove(t, n);
			});
		}, _C = function(e, t, n, r, i, a) {
			I(a || e._componentsViews, function(e) {
				var i = e.__model;
				l(i, e), e.render(i, t, n, r), c(i, e), u(i, e);
			});
		}, vC = function(e, t, n, r, i, a) {
			var d = e._scheduler;
			i = M(i || {}, { updatedSeries: t.getSeries() }), sx.trigger("series:beforeupdate", t, n, i);
			var f = !1;
			t.eachSeries(function(t) {
				var n = e._chartsMap[t.__viewId];
				n.__alive = !0;
				var i = n.renderTask;
				d.updatePayload(i, r), l(t, n), a && a.get(t.uid) && i.dirty(), i.perform(d.getPerformArgs(i)) && (f = !0), n.group.silent = !!t.get("silent"), s(t, n), Ud(t);
			}), d.unfinished = f || d.unfinished, sx.trigger("series:layoutlabels", t, n, i), sx.trigger("series:transition", t, n, i), t.eachSeries(function(t) {
				var n = e._chartsMap[t.__viewId];
				c(t, n), u(t, n);
			}), o(e, t), sx.trigger("series:afterupdate", t, n, i);
		}, xC = function(e) {
			e[JS] = !0, e.getZr().wakeUp();
		}, CC = function(e) {
			e[KS] = (e[KS] + 1) % 1e6;
		}, SC = function(e) {
			e[JS] && (e.getZr().storage.traverse(function(e) {
				jp(e) || a(e);
			}), e[JS] = !1);
		};
		function a(e) {
			for (var t = [], n = e.currentStates, r = 0; r < n.length; r++) {
				var i = n[r];
				i !== "emphasis" && i !== "blur" && i !== "select" && t.push(i);
			}
			e.selected && e.states.select && t.push("select"), e.hoverState === 2 && e.states.emphasis ? t.push("emphasis") : e.hoverState === 1 && e.states.blur && t.push("blur"), e.useStates(t);
		}
		function o(e, t) {
			var n = e._zr;
			if (n.painter.type === "canvas") {
				var r = n.storage, a = 0;
				r.traverse(function(e) {
					e.isGroup || a++;
				});
				var o = a > G(t.get("hoverLayerThreshold"), r_.hoverLayerThreshold) && !i.node && !i.worker;
				(e._usingTHL || o) && (t.eachSeries(function(t) {
					if (!t.preventUsingHoverLayer) {
						var n = e._chartsMap[t.__viewId];
						n.__alive && n.eachRendered(function(e) {
							var t = e.states.emphasis;
							t && t.hoverLayer !== 2 && (t.hoverLayer = +!!o);
						});
					}
				}), e._usingTHL = o);
			}
		}
		function s(e, t) {
			var n = e.get("blendMode") || null;
			t.eachRendered(function(e) {
				e.isGroup || (e.style.blend = n);
			});
		}
		function c(e, t) {
			if (!e.preventAutoZ) {
				var n = Sm(e);
				t.eachRendered(function(e) {
					return wm(e, n.z, n.zlevel), !0;
				});
			}
		}
		function l(e, t) {
			t.eachRendered(function(e) {
				if (!jp(e)) {
					var t = e.getTextContent(), n = e.getTextGuideLine();
					e.stateTransition &&= null, t && t.stateTransition && (t.stateTransition = null), n && n.stateTransition && (n.stateTransition = null), e.hasState() ? (e.prevStates = e.currentStates, e.clearStates()) : e.prevStates &&= null;
				}
			});
		}
		function u(e, t) {
			var n = e.getModel("stateAnimation"), r = e.isAnimationEnabled(), i = n.get("duration"), o = i > 0 ? {
				duration: i,
				delay: n.get("delay"),
				easing: n.get("easing")
			} : null;
			t.eachRendered(function(e) {
				if (e.states && e.states.emphasis) {
					if (jp(e)) return;
					if (e instanceof ou && rf(e), e.__dirty) {
						var t = e.prevStates;
						t && e.useStates(t);
					}
					if (r) {
						e.stateTransition = o;
						var n = e.getTextContent(), i = e.getTextGuideLine();
						n && (n.stateTransition = o), i && (i.stateTransition = o);
					}
					e.__dirty && a(e);
				}
			});
		}
		yC = function(e) {
			return new (function(t) {
				n(r, t);
				function r() {
					return t !== null && t.apply(this, arguments) || this;
				}
				return r.prototype.getCoordinateSystems = function() {
					return e._coordSysMgr.getCoordinateSystems();
				}, r.prototype.getComponentByElement = function(t) {
					for (; t;) {
						var n = t.__ecComponentInfo;
						if (n != null) return e._model.getComponent(n.mainType, n.index);
						t = t.parent;
					}
				}, r.prototype.enterEmphasis = function(t, n) {
					Od(t, n), xC(e);
				}, r.prototype.leaveEmphasis = function(t, n) {
					kd(t, n), xC(e);
				}, r.prototype.enterBlur = function(t) {
					Ad(t), xC(e);
				}, r.prototype.leaveBlur = function(t) {
					jd(t), xC(e);
				}, r.prototype.enterSelect = function(t) {
					Md(t), xC(e);
				}, r.prototype.leaveSelect = function(t) {
					Nd(t), xC(e);
				}, r.prototype.getModel = function() {
					return e.getModel();
				}, r.prototype.getViewOfComponentModel = function(t) {
					return e.getViewOfComponentModel(t);
				}, r.prototype.getViewOfSeriesModel = function(t) {
					return e.getViewOfSeriesModel(t);
				}, r.prototype.getECUpdateCycleVersion = function() {
					return e[KS];
				}, r.prototype.usingTHL = function() {
					return e._usingTHL;
				}, r;
			}(Yu))(e);
		}, bC = function(e) {
			function t(e, t) {
				for (var n = 0; n < e.length; n++) {
					var r = e[n];
					r[XS] = t;
				}
			}
			I(OC, function(n, r) {
				e._messageCenter.on(r, function(n) {
					if (IC[e.group] && e[XS] !== ZS) {
						if (n && n.escapeConnect) return;
						var r = e.makeActionFromEvent(n), i = [];
						I(FC, function(t) {
							t !== e && t.group === e.group && i.push(t);
						}), t(i, ZS), I(i, function(e) {
							e[XS] !== QS && e.dispatchAction(r);
						}), t(i, $S);
					}
				});
			});
		};
	}(), t;
}(dt), TC = wC.prototype;
TC.on = eC("on"), TC.off = eC("off"), TC.one = function(e, t, n) {
	var r = this;
	function i() {
		var n = [...arguments];
		t && t.apply && t.apply(this, n), r.off(e, i);
	}
	this.on.call(this, e, i, n);
};
var EC = [
	"click",
	"dblclick",
	"mouseover",
	"mouseout",
	"mousemove",
	"mousedown",
	"mouseup",
	"globalout",
	"contextmenu"
], DC = {}, OC = {}, kC = {}, AC = [], jC = [], MC = [], NC = {}, PC = {}, FC = {}, IC = {}, LC = /* @__PURE__ */ new Date() - 0, RC = /* @__PURE__ */ new Date() - 0, zC = "_echarts_instance_";
function BC(e, t, n) {
	var r = !(n && n.ssr);
	if (r) {
		var i = GC(e);
		if (i) return i;
	}
	var a = new wC(e, t, n);
	return a.id = "ec_" + LC++, FC[a.id] = a, r && Fs(e, zC, a.id), bC(a), sx.trigger("afterinit", a), a;
}
function VC(e) {
	if (V(e)) {
		var t = e;
		e = null, I(t, function(t) {
			t.group != null && (e = t.group);
		}), e ||= "g_" + RC++, I(t, function(t) {
			t.group = e;
		});
	}
	return IC[e] = !0, e;
}
function HC(e) {
	IC[e] = !1;
}
var UC = HC;
function WC(e) {
	U(e) ? e = FC[e] : e instanceof wC || (e = GC(e)), e instanceof wC && !e.isDisposed() && e.dispose();
}
function GC(e) {
	return FC[Is(e, zC)];
}
function KC(e) {
	return FC[e];
}
function qC(e, t) {
	NC[e] = t;
}
function JC(e) {
	P(jC, e) < 0 && jC.push(e);
}
function YC(e, t) {
	ow(AC, e, t, MS);
}
function XC(e) {
	QC("afterinit", e);
}
function ZC(e) {
	QC("afterupdate", e);
}
function QC(e, t) {
	sx.on(e, t);
}
function $C(e, t, n) {
	var r, i, a, o, s;
	H(t) && (n = t, t = ""), W(e) ? (r = e.type, i = e.event, o = e.update, s = e.publishNonRefinedEvent, n ||= e.action, a = e.refineEvent) : (r = e, i = t);
	function c(e) {
		return e.toLowerCase();
	}
	i = c(i || r);
	var l = a ? c(r) : i;
	DC[r] || (Se(YS.test(r) && YS.test(i)), a && Se(i !== r), DC[r] = {
		actionType: r,
		refinedEventType: i,
		nonRefinedEventType: l,
		update: o,
		action: n,
		refineEvent: a
	}, kC[i] = 1, a && s && (kC[l] = 1), OC[l] = r);
}
function ew(e, t) {
	wg.register(e, t);
}
function tw(e) {
	var t = wg.get(e);
	if (t) return t.getDimensionsInfo ? t.getDimensionsInfo() : t.dimensions.slice();
}
function nw(e, t) {
	fx(e, t);
}
function rw(e, t) {
	ow(MC, e, t, PS, "layout", !0);
}
function iw(e, t) {
	ow(MC, e, t, LS, "visual", !0);
}
var aw = [];
function ow(e, t, n, r, i, a) {
	if ((H(t) || W(t)) && (n = t, t = r), !(P(aw, n) >= 0)) {
		aw.push(n);
		var o = Ab.wrapStageHandler(n, i);
		o.__prio = t, o.__raw = n, e.push(o);
	}
}
function sw(e, t) {
	PC[e] = t;
}
function cw(e) {
	p({ createCanvas: e });
}
function lw(e, t, n) {
	var r = ux("registerMap");
	r && r(e, t, n);
}
function uw(e) {
	var t = ux("getMap");
	return t && t(e);
}
var dw = oy;
iw(IS, wb), iw(zS, Eb), iw(zS, Db), iw(IS, Qb), iw(zS, $b), iw(US, CS), JC(cv), YC(kS, lv), sw("default", kb), $C({
	type: rd,
	event: rd,
	update: rd
}, Pe), $C({
	type: id,
	event: id,
	update: id
}, Pe), $C({
	type: ad,
	event: cd,
	update: ad,
	action: Pe,
	refineEvent: fw,
	publishNonRefinedEvent: !0
}), $C({
	type: od,
	event: cd,
	update: od,
	action: Pe,
	refineEvent: fw,
	publishNonRefinedEvent: !0
}), $C({
	type: sd,
	event: cd,
	update: sd,
	action: Pe,
	refineEvent: fw,
	publishNonRefinedEvent: !0
});
function fw(e, t, n, r) {
	return { eventContent: {
		selected: Wd(n),
		isFromClick: t.isFromClick || !1
	} };
}
qC("default", {}), qC("dark", Jb);
var pw = {};
//#endregion
//#region node_modules/echarts/lib/data/DataDiffer.js
function mw(e) {
	return e == null ? 0 : e.length || 1;
}
function hw(e) {
	return e;
}
var gw = function() {
	function e(e, t, n, r, i, a) {
		this._old = e, this._new = t, this._oldKeyGetter = n || hw, this._newKeyGetter = r || hw, this.context = i, this._diffModeMultiple = a === "multiple";
	}
	return e.prototype.add = function(e) {
		return this._add = e, this;
	}, e.prototype.update = function(e) {
		return this._update = e, this;
	}, e.prototype.updateManyToOne = function(e) {
		return this._updateManyToOne = e, this;
	}, e.prototype.updateOneToMany = function(e) {
		return this._updateOneToMany = e, this;
	}, e.prototype.updateManyToMany = function(e) {
		return this._updateManyToMany = e, this;
	}, e.prototype.remove = function(e) {
		return this._remove = e, this;
	}, e.prototype.execute = function() {
		this[this._diffModeMultiple ? "_executeMultiple" : "_executeOneToOne"]();
	}, e.prototype._executeOneToOne = function() {
		var e = this._old, t = this._new, n = {}, r = Array(e.length), i = Array(t.length);
		this._initIndexMap(e, null, r, "_oldKeyGetter"), this._initIndexMap(t, n, i, "_newKeyGetter");
		for (var a = 0; a < e.length; a++) {
			var o = r[a], s = n[o], c = mw(s);
			if (c > 1) {
				var l = s.shift();
				s.length === 1 && (n[o] = s[0]), this._update && this._update(l, a);
			} else c === 1 ? (n[o] = null, this._update && this._update(s, a)) : this._remove && this._remove(a);
		}
		this._performRestAdd(i, n);
	}, e.prototype._executeMultiple = function() {
		var e = this._old, t = this._new, n = {}, r = {}, i = [], a = [];
		this._initIndexMap(e, n, i, "_oldKeyGetter"), this._initIndexMap(t, r, a, "_newKeyGetter");
		for (var o = 0; o < i.length; o++) {
			var s = i[o], c = n[s], l = r[s], u = mw(c), d = mw(l);
			if (u > 1 && d === 1) this._updateManyToOne && this._updateManyToOne(l, c), r[s] = null;
			else if (u === 1 && d > 1) this._updateOneToMany && this._updateOneToMany(l, c), r[s] = null;
			else if (u === 1 && d === 1) this._update && this._update(l, c), r[s] = null;
			else if (u > 1 && d > 1) this._updateManyToMany && this._updateManyToMany(l, c), r[s] = null;
			else if (u > 1) for (var f = 0; f < u; f++) this._remove && this._remove(c[f]);
			else this._remove && this._remove(c);
		}
		this._performRestAdd(a, r);
	}, e.prototype._performRestAdd = function(e, t) {
		for (var n = 0; n < e.length; n++) {
			var r = e[n], i = t[r], a = mw(i);
			if (a > 1) for (var o = 0; o < a; o++) this._add && this._add(i[o]);
			else a === 1 && this._add && this._add(i);
			t[r] = null;
		}
	}, e.prototype._initIndexMap = function(e, t, n, r) {
		for (var i = this._diffModeMultiple, a = 0; a < e.length; a++) {
			var o = "_ec_" + this[r](e[a], a);
			if (i || (n[a] = o), t) {
				var s = t[o], c = mw(s);
				c === 0 ? (t[o] = a, i && n.push(o)) : c === 1 ? t[o] = [s, a] : s.push(a);
			}
		}
	}, e;
}(), _w = function() {
	function e(e, t) {
		this._encode = e, this._schema = t;
	}
	return e.prototype.get = function() {
		return {
			fullDimensions: this._getFullDimensionNames(),
			encode: this._encode
		};
	}, e.prototype._getFullDimensionNames = function() {
		return this._cachedDimNames ||= this._schema ? this._schema.makeOutputDimensionNames() : [], this._cachedDimNames;
	}, e;
}();
function vw(e, t) {
	var n = {}, r = n.encode = {}, i = K(), a = [], o = [], s = {};
	I(e.dimensions, function(t) {
		var n = e.getDimensionInfo(t), c = n.coordDim;
		if (c) {
			var l = n.coordDimIndex;
			yw(r, c)[l] = t, n.isExtraCoord || (i.set(c, 1), xw(n.type) && (a[0] = t), yw(s, c)[l] = e.getDimensionIndex(n.name)), n.defaultTooltip && o.push(t);
		}
		Bu.each(function(e, t) {
			var i = yw(r, t), a = n.otherDims[t];
			a != null && a !== !1 && (i[a] = n.name);
		});
	});
	var c = [], l = {};
	i.each(function(e, t) {
		var n = r[t];
		l[t] = n[0], c = c.concat(n);
	}), n.dataDimsOnCoord = c, n.dataDimIndicesOnCoord = L(c, function(t) {
		return e.getDimensionInfo(t).storeDimIndex;
	}), n.encodeFirstDimNotExtra = l;
	var u = r.label;
	u && u.length && (a = u.slice());
	var d = r.tooltip;
	return d && d.length ? o = d.slice() : o.length || (o = a.slice()), r.defaultedLabel = a, r.defaultedTooltip = o, n.userOutput = new _w(s, t), n;
}
function yw(e, t) {
	return e.hasOwnProperty(t) || (e[t] = []), e[t];
}
function bw(e) {
	return e === "category" ? "ordinal" : e === "time" ? "time" : "float";
}
function xw(e) {
	return e !== "ordinal" && e !== "time";
}
//#endregion
//#region node_modules/echarts/lib/data/SeriesDimensionDefine.js
var Sw = function() {
	function e(e) {
		this.otherDims = {}, e != null && M(this, e);
	}
	return e;
}(), Cw = X(), ww = {
	float: "f",
	int: "i",
	ordinal: "o",
	number: "n",
	time: "t"
}, Tw = function() {
	function e(e) {
		this.dimensions = e.dimensions, this._dimOmitted = e.dimensionOmitted, this.source = e.source, this._fullDimCount = e.fullDimensionCount, this._updateDimOmitted(e.dimensionOmitted);
	}
	return e.prototype.isDimensionOmitted = function() {
		return this._dimOmitted;
	}, e.prototype._updateDimOmitted = function(e) {
		this._dimOmitted = e, e && (this._dimNameMap ||= Ow(this.source));
	}, e.prototype.getSourceDimensionIndex = function(e) {
		return G(this._dimNameMap.get(e), -1);
	}, e.prototype.getSourceDimension = function(e) {
		var t = this.source.dimensionsDefine;
		if (t) return t[e];
	}, e.prototype.makeStoreSchema = function() {
		for (var e = this._fullDimCount, t = Sv(this.source), n = !kw(e), r = "", i = [], a = 0, o = 0; a < e; a++) {
			var s = void 0, c = void 0, l = void 0, u = this.dimensions[o];
			if (u && u.storeDimIndex === a) s = t ? u.name : null, c = u.type, l = u.ordinalMeta, o++;
			else {
				var d = this.getSourceDimension(a);
				d && (s = t ? d.name : null, c = d.type);
			}
			i.push({
				property: s,
				type: c,
				ordinalMeta: l
			}), t && s != null && (!u || !u.isCalculationCoord) && (r += n ? s.replace(/\`/g, "`1").replace(/\$/g, "`2") : s), r += "$", r += ww[c] || "f", l && (r += l.uid), r += "$";
		}
		var f = this.source;
		return {
			dimensions: i,
			hash: [
				f.seriesLayoutBy,
				f.startIndex,
				r
			].join("$$")
		};
	}, e.prototype.makeOutputDimensionNames = function() {
		for (var e = [], t = 0, n = 0; t < this._fullDimCount; t++) {
			var r = void 0, i = this.dimensions[n];
			if (i && i.storeDimIndex === t) i.isCalculationCoord || (r = i.name), n++;
			else {
				var a = this.getSourceDimension(t);
				a && (r = a.name);
			}
			e.push(r);
		}
		return e;
	}, e.prototype.appendCalculationDimension = function(e) {
		this.dimensions.push(e), e.isCalculationCoord = !0, this._fullDimCount++, this._updateDimOmitted(!0);
	}, e;
}();
function Ew(e) {
	return e instanceof Tw;
}
function Dw(e) {
	for (var t = K(), n = 0; n < (e || []).length; n++) {
		var r = e[n], i = W(r) ? r.name : r;
		i != null && t.get(i) == null && t.set(i, n);
	}
	return t;
}
function Ow(e) {
	var t = Cw(e);
	return t.dimNameMap ||= Dw(e.dimensionsDefine);
}
function kw(e) {
	return e > 30;
}
//#endregion
//#region node_modules/echarts/lib/data/SeriesData.js
var Aw = W, jw = L, Mw = typeof Int32Array > "u" ? Array : Int32Array, Nw = "e\0\0", Pw = -1, Fw = [
	"hasItemOption",
	"_nameList",
	"_idList",
	"_invertedIndicesMap",
	"_dimSummary",
	"userOutput",
	"_rawData",
	"_dimValueGetter",
	"_nameDimIdx",
	"_idDimIdx",
	"_nameRepeatCount"
], Iw = ["_approximateExtent"], Lw, Rw, zw, Bw, Vw, Hw, Uw, Ww = function() {
	function e(e, t) {
		this.type = "list", this._dimOmitted = !1, this._nameList = [], this._idList = [], this._visual = {}, this._layout = {}, this._itemVisuals = [], this._itemLayouts = [], this._graphicEls = [], this._approximateExtent = {}, this._calculationInfo = {}, this.hasItemOption = !1, this.TRANSFERABLE_METHODS = [
			"cloneShallow",
			"downSample",
			"minmaxDownSample",
			"lttbDownSample",
			"map"
		], this.CHANGABLE_METHODS = ["filterSelf", "selectRange"], this.DOWNSAMPLE_METHODS = [
			"downSample",
			"minmaxDownSample",
			"lttbDownSample"
		];
		var n, r = !1;
		Ew(e) ? (n = e.dimensions, this._dimOmitted = e.isDimensionOmitted(), this._schema = e) : (r = !0, n = e), n ||= ["x", "y"];
		for (var i = {}, a = [], o = {}, s = !1, c = {}, l = 0; l < n.length; l++) {
			var u = n[l], d = U(u) ? new Sw({ name: u }) : u instanceof Sw ? u : new Sw(u), f = d.name;
			d.type = d.type || "float", d.coordDim || (d.coordDim = f, d.coordDimIndex = 0);
			var p = d.otherDims = d.otherDims || {};
			a.push(f), i[f] = d, c[f] != null && (s = !0), d.createInvertedIndices && (o[f] = []), r && (d.storeDimIndex = l), p.itemName === 0 && (this._nameDimIdx = d.storeDimIndex), p.itemId === 0 && (this._idDimIdx = d.storeDimIndex);
		}
		if (this.dimensions = a, this._dimInfos = i, this._initGetDimensionInfo(s), this.hostModel = t, this._invertedIndicesMap = o, this._dimOmitted) {
			var m = this._dimIdxToName = K();
			I(a, function(e) {
				m.set(i[e].storeDimIndex, e);
			});
		}
	}
	return e.prototype.getDimension = function(e) {
		var t = this._recognizeDimIndex(e);
		if (t == null) return e;
		if (t = e, !this._dimOmitted) return this.dimensions[t];
		var n = this._dimIdxToName.get(t);
		if (n != null) return n;
		var r = this._schema.getSourceDimension(t);
		if (r) return r.name;
	}, e.prototype.getDimensionIndex = function(e) {
		var t = this._recognizeDimIndex(e);
		if (t != null) return t;
		if (e == null) return -1;
		var n = this._getDimInfo(e);
		return n ? n.storeDimIndex : this._dimOmitted ? this._schema.getSourceDimensionIndex(e) : -1;
	}, e.prototype._recognizeDimIndex = function(e) {
		if (ue(e) || e != null && !isNaN(e) && !this._getDimInfo(e) && (!this._dimOmitted || this._schema.getSourceDimensionIndex(e) < 0)) return +e;
	}, e.prototype._getStoreDimIndex = function(e) {
		return this.getDimensionIndex(e);
	}, e.prototype.getDimensionInfo = function(e) {
		return this._getDimInfo(this.getDimension(e));
	}, e.prototype._initGetDimensionInfo = function(e) {
		var t = this._dimInfos;
		this._getDimInfo = e ? function(e) {
			return t.hasOwnProperty(e) ? t[e] : void 0;
		} : function(e) {
			return t[e];
		};
	}, e.prototype.getDimensionsOnCoord = function() {
		return this._dimSummary.dataDimsOnCoord.slice();
	}, e.prototype.mapDimension = function(e, t) {
		var n = this._dimSummary;
		if (t == null) return n.encodeFirstDimNotExtra[e];
		var r = n.encode[e];
		return r ? r[t] : null;
	}, e.prototype.mapDimensionsAll = function(e) {
		return (this._dimSummary.encode[e] || []).slice();
	}, e.prototype.getStore = function() {
		return this._store;
	}, e.prototype.initData = function(e, t, n) {
		var r = this, i;
		if (e instanceof yy && (i = e), !i) {
			var a = this.dimensions, o = pv(e) || ie(e) ? new kv(e, a.length) : e;
			i = new yy();
			var s = jw(a, function(e) {
				return {
					type: r._dimInfos[e].type,
					property: e
				};
			});
			i.initData(o, s, n);
		}
		this._store = i, this._nameList = (t || []).slice(), this._idList = [], this._nameRepeatCount = {}, this._doInit(0, i.count()), this._dimSummary = vw(this, this._schema), this.userOutput = this._dimSummary.userOutput;
	}, e.prototype.appendData = function(e) {
		var t = this._store.appendData(e);
		this._doInit(t[0], t[1]);
	}, e.prototype.appendValues = function(e, t) {
		var n = this._store.appendValues(e, t && t.length), r = n.start, i = n.end, a = this._shouldMakeIdFromName();
		if (this._updateOrdinalMeta(), t) for (var o = r; o < i; o++) {
			var s = o - r;
			this._nameList[o] = t[s], a && Uw(this, o);
		}
	}, e.prototype._updateOrdinalMeta = function() {
		for (var e = this._store, t = this.dimensions, n = 0; n < t.length; n++) {
			var r = this._dimInfos[t[n]];
			r.ordinalMeta && e.collectOrdinalMeta(r.storeDimIndex, r.ordinalMeta);
		}
	}, e.prototype._shouldMakeIdFromName = function() {
		var e = this._store.getProvider();
		return this._idDimIdx == null && e.getSource().sourceFormat !== "typedArray" && !e.fillStorage;
	}, e.prototype._doInit = function(e, t) {
		if (!(e >= t)) {
			var n = this._store.getProvider();
			this._updateOrdinalMeta();
			var r = this._nameList, i = this._idList;
			if (n.getSource().sourceFormat === "original" && !n.pure) for (var a = [], o = e; o < t; o++) {
				var s = n.getItem(o, a);
				if (!this.hasItemOption && ds(s) && (this.hasItemOption = !0), s) {
					var c = s.name;
					r[o] == null && c != null && (r[o] = xs(c, null));
					var l = s.id;
					i[o] == null && l != null && (i[o] = xs(l, null));
				}
			}
			if (this._shouldMakeIdFromName()) for (var o = e; o < t; o++) Uw(this, o);
			Lw(this);
		}
	}, e.prototype.getApproximateExtent = function(e, t) {
		return this._approximateExtent[e] || this._store.getDataExtent(this._getStoreDimIndex(e), t);
	}, e.prototype.setApproximateExtent = function(e, t) {
		t = this.getDimension(t), this._approximateExtent[t] = e.slice();
	}, e.prototype.getCalculationInfo = function(e) {
		return this._calculationInfo[e];
	}, e.prototype.setCalculationInfo = function(e, t) {
		Aw(e) ? M(this._calculationInfo, e) : this._calculationInfo[e] = t;
	}, e.prototype.getName = function(e) {
		var t = this.getRawIndex(e), n = this._nameList[t];
		return n == null && this._nameDimIdx != null && (n = zw(this, this._nameDimIdx, t)), n ??= "", n;
	}, e.prototype._getCategory = function(e, t) {
		var n = this._store.get(e, t), r = this._store.getOrdinalMeta(e);
		return r ? r.categories[n] : n;
	}, e.prototype.getId = function(e) {
		return Rw(this, this.getRawIndex(e));
	}, e.prototype.count = function() {
		return this._store.count();
	}, e.prototype.get = function(e, t) {
		var n = this._store, r = this._dimInfos[e];
		if (r) return n.get(r.storeDimIndex, t);
	}, e.prototype.getByRawIndex = function(e, t) {
		var n = this._store, r = this._dimInfos[e];
		if (r) return n.getByRawIndex(r.storeDimIndex, t);
	}, e.prototype.getIndices = function() {
		return this._store.getIndices();
	}, e.prototype.getDataExtent = function(e) {
		return this._store.getDataExtent(this._getStoreDimIndex(e), null);
	}, e.prototype.getSum = function(e) {
		return this._store.getSum(this._getStoreDimIndex(e));
	}, e.prototype.getMedian = function(e) {
		return this._store.getMedian(this._getStoreDimIndex(e));
	}, e.prototype.getValues = function(e, t) {
		var n = this, r = this._store;
		return V(e) ? r.getValues(jw(e, function(e) {
			return n._getStoreDimIndex(e);
		}), t) : r.getValues(e);
	}, e.prototype.hasValue = function(e) {
		for (var t = this._dimSummary.dataDimIndicesOnCoord, n = 0, r = t.length; n < r; n++) if (isNaN(this._store.get(t[n], e))) return !1;
		return !0;
	}, e.prototype.indexOfName = function(e) {
		for (var t = 0, n = this._store.count(); t < n; t++) if (this.getName(t) === e) return t;
		return -1;
	}, e.prototype.getRawIndex = function(e) {
		return this._store.getRawIndex(e);
	}, e.prototype.indexOfRawIndex = function(e) {
		return this._store.indexOfRawIndex(e);
	}, e.prototype.rawIndexOf = function(e, t) {
		var n = e && this._invertedIndicesMap[e], r = n && n[t];
		return r == null || isNaN(r) ? Pw : r;
	}, e.prototype.each = function(e, t, n) {
		H(e) && (n = t, t = e, e = []);
		var r = n || this, i = jw(Bw(e), this._getStoreDimIndex, this);
		this._store.each(i, r ? z(t, r) : t);
	}, e.prototype.filterSelf = function(e, t, n) {
		H(e) && (n = t, t = e, e = []);
		var r = n || this, i = jw(Bw(e), this._getStoreDimIndex, this);
		return this._store = this._store.filter(i, r ? z(t, r) : t), this;
	}, e.prototype.selectRange = function(e) {
		var t = this, n = {}, r = R(e), i = [];
		return I(r, function(r) {
			var a = t._getStoreDimIndex(r);
			n[a] = e[r], i.push(a);
		}), this._store = this._store.selectRange(n), this;
	}, e.prototype.mapArray = function(e, t, n) {
		H(e) && (n = t, t = e, e = []), n ||= this;
		var r = [];
		return this.each(e, function() {
			r.push(t && t.apply(this, arguments));
		}, n), r;
	}, e.prototype.map = function(e, t, n, r) {
		var i = n || r || this, a = jw(Bw(e), this._getStoreDimIndex, this), o = Hw(this);
		return o._store = this._store.map(a, i ? z(t, i) : t), o;
	}, e.prototype.modify = function(e, t, n, r) {
		var i = n || r || this, a = jw(Bw(e), this._getStoreDimIndex, this);
		this._store.modify(a, i ? z(t, i) : t);
	}, e.prototype.downSample = function(e, t, n, r) {
		var i = Hw(this);
		return i._store = this._store.downSample(this._getStoreDimIndex(e), t, n, r), i;
	}, e.prototype.minmaxDownSample = function(e, t) {
		var n = Hw(this);
		return n._store = this._store.minmaxDownSample(this._getStoreDimIndex(e), t), n;
	}, e.prototype.lttbDownSample = function(e, t) {
		var n = Hw(this);
		return n._store = this._store.lttbDownSample(this._getStoreDimIndex(e), t), n;
	}, e.prototype.getRawDataItem = function(e) {
		return this._store.getRawDataItem(e);
	}, e.prototype.getItemModel = function(e) {
		var t = this.hostModel;
		return new ih(this.getRawDataItem(e), t, t && t.ecModel);
	}, e.prototype.diff = function(e) {
		var t = this;
		return new gw(e ? e.getStore().getIndices() : [], this.getStore().getIndices(), function(t) {
			return Rw(e, t);
		}, function(e) {
			return Rw(t, e);
		});
	}, e.prototype.getVisual = function(e) {
		var t = this._visual;
		return t && t[e];
	}, e.prototype.setVisual = function(e, t) {
		this._visual = this._visual || {}, Aw(e) ? M(this._visual, e) : this._visual[e] = t;
	}, e.prototype.getItemVisual = function(e, t) {
		var n = this._itemVisuals[e];
		return (n && n[t]) ?? this.getVisual(t);
	}, e.prototype.hasItemVisual = function() {
		return this._itemVisuals.length > 0;
	}, e.prototype.ensureUniqueItemVisual = function(e, t) {
		var n = this._itemVisuals, r = n[e];
		r ||= n[e] = {};
		var i = r[t];
		return i ?? (i = this.getVisual(t), V(i) ? i = i.slice() : Aw(i) && (i = M({}, i)), r[t] = i), i;
	}, e.prototype.setItemVisual = function(e, t, n) {
		var r = this._itemVisuals[e] || {};
		this._itemVisuals[e] = r, Aw(t) ? M(r, t) : r[t] = n;
	}, e.prototype.clearAllVisual = function() {
		this._visual = {}, this._itemVisuals = [];
	}, e.prototype.setLayout = function(e, t) {
		Aw(e) ? M(this._layout, e) : this._layout[e] = t;
	}, e.prototype.getLayout = function(e) {
		return this._layout[e];
	}, e.prototype.getItemLayout = function(e) {
		return this._itemLayouts[e];
	}, e.prototype.setItemLayout = function(e, t, n) {
		this._itemLayouts[e] = n ? M(this._itemLayouts[e] || {}, t) : t;
	}, e.prototype.clearItemLayouts = function() {
		this._itemLayouts.length = 0;
	}, e.prototype.setItemGraphicEl = function(e, t) {
		zu(this.hostModel && this.hostModel.seriesIndex, this.dataType, e, t), this._graphicEls[e] = t;
	}, e.prototype.getItemGraphicEl = function(e) {
		return this._graphicEls[e];
	}, e.prototype.eachItemGraphicEl = function(e, t) {
		I(this._graphicEls, function(n, r) {
			n && e && e.call(t, n, r);
		});
	}, e.prototype.cloneShallow = function(t) {
		return t ||= new e(this._schema ? this._schema : jw(this.dimensions, this._getDimInfo, this), this.hostModel), Vw(t, this), t._store = this._store, t;
	}, e.prototype.wrapMethod = function(e, t) {
		var n = this[e];
		H(n) && (this.__wrappedMethods = this.__wrappedMethods || [], this.__wrappedMethods.push(e), this[e] = function() {
			var e = n.apply(this, arguments);
			return t.apply(this, [e].concat(be(arguments)));
		});
	}, e.internalField = function() {
		Lw = function(e) {
			var t = e._invertedIndicesMap;
			I(t, function(n, r) {
				var i = e._dimInfos[r], a = i.ordinalMeta, o = e._store;
				if (a) {
					n = t[r] = new Mw(a.categories.length);
					for (var s = 0; s < n.length; s++) n[s] = Pw;
					for (var s = 0; s < o.count(); s++) n[o.get(i.storeDimIndex, s)] = s;
				}
			});
		}, zw = function(e, t, n) {
			return xs(e._getCategory(t, n), null);
		}, Rw = function(e, t) {
			var n = e._idList[t];
			return n == null && e._idDimIdx != null && (n = zw(e, e._idDimIdx, t)), n ??= Nw + t, n;
		}, Bw = function(e) {
			return V(e) || (e = e == null ? [] : [e]), e;
		}, Hw = function(t) {
			var n = new e(t._schema ? t._schema : jw(t.dimensions, t._getDimInfo, t), t.hostModel);
			return Vw(n, t), n;
		}, Vw = function(e, t) {
			I(Fw.concat(t.__wrappedMethods || []), function(n) {
				t.hasOwnProperty(n) && (e[n] = t[n]);
			}), e.__wrappedMethods = t.__wrappedMethods, I(Iw, function(n) {
				e[n] = A(t[n]);
			}), e._calculationInfo = M({}, t._calculationInfo);
		}, Uw = function(e, t) {
			var n = e._nameList, r = e._idList, i = e._nameDimIdx, a = e._idDimIdx, o = n[t], s = r[t];
			if (o == null && i != null && (n[t] = o = zw(e, i, t)), s == null && a != null && (r[t] = s = zw(e, a, t)), s == null && o != null) {
				var c = e._nameRepeatCount, l = c[o] = (c[o] || 0) + 1;
				s = o, l > 1 && (s += "__ec__" + l), r[t] = s;
			}
		};
	}(), e;
}();
//#endregion
//#region node_modules/echarts/lib/data/helper/createDimensions.js
function Gw(e, t) {
	return Kw(e, t).dimensions;
}
function Kw(e, t) {
	pv(e) || (e = hv(e)), t ||= {};
	var n = t.coordDimensions || [], r = t.dimensionsDefine || e.dimensionsDefine || [], i = K(), a = [], o = qw(e, n, r, t.dimensionsCount), s = t.canOmitUnusedDimensions && kw(o), c = r === e.dimensionsDefine, l = c ? Ow(e) : Dw(r), u = t.encodeDefine;
	!u && t.encodeDefaulter && (u = t.encodeDefaulter(e, o));
	for (var d = K(u), f = new fy(o), p = 0; p < f.length; p++) f[p] = -1;
	function m(e) {
		var t = f[e];
		if (t < 0) {
			var n = r[e], i = W(n) ? n : { name: n }, o = new Sw(), s = i.name;
			return s != null && l.get(s) != null && (o.name = o.displayName = s), i.type != null && (o.type = i.type), i.displayName != null && (o.displayName = i.displayName), f[e] = a.length, o.storeDimIndex = e, a.push(o), o;
		}
		return a[t];
	}
	if (!s) for (var p = 0; p < o; p++) m(p);
	d.each(function(e, t) {
		var n = ss(e).slice();
		if (n.length === 1 && !U(n[0]) && n[0] < 0) d.set(t, !1);
		else {
			var r = d.set(t, []);
			I(n, function(e, n) {
				var i = U(e) ? l.get(e) : e;
				i != null && i < o && (r[n] = i, g(m(i), t, n));
			});
		}
	});
	var h = 0;
	I(n, function(e) {
		var t, n, r, i;
		if (U(e)) t = e, i = {};
		else {
			i = e, t = i.name;
			var a = i.ordinalMeta;
			i.ordinalMeta = null, i = M({}, i), i.ordinalMeta = a, n = i.dimsDef, r = i.otherDims, i.name = i.coordDim = i.coordDimIndex = i.dimsDef = i.otherDims = null;
		}
		var s = d.get(t);
		if (s !== !1) {
			if (s = ss(s), !s.length) for (var l = 0; l < (n && n.length || 1); l++) {
				for (; h < o && m(h).coordDim != null;) h++;
				h < o && s.push(h++);
			}
			I(s, function(e, a) {
				var o = m(e);
				if (c && i.type != null && (o.type = i.type), g(N(o, i), t, a), o.name == null && n) {
					var s = n[a];
					!W(s) && (s = { name: s }), o.name = o.displayName = s.name, o.defaultTooltip = s.defaultTooltip;
				}
				r && N(o.otherDims, r);
			});
		}
	});
	function g(e, t, n) {
		Bu.get(t) == null ? (e.coordDim = t, e.coordDimIndex = n, i.set(t, !0)) : e.otherDims[t] = n;
	}
	var _ = t.generateCoord, v = t.generateCoordCount, y = v != null;
	v = _ ? v || 1 : 0;
	var b = _ || "value";
	function x(e) {
		e.name ??= e.coordDim;
	}
	if (s) I(a, function(e) {
		x(e);
	}), a.sort(function(e, t) {
		return e.storeDimIndex - t.storeDimIndex;
	});
	else for (var S = 0; S < o; S++) {
		var C = m(S);
		C.coordDim ?? (C.coordDim = Jw(b, i, y), C.coordDimIndex = 0, (!_ || v <= 0) && (C.isExtraCoord = !0), v--), x(C), C.type == null && (d_(e, S) === i_.Must || C.isExtraCoord && (C.otherDims.itemName != null || C.otherDims.seriesName != null)) && (C.type = "ordinal");
	}
	return Xs(a, function(e) {
		return e.name;
	}, function(e, t) {
		t > 0 && (e.name += t - 1);
	}), new Tw({
		source: e,
		dimensions: a,
		fullDimensionCount: o,
		dimensionOmitted: s
	});
}
function qw(e, t, n, r) {
	var i = Math.max(e.dimensionsDetectedCount || 1, t.length, n.length, r || 0);
	return I(t, function(e) {
		var t;
		W(e) && (t = e.dimsDef) && (i = Math.max(i, t.length));
	}), i;
}
function Jw(e, t, n) {
	if (n || t.hasKey(e)) {
		for (var r = 0; t.hasKey(e + r);) r++;
		e += r;
	}
	return t.set(e, !0), e;
}
//#endregion
//#region node_modules/echarts/lib/model/referHelper.js
var Yw = function() {
	function e(e) {
		this.coordSysDims = [], this.axisMap = K(), this.categoryAxisMap = K(), this.coordSysName = e;
	}
	return e;
}();
function Xw(e) {
	var t = e.get("coordinateSystem"), n = new Yw(t), r = Zw[t];
	if (r) return r(e, n, n.axisMap, n.categoryAxisMap), n;
}
var Zw = {
	cartesian2d: function(e, t, n, r) {
		var i = e.getReferringComponents("xAxis", js).models[0], a = e.getReferringComponents("yAxis", js).models[0];
		t.coordSysDims = ["x", "y"], n.set("x", i), n.set("y", a), Qw(i) && (r.set("x", i), t.firstCategoryDimIndex = 0), Qw(a) && (r.set("y", a), t.firstCategoryDimIndex ??= 1);
	},
	singleAxis: function(e, t, n, r) {
		var i = e.getReferringComponents("singleAxis", js).models[0];
		t.coordSysDims = ["single"], n.set("single", i), Qw(i) && (r.set("single", i), t.firstCategoryDimIndex = 0);
	},
	polar: function(e, t, n, r) {
		var i = e.getReferringComponents("polar", js).models[0], a = i.findAxisModel("radiusAxis"), o = i.findAxisModel("angleAxis");
		t.coordSysDims = ["radius", "angle"], n.set("radius", a), n.set("angle", o), Qw(a) && (r.set("radius", a), t.firstCategoryDimIndex = 0), Qw(o) && (r.set("angle", o), t.firstCategoryDimIndex ??= 1);
	},
	geo: function(e, t, n, r) {
		t.coordSysDims = ["lng", "lat"];
	},
	parallel: function(e, t, n, r) {
		var i = e.ecModel, a = i.getComponent("parallel", e.get("parallelIndex")), o = t.coordSysDims = a.dimensions.slice();
		I(a.parallelAxisIndex, function(e, a) {
			var s = i.getComponent("parallelAxis", e), c = o[a];
			n.set(c, s), Qw(s) && (r.set(c, s), t.firstCategoryDimIndex ??= a);
		});
	},
	matrix: function(e, t, n, r) {
		var i = e.getReferringComponents("matrix", js).models[0];
		t.coordSysDims = ["x", "y"];
		var a = i.getDimensionModel("x"), o = i.getDimensionModel("y");
		n.set("x", a), n.set("y", o), r.set("x", a), r.set("y", o);
	}
};
function Qw(e) {
	return e.get("type") === "category";
}
//#endregion
//#region node_modules/echarts/lib/data/helper/dataStackHelper.js
function $w(e, t, n) {
	n ||= {};
	var r = n.byIndex, i = n.stackedCoordDimension, a, o, s;
	eT(t) ? a = t : (o = t.schema, a = o.dimensions, s = t.store);
	var c = !!(e && e.get("stack")), l, u, d, f, p = !0;
	function m(e) {
		return e.type !== "ordinal" && e.type !== "time";
	}
	if (I(a, function(e, t) {
		U(e) && (a[t] = e = { name: e }), m(e) || (p = !1);
	}), I(a, function(e, t) {
		c && !e.isExtraCoord && (!r && !l && e.ordinalMeta && (l = e), !u && m(e) && (!p || e.coordDim !== "x" && e.coordDim !== "angle") && (!i || i === e.coordDim) && (u = e));
	}), u && !r && !l && (r = !0), u) {
		d = "__\0ecstackresult_" + e.id, f = "__\0ecstackedover_" + e.id, l && (l.createInvertedIndices = !0);
		var h = u.coordDim, g = u.type, _ = 0;
		I(a, function(e) {
			e.coordDim === h && _++;
		});
		var v = {
			name: d,
			coordDim: h,
			coordDimIndex: _,
			type: g,
			isExtraCoord: !0,
			isCalculationCoord: !0,
			storeDimIndex: a.length
		}, y = {
			name: f,
			coordDim: f,
			coordDimIndex: _ + 1,
			type: g,
			isExtraCoord: !0,
			isCalculationCoord: !0,
			storeDimIndex: a.length + 1
		};
		o ? (s && (v.storeDimIndex = s.ensureCalculationDimension(f, g), y.storeDimIndex = s.ensureCalculationDimension(d, g)), o.appendCalculationDimension(v), o.appendCalculationDimension(y)) : (a.push(v), a.push(y));
	}
	return {
		stackedDimension: u && u.name,
		stackedByDimension: l && l.name,
		isStackedByIndex: r,
		stackedOverDimension: f,
		stackResultDimension: d
	};
}
function eT(e) {
	return !Ew(e.schema);
}
function tT(e, t) {
	return !!t && t === e.getCalculationInfo("stackedDimension");
}
function nT(e, t) {
	return tT(e, t) ? e.getCalculationInfo("stackResultDimension") : t;
}
//#endregion
//#region node_modules/echarts/lib/chart/helper/createSeriesData.js
function rT(e, t) {
	var n = e.get("coordinateSystem"), r = wg.get(n), i;
	return t && t.coordSysDims && (i = L(t.coordSysDims, function(e) {
		var n = { name: e }, r = t.axisMap.get(e);
		return r && (n.type = bw(r.get("type"))), n;
	})), i ||= r && (r.getDimensionsInfo ? r.getDimensionsInfo() : r.dimensions.slice()) || ["x", "y"], i;
}
function iT(e, t, n) {
	var r, i;
	return n && I(e, function(e, a) {
		var o = e.coordDim, s = n.categoryAxisMap.get(o);
		s && (r ??= a, e.ordinalMeta = s.getOrdinalMeta(), t && (e.createInvertedIndices = !0)), e.otherDims.itemName != null && (i = !0);
	}), !i && r != null && (e[r].otherDims.itemName = 0), r;
}
function aT(e, t, n) {
	n ||= {};
	var r = t.getSourceManager(), i, a = !1;
	e ? (a = !0, i = hv(e)) : (i = r.getSource(), a = i.sourceFormat === Vu);
	var o = Xw(t), s = rT(t, o), c = n.useEncodeDefaulter, l = H(c) ? c : c ? B(s_, s, t) : null, u = {
		coordDimensions: s,
		generateCoord: n.generateCoord,
		encodeDefine: t.getEncode(),
		encodeDefaulter: l,
		canOmitUnusedDimensions: !a
	}, d = Kw(i, u), f = iT(d.dimensions, n.createInvertedIndices, o), p = a ? null : r.getSharedDataStore(d), m = $w(t, {
		schema: d,
		store: p
	}), h = new Ww(d, t);
	h.setCalculationInfo(m);
	var g = f != null && oT(i) ? function(e, t, n, r) {
		return r === f ? n : this.defaultDimValueGetter(e, t, n, r);
	} : null;
	return h.hasItemOption = !1, h.initData(a ? i : p, null, g), h;
}
function oT(e) {
	if (e.sourceFormat === "original") return !V(us(sT(e.data || [])));
}
function sT(e) {
	for (var t = 0; t < e.length && e[t] == null;) t++;
	return e[t];
}
//#endregion
//#region node_modules/echarts/lib/scale/Scale.js
var cT = function() {
	function e() {}
	return e.prototype.isBlank = function() {
		return this._isBlank;
	}, e.prototype.setBlank = function(e) {
		this._isBlank = e;
	}, e;
}();
gc(cT);
//#endregion
//#region node_modules/echarts/lib/data/OrdinalMeta.js
var lT = 0, uT = function() {
	function e(e) {
		this.categories = e.categories || [], this._needCollect = e.needCollect, this._deduplication = e.deduplication, this.uid = ++lT, this._onCollect = e.onCollect;
	}
	return e.createByAxisModel = function(t) {
		var n = t.option, r = n.data, i = r && L(r, dT);
		return new e({
			categories: i,
			needCollect: !i,
			deduplication: n.dedplication !== !1
		});
	}, e.prototype.getOrdinal = function(e) {
		return this._getOrCreateMap().get(e);
	}, e.prototype.parseAndCollect = function(e) {
		var t, n = this._needCollect;
		if (!U(e) && !n) return e;
		if (n && !this._deduplication) return t = this.categories.length, this.categories[t] = e, this._onCollect && this._onCollect(e, t), t;
		var r = this._getOrCreateMap();
		return t = r.get(e), t ?? (n ? (t = this.categories.length, this.categories[t] = e, r.set(e, t), this._onCollect && this._onCollect(e, t)) : t = NaN), t;
	}, e.prototype._getOrCreateMap = function() {
		return this._map ||= K(this.categories);
	}, e;
}();
function dT(e) {
	return W(e) && e.value != null ? e.value : e + "";
}
var fT = R({
	needTransform: 1,
	normalize: 1,
	scale: 1,
	transformIn: 1,
	transformOut: 1,
	contain: 1,
	getExtent: 1,
	getExtentUnsafe: 1,
	setExtent: 1,
	setExtent2: 1,
	getFilter: 1,
	sanitize: 1,
	getDefaultStartValue: 1,
	freeze: 1
});
function pT(e, t, n) {
	var r;
	e ||= {};
	var i = Ch();
	if (i) {
		var a = i.createBreakScaleMapper(t, n);
		a.hasBreaks() && (I(fT, function(t) {
			a[t] && (e[t] = z(a[t], a));
		}), r = a);
	}
	return r ?? bT(e, n), {
		brk: r,
		mapper: e
	};
}
function mT(e, t) {
	I(fT, function(n) {
		e[n] = t[n];
	});
}
function hT(e, t) {
	e.freeze = Pe;
}
function gT(e) {
	return e.getExtentUnsafe(0, 2);
}
function _T(e, t) {
	return e.getExtentUnsafe(1, t) || e.getExtentUnsafe(0, t);
}
function vT(e) {
	var t = _T(e, 3);
	return t[1] - t[0];
}
function yT(e) {
	var t = e.getExtentUnsafe(0, 3);
	return t[1] - t[0];
}
function bT(e, t) {
	var n = e || {}, r = [];
	return n._extents = r, r[0] = t ? t.slice() : zs(), M(n, xT), n;
}
var xT = {
	needTransform: function() {
		return !1;
	},
	normalize: function(e) {
		var t = this._extents[1] || this._extents[0];
		return t[1] === t[0] ? .5 : (e - t[0]) / (t[1] - t[0]);
	},
	scale: function(e) {
		var t = this._extents[1] || this._extents[0];
		return e * (t[1] - t[0]) + t[0];
	},
	transformIn: function(e) {
		return e;
	},
	transformOut: function(e) {
		return e;
	},
	contain: function(e) {
		var t = _T(this, null);
		return e >= t[0] && e <= t[1];
	},
	getExtent: function() {
		return this._extents[0].slice();
	},
	getExtentUnsafe: function(e) {
		return this._extents[e];
	},
	setExtent: function(e, t) {
		ST(this._extents, 0, e, t);
	},
	setExtent2: function(e, t, n) {
		var r = this._extents;
		r[e] || (r[e] = r[0].slice()), ST(r, e, t, n);
	},
	freeze: function() {}
};
function ST(e, t, n, r) {
	Gs(n, r) && (e[t][0] = n, e[t][1] = r);
}
//#endregion
//#region node_modules/echarts/lib/scale/helper.js
function CT(e) {
	return wT(e) || ET(e);
}
function wT(e) {
	return e.type === "interval";
}
function TT(e) {
	return e.type === "time";
}
function ET(e) {
	return e.type === "log";
}
function DT(e) {
	return e.type === "ordinal";
}
function OT(e) {
	var t = Ho(e), n = go(10, t), r = po(e / n);
	return r ? r === 2 ? r = 3 : r === 3 ? r = 5 : r *= 2 : r = 1, Eo(r * n, -t);
}
function kT(e) {
	return ko(e) + 2;
}
function AT(e, t) {
	return _o(e) / _o(t);
}
function jT(e, t, n) {
	var r = n && n.lookup;
	if (r) {
		for (var i = 0; i < r.from.length; i++) if (e === r.from[i]) return r.to[i];
	}
	return go(t, e);
}
function MT(e, t, n) {
	var r = e.slice();
	if (r[0] === r[1]) {
		var i = n && n.ctnShp;
		if (r[0] !== 0) {
			var a = fo(r[0]);
			t[1] || (r[1] += a / 2), r[0] -= a / 2;
		} else i && (r[0] = -1), r[1] = 1;
	}
	return (!Ws(r[0]) || !Ws(r[1])) && (r[0] = 0, r[1] = 1), r[1] < r[0] && r.reverse(), r;
}
function NT(e, t) {
	return [e[0] !== t[0], e[1] !== t[1]];
}
function PT(e, t) {
	return e ||= t, po(uo(e, 1));
}
function FT(e, t, n) {
	var r = gT(e), i = r[0], a = e.count(), o = Math.max((t || 0) + 1, 1);
	i !== 0 && o > 1 && a / o > 2 && (i = Math.round(Math.ceil(i / o) * o)), i !== r[0] && c(r[0], !0, !0);
	for (var s = i; s <= r[1]; s += o) c(s, !1, s === r[0] || s === r[1]);
	s - o !== r[1] && c(r[1], !0, !0);
	function c(e, t, r) {
		n({
			value: e,
			offInterval: t
		}, r);
	}
}
//#endregion
//#region node_modules/echarts/lib/scale/Ordinal.js
var IT = function(e) {
	n(t, e);
	function t(n) {
		var r = e.call(this) || this;
		r.type = "ordinal", r.parse = t.parse, mT(r, t.decoratedMethods);
		var i = n.ordinalMeta;
		i ||= new uT({}), V(i) && (i = new uT({ categories: L(i, function(e) {
			return W(e) ? e.value : e;
		}) })), r._ordinalMeta = i;
		var a = pT(null, null, n.extent || [0, i.categories.length - 1]);
		return r._mapper = a.mapper, hT(r, a.mapper), r;
	}
	return t.parse = function(e) {
		return e == null ? e = NaN : U(e) ? (e = this._ordinalMeta.getOrdinal(e), e ??= NaN) : e = po(e), e;
	}, t.prototype.getTicks = function() {
		var e = [];
		return FT(this, 0, function(t) {
			e.push(t);
		}), e;
	}, t.prototype.getMinorTicks = function(e) {}, t.prototype.setSortInfo = function(e) {
		if (e == null) this._ordinalNumbersByTick = this._ticksByOrdinalNumber = null;
		else {
			for (var t = e.ordinalNumbers, n = this._ordinalNumbersByTick = [], r = this._ticksByOrdinalNumber = [], i = 0, a = this._ordinalMeta.categories.length, o = lo(a, t.length); i < o; ++i) {
				var s = n[i] = t[i];
				r[s] = i;
			}
			for (var c = 0; i < a; ++i) {
				for (; r[c] != null;) c++;
				n[i] = c, r[c] = i;
			}
		}
	}, t.prototype._getTickNumber = function(e) {
		var t = this._ticksByOrdinalNumber;
		return t && e >= 0 && e < t.length ? t[e] : e;
	}, t.prototype.getRawOrdinalNumber = function(e) {
		var t = this._ordinalNumbersByTick;
		return t && e >= 0 && e < t.length ? t[e] : e;
	}, t.prototype.getLabel = function(e) {
		if (!this.isBlank()) {
			var t = this.getRawOrdinalNumber(e.value), n = this._ordinalMeta.categories[t];
			return n == null ? "" : n + "";
		}
	}, t.prototype.count = function() {
		var e = gT(this._mapper);
		return e[1] - e[0] + 1;
	}, t.prototype.getOrdinalMeta = function() {
		return this._ordinalMeta;
	}, t.type = "ordinal", t.decoratedMethods = {
		needTransform: function() {
			return this._mapper.needTransform();
		},
		contain: function(e) {
			return this._mapper.contain(this._getTickNumber(e)) && e >= 0 && e < this._ordinalMeta.categories.length;
		},
		normalize: function(e) {
			return this._mapper.normalize(this._getTickNumber(e));
		},
		scale: function(e) {
			return this.getRawOrdinalNumber(po(this._mapper.scale(e)));
		},
		transformIn: function(e, t) {
			return this._mapper.transformIn(this._getTickNumber(e), t);
		},
		transformOut: function(e, t) {
			return this.getRawOrdinalNumber(this._mapper.transformOut(e, t));
		},
		getExtent: function() {
			return this._mapper.getExtent();
		},
		getExtentUnsafe: function(e, t) {
			return this._mapper.getExtentUnsafe(e, t);
		},
		setExtent: function(e, t) {
			return this._mapper.setExtent(e, t);
		},
		setExtent2: function(e, t, n) {
			return this._mapper.setExtent2(e, t, n);
		}
	}, t;
}(cT);
cT.registerClass(IT);
//#endregion
//#region node_modules/echarts/lib/scale/minorTicks.js
function LT(e, t, n, r) {
	for (var i = e.getTicks({ expandToNicedExtent: !0 }), a = [], o = e.getExtent(), s = 1; s < i.length; s++) {
		var c = i[s], l = i[s - 1];
		if (!(l.break || c.break)) {
			for (var u = 0, d = [], f = (c.value - l.value) / t, p = kT(f); u < t - 1;) {
				var m = Eo(l.value + (u + 1) * f, p);
				m > o[0] && m < o[1] && d.push(m), u++;
			}
			var h = Ch();
			h && h.pruneTicksByBreak("auto", d, n, function(e) {
				return e;
			}, r, o), a.push(d);
		}
	}
	return a;
}
//#endregion
//#region node_modules/echarts/lib/scale/Interval.js
var RT = function(e) {
	n(t, e);
	function t(n) {
		var r = e.call(this) || this;
		return r.type = "interval", r.parse = t.parse, n ||= {}, r.brk = pT(r, wh(r, n), null).brk, r._cfg = {
			interval: 0,
			intervalPrecision: 2,
			intervalCount: void 0,
			niceExtent: void 0
		}, r;
	}
	return t.parse = function(e) {
		return e == null || e === "" ? NaN : Number(e);
	}, t.prototype.getConfig = function() {
		return A(this._cfg);
	}, t.prototype.setConfig = function(e) {
		var t = gT(this);
		this._cfg = e = A(e), e.niceExtent ?? (e.niceExtent = t.slice()), e.intervalPrecision ?? (e.intervalPrecision = kT(e.interval));
	}, t.prototype.getTicks = function(e) {
		e ||= {};
		var t = this._cfg, n = t.interval, r = gT(this), i = t.niceExtent, a = t.intervalPrecision, o = Ch(), s = this.brk, c = o && s, l = [];
		if (!n) return l;
		if (e.breakTicks === "only_break" && c) return o.addBreaksToTicks(l, s.breaks, r), l;
		var u = 3e3;
		r[0] < i[0] && l.push({ value: e.expandToNicedExtent ? Eo(i[0] - n, a) : r[0] });
		for (var d = function(e, t) {
			return po((t - e) / n);
		}, f = t.intervalCount, p = i[0], m = 0;; m++) {
			if (f == null) {
				if (p > i[1] || !isFinite(p) || !isFinite(i[1])) break;
			} else {
				if (m > f) break;
				p = lo(p, i[1]), m === f && (p = i[1]);
			}
			if (l.push({ value: p }), p = Eo(p + n, a), s) {
				var h = s.calcNiceTickMultiple(p, d);
				h >= 0 && (p = Eo(p + h * n, a));
			}
			if (l.length > 0 && p === l[l.length - 1].value) break;
			if (l.length > u) return [];
		}
		var g = l.length ? l[l.length - 1].value : i[1];
		return r[1] > g && l.push({ value: e.expandToNicedExtent ? Eo(g + n, a) : r[1] }), c && o.pruneTicksByBreak(e.pruneByBreak, l, s.breaks, function(e) {
			return e.value;
		}, t.interval, r), c && e.breakTicks !== "none" && o.addBreaksToTicks(l, s.breaks, r), l;
	}, t.prototype.getMinorTicks = function(e) {
		return LT(this, e, Th(this), this._cfg.interval);
	}, t.prototype.getLabel = function(e, t) {
		if (e == null) return "";
		var n = t && t.precision;
		return n == null ? n = ko(e.value) || 0 : n === "auto" && (n = this._cfg.intervalPrecision), ug(Eo(e.value, n, !0));
	}, t.type = "interval", t;
}(cT);
cT.registerClass(RT);
//#endregion
//#region node_modules/echarts/lib/scale/Time.js
var zT = function(e, t, n, r) {
	for (; n < r;) {
		var i = n + r >>> 1;
		e[i][1] < t ? n = i + 1 : r = i;
	}
	return n;
}, BT = function(e) {
	n(t, e);
	function t(n) {
		var r = e.call(this) || this;
		return r.type = "time", r.parse = t.parse, r._locale = n.locale, r._useUTC = n.useUTC, r._interval = 0, r.brk = pT(r, wh(r, n), null).brk, r;
	}
	return t.prototype.getLabel = function(e) {
		return Gh(e.value, Ih[Wh(Hh(this._minLevelUnit))] || Ih.second, this._useUTC, this._locale);
	}, t.prototype.getFormattedLabel = function(e, t, n) {
		return Kh(e, t, n, this._locale, this._useUTC);
	}, t.prototype.getTicks = function(e) {
		e ||= {};
		var t = this._interval, n = gT(this), r = Ch(), i = this.brk, a = r && i, o = [];
		if (!t) return o;
		var s = this._useUTC;
		if (a && e.breakTicks === "only_break") return Ch().addBreaksToTicks(o, i.breaks, n), o;
		o = XT(this._minLevelUnit, this._approxInterval, s, n, yT(this), i);
		var c = Lh.length - 1, l = 0;
		return I(o, function(e) {
			e.time && (c = Math.min(c, P(Lh, e.time.upperTimeUnit)), l = Math.max(l, e.time.level));
		}), a && Ch().pruneTicksByBreak(e.pruneByBreak, o, i.breaks, function(e) {
			return e.value;
		}, this._approxInterval, n), a && e.breakTicks !== "none" && Ch().addBreaksToTicks(o, i.breaks, n, function(e) {
			for (var t = Math.max(P(Lh, qh(e.vmin, s)), P(Lh, qh(e.vmax, s))), n = 0, r = 0; r < Lh.length; r++) if (!HT(Lh[r], e.vmin, e.vmax, s)) {
				n = r;
				break;
			}
			var i = Math.min(n, c);
			return {
				level: l,
				lowerTimeUnit: Lh[Math.max(i, t)],
				upperTimeUnit: Lh[i]
			};
		}), o;
	}, t.prototype.getMinorTicks = function(e) {
		return LT(this, e, Th(this), this._interval);
	}, t.prototype.setTimeInterval = function(e) {
		this._interval = e.interval, this._approxInterval = e.approxInterval, this._minLevelUnit = e.minLevelUnit;
	}, t.parse = function(e) {
		return ue(e) ? Math.round(e) : +Bo(e);
	}, t.type = "time", t;
}(cT), VT = [
	["second", Dh],
	["minute", Oh],
	["hour", kh],
	["quarter-day", kh * 6],
	["half-day", kh * 12],
	["day", Ah * 1.2],
	["half-week", Ah * 3.5],
	["week", Ah * 7],
	["month", Ah * 31],
	["quarter", Ah * 95],
	["half-year", jh / 2],
	["year", jh]
];
function HT(e, t, n, r) {
	return Jh(new Date(t), e, r).getTime() === Jh(new Date(n), e, r).getTime();
}
function UT(e, t) {
	return e /= Ah, e > 16 ? 16 : e > 7.5 ? 7 : e > 3.5 ? 4 : e > 1.5 ? 2 : 1;
}
function WT(e) {
	var t = 30 * Ah;
	return e /= t, e > 6 ? 6 : e > 3 ? 3 : e > 2 ? 2 : 1;
}
function GT(e) {
	return e /= kh, e > 12 ? 12 : e > 6 ? 6 : e > 3.5 ? 4 : e > 2 ? 2 : 1;
}
function KT(e, t) {
	return e /= t ? Oh : Dh, e > 30 ? 30 : e > 20 ? 20 : e > 15 ? 15 : e > 10 ? 10 : e > 5 ? 5 : e > 2 ? 2 : 1;
}
function qT(e) {
	return uo(Uo(e, !0), 1);
}
function JT(e, t, n) {
	var r = Math.max(0, P(Lh, t) - 1);
	return Jh(new Date(e), Lh[r], n).getTime();
}
function YT(e, t) {
	var n = /* @__PURE__ */ new Date(0);
	n[e](1);
	var r = n.getTime();
	n[e](1 + t);
	var i = n.getTime() - r;
	return function(e, t) {
		return Math.max(0, Math.round((t - e) / i));
	};
}
function XT(e, t, n, r, i, a) {
	var o = Rh, s = 0;
	function c(e, t, n, i, o, c, l) {
		for (var u = YT(o, e), d = t, f = new Date(d); d < n && d <= r[1] && (l.push({ value: d }), !(s++ > 3e3));) if (f[o](f[i]() + e), d = f.getTime(), a) {
			var p = a.calcNiceTickMultiple(d, u);
			p > 0 && (f[o](f[i]() + p * e), d = f.getTime());
		}
		l.push({
			value: d,
			notAdd: d > r[1]
		});
	}
	function l(e, i, a) {
		var o = [], s = !i.length;
		if (!HT(Hh(e), r[0], r[1], n)) {
			s && (i = [{ value: JT(r[0], e, n) }, { value: r[1] }]);
			for (var l = 0; l < i.length - 1; l++) {
				var u = i[l].value, d = i[l + 1].value;
				if (u !== d) {
					var f = void 0, p = void 0, m = void 0, h = !1;
					switch (e) {
						case "year":
							f = Math.max(1, Math.round(t / Ah / 365)), p = Yh(n), m = ng(n);
							break;
						case "half-year":
						case "quarter":
						case "month":
							f = WT(t), p = Xh(n), m = rg(n);
							break;
						case "week":
						case "half-week":
						case "day":
							f = UT(t, 31), p = Zh(n), m = ig(n), h = !0;
							break;
						case "half-day":
						case "quarter-day":
						case "hour":
							f = GT(t), p = Qh(n), m = ag(n);
							break;
						case "minute":
							f = KT(t, !0), p = $h(n), m = og(n);
							break;
						case "second":
							f = KT(t, !1), p = eg(n), m = sg(n);
							break;
						case "millisecond": f = qT(t), p = tg(n), m = cg(n);
					}
					d >= r[0] && u <= r[1] && c(f, u, d, p, m, h, o), e === "year" && a.length > 1 && l === 0 && a.unshift({ value: a[0].value - f });
				}
			}
			for (var l = 0; l < o.length; l++) a.push(o[l]);
		}
	}
	for (var u = [], d = [], f = 0, p = 0, m = 0; m < o.length; ++m) {
		var h = Hh(o[m]);
		if (Uh(o[m]) && (l(o[m], u[u.length - 1] || [], d), h !== (o[m + 1] ? Hh(o[m + 1]) : null))) {
			if (d.length) {
				p = f, d.sort(function(e, t) {
					return e.value - t.value;
				});
				for (var g = [], _ = 0; _ < d.length; ++_) {
					var v = d[_].value;
					(_ === 0 || d[_ - 1].value !== v) && (g.push(d[_]), v >= r[0] && v <= r[1] && f++);
				}
				var y = i / t;
				if (f > y * 1.5 && p > y / 1.5 || (u.push(g), f > y || e === o[m])) break;
			}
			d = [];
		}
	}
	for (var b = oe(L(u, function(e) {
		return oe(e, function(e) {
			return e.value >= r[0] && e.value <= r[1] && !e.notAdd;
		});
	}), function(e) {
		return e.length > 0;
	}), x = b.length - 1, S = [], m = 0; m < b.length; ++m) for (var C = b[m], w = 0; w < C.length; ++w) {
		var T = qh(C[w].value, n);
		S.push({
			value: C[w].value,
			time: {
				level: x - m,
				upperTimeUnit: T,
				lowerTimeUnit: T
			}
		});
	}
	Xs(S, Zs, null), S.sort(function(e, t) {
		return e.value - t.value;
	});
	var E = S[0], D = S[S.length - 1], O = qh(r[0], n), k = qh(r[1], n);
	return (!E || E.value > r[0]) && S.unshift({
		value: r[0],
		time: {
			level: 0,
			upperTimeUnit: O,
			lowerTimeUnit: O
		},
		notNice: !0
	}), (!D || D.value < r[1]) && S.push({
		value: r[1],
		time: {
			level: 0,
			upperTimeUnit: k,
			lowerTimeUnit: k
		},
		notNice: !0
	}), S;
}
var ZT = function(e, t) {
	var n = e.getExtent();
	if (n[0] === n[1] && (n[0] -= Ah, n[1] += Ah), n[1] === -Infinity && n[0] === Infinity) {
		var r = /* @__PURE__ */ new Date();
		n[1] = +new Date(r.getFullYear(), r.getMonth(), r.getDate()), n[0] = n[1] - Ah;
	}
	e.setExtent(n[0], n[1]);
	var i = PT(t.splitNumber, 10), a = yT(e) / i, o = t.minInterval, s = t.maxInterval;
	o != null && a < o && (a = o), s != null && a > s && (a = s);
	var c = VT.length, l = Math.min(zT(VT, a, 0, c), c - 1), u = VT[l][1], d = VT[Math.max(l - 1, 0)][0];
	e.setTimeInterval({
		approxInterval: a,
		interval: u,
		minLevelUnit: d
	});
};
cT.registerClass(BT);
//#endregion
//#region node_modules/echarts/lib/scale/Log.js
var QT = 0, $T = 1, eE = 2, tE = function(e) {
	n(t, e);
	function t(n) {
		var r = e.call(this) || this;
		r.type = "log", r.parse = RT.parse, r.base = n.logBase || 10;
		var i = [], a = [], o = r._lookup = {
			from: i,
			to: a
		};
		i[QT] = i[$T] = a[QT] = a[$T] = NaN, mT(r, t.mapperMethods);
		var s = Ch(), c = n.breakOption, l = { lookup: o };
		return s && s.parseAxisBreakOptionInwardTransform(c, r, { noNegative: !0 }, eE, l), r.powStub = new RT({ breakParsed: l.original }), r.intervalStub = new RT({ breakParsed: l.transformed }), hT(r, r.intervalStub), r;
	}
	return t.prototype.getTicks = function(e) {
		var t = this.base, n = this.powStub, r = Ch(), i = this.intervalStub, a = { lookup: {
			from: i.getExtent(),
			to: n.getExtent()
		} };
		return L(i.getTicks(e || {}), function(e) {
			var i = e.value, o = jT(i, t, a), s;
			if (r) {
				var c = r.getTicksBreakOutwardTransform(this, e, Th(n), this._lookup);
				c && (s = c.vBreak, o = c.tickVal);
			}
			return {
				value: o,
				break: s
			};
		}, this);
	}, t.prototype.getMinorTicks = function(e) {
		return LT(this, e, Th(this.powStub), this.intervalStub.getConfig().interval);
	}, t.prototype.getLabel = function(e, t) {
		return this.intervalStub.getLabel(e, t);
	}, t.type = "log", t.mapperMethods = {
		needTransform: function() {
			return !0;
		},
		normalize: function(e) {
			return this.intervalStub.normalize(AT(e, this.base));
		},
		scale: function(e) {
			return jT(this.intervalStub.scale(e), this.base, null);
		},
		transformIn: function(e, t) {
			return e = AT(e, this.base), t && t.depth === 2 ? e : this.intervalStub.transformIn(e, t);
		},
		transformOut: function(e, t) {
			var n = t ? t.depth : null;
			return nE.depth = n, rE.lookup = this._lookup, jT(n === 2 ? e : this.intervalStub.transformOut(e, nE), this.base, rE);
		},
		contain: function(e) {
			return this.powStub.contain(e);
		},
		setExtent: function(e, t) {
			this.setExtent2(0, e, t);
		},
		setExtent2: function(e, t, n) {
			if (!(!Gs(t, n) || t <= 0 || n <= 0)) {
				var r = iE, i = iE;
				if (e === 0) {
					var a = this._lookup;
					r = a.to, i = a.from;
				}
				this.powStub.setExtent2(e, r[QT] = t, r[$T] = n);
				var o = this.base;
				this.intervalStub.setExtent2(e, i[QT] = AT(t, o), i[$T] = AT(n, o));
			}
		},
		getFilter: function() {
			return { g: 0 };
		},
		sanitize: function(e, t) {
			return Gs(t[0], t[1]) && Zo(e) && e <= 0 && (e = t[0]), e;
		},
		getDefaultStartValue: function() {
			return 1;
		},
		getExtent: function() {
			return this.powStub.getExtent();
		},
		getExtentUnsafe: function(e, t) {
			return t === null ? this.powStub.getExtentUnsafe(e, null) : this.intervalStub.getExtentUnsafe(e, t);
		}
	}, t;
}(cT);
cT.registerClass(tE);
var nE = {}, rE = {}, iE = [], aE = {
	value: 1,
	category: 1,
	time: 1,
	log: 1
}, oE = X();
function sE(e) {
	var t = e.get("type");
	return (t == null || !q(aE, t) && !cT.getClass(t)) && (t = "value"), t;
}
function cE(e, t, n) {
	var r = Ch(), i;
	switch (r && (i = yE(e, t, n)), t) {
		case "category": return new IT({
			ordinalMeta: e.getOrdinalMeta ? e.getOrdinalMeta() : e.getCategories(),
			extent: zs()
		});
		case "time": return new BT({
			locale: e.ecModel.getLocaleModel(),
			useUTC: e.ecModel.get("useUTC"),
			breakOption: i
		});
		case "log": return new tE({
			logBase: e.get("logBase"),
			breakOption: i
		});
		case "value": return new RT({ breakOption: i });
		default: return new ((cT.getClass(t)) || RT)({});
	}
}
function lE(e, t, n) {
	var r = n ? _T(e, null) : e.getExtentUnsafe(0, null), i = r[0], a = r[1];
	return Gs(i, a) ? i === t || a === t ? 2 : i < t && a > t ? 1 : 3 : 3;
}
function uE(e) {
	oE(e).noOnMyZero = !0;
}
function dE(e) {
	return oE(e).noOnMyZero;
}
function fE(e) {
	var t = e.getLabelModel().get("formatter");
	if (e.type === "time") {
		var n = zh(t);
		return function(t, r) {
			return e.scale.getFormattedLabel(t, r, n);
		};
	}
	if (U(t)) return function(n) {
		var r = e.scale.getLabel(n);
		return t.replace("{value}", r ?? "");
	};
	if (H(t)) {
		if (e.type === "category") return function(n, r) {
			return t(pE(e, n), n.value - e.scale.getExtent()[0], null);
		};
		var r = Ch();
		return function(n, i) {
			var a = null;
			return r && (a = r.makeAxisLabelFormatterParamBreak(a, n.break)), t(pE(e, n), i, a);
		};
	}
	return function(t) {
		return e.scale.getLabel(t);
	};
}
function pE(e, t) {
	var n = e.scale;
	return DT(n) ? n.getLabel(t) : t.value;
}
function mE(e) {
	return e.get("interval") ?? "auto";
}
function hE(e) {
	return e.type === "category" && mE(e.getLabelModel()) === 0;
}
function gE(e, t) {
	var n = {};
	return I(e.mapDimensionsAll(t), function(t) {
		n[nT(e, t)] = !0;
	}), R(n);
}
function _E(e) {
	return e === "middle" || e === "center";
}
function vE(e) {
	return e.getShallow("show");
}
function yE(e, t, n) {
	var r = e.get("breaks", !0);
	if (r != null) return !Ch() || !n || !bE(t) ? void 0 : r;
}
function bE(e) {
	return e !== "category";
}
function xE(e, t, n, r, i, a) {
	var o = ET(e), s = o ? e.intervalStub : e;
	if (s.setExtent(r[0], r[1]), o) {
		var c = e.powStub, l = { depth: 2 }, u = e.transformOut(r[0], l), d = e.transformOut(r[1], l), f = NT(n, r);
		t[0] && !f[0] && (u = i[0]), t[1] && !f[1] && (d = i[1]), c.setExtent(u, d);
	}
	s.setConfig(a);
}
function SE(e, t) {
	return DT(e) ? e.getRawOrdinalNumber(t.value) : t.value;
}
function CE(e, t) {
	return DT(e) && !!t.get("boundaryGap");
}
//#endregion
//#region node_modules/echarts/lib/coord/axisModelCommonMixin.js
var wE = function() {
	function e() {}
	return e.prototype.needIncludeZero = function() {
		return !this.option.scale;
	}, e.prototype.getCoordSysModel = function() {}, e;
}(), TE = Js(), EE = X(), DE = X();
function OE(e, t) {
	var n = e.model, r = EE(_x(n.ecModel)).keyed, i = r && r.get(t);
	return i && i.get(n.uid);
}
function kE(e, t) {
	return ME(OE(e, t));
}
function AE(e, t) {
	var n = [];
	return jE(e.model.ecModel, function(e) {
		for (var r = 0; r < t.length; r++) t[r] && e.serByIdx[t[r].seriesIndex] && n.push(ME(e));
	}), n;
}
function jE(e, t) {
	var n = EE(_x(e)).keyed;
	n && n.each(function(e, n) {
		e.each(function(e, r) {
			t(e, n, r);
		});
	});
}
function ME(e) {
	return { liPosMinGap: e ? e.liPosMinGap : void 0 };
}
function NE(e, t) {
	var n = e.model.ecModel, r = EE(_x(n)).axSer;
	r && FE(n, r.get(e.model.uid), t);
}
function PE(e, t, n) {
	var r = OE(e, t);
	r && FE(e.model.ecModel, r.sers, n);
}
function FE(e, t, n) {
	if (t) for (var r = 0; r < t.length; r++) {
		var i = t[r];
		e.isSeriesFiltered(i) || n(i);
	}
}
function IE(e, t) {
	var n = OE(e, t);
	if (!n || !n.sers.length) return 0;
	var r = 0;
	return FE(e.model.ecModel, n.sers, function() {
		r++;
	}), r;
}
function LE(e, t, n) {
	var r = EE(_x(e)).keyed, i = r && r.get(t);
	i && i.each(function(e) {
		n(e.axis);
	});
}
function RE(e, t) {
	var n = e.model, r = EE(_x(n.ecModel)).keys;
	r && I(r.get(n.uid), function(e) {
		t(e);
	});
}
function zE(e) {
	var t = DE(gx(e)), n = t.keyed ||= K();
	jE(e, function(t, r, i) {
		var a = n.get(r) || n.set(r, K()), o = a.get(i) || a.set(i, {});
		t.metrics.liPosMinGap && VE.liPosMinGap(e, t, o);
	});
}
function BE(e, t) {
	VE[e] = t;
}
var VE = {};
function HE(e, t, n) {
	if (e) {
		var r = t.ecModel, i = EE(_x(r)), a = e.model.uid, o = i.axSer ||= K();
		(o.get(a) || o.set(a, [])).push(t);
		var s = t.subType, c = t.getBaseAxis() === e, l = GE.get(UE(s, c, n)) || GE.get(UE(s, c, null));
		if (l) {
			var u = i.keyed ||= K(), d = i.keys ||= K(), f = l.key, p = u.get(f) || u.set(f, K()), m = p.get(a);
			m || (m = p.set(a, {
				axis: e,
				sers: [],
				serByIdx: []
			}), m.metrics = l.getMetrics(e), (d.get(a) || d.set(a, [])).push(f)), m.sers.push(t), m.serByIdx[t.seriesIndex] = t;
		}
	}
}
function UE(e, t, n) {
	return e + "|&" + G(t, !0) + "|&" + (n || "");
}
function WE(e, t) {
	var n = UE(t.seriesType, t.baseAxis, t.coordSysType);
	GE.set(n, t), TE(e, function() {
		e.registerProcessor(e.PRIORITY.PROCESSOR.AXIS_STATISTICS, { overallReset: zE });
	});
}
var GE = K(), KE = X(), qE = 3, JE = function() {
	function e(e, t, n, r, i) {
		var a = DT(e), o = a ? t.getCategories().length : null, s;
		if (a) {
			var c = t.getCategories(!0);
			s = c && !c.length;
		}
		var l = n.slice();
		(wT(e) || ET(e) || TT(e)) && (Vs(l, XE(e, t.get("dataMin", !0))), Hs(l, XE(e, t.get("dataMax", !0)))), Ks(l) || (l[0] = l[1] = NaN);
		var u = [], d = [!1, !1], f = t.get("min", !0);
		f === "dataMin" ? (u[0] = l[0], d[0] = !0) : (u[0] = XE(e, H(f) ? f({
			min: l[0],
			max: l[1]
		}) : f), d[0] = u[0] != null);
		var p = t.get("max", !0);
		p === "dataMax" ? (u[1] = l[1], d[1] = !0) : (u[1] = XE(e, H(p) ? p({
			min: l[0],
			max: l[1]
		}) : p), d[1] = u[1] != null);
		var m = ZE(e, t), h = a ? null : l[1] - l[0] || Math.abs(l[0]);
		u[0] ??= a ? s ? l[0] : o ? 0 : NaN : l[0] - m[0] * h, u[1] ??= a ? s ? l[1] : o ? o - 1 : NaN : l[1] + m[1] * h, !Ws(u[0]) && (u[0] = NaN), !Ws(u[1]) && (u[1] = NaN);
		var g = s || _e(u[0]) || _e(u[1]) || a && !o, _ = wT(e), v = _ && t.needIncludeZero && t.needIncludeZero();
		v && (u[0] > 0 && u[1] > 0 && !d[0] && (u[0] = 0), u[0] < 0 && u[1] < 0 && !d[1] && (u[1] = 0));
		var y = !1;
		u[0] > u[1] && (u.reverse(), y = !0);
		var b = XE(e, t.get("startValue", !0)), x = b != null;
		!Zo(b) && r && (b = e.getDefaultStartValue ? e.getDefaultStartValue() : 0), Zo(b) && (x || !_ || v) && (b < u[0] && !d[0] ? (u[0] = b, d[0] = !0) : b > u[1] && !d[1] && (u[1] = b, d[1] = !0)), YE(this._i = {
			scale: e,
			dataMM: l,
			noZoomEffMM: u,
			zoomMM: [],
			fixMM: d,
			zoomFixMM: [!1, !1],
			startValue: b,
			isBlank: g,
			incl0: v,
			tggAxInv: y,
			ctnShp: i
		}, u);
	}
	return e.prototype.makeNoZoom = function() {
		return this._i.noZoomEffMM.slice();
	}, e.prototype.makeFinal = function() {
		var e = this._i, t = e.zoomMM, n = e.noZoomEffMM, r = e.zoomFixMM, i = e.fixMM, a = {
			fixMM: i,
			zoomFixMM: r,
			isBlank: e.isBlank,
			incl0: e.incl0,
			tggAxInv: e.tggAxInv,
			ctnShp: e.ctnShp,
			effMM: n.slice()
		}, o = a.effMM;
		return t[0] != null && (o[0] = t[0], i[0] = r[0] = !0), t[1] != null && (o[1] = t[1], i[1] = r[1] = !0), YE(e, o), a;
	}, e.prototype.makeRenderInfo = function() {
		return { startValue: this._i.startValue };
	}, e.prototype.setZoomMM = function(e, t) {
		this._i.zoomMM[e] = t;
	}, e;
}();
function YE(e, t) {
	var n = e.scale, r = e.dataMM;
	n.sanitize && (t[0] = n.sanitize(t[0], r), t[1] = n.sanitize(t[1], r), qs(t));
}
function XE(e, t) {
	return t == null ? null : _e(t) ? NaN : e.parse(t);
}
function ZE(e, t) {
	var n;
	if (DT(e)) n = [0, 0];
	else {
		var r = t.get("boundaryGap");
		typeof r == "boolean" && (r = null), n = V(r) ? r : [r, r];
	}
	return [QE(n[0]), QE(n[1])];
}
function QE(e) {
	return Ta(typeof e == "boolean" ? 0 : e, 1) || 0;
}
function $E(e) {
	var t = KE(e.scale);
	return t.extent ||= zs(), t;
}
function eD(e, t) {
	$E(e).dimIdxInCoord = t.get(e.dim);
}
function tD(e, t) {
	var n = e.scale, r = e.model, i = e.dim;
	n.rawExtentInfo || nD(n, e, i, r, t);
}
function nD(e, t, n, r, i) {
	var a = $E(t), o = a.extent, s = !1;
	NE(t, function(r) {
		if (r.boxCoordinateSystem) {
			var i = Og(r).coord, c = a.dimIdxInCoord;
			if (c >= 0 && V(i)) {
				var l = i[c];
				l != null && !V(l) && Bs(o, e.parse(l));
			}
		} else if (r.coordinateSystem) {
			var u = r.getData();
			if (u) {
				var d = e.getFilter ? e.getFilter() : null;
				I(gE(u, n), function(e) {
					Us(o, u.getApproximateExtent(e, d));
				});
			}
			r.__requireStartValue && r.__requireStartValue(t) && (s = !0);
		}
	});
	var c = cD(e, t, r);
	iD(e, new JE(e, r, o, s, c), i), a.extent = null;
}
function rD(e, t) {
	var n = e.scale;
	iD(n, new JE(n, e.model, t, !1, !1), qE);
}
function iD(e, t, n) {
	e.rawExtentInfo = t, t.from = n;
}
function aD(e, t) {
	oD.set(e, t);
}
var oD = K();
function sD(e, t, n, r, i) {
	e.rawExtentInfo || rD({
		scale: e,
		model: t
	}, i || zs());
	var a = e.rawExtentInfo.makeFinal(), o = a.effMM;
	return e.setExtent(o[0], o[1]), e.setBlank(a.isBlank), r && a.tggAxInv && n && !n.get("legacyMinMaxDontInverseAxis") && (r.inverse = !r.inverse), a;
}
function cD(e, t, n) {
	var r = CE(e, n), i = n.get("containShape", !0);
	if (i == null && !r && (i = !0), !i) return !1;
	var a = !1;
	return RE(t, function(e) {
		a = !!oD.get(e) || a;
	}), a;
}
function lD(e, t, n, r) {
	if (n.ctnShp) {
		var i;
		if (RE(e, function(t) {
			var n = oD.get(t);
			if (n) {
				var a = n(e, r);
				a && (i ||= [0, 0], Vs(i, a[0]), Hs(i, a[1]), uE(e));
			}
		}), i) {
			var a = t.getExtent();
			if (DT(t)) e.onBand || t.setExtent2(1, lo(a[0], a[0] + i[0]), uo(a[1], a[1] + i[1]));
			else {
				var o = a.slice();
				n.zoomFixMM[0] || (o[0] = lo(o[0], t.transformOut(t.transformIn(o[0], null) + i[0], null))), n.zoomFixMM[1] || (o[1] = uo(o[1], t.transformOut(t.transformIn(o[1], null) + i[1], null))), (o[0] < a[0] || o[1] > a[1]) && t.setExtent2(1, o[0], o[1]);
			}
		}
	}
}
//#endregion
//#region node_modules/echarts/lib/coord/axisNiceTicks.js
function uD(e, t) {
	var n = ET(e), r = n ? e.intervalStub : e, i = t.fixMinMax || [], a = n ? e.getExtent() : null, o = r.getExtent(), s = MT(o, i, t.rawExtentResult);
	r.setExtent(s[0], s[1]), s = r.getExtent();
	var c = n ? fD(r, t) : dD(r, t), l = c.intervalPrecision, u = c.interval, d = t.userInterval;
	d != null && (c.interval = d, c.intervalPrecision = kT(d)), i[0] || (s[0] = Eo(mo(s[0] / u) * u, l)), i[1] || (s[1] = Eo(ho(s[1] / u) * u, l)), d != null && (c.niceExtent = s.slice()), xE(e, i, o, s, a, c);
}
function dD(e, t) {
	var n = PT(t.splitNumber, 5), r = yT(e), i = t.minInterval, a = t.maxInterval, o = Uo(r / n, !0);
	i != null && o < i && (o = i), a != null && o > a && (o = a);
	var s = kT(o), c = e.getExtent(), l = [Eo(ho(c[0] / o) * o, s), Eo(mo(c[1] / o) * o, s)];
	return {
		interval: o,
		intervalPrecision: s,
		niceExtent: l
	};
}
function fD(e, t) {
	var n = PT(t.splitNumber, 10), r = e.getExtent(), i = yT(e), a = uo(Vo(i), 1);
	n / i * a <= .5 && (a *= 10);
	var o = kT(a), s = [Eo(ho(r[0] / a) * a, o), Eo(mo(r[1] / a) * a, o)];
	return {
		intervalPrecision: o,
		interval: a,
		niceExtent: s
	};
}
function pD(e) {
	var t = e.scale, n = e.model, r = n.axis, i = n.ecModel;
	mD(t, n, r, i, null);
}
function mD(e, t, n, r, i) {
	var a = sD(e, t, r, n, i), o = wT(e) || TT(e);
	hD(e, {
		splitNumber: t.get("splitNumber"),
		fixMinMax: a.fixMM,
		userInterval: t.get("interval"),
		minInterval: o ? t.get("minInterval") : null,
		maxInterval: o ? t.get("maxInterval") : null,
		rawExtentResult: a
	}), n && r && lD(n, e, a, r);
}
function hD(e, t) {
	gD[e.type](e, t);
}
var gD = {
	interval: uD,
	log: uD,
	time: ZT,
	ordinal: Pe
}, _D = /* @__PURE__ */ e({
	createDimensions: () => Gw,
	createList: () => vD,
	createScale: () => bD,
	createSymbol: () => Ox,
	createTextStyle: () => SD,
	dataStack: () => yD,
	enableHoverEmphasis: () => Gd,
	getECData: () => Z,
	getLayoutRect: () => zg,
	mixinAxisModelCommonMethods: () => xD
});
function vD(e) {
	return aT(null, e);
}
var yD = {
	isDimensionStacked: tT,
	enableDataStack: $w,
	getStackedDimension: nT
};
function bD(e, t) {
	var n = t;
	t instanceof ih || (n = new ih(t));
	var r = sE(n), i = cE(n, r, !1);
	return e[1] < e[0] && (e = e.slice().reverse()), mD(i, n, null, null, e), i;
}
function xD(e) {
	F(e, wE);
}
function SD(e, t) {
	return t ||= {}, Fm(e, null, null, t.state !== "normal");
}
//#endregion
//#region node_modules/echarts/lib/extension.js
var CD = [], wD = {
	registerPreprocessor: JC,
	registerProcessor: YC,
	registerPostInit: XC,
	registerPostUpdate: ZC,
	registerUpdateLifecycle: QC,
	registerAction: $C,
	registerCoordinateSystem: ew,
	registerLayout: rw,
	registerVisual: iw,
	registerTransform: dw,
	registerLoading: sw,
	registerMap: lw,
	registerImpl: lx,
	PRIORITY: WS,
	ComponentModel: Jg,
	ComponentView: rb,
	SeriesModel: Jy,
	ChartView: sb,
	registerComponentModel: function(e) {
		Jg.registerClass(e);
	},
	registerComponentView: function(e) {
		rb.registerClass(e);
	},
	registerSeriesModel: function(e) {
		Jy.registerClass(e);
	},
	registerChartView: function(e) {
		sb.registerClass(e);
	},
	registerCustomSeries: function(e, t) {
		fx(e, t);
	},
	registerSubTypeDefaulter: function(e, t) {
		Jg.registerSubTypeDefaulter(e, t);
	},
	registerPainter: function(e, t) {
		to(e, t);
	}
};
function TD(e) {
	V(e) ? I(e, function(e) {
		TD(e);
	}) : P(CD, e) >= 0 || (CD.push(e), H(e) && (e = { install: e }), e.install(wD));
}
//#endregion
//#region node_modules/zrender/lib/contain/polygon.js
var ED = 1e-8;
function DD(e, t) {
	return Math.abs(e - t) < ED;
}
function OD(e, t, n) {
	var r = 0, i = e[0];
	if (!i) return !1;
	for (var a = 1; a < e.length; a++) {
		var o = e[a];
		r += Ul(i[0], i[1], o[0], o[1], t, n), i = o;
	}
	var s = e[0];
	return (!DD(i[0], s[0]) || !DD(i[1], s[1])) && (r += Ul(i[0], i[1], s[0], s[1], t, n)), r !== 0;
}
//#endregion
//#region node_modules/echarts/lib/coord/geo/Region.js
var kD = [];
function AD(e, t) {
	for (var n = 0; n < e.length; n++) ot(e[n], e[n], t);
}
function jD(e, t, n, r) {
	for (var i = 0; i < e.length; i++) {
		var a = e[i];
		r && (a = r.project(a)), a && isFinite(a[0]) && isFinite(a[1]) && (st(t, t, a), ct(n, n, a));
	}
}
function MD(e) {
	for (var t = 0, n = 0, r = 0, i = e.length, a = e[i - 1][0], o = e[i - 1][1], s = 0; s < i; s++) {
		var c = e[s][0], l = e[s][1], u = a * l - c * o;
		t += u, n += (a + c) * u, r += (o + l) * u, a = c, o = l;
	}
	return t ? [
		n / t / 3,
		r / t / 3,
		t
	] : [e[0][0] || 0, e[0][1] || 0];
}
var ND = function() {
	function e(e) {
		this.name = e;
	}
	return e.prototype.setCenter = function(e) {
		this._center = e;
	}, e.prototype.getCenter = function() {
		var e = this._center;
		return e ||= this._center = this.calcCenter(), e;
	}, e;
}(), PD = function() {
	function e(e, t) {
		this.type = "polygon", this.exterior = e, this.interiors = t;
	}
	return e;
}(), FD = function() {
	function e(e) {
		this.type = "linestring", this.points = e;
	}
	return e;
}(), ID = function(e) {
	n(t, e);
	function t(t, n, r) {
		var i = e.call(this, t) || this;
		return i.type = "geoJSON", i.geometries = n, i._center = r && [r[0], r[1]], i;
	}
	return t.prototype.calcCenter = function() {
		for (var e = this.geometries, t, n = 0, r = 0; r < e.length; r++) {
			var i = e[r], a = i.exterior, o = a && a.length;
			o > n && (t = i, n = o);
		}
		if (t) return MD(t.exterior);
		var s = this.getBoundingRect();
		return [s.x + s.width / 2, s.y + s.height / 2];
	}, t.prototype.getBoundingRect = function(e) {
		var t = this._rect;
		if (t && !e) return t;
		var n = [Infinity, Infinity], r = [-Infinity, -Infinity], i = this.geometries;
		return I(i, function(t) {
			t.type === "polygon" ? jD(t.exterior, n, r, e) : I(t.points, function(t) {
				jD(t, n, r, e);
			});
		}), isFinite(n[0]) && isFinite(n[1]) && isFinite(r[0]) && isFinite(r[1]) || (n[0] = n[1] = r[0] = r[1] = 0), t = new Y(n[0], n[1], r[0] - n[0], r[1] - n[1]), e || (this._rect = t), t;
	}, t.prototype.contain = function(e) {
		var t = this.getBoundingRect(), n = this.geometries;
		if (!t.contain(e[0], e[1])) return !1;
		loopGeo: for (var r = 0, i = n.length; r < i; r++) {
			var a = n[r];
			if (a.type === "polygon") {
				var o = a.exterior, s = a.interiors;
				if (OD(o, e[0], e[1])) {
					for (var c = 0; c < (s ? s.length : 0); c++) if (OD(s[c], e[0], e[1])) continue loopGeo;
					return !0;
				}
			}
		}
		return !1;
	}, t.prototype.transformTo = function(e, t, n, r) {
		var i = this.getBoundingRect(), a = i.width / i.height;
		n ? r ||= n / a : n = a * r;
		for (var o = new Y(e, t, n, r), s = i.calculateTransform(o), c = this.geometries, l = 0; l < c.length; l++) {
			var u = c[l];
			u.type === "polygon" ? (AD(u.exterior, s), I(u.interiors, function(e) {
				AD(e, s);
			})) : I(u.points, function(e) {
				AD(e, s);
			});
		}
		i = this._rect, i.copy(o), this._center = [i.x + i.width / 2, i.y + i.height / 2];
	}, t.prototype.cloneShallow = function(e) {
		e ??= this.name;
		var n = new t(e, this.geometries, this._center);
		return n._rect = this._rect, n.transformTo = null, n;
	}, t;
}(ND);
(function(e) {
	n(t, e);
	function t(t, n) {
		var r = e.call(this, t) || this;
		return r.type = "geoSVG", r._elOnlyForCalculate = n, r;
	}
	return t.prototype.calcCenter = function() {
		for (var e = this._elOnlyForCalculate, t = e.getBoundingRect(), n = [t.x + t.width / 2, t.y + t.height / 2], r = Wt(kD), i = e; i && !i.isGeoSVGGraphicRoot;) Kt(r, i.getLocalTransform(), r), i = i.parent;
		return Xt(r, r), ot(n, n, r), n;
	}, t;
})(ND);
//#endregion
//#region node_modules/echarts/lib/coord/geo/parseGeoJson.js
function LD(e) {
	if (!e.UTF8Encoding) return e;
	var t = e, n = t.UTF8Scale;
	n ??= 1024;
	var r = t.features;
	return I(r, function(e) {
		var t = e.geometry, r = t.encodeOffsets, i = t.coordinates;
		if (r) switch (t.type) {
			case "LineString":
				t.coordinates = zD(i, r, n);
				break;
			case "Polygon":
				RD(i, r, n);
				break;
			case "MultiLineString":
				RD(i, r, n);
				break;
			case "MultiPolygon": I(i, function(e, t) {
				return RD(e, r[t], n);
			});
		}
	}), t.UTF8Encoding = !1, t;
}
function RD(e, t, n) {
	for (var r = 0; r < e.length; r++) e[r] = zD(e[r], t[r], n);
}
function zD(e, t, n) {
	for (var r = [], i = t[0], a = t[1], o = 0; o < e.length; o += 2) {
		var s = e.charCodeAt(o) - 64, c = e.charCodeAt(o + 1) - 64;
		s = s >> 1 ^ -(s & 1), c = c >> 1 ^ -(c & 1), s += i, c += a, i = s, a = c, r.push([s / n, c / n]);
	}
	return r;
}
function BD(e, t) {
	return e = LD(e), L(oe(e.features, function(e) {
		return e.geometry && e.properties && e.geometry.coordinates.length > 0;
	}), function(e) {
		var n = e.properties, r = e.geometry, i = [];
		switch (r.type) {
			case "Polygon":
				var a = r.coordinates;
				i.push(new PD(a[0], a.slice(1)));
				break;
			case "MultiPolygon":
				I(r.coordinates, function(e) {
					e[0] && i.push(new PD(e[0], e.slice(1)));
				});
				break;
			case "LineString":
				i.push(new FD([r.coordinates]));
				break;
			case "MultiLineString": i.push(new FD(r.coordinates));
		}
		var o = new ID(n[t || "name"], i, n.cp);
		return o.properties = n, o;
	});
}
//#endregion
//#region node_modules/echarts/lib/export/api/number.js
var VD = /* @__PURE__ */ e({
	MAX_SAFE_INTEGER: () => Io,
	asc: () => Oo,
	getPercentWithPrecision: () => No,
	getPixelPrecision: () => jo,
	getPrecision: () => ko,
	getPrecisionSafe: () => Ao,
	isNumeric: () => qo,
	isRadianAroundZero: () => Ro,
	linearMap: () => xo,
	nice: () => Uo,
	numericToNumber: () => Ko,
	parseDate: () => Bo,
	parsePercent: () => So,
	quantile: () => Wo,
	quantity: () => Vo,
	quantityExponent: () => Ho,
	reformIntervals: () => Go,
	remRadian: () => Lo,
	round: () => Do
}), HD = /* @__PURE__ */ e({
	format: () => Gh,
	parse: () => Bo,
	roundTime: () => Jh
}), UD = /* @__PURE__ */ e({
	Arc: () => up,
	BezierCurve: () => cp,
	BoundingRect: () => Y,
	Circle: () => Of,
	CompoundPath: () => dp,
	Ellipse: () => Af,
	Group: () => Wa,
	Image: () => fu,
	IncrementalDisplayable: () => Tp,
	Line: () => ip,
	LinearGradient: () => pp,
	Polygon: () => $f,
	Polyline: () => tp,
	RadialGradient: () => mp,
	Rect: () => bu,
	Ring: () => Yf,
	Sector: () => qf,
	Text: () => Tu,
	clipPointsByRect: () => am,
	clipRectByRect: () => om,
	createIcon: () => sm,
	extendPath: () => Hp,
	extendShape: () => Bp,
	getShapeClass: () => Wp,
	getTransform: () => $p,
	initProps: () => Ap,
	makeImage: () => Kp,
	makePath: () => Gp,
	mergePath: () => Jp,
	registerShape: () => Up,
	resizePath: () => Yp,
	updateProps: () => kp
}), WD = /* @__PURE__ */ e({
	addCommas: () => ug,
	capitalFirst: () => yg,
	encodeHTML: () => Tt,
	formatTime: () => vg,
	formatTpl: () => gg,
	getTextRect: () => lg,
	getTooltipMarker: () => _g,
	normalizeCssArray: () => fg,
	toCamelCase: () => dg,
	truncateText: () => Ec
}), GD = /* @__PURE__ */ e({
	bind: () => z,
	clone: () => A,
	curry: () => B,
	defaults: () => N,
	each: () => I,
	extend: () => M,
	filter: () => oe,
	indexOf: () => P,
	inherits: () => re,
	isArray: () => V,
	isFunction: () => H,
	isObject: () => W,
	isString: () => U,
	map: () => L,
	merge: () => j,
	reduce: () => ae
}), KD = X(), qD = X(), JD = {
	estimate: 1,
	determine: 2
};
function YD(e) {
	return {
		out: { noPxChangeTryDetermine: [] },
		kind: e
	};
}
function XD(e, t) {
	var n = e.getLabelModel().get("customValues");
	if (n) {
		var r = e.scale;
		return { labels: L(QD(n, r), function(t, n) {
			return {
				formattedLabel: fE(e)(t, n),
				rawLabel: r.getLabel(t),
				tick: t
			};
		}) };
	}
	return e.type === "category" ? $D(e, t) : nO(e);
}
function ZD(e, t, n) {
	var r = e.scale, i = e.getTickModel().get("customValues");
	return i ? { ticks: QD(i, r) } : e.type === "category" ? tO(e, t) : { ticks: r.getTicks(n) };
}
function QD(e, t) {
	var n = t.getExtent(), r = [];
	return I(e, function(e) {
		e = t.parse(e), e >= n[0] && e <= n[1] && r.push(e);
	}), Xs(r, Qs, null), Oo(r), L(r, function(e) {
		return { value: e };
	});
}
function $D(e, t) {
	var n = e.getLabelModel(), r = eO(e, n, t);
	return !n.get("show") || e.scale.isBlank() ? { labels: [] } : r;
}
function eO(e, t, n) {
	var r = iO(e), i = mE(t), a = n.kind === JD.estimate;
	if (!a) {
		var o = oO(r, i);
		if (o) return o;
	}
	var s, c;
	H(i) ? s = pO(e, i, !1) : (c = i === "auto" ? cO(e, n) : i, s = pO(e, c, !1));
	var l = {
		labels: s,
		labelCategoryInterval: c
	};
	return a ? n.out.noPxChangeTryDetermine.push(function() {
		return sO(r, i, l), !0;
	}) : sO(r, i, l), l;
}
function tO(e, t) {
	var n = rO(e), r = mE(t), i = oO(n, r);
	if (i) return i;
	var a, o;
	if ((!t.get("show") || e.scale.isBlank()) && (a = []), H(r)) a = pO(e, r, !0);
	else if (r === "auto") {
		var s = eO(e, e.getLabelModel(), YD(JD.determine));
		o = s.labelCategoryInterval, a = L(s.labels, function(e) {
			return e.tick;
		});
	} else o = r, a = pO(e, o, !0);
	return sO(n, r, {
		ticks: a,
		tickCategoryInterval: o
	});
}
function nO(e) {
	var t = e.scale.getTicks(), n = fE(e);
	return { labels: L(t, function(t, r) {
		return {
			formattedLabel: n(t, r),
			rawLabel: e.scale.getLabel(t),
			tick: t
		};
	}) };
}
var rO = aO("axisTick"), iO = aO("axisLabel");
function aO(e) {
	return function(t) {
		return qD(t)[e] || (qD(t)[e] = { list: [] });
	};
}
function oO(e, t) {
	for (var n = 0; n < e.list.length; n++) if (e.list[n].key === t) return e.list[n].value;
}
function sO(e, t, n) {
	return e.list.push({
		key: t,
		value: n
	}), n;
}
function cO(e, t) {
	if (t.kind === JD.estimate) {
		var n = e.calculateCategoryInterval(t);
		return t.out.noPxChangeTryDetermine.push(function() {
			return qD(e).autoInterval = n, !0;
		}), n;
	}
	return qD(e).autoInterval ?? (qD(e).autoInterval = e.calculateCategoryInterval(t));
}
function lO(e, t) {
	var n = t.kind, r = fO(e), i = fE(e), a = (r.axisRotate - r.labelRotate) / 180 * Math.PI, o = e.scale, s = o.getExtent(), c = o.count();
	if (s[1] - s[0] < 1) return 0;
	var l = 1, u = 40;
	c > u && (l = Math.max(1, Math.floor(c / u)));
	for (var d = s[0], f = e.dataToCoord(d + 1) - e.dataToCoord(d), p = Math.abs(f * Math.cos(a)), m = Math.abs(f * Math.sin(a)), h = 0, g = 0; d <= s[1]; d += l) {
		var _ = 0, v = 0, y = xa(i({ value: d }), r.font, "center", "top");
		_ = y.width * 1.3, v = y.height * 1.3, h = Math.max(h, _, 7), g = Math.max(g, v, 7);
	}
	var b = h / p, x = g / m;
	isNaN(b) && (b = Infinity), isNaN(x) && (x = Infinity);
	var S = Math.max(0, Math.floor(Math.min(b, x)));
	return n === JD.estimate ? (t.out.noPxChangeTryDetermine.push(z(uO, null, e, S, c)), S) : dO(e, S, c) ?? S;
}
function uO(e, t, n) {
	return dO(e, t, n) == null;
}
function dO(e, t, n) {
	var r = KD(e.model), i = e.getExtent(), a = r.lastAutoInterval, o = r.lastTickCount;
	if (a != null && o != null && Math.abs(a - t) <= 1 && Math.abs(o - n) <= 1 && a > t && r.axisExtent0 === i[0] && r.axisExtent1 === i[1]) return a;
	r.lastTickCount = n, r.lastAutoInterval = t, r.axisExtent0 = i[0], r.axisExtent1 = i[1];
}
function fO(e) {
	var t = e.getLabelModel();
	return {
		axisRotate: e.getRotate ? e.getRotate() : e.isHorizontal && !e.isHorizontal() ? 90 : 0,
		labelRotate: t.get("rotate") || 0,
		font: t.getFont()
	};
}
function pO(e, t, n) {
	var r = fE(e), i = e.scale, a = [], o = H(t);
	return FT(i, o ? 0 : t, function(e, s) {
		var c = i.getLabel(e);
		if (o) {
			var l = !!t(e.value, c);
			if (e.offInterval = !l, !l && !s) return;
		}
		a.push(n ? e : {
			formattedLabel: r(e),
			rawLabel: c,
			tick: e
		});
	}), a;
}
//#endregion
//#region node_modules/echarts/lib/coord/axisBand.js
var mO = .8;
function hO(e, t) {
	t ||= {};
	var n = {
		w: NaN,
		w2: NaN
	}, r = e.scale, i = t.fromStat, a = t.min, o = vT(r);
	Zo(o) || (o = NaN);
	var s = e.getExtent(), c = fo(s[1] - s[0]);
	return DT(r) ? gO(n, e, o, c) : i && _O(n, e, o, c, i), a != null && (n.w = Zo(n.w) ? uo(a, n.w) : a), n;
}
function gO(e, t, n, r) {
	var i = t.onBand, a = n + +!!i;
	a === 0 && (a = 1), e.w = r / a, !i && n && r && (e.w2 = e.w * n / r);
}
function _O(e, t, n, r, i) {
	var a = !1, o = -Infinity;
	I(i.key ? [kE(t, i.key)] : AE(t, i.sers || []), function(e) {
		var t = e.liPosMinGap;
		t != null && (t > 0 ? (t > o && (o = t), a = !1) : t === -2 && (a = !0));
	}), Zo(n) && n > 0 && Zo(o) ? (e.w = r / n * o, e.w2 = o) : a && (e.w = r * mO, e.w2 = e.w * n / r);
}
//#endregion
//#region node_modules/echarts/lib/coord/Axis.js
var vO = [0, 1], yO = function() {
	function e(e, t, n) {
		this.onBand = !1, this.inverse = !1, this.dim = e, this.scale = t, this._extent = n || [0, 0];
	}
	return e.prototype.contain = function(e) {
		var t = this._extent, n = Math.min(t[0], t[1]), r = Math.max(t[0], t[1]);
		return e >= n && e <= r;
	}, e.prototype.containData = function(e) {
		return this.scale.contain(this.scale.parse(e));
	}, e.prototype.getExtent = function() {
		return this._extent.slice();
	}, e.prototype.setExtent = function(e, t) {
		var n = this._extent;
		n[0] = e, n[1] = t;
	}, e.prototype.dataToCoord = function(e, t) {
		var n = this.scale;
		return e = n.normalize(n.parse(e)), xo(e, vO, bO(this), t);
	}, e.prototype.coordToData = function(e, t) {
		var n = xo(e, bO(this), vO, t);
		return this.scale.scale(n);
	}, e.prototype.pointToData = function(e, t) {}, e.prototype.getTicksCoords = function(e) {
		e ||= {};
		var t = e.tickModel || this.getTickModel(), n = L(ZD(this, t, {
			breakTicks: e.breakTicks,
			pruneByBreak: e.pruneByBreak
		}).ticks, function(e) {
			return {
				coord: this.dataToCoord(SE(this.scale, e)),
				tick: e
			};
		}, this), r = t.get("alignWithLabel"), i = xO(this, n, r);
		return L(n, function(e) {
			return {
				coord: e.coord,
				tickValue: e.tick.value,
				onBand: i
			};
		});
	}, e.prototype.getMinorTicksCoords = function() {
		if (DT(this.scale)) return [];
		var e = this.model.getModel("minorTick").get("splitNumber");
		return e > 0 && e < 100 || (e = 5), L(this.scale.getMinorTicks(e), function(e) {
			return L(e, function(e) {
				return {
					coord: this.dataToCoord(e),
					tickValue: e
				};
			}, this);
		}, this);
	}, e.prototype.getViewLabels = function(e) {
		return e ||= YD(JD.determine), XD(this, e).labels;
	}, e.prototype.getLabelModel = function() {
		return this.model.getModel("axisLabel");
	}, e.prototype.getTickModel = function() {
		return this.model.getModel("axisTick");
	}, e.prototype.getBandWidth = function() {
		return hO(this, { min: 1 }).w;
	}, e.prototype.calculateCategoryInterval = function(e) {
		return e ||= YD(JD.determine), lO(this, e);
	}, e;
}();
function bO(e) {
	var t = e.getExtent();
	if (e.onBand) {
		var n = (t[1] - t[0]) / e.scale.count() / 2;
		t[0] += n, t[1] -= n;
	}
	return t;
}
function xO(e, t, n) {
	var r = t.length;
	if (!e.onBand || n || !r) return !1;
	var i = hO(e).w;
	if (!i) return !1;
	I(t, function(e) {
		e.coord -= i / 2;
	});
	var a = e.scale.getExtent(), o = t[r - 1];
	return o.tick.offInterval && t.pop(), t.push({
		coord: o.coord + i,
		tick: { value: a[1] + 1 }
	}), !0;
}
//#endregion
//#region node_modules/echarts/lib/export/api.js
function SO(e) {
	var t = Jg.extend(e);
	return Jg.registerClass(t), t;
}
function CO(e) {
	var t = rb.extend(e);
	return rb.registerClass(t), t;
}
function wO(e) {
	var t = Jy.extend(e);
	return Jy.registerClass(t), t;
}
function TO(e) {
	var t = sb.extend(e);
	return sb.registerClass(t), t;
}
//#endregion
//#region node_modules/echarts/lib/label/labelGuideHelper.js
var EO = Math.PI * 2, DO = Fl.CMD, OO = [
	"top",
	"right",
	"bottom",
	"left"
];
function kO(e, t, n, r, i) {
	var a = n.width, o = n.height;
	switch (e) {
		case "top":
			r.set(n.x + a / 2, n.y - t), i.set(0, -1);
			break;
		case "bottom":
			r.set(n.x + a / 2, n.y + o + t), i.set(0, 1);
			break;
		case "left":
			r.set(n.x - t, n.y + o / 2), i.set(-1, 0);
			break;
		case "right": r.set(n.x + a + t, n.y + o / 2), i.set(1, 0);
	}
}
function AO(e, t, n, r, i, a, o, s, c) {
	o -= e, s -= t;
	var l = Math.sqrt(o * o + s * s);
	o /= l, s /= l;
	var u = o * n + e, d = s * n + t;
	if (Math.abs(r - i) % EO < 1e-4) return c[0] = u, c[1] = d, l - n;
	if (a) {
		var f = r;
		r = Bl(i), i = Bl(f);
	} else r = Bl(r), i = Bl(i);
	r > i && (i += EO);
	var p = Math.atan2(s, o);
	if (p < 0 && (p += EO), p >= r && p <= i || p + EO >= r && p + EO <= i) return c[0] = u, c[1] = d, l - n;
	var m = n * Math.cos(r) + e, h = n * Math.sin(r) + t, g = n * Math.cos(i) + e, _ = n * Math.sin(i) + t, v = (m - o) * (m - o) + (h - s) * (h - s), y = (g - o) * (g - o) + (_ - s) * (_ - s);
	return v < y ? (c[0] = m, c[1] = h, Math.sqrt(v)) : (c[0] = g, c[1] = _, Math.sqrt(y));
}
function jO(e, t, n, r, i, a, o, s) {
	var c = i - e, l = a - t, u = n - e, d = r - t, f = Math.sqrt(u * u + d * d);
	u /= f, d /= f;
	var p = (c * u + l * d) / f;
	s && (p = Math.min(Math.max(p, 0), 1)), p *= f;
	var m = o[0] = e + p * u, h = o[1] = t + p * d;
	return Math.sqrt((m - i) * (m - i) + (h - a) * (h - a));
}
function MO(e, t, n, r, i, a, o) {
	n < 0 && (e += n, n = -n), r < 0 && (t += r, r = -r);
	var s = e + n, c = t + r, l = o[0] = Math.min(Math.max(i, e), s), u = o[1] = Math.min(Math.max(a, t), c);
	return Math.sqrt((l - i) * (l - i) + (u - a) * (u - a));
}
var NO = [];
function PO(e, t, n) {
	var r = MO(t.x, t.y, t.width, t.height, e.x, e.y, NO);
	return n.set(NO[0], NO[1]), r;
}
function FO(e, t, n) {
	for (var r = 0, i = 0, a = 0, o = 0, s, c, l = Infinity, u = t.data, d = e.x, f = e.y, p = 0; p < u.length;) {
		var m = u[p++];
		p === 1 && (r = u[p], i = u[p + 1], a = r, o = i);
		var h = l;
		switch (m) {
			case DO.M:
				a = u[p++], o = u[p++], r = a, i = o;
				break;
			case DO.L:
				h = jO(r, i, u[p], u[p + 1], d, f, NO, !0), r = u[p++], i = u[p++];
				break;
			case DO.C:
				h = fr(r, i, u[p++], u[p++], u[p++], u[p++], u[p], u[p + 1], d, f, NO), r = u[p++], i = u[p++];
				break;
			case DO.Q:
				h = yr(r, i, u[p++], u[p++], u[p], u[p + 1], d, f, NO), r = u[p++], i = u[p++];
				break;
			case DO.A:
				var g = u[p++], _ = u[p++], v = u[p++], y = u[p++], b = u[p++], x = u[p++];
				p += 1;
				var S = !!(1 - u[p++]);
				s = Math.cos(b) * v + g, c = Math.sin(b) * y + _, p <= 1 && (a = s, o = c);
				var C = (d - g) * y / v + g;
				h = AO(g, _, y, b, b + x, S, C, f, NO), r = Math.cos(b + x) * v + g, i = Math.sin(b + x) * y + _;
				break;
			case DO.R:
				a = r = u[p++], o = i = u[p++];
				var w = u[p++], T = u[p++];
				h = MO(a, o, w, T, d, f, NO);
				break;
			case DO.Z: h = jO(r, i, a, o, d, f, NO, !0), r = a, i = o;
		}
		h < l && (l = h, n.set(NO[0], NO[1]));
	}
	return l;
}
var IO = new J(), LO = new J(), RO = new J(), zO = new J(), BO = new J();
function VO(e, t) {
	if (e) {
		var n = e.getTextGuideLine(), r = e.getTextContent();
		if (r && n) {
			var i = e.textGuideLineConfig || {}, a = [
				[0, 0],
				[0, 0],
				[0, 0]
			], o = i.candidates || OO, s = r.getBoundingRect().clone();
			s.applyTransform(r.getComputedTransform());
			var c = Infinity, l = i.anchor, u = e.getComputedTransform(), d = u && Xt([], u), f = t.get("length2") || 0;
			l && RO.copy(l);
			for (var p = 0; p < o.length; p++) {
				var m = o[p];
				kO(m, 0, s, IO, zO), J.scaleAndAdd(LO, IO, zO, f), LO.transform(d);
				var h = e.getBoundingRect(), g = l ? l.distance(LO) : e instanceof ou ? FO(LO, e.path, RO) : PO(LO, h, RO);
				g < c && (c = g, LO.transform(u), RO.transform(u), RO.toArray(a[0]), LO.toArray(a[1]), IO.toArray(a[2]));
			}
			WO(a, t.get("minTurnAngle")), n.setShape({ points: a });
		}
	}
}
var HO = [], UO = new J();
function WO(e, t) {
	if (t <= 180 && t > 0) {
		t = t / 180 * Math.PI, IO.fromArray(e[0]), LO.fromArray(e[1]), RO.fromArray(e[2]), J.sub(zO, IO, LO), J.sub(BO, RO, LO);
		var n = zO.len(), r = BO.len();
		if (!(n < .001 || r < .001)) {
			zO.scale(1 / n), BO.scale(1 / r);
			var i = zO.dot(BO);
			if (Math.cos(t) < i) {
				var a = jO(LO.x, LO.y, RO.x, RO.y, IO.x, IO.y, HO, !1);
				UO.fromArray(HO), UO.scaleAndAdd(BO, a / Math.tan(Math.PI - t));
				var o = RO.x === LO.x ? (UO.y - LO.y) / (RO.y - LO.y) : (UO.x - LO.x) / (RO.x - LO.x);
				if (isNaN(o)) return;
				o < 0 ? J.copy(UO, LO) : o > 1 && J.copy(UO, RO), UO.toArray(e[1]);
			}
		}
	}
}
function GO(e, t, n) {
	if (n <= 180 && n > 0) {
		n = n / 180 * Math.PI, IO.fromArray(e[0]), LO.fromArray(e[1]), RO.fromArray(e[2]), J.sub(zO, LO, IO), J.sub(BO, RO, LO);
		var r = zO.len(), i = BO.len();
		if (!(r < .001 || i < .001) && (zO.scale(1 / r), BO.scale(1 / i), zO.dot(t) < Math.cos(n))) {
			var a = jO(LO.x, LO.y, RO.x, RO.y, IO.x, IO.y, HO, !1);
			UO.fromArray(HO);
			var o = Math.PI / 2, s = o + Math.acos(BO.dot(t)) - n;
			if (s >= o) J.copy(UO, RO);
			else {
				UO.scaleAndAdd(BO, a / Math.tan(Math.PI / 2 - s));
				var c = RO.x === LO.x ? (UO.y - LO.y) / (RO.y - LO.y) : (UO.x - LO.x) / (RO.x - LO.x);
				if (isNaN(c)) return;
				c < 0 ? J.copy(UO, LO) : c > 1 && J.copy(UO, RO);
			}
			UO.toArray(e[1]);
		}
	}
}
function KO(e, t, n, r) {
	var i = n === "normal", a = i ? e : e.ensureState(n);
	a.ignore = t;
	var o = r.get("smooth");
	o = o === !0 ? .3 : Math.max(+o, 0) || 0, a.shape = a.shape || {}, a.shape.smooth = o;
	var s = r.getModel("lineStyle").getLineStyle();
	i ? e.useStyle(s) : a.style = s;
}
function qO(e, t) {
	var n = t.smooth, r = t.points;
	if (r) {
		if (e.moveTo(r[0][0], r[0][1]), n > 0 && r.length >= 3) {
			var i = tt(r[0], r[1]), a = tt(r[1], r[2]);
			if (!i || !a) {
				e.lineTo(r[1][0], r[1][1]), e.lineTo(r[2][0], r[2][1]);
				return;
			}
			var o = Math.min(i, a) * n, s = at([], r[1], r[0], o / i), c = at([], r[1], r[2], o / a), l = at([], s, c, .5);
			e.bezierCurveTo(s[0], s[1], s[0], s[1], l[0], l[1]), e.bezierCurveTo(c[0], c[1], c[0], c[1], r[2][0], r[2][1]);
		} else for (var u = 1; u < r.length; u++) e.lineTo(r[u][0], r[u][1]);
	}
}
function JO(e, t, n) {
	var r = e.getTextGuideLine(), i = e.getTextContent();
	if (!i) r && e.removeTextGuideLine();
	else {
		for (var a = t.normal, o = a.get("show"), s = i.ignore, c = 0; c < nd.length; c++) {
			var l = nd[c], u = t[l], d = l === "normal";
			if (u) {
				var f = u.get("show");
				if ((d ? s : G(i.states[l] && i.states[l].ignore, s)) || !G(f, o)) {
					var p = d ? r : r && r.states[l];
					p && (p.ignore = !0), r && KO(r, !0, l, u);
					continue;
				}
				r || (r = new tp(), e.setTextGuideLine(r), !d && (s || !o) && KO(r, !0, "normal", t.normal), e.stateProxy && (r.stateProxy = e.stateProxy)), KO(r, !1, l, u);
			}
		}
		if (r) {
			N(r.style, n), r.style.fill = null;
			var m = a.get("showAbove"), h = e.textGuideLineConfig = e.textGuideLineConfig || {};
			h.showAbove = m || !1, r.buildPath = qO;
		}
	}
}
function YO(e, t) {
	t ||= "labelLine";
	for (var n = { normal: e.getModel(t) }, r = 0; r < td.length; r++) {
		var i = td[r];
		n[i] = e.getModel([i, t]);
	}
	return n;
}
//#endregion
//#region node_modules/echarts/lib/label/labelLayoutHelper.js
var XO = [
	"label",
	"labelLine",
	"layoutOption",
	"priority",
	"defaultAttr",
	"marginForce",
	"minMarginForce",
	"marginDefault",
	"suggestIgnore"
], ZO = 1, QO = 2, $O = ZO | QO;
function ek(e, t, n) {
	n ||= $O, t ? e.dirty |= n : e.dirty &= ~n;
}
function tk(e, t) {
	return t ||= $O, e.dirty == null || !!(e.dirty & t);
}
function nk(e) {
	if (e) return tk(e) && rk(e, e.label, e), e;
}
function rk(e, t, n) {
	var r = t.getComputedTransform();
	e.transform = xm(e.transform, r);
	var i = e.localRect = bm(e.localRect, t.getBoundingRect()), a = t.style, o = a.margin, s = n && n.marginForce, c = n && n.minMarginForce, l = n && n.marginDefault, u = a.__marginType;
	u == null && l && (o = l, u = qm.textMargin);
	for (var d = 0; d < 4; d++) ik[d] = u === qm.minMargin && c && c[d] != null ? c[d] : s && s[d] != null ? s[d] : o ? o[d] : 0;
	u === qm.textMargin && fm(i, ik, !1, !1);
	var f = e.rect = bm(e.rect, i);
	return r && f.applyTransform(r), u === qm.minMargin && fm(f, ik, !1, !1), e.axisAligned = vm(r), (e.label = e.label || {}).ignore = t.ignore, ek(e, !1), ek(e, !0, QO), e;
}
var ik = [
	0,
	0,
	0,
	0
];
function ak(e, t, n) {
	return e.transform = xm(e.transform, n), e.localRect = bm(e.localRect, t), e.rect = bm(e.rect, t), n && e.rect.applyTransform(n), e.axisAligned = vm(n), e.obb = void 0, (e.label = e.label || {}).ignore = !1, e;
}
function ok(e, t) {
	if (e) {
		e.label.x += t.x, e.label.y += t.y, e.label.markRedraw();
		var n = e.transform;
		n && (n[4] += t.x, n[5] += t.y);
		var r = e.rect;
		r && (r.x += t.x, r.y += t.y);
		var i = e.obb;
		i && i.fromBoundingRect(e.localRect, n);
	}
}
function sk(e, t) {
	for (var n = 0; n < XO.length; n++) {
		var r = XO[n];
		e[r] ?? (e[r] = t[r]);
	}
	return nk(e);
}
function ck(e) {
	var t = e.obb;
	return (!t || tk(e, QO)) && (e.obb = t ||= new Cp(), t.fromBoundingRect(e.localRect, e.transform), ek(e, !1, QO)), t;
}
function lk(e, t, n, r, i) {
	var a = e.length, o = Rp[t], s = zp[t];
	if (a < 2) return !1;
	e.sort(function(e, t) {
		return e.rect[o] - t.rect[o];
	});
	for (var c = 0, l, u = !1, d = 0, f = 0; f < a; f++) {
		var p = e[f], m = p.rect;
		l = m[o] - c, l < 0 && (m[o] -= l, p.label[o] -= l, u = !0);
		var h = Math.max(-l, 0);
		d += h, c = m[o] + m[s];
	}
	d > 0 && i && S(-d / a, 0, a);
	var g = e[0], _ = e[a - 1], v, y;
	b(), v < 0 && C(-v, .8), y < 0 && C(y, .8), b(), x(v, y, 1), x(y, v, -1), b(), v < 0 && w(-v), y < 0 && w(y);
	function b() {
		v = g.rect[o] - n, y = r - _.rect[o] - _.rect[s];
	}
	function x(e, t, n) {
		if (e < 0) {
			var r = Math.min(t, -e);
			if (r > 0) {
				S(r * n, 0, a);
				var i = r + e;
				i < 0 && C(-i * n, 1);
			} else C(-e * n, 1);
		}
	}
	function S(t, n, r) {
		t !== 0 && (u = !0);
		for (var i = n; i < r; i++) {
			var a = e[i], s = a.rect;
			s[o] += t, a.label[o] += t;
		}
	}
	function C(t, n) {
		for (var r = [], i = 0, c = 1; c < a; c++) {
			var l = e[c - 1].rect, u = Math.max(e[c].rect[o] - l[o] - l[s], 0);
			r.push(u), i += u;
		}
		if (i) {
			var d = Math.min(Math.abs(t) / i, n);
			if (t > 0) for (var c = 0; c < a - 1; c++) {
				var f = r[c] * d;
				S(f, 0, c + 1);
			}
			else for (var c = a - 1; c > 0; c--) {
				var f = r[c - 1] * d;
				S(-f, c, a);
			}
		}
	}
	function w(e) {
		var t = e < 0 ? -1 : 1;
		e = Math.abs(e);
		for (var n = Math.ceil(e / (a - 1)), r = 0; r < a - 1; r++) if (t > 0 ? S(n, 0, r + 1) : S(-n, a - r - 1, a), e -= n, e <= 0) return;
	}
	return u;
}
function uk(e) {
	for (var t = 0; t < e.length; t++) {
		var n = e[t], r = n.defaultAttr, i = n.labelLine;
		n.label.attr("ignore", r.ignore), i && i.attr("ignore", r.labelGuideIgnore);
	}
}
function dk(e) {
	var t = [];
	e.sort(function(e, t) {
		return +!!t.suggestIgnore - !!e.suggestIgnore || t.priority - e.priority;
	});
	function n(e) {
		if (!e.ignore) {
			var t = e.ensureState("emphasis");
			t.ignore ??= !1;
		}
		e.ignore = !0;
	}
	for (var r = 0; r < e.length; r++) {
		var i = nk(e[r]);
		if (!i.label.ignore) {
			for (var a = i.label, o = i.labelLine, s = !1, c = 0; c < t.length; c++) if (fk(i, t[c], null, { touchThreshold: .05 })) {
				s = !0;
				break;
			}
			s ? (n(a), o && n(o)) : t.push(i);
		}
	}
}
function fk(e, t, n, r) {
	return !e || !t || e.label && e.label.ignore || t.label && t.label.ignore || !e.rect.intersect(t.rect, n, r) ? !1 : e.axisAligned && t.axisAligned ? !0 : ck(e).intersect(ck(t), n, r);
}
//#endregion
//#region node_modules/echarts/lib/label/LabelManager.js
function pk(e) {
	if (e) {
		for (var t = [], n = 0; n < e.length; n++) t.push(e[n].slice());
		return t;
	}
}
function mk(e, t) {
	var n = e.label, r = t && t.getTextGuideLine();
	return {
		dataIndex: e.dataIndex,
		dataType: e.dataType,
		seriesIndex: e.seriesModel.seriesIndex,
		text: e.label.style.text,
		rect: e.hostRect,
		labelRect: e.rect,
		align: n.style.align,
		verticalAlign: n.style.verticalAlign,
		labelLinePoints: pk(r && r.shape.points)
	};
}
var hk = [
	"align",
	"verticalAlign",
	"width",
	"height",
	"fontSize"
], gk = new ca(), _k = X(), vk = X();
function yk(e, t, n) {
	for (var r = 0; r < n.length; r++) {
		var i = n[r];
		t[i] != null && (e[i] = t[i]);
	}
}
var bk = [
	"x",
	"y",
	"rotation"
], xk = function() {
	function e() {
		this._labelList = [], this._chartViewList = [];
	}
	return e.prototype.clearLabels = function() {
		this._labelList = [], this._chartViewList = [];
	}, e.prototype._addLabel = function(e, t, n, r, i) {
		var a = r.style, o = r.__hostTarget.textConfig || {}, s = r.getComputedTransform(), c = r.getBoundingRect().plain();
		Y.applyTransform(c, c, s), s ? gk.setLocalTransform(s) : (gk.x = gk.y = gk.rotation = gk.originX = gk.originY = 0, gk.scaleX = gk.scaleY = 1), gk.rotation = Bl(gk.rotation);
		var l = r.__hostTarget, u;
		if (l) {
			u = l.getBoundingRect().plain();
			var d = l.getComputedTransform();
			Y.applyTransform(u, u, d);
		}
		var f = u && l.getTextGuideLine();
		this._labelList.push({
			label: r,
			labelLine: f,
			seriesModel: n,
			dataIndex: e,
			dataType: t,
			layoutOptionOrCb: i,
			layoutOption: null,
			rect: c,
			hostRect: u,
			priority: u ? u.width * u.height : 0,
			defaultAttr: {
				ignore: r.ignore,
				labelGuideIgnore: f && f.ignore,
				x: gk.x,
				y: gk.y,
				scaleX: gk.scaleX,
				scaleY: gk.scaleY,
				rotation: gk.rotation,
				style: {
					x: a.x,
					y: a.y,
					align: a.align,
					verticalAlign: a.verticalAlign,
					width: a.width,
					height: a.height,
					fontSize: a.fontSize
				},
				cursor: r.cursor,
				attachedPos: o.position,
				attachedRot: o.rotation
			}
		});
	}, e.prototype.addLabelsOfSeries = function(e) {
		var t = this;
		this._chartViewList.push(e);
		var n = e.__model, r = n.get("labelLayout");
		(H(r) || R(r).length) && e.group.traverse(function(e) {
			if (e.ignore) return !0;
			var i = e.getTextContent(), a = Z(e);
			i && !i.disableLabelLayout && t._addLabel(a.dataIndex, a.dataType, n, i, r);
		});
	}, e.prototype.updateLayoutConfig = function(e) {
		var t = e.getWidth(), n = e.getHeight();
		function r(e, t) {
			return function() {
				VO(e, t);
			};
		}
		for (var i = 0; i < this._labelList.length; i++) {
			var a = this._labelList[i], o = a.label, s = o.__hostTarget, c = a.defaultAttr, l = void 0;
			l = H(a.layoutOptionOrCb) ? a.layoutOptionOrCb(mk(a, s)) : a.layoutOptionOrCb, l ||= {}, a.layoutOption = l;
			var u = Math.PI / 180;
			s && s.setTextConfig({
				local: !1,
				position: l.x != null || l.y != null ? null : c.attachedPos,
				rotation: l.rotate == null ? c.attachedRot : l.rotate * u,
				offset: [l.dx || 0, l.dy || 0]
			});
			var d = !1;
			if (l.x == null ? (o.x = c.x, o.setStyle("x", c.style.x)) : (o.x = So(l.x, t), o.setStyle("x", 0), d = !0), l.y == null ? (o.y = c.y, o.setStyle("y", c.style.y)) : (o.y = So(l.y, n), o.setStyle("y", 0), d = !0), l.labelLinePoints) {
				var f = s.getTextGuideLine();
				f && (f.setShape({ points: l.labelLinePoints }), d = !1);
			}
			var p = _k(o);
			p.needsUpdateLabelLine = d, o.rotation = l.rotate == null ? c.rotation : l.rotate * u, o.scaleX = c.scaleX, o.scaleY = c.scaleY;
			for (var m = 0; m < hk.length; m++) {
				var h = hk[m];
				o.setStyle(h, l[h] == null ? c.style[h] : l[h]);
			}
			if (l.draggable) {
				if (o.draggable = !0, o.cursor = "move", s) {
					var g = a.seriesModel;
					a.dataIndex != null && (g = a.seriesModel.getData(a.dataType).getItemModel(a.dataIndex)), o.on("drag", r(s, g.getModel("labelLine")));
				}
			} else o.off("drag"), o.cursor = c.cursor;
		}
	}, e.prototype.layout = function(e) {
		var t = e.getWidth(), n = e.getHeight(), r = [];
		I(this._labelList, function(e) {
			e.defaultAttr.ignore || r.push(sk({}, e));
		});
		var i = oe(r, function(e) {
			return e.layoutOption.moveOverlap === "shiftX";
		}), a = oe(r, function(e) {
			return e.layoutOption.moveOverlap === "shiftY";
		});
		lk(i, 0, 0, t), lk(a, 1, 0, n);
		var o = oe(r, function(e) {
			return e.layoutOption.hideOverlap;
		});
		uk(o), dk(o);
	}, e.prototype.processLabelsOverall = function() {
		var e = this;
		I(this._chartViewList, function(t) {
			var n = t.__model, r = t.ignoreLabelLineUpdate, i = n.isAnimationEnabled();
			t.group.traverse(function(t) {
				if (t.ignore && !t.forceLabelAnimation) return !0;
				var a = !r, o = t.getTextContent();
				!a && o && (a = _k(o).needsUpdateLabelLine), a && e._updateLabelLine(t, n), i && e._animateLabels(t, n);
			});
		});
	}, e.prototype._updateLabelLine = function(e, t) {
		var n = e.getTextContent(), r = Z(e), i = r.dataIndex;
		if (n && i != null) {
			var a = t.getData(r.dataType), o = a.getItemModel(i), s = {}, c = a.getItemVisual(i, "style");
			c && (s.stroke = c[a.getVisual("drawType")]);
			var l = o.getModel("labelLine");
			JO(e, YO(o), s), VO(e, l);
		}
	}, e.prototype._animateLabels = function(e, t) {
		var n = e.getTextContent(), r = e.getTextGuideLine();
		if (n && (e.forceLabelAnimation || !n.ignore && !n.invisible && !e.disableLabelAnimation && !jp(e))) {
			var i = _k(n), a = i.oldLayout, o = Z(e), s = o.dataIndex, c = {
				x: n.x,
				y: n.y,
				rotation: n.rotation
			}, l = t.getData(o.dataType);
			if (a) {
				n.attr(a);
				var u = e.prevStates;
				u && (P(u, "select") >= 0 && n.attr(i.oldLayoutSelect), P(u, "emphasis") >= 0 && n.attr(i.oldLayoutEmphasis)), kp(n, c, t, s);
			} else if (n.attr(c), !Wm(n).valueAnimation) {
				var d = G(n.style.opacity, 1);
				n.style.opacity = 0, Ap(n, { style: { opacity: d } }, t, s);
			}
			if (i.oldLayout = c, n.states.select) {
				var f = i.oldLayoutSelect = {};
				yk(f, c, bk), yk(f, n.states.select, bk);
			}
			if (n.states.emphasis) {
				var p = i.oldLayoutEmphasis = {};
				yk(p, c, bk), yk(p, n.states.emphasis, bk);
			}
			Km(n, s, l, t, t);
		}
		if (r && !r.ignore && !r.invisible) {
			var i = vk(r), a = i.oldLayout, m = { points: r.shape.points };
			a ? (r.attr({ shape: a }), kp(r, { shape: m }, t)) : (r.setShape(m), r.style.strokePercent = 0, Ap(r, { style: { strokePercent: 1 } }, t)), i.oldLayout = m;
		}
	}, e;
}(), Sk = X();
function Ck(e) {
	e.registerUpdateLifecycle("series:beforeupdate", function(e, t, n) {
		var r = Sk(t).labelManager;
		r ||= Sk(t).labelManager = new xk(), r.clearLabels();
	}), e.registerUpdateLifecycle("series:layoutlabels", function(e, t, n) {
		var r = Sk(t).labelManager;
		I(n.updatedSeries, function(e) {
			r.addLabelsOfSeries(t.getViewOfSeriesModel(e));
		}), r.updateLayoutConfig(t), r.layout(t), r.processLabelsOverall();
	});
}
//#endregion
//#region node_modules/echarts/core.js
var wk = /* @__PURE__ */ e({
	Axis: () => yO,
	ChartView: () => sb,
	ComponentModel: () => Jg,
	ComponentView: () => rb,
	List: () => Ww,
	Model: () => ih,
	PRIORITY: () => WS,
	SeriesModel: () => Jy,
	color: () => Dr,
	connect: () => VC,
	dataTool: () => pw,
	dependencies: () => ES,
	disConnect: () => UC,
	disconnect: () => HC,
	dispose: () => WC,
	env: () => i,
	extendChartView: () => TO,
	extendComponentModel: () => SO,
	extendComponentView: () => CO,
	extendSeriesModel: () => wO,
	format: () => WD,
	getCoordinateSystemDimensions: () => tw,
	getInstanceByDom: () => GC,
	getInstanceById: () => KC,
	getMap: () => uw,
	graphic: () => UD,
	helper: () => _D,
	init: () => BC,
	innerDrawElementOnCanvas: () => uS,
	matrix: () => Ht,
	number: () => VD,
	parseGeoJSON: () => BD,
	parseGeoJson: () => BD,
	registerAction: () => $C,
	registerCoordinateSystem: () => ew,
	registerCustomSeries: () => nw,
	registerLayout: () => rw,
	registerLoading: () => sw,
	registerLocale: () => vh,
	registerMap: () => lw,
	registerPostInit: () => XC,
	registerPostUpdate: () => ZC,
	registerPreprocessor: () => JC,
	registerProcessor: () => YC,
	registerTheme: () => qC,
	registerTransform: () => dw,
	registerUpdateLifecycle: () => QC,
	registerVisual: () => iw,
	setCanvasCreator: () => cw,
	setPlatformAPI: () => p,
	throttle: () => gb,
	time: () => HD,
	use: () => TD,
	util: () => GD,
	vector: () => Le,
	version: () => TS,
	zrUtil: () => m,
	zrender: () => Ga
}), Tk = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.hasSymbolVisual = !0, n;
	}
	return t.prototype.getInitialData = function(e) {
		return aT(null, this, { useEncodeDefaulter: !0 });
	}, t.prototype.getLegendIcon = function(e) {
		var t = new Wa(), n = Ox("line", 0, e.itemHeight / 2, e.itemWidth, 0, e.lineStyle.stroke, !1);
		t.add(n), n.setStyle(e.lineStyle);
		var r = this.getData().getVisual("symbol"), i = this.getData().getVisual("symbolRotate"), a = r === "none" ? "circle" : r, o = e.itemHeight * .8, s = Ox(a, (e.itemWidth - o) / 2, (e.itemHeight - o) / 2, o, o, e.itemStyle.fill);
		return t.add(s), s.setStyle(e.itemStyle), s.rotation = (e.iconRotate === "inherit" ? i : e.iconRotate || 0) * Math.PI / 180, s.setOrigin([e.itemWidth / 2, e.itemHeight / 2]), a.indexOf("empty") > -1 && (s.style.stroke = s.style.fill, s.style.fill = Q.color.neutral00, s.style.lineWidth = 2), t;
	}, t.type = "series.line", t.dependencies = ["grid", "polar"], t.defaultOption = {
		z: 3,
		coordinateSystem: "cartesian2d",
		legendHoverLink: !0,
		clip: !0,
		label: { position: "top" },
		endLabel: {
			show: !1,
			valueAnimation: !0,
			distance: 8
		},
		lineStyle: {
			width: 2,
			type: "solid"
		},
		emphasis: { scale: !0 },
		step: !1,
		smooth: !1,
		smoothMonotone: null,
		symbol: "emptyCircle",
		symbolSize: 6,
		symbolRotate: null,
		showSymbol: !0,
		showAllSymbol: "auto",
		connectNulls: !1,
		sampling: "none",
		animationEasing: "linear",
		progressive: 0,
		hoverLayerThreshold: Infinity,
		universalTransition: { divideShape: "clone" },
		triggerLineEvent: !1,
		triggerEvent: !1
	}, t;
}(Jy);
//#endregion
//#region node_modules/echarts/lib/chart/helper/labelHelper.js
function Ek(e, t) {
	var n = e.mapDimensionsAll("defaultedLabel"), r = n.length;
	if (r === 1) {
		var i = Vv(e, t, n[0]);
		return i == null ? null : i + "";
	}
	if (r) {
		for (var a = [], o = 0; o < n.length; o++) a.push(Vv(e, t, n[o]));
		return a.join(" ");
	}
}
function Dk(e, t) {
	var n = e.mapDimensionsAll("defaultedLabel");
	if (!V(t)) return t + "";
	for (var r = [], i = 0; i < n.length; i++) {
		var a = e.getDimensionIndex(n[i]);
		a >= 0 && r.push(t[a]);
	}
	return r.join(" ");
}
//#endregion
//#region node_modules/echarts/lib/chart/helper/Symbol.js
var Ok = function(e) {
	n(t, e);
	function t(t, n, r, i) {
		var a = e.call(this) || this;
		return a.updateData(t, n, r, i), a;
	}
	return t.prototype._createSymbol = function(e, t, n, r, i, a) {
		this.removeAll();
		var o = Ox(e, -1, -1, 2, 2, null, a);
		o.attr({
			z2: G(i, 100),
			culling: !0,
			scaleX: r[0] / 2,
			scaleY: r[1] / 2
		}), o.drift = kk, this._symbolType = e, this.add(o);
	}, t.prototype.stopSymbolAnimation = function(e) {
		this.childAt(0).stopAnimation(null, e);
	}, t.prototype.getSymbolType = function() {
		return this._symbolType;
	}, t.prototype.getSymbolPath = function() {
		return this.childAt(0);
	}, t.prototype.highlight = function() {
		Od(this.childAt(0));
	}, t.prototype.downplay = function() {
		kd(this.childAt(0));
	}, t.prototype.setZ = function(e, t) {
		var n = this.childAt(0);
		n.zlevel = e, n.z = t;
	}, t.prototype.setDraggable = function(e, t) {
		var n = this.childAt(0);
		n.draggable = e, n.cursor = !t && e ? "move" : n.cursor;
	}, t.prototype.updateData = function(e, n, r, i) {
		this.silent = !1;
		var a = e.getItemVisual(n, "symbol") || "circle", o = e.hostModel, s = t.getSymbolSize(e, n), c = t.getSymbolZ2(e, n), l = a !== this._symbolType, u = i && i.disableAnimation;
		if (l) {
			var d = e.getItemVisual(n, "symbolKeepAspect");
			this._createSymbol(a, e, n, s, c, d);
		} else {
			var f = this.childAt(0);
			f.silent = !1;
			var p = {
				scaleX: s[0] / 2,
				scaleY: s[1] / 2
			};
			u ? f.attr(p) : kp(f, p, o, n), Fp(f);
		}
		if (this._updateCommon(e, n, s, r, i), l) {
			var f = this.childAt(0);
			if (!u) {
				var p = {
					scaleX: this._sizeX,
					scaleY: this._sizeY,
					style: { opacity: f.style.opacity }
				};
				f.scaleX = f.scaleY = 0, f.style.opacity = 0, Ap(f, p, o, n);
			}
		}
		u && this.childAt(0).stopAnimation("leave");
	}, t.prototype._updateCommon = function(e, t, n, r, i) {
		var a = this.childAt(0), o = e.hostModel, s, c, l, u, d, f, p, m, h;
		if (r && (s = r.emphasisItemStyle, c = r.blurItemStyle, l = r.selectItemStyle, u = r.focus, d = r.blurScope, p = r.labelStatesModels, m = r.hoverScale, h = r.cursorStyle, f = r.emphasisDisabled), !r || e.hasItemOption) {
			var g = r && r.itemModel ? r.itemModel : e.getItemModel(t), _ = g.getModel("emphasis");
			s = _.getModel("itemStyle").getItemStyle(), l = g.getModel(["select", "itemStyle"]).getItemStyle(), c = g.getModel(["blur", "itemStyle"]).getItemStyle(), u = _.get("focus"), d = _.get("blurScope"), f = _.get("disabled"), p = Pm(g), m = _.getShallow("scale"), h = g.getShallow("cursor");
		}
		var v = e.getItemVisual(t, "symbolRotate");
		a.attr("rotation", (v || 0) * Math.PI / 180 || 0);
		var y = Ax(e.getItemVisual(t, "symbolOffset"), n);
		y && (a.x = y[0], a.y = y[1]), h && a.attr("cursor", h);
		var b = e.getItemVisual(t, "style"), x = b.fill;
		if (a instanceof fu) {
			var S = a.style;
			a.useStyle(M({
				image: S.image,
				x: S.x,
				y: S.y,
				width: S.width,
				height: S.height
			}, b));
		} else a.__isEmptyBrush ? a.useStyle(M({}, b)) : a.useStyle(b), a.style.decal = null, a.setColor(x, i && i.symbolInnerColor), a.style.strokeNoScale = !0;
		var C = e.getItemVisual(t, "liftZ"), w = this._z2;
		C == null ? w != null && (a.z2 = w, this._z2 = null) : w ?? (this._z2 = a.z2, a.z2 += C);
		var T = i && i.useNameLabel;
		Nm(a, p, {
			labelFetcher: o,
			labelDataIndex: t,
			defaultText: E,
			inheritColor: x,
			defaultOpacity: b.opacity
		});
		function E(t) {
			return T ? e.getName(t) : Ek(e, t);
		}
		this._sizeX = n[0] / 2, this._sizeY = n[1] / 2;
		var D = a.ensureState("emphasis");
		D.style = s, a.ensureState("select").style = l, a.ensureState("blur").style = c;
		var O = m == null || m === !0 ? Math.max(1.1, 3 / this._sizeY) : isFinite(m) && m > 0 ? +m : 1;
		D.scaleX = this._sizeX * O, D.scaleY = this._sizeY * O, this.setSymbolScale(1), qd(this, u, d, f);
	}, t.prototype.setSymbolScale = function(e) {
		this.scaleX = this.scaleY = e;
	}, t.prototype.fadeOut = function(e, t, n) {
		var r = this.childAt(0), i = Z(this).dataIndex, a = n && n.animation;
		if (this.silent = r.silent = !0, n && n.fadeLabel) {
			var o = r.getTextContent();
			o && Mp(o, { style: { opacity: 0 } }, t, {
				dataIndex: i,
				removeOpt: a,
				cb: function() {
					r.removeTextContent();
				}
			});
		} else r.removeTextContent();
		Mp(r, {
			style: { opacity: 0 },
			scaleX: 0,
			scaleY: 0
		}, t, {
			dataIndex: i,
			cb: e,
			removeOpt: a
		});
	}, t.getSymbolSize = function(e, t) {
		return kx(e.getItemVisual(t, "symbolSize"));
	}, t.getSymbolZ2 = function(e, t) {
		return e.getItemVisual(t, "z2");
	}, t;
}(Wa);
function kk(e, t) {
	this.parent.drift(e, t);
}
//#endregion
//#region node_modules/echarts/lib/chart/helper/SymbolDraw.js
function Ak(e, t, n, r) {
	return t && !isNaN(t[0]) && !isNaN(t[1]) && !(r && r.isIgnore && r.isIgnore(n)) && !(r && r.clipShape && !r.clipShape.contain(t[0], t[1])) && e.getItemVisual(n, "symbol") !== "none";
}
function jk(e) {
	return e != null && !W(e) && (e = { isIgnore: e }), e || {};
}
function Mk(e) {
	var t = e.hostModel, n = t.getModel("emphasis");
	return {
		emphasisItemStyle: n.getModel("itemStyle").getItemStyle(),
		blurItemStyle: t.getModel(["blur", "itemStyle"]).getItemStyle(),
		selectItemStyle: t.getModel(["select", "itemStyle"]).getItemStyle(),
		focus: n.get("focus"),
		blurScope: n.get("blurScope"),
		emphasisDisabled: n.get("disabled"),
		hoverScale: n.get("scale"),
		labelStatesModels: Pm(t),
		cursorStyle: t.get("cursor")
	};
}
function Nk(e, t, n, r, i, a, o) {
	var s = new e(t, n, r, i);
	return s.setPosition(a), t.setItemGraphicEl(n, s), o.add(s), s;
}
var Pk = function() {
	function e(e) {
		this.group = new Wa(), this._SymbolCtor = e || Ok;
	}
	return e.prototype.updateData = function(e, t) {
		this._progressiveEls = null, t = jk(t);
		var n = this.group, r = e.hostModel, i = this._data, a = this._SymbolCtor, o = t.disableAnimation, s = this._seriesScope = Mk(e), c = { disableAnimation: o }, l = t.getSymbolPoint || function(t) {
			return e.getItemLayout(t);
		};
		i || n.removeAll(), e.diff(i).add(function(r) {
			var i = l(r);
			Ak(e, i, r, t) && Nk(a, e, r, s, c, i, n);
		}).update(function(u, d) {
			var f = i.getItemGraphicEl(d), p = l(u);
			if (!Ak(e, p, u, t)) n.remove(f);
			else {
				var m = e.getItemVisual(u, "symbol") || "circle", h = f && f.getSymbolType && f.getSymbolType();
				if (!f || h && h !== m) n.remove(f), f = new a(e, u, s, c), f.setPosition(p);
				else {
					f.updateData(e, u, s, c);
					var g = {
						x: p[0],
						y: p[1]
					};
					o ? f.attr(g) : kp(f, g, r);
				}
				n.add(f), e.setItemGraphicEl(u, f);
			}
		}).remove(function(e) {
			var t = i.getItemGraphicEl(e);
			t && t.fadeOut(function() {
				n.remove(t);
			}, r);
		}).execute(), this._getSymbolPoint = l, this._data = e;
	}, e.prototype.updateLayout = function(e) {
		var t = this._data;
		if (t) for (var n = this, r = t.getStore(), i = 0, a = r.count(); i < a; i++) {
			var o = t.getItemGraphicEl(i), s = n._getSymbolPoint(i);
			Ak(t, s, i, e) ? (o ||= Nk(n._SymbolCtor, t, i, n._seriesScope, { disableAnimation: !0 }, s, n.group), o.stopAnimation(), o.setPosition(s), o.markRedraw()) : o && (n.group.remove(o), t.setItemGraphicEl(i, null));
		}
	}, e.prototype.incrementalPrepareUpdate = function(e) {
		this._seriesScope = Mk(e), this._data = null, this.group.removeAll();
	}, e.prototype.incrementalUpdate = function(e, t, n, r) {
		this._progressiveEls = [], r = jk(r);
		function i(e) {
			e.isGroup || (e.incremental = n, e.ensureState("emphasis").hoverLayer = 2);
		}
		for (var a = e.start; a < e.end; a++) {
			var o = t.getItemLayout(a);
			if (Ak(t, o, a, r)) {
				var s = new this._SymbolCtor(t, a, this._seriesScope);
				s.traverse(i), s.setPosition(o), this.group.add(s), t.setItemGraphicEl(a, s), this._progressiveEls.push(s);
			}
		}
	}, e.prototype.eachRendered = function(e) {
		_m(this._progressiveEls || this.group, e);
	}, e.prototype.remove = function(e) {
		var t = this.group, n = this._data;
		n && e ? n.eachItemGraphicEl(function(e) {
			e.fadeOut(function() {
				t.remove(e);
			}, n.hostModel);
		}) : t.removeAll();
	}, e;
}();
//#endregion
//#region node_modules/echarts/lib/chart/line/helper.js
function Fk(e, t, n) {
	var r = e.getBaseAxis(), i = e.getOtherAxis(r), a = Ik(i, n), o = r.dim, s = i.dim, c = t.mapDimension(s), l = t.mapDimension(o), u = +(s === "x" || s === "radius"), d = L(e.dimensions, function(e) {
		return t.mapDimension(e);
	}), f = !1, p = t.getCalculationInfo("stackResultDimension");
	return tT(t, d[0]) && (f = !0, d[0] = p), tT(t, d[1]) && (f = !0, d[1] = p), {
		dataDimsForPoint: d,
		valueStart: a,
		valueAxisDim: s,
		baseAxisDim: o,
		stacked: !!f,
		valueDim: c,
		baseDim: l,
		baseDataOffset: u,
		stackedOverDimension: t.getCalculationInfo("stackedOverDimension")
	};
}
function Ik(e, t) {
	var n = 0, r = e.scale.getExtent();
	return t === "start" ? n = r[0] : t === "end" ? n = r[1] : ue(t) && !isNaN(t) ? n = t : r[0] > 0 ? n = r[0] : r[1] < 0 && (n = r[1]), n;
}
function Lk(e, t, n, r) {
	var i = NaN;
	e.stacked && (i = n.get(n.getCalculationInfo("stackedOverDimension"), r)), isNaN(i) && (i = e.valueStart);
	var a = e.baseDataOffset, o = [];
	return o[a] = n.get(e.baseDim, r), o[1 - a] = i, t.dataToPoint(o);
}
function Rk(e, t) {
	return !isFinite(e) || !isFinite(t);
}
//#endregion
//#region node_modules/echarts/lib/util/vendor.js
var zk = typeof Float32Array < "u" ? Float32Array : void 0, Bk = typeof Float64Array < "u" ? Float64Array : void 0;
function Vk(e) {
	return Hk({ ctor: zk }, e).arr;
}
function Hk(e, t) {
	var n = e.arr, r = e.ctor;
	if (t > Io && (t = Io), !n || e.typed && n.length < t) {
		var i = void 0;
		if (r) try {
			i = new r(t), e.typed = !0, n && i.set(n);
		} catch {}
		if (!i && (i = [], e.typed = !1, n)) for (var a = 0, o = n.length; a < o; a++) i[a] = n[a];
		e.arr = i;
	}
	return e;
}
//#endregion
//#region node_modules/echarts/lib/chart/line/lineAnimationDiff.js
function Uk(e, t) {
	var n = [];
	return t.diff(e).add(function(e) {
		n.push({
			cmd: "+",
			idx: e
		});
	}).update(function(e, t) {
		n.push({
			cmd: "=",
			idx: t,
			idx1: e
		});
	}).remove(function(e) {
		n.push({
			cmd: "-",
			idx: e
		});
	}).execute(), n;
}
function Wk(e, t, n, r, i, a, o, s) {
	for (var c = Uk(e, t), l = [], u = [], d = [], f = [], p = [], m = [], h = [], g = Fk(i, t, o), _ = e.getLayout("points") || [], v = t.getLayout("points") || [], y = 0; y < c.length; y++) {
		var b = c[y], x = !0, S = void 0, C = void 0;
		switch (b.cmd) {
			case "=":
				S = b.idx * 2, C = b.idx1 * 2;
				var w = _[S], T = _[S + 1], E = v[C], D = v[C + 1];
				(isNaN(w) || isNaN(T)) && (w = E, T = D), l.push(w, T), u.push(E, D), d.push(n[S], n[S + 1]), f.push(r[C], r[C + 1]), h.push(t.getRawIndex(b.idx1));
				break;
			case "+":
				var O = b.idx, k = g.dataDimsForPoint, A = i.dataToPoint([t.get(k[0], O), t.get(k[1], O)]);
				C = O * 2, l.push(A[0], A[1]), u.push(v[C], v[C + 1]);
				var j = Lk(g, i, t, O);
				d.push(j[0], j[1]), f.push(r[C], r[C + 1]), h.push(t.getRawIndex(O));
				break;
			case "-": x = !1;
		}
		x && (p.push(b), m.push(m.length));
	}
	m.sort(function(e, t) {
		return h[e] - h[t];
	});
	for (var ee = l.length, M = Vk(ee), te = Vk(ee), N = Vk(ee), ne = Vk(ee), P = [], y = 0; y < m.length; y++) {
		var re = m[y], F = y * 2, ie = re * 2;
		M[F] = l[ie], M[F + 1] = l[ie + 1], te[F] = u[ie], te[F + 1] = u[ie + 1], N[F] = d[ie], N[F + 1] = d[ie + 1], ne[F] = f[ie], ne[F + 1] = f[ie + 1], P[y] = p[re];
	}
	return {
		current: M,
		next: te,
		stackedOnCurrent: N,
		stackedOnNext: ne,
		status: P
	};
}
//#endregion
//#region node_modules/echarts/lib/chart/line/poly.js
var Gk = Math.min, Kk = Math.max;
function qk(e, t, n, r, i, a, o, s, c) {
	for (var l, u, d, f, p, m, h = n, g = 0; g < r; g++) {
		var _ = t[h * 2], v = t[h * 2 + 1];
		if (h >= i || h < 0) break;
		if (Rk(_, v)) {
			if (c) {
				h += a;
				continue;
			}
			break;
		}
		if (h === n) e[a > 0 ? "moveTo" : "lineTo"](_, v), d = _, f = v;
		else {
			var y = _ - l, b = v - u;
			if (y * y + b * b < .5) {
				h += a;
				continue;
			}
			if (o > 0) {
				for (var x = h + a, S = t[x * 2], C = t[x * 2 + 1]; S === _ && C === v && g < r;) g++, x += a, h += a, S = t[x * 2], C = t[x * 2 + 1], _ = t[h * 2], v = t[h * 2 + 1], y = _ - l, b = v - u;
				var w = g + 1;
				if (c) for (; Rk(S, C) && w < r;) w++, x += a, S = t[x * 2], C = t[x * 2 + 1];
				var T = .5, E = 0, D = 0, O = void 0, k = void 0;
				if (w >= r || Rk(S, C)) p = _, m = v;
				else {
					E = S - l, D = C - u;
					var A = _ - l, j = S - _, ee = v - u, M = C - v, te = void 0, N = void 0;
					if (s === "x") {
						te = Math.abs(A), N = Math.abs(j);
						var ne = E > 0 ? 1 : -1;
						p = _ - ne * te * o, m = v, O = _ + ne * N * o, k = v;
					} else if (s === "y") {
						te = Math.abs(ee), N = Math.abs(M);
						var P = D > 0 ? 1 : -1;
						p = _, m = v - P * te * o, O = _, k = v + P * N * o;
					} else te = Math.sqrt(A * A + ee * ee), N = Math.sqrt(j * j + M * M), T = N / (N + te), p = _ - E * o * (1 - T), m = v - D * o * (1 - T), O = _ + E * o * T, k = v + D * o * T, O = Gk(O, Kk(S, _)), k = Gk(k, Kk(C, v)), O = Kk(O, Gk(S, _)), k = Kk(k, Gk(C, v)), E = O - _, D = k - v, p = _ - E * te / N, m = v - D * te / N, p = Gk(p, Kk(l, _)), m = Gk(m, Kk(u, v)), p = Kk(p, Gk(l, _)), m = Kk(m, Gk(u, v)), E = _ - p, D = v - m, O = _ + E * N / te, k = v + D * N / te;
				}
				e.bezierCurveTo(d, f, p, m, _, v), d = O, f = k;
			} else e.lineTo(_, v);
		}
		l = _, u = v, h += a;
	}
	return g;
}
var Jk = function() {
	function e() {
		this.smooth = 0, this.smoothConstraint = !0;
	}
	return e;
}(), Yk = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this, t) || this;
		return n.type = "ec-polyline", n;
	}
	return t.prototype.getDefaultStyle = function() {
		return {
			stroke: Q.color.neutral99,
			fill: null
		};
	}, t.prototype.getDefaultShape = function() {
		return new Jk();
	}, t.prototype.buildPath = function(e, t) {
		var n = t.points, r = 0, i = n.length / 2;
		if (t.connectNulls) {
			for (; i > 0 && Rk(n[i * 2 - 2], n[i * 2 - 1]); i--);
			for (; r < i && Rk(n[r * 2], n[r * 2 + 1]); r++);
		}
		for (; r < i;) r += qk(e, n, r, i, i, 1, t.smooth, t.smoothMonotone, t.connectNulls) + 1;
	}, t.prototype.getPointOn = function(e, t) {
		this.path || (this.createPathProxy(), this.buildPath(this.path, this.shape));
		for (var n = this.path.data, r = Fl.CMD, i, a, o = t === "x", s = [], c = 0; c < n.length;) {
			var l = n[c++], u = void 0, d = void 0, f = void 0, p = void 0, m = void 0, h = void 0, g = void 0;
			switch (l) {
				case r.M:
					i = n[c++], a = n[c++];
					break;
				case r.L:
					if (u = n[c++], d = n[c++], g = o ? (e - i) / (u - i) : (e - a) / (d - a), g <= 1 && g >= 0) {
						var _ = o ? (d - a) * g + a : (u - i) * g + i;
						return o ? [e, _] : [_, e];
					}
					i = u, a = d;
					break;
				case r.C:
					u = n[c++], d = n[c++], f = n[c++], p = n[c++], m = n[c++], h = n[c++];
					var v = o ? lr(i, u, f, m, e, s) : lr(a, d, p, h, e, s);
					if (v > 0) for (var y = 0; y < v; y++) {
						var b = s[y];
						if (b <= 1 && b >= 0) {
							var _ = o ? sr(a, d, p, h, b) : sr(i, u, f, m, b);
							return o ? [e, _] : [_, e];
						}
					}
					i = m, a = h;
			}
		}
	}, t;
}(ou), Xk = function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t;
}(Jk), Zk = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this, t) || this;
		return n.type = "ec-polygon", n;
	}
	return t.prototype.getDefaultShape = function() {
		return new Xk();
	}, t.prototype.buildPath = function(e, t) {
		var n = t.points, r = t.stackedOnPoints, i = 0, a = n.length / 2, o = t.smoothMonotone;
		if (t.connectNulls) {
			for (; a > 0 && Rk(n[a * 2 - 2], n[a * 2 - 1]); a--);
			for (; i < a && Rk(n[i * 2], n[i * 2 + 1]); i++);
		}
		for (; i < a;) {
			var s = qk(e, n, i, a, a, 1, t.smooth, o, t.connectNulls);
			qk(e, r, i + s - 1, s, a, -1, t.stackedOnSmooth, o, t.connectNulls), i += s + 1, e.closePath();
		}
	}, t;
}(ou);
//#endregion
//#region node_modules/echarts/lib/chart/helper/createClipPathFromCoordSys.js
function Qk(e, t, n, r, i) {
	var a = e.getArea(), o = a.x, s = a.y, c = a.width, l = a.height, u = n.get(["lineStyle", "width"]) || 0;
	o -= u / 2, s -= u / 2, c += u, l += u, c = Math.ceil(c), o !== Math.floor(o) && (o = Math.floor(o), c++);
	var d = new bu({ shape: {
		x: o,
		y: s,
		width: c,
		height: l
	} });
	if (t) {
		var f = e.getBaseAxis(), p = f.isHorizontal(), m = f.inverse;
		p ? (m && (d.shape.x += c), d.shape.width = 0) : (m || (d.shape.y += l), d.shape.height = 0);
		var h = H(i) ? function(e) {
			i(e, d);
		} : null;
		Ap(d, { shape: {
			width: c,
			height: l,
			x: o,
			y: s
		} }, n, null, r, h);
	}
	return d;
}
function $k(e, t, n) {
	var r = e.getArea(), i = Eo(r.r0, 1), a = Eo(r.r, 1), o = new qf({ shape: {
		cx: Eo(e.cx, 1),
		cy: Eo(e.cy, 1),
		r0: i,
		r: a,
		startAngle: r.startAngle,
		endAngle: r.endAngle,
		clockwise: r.clockwise
	} });
	return t && (e.getBaseAxis().dim === "angle" ? o.shape.endAngle = r.startAngle : o.shape.r = i, Ap(o, { shape: {
		endAngle: r.endAngle,
		r: a
	} }, n)), o;
}
function eA(e, t, n, r, i) {
	return e ? e.type === "polar" ? $k(e, t, n) : e.type === "cartesian2d" ? Qk(e, t, n, r, i) : null : null;
}
function tA(e, t, n) {
	e ? t.setClipPath(n) : t.removeClipPath();
}
function nA(e) {
	var t = e.coordinateSystem;
	if (e.get("clip", !0) && t && (!t.shouldClip || t.shouldClip())) return t.getArea && t.getArea(.1);
}
//#endregion
//#region node_modules/echarts/lib/coord/CoordinateSystem.js
function rA(e, t) {
	return e.type === t;
}
function iA(e) {
	var t = e.dimensions;
	return t[0] === "lng" && t[1] === "lat" && !!e.getViewRect;
}
//#endregion
//#region node_modules/echarts/lib/util/styleCompat.js
function aA(e, t, n, r) {
	return e && (e.legacy || e.legacy !== !1 && !n && !r && t !== "tspan" && (t === "text" || q(e, "text")));
}
function oA(e, t, n) {
	var r = e, i, a, o;
	if (t === "text") o = r;
	else {
		o = {}, q(r, "text") && (o.text = r.text), q(r, "rich") && (o.rich = r.rich), q(r, "textFill") && (o.fill = r.textFill), q(r, "textStroke") && (o.stroke = r.textStroke), q(r, "fontFamily") && (o.fontFamily = r.fontFamily), q(r, "fontSize") && (o.fontSize = r.fontSize), q(r, "fontStyle") && (o.fontStyle = r.fontStyle), q(r, "fontWeight") && (o.fontWeight = r.fontWeight), a = {
			type: "text",
			style: o,
			silent: !0
		}, i = {};
		var s = q(r, "textPosition");
		n ? i.position = s ? r.textPosition : "inside" : s && (i.position = r.textPosition), q(r, "textPosition") && (i.position = r.textPosition), q(r, "textOffset") && (i.offset = r.textOffset), q(r, "textRotation") && (i.rotation = r.textRotation), q(r, "textDistance") && (i.distance = r.textDistance);
	}
	return sA(o, e), I(o.rich, function(e) {
		sA(e, e);
	}), {
		textConfig: i,
		textContent: a
	};
}
function sA(e, t) {
	t && (t.font = t.textFont || t.font, q(t, "textStrokeWidth") && (e.lineWidth = t.textStrokeWidth), q(t, "textAlign") && (e.align = t.textAlign), q(t, "textVerticalAlign") && (e.verticalAlign = t.textVerticalAlign), q(t, "textLineHeight") && (e.lineHeight = t.textLineHeight), q(t, "textWidth") && (e.width = t.textWidth), q(t, "textHeight") && (e.height = t.textHeight), q(t, "textBackgroundColor") && (e.backgroundColor = t.textBackgroundColor), q(t, "textPadding") && (e.padding = t.textPadding), q(t, "textBorderColor") && (e.borderColor = t.textBorderColor), q(t, "textBorderWidth") && (e.borderWidth = t.textBorderWidth), q(t, "textBorderRadius") && (e.borderRadius = t.textBorderRadius), q(t, "textBoxShadowColor") && (e.shadowColor = t.textBoxShadowColor), q(t, "textBoxShadowBlur") && (e.shadowBlur = t.textBoxShadowBlur), q(t, "textBoxShadowOffsetX") && (e.shadowOffsetX = t.textBoxShadowOffsetX), q(t, "textBoxShadowOffsetY") && (e.shadowOffsetY = t.textBoxShadowOffsetY));
}
//#endregion
//#region node_modules/echarts/lib/chart/line/LineView.js
function cA(e, t) {
	if (e.length === t.length) {
		for (var n = 0; n < e.length; n++) if (e[n] !== t[n]) return;
		return !0;
	}
}
function lA(e) {
	for (var t = zs(), n = zs(), r = 0; r < e.length;) {
		var i = e[r++], a = e[r++];
		Rk(i, a) || (Bs(t, i), Bs(n, a));
	}
	return [t, n];
}
function uA(e, t) {
	var n = lA(e), r = n[0], i = n[1], a = lA(t), o = a[0], s = a[1];
	return Math.max(Math.abs(r[0] - o[0]), Math.abs(i[0] - s[0]), Math.abs(r[1] - o[1]), Math.abs(i[1] - s[1]));
}
function dA(e) {
	return ue(e) ? e : e ? .5 : 0;
}
function fA(e, t, n) {
	if (n.valueDim == null) return [];
	for (var r = t.count(), i = Vk(r * 2), a = 0; a < r; a++) {
		var o = Lk(n, e, t, a);
		i[a * 2] = o[0], i[a * 2 + 1] = o[1];
	}
	return i;
}
function pA(e, t, n, r, i) {
	var a = n.getBaseAxis(), o = a.dim === "x" || a.dim === "radius" ? 0 : 1, s = [], c = 0, l = [], u = [], d = [], f = [];
	if (i) {
		for (c = 0; c < e.length; c += 2) {
			var p = t || e;
			Rk(p[c], p[c + 1]) || f.push(e[c], e[c + 1]);
		}
		e = f;
	}
	for (c = 0; c < e.length - 2; c += 2) switch (d[0] = e[c + 2], d[1] = e[c + 3], u[0] = e[c], u[1] = e[c + 1], s.push(u[0], u[1]), r) {
		case "end":
			l[o] = d[o], l[1 - o] = u[1 - o], s.push(l[0], l[1]);
			break;
		case "middle":
			var m = (u[o] + d[o]) / 2, h = [];
			l[o] = h[o] = m, l[1 - o] = u[1 - o], h[1 - o] = d[1 - o], s.push(l[0], l[1]), s.push(h[0], h[1]);
			break;
		default: l[o] = u[o], l[1 - o] = d[1 - o], s.push(l[0], l[1]);
	}
	return s.push(e[c++], e[c++]), s;
}
function mA(e, t) {
	var n = [], r = e.length, i, a;
	function o(e, t, n) {
		var r = e.coord;
		return {
			coord: n,
			color: Jr((n - r) / (t.coord - r), [e.color, t.color])
		};
	}
	for (var s = 0; s < r; s++) {
		var c = e[s], l = c.coord;
		if (l < 0) i = c;
		else if (l > t) {
			a ? n.push(o(a, c, t)) : i && n.push(o(i, c, 0), o(i, c, t));
			break;
		} else i &&= (n.push(o(i, c, 0)), null), n.push(c), a = c;
	}
	return n;
}
function hA(e, t, n) {
	var r = e.getVisual("visualMeta");
	if (r && r.length && e.count() && t.type === "cartesian2d") {
		for (var i, a, o = r.length - 1; o >= 0; o--) {
			var s = e.getDimensionInfo(r[o].dimension);
			if (i = s && s.coordDim, i === "x" || i === "y") {
				a = r[o];
				break;
			}
		}
		if (a) {
			var c = t.getAxis(i), l = L(a.stops, function(e) {
				return {
					coord: c.toGlobalCoord(c.dataToCoord(e.value)),
					color: e.color
				};
			}), u = l.length, d = a.outerColors.slice();
			u && l[0].coord > l[u - 1].coord && (l.reverse(), d.reverse());
			var f = mA(l, i === "x" ? n.getWidth() : n.getHeight()), p = f.length;
			if (!p && u) return l[0].coord < 0 ? d[1] ? d[1] : l[u - 1].color : d[0] ? d[0] : l[0].color;
			var m = 10, h = f[0].coord - m, g = f[p - 1].coord + m, _ = g - h;
			if (_ < .001) return "transparent";
			I(f, function(e) {
				e.offset = (e.coord - h) / _;
			}), f.push({
				offset: p ? f[p - 1].offset : .5,
				color: d[1] || "transparent"
			}), f.unshift({
				offset: p ? f[0].offset : .5,
				color: d[0] || "transparent"
			});
			var v = new pp(0, 0, 0, 0, f, !0);
			return v[i] = h, v[i + "2"] = g, v;
		}
	}
}
function gA(e, t, n) {
	var r = e.get("showAllSymbol"), i = r === "auto";
	if (!r || i) {
		var a = n.getAxesByScale("ordinal")[0];
		if (a && !(i && _A(a, t))) {
			var o = t.mapDimension(a.dim), s = {};
			return I(a.getViewLabels(), function(e) {
				e.tick.offInterval || (s[SE(a.scale, e.tick)] = 1);
			}), function(e) {
				return !s.hasOwnProperty(t.get(o, e));
			};
		}
	}
}
function _A(e, t) {
	var n = e.getExtent(), r = Math.abs(n[1] - n[0]) / e.scale.count();
	isNaN(r) && (r = 0);
	for (var i = t.count(), a = Math.max(1, Math.round(i / 5)), o = 0; o < i; o += a) if (Ok.getSymbolSize(t, o)[+!!e.isHorizontal()] * 1.5 > r) return !1;
	return !0;
}
function vA(e) {
	for (var t = e.length / 2; t > 0 && Rk(e[t * 2 - 2], e[t * 2 - 1]); t--);
	return t - 1;
}
function yA(e, t) {
	return [e[t * 2], e[t * 2 + 1]];
}
function bA(e, t, n) {
	for (var r = e.length / 2, i = n === "x" ? 0 : 1, a, o, s = 0, c = -1, l = 0; l < r; l++) if (o = e[l * 2 + i], !Rk(o, e[l * 2 + 1 - i])) {
		if (l === 0) a = o;
		else {
			if (a <= t && o >= t || a >= t && o <= t) {
				c = l;
				break;
			}
			s = l, a = o;
		}
	}
	return {
		range: [s, c],
		t: (t - a) / (o - a)
	};
}
function xA(e) {
	if (e.get(["endLabel", "show"])) return !0;
	for (var t = 0; t < td.length; t++) if (e.get([
		td[t],
		"endLabel",
		"show"
	])) return !0;
	return !1;
}
function SA(e, t, n, r) {
	if (rA(t, "cartesian2d")) {
		var i = r.getModel("endLabel"), a = i.get("valueAnimation"), o = r.getData(), s = { lastFrameIndex: 0 }, c = xA(r) ? function(n, r) {
			e._endLabelOnDuring(n, r, o, s, a, i, t);
		} : null, l = t.getBaseAxis().isHorizontal(), u = Qk(t, n, r, function() {
			var t = e._endLabel;
			t && n && s.originalX != null && t.attr({
				x: s.originalX,
				y: s.originalY
			});
		}, c);
		if (!r.get("clip", !0)) {
			var d = u.shape, f = Math.max(d.width, d.height);
			l ? (d.y -= f, d.height += f * 2) : (d.x -= f, d.width += f * 2);
		}
		return c && c(1, u), u;
	}
	return $k(t, n, r);
}
function CA(e, t) {
	var n = t.getBaseAxis(), r = n.isHorizontal(), i = n.inverse, a = r ? i ? "right" : "left" : "center", o = r ? "middle" : i ? "top" : "bottom";
	return { normal: {
		align: e.get("align") || a,
		verticalAlign: e.get("verticalAlign") || o
	} };
}
var wA = function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t.prototype.init = function() {
		var e = new Wa(), t = new Pk();
		this.group.add(t.group), this._symbolDraw = t, this._lineGroup = e, this._changePolyState = z(this._changePolyState, this);
	}, t.prototype.render = function(e, t, n) {
		var r = e.coordinateSystem, i = this.group, a = e.getData(), o = e.getModel("lineStyle"), s = e.getModel("areaStyle"), c = a.getLayout("points") || [], l = r.type === "polar", u = this._coordSys, d = this._symbolDraw, f = this._polyline, p = this._polygon, m = this._lineGroup, h = !t.ssr && e.get("animation"), g = !s.isEmpty(), _ = s.get("origin"), v = Fk(r, a, _), y = g && fA(r, a, v), b = e.get("showSymbol"), x = e.get("connectNulls"), S = b && !l && gA(e, a, r), C = this._data;
		C && C.eachItemGraphicEl(function(e, t) {
			e.__temp && (i.remove(e), C.setItemGraphicEl(t, null));
		}), b || d.remove(), i.add(m);
		var w = !l && e.get("step"), T;
		r && r.getArea && e.get("clip", !0) && (T = r.getArea(), T.width == null ? T.r0 && (T.r0 -= .5, T.r += .5) : (T.x -= .1, T.y -= .1, T.width += .2, T.height += .2)), this._clipShapeForSymbol = T;
		var E = hA(a, r, n) || a.getVisual("style")[a.getVisual("drawType")];
		if (!(f && u.type === r.type && w === this._step)) b && d.updateData(a, {
			isIgnore: S,
			clipShape: T,
			disableAnimation: !0,
			getSymbolPoint: function(e) {
				return [c[e * 2], c[e * 2 + 1]];
			}
		}), h && this._initSymbolLabelAnimation(a, r, T), w && (y &&= pA(y, c, r, w, x), c = pA(c, null, r, w, x)), f = this._newPolyline(c), g ? p = this._newPolygon(c, y) : p &&= (m.remove(p), this._polygon = null), l || this._initOrUpdateEndLabel(e, r, bg(E)), m.setClipPath(SA(this, r, !0, e));
		else {
			g && !p ? p = this._newPolygon(c, y) : p && !g && (m.remove(p), p = this._polygon = null), l || this._initOrUpdateEndLabel(e, r, bg(E));
			var D = m.getClipPath();
			D ? Ap(D, { shape: SA(this, r, !1, e).shape }, e) : m.setClipPath(SA(this, r, !0, e)), b && d.updateData(a, {
				isIgnore: S,
				clipShape: T,
				disableAnimation: !0,
				getSymbolPoint: function(e) {
					return [c[e * 2], c[e * 2 + 1]];
				}
			}), (!cA(this._stackedOnPoints, y) || !cA(this._points, c)) && (h ? this._doUpdateAnimation(a, y, r, n, w, _, x) : (w && (y &&= pA(y, c, r, w, x), c = pA(c, null, r, w, x)), f.setShape({ points: c }), p && p.setShape({
				points: c,
				stackedOnPoints: y
			})));
		}
		var O = e.getModel("emphasis"), k = O.get("focus"), A = O.get("blurScope"), j = O.get("disabled");
		if (f.useStyle(N(o.getLineStyle(), {
			fill: "none",
			stroke: E,
			lineJoin: "bevel"
		})), Zd(f, e, "lineStyle"), f.style.lineWidth > 0 && e.get([
			"emphasis",
			"lineStyle",
			"width"
		]) === "bolder") {
			var ee = f.getState("emphasis").style;
			ee.lineWidth = +f.style.lineWidth + 1;
		}
		Z(f).seriesIndex = e.seriesIndex, qd(f, k, A, j);
		var M = dA(e.get("smooth")), te = e.get("smoothMonotone");
		if (f.setShape({
			smooth: M,
			smoothMonotone: te,
			connectNulls: x
		}), p) {
			var ne = a.getCalculationInfo("stackedOnSeries"), P = 0;
			p.useStyle(N(s.getAreaStyle(), {
				fill: E,
				opacity: .7,
				lineJoin: "bevel",
				decal: a.getVisual("style").decal
			})), ne && (P = dA(ne.get("smooth"))), p.setShape({
				smooth: M,
				stackedOnSmooth: P,
				smoothMonotone: te,
				connectNulls: x
			}), Zd(p, e, "areaStyle"), Z(p).seriesIndex = e.seriesIndex, qd(p, k, A, j);
		}
		var re = this._changePolyState;
		a.eachItemGraphicEl(function(e) {
			e && (e.onHoverStateChange = re);
		}), this._polyline.onHoverStateChange = re, this._data = a, this._coordSys = r, this._stackedOnPoints = y, this._points = c, this._step = w, this._valueOrigin = _;
		var F = e.get("triggerEvent"), ie = e.get("triggerLineEvent"), I = ie === !0 || F === !0 || F === "line", L = ie === !0 || F === !0 || F === "area";
		this.packEventData(e, f, I), p && this.packEventData(e, p, L);
	}, t.prototype.packEventData = function(e, t, n) {
		Z(t).eventData = n ? {
			componentType: "series",
			componentSubType: "line",
			componentIndex: e.componentIndex,
			seriesIndex: e.seriesIndex,
			seriesName: e.name,
			seriesType: "line",
			selfType: t === this._polygon ? "area" : "line"
		} : null;
	}, t.prototype.highlight = function(e, t, n, r) {
		var i = e.getData(), a = Ds(i, r);
		if (this._changePolyState("emphasis"), !(a instanceof Array) && a != null && a >= 0) {
			var o = i.getLayout("points"), s = i.getItemGraphicEl(a);
			if (!s) {
				var c = o[a * 2], l = o[a * 2 + 1];
				if (Rk(c, l) || this._clipShapeForSymbol && !this._clipShapeForSymbol.contain(c, l)) return;
				var u = e.get("zlevel") || 0, d = e.get("z") || 0;
				s = new Ok(i, a), s.x = c, s.y = l, s.setZ(u, d);
				var f = s.getSymbolPath().getTextContent();
				f && (f.zlevel = u, f.z = d, f.z2 = this._polyline.z2 + 1), s.__temp = !0, i.setItemGraphicEl(a, s), s.stopSymbolAnimation(!0), this.group.add(s);
			}
			s.highlight();
		} else sb.prototype.highlight.call(this, e, t, n, r);
	}, t.prototype.downplay = function(e, t, n, r) {
		var i = e.getData(), a = Ds(i, r);
		if (this._changePolyState("normal"), a != null && a >= 0) {
			var o = i.getItemGraphicEl(a);
			o && (o.__temp ? (i.setItemGraphicEl(a, null), this.group.remove(o)) : o.downplay());
		} else sb.prototype.downplay.call(this, e, t, n, r);
	}, t.prototype._changePolyState = function(e) {
		var t = this._polygon;
		yd(this._polyline, e), t && yd(t, e);
	}, t.prototype._newPolyline = function(e) {
		var t = this._polyline;
		return t && this._lineGroup.remove(t), t = new Yk({
			shape: { points: e },
			segmentIgnoreThreshold: 2,
			z2: 10
		}), this._lineGroup.add(t), this._polyline = t, t;
	}, t.prototype._newPolygon = function(e, t) {
		var n = this._polygon;
		return n && this._lineGroup.remove(n), n = new Zk({
			shape: {
				points: e,
				stackedOnPoints: t
			},
			segmentIgnoreThreshold: 2
		}), this._lineGroup.add(n), this._polygon = n, n;
	}, t.prototype._initSymbolLabelAnimation = function(e, t, n) {
		var r, i, a = t.getBaseAxis(), o = a.inverse;
		t.type === "cartesian2d" ? (r = a.isHorizontal(), i = !1) : t.type === "polar" && (r = a.dim === "angle", i = !0);
		var s = e.hostModel, c = s.get("animationDuration");
		H(c) && (c = c(null));
		var l = s.get("animationDelay") || 0, u = H(l) ? l(null) : l;
		e.eachItemGraphicEl(function(e, a) {
			var s = e;
			if (s) {
				var d = [e.x, e.y], f = void 0, p = void 0, m = void 0;
				if (n) {
					if (i) {
						var h = n, g = t.pointToCoord(d);
						r ? (f = h.startAngle, p = h.endAngle, m = -g[1] / 180 * Math.PI) : (f = h.r0, p = h.r, m = g[0]);
					} else {
						var _ = n;
						r ? (f = _.x, p = _.x + _.width, m = e.x) : (f = _.y + _.height, p = _.y, m = e.y);
					}
				}
				var v = p === f ? 0 : (m - f) / (p - f);
				o && (v = 1 - v);
				var y = H(l) ? l(a) : c * v + u, b = s.getSymbolPath(), x = b.getTextContent();
				s.attr({
					scaleX: 0,
					scaleY: 0
				}), s.animateTo({
					scaleX: 1,
					scaleY: 1
				}, {
					duration: 200,
					setToFinal: !0,
					delay: y
				}), x && x.animateFrom({ style: { opacity: 0 } }, {
					duration: 300,
					delay: y
				}), b.disableLabelAnimation = !0;
			}
		});
	}, t.prototype._initOrUpdateEndLabel = function(e, t, n) {
		var r = e.getModel("endLabel");
		if (xA(e)) {
			var i = e.getData(), a = this._polyline, o = i.getLayout("points");
			if (!o) {
				a.removeTextContent(), this._endLabel = null;
				return;
			}
			var s = this._endLabel;
			s || (s = this._endLabel = new Tu({ z2: 200 }), s.ignoreClip = !0, a.setTextContent(this._endLabel), a.disableLabelAnimation = !0);
			var c = vA(o);
			c >= 0 && (Nm(a, Pm(e, "endLabel"), {
				inheritColor: n,
				labelFetcher: e,
				labelDataIndex: c,
				defaultText: function(e, t, n) {
					return n == null ? Ek(i, e) : Dk(i, n);
				},
				enableTextSetter: !0
			}, CA(r, t)), a.textConfig.position = null);
		} else this._endLabel &&= (this._polyline.removeTextContent(), null);
	}, t.prototype._endLabelOnDuring = function(e, t, n, r, i, a, o) {
		var s = this._endLabel, c = this._polyline;
		if (s) {
			e < 1 && r.originalX == null && (r.originalX = s.x, r.originalY = s.y);
			var l = n.getLayout("points"), u = n.hostModel, d = u.get("connectNulls"), f = a.get("precision"), p = a.get("distance") || 0, m = o.getBaseAxis(), h = m.isHorizontal(), g = m.inverse, _ = t.shape, v = g ? h ? _.x : _.y + _.height : h ? _.x + _.width : _.y, y = (h ? p : 0) * (g ? -1 : 1), b = (h ? 0 : -p) * (g ? -1 : 1), x = h ? "x" : "y", S = bA(l, v, x), C = S.range, w = C[1] - C[0], T = void 0;
			if (w >= 1) {
				if (w > 1 && !d) {
					var E = yA(l, C[0]);
					s.attr({
						x: E[0] + y,
						y: E[1] + b
					}), i && (T = u.getRawValue(C[0]));
				} else {
					var E = c.getPointOn(v, x);
					E && s.attr({
						x: E[0] + y,
						y: E[1] + b
					});
					var D = u.getRawValue(C[0]), O = u.getRawValue(C[1]);
					i && (T = Rs(n, f, D, O, S.t));
				}
				r.lastFrameIndex = C[0];
			} else {
				var k = e === 1 || r.lastFrameIndex > 0 ? C[0] : 0, E = yA(l, k);
				i && (T = u.getRawValue(k)), s.attr({
					x: E[0] + y,
					y: E[1] + b
				});
			}
			if (i) {
				var A = Wm(s);
				typeof A.setLabelText == "function" && A.setLabelText(T);
			}
		}
	}, t.prototype._doUpdateAnimation = function(e, t, n, r, i, a, o) {
		var s = this._polyline, c = this._polygon, l = e.hostModel, u = Wk(this._data, e, this._stackedOnPoints, t, this._coordSys, n, this._valueOrigin, a), d = u.current, f = u.stackedOnCurrent, p = u.next, m = u.stackedOnNext;
		if (i && (f = pA(u.stackedOnCurrent, u.current, n, i, o), d = pA(u.current, null, n, i, o), m = pA(u.stackedOnNext, u.next, n, i, o), p = pA(u.next, null, n, i, o)), uA(d, p) > 3e3 || c && uA(f, m) > 3e3) s.stopAnimation(), s.setShape({ points: p }), c && (c.stopAnimation(), c.setShape({
			points: p,
			stackedOnPoints: m
		}));
		else {
			s.shape.__points = u.current, s.shape.points = d;
			var h = { shape: { points: p } };
			u.current !== d && (h.shape.__points = u.next), s.stopAnimation(), kp(s, h, l), c && (c.setShape({
				points: d,
				stackedOnPoints: f
			}), c.stopAnimation(), kp(c, { shape: { stackedOnPoints: m } }, l), s.shape.points !== c.shape.points && (c.shape.points = s.shape.points));
			for (var g = [], _ = u.status, v = 0; v < _.length; v++) if (_[v].cmd === "=") {
				var y = e.getItemGraphicEl(_[v].idx1);
				y && g.push({
					el: y,
					ptIdx: v
				});
			}
			s.animators && s.animators.length && s.animators[0].during(function() {
				c && c.dirtyShape();
				for (var e = s.shape.__points, t = 0; t < g.length; t++) {
					var n = g[t].el, r = g[t].ptIdx * 2;
					n.x = e[r], n.y = e[r + 1], n.markRedraw();
				}
			});
		}
	}, t.prototype.remove = function(e) {
		var t = this.group, n = this._data;
		this._lineGroup.removeAll(), this._symbolDraw.remove(!0), n && n.eachItemGraphicEl(function(e, r) {
			e.__temp && (t.remove(e), n.setItemGraphicEl(r, null));
		}), this._polyline = this._polygon = this._coordSys = this._points = this._stackedOnPoints = this._endLabel = this._data = null;
	}, t.type = "line", t;
}(sb);
//#endregion
//#region node_modules/echarts/lib/layout/points.js
function TA(e, t) {
	return {
		seriesType: e,
		plan: ib(),
		reset: function(e) {
			var n = e.getData(), r = e.coordinateSystem, i = e.pipelineContext, a = t || i.large;
			if (r) {
				var o = L(r.dimensions, function(e) {
					return n.mapDimension(e);
				}).slice(0, 2), s = o.length, c = n.getCalculationInfo("stackResultDimension");
				tT(n, o[0]) && (o[0] = c), tT(n, o[1]) && (o[1] = c);
				var l = n.getStore(), u = n.getDimensionIndex(o[0]), d = n.getDimensionIndex(o[1]);
				return s && { progress: function(e, t) {
					for (var n = e.end - e.start, i = a && Vk(n * s), o = [], c = [], f = e.start, p = 0; f < e.end; f++) {
						var m = void 0;
						if (s === 1) {
							var h = l.get(u, f);
							m = r.dataToPoint(h, null, c);
						} else o[0] = l.get(u, f), o[1] = l.get(d, f), m = r.dataToPoint(o, null, c);
						a ? (i[p++] = m[0], i[p++] = m[1]) : t.setItemLayout(f, m.slice());
					}
					a && (t.setLayout("points", i), t.setLayout("pointsRange", {
						start: e.start,
						end: e.end
					}));
				} };
			}
		}
	};
}
//#endregion
//#region node_modules/echarts/lib/processor/dataSample.js
var EA = {
	average: function(e) {
		for (var t = 0, n = 0, r = 0; r < e.length; r++) isNaN(e[r]) || (t += e[r], n++);
		return n === 0 ? NaN : t / n;
	},
	sum: function(e) {
		for (var t = 0, n = 0; n < e.length; n++) t += e[n] || 0;
		return t;
	},
	max: function(e) {
		for (var t = -Infinity, n = 0; n < e.length; n++) e[n] > t && (t = e[n]);
		return isFinite(t) ? t : NaN;
	},
	min: function(e) {
		for (var t = Infinity, n = 0; n < e.length; n++) e[n] < t && (t = e[n]);
		return isFinite(t) ? t : NaN;
	},
	nearest: function(e) {
		return e[0];
	}
}, DA = function(e) {
	return Math.round(e.length / 2);
};
function OA(e) {
	return {
		seriesType: e,
		reset: function(e, t, n) {
			var r = e.getData(), i = e.get("sampling"), a = e.coordinateSystem, o = r.count();
			if (o > 10 && a.type === "cartesian2d" && i) {
				var s = a.getBaseAxis(), c = a.getOtherAxis(s), l = s.getExtent(), u = n.getDevicePixelRatio(), d = Math.abs(l[1] - l[0]) * (u || 1), f = Math.round(o / d);
				if (isFinite(f) && f > 1) {
					i === "lttb" ? e.setData(r.lttbDownSample(r.mapDimension(c.dim), 1 / f)) : i === "minmax" && e.setData(r.minmaxDownSample(r.mapDimension(c.dim), 1 / f));
					var p = void 0;
					U(i) ? p = EA[i] : H(i) && (p = i), p && e.setData(r.downSample(r.mapDimension(c.dim), 1 / f, p, DA));
				}
			}
		}
	};
}
//#endregion
//#region node_modules/echarts/lib/chart/line/install.js
function kA(e) {
	e.registerChartView(wA), e.registerSeriesModel(Tk), e.registerLayout(TA("line", !0)), e.registerVisual({
		seriesType: "line",
		reset: function(e) {
			var t = e.getData(), n = e.getModel("lineStyle").getLineStyle();
			n && !n.stroke && (n.stroke = t.getVisual("style").fill), t.setVisual("legendLineStyle", n);
		}
	}), e.registerProcessor(e.PRIORITY.PROCESSOR.STATISTIC, OA("line"));
}
//#endregion
//#region node_modules/echarts/lib/coord/cartesian/Axis2D.js
var AA = function(e) {
	n(t, e);
	function t(t, n, r, i, a) {
		var o = e.call(this, t, n, r) || this;
		return o.index = 0, o.type = i || "value", o.position = a || "bottom", o;
	}
	return t.prototype.isHorizontal = function() {
		var e = this.position;
		return e === "top" || e === "bottom";
	}, t.prototype.getGlobalExtent = function(e) {
		var t = this.getExtent();
		return t[0] = this.toGlobalCoord(t[0]), t[1] = this.toGlobalCoord(t[1]), e && t[0] > t[1] && t.reverse(), t;
	}, t.prototype.pointToData = function(e, t) {
		return this.coordToData(this.toLocalCoord(e[this.dim === "x" ? 0 : 1]), t);
	}, t.prototype.setCategorySortInfo = function(e) {
		if (this.type !== "category") return !1;
		this.model.option.categorySortInfo = e, this.scale.setSortInfo(e);
	}, t;
}(yO), jA = null;
function MA() {
	return jA;
}
//#endregion
//#region node_modules/echarts/lib/component/axis/axisAction.js
var NA = "expandAxisBreak", PA = Math.PI, FA = [
	[
		1,
		2,
		1,
		2
	],
	[
		5,
		3,
		5,
		3
	],
	[
		8,
		3,
		8,
		3
	]
], IA = [
	[
		0,
		1,
		0,
		1
	],
	[
		0,
		3,
		0,
		3
	],
	[
		0,
		3,
		0,
		3
	]
], LA = X(), RA = X(), zA = function() {
	function e(e) {
		this.recordMap = {}, this.resolveAxisNameOverlap = e;
	}
	return e.prototype.ensureRecord = function(e) {
		var t = e.axis.dim, n = e.componentIndex, r = this.recordMap, i = r[t] || (r[t] = []);
		return i[n] || (i[n] = { ready: {} });
	}, e;
}();
function BA(e, t, n, r) {
	var i = n.axis, a = t.ensureRecord(n), o = [], s, c = uj(e.axisName) && _E(e.nameLocation);
	I(r, function(e) {
		var t = nk(e);
		if (t && !t.label.ignore) {
			o.push(t);
			var n = a.transGroup;
			c && (n.transform ? Xt(VA, n.transform) : Wt(VA), t.transform && Kt(VA, VA, t.transform), Y.copy(HA, t.localRect), HA.applyTransform(VA), s ? s.union(HA) : Y.copy(s = new Y(0, 0, 0, 0), HA));
		}
	});
	var l = Math.abs(a.dirVec.x) > .1 ? "x" : "y", u = a.transGroup[l];
	if (o.sort(function(e, t) {
		return Math.abs(e.label[l] - u) - Math.abs(t.label[l] - u);
	}), c && s) {
		var d = i.getExtent(), f = Math.min(d[0], d[1]), p = Math.max(d[0], d[1]) - f;
		s.union(new Y(f, 0, p, 1));
	}
	a.stOccupiedRect = s, a.labelInfoList = o;
}
var VA = Ut(), HA = new Y(0, 0, 0, 0), UA = function(e, t, n, r, i, a) {
	if (_E(e.nameLocation)) {
		var o = a.stOccupiedRect;
		o && WA(ak({}, o, a.transGroup.transform), r, i);
	} else GA(a.labelInfoList, a.dirVec, r, i);
};
function WA(e, t, n) {
	var r = new J();
	fk(e, t, r, {
		direction: Math.atan2(n.y, n.x),
		bidirectional: !1,
		touchThreshold: .05
	}) && ok(t, r);
}
function GA(e, t, n, r) {
	for (var i = J.dot(r, t) >= 0, a = 0, o = e.length; a < o; a++) {
		var s = e[i ? a : o - 1 - a];
		s.label.ignore || WA(s, n, r);
	}
}
var KA = function() {
	function e(e, t, n, r) {
		this.group = new Wa(), this._axisModel = e, this._api = t, this._local = {}, this._shared = r || new zA(UA), this._resetCfgDetermined(n);
	}
	return e.prototype.updateCfg = function(e) {
		var t = this._cfg.raw;
		t.position = e.position, t.labelOffset = e.labelOffset, this._resetCfgDetermined(t);
	}, e.prototype.__getRawCfg = function() {
		return this._cfg.raw;
	}, e.prototype._resetCfgDetermined = function(e) {
		var t = this._axisModel, n = t.getDefaultOption ? t.getDefaultOption() : {}, r = G(e.axisName, t.get("name")), i = t.get("nameMoveOverlap");
		(i == null || i === "auto") && (i = G(e.defaultNameMoveOverlap, !0));
		var a = {
			raw: e,
			position: e.position,
			rotation: e.rotation,
			nameDirection: G(e.nameDirection, 1),
			tickDirection: G(e.tickDirection, 1),
			labelDirection: G(e.labelDirection, 1),
			labelOffset: G(e.labelOffset, 0),
			silent: G(e.silent, !0),
			axisName: r,
			nameLocation: ye(t.get("nameLocation"), n.nameLocation, "end"),
			shouldNameMoveOverlap: uj(r) && i,
			optionHideOverlap: t.get(["axisLabel", "hideOverlap"]),
			showMinorTicks: t.get(["minorTick", "show"])
		};
		this._cfg = a;
		var o = new Wa({
			x: a.position[0],
			y: a.position[1],
			rotation: a.rotation
		});
		o.updateTransform(), this._transformGroup = o;
		var s = this._shared.ensureRecord(t);
		s.transGroup = this._transformGroup, s.dirVec = new J(Math.cos(-a.rotation), Math.sin(-a.rotation));
	}, e.prototype.build = function(e, t) {
		var n = this;
		return e ||= {
			axisLine: !0,
			axisTickLabelEstimate: !1,
			axisTickLabelDetermine: !0,
			axisName: !0
		}, I(qA, function(r) {
			e[r] && JA[r](n._cfg, n._local, n._shared, n._axisModel, n.group, n._transformGroup, n._api, t || {});
		}), this;
	}, e.innerTextLayout = function(e, t, n) {
		var r = Lo(t - e), i, a;
		return Ro(r) ? (a = n > 0 ? "top" : "bottom", i = "center") : Ro(r - PA) ? (a = n > 0 ? "bottom" : "top", i = "center") : (a = "middle", i = r > 0 && r < PA ? n > 0 ? "right" : "left" : n > 0 ? "left" : "right"), {
			rotation: r,
			textAlign: i,
			textVerticalAlign: a
		};
	}, e.makeAxisEventDataBase = function(e) {
		var t = {
			componentType: e.mainType,
			componentIndex: e.componentIndex
		};
		return t[e.mainType + "Index"] = e.componentIndex, t;
	}, e.isLabelSilent = function(e) {
		var t = e.get("tooltip");
		return e.get("silent") || !(e.get("triggerEvent") || t && t.show);
	}, e;
}(), qA = [
	"axisLine",
	"axisTickLabelEstimate",
	"axisTickLabelDetermine",
	"axisName"
], JA = {
	axisLine: function(e, t, n, r, i, a, o) {
		var s = r.get(["axisLine", "show"]);
		if (s === "auto" && (s = !0, e.raw.axisLineAutoShow != null && (s = !!e.raw.axisLineAutoShow)), s) {
			var c = r.axis.getExtent(), l = a.transform, u = [c[0], 0], d = [c[1], 0], f = u[0] > d[0];
			l && (ot(u, u, l), ot(d, d, l));
			var p = M({ lineCap: "round" }, r.getModel(["axisLine", "lineStyle"]).getLineStyle()), m = {
				strokeContainThreshold: e.raw.strokeContainThreshold || 5,
				silent: !0,
				z2: 1,
				style: p
			};
			if (r.get(["axisLine", "breakLine"]) && Eh(r.axis.scale)) MA().buildAxisBreakLine(r, i, a, m);
			else {
				var h = new ip(M({ shape: {
					x1: u[0],
					y1: u[1],
					x2: d[0],
					y2: d[1]
				} }, m));
				Xp(h.shape, h.style.lineWidth), h.anid = "line", i.add(h);
			}
			var g = r.get(["axisLine", "symbol"]);
			if (g != null) {
				var _ = r.get(["axisLine", "symbolSize"]);
				U(g) && (g = [g, g]), (U(_) || ue(_)) && (_ = [_, _]);
				var v = Ax(r.get(["axisLine", "symbolOffset"]) || 0, _), y = _[0], b = _[1];
				I([{
					rotate: e.rotation + Math.PI / 2,
					offset: v[0],
					r: 0
				}, {
					rotate: e.rotation - Math.PI / 2,
					offset: v[1],
					r: Math.sqrt((u[0] - d[0]) * (u[0] - d[0]) + (u[1] - d[1]) * (u[1] - d[1]))
				}], function(t, n) {
					if (g[n] !== "none" && g[n] != null) {
						var r = Ox(g[n], -y / 2, -b / 2, y, b, p.stroke, !0), a = t.r + t.offset, o = f ? d : u;
						r.attr({
							rotation: t.rotate,
							x: o[0] + a * Math.cos(e.rotation),
							y: o[1] - a * Math.sin(e.rotation),
							silent: !0,
							z2: 11
						}), i.add(r);
					}
				});
			}
		}
	},
	axisTickLabelEstimate: function(e, t, n, r, i, a, o, s) {
		rj(t, i, s) && YA(e, t, n, r, i, a, o, JD.estimate);
	},
	axisTickLabelDetermine: function(e, t, n, r, i, a, o, s) {
		rj(t, i, s) && YA(e, t, n, r, i, a, o, JD.determine);
		var c = tj(e, i, a, r);
		QA(e, t.labelLayoutList, c), nj(e, i, a, r, e.tickDirection);
	},
	axisName: function(e, t, n, r, i, a, o, s) {
		var c = n.ensureRecord(r);
		t.nameEl &&= (i.remove(t.nameEl), c.nameLayout = c.nameLocation = null);
		var l = e.axisName;
		if (uj(l)) {
			var u = e.nameLocation, d = e.nameDirection, f = r.getModel("nameTextStyle"), p = r.get("nameGap") || 0, m = r.axis.getExtent(), h = r.axis.inverse ? -1 : 1, g = new J(0, 0), _ = new J(0, 0);
			u === "start" ? (g.x = m[0] - h * p, _.x = -h) : u === "end" ? (g.x = m[1] + h * p, _.x = h) : (g.x = (m[0] + m[1]) / 2, g.y = e.labelOffset + d * p, _.y = d);
			var v = Ut();
			_.transform(Jt(v, v, e.rotation));
			var y = r.get("nameRotate");
			y != null && (y = y * PA / 180);
			var b, x;
			_E(u) ? b = KA.innerTextLayout(e.rotation, y ?? e.rotation, d) : (b = XA(e.rotation, u, y || 0, m), x = e.raw.axisNameAvailableWidth, x != null && (x = Math.abs(x / Math.sin(b.rotation)), !isFinite(x) && (x = null)));
			var S = f.getFont(), C = r.get("nameTruncate", !0) || {}, w = C.ellipsis, T = ve(e.raw.nameTruncateMaxWidth, C.maxWidth, x), E = s.nameMarginLevel || 0, D = new Tu({
				x: g.x,
				y: g.y,
				rotation: b.rotation,
				silent: KA.isLabelSilent(r),
				style: Fm(f, {
					text: l,
					font: S,
					overflow: "truncate",
					width: T,
					ellipsis: w,
					fill: f.getTextColor() || r.get([
						"axisLine",
						"lineStyle",
						"color"
					]),
					align: f.get("align") || b.textAlign,
					verticalAlign: f.get("verticalAlign") || b.textVerticalAlign
				}),
				z2: 1
			});
			if (hm({
				el: D,
				componentModel: r,
				itemName: l
			}), D.__fullText = l, D.anid = "name", r.get("triggerEvent")) {
				var O = KA.makeAxisEventDataBase(r);
				O.targetType = "axisName", O.name = l, Z(D).eventData = O;
			}
			a.add(D), D.updateTransform(), t.nameEl = D;
			var k = c.nameLayout = nk({
				label: D,
				priority: D.z2,
				defaultAttr: { ignore: D.ignore },
				marginDefault: _E(u) ? FA[E] : IA[E]
			});
			if (c.nameLocation = u, i.add(D), D.decomposeTransform(), e.shouldNameMoveOverlap && k) {
				var A = n.ensureRecord(r);
				n.resolveAxisNameOverlap(e, n, r, k, _, A);
			}
		}
	}
};
function YA(e, t, n, r, i, a, o, s) {
	aj(t) || ij(e, t, i, s, r, o);
	var c = t.labelLayoutList;
	sj(e, r, c, a), fj(r, e.rotation, c);
	var l = e.optionHideOverlap;
	ZA(r, c, l), l && dk(oe(c, function(e) {
		return e && !e.label.ignore;
	})), BA(e, n, r, c);
}
function XA(e, t, n, r) {
	var i = Lo(n - e), a, o, s = r[0] > r[1], c = t === "start" && !s || t !== "start" && s;
	return Ro(i - PA / 2) ? (o = c ? "bottom" : "top", a = "center") : Ro(i - PA * 1.5) ? (o = c ? "top" : "bottom", a = "center") : (o = "middle", a = i < PA * 1.5 && i > PA / 2 ? c ? "left" : "right" : c ? "right" : "left"), {
		rotation: i,
		textAlign: a,
		textVerticalAlign: o
	};
}
function ZA(e, t, n) {
	var r = e.axis, i = e.get(["axisLabel", "customValues"]);
	if (hE(r)) return;
	function a(e, a, o) {
		var s = nk(t[a]), c = nk(t[o]), l = r.scale;
		if (s && c) {
			if (e == null) {
				if (!n && i) return;
				var u = LA(s.label).labelInfo.tick;
				if (TT(l) && u.notNice || DT(l) && u.offInterval) {
					$A(s.label);
					return;
				}
			}
			if (e === !1 || s.suggestIgnore) $A(s.label);
			else if (c.suggestIgnore) $A(c.label);
			else {
				var d = .1;
				if (!n) {
					var f = [
						0,
						0,
						0,
						0
					];
					s = sk({ marginForce: f }, s), c = sk({ marginForce: f }, c);
				}
				fk(s, c, null, { touchThreshold: d }) && $A(e ? c.label : s.label);
			}
		}
	}
	var o = e.get(["axisLabel", "showMinLabel"]), s = e.get(["axisLabel", "showMaxLabel"]), c = t.length;
	a(o, 0, 1), a(s, c - 1, c - 2);
}
function QA(e, t, n) {
	e.showMinorTicks || I(t, function(e) {
		if (e && e.label.ignore) for (var t = 0; t < n.length; t++) {
			var r = n[t], i = RA(r), a = LA(e.label);
			if (i.tickValue != null && !i.onBand && i.tickValue === a.labelInfo.tick.value) {
				$A(r);
				return;
			}
		}
	});
}
function $A(e) {
	e && (e.ignore = !0);
}
function ej(e, t, n, r, i) {
	for (var a = [], o = [], s = [], c = 0; c < e.length; c++) {
		var l = e[c].coord;
		o[0] = l, o[1] = 0, s[0] = l, s[1] = n, t && (ot(o, o, t), ot(s, s, t));
		var u = new ip({
			shape: {
				x1: o[0],
				y1: o[1],
				x2: s[0],
				y2: s[1]
			},
			style: r,
			z2: 2,
			autoBatch: !0,
			silent: !0
		});
		Xp(u.shape, u.style.lineWidth), u.anid = i + "_" + e[c].tickValue, a.push(u);
		var d = RA(u);
		d.onBand = !!e[c].onBand, d.tickValue = e[c].tickValue;
	}
	return a;
}
function tj(e, t, n, r) {
	var i = r.axis, a = r.getModel("axisTick"), o = a.get("show");
	if (o === "auto" && (o = !0, e.raw.axisTickAutoShow != null && (o = !!e.raw.axisTickAutoShow)), !o || i.scale.isBlank()) return [];
	for (var s = a.getModel("lineStyle"), c = e.tickDirection * a.get("length"), l = ej(i.getTicksCoords(), n.transform, c, N(s.getLineStyle(), { stroke: r.get([
		"axisLine",
		"lineStyle",
		"color"
	]) }), "ticks"), u = 0; u < l.length; u++) t.add(l[u]);
	return l;
}
function nj(e, t, n, r, i) {
	var a = r.axis, o = r.getModel("minorTick");
	if (e.showMinorTicks && !a.scale.isBlank()) {
		var s = a.getMinorTicksCoords();
		if (s.length) for (var c = o.getModel("lineStyle"), l = i * o.get("length"), u = N(c.getLineStyle(), N(r.getModel("axisTick").getLineStyle(), { stroke: r.get([
			"axisLine",
			"lineStyle",
			"color"
		]) })), d = 0; d < s.length; d++) for (var f = ej(s[d], n.transform, l, u, "minorticks_" + d), p = 0; p < f.length; p++) t.add(f[p]);
	}
}
function rj(e, t, n) {
	if (aj(e)) {
		var r = e.axisLabelsCreationContext.out.noPxChangeTryDetermine;
		if (n.noPxChange) {
			for (var i = !0, a = 0; a < r.length; a++) i &&= r[a]();
			if (i) return !1;
		}
		r.length && (t.remove(e.labelGroup), oj(e, null, null, null));
	}
	return !0;
}
function ij(e, t, n, r, i, a) {
	var o = i.axis, s = ve(e.raw.axisLabelShow, i.get(["axisLabel", "show"])), c = new Wa();
	n.add(c);
	var l = YD(r);
	if (!s || o.scale.isBlank()) oj(t, [], c, l);
	else {
		var u = i.getModel("axisLabel"), d = o.getViewLabels(l), f = (ve(e.raw.labelRotate, u.get("rotate")) || 0) * PA / 180, p = KA.innerTextLayout(e.rotation, f, e.labelDirection), m = i.getCategories && i.getCategories(!0), h = [], g = i.get("triggerEvent"), _ = Infinity, v = -Infinity;
		I(d, function(e, t) {
			var n = e.tick, r = e.formattedLabel, s = e.rawLabel, l = u, f = SE(o.scale, n);
			if (m && m[f]) {
				var y = m[f];
				W(y) && y.textStyle && (l = new ih(y.textStyle, u, i.ecModel));
			}
			var b = l.getTextColor() || i.get([
				"axisLine",
				"lineStyle",
				"color"
			]), x = l.getShallow("align", !0) || p.textAlign, S = G(l.getShallow("alignMinLabel", !0), x), C = G(l.getShallow("alignMaxLabel", !0), x), w = l.getShallow("verticalAlign", !0) || l.getShallow("baseline", !0) || p.textVerticalAlign, T = G(l.getShallow("verticalAlignMinLabel", !0), w), E = G(l.getShallow("verticalAlignMaxLabel", !0), w), D = 10 + (n.time?.level || 0);
			_ = Math.min(_, D), v = Math.max(v, D);
			var O = new Tu({
				x: 0,
				y: 0,
				rotation: 0,
				silent: KA.isLabelSilent(i),
				z2: D,
				style: Fm(l, {
					text: r,
					align: t === 0 ? S : t === d.length - 1 ? C : x,
					verticalAlign: t === 0 ? T : t === d.length - 1 ? E : w,
					fill: H(b) ? b(o.type === "category" ? s : o.type === "value" ? f + "" : f, t) : b
				})
			});
			O.anid = "label_" + f;
			var k = LA(O);
			if (k.labelInfo = e, k.layoutRotation = p.rotation, hm({
				el: O,
				componentModel: i,
				itemName: r,
				formatterParamsExtra: {
					isTruncated: function() {
						return O.isTruncated;
					},
					value: s,
					tickIndex: t
				}
			}), g) {
				var A = KA.makeAxisEventDataBase(i);
				A.targetType = "axisLabel", A.value = s, A.tickIndex = t;
				var j = e.tick.break;
				if (j) {
					var ee = j.parsedBreak;
					A.break = {
						start: ee.vmin,
						end: ee.vmax
					};
				}
				o.type === "category" && (A.dataIndex = f), Z(O).eventData = A, j && dj(i, a, O, j);
			}
			h.push(O), c.add(O);
		}), oj(t, L(h, function(e) {
			return {
				label: e,
				priority: LA(e).labelInfo.tick.break ? e.z2 + (v - _ + 1) : e.z2,
				defaultAttr: { ignore: e.ignore }
			};
		}), c, l);
	}
}
function aj(e) {
	return !!e.labelLayoutList;
}
function oj(e, t, n, r) {
	e.labelLayoutList = t, e.labelGroup = n, e.axisLabelsCreationContext = r;
}
function sj(e, t, n, r) {
	var i = t.get(["axisLabel", "margin"]);
	I(n, function(n, a) {
		var o = nk(n);
		if (o) {
			var s = o.label, c = LA(s);
			o.suggestIgnore = s.ignore, s.ignore = !1, fa(cj, lj);
			var l = t.axis;
			cj.x = l.dataToCoord(SE(l.scale, c.labelInfo.tick)), cj.y = e.labelOffset + e.labelDirection * i, cj.rotation = c.layoutRotation, r.add(cj), cj.updateTransform(), r.remove(cj), cj.decomposeTransform(), fa(s, cj), s.markRedraw(), ek(o, !0), nk(o);
		}
	});
}
var cj = new bu(), lj = new bu();
function uj(e) {
	return !!e;
}
function dj(e, t, n, r) {
	n.on("click", function(n) {
		var i = {
			type: NA,
			breaks: [{
				start: r.parsedBreak.breakOption.start,
				end: r.parsedBreak.breakOption.end
			}]
		};
		i[e.axis.dim + "AxisIndex"] = e.componentIndex, t.dispatchAction(i);
	});
}
function fj(e, t, n) {
	var r = Ch();
	if (r) {
		var i = r.retrieveAxisBreakPairs(n, function(e) {
			return e && LA(e.label).labelInfo.tick.break;
		}, !0), a = e.get(["breakLabelLayout", "moveOverlap"], !0);
		(a === !0 || a === "auto") && I(i, function(r) {
			MA().adjustBreakLabelPair(e.axis.inverse, t, [nk(n[r[0]]), nk(n[r[1]])]);
		});
	}
}
//#endregion
//#region node_modules/echarts/lib/coord/cartesian/cartesianAxisHelper.js
function pj(e, t, n) {
	n ||= {};
	var r = t.axis, i = {}, a = r.getAxesOnZeroOf()[0], o = r.position, s = a ? "onZero" : o, c = r.dim, l = [
		e.x,
		e.x + e.width,
		e.y,
		e.y + e.height
	], u = {
		left: 0,
		right: 1,
		top: 0,
		bottom: 1,
		onZero: 2
	}, d = t.get("offset") || 0, f = c === "x" ? [l[2] - d, l[3] + d] : [l[0] - d, l[1] + d];
	if (a) {
		var p = a.toGlobalCoord(a.dataToCoord(0));
		f[u.onZero] = Math.max(Math.min(p, f[1]), f[0]);
	}
	i.position = [c === "y" ? f[u[s]] : l[0], c === "x" ? f[u[s]] : l[3]], i.rotation = Math.PI / 2 * (c === "x" ? 0 : 1), i.labelDirection = i.tickDirection = i.nameDirection = {
		top: -1,
		bottom: 1,
		left: -1,
		right: 1
	}[o], i.labelOffset = a ? f[u[o]] - f[u.onZero] : 0, t.get(["axisTick", "inside"]) && (i.tickDirection = -i.tickDirection), ve(n.labelInside, t.get(["axisLabel", "inside"])) && (i.labelDirection = -i.labelDirection);
	var m = t.get(["axisLabel", "rotate"]);
	return i.labelRotate = s === "top" ? -m : m, i.z2 = 1, i;
}
function mj(e) {
	return e.coordinateSystem && e.coordinateSystem.type === "cartesian2d";
}
function hj(e) {
	var t = {
		xAxisModel: null,
		yAxisModel: null
	};
	return I(t, function(n, r) {
		var i = r.replace(/Model$/, "");
		t[r] = e.getReferringComponents(i, js).models[0];
	}), t;
}
function gj(e, t, n, r, i, a) {
	for (var o = pj(e, n), s = !1, c = !1, l = 0; l < t.length; l++) CT(t[l].getOtherAxis(n.axis).scale) && (s = c = !0, n.axis.type === "category" && n.axis.onBand && (c = !1));
	return o.axisLineAutoShow = s, o.axisTickAutoShow = c, o.defaultNameMoveOverlap = a, new KA(n, r, o, i);
}
function _j(e, t, n) {
	var r = pj(t, n);
	e.updateCfg(r);
}
//#endregion
//#region node_modules/echarts/lib/coord/axisStatisticsMetricsImpl.js
function vj() {
	BE("liPosMinGap", yj);
}
function yj(e, t, n) {
	var r = K(), i = n.serUids, a = n.liPosMinGap, o, s = t.axis, c = s.scale, l = c.needTransform(), u = c.getFilter ? c.getFilter() : null, d = Zv(u);
	function f(n) {
		FE(e, t.sers, function(e) {
			var t = e.getRawData(), r = t.getDimensionIndex(t.mapDimension(s.dim));
			r >= 0 && n(r, e, t.getStore());
		});
	}
	var p = 0;
	if (f(function(e, t, n) {
		r.set(t.uid, 1), (!i || !i.hasKey(t.uid)) && (o = !0), p += n.count();
	}), (!i || i.keys().length !== r.keys().length) && (o = !0), !o && a != null) t.liPosMinGap = a;
	else {
		Hk(bj, p);
		var m = 0;
		f(function(e, t, n) {
			for (var r = 0, i = n.count(); r < i; ++r) {
				var a = n.get(e, r);
				isFinite(a) && (!u || Qv(d, a)) && (l && (a = c.transformIn(a, null)), bj.arr[m++] = a);
			}
		});
		var h = bj.typed ? bj.arr.subarray(0, m) : (bj.arr.length = m, bj.arr);
		bj.typed ? h.sort() : Oo(h);
		for (var g = Infinity, _ = 1; _ < m; ++_) {
			var v = h[_] - h[_ - 1];
			v > 0 && v < g && (g = v);
		}
		n.liPosMinGap = t.liPosMinGap = Zo(g) ? g : m > 0 ? -2 : -1, n.serUids = r;
	}
}
var bj = Hk({ ctor: Bk }, 50);
//#endregion
//#region node_modules/echarts/lib/chart/helper/axisSnippets.js
function xj(e) {
	return function(t, n) {
		var r = hO(t, { fromStat: { key: e } });
		if (Zo(r.w2)) return [-r.w2 / 2, r.w2 / 2];
	};
}
function Sj(e) {
	return e + "|&";
}
function Cj(e, t) {
	return e + "|&" + t;
}
function wj(e) {
	return vj(), { liPosMinGap: !DT(e.scale) };
}
//#endregion
//#region node_modules/echarts/lib/layout/barCommon.js
function Tj(e, t, n, r) {
	WE(e, {
		key: t,
		seriesType: n,
		coordSysType: r,
		getMetrics: wj
	});
}
function Ej(e) {
	return e.scale.rawExtentInfo.makeRenderInfo().startValue;
}
//#endregion
//#region node_modules/echarts/lib/coord/cartesian/GridModel.js
var Dj = {
	left: 0,
	right: 0,
	top: 0,
	bottom: 0
}, Oj = ["25%", "25%"], kj = "cartesian2d", Aj = function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t.prototype.mergeDefaultAndTheme = function(t, n) {
		var r = Gg(t.outerBounds);
		e.prototype.mergeDefaultAndTheme.apply(this, arguments), r && t.outerBounds && Wg(t.outerBounds, r);
	}, t.prototype.mergeOption = function(t, n) {
		e.prototype.mergeOption.apply(this, arguments), this.option.outerBounds && t.outerBounds && Wg(this.option.outerBounds, t.outerBounds);
	}, t.type = "grid", t.dependencies = ["xAxis", "yAxis"], t.layoutMode = "box", t.defaultOption = {
		show: !1,
		z: 0,
		left: "15%",
		top: 65,
		right: "10%",
		bottom: 80,
		containLabel: !1,
		outerBoundsMode: "auto",
		outerBounds: Dj,
		outerBoundsContain: "all",
		outerBoundsClampWidth: Oj[0],
		outerBoundsClampHeight: Oj[1],
		backgroundColor: Q.color.transparent,
		borderWidth: 1,
		borderColor: Q.color.neutral30
	}, t;
}(Jg), jj = Js(), Mj = "__ec_stack_";
function Nj(e) {
	return e.get("stack") || Mj + e.seriesIndex;
}
function Pj(e, t) {
	var n = Fj(e, t);
	return n.columnMap = Ij(n), n;
}
function Fj(e, t) {
	var n = Cj(t, kj), r = [], i = hO(e, {
		fromStat: { key: n },
		min: 1
	});
	return PE(e, n, function(e) {
		r.push({
			barWidth: So(e.get("barWidth"), i.w),
			barMaxWidth: So(e.get("barMaxWidth"), i.w),
			barMinWidth: So(e.get("barMinWidth") || (zj(e) ? .5 : 1), i.w),
			barGap: e.get("barGap"),
			barCategoryGap: e.get("barCategoryGap"),
			defaultBarGap: e.get("defaultBarGap"),
			stackId: Nj(e)
		});
	}), {
		bandWidthResult: i,
		seriesInfo: r
	};
}
function Ij(e) {
	var t = e.bandWidthResult.w, n = t, r = 0, i, a, o = [], s = {};
	I(e.seriesInfo, function(e, t) {
		t || (a = e.defaultBarGap || 0);
		var c = e.stackId;
		q(s, c) || r++;
		var l = s[c];
		l || (l = s[c] = {
			width: 0,
			maxWidth: 0
		}, o.push(c));
		var u = e.barWidth;
		u && !l.width && (l.width = u, u = lo(n, u), n -= u);
		var d = e.barMaxWidth;
		d && (l.maxWidth = d);
		var f = e.barMinWidth;
		f && (l.minWidth = f);
		var p = e.barGap;
		p != null && (a = p);
		var m = e.barCategoryGap;
		m != null && (i = m);
	}), i ??= uo(35 - o.length * 4, 15) + "%";
	var c = So(i, t), l = So(a, 1), u = (n - c) / (r + (r - 1) * l);
	u = uo(u, 0), I(o, function(e) {
		var t = s[e], i = t.maxWidth, a = t.minWidth;
		if (t.width) {
			var o = t.width;
			i && (o = lo(o, i)), a && (o = uo(o, a)), t.width = o, n -= o + l * o, r--;
		} else {
			var o = u;
			i && i < o && (o = lo(i, n)), a && a > o && (o = a), o !== u && (t.width = o, n -= o + l * o, r--);
		}
	}), u = (n - c) / (r + (r - 1) * l), u = uo(u, 0);
	var d = 0, f;
	I(o, function(e) {
		var t = s[e];
		t.width ||= u, f = t, d += t.width * (1 + l);
	}), f && (d -= f.width * l);
	var p = {}, m = -d / 2;
	return I(o, function(e) {
		var n = s[e];
		p[e] = p[e] || {
			bandWidth: t,
			offset: m,
			width: n.width
		}, m += n.width * (1 + l);
	}), p;
}
function Lj(e) {
	return {
		seriesType: e,
		overallReset: function(t) {
			var n = Cj(e, kj);
			LE(t, n, function(t) {
				var r = Pj(t, e);
				PE(t, n, function(e) {
					var t = r.columnMap[Nj(e)];
					e.getData().setLayout({
						bandWidth: t.bandWidth,
						offset: t.offset,
						size: t.width
					});
				});
			});
		}
	};
}
function Rj(e) {
	return {
		seriesType: e,
		plan: ib(),
		reset: function(e) {
			if (mj(e)) {
				var t = e.getData(), n = e.coordinateSystem, r = n.getBaseAxis(), i = n.getOtherAxis(r), a = t.getDimensionIndex(t.mapDimension(i.dim)), o = t.getDimensionIndex(t.mapDimension(r.dim)), s = e.get("showBackground", !0), c = t.mapDimension(i.dim), l = t.getCalculationInfo("stackResultDimension"), u = tT(t, c) && !!t.getCalculationInfo("stackedOnSeries"), d = i.isHorizontal(), f = i.toGlobalCoord(i.dataToCoord(Ej(i))), p = zj(e), m = e.get("barMinHeight") || 0, h = l && t.getDimensionIndex(l), g = t.getLayout("size"), _ = t.getLayout("offset");
				return { progress: function(e, t) {
					for (var r = e.count, i = p && Vk(r * 3), c = p && s && Vk(r * 3), l = p && Vk(r), v = n.master.getRect(), y = d ? v.width : v.height, b, x = t.getStore(), S = 0; (b = e.next()) != null;) {
						var C = x.get(u ? h : a, b), w = x.get(o, b), T = f, E = void 0;
						u && (E = +C - x.get(a, b));
						var D = void 0, O = void 0, k = void 0, A = void 0;
						if (d) {
							var j = n.dataToPoint([C, w]);
							u && (T = n.dataToPoint([E, w])[0]), D = T, O = j[1] + _, k = j[0] - T, A = g, fo(k) < m && (k = (k < 0 ? -1 : 1) * m);
						} else {
							var j = n.dataToPoint([w, C]);
							u && (T = n.dataToPoint([w, E])[1]), D = j[0] + _, O = T, k = g, A = j[1] - T, fo(A) < m && (A = (A <= 0 ? -1 : 1) * m);
						}
						p ? (i[S] = D, i[S + 1] = O, i[S + 2] = d ? k : A, c && (c[S] = d ? v.x : D, c[S + 1] = d ? O : v.y, c[S + 2] = y), l[b] = b) : t.setItemLayout(b, {
							x: D,
							y: O,
							width: k,
							height: A
						}), S += 3;
					}
					p && t.setLayout({
						largePoints: i,
						largeDataIndices: l,
						largeBackgroundPoints: c,
						valueAxisHorizontal: d
					});
				} };
			}
		}
	};
}
function zj(e) {
	return e.pipelineContext && e.pipelineContext.large;
}
function Bj(e) {
	return xj(Cj(e, kj));
}
function Vj(e) {
	jj(e, function() {
		function t(t) {
			var n = Cj(t, kj);
			Tj(e, n, t, kj), aD(n, Bj(t));
		}
		t("bar"), t("pictorialBar");
	});
}
//#endregion
//#region node_modules/echarts/lib/chart/bar/BaseBarSeries.js
var Hj = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.getInitialData = function(e, t) {
		return aT(null, this, { useEncodeDefaulter: !0 });
	}, t.prototype.getMarkerPosition = function(e, t, n) {
		var r = this.coordinateSystem;
		if (r && r.clampData) {
			var i = r.clampData(e), a = r.dataToPoint(i);
			if (n) I(r.getAxes(), function(e, n) {
				if (e.type === "category" && t != null) {
					var r = e.getTicksCoords(), o = e.getTickModel().get("alignWithLabel"), s = i[n], c = t[n] === "x1" || t[n] === "y1";
					if (c && !o && (s += 1), r.length < 2) return;
					if (r.length === 2) {
						a[n] = e.toGlobalCoord(e.getExtent()[+!!c]);
						return;
					}
					for (var l = void 0, u = void 0, d = 1, f = 0; f < r.length; f++) {
						var p = r[f].coord, m = f === r.length - 1 ? r[f - 1].tickValue + d : r[f].tickValue;
						if (m === s) {
							u = p;
							break;
						}
						if (m < s) l = p;
						else if (l != null && m > s) {
							u = (p + l) / 2;
							break;
						}
						f === 1 && (d = m - r[0].tickValue);
					}
					u ?? (l ? l && (u = r[r.length - 1].coord) : u = r[0].coord), a[n] = e.toGlobalCoord(u);
				}
			});
			else {
				var o = this.getData(), s = o.getLayout("offset"), c = o.getLayout("size"), l = +!r.getBaseAxis().isHorizontal();
				a[l] += s + c / 2;
			}
			return a;
		}
		return [NaN, NaN];
	}, t.prototype.__requireStartValue = function(e) {
		return this.getBaseAxis() !== e;
	}, t.type = "series.__base_bar__", t.defaultOption = {
		z: 2,
		coordinateSystem: "cartesian2d",
		legendHoverLink: !0,
		barMinHeight: 0,
		barMinAngle: 0,
		large: !1,
		largeThreshold: 400,
		progressive: 3e3,
		progressiveChunkMode: "mod",
		defaultBarGap: "10%"
	}, t;
}(Jy);
Jy.registerClass(Hj);
//#endregion
//#region node_modules/echarts/lib/chart/bar/BarSeries.js
var Uj = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.getInitialData = function() {
		return aT(null, this, {
			useEncodeDefaulter: !0,
			createInvertedIndices: !!this.get("realtimeSort", !0) || null
		});
	}, t.prototype.getProgressive = function() {
		return this.get("large") ? this.get("progressive") : !1;
	}, t.prototype.__preparePipelineContext = function(e, t) {
		var n = ec(this, e, t);
		return n.progressiveRender && (n.large = !0), n;
	}, t.prototype.brushSelector = function(e, t, n) {
		return n.rect(t.getItemLayout(e));
	}, t.type = "series.bar", t.dependencies = ["grid", "polar"], t.defaultOption = lh(Hj.defaultOption, {
		clip: !0,
		roundCap: !1,
		showBackground: !1,
		backgroundStyle: {
			color: "rgba(180, 180, 180, 0.2)",
			borderColor: null,
			borderWidth: 0,
			borderType: "solid",
			borderRadius: 0,
			shadowBlur: 0,
			shadowColor: null,
			shadowOffsetX: 0,
			shadowOffsetY: 0,
			opacity: 1
		},
		select: { itemStyle: {
			borderColor: Q.color.primary,
			borderWidth: 2
		} },
		realtimeSort: !1
	}), t;
}(Hj), Wj = function() {
	function e() {
		this.cx = 0, this.cy = 0, this.r0 = 0, this.r = 0, this.startAngle = 0, this.endAngle = Math.PI * 2, this.clockwise = !0;
	}
	return e;
}(), Gj = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this, t) || this;
		return n.type = "sausage", n;
	}
	return t.prototype.getDefaultShape = function() {
		return new Wj();
	}, t.prototype.buildPath = function(e, t) {
		var n = t.cx, r = t.cy, i = Math.max(t.r0 || 0, 0), a = Math.max(t.r, 0), o = (a - i) * .5, s = i + o, c = t.startAngle, l = t.endAngle, u = t.clockwise, d = Math.PI * 2, f = u ? l - c < d : c - l < d;
		f || (c = l - (u ? d : -d));
		var p = Math.cos(c), m = Math.sin(c), h = Math.cos(l), g = Math.sin(l);
		f ? (e.moveTo(p * i + n, m * i + r), e.arc(p * s + n, m * s + r, o, -Math.PI + c, c, !u)) : e.moveTo(p * a + n, m * a + r), e.arc(n, r, a, c, l, !u), e.arc(h * s + n, g * s + r, o, l - Math.PI * 2, l - Math.PI, !u), i !== 0 && e.arc(n, r, i, l, c, u);
	}, t;
}(ou);
//#endregion
//#region node_modules/echarts/lib/label/sectorLabel.js
function Kj(e, t) {
	t ||= {};
	var n = t.isRoundCap;
	return function(t, r, i) {
		var a = r.position;
		if (!a || a instanceof Array) return Ea(t, r, i);
		var o = e(a), s = r.distance == null ? 5 : r.distance, c = this.shape, l = c.cx, u = c.cy, d = c.r, f = c.r0, p = (d + f) / 2, m = c.startAngle, h = c.endAngle, g = (m + h) / 2, _ = n ? Math.abs(d - f) / 2 : 0, v = Math.cos, y = Math.sin, b = l + d * v(m), x = u + d * y(m), S = "left", C = "top";
		switch (o) {
			case "startArc":
				b = l + (f - s) * v(g), x = u + (f - s) * y(g), S = "center", C = "top";
				break;
			case "insideStartArc":
				b = l + (f + s) * v(g), x = u + (f + s) * y(g), S = "center", C = "bottom";
				break;
			case "startAngle":
				b = l + p * v(m) + Jj(m, s + _, !1), x = u + p * y(m) + Yj(m, s + _, !1), S = "right", C = "middle";
				break;
			case "insideStartAngle":
				b = l + p * v(m) + Jj(m, -s + _, !1), x = u + p * y(m) + Yj(m, -s + _, !1), S = "left", C = "middle";
				break;
			case "middle":
				b = l + p * v(g), x = u + p * y(g), S = "center", C = "middle";
				break;
			case "endArc":
				b = l + (d + s) * v(g), x = u + (d + s) * y(g), S = "center", C = "bottom";
				break;
			case "insideEndArc":
				b = l + (d - s) * v(g), x = u + (d - s) * y(g), S = "center", C = "top";
				break;
			case "endAngle":
				b = l + p * v(h) + Jj(h, s + _, !0), x = u + p * y(h) + Yj(h, s + _, !0), S = "left", C = "middle";
				break;
			case "insideEndAngle":
				b = l + p * v(h) + Jj(h, -s + _, !0), x = u + p * y(h) + Yj(h, -s + _, !0), S = "right", C = "middle";
				break;
			default: return Ea(t, r, i);
		}
		return t ||= {}, t.x = b, t.y = x, t.align = S, t.verticalAlign = C, t;
	};
}
function qj(e, t, n, r) {
	if (ue(r)) e.setTextConfig({ rotation: r });
	else if (V(t)) e.setTextConfig({ rotation: 0 });
	else {
		var i = e.shape, a = i.clockwise ? i.startAngle : i.endAngle, o = i.clockwise ? i.endAngle : i.startAngle, s = (a + o) / 2, c, l = n(t);
		switch (l) {
			case "startArc":
			case "insideStartArc":
			case "middle":
			case "insideEndArc":
			case "endArc":
				c = s;
				break;
			case "startAngle":
			case "insideStartAngle":
				c = a;
				break;
			case "endAngle":
			case "insideEndAngle":
				c = o;
				break;
			default:
				e.setTextConfig({ rotation: 0 });
				return;
		}
		var u = Math.PI * 1.5 - c;
		l === "middle" && u > Math.PI / 2 && u < Math.PI * 1.5 && (u -= Math.PI), e.setTextConfig({ rotation: u });
	}
}
function Jj(e, t, n) {
	return t * Math.sin(e) * (n ? -1 : 1);
}
function Yj(e, t, n) {
	return t * Math.cos(e) * (n ? 1 : -1);
}
//#endregion
//#region node_modules/echarts/lib/chart/helper/sectorHelper.js
function Xj(e, t, n) {
	var r = e.get("borderRadius");
	if (r == null) return n ? { cornerRadius: 0 } : null;
	V(r) || (r = [
		r,
		r,
		r,
		r
	]);
	var i = Math.abs(t.r || 0 - t.r0 || 0);
	return { cornerRadius: L(r, function(e) {
		return Ta(e, i);
	}) };
}
//#endregion
//#region node_modules/echarts/lib/chart/bar/BarView.js
var Zj = Math.max, Qj = Math.min, $j = function(e) {
	n(t, e);
	function t() {
		var t = e.call(this) || this;
		return t.type = "bar", t._isFirstFrame = !0, t;
	}
	return t.prototype.render = function(e, t, n, r) {
		this._model = e, this._removeOnRenderedListener(n), this._updateDrawMode(e);
		var i = e.get("coordinateSystem");
		(i === "cartesian2d" || i === "polar") && (this._progressiveEls = null, this._isLargeDraw ? this._renderLarge(e, t, n) : this._renderNormal(e, t, n, r));
	}, t.prototype.incrementalPrepareRender = function(e) {
		this._clear(), this._updateDrawMode(e), this._updateLargeClip(e);
	}, t.prototype.incrementalRender = function(e, t) {
		this._progressiveEls = [], this._incrementalRenderLarge(e, t);
	}, t.prototype.eachRendered = function(e) {
		_m(this._progressiveEls || this.group, e);
	}, t.prototype._updateDrawMode = function(e) {
		var t = e.pipelineContext.large;
		(this._isLargeDraw == null || t !== this._isLargeDraw) && (this._isLargeDraw = t, this._clear());
	}, t.prototype._renderNormal = function(e, t, n, r) {
		var i = this.group, a = e.getData(), o = this._data, s = e.coordinateSystem, c = s.getBaseAxis(), l;
		s.type === "cartesian2d" ? l = c.isHorizontal() : s.type === "polar" && (l = c.dim === "angle");
		var u = e.isAnimationEnabled() ? e : null, d = nM(e, s);
		d && this._enableRealtimeSort(d, a, n);
		var f = e.get("clip", !0) || d, p = s.getArea();
		i.removeClipPath();
		var m = e.get("roundCap", !0), h = e.get("showBackground", !0), g = e.getModel("backgroundStyle"), _ = g.get("borderRadius") || 0, v = [], y = this._backgroundEls, b = r && r.isInitSort, x = r && r.type === "changeAxisOrder";
		function S(e) {
			var t = cM[s.type](a, e);
			if (!t) return null;
			var n = yM(s, l, t);
			return n.useStyle(g.getItemStyle()), s.type === "cartesian2d" ? n.setShape("r", _) : n.setShape("cornerRadius", _), v[e] = n, n;
		}
		a.diff(o).add(function(t) {
			var n = a.getItemModel(t), r = cM[s.type](a, t, n);
			if (r && (h && S(t), a.hasValue(t) && sM[s.type](r))) {
				var o = !1;
				f && (o = eM[s.type](p, r));
				var g = tM[s.type](e, a, t, r, l, u, c.model, !1, m);
				d && (g.forceLabelAnimation = !0), dM(g, a, t, n, r, e, l, s.type === "polar"), b ? g.attr({ shape: r }) : d ? rM(d, u, g, r, t, l, !1, !1) : Ap(g, { shape: r }, e, t), a.setItemGraphicEl(t, g), i.add(g), g.ignore = o;
			}
		}).update(function(t, n) {
			var r = a.getItemModel(t), C = cM[s.type](a, t, r);
			if (C) {
				if (h) {
					var w = void 0;
					y.length === 0 ? w = S(n) : (w = y[n], w.useStyle(g.getItemStyle()), s.type === "cartesian2d" ? w.setShape("r", _) : w.setShape("cornerRadius", _), v[t] = w);
					var T = cM[s.type](a, t), E = vM(l, T, s);
					kp(w, { shape: E }, u, t);
				}
				var D = o.getItemGraphicEl(n);
				if (!a.hasValue(t) || !sM[s.type](C)) i.remove(D);
				else {
					var O = !1;
					if (f && (O = eM[s.type](p, C), O && i.remove(D)), D && (D.type === "sector" && m || D.type === "sausage" && !m) && (D && Pp(D, e, n), D = null), D ? Fp(D) : D = tM[s.type](e, a, t, C, l, u, c.model, !0, m), d && (D.forceLabelAnimation = !0), x) {
						var k = D.getTextContent();
						if (k) {
							var A = Wm(k);
							A.prevValue != null && (A.prevValue = A.value);
						}
					} else dM(D, a, t, r, C, e, l, s.type === "polar");
					b ? D.attr({ shape: C }) : d ? rM(d, u, D, C, t, l, !0, x) : kp(D, { shape: C }, e, t, null), a.setItemGraphicEl(t, D), D.ignore = O, i.add(D);
				}
			}
		}).remove(function(t) {
			var n = o.getItemGraphicEl(t);
			n && Pp(n, e, t);
		}).execute();
		var C = this._backgroundGroup ||= new Wa();
		C.removeAll();
		for (var w = 0; w < v.length; ++w) C.add(v[w]);
		i.add(C), this._backgroundEls = v, this._data = a;
	}, t.prototype._renderLarge = function(e, t, n) {
		this._clear(), hM(e, this.group), this._updateLargeClip(e);
	}, t.prototype._incrementalRenderLarge = function(e, t) {
		this._removeBackground(), hM(t, this.group, this._progressiveEls, !0);
	}, t.prototype._updateLargeClip = function(e) {
		var t = e.get("clip", !0) && eA(e.coordinateSystem, !1, e), n = this.group;
		t ? n.setClipPath(t) : n.removeClipPath();
	}, t.prototype._enableRealtimeSort = function(e, t, n) {
		var r = this;
		if (t.count()) {
			var i = e.baseAxis;
			if (this._isFirstFrame) this._dispatchInitSort(t, e, n), this._isFirstFrame = !1;
			else {
				var a = function(e) {
					var n = t.getItemGraphicEl(e), r = n && n.shape;
					return r && Math.abs(i.isHorizontal() ? r.height : r.width) || 0;
				};
				this._onRendered = function() {
					r._updateSortWithinSameData(t, a, i, n);
				}, n.getZr().on("rendered", this._onRendered);
			}
		}
	}, t.prototype._dataSort = function(e, t, n) {
		var r = [];
		return e.each(e.mapDimension(t.dim), function(e, t) {
			var i = n(t);
			i ??= NaN, r.push({
				dataIndex: t,
				mappedValue: i,
				ordinalNumber: e
			});
		}), r.sort(function(e, t) {
			return t.mappedValue - e.mappedValue;
		}), { ordinalNumbers: L(r, function(e) {
			return e.ordinalNumber;
		}) };
	}, t.prototype._isOrderChangedWithinSameData = function(e, t, n) {
		for (var r = n.scale, i = e.mapDimension(n.dim), a = Number.MAX_VALUE, o = 0, s = r.getOrdinalMeta().categories.length; o < s; ++o) {
			var c = e.rawIndexOf(i, r.getRawOrdinalNumber(o)), l = c < 0 ? Number.MIN_VALUE : t(e.indexOfRawIndex(c));
			if (l > a) return !0;
			a = l;
		}
		return !1;
	}, t.prototype._isOrderDifferentInView = function(e, t) {
		for (var n = t.scale, r = n.getExtent(), i = Math.max(0, r[0]), a = Math.min(r[1], n.getOrdinalMeta().categories.length - 1); i <= a; ++i) if (e.ordinalNumbers[i] !== n.getRawOrdinalNumber(i)) return !0;
	}, t.prototype._updateSortWithinSameData = function(e, t, n, r) {
		if (this._isOrderChangedWithinSameData(e, t, n)) {
			var i = this._dataSort(e, n, t);
			this._isOrderDifferentInView(i, n) && (this._removeOnRenderedListener(r), r.dispatchAction({
				type: "changeAxisOrder",
				componentType: n.dim + "Axis",
				axisId: n.index,
				sortInfo: i
			}));
		}
	}, t.prototype._dispatchInitSort = function(e, t, n) {
		var r = t.baseAxis, i = this._dataSort(e, r, function(n) {
			return e.get(e.mapDimension(t.otherAxis.dim), n);
		});
		n.dispatchAction({
			type: "changeAxisOrder",
			componentType: r.dim + "Axis",
			isInitSort: !0,
			axisId: r.index,
			sortInfo: i
		});
	}, t.prototype.remove = function(e, t) {
		this._clear(this._model), this._removeOnRenderedListener(t);
	}, t.prototype.dispose = function(e, t) {
		this._removeOnRenderedListener(t);
	}, t.prototype._removeOnRenderedListener = function(e) {
		this._onRendered &&= (e.getZr().off("rendered", this._onRendered), null);
	}, t.prototype._clear = function(e) {
		var t = this.group, n = this._data;
		e && e.isAnimationEnabled() && n && !this._isLargeDraw ? (this._removeBackground(), this._backgroundEls = [], n.eachItemGraphicEl(function(t) {
			Pp(t, e, Z(t).dataIndex);
		})) : t.removeAll(), this._data = null, this._isFirstFrame = !0;
	}, t.prototype._removeBackground = function() {
		this.group.remove(this._backgroundGroup), this._backgroundGroup = null;
	}, t.type = "bar", t;
}(sb), eM = {
	cartesian2d: function(e, t) {
		var n = t.width < 0 ? -1 : 1, r = t.height < 0 ? -1 : 1;
		n < 0 && (t.x += t.width, t.width = -t.width), r < 0 && (t.y += t.height, t.height = -t.height);
		var i = e.x + e.width, a = e.y + e.height, o = Zj(t.x, e.x), s = Qj(t.x + t.width, i), c = Zj(t.y, e.y), l = Qj(t.y + t.height, a), u = s < o, d = l < c;
		return t.x = u && o > i ? s : o, t.y = d && c > a ? l : c, t.width = u ? 0 : s - o, t.height = d ? 0 : l - c, n < 0 && (t.x += t.width, t.width = -t.width), r < 0 && (t.y += t.height, t.height = -t.height), u || d;
	},
	polar: function(e, t) {
		var n = t.r0 <= t.r ? 1 : -1;
		if (n < 0) {
			var r = t.r;
			t.r = t.r0, t.r0 = r;
		}
		var i = Qj(t.r, e.r), a = Zj(t.r0, e.r0);
		t.r = i, t.r0 = a;
		var o = i - a < 0;
		if (n < 0) {
			var r = t.r;
			t.r = t.r0, t.r0 = r;
		}
		return o;
	}
}, tM = {
	cartesian2d: function(e, t, n, r, i, a, o, s, c) {
		var l = new bu({
			shape: M({}, r),
			z2: 1
		});
		if (l.__dataIndex = n, l.name = "item", a) {
			var u = l.shape, d = i ? "height" : "width";
			u[d] = 0;
		}
		return l;
	},
	polar: function(e, t, n, r, i, a, o, s, c) {
		var l = !i && c ? Gj : qf, u = new l({
			shape: r,
			z2: 1
		});
		if (u.name = "item", u.calculateTextPosition = Kj(uM(i), { isRoundCap: l === Gj }), a) {
			var d = u.shape, f = i ? "r" : "endAngle", p = {};
			d[f] = i ? r.r0 : r.startAngle, p[f] = r[f], (s ? kp : Ap)(u, { shape: p }, a);
		}
		return u;
	}
};
function nM(e, t) {
	var n = e.get("realtimeSort", !0), r = t.getBaseAxis();
	if (n && r.type === "category" && t.type === "cartesian2d") return {
		baseAxis: r,
		otherAxis: t.getOtherAxis(r)
	};
}
function rM(e, t, n, r, i, a, o, s) {
	var c, l;
	a ? (l = {
		x: r.x,
		width: r.width
	}, c = {
		y: r.y,
		height: r.height
	}) : (l = {
		y: r.y,
		height: r.height
	}, c = {
		x: r.x,
		width: r.width
	}), s || (o ? kp : Ap)(n, { shape: c }, t, i, null);
	var u = t ? e.baseAxis.model : null;
	(o ? kp : Ap)(n, { shape: l }, u, i);
}
function iM(e, t) {
	for (var n = 0; n < t.length; n++) if (!isFinite(e[t[n]])) return !0;
	return !1;
}
var aM = [
	"x",
	"y",
	"width",
	"height"
], oM = [
	"cx",
	"cy",
	"r",
	"startAngle",
	"endAngle"
], sM = {
	cartesian2d: function(e) {
		return !iM(e, aM);
	},
	polar: function(e) {
		return !iM(e, oM);
	}
}, cM = {
	cartesian2d: function(e, t, n) {
		var r = e.getItemLayout(t);
		if (!r) return null;
		var i = n ? fM(n, r) : 0, a = r.width > 0 ? 1 : -1, o = r.height > 0 ? 1 : -1;
		return {
			x: r.x + a * i / 2,
			y: r.y + o * i / 2,
			width: r.width - a * i,
			height: r.height - o * i
		};
	},
	polar: function(e, t, n) {
		var r = e.getItemLayout(t);
		return {
			cx: r.cx,
			cy: r.cy,
			r0: r.r0,
			r: r.r,
			startAngle: r.startAngle,
			endAngle: r.endAngle,
			clockwise: r.clockwise
		};
	}
};
function lM(e) {
	return e.startAngle != null && e.endAngle != null && e.startAngle === e.endAngle;
}
function uM(e) {
	return function(e) {
		var t = e ? "Arc" : "Angle";
		return function(e) {
			switch (e) {
				case "start":
				case "insideStart":
				case "end":
				case "insideEnd": return e + t;
				default: return e;
			}
		};
	}(e);
}
function dM(e, t, n, r, i, a, o, s) {
	var c = t.getItemVisual(n, "style");
	if (!s) {
		var l = r.get(["itemStyle", "borderRadius"]) || 0;
		e.setShape("r", l);
	} else if (!a.get("roundCap")) {
		var u = e.shape;
		M(u, Xj(r.getModel("itemStyle"), u, !0)), e.setShape(u);
	}
	e.useStyle(c);
	var d = r.getShallow("cursor");
	d && e.attr("cursor", d);
	var f = s ? o ? i.r >= i.r0 ? "endArc" : "startArc" : i.endAngle >= i.startAngle ? "endAngle" : "startAngle" : o ? bM(i, a.coordinateSystem) : xM(i, a.coordinateSystem), p = Pm(r);
	Nm(e, p, {
		labelFetcher: a,
		labelDataIndex: n,
		defaultText: Ek(a.getData(), n),
		inheritColor: c.fill,
		defaultOpacity: c.opacity,
		defaultOutsidePosition: f
	});
	var m = e.getTextContent();
	if (s && m) {
		var h = r.get(["label", "position"]);
		e.textConfig.inside = h === "middle" || null, qj(e, h === "outside" ? f : h, uM(o), r.get(["label", "rotate"]));
	}
	Gm(m, p, a.getRawValue(n), function(e) {
		return Dk(t, e);
	});
	var g = r.getModel(["emphasis"]);
	qd(e, g.get("focus"), g.get("blurScope"), g.get("disabled")), Zd(e, r), lM(i) && (e.style.fill = "none", e.style.stroke = "none", I(e.states, function(e) {
		e.style && (e.style.fill = e.style.stroke = "none");
	}));
}
function fM(e, t) {
	var n = e.get(["itemStyle", "borderColor"]);
	if (!n || n === "none") return 0;
	var r = e.get(["itemStyle", "borderWidth"]) || 0, i = isNaN(t.width) ? Number.MAX_VALUE : Math.abs(t.width), a = isNaN(t.height) ? Number.MAX_VALUE : Math.abs(t.height);
	return Math.min(r, i, a);
}
var pM = function() {
	function e() {}
	return e;
}(), mM = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this, t) || this;
		return n.type = "largeBar", n;
	}
	return t.prototype.getDefaultShape = function() {
		return new pM();
	}, t.prototype.buildPath = function(e, t) {
		for (var n = t.points, r = this.baseDimIdx, i = 1 - this.baseDimIdx, a = [], o = [], s = this.barWidth, c = 0; c < n.length; c += 3) o[r] = s, o[i] = n[c + 2], a[r] = n[c + r], a[i] = n[c + i], e.rect(a[0], a[1], o[0], o[1]);
	}, t;
}(ou);
function hM(e, t, n, r) {
	var i = e.getData(), a = +!!i.getLayout("valueAxisHorizontal"), o = i.getLayout("largeDataIndices"), s = i.getLayout("size"), c = e.getModel("backgroundStyle"), l = i.getLayout("largeBackgroundPoints"), u = r ? $s(e) : 0;
	if (l) {
		var d = new mM({
			shape: { points: l },
			incremental: u,
			silent: !0,
			z2: 0
		});
		d.baseDimIdx = a, d.largeDataIndices = o, d.barWidth = s, d.useStyle(c.getItemStyle()), t.add(d), n && n.push(d);
	}
	var f = new mM({
		shape: { points: i.getLayout("largePoints") },
		incremental: u,
		ignoreCoarsePointer: !0,
		z2: 1
	});
	f.baseDimIdx = a, f.largeDataIndices = o, f.barWidth = s, t.add(f), f.useStyle(i.getVisual("style")), f.style.stroke = null, Z(f).seriesIndex = e.seriesIndex, e.get("silent") || (f.on("mousedown", gM), f.on("mousemove", gM)), n && n.push(f);
}
var gM = gb(function(e) {
	var t = this, n = _M(t, e.offsetX, e.offsetY);
	Z(t).dataIndex = n >= 0 ? n : null;
}, 30, !1);
function _M(e, t, n) {
	for (var r = e.baseDimIdx, i = 1 - r, a = e.shape.points, o = e.largeDataIndices, s = [], c = [], l = e.barWidth, u = 0, d = a.length / 3; u < d; u++) {
		var f = u * 3;
		if (c[r] = l, c[i] = a[f + 2], s[r] = a[f + r], s[i] = a[f + i], c[i] < 0 && (s[i] += c[i], c[i] = -c[i]), t >= s[0] && t <= s[0] + c[0] && n >= s[1] && n <= s[1] + c[1]) return o[u];
	}
	return -1;
}
function vM(e, t, n) {
	if (rA(n, "cartesian2d")) {
		var r = t, i = n.getArea();
		return {
			x: e ? r.x : i.x,
			y: e ? i.y : r.y,
			width: e ? r.width : i.width,
			height: e ? i.height : r.height
		};
	}
	var i = n.getArea(), a = t;
	return {
		cx: i.cx,
		cy: i.cy,
		r0: e ? i.r0 : a.r0,
		r: e ? i.r : a.r,
		startAngle: e ? a.startAngle : 0,
		endAngle: e ? a.endAngle : Math.PI * 2
	};
}
function yM(e, t, n) {
	return new (e.type === "polar" ? qf : bu)({
		shape: vM(t, n, e),
		silent: !0,
		z2: 0
	});
}
function bM(e, t) {
	return e.height === 0 ? t.getOtherAxis(t.getBaseAxis()).inverse ? "bottom" : "top" : e.height > 0 ? "bottom" : "top";
}
function xM(e, t) {
	return e.width === 0 ? t.getOtherAxis(t.getBaseAxis()).inverse ? "left" : "right" : e.width >= 0 ? "right" : "left";
}
//#endregion
//#region node_modules/echarts/lib/chart/bar/install.js
function SM(e) {
	e.registerChartView($j), e.registerSeriesModel(Uj), e.registerLayout(e.PRIORITY.VISUAL.LAYOUT, Lj("bar")), e.registerLayout(e.PRIORITY.VISUAL.PROGRESSIVE_LAYOUT, Rj("bar")), e.registerProcessor(e.PRIORITY.PROCESSOR.STATISTIC, OA("bar")), e.registerAction({
		type: "changeAxisOrder",
		event: "changeAxisOrder",
		update: "update"
	}, function(e, t) {
		var n = e.componentType || "series";
		t.eachComponent({
			mainType: n,
			query: e
		}, function(t) {
			e.sortInfo && t.axis.setCategorySortInfo(e.sortInfo);
		});
	}), Vj(e);
}
//#endregion
//#region node_modules/echarts/lib/processor/dataFilter.js
function CM(e) {
	return {
		seriesType: e,
		reset: function(e, t) {
			var n = t.findComponents({ mainType: "legend" });
			if (n && n.length) {
				var r = e.getData();
				r.filterSelf(function(e) {
					for (var t = r.getName(e), i = 0; i < n.length; i++) if (!n[i].isSelected(t)) return !1;
					return !0;
				});
			}
		}
	};
}
//#endregion
//#region node_modules/echarts/lib/chart/helper/createSeriesDataSimply.js
function wM(e, t, n) {
	t = V(t) && { coordDimensions: t } || M({ encodeDefine: e.getEncode() }, t);
	var r = e.getSource(), i = Kw(r, t).dimensions, a = new Ww(i, e);
	return a.initData(r, n), a;
}
//#endregion
//#region node_modules/echarts/lib/visual/LegendVisualProvider.js
var TM = function() {
	function e(e, t) {
		this._getDataWithEncodedVisual = e, this._getRawData = t;
	}
	return e.prototype.getAllNames = function() {
		var e = this._getRawData();
		return e.mapArray(e.getName);
	}, e.prototype.containName = function(e) {
		return this._getRawData().indexOfName(e) >= 0;
	}, e.prototype.indexOfName = function(e) {
		return this._getDataWithEncodedVisual().indexOfName(e);
	}, e.prototype.getItemVisual = function(e, t) {
		return this._getDataWithEncodedVisual().getItemVisual(e, t);
	}, e;
}(), EM = X(), DM = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.init = function(t) {
		e.prototype.init.apply(this, arguments), this.legendVisualProvider = new TM(z(this.getData, this), z(this.getRawData, this)), this._defaultLabelLine(t);
	}, t.prototype.mergeOption = function() {
		e.prototype.mergeOption.apply(this, arguments);
	}, t.prototype.getInitialData = function() {
		return wM(this, {
			coordDimensions: ["value"],
			encodeDefaulter: B(c_, this)
		});
	}, t.prototype.getDataParams = function(t) {
		var n = this.getData(), r = EM(n), i = r.seats;
		if (!i) {
			var a = [];
			n.each(n.mapDimension("value"), function(e) {
				a.push(e);
			}), i = r.seats = Po(a, n.hostModel.get("percentPrecision"));
		}
		var o = e.prototype.getDataParams.call(this, t);
		return o.percent = i[t] || 0, o.$vars.push("percent"), o;
	}, t.prototype._defaultLabelLine = function(e) {
		cs(e, "labelLine", ["show"]);
		var t = e.labelLine, n = e.emphasis.labelLine;
		t.show = t.show && e.label.show, n.show = n.show && e.emphasis.label.show;
	}, t.type = "series.pie", t.defaultOption = {
		z: 2,
		legendHoverLink: !0,
		colorBy: "data",
		center: ["50%", "50%"],
		radius: [0, "50%"],
		clockwise: !0,
		startAngle: 90,
		endAngle: "auto",
		padAngle: 0,
		minAngle: 0,
		minShowLabelAngle: 0,
		selectedOffset: 10,
		percentPrecision: 2,
		stillShowZeroSum: !0,
		coordinateSystemUsage: "box",
		left: 0,
		top: 0,
		right: 0,
		bottom: 0,
		width: null,
		height: null,
		label: {
			rotate: 0,
			show: !0,
			overflow: "truncate",
			position: "outer",
			alignTo: "none",
			edgeDistance: "25%",
			distanceToLabelLine: 5
		},
		labelLine: {
			show: !0,
			length: 15,
			length2: 30,
			smooth: !1,
			minTurnAngle: 90,
			maxSurfaceAngle: 90,
			lineStyle: {
				width: 1,
				type: "solid"
			}
		},
		itemStyle: {
			borderWidth: 1,
			borderJoin: "round"
		},
		showEmptyCircle: !0,
		emptyCircleStyle: {
			color: "lightgray",
			opacity: 1
		},
		labelLayout: { hideOverlap: !0 },
		emphasis: {
			scale: !0,
			scaleSize: 5
		},
		avoidLabelOverlap: !0,
		animationType: "expansion",
		animationDuration: 1e3,
		animationTypeUpdate: "transition",
		animationEasingUpdate: "cubicInOut",
		animationDurationUpdate: 500,
		animationEasing: "cubicInOut"
	}, t;
}(Jy);
Eg({
	fullType: DM.type,
	getCoord2: function(e) {
		return e.getShallow("center");
	}
});
//#endregion
//#region node_modules/echarts/lib/chart/pie/labelLayout.js
var OM = Math.PI / 180;
function kM(e, t, n, r, i, a, o, s, c, l) {
	if (e.length < 2) return;
	function u(e) {
		for (var a = e.rB, o = a * a, s = 0; s < e.list.length; s++) {
			var c = e.list[s], l = Math.abs(c.label.y - n), u = r + c.len, d = u * u, f = t + (Math.sqrt(Math.abs((1 - l * l / o) * d)) + c.len2) * i, p = f - c.label.x;
			jM(c, c.targetTextWidth - p * i, !0), c.label.x = f;
		}
	}
	function d(e) {
		for (var a = {
			list: [],
			maxY: 0
		}, o = {
			list: [],
			maxY: 0
		}, s = 0; s < e.length; s++) if (e[s].labelAlignTo === "none") {
			var c = e[s], l = c.label.y > n ? o : a, d = Math.abs(c.label.y - n);
			if (d >= l.maxY) {
				var f = c.label.x - t - c.len2 * i, p = r + c.len;
				l.rB = Math.abs(f) < p ? Math.sqrt(d * d / (1 - f * f / p / p)) : p, l.maxY = d;
			}
			l.list.push(c);
		}
		u(a), u(o);
	}
	for (var f = e.length, p = 0; p < f; p++) if (e[p].position === "outer" && e[p].labelAlignTo === "labelLine") {
		var m = e[p].label.x - l;
		e[p].linePoints[1][0] += m, e[p].label.x = l;
	}
	lk(e, 1, c, c + o) && d(e);
}
function AM(e, t, n, r, i, a, o, s) {
	for (var c = [], l = [], u = Number.MAX_VALUE, d = -Number.MAX_VALUE, f = 0; f < e.length; f++) {
		var p = e[f].label;
		FM(e[f]) || (p.x < t ? (u = Math.min(u, p.x), c.push(e[f])) : (d = Math.max(d, p.x), l.push(e[f])));
	}
	for (var f = 0; f < e.length; f++) {
		var m = e[f];
		if (!FM(m) && m.linePoints) {
			if (m.labelStyleWidth != null) continue;
			var p = m.label, h = m.linePoints, g = void 0;
			g = m.labelAlignTo === "edge" ? p.x < t ? h[2][0] - m.labelDistance - o - m.edgeDistance : o + i - m.edgeDistance - h[2][0] - m.labelDistance : m.labelAlignTo === "labelLine" ? p.x < t ? u - o - m.bleedMargin : o + i - d - m.bleedMargin : p.x < t ? p.x - o - m.bleedMargin : o + i - p.x - m.bleedMargin, m.targetTextWidth = g, jM(m, g, !1);
		}
	}
	kM(l, t, n, r, 1, i, a, o, s, d), kM(c, t, n, r, -1, i, a, o, s, u);
	for (var f = 0; f < e.length; f++) {
		var m = e[f];
		if (!FM(m) && m.linePoints) {
			var p = m.label, h = m.linePoints, _ = m.labelAlignTo === "edge", v = p.style.padding, y = v ? v[1] + v[3] : 0, b = p.style.backgroundColor ? 0 : y, x = m.rect.width + b, S = h[1][0] - h[2][0];
			_ ? p.x < t ? h[2][0] = o + m.edgeDistance + x + m.labelDistance : h[2][0] = o + i - m.edgeDistance - x - m.labelDistance : (p.x < t ? h[2][0] = p.x + m.labelDistance : h[2][0] = p.x - m.labelDistance, h[1][0] = h[2][0] + S), h[1][1] = h[2][1] = p.y;
		}
	}
}
function jM(e, t, n) {
	if (e.labelStyleWidth == null) {
		var r = e.label, i = r.style, a = e.rect, o = i.backgroundColor, s = i.padding, c = s ? s[1] + s[3] : 0, l = i.overflow, u = a.width + (o ? 0 : c);
		if (t < u || n) {
			if (l && l.match("break")) {
				r.setStyle("backgroundColor", null), r.setStyle("width", t - c);
				var d = r.getBoundingRect();
				r.setStyle("width", Math.ceil(d.width)), r.setStyle("backgroundColor", o);
			} else {
				var f = t - c, p = t < u ? f : n ? f > e.unconstrainedWidth ? null : f : null;
				r.setStyle("width", p);
			}
			MM(a, r);
		}
	}
}
function MM(e, t) {
	PM.rect = e, rk(PM, t, NM);
}
var NM = {
	minMarginForce: [
		null,
		0,
		null,
		0
	],
	marginDefault: [
		1,
		0,
		1,
		0
	]
}, PM = {};
function FM(e) {
	return e.position === "center";
}
function IM(e) {
	var t = e.getData(), n = [], r, i, a = !1, o = (e.get("minShowLabelAngle") || 0) * OM, s = t.getLayout("viewRect"), c = t.getLayout("r"), l = s.width, u = s.x, d = s.y, f = s.height;
	function p(e) {
		e.ignore = !0;
	}
	function m(e) {
		if (!e.ignore) return !0;
		for (var t in e.states) if (e.states[t].ignore === !1) return !0;
		return !1;
	}
	t.each(function(e) {
		var s = t.getItemGraphicEl(e), d = s.shape, h = s.getTextContent(), g = s.getTextGuideLine(), _ = t.getItemModel(e), v = _.getModel("label"), y = v.get("position") || _.get([
			"emphasis",
			"label",
			"position"
		]), b = v.get("distanceToLabelLine"), x = v.get("alignTo"), S = So(v.get("edgeDistance"), l), C = v.get("bleedMargin");
		C ??= Math.min(l, f) > 200 ? 10 : 2;
		var w = _.getModel("labelLine"), T = w.get("length");
		T = So(T, l);
		var E = w.get("length2");
		if (E = So(E, l), Math.abs(d.endAngle - d.startAngle) < o) I(h.states, p), h.ignore = !0, g && (I(g.states, p), g.ignore = !0);
		else if (m(h)) {
			var D = (d.startAngle + d.endAngle) / 2, O = Math.cos(D), k = Math.sin(D), A, j, ee, M;
			r = d.cx, i = d.cy;
			var te = y === "inside" || y === "inner";
			if (y === "center") A = d.cx, j = d.cy, M = "center";
			else {
				var N = (te ? (d.r + d.r0) / 2 * O : d.r * O) + r, ne = (te ? (d.r + d.r0) / 2 * k : d.r * k) + i;
				if (A = N + O * 3, j = ne + k * 3, !te) {
					var P = N + O * (T + c - d.r), re = ne + k * (T + c - d.r), F = P + (O < 0 ? -1 : 1) * E, ie = re;
					A = x === "edge" ? O < 0 ? u + S : u + l - S : F + (O < 0 ? -b : b), j = ie, ee = [
						[N, ne],
						[P, re],
						[F, ie]
					];
				}
				M = te ? "center" : x === "edge" ? O > 0 ? "right" : "left" : O > 0 ? "left" : "right";
			}
			var L = Math.PI, ae = 0, oe = v.get("rotate");
			if (ue(oe)) ae = L / 180 * oe;
			else if (y === "center") ae = 0;
			else if (oe === "radial" || oe === !0) ae = O < 0 ? -D + L : -D;
			else if (oe === "tangential" || oe === "tangential-noflip" && y !== "outside" && y !== "outer") {
				var se = Math.atan2(O, k);
				se < 0 && (se = L * 2 + se), k > 0 && oe !== "tangential-noflip" && (se = L + se), ae = se - L;
			}
			if (a = !!ae, h.x = A, h.y = j, h.rotation = ae, h.setStyle({ verticalAlign: "middle" }), te) {
				h.setStyle({ align: M });
				var R = h.states.select;
				R && (R.x += h.x, R.y += h.y);
			} else {
				var ce = new Y(0, 0, 0, 0);
				MM(ce, h), n.push({
					label: h,
					labelLine: g,
					position: y,
					len: T,
					len2: E,
					minTurnAngle: w.get("minTurnAngle"),
					maxSurfaceAngle: w.get("maxSurfaceAngle"),
					surfaceNormal: new J(O, k),
					linePoints: ee,
					textAlign: M,
					labelDistance: b,
					labelAlignTo: x,
					edgeDistance: S,
					bleedMargin: C,
					rect: ce,
					unconstrainedWidth: ce.width,
					labelStyleWidth: h.style.width
				});
			}
			s.setTextConfig({ inside: te });
		}
	}), !a && e.get("avoidLabelOverlap") && AM(n, r, i, c, l, f, u, d);
	for (var h = 0; h < n.length; h++) {
		var g = n[h], _ = g.label, v = g.labelLine, y = isNaN(_.x) || isNaN(_.y);
		if (_) {
			_.setStyle({ align: g.textAlign }), y && (I(_.states, p), _.ignore = !0);
			var b = _.states.select;
			b && (b.x += _.x, b.y += _.y);
		}
		if (v) {
			var x = g.linePoints;
			y || !x ? (I(v.states, p), v.ignore = !0) : (WO(x, g.minTurnAngle), GO(x, g.surfaceNormal, g.maxSurfaceAngle), v.setShape({ points: x }), _.__hostTarget.textGuideLineConfig = { anchor: new J(x[0][0], x[0][1]) });
		}
	}
}
//#endregion
//#region node_modules/echarts/lib/chart/pie/pieLayout.js
var LM = Math.PI * 2, RM = Math.PI / 180, zM = tc("pie", BM);
function BM(e, t) {
	e.eachSeriesByType("pie", function(e) {
		var n = e.getData(), r = n.mapDimension("value"), i = Rg(e, t), a = i.cx, o = i.cy, s = i.r, c = i.r0, l = i.viewRect, u = -e.get("startAngle") * RM, d = e.get("endAngle"), f = e.get("padAngle") * RM;
		d = d === "auto" ? u - LM : -d * RM;
		var p = e.get("minAngle") * RM + f, m = 0;
		n.each(r, function(e) {
			!isNaN(e) && m++;
		});
		var h = n.getSum(r), g = Math.PI / (h || m) * 2, _ = e.get("clockwise"), v = e.get("roseType"), y = e.get("stillShowZeroSum"), b = n.getDataExtent(r);
		b[0] = 0;
		var x = _ ? 1 : -1, S = [u, d], C = x * f / 2;
		Pl(S, !_), u = S[0], d = S[1];
		var w = VM(e);
		w.startAngle = u, w.endAngle = d, w.clockwise = _, w.cx = a, w.cy = o, w.r = s, w.r0 = c;
		var T = Math.abs(d - u), E = T, D = 0, O = u;
		if (n.setLayout({
			viewRect: l,
			r: s
		}), n.each(r, function(e, t) {
			var r;
			if (isNaN(e)) n.setItemLayout(t, {
				angle: NaN,
				startAngle: NaN,
				endAngle: NaN,
				clockwise: _,
				cx: a,
				cy: o,
				r0: c,
				r: v ? NaN : s
			});
			else {
				r = v === "area" ? T / m : h === 0 && y ? g : e * g, r < p ? (r = p, E -= p) : D += e;
				var i = O + x * r, l = 0, u = 0;
				f > r ? (l = O + x * r / 2, u = l) : (l = O + C, u = i - C), n.setItemLayout(t, {
					angle: r,
					startAngle: l,
					endAngle: u,
					clockwise: _,
					cx: a,
					cy: o,
					r0: c,
					r: v ? xo(e, b, [c, s]) : s
				}), O = i;
			}
		}), E < LM && m) {
			if (E <= .001) {
				var k = T / m;
				n.each(r, function(e, t) {
					if (!isNaN(e)) {
						var r = n.getItemLayout(t);
						r.angle = k;
						var i = 0, a = 0;
						k < f ? (i = u + x * (t + 1 / 2) * k, a = i) : (i = u + x * t * k + C, a = u + x * (t + 1) * k - C), r.startAngle = i, r.endAngle = a;
					}
				});
			} else g = E / D, O = u, n.each(r, function(e, t) {
				if (!isNaN(e)) {
					var r = n.getItemLayout(t), i = r.angle === p ? p : e * g, a = 0, o = 0;
					i < f ? (a = O + x * i / 2, o = a) : (a = O + C, o = O + x * i - C), r.startAngle = a, r.endAngle = o, O += x * i;
				}
			});
		}
	});
}
var VM = X(), HM = function(e) {
	n(t, e);
	function t(t, n, r) {
		var i = e.call(this) || this;
		i.z2 = 2;
		var a = new Tu();
		return i.setTextContent(a), i.updateData(t, n, r, !0), i;
	}
	return t.prototype.updateData = function(e, t, n, r) {
		var i = this, a = e.hostModel, o = e.getItemModel(t), s = o.getModel("emphasis"), c = e.getItemLayout(t), l = M(Xj(o.getModel("itemStyle"), c, !0), c);
		if (isNaN(l.startAngle)) i.setShape(l);
		else {
			if (r) {
				i.setShape(l);
				var u = a.getShallow("animationType");
				a.ecModel.ssr ? (Ap(i, {
					scaleX: 0,
					scaleY: 0
				}, a, {
					dataIndex: t,
					isFrom: !0
				}), i.originX = l.cx, i.originY = l.cy) : u === "scale" ? (i.shape.r = c.r0, Ap(i, { shape: { r: c.r } }, a, t)) : n == null ? (i.shape.endAngle = c.startAngle, kp(i, { shape: { endAngle: c.endAngle } }, a, t)) : (i.setShape({
					startAngle: n,
					endAngle: n
				}), Ap(i, { shape: {
					startAngle: c.startAngle,
					endAngle: c.endAngle
				} }, a, t));
			} else Fp(i), kp(i, { shape: l }, a, t);
			i.useStyle(e.getItemVisual(t, "style")), Zd(i, o);
			var d = (c.startAngle + c.endAngle) / 2, f = a.get("selectedOffset"), p = Math.cos(d) * f, m = Math.sin(d) * f, h = o.getShallow("cursor");
			h && i.attr("cursor", h), this._updateLabel(a, e, t), i.ensureState("emphasis").shape = M({ r: c.r + (s.get("scale") && s.get("scaleSize") || 0) }, Xj(s.getModel("itemStyle"), c)), M(i.ensureState("select"), {
				x: p,
				y: m,
				shape: Xj(o.getModel(["select", "itemStyle"]), c)
			}), M(i.ensureState("blur"), { shape: Xj(o.getModel(["blur", "itemStyle"]), c) });
			var g = i.getTextGuideLine(), _ = i.getTextContent();
			g && M(g.ensureState("select"), {
				x: p,
				y: m
			}), M(_.ensureState("select"), {
				x: p,
				y: m
			}), qd(this, s.get("focus"), s.get("blurScope"), s.get("disabled"));
		}
	}, t.prototype._updateLabel = function(e, t, n) {
		var r = this, i = t.getItemModel(n), a = i.getModel("labelLine"), o = t.getItemVisual(n, "style"), s = o && o.fill, c = o && o.opacity;
		Nm(r, Pm(i), {
			labelFetcher: t.hostModel,
			labelDataIndex: n,
			inheritColor: s,
			defaultOpacity: c,
			defaultText: e.getFormattedLabel(n, "normal") || t.getName(n)
		});
		var l = r.getTextContent();
		r.setTextConfig({
			position: null,
			rotation: null
		}), l.attr({ z2: 10 });
		var u = i.get(["label", "position"]);
		if (u !== "outside" && u !== "outer") r.removeTextGuideLine();
		else {
			var d = this.getTextGuideLine();
			d || (d = new tp(), this.setTextGuideLine(d)), JO(this, YO(i), {
				stroke: s,
				opacity: ye(a.get(["lineStyle", "opacity"]), c, 1)
			});
		}
	}, t;
}(qf), UM = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t.type = "pie", t.ignoreLabelLineUpdate = !0, t;
	}
	return t.prototype.render = function(e, t, n, r) {
		var i = e.getData(), a = this._data, o = this.group, s;
		if (!a && i.count() > 0) {
			for (var c = i.getItemLayout(0), l = 1; isNaN(c && c.startAngle) && l < i.count(); ++l) c = i.getItemLayout(l);
			c && (s = c.startAngle);
		}
		if (this._emptyCircleSector && o.remove(this._emptyCircleSector), i.count() === 0 && e.get("showEmptyCircle")) {
			var u = new qf({ shape: A(VM(e)) });
			u.useStyle(e.getModel("emptyCircleStyle").getItemStyle()), this._emptyCircleSector = u, o.add(u);
		}
		i.diff(a).add(function(e) {
			var t = new HM(i, e, s);
			i.setItemGraphicEl(e, t), o.add(t);
		}).update(function(e, t) {
			var n = a.getItemGraphicEl(t);
			n.updateData(i, e, s), n.off("click"), o.add(n), i.setItemGraphicEl(e, n);
		}).remove(function(t) {
			Pp(a.getItemGraphicEl(t), e, t);
		}).execute(), IM(e), e.get("animationTypeUpdate") !== "expansion" && (this._data = i);
	}, t.prototype.dispose = function() {}, t.prototype.containPoint = function(e, t) {
		var n = t.getData().getItemLayout(0);
		if (n) {
			var r = e[0] - n.cx, i = e[1] - n.cy, a = Math.sqrt(r * r + i * i);
			return a <= n.r && a >= n.r0;
		}
	}, t.type = "pie", t;
}(sb);
//#endregion
//#region node_modules/echarts/lib/processor/negativeDataFilter.js
function WM(e) {
	return {
		seriesType: e,
		reset: function(e, t) {
			var n = e.getData();
			n.filterSelf(function(e) {
				var t = n.mapDimension("value"), r = n.get(t, e);
				return !(ue(r) && !isNaN(r) && r < 0);
			});
		}
	};
}
//#endregion
//#region node_modules/echarts/lib/chart/pie/install.js
function GM(e) {
	e.registerChartView(UM), e.registerSeriesModel(DM), rx("pie", e.registerAction), e.registerLayout(zM), e.registerProcessor(CM("pie")), e.registerProcessor(WM("pie"));
}
//#endregion
//#region node_modules/echarts/lib/chart/scatter/ScatterSeries.js
var KM = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.hasSymbolVisual = !0, n;
	}
	return t.prototype.getInitialData = function(e, t) {
		return aT(null, this, { useEncodeDefaulter: !0 });
	}, t.prototype.getProgressive = function() {
		return this.option.progressive ?? (this.option.large ? 5e3 : this.get("progressive"));
	}, t.prototype.getProgressiveThreshold = function() {
		return this.option.progressiveThreshold ?? (this.option.large ? 1e4 : this.get("progressiveThreshold"));
	}, t.prototype.brushSelector = function(e, t, n) {
		return n.point(t.getItemLayout(e));
	}, t.prototype.getZLevelKey = function() {
		return this.getData().count() > this.getProgressiveThreshold() ? this.id : "";
	}, t.type = "series.scatter", t.dependencies = [
		"grid",
		"polar",
		"geo",
		"singleAxis",
		"calendar",
		"matrix"
	], t.defaultOption = {
		coordinateSystem: "cartesian2d",
		z: 2,
		legendHoverLink: !0,
		symbolSize: 10,
		large: !1,
		largeThreshold: 2e3,
		itemStyle: { opacity: .8 },
		emphasis: { scale: !0 },
		clip: !0,
		select: { itemStyle: { borderColor: Q.color.primary } },
		universalTransition: { divideShape: "clone" }
	}, t;
}(Jy), qM = 4, JM = function() {
	function e() {}
	return e;
}(), YM = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this, t) || this;
		return n._off = 0, n.hoverDataIdx = -1, n;
	}
	return t.prototype.getDefaultShape = function() {
		return new JM();
	}, t.prototype.reset = function() {
		this.notClear = !1, this._off = 0;
	}, t.prototype.beforeBrush = function(e) {
		e && !e.contentRetained && this.reset();
	}, t.prototype.buildPath = function(e, t) {
		var n = t.points, r = t.size, i = this.symbolProxy, a = i.shape, o = e.getContext ? e.getContext() : e, s = o && r[0] < qM, c = this.softClipShape, l;
		if (s) this._ctx = o;
		else {
			for (this._ctx = null, l = this._off; l < n.length;) {
				var u = n[l++], d = n[l++];
				isNaN(u) || isNaN(d) || (!c || c.contain(u, d)) && (a.x = u - r[0] / 2, a.y = d - r[1] / 2, a.width = r[0], a.height = r[1], i.buildPath(e, a, !0));
			}
			this.incremental && (this._off = l, this.notClear = !0);
		}
	}, t.prototype.afterBrush = function() {
		var e = this.shape, t = e.points, n = e.size, r = this._ctx, i = this.softClipShape, a;
		if (r) {
			for (a = this._off; a < t.length;) {
				var o = t[a++], s = t[a++];
				isNaN(o) || isNaN(s) || (!i || i.contain(o, s)) && r.fillRect(o - n[0] / 2, s - n[1] / 2, n[0], n[1]);
			}
			this.incremental && (this._off = a, this.notClear = !0);
		}
	}, t.prototype.findDataIndex = function(e, t) {
		for (var n = this.shape, r = n.points, i = n.size, a = Math.max(i[0], 4), o = Math.max(i[1], 4), s = r.length / 2 - 1; s >= 0; s--) {
			var c = s * 2, l = r[c] - a / 2, u = r[c + 1] - o / 2;
			if (e >= l && t >= u && e <= l + a && t <= u + o) return s;
		}
		return -1;
	}, t.prototype.contain = function(e, t) {
		var n = this.transformCoordToLocal(e, t), r = this.getBoundingRect();
		return e = n[0], t = n[1], r.contain(e, t) ? (this.hoverDataIdx = this.findDataIndex(e, t)) >= 0 : (this.hoverDataIdx = -1, !1);
	}, t.prototype.getBoundingRect = function() {
		var e = this._rect;
		if (!e) {
			for (var t = this.shape, n = t.points, r = t.size, i = r[0], a = r[1], o = Infinity, s = Infinity, c = -Infinity, l = -Infinity, u = 0; u < n.length;) {
				var d = n[u++], f = n[u++];
				o = Math.min(d, o), c = Math.max(d, c), s = Math.min(f, s), l = Math.max(f, l);
			}
			e = this._rect = new Y(o - i / 2, s - a / 2, c - o + i, l - s + a);
		}
		return e;
	}, t;
}(ou), XM = function() {
	function e() {
		this.group = new Wa();
	}
	return e.prototype.updateData = function(e, t) {
		this._clear(), this._data = e;
		var n = this._create();
		n.setShape({ points: e.getLayout("points") }), this._setCommon(n, e, t);
	}, e.prototype.updateLayout = function(e) {
		var t = this._data;
		if (t) {
			var n = t.getLayout("points");
			this.group.eachChild(function(e) {
				if (e.startIndex != null) {
					var t = (e.endIndex - e.startIndex) * 2, r = e.startIndex * 4 * 2;
					n = new Float32Array(n.buffer, r, t);
				}
				e.setShape("points", n), e.reset(), e.stopAnimation();
			});
		}
	}, e.prototype.incrementalPrepareUpdate = function(e) {
		this._clear();
	}, e.prototype.incrementalUpdate = function(e, t, n, r) {
		var i = this._newAdded[0], a = t.getLayout("points"), o = i && i.shape.points;
		if (o && o.length < 2e4) {
			var s = o.length, c = new Float32Array(s + a.length);
			c.set(o), c.set(a, s), i.endIndex = e.end, i.setShape({ points: c });
		} else {
			this._newAdded = [];
			var l = this._create();
			l.startIndex = e.start, l.endIndex = e.end, l.incremental = n, l.setShape({ points: a }), this._setCommon(l, t, r);
		}
	}, e.prototype.eachRendered = function(e) {
		this._newAdded[0] && e(this._newAdded[0]);
	}, e.prototype._create = function() {
		var e = new YM({ cursor: "default" });
		return e.ignoreCoarsePointer = !0, this.group.add(e), this._newAdded.push(e), e;
	}, e.prototype._setCommon = function(e, t, n) {
		var r = t.hostModel;
		n ||= {};
		var i = t.getVisual("symbolSize");
		e.setShape("size", i instanceof Array ? i : [i, i]), e.softClipShape = n.clipShape || null, e.symbolProxy = Ox(t.getVisual("symbol"), 0, 0, 0, 0), e.setColor = e.symbolProxy.setColor;
		var a = e.shape.size[0] < qM;
		e.useStyle(r.getModel("itemStyle").getItemStyle(a ? [
			"color",
			"shadowBlur",
			"shadowColor"
		] : ["color"]));
		var o = t.getVisual("style"), s = o && o.fill;
		s && e.setColor(s);
		var c = Z(e);
		c.seriesIndex = r.seriesIndex, e.on("mousemove", function(t) {
			c.dataIndex = null;
			var n = e.hoverDataIdx;
			n >= 0 && (c.dataIndex = n + (e.startIndex || 0));
		});
	}, e.prototype.remove = function() {
		this._clear();
	}, e.prototype._clear = function() {
		this._newAdded = [], this.group.removeAll();
	}, e;
}(), ZM = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.render = function(e, t, n) {
		var r = e.getData();
		this._updateSymbolDraw(r, e).updateData(r, QM(e)), this._finished = !0;
	}, t.prototype.incrementalPrepareRender = function(e, t, n) {
		var r = e.getData();
		this._updateSymbolDraw(r, e).incrementalPrepareUpdate(r), this._finished = !1;
	}, t.prototype.incrementalRender = function(e, t, n) {
		this._symbolDraw.incrementalUpdate(e, t.getData(), $s(t), QM(t)), this._finished = e.end === t.getData().count();
	}, t.prototype.updateTransform = function(e, t, n) {
		var r = e.getData();
		if (this.group.dirty(), this._finished) {
			var i = TA("").reset(e, t, n);
			i.progress && i.progress({
				start: 0,
				end: r.count(),
				count: r.count()
			}, r), this._symbolDraw.updateLayout(QM(e));
		} else return { update: !0 };
	}, t.prototype.eachRendered = function(e) {
		this._symbolDraw && this._symbolDraw.eachRendered(e);
	}, t.prototype._updateSymbolDraw = function(e, t) {
		var n = this._symbolDraw, r = t.pipelineContext.large;
		return (!n || r !== this._isLargeDraw) && (n && n.remove(), n = this._symbolDraw = r ? new XM() : new Pk(), this._isLargeDraw = r, this.group.removeAll()), this.group.add(n.group), n;
	}, t.prototype.remove = function(e, t) {
		this._symbolDraw && this._symbolDraw.remove(!0), this._symbolDraw = null;
	}, t.prototype.dispose = function() {}, t.type = "scatter", t;
}(sb);
function QM(e) {
	return { clipShape: nA(e) };
}
//#endregion
//#region node_modules/echarts/lib/coord/cartesian/AxisModel.js
var $M = function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t.prototype.getCoordSysModel = function() {
		return this.getReferringComponents("grid", js).models[0];
	}, t.type = "cartesian2dAxis", t;
}(Jg);
F($M, wE);
//#endregion
//#region node_modules/echarts/lib/coord/axisDefault.js
var eN = {
	show: !0,
	z: 0,
	inverse: !1,
	name: "",
	nameLocation: "end",
	nameRotate: null,
	nameTruncate: {
		maxWidth: null,
		ellipsis: "...",
		placeholder: "."
	},
	nameTextStyle: {},
	nameGap: 15,
	silent: !1,
	triggerEvent: !1,
	tooltip: { show: !1 },
	axisPointer: {},
	axisLine: {
		show: !0,
		onZero: "auto",
		onZeroAxisIndex: null,
		lineStyle: {
			color: Q.color.axisLine,
			width: 1,
			type: "solid"
		},
		symbol: ["none", "none"],
		symbolSize: [10, 15],
		breakLine: !0
	},
	axisTick: {
		show: !0,
		inside: !1,
		length: 5,
		lineStyle: { width: 1 }
	},
	axisLabel: {
		show: !0,
		inside: !1,
		rotate: 0,
		showMinLabel: null,
		showMaxLabel: null,
		margin: 8,
		fontSize: 12,
		color: Q.color.axisLabel,
		textMargin: [0, 3]
	},
	splitLine: {
		show: !0,
		showMinLine: !0,
		showMaxLine: !0,
		lineStyle: {
			color: Q.color.axisSplitLine,
			width: 1,
			type: "solid"
		}
	},
	splitArea: {
		show: !1,
		areaStyle: { color: [Q.color.backgroundTint, Q.color.backgroundTransparent] }
	},
	breakArea: {
		show: !0,
		itemStyle: {
			color: Q.color.neutral00,
			borderColor: Q.color.border,
			borderWidth: 1,
			borderType: [3, 3],
			opacity: .6
		},
		zigzagAmplitude: 4,
		zigzagMinSpan: 4,
		zigzagMaxSpan: 20,
		zigzagZ: 100,
		expandOnClick: !0
	},
	breakLabelLayout: { moveOverlap: "auto" }
}, tN = j({
	boundaryGap: !0,
	deduplication: null,
	jitter: 0,
	jitterOverlap: !0,
	jitterMargin: 2,
	splitLine: { show: !1 },
	axisTick: {
		alignWithLabel: !1,
		interval: "auto",
		show: "auto"
	},
	axisLabel: { interval: "auto" }
}, eN), nN = j({
	boundaryGap: [0, 0],
	axisLine: { show: "auto" },
	axisTick: { show: "auto" },
	splitNumber: 5,
	minorTick: {
		show: !1,
		splitNumber: 5,
		length: 3,
		lineStyle: {}
	},
	minorSplitLine: {
		show: !1,
		lineStyle: {
			color: Q.color.axisMinorSplitLine,
			width: 1
		}
	}
}, eN), rN = {
	category: tN,
	value: nN,
	time: j({
		splitNumber: 6,
		axisLabel: { rich: { primary: { fontWeight: "bold" } } },
		splitLine: { show: !1 }
	}, nN),
	log: N({ logBase: 10 }, nN)
};
//#endregion
//#region node_modules/echarts/lib/coord/axisModelCreator.js
function iN(e, t, r, i) {
	I(aE, function(a, o) {
		var s = j(j({}, rN[o], !0), i, !0), c = function(e) {
			n(r, e);
			function r() {
				var n = e !== null && e.apply(this, arguments) || this;
				return n.type = t + "Axis." + o, n;
			}
			return r.prototype.mergeDefaultAndTheme = function(e, t) {
				var n = Ug(this), r = n ? Gg(e) : {};
				j(e, t.getTheme().get(o + "Axis")), j(e, this.getDefaultOption()), e.type = aN(e), n && Wg(e, r, n);
			}, r.prototype.optionUpdated = function() {
				this.option.type === "category" && (this.__ordinalMeta = uT.createByAxisModel(this));
			}, r.prototype.getCategories = function(e) {
				var t = this.option;
				if (t.type === "category") return e ? t.data : this.__ordinalMeta.categories;
			}, r.prototype.getOrdinalMeta = function() {
				return this.__ordinalMeta;
			}, r.prototype.updateAxisBreaks = function(e) {
				var t = MA();
				return t ? t.updateModelAxisBreak(this, e) : { breaks: [] };
			}, r.type = t + "Axis." + o, r.defaultOption = s, r;
		}(r);
		e.registerComponentModel(c);
	}), e.registerSubTypeDefaulter(t + "Axis", aN);
}
function aN(e) {
	return e.type || (e.data ? "category" : "value");
}
//#endregion
//#region node_modules/echarts/lib/coord/cartesian/Cartesian.js
var oN = function() {
	function e(e) {
		this.type = "cartesian", this._dimList = [], this._axes = {}, this.name = e || "";
	}
	return e.prototype.getAxis = function(e) {
		return this._axes[e];
	}, e.prototype.getAxes = function() {
		return L(this._dimList, function(e) {
			return this._axes[e];
		}, this);
	}, e.prototype.getAxesByScale = function(e) {
		return e = e.toLowerCase(), oe(this.getAxes(), function(t) {
			return t.scale.type === e;
		});
	}, e.prototype.addAxis = function(e) {
		var t = e.dim;
		this._axes[t] = e, this._dimList.push(t);
	}, e;
}(), sN = ["x", "y"];
function cN(e) {
	return (e.type === "interval" || e.type === "time") && !Eh(e);
}
var lN = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t.type = kj, t.dimensions = sN, t;
	}
	return t.prototype.calcAffineTransform = function() {
		this._transform = this._invTransform = null;
		var e = this.getAxis("x").scale, t = this.getAxis("y").scale;
		if (cN(e) && cN(t)) {
			var n = _T(e, null), r = _T(t, null), i = this.dataToPoint([n[0], r[0]]), a = this.dataToPoint([n[1], r[1]]), o = n[1] - n[0], s = r[1] - r[0];
			if (o && s) {
				var c = (a[0] - i[0]) / o, l = (a[1] - i[1]) / s, u = i[0] - n[0] * c, d = i[1] - r[0] * l, f = this._transform = [
					c,
					0,
					0,
					l,
					u,
					d
				];
				this._invTransform = Xt([], f);
			}
		}
	}, t.prototype.getBaseAxis = function() {
		return this.getAxesByScale("ordinal")[0] || this.getAxesByScale("time")[0] || this.getAxis("x");
	}, t.prototype.containPoint = function(e) {
		var t = this.getAxis("x"), n = this.getAxis("y");
		return t.contain(t.toLocalCoord(e[0])) && n.contain(n.toLocalCoord(e[1]));
	}, t.prototype.containData = function(e) {
		return this.getAxis("x").containData(e[0]) && this.getAxis("y").containData(e[1]);
	}, t.prototype.containZone = function(e, t) {
		var n = this.dataToPoint(e), r = this.dataToPoint(t), i = this.getArea(), a = new Y(n[0], n[1], r[0] - n[0], r[1] - n[1]);
		return i.intersect(a);
	}, t.prototype.dataToPoint = function(e, t, n) {
		n ||= [];
		var r = e[0], i = e[1];
		if (this._transform && r != null && isFinite(r) && i != null && isFinite(i)) return ot(n, e, this._transform);
		var a = this.getAxis("x"), o = this.getAxis("y");
		return n[0] = a.toGlobalCoord(a.dataToCoord(r, t)), n[1] = o.toGlobalCoord(o.dataToCoord(i, t)), n;
	}, t.prototype.clampData = function(e, t) {
		var n = this.getAxis("x").scale, r = this.getAxis("y").scale, i = n.getExtent(), a = r.getExtent(), o = n.parse(e[0]), s = r.parse(e[1]);
		return t ||= [], t[0] = Math.min(Math.max(Math.min(i[0], i[1]), o), Math.max(i[0], i[1])), t[1] = Math.min(Math.max(Math.min(a[0], a[1]), s), Math.max(a[0], a[1])), t;
	}, t.prototype.pointToData = function(e, t, n) {
		if (n ||= [], this._invTransform) return ot(n, e, this._invTransform);
		var r = this.getAxis("x"), i = this.getAxis("y");
		return n[0] = r.coordToData(r.toLocalCoord(e[0]), t), n[1] = i.coordToData(i.toLocalCoord(e[1]), t), n;
	}, t.prototype.getOtherAxis = function(e) {
		return this.getAxis(e.dim === "x" ? "y" : "x");
	}, t.prototype.getArea = function(e) {
		e ||= 0;
		var t = this.getAxis("x").getGlobalExtent(), n = this.getAxis("y").getGlobalExtent(), r = Math.min(t[0], t[1]) - e, i = Math.min(n[0], n[1]) - e;
		return new Y(r, i, Math.max(t[0], t[1]) - r + e, Math.max(n[0], n[1]) - i + e);
	}, t;
}(oN);
//#endregion
//#region node_modules/echarts/lib/coord/axisAlignTicks.js
function uN(e, t) {
	var n = e.scale, r = e.model, i = sD(n, r, r.ecModel, e, null), a = ET(n), o = ET(t) ? t.intervalStub : t, s = a ? n.intervalStub : n, c = n.base, l = o.getTicks(), u = o.getTicks({ expandToNicedExtent: !0 }), d = l.length - 1, f, p, m;
	if (d === 1) f = p = 0, m = 1;
	else if (d === 2) {
		var h = fo(l[0].value - l[1].value), g = fo(l[1].value - l[2].value);
		f = p = 0, h === g ? m = 2 : (m = 1, h < g ? f = h / g : p = g / h);
	} else {
		var _ = o.getConfig().interval;
		f = (1 - (l[0].value - u[0].value) / _) % 1, p = (1 - (u[d].value - l[d].value) / _) % 1, m = d - +!!f - !!p;
	}
	var v = i.zoomFixMM, y = v[0] || v[1], b = [i.fixMM[0] || y, i.fixMM[1] || y], x = n.getExtent(), S = s.getExtent(), C = MT(S, b), w, T, E, D, O, k;
	function A(e) {
		for (var t = 50, n = 0; n < t && !e(); n++) E = a ? E * uo(c, 2) : OT(E), D = kT(E);
	}
	function j() {
		w = Eo(k - E * f, D);
	}
	function ee() {
		T = Eo(O + E * p, D);
	}
	function M() {
		k = f ? Eo(w + E * f, D) : w;
	}
	function te() {
		O = p ? Eo(T - E * p, D) : T;
	}
	if (b[0] && b[1]) {
		w = C[0], T = C[1], E = (T - w) / (m + f + p);
		var N = e.getExtent(), ne = fo(N[1] - N[0]);
		D = Mo([T, w], ne, .5 / m), M(), te(), Zo(D) && (E = Eo(E, D));
	} else {
		var P = C[1] - C[0];
		E = a ? uo(Vo(P), 1) : Uo(P / m, 2), D = kT(E), b[0] ? (w = C[0], A(function() {
			if (M(), O = Eo(k + E * m, D), ee(), T >= C[1]) return !0;
		})) : b[1] ? (T = C[1], A(function() {
			if (te(), k = Eo(O - E * m, D), j(), w <= C[0]) return !0;
		})) : A(function() {
			k = Eo(ho(C[0] / E) * E, D), O = Eo(mo(C[1] / E) * E, D);
			var e = po((O - k) / E);
			if (e <= m) {
				var t = m - e, n = void 0, r = i.incl0 || a;
				if (r && C[0] === 0) n = [0, t];
				else if (r && C[1] === 0) n = [t, 0];
				else {
					var o = mo(t / 2);
					n = t % 2 == 0 ? [o, o] : w + T < C[0] + C[1] ? [o, o + 1] : [o + 1, o];
				}
				if (k = Eo(k - E * n[0], D), O = Eo(O + E * n[1], D), j(), ee(), w <= C[0] && T >= C[1]) return !0;
			}
		});
	}
	xE(n, b, S, [w, T], x, {
		interval: E,
		intervalCount: m,
		intervalPrecision: D,
		niceExtent: [k, O]
	});
}
//#endregion
//#region node_modules/echarts/lib/coord/cartesian/Grid.js
var dN = [[3, 1], [0, 2]], fN = function() {
	function e(e, t, n) {
		this.type = "grid", this._coordsMap = {}, this._coordsList = [], this._axesMap = {}, this._axesList = [], this.axisPointerEnabled = !0, this.dimensions = sN, this._initCartesian(e, t, n), this.model = e;
	}
	return e.prototype.getRect = function() {
		return this._rect;
	}, e.prototype.update = function(e, t) {
		var n = this._axesMap;
		I(this._axesList, function(e) {
			tD(e, 1);
			var t = e.scale;
			DT(t) && t.setSortInfo(e.model.get("categorySortInfo"));
		});
		function r(e) {
			for (var t = R(e), n = [], r = t.length - 1; r >= 0; r--) {
				var i = e[+t[r]];
				i.__alignTo ? n.push(i) : pD(i);
			}
			I(n, function(e) {
				_N(e, e.__alignTo) ? pD(e) : uN(e, e.__alignTo.scale);
			});
		}
		r(n.x), r(n.y);
		var i = {};
		I(n.x, function(e) {
			mN(n, "y", e, i);
		}), I(n.y, function(e) {
			mN(n, "x", e, i);
		}), this.resize(this.model, t);
	}, e.prototype.resize = function(e, t, n) {
		var r = Vg(e, t), i = this._rect = zg(e.getBoxLayoutParams(), r.refContainer), a = this._axesMap, o = this._coordsList, s = e.get("containLabel");
		if (yN(a, i), !n) {
			var c = CN(i, o, a, s, t), l = void 0;
			if (s) xN ? (xN(this._axesList, i), yN(a, i)) : l = SN(i.clone(), "axisLabel", null, i, a, c, r);
			else {
				var u = TN(e, i, r), d = u.outerBoundsRect, f = u.parsedOuterBoundsContain, p = u.outerBoundsClamp;
				d && (l = SN(d, f, p, i, a, c, r));
			}
			wN(i, a, JD.determine, null, l, r), I(this._coordsList, function(e) {
				e.calcAffineTransform();
			});
		}
	}, e.prototype.getAxis = function(e, t) {
		var n = this._axesMap[e];
		if (n != null) return n[t || 0];
	}, e.prototype.getAxes = function() {
		return this._axesList.slice();
	}, e.prototype.getCartesian = function(e, t) {
		if (e != null && t != null) {
			var n = "x" + e + "y" + t;
			return this._coordsMap[n];
		}
		W(e) && (t = e.yAxisIndex, e = e.xAxisIndex);
		for (var r = 0, i = this._coordsList; r < i.length; r++) if (i[r].getAxis("x").index === e || i[r].getAxis("y").index === t) return i[r];
	}, e.prototype.getCartesians = function() {
		return this._coordsList.slice();
	}, e.prototype.convertToPixel = function(e, t, n) {
		var r = this._findConvertTarget(t);
		return r.cartesian ? r.cartesian.dataToPoint(n) : r.axis ? r.axis.toGlobalCoord(r.axis.dataToCoord(n)) : null;
	}, e.prototype.convertFromPixel = function(e, t, n) {
		var r = this._findConvertTarget(t);
		return r.cartesian ? r.cartesian.pointToData(n) : r.axis ? r.axis.coordToData(r.axis.toLocalCoord(n)) : null;
	}, e.prototype._findConvertTarget = function(e) {
		var t = e.seriesModel, n = e.xAxisModel || t && t.getReferringComponents("xAxis", js).models[0], r = e.yAxisModel || t && t.getReferringComponents("yAxis", js).models[0], i = e.gridModel, a = this._coordsList, o, s;
		return t ? (o = t.coordinateSystem, P(a, o) < 0 && (o = null)) : n && r ? o = this.getCartesian(n.componentIndex, r.componentIndex) : n ? s = this.getAxis("x", n.componentIndex) : r ? s = this.getAxis("y", r.componentIndex) : i && i.coordinateSystem === this && (o = this._coordsList[0]), {
			cartesian: o,
			axis: s
		};
	}, e.prototype.containPoint = function(e) {
		var t = this._coordsList[0];
		if (t) return t.containPoint(e);
	}, e.prototype._initCartesian = function(e, t, n) {
		var r = this, i = this, a = {
			left: !1,
			right: !1,
			top: !1,
			bottom: !1
		}, o = {
			x: {},
			y: {}
		}, s = {
			x: 0,
			y: 0
		};
		if (t.eachComponent("xAxis", c("x"), this), t.eachComponent("yAxis", c("y"), this), !s.x || !s.y) {
			this._axesMap = {}, this._axesList = [];
			return;
		}
		this._axesMap = o, I(o.x, function(t, n) {
			I(o.y, function(i, a) {
				var o = "x" + n + "y" + a, s = new lN(o);
				s.master = r, s.model = e, r._coordsMap[o] = s, r._coordsList.push(s), s.addAxis(t), s.addAxis(i);
			});
		}), gN(o.x), gN(o.y);
		function c(t) {
			return function(n, r) {
				if (pN(n, e)) {
					var c = n.get("position");
					t === "x" ? c !== "top" && c !== "bottom" && (c = a.bottom ? "top" : "bottom") : c !== "left" && c !== "right" && (c = a.left ? "right" : "left"), a[c] = !0;
					var l = sE(n), u = new AA(t, cE(n, l, !0), [0, 0], l, c);
					u.onBand = CE(u.scale, n), u.inverse = n.get("inverse"), n.axis = u, u.model = n, u.grid = i, u.index = r, i._axesList.push(u), o[t][r] = u, s[t]++;
				}
			};
		}
	}, e.prototype.getTooltipAxes = function(e) {
		var t = [], n = [];
		return I(this.getCartesians(), function(r) {
			var i = e != null && e !== "auto" ? r.getAxis(e) : r.getBaseAxis(), a = r.getOtherAxis(i);
			P(t, i) < 0 && t.push(i), P(n, a) < 0 && n.push(a);
		}), {
			baseAxes: t,
			otherAxes: n
		};
	}, e.create = function(t, n) {
		var r = [];
		return t.eachComponent("grid", function(i, a) {
			var o = new e(i, t, n);
			o.name = "grid_" + a, o.resize(i, n, !0), i.coordinateSystem = o, r.push(o), I(o._axesList, function(t) {
				eD(t, e.dimIdxMap);
			});
		}), t.eachSeries(function(e) {
			var t, n;
			Ag({
				targetModel: e,
				coordSysType: kj,
				coordSysProvider: r
			});
			function r() {
				var r = hj(e), i = r.xAxisModel, a = r.yAxisModel;
				return t = i.axis, n = a.axis, i.getCoordSysModel().coordinateSystem.getCartesian(i.componentIndex, a.componentIndex);
			}
			t && n && (HE(t, e, kj), HE(n, e, kj));
		}, this), r;
	}, e.dimensions = sN, e.dimIdxMap = Dw(sN), e;
}();
function pN(e, t) {
	return e.getCoordSysModel() === t;
}
function mN(e, t, n, r) {
	n.getAxesOnZeroOf = function() {
		return a ? [a] : [];
	};
	var i = e[t], a, o = n.model, s = o.get(["axisLine", "onZero"]), c = o.get(["axisLine", "onZeroAxisIndex"]);
	if (!s) return;
	if (c != null) hN(s, i[c]) && (a = i[c]);
	else for (var l in i) if (q(i, l) && hN(s, i[l]) && !r[u(i[l])]) {
		a = i[l];
		break;
	}
	a && (r[u(a)] = !0);
	function u(e) {
		return e.dim + "_" + e.index;
	}
}
function hN(e, t) {
	if (!t) return !1;
	var n = t.scale, r = lE(n, 0, !1), i = t && t.type !== "category" && t.type !== "time" && r !== 3;
	return i && e === "auto" && dE(t) && (i = !1), i;
}
function gN(e) {
	for (var t = R(e), n, r = [], i = t.length - 1; i >= 0; i--) {
		var a = e[+t[i]];
		CT(a.scale) && yE(a.model, a.type, !0) == null && (a.model.get("alignTicks") && a.model.get("interval") == null ? r.push(a) : n = a);
	}
	n ||= r.pop(), n && I(r, function(e) {
		e.__alignTo = n;
	});
}
function _N(e, t) {
	return Eh(e.scale) || Eh(t.scale) || t.scale.getTicks().length < 2;
}
function vN(e, t) {
	var n = e.getExtent(), r = n[0] + n[1];
	e.toGlobalCoord = e.dim === "x" ? function(e) {
		return e + t;
	} : function(e) {
		return r - e + t;
	}, e.toLocalCoord = e.dim === "x" ? function(e) {
		return e - t;
	} : function(e) {
		return r - e + t;
	};
}
function yN(e, t) {
	I(e.x, function(e) {
		return bN(e, t.x, t.width);
	}), I(e.y, function(e) {
		return bN(e, t.y, t.height);
	});
}
function bN(e, t, n) {
	var r = [0, n], i = +!!e.inverse;
	e.setExtent(r[i], r[1 - i]), vN(e, t);
}
var xN;
function SN(e, t, n, r, i, a, o) {
	wN(r, i, JD.estimate, t, !1, o);
	var s = [
		0,
		0,
		0,
		0
	];
	l(0), l(1), u(r, 0, NaN), u(r, 1, NaN);
	var c = se(s, function(e) {
		return e > 0;
	}) == null;
	return fm(r, s, !0, !0, n), yN(i, r), c;
	function l(e) {
		I(i[Rp[e]], function(t) {
			if (vE(t.model)) {
				var n = a.ensureRecord(t.model), r = n.labelInfoList;
				if (r) for (var i = 0; i < r.length; i++) {
					var o = r[i], s = t.scale.normalize(SE(t.scale, LA(o.label).labelInfo.tick));
					s = e === 1 ? 1 - s : s, u(o.rect, e, s), u(o.rect, 1 - e, NaN);
				}
				var c = n.nameLayout;
				if (c) {
					var s = _E(n.nameLocation) ? .5 : NaN;
					u(c.rect, e, s), u(c.rect, 1 - e, NaN);
				}
			}
		});
	}
	function u(t, n, r) {
		var i = e[Rp[n]] - t[Rp[n]], a = t[zp[n]] + t[Rp[n]] - (e[zp[n]] + e[Rp[n]]);
		i = d(i, 1 - r), a = d(a, r);
		var o = dN[n][0], c = dN[n][1];
		s[o] = uo(s[o], i), s[c] = uo(s[c], a);
	}
	function d(e, t) {
		return e > 0 && !_e(t) && t > 1e-4 && (e /= t), e;
	}
}
function CN(e, t, n, r, i) {
	var a = new zA(EN);
	return I(n, function(n) {
		return I(n, function(n) {
			if (vE(n.model)) {
				var o = !r;
				n.axisBuilder = gj(e, t, n.model, i, a, o);
			}
		});
	}), a;
}
function wN(e, t, n, r, i, a) {
	var o = n === JD.determine;
	I(t, function(t) {
		return I(t, function(t) {
			vE(t.model) && (_j(t.axisBuilder, e, t.model), t.axisBuilder.build(o ? { axisTickLabelDetermine: !0 } : { axisTickLabelEstimate: !0 }, { noPxChange: i }));
		});
	});
	var s = {
		x: 0,
		y: 0
	};
	c(0), c(1);
	function c(t) {
		s[Rp[1 - t]] = e[zp[t]] <= a.refContainer[zp[t]] * .5 ? 0 : 1 - t == 1 ? 2 : 1;
	}
	I(t, function(e, t) {
		return I(e, function(e) {
			vE(e.model) && ((r === "all" || o) && e.axisBuilder.build({ axisName: !0 }, { nameMarginLevel: s[t] }), o && e.axisBuilder.build({ axisLine: !0 }));
		});
	});
}
function TN(e, t, n) {
	var r, i = e.get("outerBoundsMode", !0);
	i === "same" ? r = t.clone() : (i == null || i === "auto") && (r = zg(e.get("outerBounds", !0) || Dj, n.refContainer));
	var a = e.get("outerBoundsContain", !0), o = a == null || a === "auto" || P(["all", "axisLabel"], a) < 0 ? "all" : a, s = [wo(G(e.get("outerBoundsClampWidth", !0), Oj[0]), t.width), wo(G(e.get("outerBoundsClampHeight", !0), Oj[1]), t.height)];
	return {
		outerBoundsRect: r,
		parsedOuterBoundsContain: o,
		outerBoundsClamp: s
	};
}
var EN = function(e, t, n, r, i, a) {
	var o = n.axis.dim === "x" ? "y" : "x";
	UA(e, t, n, r, i, a), _E(e.nameLocation) || I(t.recordMap[o], function(e) {
		e && e.labelInfoList && e.dirVec && GA(e.labelInfoList, e.dirVec, r, i);
	});
};
//#endregion
//#region node_modules/echarts/lib/component/axisPointer/modelHelper.js
function DN(e, t) {
	var n = {
		axesInfo: {},
		seriesInvolved: !1,
		coordSysAxesInfo: {},
		coordSysMap: {}
	};
	return ON(n, e, t), n.seriesInvolved && AN(n, e), n;
}
function ON(e, t, n) {
	var r = t.getComponent("tooltip"), i = t.getComponent("axisPointer"), a = i.get("link", !0) || [], o = [];
	I(n.getCoordinateSystems(), function(n) {
		if (!n.axisPointerEnabled) return;
		var s = LN(n.model), c = e.coordSysAxesInfo[s] = {};
		e.coordSysMap[s] = n;
		var l = n.model.getModel("tooltip", r);
		if (I(n.getAxes(), B(p, !1, null)), n.getTooltipAxes && r && l.get("show")) {
			var u = l.get("trigger") === "axis", d = l.get(["axisPointer", "type"]) === "cross", f = n.getTooltipAxes(l.get(["axisPointer", "axis"]));
			(u || d) && I(f.baseAxes, B(p, !d || "cross", u)), d && I(f.otherAxes, B(p, "cross", !1));
		}
		function p(r, s, u) {
			var d = u.model.getModel("axisPointer", i), f = d.get("show");
			if (f && (f !== "auto" || r || IN(d))) {
				s ??= d.get("triggerTooltip"), d = r ? kN(u, l, i, t, r, s) : d;
				var p = d.get("snap"), m = d.get("triggerEmphasis"), h = LN(u.model), g = s || p || u.type === "category", _ = e.axesInfo[h] = {
					key: h,
					axis: u,
					coordSys: n,
					axisPointerModel: d,
					triggerTooltip: s,
					triggerEmphasis: m,
					involveSeries: g,
					snap: p,
					useHandle: IN(d),
					seriesModels: [],
					linkGroup: null
				};
				c[h] = _, e.seriesInvolved = e.seriesInvolved || g;
				var v = jN(a, u);
				if (v != null) {
					var y = o[v] || (o[v] = { axesInfo: {} });
					y.axesInfo[h] = _, y.mapper = a[v].mapper, _.linkGroup = y;
				}
			}
		}
	});
}
function kN(e, t, n, r, i, a) {
	var o = t.getModel("axisPointer"), s = [
		"type",
		"snap",
		"lineStyle",
		"shadowStyle",
		"label",
		"animation",
		"animationDurationUpdate",
		"animationEasingUpdate",
		"z"
	], c = {};
	I(s, function(e) {
		c[e] = A(o.get(e));
	}), c.snap = e.type !== "category" && !!a, o.get("type") === "cross" && (c.type = "line");
	var l = c.label ||= {};
	if (l.show ??= !1, i === "cross" && (l.show = o.get(["label", "show"]) ?? !0, !a)) {
		var u = c.lineStyle = o.get("crossStyle");
		u && N(l, u.textStyle);
	}
	return e.model.getModel("axisPointer", new ih(c, n, r));
}
function AN(e, t) {
	t.eachSeries(function(t) {
		var n = t.coordinateSystem, r = t.get(["tooltip", "trigger"], !0), i = t.get(["tooltip", "show"], !0);
		n && n.model && r !== "none" && r !== !1 && r !== "item" && i !== !1 && t.get(["axisPointer", "show"], !0) !== !1 && I(e.coordSysAxesInfo[LN(n.model)], function(e) {
			var r = e.axis;
			n.getAxis(r.dim) === r && (e.seriesModels.push(t), e.seriesDataCount ??= 0, e.seriesDataCount += t.getData().count());
		});
	});
}
function jN(e, t) {
	for (var n = t.model, r = t.dim, i = 0; i < e.length; i++) {
		var a = e[i] || {};
		if (MN(a[r + "AxisId"], n.id) || MN(a[r + "AxisIndex"], n.componentIndex) || MN(a[r + "AxisName"], n.name)) return i;
	}
}
function MN(e, t) {
	return e === "all" || V(e) && P(e, t) >= 0 || e === t;
}
function NN(e) {
	var t = PN(e);
	if (t) {
		var n = t.axisPointerModel, r = t.axis.scale, i = n.option, a = n.get("status"), o = n.get("value");
		o != null && (o = r.parse(o));
		var s = IN(n);
		a ?? (i.status = s ? "show" : "hide");
		var c = r.getExtent();
		(o == null || o > c[1]) && (o = c[1]), o < c[0] && (o = c[0]), i.value = o, s && (i.status = t.axis.scale.isBlank() ? "hide" : "show");
	}
}
function PN(e) {
	var t = (e.ecModel.getComponent("axisPointer") || {}).coordSysAxesInfo;
	return t && t.axesInfo[LN(e)];
}
function FN(e) {
	var t = PN(e);
	return t && t.axisPointerModel;
}
function IN(e) {
	return !!e.get(["handle", "show"]);
}
function LN(e) {
	return e.type + "||" + e.id;
}
//#endregion
//#region node_modules/echarts/lib/component/axis/AxisView.js
var RN = {}, zN = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.render = function(t, n, r, i) {
		this.axisPointerClass && NN(t), e.prototype.render.apply(this, arguments), this._doUpdateAxisPointerClass(t, r, !0);
	}, t.prototype.updateAxisPointer = function(e, t, n, r) {
		this._doUpdateAxisPointerClass(e, n, !1);
	}, t.prototype.remove = function(e, t) {
		var n = this._axisPointer;
		n && n.remove(t);
	}, t.prototype.dispose = function(t, n) {
		this._disposeAxisPointer(n), e.prototype.dispose.apply(this, arguments);
	}, t.prototype._doUpdateAxisPointerClass = function(e, n, r) {
		var i = t.getAxisPointerClass(this.axisPointerClass);
		if (i) {
			var a = FN(e);
			a ? (this._axisPointer ||= new i()).render(e, a, n, r) : this._disposeAxisPointer(n);
		}
	}, t.prototype._disposeAxisPointer = function(e) {
		this._axisPointer && this._axisPointer.dispose(e), this._axisPointer = null;
	}, t.registerAxisPointerClass = function(e, t) {
		RN[e] = t;
	}, t.getAxisPointerClass = function(e) {
		return e && RN[e];
	}, t.type = "axis", t;
}(rb), BN = X();
function VN(e, t, n, r) {
	var i = n.axis;
	if (!i.scale.isBlank()) {
		var a = n.getModel("splitArea"), o = a.getModel("areaStyle"), s = o.get("color"), c = r.coordinateSystem.getRect(), l = i.getTicksCoords({
			tickModel: a,
			breakTicks: "none",
			pruneByBreak: "preserve_extent_bound"
		});
		if (l.length) {
			var u = s.length, d = BN(e).splitAreaColors, f = K(), p = 0;
			if (d) for (var m = 0; m < l.length; m++) {
				var h = d.get(l[m].tickValue);
				if (h != null) {
					p = (h + (u - 1) * m) % u;
					break;
				}
			}
			var g = i.toGlobalCoord(l[0].coord), _ = o.getAreaStyle();
			s = V(s) ? s : [s];
			for (var m = 1; m < l.length; m++) {
				var v = i.toGlobalCoord(l[m].coord), y = void 0, b = void 0, x = void 0, S = void 0;
				i.isHorizontal() ? (y = g, b = c.y, x = v - y, S = c.height, g = y + x) : (y = c.x, b = g, x = c.width, S = v - b, g = b + S);
				var C = l[m - 1].tickValue;
				C != null && f.set(C, p), t.add(new bu({
					anid: C == null ? null : "area_" + C,
					shape: {
						x: y,
						y: b,
						width: x,
						height: S
					},
					style: N({ fill: s[p] }, _),
					autoBatch: !0,
					silent: !0
				})), p = (p + 1) % u;
			}
			BN(e).splitAreaColors = f;
		}
	}
}
function HN(e) {
	BN(e).splitAreaColors = null;
}
//#endregion
//#region node_modules/echarts/lib/component/axis/CartesianAxisView.js
var UN = [
	"splitArea",
	"splitLine",
	"minorSplitLine",
	"breakArea"
], WN = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.axisPointerClass = "CartesianAxisPointer", n;
	}
	return t.prototype.render = function(t, n, r, i) {
		this.group.removeAll();
		var a = this._axisGroup;
		this._axisGroup = new Wa(), this.group.add(this._axisGroup), vE(t) && (this._axisGroup.add(t.axis.axisBuilder.group), I(UN, function(e) {
			t.get([e, "show"]) && GN[e](this, this._axisGroup, t, t.getCoordSysModel(), r);
		}, this), i && i.type === "changeAxisOrder" && i.isInitSort || im(a, this._axisGroup, t), e.prototype.render.call(this, t, n, r, i));
	}, t.prototype.remove = function() {
		HN(this);
	}, t.type = "cartesianAxis", t;
}(zN), GN = {
	splitLine: function(e, t, n, r, i) {
		var a = n.axis;
		if (!a.scale.isBlank()) {
			var o = n.getModel("splitLine"), s = o.getModel("lineStyle"), c = s.get("color"), l = o.get("showMinLine") !== !1, u = o.get("showMaxLine") !== !1;
			c = V(c) ? c : [c];
			for (var d = r.coordinateSystem.getRect(), f = a.isHorizontal(), p = 0, m = a.getTicksCoords({
				tickModel: o,
				breakTicks: "none",
				pruneByBreak: "preserve_extent_bound"
			}), h = [], g = [], _ = s.getLineStyle(), v = 0; v < m.length; v++) {
				var y = a.toGlobalCoord(m[v].coord);
				if (!(v === 0 && !l || v === m.length - 1 && !u)) {
					var b = m[v].tickValue;
					f ? (h[0] = y, h[1] = d.y, g[0] = y, g[1] = d.y + d.height) : (h[0] = d.x, h[1] = y, g[0] = d.x + d.width, g[1] = y);
					var x = p++ % c.length, S = new ip({
						anid: b == null ? null : "line_" + b,
						autoBatch: !0,
						shape: {
							x1: h[0],
							y1: h[1],
							x2: g[0],
							y2: g[1]
						},
						style: N({ stroke: c[x] }, _),
						silent: !0
					});
					Xp(S.shape, _.lineWidth), t.add(S);
				}
			}
		}
	},
	minorSplitLine: function(e, t, n, r, i) {
		var a = n.axis, o = n.getModel("minorSplitLine").getModel("lineStyle"), s = r.coordinateSystem.getRect(), c = a.isHorizontal(), l = a.getMinorTicksCoords();
		if (l.length) for (var u = [], d = [], f = o.getLineStyle(), p = 0; p < l.length; p++) for (var m = 0; m < l[p].length; m++) {
			var h = a.toGlobalCoord(l[p][m].coord);
			c ? (u[0] = h, u[1] = s.y, d[0] = h, d[1] = s.y + s.height) : (u[0] = s.x, u[1] = h, d[0] = s.x + s.width, d[1] = h);
			var g = new ip({
				anid: "minor_line_" + l[p][m].tickValue,
				autoBatch: !0,
				shape: {
					x1: u[0],
					y1: u[1],
					x2: d[0],
					y2: d[1]
				},
				style: f,
				silent: !0
			});
			Xp(g.shape, f.lineWidth), t.add(g);
		}
	},
	splitArea: function(e, t, n, r, i) {
		VN(e, t, n, r);
	},
	breakArea: function(e, t, n, r, i) {
		var a = MA(), o = n.axis.scale;
		a && o.type !== "ordinal" && a.rectCoordBuildBreakAxis(t, e, n, r.coordinateSystem.getRect(), i);
	}
}, KN = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.type = "xAxis", t;
}(WN), qN = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t.type = KN.type, t;
	}
	return t.type = "yAxis", t;
}(WN), JN = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t.type = "grid", t;
	}
	return t.prototype.render = function(e, t) {
		this.group.removeAll(), e.get("show") && this.group.add(new bu({
			shape: e.coordinateSystem.getRect(),
			style: N({ fill: e.get("backgroundColor") }, e.getItemStyle()),
			silent: !0,
			z2: -1
		}));
	}, t.type = "grid", t;
}(rb), YN = { offset: 0 };
function XN(e) {
	e.registerComponentView(JN), e.registerComponentModel(Aj), e.registerCoordinateSystem("cartesian2d", fN), iN(e, "x", $M, YN), iN(e, "y", $M, YN), e.registerComponentView(KN), e.registerComponentView(qN), e.registerPreprocessor(function(e) {
		e.xAxis && e.yAxis && !e.grid && (e.grid = {});
	});
}
//#endregion
//#region node_modules/echarts/lib/chart/scatter/install.js
function ZN(e) {
	TD(XN), e.registerSeriesModel(KM), e.registerChartView(ZM), e.registerLayout(TA("scatter"));
}
//#endregion
//#region node_modules/echarts/lib/component/helper/interactionMutex.js
var QN = X();
function $N(e, t) {
	return !!QN(e)[t];
}
$C({
	type: "takeGlobalCursor",
	event: "globalCursorTaken",
	update: "update"
}, Pe);
//#endregion
//#region node_modules/echarts/lib/component/helper/cursorHelper.js
var eP = {
	axisPointer: 1,
	tooltip: 1,
	brush: 1
};
function tP(e, t, n) {
	var r = t.getComponentByElement(e.topTarget);
	if (!r || r === n || eP.hasOwnProperty(r.mainType)) return !1;
	var i = r.coordinateSystem;
	if (!i || i.model === n) return !1;
	var a = Sm(r), o = Sm(n);
	return !((a.zlevel - o.zlevel || a.z - o.z) <= 0);
}
//#endregion
//#region node_modules/echarts/lib/component/helper/RoamController.js
var nP = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this) || this;
		n._zr = t;
		var r = z(n._mousedownHandler, n), i = z(n._mousemoveHandler, n), a = z(n._mouseupHandler, n), o = z(n._mousewheelHandler, n), s = z(n._pinchHandler, n);
		return n.enable = function(e, n) {
			var c = n.zInfo, l = Sm(c.component), u = l.z, d = l.zlevel, f = {
				component: c.component,
				z: u,
				zlevel: d,
				z2: G(c.z2, -Infinity)
			}, p = M({}, n.triggerInfo);
			this._opt = N(M({}, n), {
				zoomOnMouseWheel: !0,
				moveOnMouseMove: !0,
				moveOnMouseWheel: !1,
				preventDefaultMouseMove: !0,
				zInfoParsed: f,
				triggerInfo: p,
				cursorGrab: "grab",
				cursorGrabbing: "grabbing"
			}), e ??= !0, (!this._enabled || this._controlType !== e) && (this.disable(), this._enabled = !0, (e === !0 || e === "move" || e === "pan") && (oP(t, "mousedown", r, f), oP(t, "mousemove", i, f), oP(t, "mouseup", a, f)), (e === !0 || e === "scale" || e === "zoom") && (oP(t, "mousewheel", o, f), oP(t, "pinch", s, f)));
		}, n.disable = function() {
			this._enabled && (this._enabled = !1, sP(t, "mousedown", r), sP(t, "mousemove", i), sP(t, "mouseup", a), sP(t, "mousewheel", o), sP(t, "pinch", s));
		}, n;
	}
	return t.prototype.isDragging = function() {
		return this._dragging;
	}, t.prototype.isPinching = function() {
		return this._pinching;
	}, t.prototype._checkPointer = function(e, t, n) {
		var r = this._opt, i = r.zInfoParsed;
		if (tP(e, r.api, i.component)) return !1;
		var a = r.triggerInfo, o = a.roamTrigger, s = !1;
		return o === "global" && (s = !0), s ||= a.isInSelf(e, t, n), s && a.isInClip && !a.isInClip(e, t, n) && (s = !1), s;
	}, t.prototype._decideCursorStyle = function(e, t, n, r) {
		var i = e.target;
		if (!i && this._checkPointer(e, t, n)) return this._opt.cursorGrab;
		if (r) return i && i.cursor || "default";
	}, t.prototype.dispose = function() {
		this.disable();
	}, t.prototype._mousedownHandler = function(e) {
		if (!(Lt(e) || rP(e))) {
			for (var t = e.target; t;) {
				if (t.draggable) return;
				t = t.__hostTarget || t.parent;
			}
			var n = e.offsetX, r = e.offsetY;
			this._checkPointer(e, n, r) && (this._x = n, this._y = r, this._dragging = !0);
		}
	}, t.prototype._mousemoveHandler = function(e) {
		var t = this._zr;
		if (!(e.gestureEvent === "pinch" || $N(t, "globalPan") || rP(e))) {
			var n = e.offsetX, r = e.offsetY;
			if (!this._dragging || !dP("moveOnMouseMove", e, this._opt)) {
				var i = this._decideCursorStyle(e, n, r, !1);
				i && t.setCursorStyle(i);
			} else {
				t.setCursorStyle(this._opt.cursorGrabbing);
				var a = this._x, o = this._y, s = n - a, c = r - o;
				this._x = n, this._y = r, this._opt.preventDefaultMouseMove && It(e.event), e.__ecRoamConsumed = !0, uP(this, "pan", "moveOnMouseMove", e, {
					dx: s,
					dy: c,
					oldX: a,
					oldY: o,
					newX: n,
					newY: r,
					isAvailableBehavior: null
				});
			}
		}
	}, t.prototype._mouseupHandler = function(e) {
		if (!rP(e)) {
			var t = this._zr;
			if (!Lt(e)) {
				this._dragging = !1;
				var n = this._decideCursorStyle(e, e.offsetX, e.offsetY, !0);
				n && t.setCursorStyle(n);
			}
		}
	}, t.prototype._mousewheelHandler = function(e) {
		if (!rP(e)) {
			var t = dP("zoomOnMouseWheel", e, this._opt), n = dP("moveOnMouseWheel", e, this._opt), r = e.wheelDelta, i = Math.abs(r), a = e.offsetX, o = e.offsetY;
			if (r !== 0 && (t || n)) {
				if (t) {
					var s = i > 3 ? 1.4 : i > 1 ? 1.2 : 1.1, c = r > 0 ? s : 1 / s;
					this._checkTriggerMoveZoom(this, "zoom", "zoomOnMouseWheel", e, {
						scale: c,
						originX: a,
						originY: o,
						isAvailableBehavior: null
					});
				}
				if (n) {
					var l = Math.abs(r), u = (r > 0 ? 1 : -1) * (l > 3 ? .4 : l > 1 ? .15 : .05);
					this._checkTriggerMoveZoom(this, "scrollMove", "moveOnMouseWheel", e, {
						scrollDelta: u,
						originX: a,
						originY: o,
						isAvailableBehavior: null
					});
				}
			}
		}
	}, t.prototype._pinchHandler = function(e) {
		if (!($N(this._zr, "globalPan") || rP(e))) {
			var t = e.pinchScale > 1 ? 1.1 : 1 / 1.1;
			this._checkTriggerMoveZoom(this, "zoom", null, e, {
				scale: t,
				originX: e.pinchX,
				originY: e.pinchY,
				isAvailableBehavior: null
			});
		}
	}, t.prototype._checkTriggerMoveZoom = function(e, t, n, r, i) {
		e._checkPointer(r, i.originX, i.originY) && (It(r.event), r.__ecRoamConsumed = !0, uP(e, t, n, r, i));
	}, t;
}(dt);
function rP(e) {
	return e.__ecRoamConsumed;
}
var iP = X();
function aP(e) {
	var t = iP(e);
	return t.roam = t.roam || {}, t.uniform = t.uniform || {}, t;
}
function oP(e, t, n, r) {
	for (var i = aP(e).roam, a = i[t] = i[t] || [], o = 0; o < a.length; o++) {
		var s = a[o].zInfoParsed;
		if ((s.zlevel - r.zlevel || s.z - r.z || s.z2 - r.z2) <= 0) break;
	}
	a.splice(o, 0, {
		listener: n,
		zInfoParsed: r
	}), cP(e, t);
}
function sP(e, t, n) {
	for (var r = aP(e).roam[t] || [], i = 0; i < r.length; i++) if (r[i].listener === n) {
		r.splice(i, 1), r.length || lP(e, t);
		return;
	}
}
function cP(e, t) {
	var n = aP(e);
	n.uniform[t] || e.on(t, n.uniform[t] = function(e) {
		var r = n.roam[t];
		if (r) for (var i = 0; i < r.length; i++) r[i].listener(e);
	});
}
function lP(e, t) {
	var n = aP(e).uniform;
	n[t] && (e.off(t, n[t]), n[t] = null);
}
function uP(e, t, n, r, i) {
	i.isAvailableBehavior = z(dP, null, n, r), e.trigger(t, i);
}
function dP(e, t, n) {
	var r = n[e];
	return !e || r && (!U(r) || t.event[r + "Key"]);
}
function fP(e) {
	return e;
}
var pP = "view";
(function(e) {
	n(t, e);
	function t(t, n, r) {
		var i = e.call(this) || this;
		i.type = pP, i.dimensions = ["x", "y"];
		var a = fP(i);
		a.invertY = t, a.lgCt = n, a.lgGeo = r;
		var o = a.trans = [];
		return o[0] = ua(), o[1] = ua(), o[2] = ua(), a.mtRaw = Ut(), a.mtRawInv = Ut(), a.mtOverall = Ut(), a.mtOverallInv = Ut(), a.zoom = 1, i;
	}
	return t.prototype.getBoundingRect = function() {
		return hP(null, this);
	}, t.prototype.getViewRect = function() {
		return gP(null, this);
	}, t.prototype.getRoamTransform = function() {
		return la(fP(this).trans[1]);
	}, t.prototype.dataToPoint = function(e, t, n) {
		var r = t ? fP(this).mtRaw : fP(this).mtOverall;
		return n ||= [], r ? ot(n, e, r) : ze(n, e);
	}, t.prototype.pointToData = function(e, t, n) {
		n ||= [];
		var r = fP(this).mtOverallInv;
		return r ? ot(n, e, r) : ze(n, e);
	}, t.prototype.convertToPixel = function(e, t, n) {
		var r = _P(t);
		return r === this ? r.dataToPoint(n) : null;
	}, t.prototype.convertFromPixel = function(e, t, n) {
		var r = _P(t);
		return r === this ? r.pointToData(n) : null;
	}, t.prototype.containPoint = function(e) {
		var t = fP(this);
		return mn(mP, t.dataRect), gn(mP, mP, t.mtOverall), _n(mP, e[0], e[1]);
	}, t.dimensions = ["x", "y"], t;
})(ca);
var mP = fn();
function hP(e, t) {
	return mn(e || fn(), fP(t).dataRect);
}
function gP(e, t) {
	return mn(e || fn(), fP(t).viewRect);
}
fn();
function _P(e) {
	var t = e.seriesModel;
	return t ? t.coordinateSystem : null;
}
ua(), ua();
function vP(e, t) {
	if (t) {
		var n = t.min || 0, r = t.max || Infinity;
		e = Math.max(Math.min(r, e), n);
	}
	return e;
}
//#endregion
//#region node_modules/echarts/lib/data/helper/linkSeriesData.js
var yP = X();
function bP(e) {
	var t = e.mainData, n = e.datas;
	n || (n = { main: t }, e.datasAttr = { main: "data" }), e.datas = e.mainData = null, DP(t, n, e), I(n, function(n) {
		I(t.TRANSFERABLE_METHODS, function(t) {
			n.wrapMethod(t, B(xP, e));
		});
	}), t.wrapMethod("cloneShallow", B(CP, e)), I(t.CHANGABLE_METHODS, function(n) {
		t.wrapMethod(n, B(SP, e));
	}), Se(n[t.dataType] === t);
}
function xP(e, t) {
	if (EP(this)) {
		var n = M({}, yP(this).datas);
		n[this.dataType] = t, DP(t, n, e);
	} else OP(t, this.dataType, yP(this).mainData, e);
	return t;
}
function SP(e, t) {
	return e.struct && e.struct.update(), t;
}
function CP(e, t) {
	return I(yP(t).datas, function(n, r) {
		n !== t && OP(n.cloneShallow(), r, t, e);
	}), t;
}
function wP(e) {
	var t = yP(this).mainData;
	return e == null || t == null ? t : yP(t).datas[e];
}
function TP() {
	var e = yP(this).mainData;
	return e == null ? [{ data: e }] : L(R(yP(e).datas), function(t) {
		return {
			type: t,
			data: yP(e).datas[t]
		};
	});
}
function EP(e) {
	return yP(e).mainData === e;
}
function DP(e, t, n) {
	yP(e).datas = {}, I(t, function(t, r) {
		OP(t, r, e, n);
	});
}
function OP(e, t, n, r) {
	yP(n).datas[t] = e, yP(e).mainData = n, e.dataType = t, r.struct && (e[r.structAttr] = r.struct, r.struct[r.datasAttr[t]] = e), e.getLinkedData = wP, e.getLinkedDataAll = TP;
}
//#endregion
//#region node_modules/echarts/lib/data/Tree.js
var kP = function() {
	function e(e, t) {
		this.depth = 0, this.height = 0, this.dataIndex = -1, this.children = [], this.viewChildren = [], this.isExpand = !1, this.name = e || "", this.hostTree = t;
	}
	return e.prototype.isRemoved = function() {
		return this.dataIndex < 0;
	}, e.prototype.eachNode = function(e, t, n) {
		H(e) && (n = t, t = e, e = null), e ||= {}, U(e) && (e = { order: e });
		var r = e.order || "preorder", i = this[e.attr || "children"], a;
		r === "preorder" && (a = t.call(n, this));
		for (var o = 0; !a && o < i.length; o++) i[o].eachNode(e, t, n);
		r === "postorder" && t.call(n, this);
	}, e.prototype.updateDepthAndHeight = function(e) {
		var t = 0;
		this.depth = e;
		for (var n = 0; n < this.children.length; n++) {
			var r = this.children[n];
			r.updateDepthAndHeight(e + 1), r.height > t && (t = r.height);
		}
		this.height = t + 1;
	}, e.prototype.getNodeById = function(e) {
		if (this.getId() === e) return this;
		for (var t = 0, n = this.children, r = n.length; t < r; t++) {
			var i = n[t].getNodeById(e);
			if (i) return i;
		}
	}, e.prototype.contains = function(e) {
		if (e === this) return !0;
		for (var t = 0, n = this.children, r = n.length; t < r; t++) {
			var i = n[t].contains(e);
			if (i) return i;
		}
	}, e.prototype.getAncestors = function(e) {
		for (var t = [], n = e ? this : this.parentNode; n;) t.push(n), n = n.parentNode;
		return t.reverse(), t;
	}, e.prototype.getAncestorsIndices = function() {
		for (var e = [], t = this; t;) e.push(t.dataIndex), t = t.parentNode;
		return e.reverse(), e;
	}, e.prototype.getDescendantIndices = function() {
		var e = [];
		return this.eachNode(function(t) {
			e.push(t.dataIndex);
		}), e;
	}, e.prototype.getValue = function(e) {
		var t = this.hostTree.data;
		return t.getStore().get(t.getDimensionIndex(e || "value"), this.dataIndex);
	}, e.prototype.setLayout = function(e, t) {
		this.dataIndex >= 0 && this.hostTree.data.setItemLayout(this.dataIndex, e, t);
	}, e.prototype.getLayout = function() {
		return this.hostTree.data.getItemLayout(this.dataIndex);
	}, e.prototype.getModel = function(e) {
		if (!(this.dataIndex < 0)) return this.hostTree.data.getItemModel(this.dataIndex).getModel(e);
	}, e.prototype.getLevelModel = function() {
		return (this.hostTree.levelModels || [])[this.depth];
	}, e.prototype.setVisual = function(e, t) {
		this.dataIndex >= 0 && this.hostTree.data.setItemVisual(this.dataIndex, e, t);
	}, e.prototype.getVisual = function(e) {
		return this.hostTree.data.getItemVisual(this.dataIndex, e);
	}, e.prototype.getRawIndex = function() {
		return this.hostTree.data.getRawIndex(this.dataIndex);
	}, e.prototype.getId = function() {
		return this.hostTree.data.getId(this.dataIndex);
	}, e.prototype.getChildIndex = function() {
		if (this.parentNode) {
			for (var e = this.parentNode.children, t = 0; t < e.length; ++t) if (e[t] === this) return t;
			return -1;
		}
		return -1;
	}, e.prototype.isAncestorOf = function(e) {
		for (var t = e.parentNode; t;) {
			if (t === this) return !0;
			t = t.parentNode;
		}
		return !1;
	}, e.prototype.isDescendantOf = function(e) {
		return e !== this && e.isAncestorOf(this);
	}, e;
}(), AP = function() {
	function e(e) {
		this.type = "tree", this._nodes = [], this.hostModel = e;
	}
	return e.prototype.eachNode = function(e, t, n) {
		this.root.eachNode(e, t, n);
	}, e.prototype.getNodeByDataIndex = function(e) {
		var t = this.data.getRawIndex(e);
		return this._nodes[t];
	}, e.prototype.getNodeById = function(e) {
		return this.root.getNodeById(e);
	}, e.prototype.update = function() {
		for (var e = this.data, t = this._nodes, n = 0, r = t.length; n < r; n++) t[n].dataIndex = -1;
		for (var n = 0, r = e.count(); n < r; n++) t[e.getRawIndex(n)].dataIndex = n;
	}, e.prototype.clearLayouts = function() {
		this.data.clearItemLayouts();
	}, e.createTree = function(t, n, r) {
		var i = new e(n), a = [], o = 1;
		s(t);
		function s(e, t) {
			var n = e.value;
			o = Math.max(o, V(n) ? n.length : 1), a.push(e);
			var r = new kP(xs(e.name, ""), i);
			t ? jP(r, t) : i.root = r, i._nodes.push(r);
			var c = e.children;
			if (c) for (var l = 0; l < c.length; l++) s(c[l], r);
		}
		i.root.updateDepthAndHeight(0);
		var c = Kw(a, {
			coordDimensions: ["value"],
			dimensionsCount: o
		}).dimensions, l = new Ww(c, n);
		return l.initData(a), r && r(l), bP({
			mainData: l,
			struct: i,
			structAttr: "tree"
		}), i.update(), i;
	}, e;
}();
function jP(e, t) {
	var n = t.children;
	e.parentNode !== t && (n.push(e), e.parentNode = t);
}
//#endregion
//#region node_modules/echarts/lib/chart/helper/treeHelper.js
function MP(e, t, n) {
	if (e && P(t, e.type) >= 0) {
		var r = n.getData().tree.root, i = e.targetNode;
		if (U(i) && (i = r.getNodeById(i)), i && r.contains(i)) return { node: i };
		var a = e.targetNodeId;
		if (a != null && (i = r.getNodeById(a))) return { node: i };
	}
}
function NP(e) {
	for (var t = []; e;) e = e.parentNode, e && t.push(e);
	return t.reverse();
}
function PP(e, t) {
	return P(NP(e), t) >= 0;
}
function FP(e, t) {
	for (var n = []; e;) {
		var r = e.dataIndex;
		n.push({
			name: e.name,
			dataIndex: r,
			value: t.getRawValue(r)
		}), e = e.parentNode;
	}
	return n.reverse(), n;
}
//#endregion
//#region node_modules/echarts/lib/chart/treemap/treemapAction.js
var IP = [
	"treemapZoomToNode",
	"treemapRender",
	"treemapMove"
];
function LP(e) {
	for (var t = 0; t < IP.length; t++) e.registerAction({
		type: IP[t],
		update: "updateView"
	}, Pe);
	e.registerAction({
		type: "treemapRootToNode",
		update: "updateView"
	}, function(e, t) {
		t.eachComponent({
			mainType: "series",
			subType: "treemap",
			query: e
		}, n);
		function n(t, n) {
			var r = MP(e, ["treemapZoomToNode", "treemapRootToNode"], t);
			if (r) {
				var i = t.getViewRoot();
				i && (e.direction = PP(i, r.node) ? "rollUp" : "drillDown"), t.resetViewRoot(r.node);
			}
		}
	});
}
//#endregion
//#region node_modules/echarts/lib/chart/helper/enableAriaDecalForTree.js
function RP(e) {
	var t = e.getData().tree, n = {};
	t.eachNode(function(t) {
		for (var r = t; r && r.depth > 1;) r = r.parentNode;
		var i = v_(e.ecModel, r.name || r.dataIndex + "", n);
		t.setVisual("decal", i);
	});
}
//#endregion
//#region node_modules/echarts/lib/chart/treemap/TreemapSeries.js
var zP = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.preventUsingHoverLayer = !0, n;
	}
	return t.prototype.getInitialData = function(e, t) {
		var n = {
			name: e.name,
			children: e.data
		};
		BP(n);
		var r = e.levels || [], i = new ih({ itemStyle: this.designatedVisualItemStyle = {} }, this, t);
		r = e.levels = VP(r, t);
		var a = L(r || [], function(e) {
			return new ih(e, i, t);
		}, this), o = AP.createTree(n, this, s);
		function s(e) {
			e.wrapMethod("getItemModel", function(e, t) {
				var n = o.getNodeByDataIndex(t);
				return e.parentModel = (n ? a[n.depth] : null) || i, e;
			});
		}
		return o.data;
	}, t.prototype.optionUpdated = function() {
		this.resetViewRoot();
	}, t.prototype.formatTooltip = function(e, t, n) {
		var r = this.getData(), i = this.getRawValue(e);
		return Oy("nameValue", {
			name: r.getName(e),
			value: i
		});
	}, t.prototype.getDataParams = function(t) {
		var n = e.prototype.getDataParams.apply(this, arguments);
		return n.treeAncestors = FP(this.getData().tree.getNodeByDataIndex(t), this), n.treePathInfo = n.treeAncestors, n;
	}, t.prototype.setLayoutInfo = function(e) {
		this.layoutInfo = this.layoutInfo || {}, M(this.layoutInfo, e);
	}, t.prototype.mapIdToIndex = function(e) {
		var t = this._idIndexMap;
		t || (t = this._idIndexMap = K(), this._idIndexMapCount = 0);
		var n = t.get(e);
		return n ?? t.set(e, n = this._idIndexMapCount++), n;
	}, t.prototype.getViewRoot = function() {
		return this._viewRoot;
	}, t.prototype.resetViewRoot = function(e) {
		e ? this._viewRoot = e : e = this._viewRoot;
		var t = this.getRawData().tree.root;
		(!e || e !== t && !t.contains(e)) && (this._viewRoot = t);
	}, t.prototype.enableAriaDecal = function() {
		RP(this);
	}, t.type = "series.treemap", t.layoutMode = "box", t.defaultOption = {
		progressive: 0,
		coordinateSystemUsage: "box",
		left: Q.size.l,
		top: Q.size.xxxl,
		right: Q.size.l,
		bottom: Q.size.xxxl,
		sort: !0,
		clipWindow: "origin",
		squareRatio: .5 * (1 + Math.sqrt(5)),
		leafDepth: null,
		drillDownIcon: "▶",
		zoomToNodeRatio: .1024,
		scaleLimit: {
			max: 5,
			min: .2
		},
		roam: !0,
		roamTrigger: "global",
		nodeClick: "zoomToNode",
		animation: !0,
		animationDurationUpdate: 900,
		animationEasing: "quinticInOut",
		breadcrumb: {
			show: !0,
			height: 22,
			left: "center",
			bottom: Q.size.m,
			emptyItemWidth: 25,
			itemStyle: {
				color: Q.color.backgroundShade,
				textStyle: { color: Q.color.secondary }
			},
			emphasis: { itemStyle: { color: Q.color.background } }
		},
		label: {
			show: !0,
			distance: 0,
			padding: 5,
			position: "inside",
			color: Q.color.neutral00,
			overflow: "truncate"
		},
		upperLabel: {
			show: !1,
			position: [0, "50%"],
			height: 20,
			overflow: "truncate",
			verticalAlign: "middle"
		},
		itemStyle: {
			color: null,
			colorAlpha: null,
			colorSaturation: null,
			borderWidth: 0,
			gapWidth: 0,
			borderColor: Q.color.neutral00,
			borderColorSaturation: null
		},
		emphasis: { upperLabel: {
			show: !0,
			position: [0, "50%"],
			overflow: "truncate",
			verticalAlign: "middle"
		} },
		visualDimension: 0,
		visualMin: null,
		visualMax: null,
		color: [],
		colorAlpha: null,
		colorSaturation: null,
		colorMappingBy: "index",
		visibleMin: 10,
		childrenVisibleMin: null,
		levels: []
	}, t;
}(Jy);
function BP(e) {
	var t = 0;
	I(e.children, function(e) {
		BP(e);
		var n = e.value;
		V(n) && (n = n[0]), t += n;
	});
	var n = e.value;
	V(n) && (n = n[0]), (n == null || isNaN(n)) && (n = t), n < 0 && (n = 0), V(e.value) ? e.value[0] = n : e.value = n;
}
function VP(e, t) {
	var n = ss(t.get("color")), r = ss(t.get([
		"aria",
		"decal",
		"decals"
	]));
	if (n) {
		e ||= [];
		var i, a;
		I(e, function(e) {
			var t = new ih(e), n = t.get("color"), r = t.get("decal");
			(t.get(["itemStyle", "color"]) || n && n !== "none") && (i = !0), (t.get(["itemStyle", "decal"]) || r && r !== "none") && (a = !0);
		});
		var o = e[0] || (e[0] = {});
		return i || (o.color = n.slice()), !a && r && (o.decal = r.slice()), e;
	}
}
//#endregion
//#region node_modules/echarts/lib/chart/treemap/Breadcrumb.js
var HP = 8, UP = 8, WP = 5, GP = function() {
	function e(e) {
		this.group = new Wa(), e.add(this.group);
	}
	return e.prototype.render = function(e, t, n, r) {
		var i = e.getModel("breadcrumb"), a = this.group;
		if (a.removeAll(), i.get("show") && n) {
			var o = i.getModel("itemStyle"), s = i.getModel("emphasis"), c = o.getModel("textStyle"), l = s.getModel(["itemStyle", "textStyle"]), u = Vg(e, t).refContainer, d = {
				left: i.get("left"),
				right: i.get("right"),
				top: i.get("top"),
				bottom: i.get("bottom")
			}, f = {
				emptyItemWidth: i.get("emptyItemWidth"),
				totalWidth: 0,
				renderList: []
			}, p = zg(d, u);
			this._prepare(n, f, c), this._renderContent(e, f, p, o, s, c, l, r), Hg(a, d, u);
		}
	}, e.prototype._prepare = function(e, t, n) {
		for (var r = e; r; r = r.parentNode) {
			var i = xs(r.getModel().get("name"), ""), a = n.getTextRect(i), o = Math.max(a.width + HP * 2, t.emptyItemWidth);
			t.totalWidth += o + UP, t.renderList.push({
				node: r,
				text: i,
				width: o
			});
		}
	}, e.prototype._renderContent = function(e, t, n, r, i, a, o, s) {
		for (var c = 0, l = t.emptyItemWidth, u = e.get(["breadcrumb", "height"]), d = t.totalWidth, f = t.renderList, p = i.getModel("itemStyle").getItemStyle(), m = f.length - 1; m >= 0; m--) {
			var h = f[m], g = h.node, _ = h.width, v = h.text;
			d > n.width && (d -= _ - l, _ = l, v = null);
			var y = new $f({
				shape: { points: KP(c, 0, _, u, m === f.length - 1, m === 0) },
				style: N(r.getItemStyle(), { lineJoin: "bevel" }),
				textContent: new Tu({ style: Fm(a, { text: v }) }),
				textConfig: { position: "inside" },
				z2: 1e5,
				onclick: B(s, g)
			});
			y.disableLabelAnimation = !0, y.getTextContent().ensureState("emphasis").style = Fm(o, { text: v }), y.ensureState("emphasis").style = p, qd(y, i.get("focus"), i.get("blurScope"), i.get("disabled")), this.group.add(y), qP(y, e, g), c += _ + UP;
		}
	}, e.prototype.remove = function() {
		this.group.removeAll();
	}, e;
}();
function KP(e, t, n, r, i, a) {
	var o = [
		[i ? e : e - WP, t],
		[e + n, t],
		[e + n, t + r],
		[i ? e : e - WP, t + r]
	];
	return !a && o.splice(2, 0, [e + n + WP, t + r / 2]), !i && o.push([e, t + r / 2]), o;
}
function qP(e, t, n) {
	Z(e).eventData = {
		componentType: "series",
		componentSubType: "treemap",
		componentIndex: t.componentIndex,
		seriesIndex: t.seriesIndex,
		seriesName: t.name,
		seriesType: "treemap",
		selfType: "breadcrumb",
		nodeData: {
			dataIndex: n && n.dataIndex,
			name: n && n.name
		},
		treePathInfo: n && FP(n, t)
	};
}
//#endregion
//#region node_modules/echarts/lib/util/animation.js
var JP = function() {
	function e() {
		this._storage = [], this._elExistsMap = {};
	}
	return e.prototype.add = function(e, t, n, r, i) {
		return !this._elExistsMap[e.id] && (this._elExistsMap[e.id] = !0, this._storage.push({
			el: e,
			target: t,
			duration: n,
			delay: r,
			easing: i
		}), !0);
	}, e.prototype.finished = function(e) {
		return this._finishedCallback = e, this;
	}, e.prototype.start = function() {
		for (var e = this, t = this._storage.length, n = function() {
			t--, t <= 0 && (e._storage.length = 0, e._elExistsMap = {}, e._finishedCallback && e._finishedCallback());
		}, r = 0, i = this._storage.length; r < i; r++) {
			var a = this._storage[r];
			a.el.animateTo(a.target, {
				duration: a.duration,
				delay: a.delay,
				easing: a.easing,
				setToFinal: !0,
				done: n,
				aborted: n
			});
		}
		return this;
	}, e;
}();
function YP() {
	return new JP();
}
//#endregion
//#region node_modules/echarts/lib/chart/treemap/treemapLayout.js
var XP = Math.max, ZP = Math.min, QP = I, $P = ["itemStyle", "borderWidth"], eF = ["itemStyle", "gapWidth"], tF = ["upperLabel", "show"], nF = ["upperLabel", "height"], rF = {
	seriesType: "treemap",
	reset: function(e, t, n, r) {
		var i = e.option, a = Vg(e, n).refContainer, o = zg(e.getBoxLayoutParams(), a), s = r && r.type, c = MP(r, ["treemapZoomToNode", "treemapRootToNode"], e), l = s === "treemapRender" || s === "treemapMove" ? r.rootRect : null, u = e.getViewRoot(), d = NP(u);
		if (s !== "treemapMove") {
			var f = !1, p = s === "treemapZoomToNode" ? (f = !0, dF(e, c, u, o)) : l ? (f = !0, M({}, l)) : M({}, o);
			if (f) {
				var m = hF(o, p);
				m = gF(m, e), p.width = o.width * m, p.height = o.height * m;
			}
			var h = i.sort;
			h && h !== "asc" && h !== "desc" && (h = "desc");
			var g = {
				squareRatio: i.squareRatio,
				sort: h,
				leafDepth: i.leafDepth
			};
			u.hostTree.clearLayouts();
			var _ = {
				x: 0,
				y: 0,
				width: p.width,
				height: p.height,
				area: p.width * p.height
			};
			u.setLayout(_), iF(u, g, !1, 0), _ = u.getLayout(), QP(d, function(e, t) {
				var n = (d[t + 1] || u).getValue();
				e.setLayout(M({
					dataExtent: [n, n],
					borderWidth: 0,
					upperHeight: 0
				}, _));
			});
		}
		var v = e.getData().tree.root;
		v.setLayout(fF(o, l, c), !0), e.setLayoutInfo(o), pF(v, new Y(-o.x, -o.y, n.getWidth(), n.getHeight()), d, u, 0);
	}
};
function iF(e, t, n, r) {
	var i, a;
	if (!e.isRemoved()) {
		var o = e.getLayout();
		i = o.width, a = o.height;
		var s = e.getModel(), c = s.get($P), l = s.get(eF) / 2, u = mF(s), d = Math.max(c, u), f = c - l, p = d - l;
		e.setLayout({
			borderWidth: c,
			upperHeight: d,
			upperLabelHeight: u
		}, !0), i = XP(i - 2 * f, 0), a = XP(a - f - p, 0);
		var m = i * a, h = aF(e, s, m, t, n, r);
		if (h.length) {
			var g = {
				x: f,
				y: p,
				width: i,
				height: a
			}, _ = ZP(i, a), v = Infinity, y = [];
			y.area = 0;
			for (var b = 0, x = h.length; b < x;) {
				var S = h[b];
				y.push(S), y.area += S.getLayout().area;
				var C = lF(y, _, t.squareRatio);
				C <= v ? (b++, v = C) : (y.area -= y.pop().getLayout().area, uF(y, _, g, l, !1), _ = ZP(g.width, g.height), y.length = y.area = 0, v = Infinity);
			}
			if (y.length && uF(y, _, g, l, !0), !n) {
				var w = s.get("childrenVisibleMin");
				w != null && m < w && (n = !0);
			}
			for (var b = 0, x = h.length; b < x; b++) iF(h[b], t, n, r + 1);
		}
	}
}
function aF(e, t, n, r, i, a) {
	var o = e.children || [], s = r.sort;
	s !== "asc" && s !== "desc" && (s = null);
	var c = r.leafDepth != null && r.leafDepth <= a;
	if (i && !c) return e.viewChildren = [];
	o = oe(o, function(e) {
		return !e.isRemoved();
	}), sF(o, s);
	var l = cF(t, o, s);
	if (l.sum === 0 || (l.sum = oF(t, n, l.sum, s, o), l.sum === 0)) return e.viewChildren = [];
	for (var u = 0, d = o.length; u < d; u++) {
		var f = o[u].getValue() / l.sum * n;
		o[u].setLayout({ area: f });
	}
	return c && (o.length && e.setLayout({ isLeafRoot: !0 }, !0), o.length = 0), e.viewChildren = o, e.setLayout({ dataExtent: l.dataExtent }, !0), o;
}
function oF(e, t, n, r, i) {
	if (!r) return n;
	for (var a = e.get("visibleMin"), o = i.length, s = o, c = o - 1; c >= 0; c--) {
		var l = i[r === "asc" ? o - c - 1 : c].getValue();
		l / n * t < a && (s = c, n -= l);
	}
	return r === "asc" ? i.splice(0, o - s) : i.splice(s, o - s), n;
}
function sF(e, t) {
	return t && e.sort(function(e, n) {
		var r = t === "asc" ? e.getValue() - n.getValue() : n.getValue() - e.getValue();
		return r === 0 ? t === "asc" ? e.dataIndex - n.dataIndex : n.dataIndex - e.dataIndex : r;
	}), e;
}
function cF(e, t, n) {
	for (var r = 0, i = 0, a = t.length; i < a; i++) r += t[i].getValue();
	var o = e.get("visualDimension"), s;
	return !t || !t.length ? s = [NaN, NaN] : o === "value" && n ? (s = [t[t.length - 1].getValue(), t[0].getValue()], n === "asc" && s.reverse()) : (s = zs(), QP(t, function(e) {
		var t = e.getValue(o);
		t < s[0] && (s[0] = t), t > s[1] && (s[1] = t);
	})), {
		sum: r,
		dataExtent: s
	};
}
function lF(e, t, n) {
	for (var r = 0, i = Infinity, a = 0, o = void 0, s = e.length; a < s; a++) o = e[a].getLayout().area, o && (o < i && (i = o), o > r && (r = o));
	var c = e.area * e.area, l = t * t * n;
	return c ? XP(l * r / c, c / (l * i)) : Infinity;
}
function uF(e, t, n, r, i) {
	var a = t === n.width ? 0 : 1, o = 1 - a, s = ["x", "y"], c = ["width", "height"], l = n[s[a]], u = t ? e.area / t : 0;
	(i || u > n[c[o]]) && (u = n[c[o]]);
	for (var d = 0, f = e.length; d < f; d++) {
		var p = e[d], m = {}, h = u ? p.getLayout().area / u : 0, g = m[c[o]] = XP(u - 2 * r, 0), _ = n[s[a]] + n[c[a]] - l, v = d === f - 1 || _ < h ? _ : h, y = m[c[a]] = XP(v - 2 * r, 0);
		m[s[o]] = n[s[o]] + ZP(r, g / 2), m[s[a]] = l + ZP(r, y / 2), l += v, p.setLayout(m, !0);
	}
	n[s[o]] += u, n[c[o]] -= u;
}
function dF(e, t, n, r) {
	var i = (t || {}).node, a = r.width, o = r.height, s = M({}, r);
	if (!i || i === n) return s;
	for (var c, l = a * o, u = l * e.option.zoomToNodeRatio; c = i.parentNode;) {
		for (var d = 0, f = c.children, p = 0, m = f.length; p < m; p++) d += f[p].getValue();
		var h = i.getValue();
		if (h === 0) return s;
		u *= d / h;
		var g = c.getModel(), _ = g.get($P), v = Math.max(_, mF(g));
		u += 4 * _ * _ + (3 * _ + v) * u ** .5, u > Io && (u = Io), i = c;
	}
	u < l && (u = l);
	var y = (u / l) ** .5;
	return {
		width: a * y,
		height: o * y
	};
}
function fF(e, t, n) {
	if (t) return {
		x: t.x,
		y: t.y
	};
	var r = {
		x: 0,
		y: 0
	};
	if (!n) return r;
	var i = n.node, a = i.getLayout();
	if (!a) return r;
	for (var o = [a.width / 2, a.height / 2], s = i; s;) {
		var c = s.getLayout();
		o[0] += c.x, o[1] += c.y, s = s.parentNode;
	}
	return {
		x: e.width / 2 - o[0],
		y: e.height / 2 - o[1]
	};
}
function pF(e, t, n, r, i) {
	var a = e.getLayout(), o = n[i], s = o && o === e;
	if (!(o && !s || i === n.length && e !== r)) {
		e.setLayout({
			isInView: !0,
			invisible: !s && !t.intersect(a),
			isAboveViewRoot: s
		}, !0);
		var c = new Y(t.x - a.x, t.y - a.y, t.width, t.height);
		QP(e.viewChildren || [], function(e) {
			pF(e, c, n, r, i + 1);
		});
	}
}
function mF(e) {
	return e.get(tF) ? e.get(nF) : 0;
}
function hF(e, t) {
	return t.width / e.width || t.height / e.height || 1;
}
function gF(e, t) {
	return vP(e, t.get("scaleLimit", !0));
}
//#endregion
//#region node_modules/echarts/lib/chart/treemap/TreemapView.js
var _F = Wa, vF = bu, yF = 3, bF = "label", xF = "upperLabel", SF = 100, CF = 20, wF = 30, TF = _c([
	["fill", "color"],
	["stroke", "strokeColor"],
	["lineWidth", "strokeWidth"],
	["shadowBlur"],
	["shadowOffsetX"],
	["shadowOffsetY"],
	["shadowColor"]
]), EF = function(e) {
	var t = TF(e);
	return t.stroke = t.fill = t.lineWidth = null, t;
}, DF = X(), OF = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n._state = "ready", n._storage = kF(), n;
	}
	return t.prototype.render = function(e, t, n, r) {
		if (!(P(t.findComponents({
			mainType: "series",
			subType: "treemap",
			query: r
		}), e) < 0)) {
			this.seriesModel = e, this.api = n, this.ecModel = t;
			var i = MP(r, ["treemapZoomToNode", "treemapRootToNode"], e), a = r && r.type, o = e.layoutInfo, s = !this._oldTree, c = this._storage, l = a === "treemapRootToNode" && i && c ? {
				rootNodeGroup: c.nodeGroup[i.node.getRawIndex()],
				direction: r.direction
			} : null, u = this._giveContainerGroup(o), d = e.get("animation"), f = this._doRender(u, e, l);
			d && !s && (!a || a === "treemapZoomToNode" || a === "treemapRootToNode") ? this._doAnimation(u, f, e, l) : f.renderFinally(), this._resetController(n), this._renderBreadcrumb(e, n, i);
		}
	}, t.prototype._giveContainerGroup = function(e) {
		var t = this._containerGroup;
		return t || (t = this._containerGroup = new _F(), this._initEvents(t), this.group.add(t)), t.x = e.x, t.y = e.y, t;
	}, t.prototype._doRender = function(e, t, n) {
		var r = t.getData().tree, i = this._oldTree, a = kF(), o = kF(), s = this._storage, c = [];
		function l(e, r, i, l) {
			return AF(t, o, s, n, a, c, e, r, i, l);
		}
		d(r.root ? [r.root] : [], i && i.root ? [i.root] : [], e, r === i || !i, 0);
		var u = f(s);
		return this._oldTree = r, this._storage = o, {
			lastsForAnimation: a,
			willDeleteEls: u,
			renderFinally: p
		};
		function d(e, t, n, r, i) {
			r ? (t = e, I(e, function(e, t) {
				!e.isRemoved() && o(t, t);
			})) : new gw(t, e, a, a).add(o).update(o).remove(B(o, null)).execute();
			function a(e) {
				return e.getId();
			}
			function o(a, o) {
				var s = a == null ? null : e[a], c = o == null ? null : t[o], u = l(s, c, n, i);
				u && d(s && s.viewChildren || [], c && c.viewChildren || [], u, r, i + 1);
			}
		}
		function f(e) {
			var t = kF();
			return e && I(e, function(e, n) {
				var r = t[n];
				I(e, function(e) {
					e && (r.push(e), DF(e).willDelete = !0);
				});
			}), t;
		}
		function p() {
			I(u, function(e) {
				I(e, function(e) {
					e.parent && e.parent.remove(e);
				});
			}), I(c, function(e) {
				e.invisible = !0, e.dirty();
			});
		}
	}, t.prototype._doAnimation = function(e, t, n, r) {
		var i = n.get("animationDurationUpdate"), a = n.get("animationEasing"), o = (H(i) ? 0 : i) || 0, s = (H(a) ? null : a) || "cubicOut", c = YP();
		I(t.willDeleteEls, function(e, t) {
			I(e, function(e, n) {
				if (!e.invisible) {
					var i = e.parent, a, l = DF(i);
					if (r && r.direction === "drillDown") a = i === r.rootNodeGroup ? {
						shape: {
							x: 0,
							y: 0,
							width: l.nodeWidth,
							height: l.nodeHeight
						},
						style: { opacity: 0 }
					} : { style: { opacity: 0 } };
					else {
						var u = 0, d = 0;
						l.willDelete || (u = l.nodeWidth / 2, d = l.nodeHeight / 2), a = t === "nodeGroup" ? {
							x: u,
							y: d,
							style: { opacity: 0 }
						} : {
							shape: {
								x: u,
								y: d,
								width: 0,
								height: 0
							},
							style: { opacity: 0 }
						};
					}
					a && c.add(e, a, o, 0, s);
				}
			});
		}), I(this._storage, function(e, n) {
			I(e, function(e, r) {
				var i = t.lastsForAnimation[n][r], a = {};
				i && (e instanceof Wa ? i.oldX != null && (a.x = e.x, a.y = e.y, e.x = i.oldX, e.y = i.oldY) : (i.oldShape && (a.shape = M({}, e.shape), e.setShape(i.oldShape)), i.fadein ? (e.setStyle("opacity", 0), a.style = { opacity: 1 }) : e.style.opacity !== 1 && (a.style = { opacity: 1 })), c.add(e, a, o, 0, s));
			});
		}, this), this._state = "animating", c.finished(z(function() {
			this._state = "ready", t.renderFinally();
		}, this)).start();
	}, t.prototype._resetController = function(e) {
		var t = this, n = this.seriesModel, r = this._controller;
		r || (r = this._controller = new nP(e.getZr()), r.on("pan", z(this._onPan, this)), r.on("zoom", z(this._onZoom, this))), r.enable(n.get("roam"), {
			api: e,
			zInfo: { component: n },
			triggerInfo: {
				roamTrigger: n.get("roamTrigger"),
				isInSelf: function(e, n, r) {
					var i = t._containerGroup;
					return i ? i.getBoundingRect().contain(n - i.x, r - i.y) : !1;
				}
			}
		});
	}, t.prototype._clearController = function() {
		var e = this._controller;
		e &&= (e.dispose(), null);
	}, t.prototype._onPan = function(e) {
		if (this._state !== "animating" && (Math.abs(e.dx) > yF || Math.abs(e.dy) > yF)) {
			var t = this.seriesModel.getData().tree.root;
			if (!t) return;
			var n = t.getLayout();
			if (!n) return;
			this.api.dispatchAction({
				type: "treemapMove",
				from: this.uid,
				seriesId: this.seriesModel.id,
				rootRect: {
					x: n.x + e.dx,
					y: n.y + e.dy,
					width: n.width,
					height: n.height
				}
			});
		}
	}, t.prototype._onZoom = function(e) {
		var t = e.originX, n = e.originY, r = e.scale, i = this.seriesModel;
		if (this._state !== "animating") {
			var a = i.getData().tree.root;
			if (!a) return;
			var o = a.getLayout();
			if (!o) return;
			var s = new Y(o.x, o.y, o.width, o.height), c = i.layoutInfo, l = hF(c, o), u = l * r;
			u = gF(u, i);
			var d = u / l;
			t -= c.x, n -= c.y;
			var f = Ut();
			qt(f, f, [-t, -n]), Yt(f, f, [d, d]), qt(f, f, [t, n]), s.applyTransform(f), this.api.dispatchAction({
				type: "treemapRender",
				from: this.uid,
				seriesId: this.seriesModel.id,
				rootRect: {
					x: s.x,
					y: s.y,
					width: s.width,
					height: s.height
				}
			});
		}
	}, t.prototype._initEvents = function(e) {
		var t = this;
		e.on("click", function(e) {
			if (t._state === "ready") {
				var n = t.seriesModel.get("nodeClick", !0);
				if (n) {
					var r = t.findTarget(e.offsetX, e.offsetY);
					if (r) {
						var i = r.node;
						if (i.getLayout().isLeafRoot) t._rootToNode(r);
						else if (n === "zoomToNode") t._zoomToNode(r);
						else if (n === "link") {
							var a = i.hostTree.data.getItemModel(i.dataIndex), o = a.get("link", !0), s = a.get("target", !0) || "blank";
							o && xg(o, s);
						}
					}
				}
			}
		}, this);
	}, t.prototype._renderBreadcrumb = function(e, t, n) {
		var r = this;
		n || (n = e.get("leafDepth", !0) == null ? this.findTarget(t.getWidth() / 2, t.getHeight() / 2) : { node: e.getViewRoot() }, n ||= { node: e.getData().tree.root }), (this._breadcrumb ||= new GP(this.group)).render(e, t, n.node, function(t) {
			r._state !== "animating" && (PP(e.getViewRoot(), t) ? r._rootToNode({ node: t }) : r._zoomToNode({ node: t }));
		});
	}, t.prototype.remove = function() {
		this._clearController(), this._containerGroup && this._containerGroup.removeAll(), this._storage = kF(), this._state = "ready", this._breadcrumb && this._breadcrumb.remove();
	}, t.prototype.dispose = function() {
		this._clearController();
	}, t.prototype._zoomToNode = function(e) {
		this.api.dispatchAction({
			type: "treemapZoomToNode",
			from: this.uid,
			seriesId: this.seriesModel.id,
			targetNode: e.node
		});
	}, t.prototype._rootToNode = function(e) {
		this.api.dispatchAction({
			type: "treemapRootToNode",
			from: this.uid,
			seriesId: this.seriesModel.id,
			targetNode: e.node
		});
	}, t.prototype.findTarget = function(e, t) {
		var n;
		return this.seriesModel.getViewRoot().eachNode({
			attr: "viewChildren",
			order: "preorder"
		}, function(r) {
			var i = this._storage.background[r.getRawIndex()];
			if (i) {
				var a = i.transformCoordToLocal(e, t), o = i.shape;
				if (o.x <= a[0] && a[0] <= o.x + o.width && o.y <= a[1] && a[1] <= o.y + o.height) n = {
					node: r,
					offsetX: a[0],
					offsetY: a[1]
				};
				else return !1;
			}
		}, this), n;
	}, t.type = "treemap", t;
}(sb);
function kF() {
	return {
		nodeGroup: [],
		background: [],
		content: []
	};
}
function AF(e, t, n, r, i, a, o, s, c, l) {
	if (!o) return;
	var u = o.getLayout(), d = e.getData(), f = o.getModel();
	if (d.setItemGraphicEl(o.dataIndex, null), !u || !u.isInView) return;
	var p = u.width, m = u.height, h = u.borderWidth, g = u.invisible, _ = o.getRawIndex(), v = s && s.getRawIndex(), y = o.viewChildren, b = u.upperHeight, x = y && y.length, S = f.getModel("itemStyle"), C = f.getModel(["emphasis", "itemStyle"]), w = f.getModel(["blur", "itemStyle"]), T = f.getModel(["select", "itemStyle"]), E = S.get("borderRadius") || 0, D = L("nodeGroup", _F);
	if (!D) return;
	if (c.add(D), D.x = u.x || 0, D.y = u.y || 0, D.markRedraw(), DF(D).nodeWidth = p, DF(D).nodeHeight = m, u.isAboveViewRoot) return D;
	var O = L("background", vF, l, CF);
	O && P(D, O, x && u.upperLabelHeight);
	var k = f.getModel("emphasis"), A = k.get("focus"), j = k.get("blurScope"), ee = k.get("disabled"), te = A === "ancestor" ? o.getAncestorsIndices() : A === "descendant" ? o.getDescendantIndices() : A;
	if (x) $d(D) && Qd(D, !1), O && (Qd(O, !ee), d.setItemGraphicEl(o.dataIndex, O), Jd(O, te, j));
	else {
		var N = L("content", vF, l, wF);
		N && re(D, N), O.disableMorphing = !0, O && $d(O) && Qd(O, !1), Qd(D, !ee), d.setItemGraphicEl(o.dataIndex, D);
		var ne = f.getShallow("cursor");
		ne && N.attr("cursor", ne), Jd(D, te, j);
	}
	return D;
	function P(t, n, r) {
		var i = Z(n);
		if (i.dataIndex = o.dataIndex, i.seriesIndex = e.seriesIndex, n.setShape({
			x: 0,
			y: 0,
			width: p,
			height: m,
			r: E
		}), g) F(n);
		else {
			n.invisible = !1;
			var a = o.getVisual("style"), s = a.stroke, c = EF(S);
			c.fill = s;
			var l = TF(C);
			l.fill = C.get("borderColor");
			var u = TF(w);
			u.fill = w.get("borderColor");
			var d = TF(T);
			if (d.fill = T.get("borderColor"), r) {
				var f = p - 2 * h;
				ie(n, s, a.opacity, {
					x: h,
					y: 0,
					width: f,
					height: b
				});
			} else n.removeTextContent();
			n.setStyle(c), n.ensureState("emphasis").style = l, n.ensureState("blur").style = u, n.ensureState("select").style = d, Td(n);
		}
		t.add(n);
	}
	function re(t, n) {
		var r = Z(n);
		r.dataIndex = o.dataIndex, r.seriesIndex = e.seriesIndex;
		var i = Math.max(p - 2 * h, 0), a = Math.max(m - 2 * h, 0);
		if (n.culling = !0, n.setShape({
			x: h,
			y: h,
			width: i,
			height: a,
			r: E
		}), g) F(n);
		else {
			n.invisible = !1;
			var s = o.getVisual("style"), c = s.fill, l = EF(S);
			l.fill = c, l.decal = s.decal;
			var u = TF(C), d = TF(w), f = TF(T);
			ie(n, c, s.opacity, null), n.setStyle(l), n.ensureState("emphasis").style = u, n.ensureState("blur").style = d, n.ensureState("select").style = f, Td(n);
		}
		t.add(n);
	}
	function F(e) {
		!e.invisible && a.push(e);
	}
	function ie(t, n, r, i) {
		var a = f.getModel(i ? xF : bF), s = xs(f.get("name"), null), c = a.getShallow("show");
		Nm(t, Pm(f, i ? xF : bF), {
			defaultText: c ? s : null,
			inheritColor: n,
			defaultOpacity: r,
			labelFetcher: e,
			labelDataIndex: o.dataIndex
		});
		var l = t.getTextContent();
		if (l) {
			var d = l.style, p = xe(d.padding || 0);
			i && (t.setTextConfig({ layoutRect: i }), l.disableLabelLayout = !0), l.beforeUpdate = function() {
				var e = Math.max((i ? i.width : t.shape.width) - p[1] - p[3], 0), n = Math.max((i ? i.height : t.shape.height) - p[0] - p[2], 0);
				(d.width !== e || d.height !== n) && l.setStyle({
					width: e,
					height: n
				});
			}, d.truncateMinChar = 2, d.lineOverflow = "truncate", I(d, i, u);
			var m = l.getState("emphasis");
			I(m ? m.style : null, i, u);
		}
	}
	function I(t, n, r) {
		var i = t ? t.text : null;
		if (!n && r.isLeafRoot && i != null) {
			var a = e.get("drillDownIcon", !0);
			t.text = a ? a + " " + i : i;
		}
	}
	function L(e, r, a, o) {
		var s = v != null && n[e][v], c = i[e];
		return s ? (n[e][v] = null, ae(c, s)) : g || (s = new r(), s instanceof $c && (s.z2 = jF(a, o)), oe(c, s)), t[e][_] = s;
	}
	function ae(e, t) {
		var n = e[_] = {};
		t instanceof _F ? (n.oldX = t.x, n.oldY = t.y) : n.oldShape = M({}, t.shape);
	}
	function oe(e, t) {
		var n = e[_] = {}, a = o.parentNode, s = t instanceof Wa;
		if (a && (!r || r.direction === "drillDown")) {
			var c = 0, l = 0, u = i.background[a.getRawIndex()];
			!r && u && u.oldShape && (c = u.oldShape.width, l = u.oldShape.height), s ? (n.oldX = 0, n.oldY = l) : n.oldShape = {
				x: c,
				y: l,
				width: 0,
				height: 0
			};
		}
		n.fadein = !s;
	}
}
function jF(e, t) {
	return e * SF + t;
}
//#endregion
//#region node_modules/echarts/lib/visual/VisualMapping.js
var MF = I, NF = W, PF = -1, FF = function() {
	function e(t) {
		var n = t.mappingMethod, r = t.type, i = this.option = A(t);
		this.type = r, this.mappingMethod = n, this._normalizeData = qF[n];
		var a = e.visualHandlers[r];
		this.applyVisual = a.applyVisual, this.getColorMapper = a.getColorMapper, this._normalizedToVisual = a._normalizedToVisual[n], n === "piecewise" ? (RF(i), IF(i)) : n === "category" ? i.categories ? LF(i) : RF(i, !0) : (Se(n !== "linear" || i.dataExtent), RF(i));
	}
	return e.prototype.mapValueToVisual = function(e) {
		var t = this._normalizeData(e);
		return this._normalizedToVisual(t, e);
	}, e.prototype.getNormalizer = function() {
		return z(this._normalizeData, this);
	}, e.listVisualTypes = function() {
		return R(e.visualHandlers);
	}, e.isValidType = function(t) {
		return e.visualHandlers.hasOwnProperty(t);
	}, e.eachVisual = function(e, t, n) {
		W(e) ? I(e, t, n) : t.call(n, e);
	}, e.mapVisual = function(t, n, r) {
		var i, a = V(t) ? [] : W(t) ? {} : (i = !0, null);
		return e.eachVisual(t, function(e, t) {
			var o = n.call(r, e, t);
			i ? a = o : a[t] = o;
		}), a;
	}, e.retrieveVisuals = function(t) {
		var n = {}, r;
		return t && MF(e.visualHandlers, function(e, i) {
			t.hasOwnProperty(i) && (n[i] = t[i], r = !0);
		}), r ? n : null;
	}, e.prepareVisualTypes = function(e) {
		if (V(e)) e = e.slice();
		else if (NF(e)) {
			var t = [];
			MF(e, function(e, n) {
				t.push(n);
			}), e = t;
		} else return [];
		return e.sort(function(e, t) {
			return t === "color" && e !== "color" && e.indexOf("color") === 0 ? 1 : -1;
		}), e;
	}, e.dependsOn = function(e, t) {
		return t === "color" ? !!(e && e.indexOf(t) === 0) : e === t;
	}, e.findPieceIndex = function(e, t, n) {
		for (var r, i = Infinity, a = 0, o = t.length; a < o; a++) {
			var s = t[a].value;
			if (s != null) {
				if (s === e || U(s) && s === e + "") return a;
				n && d(s, a);
			}
		}
		for (var a = 0, o = t.length; a < o; a++) {
			var c = t[a], l = c.interval, u = c.close;
			if (l) {
				if (l[0] === -Infinity) {
					if (JF(u[1], e, l[1])) return a;
				} else if (l[1] === Infinity) {
					if (JF(u[0], l[0], e)) return a;
				} else if (JF(u[0], l[0], e) && JF(u[1], e, l[1])) return a;
				n && d(l[0], a), n && d(l[1], a);
			}
		}
		if (n) return e === Infinity ? t.length - 1 : e === -Infinity ? 0 : r;
		function d(t, n) {
			var a = Math.abs(t - e);
			a < i && (i = a, r = n);
		}
	}, e.visualHandlers = {
		color: {
			applyVisual: VF("color"),
			getColorMapper: function() {
				var e = this.option;
				return z(e.mappingMethod === "category" ? function(e, t) {
					return !t && (e = this._normalizeData(e)), HF.call(this, e);
				} : function(t, n, r) {
					var i = !!r;
					return !n && (t = this._normalizeData(t)), r = Kr(t, e.parsedVisual, r), i ? r : Qr(r, "rgba");
				}, this);
			},
			_normalizedToVisual: {
				linear: function(e) {
					return Qr(Kr(e, this.option.parsedVisual), "rgba");
				},
				category: HF,
				piecewise: function(e, t) {
					var n = GF.call(this, t);
					return n ??= Qr(Kr(e, this.option.parsedVisual), "rgba"), n;
				},
				fixed: UF
			}
		},
		colorHue: zF(function(e, t) {
			return Xr(e, t);
		}),
		colorSaturation: zF(function(e, t) {
			return Xr(e, null, t);
		}),
		colorLightness: zF(function(e, t) {
			return Xr(e, null, null, t);
		}),
		colorAlpha: zF(function(e, t) {
			return Zr(e, t);
		}),
		decal: {
			applyVisual: VF("decal"),
			_normalizedToVisual: {
				linear: null,
				category: HF,
				piecewise: null,
				fixed: null
			}
		},
		opacity: {
			applyVisual: VF("opacity"),
			_normalizedToVisual: WF([0, 1])
		},
		liftZ: {
			applyVisual: VF("liftZ"),
			_normalizedToVisual: {
				linear: UF,
				category: UF,
				piecewise: UF,
				fixed: UF
			}
		},
		symbol: {
			applyVisual: function(e, t, n) {
				n("symbol", this.mapValueToVisual(e));
			},
			_normalizedToVisual: {
				linear: BF,
				category: HF,
				piecewise: function(e, t) {
					var n = GF.call(this, t);
					return n ??= BF.call(this, e), n;
				},
				fixed: UF
			}
		},
		symbolSize: {
			applyVisual: VF("symbolSize"),
			_normalizedToVisual: WF([0, 1])
		}
	}, e;
}();
function IF(e) {
	var t = e.pieceList;
	e.hasSpecialVisual = !1, I(t, function(t, n) {
		t.originIndex = n, t.visual != null && (e.hasSpecialVisual = !0);
	});
}
function LF(e) {
	var t = e.categories, n = e.categoryMap = {}, r = e.visual;
	if (MF(t, function(e, t) {
		n[e] = t;
	}), !V(r)) {
		var i = [];
		W(r) ? MF(r, function(e, t) {
			var r = n[t];
			i[r ?? PF] = e;
		}) : i[PF] = r, r = KF(e, i);
	}
	for (var a = t.length - 1; a >= 0; a--) r[a] ?? (delete n[t[a]], t.pop());
}
function RF(e, t) {
	var n = e.visual, r = [];
	W(n) ? MF(n, function(e) {
		r.push(e);
	}) : n != null && r.push(n), !t && r.length === 1 && !{
		color: 1,
		symbol: 1
	}.hasOwnProperty(e.type) && (r[1] = r[0]), KF(e, r);
}
function zF(e) {
	return {
		applyVisual: function(t, n, r) {
			var i = this.mapValueToVisual(t);
			r("color", e(n("color"), i));
		},
		_normalizedToVisual: WF([0, 1])
	};
}
function BF(e) {
	var t = this.option.visual;
	return t[Math.round(xo(e, [0, 1], [0, t.length - 1], !0))] || {};
}
function VF(e) {
	return function(t, n, r) {
		r(e, this.mapValueToVisual(t));
	};
}
function HF(e) {
	var t = this.option.visual;
	return t[this.option.loop && e !== PF ? e % t.length : e];
}
function UF() {
	return this.option.visual[0];
}
function WF(e) {
	return {
		linear: function(t) {
			return xo(t, e, this.option.visual, !0);
		},
		category: HF,
		piecewise: function(t, n) {
			var r = GF.call(this, n);
			return r ??= xo(t, e, this.option.visual, !0), r;
		},
		fixed: UF
	};
}
function GF(e) {
	var t = this.option, n = t.pieceList;
	if (t.hasSpecialVisual) {
		var r = n[FF.findPieceIndex(e, n)];
		if (r && r.visual) return r.visual[this.type];
	}
}
function KF(e, t) {
	return e.visual = t, e.type === "color" && (e.parsedVisual = L(t, function(e) {
		return Vr(e) || [
			0,
			0,
			0,
			1
		];
	})), t;
}
var qF = {
	linear: function(e) {
		return xo(e, this.option.dataExtent, [0, 1], !0);
	},
	piecewise: function(e) {
		var t = this.option.pieceList, n = FF.findPieceIndex(e, t, !0);
		if (n != null) return xo(n, [0, t.length - 1], [0, 1], !0);
	},
	category: function(e) {
		return (this.option.categories ? this.option.categoryMap[e] : e) ?? PF;
	},
	fixed: Pe
};
function JF(e, t, n) {
	return e ? t <= n : t < n;
}
//#endregion
//#region node_modules/echarts/lib/chart/treemap/treemapVisual.js
var YF = "itemStyle", XF = X(), ZF = {
	seriesType: "treemap",
	reset: function(e) {
		var t = e.getData().tree.root;
		t.isRemoved() || QF(t, {}, e.getViewRoot().getAncestors(), e);
	}
};
function QF(e, t, n, r) {
	var i = e.getModel(), a = e.getLayout(), o = e.hostTree.data;
	if (a && !a.invisible && a.isInView) {
		var s = i.getModel(YF), c = $F(s, t, r), l = o.ensureUniqueItemVisual(e.dataIndex, "style"), u = s.get("borderColor"), d = s.get("borderColorSaturation"), f;
		d != null && (f = eI(c), u = tI(d, f)), l.stroke = u;
		var p = e.viewChildren;
		if (!p || !p.length) f = eI(c), l.fill = f;
		else {
			var m = rI(e, i, a, s, c, p);
			I(p, function(e, t) {
				(e.depth >= n.length || e === n[e.depth]) && QF(e, aI(i, c, e, t, m, r), n, r);
			});
		}
	}
}
function $F(e, t, n) {
	var r = M({}, t), i = n.designatedVisualItemStyle;
	return I([
		"color",
		"colorAlpha",
		"colorSaturation"
	], function(n) {
		i[n] = t[n];
		var a = e.get(n);
		i[n] = null, a != null && (r[n] = a);
	}), r;
}
function eI(e) {
	var t = nI(e, "color");
	if (t) {
		var n = nI(e, "colorAlpha"), r = nI(e, "colorSaturation");
		return r && (t = Xr(t, null, null, r)), n && (t = Zr(t, n)), t;
	}
}
function tI(e, t) {
	return t == null ? null : Xr(t, null, null, e);
}
function nI(e, t) {
	var n = e[t];
	if (n != null && n !== "none") return n;
}
function rI(e, t, n, r, i, a) {
	if (a && a.length) {
		var o = iI(t, "color") || i.color != null && i.color !== "none" && (iI(t, "colorAlpha") || iI(t, "colorSaturation"));
		if (o) {
			var s = t.get("visualMin"), c = t.get("visualMax"), l = n.dataExtent.slice();
			s != null && s < l[0] && (l[0] = s), c != null && c > l[1] && (l[1] = c);
			var u = t.get("colorMappingBy"), d = {
				type: o.name,
				dataExtent: l,
				visual: o.range
			};
			d.type === "color" && (u === "index" || u === "id") ? (d.mappingMethod = "category", d.loop = !0) : d.mappingMethod = "linear";
			var f = new FF(d);
			return XF(f).drColorMappingBy = u, f;
		}
	}
}
function iI(e, t) {
	var n = e.get(t);
	return V(n) && n.length ? {
		name: t,
		range: n
	} : null;
}
function aI(e, t, n, r, i, a) {
	var o = M({}, t);
	if (i) {
		var s = i.type, c = s === "color" && XF(i).drColorMappingBy, l = c === "index" ? r : c === "id" ? a.mapIdToIndex(n.getId()) : n.getValue(e.get("visualDimension"));
		o[s] = i.mapValueToVisual(l);
	}
	return o;
}
//#endregion
//#region node_modules/echarts/lib/chart/treemap/install.js
function oI(e) {
	e.registerSeriesModel(zP), e.registerChartView(OF), e.registerVisual(ZF), e.registerLayout(rF), LP(e);
}
//#endregion
//#region node_modules/echarts/lib/chart/helper/LinePath.js
var sI = ip.prototype, cI = cp.prototype, lI = function() {
	function e() {
		this.x1 = 0, this.y1 = 0, this.x2 = 0, this.y2 = 0, this.percent = 1;
	}
	return e;
}();
(function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t;
})(lI);
function uI(e) {
	return isNaN(+e.cpx1) || isNaN(+e.cpy1);
}
var dI = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this, t) || this;
		return n.type = "ec-line", n;
	}
	return t.prototype.getDefaultStyle = function() {
		return {
			stroke: Q.color.neutral99,
			fill: null
		};
	}, t.prototype.getDefaultShape = function() {
		return new lI();
	}, t.prototype.buildPath = function(e, t) {
		uI(t) ? sI.buildPath.call(this, e, t) : cI.buildPath.call(this, e, t);
	}, t.prototype.pointAt = function(e) {
		return uI(this.shape) ? sI.pointAt.call(this, e) : cI.pointAt.call(this, e);
	}, t.prototype.tangentAt = function(e) {
		var t = this.shape, n = uI(t) ? [t.x2 - t.x1, t.y2 - t.y1] : cI.tangentAt.call(this, e);
		return $e(n, n);
	}, t;
}(ou), fI = ["fromSymbol", "toSymbol"];
function pI(e) {
	return "_" + e + "Type";
}
function mI(e, t, n) {
	var r = t.getItemVisual(n, e);
	if (!r || r === "none") return r;
	var i = t.getItemVisual(n, e + "Size"), a = t.getItemVisual(n, e + "Rotate"), o = t.getItemVisual(n, e + "Offset"), s = t.getItemVisual(n, e + "KeepAspect"), c = kx(i), l = Ax(o || 0, c);
	return r + c + l + (a || "") + (s || "");
}
function hI(e, t, n) {
	var r = t.getItemVisual(n, e);
	if (r && r !== "none") {
		var i = t.getItemVisual(n, e + "Size"), a = t.getItemVisual(n, e + "Rotate"), o = t.getItemVisual(n, e + "Offset"), s = t.getItemVisual(n, e + "KeepAspect"), c = kx(i), l = Ax(o || 0, c), u = Ox(r, -c[0] / 2 + l[0], -c[1] / 2 + l[1], c[0], c[1], null, s);
		return u.__specifiedRotation = a == null || isNaN(a) ? void 0 : a * Math.PI / 180 || 0, u.name = e, u;
	}
}
function gI(e) {
	var t = new dI({
		name: "line",
		subPixelOptimize: !0
	});
	return _I(t.shape, e), t;
}
function _I(e, t) {
	e.x1 = t[0][0], e.y1 = t[0][1], e.x2 = t[1][0], e.y2 = t[1][1], e.percent = 1;
	var n = t[2];
	n ? (e.cpx1 = n[0], e.cpy1 = n[1]) : (e.cpx1 = NaN, e.cpy1 = NaN);
}
var vI = function(e) {
	n(t, e);
	function t(t, n, r) {
		var i = e.call(this) || this;
		return i._createLine(t, n, r), i;
	}
	return t.prototype._createLine = function(e, t, n) {
		var r = e.hostModel, i = e.getItemLayout(t), a = e.getItemVisual(t, "z2"), o = gI(i);
		o.shape.percent = 0, Ap(o, {
			z2: G(a, 0),
			shape: { percent: 1 }
		}, r, t), this.add(o), I(fI, function(n) {
			var r = hI(n, e, t);
			this.add(r), this[pI(n)] = mI(n, e, t);
		}, this), this._updateCommonStl(e, t, n);
	}, t.prototype.updateData = function(e, t, n) {
		var r = e.hostModel, i = this.childOfName("line"), a = e.getItemLayout(t), o = { shape: {} };
		_I(o.shape, a), kp(i, o, r, t), I(fI, function(n) {
			var r = mI(n, e, t), i = pI(n);
			if (this[i] !== r) {
				this.remove(this.childOfName(n));
				var a = hI(n, e, t);
				this.add(a);
			}
			this[i] = r;
		}, this), this._updateCommonStl(e, t, n);
	}, t.prototype.getLinePath = function() {
		return this.childAt(0);
	}, t.prototype._updateCommonStl = function(e, t, n) {
		var r = e.hostModel, i = this.childOfName("line"), a = n && n.emphasisLineStyle, o = n && n.blurLineStyle, s = n && n.selectLineStyle, c = n && n.labelStatesModels, l = n && n.emphasisDisabled, u = n && n.focus, d = n && n.blurScope;
		if (!n || e.hasItemOption) {
			var f = e.getItemModel(t), p = f.getModel("emphasis");
			a = p.getModel("lineStyle").getLineStyle(), o = f.getModel(["blur", "lineStyle"]).getLineStyle(), s = f.getModel(["select", "lineStyle"]).getLineStyle(), l = p.get("disabled"), u = p.get("focus"), d = p.get("blurScope"), c = Pm(f);
		}
		var m = e.getItemVisual(t, "style"), h = m.stroke;
		i.useStyle(m), i.style.fill = null, i.style.strokeNoScale = !0, i.ensureState("emphasis").style = a, i.ensureState("blur").style = o, i.ensureState("select").style = s, I(fI, function(e) {
			var t = this.childOfName(e);
			if (t) {
				t.setColor(h), t.style.opacity = m.opacity;
				for (var n = 0; n < td.length; n++) {
					var r = td[n], a = i.getState(r);
					if (a) {
						var o = a.style || {}, s = t.ensureState(r), c = s.style ||= {};
						o.stroke != null && (c[t.__isEmptyBrush ? "stroke" : "fill"] = o.stroke), o.opacity != null && (c.opacity = o.opacity);
					}
				}
				t.markRedraw();
			}
		}, this);
		var g = r.getRawValue(t);
		Nm(this, c, {
			labelDataIndex: t,
			labelFetcher: { getFormattedLabel: function(t, n) {
				return r.getFormattedLabel(t, n, e.dataType);
			} },
			inheritColor: h || Q.color.neutral99,
			defaultOpacity: m.opacity,
			defaultText: (g == null ? e.getName(t) : isFinite(g) ? Eo(g, 10) : g) + ""
		});
		var _ = this.getTextContent();
		if (_) {
			var v = c.normal;
			_.__align = _.style.align, _.__verticalAlign = _.style.verticalAlign, _.__position = v.get("position") || "middle";
			var y = v.get("distance");
			V(y) || (y = [y, y]), _.__labelDistance = y;
		}
		this.setTextConfig({
			position: null,
			local: !0,
			inside: !1
		}), qd(this, u, d, l);
	}, t.prototype.highlight = function() {
		Od(this);
	}, t.prototype.downplay = function() {
		kd(this);
	}, t.prototype.updateLayout = function(e, t) {
		this.childOfName("line").stopAnimation(), this.setLinePoints(e.getItemLayout(t));
	}, t.prototype.setLinePoints = function(e) {
		var t = this.childOfName("line");
		_I(t.shape, e), t.dirty();
	}, t.prototype.beforeUpdate = function() {
		var e = this, t = e.childOfName("fromSymbol"), n = e.childOfName("toSymbol"), r = e.getTextContent();
		if (!t && !n && (!r || r.ignore)) return;
		for (var i = 1, a = this.parent; a;) a.scaleX && (i /= a.scaleX), a = a.parent;
		var o = e.childOfName("line");
		if (!this.__dirty && !o.__dirty) return;
		var s = o.shape.percent, c = o.pointAt(0), l = o.pointAt(s), u = We([], l, c);
		$e(u, u);
		function d(e, t) {
			var n = e.__specifiedRotation;
			if (n == null) {
				var r = o.tangentAt(t);
				e.attr("rotation", (t === 1 ? -1 : 1) * Math.PI / 2 - Math.atan2(r[1], r[0]));
			} else e.attr("rotation", n);
		}
		if (t && (t.setPosition(c), d(t, 0), t.scaleX = t.scaleY = i * s, t.markRedraw()), n && (n.setPosition(l), d(n, 1), n.scaleX = n.scaleY = i * s, n.markRedraw()), r && !r.ignore) {
			r.x = r.y = 0, r.originX = r.originY = 0;
			var f = void 0, p = void 0, m = r.__labelDistance, h = m[0] * i, g = m[1] * i, _ = s / 2, v = o.tangentAt(_), y = [v[1], -v[0]], b = o.pointAt(_);
			y[1] > 0 && (y[0] = -y[0], y[1] = -y[1]);
			var x = v[0] < 0 ? -1 : 1;
			if (r.__position !== "start" && r.__position !== "end") {
				var S = -Math.atan2(v[1], v[0]);
				l[0] < c[0] && (S = Math.PI + S), r.rotation = S;
			}
			var C = void 0;
			switch (r.__position) {
				case "insideStartTop":
				case "insideMiddleTop":
				case "insideEndTop":
				case "middle":
					C = -g, p = "bottom";
					break;
				case "insideStartBottom":
				case "insideMiddleBottom":
				case "insideEndBottom":
					C = g, p = "top";
					break;
				default: C = 0, p = "middle";
			}
			switch (r.__position) {
				case "end":
					r.x = u[0] * h + l[0], r.y = u[1] * g + l[1], f = u[0] > .8 ? "left" : u[0] < -.8 ? "right" : "center", p = u[1] > .8 ? "top" : u[1] < -.8 ? "bottom" : "middle";
					break;
				case "start":
					r.x = -u[0] * h + c[0], r.y = -u[1] * g + c[1], f = u[0] > .8 ? "right" : u[0] < -.8 ? "left" : "center", p = u[1] > .8 ? "bottom" : u[1] < -.8 ? "top" : "middle";
					break;
				case "insideStartTop":
				case "insideStart":
				case "insideStartBottom":
					r.x = h * x + c[0], r.y = c[1] + C, f = v[0] < 0 ? "right" : "left", r.originX = -h * x, r.originY = -C;
					break;
				case "insideMiddleTop":
				case "insideMiddle":
				case "insideMiddleBottom":
				case "middle":
					r.x = b[0], r.y = b[1] + C, f = "center", r.originY = -C;
					break;
				case "insideEndTop":
				case "insideEnd":
				case "insideEndBottom": r.x = -h * x + l[0], r.y = l[1] + C, f = v[0] >= 0 ? "right" : "left", r.originX = h * x, r.originY = -C;
			}
			r.scaleX = r.scaleY = i, r.setStyle({
				verticalAlign: r.__verticalAlign || p,
				align: r.__align || f
			});
		}
	}, t;
}(Wa), yI = function() {
	function e(e) {
		this.group = new Wa(), this._LineCtor = e || vI;
	}
	return e.prototype.updateData = function(e) {
		var t = this;
		this._progressiveEls = null;
		var n = this, r = n.group, i = n._lineData;
		n._lineData = e, i || r.removeAll();
		var a = xI(e);
		e.diff(i).add(function(n) {
			t._doAdd(e, n, a);
		}).update(function(n, r) {
			t._doUpdate(i, e, r, n, a);
		}).remove(function(e) {
			r.remove(i.getItemGraphicEl(e));
		}).execute();
	}, e.prototype.updateLayout = function() {
		var e = this._lineData;
		e && e.eachItemGraphicEl(function(t, n) {
			t.updateLayout(e, n);
		}, this);
	}, e.prototype.incrementalPrepareUpdate = function(e) {
		this._seriesScope = xI(e), this._lineData = null, this.group.removeAll();
	}, e.prototype.incrementalUpdate = function(e, t, n) {
		this._progressiveEls = [];
		function r(e) {
			!e.isGroup && !bI(e) && (e.incremental = n, e.ensureState("emphasis").hoverLayer = 2);
		}
		for (var i = e.start; i < e.end; i++) if (CI(t.getItemLayout(i))) {
			var a = new this._LineCtor(t, i, this._seriesScope);
			a.traverse(r), this.group.add(a), t.setItemGraphicEl(i, a), this._progressiveEls.push(a);
		}
	}, e.prototype.remove = function() {
		this.group.removeAll();
	}, e.prototype.eachRendered = function(e) {
		_m(this._progressiveEls || this.group, e);
	}, e.prototype._doAdd = function(e, t, n) {
		if (CI(e.getItemLayout(t))) {
			var r = new this._LineCtor(e, t, n);
			e.setItemGraphicEl(t, r), this.group.add(r);
		}
	}, e.prototype._doUpdate = function(e, t, n, r, i) {
		var a = e.getItemGraphicEl(n);
		CI(t.getItemLayout(r)) ? (a ? a.updateData(t, r, i) : a = new this._LineCtor(t, r, i), t.setItemGraphicEl(r, a), this.group.add(a)) : this.group.remove(a);
	}, e;
}();
function bI(e) {
	return e.animators && e.animators.length > 0;
}
function xI(e) {
	var t = e.hostModel, n = t.getModel("emphasis");
	return {
		lineStyle: t.getModel("lineStyle").getLineStyle(),
		emphasisLineStyle: n.getModel(["lineStyle"]).getLineStyle(),
		blurLineStyle: t.getModel(["blur", "lineStyle"]).getLineStyle(),
		selectLineStyle: t.getModel(["select", "lineStyle"]).getLineStyle(),
		emphasisDisabled: n.get("disabled"),
		blurScope: n.get("blurScope"),
		focus: n.get("focus"),
		labelStatesModels: Pm(t)
	};
}
function SI(e) {
	return isNaN(e[0]) || isNaN(e[1]);
}
function CI(e) {
	return e && !SI(e[0]) && !SI(e[1]);
}
//#endregion
//#region node_modules/echarts/lib/component/helper/sliderMove.js
function wI(e, t, n, r, i, a) {
	e ||= 0;
	var o = Fo(n[1], -n[0]);
	if (i != null && (i = EI(i, [0, o])), a != null && (a = Math.max(a, i ?? 0)), r === "all") {
		var s = Math.abs(Fo(t[1], -t[0]));
		s = EI(s, [0, o]), i = a = EI(s, [i, a]), r = 0;
	}
	t[0] = EI(t[0], n), t[1] = EI(t[1], n);
	var c = TI(t, r);
	t[r] += e;
	var l = i || 0, u = n.slice();
	c.sign < 0 ? u[0] = Fo(u[0], l) : u[1] = Fo(u[1], -l), t[r] = EI(t[r], u);
	var d = TI(t, r);
	return i != null && (d.sign !== c.sign || d.span < i) && (t[1 - r] = Fo(t[r], c.sign * i)), d = TI(t, r), a != null && d.span > a && (t[1 - r] = Fo(t[r], d.sign * a)), t;
}
function TI(e, t) {
	var n = e[t] - e[1 - t];
	return {
		span: Math.abs(n),
		sign: n > 0 ? -1 : n < 0 ? 1 : t ? -1 : 1
	};
}
function EI(e, t) {
	return Math.min(t[1] == null ? Infinity : t[1], Math.max(t[0] == null ? -Infinity : t[0], e));
}
//#endregion
//#region node_modules/echarts/lib/chart/helper/whiskerBoxCommon.js
var DI = function() {
	function e() {}
	return e.prototype._hasEncodeRule = function(e) {
		var t = this.getEncode();
		return t && t.get(e) != null;
	}, e.prototype.getInitialData = function(e, t) {
		var n, r = t.getComponent("xAxis", this.get("xAxisIndex")), i = t.getComponent("yAxis", this.get("yAxisIndex")), a = r.get("type"), o = i.get("type"), s, c = e.layout;
		a === "category" ? (c = "horizontal", n = r.getOrdinalMeta(), s = !this._hasEncodeRule("x")) : o === "category" && (c = "vertical", n = i.getOrdinalMeta(), s = !this._hasEncodeRule("y")), c ||= o === "time" ? "vertical" : "horizontal", this._layout = c;
		var l = ["x", "y"], u = c === "horizontal" ? 0 : 1, d = this._baseAxisDim = l[u], f = l[1 - u], p = [r, i], m = p[u].get("type"), h = p[1 - u].get("type"), g = e.data;
		if (g && s) {
			var _ = [];
			I(g, function(e, t) {
				var n;
				V(e) ? (n = e.slice(), e.unshift(t)) : V(e.value) ? (n = M({}, e), n.value = n.value.slice(), e.value.unshift(t)) : n = e, _.push(n);
			}), e.data = _;
		}
		var v = this.defaultValueDimensions, y = [{
			name: d,
			type: bw(m),
			ordinalMeta: n,
			otherDims: {
				tooltip: !1,
				itemName: 0
			},
			dimsDef: ["base"]
		}, {
			name: f,
			type: bw(h),
			dimsDef: v.slice()
		}];
		return wM(this, {
			coordDimensions: y,
			dimensionsCount: v.length + 1,
			encodeDefaulter: B(s_, y, this)
		});
	}, e.prototype.getBaseAxis = function() {
		var e = this._baseAxisDim;
		return this.ecModel.getComponent(e + "Axis", this.get(e + "AxisIndex")).axis;
	}, e.prototype.getWhiskerBoxesLayout = function() {
		return this._layout;
	}, e;
}();
function OI(e, t) {
	for (var n = t.ends.length, r = 0, i = 0; i < n; i++) e.contain(t.ends[i][0], t.ends[i][1]) && r++;
	return r ? +(r < n) : 2;
}
//#endregion
//#region node_modules/echarts/lib/chart/boxplot/BoxplotSeries.js
var kI = "boxplot", AI = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.defaultValueDimensions = [
			{
				name: "min",
				defaultTooltip: !0
			},
			{
				name: "Q1",
				defaultTooltip: !0
			},
			{
				name: "median",
				defaultTooltip: !0
			},
			{
				name: "Q3",
				defaultTooltip: !0
			},
			{
				name: "max",
				defaultTooltip: !0
			}
		], n.visualDrawType = "stroke", n;
	}
	return t.type = "series." + kI, t.dependencies = [
		"xAxis",
		"yAxis",
		"grid"
	], t.defaultOption = {
		z: 2,
		coordinateSystem: "cartesian2d",
		legendHoverLink: !0,
		layout: null,
		clip: !0,
		boxWidth: [7, 50],
		itemStyle: {
			color: Q.color.neutral00,
			borderWidth: 1
		},
		emphasis: {
			scale: !0,
			itemStyle: {
				borderWidth: 2,
				shadowBlur: 5,
				shadowOffsetX: 1,
				shadowOffsetY: 1,
				shadowColor: Q.color.shadow
			}
		},
		animationDuration: 800
	}, t;
}(Jy);
F(AI, DI, !0);
//#endregion
//#region node_modules/echarts/lib/chart/boxplot/BoxplotView.js
var jI = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t.type = kI, t;
	}
	return t.prototype.render = function(e, t, n) {
		var r = e.getData(), i = this.group, a = this._data;
		this._data || i.removeAll();
		var o = +(e.getWhiskerBoxesLayout() === "horizontal"), s = e.get("clip", !0), c = e.coordinateSystem, l = c.getArea && c.getArea(), u = s && eA(c, !1, e);
		r.diff(a).add(function(e) {
			if (r.hasValue(e)) {
				var t = r.getItemLayout(e), n = s ? OI(l, t) : 0;
				if (n === 2) return;
				var a = PI(t, r, e, o, !0);
				tA(n === 1, a, u), r.setItemGraphicEl(e, a), i.add(a);
			}
		}).update(function(e, t) {
			var n = a.getItemGraphicEl(t);
			if (!r.hasValue(e)) i.remove(n);
			else {
				var c = r.getItemLayout(e), d = s ? OI(l, c) : 0;
				d === 2 ? i.remove(n) : (n ? (Fp(n), FI(c, n, r, e)) : n = PI(c, r, e, o), tA(d === 1, n, u), i.add(n), r.setItemGraphicEl(e, n));
			}
		}).remove(function(e) {
			var t = a.getItemGraphicEl(e);
			t && i.remove(t);
		}).execute(), this._data = r;
	}, t.prototype.remove = function(e) {
		var t = this.group, n = this._data;
		this._data = null, n && n.eachItemGraphicEl(function(e) {
			e && t.remove(e);
		});
	}, t.type = kI, t;
}(sb), MI = function() {
	function e() {}
	return e;
}(), NI = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this, t) || this;
		return n.type = "boxplotBoxPath", n;
	}
	return t.prototype.getDefaultShape = function() {
		return new MI();
	}, t.prototype.buildPath = function(e, t) {
		var n = t.points, r = 0;
		for (e.moveTo(n[r][0], n[r][1]), r++; r < 4; r++) e.lineTo(n[r][0], n[r][1]);
		for (e.closePath(); r < n.length; r++) e.moveTo(n[r][0], n[r][1]), r++, e.lineTo(n[r][0], n[r][1]);
	}, t;
}(ou);
function PI(e, t, n, r, i) {
	var a = e.ends, o = new NI({ shape: { points: i ? II(a, r, e) : a } });
	return FI(e, o, t, n, i), o;
}
function FI(e, t, n, r, i) {
	var a = n.hostModel, o = Ip[i ? "initProps" : "updateProps"];
	o(t, { shape: { points: e.ends } }, a, r), t.useStyle(n.getItemVisual(r, "style")), t.style.strokeNoScale = !0, t.z2 = 100;
	var s = n.getItemModel(r), c = s.getModel("emphasis");
	Zd(t, s), qd(t, c.get("focus"), c.get("blurScope"), c.get("disabled"));
}
function II(e, t, n) {
	return L(e, function(e) {
		return e = e.slice(), e[t] = n.initBaseline, e;
	});
}
//#endregion
//#region node_modules/echarts/lib/chart/boxplot/boxplotLayout.js
var LI = Js(), RI = tc(kI, zI);
function zI(e) {
	var t = Sj(kI);
	LE(e, t, function(e) {
		var n = IE(e, t);
		if (n) {
			var r = BI(e, n);
			PE(e, t, function(e) {
				var t = e.seriesIndex;
				VI(e, r.boxOffsetList[t], r.boxWidthList[t]);
			});
		}
	});
}
function BI(e, t) {
	var n = [], r = [], i = [], a = hO(e, {
		fromStat: { key: Sj(kI) },
		min: 1
	}).w;
	PE(e, Sj(kI), function(e) {
		var t = e.get("boxWidth");
		V(t) || (t = [t, t]), i[e.seriesIndex] = [So(t[0], a) || 0, So(t[1], a) || 0];
	});
	var o = a * .8 - 2, s = o / t * .3, c = (o - s * (t - 1)) / t, l = c / 2 - o / 2;
	return PE(e, Sj(kI), function(e) {
		var t = e.seriesIndex;
		r[t] = l, l += s + c, n[t] = lo(uo(c, i[t][0]), i[t][1]);
	}), {
		boxOffsetList: r,
		boxWidthList: n
	};
}
function VI(e, t, n) {
	var r = e.coordinateSystem, i = e.getData(), a = n / 2, o = e.getWhiskerBoxesLayout() === "horizontal" ? 0 : 1, s = 1 - o, c = ["x", "y"], l = i.mapDimension(c[o]), u = i.mapDimensionsAll(c[s]);
	if (l == null || u.length < 5) return;
	for (var d = 0; d < i.count(); d++) {
		var f = i.get(l, d), p = y(f, u[2], d), m = y(f, u[0], d), h = y(f, u[1], d), g = y(f, u[3], d), _ = y(f, u[4], d), v = [];
		b(v, h, !1), b(v, g, !0), v.push(m, h, _, g), x(v, m), x(v, _), x(v, p), i.setItemLayout(d, {
			initBaseline: p[s],
			ends: v
		});
	}
	function y(e, n, a) {
		var c = i.get(n, a), l = [];
		l[o] = e, l[s] = c;
		var u;
		return isNaN(e) || isNaN(c) ? u = [NaN, NaN] : (u = r.dataToPoint(l), u[o] += t), u;
	}
	function b(e, t, n) {
		var r = t.slice(), i = t.slice();
		r[o] += a, i[o] -= a, n ? e.push(r, i) : e.push(i, r);
	}
	function x(e, t) {
		var n = t.slice(), r = t.slice();
		n[o] -= a, r[o] += a, e.push(n, r);
	}
}
function HI(e) {
	LI(e, function() {
		var t = Sj(kI);
		WE(e, {
			key: t,
			seriesType: kI,
			getMetrics: wj
		}), aD(t, xj(t));
	});
}
//#endregion
//#region node_modules/echarts/lib/chart/boxplot/prepareBoxplotData.js
function UI(e, t) {
	t ||= {};
	for (var n = [], r = [], i = t.boundIQR, a = i === "none" || i === 0, o = 0; o < e.length; o++) {
		var s = Oo(e[o].slice()), c = Wo(s, .25), l = Wo(s, .5), u = Wo(s, .75), d = s[0], f = s[s.length - 1], p = (i ?? 1.5) * (u - c), m = a ? d : Math.max(d, c - p), h = a ? f : Math.min(f, u + p), g = t.itemNameFormatter, _ = H(g) ? g({ value: o }) : U(g) ? g.replace("{value}", o + "") : o + "";
		n.push([
			_,
			m,
			c,
			l,
			u,
			h
		]);
		for (var v = 0; v < s.length; v++) {
			var y = s[v];
			if (y < m || y > h) {
				var b = [_, y];
				r.push(b);
			}
		}
	}
	return {
		boxData: n,
		outliers: r
	};
}
//#endregion
//#region node_modules/echarts/lib/chart/boxplot/boxplotTransform.js
var WI = {
	type: "echarts:boxplot",
	transform: function(e) {
		var t = e.upstream;
		t.sourceFormat !== "arrayRows" && rs("");
		var n = UI(t.getRawData(), e.config);
		return [{
			dimensions: [
				"ItemName",
				"Low",
				"Q1",
				"Q2",
				"Q3",
				"High"
			],
			data: n.boxData
		}, { data: n.outliers }];
	}
};
//#endregion
//#region node_modules/echarts/lib/chart/boxplot/install.js
function GI(e) {
	e.registerSeriesModel(AI), e.registerChartView(jI), e.registerLayout(RI), e.registerTransform(WI), HI(e);
}
//#endregion
//#region node_modules/echarts/lib/chart/helper/EffectLine.js
var KI = function(e) {
	n(t, e);
	function t(t, n, r) {
		var i = e.call(this) || this;
		return i.add(i.createLine(t, n, r)), i._updateEffectSymbol(t, n), i;
	}
	return t.prototype.createLine = function(e, t, n) {
		return new vI(e, t, n);
	}, t.prototype._updateEffectSymbol = function(e, t) {
		var n = e.getItemModel(t).getModel("effect"), r = n.get("symbolSize"), i = n.get("symbol");
		V(r) || (r = [r, r]);
		var a = e.getItemVisual(t, "style"), o = n.get("color") || a && a.stroke, s = this.childAt(1);
		this._symbolType !== i && (this.remove(s), s = Ox(i, -.5, -.5, 1, 1, o), s.z2 = 100, s.culling = !0, this.add(s)), s && (s.setStyle("shadowColor", o), s.setStyle(n.getItemStyle(["color"])), s.scaleX = r[0], s.scaleY = r[1], s.setColor(o), this._symbolType = i, this._symbolScale = r, this._updateEffectAnimation(e, n, t));
	}, t.prototype._updateEffectAnimation = function(e, t, n) {
		var r = this.childAt(1);
		if (r) {
			var i = e.getItemLayout(n), a = t.get("period") * 1e3, o = t.get("loop"), s = t.get("roundTrip"), c = t.get("constantSpeed"), l = ve(t.get("delay"), function(t) {
				return t / e.count() * a / 3;
			});
			if (r.ignore = !0, this._updateAnimationPoints(r, i), c > 0 && (a = this._getLineLength(r) / c * 1e3), a !== this._period || o !== this._loop || s !== this._roundTrip) {
				r.stopAnimation();
				var u = void 0;
				u = H(l) ? l(n) : l, r.__t > 0 && (u = -a * r.__t), this._animateSymbol(r, a, u, o, s);
			}
			this._period = a, this._loop = o, this._roundTrip = s;
		}
	}, t.prototype._animateSymbol = function(e, t, n, r, i) {
		if (t > 0) {
			e.__t = 0;
			var a = this, o = e.animate("", r).when(i ? t * 2 : t, { __t: i ? 2 : 1 }).delay(n).during(function() {
				a._updateSymbolPosition(e);
			});
			r || o.done(function() {
				a.remove(e);
			}), o.start();
		}
	}, t.prototype._getLineLength = function(e) {
		return tt(e.__p1, e.__cp1) + tt(e.__cp1, e.__p2);
	}, t.prototype._updateAnimationPoints = function(e, t) {
		e.__p1 = t[0], e.__p2 = t[1], e.__cp1 = t[2] || [(t[0][0] + t[1][0]) / 2, (t[0][1] + t[1][1]) / 2];
	}, t.prototype.updateData = function(e, t, n) {
		this.childAt(0).updateData(e, t, n), this._updateEffectSymbol(e, t);
	}, t.prototype._updateSymbolPosition = function(e) {
		var t = e.__p1, n = e.__p2, r = e.__cp1, i = e.__t <= 1 ? e.__t : 2 - e.__t, a = [e.x, e.y], o = a.slice(), s = mr, c = hr;
		a[0] = s(t[0], r[0], n[0], i), a[1] = s(t[1], r[1], n[1], i);
		var l = e.__t <= 1 ? c(t[0], r[0], n[0], i) : c(n[0], r[0], t[0], 1 - i), u = e.__t <= 1 ? c(t[1], r[1], n[1], i) : c(n[1], r[1], t[1], 1 - i);
		e.rotation = -Math.atan2(u, l) - Math.PI / 2, (this._symbolType === "line" || this._symbolType === "rect" || this._symbolType === "roundRect") && (e.__lastT !== void 0 && e.__lastT < e.__t ? (e.scaleY = tt(o, a) * 1.05, i === 1 && (a[0] = o[0] + (a[0] - o[0]) / 2, a[1] = o[1] + (a[1] - o[1]) / 2)) : e.scaleY = e.__lastT === 1 ? 2 * tt(t, a) : this._symbolScale[1]), e.__lastT = e.__t, e.ignore = !1, e.x = a[0], e.y = a[1];
	}, t.prototype.updateLayout = function(e, t) {
		this.childAt(0).updateLayout(e, t);
		var n = e.getItemModel(t).getModel("effect");
		this._updateEffectAnimation(e, n, t);
	}, t;
}(Wa), qI = function(e) {
	n(t, e);
	function t(t, n, r) {
		var i = e.call(this) || this;
		return i._createPolyline(t, n, r), i;
	}
	return t.prototype._createPolyline = function(e, t, n) {
		var r = new tp({ shape: { points: e.getItemLayout(t) } });
		this.add(r), this._updateCommonStl(e, t, n);
	}, t.prototype.updateData = function(e, t, n) {
		var r = e.hostModel;
		kp(this.childAt(0), { shape: { points: e.getItemLayout(t) } }, r, t), this._updateCommonStl(e, t, n);
	}, t.prototype._updateCommonStl = function(e, t, n) {
		var r = this.childAt(0), i = e.getItemModel(t), a = n && n.emphasisLineStyle, o = n && n.focus, s = n && n.blurScope, c = n && n.emphasisDisabled;
		if (!n || e.hasItemOption) {
			var l = i.getModel("emphasis");
			a = l.getModel("lineStyle").getLineStyle(), c = l.get("disabled"), o = l.get("focus"), s = l.get("blurScope");
		}
		r.useStyle(e.getItemVisual(t, "style")), r.style.fill = null, r.style.strokeNoScale = !0;
		var u = r.ensureState("emphasis");
		u.style = a, qd(this, o, s, c);
	}, t.prototype.updateLayout = function(e, t) {
		var n = this.childAt(0);
		n.stopAnimation(), n.setShape("points", e.getItemLayout(t));
	}, t;
}(Wa), JI = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t._lastFrame = 0, t._lastFramePercent = 0, t;
	}
	return t.prototype.createLine = function(e, t, n) {
		return new qI(e, t, n);
	}, t.prototype._updateAnimationPoints = function(e, t) {
		this._points = t;
		for (var n = [0], r = 0, i = 1; i < t.length; i++) {
			var a = t[i - 1], o = t[i];
			r += tt(a, o), n.push(r);
		}
		if (r === 0) this._length = 0;
		else {
			for (var i = 0; i < n.length; i++) n[i] /= r;
			this._offsets = n, this._length = r;
		}
	}, t.prototype._getLineLength = function() {
		return this._length;
	}, t.prototype._updateSymbolPosition = function(e) {
		var t = e.__t <= 1 ? e.__t : 2 - e.__t, n = this._points, r = this._offsets, i = n.length;
		if (r) {
			var a = this._lastFrame, o;
			if (t < this._lastFramePercent) {
				for (o = Math.min(a + 1, i - 1); o >= 0 && !(r[o] <= t); o--);
				o = Math.min(o, i - 2);
			} else {
				for (o = a; o < i && !(r[o] > t); o++);
				o = Math.min(o - 1, i - 2);
			}
			var s = (t - r[o]) / (r[o + 1] - r[o]), c = n[o], l = n[o + 1];
			e.x = c[0] * (1 - s) + s * l[0], e.y = c[1] * (1 - s) + s * l[1];
			var u = e.__t <= 1 ? l[0] - c[0] : c[0] - l[0], d = e.__t <= 1 ? l[1] - c[1] : c[1] - l[1];
			e.rotation = -Math.atan2(d, u) - Math.PI / 2, this._lastFrame = o, this._lastFramePercent = t, e.ignore = !1;
		}
	}, t;
}(KI), YI = function() {
	function e() {
		this.polyline = !1, this.curveness = 0, this.segs = [];
	}
	return e;
}(), XI = function(e) {
	n(t, e);
	function t(t) {
		var n = e.call(this, t) || this;
		return n._off = 0, n.hoverDataIdx = -1, n;
	}
	return t.prototype.reset = function() {
		this.notClear = !1, this._off = 0;
	}, t.prototype.beforeBrush = function(e) {
		e && !e.contentRetained && this.reset();
	}, t.prototype.getDefaultStyle = function() {
		return {
			stroke: Q.color.neutral99,
			fill: null
		};
	}, t.prototype.getDefaultShape = function() {
		return new YI();
	}, t.prototype.buildPath = function(e, t) {
		var n = t.segs, r = t.curveness, i;
		if (t.polyline) for (i = this._off; i < n.length;) {
			var a = n[i++];
			if (a > 0) {
				e.moveTo(n[i++], n[i++]);
				for (var o = 1; o < a; o++) e.lineTo(n[i++], n[i++]);
			}
		}
		else for (i = this._off; i < n.length;) {
			var s = n[i++], c = n[i++], l = n[i++], u = n[i++];
			if (e.moveTo(s, c), r > 0) {
				var d = (s + l) / 2 - (c - u) * r, f = (c + u) / 2 - (l - s) * r;
				e.quadraticCurveTo(d, f, l, u);
			} else e.lineTo(l, u);
		}
		this.incremental && (this._off = i, this.notClear = !0);
	}, t.prototype.findDataIndex = function(e, t) {
		var n = this.shape, r = n.segs, i = n.curveness, a = this.style.lineWidth;
		if (n.polyline) for (var o = 0, s = 0; s < r.length;) {
			var c = r[s++];
			if (c > 0) for (var l = r[s++], u = r[s++], d = 1; d < c; d++) {
				var f = r[s++], p = r[s++];
				if (Il(l, u, f, p, a, e, t)) return o;
			}
			o++;
		}
		else for (var o = 0, s = 0; s < r.length;) {
			var l = r[s++], u = r[s++], f = r[s++], p = r[s++];
			if (i > 0) {
				if (Rl(l, u, (l + f) / 2 - (u - p) * i, (u + p) / 2 - (f - l) * i, f, p, a, e, t)) return o;
			} else if (Il(l, u, f, p, a, e, t)) return o;
			o++;
		}
		return -1;
	}, t.prototype.contain = function(e, t) {
		var n = this.transformCoordToLocal(e, t), r = this.getBoundingRect();
		return e = n[0], t = n[1], r.contain(e, t) ? (this.hoverDataIdx = this.findDataIndex(e, t)) >= 0 : (this.hoverDataIdx = -1, !1);
	}, t.prototype.getBoundingRect = function() {
		var e = this._rect;
		if (!e) {
			for (var t = this.shape.segs, n = Infinity, r = Infinity, i = -Infinity, a = -Infinity, o = 0; o < t.length;) {
				var s = t[o++], c = t[o++];
				n = Math.min(s, n), i = Math.max(s, i), r = Math.min(c, r), a = Math.max(c, a);
			}
			e = this._rect = new Y(n, r, i, a);
		}
		return e;
	}, t;
}(ou), ZI = function() {
	function e() {
		this.group = new Wa();
	}
	return e.prototype.updateData = function(e) {
		this._clear();
		var t = this._create();
		t.setShape({ segs: e.getLayout("linesPoints") }), this._setCommon(t, e);
	}, e.prototype.incrementalPrepareUpdate = function(e) {
		this.group.removeAll(), this._clear();
	}, e.prototype.incrementalUpdate = function(e, t, n) {
		var r = this._newAdded[0], i = t.getLayout("linesPoints"), a = r && r.shape.segs;
		if (a && a.length < 2e4) {
			var o = a.length, s = new Float32Array(o + i.length);
			s.set(a), s.set(i, o), r.setShape({ segs: s });
		} else {
			this._newAdded = [];
			var c = this._create();
			c.incremental = n, c.setShape({ segs: i }), this._setCommon(c, t), c.__startIndex = e.start;
		}
	}, e.prototype.remove = function() {
		this._clear();
	}, e.prototype.eachRendered = function(e) {
		this._newAdded[0] && e(this._newAdded[0]);
	}, e.prototype._create = function() {
		var e = new XI({
			cursor: "default",
			ignoreCoarsePointer: !0
		});
		return this._newAdded.push(e), this.group.add(e), e;
	}, e.prototype._setCommon = function(e, t, n) {
		var r = t.hostModel;
		e.setShape({
			polyline: r.get("polyline"),
			curveness: r.get(["lineStyle", "curveness"])
		}), e.useStyle(r.getModel("lineStyle").getLineStyle()), e.style.strokeNoScale = !0;
		var i = t.getVisual("style");
		i && i.stroke && e.setStyle("stroke", i.stroke), e.setStyle("fill", null);
		var a = Z(e);
		a.seriesIndex = r.seriesIndex, e.on("mousemove", function(t) {
			a.dataIndex = null;
			var n = e.hoverDataIdx;
			n > 0 && (a.dataIndex = n + e.__startIndex);
		});
	}, e.prototype._clear = function() {
		this._newAdded = [], this.group.removeAll();
	}, e;
}(), QI = {
	seriesType: "lines",
	plan: ib(),
	reset: function(e) {
		var t = e.coordinateSystem;
		if (t) {
			var n = e.get("polyline"), r = e.pipelineContext.large;
			return { progress: function(i, a) {
				var o = [];
				if (r) {
					var s = void 0, c = i.end - i.start;
					if (n) {
						for (var l = 0, u = i.start; u < i.end; u++) l += e.getLineCoordsCount(u);
						s = new Float32Array(c + l * 2);
					} else s = new Float32Array(c * 4);
					for (var d = 0, f = [], u = i.start; u < i.end; u++) {
						var p = e.getLineCoords(u, o);
						n && (s[d++] = p);
						for (var m = 0; m < p; m++) f = t.dataToPoint(o[m], !1, f), s[d++] = f[0], s[d++] = f[1];
					}
					a.setLayout("linesPoints", s);
				} else for (var u = i.start; u < i.end; u++) {
					var h = a.getItemModel(u), p = e.getLineCoords(u, o), g = [];
					if (n) for (var _ = 0; _ < p; _++) g.push(t.dataToPoint(o[_]));
					else {
						g[0] = t.dataToPoint(o[0]), g[1] = t.dataToPoint(o[1]);
						var v = h.get(["lineStyle", "curveness"]);
						+v && (g[2] = [(g[0][0] + g[1][0]) / 2 - (g[0][1] - g[1][1]) * v, (g[0][1] + g[1][1]) / 2 - (g[1][0] - g[0][0]) * v]);
					}
					a.setItemLayout(u, g);
				}
			} };
		}
	}
}, $I = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.render = function(e, t, n) {
		var r = e.getData(), i = this._updateLineDraw(r, e), a = e.get("zlevel"), o = e.get(["effect", "trailLength"]), s = n.getZr(), c = !!km(n);
		c && s.painter.getLayer(a).clear(!0), this._lastZlevel != null && c && s.configLayer(this._lastZlevel, { motionBlur: !1 }), this._showEffect(e) && o > 0 && c && s.configLayer(a, {
			motionBlur: !0,
			lastFrameAlpha: Math.max(Math.min(o / 10 + .9, 1), 0)
		}), i.updateData(r);
		var l = e.get("clip", !0) && eA(e.coordinateSystem, !1, e);
		l ? this.group.setClipPath(l) : this.group.removeClipPath(), this._lastZlevel = a, this._finished = !0;
	}, t.prototype.incrementalPrepareRender = function(e, t, n) {
		var r = e.getData();
		this._updateLineDraw(r, e).incrementalPrepareUpdate(r), this._clearLayer(n), this._finished = !1;
	}, t.prototype.incrementalRender = function(e, t, n) {
		this._lineDraw.incrementalUpdate(e, t.getData(), $s(t)), this._finished = e.end === t.getData().count();
	}, t.prototype.eachRendered = function(e) {
		this._lineDraw && this._lineDraw.eachRendered(e);
	}, t.prototype.updateTransform = function(e, t, n) {
		var r = e.getData(), i = this._lineDraw;
		if (!this._finished || !i || !i.updateLayout) return { update: !0 };
		var a = QI.reset(e, t, n);
		a.progress && a.progress({
			start: 0,
			end: r.count(),
			count: r.count()
		}, r), i.updateLayout(), this._clearLayer(n);
	}, t.prototype._updateLineDraw = function(e, t) {
		var n = this._lineDraw, r = this._showEffect(t), i = !!t.get("polyline"), a = t.pipelineContext.large;
		return (!n || r !== this._hasEffet || i !== this._isPolyline || a !== this._isLargeDraw) && (n && n.remove(), n = this._lineDraw = a ? new ZI() : new yI(i ? r ? JI : qI : r ? KI : vI), this._hasEffet = r, this._isPolyline = i, this._isLargeDraw = a), this.group.add(n.group), n;
	}, t.prototype._showEffect = function(e) {
		return !!e.get(["effect", "show"]);
	}, t.prototype._clearLayer = function(e) {
		var t = km(e);
		t && this._lastZlevel != null && t.getLayer(this._lastZlevel).clear(!0);
	}, t.prototype.remove = function(e, t) {
		this._lineDraw && this._lineDraw.remove(), this._lineDraw = null, this._clearLayer(t);
	}, t.prototype.dispose = function(e, t) {
		this.remove(e, t);
	}, t.type = "lines", t;
}(sb), eL = typeof Uint32Array > "u" ? Array : Uint32Array, tL = typeof Float64Array > "u" ? Array : Float64Array;
function nL(e) {
	var t = e.data;
	t && t[0] && t[0][0] && t[0][0].coord && (e.data = L(t, function(e) {
		var t = { coords: [e[0].coord, e[1].coord] };
		return e[0].name && (t.fromName = e[0].name), e[1].name && (t.toName = e[1].name), ee([
			t,
			e[0],
			e[1]
		]);
	}));
}
var rL = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.visualStyleAccessPath = "lineStyle", n.visualDrawType = "stroke", n;
	}
	return t.prototype.init = function(t) {
		t.data = t.data || [], nL(t);
		var n = this._processFlatCoordsArray(t.data);
		this._flatCoords = n.flatCoords, this._flatCoordsOffset = n.flatCoordsOffset, n.flatCoords && (t.data = new Float32Array(n.count)), e.prototype.init.apply(this, arguments);
	}, t.prototype.mergeOption = function(t) {
		if (nL(t), t.data) {
			var n = this._processFlatCoordsArray(t.data);
			this._flatCoords = n.flatCoords, this._flatCoordsOffset = n.flatCoordsOffset, n.flatCoords && (t.data = new Float32Array(n.count));
		}
		e.prototype.mergeOption.apply(this, arguments);
	}, t.prototype.appendData = function(e) {
		var t = this._processFlatCoordsArray(e.data);
		t.flatCoords && (this._flatCoords ? (this._flatCoords = je(this._flatCoords, t.flatCoords), this._flatCoordsOffset = je(this._flatCoordsOffset, t.flatCoordsOffset)) : (this._flatCoords = t.flatCoords, this._flatCoordsOffset = t.flatCoordsOffset), e.data = new Float32Array(t.count)), this.getRawData().appendData(e.data);
	}, t.prototype._getCoordsFromItemModel = function(e) {
		var t = this.getData().getItemModel(e);
		return t.option instanceof Array ? t.option : t.getShallow("coords");
	}, t.prototype.getLineCoordsCount = function(e) {
		return this._flatCoordsOffset ? this._flatCoordsOffset[e * 2 + 1] : this._getCoordsFromItemModel(e).length;
	}, t.prototype.getLineCoords = function(e, t) {
		if (this._flatCoordsOffset) {
			for (var n = this._flatCoordsOffset[e * 2], r = this._flatCoordsOffset[e * 2 + 1], i = 0; i < r; i++) t[i] = t[i] || [], t[i][0] = this._flatCoords[n + i * 2], t[i][1] = this._flatCoords[n + i * 2 + 1];
			return r;
		}
		for (var a = this._getCoordsFromItemModel(e), i = 0; i < a.length; i++) t[i] = t[i] || [], t[i][0] = a[i][0], t[i][1] = a[i][1];
		return a.length;
	}, t.prototype._processFlatCoordsArray = function(e) {
		var t = 0;
		if (this._flatCoords && (t = this._flatCoords.length), ue(e[0])) {
			for (var n = e.length, r = new eL(n), i = new tL(n), a = 0, o = 0, s = 0, c = 0; c < n;) {
				s++;
				var l = e[c++];
				r[o++] = a + t, r[o++] = l;
				for (var u = 0; u < l; u++) {
					var d = e[c++], f = e[c++];
					i[a++] = d, i[a++] = f;
				}
			}
			return {
				flatCoordsOffset: new Uint32Array(r.buffer, 0, o),
				flatCoords: i,
				count: s
			};
		}
		return {
			flatCoordsOffset: null,
			flatCoords: null,
			count: e.length
		};
	}, t.prototype.getInitialData = function(e, t) {
		var n = new Ww(["value"], this);
		return n.hasItemOption = !1, n.initData(e.data, [], function(e, t, r, i) {
			if (e instanceof Array) return NaN;
			n.hasItemOption = !0;
			var a = e.value;
			if (a != null) return a instanceof Array ? a[i] : a;
		}), n;
	}, t.prototype.formatTooltip = function(e, t, n) {
		var r = this.getData(), i = this.getRawValue(e), a = r.getItemModel(e), o = a.get("name");
		if (!o) {
			var s = a.get("fromName"), c = a.get("toName"), l = [];
			s != null && l.push(s), c != null && l.push(c), o = l.join(" > ");
		}
		return Oy("nameValue", {
			name: o,
			value: i,
			noValue: i == null || isNaN(i)
		});
	}, t.prototype.preventIncremental = function() {
		return !!this.get(["effect", "show"]);
	}, t.prototype.getProgressive = function() {
		return this.option.progressive ?? (this.option.large ? 1e4 : this.get("progressive"));
	}, t.prototype.getProgressiveThreshold = function() {
		return this.option.progressiveThreshold ?? (this.option.large ? 2e4 : this.get("progressiveThreshold"));
	}, t.prototype.getZLevelKey = function() {
		var e = this.getModel("effect"), t = e.get("trailLength");
		return this.getData().count() > this.getProgressiveThreshold() ? this.id : e.get("show") && t > 0 ? t + "" : "";
	}, t.type = "series.lines", t.dependencies = [
		"grid",
		"polar",
		"geo",
		"calendar"
	], t.defaultOption = {
		coordinateSystem: "geo",
		z: 2,
		legendHoverLink: !0,
		xAxisIndex: 0,
		yAxisIndex: 0,
		symbol: ["none", "none"],
		symbolSize: [10, 10],
		geoIndex: 0,
		effect: {
			show: !1,
			period: 4,
			constantSpeed: 0,
			symbol: "circle",
			symbolSize: 3,
			loop: !0,
			trailLength: .2
		},
		large: !1,
		largeThreshold: 2e3,
		polyline: !1,
		clip: !0,
		label: {
			show: !1,
			position: "end"
		},
		lineStyle: { opacity: .5 }
	}, t;
}(Jy);
//#endregion
//#region node_modules/echarts/lib/chart/lines/linesVisual.js
function iL(e) {
	return e instanceof Array || (e = [e, e]), e;
}
var aL = {
	seriesType: "lines",
	reset: function(e) {
		var t = iL(e.get("symbol")), n = iL(e.get("symbolSize")), r = e.getData();
		r.setVisual("fromSymbol", t && t[0]), r.setVisual("toSymbol", t && t[1]), r.setVisual("fromSymbolSize", n && n[0]), r.setVisual("toSymbolSize", n && n[1]);
		function i(e, t) {
			var n = e.getItemModel(t), r = iL(n.getShallow("symbol", !0)), i = iL(n.getShallow("symbolSize", !0));
			r[0] && e.setItemVisual(t, "fromSymbol", r[0]), r[1] && e.setItemVisual(t, "toSymbol", r[1]), i[0] && e.setItemVisual(t, "fromSymbolSize", i[0]), i[1] && e.setItemVisual(t, "toSymbolSize", i[1]);
		}
		return { dataEach: r.hasItemOption ? i : null };
	}
};
//#endregion
//#region node_modules/echarts/lib/chart/lines/install.js
function oL(e) {
	e.registerChartView($I), e.registerSeriesModel(rL), e.registerLayout(QI), e.registerVisual(aL);
}
//#endregion
//#region node_modules/echarts/lib/chart/heatmap/HeatmapLayer.js
var sL = 256, cL = function() {
	function e() {
		this.blurSize = 30, this.pointSize = 20, this.maxOpacity = 1, this.minOpacity = 0, this._gradientPixels = {
			inRange: null,
			outOfRange: null
		};
		var e = f.createCanvas();
		this.canvas = e;
	}
	return e.prototype.update = function(e, t, n, r, i, a) {
		var o = this._getBrush(), s = this._getGradient(i, "inRange"), c = this._getGradient(i, "outOfRange"), l = this.pointSize + this.blurSize, u = this.canvas, d = u.getContext("2d"), f = e.length;
		u.width = t, u.height = n;
		for (var p = 0; p < f; ++p) {
			var m = e[p], h = m[0], g = m[1], _ = m[2], v = r(_);
			d.globalAlpha = v, d.drawImage(o, h - l, g - l);
		}
		if (!u.width || !u.height) return u;
		for (var y = d.getImageData(0, 0, u.width, u.height), b = y.data, x = 0, S = b.length, C = this.minOpacity, w = this.maxOpacity - C; x < S;) {
			var v = b[x + 3] / 256, T = Math.floor(v * (sL - 1)) * 4;
			if (v > 0) {
				var E = a(v) ? s : c;
				v > 0 && (v = v * w + C), b[x++] = E[T], b[x++] = E[T + 1], b[x++] = E[T + 2], b[x++] = E[T + 3] * v * 256;
			} else x += 4;
		}
		return d.putImageData(y, 0, 0), u;
	}, e.prototype._getBrush = function() {
		var e = this._brushCanvas ||= f.createCanvas(), t = this.pointSize + this.blurSize, n = t * 2;
		e.width = n, e.height = n;
		var r = e.getContext("2d");
		return r.clearRect(0, 0, n, n), r.shadowOffsetX = n, r.shadowBlur = this.blurSize, r.shadowColor = Q.color.neutral99, r.beginPath(), r.arc(-t, t, this.pointSize, 0, Math.PI * 2, !0), r.closePath(), r.fill(), e;
	}, e.prototype._getGradient = function(e, t) {
		for (var n = this._gradientPixels, r = n[t] || (n[t] = /* @__PURE__ */ new Uint8ClampedArray(1024)), i = [
			0,
			0,
			0,
			0
		], a = 0, o = 0; o < 256; o++) e[t](o / 255, !0, i), r[a++] = i[0], r[a++] = i[1], r[a++] = i[2], r[a++] = i[3];
		return r;
	}, e;
}();
//#endregion
//#region node_modules/echarts/lib/chart/heatmap/HeatmapView.js
function lL(e, t, n) {
	var r = e[1] - e[0];
	t = L(t, function(t) {
		return { interval: [(t.interval[0] - e[0]) / r, (t.interval[1] - e[0]) / r] };
	});
	var i = t.length, a = 0;
	return function(e) {
		for (var r = a; r < i; r++) {
			var o = t[r].interval;
			if (o[0] <= e && e <= o[1]) {
				a = r;
				break;
			}
		}
		if (r === i) for (r = a - 1; r >= 0; r--) {
			var o = t[r].interval;
			if (o[0] <= e && e <= o[1]) {
				a = r;
				break;
			}
		}
		return r >= 0 && r < i && n[r];
	};
}
function uL(e, t) {
	var n = e[1] - e[0];
	return t = [(t[0] - e[0]) / n, (t[1] - e[0]) / n], function(e) {
		return e >= t[0] && e <= t[1];
	};
}
var dL = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.render = function(e, t, n) {
		var r;
		t.eachComponent("visualMap", function(t) {
			t.eachTargetSeries(function(n) {
				n === e && (r = t);
			});
		}), this._progressiveEls = null, this.group.removeAll();
		var i = e.coordinateSystem;
		i.type === "cartesian2d" || i.type === "calendar" || i.type === "matrix" ? this._renderOnGridLike(e, n, 0, e.getData().count()) : iA(i) && this._renderOnGeo(i, e, r, n);
	}, t.prototype.incrementalPrepareRender = function(e, t, n) {
		this.group.removeAll();
	}, t.prototype.incrementalRender = function(e, t, n, r) {
		var i = t.coordinateSystem;
		i && (iA(i) ? this.render(t, n, r) : (this._progressiveEls = [], this._renderOnGridLike(t, r, e.start, e.end, !0)));
	}, t.prototype.eachRendered = function(e) {
		_m(this._progressiveEls || this.group, e);
	}, t.prototype._renderOnGridLike = function(e, t, n, r, i) {
		var a = e.coordinateSystem, o = rA(a, "cartesian2d"), s = rA(a, "matrix"), c, l, u, d;
		if (o) {
			var f = a.getAxis("x"), p = a.getAxis("y");
			c = hO(f).w + .5, l = hO(p).w + .5, u = f.scale.getExtent(), d = p.scale.getExtent();
		}
		for (var m = this.group, h = e.getData(), g = e.getModel(["emphasis", "itemStyle"]).getItemStyle(), _ = e.getModel(["blur", "itemStyle"]).getItemStyle(), v = e.getModel(["select", "itemStyle"]).getItemStyle(), y = e.get(["itemStyle", "borderRadius"]), b = Pm(e), x = e.getModel("emphasis"), S = x.get("focus"), C = x.get("blurScope"), w = x.get("disabled"), T = o || s ? [
			h.mapDimension("x"),
			h.mapDimension("y"),
			h.mapDimension("value")
		] : [h.mapDimension("time"), h.mapDimension("value")], E = n; E < r; E++) {
			var D = void 0, O = h.getItemVisual(E, "style");
			if (o) {
				var k = h.get(T[0], E), A = h.get(T[1], E);
				if (isNaN(h.get(T[2], E)) || isNaN(k) || isNaN(A) || k < u[0] || k > u[1] || A < d[0] || A > d[1]) continue;
				var j = a.dataToPoint([k, A]);
				D = new bu({
					shape: {
						x: j[0] - c / 2,
						y: j[1] - l / 2,
						width: c,
						height: l
					},
					style: O
				});
			} else if (s) {
				var ee = a.dataToLayout([h.get(T[0], E), h.get(T[1], E)]).rect;
				if (_e(ee.x)) continue;
				D = new bu({
					z2: 1,
					shape: ee,
					style: O
				});
			} else {
				if (isNaN(h.get(T[1], E))) continue;
				var M = a.dataToLayout([h.get(T[0], E)]), ee = M.contentRect || M.rect;
				if (_e(ee.x) || _e(ee.y)) continue;
				D = new bu({
					z2: 1,
					shape: ee,
					style: O
				});
			}
			if (h.hasItemOption) {
				var te = h.getItemModel(E), N = te.getModel("emphasis");
				g = N.getModel("itemStyle").getItemStyle(), _ = te.getModel(["blur", "itemStyle"]).getItemStyle(), v = te.getModel(["select", "itemStyle"]).getItemStyle(), y = te.get(["itemStyle", "borderRadius"]), S = N.get("focus"), C = N.get("blurScope"), w = N.get("disabled"), b = Pm(te);
			}
			D.shape.r = y;
			var ne = e.getRawValue(E), P = "-";
			ne && ne[2] != null && (P = ne[2] + ""), Nm(D, b, {
				labelFetcher: e,
				labelDataIndex: E,
				defaultOpacity: O.opacity,
				defaultText: P
			}), D.ensureState("emphasis").style = g, D.ensureState("blur").style = _, D.ensureState("select").style = v, qd(D, S, C, w), D.incremental = $s(e, i), i && (D.states.emphasis.hoverLayer = 2), m.add(D), h.setItemGraphicEl(E, D), this._progressiveEls && this._progressiveEls.push(D);
		}
	}, t.prototype._renderOnGeo = function(e, t, n, r) {
		var i = n.targetVisuals.inRange, a = n.targetVisuals.outOfRange, o = t.getData(), s = this._hmLayer || this._hmLayer || new cL();
		s.blurSize = t.get("blurSize"), s.pointSize = t.get("pointSize"), s.minOpacity = t.get("minOpacity"), s.maxOpacity = t.get("maxOpacity");
		var c = e.getViewRect().clone(), l = e.getRoamTransform();
		c.applyTransform(l);
		var u = Math.max(c.x, 0), d = Math.max(c.y, 0), f = Math.min(c.width + c.x, r.getWidth()), p = Math.min(c.height + c.y, r.getHeight()), m = f - u, h = p - d, g = [
			o.mapDimension("lng"),
			o.mapDimension("lat"),
			o.mapDimension("value")
		], _ = o.mapArray(g, function(t, n, r) {
			var i = e.dataToPoint([t, n]);
			return i[0] -= u, i[1] -= d, i.push(r), i;
		}), v = n.getExtent(), y = n.type === "visualMap.continuous" ? uL(v, n.option.range) : lL(v, n.getPieceList(), n.option.selected);
		s.update(_, m, h, i.color.getNormalizer(), {
			inRange: i.color.getColorMapper(),
			outOfRange: a.color.getColorMapper()
		}, y);
		var b = new fu({
			style: {
				width: m,
				height: h,
				x: u,
				y: d,
				image: s.canvas
			},
			silent: !0
		});
		this.group.add(b);
	}, t.type = "heatmap", t;
}(sb), fL = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.getInitialData = function(e, t) {
		return aT(null, this, { generateCoord: "value" });
	}, t.prototype.preventIncremental = function() {
		var e = wg.get(this.get("coordinateSystem"));
		if (e && e.dimensions) return e.dimensions[0] === "lng" && e.dimensions[1] === "lat";
	}, t.type = "series.heatmap", t.dependencies = [
		"grid",
		"geo",
		"calendar",
		"matrix"
	], t.defaultOption = {
		coordinateSystem: "cartesian2d",
		z: 2,
		geoIndex: 0,
		blurSize: 30,
		pointSize: 20,
		maxOpacity: 1,
		minOpacity: 0,
		select: { itemStyle: { borderColor: Q.color.primary } }
	}, t;
}(Jy);
//#endregion
//#region node_modules/echarts/lib/chart/heatmap/install.js
function pL(e) {
	e.registerChartView(dL), e.registerSeriesModel(fL);
}
//#endregion
//#region node_modules/echarts/lib/animation/customGraphicTransition.js
var mL = {
	position: ["x", "y"],
	scale: ["scaleX", "scaleY"],
	origin: ["originX", "originY"]
}, hL = R(mL);
ae(da, function(e, t) {
	return e[t] = 1, e;
}, {}), da.join(", ");
var gL = [
	"",
	"style",
	"shape",
	"extra"
], _L = X();
function vL(e, t, n, r, i) {
	var a = e + "Animation", o = Dp(e, r, i) || {}, s = _L(t).userDuring;
	return o.duration > 0 && (o.during = s ? z(OL, {
		el: t,
		userDuring: s
	}) : null, o.setToFinal = !0, o.scope = e), M(o, n[a]), o;
}
function yL(e, t, n, r) {
	r ||= {};
	var i = r.dataIndex, a = r.isInit, o = r.clearStyle, s = n.isAnimationEnabled(), c = _L(e), l = t.style;
	c.userDuring = t.during;
	var u = {}, d = {};
	if (ML(e, t, d), e.type === "compound") for (var f = e.shape.paths, p = t.shape.paths, m = 0; m < p.length; m++) {
		var h = p[m];
		AL("shape", h, f[m]);
	}
	else AL("shape", t, d), AL("extra", t, d);
	if (!a && s && (jL(e, t, u), kL("shape", e, t, u), kL("extra", e, t, u), NL(e, t, l, u)), d.style = l, CL(e, d, o), TL(e, t), s) {
		if (a) {
			var g = {};
			I(gL, function(e) {
				var n = e ? t[e] : t;
				n && n.enterFrom && (e && (g[e] = g[e] || {}), M(e ? g[e] : g, n.enterFrom));
			});
			var _ = vL("enter", e, t, n, i);
			_.duration > 0 && e.animateFrom(g, _);
		} else wL(e, t, i || 0, n, u);
	}
	bL(e, t), l ? e.dirty() : e.markRedraw();
}
function bL(e, t) {
	for (var n = _L(e).leaveToProps, r = 0; r < gL.length; r++) {
		var i = gL[r], a = i ? t[i] : t;
		a && a.leaveTo && (n ||= _L(e).leaveToProps = {}, i && (n[i] = n[i] || {}), M(i ? n[i] : n, a.leaveTo));
	}
}
function xL(e, t, n, r) {
	if (e) {
		var i = e.parent, a = _L(e).leaveToProps;
		if (a) {
			var o = vL("update", e, t, n, 0);
			o.done = function() {
				i && i.remove(e), r && r();
			}, e.animateTo(a, o);
		} else i && i.remove(e), r && r();
	}
}
function SL(e) {
	return e === "all";
}
function CL(e, t, n) {
	var r = t.style;
	if (!e.isGroup && r) {
		if (n) {
			e.useStyle({});
			for (var i = e.animators, a = 0; a < i.length; a++) {
				var o = i[a];
				o.targetName === "style" && o.changeTarget(e.style);
			}
		}
		e.setStyle(r);
	}
	t && (t.style = null, t && e.attr(t), t.style = r);
}
function wL(e, t, n, r, i) {
	if (i) {
		var a = vL("update", e, t, r, n);
		a.duration > 0 && e.animateFrom(i, a);
	}
}
function TL(e, t) {
	q(t, "silent") && (e.silent = t.silent), q(t, "ignore") && (e.ignore = t.ignore), e instanceof $c && q(t, "invisible") && (e.invisible = t.invisible), e instanceof ou && q(t, "autoBatch") && (e.autoBatch = t.autoBatch);
}
var EL = {}, DL = {
	setTransform: function(e, t) {
		return EL.el[e] = t, this;
	},
	getTransform: function(e) {
		return EL.el[e];
	},
	setShape: function(e, t) {
		var n = EL.el, r = n.shape ||= {};
		return r[e] = t, n.dirtyShape && n.dirtyShape(), this;
	},
	getShape: function(e) {
		var t = EL.el.shape;
		if (t) return t[e];
	},
	setStyle: function(e, t) {
		var n = EL.el, r = n.style;
		return r && (r[e] = t, n.dirtyStyle && n.dirtyStyle()), this;
	},
	getStyle: function(e) {
		var t = EL.el.style;
		if (t) return t[e];
	},
	setExtra: function(e, t) {
		var n = EL.el.extra || (EL.el.extra = {});
		return n[e] = t, this;
	},
	getExtra: function(e) {
		var t = EL.el.extra;
		if (t) return t[e];
	}
};
function OL() {
	var e = this, t = e.el;
	if (t) {
		var n = _L(t).userDuring, r = e.userDuring;
		n === r ? (EL.el = t, r(DL)) : e.el = e.userDuring = null;
	}
}
function kL(e, t, n, r) {
	var i = n[e];
	if (i) {
		var a = t[e], o;
		if (a) {
			var s = n.transition, c = i.transition;
			if (c) {
				if (!o && (o = r[e] = {}), SL(c)) M(o, a);
				else for (var l = ss(c), u = 0; u < l.length; u++) {
					var d = l[u], f = a[d];
					o[d] = f;
				}
			} else if (SL(s) || P(s, e) >= 0) {
				!o && (o = r[e] = {});
				for (var p = R(a), u = 0; u < p.length; u++) {
					var d = p[u], f = a[d];
					PL(i[d], f) && (o[d] = f);
				}
			}
		}
	}
}
function AL(e, t, n) {
	var r = t[e];
	if (r) for (var i = n[e] = {}, a = R(r), o = 0; o < a.length; o++) {
		var s = a[o];
		i[s] = pi(r[s]);
	}
}
function jL(e, t, n) {
	for (var r = t.transition, i = SL(r) ? da : ss(r || []), a = 0; a < i.length; a++) {
		var o = i[a];
		o !== "style" && o !== "shape" && o !== "extra" && (n[o] = e[o]);
	}
}
function ML(e, t, n) {
	for (var r = 0; r < hL.length; r++) {
		var i = hL[r], a = mL[i], o = t[i];
		o && (n[a[0]] = o[0], n[a[1]] = o[1]);
	}
	for (var r = 0; r < da.length; r++) {
		var s = da[r];
		t[s] != null && (n[s] = t[s]);
	}
}
function NL(e, t, n, r) {
	if (n) {
		var i = e.style, a;
		if (i) {
			var o = n.transition, s = t.transition;
			if (o && !SL(o)) {
				var c = ss(o);
				!a && (a = r.style = {});
				for (var l = 0; l < c.length; l++) {
					var u = c[l], d = i[u];
					a[u] = d;
				}
			} else if (e.getAnimationStyleProps && (SL(s) || SL(o) || P(s, "style") >= 0)) {
				var f = e.getAnimationStyleProps(), p = f ? f.style : null;
				if (p) {
					!a && (a = r.style = {});
					for (var m = R(n), l = 0; l < m.length; l++) {
						var u = m[l];
						if (p[u]) {
							var d = i[u];
							a[u] = d;
						}
					}
				}
			}
		}
	}
}
function PL(e, t) {
	return ie(e) ? e !== t : e != null && isFinite(e);
}
//#endregion
//#region node_modules/echarts/lib/animation/customGraphicKeyframeAnimation.js
var FL = X(), IL = [
	"percent",
	"easing",
	"shape",
	"style",
	"extra"
];
function LL(e) {
	e.stopAnimation("keyframe"), e.attr(FL(e));
}
function RL(e, t, n) {
	if (n.isAnimationEnabled() && t) {
		if (V(t)) I(t, function(t) {
			RL(e, t, n);
		});
		else {
			var r = t.keyframes, i = t.duration;
			if (n && i == null) {
				var a = Dp("enter", n, 0);
				i = a && a.duration;
			}
			if (r && i) {
				var o = FL(e);
				I(gL, function(n) {
					if (!n || e[n]) {
						var a;
						r.sort(function(e, t) {
							return e.percent - t.percent;
						}), I(r, function(r) {
							var s = e.animators, c = n ? r[n] : r;
							if (c) {
								var l = R(c);
								if (n || (l = oe(l, function(e) {
									return P(IL, e) < 0;
								})), l.length) {
									a || (a = e.animate(n, t.loop, !0), a.scope = "keyframe");
									for (var u = 0; u < s.length; u++) s[u] !== a && s[u].targetName === a.targetName && s[u].stopTracks(l);
									n && (o[n] = o[n] || {});
									var d = n ? o[n] : o;
									I(l, function(t) {
										d[t] = ((n ? e[n] : e) || {})[t];
									}), a.whenWithKeys(i * r.percent, c, l, r.easing);
								}
							}
						}), a && a.delay(t.delay || 0).duration(i).start(t.easing);
					}
				});
			}
		}
	}
}
//#endregion
//#region node_modules/echarts/lib/component/axisPointer/BaseAxisPointer.js
var zL = X(), BL = A, VL = z, HL = function() {
	function e() {
		this._dragging = !1, this.animationThreshold = 15;
	}
	return e.prototype.render = function(e, t, n, r) {
		var i = t.get("value"), a = t.get("status");
		if (this._axisModel = e, this._axisPointerModel = t, this._api = n, r || this._lastValue !== i || this._lastStatus !== a) {
			this._lastValue = i, this._lastStatus = a;
			var o = this._group, s = this._handle;
			if (!a || a === "hide") o && o.hide(), s && s.hide();
			else {
				o && o.show(), s && s.show();
				var c = {};
				this.makeElOption(c, i, e, t, n);
				var l = c.graphicKey;
				l !== this._lastGraphicKey && this.clear(n), this._lastGraphicKey = l;
				var u = this._moveAnimation = this.determineAnimation(e, t);
				if (!o) o = this._group = new Wa(), this.createPointerEl(o, c, e, t), this.createLabelEl(o, c, e, t), n.getZr().add(o);
				else {
					var d = B(UL, t, u);
					this.updatePointerEl(o, c, d), this.updateLabelEl(o, c, d, t);
				}
				qL(o, t, !0), this._renderHandle(i);
			}
		}
	}, e.prototype.remove = function(e) {
		this.clear(e);
	}, e.prototype.dispose = function(e) {
		this.clear(e);
	}, e.prototype.determineAnimation = function(e, t) {
		var n = t.get("animation"), r = e.axis, i = r.type === "category", a = t.get("snap");
		if (!a && !i) return !1;
		if (n === "auto" || n == null) {
			var o = this.animationThreshold;
			if (i && hO(r).w > o) return !0;
			if (a) {
				var s = PN(e).seriesDataCount, c = r.getExtent();
				return Math.abs(c[0] - c[1]) / s > o;
			}
			return !1;
		}
		return n === !0;
	}, e.prototype.makeElOption = function(e, t, n, r, i) {}, e.prototype.createPointerEl = function(e, t, n, r) {
		var i = t.pointer;
		if (i) {
			var a = zL(e).pointerEl = new Ip[i.type](BL(t.pointer));
			e.add(a);
		}
	}, e.prototype.createLabelEl = function(e, t, n, r) {
		if (t.label) {
			var i = zL(e).labelEl = new Tu(BL(t.label));
			e.add(i), GL(i, r);
		}
	}, e.prototype.updatePointerEl = function(e, t, n) {
		var r = zL(e).pointerEl;
		r && t.pointer && (r.setStyle(t.pointer.style), n(r, { shape: t.pointer.shape }));
	}, e.prototype.updateLabelEl = function(e, t, n, r) {
		var i = zL(e).labelEl;
		i && (i.setStyle(t.label.style), n(i, {
			x: t.label.x,
			y: t.label.y
		}), GL(i, r));
	}, e.prototype._renderHandle = function(e) {
		if (!this._dragging && this.updateHandleTransform) {
			var t = this._axisPointerModel, n = this._api.getZr(), r = this._handle, i = t.getModel("handle"), a = t.get("status");
			if (!i.get("show") || !a || a === "hide") r && n.remove(r), this._handle = null;
			else {
				var o;
				this._handle || (o = !0, r = this._handle = sm(i.get("icon"), {
					cursor: "move",
					draggable: !0,
					onmousemove: function(e) {
						It(e.event);
					},
					onmousedown: VL(this._onHandleDragMove, this, 0, 0),
					drift: VL(this._onHandleDragMove, this),
					ondragend: VL(this._onHandleDragEnd, this)
				}), n.add(r)), qL(r, t, !1), r.setStyle(i.getItemStyle(null, [
					"color",
					"borderColor",
					"borderWidth",
					"opacity",
					"shadowColor",
					"shadowBlur",
					"shadowOffsetX",
					"shadowOffsetY"
				]));
				var s = i.get("size");
				V(s) || (s = [s, s]), r.scaleX = s[0] / 2, r.scaleY = s[1] / 2, _b(this, "_doDispatchAxisPointer", i.get("throttle") || 0, "fixRate"), this._moveHandleToValue(e, o);
			}
		}
	}, e.prototype._moveHandleToValue = function(e, t) {
		UL(this._axisPointerModel, !t && this._moveAnimation, this._handle, KL(this.getHandleTransform(e, this._axisModel, this._axisPointerModel)));
	}, e.prototype._onHandleDragMove = function(e, t) {
		var n = this._handle;
		if (n) {
			this._dragging = !0;
			var r = this.updateHandleTransform(KL(n), [e, t], this._axisModel, this._axisPointerModel);
			this._payloadInfo = r, n.stopAnimation(), n.attr(KL(r)), zL(n).lastProp = null, this._doDispatchAxisPointer();
		}
	}, e.prototype._doDispatchAxisPointer = function() {
		if (this._handle) {
			var e = this._payloadInfo, t = this._axisModel;
			this._api.dispatchAction({
				type: "updateAxisPointer",
				x: e.cursorPoint[0],
				y: e.cursorPoint[1],
				tooltipOption: e.tooltipOption,
				axesInfo: [{
					axisDim: t.axis.dim,
					axisIndex: t.componentIndex
				}]
			});
		}
	}, e.prototype._onHandleDragEnd = function() {
		if (this._dragging = !1, this._handle) {
			var e = this._axisPointerModel.get("value");
			this._moveHandleToValue(e), this._api.dispatchAction({ type: "hideTip" });
		}
	}, e.prototype.clear = function(e) {
		this._lastValue = null, this._lastStatus = null;
		var t = e.getZr(), n = this._group, r = this._handle;
		t && n && (this._lastGraphicKey = null, n && t.remove(n), r && t.remove(r), this._group = null, this._handle = null, this._payloadInfo = null), vb(this, "_doDispatchAxisPointer");
	}, e.prototype.doClear = function() {}, e.prototype.buildLabel = function(e, t, n) {
		return n ||= 0, {
			x: e[n],
			y: e[1 - n],
			width: t[n],
			height: t[1 - n]
		};
	}, e;
}();
function UL(e, t, n, r) {
	WL(zL(n).lastProp, r) || (zL(n).lastProp = r, t ? kp(n, r, e) : (n.stopAnimation(), n.attr(r)));
}
function WL(e, t) {
	if (W(e) && W(t)) {
		var n = !0;
		return I(t, function(t, r) {
			n &&= WL(e[r], t);
		}), !!n;
	}
	return e === t;
}
function GL(e, t) {
	e[t.get(["label", "show"]) ? "show" : "hide"]();
}
function KL(e) {
	return {
		x: e.x || 0,
		y: e.y || 0,
		rotation: e.rotation || 0
	};
}
function qL(e, t, n) {
	var r = t.get("z"), i = t.get("zlevel");
	e && e.traverse(function(e) {
		e.type !== "group" && (r != null && (e.z = r), i != null && (e.zlevel = i), e.silent = n);
	});
}
//#endregion
//#region node_modules/echarts/lib/component/axisPointer/viewHelper.js
function JL(e) {
	var t = e.get("type"), n = e.getModel(t + "Style"), r;
	return t === "line" ? (r = n.getLineStyle(), r.fill = null) : t === "shadow" && (r = n.getAreaStyle(), r.stroke = null), r;
}
function YL(e, t, n, r, i) {
	var a = ZL(n.get("value"), t.axis, t.ecModel, n.get("seriesDataIndices"), {
		precision: n.get(["label", "precision"]),
		formatter: n.get(["label", "formatter"])
	}), o = n.getModel("label"), s = fg(o.get("padding") || 0), c = o.getFont(), l = xa(a, c), u = i.position, d = l.width + s[1] + s[3], f = l.height + s[0] + s[2], p = i.align;
	p === "right" && (u[0] -= d), p === "center" && (u[0] -= d / 2);
	var m = i.verticalAlign;
	m === "bottom" && (u[1] -= f), m === "middle" && (u[1] -= f / 2), XL(u, d, f, r);
	var h = o.get("backgroundColor");
	(!h || h === "auto") && (h = t.get([
		"axisLine",
		"lineStyle",
		"color"
	])), e.label = {
		x: u[0],
		y: u[1],
		style: Fm(o, {
			text: a,
			font: c,
			fill: o.getTextColor(),
			padding: s,
			backgroundColor: h
		}),
		z2: 10
	};
}
function XL(e, t, n, r) {
	var i = r.getWidth(), a = r.getHeight();
	e[0] = Math.min(e[0] + t, i) - t, e[1] = Math.min(e[1] + n, a) - n, e[0] = Math.max(e[0], 0), e[1] = Math.max(e[1], 0);
}
function ZL(e, t, n, r, i) {
	e = t.scale.parse(e);
	var a = t.scale.getLabel({ value: e }, { precision: i.precision }), o = i.formatter;
	if (o) {
		var s = {
			value: pE(t, { value: e }),
			axisDimension: t.dim,
			axisIndex: t.index,
			seriesData: []
		};
		I(r, function(e) {
			var t = n.getSeriesByIndex(e.seriesIndex), r = e.dataIndexInside, i = t && t.getDataParams(r);
			i && s.seriesData.push(i);
		}), U(o) ? a = o.replace("{value}", a) : H(o) && (a = o(s));
	}
	return a;
}
function QL(e, t, n) {
	var r = Ut();
	return Jt(r, r, n.rotation), qt(r, r, n.position), em([e.dataToCoord(t), (n.labelOffset || 0) + (n.labelDirection || 1) * (n.labelMargin || 0)], r);
}
function $L(e, t, n, r, i, a) {
	var o = KA.innerTextLayout(n.rotation, 0, n.labelDirection);
	n.labelMargin = i.get(["label", "margin"]), YL(t, r, i, a, {
		position: QL(r.axis, e, n),
		align: o.textAlign,
		verticalAlign: o.textVerticalAlign
	});
}
function eR(e, t, n) {
	return n ||= 0, {
		x1: e[n],
		y1: e[1 - n],
		x2: t[n],
		y2: t[1 - n]
	};
}
function tR(e, t, n) {
	return n ||= 0, {
		x: e[n],
		y: e[1 - n],
		width: t[n],
		height: t[1 - n]
	};
}
function nR(e, t, n) {
	return hO(e, {
		fromStat: { sers: L(t, function(e) {
			return n.getSeriesByIndex(e.seriesIndex);
		}) },
		min: 1
	}).w;
}
function rR(e, t, n) {
	return [uo(lo(t[0], t[1]), e - n / 2), lo(e + n / 2, uo(t[0], t[1]))];
}
//#endregion
//#region node_modules/echarts/lib/component/axisPointer/CartesianAxisPointer.js
var iR = function(e) {
	n(t, e);
	function t() {
		return e !== null && e.apply(this, arguments) || this;
	}
	return t.prototype.makeElOption = function(e, t, n, r, i) {
		var a = n.axis, o = a.grid, s = r.get("type"), c = a.getGlobalExtent(), l = aR(o, a).getOtherAxis(a).getGlobalExtent(), u = a.toGlobalCoord(a.dataToCoord(t, !0));
		if (s && s !== "none") {
			var d = JL(r), f = oR[s](a, u, c, l, r.get("seriesDataIndices"), r.ecModel);
			f.style = d, e.graphicKey = f.type, e.pointer = f;
		}
		$L(t, e, pj(o.getRect(), n), n, r, i);
	}, t.prototype.getHandleTransform = function(e, t, n) {
		var r = pj(t.axis.grid.getRect(), t, { labelInside: !1 });
		r.labelMargin = n.get(["handle", "margin"]);
		var i = QL(t.axis, e, r);
		return {
			x: i[0],
			y: i[1],
			rotation: r.rotation + (r.labelDirection < 0 ? Math.PI : 0)
		};
	}, t.prototype.updateHandleTransform = function(e, t, n, r) {
		var i = n.axis, a = i.grid, o = i.getGlobalExtent(!0), s = aR(a, i).getOtherAxis(i).getGlobalExtent(), c = i.dim === "x" ? 0 : 1, l = [e.x, e.y];
		l[c] += t[c], l[c] = lo(o[1], l[c]), l[c] = uo(o[0], l[c]);
		var u = (s[1] + s[0]) / 2, d = [u, u];
		return d[c] = l[c], {
			x: l[0],
			y: l[1],
			rotation: e.rotation,
			cursorPoint: d,
			tooltipOption: [{ verticalAlign: "middle" }, { align: "center" }][c]
		};
	}, t;
}(HL);
function aR(e, t) {
	var n = {};
	return n[t.dim + "AxisIndex"] = t.index, e.getCartesian(n);
}
var oR = {
	line: function(e, t, n, r) {
		return {
			type: "Line",
			subPixelOptimize: !0,
			shape: eR([t, r[0]], [t, r[1]], sR(e))
		};
	},
	shadow: function(e, t, n, r, i, a) {
		var o = nR(e, i, a), s = r[1] - r[0], c = rR(t, n, o), l = c[0], u = c[1];
		return {
			type: "Rect",
			shape: tR([l, r[0]], [u - l, s], sR(e))
		};
	}
};
function sR(e) {
	return e.dim === "x" ? 0 : 1;
}
//#endregion
//#region node_modules/echarts/lib/component/axisPointer/AxisPointerModel.js
var cR = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.type = "axisPointer", t.defaultOption = {
		show: "auto",
		z: 50,
		type: "line",
		snap: !1,
		triggerTooltip: !0,
		triggerEmphasis: !0,
		value: null,
		status: null,
		link: [],
		animation: null,
		animationDurationUpdate: 200,
		lineStyle: {
			color: Q.color.border,
			width: 1,
			type: "dashed"
		},
		shadowStyle: { color: Q.color.shadowTint },
		label: {
			show: !0,
			formatter: null,
			precision: "auto",
			margin: 3,
			color: Q.color.neutral00,
			padding: [
				5,
				7,
				5,
				7
			],
			backgroundColor: Q.color.accent60,
			borderColor: null,
			borderWidth: 0,
			borderRadius: 3
		},
		handle: {
			show: !1,
			icon: "M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4h1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7v-1.2h6.6z M13.3,22H6.7v-1.2h6.6z M13.3,19.6H6.7v-1.2h6.6z",
			size: 45,
			margin: 50,
			color: Q.color.accent40,
			throttle: 40
		}
	}, t;
}(Jg), lR = X(), uR = I;
function dR(e, t, n) {
	if (!i.node) {
		var r = t.getZr();
		lR(r).records || (lR(r).records = {}), fR(r, t);
		var a = lR(r).records[e] || (lR(r).records[e] = {});
		a.handler = n;
	}
}
function fR(e, t) {
	if (lR(e).initialized) return;
	lR(e).initialized = !0, n("click", B(hR, "click")), n("mousemove", B(hR, "mousemove")), n("mousewheel", B(hR, "mousewheel")), n("globalout", mR);
	function n(n, r) {
		e.on(n, function(n) {
			var i = gR(t);
			uR(lR(e).records, function(e) {
				e && r(e, n, i.dispatchAction);
			}), pR(i.pendings, t);
		});
	}
}
function pR(e, t) {
	var n = e.showTip.length, r = e.hideTip.length, i;
	n ? i = e.showTip[n - 1] : r && (i = e.hideTip[r - 1]), i && (i.dispatchAction = null, t.dispatchAction(i));
}
function mR(e, t, n) {
	e.handler("leave", null, n);
}
function hR(e, t, n, r) {
	t.handler(e, n, r);
}
function gR(e) {
	var t = {
		showTip: [],
		hideTip: []
	}, n = function(r) {
		var i = t[r.type];
		i ? i.push(r) : (r.dispatchAction = n, e.dispatchAction(r));
	};
	return {
		dispatchAction: n,
		pendings: t
	};
}
function _R(e, t) {
	if (!i.node) {
		var n = t.getZr();
		(lR(n).records || {})[e] && (lR(n).records[e] = null);
	}
}
//#endregion
//#region node_modules/echarts/lib/component/axisPointer/AxisPointerView.js
var vR = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.render = function(e, t, n) {
		var r = t.getComponent("tooltip"), i = e.get("triggerOn") || r && r.get("triggerOn") || "mousemove|click|mousewheel";
		dR("axisPointer", n, function(e, t, n) {
			i !== "none" && (e === "leave" || i.indexOf(e) >= 0) && n({
				type: "updateAxisPointer",
				currTrigger: e,
				x: t && t.offsetX,
				y: t && t.offsetY
			});
		});
	}, t.prototype.remove = function(e, t) {
		_R("axisPointer", t);
	}, t.prototype.dispose = function(e, t) {
		_R("axisPointer", t);
	}, t.type = "axisPointer", t;
}(rb);
//#endregion
//#region node_modules/echarts/lib/component/axisPointer/findPointFromSeries.js
function yR(e, t) {
	var n = [], r = e.seriesIndex, i;
	if (r == null || !(i = t.getSeriesByIndex(r))) return { point: [] };
	var a = i.getData(), o = Ds(a, e);
	if (o == null || o < 0 || V(o)) return { point: [] };
	var s = a.getItemGraphicEl(o), c = i.coordinateSystem;
	if (i.getTooltipPosition) n = i.getTooltipPosition(o) || [];
	else if (c && c.dataToPoint) {
		if (e.isStacked) {
			var l = c.getBaseAxis(), u = c.getOtherAxis(l).dim, d = l.dim, f = +(u === "x" || u === "radius"), p = a.mapDimension(d), m = [];
			m[f] = a.get(p, o), m[1 - f] = a.get(a.getCalculationInfo("stackResultDimension"), o), n = c.dataToPoint(m) || [];
		} else n = c.dataToPoint(a.getValues(L(c.dimensions, function(e) {
			return a.mapDimension(e);
		}), o)) || [];
	} else if (s) {
		var h = s.getBoundingRect().clone();
		h.applyTransform(s.transform), n = [h.x + h.width / 2, h.y + h.height / 2];
	}
	return {
		point: n,
		el: s
	};
}
//#endregion
//#region node_modules/echarts/lib/component/axisPointer/axisTrigger.js
var bR = X();
function xR(e, t, n) {
	var r = e.currTrigger, i = [e.x, e.y], a = e, o = e.dispatchAction || z(n.dispatchAction, n), s = t.getComponent("axisPointer").coordSysAxesInfo;
	if (s) {
		jR(i) && (i = yR({
			seriesIndex: a.seriesIndex,
			dataIndex: a.dataIndex
		}, t).point);
		var c = jR(i), l = a.axesInfo, u = s.axesInfo, d = r === "leave" || jR(i), f = {}, p = {}, m = {
			list: [],
			map: {}
		}, h = {
			showPointer: B(wR, p),
			showTooltip: B(TR, m)
		};
		I(s.coordSysMap, function(e, t) {
			var n = c || e.containPoint(i);
			I(s.coordSysAxesInfo[t], function(e, t) {
				var r = e.axis, a = kR(l, e);
				if (!d && n && (!l || a)) {
					var o = a && a.value;
					o == null && !c && (o = r.pointToData(i)), o != null && SR(e, o, h, !1, f);
				}
			});
		});
		var g = {};
		return I(u, function(e, t) {
			var n = e.linkGroup;
			n && !p[t] && I(n.axesInfo, function(t, r) {
				var i = p[r];
				if (t !== e && i) {
					var a = i.value;
					n.mapper && (a = e.axis.scale.parse(n.mapper(a, AR(t), AR(e)))), g[e.key] = a;
				}
			});
		}), I(g, function(e, t) {
			SR(u[t], e, h, !0, f);
		}), ER(p, u, f), DR(m, i, e, o), OR(u, o, n), f;
	}
}
function SR(e, t, n, r, i) {
	var a = e.axis;
	if (!a.scale.isBlank() && a.containData(t)) {
		if (!e.involveSeries) n.showPointer(e, t);
		else {
			var o = CR(t, e), s = o.payloadBatch, c = o.snapToValue;
			s[0] && i.seriesIndex == null && M(i, s[0]), !r && e.snap && a.containData(c) && c != null && (t = c), n.showPointer(e, t, s), n.showTooltip(e, o, c);
		}
	}
}
function CR(e, t) {
	var n = t.axis, r = n.dim, i = e, a = [], o = Number.MAX_VALUE, s = -1;
	return I(t.seriesModels, function(t, c) {
		var l = t.getData().mapDimensionsAll(r), u, d;
		if (t.getAxisTooltipData) {
			var f = t.getAxisTooltipData(l, e, n);
			d = f.dataIndices, u = f.nestestValue;
		} else {
			if (d = t.indicesOfNearest(r, l[0], e, n.type === "category" ? .5 : null), !d.length) return;
			u = t.getData().get(l[0], d[0]);
		}
		if (Zo(u)) {
			var p = e - u, m = Math.abs(p);
			m <= o && ((m < o || p >= 0 && s < 0) && (o = m, s = p, i = u, a.length = 0), I(d, function(e) {
				a.push({
					seriesIndex: t.seriesIndex,
					dataIndexInside: e,
					dataIndex: t.getData().getRawIndex(e)
				});
			}));
		}
	}), {
		payloadBatch: a,
		snapToValue: i
	};
}
function wR(e, t, n, r) {
	e[t.key] = {
		value: n,
		payloadBatch: r
	};
}
function TR(e, t, n, r) {
	var i = n.payloadBatch, a = t.axis, o = a.model, s = t.axisPointerModel;
	if (t.triggerTooltip && i.length) {
		var c = t.coordSys.model, l = LN(c), u = e.map[l];
		u || (u = e.map[l] = {
			coordSysId: c.id,
			coordSysIndex: c.componentIndex,
			coordSysType: c.type,
			coordSysMainType: c.mainType,
			dataByAxis: []
		}, e.list.push(u)), u.dataByAxis.push({
			axisDim: a.dim,
			axisIndex: o.componentIndex,
			axisType: o.type,
			axisId: o.id,
			value: r,
			valueLabelOpt: {
				precision: s.get(["label", "precision"]),
				formatter: s.get(["label", "formatter"])
			},
			seriesDataIndices: i.slice()
		});
	}
}
function ER(e, t, n) {
	var r = n.axesInfo = [];
	I(t, function(t, n) {
		var i = t.axisPointerModel.option, a = e[n];
		a ? (!t.useHandle && (i.status = "show"), i.value = a.value, i.seriesDataIndices = (a.payloadBatch || []).slice()) : !t.useHandle && (i.status = "hide"), i.status === "show" && r.push({
			axisDim: t.axis.dim,
			axisIndex: t.axis.model.componentIndex,
			value: i.value
		});
	});
}
function DR(e, t, n, r) {
	if (jR(t) || !e.list.length) r({ type: "hideTip" });
	else {
		var i = ((e.list[0].dataByAxis[0] || {}).seriesDataIndices || [])[0] || {};
		r({
			type: "showTip",
			escapeConnect: !0,
			x: t[0],
			y: t[1],
			tooltipOption: n.tooltipOption,
			position: n.position,
			dataIndexInside: i.dataIndexInside,
			dataIndex: i.dataIndex,
			seriesIndex: i.seriesIndex,
			dataByCoordSys: e.list
		});
	}
}
function OR(e, t, n) {
	var r = n.getZr(), i = "axisPointerLastHighlights", a = bR(r)[i] || {}, o = bR(r)[i] = {};
	I(e, function(e, t) {
		var n = e.axisPointerModel.option;
		n.status === "show" && e.triggerEmphasis && I(n.seriesDataIndices, function(e) {
			o[e.seriesIndex + "|" + e.dataIndex] = e;
		});
	});
	var s = [], c = [];
	function l(e) {
		return {
			seriesIndex: e.seriesIndex,
			dataIndex: e.dataIndex
		};
	}
	I(a, function(e, t) {
		!o[t] && c.push(l(e));
	}), I(o, function(e, t) {
		!a[t] && s.push(l(e));
	}), c.length && n.dispatchAction({
		type: "downplay",
		escapeConnect: !0,
		notBlur: !0,
		batch: c
	}), s.length && n.dispatchAction({
		type: "highlight",
		escapeConnect: !0,
		notBlur: !0,
		batch: s
	});
}
function kR(e, t) {
	for (var n = 0; n < (e || []).length; n++) {
		var r = e[n];
		if (t.axis.dim === r.axisDim && t.axis.model.componentIndex === r.axisIndex) return r;
	}
}
function AR(e) {
	var t = e.axis.model, n = {}, r = n.axisDim = e.axis.dim;
	return n.axisIndex = n[r + "AxisIndex"] = t.componentIndex, n.axisName = n[r + "AxisName"] = t.name, n.axisId = n[r + "AxisId"] = t.id, n;
}
function jR(e) {
	return !e || e[0] == null || isNaN(e[0]) || e[1] == null || isNaN(e[1]);
}
//#endregion
//#region node_modules/echarts/lib/component/axisPointer/install.js
function MR(e) {
	zN.registerAxisPointerClass("CartesianAxisPointer", iR), e.registerComponentModel(cR), e.registerComponentView(vR), e.registerPreprocessor(function(e) {
		if (e) {
			(!e.axisPointer || e.axisPointer.length === 0) && (e.axisPointer = {});
			var t = e.axisPointer.link;
			t && !V(t) && (e.axisPointer.link = [t]);
		}
	}), e.registerProcessor(e.PRIORITY.PROCESSOR.STATISTIC, { overallReset: function(e, t) {
		e.getComponent("axisPointer").coordSysAxesInfo = DN(e, t);
	} }), e.registerAction({
		type: "updateAxisPointer",
		event: "updateAxisPointer",
		update: ":updateAxisPointer"
	}, xR);
}
//#endregion
//#region node_modules/echarts/lib/component/grid/install.js
function NR(e) {
	TD(XN), TD(MR);
}
//#endregion
//#region node_modules/echarts/lib/component/graphic/GraphicModel.js
function PR(e, t) {
	var n = e.existing;
	if (t.id = e.keyInfo.id, !t.type && n && (t.type = n.type), t.parentId == null) {
		var r = t.parentOption;
		r ? t.parentId = r.id : n && (t.parentId = n.parentId);
	}
	t.parentOption = null;
}
function FR(e, t) {
	var n;
	return I(t, function(t) {
		e[t] != null && e[t] !== "auto" && (n = !0);
	}), n;
}
function IR(e, t, n) {
	var r = M({}, n), i = e[t], a = n.$action || "merge";
	a === "merge" ? i ? (j(i, r, !0), Wg(i, r, { ignoreSize: !0 }), Kg(n, i), zR(n, i), zR(n, i, "shape"), zR(n, i, "style"), zR(n, i, "extra"), n.clipPath = i.clipPath) : e[t] = r : a === "replace" ? e[t] = r : a === "remove" && i && (e[t] = null);
}
var LR = [
	"transition",
	"enterFrom",
	"leaveTo"
], RR = LR.concat([
	"enterAnimation",
	"updateAnimation",
	"leaveAnimation"
]);
function zR(e, t, n) {
	if (n && (!e[n] && t[n] && (e[n] = {}), e = e[n], t = t[n]), e && t) for (var r = n ? LR : RR, i = 0; i < r.length; i++) {
		var a = r[i];
		e[a] == null && t[a] != null && (e[a] = t[a]);
	}
}
function BR(e, t) {
	if (e && (e.hv = t.hv = [FR(t, ["left", "right"]), FR(t, ["top", "bottom"])], e.type === "group")) {
		var n = e, r = t;
		n.width ??= r.width = 0, n.height ??= r.height = 0;
	}
}
var VR = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.preventAutoZ = !0, n;
	}
	return t.prototype.mergeOption = function(t, n) {
		var r = this.option.elements;
		this.option.elements = null, e.prototype.mergeOption.call(this, t, n), this.option.elements = r;
	}, t.prototype.optionUpdated = function(e, t) {
		var n = this.option, r = (t ? n : e).elements, i = n.elements = t ? [] : n.elements, a = [];
		this._flatten(r, a, null);
		var o = fs(i, a, "normalMerge"), s = this._elOptionsToUpdate = [];
		I(o, function(e, t) {
			var n = e.newOption;
			n && (s.push(n), PR(e, n), IR(i, t, n), BR(i[t], n));
		}, this), n.elements = oe(i, function(e) {
			return e && delete e.$action, e != null;
		});
	}, t.prototype._flatten = function(e, t, n) {
		I(e, function(e) {
			if (e) {
				n && (e.parentOption = n), t.push(e);
				var r = e.children;
				r && r.length && this._flatten(r, t, e), delete e.children;
			}
		}, this);
	}, t.prototype.useElOptionsToUpdate = function() {
		var e = this._elOptionsToUpdate;
		return this._elOptionsToUpdate = null, e;
	}, t.type = "graphic", t.defaultOption = { elements: [] }, t;
}(Jg), HR = {
	path: null,
	compoundPath: null,
	group: Wa,
	image: fu,
	text: Tu
}, UR = X(), WR = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.init = function() {
		this._elMap = K();
	}, t.prototype.render = function(e, t, n) {
		e !== this._lastGraphicModel && this._clear(), this._lastGraphicModel = e, this._updateElements(e), this._relocate(e, n);
	}, t.prototype._updateElements = function(e) {
		var t = e.useElOptionsToUpdate();
		if (t) {
			var n = this._elMap, r = this.group, i = e.get("z"), a = e.get("zlevel");
			I(t, function(t) {
				var o = xs(t.id, null), s = o == null ? null : n.get(o), c = xs(t.parentId, null), l = c == null ? r : n.get(c), u = t.type, d = t.style;
				u === "text" && d && t.hv && t.hv[1] && (d.textVerticalAlign = d.textBaseline = d.verticalAlign = d.align = null);
				var f = t.textContent, p = t.textConfig;
				if (d && aA(d, u, !!p, !!f)) {
					var m = oA(d, u, !0);
					!p && m.textConfig && (p = t.textConfig = m.textConfig), !f && m.textContent && (f = m.textContent);
				}
				var h = YR(t), g = t.$action || "merge", _ = g === "merge", v = g === "replace";
				if (_) {
					var y = !s, b = s;
					y ? b = KR(o, l, t.type, n) : (b && (UR(b).isNew = !1), LL(b)), b && (yL(b, h, e, { isInit: y }), JR(b, t, i, a));
				} else if (v) {
					qR(s, t, n, e);
					var x = KR(o, l, t.type, n);
					x && (yL(x, h, e, { isInit: !0 }), JR(x, t, i, a));
				} else g === "remove" && (bL(s, t), qR(s, t, n, e));
				var S = n.get(o);
				if (S && f) {
					if (_) {
						var C = S.getTextContent();
						C ? C.attr(f) : S.setTextContent(new Tu(f));
					} else v && S.setTextContent(new Tu(f));
				}
				if (S) {
					var w = t.clipPath;
					if (w) {
						var T = w.type, E = void 0, y = !1;
						if (_) {
							var D = S.getClipPath();
							y = !D || UR(D).type !== T, E = y ? GR(T) : D;
						} else v && (y = !0, E = GR(T));
						S.setClipPath(E), yL(E, w, e, { isInit: y }), RL(E, w.keyframeAnimation, e);
					}
					var O = UR(S);
					S.setTextConfig(p), O.option = t, XR(S, e, t), hm({
						el: S,
						componentModel: e,
						itemName: S.name,
						itemTooltipOption: t.tooltip
					}), RL(S, t.keyframeAnimation, e);
				}
			});
		}
	}, t.prototype._relocate = function(e, t) {
		for (var n = e.option.elements, r = this.group, i = this._elMap, a = t.getWidth(), o = t.getHeight(), s = ["x", "y"], c = 0; c < n.length; c++) {
			var l = n[c], u = xs(l.id, null), d = u == null ? null : i.get(u);
			if (d && d.isGroup) {
				var f = d.parent, p = f === r, m = UR(d), h = UR(f);
				m.width = So(m.option.width, p ? a : h.width) || 0, m.height = So(m.option.height, p ? o : h.height) || 0;
			}
		}
		for (var c = n.length - 1; c >= 0; c--) {
			var l = n[c], u = xs(l.id, null), d = u == null ? null : i.get(u);
			if (d) {
				var f = d.parent, h = UR(f), g = f === r ? {
					width: a,
					height: o
				} : {
					width: h.width,
					height: h.height
				}, _ = {}, v = Hg(d, l, g, null, {
					hv: l.hv,
					boundingMode: l.bounding
				}, _);
				if (!UR(d).isNew && v) {
					for (var y = l.transition, b = {}, x = 0; x < s.length; x++) {
						var S = s[x], C = _[S];
						y && (SL(y) || P(y, S) >= 0) ? b[S] = C : d[S] = C;
					}
					kp(d, b, e, 0);
				} else d.attr(_);
			}
		}
	}, t.prototype._clear = function() {
		var e = this, t = this._elMap;
		t.each(function(n) {
			qR(n, UR(n).option, t, e._lastGraphicModel);
		}), this._elMap = K();
	}, t.prototype.dispose = function() {
		this._clear();
	}, t.type = "graphic", t;
}(rb);
function GR(e) {
	var t = new (q(HR, e) ? HR[e] : Wp(e))({});
	return UR(t).type = e, t;
}
function KR(e, t, n, r) {
	var i = GR(n);
	return t.add(i), r.set(e, i), UR(i).id = e, UR(i).isNew = !0, i;
}
function qR(e, t, n, r) {
	e && e.parent && (e.type === "group" && e.traverse(function(e) {
		qR(e, t, n, r);
	}), xL(e, t, r), n.removeKey(UR(e).id));
}
function JR(e, t, n, r) {
	e.isGroup || I([
		["cursor", $c.prototype.cursor],
		["zlevel", r || 0],
		["z", n || 0],
		["z2", 0]
	], function(n) {
		var r = n[0];
		q(t, r) ? e[r] = G(t[r], n[1]) : e[r] ?? (e[r] = n[1]);
	}), I(R(t), function(n) {
		if (n.indexOf("on") === 0) {
			var r = t[n];
			e[n] = H(r) ? r : null;
		}
	}), q(t, "draggable") && (e.draggable = t.draggable), t.name != null && (e.name = t.name), t.id != null && (e.id = t.id);
}
function YR(e) {
	return e = M({}, e), I([
		"id",
		"parentId",
		"$action",
		"hv",
		"bounding",
		"textContent",
		"clipPath"
	].concat(Mg), function(t) {
		delete e[t];
	}), e;
}
function XR(e, t, n) {
	var r = Z(e).eventData;
	!e.silent && !e.ignore && !r && (r = Z(e).eventData = {
		componentType: "graphic",
		componentIndex: t.componentIndex,
		name: e.name
	}), r && (r.info = n.info);
}
//#endregion
//#region node_modules/echarts/lib/component/graphic/install.js
function ZR(e) {
	e.registerComponentModel(VR), e.registerComponentView(WR), e.registerPreprocessor(function(e) {
		var t = e.graphic;
		V(t) ? e.graphic = !t[0] || !t[0].elements ? [{ elements: t }] : [e.graphic[0]] : t && !t.elements && (e.graphic = [{ elements: [t] }]);
	});
}
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/helper.js
var QR = [
	"x",
	"y",
	"radius",
	"angle",
	"single"
], $R = X(), ez = [
	"cartesian2d",
	"polar",
	"singleAxis"
];
function tz(e) {
	return P(ez, e.get("coordinateSystem")) >= 0;
}
function nz(e) {
	return e + "Axis";
}
function rz(e, t) {
	var n = K(), r = [], i = K();
	e.eachComponent({
		mainType: "dataZoom",
		query: t
	}, function(e) {
		i.get(e.uid) || s(e);
	});
	var a;
	do
		a = !1, e.eachComponent("dataZoom", o);
	while (a);
	function o(e) {
		!i.get(e.uid) && c(e) && (s(e), a = !0);
	}
	function s(e) {
		i.set(e.uid, !0), r.push(e), l(e);
	}
	function c(e) {
		var t = !1;
		return e.eachTargetAxis(function(e, r) {
			var i = n.get(e);
			i && i[r] && (t = !0);
		}), t;
	}
	function l(e) {
		e.eachTargetAxis(function(e, t) {
			(n.get(e) || n.set(e, []))[t] = !0;
		});
	}
	return r;
}
function iz(e) {
	var t = e.ecModel, n = {
		infoList: [],
		infoMap: K()
	};
	return e.eachTargetAxis(function(e, r) {
		var i = t.getComponent(nz(e), r);
		if (i) {
			var a = i.getCoordSysModel();
			if (a) {
				var o = a.uid, s = n.infoMap.get(o);
				s || (s = {
					model: a,
					axisModels: []
				}, n.infoList.push(s), n.infoMap.set(o, s)), s.axisModels.push(i);
			}
		}
	}), n;
}
function az(e) {
	var t = $R(gx(e));
	return t.axisProxyMap ||= K();
}
function oz(e) {
	if (e) return az(e.ecModel).get(e.uid);
}
function sz(e, t) {
	az(e.ecModel).set(e.uid, t);
}
function cz(e, t) {
	var n = t.getAxisModel().axis.__alignTo;
	return n && e.getAxisProxy(n.dim, n.model.componentIndex) ? oz(n.model) : null;
}
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/DataZoomModel.js
var lz = function() {
	function e() {
		this.indexList = [], this.indexMap = [];
	}
	return e.prototype.add = function(e) {
		this.indexMap[e] || (this.indexList.push(e), this.indexMap[e] = !0);
	}, e;
}(), uz = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n._autoThrottle = !0, n._noTarget = !0, n._rangePropMode = ["percent", "percent"], n;
	}
	return t.prototype.init = function(e, t, n) {
		var r = dz(e);
		this.settledOption = r, this.mergeDefaultAndTheme(e, n), this._doInit(r);
	}, t.prototype.mergeOption = function(e) {
		var t = dz(e);
		j(this.option, e, !0), j(this.settledOption, t, !0), this._doInit(t);
	}, t.prototype._doInit = function(e) {
		var t = this.option;
		this._setDefaultThrottle(e), this._updateRangeUse(e);
		var n = this.settledOption;
		I([["start", "startValue"], ["end", "endValue"]], function(e, r) {
			this._rangePropMode[r] === "value" && (t[e[0]] = n[e[0]] = null);
		}, this), this._resetTarget();
	}, t.prototype._resetTarget = function() {
		var e = this.get("orient", !0), t = this._targetAxisInfoMap = K();
		this._fillSpecifiedTargetAxis(t) ? this._orient = e || this._makeAutoOrientByTargetAxis() : (this._orient = e || "horizontal", this._fillAutoTargetAxisByOrient(t, this._orient)), this._noTarget = !0, t.each(function(e) {
			e.indexList.length && (this._noTarget = !1);
		}, this);
	}, t.prototype._fillSpecifiedTargetAxis = function(e) {
		var t = !1;
		return I(QR, function(n) {
			var r = this.getReferringComponents(nz(n), Ms);
			if (r.specified) {
				t = !0;
				var i = new lz();
				I(r.models, function(e) {
					i.add(e.componentIndex);
				}), e.set(n, i);
			}
		}, this), t;
	}, t.prototype._fillAutoTargetAxisByOrient = function(e, t) {
		var n = this.ecModel, r = !0;
		if (r) {
			var i = t === "vertical" ? "y" : "x", a = n.findComponents({ mainType: i + "Axis" });
			o(a, i);
		}
		if (r) {
			var a = n.findComponents({
				mainType: "singleAxis",
				filter: function(e) {
					return e.get("orient", !0) === t;
				}
			});
			o(a, "single");
		}
		function o(t, n) {
			var i = t[0];
			if (i) {
				var a = new lz();
				if (a.add(i.componentIndex), e.set(n, a), r = !1, n === "x" || n === "y") {
					var o = i.getReferringComponents("grid", js).models[0];
					o && I(t, function(e) {
						i.componentIndex !== e.componentIndex && o === e.getReferringComponents("grid", js).models[0] && a.add(e.componentIndex);
					});
				}
			}
		}
		r && I(QR, function(t) {
			if (r) {
				var i = n.findComponents({
					mainType: nz(t),
					filter: function(e) {
						return e.get("type", !0) === "category";
					}
				});
				if (i[0]) {
					var a = new lz();
					a.add(i[0].componentIndex), e.set(t, a), r = !1;
				}
			}
		}, this);
	}, t.prototype._makeAutoOrientByTargetAxis = function() {
		var e;
		return this.eachTargetAxis(function(t) {
			!e && (e = t);
		}, this), e === "y" ? "vertical" : "horizontal";
	}, t.prototype._setDefaultThrottle = function(e) {
		if (e.hasOwnProperty("throttle") && (this._autoThrottle = !1), this._autoThrottle) {
			var t = this.ecModel.option;
			this.option.throttle = t.animation && t.animationDurationUpdate > 0 ? 100 : 20;
		}
	}, t.prototype._updateRangeUse = function(e) {
		var t = this._rangePropMode, n = this.get("rangeMode");
		I([["start", "startValue"], ["end", "endValue"]], function(r, i) {
			var a = e[r[0]] != null, o = e[r[1]] != null;
			a && !o ? t[i] = "percent" : !a && o ? t[i] = "value" : n ? t[i] = n[i] : a && (t[i] = "percent");
		});
	}, t.prototype.noTarget = function() {
		return this._noTarget;
	}, t.prototype.getFirstTargetAxisModel = function() {
		var e;
		return this.eachTargetAxis(function(t, n) {
			e ??= this.ecModel.getComponent(nz(t), n);
		}, this), e;
	}, t.prototype.eachTargetAxis = function(e, t) {
		this._targetAxisInfoMap.each(function(n, r) {
			I(n.indexList, function(n) {
				e.call(t, r, n);
			});
		});
	}, t.prototype.getAxisProxy = function(e, t) {
		return oz(this.getAxisModel(e, t));
	}, t.prototype.getAxisModel = function(e, t) {
		var n = this._targetAxisInfoMap.get(e);
		if (n && n.indexMap[t]) return this.ecModel.getComponent(nz(e), t);
	}, t.prototype.setRawRange = function(e) {
		var t = this.option, n = this.settledOption;
		I([["start", "startValue"], ["end", "endValue"]], function(r) {
			(e[r[0]] != null || e[r[1]] != null) && (t[r[0]] = n[r[0]] = e[r[0]], t[r[1]] = n[r[1]] = e[r[1]]);
		}, this), this._updateRangeUse(e);
	}, t.prototype.setCalculatedRange = function(e) {
		var t = this.option;
		I([
			"start",
			"startValue",
			"end",
			"endValue"
		], function(n) {
			t[n] = e[n];
		});
	}, t.prototype.getPercentRange = function() {
		var e = this.findRepresentativeAxisProxy();
		if (e) return e.getWindow().percent;
	}, t.prototype.getValueRange = function(e, t) {
		if (e == null && t == null) {
			var n = this.findRepresentativeAxisProxy();
			if (n) return n.getWindow().value;
		} else return this.getAxisProxy(e, t).getWindow().value;
	}, t.prototype.findRepresentativeAxisProxy = function(e) {
		if (e) return oz(e);
		for (var t, n = this._targetAxisInfoMap.keys(), r = 0; r < n.length; r++) for (var i = n[r], a = this._targetAxisInfoMap.get(i), o = 0; o < a.indexList.length; o++) {
			var s = this.getAxisProxy(i, a.indexList[o]);
			if (s.hostedBy(this)) return s;
			t ||= s;
		}
		return t;
	}, t.prototype.getRangePropMode = function() {
		return this._rangePropMode.slice();
	}, t.prototype.getOrient = function() {
		return this._orient;
	}, t.type = "dataZoom", t.dependencies = [
		"xAxis",
		"yAxis",
		"radiusAxis",
		"angleAxis",
		"singleAxis",
		"series",
		"toolbox"
	], t.defaultOption = {
		z: 4,
		filterMode: "filter",
		start: 0,
		end: 100
	}, t;
}(Jg);
function dz(e) {
	var t = {};
	return I([
		"start",
		"end",
		"startValue",
		"endValue",
		"throttle"
	], function(n) {
		e.hasOwnProperty(n) && (t[n] = e[n]);
	}), t;
}
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/DataZoomView.js
var fz = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.render = function(e, t, n, r) {
		this.dataZoomModel = e, this.ecModel = t, this.api = n;
	}, t.type = "dataZoom", t;
}(rb), pz = function() {
	function e(e, t, n, r) {
		this._dimName = e, this._axisIndex = t, this.ecModel = r, this._dataZoomModel = n;
	}
	return e.prototype.hostedBy = function(e) {
		return this._dataZoomModel === e;
	}, e.prototype.getWindow = function() {
		return A(this._window);
	}, e.prototype.getTargetSeriesModels = function() {
		var e = [];
		return this.ecModel.eachSeries(function(t) {
			if (tz(t)) {
				var n = nz(this._dimName), r = t.getReferringComponents(n, js).models[0];
				r && this._axisIndex === r.componentIndex && e.push(t);
			}
		}, this), e;
	}, e.prototype.getAxisModel = function() {
		return this.ecModel.getComponent(this._dimName + "Axis", this._axisIndex);
	}, e.prototype.getMinMaxSpan = function() {
		return A(this._minMaxSpan);
	}, e.prototype.calculateDataWindow = function(e) {
		var t = this._extent, n = this.getAxisModel().axis, r = n.scale, i = this._dataZoomModel.getRangePropMode(), a = [0, 100], o = [], s = [], c, l = [!1, !1];
		I(["start", "end"], function(n, u) {
			var d = e[n], f = e[n + "Value"];
			i[u] === "percent" ? (d ??= a[u], f = xo(d, a, t), l[u] = !0) : (c = !0, f == null ? f = t[u] : (f = r.parse(f), r.sanitize && (f = r.sanitize(f, t))), d = xo(f, t, a)), s[u] = f == null || isNaN(f) ? t[u] : f, o[u] = d == null || isNaN(d) ? a[u] : d;
		}), Oo(s), Oo(o);
		var u = this._minMaxSpan;
		c ? d(s, o, t, a, !1) : d(o, s, a, t, !0);
		function d(e, t, n, r, i) {
			var a = i ? "Span" : "ValueSpan";
			wI(0, e, n, "all", u["min" + a], u["max" + a]);
			for (var o = 0; o < 2; o++) t[o] = xo(e[o], n, r, !0), i && (t[o] = t[o], l[o] = !0);
			qs(t);
		}
		var f = DT(r) || TT(r), p = n.getExtent(), m = fo(p[1] - p[0]), h = f ? 0 : Mo(s, m, .5);
		I([[0, ho], [1, mo]], function(e) {
			var n = e[0], r = e[1];
			l[n] && isFinite(h) && (s[n] = Eo(s[n], h), s[n] = lo(t[1], uo(t[0], s[n])), o[n] === a[n] && (s[n] = t[n], f && (s[n] = r(s[n]))));
		}), qs(s);
		var g = [xo(s[0], t, a, !0), xo(s[1], t, a, !0)];
		return qs(g), {
			value: s,
			percent: o,
			percentInverted: g,
			valuePrecision: h
		};
	}, e.prototype.reset = function(e, t) {
		if (this.hostedBy(e)) {
			var n = this.getAxisModel().axis;
			tD(n, 2);
			var r = n.scale.rawExtentInfo;
			this._extent = r.makeNoZoom(), this._updateMinMaxSpan();
			var i = e.settledOption;
			t && (i = N({
				start: t[0],
				end: t[1]
			}, i));
			var a = this._window = this.calculateDataWindow(i), o = a.percent, s = a.value;
			o[0] !== 0 && r.setZoomMM(0, s[0]), o[1] !== 100 && r.setZoomMM(1, s[1]);
		}
	}, e.prototype.filterData = function(e, t) {
		if (!this.hostedBy(e)) return;
		var n = this._dimName, r = this.getTargetSeriesModels(), i = e.get("filterMode"), a = this._window.value;
		if (i === "none") return;
		I(r, function(e) {
			var t = e.getData(), r = t.mapDimensionsAll(n);
			if (r.length) {
				if (i === "weakFilter") {
					var s = t.getStore(), c = L(r, function(e) {
						return t.getDimensionIndex(e);
					}, t);
					t.filterSelf(function(e) {
						for (var t, n, i, o = 0; o < r.length; o++) {
							var l = s.get(c[o], e), u = !isNaN(l), d = l < a[0], f = l > a[1];
							if (u && !d && !f) return !0;
							u && (i = !0), d && (t = !0), f && (n = !0);
						}
						return i && t && n;
					});
				} else I(r, function(n) {
					if (i === "empty") e.setData(t = t.map(n, function(e) {
						return o(e) ? e : NaN;
					}));
					else {
						var r = {};
						r[n] = a, t.selectRange(r);
					}
				});
				I(r, function(e) {
					t.setApproximateExtent(a, e);
				});
			}
		});
		function o(e) {
			return e >= a[0] && e <= a[1];
		}
	}, e.prototype._updateMinMaxSpan = function() {
		var e = this._minMaxSpan = {}, t = this._dataZoomModel, n = this._extent;
		I(["min", "max"], function(r) {
			var i = t.get(r + "Span"), a = t.get(r + "ValueSpan");
			a != null && (a = this.getAxisModel().axis.scale.parse(a)), a == null ? i != null && (a = xo(i, [0, 100], n, !0) - n[0]) : i = xo(n[0] + a, n, [0, 100], !0), e[r + "Span"] = i, e[r + "ValueSpan"] = a;
		}, this);
	}, e;
}(), mz = {
	dirtyOnOverallProgress: !0,
	getTargetSeries: function(e) {
		function t(t) {
			e.eachComponent("dataZoom", function(n) {
				n.eachTargetAxis(function(r, i) {
					t(r, i, e.getComponent(nz(r), i), n);
				});
			});
		}
		var n = [];
		t(function(t, r, i, a) {
			if (!oz(i)) {
				var o = new pz(t, r, a, e);
				n.push(o), sz(i, o);
			}
		});
		var r = K();
		return I(n, function(e) {
			I(e.getTargetSeriesModels(), function(e) {
				r.set(e.uid, e);
			});
		}), r;
	},
	overallReset: function(e, t) {
		e.eachComponent("dataZoom", function(e) {
			var n = [];
			e.eachTargetAxis(function(t, r) {
				var i = e.getAxisProxy(t, r), a = cz(e, i);
				a ? n.push([i, a]) : i.reset(e, null);
			}), I(n, function(t) {
				t[0].reset(e, t[1].getWindow().percentInverted);
			}), e.eachTargetAxis(function(n, r) {
				e.getAxisProxy(n, r).filterData(e, t);
			});
		}), e.eachComponent("dataZoom", function(e) {
			var t = e.findRepresentativeAxisProxy();
			if (t) {
				var n = t.getWindow(), r = n.percent, i = n.value;
				e.setCalculatedRange({
					start: r[0],
					end: r[1],
					startValue: i[0],
					endValue: i[1]
				});
			}
		});
	}
};
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/dataZoomAction.js
function hz(e) {
	e.registerAction("dataZoom", function(e, t) {
		I(rz(t, e), function(t) {
			t.setRawRange({
				start: e.start,
				end: e.end,
				startValue: e.startValue,
				endValue: e.endValue
			});
		});
	});
}
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/installCommon.js
var gz = Js();
function _z(e) {
	gz(e, function() {
		e.registerProcessor(e.PRIORITY.PROCESSOR.FILTER, mz), hz(e), e.registerSubTypeDefaulter("dataZoom", function() {
			return "slider";
		});
	});
}
//#endregion
//#region node_modules/echarts/lib/component/helper/listComponent.js
function vz(e, t) {
	var n = fg(t.get("padding")), r = t.getItemStyle(["color", "opacity"]);
	return r.fill = t.get("backgroundColor"), new bu({
		shape: {
			x: e.x - n[3],
			y: e.y - n[0],
			width: e.width + n[1] + n[3],
			height: e.height + n[0] + n[2],
			r: t.get("borderRadius")
		},
		style: r,
		silent: !0,
		z2: -1
	});
}
//#endregion
//#region node_modules/echarts/lib/component/tooltip/TooltipModel.js
var yz = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.type = "tooltip", t.dependencies = ["axisPointer"], t.defaultOption = {
		z: 60,
		show: !0,
		showContent: !0,
		trigger: "item",
		triggerOn: "mousemove|click|mousewheel",
		alwaysShowContent: !1,
		renderMode: "auto",
		confine: null,
		showDelay: 0,
		hideDelay: 100,
		transitionDuration: .4,
		displayTransition: !0,
		enterable: !1,
		backgroundColor: Q.color.neutral00,
		shadowBlur: 10,
		shadowColor: "rgba(0, 0, 0, .2)",
		shadowOffsetX: 1,
		shadowOffsetY: 2,
		borderRadius: 4,
		borderWidth: 1,
		defaultBorderColor: Q.color.border,
		padding: null,
		extraCssText: "",
		axisPointer: {
			type: "line",
			axis: "auto",
			animation: "auto",
			animationDurationUpdate: 200,
			animationEasingUpdate: "exponentialOut",
			crossStyle: {
				color: Q.color.borderShade,
				width: 1,
				type: "dashed",
				textStyle: {}
			}
		},
		textStyle: {
			color: Q.color.tertiary,
			fontSize: 14
		}
	}, t;
}(Jg);
//#endregion
//#region node_modules/echarts/lib/component/tooltip/helper.js
function bz(e) {
	var t = e.get("confine");
	return t == null ? e.get("renderMode") === "richText" : !!t;
}
function xz(e) {
	if (i.domSupported) {
		for (var t = document.documentElement.style, n = 0, r = e.length; n < r; n++) if (e[n] in t) return e[n];
	}
}
var Sz = xz([
	"transform",
	"webkitTransform",
	"OTransform",
	"MozTransform",
	"msTransform"
]), Cz = xz([
	"webkitTransition",
	"transition",
	"OTransition",
	"MozTransition",
	"msTransition"
]);
function wz(e, t) {
	if (!e) return t;
	t = dg(t, !0);
	var n = e.indexOf(t);
	return e = n === -1 ? t : "-" + e.slice(0, n) + "-" + t, e.toLowerCase();
}
function Tz(e, t) {
	var n = e.currentStyle || document.defaultView && document.defaultView.getComputedStyle(e);
	return n ? t ? n[t] : n : null;
}
//#endregion
//#region node_modules/echarts/lib/component/tooltip/TooltipHTMLContent.js
var Ez = wz(Cz, "transition"), Dz = wz(Sz, "transform"), Oz = "position:absolute;display:block;border-style:solid;white-space:nowrap;z-index:9999999;" + (i.transform3dSupported ? "will-change:transform;" : "");
function kz(e) {
	return e = e === "left" ? "right" : e === "right" ? "left" : e === "top" ? "bottom" : "top", e;
}
function Az(e, t, n) {
	if (!U(n) || n === "inside") return "";
	var r = e.get("backgroundColor"), i = e.get("borderWidth");
	t = bg(t);
	var a = kz(n), o = Math.max(Math.round(i) * 1.5, 6), s = "", c = Dz + ":", l;
	P(["left", "right"], a) > -1 ? (s += "top:50%", c += "translateY(-50%) rotate(" + (l = a === "left" ? -225 : -45) + "deg)") : (s += "left:50%", c += "translateX(-50%) rotate(" + (l = a === "top" ? 225 : 45) + "deg)");
	var u = l * Math.PI / 180, d = o + i, f = d * Math.abs(Math.cos(u)) + d * Math.abs(Math.sin(u)), p = Math.round(((f - Math.SQRT2 * i) / 2 + Math.SQRT2 * i - (f - d) / 2) * 100) / 100;
	s += ";" + a + ":-" + p + "px";
	var m = t + " solid " + i + "px;";
	return "<div style=\"" + [
		"position:absolute;width:" + o + "px;height:" + o + "px;z-index:-1;",
		s + ";" + c + ";",
		"border-bottom:" + m,
		"border-right:" + m,
		"background-color:" + r + ";"
	].join("") + "\"></div>";
}
function jz(e, t, n) {
	var r = "cubic-bezier(0.23,1,0.32,1)", a = "", o = "";
	return n && (a = " " + e / 2 + "s " + r, o = "opacity" + a + ",visibility" + a), t || (a = " " + e + "s " + r, o += (o.length ? "," : "") + (i.transformSupported ? "" + Dz + a : ",left" + a + ",top" + a)), Ez + ":" + o;
}
function Mz(e, t, n) {
	var r = e.toFixed(0) + "px", a = t.toFixed(0) + "px";
	if (!i.transformSupported) return n ? "top:" + a + ";left:" + r + ";" : [["top", a], ["left", r]];
	var o = i.transform3dSupported, s = "translate" + (o ? "3d" : "") + "(" + r + "," + a + (o ? ",0" : "") + ")";
	return n ? "top:0;left:0;" + Dz + ":" + s + ";" : [
		["top", 0],
		["left", 0],
		[Sz, s]
	];
}
function Nz(e) {
	var t = [], n = e.get("fontSize"), r = e.getTextColor();
	r && t.push("color:" + r), t.push("font:" + e.getFont());
	var i = G(e.get("lineHeight"), Math.round(n * 3 / 2));
	n && t.push("line-height:" + i + "px");
	var a = e.get("textShadowColor"), o = e.get("textShadowBlur") || 0, s = e.get("textShadowOffsetX") || 0, c = e.get("textShadowOffsetY") || 0;
	return a && o && t.push("text-shadow:" + s + "px " + c + "px " + o + "px " + a), I(["decoration", "align"], function(n) {
		var r = e.get(n);
		r && t.push("text-" + n + ":" + r);
	}), t.join(";");
}
function Pz(e, t, n, r) {
	var i = [], a = e.get("transitionDuration"), o = e.get("backgroundColor"), s = e.get("shadowBlur"), c = e.get("shadowColor"), l = e.get("shadowOffsetX"), u = e.get("shadowOffsetY"), d = e.getModel("textStyle"), f = Hy(e, "html"), p = l + "px " + u + "px " + s + "px " + c;
	return i.push("box-shadow:" + p), t && a > 0 && i.push(jz(a, n, r)), o && i.push("background-color:" + o), I([
		"width",
		"color",
		"radius"
	], function(t) {
		var n = "border-" + t, r = dg(n), a = e.get(r);
		a != null && i.push(n + ":" + a + (t === "color" ? "" : "px"));
	}), i.push(Nz(d)), f != null && i.push("padding:" + fg(f).join("px ") + "px"), i.join(";") + ";";
}
function Fz(e, t, n, r, i) {
	var a = t && t.painter;
	if (n) {
		var o = a && a.getViewportRoot();
		o && _t(e, o, n, r, i);
	} else {
		e[0] = r, e[1] = i;
		var s = a && a.getViewportRootOffset();
		s && (e[0] += s.offsetLeft, e[1] += s.offsetTop);
	}
	e[2] = e[0] / t.getWidth(), e[3] = e[1] / t.getHeight();
}
var Iz = function() {
	function e(e, t) {
		if (this._show = !1, this._styleCoord = [
			0,
			0,
			0,
			0
		], this._enterable = !0, this._alwaysShowContent = !1, this._firstShow = !0, this._longHide = !0, i.wxa) return null;
		var n = document.createElement("div");
		n.domBelongToZr = !0, this.el = n;
		var r = this._zr = e.getZr(), a = t.appendTo, o = a && (U(a) ? document.querySelector(a) : pe(a) ? a : H(a) && a(e.getDom()));
		Fz(this._styleCoord, r, o, e.getWidth() / 2, e.getHeight() / 2), (o || e.getDom()).appendChild(n), this._api = e, this._container = o;
		var s = this;
		n.onmouseenter = function() {
			s._enterable && (clearTimeout(s._hideTimeout), s._show = !0), s._inContent = !0;
		}, n.onmousemove = function(e) {
			if (e ||= window.event, !s._enterable) {
				var t = r.handler;
				Mt(r.painter.getViewportRoot(), e, !0), t.dispatch("mousemove", e);
			}
		}, n.onmouseleave = function() {
			s._inContent = !1, s._enterable && s._show && s.hideLater(s._hideDelay);
		};
	}
	return e.prototype.update = function(e) {
		if (!this._container) {
			var t = this._api.getDom(), n = Tz(t, "position"), r = t.style;
			r.position !== "absolute" && n !== "absolute" && (r.position = "relative");
		}
		var i = e.get("alwaysShowContent");
		i && this._moveIfResized(), this._alwaysShowContent = i, this._enableDisplayTransition = e.get("displayTransition") && e.get("transitionDuration") > 0, this.el.className = e.get("className") || "";
	}, e.prototype.show = function(e, t) {
		clearTimeout(this._hideTimeout), clearTimeout(this._longHideTimeout);
		var n = this.el, r = n.style, i = this._styleCoord;
		n.innerHTML ? r.cssText = Oz + Pz(e, !this._firstShow, this._longHide, this._enableDisplayTransition) + Mz(i[0], i[1], !0) + ("border-color:" + bg(t) + ";") + (e.get("extraCssText") || "") + (";pointer-events:" + (this._enterable ? "auto" : "none")) : r.display = "none", this._show = !0, this._firstShow = !1, this._longHide = !1;
	}, e.prototype.setContent = function(e, t, n, r, i) {
		var a = this.el;
		if (e == null) a.innerHTML = "";
		else {
			var o = "";
			if (U(i) && n.get("trigger") === "item" && !bz(n) && (o = Az(n, r, i)), U(e)) a.innerHTML = e + o;
			else if (e) {
				a.innerHTML = "", V(e) || (e = [e]);
				for (var s = 0; s < e.length; s++) pe(e[s]) && e[s].parentNode !== a && a.appendChild(e[s]);
				if (o && a.childNodes.length) {
					var c = document.createElement("div");
					c.innerHTML = o, a.appendChild(c);
				}
			}
		}
	}, e.prototype.setEnterable = function(e) {
		this._enterable = e;
	}, e.prototype.getSize = function() {
		var e = this.el;
		return e ? [e.offsetWidth, e.offsetHeight] : [0, 0];
	}, e.prototype.moveTo = function(e, t) {
		if (this.el) {
			var n = this._styleCoord;
			if (Fz(n, this._zr, this._container, e, t), n[0] != null && n[1] != null) {
				var r = this.el.style;
				I(Mz(n[0], n[1]), function(e) {
					r[e[0]] = e[1];
				});
			}
		}
	}, e.prototype._moveIfResized = function() {
		var e = this._styleCoord[2], t = this._styleCoord[3];
		this.moveTo(e * this._zr.getWidth(), t * this._zr.getHeight());
	}, e.prototype.hide = function() {
		var e = this, t = this.el.style;
		this._enableDisplayTransition ? (t.visibility = "hidden", t.opacity = "0") : t.display = "none", i.transform3dSupported && (t.willChange = ""), this._show = !1, this._longHideTimeout = setTimeout(function() {
			return e._longHide = !0;
		}, 500);
	}, e.prototype.hideLater = function(e) {
		this._show && !(this._inContent && this._enterable) && !this._alwaysShowContent && (e ? (this._hideDelay = e, this._show = !1, this._hideTimeout = setTimeout(z(this.hide, this), e)) : this.hide());
	}, e.prototype.isShow = function() {
		return this._show;
	}, e.prototype.dispose = function() {
		clearTimeout(this._hideTimeout), clearTimeout(this._longHideTimeout);
		var e = this._zr;
		vt(e && e.painter && e.painter.getViewportRoot(), this._container);
		var t = this.el;
		if (t) {
			t.onmouseenter = t.onmousemove = t.onmouseleave = null;
			var n = t.parentNode;
			n && n.removeChild(t);
		}
		this.el = this._container = null;
	}, e;
}(), Lz = function() {
	function e(e) {
		this._show = !1, this._styleCoord = [
			0,
			0,
			0,
			0
		], this._alwaysShowContent = !1, this._enterable = !0, this._zr = e.getZr(), Bz(this._styleCoord, this._zr, e.getWidth() / 2, e.getHeight() / 2);
	}
	return e.prototype.update = function(e) {
		var t = e.get("alwaysShowContent");
		t && this._moveIfResized(), this._alwaysShowContent = t;
	}, e.prototype.show = function() {
		this._hideTimeout && clearTimeout(this._hideTimeout), this.el.show(), this._show = !0;
	}, e.prototype.setContent = function(e, t, n, r, i) {
		var a = this;
		W(e) && rs(""), this.el && this._zr.remove(this.el);
		var o = n.getModel("textStyle");
		this.el = new Tu({
			style: {
				rich: t.richTextStyles,
				text: e,
				lineHeight: 22,
				borderWidth: 1,
				borderColor: r,
				textShadowColor: o.get("textShadowColor"),
				fill: n.get(["textStyle", "color"]),
				padding: Hy(n, "richText"),
				verticalAlign: "top",
				align: "left"
			},
			z: n.get("z")
		}), I([
			"backgroundColor",
			"borderRadius",
			"shadowColor",
			"shadowBlur",
			"shadowOffsetX",
			"shadowOffsetY"
		], function(e) {
			a.el.style[e] = n.get(e);
		}), I([
			"textShadowBlur",
			"textShadowOffsetX",
			"textShadowOffsetY"
		], function(e) {
			a.el.style[e] = o.get(e) || 0;
		}), this._zr.add(this.el);
		var s = this;
		this.el.on("mouseover", function() {
			s._enterable && (clearTimeout(s._hideTimeout), s._show = !0), s._inContent = !0;
		}), this.el.on("mouseout", function() {
			s._enterable && s._show && s.hideLater(s._hideDelay), s._inContent = !1;
		});
	}, e.prototype.setEnterable = function(e) {
		this._enterable = e;
	}, e.prototype.getSize = function() {
		var e = this.el, t = this.el.getBoundingRect(), n = zz(e.style);
		return [t.width + n.left + n.right, t.height + n.top + n.bottom];
	}, e.prototype.moveTo = function(e, t) {
		var n = this.el;
		if (n) {
			var r = this._styleCoord;
			Bz(r, this._zr, e, t), e = r[0], t = r[1];
			var i = n.style, a = Rz(i.borderWidth || 0), o = zz(i);
			n.x = e + a + o.left, n.y = t + a + o.top, n.markRedraw();
		}
	}, e.prototype._moveIfResized = function() {
		var e = this._styleCoord[2], t = this._styleCoord[3];
		this.moveTo(e * this._zr.getWidth(), t * this._zr.getHeight());
	}, e.prototype.hide = function() {
		this.el && this.el.hide(), this._show = !1;
	}, e.prototype.hideLater = function(e) {
		this._show && !(this._inContent && this._enterable) && !this._alwaysShowContent && (e ? (this._hideDelay = e, this._show = !1, this._hideTimeout = setTimeout(z(this.hide, this), e)) : this.hide());
	}, e.prototype.isShow = function() {
		return this._show;
	}, e.prototype.dispose = function() {
		this._zr.remove(this.el);
	}, e;
}();
function Rz(e) {
	return Math.max(0, e);
}
function zz(e) {
	var t = Rz(e.shadowBlur || 0), n = Rz(e.shadowOffsetX || 0), r = Rz(e.shadowOffsetY || 0);
	return {
		left: Rz(t - n),
		right: Rz(t + n),
		top: Rz(t - r),
		bottom: Rz(t + r)
	};
}
function Bz(e, t, n, r) {
	e[0] = n, e[1] = r, e[2] = e[0] / t.getWidth(), e[3] = e[1] / t.getHeight();
}
//#endregion
//#region node_modules/echarts/lib/component/tooltip/TooltipView.js
var Vz = new bu({ shape: {
	x: -1,
	y: -1,
	width: 2,
	height: 2
} }), Hz = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.init = function(e, t) {
		if (!i.node && t.getDom()) {
			var n = e.getComponent("tooltip"), r = this._renderMode = Ls(n.get("renderMode"));
			this._tooltipContent = r === "richText" ? new Lz(t) : new Iz(t, { appendTo: n.get("appendToBody", !0) ? "body" : n.get("appendTo", !0) });
		}
	}, t.prototype.render = function(e, t, n) {
		if (!i.node && n.getDom()) {
			this.group.removeAll(), this._tooltipModel = e, this._ecModel = t, this._api = n;
			var r = this._tooltipContent;
			r.update(e), r.setEnterable(e.get("enterable")), this._initGlobalListener(), this._keepShow(), this._renderMode !== "richText" && e.get("transitionDuration") ? _b(this, "_updatePosition", 50, "fixRate") : vb(this, "_updatePosition");
		}
	}, t.prototype._initGlobalListener = function() {
		var e = this._tooltipModel.get("triggerOn");
		dR("itemTooltip", this._api, z(function(t, n, r) {
			e !== "none" && (e.indexOf(t) >= 0 ? this._tryShow(n, r) : t === "leave" && this._hide(r));
		}, this));
	}, t.prototype._keepShow = function() {
		var e = this._tooltipModel, t = this._ecModel, n = this._api, r = e.get("triggerOn");
		if (e.get("trigger") !== "axis" && (this._lastDataByCoordSys = null, this._cbParamsList = null), this._lastX != null && this._lastY != null && r !== "none" && r !== "click") {
			var i = this;
			clearTimeout(this._refreshUpdateTimeout), this._refreshUpdateTimeout = setTimeout(function() {
				!n.isDisposed() && i.manuallyShowTip(e, t, n, {
					x: i._lastX,
					y: i._lastY,
					dataByCoordSys: i._lastDataByCoordSys
				});
			});
		}
	}, t.prototype.manuallyShowTip = function(e, t, n, r) {
		if (r.from !== this.uid && !i.node && n.getDom()) {
			var a = Wz(r, n);
			this._ticket = "";
			var o = r.dataByCoordSys, s = Yz(r, t, n);
			if (s) {
				var c = s.el.getBoundingRect().clone();
				c.applyTransform(s.el.transform), this._tryShow({
					offsetX: c.x + c.width / 2,
					offsetY: c.y + c.height / 2,
					target: s.el,
					position: r.position,
					positionDefault: "bottom"
				}, a);
			} else if (r.tooltip && r.x != null && r.y != null) {
				var l = Vz;
				l.x = r.x, l.y = r.y, l.update(), Z(l).tooltipConfig = {
					name: null,
					option: r.tooltip
				}, this._tryShow({
					offsetX: r.x,
					offsetY: r.y,
					target: l
				}, a);
			} else if (o) this._tryShow({
				offsetX: r.x,
				offsetY: r.y,
				position: r.position,
				dataByCoordSys: o,
				tooltipOption: r.tooltipOption
			}, a);
			else if (r.seriesIndex != null) {
				if (this._manuallyAxisShowTip(e, t, n, r)) return;
				var u = yR(r, t), d = u.point[0], f = u.point[1];
				d != null && f != null && this._tryShow({
					offsetX: d,
					offsetY: f,
					target: u.el,
					position: r.position,
					positionDefault: "bottom"
				}, a);
			} else r.x != null && r.y != null && (n.dispatchAction({
				type: "updateAxisPointer",
				x: r.x,
				y: r.y
			}), this._tryShow({
				offsetX: r.x,
				offsetY: r.y,
				position: r.position,
				target: n.getZr().findHover(r.x, r.y).target
			}, a));
		}
	}, t.prototype.manuallyHideTip = function(e, t, n, r) {
		var i = this._tooltipContent;
		this._tooltipModel && i.hideLater(this._tooltipModel.get("hideDelay")), this._lastX = this._lastY = this._lastDataByCoordSys = null, this._cbParamsList = null, r.from !== this.uid && this._hide(Wz(r, n));
	}, t.prototype._manuallyAxisShowTip = function(e, t, n, r) {
		var i = r.seriesIndex, a = r.dataIndex, o = t.getComponent("axisPointer").coordSysAxesInfo;
		if (i != null && a != null && o != null) {
			var s = t.getSeriesByIndex(i);
			if (s && Uz([
				s.getData().getItemModel(a),
				s,
				(s.coordinateSystem || {}).model
			], this._tooltipModel).get("trigger") === "axis") return n.dispatchAction({
				type: "updateAxisPointer",
				seriesIndex: i,
				dataIndex: a,
				position: r.position
			}), !0;
		}
	}, t.prototype._tryShow = function(e, t) {
		var n = e.target;
		if (this._tooltipModel) {
			this._lastX = e.offsetX, this._lastY = e.offsetY;
			var r = e.dataByCoordSys;
			if (r && r.length) this._showAxisTooltip(r, e);
			else if (n) {
				if (Z(n).ssrType === "legend") return;
				this._lastDataByCoordSys = null, this._cbParamsList = null;
				var i, a;
				ox(n, function(e) {
					if (e.tooltipDisabled) return i = a = null, !0;
					i || a || (Z(e).dataIndex == null ? Z(e).tooltipConfig != null && (a = e) : i = e);
				}, !0), i ? this._showSeriesItemTooltip(e, i, t) : a ? this._showComponentItemTooltip(e, a, t) : this._hide(t);
			} else this._lastDataByCoordSys = null, this._cbParamsList = null, this._hide(t);
		}
	}, t.prototype._showOrMove = function(e, t) {
		var n = e.get("showDelay");
		t = z(t, this), clearTimeout(this._showTimout), n > 0 ? this._showTimout = setTimeout(t, n) : t();
	}, t.prototype._showAxisTooltip = function(e, t) {
		var n = this._ecModel, r = this._tooltipModel, i = [t.offsetX, t.offsetY], a = Uz([t.tooltipOption], r), o = this._renderMode, s = [], c = Oy("section", {
			blocks: [],
			noHeader: !0
		}), l = [], u = new Uy();
		I(e, function(e) {
			I(e.dataByAxis, function(e) {
				var t = n.getComponent(e.axisDim + "Axis", e.axisIndex), i = e.value, a = t.axis, d = a.scale.parse(i);
				if (t && i != null) {
					var f = ZL(i, a, n, e.seriesDataIndices, e.valueLabelOpt), p = Oy("section", {
						header: f,
						noHeader: !Ce(f),
						sortBlocks: !0,
						blocks: []
					});
					c.blocks.push(p), I(e.seriesDataIndices, function(i) {
						var a = n.getSeriesByIndex(i.seriesIndex), c = i.dataIndexInside, m = a.getDataParams(c);
						if (!(m.dataIndex < 0)) {
							m.axisDim = e.axisDim, m.axisIndex = e.axisIndex, m.axisType = e.axisType, m.axisId = e.axisId, m.axisValue = pE(t.axis, { value: d }), m.axisValueLabel = f, m.marker = u.makeTooltipMarker("item", bg(m.color), o);
							var h = Wv(a.formatTooltip(c, !0, null)), g = h.frag;
							if (g) {
								var _ = Uz([a], r).get("valueFormatter");
								p.blocks.push(_ ? M({ valueFormatter: _ }, g) : g);
							}
							h.text && l.push(h.text), s.push(m);
						}
					});
				}
			});
		}), c.blocks.reverse(), l.reverse();
		var d = t.position, f = Py(c, u, o, a.get("order"), n.get("useUTC"), a.get("textStyle"));
		f && l.unshift(f);
		var p = o === "richText" ? "\n\n" : "<br/>", m = l.join(p);
		this._showOrMove(a, function() {
			this._updateContentNotChangedOnAxis(e, s) ? this._updatePosition(a, d, i[0], i[1], this._tooltipContent, s) : this._showTooltipContent(a, m, s, Math.random() + "", i[0], i[1], d, null, u);
		});
	}, t.prototype._showSeriesItemTooltip = function(e, t, n) {
		var r = this._ecModel, i = Z(t), a = i.seriesIndex, o = r.getSeriesByIndex(a), s = i.dataModel || o, c = i.dataIndex, l = i.dataType, u = s.getData(l), d = this._renderMode, f = e.positionDefault, p = Uz([
			u.getItemModel(c),
			s,
			o && (o.coordinateSystem || {}).model
		], this._tooltipModel, f ? { position: f } : null), m = p.get("trigger");
		if (m == null || m === "item") {
			var h = s.getDataParams(c, l), g = new Uy();
			h.marker = g.makeTooltipMarker("item", bg(h.color), d);
			var _ = Wv(s.formatTooltip(c, !1, l)), v = p.get("order"), y = p.get("valueFormatter"), b = _.frag, x = b ? Py(y ? M({ valueFormatter: y }, b) : b, g, d, v, r.get("useUTC"), p.get("textStyle")) : _.text, S = "item_" + s.name + "_" + c;
			this._showOrMove(p, function() {
				this._showTooltipContent(p, x, h, S, e.offsetX, e.offsetY, e.position, e.target, g);
			}), n({
				type: "showTip",
				dataIndexInside: c,
				dataIndex: u.getRawIndex(c),
				seriesIndex: a,
				from: this.uid
			});
		}
	}, t.prototype._showComponentItemTooltip = function(e, t, n) {
		var r = this._renderMode === "html", i = Z(t), a = i.tooltipConfig.option || {}, o = a.encodeHTMLContent;
		if (U(a)) {
			var s = a;
			a = {
				content: s,
				formatter: s
			}, o = !0;
		}
		o && r && a.content && (a = A(a), a.content = Tt(a.content));
		var c = [a], l = this._ecModel.getComponent(i.componentMainType, i.componentIndex);
		l && c.push(l), c.push({ formatter: a.content });
		var u = e.positionDefault, d = Uz(c, this._tooltipModel, u ? { position: u } : null), f = d.get("content"), p = Math.random() + "", m = new Uy();
		this._showOrMove(d, function() {
			var n = A(d.get("formatterParams") || {});
			this._showTooltipContent(d, f, n, p, e.offsetX, e.offsetY, e.position, t, m);
		}), n({
			type: "showTip",
			from: this.uid
		});
	}, t.prototype._showTooltipContent = function(e, t, n, r, i, a, o, s, c) {
		if (this._ticket = "", e.get("showContent") && e.get("show")) {
			var l = this._tooltipContent;
			l.setEnterable(e.get("enterable"));
			var u = e.get("formatter");
			o ||= e.get("position");
			var d = t, f = this._getNearestPoint([i, a], n, e.get("trigger"), e.get("borderColor"), e.get("defaultBorderColor", !0)).color;
			if (u) {
				if (U(u)) {
					var p = e.ecModel.get("useUTC"), m = V(n) ? n[0] : n, h = m && m.axisType && m.axisType.indexOf("time") >= 0;
					d = u, h && (d = Gh(m.axisValue, d, p)), d = gg(d, n, !0);
				} else if (H(u)) {
					var g = z(function(t, r) {
						t === this._ticket && (l.setContent(r, c, e, f, o), this._updatePosition(e, o, i, a, l, n, s));
					}, this);
					this._ticket = r, d = u(n, r, g);
				} else d = u;
			}
			l.setContent(d, c, e, f, o), l.show(e, f), this._updatePosition(e, o, i, a, l, n, s);
		}
	}, t.prototype._getNearestPoint = function(e, t, n, r, i) {
		if (n === "axis" || V(t)) return { color: r || i };
		if (!V(t)) return { color: r || t.color || t.borderColor };
	}, t.prototype._updatePosition = function(e, t, n, r, i, a, o) {
		var s = this._api.getWidth(), c = this._api.getHeight();
		t ||= e.get("position");
		var l = i.getSize(), u = e.get("align"), d = e.get("verticalAlign"), f = o && o.getBoundingRect().clone();
		if (o && f.applyTransform(o.transform), H(t) && (t = t([n, r], a, i.el, f, {
			viewSize: [s, c],
			contentSize: l.slice()
		})), V(t)) n = So(t[0], s), r = So(t[1], c);
		else if (W(t)) {
			var p = t;
			p.width = l[0], p.height = l[1];
			var m = zg(p, {
				width: s,
				height: c
			});
			n = m.x, r = m.y, u = null, d = null;
		} else if (U(t) && o) {
			var h = qz(t, f, l, e.get("borderWidth"));
			n = h[0], r = h[1];
		} else {
			var h = Gz(n, r, i, s, c, u ? null : 20, d ? null : 20);
			n = h[0], r = h[1];
		}
		if (u && (n -= Jz(u) ? l[0] / 2 : u === "right" ? l[0] : 0), d && (r -= Jz(d) ? l[1] / 2 : d === "bottom" ? l[1] : 0), bz(e)) {
			var h = Kz(n, r, i, s, c);
			n = h[0], r = h[1];
		}
		i.moveTo(n, r);
	}, t.prototype._updateContentNotChangedOnAxis = function(e, t) {
		var n = this._lastDataByCoordSys, r = this._cbParamsList, i = !!n && n.length === e.length;
		return i && I(n, function(n, a) {
			var o = n.dataByAxis || [], s = (e[a] || {}).dataByAxis || [];
			i &&= o.length === s.length, i && I(o, function(e, n) {
				var a = s[n] || {}, o = e.seriesDataIndices || [], c = a.seriesDataIndices || [];
				i = i && e.value === a.value && e.axisType === a.axisType && e.axisId === a.axisId && o.length === c.length, i && I(o, function(e, t) {
					var n = c[t];
					i = i && e.seriesIndex === n.seriesIndex && e.dataIndex === n.dataIndex;
				}), r && I(e.seriesDataIndices, function(e) {
					var n = e.seriesIndex, a = t[n], o = r[n];
					a && o && o.data !== a.data && (i = !1);
				});
			});
		}), this._lastDataByCoordSys = e, this._cbParamsList = t, !!i;
	}, t.prototype._hide = function(e) {
		this._lastDataByCoordSys = null, this._cbParamsList = null, e({
			type: "hideTip",
			from: this.uid
		});
	}, t.prototype.dispose = function(e, t) {
		!i.node && t.getDom() && (vb(this, "_updatePosition"), this._tooltipContent.dispose(), _R("itemTooltip", t), this._tooltipContent = null, this._tooltipModel = null, this._lastDataByCoordSys = null, this._cbParamsList = null);
	}, t.type = "tooltip", t;
}(rb);
function Uz(e, t, n) {
	var r = t.ecModel, i;
	n ? (i = new ih(n, r, r), i = new ih(t.option, i, r)) : i = t;
	for (var a = e.length - 1; a >= 0; a--) {
		var o = e[a];
		o && (o instanceof ih && (o = o.get("tooltip", !0)), U(o) && (o = { formatter: o }), o && (i = new ih(o, i, r)));
	}
	return i;
}
function Wz(e, t) {
	return e.dispatchAction || z(t.dispatchAction, t);
}
function Gz(e, t, n, r, i, a, o) {
	var s = n.getSize(), c = s[0], l = s[1];
	return a != null && (e + c + a + 2 > r ? e -= c + a : e += a), o != null && (t + l + o > i ? t -= l + o : t += o), [e, t];
}
function Kz(e, t, n, r, i) {
	var a = n.getSize(), o = a[0], s = a[1];
	return e = Math.min(e + o, r) - o, t = Math.min(t + s, i) - s, e = Math.max(e, 0), t = Math.max(t, 0), [e, t];
}
function qz(e, t, n, r) {
	var i = n[0], a = n[1], o = Math.ceil(Math.SQRT2 * r) + 8, s = 0, c = 0, l = t.width, u = t.height;
	switch (e) {
		case "inside":
			s = t.x + l / 2 - i / 2, c = t.y + u / 2 - a / 2;
			break;
		case "top":
			s = t.x + l / 2 - i / 2, c = t.y - a - o;
			break;
		case "bottom":
			s = t.x + l / 2 - i / 2, c = t.y + u + o;
			break;
		case "left":
			s = t.x - i - o, c = t.y + u / 2 - a / 2;
			break;
		case "right": s = t.x + l + o, c = t.y + u / 2 - a / 2;
	}
	return [s, c];
}
function Jz(e) {
	return e === "center" || e === "middle";
}
function Yz(e, t, n) {
	var r = As(e).queryOptionMap, i = r.keys()[0];
	if (i && i !== "series") {
		var a = Ns(t, i, r.get(i), {
			useDefault: !1,
			enableAll: !1,
			enableNone: !1
		}).models[0];
		if (a) {
			var o = n.getViewOfComponentModel(a), s;
			if (o.group.traverse(function(t) {
				var n = Z(t).tooltipConfig;
				if (n && n.name === e.name) return s = t, !0;
			}), s) return {
				componentMainType: i,
				componentIndex: a.componentIndex,
				el: s
			};
		}
	}
}
//#endregion
//#region node_modules/echarts/lib/component/tooltip/install.js
function Xz(e) {
	TD(MR), e.registerComponentModel(yz), e.registerComponentView(Hz), e.registerAction({
		type: "showTip",
		event: "showTip",
		update: "tooltip:manuallyShowTip"
	}, Pe), e.registerAction({
		type: "hideTip",
		event: "hideTip",
		update: "tooltip:manuallyHideTip"
	}, Pe);
}
//#endregion
//#region node_modules/echarts/lib/visual/visualSolution.js
var Zz = I;
function Qz(e) {
	if (e) {
		for (var t in e) if (e.hasOwnProperty(t)) return !0;
	}
}
function $z(e, t, n) {
	var r = {};
	return Zz(t, function(t) {
		var a = r[t] = i();
		Zz(e[t], function(e, r) {
			if (FF.isValidType(r)) {
				var i = {
					type: r,
					visual: e
				};
				n && n(i, t), a[r] = new FF(i), r === "opacity" && (i = A(i), i.type = "colorAlpha", a.__hidden.__alphaForOpacity = new FF(i));
			}
		});
	}), r;
	function i() {
		var e = function() {};
		return e.prototype.__hidden = e.prototype, new e();
	}
}
function eB(e, t, n) {
	var r;
	I(n, function(e) {
		t.hasOwnProperty(e) && Qz(t[e]) && (r = !0);
	}), r && I(n, function(n) {
		t.hasOwnProperty(n) && Qz(t[n]) ? e[n] = A(t[n]) : delete e[n];
	});
}
function tB(e, t, n, r) {
	var i = {};
	return I(e, function(e) {
		i[e] = FF.prepareVisualTypes(t[e]);
	}), { progress: function(e, a) {
		var o;
		r != null && (o = a.getDimensionIndex(r));
		function s(e) {
			return ex(a, l, e);
		}
		function c(e, t) {
			nx(a, l, e, t);
		}
		for (var l, u = a.getStore(); (l = e.next()) != null;) {
			var d = a.getRawDataItem(l);
			if (!(d && d.visualMap === !1)) for (var f = r == null ? l : u.get(o, l), p = n(f), m = t[p], h = i[p], g = 0, _ = h.length; g < _; g++) {
				var v = h[g];
				m[v] && m[v].applyVisual(f, s, c);
			}
		}
	} };
}
//#endregion
//#region node_modules/echarts/lib/component/title/install.js
var nB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.layoutMode = {
			type: "box",
			ignoreSize: !0
		}, n;
	}
	return t.type = "title", t.defaultOption = {
		z: 6,
		show: !0,
		text: "",
		target: "blank",
		subtext: "",
		subtarget: "blank",
		left: "center",
		top: Q.size.m,
		backgroundColor: Q.color.transparent,
		borderColor: Q.color.primary,
		borderWidth: 0,
		padding: 5,
		itemGap: 10,
		textStyle: {
			fontSize: 18,
			fontWeight: "bold",
			color: Q.color.primary
		},
		subtextStyle: {
			fontSize: 12,
			color: Q.color.quaternary
		}
	}, t;
}(Jg), rB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.render = function(e, t, n) {
		if (this.group.removeAll(), e.get("show")) {
			var r = this.group, i = e.getModel("textStyle"), a = e.getModel("subtextStyle"), o = e.get("textAlign"), s = G(e.get("textBaseline"), e.get("textVerticalAlign")), c = new Tu({
				style: Fm(i, {
					text: e.get("text"),
					fill: i.getTextColor()
				}, { disableBox: !0 }),
				z2: 10
			}), l = c.getBoundingRect(), u = e.get("subtext"), d = new Tu({
				style: Fm(a, {
					text: u,
					fill: a.getTextColor(),
					y: l.height + e.get("itemGap"),
					verticalAlign: "top"
				}, { disableBox: !0 }),
				z2: 10
			}), f = e.get("link"), p = e.get("sublink"), m = e.get("triggerEvent", !0);
			c.silent = !f && !m, d.silent = !p && !m, f && c.on("click", function() {
				xg(f, "_" + e.get("target"));
			}), p && d.on("click", function() {
				xg(p, "_" + e.get("subtarget"));
			}), Z(c).eventData = Z(d).eventData = m ? {
				componentType: "title",
				componentIndex: e.componentIndex
			} : null, r.add(c), u && r.add(d);
			var h = r.getBoundingRect(), g = e.getBoxLayoutParams();
			g.width = h.width, g.height = h.height;
			var _ = zg(g, Vg(e, n).refContainer, e.get("padding"));
			o || (o = e.get("left") || e.get("right"), o === "middle" && (o = "center"), o === "right" ? _.x += _.width : o === "center" && (_.x += _.width / 2)), s || (s = e.get("top") || e.get("bottom"), s === "center" && (s = "middle"), s === "bottom" ? _.y += _.height : s === "middle" && (_.y += _.height / 2), s ||= "top"), r.x = _.x, r.y = _.y, r.markRedraw();
			var v = {
				align: o,
				verticalAlign: s
			};
			c.setStyle(v), d.setStyle(v), h = r.getBoundingRect();
			var y = _.margin, b = e.getItemStyle(["color", "opacity"]);
			b.fill = e.get("backgroundColor");
			var x = new bu({
				shape: {
					x: h.x - y[3],
					y: h.y - y[0],
					width: h.width + y[1] + y[3],
					height: h.height + y[0] + y[2],
					r: e.get("borderRadius")
				},
				style: b,
				subPixelOptimize: !0,
				silent: !0
			});
			r.add(x);
		}
	}, t.type = "title", t;
}(rb);
function iB(e) {
	e.registerComponentModel(nB), e.registerComponentView(rB);
}
//#endregion
//#region node_modules/echarts/lib/component/marker/checkMarkerInSeries.js
function aB(e, t) {
	if (!e) return !1;
	for (var n = V(e) ? e : [e], r = 0; r < n.length; r++) if (n[r] && n[r][t]) return !0;
	return !1;
}
//#endregion
//#region node_modules/echarts/lib/component/marker/MarkerModel.js
function oB(e) {
	cs(e, "label", ["show"]);
}
var sB = X(), cB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.createdBySelf = !1, n.preventAutoZ = !0, n;
	}
	return t.prototype.init = function(e, t, n) {
		this.mergeDefaultAndTheme(e, n), this._mergeOption(e, n, !1, !0);
	}, t.prototype.isAnimationEnabled = function() {
		if (i.node) return !1;
		var e = this.__hostSeries;
		return this.getShallow("animation") && e && e.isAnimationEnabled();
	}, t.prototype.mergeOption = function(e, t) {
		this._mergeOption(e, t, !1, !1);
	}, t.prototype._mergeOption = function(e, t, n, r) {
		var i = this.mainType;
		n || t.eachSeries(function(e) {
			var n = e.get(this.mainType, !0), a = sB(e)[i];
			!n || !n.data ? sB(e)[i] = null : (a ? a._mergeOption(n, t, !0) : (r && oB(n), I(n.data, function(e) {
				e instanceof Array ? (oB(e[0]), oB(e[1])) : oB(e);
			}), a = this.createMarkerModelFromSeries(n, this, t), M(a, {
				mainType: this.mainType,
				seriesIndex: e.seriesIndex,
				name: e.name,
				createdBySelf: !0
			}), a.__hostSeries = e), sB(e)[i] = a);
		}, this);
	}, t.prototype.formatTooltip = function(e, t, n) {
		var r = this.getData(), i = this.getRawValue(e), a = r.getName(e);
		return Oy("section", {
			header: this.name,
			blocks: [Oy("nameValue", {
				name: a,
				value: i,
				noName: !a,
				noValue: i == null
			})]
		});
	}, t.prototype.getData = function() {
		return this._data;
	}, t.prototype.setData = function(e) {
		this._data = e;
	}, t.prototype.getDataParams = function(e, t) {
		var n = Uv.prototype.getDataParams.call(this, e, t), r = this.__hostSeries;
		return r && (n.seriesId = r.id, n.seriesName = r.name, n.seriesType = r.subType), n;
	}, t.getMarkerModelFromSeries = function(e, t) {
		return sB(e)[t];
	}, t.type = "marker", t.dependencies = [
		"series",
		"grid",
		"polar",
		"geo"
	], t;
}(Jg);
F(cB, Uv.prototype);
//#endregion
//#region node_modules/echarts/lib/component/marker/MarkPointModel.js
var lB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.createMarkerModelFromSeries = function(e, n, r) {
		return new t(e, n, r);
	}, t.type = "markPoint", t.defaultOption = {
		z: 5,
		symbol: "pin",
		symbolSize: 50,
		tooltip: { trigger: "item" },
		label: {
			show: !0,
			position: "inside"
		},
		itemStyle: { borderWidth: 2 },
		emphasis: { label: { show: !0 } }
	}, t;
}(cB);
//#endregion
//#region node_modules/echarts/lib/component/marker/markerHelper.js
function uB(e) {
	return !(isNaN(parseFloat(e.x)) && isNaN(parseFloat(e.y)));
}
function dB(e) {
	return !isNaN(parseFloat(e.x)) && !isNaN(parseFloat(e.y));
}
function fB(e, t, n, r, i, a, o) {
	var s = [], c = tT(t, i) ? t.getCalculationInfo("stackResultDimension") : i, l = bB(t, c, e), u = t.hostModel.indicesOfNearest(n, c, l)[0];
	s[a] = t.get(r, u), s[o] = t.get(c, u);
	var d = t.get(i, u), f = ko(t.get(i, u));
	return f = Math.min(f, 20), f >= 0 && (s[o] = +s[o].toFixed(f)), [s, d];
}
var pB = {
	min: B(fB, "min"),
	max: B(fB, "max"),
	average: B(fB, "average"),
	median: B(fB, "median")
};
function mB(e, t) {
	if (t) {
		var n = e.getData(), r = e.coordinateSystem, i = r && r.dimensions;
		if (!dB(t) && !V(t.coord) && V(i)) {
			var a = hB(t, n, r, e);
			if (t = A(t), t.type && pB[t.type] && a.baseAxis && a.valueAxis) {
				var o = P(i, a.baseAxis.dim), s = P(i, a.valueAxis.dim), c = pB[t.type](n, a.valueAxis.dim, a.baseDataDim, a.valueDataDim, o, s);
				t.coord = c[0], t.value = c[1];
			} else t.coord = [t.xAxis == null ? t.radiusAxis : t.xAxis, t.yAxis == null ? t.angleAxis : t.yAxis];
		}
		if (t.coord == null || !V(i)) {
			t.coord = [];
			var l = e.getBaseAxis();
			if (l && t.type && pB[t.type]) {
				var u = r.getOtherAxis(l);
				u && (t.value = bB(n, n.mapDimension(u.dim), t.type));
			}
		} else for (var d = t.coord, f = 0; f < 2; f++) pB[d[f]] && (d[f] = bB(n, n.mapDimension(i[f]), d[f]));
		return t;
	}
}
function hB(e, t, n, r) {
	var i = {};
	return e.valueIndex != null || e.valueDim != null ? (i.valueDataDim = e.valueIndex == null ? e.valueDim : t.getDimension(e.valueIndex), i.valueAxis = n.getAxis(gB(r, i.valueDataDim)), i.baseAxis = n.getOtherAxis(i.valueAxis), i.baseDataDim = t.mapDimension(i.baseAxis.dim)) : (i.baseAxis = r.getBaseAxis(), i.valueAxis = n.getOtherAxis(i.baseAxis), i.baseDataDim = t.mapDimension(i.baseAxis.dim), i.valueDataDim = t.mapDimension(i.valueAxis.dim)), i;
}
function gB(e, t) {
	var n = e.getData().getDimensionInfo(t);
	return n && n.coordDim;
}
function _B(e, t) {
	return e && e.containData && t.coord && !uB(t) ? e.containData(t.coord) : !0;
}
function vB(e, t, n) {
	return e && e.containZone && t.coord && n.coord && !uB(t) && !uB(n) ? e.containZone(t.coord, n.coord) : !0;
}
function yB(e, t) {
	return e ? function(e, n, r, i) {
		return Jv(i < 2 ? e.coord && e.coord[i] : e.value, t[i]);
	} : function(e, n, r, i) {
		return Jv(e.value, t[i]);
	};
}
function bB(e, t, n) {
	if (n === "average") {
		var r = 0, i = 0;
		return e.each(t, function(e, t) {
			isNaN(e) || (r += e, i++);
		}), r / i;
	}
	return n === "median" ? e.getMedian(t) : e.getDataExtent(t)[+(n === "max")];
}
//#endregion
//#region node_modules/echarts/lib/component/marker/MarkerView.js
var xB = X(), SB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.init = function() {
		this.markerGroupMap = K();
	}, t.prototype.render = function(e, t, n) {
		var r = this, i = this.markerGroupMap;
		i.each(function(e) {
			xB(e).keep = !1;
		}), t.eachSeries(function(e) {
			var i = cB.getMarkerModelFromSeries(e, r.type);
			i && r.renderSeries(e, i, t, n);
		}), i.each(function(e) {
			!xB(e).keep && r.group.remove(e.group);
		}), CB(t, i, this.type);
	}, t.prototype.markKeep = function(e) {
		xB(e).keep = !0;
	}, t.prototype.toggleBlurSeries = function(e, t) {
		var n = this;
		I(e, function(e) {
			var r = cB.getMarkerModelFromSeries(e, n.type);
			r && r.getData().eachItemGraphicEl(function(e) {
				e && (t ? Ad(e) : jd(e));
			});
		});
	}, t.type = "marker", t;
}(rb);
function CB(e, t, n) {
	e.eachSeries(function(e) {
		var r = cB.getMarkerModelFromSeries(e, n), i = t.get(e.id);
		if (r && i && i.group) {
			var a = Sm(r), o = a.z, s = a.zlevel;
			wm(i.group, o, s);
		}
	});
}
//#endregion
//#region node_modules/echarts/lib/component/marker/MarkPointView.js
function wB(e, t, n) {
	var r = t.coordinateSystem, i = n.getWidth(), a = n.getHeight(), o = r && r.getArea && r.getArea();
	e.each(function(n) {
		var s = e.getItemModel(n), c = s.get("relativeTo") === "coordinate", l = c ? o ? o.width : 0 : i, u = c ? o ? o.height : 0 : a, d = c && o ? o.x : 0, f = c && o ? o.y : 0, p, m = So(s.get("x"), l) + d, h = So(s.get("y"), u) + f;
		if (!isNaN(m) && !isNaN(h)) p = [m, h];
		else if (t.getMarkerPosition) p = t.getMarkerPosition(e.getValues(e.dimensions, n));
		else if (r) {
			var g = e.get(r.dimensions[0], n), _ = e.get(r.dimensions[1], n);
			p = r.dataToPoint([g, _]);
		}
		isNaN(m) || (p[0] = m), isNaN(h) || (p[1] = h), e.setItemLayout(n, p);
	});
}
var TB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.updateTransform = function(e, t, n) {
		t.eachSeries(function(e) {
			var t = cB.getMarkerModelFromSeries(e, "markPoint");
			t && (wB(t.getData(), e, n), this.markerGroupMap.get(e.id).updateLayout());
		}, this);
	}, t.prototype.renderSeries = function(e, t, n, r) {
		var i = e.coordinateSystem, a = e.id, o = e.getData(), s = this.markerGroupMap, c = s.get(a) || s.set(a, new Pk()), l = EB(i, e, t);
		t.setData(l), wB(t.getData(), e, r), l.each(function(e) {
			var n = l.getItemModel(e), r = n.getShallow("symbol"), i = n.getShallow("symbolSize"), a = n.getShallow("symbolRotate"), s = n.getShallow("symbolOffset"), c = n.getShallow("symbolKeepAspect");
			if (H(r) || H(i) || H(a) || H(s)) {
				var u = t.getRawValue(e), d = t.getDataParams(e);
				H(r) && (r = r(u, d)), H(i) && (i = i(u, d)), H(a) && (a = a(u, d)), H(s) && (s = s(u, d));
			}
			var f = n.getModel("itemStyle").getItemStyle(), p = n.get("z2"), m = tx(o, "color");
			f.fill ||= m, l.setItemVisual(e, {
				z2: G(p, 0),
				symbol: r,
				symbolSize: i,
				symbolRotate: a,
				symbolOffset: s,
				symbolKeepAspect: c,
				style: f
			});
		}), c.updateData(l), this.group.add(c.group), l.eachItemGraphicEl(function(e) {
			e.traverse(function(e) {
				Z(e).dataModel = t;
			});
		}), this.markKeep(c), c.group.silent = t.get("silent") || e.get("silent");
	}, t.type = "markPoint", t;
}(SB);
function EB(e, t, n) {
	var r = e ? L(e && e.dimensions, function(e) {
		var n = t.getData();
		return M(M({}, n.getDimensionInfo(n.mapDimension(e)) || {}), {
			name: e,
			ordinalMeta: null
		});
	}) : [{
		name: "value",
		type: "float"
	}], i = new Ww(r, n), a = L(n.get("data"), B(mB, t));
	e && (a = oe(a, B(_B, e)));
	var o = yB(!!e, r);
	return i.initData(a, null, o), i;
}
//#endregion
//#region node_modules/echarts/lib/component/marker/installMarkPoint.js
function DB(e) {
	e.registerComponentModel(lB), e.registerComponentView(TB), e.registerPreprocessor(function(e) {
		aB(e.series, "markPoint") && (e.markPoint = e.markPoint || {});
	});
}
//#endregion
//#region node_modules/echarts/lib/component/marker/MarkLineModel.js
var OB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.createMarkerModelFromSeries = function(e, n, r) {
		return new t(e, n, r);
	}, t.type = "markLine", t.defaultOption = {
		z: 5,
		symbol: ["circle", "arrow"],
		symbolSize: [8, 16],
		symbolOffset: 0,
		precision: 2,
		tooltip: { trigger: "item" },
		label: {
			show: !0,
			position: "end",
			distance: 5
		},
		lineStyle: { type: "dashed" },
		emphasis: {
			label: { show: !0 },
			lineStyle: { width: 3 }
		},
		animationEasing: "linear"
	}, t;
}(cB), kB = X(), AB = function(e, t, n, r) {
	var i = e.getData(), a;
	if (V(r)) a = r;
	else {
		var o = r.type;
		if (o === "min" || o === "max" || o === "average" || o === "median" || r.xAxis != null || r.yAxis != null) {
			var s = void 0, c = void 0;
			if (r.yAxis != null || r.xAxis != null) s = t.getAxis(r.yAxis == null ? "x" : "y"), c = ve(r.yAxis, r.xAxis);
			else {
				var l = hB(r, i, t, e);
				s = l.valueAxis, c = bB(i, nT(i, l.valueDataDim), o);
			}
			var u = s.dim === "x" ? 0 : 1, d = 1 - u, f = A(r), p = { coord: [] };
			f.type = null, f.coord = [], f.coord[d] = -Infinity, p.coord[d] = Infinity;
			var m = n.get("precision");
			m >= 0 && ue(c) && (c = +c.toFixed(Math.min(m, 20))), f.coord[u] = p.coord[u] = c, a = [
				f,
				p,
				{
					type: o,
					valueIndex: r.valueIndex,
					value: c
				}
			];
		} else a = [];
	}
	var h = [
		mB(e, a[0]),
		mB(e, a[1]),
		M({}, a[2])
	];
	return h[2].type = h[2].type || null, j(h[2], h[0]), j(h[2], h[1]), h;
};
function jB(e) {
	return !isNaN(e) && !isFinite(e);
}
function MB(e, t, n, r) {
	var i = 1 - e, a = r.dimensions[e];
	return jB(t[i]) && jB(n[i]) && t[e] === n[e] && r.getAxis(a).containData(t[e]);
}
function NB(e, t) {
	if (e.type === "cartesian2d") {
		var n = t[0].coord, r = t[1].coord;
		if (n && r && (MB(1, n, r, e) || MB(0, n, r, e))) return !0;
	}
	return _B(e, t[0]) && _B(e, t[1]);
}
function PB(e, t, n, r, i) {
	var a = r.coordinateSystem, o = e.getItemModel(t), s, c = So(o.get("x"), i.getWidth()), l = So(o.get("y"), i.getHeight());
	if (!isNaN(c) && !isNaN(l)) s = [c, l];
	else {
		if (r.getMarkerPosition) s = r.getMarkerPosition(e.getValues(e.dimensions, t));
		else {
			var u = a.dimensions, d = e.get(u[0], t), f = e.get(u[1], t);
			s = a.dataToPoint([d, f]);
		}
		if (rA(a, "cartesian2d")) {
			var p = a.getAxis("x"), m = a.getAxis("y"), u = a.dimensions;
			jB(e.get(u[0], t)) ? s[0] = p.toGlobalCoord(p.getExtent()[+!n]) : jB(e.get(u[1], t)) && (s[1] = m.toGlobalCoord(m.getExtent()[+!n]));
		}
		isNaN(c) || (s[0] = c), isNaN(l) || (s[1] = l);
	}
	e.setItemLayout(t, s);
}
var FB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.updateTransform = function(e, t, n) {
		t.eachSeries(function(e) {
			var t = cB.getMarkerModelFromSeries(e, "markLine");
			if (t) {
				var r = t.getData(), i = kB(t).from, a = kB(t).to;
				i.each(function(t) {
					PB(i, t, !0, e, n), PB(a, t, !1, e, n);
				}), r.each(function(e) {
					r.setItemLayout(e, [i.getItemLayout(e), a.getItemLayout(e)]);
				}), this.markerGroupMap.get(e.id).updateLayout();
			}
		}, this);
	}, t.prototype.renderSeries = function(e, t, n, r) {
		var i = e.coordinateSystem, a = e.id, o = e.getData(), s = this.markerGroupMap, c = s.get(a) || s.set(a, new yI());
		this.group.add(c.group);
		var l = IB(i, e, t), u = l.from, d = l.to, f = l.line;
		kB(t).from = u, kB(t).to = d, t.setData(f);
		var p = t.get("symbol"), m = t.get("symbolSize"), h = t.get("symbolRotate"), g = t.get("symbolOffset");
		V(p) || (p = [p, p]), V(m) || (m = [m, m]), V(h) || (h = [h, h]), V(g) || (g = [g, g]), l.from.each(function(e) {
			_(u, e, !0), _(d, e, !1);
		}), f.each(function(e) {
			var t = f.getItemModel(e), n = t.getModel("lineStyle").getLineStyle();
			f.setItemLayout(e, [u.getItemLayout(e), d.getItemLayout(e)]);
			var r = t.get("z2");
			n.stroke ??= u.getItemVisual(e, "style").fill, f.setItemVisual(e, {
				z2: G(r, 0),
				fromSymbolKeepAspect: u.getItemVisual(e, "symbolKeepAspect"),
				fromSymbolOffset: u.getItemVisual(e, "symbolOffset"),
				fromSymbolRotate: u.getItemVisual(e, "symbolRotate"),
				fromSymbolSize: u.getItemVisual(e, "symbolSize"),
				fromSymbol: u.getItemVisual(e, "symbol"),
				toSymbolKeepAspect: d.getItemVisual(e, "symbolKeepAspect"),
				toSymbolOffset: d.getItemVisual(e, "symbolOffset"),
				toSymbolRotate: d.getItemVisual(e, "symbolRotate"),
				toSymbolSize: d.getItemVisual(e, "symbolSize"),
				toSymbol: d.getItemVisual(e, "symbol"),
				style: n
			});
		}), c.updateData(f), l.line.eachItemGraphicEl(function(e) {
			Z(e).dataModel = t, e.traverse(function(e) {
				Z(e).dataModel = t;
			});
		});
		function _(t, n, i) {
			var a = t.getItemModel(n);
			PB(t, n, i, e, r);
			var s = a.getModel("itemStyle").getItemStyle();
			s.fill ??= tx(o, "color"), t.setItemVisual(n, {
				symbolKeepAspect: a.get("symbolKeepAspect"),
				symbolOffset: G(a.get("symbolOffset", !0), g[+!i]),
				symbolRotate: G(a.get("symbolRotate", !0), h[+!i]),
				symbolSize: G(a.get("symbolSize"), m[+!i]),
				symbol: G(a.get("symbol", !0), p[+!i]),
				style: s
			});
		}
		this.markKeep(c), c.group.silent = t.get("silent") || e.get("silent");
	}, t.type = "markLine", t;
}(SB);
function IB(e, t, n) {
	var r = e ? L(e && e.dimensions, function(e) {
		var n = t.getData();
		return M(M({}, n.getDimensionInfo(n.mapDimension(e)) || {}), {
			name: e,
			ordinalMeta: null
		});
	}) : [{
		name: "value",
		type: "float"
	}], i = new Ww(r, n), a = new Ww(r, n), o = new Ww([], n), s = L(n.get("data"), B(AB, t, e, n));
	e && (s = oe(s, B(NB, e)));
	var c = yB(!!e, r);
	return i.initData(L(s, function(e) {
		return e[0];
	}), null, c), a.initData(L(s, function(e) {
		return e[1];
	}), null, c), o.initData(L(s, function(e) {
		return e[2];
	})), o.hasItemOption = !0, {
		from: i,
		to: a,
		line: o
	};
}
//#endregion
//#region node_modules/echarts/lib/component/marker/installMarkLine.js
function LB(e) {
	e.registerComponentModel(OB), e.registerComponentView(FB), e.registerPreprocessor(function(e) {
		aB(e.series, "markLine") && (e.markLine = e.markLine || {});
	});
}
//#endregion
//#region node_modules/echarts/lib/component/marker/MarkAreaModel.js
var RB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.createMarkerModelFromSeries = function(e, n, r) {
		return new t(e, n, r);
	}, t.type = "markArea", t.defaultOption = {
		z: 1,
		tooltip: { trigger: "item" },
		animation: !1,
		label: {
			show: !0,
			position: "top"
		},
		itemStyle: { borderWidth: 0 },
		emphasis: { label: {
			show: !0,
			position: "top"
		} }
	}, t;
}(cB), zB = X(), BB = function(e, t, n, r) {
	var i = r[0], a = r[1];
	if (i && a) {
		var o = mB(e, i), s = mB(e, a), c = o.coord, l = s.coord;
		c[0] = ve(c[0], -Infinity), c[1] = ve(c[1], -Infinity), l[0] = ve(l[0], Infinity), l[1] = ve(l[1], Infinity);
		var u = ee([
			{},
			o,
			s
		]);
		return u.coord = [o.coord, s.coord], u.x0 = o.x, u.y0 = o.y, u.x1 = s.x, u.y1 = s.y, u;
	}
};
function VB(e) {
	return !isNaN(e) && !isFinite(e);
}
function HB(e, t, n, r) {
	var i = 1 - e;
	return VB(t[i]) && VB(n[i]);
}
function UB(e, t) {
	var n = t.coord[0], r = t.coord[1], i = {
		coord: n,
		x: t.x0,
		y: t.y0
	}, a = {
		coord: r,
		x: t.x1,
		y: t.y1
	};
	return rA(e, "cartesian2d") ? n && r && (HB(1, n, r, e) || HB(0, n, r, e)) ? !0 : vB(e, i, a) : _B(e, i) || _B(e, a);
}
function WB(e, t, n, r, i) {
	var a = r.coordinateSystem, o = e.getItemModel(t), s, c = So(o.get(n[0]), i.getWidth()), l = So(o.get(n[1]), i.getHeight());
	if (!isNaN(c) && !isNaN(l)) s = [c, l];
	else {
		if (r.getMarkerPosition) {
			var u = e.getValues(["x0", "y0"], t), d = e.getValues(["x1", "y1"], t), f = a.clampData(u), p = a.clampData(d), m = [];
			m[0] = n[0] === "x0" ? f[0] > p[0] ? d[0] : u[0] : f[0] > p[0] ? u[0] : d[0], m[1] = n[1] === "y0" ? f[1] > p[1] ? d[1] : u[1] : f[1] > p[1] ? u[1] : d[1], s = r.getMarkerPosition(m, n, !0);
		} else {
			var h = e.get(n[0], t), g = e.get(n[1], t), _ = [h, g];
			a.clampData && a.clampData(_, _), s = a.dataToPoint(_, !0);
		}
		if (rA(a, "cartesian2d")) {
			var v = a.getAxis("x"), y = a.getAxis("y"), h = e.get(n[0], t), g = e.get(n[1], t);
			VB(h) ? s[0] = v.toGlobalCoord(v.getExtent()[n[0] === "x0" ? 0 : 1]) : VB(g) && (s[1] = y.toGlobalCoord(y.getExtent()[n[1] === "y0" ? 0 : 1]));
		}
		isNaN(c) || (s[0] = c), isNaN(l) || (s[1] = l);
	}
	return s;
}
var GB = [
	["x0", "y0"],
	["x1", "y0"],
	["x1", "y1"],
	["x0", "y1"]
], KB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.updateTransform = function(e, t, n) {
		t.eachSeries(function(e) {
			var t = cB.getMarkerModelFromSeries(e, "markArea");
			if (t) {
				var r = t.getData();
				r.each(function(t) {
					var i = L(GB, function(i) {
						return WB(r, t, i, e, n);
					});
					r.setItemLayout(t, i), r.getItemGraphicEl(t).setShape("points", i);
				});
			}
		}, this);
	}, t.prototype.renderSeries = function(e, t, n, r) {
		var i = e.coordinateSystem, a = e.id, o = e.getData(), s = this.markerGroupMap, c = s.get(a) || s.set(a, { group: new Wa() });
		this.group.add(c.group), this.markKeep(c);
		var l = qB(i, e, t);
		t.setData(l), l.each(function(t) {
			var n = L(GB, function(n) {
				return WB(l, t, n, e, r);
			}), a = i.getAxis("x").scale, s = i.getAxis("y").scale, c = a.getExtent(), u = s.getExtent(), d = [a.parse(l.get("x0", t)), a.parse(l.get("x1", t))], f = [s.parse(l.get("y0", t)), s.parse(l.get("y1", t))];
			Oo(d), Oo(f);
			var p = c[0] > d[1] || c[1] < d[0] || u[0] > f[1] || u[1] < f[0];
			l.setItemLayout(t, {
				points: n,
				allClipped: p
			});
			var m = l.getItemModel(t), h = m.getModel("itemStyle").getItemStyle(), g = m.get("z2"), _ = tx(o, "color");
			h.fill || (h.fill = _, U(h.fill) && (h.fill = Zr(h.fill, .4))), h.stroke ||= _, l.setItemVisual(t, "style", h), l.setItemVisual(t, "z2", G(g, 0));
		}), l.diff(zB(c).data).add(function(e) {
			var t = l.getItemLayout(e), n = l.getItemVisual(e, "z2");
			if (!t.allClipped) {
				var r = new $f({
					z2: G(n, 0),
					shape: { points: t.points }
				});
				l.setItemGraphicEl(e, r), c.group.add(r);
			}
		}).update(function(e, n) {
			var r = zB(c).data.getItemGraphicEl(n), i = l.getItemLayout(e), a = l.getItemVisual(e, "z2");
			i.allClipped ? r && c.group.remove(r) : (r ? kp(r, {
				z2: G(a, 0),
				shape: { points: i.points }
			}, t, e) : r = new $f({ shape: { points: i.points } }), l.setItemGraphicEl(e, r), c.group.add(r));
		}).remove(function(e) {
			var t = zB(c).data.getItemGraphicEl(e);
			c.group.remove(t);
		}).execute(), l.eachItemGraphicEl(function(e, n) {
			var r = l.getItemModel(n), i = l.getItemVisual(n, "style");
			e.useStyle(l.getItemVisual(n, "style")), Nm(e, Pm(r), {
				labelFetcher: t,
				labelDataIndex: n,
				defaultText: l.getName(n) || "",
				inheritColor: U(i.fill) ? Zr(i.fill, 1) : Q.color.neutral99
			}), Zd(e, r), qd(e, null, null, r.get(["emphasis", "disabled"])), Z(e).dataModel = t;
		}), zB(c).data = l, c.group.silent = t.get("silent") || e.get("silent");
	}, t.type = "markArea", t;
}(SB);
function qB(e, t, n) {
	var r, i, a = [
		"x0",
		"y0",
		"x1",
		"y1"
	];
	if (e) {
		var o = L(e && e.dimensions, function(e) {
			var n = t.getData();
			return M(M({}, n.getDimensionInfo(n.mapDimension(e)) || {}), {
				name: e,
				ordinalMeta: null
			});
		});
		i = L(a, function(e, t) {
			return {
				name: e,
				type: o[t % 2].type
			};
		}), r = new Ww(i, n);
	} else i = [{
		name: "value",
		type: "float"
	}], r = new Ww(i, n);
	var s = L(n.get("data"), B(BB, t, e, n));
	e && (s = oe(s, B(UB, e)));
	var c = e ? function(e, t, n, r) {
		var a = e.coord[Math.floor(r / 2)][r % 2];
		return Jv(a, i[r]);
	} : function(e, t, n, r) {
		return Jv(e.value, i[r]);
	};
	return r.initData(s, null, c), r.hasItemOption = !0, r;
}
//#endregion
//#region node_modules/echarts/lib/component/marker/installMarkArea.js
function JB(e) {
	e.registerComponentModel(RB), e.registerComponentView(KB), e.registerPreprocessor(function(e) {
		aB(e.series, "markArea") && (e.markArea = e.markArea || {});
	});
}
//#endregion
//#region node_modules/echarts/lib/component/legend/LegendModel.js
var YB = function(e, t) {
	if (t === "all") return {
		type: "all",
		title: e.getLocaleModel().get([
			"legend",
			"selector",
			"all"
		])
	};
	if (t === "inverse") return {
		type: "inverse",
		title: e.getLocaleModel().get([
			"legend",
			"selector",
			"inverse"
		])
	};
}, XB = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.layoutMode = {
			type: "box",
			ignoreSize: !0
		}, n;
	}
	return t.prototype.init = function(e, t, n) {
		this.mergeDefaultAndTheme(e, n), e.selected = e.selected || {}, this._updateSelector(e);
	}, t.prototype.mergeOption = function(t, n) {
		e.prototype.mergeOption.call(this, t, n), this._updateSelector(t);
	}, t.prototype._updateSelector = function(e) {
		var t = e.selector, n = this.ecModel;
		t === !0 && (t = e.selector = ["all", "inverse"]), V(t) && I(t, function(e, r) {
			U(e) && (e = { type: e }), t[r] = j(e, YB(n, e.type));
		});
	}, t.prototype.optionUpdated = function() {
		this._updateData(this.ecModel);
		var e = this._data;
		if (e[0] && this.get("selectedMode") === "single") {
			for (var t = !1, n = 0; n < e.length; n++) {
				var r = e[n].get("name");
				if (this.isSelected(r)) {
					this.select(r), t = !0;
					break;
				}
			}
			!t && this.select(e[0].get("name"));
		}
	}, t.prototype._updateData = function(e) {
		var t = [], n = [];
		e.eachRawSeries(function(r) {
			var i = r.name;
			n.push(i);
			var a;
			if (r.legendVisualProvider) {
				var o = r.legendVisualProvider.getAllNames();
				e.isSeriesFiltered(r) || (n = n.concat(o)), o.length ? t = t.concat(o) : a = !0;
			} else a = !0;
			a && Ss(r) && t.push(r.name);
		}), this._availableNames = n;
		var r = this.get("data") || t, i = K(), a = L(r, function(e) {
			return (U(e) || ue(e)) && (e = { name: e }), i.get(e.name) ? null : (i.set(e.name, !0), new ih(e, this, this.ecModel));
		}, this);
		this._data = oe(a, function(e) {
			return !!e;
		});
	}, t.prototype.getData = function() {
		return this._data;
	}, t.prototype.select = function(e) {
		var t = this.option.selected;
		if (this.get("selectedMode") === "single") {
			var n = this._data;
			I(n, function(e) {
				t[e.get("name")] = !1;
			});
		}
		t[e] = !0;
	}, t.prototype.unSelect = function(e) {
		this.get("selectedMode") !== "single" && (this.option.selected[e] = !1);
	}, t.prototype.toggleSelected = function(e) {
		var t = this.option.selected;
		t.hasOwnProperty(e) || (t[e] = !0), this[t[e] ? "unSelect" : "select"](e);
	}, t.prototype.allSelect = function() {
		var e = this._data, t = this.option.selected;
		I(e, function(e) {
			t[e.get("name", !0)] = !0;
		});
	}, t.prototype.inverseSelect = function() {
		var e = this._data, t = this.option.selected;
		I(e, function(e) {
			var n = e.get("name", !0);
			t.hasOwnProperty(n) || (t[n] = !0), t[n] = !t[n];
		});
	}, t.prototype.isSelected = function(e) {
		var t = this.option.selected;
		return !(t.hasOwnProperty(e) && !t[e]) && P(this._availableNames, e) >= 0;
	}, t.prototype.getOrient = function() {
		return this.get("orient") === "vertical" ? {
			index: 1,
			name: "vertical"
		} : {
			index: 0,
			name: "horizontal"
		};
	}, t.type = "legend.plain", t.dependencies = ["series"], t.defaultOption = {
		z: 4,
		show: !0,
		orient: "horizontal",
		left: "center",
		bottom: Q.size.m,
		align: "auto",
		backgroundColor: Q.color.transparent,
		borderColor: Q.color.border,
		borderRadius: 0,
		borderWidth: 0,
		padding: 5,
		itemGap: 8,
		itemWidth: 25,
		itemHeight: 14,
		symbolRotate: "inherit",
		symbolKeepAspect: !0,
		inactiveColor: Q.color.disabled,
		inactiveBorderColor: Q.color.disabled,
		inactiveBorderWidth: "auto",
		itemStyle: {
			color: "inherit",
			opacity: "inherit",
			borderColor: "inherit",
			borderWidth: "auto",
			borderCap: "inherit",
			borderJoin: "inherit",
			borderDashOffset: "inherit",
			borderMiterLimit: "inherit"
		},
		lineStyle: {
			width: "auto",
			color: "inherit",
			inactiveColor: Q.color.disabled,
			inactiveWidth: 2,
			opacity: "inherit",
			type: "inherit",
			cap: "inherit",
			join: "inherit",
			dashOffset: "inherit",
			miterLimit: "inherit"
		},
		textStyle: { color: Q.color.secondary },
		selectedMode: !0,
		selector: !1,
		selectorLabel: {
			show: !0,
			borderRadius: 10,
			padding: [
				3,
				5,
				3,
				5
			],
			fontSize: 12,
			fontFamily: "sans-serif",
			color: Q.color.tertiary,
			borderWidth: 1,
			borderColor: Q.color.border
		},
		emphasis: { selectorLabel: {
			show: !0,
			color: Q.color.quaternary
		} },
		selectorPosition: "auto",
		selectorItemGap: 7,
		selectorButtonGap: 10,
		tooltip: { show: !1 },
		triggerEvent: !1
	}, t;
}(Jg), ZB = B, QB = I, $B = Wa, eV = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.newlineDisabled = !1, n;
	}
	return t.prototype.init = function() {
		this.group.add(this._contentGroup = new $B()), this.group.add(this._selectorGroup = new $B()), this._isFirstRender = !0;
	}, t.prototype.getContentGroup = function() {
		return this._contentGroup;
	}, t.prototype.getSelectorGroup = function() {
		return this._selectorGroup;
	}, t.prototype.render = function(e, t, n) {
		var r = this._isFirstRender;
		if (this._isFirstRender = !1, this.resetInner(), e.get("show", !0)) {
			var i = e.get("align"), a = e.get("orient");
			(!i || i === "auto") && (i = e.get("left") === "right" && a === "vertical" ? "right" : "left");
			var o = e.get("selector", !0), s = e.get("selectorPosition", !0);
			o && (!s || s === "auto") && (s = a === "horizontal" ? "end" : "start"), this.renderInner(i, e, t, n, o, a, s);
			var c = Vg(e, n).refContainer, l = e.getBoxLayoutParams(), u = e.get("padding"), d = zg(l, c, u), f = this.layoutInner(e, i, d, r, o, s), p = zg(N({
				width: f.width,
				height: f.height
			}, l), c, u);
			this.group.x = p.x - f.x, this.group.y = p.y - f.y, this.group.markRedraw(), this.group.add(this._backgroundEl = vz(f, e));
		}
	}, t.prototype.resetInner = function() {
		this.getContentGroup().removeAll(), this._backgroundEl && this.group.remove(this._backgroundEl), this.getSelectorGroup().removeAll();
	}, t.prototype.renderInner = function(e, t, n, r, i, a, o) {
		var s = this.getContentGroup(), c = K(), l = t.get("selectedMode"), u = t.get("triggerEvent"), d = [];
		n.eachRawSeries(function(e) {
			!e.get("legendHoverLink") && d.push(e.id);
		}), QB(t.getData(), function(i, a) {
			var o = this, f = i.get("name");
			if (!this.newlineDisabled && (f === "" || f === "\n")) {
				var p = new $B();
				p.newline = !0, s.add(p);
			} else {
				var m = n.getSeriesByName(f)[0];
				if (!c.get(f)) {
					if (m) {
						var h = m.getData(), g = h.getVisual("legendLineStyle") || {}, _ = h.getVisual("legendIcon"), v = h.getVisual("style"), y = this._createItem(m, f, a, i, t, e, g, v, _, l, r);
						y.on("click", ZB(rV, f, null, r, d)).on("mouseover", ZB(iV, m.name, null, r, d)).on("mouseout", ZB(aV, m.name, null, r, d)), n.ssr && y.eachChild(function(e) {
							var t = Z(e);
							t.seriesIndex = m.seriesIndex, t.dataIndex = a, t.ssrType = "legend";
						}), u && y.eachChild(function(e) {
							o.packEventData(e, t, m, a, f);
						}), c.set(f, !0);
					} else n.eachRawSeries(function(o) {
						var s = this;
						if (!c.get(f) && o.legendVisualProvider) {
							var p = o.legendVisualProvider;
							if (!p.containName(f)) return;
							var m = p.indexOfName(f), h = p.getItemVisual(m, "style"), g = p.getItemVisual(m, "legendIcon"), _ = Vr(h.fill);
							_ && _[3] === 0 && (_[3] = .2, h = M(M({}, h), { fill: Qr(_, "rgba") }));
							var v = this._createItem(o, f, a, i, t, e, {}, h, g, l, r);
							v.on("click", ZB(rV, null, f, r, d)).on("mouseover", ZB(iV, null, f, r, d)).on("mouseout", ZB(aV, null, f, r, d)), n.ssr && v.eachChild(function(e) {
								var t = Z(e);
								t.seriesIndex = o.seriesIndex, t.dataIndex = a, t.ssrType = "legend";
							}), u && v.eachChild(function(e) {
								s.packEventData(e, t, o, a, f);
							}), c.set(f, !0);
						}
					}, this);
				}
			}
		}, this), i && this._createSelector(i, t, r, a, o);
	}, t.prototype.packEventData = function(e, t, n, r, i) {
		var a = {
			componentType: "legend",
			componentIndex: t.componentIndex,
			dataIndex: r,
			value: i,
			seriesIndex: n.seriesIndex
		};
		Z(e).eventData = a;
	}, t.prototype._createSelector = function(e, t, n, r, i) {
		var a = this.getSelectorGroup();
		QB(e, function(e) {
			var r = e.type, i = new Tu({
				style: {
					x: 0,
					y: 0,
					align: "center",
					verticalAlign: "middle"
				},
				onclick: function() {
					n.dispatchAction({
						type: r === "all" ? "legendAllSelect" : "legendInverseSelect",
						legendId: t.id
					});
				}
			});
			a.add(i), Nm(i, {
				normal: t.getModel("selectorLabel"),
				emphasis: t.getModel(["emphasis", "selectorLabel"])
			}, { defaultText: e.title }), Gd(i);
		});
	}, t.prototype._createItem = function(e, t, n, r, i, a, o, s, c, l, u) {
		var d = e.visualDrawType, f = i.get("itemWidth"), p = i.get("itemHeight"), m = i.isSelected(t), h = r.get("symbolRotate"), g = r.get("symbolKeepAspect"), _ = r.get("icon");
		c = _ || c || "roundRect";
		var v = tV(c, r, o, s, d, m, u), y = new $B(), b = r.getModel("textStyle");
		if (H(e.getLegendIcon) && (!_ || _ === "inherit")) y.add(e.getLegendIcon({
			itemWidth: f,
			itemHeight: p,
			icon: c,
			iconRotate: h,
			itemStyle: v.itemStyle,
			lineStyle: v.lineStyle,
			symbolKeepAspect: g
		}));
		else {
			var x = _ === "inherit" && e.getData().getVisual("symbol") ? h === "inherit" ? e.getData().getVisual("symbolRotate") : h : 0;
			y.add(nV({
				itemWidth: f,
				itemHeight: p,
				icon: c,
				iconRotate: x,
				itemStyle: v.itemStyle,
				lineStyle: v.lineStyle,
				symbolKeepAspect: g
			}));
		}
		var S = a === "left" ? f + 5 : -5, C = a, w = i.get("formatter"), T = t;
		U(w) && w ? T = w.replace("{name}", t ?? "") : H(w) && (T = w(t));
		var E = m ? b.getTextColor() : r.get("inactiveColor");
		y.add(new Tu({ style: Fm(b, {
			text: T,
			x: S,
			y: p / 2,
			fill: E,
			align: C,
			verticalAlign: "middle"
		}, { inheritColor: E }) }));
		var D = new bu({
			shape: y.getBoundingRect(),
			style: { fill: "transparent" }
		}), O = r.getModel("tooltip");
		return O.get("show") && hm({
			el: D,
			componentModel: i,
			itemName: t,
			itemTooltipOption: O.option
		}), y.add(D), y.eachChild(function(e) {
			e.silent = !0;
		}), D.silent = !l, this.getContentGroup().add(y), Gd(y), y.__legendDataIndex = n, y;
	}, t.prototype.layoutInner = function(e, t, n, r, i, a) {
		var o = this.getContentGroup(), s = this.getSelectorGroup();
		Fg(e.get("orient"), o, e.get("itemGap"), n.width, n.height);
		var c = o.getBoundingRect(), l = [-c.x, -c.y];
		if (s.markRedraw(), o.markRedraw(), i) {
			Fg("horizontal", s, e.get("selectorItemGap", !0));
			var u = s.getBoundingRect(), d = [-u.x, -u.y], f = e.get("selectorButtonGap", !0), p = e.getOrient().index, m = p === 0 ? "width" : "height", h = p === 0 ? "height" : "width", g = p === 0 ? "y" : "x";
			a === "end" ? d[p] += c[m] + f : l[p] += u[m] + f, d[1 - p] += c[h] / 2 - u[h] / 2, s.x = d[0], s.y = d[1], o.x = l[0], o.y = l[1];
			var _ = {
				x: 0,
				y: 0
			};
			return _[m] = c[m] + f + u[m], _[h] = Math.max(c[h], u[h]), _[g] = Math.min(0, u[g] + d[1 - p]), _;
		}
		return o.x = l[0], o.y = l[1], this.group.getBoundingRect();
	}, t.prototype.remove = function() {
		this.getContentGroup().removeAll(), this._isFirstRender = !0;
	}, t.type = "legend.plain", t;
}(rb);
function tV(e, t, n, r, i, a, o) {
	function s(e, t) {
		e.lineWidth === "auto" && (e.lineWidth = t.lineWidth > 0 ? 2 : 0), QB(e, function(n, r) {
			e[r] === "inherit" && (e[r] = t[r]);
		});
	}
	var c = t.getModel("itemStyle"), l = c.getItemStyle(), u = e.lastIndexOf("empty", 0) === 0 ? "fill" : "stroke", d = c.getShallow("decal");
	l.decal = !d || d === "inherit" ? r.decal : _S(d, o), l.fill === "inherit" && (l.fill = r[i]), l.stroke === "inherit" && (l.stroke = r[u]), l.opacity === "inherit" && (l.opacity = (i === "fill" ? r : n).opacity), s(l, r);
	var f = t.getModel("lineStyle"), p = f.getLineStyle();
	if (s(p, n), l.fill === "auto" && (l.fill = r.fill), l.stroke === "auto" && (l.stroke = r.fill), p.stroke === "auto" && (p.stroke = r.fill), !a) {
		var m = t.get("inactiveBorderWidth"), h = l[u];
		l.lineWidth = m === "auto" ? r.lineWidth > 0 && h ? 2 : 0 : l.lineWidth, l.fill = t.get("inactiveColor"), l.stroke = t.get("inactiveBorderColor"), p.stroke = f.get("inactiveColor"), p.lineWidth = f.get("inactiveWidth");
	}
	return {
		itemStyle: l,
		lineStyle: p
	};
}
function nV(e) {
	var t = e.icon || "roundRect", n = Ox(t, 0, 0, e.itemWidth, e.itemHeight, e.itemStyle.fill, e.symbolKeepAspect);
	return n.setStyle(e.itemStyle), n.rotation = (e.iconRotate || 0) * Math.PI / 180, n.setOrigin([e.itemWidth / 2, e.itemHeight / 2]), t.indexOf("empty") > -1 && (n.style.stroke = n.style.fill, n.style.fill = Q.color.neutral00, n.style.lineWidth = 2), n;
}
function rV(e, t, n, r) {
	aV(e, t, n, r), n.dispatchAction({
		type: "legendToggleSelect",
		name: e ?? t
	}), iV(e, t, n, r);
}
function iV(e, t, n, r) {
	n.usingTHL() || n.dispatchAction({
		type: "highlight",
		seriesName: e,
		name: t,
		excludeSeriesId: r
	});
}
function aV(e, t, n, r) {
	n.usingTHL() || n.dispatchAction({
		type: "downplay",
		seriesName: e,
		name: t,
		excludeSeriesId: r
	});
}
//#endregion
//#region node_modules/echarts/lib/component/legend/legendAction.js
function oV(e, t, n) {
	var r = e === "allSelect" || e === "inverseSelect", i = {}, a = [];
	n.eachComponent({
		mainType: "legend",
		query: t
	}, function(n) {
		r ? n[e]() : n[e](t.name), sV(n, i), a.push(n.componentIndex);
	});
	var o = {};
	return n.eachComponent("legend", function(e) {
		I(i, function(t, n) {
			e[t ? "select" : "unSelect"](n);
		}), sV(e, o);
	}), r ? {
		selected: o,
		legendIndex: a
	} : {
		name: t.name,
		selected: o
	};
}
function sV(e, t) {
	var n = t || {};
	return I(e.getData(), function(t) {
		var r = t.get("name");
		if (r !== "\n" && r !== "") {
			var i = e.isSelected(r);
			n[r] = q(n, r) ? n[r] && i : i;
		}
	}), n;
}
function cV(e) {
	e.registerAction("legendToggleSelect", "legendselectchanged", B(oV, "toggleSelected")), e.registerAction("legendAllSelect", "legendselectall", B(oV, "allSelect")), e.registerAction("legendInverseSelect", "legendinverseselect", B(oV, "inverseSelect")), e.registerAction("legendSelect", "legendselected", B(oV, "select")), e.registerAction("legendUnSelect", "legendunselected", B(oV, "unSelect"));
}
//#endregion
//#region node_modules/echarts/lib/component/legend/legendFilter.js
var lV = nc(uV);
function uV(e) {
	var t = e.findComponents({ mainType: "legend" });
	t && t.length && e.filterSeries(function(e) {
		for (var n = 0; n < t.length; n++) if (!t[n].isSelected(e.name)) return !1;
		return !0;
	});
}
//#endregion
//#region node_modules/echarts/lib/component/legend/installLegendPlain.js
function dV(e) {
	e.registerComponentModel(XB), e.registerComponentView(eV), e.registerProcessor(e.PRIORITY.PROCESSOR.SERIES_FILTER, lV), e.registerSubTypeDefaulter("legend", function() {
		return "plain";
	}), cV(e);
}
//#endregion
//#region node_modules/echarts/lib/component/legend/ScrollableLegendModel.js
var fV = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.setScrollDataIndex = function(e) {
		this.option.scrollDataIndex = e;
	}, t.prototype.init = function(t, n, r) {
		var i = Gg(t);
		e.prototype.init.call(this, t, n, r), pV(this, t, i);
	}, t.prototype.mergeOption = function(t, n) {
		e.prototype.mergeOption.call(this, t, n), pV(this, this.option, t);
	}, t.type = "legend.scroll", t.defaultOption = lh(XB.defaultOption, {
		scrollDataIndex: 0,
		pageButtonItemGap: 5,
		pageButtonGap: null,
		pageButtonPosition: "end",
		pageFormatter: "{current}/{total}",
		pageIcons: {
			horizontal: ["M0,0L12,-10L12,10z", "M0,0L-12,-10L-12,10z"],
			vertical: ["M0,0L20,0L10,-20z", "M0,0L20,0L10,20z"]
		},
		pageIconColor: Q.color.accent50,
		pageIconInactiveColor: Q.color.accent10,
		pageIconSize: 15,
		pageTextStyle: { color: Q.color.tertiary },
		animationDurationUpdate: 800
	}), t;
}(XB);
function pV(e, t, n) {
	var r = e.getOrient(), i = [1, 1];
	i[r.index] = 0, Wg(t, n, {
		type: "box",
		ignoreSize: !!i
	});
}
//#endregion
//#region node_modules/echarts/lib/component/legend/ScrollableLegendView.js
var mV = Wa, hV = ["width", "height"], gV = ["x", "y"], _V = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.newlineDisabled = !0, n._currentIndex = 0, n;
	}
	return t.prototype.init = function() {
		e.prototype.init.call(this), this.group.add(this._containerGroup = new mV()), this._containerGroup.add(this.getContentGroup()), this.group.add(this._controllerGroup = new mV());
	}, t.prototype.resetInner = function() {
		e.prototype.resetInner.call(this), this._controllerGroup.removeAll(), this._containerGroup.removeClipPath(), this._containerGroup.__rectSize = null;
	}, t.prototype.renderInner = function(t, n, r, i, a, o, s) {
		var c = this;
		e.prototype.renderInner.call(this, t, n, r, i, a, o, s);
		var l = this._controllerGroup, u = n.get("pageIconSize", !0), d = V(u) ? u : [u, u];
		p("pagePrev", 0);
		var f = n.getModel("pageTextStyle");
		l.add(new Tu({
			name: "pageText",
			style: {
				text: "xx/xx",
				fill: f.getTextColor(),
				font: f.getFont(),
				verticalAlign: "middle",
				align: "center"
			},
			silent: !0
		})), p("pageNext", 1);
		function p(e, t) {
			var r = e + "DataIndex", a = sm(n.get("pageIcons", !0)[n.getOrient().name][t], { onclick: z(c._pageGo, c, r, n, i) }, {
				x: -d[0] / 2,
				y: -d[1] / 2,
				width: d[0],
				height: d[1]
			});
			a.name = e, l.add(a);
		}
	}, t.prototype.layoutInner = function(e, t, n, r, i, a) {
		var o = this.getSelectorGroup(), s = e.getOrient().index, c = hV[s], l = gV[s], u = hV[1 - s], d = gV[1 - s];
		i && Fg("horizontal", o, e.get("selectorItemGap", !0));
		var f = e.get("selectorButtonGap", !0), p = o.getBoundingRect(), m = [-p.x, -p.y], h = A(n);
		i && (h[c] = n[c] - p[c] - f);
		var g = this._layoutContentAndController(e, r, h, s, c, u, d, l);
		if (i) {
			if (a === "end") m[s] += g[c] + f;
			else {
				var _ = p[c] + f;
				m[s] -= _, g[l] -= _;
			}
			g[c] += p[c] + f, m[1 - s] += g[d] + g[u] / 2 - p[u] / 2, g[u] = Math.max(g[u], p[u]), g[d] = Math.min(g[d], p[d] + m[1 - s]), o.x = m[0], o.y = m[1], o.markRedraw();
		}
		return g;
	}, t.prototype._layoutContentAndController = function(e, t, n, r, i, a, o, s) {
		var c = this.getContentGroup(), l = this._containerGroup, u = this._controllerGroup;
		Fg(e.get("orient"), c, e.get("itemGap"), r ? n.width : null, r ? null : n.height), Fg("horizontal", u, e.get("pageButtonItemGap", !0));
		var d = c.getBoundingRect(), f = u.getBoundingRect(), p = this._showController = d[i] > n[i], m = [-d.x, -d.y];
		t || (m[r] = c[s]);
		var h = [0, 0], g = [-f.x, -f.y], _ = G(e.get("pageButtonGap", !0), e.get("itemGap", !0));
		p && (e.get("pageButtonPosition", !0) === "end" ? g[r] += n[i] - f[i] : h[r] += f[i] + _), g[1 - r] += d[a] / 2 - f[a] / 2, c.setPosition(m), l.setPosition(h), u.setPosition(g);
		var v = {
			x: 0,
			y: 0
		};
		if (v[i] = p ? n[i] : d[i], v[a] = Math.max(d[a], f[a]), v[o] = Math.min(0, f[o] + g[1 - r]), l.__rectSize = n[i], p) {
			var y = {
				x: 0,
				y: 0
			};
			y[i] = Math.max(n[i] - f[i] - _, 0), y[a] = v[a], l.setClipPath(new bu({ shape: y })), l.__rectSize = y[i];
		} else u.eachChild(function(e) {
			e.attr({
				invisible: !0,
				silent: !0
			});
		});
		var b = this._getPageInfo(e);
		return b.pageIndex != null && kp(c, {
			x: b.contentPosition[0],
			y: b.contentPosition[1]
		}, p ? e : null), this._updatePageInfoView(e, b), v;
	}, t.prototype._pageGo = function(e, t, n) {
		var r = this._getPageInfo(t)[e];
		r != null && n.dispatchAction({
			type: "legendScroll",
			scrollDataIndex: r,
			legendId: t.id
		});
	}, t.prototype._updatePageInfoView = function(e, t) {
		var n = this._controllerGroup;
		I(["pagePrev", "pageNext"], function(r) {
			var i = t[r + "DataIndex"] != null, a = n.childOfName(r);
			a && (a.setStyle("fill", i ? e.get("pageIconColor", !0) : e.get("pageIconInactiveColor", !0)), a.cursor = i ? "pointer" : "default");
		});
		var r = n.childOfName("pageText"), i = e.get("pageFormatter"), a = t.pageIndex, o = a == null ? 0 : a + 1, s = t.pageCount;
		r && i && r.setStyle("text", U(i) ? i.replace("{current}", o == null ? "" : o + "").replace("{total}", s == null ? "" : s + "") : i({
			current: o,
			total: s
		}));
	}, t.prototype._getPageInfo = function(e) {
		var t = e.get("scrollDataIndex", !0), n = this.getContentGroup(), r = this._containerGroup.__rectSize, i = e.getOrient().index, a = hV[i], o = gV[i], s = this._findTargetItemIndex(t), c = n.children(), l = c[s], u = c.length, d = +!!u, f = {
			contentPosition: [n.x, n.y],
			pageCount: d,
			pageIndex: d - 1,
			pagePrevDataIndex: null,
			pageNextDataIndex: null
		};
		if (!l) return f;
		var p = v(l);
		f.contentPosition[i] = -p.s;
		for (var m = s + 1, h = p, g = p, _ = null; m <= u; ++m) _ = v(c[m]), (!_ && g.e > h.s + r || _ && !y(_, h.s)) && (h = g.i > h.i ? g : _, h && (f.pageNextDataIndex ??= h.i, ++f.pageCount)), g = _;
		for (var m = s - 1, h = p, g = p, _ = null; m >= -1; --m) _ = v(c[m]), (!_ || !y(g, _.s)) && h.i < g.i && (g = h, f.pagePrevDataIndex ??= h.i, ++f.pageCount, ++f.pageIndex), h = _;
		return f;
		function v(e) {
			if (e) {
				var t = e.getBoundingRect(), n = t[o] + e[o];
				return {
					s: n,
					e: n + t[a],
					i: e.__legendDataIndex
				};
			}
		}
		function y(e, t) {
			return e.e >= t && e.s <= t + r;
		}
	}, t.prototype._findTargetItemIndex = function(e) {
		if (!this._showController) return 0;
		var t, n = this.getContentGroup(), r;
		return n.eachChild(function(n, i) {
			var a = n.__legendDataIndex;
			r == null && a != null && (r = i), a === e && (t = i);
		}), t ?? r;
	}, t.type = "legend.scroll", t;
}(eV);
//#endregion
//#region node_modules/echarts/lib/component/legend/scrollableLegendAction.js
function vV(e) {
	e.registerAction("legendScroll", "legendscroll", function(e, t) {
		var n = e.scrollDataIndex;
		n != null && t.eachComponent({
			mainType: "legend",
			subType: "scroll",
			query: e
		}, function(e) {
			e.setScrollDataIndex(n);
		});
	});
}
//#endregion
//#region node_modules/echarts/lib/component/legend/installLegendScroll.js
function yV(e) {
	TD(dV), e.registerComponentModel(fV), e.registerComponentView(_V), vV(e);
}
//#endregion
//#region node_modules/echarts/lib/component/legend/install.js
function bV(e) {
	TD(dV), TD(yV);
}
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/InsideZoomModel.js
var xV = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.type = "dataZoom.inside", t.defaultOption = lh(uz.defaultOption, {
		disabled: !1,
		zoomLock: !1,
		zoomOnMouseWheel: !0,
		moveOnMouseMove: !0,
		moveOnMouseWheel: !1,
		preventDefaultMouseMove: !0
	}), t;
}(uz), SV = X();
function CV(e, t, n) {
	SV(e).coordSysRecordMap.each(function(e) {
		var r = e.dataZoomInfoMap.get(t.uid);
		r && (r.getRange = n);
	});
}
function wV(e, t) {
	for (var n = SV(e).coordSysRecordMap, r = n.keys(), i = 0; i < r.length; i++) {
		var a = r[i], o = n.get(a), s = o.dataZoomInfoMap;
		if (s) {
			var c = t.uid;
			s.get(c) && (s.removeKey(c), s.keys().length || TV(n, o));
		}
	}
}
function TV(e, t) {
	if (t) {
		e.removeKey(t.model.uid);
		var n = t.controller;
		n && n.dispose();
	}
}
function EV(e, t) {
	var n = {
		model: t,
		containsPoint: B(OV, t),
		dispatchAction: B(DV, e),
		dataZoomInfoMap: null,
		controller: null
	}, r = n.controller = new nP(e.getZr());
	return I([
		"pan",
		"zoom",
		"scrollMove"
	], function(e) {
		r.on(e, function(t) {
			var r = [];
			n.dataZoomInfoMap.each(function(i) {
				if (t.isAvailableBehavior(i.model.option)) {
					var a = (i.getRange || {})[e], o = a && a(i.dzReferCoordSysInfo, n.model.mainType, n.controller, t);
					!i.model.get("disabled", !0) && o && r.push({
						dataZoomId: i.model.id,
						start: o[0],
						end: o[1]
					});
				}
			}), r.length && n.dispatchAction(r);
		});
	}), n;
}
function DV(e, t) {
	e.isDisposed() || e.dispatchAction({
		type: "dataZoom",
		animation: {
			easing: "cubicOut",
			duration: 100
		},
		batch: t
	});
}
function OV(e, t, n, r) {
	return e.coordinateSystem.containPoint([n, r]);
}
function kV(e, t, n) {
	var r, i = "type_", a = {
		type_true: 2,
		type_move: 1,
		type_false: 0,
		type_undefined: -1
	}, o = !0, s, c;
	return e.each(function(e) {
		var t = e.model, n = t.get("disabled", !0) ? !1 : !t.get("zoomLock", !0) || "move";
		a[i + n] > a[i + r] && (r = n), o &&= t.get("preventDefaultMouseMove", !0), s = G(t.get("cursorGrab", !0), s), c = G(t.get("cursorGrabbing", !0), c);
	}), {
		controlType: r,
		opt: {
			zoomOnMouseWheel: !0,
			moveOnMouseMove: !0,
			moveOnMouseWheel: !0,
			preventDefaultMouseMove: !!o,
			api: n,
			zInfo: { component: t.model },
			triggerInfo: {
				roamTrigger: null,
				isInSelf: t.containsPoint
			},
			cursorGrab: s,
			cursorGrabbing: c
		}
	};
}
function AV(e) {
	e.registerUpdateLifecycle("coordsys:aftercreate", function(e, t) {
		var n = SV(t), r = n.coordSysRecordMap ||= K();
		r.each(function(e) {
			e.dataZoomInfoMap = null;
		}), e.eachComponent({
			mainType: "dataZoom",
			subType: "inside"
		}, function(e) {
			I(iz(e).infoList, function(n) {
				var i = n.model.uid, a = r.get(i) || r.set(i, EV(t, n.model));
				(a.dataZoomInfoMap ||= K()).set(e.uid, {
					dzReferCoordSysInfo: n,
					model: e,
					getRange: null
				});
			});
		}), r.each(function(e) {
			var n = e.controller, i, a = e.dataZoomInfoMap;
			if (a) {
				var o = a.keys()[0];
				o != null && (i = a.get(o));
			}
			if (!i) TV(r, e);
			else {
				var s = kV(a, e, t);
				n.enable(s.controlType, s.opt), _b(e, "dispatchAction", i.model.get("throttle", !0), "fixRate");
			}
		});
	});
}
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/InsideZoomView.js
var jV = function(e) {
	n(t, e);
	function t() {
		var t = e !== null && e.apply(this, arguments) || this;
		return t.type = "dataZoom.inside", t;
	}
	return t.prototype.render = function(t, n, r) {
		e.prototype.render.apply(this, arguments), t.noTarget() ? this._clear() : (this.range = t.getPercentRange(), CV(r, t, {
			pan: z(MV.pan, this),
			zoom: z(MV.zoom, this),
			scrollMove: z(MV.scrollMove, this)
		}));
	}, t.prototype.dispose = function() {
		this._clear(), e.prototype.dispose.apply(this, arguments);
	}, t.prototype._clear = function() {
		wV(this.api, this.dataZoomModel), this.range = null;
	}, t.type = "dataZoom.inside", t;
}(fz), MV = {
	zoom: function(e, t, n, r) {
		var i = this.range, a = i.slice(), o = e.axisModels[0];
		if (o) {
			var s = PV[t](null, [r.originX, r.originY], o, n, e), c = (s.signal > 0 ? s.pixelStart + s.pixelLength - s.pixel : s.pixel - s.pixelStart) / s.pixelLength * (a[1] - a[0]) + a[0], l = Math.max(1 / r.scale, 0);
			a[0] = (a[0] - c) * l + c, a[1] = (a[1] - c) * l + c;
			var u = this.dataZoomModel.findRepresentativeAxisProxy().getMinMaxSpan();
			if (wI(0, a, [0, 100], 0, u.minSpan, u.maxSpan), this.range = a, i[0] !== a[0] || i[1] !== a[1]) return a;
		}
	},
	pan: NV(function(e, t, n, r, i, a) {
		var o = PV[r]([a.oldX, a.oldY], [a.newX, a.newY], t, i, n);
		return o.signal * (e[1] - e[0]) * o.pixel / o.pixelLength;
	}),
	scrollMove: NV(function(e, t, n, r, i, a) {
		return PV[r]([0, 0], [a.scrollDelta, a.scrollDelta], t, i, n).signal * (e[1] - e[0]) * a.scrollDelta;
	})
};
function NV(e) {
	return function(t, n, r, i) {
		var a = this.range, o = a.slice(), s = t.axisModels[0];
		if (s && (wI(e(o, s, t, n, r, i), o, [0, 100], "all"), this.range = o, a[0] !== o[0] || a[1] !== o[1])) return o;
	};
}
var PV = {
	grid: function(e, t, n, r, i) {
		var a = n.axis, o = {}, s = i.model.coordinateSystem.getRect();
		return e ||= [0, 0], a.dim === "x" ? (o.pixel = t[0] - e[0], o.pixelLength = s.width, o.pixelStart = s.x, o.signal = a.inverse ? 1 : -1) : (o.pixel = t[1] - e[1], o.pixelLength = s.height, o.pixelStart = s.y, o.signal = a.inverse ? -1 : 1), o;
	},
	polar: function(e, t, n, r, i) {
		var a = n.axis, o = {}, s = i.model.coordinateSystem, c = s.getRadiusAxis().getExtent(), l = s.getAngleAxis().getExtent();
		return e = e ? s.pointToCoord(e) : [0, 0], t = s.pointToCoord(t), n.mainType === "radiusAxis" ? (o.pixel = t[0] - e[0], o.pixelLength = c[1] - c[0], o.pixelStart = c[0], o.signal = a.inverse ? 1 : -1) : (o.pixel = t[1] - e[1], o.pixelLength = l[1] - l[0], o.pixelStart = l[0], o.signal = a.inverse ? -1 : 1), o;
	},
	singleAxis: function(e, t, n, r, i) {
		var a = n.axis, o = i.model.coordinateSystem.getRect(), s = {};
		return e ||= [0, 0], a.orient === "horizontal" ? (s.pixel = t[0] - e[0], s.pixelLength = o.width, s.pixelStart = o.x, s.signal = a.inverse ? 1 : -1) : (s.pixel = t[1] - e[1], s.pixelLength = o.height, s.pixelStart = o.y, s.signal = a.inverse ? -1 : 1), s;
	}
};
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/installDataZoomInside.js
function FV(e) {
	_z(e), e.registerComponentModel(xV), e.registerComponentView(jV), AV(e);
}
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/SliderZoomModel.js
var IV = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.type = "dataZoom.slider", t.layoutMode = "box", t.defaultOption = lh(uz.defaultOption, {
		show: !0,
		right: "ph",
		top: "ph",
		width: "ph",
		height: "ph",
		left: null,
		bottom: null,
		borderColor: Q.color.accent10,
		borderRadius: 0,
		backgroundColor: Q.color.transparent,
		dataBackground: {
			lineStyle: {
				color: Q.color.accent30,
				width: .5
			},
			areaStyle: {
				color: Q.color.accent20,
				opacity: .2
			}
		},
		selectedDataBackground: {
			lineStyle: {
				color: Q.color.accent40,
				width: .5
			},
			areaStyle: {
				color: Q.color.accent20,
				opacity: .3
			}
		},
		fillerColor: "rgba(135,175,274,0.2)",
		handleIcon: "path://M-9.35,34.56V42m0-40V9.5m-2,0h4a2,2,0,0,1,2,2v21a2,2,0,0,1-2,2h-4a2,2,0,0,1-2-2v-21A2,2,0,0,1-11.35,9.5Z",
		handleSize: "100%",
		handleStyle: {
			color: Q.color.neutral00,
			borderColor: Q.color.accent20
		},
		moveHandleSize: 7,
		moveHandleIcon: "path://M-320.9-50L-320.9-50c18.1,0,27.1,9,27.1,27.1V85.7c0,18.1-9,27.1-27.1,27.1l0,0c-18.1,0-27.1-9-27.1-27.1V-22.9C-348-41-339-50-320.9-50z M-212.3-50L-212.3-50c18.1,0,27.1,9,27.1,27.1V85.7c0,18.1-9,27.1-27.1,27.1l0,0c-18.1,0-27.1-9-27.1-27.1V-22.9C-239.4-41-230.4-50-212.3-50z M-103.7-50L-103.7-50c18.1,0,27.1,9,27.1,27.1V85.7c0,18.1-9,27.1-27.1,27.1l0,0c-18.1,0-27.1-9-27.1-27.1V-22.9C-130.9-41-121.8-50-103.7-50z",
		moveHandleStyle: {
			color: Q.color.accent40,
			opacity: .5
		},
		showDetail: !0,
		showDataShadow: "auto",
		realtime: !0,
		zoomLock: !1,
		textStyle: { color: Q.color.tertiary },
		brushSelect: !0,
		brushStyle: {
			color: Q.color.accent30,
			opacity: .3
		},
		emphasis: {
			handleLabel: { show: !0 },
			handleStyle: { borderColor: Q.color.accent40 },
			moveHandleStyle: { opacity: .8 }
		},
		defaultLocationEdgeGap: 15
	}), t;
}(uz), LV = bu, RV = 1, zV = 30, BV = 7, VV = "horizontal", HV = "vertical", UV = 5, WV = [
	"line",
	"bar",
	"candlestick",
	"scatter"
], GV = {
	easing: "cubicOut",
	duration: 100,
	delay: 0
}, KV = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n._displayables = {}, n;
	}
	return t.prototype.init = function(e, t) {
		this.api = t, this._onBrush = z(this._onBrush, this), this._onBrushEnd = z(this._onBrushEnd, this);
	}, t.prototype.render = function(t, n, r, i) {
		e.prototype.render.apply(this, arguments), _b(this, "_dispatchZoomAction", t.get("throttle"), "fixRate"), this._orient = t.getOrient(), t.get("show") === !1 ? this.group.removeAll() : t.noTarget() ? (this._clear(), this.group.removeAll()) : ((!i || i.type !== "dataZoom" || i.from !== this.uid) && this._buildView(), this._updateView());
	}, t.prototype.dispose = function() {
		this._clear(), e.prototype.dispose.apply(this, arguments);
	}, t.prototype._clear = function() {
		vb(this, "_dispatchZoomAction");
		var e = this.api.getZr();
		e.off("mousemove", this._onBrush), e.off("mouseup", this._onBrushEnd);
	}, t.prototype._buildView = function() {
		var e = this.group;
		e.removeAll(), this._brushing = !1, this._displayables.brushRect = null, this._resetLocation(), this._resetInterval();
		var t = this._displayables.sliderGroup = new Wa();
		this._renderBackground(), this._renderHandle(), this._renderDataShadow(), e.add(t), this._positionGroup();
	}, t.prototype._resetLocation = function() {
		var e = this.dataZoomModel, t = this.api, n = e.get("brushSelect") ? BV : 0, r = Vg(e, t).refContainer, i = this._findCoordRect(), a = e.get("defaultLocationEdgeGap", !0) || 0, o = this._orient === VV ? {
			right: r.width - i.x - i.width,
			top: r.height - zV - a - n,
			width: i.width,
			height: zV
		} : {
			right: a,
			top: i.y,
			width: zV,
			height: i.height
		}, s = Gg(e.option);
		I([
			"right",
			"top",
			"width",
			"height"
		], function(e) {
			s[e] === "ph" && (s[e] = o[e]);
		});
		var c = zg(s, r);
		this._location = {
			x: c.x,
			y: c.y
		}, this._size = [c.width, c.height], this._orient === HV && this._size.reverse();
	}, t.prototype._positionGroup = function() {
		var e = this.group, t = this._location, n = this._orient, r = this.dataZoomModel.getFirstTargetAxisModel(), i = r && r.get("inverse"), a = this._displayables.sliderGroup, o = (this._dataShadowInfo || {}).otherAxisInverse;
		a.attr(n === VV && !i ? {
			scaleY: o ? 1 : -1,
			scaleX: 1
		} : n === VV && i ? {
			scaleY: o ? 1 : -1,
			scaleX: -1
		} : n === HV && !i ? {
			scaleY: o ? -1 : 1,
			scaleX: 1,
			rotation: Math.PI / 2
		} : {
			scaleY: o ? -1 : 1,
			scaleX: -1,
			rotation: Math.PI / 2
		});
		var s = e.getBoundingRect([a]), c = isNaN(s.x) ? 0 : s.x, l = isNaN(s.y) ? 0 : s.y;
		e.x = t.x - c, e.y = t.y - l, e.markRedraw();
	}, t.prototype._getViewExtent = function() {
		return [0, this._size[0]];
	}, t.prototype._renderBackground = function() {
		var e = this.dataZoomModel, t = this._size, n = this._displayables.sliderGroup, r = e.get("brushSelect");
		n.add(new LV({
			silent: !0,
			shape: {
				x: 0,
				y: 0,
				width: t[0],
				height: t[1]
			},
			style: { fill: e.get("backgroundColor") },
			z2: -40
		}));
		var i = new LV({
			shape: {
				x: 0,
				y: 0,
				width: t[0],
				height: t[1]
			},
			style: { fill: "transparent" },
			z2: 0,
			onclick: z(this._onClickPanel, this)
		}), a = this.api.getZr();
		r ? (i.on("mousedown", this._onBrushStart, this), i.cursor = "crosshair", a.on("mousemove", this._onBrush), a.on("mouseup", this._onBrushEnd)) : (a.off("mousemove", this._onBrush), a.off("mouseup", this._onBrushEnd)), n.add(i);
	}, t.prototype._renderDataShadow = function() {
		var e = this._dataShadowInfo = this._prepareDataShadowInfo();
		if (this._displayables.dataShadowSegs = [], !e) return;
		var t = this._size, n = this._shadowSize || [], r = e.series, i = r.getRawData(), a = r.getShadowDim && r.getShadowDim(), o = a && i.getDimensionInfo(a) ? r.getShadowDim() : e.otherDim;
		if (o == null) return;
		var s = this._shadowPolygonPts, c = this._shadowPolylinePts;
		if (i !== this._shadowData || o !== this._shadowDim || t[0] !== n[0] || t[1] !== n[1]) {
			var l = i.getDataExtent(e.thisDim), u = i.getDataExtent(o), d = (u[1] - u[0]) * .3;
			u = [u[0] - d, u[1] + d];
			var f = [0, t[1]], p = [0, t[0]], m = [[t[0], 0], [0, 0]], h = [], g = p[1] / Math.max(1, i.count() - 1), _ = t[0] / (l[1] - l[0]), v = e.thisAxis.type === "time", y = -g, b = Math.round(i.count() / t[0]), x;
			i.each([e.thisDim, o], function(e, t, n) {
				if (b > 0 && n % b) v || (y += g);
				else {
					y = v ? (+e - l[0]) * _ : y + g;
					var r = t == null || isNaN(t) || t === "", i = r ? 0 : xo(t, u, f, !0);
					r && !x && n ? (m.push([m[m.length - 1][0], 0]), h.push([h[h.length - 1][0], 0])) : !r && x && (m.push([y, 0]), h.push([y, 0])), r || (m.push([y, i]), h.push([y, i])), x = r;
				}
			}), s = this._shadowPolygonPts = m, c = this._shadowPolylinePts = h;
		}
		this._shadowData = i, this._shadowDim = o, this._shadowSize = [t[0], t[1]];
		var S = this.dataZoomModel;
		function C(e) {
			var t = S.getModel(e ? "selectedDataBackground" : "dataBackground"), n = new Wa(), r = new $f({
				shape: { points: s },
				segmentIgnoreThreshold: 1,
				style: t.getModel("areaStyle").getAreaStyle(),
				silent: !0,
				z2: -20
			}), i = new tp({
				shape: { points: c },
				segmentIgnoreThreshold: 1,
				style: t.getModel("lineStyle").getLineStyle(),
				silent: !0,
				z2: -19
			});
			return n.add(r), n.add(i), n;
		}
		for (var w = 0; w < 3; w++) {
			var T = C(w === 1);
			this._displayables.sliderGroup.add(T), this._displayables.dataShadowSegs.push(T);
		}
	}, t.prototype._prepareDataShadowInfo = function() {
		var e = this.dataZoomModel, t = e.get("showDataShadow");
		if (t !== !1) {
			var n, r = this.ecModel;
			return e.eachTargetAxis(function(i, a) {
				I(e.getAxisProxy(i, a).getTargetSeriesModels(), function(e) {
					if (!n && !(t !== !0 && P(WV, e.get("type")) < 0)) {
						var o = r.getComponent(nz(i), a).axis, s = JV(i), c, l = e.coordinateSystem;
						s != null && l.getOtherAxis && (c = l.getOtherAxis(o).inverse), s = e.getData().mapDimension(s), n = {
							thisAxis: o,
							series: e,
							thisDim: e.getData().mapDimension(i),
							otherDim: s,
							otherAxisInverse: c
						};
					}
				}, this);
			}, this), n;
		}
	}, t.prototype._renderHandle = function() {
		var e = this.group, t = this._displayables, n = t.handles = [null, null], r = t.handleLabels = [null, null], i = this._displayables.sliderGroup, a = this._size, o = this.dataZoomModel, s = this.api, c = o.get("borderRadius") || 0, l = o.get("brushSelect"), u = t.filler = new LV({
			silent: l,
			style: { fill: o.get("fillerColor") },
			textConfig: { position: "inside" }
		});
		i.add(u), i.add(new LV({
			silent: !0,
			subPixelOptimize: !0,
			shape: {
				x: 0,
				y: 0,
				width: a[0],
				height: a[1],
				r: c
			},
			style: {
				stroke: o.get("dataBackgroundColor") || o.get("borderColor"),
				lineWidth: RV,
				fill: Q.color.transparent
			}
		})), I([0, 1], function(t) {
			var a = o.get("handleIcon");
			!Tx[a] && a.indexOf("path://") < 0 && a.indexOf("image://") < 0 && (a = "path://" + a);
			var s = Ox(a, -1, 0, 2, 2, null, !0);
			s.attr({
				cursor: YV(this._orient),
				draggable: !0,
				drift: z(this._onDragMove, this, t),
				ondragend: z(this._onDragEnd, this),
				onmouseover: z(this._onOverDataInfoTriggerArea, this, !0),
				onmouseout: z(this._onOverDataInfoTriggerArea, this, !1),
				z2: 5
			});
			var c = s.getBoundingRect(), l = o.get("handleSize");
			this._handleHeight = So(l, this._size[1]), this._handleWidth = c.width / c.height * this._handleHeight, s.setStyle(o.getModel("handleStyle").getItemStyle()), s.style.strokeNoScale = !0, s.rectHover = !0, s.ensureState("emphasis").style = o.getModel(["emphasis", "handleStyle"]).getItemStyle(), Gd(s);
			var u = o.get("handleColor");
			u != null && (s.style.fill = u), i.add(n[t] = s);
			var d = o.getModel("textStyle"), f = (o.get("handleLabel") || {}).show || !1;
			e.add(r[t] = new Tu({
				silent: !0,
				invisible: !f,
				style: Fm(d, {
					x: 0,
					y: 0,
					text: "",
					verticalAlign: "middle",
					align: "center",
					fill: d.getTextColor(),
					font: d.getFont()
				}),
				z2: 10
			}));
		}, this);
		var d = u;
		if (l) {
			var f = So(o.get("moveHandleSize"), a[1]), p = t.moveHandle = new bu({
				style: o.getModel("moveHandleStyle").getItemStyle(),
				silent: !0,
				shape: {
					r: [
						0,
						0,
						2,
						2
					],
					y: a[1] - .5,
					height: f
				}
			}), m = f * .8, h = t.moveHandleIcon = Ox(o.get("moveHandleIcon"), -m / 2, -m / 2, m, m, Q.color.neutral00, !0);
			h.silent = !0, h.y = a[1] + f / 2 - .5, p.ensureState("emphasis").style = o.getModel(["emphasis", "moveHandleStyle"]).getItemStyle();
			var g = Math.min(a[1] / 2, Math.max(f, 10));
			d = t.moveZone = new bu({
				invisible: !0,
				shape: {
					y: a[1] - g,
					height: f + g
				}
			}), d.on("mouseover", function() {
				s.enterEmphasis(p);
			}).on("mouseout", function() {
				s.leaveEmphasis(p);
			}), i.add(p), i.add(h), i.add(d);
		}
		d.attr({
			draggable: !0,
			cursor: "grab",
			drift: z(this._onActualMoveZoneDrift, this),
			ondragstart: z(this._onActualMoveZoneDragStart, this),
			ondragend: z(this._onActualMoveZoneDragEnd, this),
			onmouseover: z(this._onOverDataInfoTriggerArea, this, !0),
			onmouseout: z(this._onOverDataInfoTriggerArea, this, !1)
		});
	}, t.prototype._resetInterval = function() {
		var e = this._range = this.dataZoomModel.getPercentRange(), t = this._getViewExtent();
		this._handleEnds = [xo(e[0], [0, 100], t, !0), xo(e[1], [0, 100], t, !0)];
	}, t.prototype._updateInterval = function(e, t) {
		var n = this.dataZoomModel, r = this._handleEnds, i = this._getViewExtent(), a = n.findRepresentativeAxisProxy().getMinMaxSpan(), o = [0, 100];
		wI(t, r, i, n.get("zoomLock") ? "all" : e, a.minSpan == null ? null : xo(a.minSpan, o, i, !0), a.maxSpan == null ? null : xo(a.maxSpan, o, i, !0));
		var s = this._range, c = this._range = Oo([xo(r[0], i, o, !0), xo(r[1], i, o, !0)]);
		return !s || s[0] !== c[0] || s[1] !== c[1];
	}, t.prototype._updateView = function(e) {
		var t = this._displayables, n = this._handleEnds, r = Oo(n.slice()), i = this._size;
		I([0, 1], function(e) {
			var r = t.handles[e], a = this._handleHeight;
			r.attr({
				scaleX: a / 2,
				scaleY: a / 2,
				x: n[e] + (e ? -1 : 1),
				y: i[1] / 2 - a / 2
			});
		}, this), t.filler.setShape({
			x: r[0],
			y: 0,
			width: r[1] - r[0],
			height: i[1]
		});
		var a = {
			x: r[0],
			width: r[1] - r[0]
		};
		t.moveHandle && (t.moveHandle.setShape(a), t.moveZone.setShape(a), t.moveZone.getBoundingRect(), t.moveHandleIcon && t.moveHandleIcon.attr("x", a.x + a.width / 2));
		for (var o = t.dataShadowSegs, s = [
			0,
			r[0],
			r[1],
			i[0]
		], c = 0; c < o.length; c++) {
			var l = o[c], u = l.getClipPath();
			u || (u = new bu(), l.setClipPath(u)), u.setShape({
				x: s[c],
				y: 0,
				width: s[c + 1] - s[c],
				height: i[1]
			});
		}
		this._updateDataInfo(e);
	}, t.prototype._updateDataInfo = function(e) {
		var t = this.dataZoomModel, n = this._displayables, r = n.handleLabels, i = this._orient, a = ["", ""];
		if (t.get("showDetail")) {
			var o = t.findRepresentativeAxisProxy(), s = o.getAxisModel().axis.scale;
			if (o) {
				var c = this._range, l;
				if (e) {
					var u = {
						start: c[0],
						end: c[1]
					}, d = cz(t, o);
					if (d) {
						var f = d.calculateDataWindow(u).percentInverted;
						u = {
							start: f[0],
							end: f[1]
						};
					}
					l = o.calculateDataWindow(u);
				} else l = o.getWindow();
				a = [qV(t, 0, l, s), qV(t, 1, l, s)];
			}
		}
		var p = Oo(this._handleEnds.slice());
		m.call(this, 0), m.call(this, 1);
		function m(e) {
			var t = $p(n.handles[e].parent, this.group), o = tm(e === 0 ? "right" : "left", t), s = this._handleWidth / 2 + UV, c = em([p[e] + (e === 0 ? -s : s), this._size[1] / 2], t);
			r[e].setStyle({
				x: c[0],
				y: c[1],
				verticalAlign: i === VV ? "middle" : o,
				align: i === VV ? o : "center",
				text: a[e]
			});
		}
	}, t.prototype._onOverDataInfoTriggerArea = function(e) {
		this._isOverDataInfoTriggerArea = e, this._showDataInfo(e);
	}, t.prototype._showDataInfo = function(e) {
		var t = (this.dataZoomModel.get("handleLabel") || {}).show || !1, n = this.dataZoomModel.getModel(["emphasis", "handleLabel"]).get("show") || !1, r = e || this._dragging ? n : t, i = this._displayables, a = i.handleLabels;
		a[0].attr("invisible", !r), a[1].attr("invisible", !r), i.moveHandle && this.api[r ? "enterEmphasis" : "leaveEmphasis"](i.moveHandle, 1);
	}, t.prototype._onActualMoveZoneDrift = function(e, t, n) {
		this.api.getZr().setCursorStyle("grabbing"), this._onDragMove("all", e, t, n);
	}, t.prototype._onActualMoveZoneDragStart = function(e) {
		e.target.attr("cursor", "grabbing"), this._showDataInfo(!0);
	}, t.prototype._onActualMoveZoneDragEnd = function(e) {
		e.target.attr("cursor", "grab"), this._onDragEnd();
	}, t.prototype._onDragMove = function(e, t, n, r) {
		this._dragging = !0, It(r.event);
		var i = this._displayables.sliderGroup.getLocalTransform(), a = em([t, n], i, !0), o = this._updateInterval(e, a[0]), s = this.dataZoomModel.get("realtime");
		this._updateView(!s), o && s && this._dispatchZoomAction(!0);
	}, t.prototype._onDragEnd = function() {
		this._dragging = !1, this._isOverDataInfoTriggerArea || this._showDataInfo(!1), !this.dataZoomModel.get("realtime") && this._dispatchZoomAction(!1);
	}, t.prototype._onClickPanel = function(e) {
		var t = this._size, n = this._displayables.sliderGroup.transformCoordToLocal(e.offsetX, e.offsetY);
		if (!(n[0] < 0 || n[0] > t[0] || n[1] < 0 || n[1] > t[1])) {
			var r = this._handleEnds, i = (r[0] + r[1]) / 2, a = this._updateInterval("all", n[0] - i);
			this._updateView(), a && this._dispatchZoomAction(!1);
		}
	}, t.prototype._onBrushStart = function(e) {
		var t = e.offsetX, n = e.offsetY;
		this._brushStart = new J(t, n), this._brushing = !0, this._brushStartTime = +/* @__PURE__ */ new Date();
	}, t.prototype._onBrushEnd = function(e) {
		if (this._brushing) {
			var t = this._displayables.brushRect;
			if (this._brushing = !1, t) {
				t.attr("ignore", !0);
				var n = t.shape;
				if (!(+/* @__PURE__ */ new Date() - this._brushStartTime < 200 && Math.abs(n.width) < 5)) {
					var r = this._getViewExtent(), i = [0, 100], a = this._handleEnds = [n.x, n.x + n.width], o = this.dataZoomModel.findRepresentativeAxisProxy().getMinMaxSpan();
					wI(0, a, r, 0, o.minSpan == null ? null : xo(o.minSpan, i, r, !0), o.maxSpan == null ? null : xo(o.maxSpan, i, r, !0)), this._range = Oo([xo(a[0], r, i, !0), xo(a[1], r, i, !0)]), this._updateView(), this._dispatchZoomAction(!1);
				}
			}
		}
	}, t.prototype._onBrush = function(e) {
		this._brushing && (It(e.event), this._updateBrushRect(e.offsetX, e.offsetY));
	}, t.prototype._updateBrushRect = function(e, t) {
		var n = this._displayables, r = this.dataZoomModel, i = n.brushRect;
		i || (i = n.brushRect = new LV({
			silent: !0,
			style: r.getModel("brushStyle").getItemStyle()
		}), n.sliderGroup.add(i)), i.attr("ignore", !1);
		var a = this._brushStart, o = this._displayables.sliderGroup, s = o.transformCoordToLocal(e, t), c = o.transformCoordToLocal(a.x, a.y), l = this._size;
		s[0] = Math.max(Math.min(l[0], s[0]), 0), i.setShape({
			x: c[0],
			y: 0,
			width: s[0] - c[0],
			height: l[1]
		});
	}, t.prototype._dispatchZoomAction = function(e) {
		var t = this._range;
		this.api.dispatchAction({
			type: "dataZoom",
			from: this.uid,
			dataZoomId: this.dataZoomModel.id,
			animation: e ? GV : null,
			start: t[0],
			end: t[1]
		});
	}, t.prototype._findCoordRect = function() {
		var e, t = iz(this.dataZoomModel).infoList;
		if (!e && t.length) {
			var n = t[0].model.coordinateSystem;
			e = n.getRect && n.getRect();
		}
		if (!e) {
			var r = this.api.getWidth(), i = this.api.getHeight();
			e = {
				x: r * .2,
				y: i * .2,
				width: r * .6,
				height: i * .6
			};
		}
		return e;
	}, t.type = "dataZoom.slider", t;
}(fz);
function qV(e, t, n, r) {
	var i = e.get("labelFormatter"), a = e.get("labelPrecision");
	(a == null || a === "auto") && (a = n.valuePrecision);
	var o = n.value[t], s = o == null || isNaN(o) ? "" : DT(r) || TT(r) ? r.getLabel({ value: Math.round(o) }) : isFinite(a) ? Eo(o, a, !0) : o + "";
	return H(i) ? i(o, s) : U(i) ? i.replace("{value}", s) : s;
}
function JV(e) {
	return {
		x: "y",
		y: "x",
		radius: "angle",
		angle: "radius"
	}[e];
}
function YV(e) {
	return e === "vertical" ? "ns-resize" : "ew-resize";
}
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/installDataZoomSlider.js
function XV(e) {
	e.registerComponentModel(IV), e.registerComponentView(KV), _z(e);
}
//#endregion
//#region node_modules/echarts/lib/component/dataZoom/install.js
function ZV(e) {
	TD(FV), TD(XV);
}
//#endregion
//#region node_modules/echarts/lib/visual/visualDefault.js
var QV = { get: function(e, t, n) {
	var r = A(($V[e] || {})[t]);
	return n && V(r) ? r[r.length - 1] : r;
} }, $V = {
	color: {
		active: ["#006edd", "#e0ffff"],
		inactive: [Q.color.transparent]
	},
	colorHue: {
		active: [0, 360],
		inactive: [0, 0]
	},
	colorSaturation: {
		active: [.3, 1],
		inactive: [0, 0]
	},
	colorLightness: {
		active: [.9, .5],
		inactive: [0, 0]
	},
	colorAlpha: {
		active: [.3, 1],
		inactive: [0, 0]
	},
	opacity: {
		active: [.3, 1],
		inactive: [0, 0]
	},
	symbol: {
		active: [
			"circle",
			"roundRect",
			"diamond"
		],
		inactive: ["none"]
	},
	symbolSize: {
		active: [10, 50],
		inactive: [0, 0]
	}
}, eH = FF.mapVisual, tH = FF.eachVisual, nH = V, rH = I, iH = Oo, aH = xo, oH = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.stateList = ["inRange", "outOfRange"], n.replacableOptionKeys = [
			"inRange",
			"outOfRange",
			"target",
			"controller",
			"color"
		], n.layoutMode = {
			type: "box",
			ignoreSize: !0
		}, n.dataBound = [-Infinity, Infinity], n.targetVisuals = {}, n.controllerVisuals = {}, n;
	}
	return t.prototype.init = function(e, t, n) {
		this.mergeDefaultAndTheme(e, n);
	}, t.prototype.optionUpdated = function(e, t) {
		var n = this.option;
		!t && eB(n, e, this.replacableOptionKeys), this.textStyleModel = this.getModel("textStyle"), this.resetItemSize(), this.completeVisualOption();
	}, t.prototype.resetVisual = function(e) {
		var t = this.stateList;
		e = z(e, this), this.controllerVisuals = $z(this.option.controller, t, e), this.targetVisuals = $z(this.option.target, t, e);
	}, t.prototype.getItemSymbol = function() {
		return null;
	}, t.prototype.getTargetSeriesIndices = function() {
		var e = this, t = this.option.seriesTargets;
		if (t) {
			var n = [];
			return rH(t, function(t) {
				if (t.seriesIndex != null) n.push(t.seriesIndex);
				else if (t.seriesId != null) {
					var r;
					e.ecModel.eachSeries(function(e) {
						e.id === t.seriesId && (r = e);
					}), r && n.push(r.componentIndex);
				}
			}), n;
		}
		var r = this.option.seriesId, i = this.option.seriesIndex;
		i == null && r == null && (i = "all");
		var a = Ns(this.ecModel, "series", {
			index: i,
			id: r
		}, {
			useDefault: !1,
			enableAll: !0,
			enableNone: !1
		}).models;
		return L(a, function(e) {
			return e.componentIndex;
		});
	}, t.prototype.eachTargetSeries = function(e, t) {
		I(this.getTargetSeriesIndices(), function(n) {
			var r = this.ecModel.getSeriesByIndex(n);
			r && e.call(t, r);
		}, this);
	}, t.prototype.isTargetSeries = function(e) {
		var t = !1;
		return this.eachTargetSeries(function(n) {
			n === e && (t = !0);
		}), t;
	}, t.prototype.formatValueText = function(e, t, n) {
		var r = this.option, i = r.precision, a = this.dataBound, o = r.formatter, s;
		n ||= ["<", ">"], V(e) && (e = e.slice(), s = !0);
		var c = t ? e : s ? [l(e[0]), l(e[1])] : l(e);
		return U(o) ? o.replace("{value}", s ? c[0] : c).replace("{value2}", s ? c[1] : c) : H(o) ? s ? o(e[0], e[1]) : o(e) : s ? e[0] === a[0] ? n[0] + " " + c[1] : e[1] === a[1] ? n[1] + " " + c[0] : c[0] + " - " + c[1] : c;
		function l(e) {
			return e === a[0] ? "min" : e === a[1] ? "max" : (+e).toFixed(Math.min(i, 20));
		}
	}, t.prototype.resetExtent = function() {
		var e = this.option, t = iH([e.min, e.max]);
		this._dataExtent = t;
	}, t.prototype.getDimension = function(e) {
		var t = this, n = this.option.seriesTargets;
		if (n) {
			var r = se(n, function(n) {
				return n.seriesIndex != null && n.seriesIndex === e || n.seriesId != null && n.seriesId === t.ecModel.getSeriesByIndex(e).id;
			});
			if (r) return r.dimension;
		}
		return this.option.dimension;
	}, t.prototype.getDataDimensionIndex = function(e) {
		var t = e.hostModel.seriesIndex, n = this.getDimension(t);
		if (n != null) return e.getDimensionIndex(n);
		for (var r = e.dimensions, i = r.length - 1; i >= 0; i--) {
			var a = r[i], o = e.getDimensionInfo(a);
			if (!o.isCalculationCoord) return o.storeDimIndex;
		}
	}, t.prototype.getExtent = function() {
		return this._dataExtent.slice();
	}, t.prototype.completeVisualOption = function() {
		var e = this.ecModel, t = this.option, n = {
			inRange: t.inRange,
			outOfRange: t.outOfRange
		}, r = t.target ||= {}, i = t.controller ||= {};
		j(r, n), j(i, n);
		var a = this.isCategory();
		o.call(this, r), o.call(this, i), s.call(this, r, "inRange", "outOfRange"), c.call(this, i);
		function o(n) {
			nH(t.color) && !n.inRange && (n.inRange = { color: t.color.slice().reverse() }), n.inRange = n.inRange || { color: e.get("gradientColor") };
		}
		function s(e, t, n) {
			var r = e[t], i = e[n];
			r && !i && (i = e[n] = {}, rH(r, function(e, t) {
				if (FF.isValidType(t)) {
					var n = QV.get(t, "inactive", a);
					n != null && (i[t] = n, t === "color" && !i.hasOwnProperty("opacity") && !i.hasOwnProperty("colorAlpha") && (i.opacity = [0, 0]));
				}
			}));
		}
		function c(e) {
			var t = (e.inRange || {}).symbol || (e.outOfRange || {}).symbol, n = (e.inRange || {}).symbolSize || (e.outOfRange || {}).symbolSize, r = this.get("inactiveColor"), i = this.getItemSymbol() || "roundRect";
			rH(this.stateList, function(o) {
				var s = this.itemSize, c = e[o];
				c ||= e[o] = { color: a ? r : [r] }, c.symbol ?? (c.symbol = t && A(t) || (a ? i : [i])), c.symbolSize ?? (c.symbolSize = n && A(n) || (a ? s[0] : [s[0], s[0]])), c.symbol = eH(c.symbol, function(e) {
					return e === "none" ? i : e;
				});
				var l = c.symbolSize;
				if (l != null) {
					var u = -Infinity;
					tH(l, function(e) {
						e > u && (u = e);
					}), c.symbolSize = eH(l, function(e) {
						return aH(e, [0, u], [0, s[0]], !0);
					});
				}
			}, this);
		}
	}, t.prototype.resetItemSize = function() {
		this.itemSize = [parseFloat(this.get("itemWidth")), parseFloat(this.get("itemHeight"))];
	}, t.prototype.isCategory = function() {
		return !!this.option.categories;
	}, t.prototype.setSelected = function(e) {}, t.prototype.getSelected = function() {
		return null;
	}, t.prototype.getValueState = function(e) {
		return null;
	}, t.prototype.getVisualMeta = function(e) {
		return null;
	}, t.type = "visualMap", t.dependencies = ["series"], t.defaultOption = {
		show: !0,
		z: 4,
		min: 0,
		max: 200,
		left: 0,
		right: null,
		top: null,
		bottom: 0,
		itemWidth: null,
		itemHeight: null,
		inverse: !1,
		orient: "vertical",
		backgroundColor: Q.color.transparent,
		borderColor: Q.color.borderTint,
		contentColor: Q.color.theme[0],
		inactiveColor: Q.color.disabled,
		borderWidth: 0,
		padding: Q.size.m,
		textGap: 10,
		precision: 0,
		textStyle: { color: Q.color.secondary }
	}, t;
}(Jg), sH = [20, 140], cH = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.optionUpdated = function(t, n) {
		e.prototype.optionUpdated.apply(this, arguments), this.resetExtent(), this.resetVisual(function(e) {
			e.mappingMethod = "linear", e.dataExtent = this.getExtent();
		}), this._resetRange();
	}, t.prototype.resetItemSize = function() {
		e.prototype.resetItemSize.apply(this, arguments);
		var t = this.itemSize;
		(t[0] == null || isNaN(t[0])) && (t[0] = sH[0]), (t[1] == null || isNaN(t[1])) && (t[1] = sH[1]);
	}, t.prototype._resetRange = function() {
		var e = this.getExtent(), t = this.option.range;
		!t || t.auto ? (e.auto = 1, this.option.range = e) : V(t) && (t[0] > t[1] && t.reverse(), t[0] = Math.max(t[0], e[0]), t[1] = Math.min(t[1], e[1]));
	}, t.prototype.completeVisualOption = function() {
		e.prototype.completeVisualOption.apply(this, arguments), I(this.stateList, function(e) {
			var t = this.option.controller[e].symbolSize;
			t && t[0] !== t[1] && (t[0] = t[1] / 3);
		}, this);
	}, t.prototype.setSelected = function(e) {
		this.option.range = e.slice(), this._resetRange();
	}, t.prototype.getSelected = function() {
		var e = this.getExtent(), t = Oo((this.get("range") || []).slice());
		return t[0] > e[1] && (t[0] = e[1]), t[1] > e[1] && (t[1] = e[1]), t[0] < e[0] && (t[0] = e[0]), t[1] < e[0] && (t[1] = e[0]), t;
	}, t.prototype.getValueState = function(e) {
		var t = this.option.range, n = this.getExtent(), r = G(this.option.unboundedRange, !0);
		return (r && t[0] <= n[0] || t[0] <= e) && (r && t[1] >= n[1] || e <= t[1]) ? "inRange" : "outOfRange";
	}, t.prototype.findTargetDataIndices = function(e) {
		var t = [];
		return this.eachTargetSeries(function(n) {
			var r = [], i = n.getData();
			i.each(this.getDataDimensionIndex(i), function(t, n) {
				e[0] <= t && t <= e[1] && r.push(n);
			}, this), t.push({
				seriesId: n.id,
				dataIndex: r
			});
		}, this), t;
	}, t.prototype.getVisualMeta = function(e) {
		var t = lH(this, "outOfRange", this.getExtent()), n = lH(this, "inRange", this.option.range.slice()), r = [];
		function i(t, n) {
			r.push({
				value: t,
				color: e(t, n)
			});
		}
		for (var a = 0, o = 0, s = n.length, c = t.length; o < c && (!n.length || t[o] <= n[0]); o++) t[o] < n[a] && i(t[o], "outOfRange");
		for (var l = 1; a < s; a++, l = 0) l && r.length && i(n[a], "outOfRange"), i(n[a], "inRange");
		for (var l = 1; o < c; o++) (!n.length || n[n.length - 1] < t[o]) && (l &&= (r.length && i(r[r.length - 1].value, "outOfRange"), 0), i(t[o], "outOfRange"));
		var u = r.length;
		return {
			stops: r,
			outerColors: [u ? r[0].color : "transparent", u ? r[u - 1].color : "transparent"]
		};
	}, t.type = "visualMap.continuous", t.defaultOption = lh(oH.defaultOption, {
		align: "auto",
		calculable: !1,
		hoverLink: !0,
		realtime: !0,
		handleIcon: "path://M-11.39,9.77h0a3.5,3.5,0,0,1-3.5,3.5h-22a3.5,3.5,0,0,1-3.5-3.5h0a3.5,3.5,0,0,1,3.5-3.5h22A3.5,3.5,0,0,1-11.39,9.77Z",
		handleSize: "120%",
		handleStyle: {
			borderColor: Q.color.neutral00,
			borderWidth: 1
		},
		indicatorIcon: "circle",
		indicatorSize: "50%",
		indicatorStyle: {
			borderColor: Q.color.neutral00,
			borderWidth: 2,
			shadowBlur: 2,
			shadowOffsetX: 1,
			shadowOffsetY: 1,
			shadowColor: Q.color.shadow
		}
	}), t;
}(oH);
function lH(e, t, n) {
	if (n[0] === n[1]) return n.slice();
	for (var r = 200, i = (n[1] - n[0]) / r, a = n[0], o = [], s = 0; s <= r && a < n[1]; s++) o.push(a), a += i;
	return o.push(n[1]), o;
}
//#endregion
//#region node_modules/echarts/lib/component/visualMap/VisualMapView.js
var uH = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n.autoPositionValues = {
			left: 1,
			right: 1,
			top: 1,
			bottom: 1
		}, n;
	}
	return t.prototype.init = function(e, t) {
		this.ecModel = e, this.api = t;
	}, t.prototype.render = function(e, t, n, r) {
		this.visualMapModel = e, e.get("show") === !1 ? this.group.removeAll() : this.doRender(e, t, n, r);
	}, t.prototype.renderBackground = function(e) {
		var t = this.visualMapModel, n = fg(t.get("padding") || 0), r = e.getBoundingRect();
		e.add(new bu({
			z2: -1,
			silent: !0,
			shape: {
				x: r.x - n[3],
				y: r.y - n[0],
				width: r.width + n[3] + n[1],
				height: r.height + n[0] + n[2]
			},
			style: {
				fill: t.get("backgroundColor"),
				stroke: t.get("borderColor"),
				lineWidth: t.get("borderWidth")
			}
		}));
	}, t.prototype.getControllerVisual = function(e, t, n) {
		n ||= {};
		var r = n.forceState, i = this.visualMapModel, a = {};
		t === "color" && (a.color = i.get("contentColor"));
		function o(e) {
			return a[e];
		}
		function s(e, t) {
			a[e] = t;
		}
		var c = i.controllerVisuals[r || i.getValueState(e)];
		return I(FF.prepareVisualTypes(c), function(r) {
			var i = c[r];
			n.convertOpacityToAlpha && r === "opacity" && (r = "colorAlpha", i = c.__alphaForOpacity), FF.dependsOn(r, t) && i && i.applyVisual(e, o, s);
		}), a[t];
	}, t.prototype.positionGroup = function(e) {
		var t = this.visualMapModel, n = this.api, r = Vg(t, n).refContainer;
		Hg(e, t.getBoxLayoutParams(), r);
	}, t.prototype.doRender = function(e, t, n, r) {}, t.type = "visualMap", t;
}(rb), dH = [[
	"left",
	"right",
	"width"
], [
	"top",
	"bottom",
	"height"
]];
function fH(e, t, n) {
	var r = e.option, i = r.align;
	if (i != null && i !== "auto") return i;
	for (var a = {
		width: t.getWidth(),
		height: t.getHeight()
	}, o = +(r.orient === "horizontal"), s = dH[o], c = [
		0,
		null,
		10
	], l = {}, u = 0; u < 3; u++) l[dH[1 - o][u]] = c[u], l[s[u]] = u === 2 ? n[0] : r[s[u]];
	var d = [[
		"x",
		"width",
		3
	], [
		"y",
		"height",
		0
	]][o], f = zg(l, a, r.padding);
	return s[(f.margin[d[2]] || 0) + f[d[0]] + f[d[1]] * .5 < a[d[1]] * .5 ? 0 : 1];
}
function pH(e, t) {
	return I(e || [], function(e) {
		e.dataIndex != null && (e.dataIndexInside = e.dataIndex, e.dataIndex = null), e.highlightKey = "visualMap" + (t ? t.componentIndex : "");
	}), e;
}
//#endregion
//#region node_modules/echarts/lib/component/visualMap/ContinuousView.js
var mH = xo, hH = I, gH = Math.min, _H = Math.max, vH = 12, yH = 6, bH = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n._shapes = {}, n._dataInterval = [], n._handleEnds = [], n._hoverLinkDataIndices = [], n;
	}
	return t.prototype.init = function(t, n) {
		e.prototype.init.call(this, t, n), this._hoverLinkFromSeriesMouseOver = z(this._hoverLinkFromSeriesMouseOver, this), this._hideIndicator = z(this._hideIndicator, this);
	}, t.prototype.doRender = function(e, t, n, r) {
		(!r || r.type !== "selectDataRange" || r.from !== this.uid) && this._buildView();
	}, t.prototype._buildView = function() {
		this.group.removeAll();
		var e = this.visualMapModel, t = this.group;
		this._orient = e.get("orient"), this._useHandle = e.get("calculable"), this._resetInterval(), this._renderBar(t);
		var n = e.get("text");
		this._renderEndsText(t, n, 0), this._renderEndsText(t, n, 1), this._updateView(!0), this.renderBackground(t), this._updateView(), this._enableHoverLinkToSeries(), this._enableHoverLinkFromSeries(), this.positionGroup(t);
	}, t.prototype._renderEndsText = function(e, t, n) {
		if (t) {
			var r = t[1 - n];
			r = r == null ? "" : r + "";
			var i = this.visualMapModel, a = i.get("textGap"), o = i.itemSize, s = this._shapes.mainGroup, c = this._applyTransform([o[0] / 2, n === 0 ? -a : o[1] + a], s), l = this._applyTransform(n === 0 ? "bottom" : "top", s), u = this._orient, d = this.visualMapModel.textStyleModel;
			this.group.add(new Tu({ style: Fm(d, {
				x: c[0],
				y: c[1],
				verticalAlign: d.get("verticalAlign") || (u === "horizontal" ? "middle" : l),
				align: d.get("align") || (u === "horizontal" ? l : "center"),
				text: r
			}) }));
		}
	}, t.prototype._renderBar = function(e) {
		var t = this.visualMapModel, n = this._shapes, r = t.itemSize, i = this._orient, a = this._useHandle, o = fH(t, this.api, r), s = n.mainGroup = this._createBarGroup(o), c = new Wa();
		s.add(c), c.add(n.outOfRange = xH()), c.add(n.inRange = xH(null, a ? wH(this._orient) : null, z(this._dragHandle, this, "all", !1), z(this._dragHandle, this, "all", !0))), c.setClipPath(new bu({ shape: {
			x: 0,
			y: 0,
			width: r[0],
			height: r[1],
			r: 3
		} }));
		var l = t.textStyleModel.getTextRect("国"), u = _H(l.width, l.height);
		a && (n.handleThumbs = [], n.handleLabels = [], n.handleLabelPoints = [], this._createHandle(t, s, 0, r, u, i), this._createHandle(t, s, 1, r, u, i)), this._createIndicator(t, s, r, u, i), e.add(s);
	}, t.prototype._createHandle = function(e, t, n, r, i, a) {
		var o = z(this._dragHandle, this, n, !1), s = z(this._dragHandle, this, n, !0), c = Ta(e.get("handleSize"), r[0]), l = Ox(e.get("handleIcon"), -c / 2, -c / 2, c, c, null, !0), u = wH(this._orient);
		l.attr({
			cursor: u,
			draggable: !0,
			drift: o,
			ondragend: s,
			onmousemove: function(e) {
				It(e.event);
			}
		}), l.x = r[0] / 2, l.useStyle(e.getModel("handleStyle").getItemStyle()), l.setStyle({
			strokeNoScale: !0,
			strokeFirst: !0
		}), l.style.lineWidth *= 2, l.ensureState("emphasis").style = e.getModel(["emphasis", "handleStyle"]).getItemStyle(), Qd(l, !0), t.add(l);
		var d = this.visualMapModel.textStyleModel, f = new Tu({
			cursor: u,
			draggable: !0,
			drift: o,
			onmousemove: function(e) {
				It(e.event);
			},
			ondragend: s,
			style: Fm(d, {
				x: 0,
				y: 0,
				text: ""
			})
		});
		f.ensureState("blur").style = { opacity: .1 }, f.stateTransition = { duration: 200 }, this.group.add(f);
		var p = [c, 0], m = this._shapes;
		m.handleThumbs[n] = l, m.handleLabelPoints[n] = p, m.handleLabels[n] = f;
	}, t.prototype._createIndicator = function(e, t, n, r, i) {
		var a = Ta(e.get("indicatorSize"), n[0]), o = Ox(e.get("indicatorIcon"), -a / 2, -a / 2, a, a, null, !0);
		o.attr({
			cursor: "move",
			invisible: !0,
			silent: !0,
			x: n[0] / 2
		});
		var s = e.getModel("indicatorStyle").getItemStyle();
		if (o instanceof fu) {
			var c = o.style;
			o.useStyle(M({
				image: c.image,
				x: c.x,
				y: c.y,
				width: c.width,
				height: c.height
			}, s));
		} else o.useStyle(s);
		t.add(o);
		var l = this.visualMapModel.textStyleModel, u = new Tu({
			silent: !0,
			invisible: !0,
			style: Fm(l, {
				x: 0,
				y: 0,
				text: ""
			})
		});
		this.group.add(u);
		var d = [(i === "horizontal" ? r / 2 : yH) + n[0] / 2, 0], f = this._shapes;
		f.indicator = o, f.indicatorLabel = u, f.indicatorLabelPoint = d, this._firstShowIndicator = !0;
	}, t.prototype._dragHandle = function(e, t, n, r) {
		if (this._useHandle) {
			if (this._dragging = !t, !t) {
				var i = this._applyTransform([n, r], this._shapes.mainGroup, !0);
				this._updateInterval(e, i[1]), this._hideIndicator(), this._updateView();
			}
			t === !this.visualMapModel.get("realtime") && this.api.dispatchAction({
				type: "selectDataRange",
				from: this.uid,
				visualMapId: this.visualMapModel.id,
				selected: this._dataInterval.slice()
			}), t ? !this._hovering && this._clearHoverLinkToSeries() : CH(this.visualMapModel) && this._doHoverLinkToSeries(this._handleEnds[e], !1);
		}
	}, t.prototype._resetInterval = function() {
		var e = this.visualMapModel, t = this._dataInterval = e.getSelected(), n = e.getExtent(), r = [0, e.itemSize[1]];
		this._handleEnds = [mH(t[0], n, r, !0), mH(t[1], n, r, !0)];
	}, t.prototype._updateInterval = function(e, t) {
		t ||= 0;
		var n = this.visualMapModel, r = this._handleEnds, i = [0, n.itemSize[1]];
		wI(t, r, i, e, 0);
		var a = n.getExtent();
		this._dataInterval = [mH(r[0], i, a, !0), mH(r[1], i, a, !0)];
	}, t.prototype._updateView = function(e) {
		var t = this.visualMapModel, n = t.getExtent(), r = this._shapes, i = [0, t.itemSize[1]], a = e ? i : this._handleEnds, o = this._createBarVisual(this._dataInterval, n, a, "inRange"), s = this._createBarVisual(n, n, i, "outOfRange");
		r.inRange.setStyle({ fill: o.barColor }).setShape("points", o.barPoints), r.outOfRange.setStyle({ fill: s.barColor }).setShape("points", s.barPoints), this._updateHandle(a, o);
	}, t.prototype._createBarVisual = function(e, t, n, r) {
		var i = {
			forceState: r,
			convertOpacityToAlpha: !0
		}, a = this._makeColorGradient(e, i), o = [this.getControllerVisual(e[0], "symbolSize", i), this.getControllerVisual(e[1], "symbolSize", i)], s = this._createBarPoints(n, o);
		return {
			barColor: new pp(0, 0, 0, 1, a),
			barPoints: s,
			handlesColor: [a[0].color, a[a.length - 1].color]
		};
	}, t.prototype._makeColorGradient = function(e, t) {
		var n = 100, r = [], i = (e[1] - e[0]) / n;
		r.push({
			color: this.getControllerVisual(e[0], "color", t),
			offset: 0
		});
		for (var a = 1; a < n; a++) {
			var o = e[0] + i * a;
			if (o > e[1]) break;
			r.push({
				color: this.getControllerVisual(o, "color", t),
				offset: a / n
			});
		}
		return r.push({
			color: this.getControllerVisual(e[1], "color", t),
			offset: 1
		}), r;
	}, t.prototype._createBarPoints = function(e, t) {
		var n = this.visualMapModel.itemSize;
		return [
			[n[0] - t[0], e[0]],
			[n[0], e[0]],
			[n[0], e[1]],
			[n[0] - t[1], e[1]]
		];
	}, t.prototype._createBarGroup = function(e) {
		var t = this._orient, n = this.visualMapModel.get("inverse");
		return new Wa(t === "horizontal" && !n ? {
			scaleX: e === "bottom" ? 1 : -1,
			rotation: Math.PI / 2
		} : t === "horizontal" && n ? {
			scaleX: e === "bottom" ? -1 : 1,
			rotation: -Math.PI / 2
		} : t === "vertical" && !n ? {
			scaleX: e === "left" ? 1 : -1,
			scaleY: -1
		} : { scaleX: e === "left" ? 1 : -1 });
	}, t.prototype._updateHandle = function(e, t) {
		if (this._useHandle) {
			var n = this._shapes, r = this.visualMapModel, i = n.handleThumbs, a = n.handleLabels, o = r.itemSize, s = r.getExtent(), c = this._applyTransform("left", n.mainGroup);
			hH([0, 1], function(l) {
				var u = i[l];
				u.setStyle("fill", t.handlesColor[l]), u.y = e[l];
				var d = mH(e[l], [0, o[1]], s, !0), f = this.getControllerVisual(d, "symbolSize");
				u.scaleX = u.scaleY = f / o[0], u.x = o[0] - f / 2;
				var p = em(n.handleLabelPoints[l], $p(u, this.group));
				if (this._orient === "horizontal") {
					var m = c === "left" || c === "top" ? (o[0] - f) / 2 : (o[0] - f) / -2;
					p[1] += m;
				}
				a[l].setStyle({
					x: p[0],
					y: p[1],
					text: r.formatValueText(this._dataInterval[l]),
					verticalAlign: "middle",
					align: this._orient === "vertical" ? this._applyTransform("left", n.mainGroup) : "center"
				});
			}, this);
		}
	}, t.prototype._showIndicator = function(e, t, n, r) {
		var i = this.visualMapModel, a = i.getExtent(), o = i.itemSize, s = [0, o[1]], c = this._shapes, l = c.indicator;
		if (l) {
			l.attr("invisible", !1);
			var u = this.getControllerVisual(e, "color", { convertOpacityToAlpha: !0 }), d = this.getControllerVisual(e, "symbolSize"), f = mH(e, a, s, !0), p = o[0] - d / 2, m = {
				x: l.x,
				y: l.y
			};
			l.y = f, l.x = p;
			var h = em(c.indicatorLabelPoint, $p(l, this.group)), g = c.indicatorLabel;
			g.attr("invisible", !1);
			var _ = this._applyTransform("left", c.mainGroup), v = this._orient === "horizontal";
			g.setStyle({
				text: (n || "") + i.formatValueText(t),
				verticalAlign: v ? _ : "middle",
				align: v ? "center" : _
			});
			var y = {
				x: p,
				y: f,
				style: { fill: u }
			}, b = { style: {
				x: h[0],
				y: h[1]
			} };
			if (i.ecModel.isAnimationEnabled() && !this._firstShowIndicator) {
				var x = {
					duration: 100,
					easing: "cubicInOut",
					additive: !0
				};
				l.x = m.x, l.y = m.y, l.animateTo(y, x), g.animateTo(b, x);
			} else l.attr(y), g.attr(b);
			this._firstShowIndicator = !1;
			var S = this._shapes.handleLabels;
			if (S) for (var C = 0; C < S.length; C++) this.api.enterBlur(S[C]);
		}
	}, t.prototype._enableHoverLinkToSeries = function() {
		var e = this;
		this._shapes.mainGroup.on("mousemove", function(t) {
			if (e._hovering = !0, !e._dragging) {
				var n = e.visualMapModel.itemSize, r = e._applyTransform([t.offsetX, t.offsetY], e._shapes.mainGroup, !0, !0);
				r[1] = gH(_H(0, r[1]), n[1]), e._doHoverLinkToSeries(r[1], 0 <= r[0] && r[0] <= n[0]);
			}
		}).on("mouseout", function() {
			e._hovering = !1, !e._dragging && e._clearHoverLinkToSeries();
		});
	}, t.prototype._enableHoverLinkFromSeries = function() {
		var e = this.api.getZr();
		this.visualMapModel.option.hoverLink ? (e.on("mouseover", this._hoverLinkFromSeriesMouseOver, this), e.on("mouseout", this._hideIndicator, this)) : this._clearHoverLinkFromSeries();
	}, t.prototype._doHoverLinkToSeries = function(e, t) {
		var n = this.visualMapModel, r = n.itemSize;
		if (n.option.hoverLink) {
			var i = [0, r[1]], a = n.getExtent();
			e = gH(_H(i[0], e), i[1]);
			var o = SH(n, a, i), s = [e - o, e + o], c = mH(e, i, a, !0), l = [mH(s[0], i, a, !0), mH(s[1], i, a, !0)];
			s[0] < i[0] && (l[0] = -Infinity), s[1] > i[1] && (l[1] = Infinity), t && (l[0] === -Infinity ? this._showIndicator(c, l[1], "< ", o) : l[1] === Infinity ? this._showIndicator(c, l[0], "> ", o) : this._showIndicator(c, c, "≈ ", o));
			var u = this._hoverLinkDataIndices, d = [];
			(t || CH(n)) && (d = this._hoverLinkDataIndices = n.findTargetDataIndices(l));
			var f = Es(u, d);
			this._dispatchHighDown("downplay", pH(f[0], n)), this._dispatchHighDown("highlight", pH(f[1], n));
		}
	}, t.prototype._hoverLinkFromSeriesMouseOver = function(e) {
		var t;
		if (ox(e.target, function(e) {
			var n = Z(e);
			if (n.dataIndex != null) return t = n, !0;
		}, !0), t) {
			var n = this.ecModel.getSeriesByIndex(t.seriesIndex), r = this.visualMapModel;
			if (r.isTargetSeries(n)) {
				var i = n.getData(t.dataType), a = i.getStore().get(r.getDataDimensionIndex(i), t.dataIndex);
				isNaN(a) || this._showIndicator(a, a);
			}
		}
	}, t.prototype._hideIndicator = function() {
		var e = this._shapes;
		e.indicator && e.indicator.attr("invisible", !0), e.indicatorLabel && e.indicatorLabel.attr("invisible", !0);
		var t = this._shapes.handleLabels;
		if (t) for (var n = 0; n < t.length; n++) this.api.leaveBlur(t[n]);
	}, t.prototype._clearHoverLinkToSeries = function() {
		this._hideIndicator();
		var e = this._hoverLinkDataIndices;
		this._dispatchHighDown("downplay", pH(e, this.visualMapModel)), e.length = 0;
	}, t.prototype._clearHoverLinkFromSeries = function() {
		this._hideIndicator();
		var e = this.api.getZr();
		e.off("mouseover", this._hoverLinkFromSeriesMouseOver), e.off("mouseout", this._hideIndicator);
	}, t.prototype._applyTransform = function(e, t, n, r) {
		var i = $p(t, r ? null : this.group);
		return V(e) ? em(e, i, n) : tm(e, i, n);
	}, t.prototype._dispatchHighDown = function(e, t) {
		t && t.length && this.api.dispatchAction({
			type: e,
			batch: t
		});
	}, t.prototype.dispose = function() {
		this._clearHoverLinkFromSeries(), this._clearHoverLinkToSeries();
	}, t.type = "visualMap.continuous", t;
}(uH);
function xH(e, t, n, r) {
	return new $f({
		shape: { points: e },
		draggable: !!n,
		cursor: t,
		drift: n,
		onmousemove: function(e) {
			It(e.event);
		},
		ondragend: r
	});
}
function SH(e, t, n) {
	var r = vH / 2, i = e.get("hoverLinkDataSize");
	return i && (r = mH(i, t, n, !0) / 2), r;
}
function CH(e) {
	return !!(e.get("hoverLinkOnHandle") ?? e.get("realtime"));
}
function wH(e) {
	return e === "vertical" ? "ns-resize" : "ew-resize";
}
//#endregion
//#region node_modules/echarts/lib/component/visualMap/visualMapAction.js
var TH = {
	type: "selectDataRange",
	event: "dataRangeSelected",
	update: "update"
}, EH = function(e, t) {
	t.eachComponent({
		mainType: "visualMap",
		query: e
	}, function(t) {
		t.setSelected(e.selected);
	});
}, DH = [{
	createOnAllSeries: !0,
	reset: function(e, t) {
		var n = [];
		return t.eachComponent("visualMap", function(t) {
			var r = e.pipelineContext;
			!t.isTargetSeries(e) || r && r.large || n.push(tB(t.stateList, t.targetVisuals, z(t.getValueState, t), t.getDataDimensionIndex(e.getData())));
		}), n;
	}
}, {
	createOnAllSeries: !0,
	reset: function(e, t) {
		var n = e.getData(), r = [];
		t.eachComponent("visualMap", function(t) {
			if (t.isTargetSeries(e)) {
				var i = t.getVisualMeta(z(OH, null, e, t)) || {
					stops: [],
					outerColors: []
				}, a = t.getDataDimensionIndex(n);
				a >= 0 && (i.dimension = a, r.push(i));
			}
		}), e.getData().setVisual("visualMeta", r);
	}
}];
function OH(e, t, n, r) {
	for (var i = t.targetVisuals[r], a = FF.prepareVisualTypes(i), o = { color: tx(e.getData(), "color") }, s = 0, c = a.length; s < c; s++) {
		var l = a[s], u = i[l === "opacity" ? "__alphaForOpacity" : l];
		u && u.applyVisual(n, d, f);
	}
	return o.color;
	function d(e) {
		return o[e];
	}
	function f(e, t) {
		o[e] = t;
	}
}
//#endregion
//#region node_modules/echarts/lib/component/visualMap/preprocessor.js
var kH = I;
function AH(e) {
	var t = e && e.visualMap;
	V(t) || (t = t ? [t] : []), kH(t, function(e) {
		if (e) {
			jH(e, "splitList") && !jH(e, "pieces") && (e.pieces = e.splitList, delete e.splitList);
			var t = e.pieces;
			t && V(t) && kH(t, function(e) {
				W(e) && (jH(e, "start") && !jH(e, "min") && (e.min = e.start), jH(e, "end") && !jH(e, "max") && (e.max = e.end));
			});
		}
	});
}
function jH(e, t) {
	return e && e.hasOwnProperty && e.hasOwnProperty(t);
}
//#endregion
//#region node_modules/echarts/lib/component/visualMap/installCommon.js
var MH = !1;
function NH(e) {
	MH || (MH = !0, e.registerSubTypeDefaulter("visualMap", function(e) {
		return !e.categories && (!(e.pieces ? e.pieces.length > 0 : e.splitNumber > 0) || e.calculable) ? "continuous" : "piecewise";
	}), e.registerAction(TH, EH), I(DH, function(t) {
		e.registerVisual(e.PRIORITY.VISUAL.COMPONENT, t);
	}), e.registerPreprocessor(AH));
}
//#endregion
//#region node_modules/echarts/lib/component/visualMap/installVisualMapContinuous.js
function PH(e) {
	e.registerComponentModel(cH), e.registerComponentView(bH), NH(e);
}
//#endregion
//#region node_modules/echarts/lib/component/visualMap/PiecewiseModel.js
var FH = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n._pieceList = [], n;
	}
	return t.prototype.optionUpdated = function(t, n) {
		e.prototype.optionUpdated.apply(this, arguments), this.resetExtent();
		var r = this._mode = this._determineMode();
		this._pieceList = [], IH[this._mode].call(this, this._pieceList), this._resetSelected(t, n);
		var i = this.option.categories;
		this.resetVisual(function(e, t) {
			r === "categories" ? (e.mappingMethod = "category", e.categories = A(i)) : (e.dataExtent = this.getExtent(), e.mappingMethod = "piecewise", e.pieceList = L(this._pieceList, function(e) {
				return e = A(e), t !== "inRange" && (e.visual = null), e;
			}));
		});
	}, t.prototype.completeVisualOption = function() {
		var t = this.option, n = {}, r = FF.listVisualTypes(), i = this.isCategory();
		I(t.pieces, function(e) {
			I(r, function(t) {
				e.hasOwnProperty(t) && (n[t] = 1);
			});
		}), I(n, function(e, n) {
			var r = !1;
			I(this.stateList, function(e) {
				r = r || a(t, e, n) || a(t.target, e, n);
			}, this), !r && I(this.stateList, function(e) {
				(t[e] || (t[e] = {}))[n] = QV.get(n, e === "inRange" ? "active" : "inactive", i);
			});
		}, this);
		function a(e, t, n) {
			return e && e[t] && e[t].hasOwnProperty(n);
		}
		e.prototype.completeVisualOption.apply(this, arguments);
	}, t.prototype._resetSelected = function(e, t) {
		var n = this.option, r = this._pieceList, i = (t ? n : e).selected || {};
		if (n.selected = i, I(r, function(e, t) {
			var n = this.getSelectedMapKey(e);
			i.hasOwnProperty(n) || (i[n] = !0);
		}, this), n.selectedMode === "single") {
			var a = !1;
			I(r, function(e, t) {
				var n = this.getSelectedMapKey(e);
				i[n] && (a ? i[n] = !1 : a = !0);
			}, this);
		}
	}, t.prototype.getItemSymbol = function() {
		return this.get("itemSymbol");
	}, t.prototype.getSelectedMapKey = function(e) {
		return this._mode === "categories" ? e.value + "" : e.index + "";
	}, t.prototype.getPieceList = function() {
		return this._pieceList;
	}, t.prototype._determineMode = function() {
		var e = this.option;
		return e.pieces && e.pieces.length > 0 ? "pieces" : this.option.categories ? "categories" : "splitNumber";
	}, t.prototype.setSelected = function(e) {
		this.option.selected = A(e);
	}, t.prototype.getValueState = function(e) {
		var t = FF.findPieceIndex(e, this._pieceList);
		return t == null ? "outOfRange" : this.option.selected[this.getSelectedMapKey(this._pieceList[t])] ? "inRange" : "outOfRange";
	}, t.prototype.findTargetDataIndices = function(e) {
		var t = [], n = this._pieceList;
		return this.eachTargetSeries(function(r) {
			var i = [], a = r.getData();
			a.each(this.getDataDimensionIndex(a), function(t, r) {
				FF.findPieceIndex(t, n) === e && i.push(r);
			}, this), t.push({
				seriesId: r.id,
				dataIndex: i
			});
		}, this), t;
	}, t.prototype.getRepresentValue = function(e) {
		var t;
		if (this.isCategory()) t = e.value;
		else if (e.value != null) t = e.value;
		else {
			var n = e.interval || [];
			t = n[0] === -Infinity && n[1] === Infinity ? 0 : (n[0] + n[1]) / 2;
		}
		return t;
	}, t.prototype.getVisualMeta = function(e) {
		if (this.isCategory()) return;
		var t = [], n = ["", ""], r = this;
		function i(i, a) {
			var o = r.getRepresentValue({ interval: i });
			a ||= r.getValueState(o);
			var s = e(o, a);
			i[0] === -Infinity ? n[0] = s : i[1] === Infinity ? n[1] = s : t.push({
				value: i[0],
				color: s
			}, {
				value: i[1],
				color: s
			});
		}
		var a = this._pieceList.slice();
		if (!a.length) a.push({ interval: [-Infinity, Infinity] });
		else {
			var o = a[0].interval[0];
			o !== -Infinity && a.unshift({ interval: [-Infinity, o] }), o = a[a.length - 1].interval[1], o !== Infinity && a.push({ interval: [o, Infinity] });
		}
		var s = -Infinity;
		return I(a, function(e) {
			var t = e.interval;
			t && (t[0] > s && i([s, t[0]], "outOfRange"), i(t.slice()), s = t[1]);
		}, this), {
			stops: t,
			outerColors: n
		};
	}, t.type = "visualMap.piecewise", t.defaultOption = lh(oH.defaultOption, {
		selected: null,
		minOpen: !1,
		maxOpen: !1,
		align: "auto",
		itemWidth: 20,
		itemHeight: 14,
		itemSymbol: "roundRect",
		pieces: null,
		categories: null,
		splitNumber: 5,
		selectedMode: "multiple",
		itemGap: 10,
		hoverLink: !0
	}), t;
}(oH), IH = {
	splitNumber: function(e) {
		var t = this.option, n = Math.min(t.precision, 20), r = this.getExtent(), i = t.splitNumber;
		i = Math.max(parseInt(i, 10), 1), t.splitNumber = i;
		for (var a = (r[1] - r[0]) / i; +a.toFixed(n) !== a && n < 5;) n++;
		t.precision = n, a = +a.toFixed(n), t.minOpen && e.push({
			interval: [-Infinity, r[0]],
			close: [0, 0]
		});
		for (var o = 0, s = r[0]; o < i; s += a, o++) {
			var c = o === i - 1 ? r[1] : s + a;
			e.push({
				interval: [s, c],
				close: [1, 1]
			});
		}
		t.maxOpen && e.push({
			interval: [r[1], Infinity],
			close: [0, 0]
		}), Go(e), I(e, function(e, t) {
			e.index = t, e.text = this.formatValueText(e.interval);
		}, this);
	},
	categories: function(e) {
		var t = this.option;
		I(t.categories, function(t) {
			e.push({
				text: this.formatValueText(t, !0),
				value: t
			});
		}, this), LH(t, e);
	},
	pieces: function(e) {
		var t = this.option;
		I(t.pieces, function(t, n) {
			W(t) || (t = { value: t });
			var r = {
				text: "",
				index: n
			};
			if (t.label != null && (r.text = t.label), t.hasOwnProperty("value")) {
				var i = r.value = t.value;
				r.interval = [i, i], r.close = [1, 1];
			} else {
				for (var a = r.interval = [], o = r.close = [0, 0], s = [
					1,
					0,
					1
				], c = [-Infinity, Infinity], l = [], u = 0; u < 2; u++) {
					for (var d = [[
						"gte",
						"gt",
						"min"
					], [
						"lte",
						"lt",
						"max"
					]][u], f = 0; f < 3 && a[u] == null; f++) a[u] = t[d[f]], o[u] = s[f], l[u] = f === 2;
					a[u] ?? (a[u] = c[u]);
				}
				l[0] && a[1] === Infinity && (o[0] = 0), l[1] && a[0] === -Infinity && (o[1] = 0), a[0] === a[1] && o[0] && o[1] && (r.value = a[0]);
			}
			r.visual = FF.retrieveVisuals(t), e.push(r);
		}, this), LH(t, e), Go(e), I(e, function(e) {
			var t = e.close, n = [["<", "≤"][t[1]], [">", "≥"][t[0]]];
			e.text = e.text || this.formatValueText(e.value == null ? e.interval : e.value, !1, n);
		}, this);
	}
};
function LH(e, t) {
	var n = e.inverse;
	(e.orient === "vertical" ? !n : n) && t.reverse();
}
//#endregion
//#region node_modules/echarts/lib/component/visualMap/PiecewiseView.js
var RH = function(e) {
	n(t, e);
	function t() {
		var n = e !== null && e.apply(this, arguments) || this;
		return n.type = t.type, n;
	}
	return t.prototype.doRender = function() {
		var e = this.group;
		e.removeAll();
		var t = this.visualMapModel, n = t.get("textGap"), r = t.textStyleModel, i = this._getItemAlign(), a = t.itemSize, o = this._getViewData(), s = o.endsText, c = ve(t.get("showLabel", !0), !s), l = !t.get("selectedMode");
		s && this._renderEndsText(e, s[0], a, c, i), I(o.viewPieceList, function(o) {
			var s = o.piece, u = new Wa();
			u.onclick = z(this._onItemClick, this, s), this._enableHoverLink(u, o.indexInModelPieceList);
			var d = t.getRepresentValue(s);
			if (this._createItemSymbol(u, d, [
				0,
				0,
				a[0],
				a[1]
			], l), c) {
				var f = this.visualMapModel.getValueState(d), p = r.get("align") || i;
				u.add(new Tu({
					style: Fm(r, {
						x: p === "right" ? -n : a[0] + n,
						y: a[1] / 2,
						text: s.text,
						verticalAlign: r.get("verticalAlign") || "middle",
						align: p,
						opacity: G(r.get("opacity"), f === "outOfRange" ? .5 : 1)
					}),
					silent: l
				}));
			}
			e.add(u);
		}, this), s && this._renderEndsText(e, s[1], a, c, i), Fg(t.get("orient"), e, t.get("itemGap")), this.renderBackground(e), this.positionGroup(e);
	}, t.prototype._enableHoverLink = function(e, t) {
		var n = this;
		e.on("mouseover", function() {
			return r("highlight");
		}).on("mouseout", function() {
			return r("downplay");
		});
		var r = function(e) {
			var r = n.visualMapModel;
			r.option.hoverLink && n.api.dispatchAction({
				type: e,
				batch: pH(r.findTargetDataIndices(t), r)
			});
		};
	}, t.prototype._getItemAlign = function() {
		var e = this.visualMapModel, t = e.option;
		if (t.orient === "vertical") return fH(e, this.api, e.itemSize);
		var n = t.align;
		return (!n || n === "auto") && (n = "left"), n;
	}, t.prototype._renderEndsText = function(e, t, n, r, i) {
		if (t) {
			var a = new Wa(), o = this.visualMapModel.textStyleModel;
			a.add(new Tu({ style: Fm(o, {
				x: r ? i === "right" ? n[0] : 0 : n[0] / 2,
				y: n[1] / 2,
				verticalAlign: "middle",
				align: r ? i : "center",
				text: t
			}) })), e.add(a);
		}
	}, t.prototype._getViewData = function() {
		var e = this.visualMapModel, t = L(e.getPieceList(), function(e, t) {
			return {
				piece: e,
				indexInModelPieceList: t
			};
		}), n = e.get("text"), r = e.get("orient"), i = e.get("inverse");
		return (r === "horizontal" ? i : !i) ? t.reverse() : n &&= n.slice().reverse(), {
			viewPieceList: t,
			endsText: n
		};
	}, t.prototype._createItemSymbol = function(e, t, n, r) {
		var i = Ox(this.getControllerVisual(t, "symbol"), n[0], n[1], n[2], n[3], this.getControllerVisual(t, "color"));
		i.silent = r, e.add(i);
	}, t.prototype._onItemClick = function(e) {
		var t = this.visualMapModel, n = t.option, r = n.selectedMode;
		if (r) {
			var i = A(n.selected), a = t.getSelectedMapKey(e);
			r === "single" || r === !0 ? (i[a] = !0, I(i, function(e, t) {
				i[t] = t === a;
			})) : i[a] = !i[a], this.api.dispatchAction({
				type: "selectDataRange",
				from: this.uid,
				visualMapId: this.visualMapModel.id,
				selected: i
			});
		}
	}, t.type = "visualMap.piecewise", t;
}(uH);
//#endregion
//#region node_modules/echarts/lib/component/visualMap/installVisualMapPiecewise.js
function zH(e) {
	e.registerComponentModel(FH), e.registerComponentView(RH), NH(e);
}
//#endregion
//#region node_modules/echarts/lib/component/visualMap/install.js
function BH(e) {
	TD(PH), TD(zH);
}
//#endregion
//#region node_modules/zrender/lib/canvas/Layer.js
function VH(e, t, n) {
	var r = f.createCanvas(), i = t.getWidth(), a = t.getHeight(), o = r.style;
	return o && (o.position = "absolute", o.left = "0", o.top = "0", o.width = i + "px", o.height = a + "px", r.setAttribute("data-zr-dom-id", e)), r.width = i * n, r.height = a * n, r;
}
function HH(e) {
	return !e.__cursors.get(0);
}
function UH(e) {
	var t = e.__cursors.get(0);
	return {
		startIdx: t ? t.startIdx : 0,
		endIdx: t ? t.endIdx : 0
	};
}
var WH = function(e) {
	n(t, e);
	function t(t, n, r) {
		var i = e.call(this) || this;
		i.motionBlur = !1, i.lastFrameAlpha = .7, i.dpr = 1, i.virtual = !1, i.config = {}, i.zlevel = 0, i.zlevel2 = 0, i.maxRepaintRectCount = 5, i.__dirty = !0, i.__firstTimePaint = !0, i.__prevIdx = {
			startIdx: 0,
			endIdx: 0
		};
		var a;
		r ||= Xi, typeof t == "string" ? a = VH(t, n, r) : W(t) && (a = t, t = a.id), i.id = t, i.dom = a;
		var o = a.style;
		return o && (Ne(a), a.onselectstart = function() {
			return !1;
		}, o.padding = "0", o.margin = "0", o.borderWidth = "0"), i.painter = n, i.dpr = r, i;
	}
	return t.prototype.afterBrush = function() {
		this.__prevIdx = UH(this);
	}, t.prototype.initContext = function() {
		this.ctx = this.dom.getContext("2d"), this.ctx.dpr = this.dpr;
	}, t.prototype.setUnpainted = function() {
		this.__firstTimePaint = !0;
	}, t.prototype.createBackBuffer = function() {
		var e = this.dpr;
		this.domBack = VH("back-" + this.id, this.painter, e), this.ctxBack = this.domBack.getContext("2d"), e !== 1 && this.ctxBack.scale(e, e);
	}, t.prototype.createRepaintRects = function(e, t, n, r) {
		if (this.__firstTimePaint) return this.__firstTimePaint = !1, null;
		var i = [], a = this.maxRepaintRectCount, o = !1, s = new Y(0, 0, 0, 0);
		function c(e) {
			if (e.isFinite() && !e.isZero()) {
				if (i.length === 0) {
					var t = new Y(0, 0, 0, 0);
					t.copy(e), i.push(t);
				} else {
					for (var n = !1, r = Infinity, c = 0, l = 0; l < i.length; ++l) {
						var u = i[l];
						if (u.intersect(e)) {
							var d = new Y(0, 0, 0, 0);
							d.copy(u), d.union(e), i[l] = d, n = !0;
							break;
						}
						if (o) {
							s.copy(e), s.union(u);
							var f = e.width * e.height, p = u.width * u.height, m = s.width * s.height - f - p;
							m < r && (r = m, c = l);
						}
					}
					if (o && (i[c].union(e), n = !0), !n) {
						var t = new Y(0, 0, 0, 0);
						t.copy(e), i.push(t);
					}
					o ||= i.length >= a;
				}
			}
		}
		for (var l = UH(this), u = l.startIdx; u < l.endIdx; ++u) {
			var d = e[u];
			if (d) {
				var f = d.shouldBePainted(n, r, !0, !0), p = d.__isRendered && (d.__dirty & 1 || !f) ? d.getPrevPaintRect() : null;
				p && c(p);
				var m = f && (d.__dirty & 1 || !d.__isRendered) ? d.getPaintRect() : null;
				m && c(m);
			}
		}
		for (var h = this.__prevIdx, u = h.startIdx; u < h.endIdx; ++u) {
			var d = t[u], f = d && d.shouldBePainted(n, r, !0, !0);
			if (d && (!f || !d.__zr) && d.__isRendered) {
				var p = d.getPrevPaintRect();
				p && c(p);
			}
		}
		var g;
		do {
			g = !1;
			for (var u = 0; u < i.length;) if (i[u].isZero()) i.splice(u, 1);
			else {
				for (var _ = u + 1; _ < i.length;) i[u].intersect(i[_]) ? (g = !0, i[u].union(i[_]), i.splice(_, 1)) : _++;
				u++;
			}
		} while (g);
		return this._paintRects = i, i;
	}, t.prototype.debugGetPaintRects = function() {
		return (this._paintRects || []).slice();
	}, t.prototype.resize = function(e, t) {
		var n = this.dpr, r = this.dom, i = r.style, a = this.domBack;
		i && (i.width = e + "px", i.height = t + "px"), r.width = e * n, r.height = t * n, a && (a.width = e * n, a.height = t * n, n !== 1 && this.ctxBack.scale(n, n));
	}, t.prototype.clear = function(e, t, n) {
		var r = this.dom, i = this.ctx, a = r.width, o = r.height;
		t ||= this.clearColor;
		var s = this.motionBlur && !e, c = this.lastFrameAlpha, l = this.dpr, u = this;
		s && (this.domBack || this.createBackBuffer(), this.ctxBack.globalCompositeOperation = "copy", this.ctxBack.drawImage(r, 0, 0, a / l, o / l));
		var d = this.domBack;
		function f(e, n, r, a) {
			if (i.clearRect(e, n, r, a), t && t !== "transparent") {
				var o = void 0;
				me(t) ? (o = (t.global || t.__width === r && t.__height === a) && t.__canvasGradient || Px(i, t, {
					x: 0,
					y: 0,
					width: r,
					height: a
				}), t.__canvasGradient = o, t.__width = r, t.__height = a) : he(t) && (t.scaleX = t.scaleX || l, t.scaleY = t.scaleY || l, o = Kx(i, t, { dirty: function() {
					u.setUnpainted(), u.painter.refresh();
				} })), i.save(), i.fillStyle = o || t, i.fillRect(e, n, r, a), i.restore();
			}
			s && (i.save(), i.globalAlpha = c, i.drawImage(d, e, n, r, a), i.restore());
		}
		!n || s ? f(0, 0, a, o) : n.length && I(n, function(e) {
			f(e.x * l, e.y * l, e.width * l, e.height * l);
		});
	}, t;
}(dt), GH = 1e5, KH = 314159, qH = void 0, JH = 1, YH = 2;
function XH(e) {
	return e ? e.__builtin__ ? !0 : typeof e.resize == "function" && typeof e.refresh == "function" : !1;
}
function ZH(e, t) {
	var n = document.createElement("div");
	return n.style.cssText = [
		"position:relative",
		"width:" + e + "px",
		"height:" + t + "px",
		"padding:0",
		"margin:0",
		"border-width:0"
	].join(";") + ";", n;
}
function QH(e, t, n, r) {
	var i = new WH(e, t, t.dpr);
	return i.zlevel = n, i.zlevel2 = r, i.__builtin__ = !0, $H(i), i;
}
function $H(e) {
	e.__cursorStack = [], e.__cursors = K();
}
function eU(e) {
	return e.startIdx = e.drawIdx = e.endIdx = e.endIdxNew = 0, e.used = !1, e.first = e.last = NaN, e.notClearIdx = -1, e;
}
function tU(e, t) {
	var n = e.__cursors, r = +t;
	return n.get(r) || (e.__cursorStack.push(r), n.set(r, eU({ key: r })));
}
function nU(e, t) {
	for (var n = e.__cursorStack, r = 0; r < n.length; r++) t(e.__cursors.get(n[r]));
}
function rU(e, t) {
	var n = e.layers;
	return n[t] || (n[t] = [
		,
		,
		,
	]);
}
function iU(e, t, n) {
	for (var r = e.layerStack, i = 0; i < r.length; i++) {
		var a = r[i].zl, o = r[i].zl2, s = e.layers[a][o];
		(!n || (!(n & aU) || s.__builtin__) && (!(n & oU) || !s.__builtin__) && (!(n & sU) || s !== e.hoverlayer)) && t(s, a, o, i);
	}
}
var aU = 1, oU = 2, sU = 4, cU = aU | sU, lU = function() {
	function e(e, t, n, r) {
		this.type = "canvas", this._prevDisplayList = [], this._layerConfig = {}, this._needsManuallyCompositing = !1, this.type = "canvas", this._i = {
			layerStack: [],
			layers: []
		};
		var i = !e.nodeName || e.nodeName.toUpperCase() === "CANVAS";
		if (this._opts = n = M({}, n || {}), this.dpr = n.devicePixelRatio || Xi, this._singleCanvas = i, this.root = e, e.style && (Ne(e), e.innerHTML = ""), this.storage = t, this._prevDisplayList = [], i) {
			var a = e, o = a.width, s = a.height;
			n.width != null && (o = n.width), n.height != null && (s = n.height), this.dpr = n.devicePixelRatio || 1, a.width = o * this.dpr, a.height = s * this.dpr, this._width = o, this._height = s;
			var c = QH(a, this, KH, 0);
			c.initContext(), this._insertLayer(c, KH, 0, !0), this._domRoot = e;
		} else {
			this._width = Lx(e, 0, n), this._height = Lx(e, 1, n);
			var l = this._domRoot = ZH(this._width, this._height);
			e.appendChild(l);
		}
	}
	return e.prototype.getType = function() {
		return "canvas";
	}, e.prototype.isSingleCanvas = function() {
		return this._singleCanvas;
	}, e.prototype.getViewportRoot = function() {
		return this._domRoot;
	}, e.prototype.getViewportRootOffset = function() {
		var e = this.getViewportRoot();
		if (e) return {
			offsetLeft: e.offsetLeft || 0,
			offsetTop: e.offsetTop || 0
		};
	}, e.prototype.refresh = function(e) {
		var t = e && !W(e) ? { paintAll: !!e } : e || {}, n = G(t.refresh, !0), r = G(t.refreshHover, !1);
		if (r && (this._hoverLayerDirty = YH), !n) return r && this._paintHoverList(this.storage.getDisplayList(!1)), this;
		var i = this.storage.getDisplayList(!0);
		this._updateLayerStatus(i, t.paintAll), this._redrawId = Math.random();
		var a = this._prevDisplayList;
		this._paintList(i, a, this._redrawId);
		var o = this._backgroundColor;
		return iU(this._i, function(e, t, n, r) {
			e.refresh && e.refresh(r === 0 ? o : null);
		}, oU), this._opts.useDirtyRect && (this._prevDisplayList = i.slice()), this;
	}, e.prototype._paintHoverList = function(e) {
		var t = this._i.hoverlayer, n = this._hoverLayerDirty;
		if (this._hoverLayerDirty = qH, n !== qH && (!t && n === YH && (t = this._i.hoverlayer = this._ensureLayer(GH)), t)) {
			t.clear();
			for (var r = {
				inHover: !0,
				viewWidth: this._width,
				viewHeight: this._height,
				beforeBrushParam: {}
			}, i, a = 0, o = e.length; a < o; a++) {
				var s = e[a];
				if (s.__inHover) {
					i || (i = t.ctx, i.save());
					var c = s.__hoverStyle, l = void 0;
					c && (l = s.style, s.style = c), dS(i, s, r), c && (s.style = l);
				}
			}
			i && (fS(i, r), i.restore());
		}
	}, e.prototype.getHoverLayer = function() {
		return this._ensureLayer(GH);
	}, e.prototype.paintOne = function(e, t) {
		uS(e, t);
	}, e.prototype._paintList = function(e, t, n) {
		if (this._redrawId === n) {
			var r = this._doPaintList(e, t);
			if (this._needsManuallyCompositing && this._compositeManually(), r) iU(this._i, function(e) {
				e.afterBrush && e.afterBrush();
			}, cU), this._paintHoverList(e);
			else {
				var i = this;
				Jn(function() {
					i._paintList(e, t, n);
				});
			}
		}
	}, e.prototype._compositeManually = function() {
		var e = this._ensureLayer(KH).ctx, t = this._domRoot.width, n = this._domRoot.height;
		e.clearRect(0, 0, t, n), iU(this._i, function(r) {
			r.virtual && e.drawImage(r.dom, 0, 0, t, n);
		}, aU);
	}, e.prototype._doPaintList = function(e, t) {
		var n = this, r = !0;
		return iU(this._i, function(i) {
			var a = !1;
			if (nU(i, function(e) {
				(e.drawIdx < e.endIdx || e.notClearIdx >= 0) && (a = !0);
			}), a || i.__dirty) {
				var o = n._opts.useDirtyRect && !HH(i) ? i.createRepaintRects(e, t, n._width, n._height) : null, s = n._i.layerStack[0], c = !0;
				if (i.__dirty) {
					c = !1, i.__dirty = !1;
					var l = i.zlevel === s.zl && i.zlevel2 === s.zl2 ? n._backgroundColor : null;
					i.clear(!1, l, o);
				}
				nU(i, function(t) {
					var a = n._paintPerCursor(i, t, e, o, c);
					r &&= a;
				});
			}
		}, cU), i.wxa && iU(this._i, function(e) {
			e && e.ctx && e.ctx.draw && e.ctx.draw();
		}), r;
	}, e.prototype._paintPerCursor = function(e, t, n, r, i) {
		var a = e.ctx;
		if (r) {
			if (!r.length) t.drawIdx = t.endIdx;
			else for (var o = this.dpr, s = 0; s < r.length; ++s) {
				var c = r[s];
				a.save(), a.beginPath(), a.rect(c.x * o, c.y * o, c.width * o, c.height * o), a.clip(), this._paintPerCursorInRect(e, t, n, c, i), a.restore();
			}
		} else a.save(), this._paintPerCursorInRect(e, t, n, null, i), a.restore();
		return t.drawIdx >= t.endIdx;
	}, e.prototype._paintPerCursorInRect = function(e, t, n, r, i) {
		for (var a = {
			inHover: !1,
			allClipped: !1,
			prevEl: null,
			viewWidth: this._width,
			viewHeight: this._height,
			beforeBrushParam: { contentRetained: i }
		}, o = e.ctx, s = HH(e), c = s && f.getTime(), l = t.drawIdx, u = t.notClearIdx, d = u >= 0 ? Math.min(u, l) : l; d < t.endIdx; d++) {
			var p = n[d];
			if (!(d < l && !p.notClear)) {
				if (p.__inHover && (this._hoverLayerDirty = YH), r != null) {
					var m = p.getPaintRect();
					m && m.intersect(r) && (dS(o, p, a), p.setPrevPaintRect(m));
				} else dS(o, p, a);
				if (s && f.getTime() - c > 15) {
					d++;
					break;
				}
			}
		}
		fS(o, a), t.drawIdx = Math.max(d, l);
	}, e.prototype.getLayer = function(e, t) {
		return this._ensureLayer(e, 0, t);
	}, e.prototype._ensureLayer = function(e, t, n) {
		t ||= 0;
		var r = this._singleCanvas;
		r && !this._needsManuallyCompositing && (e = KH, t = 0);
		var i = rU(this._i, e)[t];
		return i || (i = QH("zr_" + e + "." + t, this, e, t), this._layerConfig[e] && j(i, this._layerConfig[e], !0), (n || r && e !== KH) && (i.virtual = !0), this._insertLayer(i, e, t, !1), i.initContext()), i;
	}, e.prototype.insertLayer = function(e, t) {
		this._insertLayer(t, e, 0, !1);
	}, e.prototype._insertLayer = function(e, t, n, r) {
		var i = this._i, a = i.layers, o = i.layerStack, s = this._domRoot, c = null;
		if (!(a[t] && a[t][n]) && XH(e)) {
			for (var l = o.length, u = 0; u < l && (o[u].zl < t || o[u].zl === t && o[u].zl2 < n);) u++;
			if (u > 0 && (c = rU(i, o[u - 1].zl)[o[u - 1].zl2]), o.splice(u, 0, {
				zl: t,
				zl2: n
			}), rU(i, t)[n] = e, !r && !e.virtual) {
				if (c) {
					var d = c.dom;
					d.nextSibling ? s.insertBefore(e.dom, d.nextSibling) : s.appendChild(e.dom);
				} else s.firstChild ? s.insertBefore(e.dom, s.firstChild) : s.appendChild(e.dom);
			}
			e.painter ||= this;
		}
	}, e.prototype.eachLayer = function(e, t) {
		return iU(this._i, function(n, r) {
			e.call(t, n, r);
		});
	}, e.prototype.eachBuiltinLayer = function(e, t) {
		return iU(this._i, function(n, r) {
			e.call(t, n, r);
		}, aU);
	}, e.prototype.eachOtherLayer = function(e, t) {
		return iU(this._i, function(n, r) {
			e.call(t, n, r);
		}, oU);
	}, e.prototype.getLayers = function() {
		var e = {};
		return iU(this._i, function(t, n, r) {
			e[t.id] = t;
		}), e;
	}, e.prototype._updateLayerStatus = function(e, t) {
		var n = this;
		if (n._singleCanvas) for (var r = 1; r < e.length; r++) {
			var i = e[r];
			if (i.zlevel !== e[r - 1].zlevel || i.incremental) {
				n._needsManuallyCompositing = !0;
				break;
			}
		}
		iU(n._i, function(e) {
			e.__dirty = !1, nU(e, function(e) {
				e.used = !1, e.endIdxNew = 0, e.notClearIdx = -1;
			});
		}, cU);
		for (var a, o = null, s = null, c = !1, l = 0, u = e.length; l < u; l++) {
			var i = e[l], d = i.zlevel, f = i.incremental, p = void 0;
			if (a !== d && (a = d, c = !1), f ? (c = !0, p = 1) : p = c ? 2 : 0, (!o || d !== o.zlevel || p !== o.zlevel2) && (o = n._ensureLayer(d, p), s = null, !o.__builtin__)) k("ZLevel " + d + " has been used by unknown layer " + o.id);
			else {
				if ((!s || f !== s.key) && (s = tU(o, f), !s.used)) {
					if (s.used = !0, !t && s.first === i.id) {
						var m = l - s.startIdx;
						s.startIdx = l, s.drawIdx += m, s.endIdx += m;
					} else o.__dirty = !0, s.first = i.id, s.startIdx = s.drawIdx = l, s.endIdx = l + 1;
				}
				s.endIdxNew = l + 1, i.__dirty & 1 && !i.__inHover && ((!f || !i.notClear && l < s.drawIdx) && (o.__dirty = !0), f && i.notClear && s.notClearIdx < 0 && (s.notClearIdx = l));
			}
		}
		iU(n._i, function(t) {
			for (var r = t.__cursorStack, i = t.__cursors, a = r.length - 1; a >= 0; a--) {
				var o = i.get(r[a]);
				if (!o.used) t.__dirty = !0, i.removeKey(r[a]), r.splice(a, 1);
				else {
					var s = o.endIdxNew;
					(HH(t) ? s < o.drawIdx : s !== o.endIdx || !s || e[s - 1].id !== o.last) && (t.__dirty = !0), o.endIdx = o.endIdxNew, o.last = s ? e[s - 1].id : NaN;
				}
			}
			t.__dirty && (nU(t, function(e) {
				e.drawIdx = e.startIdx;
			}), n._hoverLayerDirty === qH && (n._hoverLayerDirty = JH));
		}, cU);
	}, e.prototype.clear = function() {
		return iU(this._i, function(e) {
			e.clear(), $H(e);
		}, aU), this;
	}, e.prototype.setBackgroundColor = function(e) {
		this._backgroundColor = e, iU(this._i, function(e) {
			e.setUnpainted();
		});
	}, e.prototype.configLayer = function(e, t) {
		if (t) {
			var n = this._layerConfig;
			n[e] ? j(n[e], t, !0) : n[e] = t, iU(this._i, function(e, t) {
				j(e, n[t], !0);
			});
		}
	}, e.prototype.delLayer = function(e) {
		for (var t = this._i.layerStack, n = this._i.layers, r = t.length - 1; r >= 0; r--) {
			var i = t[r];
			if (i.zl === e) {
				var a = n[e][i.zl2];
				if (a.__builtin__) continue;
				if (t.splice(r, 1), n[e][i.zl2] = void 0, !a.virtual) {
					var o = a.dom.parentNode;
					o && o.removeChild(a.dom);
				}
			}
		}
	}, e.prototype.resize = function(e, t) {
		if (this._domRoot.style) {
			var n = this._domRoot;
			n.style.display = "none";
			var r = this._opts, i = this.root;
			e != null && (r.width = e), t != null && (r.height = t), e = Lx(i, 0, r), t = Lx(i, 1, r), n.style.display = "", (this._width !== e || t !== this._height) && (n.style.width = e + "px", n.style.height = t + "px", iU(this._i, function(n) {
				n.resize(e, t);
			}), this.refresh({ paintAll: !0 })), this._width = e, this._height = t;
		} else {
			if (e == null || t == null) return;
			this._width = e, this._height = t, this._ensureLayer(KH).resize(e, t);
		}
		return this;
	}, e.prototype.clearLayer = function(e) {
		I(this._i.layers[e], function(e) {
			e && !e.__builtin__ && e.clear();
		});
	}, e.prototype.dispose = function() {
		this.root.innerHTML = "", this.root = this.storage = this._domRoot = this._i = null;
	}, e.prototype.getRenderedCanvas = function(e) {
		if (e ||= {}, this._singleCanvas && !this._compositeManually) return this._i.layers[KH][0].dom;
		var t = new WH("image", this, e.pixelRatio || this.dpr);
		t.initContext(), t.clear(!1, e.backgroundColor || this._backgroundColor);
		var n = t.ctx;
		if (e.pixelRatio <= this.dpr) {
			this.refresh();
			var r = t.dom.width, i = t.dom.height;
			iU(this._i, function(e) {
				e.__builtin__ ? n.drawImage(e.dom, 0, 0, r, i) : e.renderToCanvas && (n.save(), e.renderToCanvas(n), n.restore());
			});
		} else {
			for (var a = {
				inHover: !1,
				viewWidth: this._width,
				viewHeight: this._height,
				beforeBrushParam: {}
			}, o = this.storage.getDisplayList(!0), s = 0, c = o.length; s < c; s++) {
				var l = o[s];
				dS(n, l, a);
			}
			fS(n, a);
		}
		return t.dom;
	}, e.prototype.getWidth = function() {
		return this._width;
	}, e.prototype.getHeight = function() {
		return this._height;
	}, e;
}();
//#endregion
//#region node_modules/echarts/lib/renderer/installCanvasRenderer.js
function uU(e) {
	e.registerPainter("canvas", lU);
}
//#endregion
//#region src/lib/echarts-core.ts
TD([
	SM,
	GI,
	pL,
	kA,
	oL,
	GM,
	ZN,
	oI,
	NR,
	bV,
	JB,
	LB,
	DB,
	iB,
	Xz,
	BH,
	ZV,
	ZR,
	Ck,
	uU
]);
var dU = wk;
//#endregion
export { dU as default };

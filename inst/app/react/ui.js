import { i as e, n as t, r as n, t as r } from "./chunks/rolldown-runtime-Cb76FRpK.js";
//#region src/shims/react.ts
var i = /* @__PURE__ */ n({
	Activity: () => o,
	Children: () => s,
	Component: () => c,
	Fragment: () => l,
	Profiler: () => u,
	PureComponent: () => d,
	StrictMode: () => f,
	Suspense: () => p,
	ViewTransition: () => m,
	__CLIENT_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE: () => h,
	__COMPILER_RUNTIME: () => g,
	act: () => _,
	addTransitionType: () => v,
	cache: () => y,
	cacheSignal: () => b,
	captureOwnerStack: () => x,
	cloneElement: () => S,
	createContext: () => C,
	createElement: () => w,
	createRef: () => ee,
	default: () => a,
	forwardRef: () => T,
	isValidElement: () => te,
	lazy: () => ne,
	memo: () => re,
	startTransition: () => ie,
	unstable_useCacheRefresh: () => ae,
	use: () => oe,
	useActionState: () => se,
	useCallback: () => ce,
	useContext: () => le,
	useDebugValue: () => ue,
	useDeferredValue: () => de,
	useEffect: () => E,
	useEffectEvent: () => fe,
	useId: () => pe,
	useImperativeHandle: () => me,
	useInsertionEffect: () => he,
	useLayoutEffect: () => ge,
	useMemo: () => _e,
	useOptimistic: () => ve,
	useReducer: () => ye,
	useRef: () => D,
	useState: () => O,
	useSyncExternalStore: () => be,
	useTransition: () => xe,
	version: () => Se
}), a, o, s, c, l, u, d, f, p, m, h, g, _, v, y, b, x, S, C, w, ee, T, te, ne, re, ie, ae, oe, se, ce, le, ue, de, E, fe, pe, me, he, ge, _e, ve, ye, D, O, be, xe, Se, k = t((() => {
	a = window.shinyreact.React, {Activity: o, Children: s, Component: c, Fragment: l, Profiler: u, PureComponent: d, StrictMode: f, Suspense: p, ViewTransition: m, __CLIENT_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE: h, __COMPILER_RUNTIME: g, act: _, addTransitionType: v, cache: y, cacheSignal: b, captureOwnerStack: x, cloneElement: S, createContext: C, createElement: w, createRef: ee, forwardRef: T, isValidElement: te, lazy: ne, memo: re, startTransition: ie, unstable_useCacheRefresh: ae, use: oe, useActionState: se, useCallback: ce, useContext: le, useDebugValue: ue, useDeferredValue: de, useEffect: E, useEffectEvent: fe, useId: pe, useImperativeHandle: me, useInsertionEffect: he, useLayoutEffect: ge, useMemo: _e, useOptimistic: ve, useReducer: ye, useRef: D, useState: O, useSyncExternalStore: be, useTransition: xe, version: Se} = a;
})), Ce = (e) => e?.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase();
//#endregion
//#region node_modules/lucide-react/dist/esm/shared/src/utils/toLucideIconData.mjs
function we(e, t, n = []) {
	if (t == null) throw Error("[lucide]: iconNode is required when icon name is used");
	return {
		name: Ce(e),
		size: 24,
		node: t,
		...n.length > 0 ? { aliases: n } : {}
	};
}
//#endregion
//#region node_modules/lucide-react/dist/esm/shared/src/utils/toCamelCase.mjs
var Te = (e) => {
	let t = "", n = !1;
	for (let r of e) r === "-" || r === "_" || r <= " " ? n = t.length > 0 : (t.length === 0 ? t += r.toLowerCase() : t += n ? r.toUpperCase() : r, n = !1);
	return t;
}, Ee = (e) => {
	let t = Te(e);
	return t.charAt(0).toUpperCase() + t.slice(1);
}, De = (...e) => e.filter((e, t, n) => !!e && e.trim() !== "" && n.indexOf(e) === t).join(" ").trim(), Oe = {
	xmlns: "http://www.w3.org/2000/svg",
	width: 24,
	height: 24,
	viewBox: "0 0 24 24",
	fill: "none",
	stroke: "currentColor",
	"stroke-width": 2,
	"stroke-linecap": "round",
	"stroke-linejoin": "round"
};
//#endregion
//#region node_modules/lucide-react/dist/esm/shared/src/build/buildLucideIconNode.mjs
function ke(e) {
	return e != null;
}
function Ae(e, t = {}) {
	let n = t.attributeNames ?? {}, r = (e) => n[e] ?? e, i = e.size ?? e.width ?? Oe.width, a = e.size ?? e.height ?? Oe.height, o = e.aliases?.filter((e) => typeof e == "string" && e.trim() !== "").map((e) => `lucide-${e}`) ?? [], s = [...e.name ? [`lucide-${e.name}`] : [], ...o], c = t.className?.split(" ").filter(Boolean) ?? [], l = t.includeDefaultClasses === !1 ? De(...c) : De("lucide", ...s, ...c), u = t.absoluteStrokeWidth ? Number(t.strokeWidth ?? Oe["stroke-width"]) * Number(e.size ?? e.width ?? Oe.width) / Number(t.size ?? t.width ?? Oe.width) : t.strokeWidth ?? Oe["stroke-width"];
	return [
		"svg",
		{
			...Object.entries(Oe).reduce((e, [t, n]) => (e[r(t)] = n, e), {}),
			..."color" in t && t.color && { [r("stroke")]: t.color },
			..."size" in t && ke(t.size) && {
				[r("width")]: t.size,
				[r("height")]: t.size
			},
			..."width" in t && ke(t.width) && { [r("width")]: t.width },
			..."height" in t && ke(t.height) && { [r("height")]: t.height },
			[r("stroke-width")]: u,
			...l && { [r("class")]: l },
			[r("viewBox")]: `0 0 ${i} ${a}`,
			...t.hasA11yProp === !1 ? { [r("aria-hidden")]: "true" } : {},
			..."attributes" in t && t.attributes
		},
		e.node.map((e) => {
			let [n, i, a] = e, o = t.nonScalingStroke ? {
				[r("vector-effect")]: "non-scaling-stroke",
				...i
			} : i;
			return a ? [
				n,
				o,
				a
			] : [n, o];
		})
	];
}
//#endregion
//#region node_modules/lucide-react/dist/esm/shared/src/build/buildLucideIconForReact.mjs
function je(e, t = {}) {
	return Ae(e, {
		...t,
		attributeNames: {
			...t.attributeNames,
			class: "className",
			"stroke-width": "strokeWidth",
			"stroke-linecap": "strokeLinecap",
			"stroke-linejoin": "strokeLinejoin",
			"vector-effect": "vectorEffect"
		}
	});
}
//#endregion
//#region node_modules/lucide-react/dist/esm/shared/src/utils/hasA11yProp.mjs
var Me = (e) => {
	for (let t in e) if (t.startsWith("aria-") || t === "role" || t === "title") return !0;
	return !1;
};
//#endregion
//#region node_modules/lucide-react/dist/esm/context.mjs
k();
var Ne = C({}), Pe = () => le(Ne);
//#endregion
//#region node_modules/lucide-react/dist/esm/Icon.mjs
k();
var Fe = T(({ color: e, size: t, width: n, height: r, strokeWidth: i, absoluteStrokeWidth: a, nonScalingStroke: o, className: s = "", children: c, iconNode: l = [], icon: u = {
	node: l,
	aliases: [],
	size: 24
}, ...d }, f) => {
	let { size: p = 24, strokeWidth: m = 2, absoluteStrokeWidth: h = !1, nonScalingStroke: g = !1, color: _ = "currentColor", className: v = "" } = Pe() ?? {}, y = !!c || Me(d), [b, x, S = []] = je(u, {
		color: e ?? _,
		width: n ?? t ?? p,
		height: r ?? t ?? p,
		strokeWidth: i ?? m,
		absoluteStrokeWidth: a ?? h,
		nonScalingStroke: o ?? g,
		className: De(v, s),
		hasA11yProp: y,
		attributes: d
	});
	return w(b, {
		ref: f,
		...x
	}, [...S.map(([e, t]) => w(e, t)), ...Array.isArray(c) ? c : [c]]);
});
//#endregion
//#region node_modules/lucide-react/dist/esm/createLucideIcon.mjs
k();
function A(e, t = [], n = []) {
	let r = typeof e == "string" ? we(e, t, n) : e, i = T(({ className: e, ...t }, n) => w(Fe, {
		ref: n,
		icon: r,
		className: e,
		...t
	}));
	return r.name && (i.displayName = Ee(r.name)), i;
}
//#endregion
//#region node_modules/lucide-react/dist/esm/icons/activity.mjs
var Ie = {
	name: "activity",
	size: 24,
	node: [["path", {
		d: "M22 12h-2.48a2 2 0 0 0-1.93 1.46l-2.35 8.36a.25.25 0 0 1-.48 0L9.24 2.18a.25.25 0 0 0-.48 0l-2.35 8.36A2 2 0 0 1 4.49 12H2",
		key: "169zse"
	}]]
};
Ie.node;
var Le = A(Ie), Re = {
	name: "arrow-down-up",
	size: 24,
	node: [
		["path", {
			d: "m3 16 4 4 4-4",
			key: "1co6wj"
		}],
		["path", {
			d: "M7 20V4",
			key: "1yoxec"
		}],
		["path", {
			d: "m21 8-4-4-4 4",
			key: "1c9v7m"
		}],
		["path", {
			d: "M17 4v16",
			key: "7dpous"
		}]
	]
};
Re.node;
var ze = A(Re), Be = {
	name: "arrow-down-wide-narrow",
	size: 24,
	node: [
		["path", {
			d: "m3 16 4 4 4-4",
			key: "1co6wj"
		}],
		["path", {
			d: "M7 20V4",
			key: "1yoxec"
		}],
		["path", {
			d: "M11 4h10",
			key: "1w87gc"
		}],
		["path", {
			d: "M11 8h7",
			key: "djye34"
		}],
		["path", {
			d: "M11 12h4",
			key: "q8tih4"
		}]
	],
	aliases: ["sort-desc"]
};
Be.node;
var Ve = A(Be), He = {
	name: "arrow-down",
	size: 24,
	node: [["path", {
		d: "M12 5v14",
		key: "s699le"
	}], ["path", {
		d: "m19 12-7 7-7-7",
		key: "1idqje"
	}]]
};
He.node;
var Ue = A(He), We = {
	name: "arrow-left",
	size: 24,
	node: [["path", {
		d: "m12 19-7-7 7-7",
		key: "1l729n"
	}], ["path", {
		d: "M19 12H5",
		key: "x3x0zl"
	}]]
};
We.node;
var Ge = A(We), Ke = {
	name: "arrow-right",
	size: 24,
	node: [["path", {
		d: "M5 12h14",
		key: "1ays0h"
	}], ["path", {
		d: "m12 5 7 7-7 7",
		key: "xquz4c"
	}]]
};
Ke.node;
var qe = A(Ke), Je = {
	name: "arrow-up",
	size: 24,
	node: [["path", {
		d: "m5 12 7-7 7 7",
		key: "hav0vg"
	}], ["path", {
		d: "M12 19V5",
		key: "x0mq9r"
	}]]
};
Je.node;
var Ye = A(Je), Xe = {
	name: "badge-check",
	size: 24,
	node: [["path", {
		d: "M3.85 8.62a4 4 0 0 1 4.78-4.77 4 4 0 0 1 6.74 0 4 4 0 0 1 4.78 4.78 4 4 0 0 1 0 6.74 4 4 0 0 1-4.77 4.78 4 4 0 0 1-6.75 0 4 4 0 0 1-4.78-4.77 4 4 0 0 1 0-6.76Z",
		key: "3c2336"
	}], ["path", {
		d: "m16 9-5.5 5.5L8 12",
		key: "xofnsj"
	}]],
	aliases: ["verified"]
};
Xe.node;
var Ze = A(Xe), Qe = {
	name: "banknote",
	size: 24,
	node: [
		["rect", {
			width: "20",
			height: "12",
			x: "2",
			y: "6",
			rx: "2",
			key: "9lu3g6"
		}],
		["circle", {
			cx: "12",
			cy: "12",
			r: "2",
			key: "1c9p78"
		}],
		["path", {
			d: "M6 12h.01M18 12h.01",
			key: "113zkx"
		}]
	]
};
Qe.node;
var $e = A(Qe), et = {
	name: "bold",
	size: 24,
	node: [["path", {
		d: "M6 12h9a4 4 0 0 1 0 8H7a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h7a4 4 0 0 1 0 8",
		key: "mg9rjx"
	}]]
};
et.node;
var tt = A(et), nt = {
	name: "book-bookmark",
	size: 24,
	node: [["path", {
		d: "M10 2v7.751a.25.25 0 00.407.195l2.28-1.834a.5.5 0 01.627 0l2.28 1.834A.25.25 0 0016 9.751V2",
		key: "x9x4jl"
	}], ["path", {
		d: "M4 19.5v-15A2.5 2.5 0 016.5 2H19a1 1 0 011 1v18a1 1 0 01-1 1H6.5a1 1 0 010-5H20",
		key: "1889un"
	}]],
	aliases: ["book-marked"]
};
nt.node;
var rt = A(nt), it = {
	name: "book-open",
	size: 24,
	node: [["path", {
		d: "M12 5v16",
		key: "1f6ucr"
	}], ["path", {
		d: "M20.001 19A2 2 0 0022 17V5a2 2 0 00-1.999-2L16 3.002A5 5 0 0012 5a5 5 0 00-4-2H4a2 2 0 00-2 2v12a2 2 0 001.999 2H8a5 5 0 014 2 5 5 0 014-2z",
		key: "1fyvmf"
	}]]
};
it.node;
var at = A(it), ot = {
	name: "calculator",
	size: 24,
	node: [
		["rect", {
			width: "16",
			height: "20",
			x: "4",
			y: "2",
			rx: "2",
			key: "1nb95v"
		}],
		["line", {
			x1: "8",
			x2: "16",
			y1: "6",
			y2: "6",
			key: "x4nwl0"
		}],
		["line", {
			x1: "16",
			x2: "16",
			y1: "14",
			y2: "18",
			key: "wjye3r"
		}],
		["path", {
			d: "M16 10h.01",
			key: "1m94wz"
		}],
		["path", {
			d: "M12 10h.01",
			key: "1nrarc"
		}],
		["path", {
			d: "M8 10h.01",
			key: "19clt8"
		}],
		["path", {
			d: "M12 14h.01",
			key: "1etili"
		}],
		["path", {
			d: "M8 14h.01",
			key: "6423bh"
		}],
		["path", {
			d: "M12 18h.01",
			key: "mhygvu"
		}],
		["path", {
			d: "M8 18h.01",
			key: "lrp35t"
		}]
	]
};
ot.node;
var st = A(ot), ct = {
	name: "calendar-days",
	size: 24,
	node: [
		["path", {
			d: "M8 2v3",
			key: "1ioesn"
		}],
		["path", {
			d: "M16 2v3",
			key: "otl347"
		}],
		["rect", {
			x: "3",
			y: "3",
			width: "18",
			height: "18",
			rx: "2",
			key: "h1oib"
		}],
		["path", {
			d: "M3 9h18",
			key: "1pudct"
		}],
		["path", {
			d: "M8 13h.01",
			key: "1sbv64"
		}],
		["path", {
			d: "M12 13h.01",
			key: "y0uutt"
		}],
		["path", {
			d: "M16 13h.01",
			key: "wip0gl"
		}],
		["path", {
			d: "M8 17h.01",
			key: "p3bg7i"
		}],
		["path", {
			d: "M12 17h.01",
			key: "p32p05"
		}],
		["path", {
			d: "M16 17h.01",
			key: "ql8jdd"
		}]
	]
};
ct.node;
var lt = A(ct), ut = {
	name: "calendar-range",
	size: 24,
	node: [
		["rect", {
			x: "3",
			y: "3",
			width: "18",
			height: "18",
			rx: "2",
			key: "h1oib"
		}],
		["path", {
			d: "M16 2v3",
			key: "otl347"
		}],
		["path", {
			d: "M3 9h18",
			key: "1pudct"
		}],
		["path", {
			d: "M8 2v3",
			key: "1ioesn"
		}],
		["path", {
			d: "M17 13h-6",
			key: "1qbiup"
		}],
		["path", {
			d: "M13 17H7",
			key: "1x38vv"
		}],
		["path", {
			d: "M7 13h.01",
			key: "1vezk1"
		}],
		["path", {
			d: "M17 17h.01",
			key: "1sd3ek"
		}]
	]
};
ut.node;
var dt = A(ut), ft = {
	name: "calendar-x",
	size: 24,
	node: [
		["path", {
			d: "M8 2v3",
			key: "1ioesn"
		}],
		["path", {
			d: "M16 2v3",
			key: "otl347"
		}],
		["rect", {
			x: "3",
			y: "3",
			width: "18",
			height: "18",
			rx: "2",
			key: "h1oib"
		}],
		["path", {
			d: "M3 9h18",
			key: "1pudct"
		}],
		["path", {
			d: "m14 13-4 4",
			key: "1gib57"
		}],
		["path", {
			d: "m10 13 4 4",
			key: "153uiq"
		}]
	]
};
ft.node;
var pt = A(ft), mt = {
	name: "calendar",
	size: 24,
	node: [
		["path", {
			d: "M8 2v3",
			key: "1ioesn"
		}],
		["path", {
			d: "M16 2v3",
			key: "otl347"
		}],
		["rect", {
			x: "3",
			y: "3",
			width: "18",
			height: "18",
			rx: "2",
			key: "h1oib"
		}],
		["path", {
			d: "M3 9h18",
			key: "1pudct"
		}]
	]
};
mt.node;
var ht = A(mt), gt = {
	name: "chart-bar",
	size: 24,
	node: [
		["path", {
			d: "M3 3v16a2 2 0 0 0 2 2h16",
			key: "c24i48"
		}],
		["path", {
			d: "M7 16h8",
			key: "srdodz"
		}],
		["path", {
			d: "M7 11h12",
			key: "127s9w"
		}],
		["path", {
			d: "M7 6h3",
			key: "w9rmul"
		}]
	],
	aliases: ["bar-chart-horizontal"]
};
gt.node;
var _t = A(gt), vt = {
	name: "chart-column",
	size: 24,
	node: [
		["path", {
			d: "M3 3v16a2 2 0 0 0 2 2h16",
			key: "c24i48"
		}],
		["path", {
			d: "M18 17V9",
			key: "2bz60n"
		}],
		["path", {
			d: "M13 17V5",
			key: "1frdt8"
		}],
		["path", {
			d: "M8 17v-3",
			key: "17ska0"
		}]
	],
	aliases: ["bar-chart-3"]
};
vt.node;
var yt = A(vt), bt = {
	name: "chart-pie",
	size: 24,
	node: [["path", {
		d: "M21 12c.552 0 1.005-.449.95-.998a10 10 0 0 0-8.953-8.951c-.55-.055-.998.398-.998.95v8a1 1 0 0 0 1 1z",
		key: "pzmjnu"
	}], ["path", {
		d: "M21.21 15.89A10 10 0 1 1 8 2.83",
		key: "k2fpak"
	}]],
	aliases: ["pie-chart"]
};
bt.node;
var xt = A(bt), St = {
	name: "check-check",
	size: 24,
	node: [["path", {
		d: "M18 6 7 17l-5-5",
		key: "116fxf"
	}], ["path", {
		d: "m22 10-7.5 7.5L13 16",
		key: "ke71qq"
	}]]
};
St.node;
var Ct = A(St), wt = {
	name: "check",
	size: 24,
	node: [["path", {
		d: "M20 6 9 17l-5-5",
		key: "1gmf2c"
	}]]
};
wt.node;
var Tt = A(wt), Et = {
	name: "chevron-down",
	size: 24,
	node: [["path", {
		d: "m6 9 6 6 6-6",
		key: "qrunsl"
	}]]
};
Et.node;
var Dt = A(Et), Ot = {
	name: "chevron-left",
	size: 24,
	node: [["path", {
		d: "m15 18-6-6 6-6",
		key: "1wnfg3"
	}]]
};
Ot.node;
var kt = A(Ot), At = {
	name: "chevron-right",
	size: 24,
	node: [["path", {
		d: "m9 18 6-6-6-6",
		key: "mthhwq"
	}]]
};
At.node;
var jt = A(At), Mt = {
	name: "circle-alert",
	size: 24,
	node: [
		["circle", {
			cx: "12",
			cy: "12",
			r: "10",
			key: "1mglay"
		}],
		["line", {
			x1: "12",
			x2: "12",
			y1: "8",
			y2: "12",
			key: "1pkeuh"
		}],
		["line", {
			x1: "12",
			x2: "12.01",
			y1: "16",
			y2: "16",
			key: "4dfq90"
		}]
	],
	aliases: ["alert-circle"]
};
Mt.node;
var Nt = A(Mt), Pt = {
	name: "circle-arrow-down",
	size: 24,
	node: [
		["circle", {
			cx: "12",
			cy: "12",
			r: "10",
			key: "1mglay"
		}],
		["path", {
			d: "M12 8v8",
			key: "napkw2"
		}],
		["path", {
			d: "m8 12 4 4 4-4",
			key: "k98ssh"
		}]
	],
	aliases: ["arrow-down-circle"]
};
Pt.node;
var Ft = A(Pt), It = {
	name: "circle-check",
	size: 24,
	node: [["circle", {
		cx: "12",
		cy: "12",
		r: "10",
		key: "1mglay"
	}], ["path", {
		d: "m16 9-5.5 5.5L8 12",
		key: "xofnsj"
	}]],
	aliases: ["check-circle-2"]
};
It.node;
var Lt = A(It), Rt = {
	name: "circle-dashed",
	size: 24,
	node: [
		["path", {
			d: "M10.1 2.182a10 10 0 0 1 3.8 0",
			key: "5ilxe3"
		}],
		["path", {
			d: "M13.9 21.818a10 10 0 0 1-3.8 0",
			key: "11zvb9"
		}],
		["path", {
			d: "M17.609 3.721a10 10 0 0 1 2.69 2.7",
			key: "1iw5b2"
		}],
		["path", {
			d: "M2.182 13.9a10 10 0 0 1 0-3.8",
			key: "c0bmvh"
		}],
		["path", {
			d: "M20.279 17.609a10 10 0 0 1-2.7 2.69",
			key: "1ruxm7"
		}],
		["path", {
			d: "M21.818 10.1a10 10 0 0 1 0 3.8",
			key: "qkgqxc"
		}],
		["path", {
			d: "M3.721 6.391a10 10 0 0 1 2.7-2.69",
			key: "1mcia2"
		}],
		["path", {
			d: "M6.391 20.279a10 10 0 0 1-2.69-2.7",
			key: "1fvljs"
		}]
	]
};
Rt.node;
var zt = A(Rt), Bt = {
	name: "circle-minus",
	size: 24,
	node: [["circle", {
		cx: "12",
		cy: "12",
		r: "10",
		key: "1mglay"
	}], ["path", {
		d: "M8 12h8",
		key: "1wcyev"
	}]],
	aliases: ["minus-circle"]
};
Bt.node;
var Vt = A(Bt), Ht = {
	name: "circle-question-mark",
	size: 24,
	node: [
		["circle", {
			cx: "12",
			cy: "12",
			r: "10",
			key: "1mglay"
		}],
		["path", {
			d: "M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3",
			key: "1u773s"
		}],
		["path", {
			d: "M12 17h.01",
			key: "p32p05"
		}]
	],
	aliases: ["help-circle", "circle-help"]
};
Ht.node;
var Ut = A(Ht), Wt = {
	name: "circle-user-round",
	size: 24,
	node: [
		["path", {
			d: "M17.925 20.056a6 6 0 0 0-11.851.001",
			key: "z69sun"
		}],
		["circle", {
			cx: "12",
			cy: "11",
			r: "4",
			key: "1gt34v"
		}],
		["circle", {
			cx: "12",
			cy: "12",
			r: "10",
			key: "1mglay"
		}]
	],
	aliases: ["user-circle-2"]
};
Wt.node;
var Gt = A(Wt), Kt = {
	name: "circle-x",
	size: 24,
	node: [
		["circle", {
			cx: "12",
			cy: "12",
			r: "10",
			key: "1mglay"
		}],
		["path", {
			d: "m15 9-6 6",
			key: "1uzhvr"
		}],
		["path", {
			d: "m9 9 6 6",
			key: "z0biqf"
		}]
	],
	aliases: ["x-circle"]
};
Kt.node;
var qt = A(Kt), Jt = {
	name: "clipboard-check",
	size: 24,
	node: [
		["rect", {
			width: "8",
			height: "4",
			x: "8",
			y: "2",
			rx: "1",
			ry: "1",
			key: "tgr4d6"
		}],
		["path", {
			d: "M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2",
			key: "116196"
		}],
		["path", {
			d: "m9 14 2 2 4-4",
			key: "df797q"
		}]
	]
};
Jt.node;
var Yt = A(Jt), Xt = {
	name: "clipboard-list",
	size: 24,
	node: [
		["rect", {
			width: "8",
			height: "4",
			x: "8",
			y: "2",
			rx: "1",
			ry: "1",
			key: "tgr4d6"
		}],
		["path", {
			d: "M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2",
			key: "116196"
		}],
		["path", {
			d: "M12 11h4",
			key: "1jrz19"
		}],
		["path", {
			d: "M12 16h4",
			key: "n85exb"
		}],
		["path", {
			d: "M8 11h.01",
			key: "1dfujw"
		}],
		["path", {
			d: "M8 16h.01",
			key: "18s6g9"
		}]
	]
};
Xt.node;
var Zt = A(Xt), Qt = {
	name: "clock",
	size: 24,
	node: [["circle", {
		cx: "12",
		cy: "12",
		r: "10",
		key: "1mglay"
	}], ["path", {
		d: "M12 6v6l4 2",
		key: "mmk7yg"
	}]]
};
Qt.node;
var $t = A(Qt), en = {
	name: "cloud-download",
	size: 24,
	node: [
		["path", {
			d: "M12 13v8l-4-4",
			key: "1f5nwf"
		}],
		["path", {
			d: "m12 21 4-4",
			key: "1lfcce"
		}],
		["path", {
			d: "M4.393 15.269A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.436 8.284",
			key: "ui1hmy"
		}]
	],
	aliases: ["download-cloud"]
};
en.node;
var tn = A(en), nn = {
	name: "columns-2",
	size: 24,
	node: [["rect", {
		width: "18",
		height: "18",
		x: "3",
		y: "3",
		rx: "2",
		key: "afitv7"
	}], ["path", {
		d: "M12 3v18",
		key: "108xh3"
	}]],
	aliases: ["columns"]
};
nn.node;
var rn = A(nn), an = {
	name: "compass",
	size: 24,
	node: [["circle", {
		cx: "12",
		cy: "12",
		r: "10",
		key: "1mglay"
	}], ["path", {
		d: "m16.24 7.76-1.804 5.411a2 2 0 0 1-1.265 1.265L7.76 16.24l1.804-5.411a2 2 0 0 1 1.265-1.265z",
		key: "9ktpf1"
	}]]
};
an.node;
var on = A(an), sn = {
	name: "copy",
	size: 24,
	node: [["rect", {
		width: "14",
		height: "14",
		x: "8",
		y: "8",
		rx: "2",
		ry: "2",
		key: "17jyea"
	}], ["path", {
		d: "M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2",
		key: "zix9uf"
	}]]
};
sn.node;
var cn = A(sn), ln = {
	name: "crosshair",
	size: 24,
	node: [
		["circle", {
			cx: "12",
			cy: "12",
			r: "10",
			key: "1mglay"
		}],
		["line", {
			x1: "22",
			x2: "18",
			y1: "12",
			y2: "12",
			key: "l9bcsi"
		}],
		["line", {
			x1: "6",
			x2: "2",
			y1: "12",
			y2: "12",
			key: "13hhkx"
		}],
		["line", {
			x1: "12",
			x2: "12",
			y1: "6",
			y2: "2",
			key: "10w3f3"
		}],
		["line", {
			x1: "12",
			x2: "12",
			y1: "22",
			y2: "18",
			key: "15g9kq"
		}]
	]
};
ln.node;
var un = A(ln), dn = {
	name: "database",
	size: 24,
	node: [
		["ellipse", {
			cx: "12",
			cy: "5",
			rx: "9",
			ry: "3",
			key: "msslwz"
		}],
		["path", {
			d: "M3 5V19A9 3 0 0 0 21 19V5",
			key: "1wlel7"
		}],
		["path", {
			d: "M3 12A9 3 0 0 0 21 12",
			key: "mv7ke4"
		}]
	]
};
dn.node;
var fn = A(dn), pn = {
	name: "download",
	size: 24,
	node: [
		["path", {
			d: "M12 15V3",
			key: "m9g1x1"
		}],
		["path", {
			d: "M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4",
			key: "ih7n3h"
		}],
		["path", {
			d: "m7 10 5 5 5-5",
			key: "brsn70"
		}]
	]
};
pn.node;
var mn = A(pn), hn = {
	name: "earth",
	size: 24,
	node: [
		["path", {
			d: "M21.54 15H17a2 2 0 0 0-2 2v4.54",
			key: "1djwo0"
		}],
		["path", {
			d: "M7 3.34V5a3 3 0 0 0 3 3a2 2 0 0 1 2 2c0 1.1.9 2 2 2a2 2 0 0 0 2-2c0-1.1.9-2 2-2h3.17",
			key: "1tzkfa"
		}],
		["path", {
			d: "M11 21.95V18a2 2 0 0 0-2-2a2 2 0 0 1-2-2v-1a2 2 0 0 0-2-2H2.05",
			key: "14pb5j"
		}],
		["circle", {
			cx: "12",
			cy: "12",
			r: "10",
			key: "1mglay"
		}]
	],
	aliases: ["globe-2"]
};
hn.node;
var gn = A(hn), _n = {
	name: "eraser",
	size: 24,
	node: [["path", {
		d: "M21 21H8a2 2 0 0 1-1.42-.587l-3.994-3.999a2 2 0 0 1 0-2.828l10-10a2 2 0 0 1 2.829 0l5.999 6a2 2 0 0 1 0 2.828L12.834 21",
		key: "g5wo59"
	}], ["path", {
		d: "m5.082 11.09 8.828 8.828",
		key: "1wx5vj"
	}]]
};
_n.node;
var vn = A(_n), yn = {
	name: "eye-off",
	size: 24,
	node: [
		["path", {
			d: "M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49",
			key: "ct8e1f"
		}],
		["path", {
			d: "M14.084 14.158a3 3 0 0 1-4.242-4.242",
			key: "151rxh"
		}],
		["path", {
			d: "M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143",
			key: "13bj9a"
		}],
		["path", {
			d: "m2 2 20 20",
			key: "1ooewy"
		}]
	]
};
yn.node;
var bn = A(yn), xn = {
	name: "file-code-corner",
	size: 24,
	node: [
		["path", {
			d: "M4 12.15V4a2 2 0 0 1 2-2h8a2.4 2.4 0 0 1 1.706.706l3.588 3.588A2.4 2.4 0 0 1 20 8v12a2 2 0 0 1-2 2h-3.35",
			key: "1wthlu"
		}],
		["path", {
			d: "M14 2v5a1 1 0 0 0 1 1h5",
			key: "wfsgrz"
		}],
		["path", {
			d: "m5 16-3 3 3 3",
			key: "331omg"
		}],
		["path", {
			d: "m9 22 3-3-3-3",
			key: "lsp7cz"
		}]
	],
	aliases: ["file-code-2"]
};
xn.node;
var Sn = A(xn), Cn = {
	name: "file-plus-corner",
	size: 24,
	node: [
		["path", {
			d: "M11.35 22H6a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h8a2.4 2.4 0 0 1 1.706.706l3.588 3.588A2.4 2.4 0 0 1 20 8v5.35",
			key: "17jvcc"
		}],
		["path", {
			d: "M14 2v5a1 1 0 0 0 1 1h5",
			key: "wfsgrz"
		}],
		["path", {
			d: "M14 19h6",
			key: "bvotb8"
		}],
		["path", {
			d: "M17 16v6",
			key: "18yu1i"
		}]
	],
	aliases: ["file-plus-2"]
};
Cn.node;
var wn = A(Cn), Tn = {
	name: "file-spreadsheet",
	size: 24,
	node: [
		["path", {
			d: "M6 22a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h8a2.4 2.4 0 0 1 1.704.706l3.588 3.588A2.4 2.4 0 0 1 20 8v12a2 2 0 0 1-2 2z",
			key: "1oefj6"
		}],
		["path", {
			d: "M14 2v5a1 1 0 0 0 1 1h5",
			key: "wfsgrz"
		}],
		["path", {
			d: "M8 13h2",
			key: "yr2amv"
		}],
		["path", {
			d: "M14 13h2",
			key: "un5t4a"
		}],
		["path", {
			d: "M8 17h2",
			key: "2yhykz"
		}],
		["path", {
			d: "M14 17h2",
			key: "10kma7"
		}]
	]
};
Tn.node;
var En = A(Tn), Dn = {
	name: "file-text",
	size: 24,
	node: [
		["path", {
			d: "M6 22a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h8a2.4 2.4 0 0 1 1.704.706l3.588 3.588A2.4 2.4 0 0 1 20 8v12a2 2 0 0 1-2 2z",
			key: "1oefj6"
		}],
		["path", {
			d: "M14 2v5a1 1 0 0 0 1 1h5",
			key: "wfsgrz"
		}],
		["path", {
			d: "M10 9H8",
			key: "b1mrlr"
		}],
		["path", {
			d: "M16 13H8",
			key: "t4e002"
		}],
		["path", {
			d: "M16 17H8",
			key: "z1uh3a"
		}]
	]
};
Dn.node;
var On = A(Dn), kn = {
	name: "files",
	size: 24,
	node: [
		["path", {
			d: "M15 2h-4a2 2 0 0 0-2 2v11a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V8",
			key: "14sh0y"
		}],
		["path", {
			d: "M16.706 2.706A2.4 2.4 0 0 0 15 2v5a1 1 0 0 0 1 1h5a2.4 2.4 0 0 0-.706-1.706z",
			key: "1970lx"
		}],
		["path", {
			d: "M5 7a2 2 0 0 0-2 2v11a2 2 0 0 0 2 2h8a2 2 0 0 0 1.732-1",
			key: "l4dndm"
		}]
	]
};
kn.node;
var An = A(kn), jn = {
	name: "fingerprint-pattern",
	size: 24,
	node: [
		["path", {
			d: "M12 10a2 2 0 0 0-2 2c0 1.02-.1 2.51-.26 4",
			key: "1nerag"
		}],
		["path", {
			d: "M14 13.12c0 2.38 0 6.38-1 8.88",
			key: "o46ks0"
		}],
		["path", {
			d: "M17.29 21.02c.12-.6.43-2.3.5-3.02",
			key: "ptglia"
		}],
		["path", {
			d: "M2 12a10 10 0 0 1 18-6",
			key: "ydlgp0"
		}],
		["path", {
			d: "M2 16h.01",
			key: "1gqxmh"
		}],
		["path", {
			d: "M21.8 16c.2-2 .131-5.354 0-6",
			key: "drycrb"
		}],
		["path", {
			d: "M5 19.5C5.5 18 6 15 6 12a6 6 0 0 1 .34-2",
			key: "1tidbn"
		}],
		["path", {
			d: "M8.65 22c.21-.66.45-1.32.57-2",
			key: "13wd9y"
		}],
		["path", {
			d: "M9 6.8a6 6 0 0 1 9 5.2v2",
			key: "1fr1j5"
		}]
	],
	aliases: ["fingerprint"]
};
jn.node;
var Mn = A(jn), Nn = {
	name: "flag",
	size: 24,
	node: [["path", {
		d: "M4 22V4a1 1 0 0 1 .4-.8A6 6 0 0 1 8 2c3 0 5 2 7.333 2q2 0 3.067-.8A1 1 0 0 1 20 4v10a1 1 0 0 1-.4.8A6 6 0 0 1 16 16c-3 0-5-2-8-2a6 6 0 0 0-4 1.528",
		key: "1jaruq"
	}]]
};
Nn.node;
var Pn = A(Nn), Fn = {
	name: "folder-open",
	size: 24,
	node: [["path", {
		d: "m6 14 1.5-2.9A2 2 0 0 1 9.24 10H20a2 2 0 0 1 1.94 2.5l-1.54 6a2 2 0 0 1-1.95 1.5H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h3.9a2 2 0 0 1 1.69.9l.81 1.2a2 2 0 0 0 1.67.9H18a2 2 0 0 1 2 2v2",
		key: "usdka0"
	}]]
};
Fn.node;
var In = A(Fn), Ln = {
	name: "funnel",
	size: 24,
	node: [["path", {
		d: "M10 20a1 1 0 0 0 .553.895l2 1A1 1 0 0 0 14 21v-7a2 2 0 0 1 .517-1.341L21.74 4.67A1 1 0 0 0 21 3H3a1 1 0 0 0-.742 1.67l7.225 7.989A2 2 0 0 1 10 14z",
		key: "sc7q7i"
	}]],
	aliases: ["filter"]
};
Ln.node;
var Rn = A(Ln), zn = {
	name: "gauge",
	size: 24,
	node: [["path", {
		d: "m12 14 4-4",
		key: "9kzdfg"
	}], ["path", {
		d: "M3.34 19a10 10 0 1 1 17.32 0",
		key: "19p75a"
	}]]
};
zn.node;
var Bn = A(zn), Vn = {
	name: "git-compare",
	size: 24,
	node: [
		["circle", {
			cx: "18",
			cy: "18",
			r: "3",
			key: "1xkwt0"
		}],
		["circle", {
			cx: "6",
			cy: "6",
			r: "3",
			key: "1lh9wr"
		}],
		["path", {
			d: "M13 6h3a2 2 0 0 1 2 2v7",
			key: "1yeb86"
		}],
		["path", {
			d: "M11 18H8a2 2 0 0 1-2-2V9",
			key: "19pyzm"
		}]
	]
};
Vn.node;
var Hn = A(Vn), Un = {
	name: "grid-3x3",
	size: 24,
	node: [
		["rect", {
			width: "18",
			height: "18",
			x: "3",
			y: "3",
			rx: "2",
			key: "afitv7"
		}],
		["path", {
			d: "M3 9h18",
			key: "1pudct"
		}],
		["path", {
			d: "M3 15h18",
			key: "5xshup"
		}],
		["path", {
			d: "M9 3v18",
			key: "fh3hqa"
		}],
		["path", {
			d: "M15 3v18",
			key: "14nvp0"
		}]
	],
	aliases: ["grid", "grid-3-x-3"]
};
Un.node;
var Wn = A(Un), Gn = {
	name: "grip-vertical",
	size: 24,
	node: [
		["circle", {
			cx: "9",
			cy: "12",
			r: "1",
			key: "1vctgf"
		}],
		["circle", {
			cx: "9",
			cy: "5",
			r: "1",
			key: "hp0tcf"
		}],
		["circle", {
			cx: "9",
			cy: "19",
			r: "1",
			key: "fkjjf6"
		}],
		["circle", {
			cx: "15",
			cy: "12",
			r: "1",
			key: "1tmaij"
		}],
		["circle", {
			cx: "15",
			cy: "5",
			r: "1",
			key: "19l28e"
		}],
		["circle", {
			cx: "15",
			cy: "19",
			r: "1",
			key: "f4zoj3"
		}]
	]
};
Gn.node;
var Kn = A(Gn), qn = {
	name: "hash",
	size: 24,
	node: [
		["line", {
			x1: "4",
			x2: "20",
			y1: "9",
			y2: "9",
			key: "4lhtct"
		}],
		["line", {
			x1: "4",
			x2: "20",
			y1: "15",
			y2: "15",
			key: "vyu0kd"
		}],
		["line", {
			x1: "10",
			x2: "8",
			y1: "3",
			y2: "21",
			key: "1ggp8o"
		}],
		["line", {
			x1: "16",
			x2: "14",
			y1: "3",
			y2: "21",
			key: "weycgp"
		}]
	]
};
qn.node;
var Jn = A(qn), Yn = {
	name: "heart-pulse",
	size: 24,
	node: [["path", {
		d: "M2 9.5a5.5 5.5 0 0 1 9.591-3.676.56.56 0 0 0 .818 0A5.49 5.49 0 0 1 22 9.5c0 2.29-1.5 4-3 5.5l-5.492 5.313a2 2 0 0 1-3 .019L5 15c-1.5-1.5-3-3.2-3-5.5",
		key: "mvr1a0"
	}], ["path", {
		d: "M3.22 13H9.5l.5-1 2 4.5 2-7 1.5 3.5h5.27",
		key: "auskq0"
	}]]
};
Yn.node;
var Xn = A(Yn), Zn = {
	name: "highlighter",
	size: 24,
	node: [["path", {
		d: "m9 11-6 6v3h9l3-3",
		key: "1a3l36"
	}], ["path", {
		d: "m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4",
		key: "14a9rk"
	}]]
};
Zn.node;
var Qn = A(Zn), $n = {
	name: "house",
	size: 24,
	node: [["path", {
		d: "M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8",
		key: "5wwlr5"
	}], ["path", {
		d: "M3 10a2 2 0 0 1 .709-1.528l7-6a2 2 0 0 1 2.582 0l7 6A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z",
		key: "r6nss1"
	}]],
	aliases: ["home"]
};
$n.node;
var er = A($n), tr = {
	name: "id-card",
	size: 24,
	node: [
		["path", {
			d: "M13 19a4 4 0 00-8 0",
			key: "cugzd5"
		}],
		["path", {
			d: "M16 10h2",
			key: "8sgtl7"
		}],
		["path", {
			d: "M16 14h2",
			key: "epxaof"
		}],
		["circle", {
			cx: "9",
			cy: "12",
			r: "3",
			key: "u3jwor"
		}],
		["rect", {
			x: "2",
			y: "5",
			width: "20",
			height: "14",
			rx: "2",
			key: "qneu4z"
		}]
	]
};
tr.node;
var nr = A(tr), rr = {
	name: "info",
	size: 24,
	node: [
		["circle", {
			cx: "12",
			cy: "12",
			r: "10",
			key: "1mglay"
		}],
		["path", {
			d: "M12 16v-4",
			key: "1dtifu"
		}],
		["path", {
			d: "M12 8h.01",
			key: "e9boi3"
		}]
	]
};
rr.node;
var ir = A(rr), ar = {
	name: "italic",
	size: 24,
	node: [
		["line", {
			x1: "19",
			x2: "10",
			y1: "4",
			y2: "4",
			key: "15jd3p"
		}],
		["line", {
			x1: "14",
			x2: "5",
			y1: "20",
			y2: "20",
			key: "bu0au3"
		}],
		["line", {
			x1: "15",
			x2: "9",
			y1: "4",
			y2: "20",
			key: "uljnxc"
		}]
	]
};
ar.node;
var or = A(ar), sr = {
	name: "layers",
	size: 24,
	node: [
		["path", {
			d: "M12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83z",
			key: "zw3jo"
		}],
		["path", {
			d: "M2 12a1 1 0 0 0 .58.91l8.6 3.91a2 2 0 0 0 1.65 0l8.58-3.9A1 1 0 0 0 22 12",
			key: "1wduqc"
		}],
		["path", {
			d: "M2 17a1 1 0 0 0 .58.91l8.6 3.91a2 2 0 0 0 1.65 0l8.58-3.9A1 1 0 0 0 22 17",
			key: "kqbvx6"
		}]
	],
	aliases: ["layers-3"]
};
sr.node;
var cr = A(sr), lr = {
	name: "lightbulb",
	size: 24,
	node: [
		["path", {
			d: "M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5",
			key: "1gvzjb"
		}],
		["path", {
			d: "M9 18h6",
			key: "x1upvd"
		}],
		["path", {
			d: "M10 22h4",
			key: "ceow96"
		}]
	]
};
lr.node;
var ur = A(lr), dr = {
	name: "link-2",
	size: 24,
	node: [
		["path", {
			d: "M9 17H7A5 5 0 0 1 7 7h2",
			key: "8i5ue5"
		}],
		["path", {
			d: "M15 7h2a5 5 0 1 1 0 10h-2",
			key: "1b9ql8"
		}],
		["line", {
			x1: "8",
			x2: "16",
			y1: "12",
			y2: "12",
			key: "1jonct"
		}]
	]
};
dr.node;
var fr = A(dr), pr = {
	name: "link",
	size: 24,
	node: [["path", {
		d: "M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71",
		key: "1cjeqo"
	}], ["path", {
		d: "M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71",
		key: "19qd67"
	}]]
};
pr.node;
var mr = A(pr), hr = {
	name: "list-checks",
	size: 24,
	node: [
		["path", {
			d: "M13 5h8",
			key: "a7qcls"
		}],
		["path", {
			d: "M13 12h8",
			key: "h98zly"
		}],
		["path", {
			d: "M13 19h8",
			key: "c3s6r1"
		}],
		["path", {
			d: "m3 17 2 2 4-4",
			key: "1jhpwq"
		}],
		["path", {
			d: "m3 7 2 2 4-4",
			key: "1obspn"
		}]
	]
};
hr.node;
var gr = A(hr), _r = {
	name: "list-ordered",
	size: 24,
	node: [
		["path", {
			d: "M11 5h10",
			key: "1cz7ny"
		}],
		["path", {
			d: "M11 12h10",
			key: "1438ji"
		}],
		["path", {
			d: "M11 19h10",
			key: "11t30w"
		}],
		["path", {
			d: "M4 4h1v5",
			key: "10yrso"
		}],
		["path", {
			d: "M4 9h2",
			key: "r1h2o0"
		}],
		["path", {
			d: "M6.5 20H3.4c0-1 2.6-1.925 2.6-3.5a1.5 1.5 0 0 0-2.6-1.02",
			key: "xtkcd5"
		}]
	]
};
_r.node;
var vr = A(_r), yr = {
	name: "list",
	size: 24,
	node: [
		["path", {
			d: "M3 5h.01",
			key: "18ugdj"
		}],
		["path", {
			d: "M3 12h.01",
			key: "nlz23k"
		}],
		["path", {
			d: "M3 19h.01",
			key: "noohij"
		}],
		["path", {
			d: "M8 5h13",
			key: "1pao27"
		}],
		["path", {
			d: "M8 12h13",
			key: "1za7za"
		}],
		["path", {
			d: "M8 19h13",
			key: "m83p4d"
		}]
	]
};
yr.node;
var br = A(yr), xr = {
	name: "lock-open",
	size: 24,
	node: [["rect", {
		width: "18",
		height: "11",
		x: "3",
		y: "11",
		rx: "2",
		ry: "2",
		key: "1w4ew1"
	}], ["path", {
		d: "M7 11V7a5 5 0 0 1 9.9-1",
		key: "1mm8w8"
	}]],
	aliases: ["unlock"]
};
xr.node;
var Sr = A(xr), Cr = {
	name: "lock",
	size: 24,
	node: [["rect", {
		width: "18",
		height: "11",
		x: "3",
		y: "11",
		rx: "2",
		ry: "2",
		key: "1w4ew1"
	}], ["path", {
		d: "M7 11V7a5 5 0 0 1 10 0v4",
		key: "fwvmzm"
	}]]
};
Cr.node;
var wr = A(Cr), Tr = {
	name: "map-pin",
	size: 24,
	node: [["path", {
		d: "M20 10c0 4.993-5.539 10.193-7.399 11.799a1 1 0 0 1-1.202 0C9.539 20.193 4 14.993 4 10a8 8 0 0 1 16 0",
		key: "1r0f0z"
	}], ["circle", {
		cx: "12",
		cy: "10",
		r: "3",
		key: "ilqhr7"
	}]]
};
Tr.node;
var Er = A(Tr), Dr = {
	name: "map",
	size: 24,
	node: [
		["path", {
			d: "M14.106 5.553a2 2 0 0 0 1.788 0l3.659-1.83A1 1 0 0 1 21 4.619v12.764a1 1 0 0 1-.553.894l-4.553 2.277a2 2 0 0 1-1.788 0l-4.212-2.106a2 2 0 0 0-1.788 0l-3.659 1.83A1 1 0 0 1 3 19.381V6.618a1 1 0 0 1 .553-.894l4.553-2.277a2 2 0 0 1 1.788 0z",
			key: "169xi5"
		}],
		["path", {
			d: "M15 5.764v15",
			key: "1pn4in"
		}],
		["path", {
			d: "M9 3.236v15",
			key: "1uimfh"
		}]
	]
};
Dr.node;
var Or = A(Dr), kr = {
	name: "maximize-2",
	size: 24,
	node: [
		["path", {
			d: "M15 3h6v6",
			key: "1q9fwt"
		}],
		["path", {
			d: "m21 3-7 7",
			key: "1l2asr"
		}],
		["path", {
			d: "m3 21 7-7",
			key: "tjx5ai"
		}],
		["path", {
			d: "M9 21H3v-6",
			key: "wtvkvv"
		}]
	]
};
kr.node;
var Ar = A(kr), jr = {
	name: "minimize-2",
	size: 24,
	node: [
		["path", {
			d: "m14 10 7-7",
			key: "oa77jy"
		}],
		["path", {
			d: "M20 10h-6V4",
			key: "mjg0md"
		}],
		["path", {
			d: "m3 21 7-7",
			key: "tjx5ai"
		}],
		["path", {
			d: "M4 14h6v6",
			key: "rmj7iw"
		}]
	]
};
jr.node;
var Mr = A(jr), Nr = {
	name: "moon",
	size: 24,
	node: [["path", {
		d: "M20.985 12.486a9 9 0 1 1-9.473-9.472c.405-.022.617.46.402.803a6 6 0 0 0 8.268 8.268c.344-.215.825-.004.803.401",
		key: "kfwtm"
	}]]
};
Nr.node;
var Pr = A(Nr), Fr = {
	name: "mouse-pointer-click",
	size: 24,
	node: [
		["path", {
			d: "M14 4.1 12 6",
			key: "ita8i4"
		}],
		["path", {
			d: "m5.1 8-2.9-.8",
			key: "1go3kf"
		}],
		["path", {
			d: "m6 12-1.9 2",
			key: "mnht97"
		}],
		["path", {
			d: "M7.2 2.2 8 5.1",
			key: "1cfko1"
		}],
		["path", {
			d: "M9.037 9.69a.498.498 0 0 1 .653-.653l11 4.5a.5.5 0 0 1-.074.949l-4.349 1.041a1 1 0 0 0-.74.739l-1.04 4.35a.5.5 0 0 1-.95.074z",
			key: "s0h3yz"
		}]
	]
};
Fr.node;
var Ir = A(Fr), Lr = {
	name: "move-vertical",
	size: 24,
	node: [
		["path", {
			d: "M12 2v20",
			key: "t6zp3m"
		}],
		["path", {
			d: "m8 18 4 4 4-4",
			key: "bh5tu3"
		}],
		["path", {
			d: "m8 6 4-4 4 4",
			key: "ybng9g"
		}]
	]
};
Lr.node;
var Rr = A(Lr), zr = {
	name: "network",
	size: 24,
	node: [
		["rect", {
			x: "16",
			y: "16",
			width: "6",
			height: "6",
			rx: "1",
			key: "4q2zg0"
		}],
		["rect", {
			x: "2",
			y: "16",
			width: "6",
			height: "6",
			rx: "1",
			key: "8cvhb9"
		}],
		["rect", {
			x: "9",
			y: "2",
			width: "6",
			height: "6",
			rx: "1",
			key: "1egb70"
		}],
		["path", {
			d: "M5 16v-3a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v3",
			key: "1jsf9p"
		}],
		["path", {
			d: "M12 12V8",
			key: "2874zd"
		}]
	]
};
zr.node;
var Br = A(zr), Vr = {
	name: "package-open",
	size: 24,
	node: [
		["path", {
			d: "M12 22v-9",
			key: "x3hkom"
		}],
		["path", {
			d: "M15.17 2.21a1.67 1.67 0 0 1 1.63 0L21 4.57a1.93 1.93 0 0 1 0 3.36L8.82 14.79a1.655 1.655 0 0 1-1.64 0L3 12.43a1.93 1.93 0 0 1 0-3.36z",
			key: "2ntwy6"
		}],
		["path", {
			d: "M20 13v3.87a2.06 2.06 0 0 1-1.11 1.83l-6 3.08a1.93 1.93 0 0 1-1.78 0l-6-3.08A2.06 2.06 0 0 1 4 16.87V13",
			key: "1pmm1c"
		}],
		["path", {
			d: "M21 12.43a1.93 1.93 0 0 0 0-3.36L8.83 2.2a1.64 1.64 0 0 0-1.63 0L3 4.57a1.93 1.93 0 0 0 0 3.36l12.18 6.86a1.636 1.636 0 0 0 1.63 0z",
			key: "12ttoo"
		}]
	]
};
Vr.node;
var Hr = A(Vr), Ur = {
	name: "pen-line",
	size: 24,
	node: [["path", {
		d: "M13 21h8",
		key: "1jsn5i"
	}], ["path", {
		d: "M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z",
		key: "1a8usu"
	}]],
	aliases: ["edit-3"]
};
Ur.node;
var Wr = A(Ur), Gr = {
	name: "pencil",
	size: 24,
	node: [["path", {
		d: "M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z",
		key: "1a8usu"
	}], ["path", {
		d: "m15 5 4 4",
		key: "1mk7zo"
	}]]
};
Gr.node;
var Kr = A(Gr), qr = {
	name: "percent",
	size: 24,
	node: [
		["line", {
			x1: "19",
			x2: "5",
			y1: "5",
			y2: "19",
			key: "1x9vlm"
		}],
		["circle", {
			cx: "6.5",
			cy: "6.5",
			r: "2.5",
			key: "4mh3h7"
		}],
		["circle", {
			cx: "17.5",
			cy: "17.5",
			r: "2.5",
			key: "1mdrzq"
		}]
	]
};
qr.node;
var Jr = A(qr), Yr = {
	name: "play",
	size: 24,
	node: [["path", {
		d: "M5 5a2 2 0 0 1 3.008-1.728l11.997 6.998a2 2 0 0 1 .003 3.458l-12 7A2 2 0 0 1 5 19z",
		key: "10ikf1"
	}]]
};
Yr.node;
var Xr = A(Yr), Zr = {
	name: "plus",
	size: 24,
	node: [["path", {
		d: "M5 12h14",
		key: "1ays0h"
	}], ["path", {
		d: "M12 5v14",
		key: "s699le"
	}]]
};
Zr.node;
var Qr = A(Zr), $r = {
	name: "refresh-cw",
	size: 24,
	node: [
		["path", {
			d: "M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8",
			key: "v9h5vc"
		}],
		["path", {
			d: "M21 3v5h-5",
			key: "1q7to0"
		}],
		["path", {
			d: "M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16",
			key: "3uifl3"
		}],
		["path", {
			d: "M8 16H3v5",
			key: "1cv678"
		}]
	]
};
$r.node;
var ei = A($r), ti = {
	name: "rotate-ccw-clock",
	size: 24,
	node: [
		["path", {
			d: "M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8",
			key: "1357e3"
		}],
		["path", {
			d: "M3 3v5h5",
			key: "1xhq8a"
		}],
		["path", {
			d: "M12 7v5l4 2",
			key: "1fdv2h"
		}]
	],
	aliases: ["history"]
};
ti.node;
var ni = A(ti), ri = {
	name: "rotate-ccw",
	size: 24,
	node: [["path", {
		d: "M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8",
		key: "1357e3"
	}], ["path", {
		d: "M3 3v5h5",
		key: "1xhq8a"
	}]]
};
ri.node;
var ii = A(ri), ai = {
	name: "ruler",
	size: 24,
	node: [
		["path", {
			d: "M21.3 15.3a2.4 2.4 0 0 1 0 3.4l-2.6 2.6a2.4 2.4 0 0 1-3.4 0L2.7 8.7a2.41 2.41 0 0 1 0-3.4l2.6-2.6a2.41 2.41 0 0 1 3.4 0Z",
			key: "icamh8"
		}],
		["path", {
			d: "m14.5 12.5 2-2",
			key: "inckbg"
		}],
		["path", {
			d: "m11.5 9.5 2-2",
			key: "fmmyf7"
		}],
		["path", {
			d: "m8.5 6.5 2-2",
			key: "vc6u1g"
		}],
		["path", {
			d: "m17.5 15.5 2-2",
			key: "wo5hmg"
		}]
	]
};
ai.node;
var oi = A(ai), si = {
	name: "save",
	size: 24,
	node: [
		["path", {
			d: "M15.2 3a2 2 0 0 1 1.4.6l3.8 3.8a2 2 0 0 1 .6 1.4V19a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z",
			key: "1c8476"
		}],
		["path", {
			d: "M17 21v-7a1 1 0 0 0-1-1H8a1 1 0 0 0-1 1v7",
			key: "1ydtos"
		}],
		["path", {
			d: "M7 3v4a1 1 0 0 0 1 1h7",
			key: "t51u73"
		}]
	]
};
si.node;
var ci = A(si), li = {
	name: "scale",
	size: 24,
	node: [
		["path", {
			d: "M12 3v18",
			key: "108xh3"
		}],
		["path", {
			d: "m19 8 3 8a5 5 0 0 1-6 0zV7",
			key: "zcdpyk"
		}],
		["path", {
			d: "M3 7h1a17 17 0 0 0 8-2 17 17 0 0 0 8 2h1",
			key: "1yorad"
		}],
		["path", {
			d: "m5 8 3 8a5 5 0 0 1-6 0zV7",
			key: "eua70x"
		}],
		["path", {
			d: "M7 21h10",
			key: "1b0cd5"
		}]
	]
};
li.node;
var ui = A(li), di = {
	name: "scan-search",
	size: 24,
	node: [
		["path", {
			d: "M3 7V5a2 2 0 0 1 2-2h2",
			key: "aa7l1z"
		}],
		["path", {
			d: "M17 3h2a2 2 0 0 1 2 2v2",
			key: "4qcy5o"
		}],
		["path", {
			d: "M21 17v2a2 2 0 0 1-2 2h-2",
			key: "6vwrx8"
		}],
		["path", {
			d: "M7 21H5a2 2 0 0 1-2-2v-2",
			key: "ioqczr"
		}],
		["circle", {
			cx: "12",
			cy: "12",
			r: "3",
			key: "1v7zrd"
		}],
		["path", {
			d: "m16 16-1.9-1.9",
			key: "1dq9hf"
		}]
	]
};
di.node;
var fi = A(di), pi = {
	name: "scissors",
	size: 24,
	node: [
		["circle", {
			cx: "6",
			cy: "6",
			r: "3",
			key: "1lh9wr"
		}],
		["path", {
			d: "M8.12 8.12 12 12",
			key: "1alkpv"
		}],
		["path", {
			d: "M20 4 8.12 15.88",
			key: "xgtan2"
		}],
		["circle", {
			cx: "6",
			cy: "18",
			r: "3",
			key: "fqmcym"
		}],
		["path", {
			d: "M14.8 14.8 20 20",
			key: "ptml3r"
		}]
	]
};
pi.node;
var mi = A(pi), hi = {
	name: "search",
	size: 24,
	node: [["path", {
		d: "m21 21-4.34-4.34",
		key: "14j7rj"
	}], ["circle", {
		cx: "11",
		cy: "11",
		r: "8",
		key: "4ej97u"
	}]]
};
hi.node;
var gi = A(hi), _i = {
	name: "share-2",
	size: 24,
	node: [
		["circle", {
			cx: "18",
			cy: "5",
			r: "3",
			key: "gq8acd"
		}],
		["circle", {
			cx: "6",
			cy: "12",
			r: "3",
			key: "w7nqdw"
		}],
		["circle", {
			cx: "18",
			cy: "19",
			r: "3",
			key: "1xt0gg"
		}],
		["line", {
			x1: "8.59",
			x2: "15.42",
			y1: "13.51",
			y2: "17.49",
			key: "47mynk"
		}],
		["line", {
			x1: "15.41",
			x2: "8.59",
			y1: "6.51",
			y2: "10.49",
			key: "1n3mei"
		}]
	]
};
_i.node;
var vi = A(_i), yi = {
	name: "shield-alert",
	size: 24,
	node: [
		["path", {
			d: "M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z",
			key: "oel41y"
		}],
		["path", {
			d: "M12 8v4",
			key: "1got3b"
		}],
		["path", {
			d: "M12 16h.01",
			key: "1drbdi"
		}]
	]
};
yi.node;
var bi = A(yi), xi = {
	name: "shuffle",
	size: 24,
	node: [
		["path", {
			d: "m18 14 4 4-4 4",
			key: "10pe0f"
		}],
		["path", {
			d: "m18 2 4 4-4 4",
			key: "pucp1d"
		}],
		["path", {
			d: "M2 18h1.973a4 4 0 0 0 3.3-1.7l5.454-8.6a4 4 0 0 1 3.3-1.7H22",
			key: "1ailkh"
		}],
		["path", {
			d: "M2 6h1.972a4 4 0 0 1 3.6 2.2",
			key: "km57vx"
		}],
		["path", {
			d: "M22 18h-6.041a4 4 0 0 1-3.3-1.8l-.359-.45",
			key: "os18l9"
		}]
	]
};
xi.node;
var Si = A(xi), Ci = {
	name: "sigma",
	size: 24,
	node: [["path", {
		d: "M18 7V5a1 1 0 0 0-1-1H6.5a.5.5 0 0 0-.4.8l4.5 6a2 2 0 0 1 0 2.4l-4.5 6a.5.5 0 0 0 .4.8H17a1 1 0 0 0 1-1v-2",
		key: "wuwx1p"
	}]]
};
Ci.node;
var wi = A(Ci), Ti = {
	name: "signpost-big",
	size: 24,
	node: [
		["path", {
			d: "M10 9H4L2 7l2-2h6",
			key: "1hq7x2"
		}],
		["path", {
			d: "M14 5h6l2 2-2 2h-6",
			key: "bv62ej"
		}],
		["path", {
			d: "M10 22V4a2 2 0 1 1 4 0v18",
			key: "eqpcf2"
		}],
		["path", {
			d: "M8 22h8",
			key: "rmew8v"
		}]
	]
};
Ti.node;
var Ei = A(Ti), Di = {
	name: "signpost",
	size: 24,
	node: [
		["path", {
			d: "M12 13v8",
			key: "1l5pq0"
		}],
		["path", {
			d: "M12 3v3",
			key: "1n5kay"
		}],
		["path", {
			d: "M2.354 10.354a1.207 1.207 0 0 1 0-1.708l2.06-2.06A2 2 0 0 1 5.828 6h12.344a2 2 0 0 1 1.414.586l2.06 2.06a1.207 1.207 0 0 1 0 1.708l-2.06 2.06a2 2 0 0 1-1.414.586H5.828a2 2 0 0 1-1.414-.586z",
			key: "1tm261"
		}]
	]
};
Di.node;
var Oi = A(Di), ki = {
	name: "sliders-horizontal",
	size: 24,
	node: [
		["path", {
			d: "M10 5H3",
			key: "1qgfaw"
		}],
		["path", {
			d: "M12 19H3",
			key: "yhmn1j"
		}],
		["path", {
			d: "M14 3v4",
			key: "1sua03"
		}],
		["path", {
			d: "M16 17v4",
			key: "1q0r14"
		}],
		["path", {
			d: "M21 12h-9",
			key: "1o4lsq"
		}],
		["path", {
			d: "M21 19h-5",
			key: "1rlt1p"
		}],
		["path", {
			d: "M21 5h-7",
			key: "1oszz2"
		}],
		["path", {
			d: "M8 10v4",
			key: "tgpxqk"
		}],
		["path", {
			d: "M8 12H3",
			key: "a7s4jb"
		}]
	]
};
ki.node;
var Ai = A(ki), ji = {
	name: "spell-check",
	size: 24,
	node: [
		["path", {
			d: "m20 15-5.5 5.5L12 18",
			key: "6ytzne"
		}],
		["path", {
			d: "m4 16 6-12 5.115 10.23",
			key: "fyukjg"
		}],
		["path", {
			d: "M6 12h8",
			key: "1hdiqa"
		}]
	]
};
ji.node;
var Mi = A(ji), Ni = {
	name: "strikethrough",
	size: 24,
	node: [
		["path", {
			d: "M16 4H9a3 3 0 0 0-2.83 4",
			key: "43sutm"
		}],
		["path", {
			d: "M14 12a4 4 0 0 1 0 8H6",
			key: "nlfj13"
		}],
		["line", {
			x1: "4",
			x2: "20",
			y1: "12",
			y2: "12",
			key: "1e0a9i"
		}]
	]
};
Ni.node;
var Pi = A(Ni), Fi = {
	name: "sun",
	size: 24,
	node: [
		["circle", {
			cx: "12",
			cy: "12",
			r: "4",
			key: "4exip2"
		}],
		["path", {
			d: "M12 2v2",
			key: "tus03m"
		}],
		["path", {
			d: "M12 20v2",
			key: "1lh1kg"
		}],
		["path", {
			d: "m4.93 4.93 1.41 1.41",
			key: "149t6j"
		}],
		["path", {
			d: "m17.66 17.66 1.41 1.41",
			key: "ptbguv"
		}],
		["path", {
			d: "M2 12h2",
			key: "1t8f8n"
		}],
		["path", {
			d: "M20 12h2",
			key: "1q8mjw"
		}],
		["path", {
			d: "m6.34 17.66-1.41 1.41",
			key: "1m8zz5"
		}],
		["path", {
			d: "m19.07 4.93-1.41 1.41",
			key: "1shlcs"
		}]
	]
};
Fi.node;
var Ii = A(Fi), Li = {
	name: "table-2",
	size: 24,
	node: [
		["path", {
			d: "M3 9h18",
			key: "1pudct"
		}],
		["path", {
			d: "M9 3v18",
			key: "fh3hqa"
		}],
		["rect", {
			x: "3",
			y: "3",
			width: "18",
			height: "18",
			rx: "2",
			key: "h1oib"
		}]
	]
};
Li.node;
var Ri = A(Li), zi = {
	name: "table-properties",
	size: 24,
	node: [
		["path", {
			d: "M15 3v18",
			key: "14nvp0"
		}],
		["rect", {
			width: "18",
			height: "18",
			x: "3",
			y: "3",
			rx: "2",
			key: "afitv7"
		}],
		["path", {
			d: "M21 9H3",
			key: "1338ky"
		}],
		["path", {
			d: "M21 15H3",
			key: "9uk58r"
		}]
	]
};
zi.node;
var Bi = A(zi), Vi = {
	name: "table",
	size: 24,
	node: [
		["path", {
			d: "M12 3v18",
			key: "108xh3"
		}],
		["rect", {
			width: "18",
			height: "18",
			x: "3",
			y: "3",
			rx: "2",
			key: "afitv7"
		}],
		["path", {
			d: "M3 9h18",
			key: "1pudct"
		}],
		["path", {
			d: "M3 15h18",
			key: "5xshup"
		}]
	]
};
Vi.node;
var Hi = A(Vi), Ui = {
	name: "target",
	size: 24,
	node: [
		["circle", {
			cx: "12",
			cy: "12",
			r: "10",
			key: "1mglay"
		}],
		["circle", {
			cx: "12",
			cy: "12",
			r: "6",
			key: "1vlfrh"
		}],
		["circle", {
			cx: "12",
			cy: "12",
			r: "2",
			key: "1c9p78"
		}]
	]
};
Ui.node;
var Wi = A(Ui), Gi = {
	name: "text-align-center",
	size: 24,
	node: [
		["path", {
			d: "M21 5H3",
			key: "1fi0y6"
		}],
		["path", {
			d: "M17 12H7",
			key: "16if0g"
		}],
		["path", {
			d: "M19 19H5",
			key: "vjpgq2"
		}]
	],
	aliases: ["align-center"]
};
Gi.node;
var Ki = A(Gi), qi = {
	name: "text-align-end",
	size: 24,
	node: [
		["path", {
			d: "M21 5H3",
			key: "1fi0y6"
		}],
		["path", {
			d: "M21 12H9",
			key: "dn1m92"
		}],
		["path", {
			d: "M21 19H7",
			key: "4cu937"
		}]
	],
	aliases: ["align-right"]
};
qi.node;
var Ji = A(qi), Yi = {
	name: "text-align-start",
	size: 24,
	node: [
		["path", {
			d: "M21 5H3",
			key: "1fi0y6"
		}],
		["path", {
			d: "M15 12H3",
			key: "6jk70r"
		}],
		["path", {
			d: "M17 19H3",
			key: "z6ezky"
		}]
	],
	aliases: ["text", "align-left"]
};
Yi.node;
var Xi = A(Yi), Zi = {
	name: "timer",
	size: 24,
	node: [
		["line", {
			x1: "10",
			x2: "14",
			y1: "2",
			y2: "2",
			key: "14vaq8"
		}],
		["line", {
			x1: "12",
			x2: "15",
			y1: "14",
			y2: "11",
			key: "17fdiu"
		}],
		["circle", {
			cx: "12",
			cy: "14",
			r: "8",
			key: "1e1u0o"
		}]
	]
};
Zi.node;
var Qi = A(Zi), $i = {
	name: "trash",
	size: 24,
	node: [
		["path", {
			d: "M10 11v6",
			key: "nco0om"
		}],
		["path", {
			d: "M14 11v6",
			key: "outv1u"
		}],
		["path", {
			d: "M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6",
			key: "miytrc"
		}],
		["path", {
			d: "M3 6h18",
			key: "d0wm0j"
		}],
		["path", {
			d: "M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2",
			key: "e791ji"
		}]
	],
	aliases: ["trash-2"]
};
$i.node;
var ea = A($i), ta = {
	name: "triangle-alert",
	size: 24,
	node: [
		["path", {
			d: "m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3",
			key: "wmoenq"
		}],
		["path", {
			d: "M12 9v4",
			key: "juzpu7"
		}],
		["path", {
			d: "M12 17h.01",
			key: "p32p05"
		}]
	],
	aliases: ["alert-triangle"]
};
ta.node;
var na = A(ta), ra = {
	name: "trending-up",
	size: 24,
	node: [["path", {
		d: "M16 7h6v6",
		key: "box55l"
	}], ["path", {
		d: "m22 7-8.5 8.5-5-5L2 17",
		key: "1t1m79"
	}]]
};
ra.node;
var ia = A(ra), aa = {
	name: "trophy",
	size: 24,
	node: [
		["path", {
			d: "M10 14.66V17a1 1 0 0 1-1 1 2 2 0 0 0-2 2v2",
			key: "pwuv1l"
		}],
		["path", {
			d: "M14 14.66V17a1 1 0 0 0 1 1 2 2 0 0 1 2 2v2",
			key: "1y54w1"
		}],
		["path", {
			d: "M17.916 10H19.5A2.5 2.5 0 0 0 22 7.5V5a1 1 0 0 0-1-1h-3",
			key: "e30mpu"
		}],
		["path", {
			d: "M4 22h16",
			key: "57wxv0"
		}],
		["path", {
			d: "M6 9a6 6 0 0 0 12 0V3a1 1 0 0 0-1-1H7a1 1 0 0 0-1 1z",
			key: "1mhfuq"
		}],
		["path", {
			d: "M6.084 10H4.5A2.5 2.5 0 0 1 2 7.5V5a1 1 0 0 1 1-1h3",
			key: "i0yafy"
		}]
	]
};
aa.node;
var oa = A(aa), sa = {
	name: "type",
	size: 24,
	node: [
		["path", {
			d: "M12 4v16",
			key: "1654pz"
		}],
		["path", {
			d: "M4 7V5a1 1 0 0 1 1-1h14a1 1 0 0 1 1 1v2",
			key: "e0r10z"
		}],
		["path", {
			d: "M9 20h6",
			key: "s66wpe"
		}]
	]
};
sa.node;
var ca = A(sa), la = {
	name: "underline",
	size: 24,
	node: [["path", {
		d: "M6 4v6a6 6 0 0 0 12 0V4",
		key: "9kb039"
	}], ["line", {
		x1: "4",
		x2: "20",
		y1: "20",
		y2: "20",
		key: "nun2al"
	}]]
};
la.node;
var ua = A(la), da = {
	name: "upload",
	size: 24,
	node: [
		["path", {
			d: "M12 3v12",
			key: "1x0j5s"
		}],
		["path", {
			d: "m17 8-5-5-5 5",
			key: "7q97r8"
		}],
		["path", {
			d: "M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4",
			key: "ih7n3h"
		}]
	]
};
da.node;
var fa = A(da), pa = {
	name: "user-check",
	size: 24,
	node: [
		["path", {
			d: "m16 11 2 2 4-4",
			key: "9rsbq5"
		}],
		["path", {
			d: "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2",
			key: "1yyitq"
		}],
		["circle", {
			cx: "9",
			cy: "7",
			r: "4",
			key: "nufk8"
		}]
	]
};
pa.node;
var ma = A(pa), ha = {
	name: "user-minus",
	size: 24,
	node: [
		["path", {
			d: "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2",
			key: "1yyitq"
		}],
		["circle", {
			cx: "9",
			cy: "7",
			r: "4",
			key: "nufk8"
		}],
		["line", {
			x1: "22",
			x2: "16",
			y1: "11",
			y2: "11",
			key: "1shjgl"
		}]
	]
};
ha.node;
var ga = A(ha), _a = {
	name: "user-plus",
	size: 24,
	node: [
		["path", {
			d: "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2",
			key: "1yyitq"
		}],
		["circle", {
			cx: "9",
			cy: "7",
			r: "4",
			key: "nufk8"
		}],
		["line", {
			x1: "19",
			x2: "19",
			y1: "8",
			y2: "14",
			key: "1bvyxn"
		}],
		["line", {
			x1: "22",
			x2: "16",
			y1: "11",
			y2: "11",
			key: "1shjgl"
		}]
	]
};
_a.node;
var va = A(_a), ya = {
	name: "user-round-check",
	size: 24,
	node: [
		["path", {
			d: "M2 21a8 8 0 0 1 13.292-6",
			key: "bjp14o"
		}],
		["circle", {
			cx: "10",
			cy: "8",
			r: "5",
			key: "o932ke"
		}],
		["path", {
			d: "m16 19 2 2 4-4",
			key: "1b14m6"
		}]
	],
	aliases: ["user-check-2"]
};
ya.node;
var ba = A(ya), xa = {
	name: "user",
	size: 24,
	node: [["path", {
		d: "M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2",
		key: "975kel"
	}], ["circle", {
		cx: "12",
		cy: "7",
		r: "4",
		key: "17ys0d"
	}]]
};
xa.node;
var Sa = A(xa), Ca = {
	name: "users-round",
	size: 24,
	node: [
		["path", {
			d: "M18 21a8 8 0 0 0-16 0",
			key: "3ypg7q"
		}],
		["circle", {
			cx: "10",
			cy: "8",
			r: "5",
			key: "o932ke"
		}],
		["path", {
			d: "M22 20c0-3.37-2-6.5-4-8a5 5 0 0 0-.45-8.3",
			key: "10s06x"
		}]
	],
	aliases: ["users-2"]
};
Ca.node;
var wa = A(Ca), Ta = {
	name: "users",
	size: 24,
	node: [
		["path", {
			d: "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2",
			key: "1yyitq"
		}],
		["path", {
			d: "M16 3.128a4 4 0 0 1 0 7.744",
			key: "16gr8j"
		}],
		["path", {
			d: "M22 21v-2a4 4 0 0 0-3-3.87",
			key: "kshegd"
		}],
		["circle", {
			cx: "9",
			cy: "7",
			r: "4",
			key: "nufk8"
		}]
	]
};
Ta.node;
var Ea = A(Ta), Da = {
	name: "venus",
	size: 24,
	node: [
		["path", {
			d: "M12 15v7",
			key: "t2xh3l"
		}],
		["path", {
			d: "M9 19h6",
			key: "456am0"
		}],
		["circle", {
			cx: "12",
			cy: "9",
			r: "6",
			key: "1nw4tq"
		}]
	]
};
Da.node;
var Oa = A(Da), ka = {
	name: "wand-sparkles",
	size: 24,
	node: [
		["path", {
			d: "m21.64 3.64-1.28-1.28a1.21 1.21 0 0 0-1.72 0L2.36 18.64a1.21 1.21 0 0 0 0 1.72l1.28 1.28a1.2 1.2 0 0 0 1.72 0L21.64 5.36a1.2 1.2 0 0 0 0-1.72",
			key: "ul74o6"
		}],
		["path", {
			d: "m14 7 3 3",
			key: "1r5n42"
		}],
		["path", {
			d: "M5 6v4",
			key: "ilb8ba"
		}],
		["path", {
			d: "M19 14v4",
			key: "blhpug"
		}],
		["path", {
			d: "M10 2v2",
			key: "7u0qdc"
		}],
		["path", {
			d: "M7 8H3",
			key: "zfb6yr"
		}],
		["path", {
			d: "M21 16h-4",
			key: "1cnmox"
		}],
		["path", {
			d: "M11 3H9",
			key: "1obp7u"
		}]
	],
	aliases: ["wand-2"]
};
ka.node;
var Aa = A(ka), ja = {
	name: "x",
	size: 24,
	node: [["path", {
		d: "M18 6 6 18",
		key: "1bl5f8"
	}], ["path", {
		d: "m6 6 12 12",
		key: "d8bk6v"
	}]]
};
ja.node;
var Ma = A(ja), Na = {
	name: "zoom-in",
	size: 24,
	node: [
		["circle", {
			cx: "11",
			cy: "11",
			r: "8",
			key: "4ej97u"
		}],
		["line", {
			x1: "21",
			x2: "16.65",
			y1: "21",
			y2: "16.65",
			key: "13gj7c"
		}],
		["line", {
			x1: "11",
			x2: "11",
			y1: "8",
			y2: "14",
			key: "1vmskp"
		}],
		["line", {
			x1: "8",
			x2: "14",
			y1: "11",
			y2: "11",
			key: "durymu"
		}]
	]
};
Na.node;
var Pa = A(Na);
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/typeof.js
function Fa(e) {
	"@babel/helpers - typeof";
	return Fa = typeof Symbol == "function" && typeof Symbol.iterator == "symbol" ? function(e) {
		return typeof e;
	} : function(e) {
		return e && typeof Symbol == "function" && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e;
	}, Fa(e);
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/toPrimitive.js
function Ia(e, t) {
	if (Fa(e) != "object" || !e) return e;
	var n;
	if (typeof Symbol < "u" && (n = e[Symbol.toPrimitive]) !== void 0) {
		var r = n.call(e, t || "default");
		if (Fa(r) != "object") return r;
		throw TypeError("@@toPrimitive must return a primitive value.");
	}
	return (t === "string" ? String : Number)(e);
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/toPropertyKey.js
function La(e) {
	var t = Ia(e, "string");
	return Fa(t) == "symbol" ? t : t + "";
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/defineProperty.js
function Ra(e, t, n) {
	return (t = La(t)) in e ? Object.defineProperty(e, t, {
		value: n,
		enumerable: !0,
		configurable: !0,
		writable: !0
	}) : e[t] = n, e;
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/objectSpread2.js
function za(e, t) {
	var n = Object.keys(e);
	if (Object.getOwnPropertySymbols) {
		var r = Object.getOwnPropertySymbols(e);
		t && (r = r.filter(function(t) {
			return Object.getOwnPropertyDescriptor(e, t).enumerable;
		})), n.push.apply(n, r);
	}
	return n;
}
function j(e) {
	for (var t = 1; t < arguments.length; t++) {
		var n = arguments[t] == null ? {} : arguments[t];
		t % 2 ? za(Object(n), !0).forEach(function(t) {
			Ra(e, t, n[t]);
		}) : Object.getOwnPropertyDescriptors ? Object.defineProperties(e, Object.getOwnPropertyDescriptors(n)) : za(Object(n)).forEach(function(t) {
			Object.defineProperty(e, t, Object.getOwnPropertyDescriptor(n, t));
		});
	}
	return e;
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/arrayWithHoles.js
function Ba(e) {
	if (Array.isArray(e)) return e;
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/iterableToArrayLimit.js
function Va(e, t) {
	var n = e == null ? null : typeof Symbol < "u" && e[Symbol.iterator] || e["@@iterator"];
	if (n != null) {
		var r, i, a, o, s = [], c = !0, l = !1;
		try {
			if (a = (n = n.call(e)).next, t === 0) {
				if (Object(n) !== n) return;
				c = !1;
			} else for (; !(c = (r = a.call(n)).done) && (s.push(r.value), s.length !== t); c = !0);
		} catch (e) {
			l = !0, i = e;
		} finally {
			try {
				if (!c && n.return != null && (o = n.return(), Object(o) !== o)) return;
			} finally {
				if (l) throw i;
			}
		}
		return s;
	}
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/arrayLikeToArray.js
function Ha(e, t) {
	(t == null || t > e.length) && (t = e.length);
	for (var n = 0, r = Array(t); n < t; n++) r[n] = e[n];
	return r;
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/unsupportedIterableToArray.js
function Ua(e, t) {
	if (e) {
		if (typeof e == "string") return Ha(e, t);
		var n = {}.toString.call(e).slice(8, -1);
		return n === "Object" && e.constructor && (n = e.constructor.name), n === "Map" || n === "Set" ? Array.from(e) : n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n) ? Ha(e, t) : void 0;
	}
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/nonIterableRest.js
function Wa() {
	throw TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/slicedToArray.js
function Ga(e, t) {
	return Ba(e) || Va(e, t) || Ua(e, t) || Wa();
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/objectWithoutPropertiesLoose.js
function Ka(e, t) {
	if (e == null) return {};
	var n = {};
	for (var r in e) if ({}.hasOwnProperty.call(e, r)) {
		if (t.indexOf(r) !== -1) continue;
		n[r] = e[r];
	}
	return n;
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/objectWithoutProperties.js
function qa(e, t) {
	if (e == null) return {};
	var n, r, i = Ka(e, t);
	if (Object.getOwnPropertySymbols) {
		var a = Object.getOwnPropertySymbols(e);
		for (r = 0; r < a.length; r++) n = a[r], t.indexOf(n) === -1 && {}.propertyIsEnumerable.call(e, n) && (i[n] = e[n]);
	}
	return i;
}
//#endregion
//#region node_modules/react-select/dist/useStateManager-7e1e8489.esm.js
k();
var Ja = [
	"defaultInputValue",
	"defaultMenuIsOpen",
	"defaultValue",
	"inputValue",
	"menuIsOpen",
	"onChange",
	"onInputChange",
	"onMenuClose",
	"onMenuOpen",
	"value"
];
function Ya(e) {
	var t = e.defaultInputValue, n = t === void 0 ? "" : t, r = e.defaultMenuIsOpen, i = r !== void 0 && r, a = e.defaultValue, o = a === void 0 ? null : a, s = e.inputValue, c = e.menuIsOpen, l = e.onChange, u = e.onInputChange, d = e.onMenuClose, f = e.onMenuOpen, p = e.value, m = qa(e, Ja), h = Ga(O(s === void 0 ? n : s), 2), g = h[0], _ = h[1], v = Ga(O(c === void 0 ? i : c), 2), y = v[0], b = v[1], x = Ga(O(p === void 0 ? o : p), 2), S = x[0], C = x[1], w = ce(function(e, t) {
		typeof l == "function" && l(e, t), C(e);
	}, [l]), ee = ce(function(e, t) {
		var n;
		typeof u == "function" && (n = u(e, t)), _(n === void 0 ? e : n);
	}, [u]), T = ce(function() {
		typeof f == "function" && f(), b(!0);
	}, [f]), te = ce(function() {
		typeof d == "function" && d(), b(!1);
	}, [d]), ne = s === void 0 ? g : s, re = c === void 0 ? y : c, ie = p === void 0 ? S : p;
	return j(j({}, m), {}, {
		inputValue: ne,
		menuIsOpen: re,
		onChange: w,
		onInputChange: ee,
		onMenuClose: te,
		onMenuOpen: T,
		value: ie
	});
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/extends.js
function M() {
	return M = Object.assign ? Object.assign.bind() : function(e) {
		for (var t = 1; t < arguments.length; t++) {
			var n = arguments[t];
			for (var r in n) ({}).hasOwnProperty.call(n, r) && (e[r] = n[r]);
		}
		return e;
	}, M.apply(null, arguments);
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/classCallCheck.js
function Xa(e, t) {
	if (!(e instanceof t)) throw TypeError("Cannot call a class as a function");
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/createClass.js
function Za(e, t) {
	for (var n = 0; n < t.length; n++) {
		var r = t[n];
		r.enumerable = r.enumerable || !1, r.configurable = !0, "value" in r && (r.writable = !0), Object.defineProperty(e, La(r.key), r);
	}
}
function Qa(e, t, n) {
	return t && Za(e.prototype, t), n && Za(e, n), Object.defineProperty(e, "prototype", { writable: !1 }), e;
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/setPrototypeOf.js
function $a(e, t) {
	return $a = Object.setPrototypeOf ? Object.setPrototypeOf.bind() : function(e, t) {
		return e.__proto__ = t, e;
	}, $a(e, t);
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/inherits.js
function eo(e, t) {
	if (typeof t != "function" && t !== null) throw TypeError("Super expression must either be null or a function");
	e.prototype = Object.create(t && t.prototype, { constructor: {
		value: e,
		writable: !0,
		configurable: !0
	} }), Object.defineProperty(e, "prototype", { writable: !1 }), t && $a(e, t);
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/getPrototypeOf.js
function to(e) {
	return to = Object.setPrototypeOf ? Object.getPrototypeOf.bind() : function(e) {
		return e.__proto__ || Object.getPrototypeOf(e);
	}, to(e);
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/isNativeReflectConstruct.js
function no() {
	try {
		var e = !Boolean.prototype.valueOf.call(Reflect.construct(Boolean, [], function() {}));
	} catch {}
	return (no = function() {
		return !!e;
	})();
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/assertThisInitialized.js
function ro(e) {
	if (e === void 0) throw ReferenceError("this hasn't been initialised - super() hasn't been called");
	return e;
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/possibleConstructorReturn.js
function io(e, t) {
	if (t && (Fa(t) == "object" || typeof t == "function")) return t;
	if (t !== void 0) throw TypeError("Derived constructors may only return object or undefined");
	return ro(e);
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/createSuper.js
function ao(e) {
	var t = no();
	return function() {
		var n, r = to(e);
		if (t) {
			var i = to(this).constructor;
			n = Reflect.construct(r, arguments, i);
		} else n = r.apply(this, arguments);
		return io(this, n);
	};
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/arrayWithoutHoles.js
function oo(e) {
	if (Array.isArray(e)) return Ha(e);
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/iterableToArray.js
function so(e) {
	if (typeof Symbol < "u" && e[Symbol.iterator] != null || e["@@iterator"] != null) return Array.from(e);
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/nonIterableSpread.js
function co() {
	throw TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/toConsumableArray.js
function lo(e) {
	return oo(e) || so(e) || Ua(e) || co();
}
//#endregion
//#region node_modules/@emotion/sheet/dist/emotion-sheet.esm.js
function uo(e) {
	if (e.sheet) return e.sheet;
	/* istanbul ignore next */
	for (var t = 0; t < document.styleSheets.length; t++) if (document.styleSheets[t].ownerNode === e) return document.styleSheets[t];
}
function fo(e) {
	var t = document.createElement("style");
	return t.setAttribute("data-emotion", e.key), e.nonce !== void 0 && t.setAttribute("nonce", e.nonce), t.appendChild(document.createTextNode("")), t.setAttribute("data-s", ""), t;
}
var po = /*#__PURE__*/ function() {
	function e(e) {
		var t = this;
		this._insertTag = function(e) {
			var n = t.tags.length === 0 ? t.insertionPoint ? t.insertionPoint.nextSibling : t.prepend ? t.container.firstChild : t.before : t.tags[t.tags.length - 1].nextSibling;
			t.container.insertBefore(e, n), t.tags.push(e);
		}, this.isSpeedy = e.speedy === void 0 || e.speedy, this.tags = [], this.ctr = 0, this.nonce = e.nonce, this.key = e.key, this.container = e.container, this.prepend = e.prepend, this.insertionPoint = e.insertionPoint, this.before = null;
	}
	var t = e.prototype;
	return t.hydrate = function(e) {
		e.forEach(this._insertTag);
	}, t.insert = function(e) {
		this.ctr % (this.isSpeedy ? 65e3 : 1) == 0 && this._insertTag(fo(this));
		var t = this.tags[this.tags.length - 1];
		if (this.isSpeedy) {
			var n = uo(t);
			try {
				n.insertRule(e, n.cssRules.length);
			} catch {}
		} else t.appendChild(document.createTextNode(e));
		this.ctr++;
	}, t.flush = function() {
		this.tags.forEach(function(e) {
			return e.parentNode?.removeChild(e);
		}), this.tags = [], this.ctr = 0;
	}, e;
}(), mo = "-ms-", ho = "-moz-", N = "-webkit-", go = "comm", _o = "rule", vo = "decl", yo = "@import", bo = "@keyframes", xo = "@layer", So = Math.abs, Co = String.fromCharCode, wo = Object.assign;
function To(e, t) {
	return ko(e, 0) ^ 45 ? (((t << 2 ^ ko(e, 0)) << 2 ^ ko(e, 1)) << 2 ^ ko(e, 2)) << 2 ^ ko(e, 3) : 0;
}
function Eo(e) {
	return e.trim();
}
function Do(e, t) {
	return (e = t.exec(e)) ? e[0] : e;
}
function P(e, t, n) {
	return e.replace(t, n);
}
function Oo(e, t) {
	return e.indexOf(t);
}
function ko(e, t) {
	return e.charCodeAt(t) | 0;
}
function Ao(e, t, n) {
	return e.slice(t, n);
}
function jo(e) {
	return e.length;
}
function Mo(e) {
	return e.length;
}
function No(e, t) {
	return t.push(e), e;
}
function Po(e, t) {
	return e.map(t).join("");
}
//#endregion
//#region node_modules/stylis/src/Tokenizer.js
var Fo = 1, Io = 1, Lo = 0, Ro = 0, zo = 0, Bo = "";
function Vo(e, t, n, r, i, a, o) {
	return {
		value: e,
		root: t,
		parent: n,
		type: r,
		props: i,
		children: a,
		line: Fo,
		column: Io,
		length: o,
		return: ""
	};
}
function Ho(e, t) {
	return wo(Vo("", null, null, "", null, null, 0), e, { length: -e.length }, t);
}
function Uo() {
	return zo;
}
function Wo() {
	return zo = Ro > 0 ? ko(Bo, --Ro) : 0, Io--, zo === 10 && (Io = 1, Fo--), zo;
}
function Go() {
	return zo = Ro < Lo ? ko(Bo, Ro++) : 0, Io++, zo === 10 && (Io = 1, Fo++), zo;
}
function Ko() {
	return ko(Bo, Ro);
}
function qo() {
	return Ro;
}
function Jo(e, t) {
	return Ao(Bo, e, t);
}
function Yo(e) {
	switch (e) {
		case 0:
		case 9:
		case 10:
		case 13:
		case 32: return 5;
		case 33:
		case 43:
		case 44:
		case 47:
		case 62:
		case 64:
		case 126:
		case 59:
		case 123:
		case 125: return 4;
		case 58: return 3;
		case 34:
		case 39:
		case 40:
		case 91: return 2;
		case 41:
		case 93: return 1;
	}
	return 0;
}
function Xo(e) {
	return Fo = Io = 1, Lo = jo(Bo = e), Ro = 0, [];
}
function Zo(e) {
	return Bo = "", e;
}
function Qo(e) {
	return Eo(Jo(Ro - 1, ts(e === 91 ? e + 2 : e === 40 ? e + 1 : e)));
}
function $o(e) {
	for (; (zo = Ko()) && zo < 33;) Go();
	return Yo(e) > 2 || Yo(zo) > 3 ? "" : " ";
}
function es(e, t) {
	for (; --t && Go() && !(zo < 48 || zo > 102 || zo > 57 && zo < 65 || zo > 70 && zo < 97););
	return Jo(e, qo() + (t < 6 && Ko() == 32 && Go() == 32));
}
function ts(e) {
	for (; Go();) switch (zo) {
		case e: return Ro;
		case 34:
		case 39:
			e !== 34 && e !== 39 && ts(zo);
			break;
		case 40:
			e === 41 && ts(e);
			break;
		case 92: Go();
	}
	return Ro;
}
function ns(e, t) {
	for (; Go() && e + zo !== 57 && (e + zo !== 84 || Ko() !== 47););
	return "/*" + Jo(t, Ro - 1) + "*" + Co(e === 47 ? e : Go());
}
function rs(e) {
	for (; !Yo(Ko());) Go();
	return Jo(e, Ro);
}
//#endregion
//#region node_modules/stylis/src/Parser.js
function is(e) {
	return Zo(as("", null, null, null, [""], e = Xo(e), 0, [0], e));
}
function as(e, t, n, r, i, a, o, s, c) {
	for (var l = 0, u = 0, d = o, f = 0, p = 0, m = 0, h = 1, g = 1, _ = 1, v = 0, y = "", b = i, x = a, S = r, C = y; g;) switch (m = v, v = Go()) {
		case 40: if (m != 108 && ko(C, d - 1) == 58) {
			Oo(C += P(Qo(v), "&", "&\f"), "&\f") != -1 && (_ = -1);
			break;
		}
		case 34:
		case 39:
		case 91:
			C += Qo(v);
			break;
		case 9:
		case 10:
		case 13:
		case 32:
			C += $o(m);
			break;
		case 92:
			C += es(qo() - 1, 7);
			continue;
		case 47:
			switch (Ko()) {
				case 42:
				case 47:
					No(ss(ns(Go(), qo()), t, n), c);
					break;
				default: C += "/";
			}
			break;
		case 123 * h: s[l++] = jo(C) * _;
		case 125 * h:
		case 59:
		case 0:
			switch (v) {
				case 0:
				case 125: g = 0;
				case 59 + u:
					_ == -1 && (C = P(C, /\f/g, "")), p > 0 && jo(C) - d && No(p > 32 ? cs(C + ";", r, n, d - 1) : cs(P(C, " ", "") + ";", r, n, d - 2), c);
					break;
				case 59: C += ";";
				default: if (No(S = os(C, t, n, l, u, i, s, y, b = [], x = [], d), a), v === 123) {
					if (u === 0) as(C, t, S, S, b, a, d, s, x);
					else switch (f === 99 && ko(C, 3) === 110 ? 100 : f) {
						case 100:
						case 108:
						case 109:
						case 115:
							as(e, S, S, r && No(os(e, S, S, 0, 0, i, s, y, i, b = [], d), x), i, x, d, s, r ? b : x);
							break;
						default: as(C, S, S, S, [""], x, 0, s, x);
					}
				}
			}
			l = u = p = 0, h = _ = 1, y = C = "", d = o;
			break;
		case 58: d = 1 + jo(C), p = m;
		default:
			if (h < 1) {
				if (v == 123) --h;
				else if (v == 125 && h++ == 0 && Wo() == 125) continue;
			}
			switch (C += Co(v), v * h) {
				case 38:
					_ = u > 0 ? 1 : (C += "\f", -1);
					break;
				case 44:
					s[l++] = (jo(C) - 1) * _, _ = 1;
					break;
				case 64:
					Ko() === 45 && (C += Qo(Go())), f = Ko(), u = d = jo(y = C += rs(qo())), v++;
					break;
				case 45: m === 45 && jo(C) == 2 && (h = 0);
			}
	}
	return a;
}
function os(e, t, n, r, i, a, o, s, c, l, u) {
	for (var d = i - 1, f = i === 0 ? a : [""], p = Mo(f), m = 0, h = 0, g = 0; m < r; ++m) for (var _ = 0, v = Ao(e, d + 1, d = So(h = o[m])), y = e; _ < p; ++_) (y = Eo(h > 0 ? f[_] + " " + v : P(v, /&\f/g, f[_]))) && (c[g++] = y);
	return Vo(e, t, n, i === 0 ? _o : s, c, l, u);
}
function ss(e, t, n) {
	return Vo(e, t, n, go, Co(Uo()), Ao(e, 2, -2), 0);
}
function cs(e, t, n, r) {
	return Vo(e, t, n, vo, Ao(e, 0, r), Ao(e, r + 1, -1), r);
}
//#endregion
//#region node_modules/stylis/src/Serializer.js
function ls(e, t) {
	for (var n = "", r = Mo(e), i = 0; i < r; i++) n += t(e[i], i, e, t) || "";
	return n;
}
function us(e, t, n, r) {
	switch (e.type) {
		case xo: if (e.children.length) break;
		case yo:
		case vo: return e.return = e.return || e.value;
		case go: return "";
		case bo: return e.return = e.value + "{" + ls(e.children, r) + "}";
		case _o: e.value = e.props.join(",");
	}
	return jo(n = ls(e.children, r)) ? e.return = e.value + "{" + n + "}" : "";
}
//#endregion
//#region node_modules/stylis/src/Middleware.js
function ds(e) {
	var t = Mo(e);
	return function(n, r, i, a) {
		for (var o = "", s = 0; s < t; s++) o += e[s](n, r, i, a) || "";
		return o;
	};
}
function fs(e) {
	return function(t) {
		t.root || (t = t.return) && e(t);
	};
}
//#endregion
//#region node_modules/@emotion/memoize/dist/emotion-memoize.esm.js
function ps(e) {
	var t = Object.create(null);
	return function(n) {
		return t[n] === void 0 && (t[n] = e(n)), t[n];
	};
}
//#endregion
//#region node_modules/@emotion/cache/dist/emotion-cache.browser.esm.js
var ms = function(e, t, n) {
	for (var r = 0, i = 0; r = i, i = Ko(), r === 38 && i === 12 && (t[n] = 1), !Yo(i);) Go();
	return Jo(e, Ro);
}, hs = function(e, t) {
	var n = -1, r = 44;
	do
		switch (Yo(r)) {
			case 0:
				r === 38 && Ko() === 12 && (t[n] = 1), e[n] += ms(Ro - 1, t, n);
				break;
			case 2:
				e[n] += Qo(r);
				break;
			case 4: if (r === 44) {
				e[++n] = Ko() === 58 ? "&\f" : "", t[n] = e[n].length;
				break;
			}
			default: e[n] += Co(r);
		}
	while (r = Go());
	return e;
}, gs = function(e, t) {
	return Zo(hs(Xo(e), t));
}, _s = /* #__PURE__ */ new WeakMap(), vs = function(e) {
	if (!(e.type !== "rule" || !e.parent || e.length < 1)) {
		for (var t = e.value, n = e.parent, r = e.column === n.column && e.line === n.line; n.type !== "rule";) if (n = n.parent, !n) return;
		if ((e.props.length !== 1 || t.charCodeAt(0) === 58 || _s.get(n)) && !r) {
			_s.set(e, !0);
			for (var i = [], a = gs(t, i), o = n.props, s = 0, c = 0; s < a.length; s++) for (var l = 0; l < o.length; l++, c++) e.props[c] = i[s] ? a[s].replace(/&\f/g, o[l]) : o[l] + " " + a[s];
		}
	}
}, ys = function(e) {
	if (e.type === "decl") {
		var t = e.value;
		t.charCodeAt(0) === 108 && t.charCodeAt(2) === 98 && (e.return = "", e.value = "");
	}
};
function bs(e, t) {
	switch (To(e, t)) {
		case 5103: return N + "print-" + e + e;
		case 5737:
		case 4201:
		case 3177:
		case 3433:
		case 1641:
		case 4457:
		case 2921:
		case 5572:
		case 6356:
		case 5844:
		case 3191:
		case 6645:
		case 3005:
		case 6391:
		case 5879:
		case 5623:
		case 6135:
		case 4599:
		case 4855:
		case 4215:
		case 6389:
		case 5109:
		case 5365:
		case 5621:
		case 3829: return N + e + e;
		case 5349:
		case 4246:
		case 4810:
		case 6968:
		case 2756: return N + e + ho + e + mo + e + e;
		case 6828:
		case 4268: return N + e + mo + e + e;
		case 6165: return N + e + mo + "flex-" + e + e;
		case 5187: return N + e + P(e, /(\w+).+(:[^]+)/, N + "box-$1$2" + mo + "flex-$1$2") + e;
		case 5443: return N + e + mo + "flex-item-" + P(e, /flex-|-self/, "") + e;
		case 4675: return N + e + mo + "flex-line-pack" + P(e, /align-content|flex-|-self/, "") + e;
		case 5548: return N + e + mo + P(e, "shrink", "negative") + e;
		case 5292: return N + e + mo + P(e, "basis", "preferred-size") + e;
		case 6060: return N + "box-" + P(e, "-grow", "") + N + e + mo + P(e, "grow", "positive") + e;
		case 4554: return N + P(e, /([^-])(transform)/g, "$1" + N + "$2") + e;
		case 6187: return P(P(P(e, /(zoom-|grab)/, N + "$1"), /(image-set)/, N + "$1"), e, "") + e;
		case 5495:
		case 3959: return P(e, /(image-set\([^]*)/, N + "$1$`$1");
		case 4968: return P(P(e, /(.+:)(flex-)?(.*)/, N + "box-pack:$3" + mo + "flex-pack:$3"), /s.+-b[^;]+/, "justify") + N + e + e;
		case 4095:
		case 3583:
		case 4068:
		case 2532: return P(e, /(.+)-inline(.+)/, N + "$1$2") + e;
		case 8116:
		case 7059:
		case 5753:
		case 5535:
		case 5445:
		case 5701:
		case 4933:
		case 4677:
		case 5533:
		case 5789:
		case 5021:
		case 4765:
			if (jo(e) - 1 - t > 6) switch (ko(e, t + 1)) {
				case 109: if (ko(e, t + 4) !== 45) break;
				case 102: return P(e, /(.+:)(.+)-([^]+)/, "$1" + N + "$2-$3$1" + ho + (ko(e, t + 3) == 108 ? "$3" : "$2-$3")) + e;
				case 115: return ~Oo(e, "stretch") ? bs(P(e, "stretch", "fill-available"), t) + e : e;
			}
			break;
		case 4949: if (ko(e, t + 1) !== 115) break;
		case 6444:
			switch (ko(e, jo(e) - 3 - (~Oo(e, "!important") && 10))) {
				case 107: return P(e, ":", ":" + N) + e;
				case 101: return P(e, /(.+:)([^;!]+)(;|!.+)?/, "$1" + N + (ko(e, 14) === 45 ? "inline-" : "") + "box$3$1" + N + "$2$3$1" + mo + "$2box$3") + e;
			}
			break;
		case 5936:
			switch (ko(e, t + 11)) {
				case 114: return N + e + mo + P(e, /[svh]\w+-[tblr]{2}/, "tb") + e;
				case 108: return N + e + mo + P(e, /[svh]\w+-[tblr]{2}/, "tb-rl") + e;
				case 45: return N + e + mo + P(e, /[svh]\w+-[tblr]{2}/, "lr") + e;
			}
			return N + e + mo + e + e;
	}
	return e;
}
var xs = [function(e, t, n, r) {
	if (e.length > -1 && !e.return) switch (e.type) {
		case vo:
			e.return = bs(e.value, e.length);
			break;
		case bo: return ls([Ho(e, { value: P(e.value, "@", "@" + N) })], r);
		case _o: if (e.length) return Po(e.props, function(t) {
			switch (Do(t, /(::plac\w+|:read-\w+)/)) {
				case ":read-only":
				case ":read-write": return ls([Ho(e, { props: [P(t, /:(read-\w+)/, ":" + ho + "$1")] })], r);
				case "::placeholder": return ls([
					Ho(e, { props: [P(t, /:(plac\w+)/, ":" + N + "input-$1")] }),
					Ho(e, { props: [P(t, /:(plac\w+)/, ":" + ho + "$1")] }),
					Ho(e, { props: [P(t, /:(plac\w+)/, mo + "input-$1")] })
				], r);
			}
			return "";
		});
	}
}], Ss = function(e) {
	var t = e.key;
	if (t === "css") {
		var n = document.querySelectorAll("style[data-emotion]:not([data-s])");
		Array.prototype.forEach.call(n, function(e) {
			e.getAttribute("data-emotion").indexOf(" ") !== -1 && (document.head.appendChild(e), e.setAttribute("data-s", ""));
		});
	}
	var r = e.stylisPlugins || xs, i = {}, a, o = [];
	a = e.container || document.head, Array.prototype.forEach.call(document.querySelectorAll("style[data-emotion^=\"" + t + " \"]"), function(e) {
		for (var t = e.getAttribute("data-emotion").split(" "), n = 1; n < t.length; n++) i[t[n]] = !0;
		o.push(e);
	});
	var s, c = [vs, ys], l, u = [us, fs(function(e) {
		l.insert(e);
	})], d = ds(c.concat(r, u)), f = function(e) {
		return ls(is(e), d);
	};
	s = function(e, t, n, r) {
		l = n, f(e ? e + "{" + t.styles + "}" : t.styles), r && (p.inserted[t.name] = !0);
	};
	var p = {
		key: t,
		sheet: new po({
			key: t,
			container: a,
			nonce: e.nonce,
			speedy: e.speedy,
			prepend: e.prepend,
			insertionPoint: e.insertionPoint
		}),
		nonce: e.nonce,
		inserted: i,
		registered: {},
		insert: s
	};
	return p.sheet.hydrate(o), p;
}, Cs = /* @__PURE__ */ r(((e) => {
	var t = typeof Symbol == "function" && Symbol.for, n = t ? Symbol.for("react.element") : 60103, r = t ? Symbol.for("react.portal") : 60106, i = t ? Symbol.for("react.fragment") : 60107, a = t ? Symbol.for("react.strict_mode") : 60108, o = t ? Symbol.for("react.profiler") : 60114, s = t ? Symbol.for("react.provider") : 60109, c = t ? Symbol.for("react.context") : 60110, l = t ? Symbol.for("react.async_mode") : 60111, u = t ? Symbol.for("react.concurrent_mode") : 60111, d = t ? Symbol.for("react.forward_ref") : 60112, f = t ? Symbol.for("react.suspense") : 60113, p = t ? Symbol.for("react.suspense_list") : 60120, m = t ? Symbol.for("react.memo") : 60115, h = t ? Symbol.for("react.lazy") : 60116, g = t ? Symbol.for("react.block") : 60121, _ = t ? Symbol.for("react.fundamental") : 60117, v = t ? Symbol.for("react.responder") : 60118, y = t ? Symbol.for("react.scope") : 60119;
	function b(e) {
		if (typeof e == "object" && e) {
			var t = e.$$typeof;
			switch (t) {
				case n: switch (e = e.type, e) {
					case l:
					case u:
					case i:
					case o:
					case a:
					case f: return e;
					default: switch (e &&= e.$$typeof, e) {
						case c:
						case d:
						case h:
						case m:
						case s: return e;
						default: return t;
					}
				}
				case r: return t;
			}
		}
	}
	function x(e) {
		return b(e) === u;
	}
	e.AsyncMode = l, e.ConcurrentMode = u, e.ContextConsumer = c, e.ContextProvider = s, e.Element = n, e.ForwardRef = d, e.Fragment = i, e.Lazy = h, e.Memo = m, e.Portal = r, e.Profiler = o, e.StrictMode = a, e.Suspense = f, e.isAsyncMode = function(e) {
		return x(e) || b(e) === l;
	}, e.isConcurrentMode = x, e.isContextConsumer = function(e) {
		return b(e) === c;
	}, e.isContextProvider = function(e) {
		return b(e) === s;
	}, e.isElement = function(e) {
		return typeof e == "object" && !!e && e.$$typeof === n;
	}, e.isForwardRef = function(e) {
		return b(e) === d;
	}, e.isFragment = function(e) {
		return b(e) === i;
	}, e.isLazy = function(e) {
		return b(e) === h;
	}, e.isMemo = function(e) {
		return b(e) === m;
	}, e.isPortal = function(e) {
		return b(e) === r;
	}, e.isProfiler = function(e) {
		return b(e) === o;
	}, e.isStrictMode = function(e) {
		return b(e) === a;
	}, e.isSuspense = function(e) {
		return b(e) === f;
	}, e.isValidElementType = function(e) {
		return typeof e == "string" || typeof e == "function" || e === i || e === u || e === o || e === a || e === f || e === p || typeof e == "object" && !!e && (e.$$typeof === h || e.$$typeof === m || e.$$typeof === s || e.$$typeof === c || e.$$typeof === d || e.$$typeof === _ || e.$$typeof === v || e.$$typeof === y || e.$$typeof === g);
	}, e.typeOf = b;
})), ws = /* @__PURE__ */ r(((e, t) => {
	t.exports = Cs();
})), Ts = /* @__PURE__ */ r(((e, t) => {
	var n = ws(), r = {
		childContextTypes: !0,
		contextType: !0,
		contextTypes: !0,
		defaultProps: !0,
		displayName: !0,
		getDefaultProps: !0,
		getDerivedStateFromError: !0,
		getDerivedStateFromProps: !0,
		mixins: !0,
		propTypes: !0,
		type: !0
	}, i = {
		name: !0,
		length: !0,
		prototype: !0,
		caller: !0,
		callee: !0,
		arguments: !0,
		arity: !0
	}, a = {
		$$typeof: !0,
		render: !0,
		defaultProps: !0,
		displayName: !0,
		propTypes: !0
	}, o = {
		$$typeof: !0,
		compare: !0,
		defaultProps: !0,
		displayName: !0,
		propTypes: !0,
		type: !0
	}, s = {};
	s[n.ForwardRef] = a, s[n.Memo] = o;
	function c(e) {
		return n.isMemo(e) ? o : s[e.$$typeof] || r;
	}
	var l = Object.defineProperty, u = Object.getOwnPropertyNames, d = Object.getOwnPropertySymbols, f = Object.getOwnPropertyDescriptor, p = Object.getPrototypeOf, m = Object.prototype;
	function h(e, t, n) {
		if (typeof t != "string") {
			if (m) {
				var r = p(t);
				r && r !== m && h(e, r, n);
			}
			var a = u(t);
			d && (a = a.concat(d(t)));
			for (var o = c(e), s = c(t), g = 0; g < a.length; ++g) {
				var _ = a[g];
				if (!i[_] && !(n && n[_]) && !(s && s[_]) && !(o && o[_])) {
					var v = f(t, _);
					try {
						l(e, _, v);
					} catch {}
				}
			}
		}
		return e;
	}
	t.exports = h;
}));
//#endregion
//#region node_modules/@emotion/utils/dist/emotion-utils.browser.esm.js
function Es(e, t, n) {
	var r = "";
	return n.split(" ").forEach(function(n) {
		e[n] === void 0 ? n && (r += n + " ") : t.push(e[n] + ";");
	}), r;
}
var Ds = function(e, t, n) {
	var r = e.key + "-" + t.name;
	n === !1 && e.registered[r] === void 0 && (e.registered[r] = t.styles);
}, Os = function(e, t, n) {
	Ds(e, t, n);
	var r = e.key + "-" + t.name;
	if (e.inserted[t.name] === void 0) {
		var i = t;
		do
			e.insert(t === i ? "." + r : "", i, e.sheet, !0), i = i.next;
		while (i !== void 0);
	}
};
//#endregion
//#region node_modules/@emotion/hash/dist/emotion-hash.esm.js
function ks(e) {
	for (var t = 0, n, r = 0, i = e.length; i >= 4; ++r, i -= 4) n = e.charCodeAt(r) & 255 | (e.charCodeAt(++r) & 255) << 8 | (e.charCodeAt(++r) & 255) << 16 | (e.charCodeAt(++r) & 255) << 24, n = (n & 65535) * 1540483477 + ((n >>> 16) * 59797 << 16), n ^= n >>> 24, t = (n & 65535) * 1540483477 + ((n >>> 16) * 59797 << 16) ^ (t & 65535) * 1540483477 + ((t >>> 16) * 59797 << 16);
	switch (i) {
		case 3: t ^= (e.charCodeAt(r + 2) & 255) << 16;
		case 2: t ^= (e.charCodeAt(r + 1) & 255) << 8;
		case 1: t ^= e.charCodeAt(r) & 255, t = (t & 65535) * 1540483477 + ((t >>> 16) * 59797 << 16);
	}
	return t ^= t >>> 13, t = (t & 65535) * 1540483477 + ((t >>> 16) * 59797 << 16), ((t ^ t >>> 15) >>> 0).toString(36);
}
//#endregion
//#region node_modules/@emotion/unitless/dist/emotion-unitless.esm.js
var As = {
	animationIterationCount: 1,
	aspectRatio: 1,
	borderImageOutset: 1,
	borderImageSlice: 1,
	borderImageWidth: 1,
	boxFlex: 1,
	boxFlexGroup: 1,
	boxOrdinalGroup: 1,
	columnCount: 1,
	columns: 1,
	flex: 1,
	flexGrow: 1,
	flexPositive: 1,
	flexShrink: 1,
	flexNegative: 1,
	flexOrder: 1,
	gridRow: 1,
	gridRowEnd: 1,
	gridRowSpan: 1,
	gridRowStart: 1,
	gridColumn: 1,
	gridColumnEnd: 1,
	gridColumnSpan: 1,
	gridColumnStart: 1,
	msGridRow: 1,
	msGridRowSpan: 1,
	msGridColumn: 1,
	msGridColumnSpan: 1,
	fontWeight: 1,
	lineHeight: 1,
	opacity: 1,
	order: 1,
	orphans: 1,
	scale: 1,
	tabSize: 1,
	widows: 1,
	zIndex: 1,
	zoom: 1,
	WebkitLineClamp: 1,
	fillOpacity: 1,
	floodOpacity: 1,
	stopOpacity: 1,
	strokeDasharray: 1,
	strokeDashoffset: 1,
	strokeMiterlimit: 1,
	strokeOpacity: 1,
	strokeWidth: 1
}, js = /[A-Z]|^ms/g, Ms = /_EMO_([^_]+?)_([^]*?)_EMO_/g, Ns = function(e) {
	return e.charCodeAt(1) === 45;
}, Ps = function(e) {
	return e != null && typeof e != "boolean";
}, Fs = /* #__PURE__ */ ps(function(e) {
	return Ns(e) ? e : e.replace(js, "-$&").toLowerCase();
}), Is = function(e, t) {
	switch (e) {
		case "animation":
		case "animationName": if (typeof t == "string") return t.replace(Ms, function(e, t, n) {
			return Bs = {
				name: t,
				styles: n,
				next: Bs
			}, t;
		});
	}
	return As[e] !== 1 && !Ns(e) && typeof t == "number" && t !== 0 ? t + "px" : t;
};
function Ls(e, t, n) {
	if (n == null) return "";
	var r = n;
	if (r.__emotion_styles !== void 0) return r;
	switch (typeof n) {
		case "boolean": return "";
		case "object":
			var i = n;
			if (i.anim === 1) return Bs = {
				name: i.name,
				styles: i.styles,
				next: Bs
			}, i.name;
			var a = n;
			if (a.styles !== void 0) {
				var o = a.next;
				if (o !== void 0) for (; o !== void 0;) Bs = {
					name: o.name,
					styles: o.styles,
					next: Bs
				}, o = o.next;
				return a.styles + ";";
			}
			return Rs(e, t, n);
		case "function": if (e !== void 0) {
			var s = Bs, c = n(e);
			return Bs = s, Ls(e, t, c);
		}
	}
	var l = n;
	if (t == null) return l;
	var u = t[l];
	return u === void 0 ? l : u;
}
function Rs(e, t, n) {
	var r = "";
	if (Array.isArray(n)) for (var i = 0; i < n.length; i++) r += Ls(e, t, n[i]) + ";";
	else for (var a in n) {
		var o = n[a];
		if (typeof o != "object") {
			var s = o;
			t != null && t[s] !== void 0 ? r += a + "{" + t[s] + "}" : Ps(s) && (r += Fs(a) + ":" + Is(a, s) + ";");
		} else if (Array.isArray(o) && typeof o[0] == "string" && (t == null || t[o[0]] === void 0)) for (var c = 0; c < o.length; c++) Ps(o[c]) && (r += Fs(a) + ":" + Is(a, o[c]) + ";");
		else {
			var l = Ls(e, t, o);
			switch (a) {
				case "animation":
				case "animationName":
					r += Fs(a) + ":" + l + ";";
					break;
				default: r += a + "{" + l + "}";
			}
		}
	}
	return r;
}
var zs = /label:\s*([^\s;{]+)\s*(;|$)/g, Bs;
function Vs(e, t, n) {
	if (e.length === 1 && typeof e[0] == "object" && e[0] !== null && e[0].styles !== void 0) return e[0];
	var r = !0, i = "";
	Bs = void 0;
	var a = e[0];
	a == null || a.raw === void 0 ? (r = !1, i += Ls(n, t, a)) : i += a[0];
	for (var o = 1; o < e.length; o++) i += Ls(n, t, e[o]), r && (i += a[o]);
	zs.lastIndex = 0;
	for (var s = "", c; (c = zs.exec(i)) !== null;) s += "-" + c[1];
	return {
		name: ks(i) + s,
		styles: i,
		next: Bs
	};
}
//#endregion
//#region node_modules/@emotion/use-insertion-effect-with-fallbacks/dist/emotion-use-insertion-effect-with-fallbacks.browser.esm.js
k();
var Hs = he || function(e) {
	return e();
};
//#endregion
//#region node_modules/@emotion/react/dist/emotion-element-f0de968e.browser.esm.js
k();
var Us = /* #__PURE__ */ C(typeof HTMLElement < "u" ? /* #__PURE__ */ Ss({ key: "css" }) : null);
Us.Provider;
var Ws = function(e) {
	return /*#__PURE__*/ T(function(t, n) {
		return e(t, le(Us), n);
	});
}, Gs = /* #__PURE__ */ C({}), Ks = {}.hasOwnProperty, qs = "__EMOTION_TYPE_PLEASE_DO_NOT_USE__", Js = function(e, t) {
	var n = {};
	for (var r in t) Ks.call(t, r) && (n[r] = t[r]);
	return n[qs] = e, n;
}, Ys = function(e) {
	var t = e.cache, n = e.serialized, r = e.isStringTag;
	return Ds(t, n, r), Hs(function() {
		return Os(t, n, r);
	}), null;
}, Xs = /* @__PURE__ */ Ws(function(e, t, n) {
	var r = e.css;
	typeof r == "string" && t.registered[r] !== void 0 && (r = t.registered[r]);
	var i = e[qs], a = [r], o = "";
	typeof e.className == "string" ? o = Es(t.registered, a, e.className) : e.className != null && (o = e.className + " ");
	var s = Vs(a, void 0, le(Gs));
	o += t.key + "-" + s.name;
	var c = {};
	for (var u in e) Ks.call(e, u) && u !== "css" && u !== qs && (c[u] = e[u]);
	return c.className = o, n && (c.ref = n), /*#__PURE__*/ w(l, null, /*#__PURE__*/ w(Ys, {
		cache: t,
		serialized: s,
		isStringTag: typeof i == "string"
	}), /*#__PURE__*/ w(i, c));
});
//#endregion
//#region node_modules/@emotion/react/dist/emotion-react.browser.esm.js
k(), Ts();
var F = function(e, t) {
	var n = arguments;
	if (t == null || !Ks.call(t, "css")) return w.apply(void 0, n);
	var r = n.length, i = Array(r);
	i[0] = Xs, i[1] = Js(e, t);
	for (var a = 2; a < r; a++) i[a] = n[a];
	return w.apply(null, i);
};
(function(e) {
	var t;
	t ||= e.JSX ||= {};
})(F ||= {});
function Zs() {
	return Vs([...arguments]);
}
function Qs() {
	var e = Zs.apply(void 0, arguments), t = "animation-" + e.name;
	return {
		name: t,
		styles: "@keyframes " + t + "{" + e.styles + "}",
		anim: 1,
		toString: function() {
			return "_EMO_" + this.name + "_" + this.styles + "_EMO_";
		}
	};
}
//#endregion
//#region node_modules/@babel/runtime/helpers/esm/taggedTemplateLiteral.js
function $s(e, t) {
	return t ||= e.slice(0), Object.freeze(Object.defineProperties(e, { raw: { value: Object.freeze(t) } }));
}
//#endregion
//#region node_modules/react-dom/cjs/react-dom.production.js
var ec = /* @__PURE__ */ r(((t) => {
	var n = (k(), e(i));
	function r(e) {
		var t = "https://react.dev/errors/" + e;
		if (1 < arguments.length) {
			t += "?args[]=" + encodeURIComponent(arguments[1]);
			for (var n = 2; n < arguments.length; n++) t += "&args[]=" + encodeURIComponent(arguments[n]);
		}
		return "Minified React error #" + e + "; visit " + t + " for the full message or use the non-minified dev environment for full errors and additional helpful warnings.";
	}
	var a = Symbol.for("react.portal"), o = Symbol.for("react.optimistic_key");
	function s(e, t, n) {
		var r = 3 < arguments.length && arguments[3] !== void 0 ? arguments[3] : null;
		return {
			$$typeof: a,
			key: r == null ? null : r === o ? o : "" + r,
			children: e,
			containerInfo: t,
			implementation: n
		};
	}
	n.__CLIENT_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE, t.createPortal = function(e, t) {
		var n = 2 < arguments.length && arguments[2] !== void 0 ? arguments[2] : null;
		if (!t || t.nodeType !== 1 && t.nodeType !== 9 && t.nodeType !== 11) throw Error(r(299));
		return s(e, t, null, n);
	};
})), tc = (/* @__PURE__ */ r(((e, t) => {
	function n() {
		if (typeof __REACT_DEVTOOLS_GLOBAL_HOOK__ < "u" && typeof __REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE == "function") try {
			__REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE(n);
		} catch (e) {
			console.error(e);
		}
	}
	n(), t.exports = ec();
})))(), nc = Math.min, rc = Math.max, ic = Math.round, ac = Math.floor, oc = (e) => ({
	x: e,
	y: e
});
function sc(e) {
	let { x: t, y: n, width: r, height: i } = e;
	return {
		width: r,
		height: i,
		top: n,
		left: t,
		right: t + r,
		bottom: n + i,
		x: t,
		y: n
	};
}
//#endregion
//#region node_modules/@floating-ui/utils/dist/floating-ui.utils.dom.mjs
function cc() {
	return typeof window < "u";
}
function lc(e) {
	return fc(e) ? (e.nodeName || "").toLowerCase() : "#document";
}
function uc(e) {
	var t;
	return (e == null || (t = e.ownerDocument) == null ? void 0 : t.defaultView) || window;
}
function dc(e) {
	return ((fc(e) ? e.ownerDocument : e.document) || window.document)?.documentElement;
}
function fc(e) {
	return cc() ? e instanceof Node || e instanceof uc(e).Node : !1;
}
function pc(e) {
	return cc() ? e instanceof Element || e instanceof uc(e).Element : !1;
}
function mc(e) {
	return cc() ? e instanceof HTMLElement || e instanceof uc(e).HTMLElement : !1;
}
function hc(e) {
	return !cc() || typeof ShadowRoot > "u" ? !1 : e instanceof ShadowRoot || e instanceof uc(e).ShadowRoot;
}
function gc(e) {
	let { overflow: t, overflowX: n, overflowY: r, display: i } = bc(e);
	return /auto|scroll|overlay|hidden|clip/.test(t + r + n) && i !== "inline" && i !== "contents";
}
var _c;
function vc() {
	return _c ??= typeof CSS < "u" && CSS.supports && CSS.supports("-webkit-backdrop-filter", "none"), _c;
}
function yc(e) {
	return /^(html|body|#document)$/.test(lc(e));
}
function bc(e) {
	return uc(e).getComputedStyle(e);
}
function xc(e) {
	if (lc(e) === "html") return e;
	let t = e.assignedSlot || e.parentNode || hc(e) && e.host || dc(e);
	return hc(t) ? t.host : t;
}
function Sc(e) {
	let t = xc(e);
	return yc(t) ? (e.ownerDocument || e).body : mc(t) && gc(t) ? t : Sc(t);
}
function Cc(e, t, n) {
	t === void 0 && (t = []), n === void 0 && (n = !0);
	let r = Sc(e), i = r === e.ownerDocument?.body, a = uc(r);
	if (i) {
		let e = wc(a);
		return t.concat(a, a.visualViewport || [], gc(r) ? r : [], e && n ? Cc(e) : []);
	}
	return t.concat(r, Cc(r, [], n));
}
function wc(e) {
	return e.parent && Object.getPrototypeOf(e.parent) ? e.frameElement : null;
}
//#endregion
//#region node_modules/@floating-ui/dom/dist/floating-ui.dom.mjs
function Tc(e) {
	let t = bc(e), n = parseFloat(t.width) || 0, r = parseFloat(t.height) || 0, i = mc(e), a = i ? e.offsetWidth : n, o = i ? e.offsetHeight : r, s = ic(n) !== a || ic(r) !== o;
	return s && (n = a, r = o), {
		width: n,
		height: r,
		$: s
	};
}
function Ec(e) {
	return pc(e) ? e : e.contextElement;
}
function Dc(e) {
	let t = Ec(e);
	if (!mc(t)) return oc(1);
	let n = t.getBoundingClientRect(), { width: r, height: i, $: a } = Tc(t), o = (a ? ic(n.width) : n.width) / r, s = (a ? ic(n.height) : n.height) / i;
	return (!o || !Number.isFinite(o)) && (o = 1), (!s || !Number.isFinite(s)) && (s = 1), {
		x: o,
		y: s
	};
}
var Oc = /*#__PURE__*/ oc(0);
function kc(e) {
	let t = uc(e);
	return !vc() || !t.visualViewport ? Oc : {
		x: t.visualViewport.offsetLeft,
		y: t.visualViewport.offsetTop
	};
}
function Ac(e, t, n) {
	return t === void 0 && (t = !1), !!n && t && n === uc(e);
}
function jc(e, t, n, r) {
	t === void 0 && (t = !1), n === void 0 && (n = !1);
	let i = e.getBoundingClientRect(), a = Ec(e), o = oc(1);
	t && (r ? pc(r) && (o = Dc(r)) : o = Dc(e));
	let s = Ac(a, n, r) ? kc(a) : oc(0), c = (i.left + s.x) / o.x, l = (i.top + s.y) / o.y, u = i.width / o.x, d = i.height / o.y;
	if (a && r) {
		let e = uc(a), t = pc(r) ? uc(r) : r, n = e, i = wc(n);
		for (; i && t !== n;) {
			let e = Dc(i), t = i.getBoundingClientRect(), r = bc(i), a = t.left + (i.clientLeft + parseFloat(r.paddingLeft)) * e.x, o = t.top + (i.clientTop + parseFloat(r.paddingTop)) * e.y;
			c *= e.x, l *= e.y, u *= e.x, d *= e.y, c += a, l += o, n = uc(i), i = wc(n);
		}
	}
	return sc({
		width: u,
		height: d,
		x: c,
		y: l
	});
}
function Mc(e, t) {
	return e.x === t.x && e.y === t.y && e.width === t.width && e.height === t.height;
}
function Nc(e, t, n) {
	let r = null, i, a = dc(e);
	function o() {
		var e;
		clearTimeout(i), (e = r) == null || e.disconnect(), r = null;
	}
	function s(n, c) {
		n === void 0 && (n = !1), c === void 0 && (c = 1), o();
		let l = e.getBoundingClientRect(), { left: u, top: d, width: f, height: p } = l;
		if (n || t(), !f || !p) return;
		let m = ac(d), h = ac(a.clientWidth - (u + f)), g = ac(a.clientHeight - (d + p)), _ = ac(u), v = {
			rootMargin: -m + "px " + -h + "px " + -g + "px " + -_ + "px",
			threshold: rc(0, nc(1, c)) || 1
		}, y = !0;
		function b(t) {
			let n = t[0].intersectionRatio;
			if (!Mc(l, e.getBoundingClientRect())) return s();
			if (n !== c) {
				if (!y) return s();
				n ? s(!1, n) : i = setTimeout(() => {
					s(!1, 1e-7);
				}, 1e3);
			}
			y = !1;
		}
		try {
			r = new IntersectionObserver(b, {
				...v,
				root: a.ownerDocument
			});
		} catch {
			r = new IntersectionObserver(b, v);
		}
		r.observe(e);
	}
	let c = uc(e), l = () => s(n);
	return c.addEventListener("resize", l), s(!0), () => {
		c.removeEventListener("resize", l), o();
	};
}
function Pc(e, t, n, r) {
	r === void 0 && (r = {});
	let { ancestorScroll: i = !0, ancestorResize: a = !0, elementResize: o = typeof ResizeObserver == "function", layoutShift: s = typeof IntersectionObserver == "function", animationFrame: c = !1 } = r, l = Ec(e), u = i || a ? [...l ? Cc(l) : [], ...t ? Cc(t) : []] : [];
	u.forEach((e) => {
		i && e.addEventListener("scroll", n), a && e.addEventListener("resize", n);
	});
	let d = l && s ? Nc(l, n, a) : null, f = -1, p = null;
	o && (p = new ResizeObserver((e) => {
		let [r] = e;
		r && r.target === l && p && t && (p.unobserve(t), cancelAnimationFrame(f), f = requestAnimationFrame(() => {
			var e;
			(e = p) == null || e.observe(t);
		})), n();
	}), l && !c && p.observe(l), t && p.observe(t));
	let m, h = c ? jc(e) : null;
	c && g();
	function g() {
		let t = jc(e);
		h && !Mc(h, t) && n(), h = t, m = requestAnimationFrame(g);
	}
	return n(), () => {
		var e;
		u.forEach((e) => {
			i && e.removeEventListener("scroll", n), a && e.removeEventListener("resize", n);
		}), d?.(), (e = p) == null || e.disconnect(), p = null, c && cancelAnimationFrame(m);
	};
}
//#endregion
//#region node_modules/use-isomorphic-layout-effect/dist/use-isomorphic-layout-effect.browser.esm.js
k();
var Fc = ge;
//#endregion
//#region node_modules/react-select/dist/index-641ee5b8.esm.js
k();
var Ic = [
	"className",
	"clearValue",
	"cx",
	"getStyles",
	"getClassNames",
	"getValue",
	"hasValue",
	"isMulti",
	"isRtl",
	"options",
	"selectOption",
	"selectProps",
	"setValue",
	"theme"
], Lc = function() {};
function Rc(e, t) {
	return t ? t[0] === "-" ? e + t : e + "__" + t : e;
}
function zc(e, t) {
	var n = [...arguments].slice(2), r = [].concat(n);
	if (t && e) for (var i in t) t.hasOwnProperty(i) && t[i] && r.push(`${Rc(e, i)}`);
	return r.filter(function(e) {
		return e;
	}).map(function(e) {
		return String(e).trim();
	}).join(" ");
}
var Bc = function(e) {
	return al(e) ? e.filter(Boolean) : Fa(e) === "object" && e !== null ? [e] : [];
}, Vc = function(e) {
	return e.className, e.clearValue, e.cx, e.getStyles, e.getClassNames, e.getValue, e.hasValue, e.isMulti, e.isRtl, e.options, e.selectOption, e.selectProps, e.setValue, e.theme, j({}, qa(e, Ic));
}, Hc = function(e, t, n) {
	var r = e.cx, i = e.getStyles, a = e.getClassNames, o = e.className;
	return {
		css: i(t, e),
		className: r(n ?? {}, a(t, e), o)
	};
};
function Uc(e) {
	return [
		document.documentElement,
		document.body,
		window
	].indexOf(e) > -1;
}
function Wc(e) {
	return Uc(e) ? window.innerHeight : e.clientHeight;
}
function Gc(e) {
	return Uc(e) ? window.pageYOffset : e.scrollTop;
}
function Kc(e, t) {
	Uc(e) ? window.scrollTo(0, t) : e.scrollTop = t;
}
function qc(e) {
	var t = getComputedStyle(e), n = t.position === "absolute", r = /(auto|scroll)/;
	if (t.position === "fixed") return document.documentElement;
	for (var i = e; i = i.parentElement;) if (t = getComputedStyle(i), !(n && t.position === "static") && r.test(t.overflow + t.overflowY + t.overflowX)) return i;
	return document.documentElement;
}
function Jc(e, t, n, r) {
	return n * ((e = e / r - 1) * e * e + 1) + t;
}
function Yc(e, t) {
	var n = arguments.length > 2 && arguments[2] !== void 0 ? arguments[2] : 200, r = arguments.length > 3 && arguments[3] !== void 0 ? arguments[3] : Lc, i = Gc(e), a = t - i, o = 10, s = 0;
	function c() {
		s += o, Kc(e, Jc(s, i, a, n)), s < n ? window.requestAnimationFrame(c) : r(e);
	}
	c();
}
function Xc(e, t) {
	var n = e.getBoundingClientRect(), r = t.getBoundingClientRect(), i = t.offsetHeight / 3;
	r.bottom + i > n.bottom ? Kc(e, Math.min(t.offsetTop + t.clientHeight - e.offsetHeight + i, e.scrollHeight)) : r.top - i < n.top && Kc(e, Math.max(t.offsetTop - i, 0));
}
function Zc(e) {
	var t = e.getBoundingClientRect();
	return {
		bottom: t.bottom,
		height: t.height,
		left: t.left,
		right: t.right,
		top: t.top,
		width: t.width
	};
}
function Qc() {
	try {
		return document.createEvent("TouchEvent"), !0;
	} catch {
		return !1;
	}
}
function $c() {
	try {
		return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
	} catch {
		return !1;
	}
}
var el = !1, tl = { get passive() {
	return el = !0;
} }, nl = typeof window < "u" ? window : {};
nl.addEventListener && nl.removeEventListener && (nl.addEventListener("p", Lc, tl), nl.removeEventListener("p", Lc, !1));
var rl = el;
function il(e) {
	return e != null;
}
function al(e) {
	return Array.isArray(e);
}
function ol(e, t, n) {
	return e ? t : n;
}
function sl(e) {
	return e;
}
function cl(e) {
	return e;
}
var ll = function(e) {
	var t = [...arguments].slice(1);
	return Object.entries(e).filter(function(e) {
		var n = Ga(e, 1)[0];
		return !t.includes(n);
	}).reduce(function(e, t) {
		var n = Ga(t, 2), r = n[0];
		return e[r] = n[1], e;
	}, {});
}, ul = ["children", "innerProps"], dl = ["children", "innerProps"];
function fl(e) {
	var t = e.maxHeight, n = e.menuEl, r = e.minHeight, i = e.placement, a = e.shouldScroll, o = e.isFixedPosition, s = e.controlHeight, c = qc(n), l = {
		placement: "bottom",
		maxHeight: t
	};
	if (!n || !n.offsetParent) return l;
	var u = c.getBoundingClientRect().height, d = n.getBoundingClientRect(), f = d.bottom, p = d.height, m = d.top, h = n.offsetParent.getBoundingClientRect().top, g = o ? window.innerHeight : Wc(c), _ = Gc(c), v = parseInt(getComputedStyle(n).marginBottom, 10), y = parseInt(getComputedStyle(n).marginTop, 10), b = h - y, x = g - m, S = b + _, C = u - _ - m, w = f - g + _ + v, ee = _ + m - y, T = 160;
	switch (i) {
		case "auto":
		case "bottom":
			if (x >= p) return {
				placement: "bottom",
				maxHeight: t
			};
			if (C >= p && !o) return a && Yc(c, w, T), {
				placement: "bottom",
				maxHeight: t
			};
			if (!o && C >= r || o && x >= r) return a && Yc(c, w, T), {
				placement: "bottom",
				maxHeight: o ? x - v : C - v
			};
			if (i === "auto" || o) {
				var te = t, ne = o ? b : S;
				return ne >= r && (te = Math.min(ne - v - s, t)), {
					placement: "top",
					maxHeight: te
				};
			}
			if (i === "bottom") return a && Kc(c, w), {
				placement: "bottom",
				maxHeight: t
			};
			break;
		case "top":
			if (b >= p) return {
				placement: "top",
				maxHeight: t
			};
			if (S >= p && !o) return a && Yc(c, ee, T), {
				placement: "top",
				maxHeight: t
			};
			if (!o && S >= r || o && b >= r) {
				var re = t;
				return (!o && S >= r || o && b >= r) && (re = o ? b - y : S - y), a && Yc(c, ee, T), {
					placement: "top",
					maxHeight: re
				};
			}
			return {
				placement: "bottom",
				maxHeight: t
			};
		default: throw Error(`Invalid placement provided "${i}".`);
	}
	return l;
}
function pl(e) {
	return e ? {
		bottom: "top",
		top: "bottom"
	}[e] : "bottom";
}
var ml = function(e) {
	return e === "auto" ? "bottom" : e;
}, hl = function(e, t) {
	var n, r = e.placement, i = e.theme, a = i.borderRadius, o = i.spacing, s = i.colors;
	return j((n = { label: "menu" }, Ra(n, pl(r), "100%"), Ra(n, "position", "absolute"), Ra(n, "width", "100%"), Ra(n, "zIndex", 1), n), t ? {} : {
		backgroundColor: s.neutral0,
		borderRadius: a,
		boxShadow: "0 0 0 1px hsla(0, 0%, 0%, 0.1), 0 4px 11px hsla(0, 0%, 0%, 0.1)",
		marginBottom: o.menuGutter,
		marginTop: o.menuGutter
	});
}, gl = /*#__PURE__*/ C(null), _l = function(e) {
	var t = e.children, n = e.minMenuHeight, r = e.maxMenuHeight, i = e.menuPlacement, a = e.menuPosition, o = e.menuShouldScrollIntoView, s = e.theme, c = (le(gl) || {}).setPortalPlacement, l = D(null), u = Ga(O(r), 2), d = u[0], f = u[1], p = Ga(O(null), 2), m = p[0], h = p[1], g = s.spacing.controlHeight;
	return Fc(function() {
		var e = l.current;
		if (e) {
			var t = a === "fixed", s = fl({
				maxHeight: r,
				menuEl: e,
				minHeight: n,
				placement: i,
				shouldScroll: o && !t,
				isFixedPosition: t,
				controlHeight: g
			});
			f(s.maxHeight), h(s.placement), c?.(s.placement);
		}
	}, [
		r,
		i,
		a,
		o,
		n,
		c,
		g
	]), t({
		ref: l,
		placerProps: j(j({}, e), {}, {
			placement: m || ml(i),
			maxHeight: d
		})
	});
}, vl = function(e) {
	var t = e.children, n = e.innerRef, r = e.innerProps;
	return F("div", M({}, Hc(e, "menu", { menu: !0 }), { ref: n }, r), t);
}, yl = function(e, t) {
	var n = e.maxHeight, r = e.theme.spacing.baseUnit;
	return j({
		maxHeight: n,
		overflowY: "auto",
		position: "relative",
		WebkitOverflowScrolling: "touch"
	}, t ? {} : {
		paddingBottom: r,
		paddingTop: r
	});
}, bl = function(e) {
	var t = e.children, n = e.innerProps, r = e.innerRef, i = e.isMulti;
	return F("div", M({}, Hc(e, "menuList", {
		"menu-list": !0,
		"menu-list--is-multi": i
	}), { ref: r }, n), t);
}, xl = function(e, t) {
	var n = e.theme, r = n.spacing.baseUnit, i = n.colors;
	return j({ textAlign: "center" }, t ? {} : {
		color: i.neutral40,
		padding: `${r * 2}px ${r * 3}px`
	});
}, Sl = xl, Cl = xl, wl = function(e) {
	var t = e.children, n = t === void 0 ? "No options" : t, r = e.innerProps, i = qa(e, ul);
	return F("div", M({}, Hc(j(j({}, i), {}, {
		children: n,
		innerProps: r
	}), "noOptionsMessage", {
		"menu-notice": !0,
		"menu-notice--no-options": !0
	}), r), n);
}, Tl = function(e) {
	var t = e.children, n = t === void 0 ? "Loading..." : t, r = e.innerProps, i = qa(e, dl);
	return F("div", M({}, Hc(j(j({}, i), {}, {
		children: n,
		innerProps: r
	}), "loadingMessage", {
		"menu-notice": !0,
		"menu-notice--loading": !0
	}), r), n);
}, El = function(e) {
	var t = e.rect, n = e.offset, r = e.position;
	return {
		left: t.left,
		position: r,
		top: n,
		width: t.width,
		zIndex: 1
	};
}, Dl = function(e) {
	var t = e.appendTo, n = e.children, r = e.controlElement, i = e.innerProps, a = e.menuPlacement, o = e.menuPosition, s = D(null), c = D(null), l = Ga(O(ml(a)), 2), u = l[0], d = l[1], f = _e(function() {
		return { setPortalPlacement: d };
	}, []), p = Ga(O(null), 2), m = p[0], h = p[1], g = ce(function() {
		if (r) {
			var e = Zc(r), t = o === "fixed" ? 0 : window.pageYOffset, n = e[u] + t;
			(n !== m?.offset || e.left !== m?.rect.left || e.width !== m?.rect.width) && h({
				offset: n,
				rect: e
			});
		}
	}, [
		r,
		o,
		u,
		m?.offset,
		m?.rect.left,
		m?.rect.width
	]);
	Fc(function() {
		g();
	}, [g]);
	var _ = ce(function() {
		typeof c.current == "function" && (c.current(), c.current = null), r && s.current && (c.current = Pc(r, s.current, g, { elementResize: "ResizeObserver" in window }));
	}, [r, g]);
	Fc(function() {
		_();
	}, [_]);
	var v = ce(function(e) {
		s.current = e, _();
	}, [_]);
	if (!t && o !== "fixed" || !m) return null;
	var y = F("div", M({ ref: v }, Hc(j(j({}, e), {}, {
		offset: m.offset,
		position: o,
		rect: m.rect
	}), "menuPortal", { "menu-portal": !0 }), i), n);
	return F(gl.Provider, { value: f }, t ? /*#__PURE__*/ (0, tc.createPortal)(y, t) : y);
}, Ol = function(e) {
	var t = e.isDisabled;
	return {
		label: "container",
		direction: e.isRtl ? "rtl" : void 0,
		pointerEvents: t ? "none" : void 0,
		position: "relative"
	};
}, kl = function(e) {
	var t = e.children, n = e.innerProps, r = e.isDisabled, i = e.isRtl;
	return F("div", M({}, Hc(e, "container", {
		"--is-disabled": r,
		"--is-rtl": i
	}), n), t);
}, Al = function(e, t) {
	var n = e.theme.spacing, r = e.isMulti, i = e.hasValue, a = e.selectProps.controlShouldRenderValue;
	return j({
		alignItems: "center",
		display: r && i && a ? "flex" : "grid",
		flex: 1,
		flexWrap: "wrap",
		WebkitOverflowScrolling: "touch",
		position: "relative",
		overflow: "hidden"
	}, t ? {} : { padding: `${n.baseUnit / 2}px ${n.baseUnit * 2}px` });
}, jl = function(e) {
	var t = e.children, n = e.innerProps, r = e.isMulti, i = e.hasValue;
	return F("div", M({}, Hc(e, "valueContainer", {
		"value-container": !0,
		"value-container--is-multi": r,
		"value-container--has-value": i
	}), n), t);
}, Ml = function() {
	return {
		alignItems: "center",
		alignSelf: "stretch",
		display: "flex",
		flexShrink: 0
	};
}, Nl = function(e) {
	var t = e.children, n = e.innerProps;
	return F("div", M({}, Hc(e, "indicatorsContainer", { indicators: !0 }), n), t);
}, Pl, Fl = ["size"], Il = [
	"innerProps",
	"isRtl",
	"size"
], Ll = {
	name: "8mmkcg",
	styles: "display:inline-block;fill:currentColor;line-height:1;stroke:currentColor;stroke-width:0"
}, Rl = function(e) {
	var t = e.size, n = qa(e, Fl);
	return F("svg", M({
		height: t,
		width: t,
		viewBox: "0 0 20 20",
		"aria-hidden": "true",
		focusable: "false",
		css: Ll
	}, n));
}, zl = function(e) {
	return F(Rl, M({ size: 20 }, e), F("path", { d: "M14.348 14.849c-0.469 0.469-1.229 0.469-1.697 0l-2.651-3.030-2.651 3.029c-0.469 0.469-1.229 0.469-1.697 0-0.469-0.469-0.469-1.229 0-1.697l2.758-3.15-2.759-3.152c-0.469-0.469-0.469-1.228 0-1.697s1.228-0.469 1.697 0l2.652 3.031 2.651-3.031c0.469-0.469 1.228-0.469 1.697 0s0.469 1.229 0 1.697l-2.758 3.152 2.758 3.15c0.469 0.469 0.469 1.229 0 1.698z" }));
}, Bl = function(e) {
	return F(Rl, M({ size: 20 }, e), F("path", { d: "M4.516 7.548c0.436-0.446 1.043-0.481 1.576 0l3.908 3.747 3.908-3.747c0.533-0.481 1.141-0.446 1.574 0 0.436 0.445 0.408 1.197 0 1.615-0.406 0.418-4.695 4.502-4.695 4.502-0.217 0.223-0.502 0.335-0.787 0.335s-0.57-0.112-0.789-0.335c0 0-4.287-4.084-4.695-4.502s-0.436-1.17 0-1.615z" }));
}, Vl = function(e, t) {
	var n = e.isFocused, r = e.theme, i = r.spacing.baseUnit, a = r.colors;
	return j({
		label: "indicatorContainer",
		display: "flex",
		transition: "color 150ms"
	}, t ? {} : {
		color: n ? a.neutral60 : a.neutral20,
		padding: i * 2,
		":hover": { color: n ? a.neutral80 : a.neutral40 }
	});
}, Hl = Vl, Ul = function(e) {
	var t = e.children, n = e.innerProps;
	return F("div", M({}, Hc(e, "dropdownIndicator", {
		indicator: !0,
		"dropdown-indicator": !0
	}), n), t || F(Bl, null));
}, Wl = Vl, Gl = function(e) {
	var t = e.children, n = e.innerProps;
	return F("div", M({}, Hc(e, "clearIndicator", {
		indicator: !0,
		"clear-indicator": !0
	}), n), t || F(zl, null));
}, Kl = function(e, t) {
	var n = e.isDisabled, r = e.theme, i = r.spacing.baseUnit, a = r.colors;
	return j({
		label: "indicatorSeparator",
		alignSelf: "stretch",
		width: 1
	}, t ? {} : {
		backgroundColor: n ? a.neutral10 : a.neutral20,
		marginBottom: i * 2,
		marginTop: i * 2
	});
}, ql = function(e) {
	var t = e.innerProps;
	return F("span", M({}, t, Hc(e, "indicatorSeparator", { "indicator-separator": !0 })));
}, Jl = Qs(Pl ||= $s(["\n  0%, 80%, 100% { opacity: 0; }\n  40% { opacity: 1; }\n"])), Yl = function(e, t) {
	var n = e.isFocused, r = e.size, i = e.theme, a = i.colors, o = i.spacing.baseUnit;
	return j({
		label: "loadingIndicator",
		display: "flex",
		transition: "color 150ms",
		alignSelf: "center",
		fontSize: r,
		lineHeight: 1,
		marginRight: r,
		textAlign: "center",
		verticalAlign: "middle"
	}, t ? {} : {
		color: n ? a.neutral60 : a.neutral20,
		padding: o * 2
	});
}, Xl = function(e) {
	var t = e.delay, n = e.offset;
	return F("span", { css: /*#__PURE__*/ Zs({
		animation: `${Jl} 1s ease-in-out ${t}ms infinite;`,
		backgroundColor: "currentColor",
		borderRadius: "1em",
		display: "inline-block",
		marginLeft: n ? "1em" : void 0,
		height: "1em",
		verticalAlign: "top",
		width: "1em"
	}, "", "") });
}, Zl = function(e) {
	var t = e.innerProps, n = e.isRtl, r = e.size, i = r === void 0 ? 4 : r, a = qa(e, Il);
	return F("div", M({}, Hc(j(j({}, a), {}, {
		innerProps: t,
		isRtl: n,
		size: i
	}), "loadingIndicator", {
		indicator: !0,
		"loading-indicator": !0
	}), t), F(Xl, {
		delay: 0,
		offset: n
	}), F(Xl, {
		delay: 160,
		offset: !0
	}), F(Xl, {
		delay: 320,
		offset: !n
	}));
}, Ql = function(e, t) {
	var n = e.isDisabled, r = e.isFocused, i = e.theme, a = i.colors, o = i.borderRadius, s = i.spacing;
	return j({
		label: "control",
		alignItems: "center",
		cursor: "default",
		display: "flex",
		flexWrap: "wrap",
		justifyContent: "space-between",
		minHeight: s.controlHeight,
		outline: "0 !important",
		position: "relative",
		transition: "all 100ms"
	}, t ? {} : {
		backgroundColor: n ? a.neutral5 : a.neutral0,
		borderColor: n ? a.neutral10 : r ? a.primary : a.neutral20,
		borderRadius: o,
		borderStyle: "solid",
		borderWidth: 1,
		boxShadow: r ? `0 0 0 1px ${a.primary}` : void 0,
		"&:hover": { borderColor: r ? a.primary : a.neutral30 }
	});
}, $l = function(e) {
	var t = e.children, n = e.isDisabled, r = e.isFocused, i = e.innerRef, a = e.innerProps, o = e.menuIsOpen;
	return F("div", M({ ref: i }, Hc(e, "control", {
		control: !0,
		"control--is-disabled": n,
		"control--is-focused": r,
		"control--menu-is-open": o
	}), a, { "aria-disabled": n || void 0 }), t);
}, eu = ["data"], tu = function(e, t) {
	var n = e.theme.spacing;
	return t ? {} : {
		paddingBottom: n.baseUnit * 2,
		paddingTop: n.baseUnit * 2
	};
}, nu = function(e) {
	var t = e.children, n = e.cx, r = e.getStyles, i = e.getClassNames, a = e.Heading, o = e.headingProps, s = e.innerProps, c = e.label, l = e.theme, u = e.selectProps;
	return F("div", M({}, Hc(e, "group", { group: !0 }), s), F(a, M({}, o, {
		selectProps: u,
		theme: l,
		getStyles: r,
		getClassNames: i,
		cx: n
	}), c), F("div", null, t));
}, ru = function(e, t) {
	var n = e.theme, r = n.colors, i = n.spacing;
	return j({
		label: "group",
		cursor: "default",
		display: "block"
	}, t ? {} : {
		color: r.neutral40,
		fontSize: "75%",
		fontWeight: 500,
		marginBottom: "0.25em",
		paddingLeft: i.baseUnit * 3,
		paddingRight: i.baseUnit * 3,
		textTransform: "uppercase"
	});
}, iu = function(e) {
	var t = Vc(e);
	t.data;
	var n = qa(t, eu);
	return F("div", M({}, Hc(e, "groupHeading", { "group-heading": !0 }), n));
}, au = nu, ou = [
	"innerRef",
	"isDisabled",
	"isHidden",
	"inputClassName"
], su = function(e, t) {
	var n = e.isDisabled, r = e.value, i = e.theme, a = i.spacing, o = i.colors;
	return j(j({
		visibility: n ? "hidden" : "visible",
		transform: r ? "translateZ(0)" : ""
	}, lu), t ? {} : {
		margin: a.baseUnit / 2,
		paddingBottom: a.baseUnit / 2,
		paddingTop: a.baseUnit / 2,
		color: o.neutral80
	});
}, cu = {
	gridArea: "1 / 2",
	font: "inherit",
	minWidth: "2px",
	border: 0,
	margin: 0,
	outline: 0,
	padding: 0
}, lu = {
	flex: "1 1 auto",
	display: "inline-grid",
	gridArea: "1 / 1 / 2 / 3",
	gridTemplateColumns: "0 min-content",
	"&:after": j({
		content: "attr(data-value) \" \"",
		visibility: "hidden",
		whiteSpace: "pre"
	}, cu)
}, uu = function(e) {
	return j({
		label: "input",
		color: "inherit",
		background: 0,
		opacity: +!e,
		width: "100%"
	}, cu);
}, du = function(e) {
	var t = e.cx, n = e.value, r = Vc(e), i = r.innerRef, a = r.isDisabled, o = r.isHidden, s = r.inputClassName, c = qa(r, ou);
	return F("div", M({}, Hc(e, "input", { "input-container": !0 }), { "data-value": n || "" }), F("input", M({
		className: t({ input: !0 }, s),
		ref: i,
		style: uu(o),
		disabled: a
	}, c)));
}, fu = function(e, t) {
	var n = e.theme, r = n.spacing, i = n.borderRadius, a = n.colors;
	return j({
		label: "multiValue",
		display: "flex",
		minWidth: 0
	}, t ? {} : {
		backgroundColor: a.neutral10,
		borderRadius: i / 2,
		margin: r.baseUnit / 2
	});
}, pu = function(e, t) {
	var n = e.theme, r = n.borderRadius, i = n.colors, a = e.cropWithEllipsis;
	return j({
		overflow: "hidden",
		textOverflow: a || a === void 0 ? "ellipsis" : void 0,
		whiteSpace: "nowrap"
	}, t ? {} : {
		borderRadius: r / 2,
		color: i.neutral80,
		fontSize: "85%",
		padding: 3,
		paddingLeft: 6
	});
}, mu = function(e, t) {
	var n = e.theme, r = n.spacing, i = n.borderRadius, a = n.colors, o = e.isFocused;
	return j({
		alignItems: "center",
		display: "flex"
	}, t ? {} : {
		borderRadius: i / 2,
		backgroundColor: o ? a.dangerLight : void 0,
		paddingLeft: r.baseUnit,
		paddingRight: r.baseUnit,
		":hover": {
			backgroundColor: a.dangerLight,
			color: a.danger
		}
	});
}, hu = function(e) {
	var t = e.children, n = e.innerProps;
	return F("div", n, t);
}, gu = hu, _u = hu;
function vu(e) {
	var t = e.children, n = e.innerProps;
	return F("div", M({ role: "button" }, n), t || F(zl, { size: 14 }));
}
var yu = function(e) {
	var t = e.children, n = e.components, r = e.data, i = e.innerProps, a = e.isDisabled, o = e.removeProps, s = e.selectProps, c = n.Container, l = n.Label, u = n.Remove;
	return F(c, {
		data: r,
		innerProps: j(j({}, Hc(e, "multiValue", {
			"multi-value": !0,
			"multi-value--is-disabled": a
		})), i),
		selectProps: s
	}, F(l, {
		data: r,
		innerProps: j({}, Hc(e, "multiValueLabel", { "multi-value__label": !0 })),
		selectProps: s
	}, t), F(u, {
		data: r,
		innerProps: j(j({}, Hc(e, "multiValueRemove", { "multi-value__remove": !0 })), {}, { "aria-label": `Remove ${t || "option"}` }, o),
		selectProps: s
	}));
}, bu = function(e, t) {
	var n = e.isDisabled, r = e.isFocused, i = e.isSelected, a = e.theme, o = a.spacing, s = a.colors;
	return j({
		label: "option",
		cursor: "default",
		display: "block",
		fontSize: "inherit",
		width: "100%",
		userSelect: "none",
		WebkitTapHighlightColor: "rgba(0, 0, 0, 0)"
	}, t ? {} : {
		backgroundColor: i ? s.primary : r ? s.primary25 : "transparent",
		color: n ? s.neutral20 : i ? s.neutral0 : "inherit",
		padding: `${o.baseUnit * 2}px ${o.baseUnit * 3}px`,
		":active": { backgroundColor: n ? void 0 : i ? s.primary : s.primary50 }
	});
}, xu = function(e) {
	var t = e.children, n = e.isDisabled, r = e.isFocused, i = e.isSelected, a = e.innerRef, o = e.innerProps;
	return F("div", M({}, Hc(e, "option", {
		option: !0,
		"option--is-disabled": n,
		"option--is-focused": r,
		"option--is-selected": i
	}), {
		ref: a,
		"aria-disabled": n
	}, o), t);
}, Su = function(e, t) {
	var n = e.theme, r = n.spacing, i = n.colors;
	return j({
		label: "placeholder",
		gridArea: "1 / 1 / 2 / 3"
	}, t ? {} : {
		color: i.neutral50,
		marginLeft: r.baseUnit / 2,
		marginRight: r.baseUnit / 2
	});
}, Cu = function(e) {
	var t = e.children, n = e.innerProps;
	return F("div", M({}, Hc(e, "placeholder", { placeholder: !0 }), n), t);
}, wu = function(e, t) {
	var n = e.isDisabled, r = e.theme, i = r.spacing, a = r.colors;
	return j({
		label: "singleValue",
		gridArea: "1 / 1 / 2 / 3",
		maxWidth: "100%",
		overflow: "hidden",
		textOverflow: "ellipsis",
		whiteSpace: "nowrap"
	}, t ? {} : {
		color: n ? a.neutral40 : a.neutral80,
		marginLeft: i.baseUnit / 2,
		marginRight: i.baseUnit / 2
	});
}, Tu = {
	ClearIndicator: Gl,
	Control: $l,
	DropdownIndicator: Ul,
	DownChevron: Bl,
	CrossIcon: zl,
	Group: au,
	GroupHeading: iu,
	IndicatorsContainer: Nl,
	IndicatorSeparator: ql,
	Input: du,
	LoadingIndicator: Zl,
	Menu: vl,
	MenuList: bl,
	MenuPortal: Dl,
	LoadingMessage: Tl,
	NoOptionsMessage: wl,
	MultiValue: yu,
	MultiValueContainer: gu,
	MultiValueLabel: _u,
	MultiValueRemove: vu,
	Option: xu,
	Placeholder: Cu,
	SelectContainer: kl,
	SingleValue: function(e) {
		var t = e.children, n = e.isDisabled, r = e.innerProps;
		return F("div", M({}, Hc(e, "singleValue", {
			"single-value": !0,
			"single-value--is-disabled": n
		}), r), t);
	},
	ValueContainer: jl
}, Eu = function(e) {
	return j(j({}, Tu), e.components);
}, Du = Number.isNaN || function(e) {
	return typeof e == "number" && e !== e;
};
function Ou(e, t) {
	return !!(e === t || Du(e) && Du(t));
}
function ku(e, t) {
	if (e.length !== t.length) return !1;
	for (var n = 0; n < e.length; n++) if (!Ou(e[n], t[n])) return !1;
	return !0;
}
function Au(e, t) {
	t === void 0 && (t = ku);
	var n = null;
	function r() {
		var r = [...arguments];
		if (n && n.lastThis === this && t(r, n.lastArgs)) return n.lastResult;
		var i = e.apply(this, r);
		return n = {
			lastResult: i,
			lastArgs: r,
			lastThis: this
		}, i;
	}
	return r.clear = function() {
		n = null;
	}, r;
}
//#endregion
//#region node_modules/react-select/dist/Select-ef7c0426.esm.js
k();
for (var ju = {
	name: "7pg0cj-a11yText",
	styles: "label:a11yText;z-index:9999;border:0;clip:rect(1px, 1px, 1px, 1px);height:1px;width:1px;position:absolute;overflow:hidden;padding:0;white-space:nowrap"
}, Mu = function(e) {
	return F("span", M({ css: ju }, e));
}, Nu = {
	guidance: function(e) {
		var t = e.isSearchable, n = e.isMulti, r = e.tabSelectsValue, i = e.context, a = e.isInitialFocus;
		switch (i) {
			case "menu": return `Use Up and Down to choose options, press Enter to select the currently focused option, press Escape to exit the menu${r ? ", press Tab to select the option and exit the menu" : ""}.`;
			case "input": return a ? `${e["aria-label"] || "Select"} is focused ${t ? ",type to refine list" : ""}, press Down to open the menu, ${n ? " press left to focus selected values" : ""}` : "";
			case "value": return "Use left and right to toggle between focused values, press Backspace to remove the currently focused value";
			default: return "";
		}
	},
	onChange: function(e) {
		var t = e.action, n = e.label, r = n === void 0 ? "" : n, i = e.labels, a = e.isDisabled;
		switch (t) {
			case "deselect-option":
			case "pop-value":
			case "remove-value": return `option ${r}, deselected.`;
			case "clear": return "All selected options have been cleared.";
			case "initial-input-focus": return `option${i.length > 1 ? "s" : ""} ${i.join(",")}, selected.`;
			case "select-option": return a ? `option ${r} is disabled. Select another option.` : `option ${r}, selected.`;
			default: return "";
		}
	},
	onFocus: function(e) {
		var t = e.context, n = e.focused, r = e.options, i = e.label, a = i === void 0 ? "" : i, o = e.selectValue, s = e.isDisabled, c = e.isSelected, l = e.isAppleDevice, u = function(e, t) {
			return e && e.length ? `${e.indexOf(t) + 1} of ${e.length}` : "";
		};
		return t === "value" && o ? `value ${a} focused, ${u(o, n)}.` : t === "menu" && l ? `${a}${`${c ? " selected" : ""}${s ? " disabled" : ""}`}, ${u(r, n)}.` : "";
	},
	onFilter: function(e) {
		var t = e.inputValue;
		return `${e.resultsMessage}${t ? " for search term " + t : ""}.`;
	}
}, Pu = function(e) {
	var t = e.ariaSelection, n = e.focusedOption, r = e.focusedValue, i = e.focusableOptions, a = e.isFocused, o = e.selectValue, s = e.selectProps, c = e.id, u = e.isAppleDevice, d = s.ariaLiveMessages, f = s.getOptionLabel, p = s.inputValue, m = s.isMulti, h = s.isOptionDisabled, g = s.isSearchable, _ = s.menuIsOpen, v = s.options, y = s.screenReaderStatus, b = s.tabSelectsValue, x = s.isLoading, S = s["aria-label"], C = s["aria-live"], w = _e(function() {
		return j(j({}, Nu), d || {});
	}, [d]), ee = _e(function() {
		var e = "";
		if (t && w.onChange) {
			var n = t.option, r = t.options, i = t.removedValue, a = t.removedValues, s = t.value, c = i || n || function(e) {
				return Array.isArray(e) ? null : e;
			}(s), l = c ? f(c) : "", u = r || a || void 0, d = u ? u.map(f) : [], p = j({
				isDisabled: c && h(c, o),
				label: l,
				labels: d
			}, t);
			e = w.onChange(p);
		}
		return e;
	}, [
		t,
		w,
		h,
		o,
		f
	]), T = _e(function() {
		var e = "", t = n || r, a = !!(n && o && o.includes(n));
		if (t && w.onFocus) {
			var s = {
				focused: t,
				label: f(t),
				isDisabled: h(t, o),
				isSelected: a,
				options: i,
				context: t === n ? "menu" : "value",
				selectValue: o,
				isAppleDevice: u
			};
			e = w.onFocus(s);
		}
		return e;
	}, [
		n,
		r,
		f,
		h,
		w,
		i,
		o,
		u
	]), te = _e(function() {
		var e = "";
		if (_ && v.length && !x && w.onFilter) {
			var t = y({ count: i.length });
			e = w.onFilter({
				inputValue: p,
				resultsMessage: t
			});
		}
		return e;
	}, [
		i,
		p,
		_,
		w,
		v,
		y,
		x
	]), ne = t?.action === "initial-input-focus", re = _e(function() {
		var e = "";
		if (w.guidance) {
			var t = r ? "value" : _ ? "menu" : "input";
			e = w.guidance({
				"aria-label": S,
				context: t,
				isDisabled: n && h(n, o),
				isMulti: m,
				isSearchable: g,
				tabSelectsValue: b,
				isInitialFocus: ne
			});
		}
		return e;
	}, [
		S,
		n,
		r,
		m,
		h,
		g,
		_,
		w,
		o,
		b,
		ne
	]), ie = F(l, null, F("span", { id: "aria-selection" }, ee), F("span", { id: "aria-focused" }, T), F("span", { id: "aria-results" }, te), F("span", { id: "aria-guidance" }, re));
	return F(l, null, F(Mu, { id: c }, ne && ie), F(Mu, {
		"aria-live": C,
		"aria-atomic": "false",
		"aria-relevant": "additions text",
		role: "log"
	}, a && !ne && ie));
}, Fu = [
	{
		base: "A",
		letters: "AⒶＡÀÁÂẦẤẪẨÃĀĂẰẮẴẲȦǠÄǞẢÅǺǍȀȂẠẬẶḀĄȺⱯ"
	},
	{
		base: "AA",
		letters: "Ꜳ"
	},
	{
		base: "AE",
		letters: "ÆǼǢ"
	},
	{
		base: "AO",
		letters: "Ꜵ"
	},
	{
		base: "AU",
		letters: "Ꜷ"
	},
	{
		base: "AV",
		letters: "ꜸꜺ"
	},
	{
		base: "AY",
		letters: "Ꜽ"
	},
	{
		base: "B",
		letters: "BⒷＢḂḄḆɃƂƁ"
	},
	{
		base: "C",
		letters: "CⒸＣĆĈĊČÇḈƇȻꜾ"
	},
	{
		base: "D",
		letters: "DⒹＤḊĎḌḐḒḎĐƋƊƉꝹ"
	},
	{
		base: "DZ",
		letters: "ǱǄ"
	},
	{
		base: "Dz",
		letters: "ǲǅ"
	},
	{
		base: "E",
		letters: "EⒺＥÈÉÊỀẾỄỂẼĒḔḖĔĖËẺĚȄȆẸỆȨḜĘḘḚƐƎ"
	},
	{
		base: "F",
		letters: "FⒻＦḞƑꝻ"
	},
	{
		base: "G",
		letters: "GⒼＧǴĜḠĞĠǦĢǤƓꞠꝽꝾ"
	},
	{
		base: "H",
		letters: "HⒽＨĤḢḦȞḤḨḪĦⱧⱵꞍ"
	},
	{
		base: "I",
		letters: "IⒾＩÌÍÎĨĪĬİÏḮỈǏȈȊỊĮḬƗ"
	},
	{
		base: "J",
		letters: "JⒿＪĴɈ"
	},
	{
		base: "K",
		letters: "KⓀＫḰǨḲĶḴƘⱩꝀꝂꝄꞢ"
	},
	{
		base: "L",
		letters: "LⓁＬĿĹĽḶḸĻḼḺŁȽⱢⱠꝈꝆꞀ"
	},
	{
		base: "LJ",
		letters: "Ǉ"
	},
	{
		base: "Lj",
		letters: "ǈ"
	},
	{
		base: "M",
		letters: "MⓂＭḾṀṂⱮƜ"
	},
	{
		base: "N",
		letters: "NⓃＮǸŃÑṄŇṆŅṊṈȠƝꞐꞤ"
	},
	{
		base: "NJ",
		letters: "Ǌ"
	},
	{
		base: "Nj",
		letters: "ǋ"
	},
	{
		base: "O",
		letters: "OⓄＯÒÓÔỒỐỖỔÕṌȬṎŌṐṒŎȮȰÖȪỎŐǑȌȎƠỜỚỠỞỢỌỘǪǬØǾƆƟꝊꝌ"
	},
	{
		base: "OI",
		letters: "Ƣ"
	},
	{
		base: "OO",
		letters: "Ꝏ"
	},
	{
		base: "OU",
		letters: "Ȣ"
	},
	{
		base: "P",
		letters: "PⓅＰṔṖƤⱣꝐꝒꝔ"
	},
	{
		base: "Q",
		letters: "QⓆＱꝖꝘɊ"
	},
	{
		base: "R",
		letters: "RⓇＲŔṘŘȐȒṚṜŖṞɌⱤꝚꞦꞂ"
	},
	{
		base: "S",
		letters: "SⓈＳẞŚṤŜṠŠṦṢṨȘŞⱾꞨꞄ"
	},
	{
		base: "T",
		letters: "TⓉＴṪŤṬȚŢṰṮŦƬƮȾꞆ"
	},
	{
		base: "TZ",
		letters: "Ꜩ"
	},
	{
		base: "U",
		letters: "UⓊＵÙÚÛŨṸŪṺŬÜǛǗǕǙỦŮŰǓȔȖƯỪỨỮỬỰỤṲŲṶṴɄ"
	},
	{
		base: "V",
		letters: "VⓋＶṼṾƲꝞɅ"
	},
	{
		base: "VY",
		letters: "Ꝡ"
	},
	{
		base: "W",
		letters: "WⓌＷẀẂŴẆẄẈⱲ"
	},
	{
		base: "X",
		letters: "XⓍＸẊẌ"
	},
	{
		base: "Y",
		letters: "YⓎＹỲÝŶỸȲẎŸỶỴƳɎỾ"
	},
	{
		base: "Z",
		letters: "ZⓏＺŹẐŻŽẒẔƵȤⱿⱫꝢ"
	},
	{
		base: "a",
		letters: "aⓐａẚàáâầấẫẩãāăằắẵẳȧǡäǟảåǻǎȁȃạậặḁąⱥɐ"
	},
	{
		base: "aa",
		letters: "ꜳ"
	},
	{
		base: "ae",
		letters: "æǽǣ"
	},
	{
		base: "ao",
		letters: "ꜵ"
	},
	{
		base: "au",
		letters: "ꜷ"
	},
	{
		base: "av",
		letters: "ꜹꜻ"
	},
	{
		base: "ay",
		letters: "ꜽ"
	},
	{
		base: "b",
		letters: "bⓑｂḃḅḇƀƃɓ"
	},
	{
		base: "c",
		letters: "cⓒｃćĉċčçḉƈȼꜿↄ"
	},
	{
		base: "d",
		letters: "dⓓｄḋďḍḑḓḏđƌɖɗꝺ"
	},
	{
		base: "dz",
		letters: "ǳǆ"
	},
	{
		base: "e",
		letters: "eⓔｅèéêềếễểẽēḕḗĕėëẻěȅȇẹệȩḝęḙḛɇɛǝ"
	},
	{
		base: "f",
		letters: "fⓕｆḟƒꝼ"
	},
	{
		base: "g",
		letters: "gⓖｇǵĝḡğġǧģǥɠꞡᵹꝿ"
	},
	{
		base: "h",
		letters: "hⓗｈĥḣḧȟḥḩḫẖħⱨⱶɥ"
	},
	{
		base: "hv",
		letters: "ƕ"
	},
	{
		base: "i",
		letters: "iⓘｉìíîĩīĭïḯỉǐȉȋịįḭɨı"
	},
	{
		base: "j",
		letters: "jⓙｊĵǰɉ"
	},
	{
		base: "k",
		letters: "kⓚｋḱǩḳķḵƙⱪꝁꝃꝅꞣ"
	},
	{
		base: "l",
		letters: "lⓛｌŀĺľḷḹļḽḻſłƚɫⱡꝉꞁꝇ"
	},
	{
		base: "lj",
		letters: "ǉ"
	},
	{
		base: "m",
		letters: "mⓜｍḿṁṃɱɯ"
	},
	{
		base: "n",
		letters: "nⓝｎǹńñṅňṇņṋṉƞɲŉꞑꞥ"
	},
	{
		base: "nj",
		letters: "ǌ"
	},
	{
		base: "o",
		letters: "oⓞｏòóôồốỗổõṍȭṏōṑṓŏȯȱöȫỏőǒȍȏơờớỡởợọộǫǭøǿɔꝋꝍɵ"
	},
	{
		base: "oi",
		letters: "ƣ"
	},
	{
		base: "ou",
		letters: "ȣ"
	},
	{
		base: "oo",
		letters: "ꝏ"
	},
	{
		base: "p",
		letters: "pⓟｐṕṗƥᵽꝑꝓꝕ"
	},
	{
		base: "q",
		letters: "qⓠｑɋꝗꝙ"
	},
	{
		base: "r",
		letters: "rⓡｒŕṙřȑȓṛṝŗṟɍɽꝛꞧꞃ"
	},
	{
		base: "s",
		letters: "sⓢｓßśṥŝṡšṧṣṩșşȿꞩꞅẛ"
	},
	{
		base: "t",
		letters: "tⓣｔṫẗťṭțţṱṯŧƭʈⱦꞇ"
	},
	{
		base: "tz",
		letters: "ꜩ"
	},
	{
		base: "u",
		letters: "uⓤｕùúûũṹūṻŭüǜǘǖǚủůűǔȕȗưừứữửựụṳųṷṵʉ"
	},
	{
		base: "v",
		letters: "vⓥｖṽṿʋꝟʌ"
	},
	{
		base: "vy",
		letters: "ꝡ"
	},
	{
		base: "w",
		letters: "wⓦｗẁẃŵẇẅẘẉⱳ"
	},
	{
		base: "x",
		letters: "xⓧｘẋẍ"
	},
	{
		base: "y",
		letters: "yⓨｙỳýŷỹȳẏÿỷẙỵƴɏỿ"
	},
	{
		base: "z",
		letters: "zⓩｚźẑżžẓẕƶȥɀⱬꝣ"
	}
], Iu = RegExp("[" + Fu.map(function(e) {
	return e.letters;
}).join("") + "]", "g"), Lu = {}, Ru = 0; Ru < Fu.length; Ru++) for (var zu = Fu[Ru], Bu = 0; Bu < zu.letters.length; Bu++) Lu[zu.letters[Bu]] = zu.base;
var Vu = function(e) {
	return e.replace(Iu, function(e) {
		return Lu[e];
	});
}, Hu = Au(Vu), Uu = function(e) {
	return e.replace(/^\s+|\s+$/g, "");
}, Wu = function(e) {
	return `${e.label} ${e.value}`;
}, Gu = function(e) {
	return function(t, n) {
		if (t.data.__isNew__) return !0;
		var r = j({
			ignoreCase: !0,
			ignoreAccents: !0,
			stringify: Wu,
			trim: !0,
			matchFrom: "any"
		}, e), i = r.ignoreCase, a = r.ignoreAccents, o = r.stringify, s = r.trim, c = r.matchFrom, l = s ? Uu(n) : n, u = s ? Uu(o(t)) : o(t);
		return i && (l = l.toLowerCase(), u = u.toLowerCase()), a && (l = Hu(l), u = Vu(u)), c === "start" ? u.substr(0, l.length) === l : u.indexOf(l) > -1;
	};
}, Ku = ["innerRef"];
function qu(e) {
	var t = e.innerRef, n = ll(qa(e, Ku), "onExited", "in", "enter", "exit", "appear");
	return F("input", M({ ref: t }, n, { css: /*#__PURE__*/ Zs({
		label: "dummyInput",
		background: 0,
		border: 0,
		caretColor: "transparent",
		fontSize: "inherit",
		gridArea: "1 / 1 / 2 / 3",
		outline: 0,
		padding: 0,
		width: 1,
		color: "transparent",
		left: -100,
		opacity: 0,
		position: "relative",
		transform: "scale(.01)"
	}, "", "") }));
}
var Ju = function(e) {
	e.cancelable && e.preventDefault(), e.stopPropagation();
};
function Yu(e) {
	var t = e.isEnabled, n = e.onBottomArrive, r = e.onBottomLeave, i = e.onTopArrive, a = e.onTopLeave, o = D(!1), s = D(!1), c = D(0), l = D(null), u = ce(function(e, t) {
		if (l.current !== null) {
			var c = l.current, u = c.scrollTop, d = c.scrollHeight, f = c.clientHeight, p = l.current, m = t > 0, h = d - f - u, g = !1;
			h > t && o.current && (r && r(e), o.current = !1), m && s.current && (a && a(e), s.current = !1), m && t > h ? (n && !o.current && n(e), p.scrollTop = d, g = !0, o.current = !0) : !m && -t > u && (i && !s.current && i(e), p.scrollTop = 0, g = !0, s.current = !0), g && Ju(e);
		}
	}, [
		n,
		r,
		i,
		a
	]), d = ce(function(e) {
		u(e, e.deltaY);
	}, [u]), f = ce(function(e) {
		c.current = e.changedTouches[0].clientY;
	}, []), p = ce(function(e) {
		u(e, c.current - e.changedTouches[0].clientY);
	}, [u]), m = ce(function(e) {
		if (e) {
			var t = rl ? { passive: !1 } : !1;
			e.addEventListener("wheel", d, t), e.addEventListener("touchstart", f, t), e.addEventListener("touchmove", p, t);
		}
	}, [
		p,
		f,
		d
	]), h = ce(function(e) {
		e && (e.removeEventListener("wheel", d, !1), e.removeEventListener("touchstart", f, !1), e.removeEventListener("touchmove", p, !1));
	}, [
		p,
		f,
		d
	]);
	return E(function() {
		if (t) {
			var e = l.current;
			return m(e), function() {
				h(e);
			};
		}
	}, [
		t,
		m,
		h
	]), function(e) {
		l.current = e;
	};
}
var Xu = [
	"boxSizing",
	"height",
	"overflow",
	"paddingRight",
	"position"
], Zu = {
	boxSizing: "border-box",
	overflow: "hidden",
	position: "relative",
	height: "100%"
};
function Qu(e) {
	e.cancelable && e.preventDefault();
}
function $u(e) {
	e.stopPropagation();
}
function ed() {
	var e = this.scrollTop, t = this.scrollHeight, n = e + this.offsetHeight;
	e === 0 ? this.scrollTop = 1 : n === t && (this.scrollTop = e - 1);
}
function td() {
	return "ontouchstart" in window || navigator.maxTouchPoints;
}
var nd = !!(typeof window < "u" && window.document && window.document.createElement), rd = 0, id = {
	capture: !1,
	passive: !1
};
function ad(e) {
	var t = e.isEnabled, n = e.accountForScrollbars, r = n === void 0 || n, i = D({}), a = D(null), o = ce(function(e) {
		if (nd) {
			var t = document.body, n = t && t.style;
			if (r && Xu.forEach(function(e) {
				var t = n && n[e];
				i.current[e] = t;
			}), r && rd < 1) {
				var a = parseInt(i.current.paddingRight, 10) || 0, o = document.body ? document.body.clientWidth : 0, s = window.innerWidth - o + a || 0;
				Object.keys(Zu).forEach(function(e) {
					var t = Zu[e];
					n && (n[e] = t);
				}), n && (n.paddingRight = `${s}px`);
			}
			t && td() && (t.addEventListener("touchmove", Qu, id), e && (e.addEventListener("touchstart", ed, id), e.addEventListener("touchmove", $u, id))), rd += 1;
		}
	}, [r]), s = ce(function(e) {
		if (nd) {
			var t = document.body, n = t && t.style;
			rd = Math.max(rd - 1, 0), r && rd < 1 && Xu.forEach(function(e) {
				var t = i.current[e];
				n && (n[e] = t);
			}), t && td() && (t.removeEventListener("touchmove", Qu, id), e && (e.removeEventListener("touchstart", ed, id), e.removeEventListener("touchmove", $u, id)));
		}
	}, [r]);
	return E(function() {
		if (t) {
			var e = a.current;
			return o(e), function() {
				s(e);
			};
		}
	}, [
		t,
		o,
		s
	]), function(e) {
		a.current = e;
	};
}
var od = function(e) {
	var t = e.target;
	return t.ownerDocument.activeElement && t.ownerDocument.activeElement.blur();
}, sd = {
	name: "1kfdb0e",
	styles: "position:fixed;left:0;bottom:0;right:0;top:0"
};
function cd(e) {
	var t = e.children, n = e.lockEnabled, r = e.captureEnabled, i = r === void 0 || r, a = e.onBottomArrive, o = e.onBottomLeave, s = e.onTopArrive, c = e.onTopLeave, u = Yu({
		isEnabled: i,
		onBottomArrive: a,
		onBottomLeave: o,
		onTopArrive: s,
		onTopLeave: c
	}), d = ad({ isEnabled: n });
	return F(l, null, n && F("div", {
		onClick: od,
		css: sd
	}), t(function(e) {
		u(e), d(e);
	}));
}
var ld = {
	name: "1a0ro4n-requiredInput",
	styles: "label:requiredInput;opacity:0;pointer-events:none;position:absolute;bottom:0;left:0;right:0;width:100%"
}, ud = function(e) {
	var t = e.name, n = e.onFocus;
	return F("input", {
		required: !0,
		name: t,
		tabIndex: -1,
		"aria-hidden": "true",
		onFocus: n,
		css: ld,
		value: "",
		onChange: function() {}
	});
};
function dd(e) {
	return typeof window < "u" && window.navigator != null && e.test(window.navigator.userAgentData?.platform || window.navigator.platform);
}
function fd() {
	return dd(/^iPhone/i);
}
function pd() {
	return dd(/^Mac/i);
}
function md() {
	return dd(/^iPad/i) || pd() && navigator.maxTouchPoints > 1;
}
function hd() {
	return fd() || md();
}
function gd() {
	return pd() || hd();
}
var _d = function(e) {
	return e.label;
}, vd = function(e) {
	return e.label;
}, yd = function(e) {
	return e.value;
}, bd = function(e) {
	return !!e.isDisabled;
}, xd = {
	clearIndicator: Wl,
	container: Ol,
	control: Ql,
	dropdownIndicator: Hl,
	group: tu,
	groupHeading: ru,
	indicatorsContainer: Ml,
	indicatorSeparator: Kl,
	input: su,
	loadingIndicator: Yl,
	loadingMessage: Cl,
	menu: hl,
	menuList: yl,
	menuPortal: El,
	multiValue: fu,
	multiValueLabel: pu,
	multiValueRemove: mu,
	noOptionsMessage: Sl,
	option: bu,
	placeholder: Su,
	singleValue: wu,
	valueContainer: Al
}, Sd = {
	primary: "#2684FF",
	primary75: "#4C9AFF",
	primary50: "#B2D4FF",
	primary25: "#DEEBFF",
	danger: "#DE350B",
	dangerLight: "#FFBDAD",
	neutral0: "hsl(0, 0%, 100%)",
	neutral5: "hsl(0, 0%, 95%)",
	neutral10: "hsl(0, 0%, 90%)",
	neutral20: "hsl(0, 0%, 80%)",
	neutral30: "hsl(0, 0%, 70%)",
	neutral40: "hsl(0, 0%, 60%)",
	neutral50: "hsl(0, 0%, 50%)",
	neutral60: "hsl(0, 0%, 40%)",
	neutral70: "hsl(0, 0%, 30%)",
	neutral80: "hsl(0, 0%, 20%)",
	neutral90: "hsl(0, 0%, 10%)"
}, Cd = 4, wd = 4, Td = {
	borderRadius: Cd,
	colors: Sd,
	spacing: {
		baseUnit: wd,
		controlHeight: 38,
		menuGutter: wd * 2
	}
}, Ed = {
	"aria-live": "polite",
	backspaceRemovesValue: !0,
	blurInputOnSelect: Qc(),
	captureMenuScroll: !Qc(),
	classNames: {},
	closeMenuOnSelect: !0,
	closeMenuOnScroll: !1,
	components: {},
	controlShouldRenderValue: !0,
	escapeClearsValue: !1,
	filterOption: Gu(),
	formatGroupLabel: _d,
	getOptionLabel: vd,
	getOptionValue: yd,
	isDisabled: !1,
	isLoading: !1,
	isMulti: !1,
	isRtl: !1,
	isSearchable: !0,
	isOptionDisabled: bd,
	loadingMessage: function() {
		return "Loading...";
	},
	maxMenuHeight: 300,
	minMenuHeight: 140,
	menuIsOpen: !1,
	menuPlacement: "bottom",
	menuPosition: "absolute",
	menuShouldBlockScroll: !1,
	menuShouldScrollIntoView: !$c(),
	noOptionsMessage: function() {
		return "No options";
	},
	openMenuOnFocus: !1,
	openMenuOnClick: !0,
	options: [],
	pageSize: 5,
	placeholder: "Select...",
	screenReaderStatus: function(e) {
		var t = e.count;
		return `${t} result${t === 1 ? "" : "s"} available`;
	},
	styles: {},
	tabIndex: 0,
	tabSelectsValue: !0,
	unstyled: !1
};
function Dd(e, t, n, r) {
	return {
		type: "option",
		data: t,
		isDisabled: Rd(e, t, n),
		isSelected: zd(e, t, n),
		label: Id(e, t),
		value: Ld(e, t),
		index: r
	};
}
function Od(e, t) {
	return e.options.map(function(n, r) {
		if ("options" in n) {
			var i = n.options.map(function(n, r) {
				return Dd(e, n, t, r);
			}).filter(function(t) {
				return Md(e, t);
			});
			return i.length > 0 ? {
				type: "group",
				data: n,
				options: i,
				index: r
			} : void 0;
		}
		var a = Dd(e, n, t, r);
		return Md(e, a) ? a : void 0;
	}).filter(il);
}
function kd(e) {
	return e.reduce(function(e, t) {
		return t.type === "group" ? e.push.apply(e, lo(t.options.map(function(e) {
			return e.data;
		}))) : e.push(t.data), e;
	}, []);
}
function Ad(e, t) {
	return e.reduce(function(e, n) {
		return n.type === "group" ? e.push.apply(e, lo(n.options.map(function(e) {
			return {
				data: e.data,
				id: `${t}-${n.index}-${e.index}`
			};
		}))) : e.push({
			data: n.data,
			id: `${t}-${n.index}`
		}), e;
	}, []);
}
function jd(e, t) {
	return kd(Od(e, t));
}
function Md(e, t) {
	var n = e.inputValue, r = n === void 0 ? "" : n, i = t.data, a = t.isSelected, o = t.label, s = t.value;
	return (!Vd(e) || !a) && Bd(e, {
		label: o,
		value: s,
		data: i
	}, r);
}
function Nd(e, t) {
	var n = e.focusedValue, r = e.selectValue.indexOf(n);
	if (r > -1) {
		if (t.indexOf(n) > -1) return n;
		if (r < t.length) return t[r];
	}
	return null;
}
function Pd(e, t) {
	var n = e.focusedOption;
	return n && t.indexOf(n) > -1 ? n : t[0];
}
var Fd = function(e, t) {
	return e.find(function(e) {
		return e.data === t;
	})?.id || null;
}, Id = function(e, t) {
	return e.getOptionLabel(t);
}, Ld = function(e, t) {
	return e.getOptionValue(t);
};
function Rd(e, t, n) {
	return typeof e.isOptionDisabled == "function" && e.isOptionDisabled(t, n);
}
function zd(e, t, n) {
	if (n.indexOf(t) > -1) return !0;
	if (typeof e.isOptionSelected == "function") return e.isOptionSelected(t, n);
	var r = Ld(e, t);
	return n.some(function(t) {
		return Ld(e, t) === r;
	});
}
function Bd(e, t, n) {
	return !e.filterOption || e.filterOption(t, n);
}
var Vd = function(e) {
	var t = e.hideSelectedOptions, n = e.isMulti;
	return t === void 0 ? n : t;
}, Hd = 1, Ud = /*#__PURE__*/ function(e) {
	eo(n, e);
	var t = ao(n);
	function n(e) {
		var r;
		if (Xa(this, n), r = t.call(this, e), r.state = {
			ariaSelection: null,
			focusedOption: null,
			focusedOptionId: null,
			focusableOptionsWithIds: [],
			focusedValue: null,
			inputIsHidden: !1,
			isFocused: !1,
			selectValue: [],
			clearFocusValueOnUpdate: !1,
			prevWasFocused: !1,
			inputIsHiddenAfterUpdate: void 0,
			prevProps: void 0,
			instancePrefix: "",
			isAppleDevice: !1
		}, r.blockOptionHover = !1, r.isComposing = !1, r.commonProps = void 0, r.initialTouchX = 0, r.initialTouchY = 0, r.openAfterFocus = !1, r.scrollToFocusedOptionOnUpdate = !1, r.userIsDragging = void 0, r.controlRef = null, r.getControlRef = function(e) {
			r.controlRef = e;
		}, r.focusedOptionRef = null, r.getFocusedOptionRef = function(e) {
			r.focusedOptionRef = e;
		}, r.menuListRef = null, r.getMenuListRef = function(e) {
			r.menuListRef = e;
		}, r.inputRef = null, r.getInputRef = function(e) {
			r.inputRef = e;
		}, r.focus = r.focusInput, r.blur = r.blurInput, r.onChange = function(e, t) {
			var n = r.props, i = n.onChange;
			t.name = n.name, r.ariaOnChange(e, t), i(e, t);
		}, r.setValue = function(e, t, n) {
			var i = r.props, a = i.closeMenuOnSelect, o = i.isMulti, s = i.inputValue;
			r.onInputChange("", {
				action: "set-value",
				prevInputValue: s
			}), a && (r.setState({ inputIsHiddenAfterUpdate: !o }), r.onMenuClose()), r.setState({ clearFocusValueOnUpdate: !0 }), r.onChange(e, {
				action: t,
				option: n
			});
		}, r.selectOption = function(e) {
			var t = r.props, n = t.blurInputOnSelect, i = t.isMulti, a = t.name, o = r.state.selectValue, s = i && r.isOptionSelected(e, o), c = r.isOptionDisabled(e, o);
			if (s) {
				var l = r.getOptionValue(e);
				r.setValue(cl(o.filter(function(e) {
					return r.getOptionValue(e) !== l;
				})), "deselect-option", e);
			} else if (!c) i ? r.setValue(cl([].concat(lo(o), [e])), "select-option", e) : r.setValue(sl(e), "select-option");
			else {
				r.ariaOnChange(sl(e), {
					action: "select-option",
					option: e,
					name: a
				});
				return;
			}
			n && r.blurInput();
		}, r.removeValue = function(e) {
			var t = r.props.isMulti, n = r.state.selectValue, i = r.getOptionValue(e), a = n.filter(function(e) {
				return r.getOptionValue(e) !== i;
			}), o = ol(t, a, a[0] || null);
			r.onChange(o, {
				action: "remove-value",
				removedValue: e
			}), r.focusInput();
		}, r.clearValue = function() {
			var e = r.state.selectValue;
			r.onChange(ol(r.props.isMulti, [], null), {
				action: "clear",
				removedValues: e
			});
		}, r.popValue = function() {
			var e = r.props.isMulti, t = r.state.selectValue, n = t[t.length - 1], i = t.slice(0, t.length - 1), a = ol(e, i, i[0] || null);
			n && r.onChange(a, {
				action: "pop-value",
				removedValue: n
			});
		}, r.getFocusedOptionId = function(e) {
			return Fd(r.state.focusableOptionsWithIds, e);
		}, r.getFocusableOptionsWithIds = function() {
			return Ad(Od(r.props, r.state.selectValue), r.getElementId("option"));
		}, r.getValue = function() {
			return r.state.selectValue;
		}, r.cx = function() {
			var e = [...arguments];
			return zc.apply(void 0, [r.props.classNamePrefix].concat(e));
		}, r.getOptionLabel = function(e) {
			return Id(r.props, e);
		}, r.getOptionValue = function(e) {
			return Ld(r.props, e);
		}, r.getStyles = function(e, t) {
			var n = r.props.unstyled, i = xd[e](t, n);
			i.boxSizing = "border-box";
			var a = r.props.styles[e];
			return a ? a(i, t) : i;
		}, r.getClassNames = function(e, t) {
			var n;
			return (n = r.props.classNames)[e]?.call(n, t);
		}, r.getElementId = function(e) {
			return `${r.state.instancePrefix}-${e}`;
		}, r.getComponents = function() {
			return Eu(r.props);
		}, r.buildCategorizedOptions = function() {
			return Od(r.props, r.state.selectValue);
		}, r.getCategorizedOptions = function() {
			return r.props.menuIsOpen ? r.buildCategorizedOptions() : [];
		}, r.buildFocusableOptions = function() {
			return kd(r.buildCategorizedOptions());
		}, r.getFocusableOptions = function() {
			return r.props.menuIsOpen ? r.buildFocusableOptions() : [];
		}, r.ariaOnChange = function(e, t) {
			r.setState({ ariaSelection: j({ value: e }, t) });
		}, r.onMenuMouseDown = function(e) {
			e.button === 0 && (e.stopPropagation(), e.preventDefault(), r.focusInput());
		}, r.onMenuMouseMove = function(e) {
			r.blockOptionHover = !1;
		}, r.onControlMouseDown = function(e) {
			if (!e.defaultPrevented) {
				var t = r.props.openMenuOnClick;
				r.state.isFocused ? r.props.menuIsOpen ? e.target.tagName !== "INPUT" && e.target.tagName !== "TEXTAREA" && r.onMenuClose() : t && r.openMenu("first") : (t && (r.openAfterFocus = !0), r.focusInput()), e.target.tagName !== "INPUT" && e.target.tagName !== "TEXTAREA" && e.preventDefault();
			}
		}, r.onDropdownIndicatorMouseDown = function(e) {
			if (!(e && e.type === "mousedown" && e.button !== 0) && !r.props.isDisabled) {
				var t = r.props, n = t.isMulti, i = t.menuIsOpen;
				r.focusInput(), i ? (r.setState({ inputIsHiddenAfterUpdate: !n }), r.onMenuClose()) : r.openMenu("first"), e.preventDefault();
			}
		}, r.onClearIndicatorMouseDown = function(e) {
			e && e.type === "mousedown" && e.button !== 0 || (r.clearValue(), e.preventDefault(), r.openAfterFocus = !1, e.type === "touchend" ? r.focusInput() : setTimeout(function() {
				return r.focusInput();
			}));
		}, r.onScroll = function(e) {
			typeof r.props.closeMenuOnScroll == "boolean" ? e.target instanceof HTMLElement && Uc(e.target) && r.props.onMenuClose() : typeof r.props.closeMenuOnScroll == "function" && r.props.closeMenuOnScroll(e) && r.props.onMenuClose();
		}, r.onCompositionStart = function() {
			r.isComposing = !0;
		}, r.onCompositionEnd = function() {
			r.isComposing = !1;
		}, r.onTouchStart = function(e) {
			var t = e.touches, n = t && t.item(0);
			n && (r.initialTouchX = n.clientX, r.initialTouchY = n.clientY, r.userIsDragging = !1);
		}, r.onTouchMove = function(e) {
			var t = e.touches, n = t && t.item(0);
			if (n) {
				var i = Math.abs(n.clientX - r.initialTouchX), a = Math.abs(n.clientY - r.initialTouchY), o = 5;
				r.userIsDragging = i > o || a > o;
			}
		}, r.onTouchEnd = function(e) {
			r.userIsDragging || (r.controlRef && !r.controlRef.contains(e.target) && r.menuListRef && !r.menuListRef.contains(e.target) && r.blurInput(), r.initialTouchX = 0, r.initialTouchY = 0);
		}, r.onControlTouchEnd = function(e) {
			r.userIsDragging || r.onControlMouseDown(e);
		}, r.onClearIndicatorTouchEnd = function(e) {
			r.userIsDragging || r.onClearIndicatorMouseDown(e);
		}, r.onDropdownIndicatorTouchEnd = function(e) {
			r.userIsDragging || r.onDropdownIndicatorMouseDown(e);
		}, r.handleInputChange = function(e) {
			var t = r.props.inputValue, n = e.currentTarget.value;
			r.setState({ inputIsHiddenAfterUpdate: !1 }), r.onInputChange(n, {
				action: "input-change",
				prevInputValue: t
			}), r.props.menuIsOpen || r.onMenuOpen();
		}, r.onInputFocus = function(e) {
			r.props.onFocus && r.props.onFocus(e), r.setState({
				inputIsHiddenAfterUpdate: !1,
				isFocused: !0
			}), (r.openAfterFocus || r.props.openMenuOnFocus) && r.openMenu("first"), r.openAfterFocus = !1;
		}, r.onInputBlur = function(e) {
			var t = r.props.inputValue;
			r.menuListRef && r.menuListRef.contains(document.activeElement) ? r.inputRef.focus() : (r.props.onBlur && r.props.onBlur(e), r.onInputChange("", {
				action: "input-blur",
				prevInputValue: t
			}), r.onMenuClose(), r.setState({
				focusedValue: null,
				isFocused: !1
			}));
		}, r.onOptionHover = function(e) {
			if (!(r.blockOptionHover || r.state.focusedOption === e)) {
				var t = r.getFocusableOptions().indexOf(e);
				r.setState({
					focusedOption: e,
					focusedOptionId: t > -1 ? r.getFocusedOptionId(e) : null
				});
			}
		}, r.shouldHideSelectedOptions = function() {
			return Vd(r.props);
		}, r.onValueInputFocus = function(e) {
			e.preventDefault(), e.stopPropagation(), r.focus();
		}, r.onKeyDown = function(e) {
			var t = r.props, n = t.isMulti, i = t.backspaceRemovesValue, a = t.escapeClearsValue, o = t.inputValue, s = t.isClearable, c = t.isDisabled, l = t.menuIsOpen, u = t.onKeyDown, d = t.tabSelectsValue, f = t.openMenuOnFocus, p = r.state, m = p.focusedOption, h = p.focusedValue, g = p.selectValue;
			if (!c && !(typeof u == "function" && (u(e), e.defaultPrevented))) {
				switch (r.blockOptionHover = !0, e.key) {
					case "ArrowLeft":
						if (!n || o) return;
						r.focusValue("previous");
						break;
					case "ArrowRight":
						if (!n || o) return;
						r.focusValue("next");
						break;
					case "Delete":
					case "Backspace":
						if (o) return;
						if (h) r.removeValue(h);
						else {
							if (!i) return;
							n ? r.popValue() : s && r.clearValue();
						}
						break;
					case "Tab":
						if (r.isComposing || e.shiftKey || !l || !d || !m || f && r.isOptionSelected(m, g)) return;
						r.selectOption(m);
						break;
					case "Enter":
						if (e.keyCode === 229) break;
						if (l) {
							if (!m || r.isComposing) return;
							r.selectOption(m);
							break;
						}
						return;
					case "Escape":
						l ? (r.setState({ inputIsHiddenAfterUpdate: !1 }), r.onInputChange("", {
							action: "menu-close",
							prevInputValue: o
						}), r.onMenuClose()) : s && a && r.clearValue();
						break;
					case " ":
						if (o) return;
						if (!l) {
							r.openMenu("first");
							break;
						}
						if (!m) return;
						r.selectOption(m);
						break;
					case "ArrowUp":
						l ? r.focusOption("up") : r.openMenu("last");
						break;
					case "ArrowDown":
						l ? r.focusOption("down") : r.openMenu("first");
						break;
					case "PageUp":
						if (!l) return;
						r.focusOption("pageup");
						break;
					case "PageDown":
						if (!l) return;
						r.focusOption("pagedown");
						break;
					case "Home":
						if (!l) return;
						r.focusOption("first");
						break;
					case "End":
						if (!l) return;
						r.focusOption("last");
						break;
					default: return;
				}
				e.preventDefault();
			}
		}, r.state.instancePrefix = "react-select-" + (r.props.instanceId || ++Hd), r.state.selectValue = Bc(e.value), e.menuIsOpen && r.state.selectValue.length) {
			var i = r.getFocusableOptionsWithIds(), a = r.buildFocusableOptions(), o = a.indexOf(r.state.selectValue[0]);
			r.state.focusableOptionsWithIds = i, r.state.focusedOption = a[o], r.state.focusedOptionId = Fd(i, a[o]);
		}
		return r;
	}
	return Qa(n, [
		{
			key: "componentDidMount",
			value: function() {
				this.startListeningComposition(), this.startListeningToTouch(), this.props.closeMenuOnScroll && document && document.addEventListener && document.addEventListener("scroll", this.onScroll, !0), this.props.autoFocus && this.focusInput(), this.props.menuIsOpen && this.state.focusedOption && this.menuListRef && this.focusedOptionRef && Xc(this.menuListRef, this.focusedOptionRef), gd() && this.setState({ isAppleDevice: !0 });
			}
		},
		{
			key: "componentDidUpdate",
			value: function(e) {
				var t = this.props, n = t.isDisabled, r = t.menuIsOpen, i = this.state.isFocused;
				(i && !n && e.isDisabled || i && r && !e.menuIsOpen) && this.focusInput(), i && n && !e.isDisabled ? this.setState({ isFocused: !1 }, this.onMenuClose) : !i && !n && e.isDisabled && this.inputRef === document.activeElement && this.setState({ isFocused: !0 }), this.menuListRef && this.focusedOptionRef && this.scrollToFocusedOptionOnUpdate && (Xc(this.menuListRef, this.focusedOptionRef), this.scrollToFocusedOptionOnUpdate = !1);
			}
		},
		{
			key: "componentWillUnmount",
			value: function() {
				this.stopListeningComposition(), this.stopListeningToTouch(), document.removeEventListener("scroll", this.onScroll, !0);
			}
		},
		{
			key: "onMenuOpen",
			value: function() {
				this.props.onMenuOpen();
			}
		},
		{
			key: "onMenuClose",
			value: function() {
				this.onInputChange("", {
					action: "menu-close",
					prevInputValue: this.props.inputValue
				}), this.props.onMenuClose();
			}
		},
		{
			key: "onInputChange",
			value: function(e, t) {
				this.props.onInputChange(e, t);
			}
		},
		{
			key: "focusInput",
			value: function() {
				this.inputRef && this.inputRef.focus();
			}
		},
		{
			key: "blurInput",
			value: function() {
				this.inputRef && this.inputRef.blur();
			}
		},
		{
			key: "openMenu",
			value: function(e) {
				var t = this, n = this.state, r = n.selectValue, i = n.isFocused, a = this.buildFocusableOptions(), o = e === "first" ? 0 : a.length - 1;
				if (!this.props.isMulti) {
					var s = a.indexOf(r[0]);
					s > -1 && (o = s);
				}
				this.scrollToFocusedOptionOnUpdate = !(i && this.menuListRef), this.setState({
					inputIsHiddenAfterUpdate: !1,
					focusedValue: null,
					focusedOption: a[o],
					focusedOptionId: this.getFocusedOptionId(a[o])
				}, function() {
					return t.onMenuOpen();
				});
			}
		},
		{
			key: "focusValue",
			value: function(e) {
				var t = this.state, n = t.selectValue, r = t.focusedValue;
				if (this.props.isMulti) {
					this.setState({ focusedOption: null });
					var i = n.indexOf(r);
					r || (i = -1);
					var a = n.length - 1, o = -1;
					if (n.length) {
						switch (e) {
							case "previous":
								o = i === 0 ? 0 : i === -1 ? a : i - 1;
								break;
							case "next": i > -1 && i < a && (o = i + 1);
						}
						this.setState({
							inputIsHidden: o !== -1,
							focusedValue: n[o]
						});
					}
				}
			}
		},
		{
			key: "focusOption",
			value: function() {
				var e = arguments.length > 0 && arguments[0] !== void 0 ? arguments[0] : "first", t = this.props.pageSize, n = this.state.focusedOption, r = this.getFocusableOptions();
				if (r.length) {
					var i = 0, a = r.indexOf(n);
					n || (a = -1), e === "up" ? i = a > 0 ? a - 1 : r.length - 1 : e === "down" ? i = (a + 1) % r.length : e === "pageup" ? (i = a - t, i < 0 && (i = 0)) : e === "pagedown" ? (i = a + t, i > r.length - 1 && (i = r.length - 1)) : e === "last" && (i = r.length - 1), this.scrollToFocusedOptionOnUpdate = !0, this.setState({
						focusedOption: r[i],
						focusedValue: null,
						focusedOptionId: this.getFocusedOptionId(r[i])
					});
				}
			}
		},
		{
			key: "getTheme",
			value: function() {
				return this.props.theme ? typeof this.props.theme == "function" ? this.props.theme(Td) : j(j({}, Td), this.props.theme) : Td;
			}
		},
		{
			key: "getCommonProps",
			value: function() {
				var e = this.clearValue, t = this.cx, n = this.getStyles, r = this.getClassNames, i = this.getValue, a = this.selectOption, o = this.setValue, s = this.props, c = s.isMulti, l = s.isRtl, u = s.options;
				return {
					clearValue: e,
					cx: t,
					getStyles: n,
					getClassNames: r,
					getValue: i,
					hasValue: this.hasValue(),
					isMulti: c,
					isRtl: l,
					options: u,
					selectOption: a,
					selectProps: s,
					setValue: o,
					theme: this.getTheme()
				};
			}
		},
		{
			key: "hasValue",
			value: function() {
				return this.state.selectValue.length > 0;
			}
		},
		{
			key: "hasOptions",
			value: function() {
				return !!this.getFocusableOptions().length;
			}
		},
		{
			key: "isClearable",
			value: function() {
				var e = this.props, t = e.isClearable, n = e.isMulti;
				return t === void 0 ? n : t;
			}
		},
		{
			key: "isOptionDisabled",
			value: function(e, t) {
				return Rd(this.props, e, t);
			}
		},
		{
			key: "isOptionSelected",
			value: function(e, t) {
				return zd(this.props, e, t);
			}
		},
		{
			key: "filterOption",
			value: function(e, t) {
				return Bd(this.props, e, t);
			}
		},
		{
			key: "formatOptionLabel",
			value: function(e, t) {
				if (typeof this.props.formatOptionLabel == "function") {
					var n = this.props.inputValue, r = this.state.selectValue;
					return this.props.formatOptionLabel(e, {
						context: t,
						inputValue: n,
						selectValue: r
					});
				}
				return this.getOptionLabel(e);
			}
		},
		{
			key: "formatGroupLabel",
			value: function(e) {
				return this.props.formatGroupLabel(e);
			}
		},
		{
			key: "startListeningComposition",
			value: function() {
				document && document.addEventListener && (document.addEventListener("compositionstart", this.onCompositionStart, !1), document.addEventListener("compositionend", this.onCompositionEnd, !1));
			}
		},
		{
			key: "stopListeningComposition",
			value: function() {
				document && document.removeEventListener && (document.removeEventListener("compositionstart", this.onCompositionStart), document.removeEventListener("compositionend", this.onCompositionEnd));
			}
		},
		{
			key: "startListeningToTouch",
			value: function() {
				document && document.addEventListener && (document.addEventListener("touchstart", this.onTouchStart, !1), document.addEventListener("touchmove", this.onTouchMove, !1), document.addEventListener("touchend", this.onTouchEnd, !1));
			}
		},
		{
			key: "stopListeningToTouch",
			value: function() {
				document && document.removeEventListener && (document.removeEventListener("touchstart", this.onTouchStart), document.removeEventListener("touchmove", this.onTouchMove), document.removeEventListener("touchend", this.onTouchEnd));
			}
		},
		{
			key: "renderInput",
			value: function() {
				var e = this.props, t = e.isDisabled, n = e.isSearchable, r = e.inputId, i = e.inputValue, a = e.tabIndex, o = e.form, s = e.menuIsOpen, c = e.required, l = this.getComponents().Input, u = this.state, d = u.inputIsHidden, f = u.ariaSelection, p = this.commonProps, m = r || this.getElementId("input"), h = j(j(j({
					"aria-autocomplete": "list",
					"aria-expanded": s,
					"aria-haspopup": !0,
					"aria-errormessage": this.props["aria-errormessage"],
					"aria-invalid": this.props["aria-invalid"],
					"aria-label": this.props["aria-label"],
					"aria-labelledby": this.props["aria-labelledby"],
					"aria-required": c,
					role: "combobox",
					"aria-activedescendant": this.state.isAppleDevice ? void 0 : this.state.focusedOptionId || ""
				}, s && { "aria-controls": this.getElementId("listbox") }), !n && { "aria-readonly": !0 }), this.hasValue() ? f?.action === "initial-input-focus" && { "aria-describedby": this.getElementId("live-region") } : { "aria-describedby": this.getElementId("placeholder") });
				return n ? /*#__PURE__*/ w(l, M({}, p, {
					autoCapitalize: "none",
					autoComplete: "off",
					autoCorrect: "off",
					id: m,
					innerRef: this.getInputRef,
					isDisabled: t,
					isHidden: d,
					onBlur: this.onInputBlur,
					onChange: this.handleInputChange,
					onFocus: this.onInputFocus,
					spellCheck: "false",
					tabIndex: a,
					form: o,
					type: "text",
					value: i
				}, h)) : /*#__PURE__*/ w(qu, M({
					id: m,
					innerRef: this.getInputRef,
					onBlur: this.onInputBlur,
					onChange: Lc,
					onFocus: this.onInputFocus,
					disabled: t,
					tabIndex: a,
					inputMode: "none",
					form: o,
					value: ""
				}, h));
			}
		},
		{
			key: "renderPlaceholderOrValue",
			value: function() {
				var e = this, t = this.getComponents(), n = t.MultiValue, r = t.MultiValueContainer, i = t.MultiValueLabel, a = t.MultiValueRemove, o = t.SingleValue, s = t.Placeholder, c = this.commonProps, l = this.props, u = l.controlShouldRenderValue, d = l.isDisabled, f = l.isMulti, p = l.inputValue, m = l.placeholder, h = this.state, g = h.selectValue, _ = h.focusedValue, v = h.isFocused;
				if (!this.hasValue() || !u) return p ? null : /*#__PURE__*/ w(s, M({}, c, {
					key: "placeholder",
					isDisabled: d,
					isFocused: v,
					innerProps: { id: this.getElementId("placeholder") }
				}), m);
				if (f) return g.map(function(t, o) {
					var s = t === _, l = `${e.getOptionLabel(t)}-${e.getOptionValue(t)}`;
					return /*#__PURE__*/ w(n, M({}, c, {
						components: {
							Container: r,
							Label: i,
							Remove: a
						},
						isFocused: s,
						isDisabled: d,
						key: l,
						index: o,
						removeProps: {
							onClick: function() {
								return e.removeValue(t);
							},
							onTouchEnd: function() {
								return e.removeValue(t);
							},
							onMouseDown: function(e) {
								e.preventDefault();
							}
						},
						data: t
					}), e.formatOptionLabel(t, "value"));
				});
				if (p) return null;
				var y = g[0];
				return /*#__PURE__*/ w(o, M({}, c, {
					data: y,
					isDisabled: d
				}), this.formatOptionLabel(y, "value"));
			}
		},
		{
			key: "renderClearIndicator",
			value: function() {
				var e = this.getComponents().ClearIndicator, t = this.commonProps, n = this.props, r = n.isDisabled, i = n.isLoading, a = this.state.isFocused;
				if (!this.isClearable() || !e || r || !this.hasValue() || i) return null;
				var o = {
					onMouseDown: this.onClearIndicatorMouseDown,
					onTouchEnd: this.onClearIndicatorTouchEnd,
					"aria-hidden": "true"
				};
				return /*#__PURE__*/ w(e, M({}, t, {
					innerProps: o,
					isFocused: a
				}));
			}
		},
		{
			key: "renderLoadingIndicator",
			value: function() {
				var e = this.getComponents().LoadingIndicator, t = this.commonProps, n = this.props, r = n.isDisabled, i = n.isLoading, a = this.state.isFocused;
				return !e || !i ? null : /*#__PURE__*/ w(e, M({}, t, {
					innerProps: { "aria-hidden": "true" },
					isDisabled: r,
					isFocused: a
				}));
			}
		},
		{
			key: "renderIndicatorSeparator",
			value: function() {
				var e = this.getComponents(), t = e.DropdownIndicator, n = e.IndicatorSeparator;
				if (!t || !n) return null;
				var r = this.commonProps, i = this.props.isDisabled, a = this.state.isFocused;
				return /*#__PURE__*/ w(n, M({}, r, {
					isDisabled: i,
					isFocused: a
				}));
			}
		},
		{
			key: "renderDropdownIndicator",
			value: function() {
				var e = this.getComponents().DropdownIndicator;
				if (!e) return null;
				var t = this.commonProps, n = this.props.isDisabled, r = this.state.isFocused, i = {
					onMouseDown: this.onDropdownIndicatorMouseDown,
					onTouchEnd: this.onDropdownIndicatorTouchEnd,
					"aria-hidden": "true"
				};
				return /*#__PURE__*/ w(e, M({}, t, {
					innerProps: i,
					isDisabled: n,
					isFocused: r
				}));
			}
		},
		{
			key: "renderMenu",
			value: function() {
				var e = this, t = this.getComponents(), n = t.Group, r = t.GroupHeading, i = t.Menu, a = t.MenuList, o = t.MenuPortal, s = t.LoadingMessage, c = t.NoOptionsMessage, l = t.Option, u = this.commonProps, d = this.state.focusedOption, f = this.props, p = f.captureMenuScroll, m = f.inputValue, h = f.isLoading, g = f.loadingMessage, _ = f.minMenuHeight, v = f.maxMenuHeight, y = f.menuIsOpen, b = f.menuPlacement, x = f.menuPosition, S = f.menuPortalTarget, C = f.menuShouldBlockScroll, ee = f.menuShouldScrollIntoView, T = f.noOptionsMessage, te = f.onMenuScrollToTop, ne = f.onMenuScrollToBottom;
				if (!y) return null;
				var re = function(t, n) {
					var r = t.type, i = t.data, a = t.isDisabled, o = t.isSelected, s = t.label, c = t.value, f = d === i, p = a ? void 0 : function() {
						return e.onOptionHover(i);
					}, m = a ? void 0 : function() {
						return e.selectOption(i);
					}, h = `${e.getElementId("option")}-${n}`, g = {
						id: h,
						onClick: m,
						onMouseMove: p,
						onMouseOver: p,
						tabIndex: -1,
						role: "option",
						"aria-selected": e.state.isAppleDevice ? void 0 : o
					};
					return /*#__PURE__*/ w(l, M({}, u, {
						innerProps: g,
						data: i,
						isDisabled: a,
						isSelected: o,
						key: h,
						label: s,
						type: r,
						value: c,
						isFocused: f,
						innerRef: f ? e.getFocusedOptionRef : void 0
					}), e.formatOptionLabel(t.data, "menu"));
				}, ie;
				if (this.hasOptions()) ie = this.getCategorizedOptions().map(function(t) {
					if (t.type === "group") {
						var i = t.data, a = t.options, o = t.index, s = `${e.getElementId("group")}-${o}`, c = `${s}-heading`;
						return /*#__PURE__*/ w(n, M({}, u, {
							key: s,
							data: i,
							options: a,
							Heading: r,
							headingProps: {
								id: c,
								data: t.data
							},
							label: e.formatGroupLabel(t.data)
						}), t.options.map(function(e) {
							return re(e, `${o}-${e.index}`);
						}));
					}
					if (t.type === "option") return re(t, `${t.index}`);
				});
				else if (h) {
					var ae = g({ inputValue: m });
					if (ae === null) return null;
					ie = /*#__PURE__*/ w(s, u, ae);
				} else {
					var oe = T({ inputValue: m });
					if (oe === null) return null;
					ie = /*#__PURE__*/ w(c, u, oe);
				}
				var se = {
					minMenuHeight: _,
					maxMenuHeight: v,
					menuPlacement: b,
					menuPosition: x,
					menuShouldScrollIntoView: ee
				}, ce = /*#__PURE__*/ w(_l, M({}, u, se), function(t) {
					var n = t.ref, r = t.placerProps, o = r.placement, s = r.maxHeight;
					return /*#__PURE__*/ w(i, M({}, u, se, {
						innerRef: n,
						innerProps: {
							onMouseDown: e.onMenuMouseDown,
							onMouseMove: e.onMenuMouseMove
						},
						isLoading: h,
						placement: o
					}), /*#__PURE__*/ w(cd, {
						captureEnabled: p,
						onTopArrive: te,
						onBottomArrive: ne,
						lockEnabled: C
					}, function(t) {
						return /*#__PURE__*/ w(a, M({}, u, {
							innerRef: function(n) {
								e.getMenuListRef(n), t(n);
							},
							innerProps: {
								role: "listbox",
								"aria-multiselectable": u.isMulti,
								id: e.getElementId("listbox")
							},
							isLoading: h,
							maxHeight: s,
							focusedOption: d
						}), ie);
					}));
				});
				return S || x === "fixed" ? /*#__PURE__*/ w(o, M({}, u, {
					appendTo: S,
					controlElement: this.controlRef,
					menuPlacement: b,
					menuPosition: x
				}), ce) : ce;
			}
		},
		{
			key: "renderFormField",
			value: function() {
				var e = this, t = this.props, n = t.delimiter, r = t.isDisabled, i = t.isMulti, a = t.name, o = t.required, s = this.state.selectValue;
				if (o && !this.hasValue() && !r) return /*#__PURE__*/ w(ud, {
					name: a,
					onFocus: this.onValueInputFocus
				});
				if (a && !r) {
					if (i) {
						if (n) {
							var c = s.map(function(t) {
								return e.getOptionValue(t);
							}).join(n);
							return /*#__PURE__*/ w("input", {
								name: a,
								type: "hidden",
								value: c
							});
						}
						var l = s.length > 0 ? s.map(function(t, n) {
							return /*#__PURE__*/ w("input", {
								key: `i-${n}`,
								name: a,
								type: "hidden",
								value: e.getOptionValue(t)
							});
						}) : /*#__PURE__*/ w("input", {
							name: a,
							type: "hidden",
							value: ""
						});
						return /*#__PURE__*/ w("div", null, l);
					}
					var u = s[0] ? this.getOptionValue(s[0]) : "";
					return /*#__PURE__*/ w("input", {
						name: a,
						type: "hidden",
						value: u
					});
				}
			}
		},
		{
			key: "renderLiveRegion",
			value: function() {
				var e = this.commonProps, t = this.state, n = t.ariaSelection, r = t.focusedOption, i = t.focusedValue, a = t.isFocused, o = t.selectValue, s = this.getFocusableOptions();
				return /*#__PURE__*/ w(Pu, M({}, e, {
					id: this.getElementId("live-region"),
					ariaSelection: n,
					focusedOption: r,
					focusedValue: i,
					isFocused: a,
					selectValue: o,
					focusableOptions: s,
					isAppleDevice: this.state.isAppleDevice
				}));
			}
		},
		{
			key: "render",
			value: function() {
				var e = this.getComponents(), t = e.Control, n = e.IndicatorsContainer, r = e.SelectContainer, i = e.ValueContainer, a = this.props, o = a.className, s = a.id, c = a.isDisabled, l = a.menuIsOpen, u = this.state.isFocused, d = this.commonProps = this.getCommonProps();
				return /*#__PURE__*/ w(r, M({}, d, {
					className: o,
					innerProps: {
						id: s,
						onKeyDown: this.onKeyDown
					},
					isDisabled: c,
					isFocused: u
				}), this.renderLiveRegion(), /*#__PURE__*/ w(t, M({}, d, {
					innerRef: this.getControlRef,
					innerProps: {
						onMouseDown: this.onControlMouseDown,
						onTouchEnd: this.onControlTouchEnd
					},
					isDisabled: c,
					isFocused: u,
					menuIsOpen: l
				}), /*#__PURE__*/ w(i, M({}, d, { isDisabled: c }), this.renderPlaceholderOrValue(), this.renderInput()), /*#__PURE__*/ w(n, M({}, d, { isDisabled: c }), this.renderClearIndicator(), this.renderLoadingIndicator(), this.renderIndicatorSeparator(), this.renderDropdownIndicator())), this.renderMenu(), this.renderFormField());
			}
		}
	], [{
		key: "getDerivedStateFromProps",
		value: function(e, t) {
			var n = t.prevProps, r = t.clearFocusValueOnUpdate, i = t.inputIsHiddenAfterUpdate, a = t.ariaSelection, o = t.isFocused, s = t.prevWasFocused, c = t.instancePrefix, l = e.options, u = e.value, d = e.menuIsOpen, f = e.inputValue, p = e.isMulti, m = Bc(u), h = {};
			if (n && (u !== n.value || l !== n.options || d !== n.menuIsOpen || f !== n.inputValue)) {
				var g = d ? jd(e, m) : [], _ = d ? Ad(Od(e, m), `${c}-option`) : [], v = r ? Nd(t, m) : null, y = Pd(t, g);
				h = {
					selectValue: m,
					focusedOption: y,
					focusedOptionId: Fd(_, y),
					focusableOptionsWithIds: _,
					focusedValue: v,
					clearFocusValueOnUpdate: !1
				};
			}
			var b = i != null && e !== n ? {
				inputIsHidden: i,
				inputIsHiddenAfterUpdate: void 0
			} : {}, x = a, S = o && s;
			return o && !S && (x = {
				value: ol(p, m, m[0] || null),
				options: m,
				action: "initial-input-focus"
			}, S = !s), a?.action === "initial-input-focus" && (x = null), j(j(j({}, h), b), {}, {
				prevProps: e,
				ariaSelection: x,
				prevWasFocused: S
			});
		}
	}]), n;
}(c);
//#endregion
//#region node_modules/react-select/dist/react-select.esm.js
Ud.defaultProps = Ed, k();
var Wd = /* @__PURE__ */ T(function(e, t) {
	var n = Ya(e);
	return /*#__PURE__*/ w(Ud, M({ ref: t }, n));
}), Gd = window.shinyreact, { useShinyInput: Kd, useSetShinyInput: qd, useShinyInputValue: I, useShinyOutputValue: L, useShinyOutputStatus: Jd, useShinyOutputError: Yd, useShinyMessageHandler: Xd, useShinyInitialized: Zd, useShinyBusy: Qd, ShinyOutput: $d, ImageOutput: ef } = Gd;
function tf(e) {
	let [t, n] = Gd.useShinyInput(e, 0, {
		debounceMs: 0,
		priority: "event"
	});
	return () => n(t + 1);
}
//#endregion
//#region src/lib/labels.ts
k();
var nf = () => window.twLabels ?? {
	labels: {},
	known: {}
};
function rf() {
	let [e, t] = O(nf);
	return E(() => {
		let e = () => t({ ...nf() });
		return document.addEventListener("tw-labels", e), () => document.removeEventListener("tw-labels", e);
	}, []), {
		label: (t) => Object.prototype.hasOwnProperty.call(e.labels, t) ? e.labels[t] : null,
		isVar: (t) => Object.prototype.hasOwnProperty.call(e.known, t) || Object.prototype.hasOwnProperty.call(e.labels, t)
	};
}
//#endregion
//#region node_modules/react/cjs/react-jsx-runtime.production.js
var af = /* @__PURE__ */ r(((e) => {
	var t = Symbol.for("react.transitional.element"), n = Symbol.for("react.fragment");
	function r(e, n, r) {
		var i = null;
		if (r !== void 0 && (i = "" + r), n.key !== void 0 && (i = "" + n.key), "key" in n) for (var a in r = {}, n) a !== "key" && (r[a] = n[a]);
		else r = n;
		return n = r.ref, {
			$$typeof: t,
			type: e,
			key: i,
			ref: n === void 0 ? null : n,
			props: r
		};
	}
	e.Fragment = n, e.jsx = r, e.jsxs = r;
})), of = /* @__PURE__ */ r(((e, t) => {
	t.exports = af();
}));
//#endregion
//#region src/lib/inputs.tsx
k();
var R = of();
function sf(e) {
	return e ? Array.isArray(e) ? e.map((e) => typeof e == "string" ? {
		value: e,
		label: e
	} : e) : Object.entries(e).map(([e, t]) => ({
		value: String(t),
		label: e
	})) : [];
}
function cf(e) {
	let t = [], n = [];
	return /<option/i.test(e) ? new DOMParser().parseFromString(`<select multiple>${e}</select>`, "text/html").querySelectorAll("option").forEach((e) => {
		let r = e.parentElement?.tagName === "OPTGROUP" ? e.parentElement.label : void 0;
		t.push({
			value: e.value,
			label: e.textContent ?? e.value,
			group: r,
			disabled: e.disabled
		}), e.selected && n.push(e.value);
	}) : new DOMParser().parseFromString(`<div>${e}</div>`, "text/html").querySelectorAll("input").forEach((e) => {
		let r = e.closest("label")?.textContent?.trim() ?? e.nextElementSibling?.textContent?.trim() ?? e.value;
		t.push({
			value: e.value,
			label: r
		}), e.checked && n.push(e.value);
	}), {
		choices: t,
		selected: n
	};
}
function lf(e) {
	let t = {};
	"label" in e && typeof e.label == "string" && (t.label = e.label);
	for (let n of [
		"min",
		"max",
		"step"
	]) {
		let r = e[n];
		if (r == null) continue;
		let i = Number(r);
		isFinite(i) && (t[n] = i), n !== "step" && (t[n === "min" ? "minRaw" : "maxRaw"] = String(r));
	}
	typeof e.placeholder == "string" && (t.placeholder = e.placeholder), typeof e.disabled == "boolean" && (t.disabled = e.disabled);
	let n = typeof e.options == "string" ? e.options : typeof e.choices == "string" ? e.choices : null, r = null;
	if (n !== null) {
		let e = cf(n);
		t.choices = e.choices, r = e.selected;
	} else Array.isArray(e.choices) && (t.choices = sf(e.choices));
	if ("value" in e ? t.value = e.value : "selected" in e ? t.value = e.selected : "start" in e || "end" in e ? t.value = [e.start, e.end] : r && r.length && (t.value = r), t.value && typeof t.value == "object" && !Array.isArray(t.value)) {
		let e = t.value;
		("start" in e || "end" in e) && (t.value = [e.start ?? "", e.end ?? ""]);
	}
	return t;
}
function uf(e, t) {
	let n = D(t);
	n.current = t, E(() => {
		let t = window.jQuery;
		if (!t) return;
		let r = document.createElement("span");
		return r.id = e, r.className = "shiny-bound-input tw-binding", r.hidden = !0, document.body.appendChild(r), t(r).data("shiny-input-binding", { receiveMessage: (e, t) => n.current(lf(t ?? {})) }), () => r.remove();
	}, [e]);
}
var df = (e) => `${e}__ctl`;
function ff(e) {
	let [t, n] = O(!0);
	return E(() => {
		let t = (t) => {
			let r = t.detail;
			r?.id === e && n(!!r.show);
		};
		return document.addEventListener("tw-input-visible", t), () => document.removeEventListener("tw-input-visible", t);
	}, [e]), t;
}
function pf({ id: e, label: t, help: n, children: r, className: i, inline: a, style: o }) {
	return ff(e) ? /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `tw-field${a ? " tw-field-inline" : ""}${i ? " " + i : ""}`,
		style: o,
		children: [
			t ? /* @__PURE__ */ (0, R.jsx)("label", {
				className: "form-label",
				htmlFor: df(e),
				children: t
			}) : null,
			r,
			n ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "form-text",
				children: n
			}) : null
		]
	}) : null;
}
function z(e) {
	let t = e.multiple ? Array.isArray(e.value) ? e.value : e.value ? [e.value] : [] : Array.isArray(e.value) ? e.value[0] ?? "" : e.value ?? "", [n, r] = O(sf(e.choices)), [i, a] = O(e.label), [o, s] = Kd(e.id, e.multiple ? t.length ? t : null : t, {
		debounceMs: 0,
		type: "tw.chr"
	}), c = JSON.stringify(e.choices ?? null), l = D(!0);
	E(() => {
		l.current ? l.current = !1 : r(sf(e.choices));
	}, [c]), uf(e.id, (t) => {
		t.label !== void 0 && a(t.label);
		let i = n;
		if (t.choices && (i = t.choices, r(t.choices)), t.value !== void 0) {
			let n = t.value === null ? [] : Array.isArray(t.value) ? t.value.map(String) : [String(t.value)];
			u(e.multiple ? n : n[0] ?? "");
		} else if (t.choices) {
			let t = new Set(i.map((e) => e.value));
			if (e.multiple) {
				let e = (Array.isArray(o) ? o : []).filter((e) => t.has(e));
				u(e);
			} else t.has(String(o ?? "")) || u(i[0]?.value ?? "");
		}
	});
	let u = (t) => {
		let n = Array.isArray(t) ? t.length ? t : null : t;
		s(n), e.onChange?.(n);
	}, d = rf(), f = (e, t) => {
		let n = e.label === e.value ? d.label(e.value) : null;
		return n && t === "menu" ? /* @__PURE__ */ (0, R.jsxs)("span", {
			className: "tw-opt",
			children: [/* @__PURE__ */ (0, R.jsx)("span", {
				className: "tw-opt-name tw-strong",
				children: e.label
			}), /* @__PURE__ */ (0, R.jsx)("span", {
				className: "tw-opt-label",
				children: n
			})]
		}) : e.label;
	}, p = !!(e.multiple && e.actions && n.length > 1), m = [...new Set(n.map((e) => e.group).filter(Boolean))], h = m.length ? [...n.filter((e) => !e.group), ...m.map((e) => ({
		label: e,
		options: n.filter((t) => t.group === e)
	}))] : n, g = (Array.isArray(o) ? o : o ? [o] : []).map((e) => n.find((t) => t.value === e) ?? {
		value: e,
		label: e
	});
	return /* @__PURE__ */ (0, R.jsxs)(pf, {
		id: e.id,
		label: p ? void 0 : i,
		help: e.help,
		className: e.className,
		children: [p ? /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-select-head",
			children: [i ? /* @__PURE__ */ (0, R.jsx)("label", {
				className: "form-label",
				htmlFor: df(e.id),
				children: i
			}) : /* @__PURE__ */ (0, R.jsx)("span", {}), /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-select-actions",
				children: [/* @__PURE__ */ (0, R.jsx)("button", {
					type: "button",
					className: "btn btn-link btn-sm p-0",
					onClick: () => u(n.map((e) => e.value)),
					children: "Select all"
				}), /* @__PURE__ */ (0, R.jsx)("button", {
					type: "button",
					className: "btn btn-link btn-sm p-0",
					onClick: () => u([]),
					children: "None"
				})]
			})]
		}) : null, /* @__PURE__ */ (0, R.jsx)(Wd, {
			inputId: df(e.id),
			classNamePrefix: "tw-select",
			className: "tw-select",
			options: h,
			isMulti: !!e.multiple,
			isDisabled: e.disabled,
			value: e.multiple ? g : g[0] ?? null,
			onChange: (t) => u(e.multiple ? (t ?? []).map((e) => e.value) : t?.value ?? ""),
			isClearable: e.clearable ?? !!e.multiple,
			placeholder: e.placeholder ?? (e.multiple ? "All" : "Choose..."),
			isOptionDisabled: (e) => !!e.disabled,
			closeMenuOnSelect: !e.multiple,
			hideSelectedOptions: !1,
			menuPortalTarget: document.body,
			menuPlacement: "auto",
			styles: { menuPortal: (e) => ({
				...e,
				zIndex: 2e3
			}) },
			noOptionsMessage: () => "Nothing to choose",
			formatOptionLabel: (e, t) => f(e, t.context),
			filterOption: (e, t) => {
				let n = t.toLowerCase();
				return !n || e.label.toLowerCase().includes(n) || e.value.toLowerCase().includes(n) || (d.label(e.value) ?? "").toLowerCase().includes(n);
			}
		})]
	});
}
function mf({ id: e, label: t, value: n, min: r, max: i, step: a, help: o, className: s, placeholder: c, onChange: l }) {
	let [u, d] = Kd(e, n ?? null, {
		debounceMs: 250,
		type: "tw.num"
	}), [f, p] = O({
		min: r,
		max: i,
		step: a
	}), [m, h] = O(t), [g, _] = O(u == null ? "" : String(u));
	return E(() => {
		u == null ? g !== "" && !isNaN(Number(g)) && _("") : Number(g) !== u && _(String(u));
	}, [u]), uf(e, (e) => {
		if (e.label !== void 0 && h(e.label), (e.min !== void 0 || e.max !== void 0 || e.step !== void 0) && p((t) => ({
			min: e.min ?? t.min,
			max: e.max ?? t.max,
			step: e.step ?? t.step
		})), e.value !== void 0) {
			let t = e.value === null || e.value === "" ? null : Number(e.value);
			d(t), _(t === null ? "" : String(t));
		}
	}), /* @__PURE__ */ (0, R.jsx)(pf, {
		id: e,
		label: m,
		help: o,
		className: s,
		children: /* @__PURE__ */ (0, R.jsx)("input", {
			id: df(e),
			type: "number",
			className: "form-control form-control-sm",
			value: g,
			placeholder: c,
			min: f.min,
			max: f.max,
			step: f.step ?? "any",
			onChange: (e) => {
				_(e.target.value);
				let t = e.target.value === "" ? null : Number(e.target.value);
				(t === null || !isNaN(t)) && (d(t), l?.(t));
			}
		})
	});
}
function hf({ id: e, label: t, value: n, placeholder: r, help: i, className: a, area: o, rows: s, password: c, onChange: l }) {
	let [u, d] = Kd(e, n ?? "", { debounceMs: 300 }), [f, p] = O(r), [m, h] = O(t);
	uf(e, (e) => {
		e.label !== void 0 && h(e.label), e.placeholder !== void 0 && p(e.placeholder), e.value !== void 0 && d(String(e.value ?? ""));
	});
	let g = {
		id: df(e),
		className: "form-control form-control-sm",
		value: u ?? "",
		placeholder: f,
		onChange: (e) => {
			d(e.target.value), l?.(e.target.value);
		}
	};
	return /* @__PURE__ */ (0, R.jsx)(pf, {
		id: e,
		label: m,
		help: i,
		className: a,
		children: o ? /* @__PURE__ */ (0, R.jsx)("textarea", {
			...g,
			rows: s ?? 3
		}) : /* @__PURE__ */ (0, R.jsx)("input", {
			...g,
			type: c ? "password" : "text",
			autoComplete: c ? "off" : void 0
		})
	});
}
function gf({ id: e, label: t, value: n, help: r, className: i, asSwitch: a, onChange: o }) {
	let [s, c] = Kd(e, !!n, { debounceMs: 0 }), [l, u] = O(t);
	return uf(e, (e) => {
		e.label !== void 0 && u(e.label), e.value !== void 0 && c(!!e.value);
	}), /* @__PURE__ */ (0, R.jsx)(pf, {
		id: e,
		help: r,
		className: i,
		children: /* @__PURE__ */ (0, R.jsxs)("div", {
			className: `form-check${a ? " form-switch" : ""}`,
			children: [/* @__PURE__ */ (0, R.jsx)("input", {
				id: df(e),
				className: "form-check-input",
				type: "checkbox",
				role: a ? "switch" : void 0,
				checked: !!s,
				onChange: (e) => {
					c(e.target.checked), o?.(e.target.checked);
				}
			}), /* @__PURE__ */ (0, R.jsx)("label", {
				className: "form-check-label",
				htmlFor: df(e),
				children: l
			})]
		})
	});
}
function _f({ id: e, label: t, choices: n, value: r, inline: i, buttons: a, help: o, className: s, size: c = "sm", onChange: l }) {
	let [u, d] = O(sf(n)), f = JSON.stringify(n ?? null);
	E(() => d(sf(n)), [f]);
	let [p, m] = Kd(e, r ?? sf(n)[0]?.value ?? "", {
		debounceMs: 0,
		type: "tw.chr"
	}), [h, g] = O(t);
	uf(e, (e) => {
		e.label !== void 0 && g(e.label), e.choices && d(e.choices), e.value !== void 0 && m(String(Array.isArray(e.value) ? e.value[0] : e.value ?? ""));
	});
	let _ = (e) => {
		m(e), l?.(e);
	};
	return /* @__PURE__ */ (0, R.jsx)(pf, {
		id: e,
		label: h,
		help: o,
		className: s,
		children: a ? /* @__PURE__ */ (0, R.jsx)("div", {
			className: `btn-group${c === "sm" ? " btn-group-sm" : ""} tw-seg`,
			role: "radiogroup",
			id: df(e),
			children: u.map((e) => /* @__PURE__ */ (0, R.jsx)("button", {
				type: "button",
				role: "radio",
				"aria-checked": p === e.value,
				className: `btn btn-outline-primary${p === e.value ? " active" : ""}`,
				onClick: () => _(e.value),
				children: e.label
			}, e.value))
		}) : /* @__PURE__ */ (0, R.jsx)("div", {
			role: "radiogroup",
			id: df(e),
			children: u.map((t, n) => /* @__PURE__ */ (0, R.jsxs)("div", {
				className: `form-check${i ? " form-check-inline" : ""}`,
				children: [/* @__PURE__ */ (0, R.jsx)("input", {
					className: "form-check-input",
					type: "radio",
					id: `${df(e)}_${n}`,
					name: df(e),
					checked: p === t.value,
					onChange: () => _(t.value)
				}), /* @__PURE__ */ (0, R.jsx)("label", {
					className: "form-check-label",
					htmlFor: `${df(e)}_${n}`,
					children: t.label
				})]
			}, t.value))
		})
	});
}
function vf({ id: e, label: t, min: n, max: r, step: i, value: a, help: o, className: s, format: c }) {
	let l = Array.isArray(a), [u, d] = Kd(e, a, {
		debounceMs: 250,
		type: "tw.num"
	}), [f, p] = O({
		min: n,
		max: r,
		step: i ?? 1
	});
	E(() => p({
		min: n,
		max: r,
		step: i ?? 1
	}), [
		n,
		r,
		i
	]), uf(e, (e) => {
		(e.min !== void 0 || e.max !== void 0 || e.step !== void 0) && p((t) => ({
			min: e.min ?? t.min,
			max: e.max ?? t.max,
			step: e.step ?? t.step
		})), e.value !== void 0 && e.value !== null && d(Array.isArray(e.value) ? e.value.map(Number) : Number(e.value));
	});
	let m = c ?? ((e) => e.toLocaleString("en-US")), h = Array.isArray(u) ? u : [u];
	return /* @__PURE__ */ (0, R.jsx)(pf, {
		id: e,
		label: t,
		help: o,
		className: s,
		children: /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-slider",
			children: [l ? /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-slider-dual",
				children: [/* @__PURE__ */ (0, R.jsx)("input", {
					type: "range",
					className: "form-range",
					min: f.min,
					max: f.max,
					step: f.step,
					value: h[0],
					onChange: (e) => d([Math.min(Number(e.target.value), h[1]), h[1]]),
					"aria-label": "From"
				}), /* @__PURE__ */ (0, R.jsx)("input", {
					type: "range",
					className: "form-range",
					min: f.min,
					max: f.max,
					step: f.step,
					value: h[1],
					onChange: (e) => d([h[0], Math.max(Number(e.target.value), h[0])]),
					"aria-label": "To"
				})]
			}) : /* @__PURE__ */ (0, R.jsx)("input", {
				id: df(e),
				type: "range",
				className: "form-range",
				min: f.min,
				max: f.max,
				step: f.step,
				value: h[0],
				onChange: (e) => d(Number(e.target.value))
			}), /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-slider-value",
				children: l ? `${m(h[0])} – ${m(h[1])}` : m(h[0])
			})]
		})
	});
}
function yf({ id: e, label: t, value: n, range: r, min: i, max: a, help: o, className: s }) {
	let [c, l] = Kd(e, r ? Array.isArray(n) ? n : null : typeof n == "string" ? n : null, {
		debounceMs: 300,
		type: "tw.date"
	}), [u, d] = O({
		min: i,
		max: a
	});
	E(() => d({
		min: i,
		max: a
	}), [i, a]), uf(e, (e) => {
		(e.minRaw !== void 0 || e.maxRaw !== void 0) && d((t) => ({
			min: e.minRaw ?? t.min,
			max: e.maxRaw ?? t.max
		})), e.value !== void 0 && l(e.value === null ? null : Array.isArray(e.value) ? e.value.map((e) => String(e ?? "")) : String(e.value));
	});
	let f = Array.isArray(c) ? c : [c ?? "", ""], p = (e, t) => {
		if (!r) {
			l(t || null);
			return;
		}
		let n = [f[0] ?? "", f[1] ?? ""];
		n[e] = t, l(n[0] || n[1] ? n : null);
	};
	return /* @__PURE__ */ (0, R.jsx)(pf, {
		id: e,
		label: t,
		help: o,
		className: s,
		children: /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-dates",
			children: [/* @__PURE__ */ (0, R.jsx)("input", {
				id: df(e),
				type: "date",
				className: "form-control form-control-sm",
				value: f[0] ?? "",
				min: u.min,
				max: u.max,
				onChange: (e) => p(0, e.target.value)
			}), r ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)("span", {
				className: "text-muted",
				children: "to"
			}), /* @__PURE__ */ (0, R.jsx)("input", {
				type: "date",
				className: "form-control form-control-sm",
				value: f[1] ?? "",
				min: u.min,
				max: u.max,
				onChange: (e) => p(1, e.target.value)
			})] }) : null]
		})
	});
}
function B({ id: e, label: t, icon: n, variant: r = "outline-primary", size: i = "sm", className: a, title: o, disabled: s, onClick: c, link: l }) {
	let u = tf(e), d = D(null);
	E(() => {
		window.twGates?.apply(e);
	});
	let f = l ? "btn btn-link p-0 tw-link" : `btn btn-${r}${i === "sm" ? " btn-sm" : ""}`;
	return /* @__PURE__ */ (0, R.jsxs)("button", {
		ref: d,
		id: e,
		type: "button",
		className: `${f} action-button${a ? " " + a : ""}`,
		title: o,
		"data-shiny-no-bind-input": "",
		disabled: s,
		onClick: () => {
			d.current?.classList.contains("tw-frozen") || (u(), c?.());
		},
		children: [
			n,
			n && t ? " " : null,
			t
		]
	});
}
function bf({ id: e, label: t, icon: n, variant: r = "outline-primary", size: i = "sm", className: a, title: o }) {
	return E(() => {
		window.twGates?.apply(e);
	}), /* @__PURE__ */ (0, R.jsxs)($d, {
		id: e,
		tagName: "a",
		title: o,
		className: `btn btn-${r}${i === "sm" ? " btn-sm" : ""} shiny-download-link${a ? " " + a : ""}`,
		download: "",
		target: "_blank",
		children: [
			n,
			n ? " " : null,
			t
		]
	});
}
function xf({ id: e, className: t, style: n, inline: r }) {
	return /* @__PURE__ */ (0, R.jsx)($d, {
		id: e,
		tagName: r ? "span" : "div",
		className: `shiny-html-output${t ? " " + t : ""}`,
		style: n
	});
}
function Sf({ id: e, className: t }) {
	return /* @__PURE__ */ (0, R.jsx)($d, {
		id: e,
		tagName: "span",
		className: `shiny-text-output${t ? " " + t : ""}`
	});
}
//#endregion
//#region src/lib/visibility.ts
k();
var Cf = () => window.jQuery, wf = /* @__PURE__ */ new Map(), Tf = /* @__PURE__ */ new Map(), Ef = /* @__PURE__ */ new Map(), Df = !1, Of = 0;
function kf(e) {
	for (let t of document.querySelectorAll(`[id="${CSS.escape(e)}"]`)) if (!t.closest(".shiny-react-output-container")) return t;
	return null;
}
function Af(e) {
	return document.querySelector(`.shiny-react-output-container [id="${CSS.escape(e)}"]`);
}
function jf() {
	Of = 0;
	let e = Cf(), t = null;
	for (let e of wf.keys()) {
		let n = Tf.get(e)?.current ?? kf(e), r = Af(e);
		if (!n || !r) continue;
		let i = n.offsetParent === null && getComputedStyle(n).position !== "fixed";
		Ef.get(e) !== i && (Ef.set(e, i), r.style.display = i ? "none" : "", t = r);
	}
	t && e && e(t).trigger("shown");
}
function Mf() {
	Of ||= window.requestAnimationFrame(jf);
}
function Nf() {
	if (Df) return;
	Df = !0;
	let e = Cf();
	e && e(document).on("shown hidden", () => Mf()), window.addEventListener("resize", Mf), document.addEventListener("click", () => window.setTimeout(Mf, 50), !0), window.setInterval(Mf, 1500);
}
function V(e, t) {
	E(() => {
		if (!e) return;
		Nf(), t && Tf.set(e, t), wf.set(e, (wf.get(e) ?? 0) + 1), Ef.delete(e), Mf();
		let n = window.setTimeout(Mf, 300);
		return () => {
			window.clearTimeout(n);
			let t = (wf.get(e) ?? 1) - 1;
			if (t > 0) {
				wf.set(e, t);
				return;
			}
			wf.delete(e), Tf.delete(e), Ef.delete(e);
			let r = Af(e);
			r && (r.style.display = "");
		};
	}, [e]);
}
//#endregion
//#region src/lib/table.tsx
k();
var Pf = new Intl.NumberFormat("en-US", { maximumFractionDigits: 2 }), Ff = (e) => String(e).padStart(2, "0");
function If(e, t) {
	if (e == null) return "";
	let n = t.format ?? "";
	if (t.type === "logical" || typeof e == "boolean") return e ? "Yes" : "No";
	if (t.type === "number" || typeof e == "number") {
		let t = Number(e);
		if (!isFinite(t)) return String(e);
		switch (n) {
			case "int": return Math.round(t).toLocaleString("en-US");
			case "dec1": return t.toLocaleString("en-US", {
				minimumFractionDigits: 1,
				maximumFractionDigits: 1
			});
			case "dec2": return t.toLocaleString("en-US", {
				minimumFractionDigits: 2,
				maximumFractionDigits: 2
			});
			case "pct": return `${Math.round(100 * t)}%`;
			case "pct1": return `${(100 * t).toFixed(1)}%`;
			case "text": return String(t);
			default: return Pf.format(t);
		}
	}
	let r = String(e);
	if (t.type === "date" || n === "date") {
		let e = /^(\d{4})-(\d{2})-(\d{2})/.exec(r);
		return e ? `${e[3]}/${e[2]}/${e[1]}` : r;
	}
	if (t.type === "datetime" || n === "datetime") {
		let e = new Date(r);
		return isNaN(e.getTime()) ? r : `${Ff(e.getDate())}/${Ff(e.getMonth() + 1)}/${e.getFullYear()}, ${Ff(e.getHours())}:${Ff(e.getMinutes())}`;
	}
	return r;
}
function Lf(e, t, n) {
	let r = t.style;
	if (r && e !== null) {
		if (r.cell) return e === "" ? void 0 : {
			background: r.cell.bg,
			color: r.cell.color ?? (r.cell.bg ? "#1f2a37" : void 0)
		};
		if (r.map) {
			let t = r.map[String(e)];
			return t ? {
				background: t.bg,
				color: t.color ?? (t.bg ? "#1f2a37" : void 0)
			} : void 0;
		}
		if (r.breaks && r.colors) {
			let t = Number(e);
			if (!isFinite(t)) return;
			let n = 0;
			for (; n < r.breaks.length && t > r.breaks[n];) n++;
			return {
				background: r.colors[n],
				color: r.text?.[n] ?? "#1f2a37"
			};
		}
		if (r.bar) {
			let t = Number(e);
			if (!isFinite(t) || n <= 0) return;
			let i = Math.max(0, Math.min(100, 100 * t / n));
			return { backgroundImage: `linear-gradient(90deg, ${r.bar}33 ${i}%, transparent ${i}%)` };
		}
	}
}
var Rf = (e, t) => e === null ? 1 : t === null ? -1 : typeof e == "number" && typeof t == "number" ? e - t : String(e).localeCompare(String(t), void 0, {
	numeric: !0,
	sensitivity: "base"
});
function zf({ id: e, height: t, className: n, toolbar: r, searchable: i = !0, compact: a }) {
	let o = L(e);
	V(e);
	let s = Jd(e), c = Yd(e), l = qd(`${e}_rows_selected`, null, {
		debounceMs: 0,
		type: "tw.num"
	}), u = qd(`${e}_rows_all`, null, {
		debounceMs: 150,
		type: "tw.num"
	}), d = qd(`${e}_state`, null, { debounceMs: 250 }), f = qd(`${e}_cell_edit`, null, {
		debounceMs: 0,
		priority: "event"
	}), p = rf(), [m, h] = O(""), [g, _] = O(null), [v, y] = O(0), [b, x] = O(null), [S, C] = O([]), [w, ee] = O(null), T = o?.columns ?? [], te = b ?? o?.page_size ?? 15, ne = !!o?.server, re = o ? `${T.map((e) => e.key).join("|")}#${o.total}#${ne ? "" : o.index.slice(0, 50).join(",")}` : "", ie = D("");
	E(() => {
		if (!o || re === ie.current) return;
		let e = ie.current === "";
		ie.current = re, (!e || S.length) && (C([]), l(null)), ne || y(0);
	}, [re]), Xd(`${e}__select`, (e) => {
		let t = e.rows ?? [];
		C(t), l(t.length ? t : null);
	}), E(() => {
		ne && d({
			page: v,
			size: te,
			sort: g?.key ?? "",
			desc: !!g?.desc,
			search: m
		});
	}, [
		ne,
		v,
		te,
		g,
		m
	]);
	let ae = _e(() => {
		if (!o) return [];
		let e = o.rows.map((e, t) => ({
			cells: e,
			row: o.index[t]
		}));
		if (ne) return e;
		let t = m.trim().toLowerCase();
		if (t && (e = e.filter((e) => e.cells.some((e, n) => e !== null && (T[n].html ? String(e).replace(/<[^>]+>/g, "") : If(e, T[n])).toLowerCase().includes(t)))), g) {
			let t = T.findIndex((e) => e.key === g.key);
			t >= 0 && (e = [...e].sort((e, n) => (g.desc ? -1 : 1) * Rf(e.cells[t], n.cells[t])));
		}
		return e;
	}, [
		o,
		m,
		g,
		ne,
		T
	]), oe = ne ? "" : ae.map((e) => e.row).join(",");
	E(() => {
		o && !ne && u(ae.map((e) => e.row));
	}, [oe]);
	let se = ne ? o?.filtered ?? 0 : ae.length, ce = Math.max(1, Math.ceil(se / te)), le = ne ? o?.page ?? 0 : Math.min(v, ce - 1), ue = ne ? ae : ae.slice(le * te, le * te + te), de = _e(() => T.map((e, t) => e.style?.bar ? Math.max(0, ...(o?.rows ?? []).map((e) => Number(e[t]) || 0)) : 0), [o, T]);
	if (c?.message) return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-output-note",
		id: e,
		children: c.message
	});
	if (!o) return /* @__PURE__ */ (0, R.jsx)("div", {
		className: `tw-dt tw-dt-empty${s === "recalculating" ? " recalculating" : ""}`,
		id: e
	});
	let fe = o.selection, pe = (e) => {
		if (fe === "none") return;
		let t = fe === "single" ? S[0] === e ? [] : [e] : S.includes(e) ? S.filter((t) => t !== e) : [...S, e];
		C(t), l(t.length ? t : null);
	}, me = ue.map((e) => e.row), he = fe === "multiple" && me.length > 0 && me.every((e) => S.includes(e)), ge = () => {
		let e = he ? S.filter((e) => !me.includes(e)) : [.../* @__PURE__ */ new Set([...S, ...me])];
		C(e), l(e.length ? e : null);
	}, ve = (e) => {
		_((t) => t?.key === e ? t.desc ? null : {
			key: e,
			desc: !0
		} : {
			key: e,
			desc: !1
		}), y(0);
	}, ye = o.group ? T.findIndex((e) => e.key === o.group) : -1, be = T.filter((e, t) => t !== ye), xe = t ?? o.height ?? void 0, Se = () => {
		w && (f({
			row: w.row,
			col: w.col + 1,
			value: w.value,
			nonce: Date.now()
		}), ee(null));
	}, k;
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `tw-dt${a ? " tw-dt-compact" : ""}${s === "recalculating" ? " recalculating" : ""}${n ? " " + n : ""}`,
		id: e,
		children: [
			(i || r) && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-dt-top",
				children: [/* @__PURE__ */ (0, R.jsx)("div", {
					className: "d-flex align-items-center gap-2 flex-wrap",
					children: r
				}), i && /* @__PURE__ */ (0, R.jsxs)("label", {
					className: "tw-search",
					children: [/* @__PURE__ */ (0, R.jsx)(gi, { size: 13 }), /* @__PURE__ */ (0, R.jsx)("input", {
						type: "search",
						className: "form-control form-control-sm",
						placeholder: "Search",
						value: m,
						onChange: (e) => {
							h(e.target.value), y(0);
						}
					})]
				})]
			}),
			se ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-table-wrap",
				style: xe ? { maxHeight: xe } : void 0,
				children: /* @__PURE__ */ (0, R.jsxs)("table", {
					className: "table table-sm table-hover tw-table mb-0",
					children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [fe === "multiple" && /* @__PURE__ */ (0, R.jsx)("th", {
						className: "tw-dt-check",
						children: /* @__PURE__ */ (0, R.jsx)("input", {
							type: "checkbox",
							className: "form-check-input",
							checked: he,
							onChange: ge,
							"aria-label": "Select the rows of this page"
						})
					}), be.map((e) => /* @__PURE__ */ (0, R.jsxs)("th", {
						onClick: () => ve(e.key),
						className: e.type === "number" ? "text-end" : void 0,
						"aria-sort": g?.key === e.key ? g.desc ? "descending" : "ascending" : "none",
						"data-col": e.key,
						title: p.label(e.key) ?? void 0,
						children: [
							e.label,
							" ",
							g?.key === e.key && (g.desc ? /* @__PURE__ */ (0, R.jsx)(Ue, { size: 11 }) : /* @__PURE__ */ (0, R.jsx)(Ye, { size: 11 }))
						]
					}, e.key))] }) }), /* @__PURE__ */ (0, R.jsx)("tbody", { children: ue.map((e) => {
						let t = ye >= 0 && e.cells[ye] !== k;
						k = ye >= 0 ? e.cells[ye] : void 0;
						let n = S.includes(e.row);
						return [t ? /* @__PURE__ */ (0, R.jsx)("tr", {
							className: "tw-dt-group",
							children: /* @__PURE__ */ (0, R.jsx)("td", {
								colSpan: be.length + +(fe === "multiple"),
								children: If(e.cells[ye], T[ye])
							})
						}, `g${e.row}`) : null, /* @__PURE__ */ (0, R.jsxs)("tr", {
							className: n ? "tw-dt-selected" : void 0,
							onClick: () => pe(e.row),
							style: fe === "none" ? void 0 : { cursor: "pointer" },
							children: [fe === "multiple" && /* @__PURE__ */ (0, R.jsx)("td", {
								className: "tw-dt-check",
								children: /* @__PURE__ */ (0, R.jsx)("input", {
									type: "checkbox",
									className: "form-check-input",
									checked: n,
									onChange: () => pe(e.row),
									onClick: (e) => e.stopPropagation(),
									"aria-label": "Select"
								})
							}), T.map((t, n) => {
								if (n === ye) return null;
								let r = e.cells[n];
								if (w && w.row === e.row && w.col === n) return /* @__PURE__ */ (0, R.jsx)("td", {
									onClick: (e) => e.stopPropagation(),
									children: /* @__PURE__ */ (0, R.jsx)("input", {
										autoFocus: !0,
										className: "form-control form-control-sm",
										value: w.value,
										onChange: (e) => ee({
											...w,
											value: e.target.value
										}),
										onKeyDown: (e) => {
											e.key === "Enter" && Se(), e.key === "Escape" && ee(null);
										},
										onBlur: Se
									})
								}, t.key);
								let i = {
									key: t.key,
									style: Lf(r, t, de[n]),
									className: `${t.type === "number" ? "text-end" : ""}${t.editable ? " tw-dt-editable" : ""}`,
									title: t.editable ? "Double-click to edit" : void 0,
									onDoubleClick: t.editable ? (t) => {
										t.stopPropagation(), ee({
											row: e.row,
											col: n,
											value: r === null ? "" : String(r)
										});
									} : void 0
								};
								if (t.html) return /* @__PURE__ */ (0, R.jsx)("td", {
									...i,
									dangerouslySetInnerHTML: { __html: String(r ?? "") }
								});
								let a = n === +(ye === 0) && typeof r == "string" && p.isVar(r) ? p.label(r) : null;
								return /* @__PURE__ */ (0, R.jsxs)("td", {
									...i,
									children: [If(r, t), a ? /* @__PURE__ */ (0, R.jsx)("span", {
										className: "tw-opt-label d-block",
										children: a
									}) : null]
								});
							})]
						}, e.row)];
					}) })]
				})
			}) : /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-dt-none",
				children: m ? "No row matches." : o.empty ?? "No data."
			}),
			se > 0 && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-dt-foot",
				children: [/* @__PURE__ */ (0, R.jsxs)("span", { children: [
					le * te + 1,
					"-",
					Math.min(se, le * te + te),
					" of ",
					se.toLocaleString("en-US"),
					se < o.total ? ` (filtered from ${o.total.toLocaleString("en-US")})` : "",
					S.length ? ` · ${S.length} selected` : ""
				] }), /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "d-flex align-items-center gap-2",
					children: [/* @__PURE__ */ (0, R.jsx)("select", {
						className: "form-select form-select-sm tw-dt-size",
						value: te,
						onChange: (e) => {
							x(Number(e.target.value)), y(0);
						},
						"aria-label": "Rows per page",
						children: [
							10,
							15,
							25,
							50,
							100
						].map((e) => /* @__PURE__ */ (0, R.jsxs)("option", {
							value: e,
							children: [e, " rows"]
						}, e))
					}), /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "btn-group btn-group-sm",
						children: [/* @__PURE__ */ (0, R.jsx)("button", {
							type: "button",
							className: "btn btn-outline-secondary",
							disabled: le === 0,
							onClick: () => y(le - 1),
							"aria-label": "Previous page",
							children: /* @__PURE__ */ (0, R.jsx)(kt, { size: 14 })
						}), /* @__PURE__ */ (0, R.jsx)("button", {
							type: "button",
							className: "btn btn-outline-secondary",
							disabled: le >= ce - 1,
							onClick: () => y(le + 1),
							"aria-label": "Next page",
							children: /* @__PURE__ */ (0, R.jsx)(jt, { size: 14 })
						})]
					})]
				})]
			})
		]
	});
}
//#endregion
//#region src/lib/layout.tsx
k();
function Bf(e, t) {
	if (!e) return;
	let n = window.jQuery;
	n && n(e).trigger(t ? "shown" : "hidden"), t && window.setTimeout(() => window.dispatchEvent(new Event("resize")), 30);
}
function H({ title: e, icon: t, actions: n, children: r, className: i, bodyClassName: a, full: o = !1, help: s, style: c, footer: l }) {
	let [u, d] = O(!1), f = D(null);
	E(() => {
		window.dispatchEvent(new Event("resize"));
	}, [u]), E(() => {
		if (!u) return;
		let e = (e) => {
			e.key === "Escape" && d(!1);
		};
		return document.addEventListener("keydown", e), () => document.removeEventListener("keydown", e);
	}, [u]);
	let p = /* @__PURE__ */ (0, R.jsxs)("div", {
		ref: f,
		className: `card tw-card${u ? " tw-card-full" : ""}${i ? " " + i : ""}`,
		style: c,
		children: [
			(e || n || o) && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "card-header d-flex justify-content-between align-items-center gap-2 flex-wrap",
				children: [/* @__PURE__ */ (0, R.jsxs)("span", {
					className: "tw-card-title",
					children: [
						t,
						t ? " " : null,
						e,
						s ? /* @__PURE__ */ (0, R.jsx)("span", {
							className: "ms-1",
							children: s
						}) : null
					]
				}), /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "d-flex align-items-center gap-2 flex-wrap",
					children: [n, o && /* @__PURE__ */ (0, R.jsx)("button", {
						type: "button",
						className: "btn btn-sm tw-expand",
						onClick: () => d(!u),
						title: u ? "Close" : "Expand",
						"aria-label": u ? "Close" : "Expand",
						children: u ? /* @__PURE__ */ (0, R.jsx)(Mr, { size: 14 }) : /* @__PURE__ */ (0, R.jsx)(Ar, { size: 14 })
					})]
				})]
			}),
			/* @__PURE__ */ (0, R.jsx)("div", {
				className: `card-body${a ? " " + a : ""}`,
				children: r
			}),
			l ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "card-footer",
				children: l
			}) : null
		]
	});
	return u ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-card-backdrop",
		onClick: () => d(!1)
	}), p] }) : p;
}
function Vf({ sidebar: e, children: t, width: n = 300, className: r }) {
	let [i, a] = O(!0);
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `tw-sidebar-layout${i ? "" : " tw-side-closed"}${r ? " " + r : ""}`,
		style: { "--tw-side-w": `${n}px` },
		children: [
			/* @__PURE__ */ (0, R.jsx)("aside", {
				className: "tw-side",
				children: /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-side-scroll",
					children: e
				})
			}),
			/* @__PURE__ */ (0, R.jsx)("button", {
				type: "button",
				className: "tw-side-toggle",
				onClick: () => {
					a(!i), window.setTimeout(() => window.dispatchEvent(new Event("resize")), 250);
				},
				title: i ? "Hide the sidebar" : "Show the sidebar",
				"aria-label": i ? "Hide the sidebar" : "Show the sidebar",
				children: /* @__PURE__ */ (0, R.jsx)(Dt, {
					size: 14,
					style: { transform: i ? "rotate(90deg)" : "rotate(-90deg)" }
				})
			}),
			/* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-side-main",
				children: t
			})
		]
	});
}
function Hf({ steps: e, open: t }) {
	let [n, r] = O(t ?? e[0]?.key ?? null), i = D({});
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-steps",
		children: e.map((e) => {
			let t = n === e.key;
			return /* @__PURE__ */ (0, R.jsxs)("section", {
				className: `tw-step${t ? " open" : ""}`,
				children: [/* @__PURE__ */ (0, R.jsxs)("button", {
					type: "button",
					className: "tw-step-head",
					"aria-expanded": t,
					onClick: () => {
						let n = t ? null : e.key;
						r(n), n && Bf(i.current[n], !0);
					},
					children: [
						/* @__PURE__ */ (0, R.jsxs)("span", {
							className: "tw-step-title",
							children: [
								e.icon,
								e.icon ? " " : null,
								e.title
							]
						}),
						!t && e.summary ? /* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-step-summary",
							children: e.summary
						}) : null,
						/* @__PURE__ */ (0, R.jsx)(Dt, {
							size: 14,
							className: "tw-step-chev"
						})
					]
				}), /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-step-body",
					ref: (t) => {
						i.current[e.key] = t;
					},
					style: { display: t ? void 0 : "none" },
					children: e.content
				})]
			}, e.key);
		})
	});
}
function Uf({ children: e }) {
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-side-actions",
		children: e
	});
}
function Wf(e) {
	return e.id ? /* @__PURE__ */ (0, R.jsx)(Kf, {
		...e,
		id: e.id
	}) : /* @__PURE__ */ (0, R.jsx)(Gf, { ...e });
}
function Gf(e) {
	let [t, n] = O(e.value ?? e.tabs.filter((e) => !e.hidden)[0]?.value ?? "");
	return /* @__PURE__ */ (0, R.jsx)(qf, {
		...e,
		cur: t,
		set: (t) => {
			n(t), e.onChange?.(t);
		}
	});
}
function Kf(e) {
	let [t, n] = Kd(e.id, e.value ?? e.tabs.filter((e) => !e.hidden)[0]?.value ?? "", { debounceMs: 0 }), r = (t) => {
		n(t), e.onChange?.(t);
	};
	return uf(e.id, (e) => {
		e.value !== void 0 && e.value !== null && r(String(Array.isArray(e.value) ? e.value[0] : e.value));
	}), /* @__PURE__ */ (0, R.jsx)(qf, {
		...e,
		cur: t,
		set: r
	});
}
function qf({ tabs: e, className: t, pills: n, cur: r, set: i }) {
	let a = e.filter((e) => !e.hidden), o = a.some((e) => e.value === r) ? r : a[0]?.value, s = D({});
	return E(() => {
		for (let t of e) Bf(s.current[t.value], t.value === o);
	}, [o]), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `tw-tabs${t ? " " + t : ""}`,
		children: [/* @__PURE__ */ (0, R.jsx)("ul", {
			className: `nav ${n ? "nav-pills" : "nav-underline"} tw-tabs-nav`,
			role: "tablist",
			children: a.map((e) => /* @__PURE__ */ (0, R.jsx)("li", {
				className: "nav-item",
				role: "presentation",
				children: /* @__PURE__ */ (0, R.jsxs)("button", {
					type: "button",
					role: "tab",
					"aria-selected": e.value === o,
					className: `nav-link${e.value === o ? " active" : ""}`,
					onClick: () => i(e.value),
					children: [
						e.icon,
						e.icon ? " " : null,
						e.label
					]
				})
			}, e.value))
		}), e.map((e) => /* @__PURE__ */ (0, R.jsx)("div", {
			ref: (t) => {
				s.current[e.value] = t;
			},
			role: "tabpanel",
			className: "tw-tab-panel",
			style: { display: e.value === o ? void 0 : "none" },
			children: e.content
		}, e.value))]
	});
}
function Jf({ kind: e = "info", children: t, className: n }) {
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `tw-notice tw-notice-${e}${n ? " " + n : ""}`,
		role: e === "danger" ? "alert" : void 0,
		children: [e === "info" ? /* @__PURE__ */ (0, R.jsx)(ir, { size: 15 }) : /* @__PURE__ */ (0, R.jsx)(na, { size: 15 }), /* @__PURE__ */ (0, R.jsx)("div", { children: t })]
	});
}
function Yf({ open: e, onClose: t, title: n, children: r, footer: i, size: a = "lg" }) {
	return E(() => {
		if (!e) return;
		let n = (e) => {
			e.key === "Escape" && t();
		};
		return document.addEventListener("keydown", n), () => document.removeEventListener("keydown", n);
	}, [e, t]), e ? (0, tc.createPortal)(/* @__PURE__ */ (0, R.jsx)("div", {
		className: "modal tw-dialog-backdrop",
		role: "presentation",
		onMouseDown: (e) => {
			e.target === e.currentTarget && t();
		},
		children: /* @__PURE__ */ (0, R.jsx)("div", {
			className: `modal-dialog modal-${a} modal-dialog-scrollable tw-dialog`,
			role: "dialog",
			"aria-modal": "true",
			children: /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "modal-content",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "modal-header",
						children: [/* @__PURE__ */ (0, R.jsx)("h5", {
							className: "modal-title",
							children: n
						}), /* @__PURE__ */ (0, R.jsx)("button", {
							type: "button",
							className: "btn-close",
							onClick: t,
							"aria-label": "Close"
						})]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "modal-body",
						children: r
					}),
					i ? /* @__PURE__ */ (0, R.jsx)("div", {
						className: "modal-footer",
						children: i
					}) : null
				]
			})
		})
	}), document.body) : null;
}
//#endregion
//#region src/pages/audit/AuditPage.tsx
var Xf = (e) => `audit_1-${e}`, Zf = [
	"All",
	"Design",
	"Selection",
	"Monitoring",
	"Session"
];
function Qf({ t: e }) {
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-audit p-3 w-100",
		children: /* @__PURE__ */ (0, R.jsxs)(H, {
			title: e("Audit trail"),
			icon: /* @__PURE__ */ (0, R.jsx)(ni, { size: 15 }),
			actions: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(_f, {
				id: Xf("phase"),
				choices: Zf.map((t) => ({
					value: t,
					label: e(t)
				})),
				value: "All",
				buttons: !0,
				className: "mb-0"
			}), /* @__PURE__ */ (0, R.jsx)(bf, {
				id: Xf("download_full_log"),
				label: e("Export"),
				icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 14 })
			})] }),
			children: [/* @__PURE__ */ (0, R.jsx)("p", {
				className: "small text-muted mb-2",
				children: e("Every change to the data and every decision, across the three phases: who, when, what and why.")
			}), /* @__PURE__ */ (0, R.jsx)(zf, { id: Xf("tab_mod_log") })]
		})
	});
}
//#endregion
//#region src/pages/audit/index.tsx
var $f = /* @__PURE__ */ n({
	default: () => Qf,
	page: () => ep
}), ep = "modif_logs", tp = "Which part of the data this analysis covers. Households outside these areas are left out of the analysis entirely (they are not counted as not selected), and the reports say which areas are covered.";
function np({ ns: e, title: t = "Areas covered", t: n = (e) => e }) {
	let r = (t) => `${e}-${t}`, i = (e, t) => /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-scope-level",
		children: [/* @__PURE__ */ (0, R.jsx)(z, {
			id: r(`col${e}`),
			label: n(`${t} column`),
			choices: [{
				value: "",
				label: n("(none)")
			}],
			value: "",
			clearable: !1
		}), /* @__PURE__ */ (0, R.jsx)(z, {
			id: r(`val${e}`),
			choices: [],
			multiple: !0,
			actions: !0,
			placeholder: n("All areas"),
			className: "tw-scope-values"
		})]
	}, e);
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-scope",
		children: [
			t ? /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-scope-head",
				children: [
					/* @__PURE__ */ (0, R.jsx)(Er, {
						size: 15,
						"aria-hidden": !0
					}),
					" ",
					n(t),
					/* @__PURE__ */ (0, R.jsx)("span", {
						className: "tw-scope-tip",
						title: n(tp),
						"aria-label": n(tp),
						children: /* @__PURE__ */ (0, R.jsx)(ir, { size: 13 })
					})
				]
			}) : /* @__PURE__ */ (0, R.jsx)("p", {
				className: "small text-muted mb-2",
				children: n("Leave empty to cover every area. Records outside the chosen areas are left out of this analysis and its report.")
			}),
			i(1, "First level"),
			i(2, "Second level"),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "d-flex gap-2",
				children: [/* @__PURE__ */ (0, R.jsx)(B, {
					id: r("apply"),
					label: n("Apply areas"),
					icon: /* @__PURE__ */ (0, R.jsx)(Rn, { size: 14 }),
					className: "flex-fill"
				}), /* @__PURE__ */ (0, R.jsx)(B, {
					id: r("clear"),
					icon: /* @__PURE__ */ (0, R.jsx)(Ma, { size: 14 }),
					variant: "outline-secondary",
					title: n("All areas")
				})]
			}),
			/* @__PURE__ */ (0, R.jsx)("div", {
				className: "small text-muted mt-1",
				children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: r("status") })
			})
		]
	});
}
//#endregion
//#region src/components/ModaImport.tsx
function rp({ ns: e, label: t = "Import from a server", variant: n = "outline-secondary", block: r = !0, size: i = "md", t: a = (e) => e }) {
	return /* @__PURE__ */ (0, R.jsx)(B, {
		id: `${e}-btn_open_moda`,
		label: a(t),
		icon: /* @__PURE__ */ (0, R.jsx)(tn, { size: 15 }),
		variant: n,
		size: i,
		className: r ? "w-100" : void 0,
		title: a("Import from a MODA / ONA form")
	});
}
//#endregion
//#region src/components/VarCalc.tsx
function ip({ ns: e, label: t = "Variable calculator", variant: n = "outline-secondary", block: r, size: i = "sm", t: a = (e) => e }) {
	return /* @__PURE__ */ (0, R.jsx)(B, {
		id: `${e}-open`,
		label: a(t),
		icon: /* @__PURE__ */ (0, R.jsx)(st, { size: 15 }),
		variant: n,
		size: i,
		className: r ? "w-100" : void 0
	});
}
function ap({ ns: e, label: t = "Binarise variables", variant: n = "outline-secondary", block: r, size: i = "sm", t: a = (e) => e }) {
	return /* @__PURE__ */ (0, R.jsx)(B, {
		id: `${e}-open_bulk`,
		label: a(t),
		icon: /* @__PURE__ */ (0, R.jsx)(Aa, { size: 15 }),
		variant: n,
		size: i,
		className: r ? "w-100" : void 0
	});
}
//#endregion
//#region src/components/DataSummary.tsx
k();
var op = [
	{
		key: "category",
		label: "Categories",
		one: "Category",
		Icon: gr
	},
	{
		key: "number",
		label: "Numbers",
		one: "Number",
		Icon: Jn
	},
	{
		key: "date",
		label: "Dates",
		one: "Date",
		Icon: ht
	},
	{
		key: "text",
		label: "Text",
		one: "Text",
		Icon: ca
	},
	{
		key: "id",
		label: "Identifiers",
		one: "Identifier",
		Icon: Mn
	},
	{
		key: "empty",
		label: "Empty",
		one: "Empty",
		Icon: Bi
	}
], sp = 40, cp = (e, t = 2) => e == null || !isFinite(e) ? "–" : Math.abs(e) >= 1e3 ? Math.round(e).toLocaleString("en-US") : Number(e.toFixed(t)).toLocaleString("en-US"), lp = (e) => `${(100 * e).toFixed(+(e > 0 && e < .01))}%`;
function up({ ns: e, label: t = "Data summary", variant: n = "outline-secondary", block: r, className: i, t: a = (e) => e }) {
	let [o, s] = O(null), c = L(`${e}-summary`);
	return Xd(`${e}-show`, (e) => s((e?.n ?? 1) - 1)), /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(B, {
		id: `${e}-open`,
		label: a(t),
		icon: /* @__PURE__ */ (0, R.jsx)(yt, { size: 15 }),
		variant: n,
		className: [r ? "w-100" : "", i ?? ""].join(" ").trim() || void 0,
		title: a("Every variable: its type, missing values, categories or distribution"),
		onClick: () => s(c?.n ?? 0)
	}), o !== null && /* @__PURE__ */ (0, R.jsx)(dp, {
		ns: e,
		after: o,
		t: a,
		onClose: () => s(null)
	})] });
}
function dp({ ns: e, after: t, t: n, onClose: r }) {
	let i = L(`${e}-summary`);
	pp();
	let [a, o] = O(""), [s, c] = O("all"), [l, u] = O(sp), d = !!i && i.n > t, f = _e(() => {
		let e = a.trim().toLowerCase();
		return (i?.vars ?? []).filter((t) => (s === "all" || t.kind === s) && (!e || t.name.toLowerCase().includes(e) || (t.label ?? "").toLowerCase().includes(e)));
	}, [
		i,
		a,
		s
	]), p = (e) => (i?.vars ?? []).filter((t) => t.kind === e).length;
	return /* @__PURE__ */ (0, R.jsx)(Yf, {
		open: !0,
		onClose: r,
		size: "xl",
		title: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
			/* @__PURE__ */ (0, R.jsx)(yt, { size: 18 }),
			" ",
			n("Data summary"),
			d && i?.title ? /* @__PURE__ */ (0, R.jsxs)("span", {
				className: "tw-ds-sub",
				children: [
					" ",
					"·",
					" ",
					n(i.title)
				]
			}) : null
		] }),
		footer: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(bf, {
			id: `${e}-download`,
			label: n("Export (Excel)")
		}), /* @__PURE__ */ (0, R.jsx)("button", {
			type: "button",
			className: "btn btn-outline-secondary btn-sm",
			onClick: r,
			children: n("Close")
		})] }),
		children: d ? i.empty ? /* @__PURE__ */ (0, R.jsx)("div", {
			className: "tw-ds-wait",
			children: n("No data loaded yet.")
		}) : /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ds-head",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("span", {
						className: "tw-ds-size",
						children: [
							/* @__PURE__ */ (0, R.jsx)("strong", { children: (i.rows ?? 0).toLocaleString("en-US") }),
							" ",
							n("rows"),
							" ",
							"·",
							" ",
							/* @__PURE__ */ (0, R.jsx)("strong", { children: i.cols }),
							" ",
							n("variables")
						]
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-ds-chips",
						role: "group",
						"aria-label": n("Type"),
						children: [/* @__PURE__ */ (0, R.jsxs)("button", {
							type: "button",
							className: `tw-ds-chip${s === "all" ? " on" : ""}`,
							onClick: () => {
								c("all"), u(sp);
							},
							children: [
								n("All"),
								" ",
								i.cols
							]
						}), op.filter((e) => p(e.key) > 0).map((e) => /* @__PURE__ */ (0, R.jsxs)("button", {
							type: "button",
							className: `tw-ds-chip${s === e.key ? " on" : ""}`,
							onClick: () => {
								c(e.key), u(sp);
							},
							children: [
								/* @__PURE__ */ (0, R.jsx)(e.Icon, { size: 12 }),
								" ",
								n(e.label),
								" ",
								p(e.key)
							]
						}, e.key))]
					}),
					/* @__PURE__ */ (0, R.jsxs)("label", {
						className: "tw-search",
						children: [/* @__PURE__ */ (0, R.jsx)(gi, { size: 13 }), /* @__PURE__ */ (0, R.jsx)("input", {
							type: "search",
							className: "form-control form-control-sm",
							placeholder: n("Find a variable"),
							value: a,
							onChange: (e) => {
								o(e.target.value), u(sp);
							}
						})]
					})
				]
			}),
			f.length ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-ds-grid",
				children: f.slice(0, l).map((e) => /* @__PURE__ */ (0, R.jsx)(fp, {
					v: e,
					rows: i.rows ?? 0,
					t: n
				}, e.name))
			}) : /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-ds-wait",
				children: n("No variable matches.")
			}),
			f.length > l && /* @__PURE__ */ (0, R.jsx)("div", {
				className: "text-center mt-2",
				children: /* @__PURE__ */ (0, R.jsxs)("button", {
					type: "button",
					className: "btn btn-outline-secondary btn-sm",
					onClick: () => u(l + sp),
					children: [
						n("Show more"),
						" (",
						f.length - l,
						")"
					]
				})
			})
		] }) : /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-ds-wait",
			children: [
				/* @__PURE__ */ (0, R.jsx)("span", { className: "spinner-border spinner-border-sm" }),
				" ",
				n("Summarising the data...")
			]
		})
	});
}
function fp({ v: e, rows: t, t: n }) {
	let r = op.find((t) => t.key === e.kind), i = t - e.missing;
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `tw-ds-card kind-${e.kind}`,
		children: [
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ds-card-head",
				children: [/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-ds-name",
					children: [/* @__PURE__ */ (0, R.jsx)("span", {
						className: "tw-ds-var",
						title: e.name,
						children: e.name
					}), e.label ? /* @__PURE__ */ (0, R.jsx)("span", {
						className: "tw-ds-label",
						title: e.label,
						children: e.label
					}) : null]
				}), /* @__PURE__ */ (0, R.jsxs)("span", {
					className: "tw-ds-kind",
					children: [
						/* @__PURE__ */ (0, R.jsx)(r.Icon, { size: 11 }),
						" ",
						n(r.one)
					]
				})]
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ds-meta",
				children: [/* @__PURE__ */ (0, R.jsxs)("span", {
					title: n("Missing values"),
					children: [/* @__PURE__ */ (0, R.jsx)("span", {
						className: `tw-ds-miss${e.missing_pct > .2 ? " high" : e.missing_pct > .05 ? " mid" : ""}`,
						children: /* @__PURE__ */ (0, R.jsx)("span", { style: { width: `${Math.min(100, 100 * e.missing_pct)}%` } })
					}), e.missing ? `${lp(e.missing_pct)} ${n("missing")}` : n("no missing value")]
				}), e.kind !== "empty" && /* @__PURE__ */ (0, R.jsxs)("span", { children: [
					e.distinct.toLocaleString("en-US"),
					" ",
					n("distinct")
				] })]
			}),
			e.kind === "category" && e.levels && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ds-levels",
				children: [e.levels.map((e) => /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-ds-level",
					title: `${e.value}: ${e.n.toLocaleString("en-US")} (${lp(i ? e.n / i : 0)})`,
					children: [
						/* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-ds-lv",
							children: e.value
						}),
						/* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-ds-bar",
							children: /* @__PURE__ */ (0, R.jsx)("span", { style: { width: `${i ? 100 * e.n / i : 0}%` } })
						}),
						/* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-ds-n",
							children: lp(i ? e.n / i : 0)
						})
					]
				}, e.value)), e.other ? /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-ds-other",
					children: [
						n("Other values"),
						": ",
						e.other.toLocaleString("en-US"),
						" (",
						lp(i ? e.other / i : 0),
						")"
					]
				}) : null]
			}),
			(e.kind === "number" || e.kind === "date") && e.hist && /* @__PURE__ */ (0, R.jsx)(hp, { h: e.hist }),
			e.kind === "number" && e.stats && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ds-stats",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("span", { children: [
						/* @__PURE__ */ (0, R.jsx)("em", { children: n("min") }),
						" ",
						cp(e.stats.min)
					] }),
					/* @__PURE__ */ (0, R.jsxs)("span", { children: [
						/* @__PURE__ */ (0, R.jsx)("em", { children: n("median") }),
						" ",
						cp(e.stats.median)
					] }),
					/* @__PURE__ */ (0, R.jsxs)("span", { children: [
						/* @__PURE__ */ (0, R.jsx)("em", { children: n("mean") }),
						" ",
						cp(e.stats.mean)
					] }),
					/* @__PURE__ */ (0, R.jsxs)("span", { children: [
						/* @__PURE__ */ (0, R.jsx)("em", { children: n("max") }),
						" ",
						cp(e.stats.max)
					] }),
					/* @__PURE__ */ (0, R.jsxs)("span", { children: [
						/* @__PURE__ */ (0, R.jsx)("em", { children: n("SD") }),
						" ",
						cp(e.stats.sd ?? null)
					] })
				]
			}),
			e.kind === "date" && e.range && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ds-stats",
				children: [/* @__PURE__ */ (0, R.jsxs)("span", { children: [
					/* @__PURE__ */ (0, R.jsx)("em", { children: n("from") }),
					" ",
					mp(e.range[0])
				] }), /* @__PURE__ */ (0, R.jsxs)("span", { children: [
					/* @__PURE__ */ (0, R.jsx)("em", { children: n("to") }),
					" ",
					mp(e.range[1])
				] })]
			}),
			(e.kind === "text" || e.kind === "id") && e.top && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ds-top",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("span", {
						className: "text-muted",
						children: [e.kind === "id" ? n("Nearly every value differs, e.g.") : n("Most frequent"), ":"]
					}),
					" ",
					e.top.map((t) => `${t.value}${e.kind === "text" ? ` (${t.n.toLocaleString("en-US")})` : ""}`).join(", ")
				]
			}),
			e.kind === "empty" && /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-ds-top text-muted",
				children: n("No value in any row.")
			})
		]
	});
}
function pp() {
	let e = D(null);
	E(() => {
		try {
			let t = document.querySelector(".modal.show:not(.tw-dialog-backdrop)"), n = window.bootstrap, r = t && n?.Modal?.getInstance(t);
			r?._focustrap && (r._focustrap.deactivate(), e.current = r._focustrap);
		} catch {}
		return () => {
			try {
				e.current?.activate();
			} catch {}
		};
	}, []);
}
var mp = (e) => {
	let t = /^(\d{4})-(\d{2})-(\d{2})/.exec(e);
	return t ? `${t[3]}/${t[2]}/${t[1]}` : e;
};
function hp({ h: e }) {
	let t = Math.max(1, ...e.counts), n = e.counts.length, r = (t) => e.date ? `${mp(String(e.edges[t]))} – ${mp(String(e.edges[t + 1] ?? e.edges[t]))}` : `${cp(Number(e.edges[t]))} – ${cp(Number(e.edges[t + 1] ?? e.edges[t]))}`;
	return /* @__PURE__ */ (0, R.jsx)("svg", {
		className: "tw-ds-spark",
		viewBox: `0 0 ${n * 10} 40`,
		preserveAspectRatio: "none",
		role: "img",
		"aria-label": "Distribution",
		children: e.counts.map((e, n) => /* @__PURE__ */ (0, R.jsx)("rect", {
			x: n * 10 + 1,
			width: 8,
			y: 40 - 38 * e / t,
			height: 38 * e / t,
			children: /* @__PURE__ */ (0, R.jsx)("title", { children: `${r(n)}: ${e.toLocaleString("en-US")}` })
		}, n))
	});
}
//#endregion
//#region src/lib/chart.tsx
k();
var gp = [
	"#0A6EB4",
	"#26bde2",
	"#f7b825",
	"#3f7e44",
	"#c5192d",
	"#8a96a3",
	"#5b6b7c",
	"#7fb3d5",
	"#fbd679",
	"#8bc28f"
];
function _p(e) {
	let t = e ? "#c9d1dc" : "#5b6b7c", n = e ? "#e8edf3" : "#1f2a37", r = "rgba(128,128,128,0.2)", i = {
		axisLine: { lineStyle: { color: r } },
		axisTick: { show: !1 },
		axisLabel: {
			color: t,
			fontSize: 10
		},
		splitLine: { lineStyle: { color: r } },
		nameTextStyle: {
			color: t,
			fontSize: 11
		}
	};
	return {
		color: gp,
		backgroundColor: "transparent",
		textStyle: {
			fontFamily: "Commissioner, system-ui, sans-serif",
			color: t
		},
		title: { textStyle: {
			color: n,
			fontSize: 13,
			fontWeight: 600
		} },
		legend: {
			textStyle: {
				color: t,
				fontSize: 11
			},
			itemWidth: 10,
			itemHeight: 10,
			icon: "roundRect"
		},
		tooltip: {
			backgroundColor: "#1f2a37",
			borderWidth: 0,
			textStyle: {
				color: "#fff",
				fontSize: 12
			},
			extraCssText: "border-radius:6px;box-shadow:0 4px 14px rgba(0,0,0,.25);"
		},
		categoryAxis: {
			...i,
			splitLine: { show: !1 }
		},
		valueAxis: i,
		timeAxis: i,
		logAxis: i,
		bar: {
			itemStyle: { borderRadius: 2 },
			label: {
				color: t,
				textBorderWidth: 0,
				textBorderColor: "transparent"
			}
		},
		line: {
			symbolSize: 5,
			lineStyle: { width: 2 },
			label: {
				color: t,
				textBorderWidth: 0,
				textBorderColor: "transparent"
			}
		},
		scatter: { label: {
			color: t,
			textBorderWidth: 0,
			textBorderColor: "transparent"
		} },
		boxplot: { itemStyle: {
			color: e ? "rgba(10,110,180,.25)" : "rgba(10,110,180,.12)",
			borderColor: "#0A6EB4"
		} },
		pie: {
			itemStyle: {
				borderColor: e ? "#10233b" : "#fff",
				borderWidth: 1
			},
			label: {
				color: t,
				textBorderWidth: 0
			}
		}
	};
}
var vp = null;
function yp() {
	return vp ??= import("./chunks/echarts-core-DmGpb3fQ.js").then(({ default: e }) => (e.registerTheme("tw-light", _p(!1)), e.registerTheme("tw-dark", _p(!0)), e)), vp;
}
var bp = (e) => {
	if (typeof e == "number") return e;
	if (e && typeof e == "object") {
		let t = e.value ?? e.data;
		return Array.isArray(t) ? Number(t[t.length - 1]) : bp(t);
	}
	return Number(e);
}, xp = (e) => (t) => {
	let n = bp(t);
	return isFinite(n) ? `${(100 * n).toFixed(e)}%` : "";
}, Sp = (e) => {
	let t = e.data;
	if (t && typeof t == "object" && t.tip) return t.tip;
	let n = Array.isArray(e.value) ? e.value[e.value.length - 1] : e.value;
	return `${e.marker ?? ""}${e.seriesName ? e.seriesName + ": " : ""}${e.name ? e.name + " " : ""}<b>${typeof n == "number" ? n.toLocaleString("en-US", { maximumFractionDigits: 2 }) : n ?? ""}</b>`;
}, Cp = {
	pct: xp(0),
	pct1: xp(1),
	num: (e) => {
		let t = bp(e);
		return isFinite(t) ? Math.round(t).toLocaleString("en-US") : "";
	},
	dec1: (e) => {
		let t = bp(e);
		return isFinite(t) ? t.toFixed(1) : "";
	},
	dec2: (e) => {
		let t = bp(e);
		return isFinite(t) ? t.toFixed(2) : "";
	},
	hmap: (e) => {
		let t = e.value, n = Array.isArray(t) ? Number(t[2]) : bp(e);
		return isFinite(n) ? Math.abs(n) < 10 ? n.toFixed(2) : Math.round(n).toLocaleString("en-US") : "";
	},
	tip: (e) => Array.isArray(e) ? e.map(Sp).join("<br>") : Sp(e)
};
function wp(e) {
	return typeof e == "string" && e.startsWith("fn:") ? Cp[e.slice(3)] ?? e : Array.isArray(e) ? e.map(wp) : e && typeof e == "object" ? Object.fromEntries(Object.entries(e).map(([e, t]) => [e, wp(t)])) : e;
}
function Tp(e) {
	let t = Array.isArray(e.series) ? e.series : e.series ? [e.series] : [];
	if (!t.some((e) => e?.type === "bar")) return e;
	let n = (t) => Array.isArray(e[t]) ? e[t] : e[t] ? [e[t]] : [], r = [...n("xAxis"), ...n("yAxis")].find((e) => e?.type === "category"), i = (e) => (r?.data ?? e.data ?? []).length, a = (e) => e <= 2 ? 90 : e <= 4 ? 72 : e <= 7 ? 54 : e <= 12 ? 38 : e <= 20 ? 26 : e <= 35 ? 16 : 10, o = (e) => e <= 4 ? "30%" : e <= 20 ? "22%" : "12%", s = t.map((e) => {
		if (e?.type !== "bar" || e.barWidth !== void 0 || e.barCategoryGap === 0 || e.barCategoryGap === "0%") return e;
		let t = Math.max(1, i(e)), n = {
			...e,
			barMaxWidth: a(t)
		};
		return e.barCategoryGap === void 0 && (n.barCategoryGap = o(t)), n;
	});
	return {
		...e,
		series: s
	};
}
function Ep() {
	let e = () => document.documentElement.getAttribute("data-bs-theme") === "dark", [t, n] = O(e);
	return E(() => {
		let t = new MutationObserver(() => n(e()));
		return t.observe(document.documentElement, {
			attributes: !0,
			attributeFilter: ["data-bs-theme"]
		}), () => t.disconnect();
	}, []), t;
}
function Dp({ option: e, height: t = 320, className: n }) {
	let r = D(null), i = D(null), [a, o] = O(0), s = Ep();
	return E(() => {
		let e = !1, t = null;
		return yp().then((n) => {
			if (e || !r.current) return;
			let a = n.init(r.current, s ? "tw-dark" : "tw-light", { renderer: "canvas" });
			i.current = a, t = new ResizeObserver(() => {
				r.current && r.current.offsetWidth > 0 && a.resize();
			}), t.observe(r.current), o((e) => e + 1);
		}), () => {
			e = !0, t?.disconnect(), i.current?.dispose(), i.current = null;
		};
	}, [s]), E(() => {
		i.current && e && i.current.setOption(wp(Tp({
			animationDuration: 300,
			...e
		})), { notMerge: !0 });
	}, [e, a]), /* @__PURE__ */ (0, R.jsx)("div", {
		ref: r,
		className: `tw-echart${n ? " " + n : ""}`,
		style: {
			height: t,
			width: "100%"
		}
	});
}
function U({ id: e, height: t, className: n }) {
	let r = L(e);
	V(e);
	let i = Yd(e), a = Jd(e), o = r?.height ?? t ?? 320;
	return i?.message ? /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-output-note",
		id: e,
		children: i.message
	}) : /* @__PURE__ */ (0, R.jsx)("div", {
		id: e,
		className: `tw-chart-holder${a === "recalculating" ? " recalculating" : ""}`,
		children: r?.option ? /* @__PURE__ */ (0, R.jsx)(Dp, {
			option: r.option,
			height: o,
			className: n
		}) : /* @__PURE__ */ (0, R.jsx)("div", { style: { height: typeof o == "number" ? o : 120 } })
	});
}
//#endregion
//#region src/pages/design/shared.tsx
k();
var Op = "scorecard_1-", W = (e) => Op + e, kp = (e) => {
	if (typeof e == "number") return e;
	if (e && typeof e == "object") {
		let t = e.value;
		return Array.isArray(t) ? Number(t[t.length - 1]) : kp(t);
	}
	return Number(e);
};
Cp.pctv = (e) => {
	let t = kp(e);
	return isFinite(t) ? `${Math.round(t)}%` : "";
}, Cp.abspctv = (e) => {
	let t = kp(e);
	return isFinite(t) ? `${Math.round(Math.abs(t))}%` : "";
};
var G = (e) => typeof e == "number" && isFinite(e), Ap = (e) => G(e) ? `${Math.round(100 * e)}%` : "–", jp = (e) => G(e) ? Math.round(e).toLocaleString("en-US") : "–", Mp = (e) => G(e) ? String(Math.round(e * 1e5) / 1e5) : "–", Np = (e) => G(e) ? e > 9999 ? "> 9999" : e > 0 && e < 1e-4 ? "< 0.0001" : String(Math.round(e * 1e4) / 1e4) : "–", Pp = (e) => G(e) ? e < .001 ? "p001" : e < .01 ? "p01" : e < .05 ? "p05" : e < .1 ? "p10" : "ns" : "na";
function Fp({ p: e }) {
	return /* @__PURE__ */ (0, R.jsx)("span", {
		className: `wfp-p wfp-p-${Pp(e)}`,
		children: G(e) ? e < .001 ? "<0.001" : e.toFixed(3) : "-"
	});
}
function Ip({ t: e }) {
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "wfp-p-legend small text-muted",
		children: [
			e("p-value:"),
			" ",
			/* @__PURE__ */ (0, R.jsx)("span", {
				className: "wfp-p wfp-p-p001",
				children: "<0.001"
			}),
			/* @__PURE__ */ (0, R.jsx)("span", {
				className: "wfp-p wfp-p-p01",
				children: "<0.01"
			}),
			/* @__PURE__ */ (0, R.jsx)("span", {
				className: "wfp-p wfp-p-p05",
				children: "<0.05"
			}),
			/* @__PURE__ */ (0, R.jsx)("span", {
				className: "wfp-p wfp-p-p10",
				children: "<0.10"
			}),
			/* @__PURE__ */ (0, R.jsxs)("span", {
				className: "wfp-p wfp-p-ns",
				children: ["≥", "0.10"]
			})
		]
	});
}
function Lp({ d: e, t }) {
	if (!e) return /* @__PURE__ */ (0, R.jsx)("span", {
		className: "text-muted",
		children: "-"
	});
	let n = e === "inclusion";
	return /* @__PURE__ */ (0, R.jsx)("span", {
		className: `wfp-dir ${n ? "is-incl" : "is-excl"}`,
		title: t(e),
		children: t(n ? "Incl" : "Excl")
	});
}
function Rp({ or: e, lo: t, hi: n }) {
	if (!G(e)) return /* @__PURE__ */ (0, R.jsx)("span", {
		className: "text-muted",
		children: "-"
	});
	let r = (e) => 100 * (Math.min(Math.max(Math.log10(e), -1), 1) + 1) / 2;
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "wfp-or",
		children: [/* @__PURE__ */ (0, R.jsxs)("div", {
			className: "wfp-or-num",
			children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: Np(e) }), G(t) && G(n) ? /* @__PURE__ */ (0, R.jsxs)("span", {
				className: "wfp-or-ci",
				children: [
					" (",
					Np(t),
					"–",
					Np(n),
					")"
				]
			}) : null]
		}), /* @__PURE__ */ (0, R.jsxs)("div", {
			className: `wfp-or-track ${e >= 1 ? "is-incl" : "is-excl"}`,
			children: [
				/* @__PURE__ */ (0, R.jsx)("span", { className: "wfp-or-one" }),
				G(t) && G(n) ? /* @__PURE__ */ (0, R.jsx)("span", {
					className: "wfp-or-whisker",
					style: {
						left: `${r(t).toFixed(1)}%`,
						width: `${Math.max(r(n) - r(t), .5).toFixed(1)}%`
					}
				}) : null,
				/* @__PURE__ */ (0, R.jsx)("span", {
					className: "wfp-or-dot",
					style: { left: `${r(e).toFixed(1)}%` }
				})
			]
		})]
	});
}
function K({ when: e, children: t, as: n = "div", className: r, style: i }) {
	return /* @__PURE__ */ (0, R.jsx)(n, {
		className: r ?? (n === "div" ? "sc-stack" : void 0),
		style: e ? i : {
			...i,
			display: "none"
		},
		children: t
	});
}
function q({ children: e, label: t = "More information", className: n }) {
	let r = D(null), [i, a] = O(null), o = () => {
		let e = r.current?.getBoundingClientRect();
		e && a({
			x: Math.min(Math.max(e.left + e.width / 2, 170), window.innerWidth - 170),
			y: e.top > 220 ? e.top - 6 : e.bottom + 6,
			below: e.top <= 220
		});
	};
	return /* @__PURE__ */ (0, R.jsxs)("span", {
		ref: r,
		className: `sc-tip${n ? " " + n : ""}`,
		tabIndex: 0,
		"aria-label": t,
		role: "button",
		onMouseEnter: o,
		onMouseLeave: () => a(null),
		onFocus: o,
		onBlur: () => a(null),
		onClick: (e) => e.stopPropagation(),
		children: [/* @__PURE__ */ (0, R.jsx)(ir, { size: 13 }), i ? (0, tc.createPortal)(/* @__PURE__ */ (0, R.jsx)("div", {
			className: `sc-tip-pop${i.below ? " below" : ""}`,
			style: {
				left: i.x,
				top: i.y
			},
			role: "tooltip",
			children: e
		}), document.body) : null]
	});
}
function zp({ title: e, items: t }) {
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-tip-list",
		children: [e ? /* @__PURE__ */ (0, R.jsx)("div", {
			className: "sc-tip-title",
			children: e
		}) : null, t.map((e, t) => /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "sc-tip-item",
			children: [
				e.name ? /* @__PURE__ */ (0, R.jsxs)("strong", { children: [e.name, " "] }) : null,
				e.text,
				e.ref ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: "sc-tip-ref",
					children: e.ref
				}) : null
			]
		}, t))]
	});
}
function Bp({ id: e, meta: t, t: n }) {
	let r = t?.help?.[e];
	return r ? /* @__PURE__ */ (0, R.jsx)(q, {
		label: n("About this chart"),
		children: /* @__PURE__ */ (0, R.jsx)(zp, {
			title: n("About this chart"),
			items: [{
				name: n("What it shows."),
				text: n(r.shows)
			}, {
				name: n("How to read it."),
				text: n(r.read)
			}]
		})
	}) : null;
}
function Vp({ id: e, title: t, icon: n, height: r = 380, meta: i, t: a, actions: o, className: s, children: c }) {
	return /* @__PURE__ */ (0, R.jsxs)(H, {
		title: t,
		icon: n,
		full: !0,
		help: /* @__PURE__ */ (0, R.jsx)(Bp, {
			id: e,
			meta: i,
			t: a
		}),
		actions: o,
		className: s,
		children: [c, /* @__PURE__ */ (0, R.jsx)(U, {
			id: W(e),
			height: r
		})]
	});
}
function Hp({ id: e, title: t, height: n = 420, meta: r, t: i }) {
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-pane",
		children: [/* @__PURE__ */ (0, R.jsxs)("div", {
			className: "sc-pane-title",
			children: [
				t,
				" ",
				/* @__PURE__ */ (0, R.jsx)(Bp, {
					id: e,
					meta: r,
					t: i
				})
			]
		}), /* @__PURE__ */ (0, R.jsx)(U, {
			id: W(e),
			height: n
		})]
	});
}
function Up({ show: e, text: t, btn: n, label: r }) {
	return /* @__PURE__ */ (0, R.jsx)(K, {
		when: e,
		children: /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "sc-gate",
			role: "status",
			children: [
				/* @__PURE__ */ (0, R.jsx)("span", {
					className: "sc-gate-icon",
					children: /* @__PURE__ */ (0, R.jsx)(wr, { size: 18 })
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "sc-gate-text",
					children: t
				}),
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: W(n),
					label: r,
					icon: /* @__PURE__ */ (0, R.jsx)(Ge, { size: 14 }),
					variant: "outline-primary"
				})
			]
		})
	});
}
function Wp({ back: e, backLabel: t, nav: n, next: r, nextLabel: i, nextIcon: a, t: o, after: s }) {
	let c = !!n?.ok;
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-stepnav",
		children: [
			e ? /* @__PURE__ */ (0, R.jsx)(B, {
				id: W(e),
				label: t,
				icon: /* @__PURE__ */ (0, R.jsx)(Ge, { size: 14 }),
				variant: "outline-secondary"
			}) : /* @__PURE__ */ (0, R.jsx)("span", {}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: `sc-stepnav-status${c ? " ok" : ""}`,
				children: [
					c ? /* @__PURE__ */ (0, R.jsx)(Lt, { size: 15 }) : /* @__PURE__ */ (0, R.jsx)(ir, { size: 15 }),
					" ",
					/* @__PURE__ */ (0, R.jsx)("span", { children: o(c ? n?.done ?? "" : n?.todo ?? "") })
				]
			}),
			s,
			/* @__PURE__ */ (0, R.jsx)(B, {
				id: W(r),
				label: i,
				icon: a ?? /* @__PURE__ */ (0, R.jsx)(qe, { size: 14 }),
				variant: c ? "primary" : "outline-secondary",
				disabled: !c,
				className: "sc-stepnav-next"
			})
		]
	});
}
function Gp({ show: e, children: t }) {
	return e ? /* @__PURE__ */ (0, R.jsx)("div", {
		className: "sc-pending",
		children: t
	}) : null;
}
function Kp({ open: e, onClose: t, title: n, children: r, footer: i }) {
	return E(() => {
		if (!e) return;
		let n = (e) => {
			e.key === "Escape" && t();
		};
		return document.addEventListener("keydown", n), () => document.removeEventListener("keydown", n);
	}, [e, t]), (0, tc.createPortal)(/* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-dialog-backdrop sc-keep-dialog",
		style: { display: e ? "flex" : "none" },
		onMouseDown: (e) => {
			e.target === e.currentTarget && t();
		},
		children: /* @__PURE__ */ (0, R.jsx)("div", {
			className: "modal-dialog tw-dialog",
			role: "dialog",
			"aria-modal": "true",
			style: { maxWidth: 560 },
			children: /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "modal-content",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "modal-header",
						children: [/* @__PURE__ */ (0, R.jsx)("h5", {
							className: "modal-title",
							children: n
						}), /* @__PURE__ */ (0, R.jsx)("button", {
							type: "button",
							className: "btn-close",
							onClick: t,
							"aria-label": "Close",
							children: /* @__PURE__ */ (0, R.jsx)(Ma, { size: 0 })
						})]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "modal-body",
						children: r
					}),
					i ? /* @__PURE__ */ (0, R.jsx)("div", {
						className: "modal-footer",
						children: i
					}) : null
				]
			})
		})
	}), document.body);
}
function qp(e, t, n, r) {
	let [i, a] = Kd(e, t, {
		debounceMs: 0,
		type: r
	});
	return uf(e, (e) => {
		e.value !== void 0 && a(typeof t == "boolean" ? !!e.value : e.value === null || e.value === "" ? null : Number(e.value));
	}), E(() => {
		a(t);
	}, [n]), [i, a];
}
function Jp(e, t) {
	let n = window.Shiny;
	for (let r of e) n?.setInputValue(`${W(r)}:shinyreact.default`, t);
	window.dispatchEvent(new CustomEvent("sc-use-all", { detail: {
		ids: e,
		on: t
	} }));
}
var Yp = /* @__PURE__ */ new Map(), Xp = /* @__PURE__ */ new Set();
function Zp(e, t) {
	t === null ? Yp.delete(e) : Yp.set(e, t), Xp.forEach((e) => e());
}
function Qp(e) {
	let [, t] = O(0);
	E(() => {
		let e = () => t((e) => e + 1);
		return Xp.add(e), () => {
			Xp.delete(e);
		};
	}, []);
	let n = e.filter((e) => Yp.get(e)).length;
	return !e.length || n === 0 ? "none" : n === e.length ? "all" : "some";
}
function $p({ id: e, value: t, stamp: n, label: r }) {
	let [i, a] = qp(W(e), t, n);
	return E(() => {
		let t = (t) => {
			let n = t.detail;
			n?.ids?.includes(e) && a(!!n.on);
		};
		return window.addEventListener("sc-use-all", t), () => window.removeEventListener("sc-use-all", t);
	}, [e]), E(() => {
		Zp(e, !!i);
	}, [e, i]), E(() => () => Zp(e, null), [e]), /* @__PURE__ */ (0, R.jsx)("input", {
		type: "checkbox",
		className: "form-check-input sc-tick",
		checked: !!i,
		"aria-label": r,
		onChange: (e) => a(e.target.checked)
	});
}
function em(e, t) {
	window.Shiny?.setInputValue(e, t, { priority: "event" });
}
var tm = class extends c {
	constructor(...e) {
		super(...e), this.state = { err: null };
	}
	static getDerivedStateFromError(e) {
		return { err: e };
	}
	render() {
		return this.state.err ? /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-notice tw-notice-danger",
			role: "alert",
			children: [/* @__PURE__ */ (0, R.jsx)(Ma, { size: 15 }), /* @__PURE__ */ (0, R.jsxs)("div", { children: [this.props.t("This part of the page could not be drawn. Save the session and reload the page."), /* @__PURE__ */ (0, R.jsx)("div", {
				className: "small text-muted",
				children: String(this.state.err.message)
			})] })]
		}) : this.props.children;
	}
};
//#endregion
//#region src/pages/design/StepFramework.tsx
k();
var nm = (e) => [
	{
		value: "outcome",
		label: e("Food-security outcome indicator")
	},
	{
		value: "pmt",
		label: e("Welfare measure: proxy means test (PMT)")
	},
	{
		value: "none",
		label: e("No outcome indicator: vulnerability ranking")
	}
];
function rm({ flow: e, meta: t, mode: n, t: r }) {
	let i = L(W("sc_framework")), a = I(W("pmt_unit")) ?? "hh", o = I(W("pmt_line_mode")) ?? "value", s = e?.fw_note ?? "validate", c = (e, t) => /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)(Gp, {
		show: e === "validate",
		children: [
			/* @__PURE__ */ (0, R.jsx)(Nt, { size: 14 }),
			" ",
			r("Click Validate: the design starts from there.")
		]
	}), /* @__PURE__ */ (0, R.jsxs)(Gp, {
		show: e === "stale",
		children: [
			/* @__PURE__ */ (0, R.jsx)(na, { size: 14 }),
			" ",
			r(t)
		]
	})] }), l = D(null);
	return V(W("sc_framework"), l), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-step",
		ref: l,
		children: [
			/* @__PURE__ */ (0, R.jsx)(_f, {
				id: W("framework_mode"),
				choices: nm(r),
				value: "outcome",
				buttons: !0,
				className: "sc-modes",
				size: "md"
			}),
			/* @__PURE__ */ (0, R.jsx)(K, {
				when: n === "none",
				children: /* @__PURE__ */ (0, R.jsxs)(H, {
					title: r("Targeting without an outcome indicator"),
					icon: /* @__PURE__ */ (0, R.jsx)(on, { size: 15 }),
					children: [
						/* @__PURE__ */ (0, R.jsx)("p", {
							className: "small mb-2",
							children: r("When no food-security assessment is available (a sudden shock, data from a partner, a registry), households are ranked on the criteria you choose instead of predicting an outcome: deprivation counting, a PCA or MCA index, or household profiles from clustering. The criteria are not tested (there is nothing to test them against) and no inclusion or exclusion error can be measured: the design reports internal consistency and the stability of the selection instead.")
						}),
						/* @__PURE__ */ (0, R.jsx)("p", {
							className: "small text-muted mb-3",
							children: r("Plan a small verification sample (a light food-security module) or use the PDM to measure the errors later.")
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "sc-row",
							children: [/* @__PURE__ */ (0, R.jsx)(hf, {
								id: W("rank_label"),
								label: r("What the ranking stands for"),
								placeholder: r("e.g. Economic vulnerability after the floods"),
								className: "sc-grow"
							}), /* @__PURE__ */ (0, R.jsx)(B, {
								id: W("fw_validate_none"),
								label: r("Validate"),
								icon: /* @__PURE__ */ (0, R.jsx)(Tt, { size: 14 }),
								variant: "primary",
								size: "md",
								className: "sc-row-btn"
							})]
						}),
						n === "none" ? c(s, "") : null
					]
				})
			}),
			/* @__PURE__ */ (0, R.jsxs)(K, {
				when: n === "outcome",
				children: [
					/* @__PURE__ */ (0, R.jsx)("p", {
						className: "sc-lead",
						children: r("Pick the food-security outcome the scorecard should predict, and which of its two levels means a vulnerable household.")
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-row",
						children: [
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: W("outcome_col"),
								label: r("Outcome variable"),
								className: "sc-grow",
								clearable: !1
							}),
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: W("outcome_pos"),
								label: r("Level meaning 'vulnerable'"),
								className: "sc-grow",
								clearable: !1
							}),
							/* @__PURE__ */ (0, R.jsx)(B, {
								id: W("fw_validate"),
								label: r("Validate"),
								icon: /* @__PURE__ */ (0, R.jsx)(Tt, { size: 14 }),
								variant: "primary",
								size: "md",
								className: "sc-row-btn"
							})
						]
					}),
					n === "outcome" ? c(s, "The outcome changed since it was validated: Validate again to apply it.") : null,
					i?.outcome ? /* @__PURE__ */ (0, R.jsx)(im, {
						o: i.outcome,
						t: r
					}) : null
				]
			}),
			/* @__PURE__ */ (0, R.jsxs)(K, {
				when: n === "pmt",
				children: [
					/* @__PURE__ */ (0, R.jsx)(sm, { t: r }),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-row sc-pmt-setup",
						children: [
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: W("pmt_welfare"),
								className: "sc-grow-2",
								clearable: !1,
								label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
									r("Welfare variable"),
									" ",
									/* @__PURE__ */ (0, R.jsx)(q, { children: r("Total consumption or expenditure (food and non-food) per household or per person, over one period. It is what the PMT predicts, never a criterion.") })
								] })
							}),
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: W("pmt_unit"),
								label: r("Measured"),
								value: "hh",
								clearable: !1,
								className: "sc-grow",
								choices: [{
									value: "hh",
									label: r("Per household")
								}, {
									value: "pc",
									label: r("Per person")
								}]
							}),
							/* @__PURE__ */ (0, R.jsx)(K, {
								when: a === "hh",
								className: "sc-grow-15",
								children: /* @__PURE__ */ (0, R.jsx)(z, {
									id: W("pmt_size"),
									clearable: !1,
									label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
										r("Household size"),
										" ",
										/* @__PURE__ */ (0, R.jsx)(q, { children: r("Divides household welfare into welfare per person, which is compared with the line.") })
									] })
								})
							}),
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: W("pmt_line_mode"),
								value: "value",
								clearable: !1,
								className: "sc-grow-13",
								label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
									r("Poverty line"),
									" ",
									/* @__PURE__ */ (0, R.jsx)(q, { children: r("A poverty line or the MEB per person, in the welfare's unit and period. Without one, the welfare below which a chosen share of households falls (relative targeting).") })
								] }),
								choices: [{
									value: "value",
									label: r("A line per person")
								}, {
									value: "share",
									label: r("The poorest share")
								}]
							}),
							/* @__PURE__ */ (0, R.jsx)(K, {
								when: o === "value",
								className: "sc-grow",
								children: /* @__PURE__ */ (0, R.jsx)(mf, {
									id: W("pmt_line"),
									label: r("Line per person"),
									min: 0
								})
							}),
							/* @__PURE__ */ (0, R.jsx)(K, {
								when: o === "share",
								className: "sc-grow",
								children: /* @__PURE__ */ (0, R.jsx)(mf, {
									id: W("pmt_share"),
									label: r("Share below it (%)"),
									value: 30,
									min: 5,
									max: 90,
									step: 5
								})
							}),
							/* @__PURE__ */ (0, R.jsx)(B, {
								id: W("pmt_validate"),
								label: r("Validate"),
								icon: /* @__PURE__ */ (0, R.jsx)(Tt, { size: 14 }),
								variant: "primary",
								size: "md",
								className: "sc-row-btn"
							})
						]
					}),
					n === "pmt" ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)(Gp, {
						show: e?.pmt_note === "validate",
						children: [
							/* @__PURE__ */ (0, R.jsx)(Nt, { size: 14 }),
							" ",
							r("Set the welfare variable and the poverty line, then Validate: the analysis starts from there.")
						]
					}), /* @__PURE__ */ (0, R.jsxs)(Gp, {
						show: e?.pmt_note === "stale",
						children: [
							/* @__PURE__ */ (0, R.jsx)(na, { size: 14 }),
							" ",
							r("The setup changed since it was validated: Validate again to apply it.")
						]
					})] }) : null,
					i?.pmt ? /* @__PURE__ */ (0, R.jsx)(om, {
						p: i.pmt,
						t: r
					}) : null
				]
			}),
			/* @__PURE__ */ (0, R.jsx)(K, {
				when: n !== "none",
				children: /* @__PURE__ */ (0, R.jsx)(H, {
					full: !0,
					title: r(n === "pmt" ? "Poor households by area" : "Vulnerable households by area"),
					icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 15 }),
					help: /* @__PURE__ */ (0, R.jsx)(Bp, {
						id: "vuln_area_plot",
						meta: t,
						t: r
					}),
					actions: /* @__PURE__ */ (0, R.jsx)("div", {
						className: "sc-card-select",
						children: /* @__PURE__ */ (0, R.jsx)(z, {
							id: W("vuln_area"),
							choices: [{
								value: "",
								label: r("(none)")
							}],
							value: "",
							placeholder: r("Area column"),
							clearable: !1
						})
					}),
					children: /* @__PURE__ */ (0, R.jsx)(U, {
						id: W("vuln_area_plot"),
						height: 380
					})
				})
			}),
			/* @__PURE__ */ (0, R.jsx)(Wp, {
				nav: e?.nav.outcome,
				next: "nav_next_outcome",
				nextLabel: r("Continue to Criteria"),
				t: r
			})
		]
	});
}
function im({ o: e, t }) {
	if (!e.n) return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-notice tw-notice-danger mt-2",
		children: t("This outcome has no usable values.")
	});
	let n = e.pct ?? 0;
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-kpis sc-kpis-3",
		children: [
			/* @__PURE__ */ (0, R.jsx)(am, {
				label: t("Households with an outcome"),
				value: jp(e.n)
			}),
			/* @__PURE__ */ (0, R.jsx)(am, {
				label: `${t("Vulnerable")} (${e.opos})`,
				value: `${n.toFixed(1)}%`,
				tone: "danger",
				share: n / 100
			}),
			/* @__PURE__ */ (0, R.jsx)(am, {
				label: t("Not vulnerable"),
				value: `${(100 - n).toFixed(1)}%`,
				tone: "success",
				share: 1 - n / 100
			})
		]
	}), n > 95 || n < 5 ? /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-notice tw-notice-warning mt-2",
		children: [/* @__PURE__ */ (0, R.jsx)(na, { size: 15 }), /* @__PURE__ */ (0, R.jsxs)("div", { children: [
			t("Only %s of households fall on one side of this outcome.").replace("%s", `${Math.min(n, 100 - n).toFixed(1)}%`),
			" ",
			t("A scorecard built on such an unbalanced outcome will separate very little. Check the level you selected is the one that means vulnerable.")
		] })]
	}) : null] });
}
function am({ label: e, value: t, tone: n, share: r, sub: i, children: a }) {
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `sc-kpi${n ? " is-" + n : ""}`,
		children: [
			/* @__PURE__ */ (0, R.jsx)("div", {
				className: "sc-kpi-label",
				children: e
			}),
			/* @__PURE__ */ (0, R.jsx)("div", {
				className: "sc-kpi-value",
				children: t
			}),
			typeof r == "number" ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "sc-kpi-bar",
				children: /* @__PURE__ */ (0, R.jsx)("span", { style: { width: `${Math.max(0, Math.min(1, r)) * 100}%` } })
			}) : null,
			i ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "sc-kpi-sub",
				children: i
			}) : null,
			a
		]
	});
}
function om({ p: e, t }) {
	let n = {
		ok: /* @__PURE__ */ (0, R.jsx)(Lt, {
			size: 15,
			className: "text-success"
		}),
		warn: /* @__PURE__ */ (0, R.jsx)(na, {
			size: 15,
			className: "text-warning"
		}),
		fail: /* @__PURE__ */ (0, R.jsx)(qt, {
			size: 15,
			className: "text-danger"
		})
	};
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
		/* @__PURE__ */ (0, R.jsxs)("div", {
			className: "sc-kpis sc-kpis-4",
			children: [
				/* @__PURE__ */ (0, R.jsx)(am, {
					label: t("Households with welfare"),
					value: jp(e.n)
				}),
				/* @__PURE__ */ (0, R.jsx)(am, {
					label: t("Median welfare per person"),
					value: e.median,
					tone: "info"
				}),
				/* @__PURE__ */ (0, R.jsx)(am, {
					label: t("Poverty line per person"),
					value: e.line
				}),
				/* @__PURE__ */ (0, R.jsx)(am, {
					label: t("Poor (at or below the line)"),
					value: `${e.poor.toFixed(1)}%`,
					tone: "danger",
					share: e.poor / 100
				})
			]
		}),
		/* @__PURE__ */ (0, R.jsx)("div", {
			className: "sc-subhead",
			children: t("Data requirements")
		}),
		/* @__PURE__ */ (0, R.jsx)("div", {
			className: "wfp-model-table-wrap",
			children: /* @__PURE__ */ (0, R.jsx)("table", {
				className: "wfp-model-table sc-req",
				children: /* @__PURE__ */ (0, R.jsx)("tbody", { children: e.requirements.map((e, r) => /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
					/* @__PURE__ */ (0, R.jsx)("td", {
						style: { width: 28 },
						children: n[e.status] ?? null
					}),
					/* @__PURE__ */ (0, R.jsx)("td", { children: /* @__PURE__ */ (0, R.jsx)("strong", { children: t(e.check) }) }),
					/* @__PURE__ */ (0, R.jsx)("td", {
						className: "small",
						children: e.detail
					})
				] }, r)) })
			})
		})
	] });
}
function sm({ t: e }) {
	return /* @__PURE__ */ (0, R.jsxs)(H, {
		title: e("Proxy means test: predicting welfare"),
		icon: /* @__PURE__ */ (0, R.jsx)($e, { size: 15 }),
		className: "mb-1",
		children: [/* @__PURE__ */ (0, R.jsx)("p", {
			className: "small mb-2",
			children: e("A proxy means test (PMT) predicts each household's welfare, its consumption or expenditure per person, from characteristics a registration team can observe and verify: dwelling, assets, household composition, education and work of the head. A household is eligible when its predicted welfare is at or below a poverty line. It needs a survey that measured welfare: a household budget or living-standards survey (HIES, LSMS) or an assessment with a full expenditure module.")
		}), /* @__PURE__ */ (0, R.jsxs)("details", {
			className: "small sc-details",
			children: [
				/* @__PURE__ */ (0, R.jsx)("summary", { children: /* @__PURE__ */ (0, R.jsx)("strong", { children: e("Data requirements and guidance") }) }),
				/* @__PURE__ */ (0, R.jsxs)("ul", {
					className: "mt-2 mb-2",
					children: [
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							/* @__PURE__ */ (0, R.jsx)("strong", { children: e("Welfare aggregate:") }),
							" ",
							e("total consumption or expenditure, food and non-food, over one recall period, per household or per person (the World Bank's standard is consumption per person or per adult equivalent).")
						] }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							/* @__PURE__ */ (0, R.jsx)("strong", { children: e("Sample:") }),
							" ",
							e("several thousand households (a household budget survey), representative of the population to be targeted; at least 10 to 20 households per proxy. Re-estimate when a new survey arrives (every 3 to 5 years, sooner after a shock).")
						] }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							/* @__PURE__ */ (0, R.jsx)("strong", { children: e("Proxies:") }),
							" ",
							e("observable and verifiable at registration, hard to manipulate, and not the welfare measure itself (no expenditure, income or coping answers). Typical: household size and composition, dwelling materials, water and sanitation, assets, land and livestock, education and occupation of the head, location.")
						] }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							/* @__PURE__ */ (0, R.jsx)("strong", { children: e("Poverty line:") }),
							" ",
							e("a national line or the MEB per person, in the welfare's unit and period; or the share of households the programme can serve (relative targeting).")
						] })
					]
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "fw-bold mt-2",
					children: e("References")
				}),
				/* @__PURE__ */ (0, R.jsxs)("ul", {
					className: "mt-1 mb-0",
					children: [
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							"World Bank: Grosh & Baker (1995), ",
							/* @__PURE__ */ (0, R.jsx)("em", { children: "Proxy Means Tests for Targeting Social Programs" }),
							", LSMS Working Paper 118; Grosh, del Ninno, Tesliuc & Ouerghi (2008), ",
							/* @__PURE__ */ (0, R.jsx)("em", { children: "For Protection and Promotion" }),
							", ch. 4; Del Ninno & Mills (2015), ",
							/* @__PURE__ */ (0, R.jsx)("em", { children: "Safety Nets in Africa" }),
							"."
						] }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							e("Accuracy:"),
							" Brown, Ravallion & van de Walle (2018), A poor means test?, ",
							/* @__PURE__ */ (0, R.jsx)("em", { children: "Journal of Development Economics" }),
							" 134: ",
							e("exclusion errors of 40-60% are common at typical coverage; a quantile regression at the poverty rate or a cut-off above the line lowers them.")
						] }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							e("Safeguards:"),
							" Kidd, Gelders & Bailey-Athias (2017), ",
							/* @__PURE__ */ (0, R.jsx)("em", { children: "Exclusion by Design" }),
							", ILO / Development Pathways: ",
							e("validate on households the model never saw, explain the formula, pair it with community validation and a grievance mechanism.")
						] }),
						/* @__PURE__ */ (0, R.jsx)("li", { children: e("Humanitarian practice: UNHCR-WFP Joint Programme Excellence and Targeting Hub, and the WFP Targeting OGN (2021): econometric eligibility models where expenditure data exist (for example Lebanon's VASyR and Jordan's refugee assistance), recalibrated with each survey.") })
					]
				})
			]
		})]
	});
}
//#endregion
//#region src/pages/design/facts.tsx
k();
var J = (e, ...t) => t.reduce((e, t) => e.replace("%s", String(t)), e), cm = (e) => G(e) ? `${Math.round(100 * e)}%` : "n/a", lm = (e) => G(e) ? e.toFixed(2) : "n/a";
function um() {
	return L(W("sc_stale"));
}
var dm = {
	outcome: {
		icon: /* @__PURE__ */ (0, R.jsx)(bi, { size: 14 }),
		head: "%s column(s) blocked as outcome indicators",
		text: "Outcome indicators reflect a household's current food consumption, which moves with the season and with assistance itself. Targeting on them is reactive rather than preventive, and they cannot then be used to validate the targeting."
	},
	unobs: {
		icon: /* @__PURE__ */ (0, R.jsx)(bn, { size: 14 }),
		head: "%s column(s) not observable at registration",
		text: "Expenditure, prices, coping strategies and their reasons, MEB and transfer values, food consumption, phone numbers and indebtedness cannot be seen or verified by a registration team, so they are not criteria."
	},
	ids: {
		icon: /* @__PURE__ */ (0, R.jsx)(nr, { size: 14 }),
		head: "%s name or identification column(s)",
		text: "Identifiers, names, phone numbers and form metadata identify a household; they do not describe it."
	}
};
function fm({ t: e }) {
	let t = L(W("sc_blocked")), n = D(null);
	V(W("sc_blocked"), n);
	let r = !!t && !t.none, i = r ? t.overridable : [];
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		ref: n,
		className: "sc-blocked",
		children: [t?.none ? /* @__PURE__ */ (0, R.jsx)("div", {
			className: "text-muted",
			children: e("No column is blocked.")
		}) : null, /* @__PURE__ */ (0, R.jsx)(K, {
			when: r,
			className: "tw-notice tw-notice-info sc-blocked-box",
			children: /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-stack",
				children: [
					r ? t.groups.map((t) => /* @__PURE__ */ (0, R.jsxs)("div", { children: [
						/* @__PURE__ */ (0, R.jsxs)("strong", {
							className: "sc-blocked-head",
							children: [
								dm[t.kind].icon,
								" ",
								J(e(dm[t.kind].head), t.n)
							]
						}),
						/* @__PURE__ */ (0, R.jsx)("p", {
							className: "small mb-1 mt-1",
							children: e(dm[t.kind].text)
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "small sc-blocked-cols",
							children: [t.cols.join(", "), t.more ? ", ..." : ""]
						})
					] }, t.kind)) : null,
					r && t.nof ? /* @__PURE__ */ (0, R.jsxs)("p", {
						className: "small mb-0",
						children: [
							e("Without an outcome, outcome indicators (FCS, rCSI, CARI...) and what a registration team cannot observe are allowed: they may rank households."),
							" ",
							e("Remember that a criterion the registration cannot collect cannot be applied in Beneficiary Selection.")
						]
					}) : null,
					/* @__PURE__ */ (0, R.jsxs)(K, {
						when: i.length > 0,
						className: "sc-allow",
						children: [
							/* @__PURE__ */ (0, R.jsxs)("strong", { children: [
								/* @__PURE__ */ (0, R.jsx)(Sr, { size: 14 }),
								" ",
								e("Allow some of them anyway")
							] }),
							/* @__PURE__ */ (0, R.jsx)("p", {
								className: "small text-muted mb-1",
								children: e("The blocking rules read column names and can be wrong. You decide: an allowed column joins the candidates, and the choice and its reason go to the audit trail and the report.")
							}),
							r && t.allowed.length ? /* @__PURE__ */ (0, R.jsxs)("div", {
								className: "small",
								children: [
									/* @__PURE__ */ (0, R.jsx)(Tt, {
										size: 13,
										className: "sc-ok-icon"
									}),
									" ",
									e("Allowed:"),
									/* @__PURE__ */ (0, R.jsx)("ul", {
										className: "mb-0",
										children: t.allowed.map((t) => /* @__PURE__ */ (0, R.jsxs)("li", { children: [
											/* @__PURE__ */ (0, R.jsx)("code", { children: t.col }),
											" ",
											"—",
											" ",
											/* @__PURE__ */ (0, R.jsx)("em", { children: t.note ?? e("no note given") })
										] }, t.col))
									})
								]
							}) : null,
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: W("allow_blocked"),
								multiple: !0,
								actions: !0,
								choices: i,
								value: r ? t.allowed.map((e) => e.col) : [],
								label: e("Columns to allow"),
								placeholder: e("Choose blocked columns to allow")
							}, r ? t.stamp : 0),
							/* @__PURE__ */ (0, R.jsx)(hf, {
								id: W("allow_reason"),
								label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
									e("Note (why)"),
									" ",
									/* @__PURE__ */ (0, R.jsx)(q, { children: e("A short explanation, recorded for the columns allowed now: it goes to the audit trail and the design report.") })
								] }),
								placeholder: e("e.g. a household characteristic despite its name; observable by the registration team here")
							}),
							/* @__PURE__ */ (0, R.jsx)("div", { children: /* @__PURE__ */ (0, R.jsx)(B, {
								id: W("allow_apply"),
								label: e("Allow as criteria"),
								icon: /* @__PURE__ */ (0, R.jsx)(Sr, { size: 13 })
							}) })
						]
					})
				]
			})
		})]
	});
}
function pm({ figs: e, t }) {
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "sc-figs",
		children: e.map((e) => /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "sc-fig",
			children: [
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "sc-fig-title",
					children: [t(e.title), e.tip ? /* @__PURE__ */ (0, R.jsx)(q, { children: t(e.tip) }) : null]
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "sc-fig-value",
					children: e.value
				}),
				e.sub ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: "sc-fig-sub",
					children: J(t(e.sub), e.arg ? t(e.arg) : "")
				}) : null
			]
		}, e.title))
	});
}
function mm({ ix: e, t }) {
	if (e.type === "pca") {
		let n = e.axes > 1 ? J(t("PCA index on %s axes (%s)."), e.axes, e.axis_share.map((n, r) => J(t("axis %s: %s, weight %s"), r + 1, cm(n), lm(e.axis_weights[r]))).join("; ")) : t("PCA index on the first component."), r = e.kaiser === 1 ? t("Kaiser's rule (eigenvalue above 1) would keep 1 axis.") : J(t("Kaiser's rule (eigenvalue above 1) would keep %s axes."), G(e.kaiser) ? e.kaiser : "n/a"), i = G(e.bartlett_p) ? e.bartlett_p < .001 ? "< 0.001" : `= ${e.bartlett_p.toFixed(3)}` : "n/a", a = /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
			/* @__PURE__ */ (0, R.jsx)("strong", { children: J(t("Total variation explained: %s"), cm(e.share)) }),
			G(e.min_var) ? ` ${J(t("(the fewest axes reaching the %s asked)."), cm(e.min_var))}` : ".",
			" ",
			n,
			" ",
			r,
			" ",
			J(t("Sampling adequacy (KMO) %s (%s); Bartlett's test p %s."), G(e.kmo) ? e.kmo.toFixed(2) : "n/a", t(e.kmo_word), i),
			e.weak ? ` ${t("The criteria share little variation: one index summarises them poorly; prefer a model, or fewer and more related criteria.")}` : "",
			" ",
			t("Weights are the index's own coefficients, scaled so the largest is 10; the points scheme does not apply.")
		] });
		return e.weak ? /* @__PURE__ */ (0, R.jsx)(Jf, {
			kind: "warning",
			children: a
		}) : /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "small text-muted",
			children: [
				/* @__PURE__ */ (0, R.jsx)(Br, { size: 13 }),
				" ",
				a
			]
		});
	}
	if (e.type === "lda") return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "small text-muted",
		children: [
			/* @__PURE__ */ (0, R.jsx)(Br, { size: 13 }),
			" ",
			J(t("LDA index: separation between the two groups (Mahalanobis D²) %s."), lm(e.mahalanobis)),
			" ",
			t("Weights are the discriminant's own coefficients, scaled so the largest is 10; the points scheme does not apply.")
		]
	});
	let n = e.type === "count" ? t("Deprivation count: each criterion met adds its points (1 by default; edit them in the table).") : e.type === "mca" ? J(t("MCA index on %s axis(es): %s of the inertia explained in total, turned towards %s."), e.axes, cm(e.share), t(e.anchor)) : J(t("%s household profiles (%s); targeted: profile %s, %s of the households. The points reproduce the targeted profiles."), e.k ?? "", t(e.algorithm ?? ""), e.target.join(", "), cm(e.target_share));
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "small text-muted",
		children: [
			/* @__PURE__ */ (0, R.jsx)(Br, { size: 13 }),
			" ",
			n,
			" ",
			J(t("Internal consistency (Cronbach's alpha) %s. No outcome: the errors cannot be measured."), lm(e.alpha))
		]
	});
}
function hm({ t: e }) {
	let t = L(W("sc_fit"));
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-fit-note",
		style: t ? void 0 : { display: "none" },
		children: [
			/* @__PURE__ */ (0, R.jsxs)(K, {
				when: !!t?.tuning,
				className: "small text-muted",
				children: [t?.tuning ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					/* @__PURE__ */ (0, R.jsx)(Ai, { size: 12 }),
					" ",
					J(e("Tuned by %s-fold cross-validation on %s training households: %s (cross-validated AUC %s)."), t.tuning.folds, jp(t.tuning.n), t.tuning.best, t.tuning.auc.toFixed(3)),
					" "
				] }) : null, /* @__PURE__ */ (0, R.jsx)(B, {
					id: W("show_tuning"),
					label: e("See the grid"),
					link: !0
				})]
			}),
			t?.k_auto ? /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "small text-muted",
				children: [
					/* @__PURE__ */ (0, R.jsx)(Ai, { size: 12 }),
					" ",
					J(e("Number of profiles chosen automatically: %s (best silhouette %s among 2 to 8)."), t.k_auto.k, lm(t.k_auto.silhouette))
				]
			}) : null,
			t ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "small text-muted",
				children: t.held_out ? J(e("%s, fitted on %s households, %s held out for evaluation; %s criteria kept."), e(t.model), jp(t.n), jp(t.held_out), t.kept) : J(e("%s, fitted on %s households; %s criteria kept."), e(t.model), jp(t.n), t.kept)
			}) : null,
			t?.index ? /* @__PURE__ */ (0, R.jsx)(mm, {
				ix: t.index,
				t: e
			}) : null,
			t?.pmt ? /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-stack",
				children: [
					/* @__PURE__ */ (0, R.jsx)(pm, {
						figs: t.pmt.figs,
						t: e
					}),
					t.pmt.nonpositive > 0 ? /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "small text-muted",
						children: [
							/* @__PURE__ */ (0, R.jsx)(ir, { size: 13 }),
							" ",
							J(e("%s households with zero or negative welfare were left out of the fit (they cannot be logged)."), jp(t.pmt.nonpositive))
						]
					}) : null,
					t.pmt.under ? /* @__PURE__ */ (0, R.jsxs)(Jf, {
						kind: "warning",
						children: [
							J(e("Under-coverage of %s: that share of poor households is predicted above the line. This is common for PMTs (Brown, Ravallion & van de Walle 2018 find 40-60% at typical coverage)."), t.pmt.under),
							" ",
							e("Consider the quantile regression, a cut-off above the line (step 4), better proxies, or combining the PMT with community validation.")
						]
					}) : null
				]
			}) : null,
			t && !t.converged ? /* @__PURE__ */ (0, R.jsxs)(Jf, {
				kind: "warning",
				children: [
					/* @__PURE__ */ (0, R.jsx)("strong", { children: e("The model did not converge cleanly.") }),
					" ",
					e("Usually one criterion perfectly predicts the outcome (complete separation). Its weight is not trustworthy -- drop it in step 3 or set the weight by hand.")
				]
			}) : null
		]
	});
}
function gm({ t: e }) {
	let t = L(W("sc_fit"));
	if (!t || !t.filled.length && !t.dropped.length) return null;
	let n = [t.filled.length ? J(t.is_pmt ? e("%s criteria had missing answers counted as 'no' (numbers as the average)") : e("%s criteria had missing answers counted as 'no'"), t.filled.length) : null, t.dropped.length ? J(e("%s removed by stepwise selection"), t.dropped.length) : null].filter(Boolean).join(" · ");
	return /* @__PURE__ */ (0, R.jsxs)("details", {
		className: "sc-details small text-muted sc-fit-details",
		children: [
			/* @__PURE__ */ (0, R.jsxs)("summary", { children: [
				/* @__PURE__ */ (0, R.jsx)(ir, { size: 13 }),
				" ",
				e("Notes on the fit:"),
				" ",
				n
			] }),
			t.filled.length ? /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "mt-1",
				children: [
					t.is_pmt ? e("Missing answers counted as 'no', missing numbers as the average (as in the score):") : e("Missing answers counted as 'no' (as in the score):"),
					" ",
					t.filled.map((e) => `${e.name} (${jp(e.n)})`).join(", "),
					"."
				]
			}) : null,
			t.dropped.length ? /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "mt-1",
				children: [
					/* @__PURE__ */ (0, R.jsx)(mi, { size: 13 }),
					" ",
					e("Removed by stepwise selection (no information once the others are known):"),
					" ",
					t.dropped.join(", ")
				]
			}) : null
		]
	});
}
function _m({ j: e, value: t, stamp: n, label: r, report: i }) {
	let [a, o] = qp(W(`tgt_${e}`), t, n);
	return E(() => {
		i(e, !!a);
	}, [a]), /* @__PURE__ */ (0, R.jsxs)("label", {
		className: "sc-prof-tick",
		children: [
			/* @__PURE__ */ (0, R.jsx)("input", {
				type: "checkbox",
				className: "form-check-input sc-tick",
				checked: !!a,
				onChange: (e) => o(e.target.checked)
			}),
			" ",
			r
		]
	});
}
var vm = (e) => {
	let t = Math.min(Math.abs(e) / .4, 1) * .55;
	return e >= 0 ? `rgba(10, 110, 180, ${t.toFixed(2)})` : `rgba(247, 184, 37, ${t.toFixed(2)})`;
};
function ym({ t: e }) {
	let t = L(W("sc_profiles")), [n, r] = O({}), i = (e, t) => r((n) => n[e] === t ? n : {
		...n,
		[e]: t
	}), a = t?.k ?? 0, o = (t) => t === 1 ? e("most vulnerable") : t === a ? e("least vulnerable") : J(e("rank %s of %s"), t, a), s = (t?.profiles ?? []).map((e) => e.j).filter((e) => n[e] ?? t?.target.includes(e)).sort((e, t) => e - t), c = (t?.profiles ?? []).filter((e) => s.includes(e.j)).reduce((e, t) => e + t.size, 0), l = !!t && s.length === t.target.length && s.every((e) => t.target.includes(e));
	return /* @__PURE__ */ (0, R.jsx)(K, {
		when: !!t,
		className: "sc-cluster",
		children: /* @__PURE__ */ (0, R.jsxs)(H, {
			title: J(e("%s household profiles"), a),
			icon: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 15 }),
			help: /* @__PURE__ */ (0, R.jsx)(q, { children: e("Profiles are ordered from the most to the least vulnerable, judged on the anchor-oriented first component. Rows: the ten criteria that separate the profiles most. Each cell is the share of the profile's households giving the answer named under the criterion, tinted blue above the average household and amber below. Tick the profiles to target, then click Target the ticked profiles: the points are refitted to reproduce them.") }),
			children: [
				t ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: "wfp-model-table-wrap wfp-prof-wrap",
					children: /* @__PURE__ */ (0, R.jsxs)("table", {
						className: "wfp-model-table wfp-prof-table",
						children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
							/* @__PURE__ */ (0, R.jsx)("th", { children: e("Criterion") }),
							/* @__PURE__ */ (0, R.jsxs)("th", { children: [
								e("Separates"),
								" ",
								/* @__PURE__ */ (0, R.jsx)(q, { children: e("How strongly the criterion tells the profiles apart: Cramer's V of the criterion against profile membership, from 0 (every profile has the same share) to 1 (the criterion alone says which profile a household is in). Above about 0.3 the criterion is one of the things that define the profiles; below 0.1 it hardly differs between them.") })
							] }),
							t.profiles.map((n) => /* @__PURE__ */ (0, R.jsxs)("th", {
								className: "num wfp-prof-head",
								children: [
									/* @__PURE__ */ (0, R.jsx)(_m, {
										j: n.j,
										value: t.target.includes(n.j),
										stamp: t.stamp,
										label: J(e("Profile %s"), n.j),
										report: i
									}),
									/* @__PURE__ */ (0, R.jsx)("div", {
										className: "small fw-normal",
										children: J(e("%s of households"), cm(n.size))
									}),
									/* @__PURE__ */ (0, R.jsx)("div", {
										className: `small fw-normal ${n.rank === 1 ? "sc-down" : "text-muted"}`,
										children: o(n.rank)
									})
								]
							}, n.j)),
							/* @__PURE__ */ (0, R.jsxs)("th", {
								className: "num",
								children: [
									e("All"),
									" ",
									/* @__PURE__ */ (0, R.jsx)(q, { children: e("The share among all households, for comparison.") })
								]
							})
						] }) }), /* @__PURE__ */ (0, R.jsx)("tbody", { children: t.rows.map((n) => /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
							/* @__PURE__ */ (0, R.jsxs)("td", {
								className: "tw-var wfp-prof-var",
								children: [
									/* @__PURE__ */ (0, R.jsx)("strong", { children: n.criterion }),
									n.label ? /* @__PURE__ */ (0, R.jsx)("div", {
										className: "tw-cell-label",
										children: n.label
									}) : null,
									n.counted ? /* @__PURE__ */ (0, R.jsx)("div", {
										className: "small text-muted",
										children: J(e("% of households answering “%s”"), n.counted)
									}) : null
								]
							}),
							/* @__PURE__ */ (0, R.jsx)("td", {
								style: { minWidth: 120 },
								children: /* @__PURE__ */ (0, R.jsxs)("div", {
									className: "d-flex align-items-center gap-2",
									children: [/* @__PURE__ */ (0, R.jsx)("div", {
										className: "wfp-prof-bar flex-grow-1",
										children: /* @__PURE__ */ (0, R.jsx)("span", { style: {
											width: `${Math.round(100 * n.v / t.vmax)}%`,
											background: "#0A6EB4"
										} })
									}), /* @__PURE__ */ (0, R.jsx)("span", {
										className: "small",
										children: n.v.toFixed(2)
									})]
								})
							}),
							n.cells.map((e, t) => /* @__PURE__ */ (0, R.jsx)("td", {
								className: "num",
								style: { background: vm(e.d) },
								children: cm(e.p)
							}, t)),
							/* @__PURE__ */ (0, R.jsx)("td", {
								className: "num text-muted",
								children: cm(n.overall)
							})
						] }, n.criterion)) })]
					})
				}) : null,
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "d-flex justify-content-between align-items-center flex-wrap gap-2 mt-2",
					children: [/* @__PURE__ */ (0, R.jsxs)("span", {
						className: "small",
						children: [s.length ? J(s.length > 1 ? e("Ticked: profiles %s, %s of households.") : e("Ticked: profile %s, %s of households."), s.join(", "), cm(c)) : e("No profile ticked."), !l && s.length ? /* @__PURE__ */ (0, R.jsxs)("span", {
							className: "sc-warn-text",
							children: [" ", e("Click Target the ticked profiles to apply.")]
						}) : null]
					}), /* @__PURE__ */ (0, R.jsx)(B, {
						id: W("cluster_apply"),
						label: e("Target the ticked profiles"),
						icon: /* @__PURE__ */ (0, R.jsx)(Wi, { size: 13 }),
						variant: "primary"
					})]
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "small mt-2",
					children: [
						J(e("Separation of the profiles (silhouette): %s"), lm(t?.silhouette)),
						G(t?.entropy) ? ` · ${J(e("classification certainty (entropy): %s"), lm(t?.entropy))}` : "",
						G(t?.bic) ? ` · ${J(e("BIC: %s"), jp(t?.bic))}` : "",
						" ",
						/* @__PURE__ */ (0, R.jsx)(B, {
							id: W("profile_quality"),
							label: e("Compare 2 to 8 profiles"),
							link: !0
						})
					]
				}),
				G(t?.fidelity) ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: `small ${t.fidelity < .8 ? "sc-warn-text" : "text-muted"}`,
					children: J(t.fidelity < .8 ? e("The points reproduce the targeted profiles with an AUC of %s: the profiles are not a straight cut through the criteria; try another number of profiles or method.") : e("The points reproduce the targeted profiles with an AUC of %s."), lm(t?.fidelity))
				}) : null
			]
		})
	});
}
function bm({ t: e }) {
	let t = L(W("sc_diagram"));
	return t ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [t.diagram ? /* @__PURE__ */ (0, R.jsx)(H, {
		full: !0,
		title: e(t.diagram.title),
		icon: /* @__PURE__ */ (0, R.jsx)(Br, { size: 15 }),
		help: /* @__PURE__ */ (0, R.jsx)(q, { children: e(t.diagram.help) }),
		className: "sc-diagram-card",
		children: /* @__PURE__ */ (0, R.jsx)("div", {
			className: "sc-diagram",
			dangerouslySetInnerHTML: { __html: t.diagram.svg }
		})
	}) : null, t.tree?.length ? /* @__PURE__ */ (0, R.jsx)(H, {
		full: !0,
		title: e("Decision tree: the rules"),
		icon: /* @__PURE__ */ (0, R.jsx)(Br, { size: 15 }),
		help: /* @__PURE__ */ (0, R.jsx)(q, { children: t.nof ? e("Each row is a leaf of the tree: the answers that lead to it, how many households it holds and the share of them in the targeted profiles. The points of the ranking are the tree's average effects, so it stays additive; the rules show what the tree itself does.") : e("Each row is a leaf of the tree: the answers that lead to it, how many training households it holds and the share of them that is vulnerable. The points of the card are the tree's average effects, so the card stays additive; the rules show what the tree itself does.") }),
		children: /* @__PURE__ */ (0, R.jsx)("div", {
			className: "wfp-model-table-wrap sc-tree-rules",
			children: /* @__PURE__ */ (0, R.jsxs)("table", {
				className: "wfp-model-table",
				children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
					/* @__PURE__ */ (0, R.jsx)("th", { children: e("If the household...") }),
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "num",
						children: e("Households")
					}),
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "num",
						children: t.nof ? e("In targeted profiles") : e("Vulnerable")
					})
				] }) }), /* @__PURE__ */ (0, R.jsx)("tbody", { children: t.tree.map((e, t) => /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
					/* @__PURE__ */ (0, R.jsx)("td", {
						className: "small",
						children: e.rule
					}),
					/* @__PURE__ */ (0, R.jsx)("td", {
						className: "num",
						children: jp(e.households)
					}),
					/* @__PURE__ */ (0, R.jsx)("td", {
						className: "num",
						children: /* @__PURE__ */ (0, R.jsx)("strong", { children: cm(e.share) })
					})
				] }, t)) })]
			})
		})
	}) : null] }) : null;
}
function xm({ t: e }) {
	let t = L(W("sc_pmt_accuracy"));
	return t ? /* @__PURE__ */ (0, R.jsxs)(H, {
		title: e("PMT targeting accuracy at this cut-off"),
		icon: /* @__PURE__ */ (0, R.jsx)(Wi, { size: 15 }),
		className: "sc-pmt-acc",
		children: [/* @__PURE__ */ (0, R.jsx)("div", {
			className: "small text-muted mb-2",
			children: J(e("Selected when predicted welfare per person is below %s (%s of the poverty line); %s evaluation households."), t.welfare, `${Math.round(t.pct_line)}%`, jp(t.n))
		}), /* @__PURE__ */ (0, R.jsx)(pm, {
			figs: t.figs,
			t: e
		})]
	}) : null;
}
function Sm({ stale: e, t }) {
	let n = e?.pmt_line;
	return n ? /* @__PURE__ */ (0, R.jsx)("span", { children: J(t("Eligible when predicted welfare per person is below %s (%s of the poverty line)."), n.welfare, `${Math.round(n.pct)}%`) }) : null;
}
var Cm = (e) => e.charAt(0).toUpperCase() + e.slice(1);
function wm({ r: e, t }) {
	let n = e?.stability;
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [n ? /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "mb-2 sc-stability-result",
		children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: J(t("%s: %s agreement"), Cm(t(n.word)), cm(n.jaccard)) }), /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "small text-muted",
			children: [J(t("Jaccard index of the selections, median of %s refits (10th-90th percentile %s-%s), at %s of households selected."), n.draws, cm(n.low), cm(n.high), cm(n.share)), G(n.spearman) ? ` ${J(t("Rank agreement (Spearman) %s."), lm(n.spearman))}` : ""]
		})]
	}) : /* @__PURE__ */ (0, R.jsx)("div", {
		className: "small text-muted mb-2",
		children: t("Refits the design on 20 resamples of the households and compares their selections with this one.")
	}), /* @__PURE__ */ (0, R.jsx)(B, {
		id: W("run_stability"),
		label: t(n ? "Check again" : "Check stability"),
		icon: /* @__PURE__ */ (0, R.jsx)(Si, { size: 13 })
	})] });
}
function Tm({ r: e, t }) {
	let n = e?.insights, r = e?.stability;
	if (!n) return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "small text-muted",
		children: t("Set a threshold that selects some households.")
	});
	let i = (e, t) => /* @__PURE__ */ (0, R.jsxs)("li", { children: [
		/* @__PURE__ */ (0, R.jsx)("strong", { children: e }),
		" ",
		t
	] });
	return /* @__PURE__ */ (0, R.jsxs)("ul", {
		className: "small mb-0 sc-insights",
		children: [
			i(J(t("%s times"), n.ratio.toFixed(1)), J(t("as many deprivations among the selected (%s of %s criteria) as among the others (%s)."), n.mean_sel.toFixed(1), n.n_criteria, n.mean_not.toFixed(1))),
			i(cm(n.concentration), J(t("of all deprivations are held by the %s of households selected."), cm(n.share))),
			!r || !G(r.spearman) ? /* @__PURE__ */ (0, R.jsx)("li", { children: t("Rank agreement across resamples: run the stability check.") }) : i(lm(r.spearman), t("rank agreement across resamples (Spearman): how far the order of households holds when the data change."))
		]
	});
}
function Em({ show: e, children: t }) {
	return /* @__PURE__ */ (0, R.jsxs)(Gp, {
		show: e,
		children: [
			/* @__PURE__ */ (0, R.jsx)(na, { size: 13 }),
			" ",
			t
		]
	});
}
//#endregion
//#region src/components/Figures.tsx
var Dm = {
	blue: "#0A6EB4",
	cyan: "#26bde2",
	amber: "#f7b825",
	green: "#3f7e44",
	red: "#c5192d",
	grey: "#8a96a3",
	slate: "#5b6b7c"
}, Om = [
	Dm.blue,
	Dm.cyan,
	Dm.amber,
	Dm.green,
	Dm.red,
	Dm.grey
], km = (e) => typeof e.share == "number" && isFinite(e.share);
function Am({ tiles: e, maxRings: t = 5 }) {
	if (!e?.length) return null;
	let n = e.filter(km).slice(0, t), r = e.filter((e) => !n.includes(e));
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [r.length > 0 && /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-figs tw-figs-cards",
		children: r.map((e) => /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-tile",
			"data-key": e.label,
			title: e.sub ?? "",
			children: [
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-tile-label",
					children: e.label
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-tile-value",
					children: e.value
				}),
				e.sub ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-tile-sub",
					children: e.sub
				}) : null
			]
		}, e.label))
	}), n.length > 0 && /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-figs",
		children: n.map((e) => /* @__PURE__ */ (0, R.jsx)(jm, { tile: e }, e.label))
	})] });
}
function jm({ tile: e }) {
	let t = 2 * Math.PI * 26, n = Math.max(0, Math.min(1, e.share ?? 0)) * t;
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-donut",
		title: e.sub ?? "",
		children: [/* @__PURE__ */ (0, R.jsxs)("svg", {
			viewBox: "0 0 64 64",
			width: 64,
			height: 64,
			role: "img",
			"aria-label": `${e.label}: ${e.value}`,
			children: [
				/* @__PURE__ */ (0, R.jsx)("circle", {
					cx: "32",
					cy: "32",
					r: 26,
					fill: "none",
					stroke: "rgba(128,128,128,.18)",
					strokeWidth: "6"
				}),
				/* @__PURE__ */ (0, R.jsx)("circle", {
					cx: "32",
					cy: "32",
					r: 26,
					fill: "none",
					stroke: Dm.blue,
					strokeWidth: "6",
					strokeLinecap: "round",
					strokeDasharray: `${n} ${t - n}`,
					transform: "rotate(-90 32 32)"
				}),
				/* @__PURE__ */ (0, R.jsx)("text", {
					x: "32",
					y: "36.5",
					textAnchor: "middle",
					style: {
						font: "700 13px Commissioner, system-ui, sans-serif",
						fill: "currentColor"
					},
					children: e.value
				})
			]
		}), /* @__PURE__ */ (0, R.jsx)("div", {
			className: "tw-donut-label",
			children: e.label
		})]
	});
}
function Y({ title: e, sub: t }) {
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "wfp-empty text-center text-muted py-4",
		children: [/* @__PURE__ */ (0, R.jsx)("div", {
			className: "fw-semibold",
			children: e
		}), t ? /* @__PURE__ */ (0, R.jsx)("div", {
			className: "small mt-1",
			children: t
		}) : null]
	});
}
var Mm = (e, t = 0) => `${(100 * e).toFixed(t)}%`, Nm = (e) => Math.round(e).toLocaleString("en-US");
//#endregion
//#region src/pages/design/StepCriteria.tsx
k();
function Pm({ flow: e, mode: t, t: n }) {
	let r = L(W("sc_criteria")), [i, a] = O(""), o = t === "none", s = D(null);
	return V(W("sc_criteria"), s), V(W("sc_pmt_numeric"), s), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-step",
		ref: s,
		children: [
			/* @__PURE__ */ (0, R.jsx)(Up, {
				show: !!e && e.gates.screening,
				text: n("Screening compares each variable with the vulnerability framework, so set it first."),
				btn: "back_to_outcome",
				label: n("Back to Vulnerability Framework")
			}),
			/* @__PURE__ */ (0, R.jsxs)(K, {
				when: !o,
				children: [
					/* @__PURE__ */ (0, R.jsx)("p", {
						className: "sc-lead",
						children: n("Every yes/no variable of the data, tested against the vulnerability framework. The ones associated with vulnerability come ticked in Use, except the weaker of any two that repeat each other. Adjust the ticks and continue to the model.")
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-settings",
						children: [
							/* @__PURE__ */ (0, R.jsx)(mf, {
								id: W("qs_alpha"),
								value: .05,
								min: .001,
								max: .5,
								step: .005,
								label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
									n("Significance level"),
									" ",
									/* @__PURE__ */ (0, R.jsx)(q, { children: n("A variable counts as associated when its adjusted p-value is below this level. 0.05 is the usual choice.") })
								] })
							}),
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: W("qs_adjust"),
								value: "BH",
								clearable: !1,
								choices: [
									{
										value: "BH",
										label: "Benjamini-Hochberg"
									},
									{
										value: "bonferroni",
										label: "Bonferroni"
									},
									{
										value: "holm",
										label: "Holm"
									},
									{
										value: "none",
										label: n("None")
									}
								],
								label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
									n("Multiplicity adjustment"),
									" ",
									/* @__PURE__ */ (0, R.jsx)(q, { children: /* @__PURE__ */ (0, R.jsx)(zp, {
										title: n("Testing many variables at once finds some by chance"),
										items: [
											{
												name: "Benjamini-Hochberg.",
												text: n("Controls the share of false findings among those declared associated. Recommended."),
												ref: "Benjamini & Hochberg (1995), JRSS B 57(1)."
											},
											{
												name: "Bonferroni / Holm.",
												text: n("Control the chance of even one false finding: stricter, fewer associations."),
												ref: "Holm (1979), Scandinavian Journal of Statistics 6(2)."
											},
											{
												name: n("None."),
												text: n("No correction; expect false findings when there are many variables.")
											}
										]
									}) })
								] })
							}),
							/* @__PURE__ */ (0, R.jsx)(mf, {
								id: W("corr_cutoff"),
								value: .8,
								min: .3,
								max: 1,
								step: .05,
								label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
									n("Overlap above |r|"),
									" ",
									/* @__PURE__ */ (0, R.jsx)(q, { children: n("Two variables correlated above this value say nearly the same thing. The weaker of the pair starts unticked, so one effect is not counted twice in the score.") })
								] })
							}),
							/* @__PURE__ */ (0, R.jsx)(B, {
								id: W("qs_run"),
								label: n("Run the tests"),
								icon: /* @__PURE__ */ (0, R.jsx)(Xr, { size: 13 }),
								variant: "outline-primary",
								size: "md",
								className: "sc-row-btn"
							})
						]
					}),
					e?.qs_stale ? /* @__PURE__ */ (0, R.jsxs)(Gp, {
						show: !0,
						children: [
							/* @__PURE__ */ (0, R.jsx)(na, { size: 14 }),
							" ",
							n("The settings changed since the tests were run: click Run the tests to apply them.")
						]
					}) : /* @__PURE__ */ (0, R.jsx)("div", {
						className: "small text-muted mb-1",
						children: n("Change the settings, then Run the tests: running again resets the Use ticks.")
					})
				]
			}),
			/* @__PURE__ */ (0, R.jsx)(K, {
				when: o,
				children: /* @__PURE__ */ (0, R.jsx)("p", {
					className: "sc-lead",
					children: n("Every yes/no variable of the data. Without an outcome nothing is tested: tick the criteria that describe vulnerability in this context (for deprivation counting, so that 'yes' means deprived). Variables met by 5% to 95% of households come ticked, except the weaker of any two that repeat each other.")
				})
			}),
			/* @__PURE__ */ (0, R.jsx)(H, {
				className: "sc-crit-card",
				title: n("Candidate criteria"),
				icon: /* @__PURE__ */ (0, R.jsx)(Jn, { size: 15 }),
				actions: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)("span", {
					title: n("Turn variables with several answers or numbers into yes/no, with the split that separates vulnerable households best. The new variables join this table."),
					children: /* @__PURE__ */ (0, R.jsx)(ap, {
						ns: W("calc"),
						t: n
					})
				}), /* @__PURE__ */ (0, R.jsx)(B, {
					id: W("open_corr"),
					label: n("Correlations"),
					icon: /* @__PURE__ */ (0, R.jsx)(Wn, { size: 13 }),
					variant: "outline-secondary",
					title: n("Correlation matrix and descriptive statistics of the ticked variables.")
				})] }),
				children: r ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "sc-crit-bar",
					children: [/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-strip",
						children: [
							/* @__PURE__ */ (0, R.jsxs)("span", { children: [
								/* @__PURE__ */ (0, R.jsx)("strong", { children: r.n }),
								" ",
								n("variables")
							] }),
							r.nof ? null : /* @__PURE__ */ (0, R.jsxs)("span", { children: [
								/* @__PURE__ */ (0, R.jsx)("strong", { children: r.associated }),
								" ",
								n("associated")
							] }),
							/* @__PURE__ */ (0, R.jsxs)("span", { children: [
								/* @__PURE__ */ (0, R.jsx)("strong", { children: r.repeating }),
								" ",
								n("repeating another")
							] }),
							/* @__PURE__ */ (0, R.jsxs)("span", {
								className: "is-key",
								children: [
									/* @__PURE__ */ (0, R.jsx)("strong", { children: e?.nav.screening.n ?? 0 }),
									" ",
									n("ticked")
								]
							})
						]
					}), /* @__PURE__ */ (0, R.jsx)("div", {
						className: "sc-crit-right",
						children: /* @__PURE__ */ (0, R.jsxs)("label", {
							className: "tw-search sc-search",
							children: [/* @__PURE__ */ (0, R.jsx)(gi, { size: 13 }), /* @__PURE__ */ (0, R.jsx)("input", {
								type: "search",
								className: "form-control form-control-sm",
								placeholder: n("Search variables"),
								"aria-label": n("Search variables"),
								value: i,
								onChange: (e) => a(e.target.value)
							})]
						})
					})]
				}), /* @__PURE__ */ (0, R.jsx)(Lm, {
					crit: r,
					q: i,
					t: n
				})] }) : /* @__PURE__ */ (0, R.jsx)(Y, {
					title: n("No variables yet"),
					sub: n("Set the vulnerability framework: the table fills by itself.")
				})
			}),
			/* @__PURE__ */ (0, R.jsx)(K, {
				when: t === "pmt",
				children: /* @__PURE__ */ (0, R.jsx)(Vm, { t: n })
			}),
			/* @__PURE__ */ (0, R.jsxs)("details", {
				className: "sc-details small",
				children: [/* @__PURE__ */ (0, R.jsx)("summary", { children: /* @__PURE__ */ (0, R.jsx)("strong", { children: n("How to read this table") }) }), /* @__PURE__ */ (0, R.jsxs)("ul", {
					className: "mt-2 mb-0",
					children: [
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							/* @__PURE__ */ (0, R.jsx)("strong", { children: n("Among vulnerable / among others") }),
							": ",
							n("the share of households meeting the criterion in each outcome group. More common among the vulnerable: an inclusion criterion; less common: an exclusion criterion.")
						] }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							/* @__PURE__ */ (0, R.jsx)("strong", { children: n("Odds ratio and adjusted p") }),
							": ",
							n("each variable is tested alone with a one-criterion logistic regression and a likelihood-ratio test (Fisher's exact test when that model cannot be estimated). The p-values are adjusted for testing many variables. ↑ associated with vulnerability, ↓ associated with not being vulnerable.")
						] }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							/* @__PURE__ */ (0, R.jsx)("strong", { children: n("Overlaps with") }),
							": ",
							n("the associated variable it correlates with most. Above the cut-off, the weaker of the pair starts unticked.")
						] }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							/* @__PURE__ */ (0, R.jsx)("strong", { children: n("Missing") }),
							": ",
							n("households with no answer. Above about 20%, check the question: in the score a missing answer counts as 'no'.")
						] }),
						o ? /* @__PURE__ */ (0, R.jsx)("li", { children: n("Without an outcome every yes/no variable is listed except names and identifiers: outcome indicators and what a registration team cannot observe may rank households too, but a criterion the registration cannot collect cannot be applied in Beneficiary Selection.") }) : /* @__PURE__ */ (0, R.jsx)("li", { children: n("Every variable listed is observable at registration and not an outcome indicator (checked automatically; the others are listed below).") }),
						/* @__PURE__ */ (0, R.jsx)("li", { children: n("A variable with no clear association alone can still matter next to others: keep what field knowledge supports, the model gives each its net weight.") })
					]
				})]
			}),
			/* @__PURE__ */ (0, R.jsxs)("details", {
				className: "sc-details small",
				onToggle: (e) => {
					e.target.open && window.dispatchEvent(new Event("resize"));
				},
				children: [/* @__PURE__ */ (0, R.jsx)("summary", { children: /* @__PURE__ */ (0, R.jsxs)("strong", { children: [
					/* @__PURE__ */ (0, R.jsx)(bi, { size: 14 }),
					" ",
					n("Columns that cannot be criteria")
				] }) }), /* @__PURE__ */ (0, R.jsx)("div", {
					className: "pt-2",
					children: /* @__PURE__ */ (0, R.jsx)(fm, { t: n })
				})]
			}),
			/* @__PURE__ */ (0, R.jsx)(Wp, {
				back: "nav_back_screening",
				backLabel: n("Back to Vulnerability Framework"),
				nav: e?.nav.screening,
				next: "nav_next_screening",
				nextLabel: `${n("Continue to the model")} (${e?.nav.screening.n ?? 0})`,
				t: n
			})
		]
	});
}
function Fm({ ids: e, t }) {
	let n = Qp(e), r = D(null);
	return E(() => {
		r.current && (r.current.indeterminate = n === "some");
	}, [n]), /* @__PURE__ */ (0, R.jsxs)("label", {
		className: "sc-use-all",
		title: t(n === "all" ? "Untick Use for every variable shown" : "Tick Use for every variable shown"),
		children: [/* @__PURE__ */ (0, R.jsx)("input", {
			ref: r,
			type: "checkbox",
			className: "form-check-input sc-tick",
			checked: n === "all",
			"aria-label": t("Tick Use for every variable shown"),
			onChange: () => Jp(e, n !== "all")
		}), /* @__PURE__ */ (0, R.jsx)("span", { children: t("Use") })]
	});
}
function Im(e, t, n) {
	let r = t.trim().toLowerCase();
	return e.rows.filter((e) => !r || `${e.criterion} ${n.label(e.criterion) ?? ""}`.toLowerCase().includes(r)).map((e) => e.id);
}
function Lm({ crit: e, q: t, t: n }) {
	let r = rf(), i = _e(() => {
		let n = t.trim().toLowerCase();
		return n ? new Set(e.rows.filter((e) => !`${e.criterion} ${r.label(e.criterion) ?? ""}`.toLowerCase().includes(n)).map((e) => e.id)) : /* @__PURE__ */ new Set();
	}, [
		t,
		e,
		r
	]), a = e.rows.length - i.size;
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "wfp-model-table-wrap sc-crit-wrap",
		children: /* @__PURE__ */ (0, R.jsxs)("table", {
			className: "wfp-model-table sc-crit",
			children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
				/* @__PURE__ */ (0, R.jsx)("th", {
					className: "text-center",
					children: /* @__PURE__ */ (0, R.jsx)(Fm, {
						ids: Im(e, t, r),
						t: n
					})
				}),
				/* @__PURE__ */ (0, R.jsx)("th", { children: n("Variable") }),
				e.nof ? /* @__PURE__ */ (0, R.jsx)("th", {
					className: "num",
					children: n("Households yes")
				}) : /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "num",
						children: n("Among vulnerable")
					}),
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "num",
						children: n("Among others")
					}),
					/* @__PURE__ */ (0, R.jsx)("th", { children: n("Odds ratio") }),
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "num",
						children: n("Adjusted p")
					})
				] }),
				/* @__PURE__ */ (0, R.jsx)("th", { children: n("Overlaps with") }),
				/* @__PURE__ */ (0, R.jsx)("th", {
					className: "num",
					children: n("Missing")
				})
			] }) }), /* @__PURE__ */ (0, R.jsxs)("tbody", { children: [e.rows.map((t) => /* @__PURE__ */ (0, R.jsx)(Rm, {
				r: t,
				nof: e.nof,
				stamp: e.stamp,
				hidden: i.has(t.id),
				label: r.label(t.criterion),
				t: n
			}, t.id)), a ? null : /* @__PURE__ */ (0, R.jsx)("tr", { children: /* @__PURE__ */ (0, R.jsx)("td", {
				colSpan: 8,
				className: "text-center text-muted small py-3",
				children: n("No variable matches.")
			}) })] })]
		})
	});
}
function Rm({ r: e, nof: t, stamp: n, hidden: r, label: i, t: a }) {
	let o = e.p, s = !e.testable && !G(o) ? /* @__PURE__ */ (0, R.jsx)("span", {
		className: "text-muted",
		children: "–"
	}) : e.testable ? e.sig ? /* @__PURE__ */ (0, R.jsxs)("strong", {
		className: e.dir === "inclusion" ? "sc-up" : "sc-down",
		children: [e.dir === "inclusion" ? "↑ " : "↓ ", zm(o)]
	}) : /* @__PURE__ */ (0, R.jsx)("span", {
		className: "text-muted",
		children: zm(o)
	}) : /* @__PURE__ */ (0, R.jsx)("span", {
		className: "text-muted",
		children: a("not testable")
	});
	return /* @__PURE__ */ (0, R.jsxs)("tr", {
		style: r ? { display: "none" } : void 0,
		className: e.sig ? "is-sig" : void 0,
		children: [
			/* @__PURE__ */ (0, R.jsx)("td", {
				className: "text-center",
				children: /* @__PURE__ */ (0, R.jsx)($p, {
					id: e.id,
					value: e.use,
					stamp: n,
					label: `${a("Use")} ${e.criterion}`
				})
			}),
			/* @__PURE__ */ (0, R.jsxs)("td", {
				className: "tw-var",
				"data-tw": "1",
				children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: e.criterion }), i ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-cell-label",
					children: i
				}) : null]
			}),
			t ? /* @__PURE__ */ (0, R.jsx)("td", {
				className: "num",
				children: /* @__PURE__ */ (0, R.jsx)(Bm, { v: e.yes })
			}) : /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: /* @__PURE__ */ (0, R.jsx)(Bm, {
						v: e.vuln,
						tone: "vuln"
					})
				}),
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: /* @__PURE__ */ (0, R.jsx)(Bm, {
						v: e.other,
						tone: "other"
					})
				}),
				/* @__PURE__ */ (0, R.jsx)("td", { children: /* @__PURE__ */ (0, R.jsx)(Rp, {
					or: e.or,
					lo: e.or_low,
					hi: e.or_high
				}) }),
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: s
				})
			] }),
			/* @__PURE__ */ (0, R.jsx)("td", {
				className: "small",
				children: e.overlap ? /* @__PURE__ */ (0, R.jsx)("span", {
					className: e.overlap.high ? "text-danger" : "text-muted",
					children: e.overlap.text
				}) : "–"
			}),
			/* @__PURE__ */ (0, R.jsx)("td", {
				className: `num${G(e.missing) && e.missing > .2 ? " text-warning" : ""}`,
				children: Ap(e.missing)
			})
		]
	});
}
var zm = (e) => G(e) ? e < 1e-4 ? "< 0.0001" : e.toFixed(4) : "–";
function Bm({ v: e, tone: t }) {
	return /* @__PURE__ */ (0, R.jsxs)("span", {
		className: `sc-share${t ? " is-" + t : ""}`,
		children: [/* @__PURE__ */ (0, R.jsx)("span", {
			className: "sc-share-num",
			children: Ap(e)
		}), /* @__PURE__ */ (0, R.jsx)("span", {
			className: "sc-share-bar",
			children: /* @__PURE__ */ (0, R.jsx)("span", { style: { width: `${G(e) ? Math.max(0, Math.min(1, e)) * 100 : 0}%` } })
		})]
	});
}
function Vm({ t: e }) {
	let t = L(W("sc_pmt_numeric"));
	return /* @__PURE__ */ (0, R.jsxs)(H, {
		title: e("Numeric proxies"),
		icon: /* @__PURE__ */ (0, R.jsx)(Jn, { size: 15 }),
		children: [/* @__PURE__ */ (0, R.jsx)("p", {
			className: "small text-muted mb-2",
			children: e("A PMT also uses numbers as they are: household size (usually the strongest proxy), rooms, members by age, years of education. Each gets points per unit; a missing value takes the average. The yes/no variables ticked above are used too; tick the numbers to use here.")
		}), t ? /* @__PURE__ */ (0, R.jsx)("div", {
			className: "wfp-model-table-wrap",
			children: /* @__PURE__ */ (0, R.jsxs)("table", {
				className: "wfp-model-table",
				children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "text-center",
						children: e("Use")
					}),
					/* @__PURE__ */ (0, R.jsx)("th", { children: e("Proxy") }),
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "num",
						children: e("Average")
					}),
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "num",
						children: e("Missing")
					}),
					/* @__PURE__ */ (0, R.jsxs)("th", {
						className: "num",
						children: [
							e("Correlation with log welfare"),
							" ",
							/* @__PURE__ */ (0, R.jsx)(q, { children: e("Negative: households with more of it are poorer (an inclusion proxy, as household size usually is).") })
						]
					})
				] }) }), /* @__PURE__ */ (0, R.jsx)("tbody", { children: t.rows.map((n) => /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
					/* @__PURE__ */ (0, R.jsx)("td", {
						className: "text-center",
						children: /* @__PURE__ */ (0, R.jsx)($p, {
							id: n.id,
							value: n.use,
							stamp: t.stamp,
							label: `${e("Use")} ${n.proxy}`
						})
					}),
					/* @__PURE__ */ (0, R.jsx)("td", {
						className: "tw-var",
						children: /* @__PURE__ */ (0, R.jsx)("strong", { children: n.proxy })
					}),
					/* @__PURE__ */ (0, R.jsx)("td", {
						className: "num",
						children: G(n.mean) ? n.mean.toFixed(2) : "–"
					}),
					/* @__PURE__ */ (0, R.jsx)("td", {
						className: "num",
						children: Ap(n.missing)
					}),
					/* @__PURE__ */ (0, R.jsx)("td", {
						className: "num",
						children: G(n.r) ? `${n.r >= 0 ? "+" : ""}${n.r.toFixed(2)}` : "–"
					})
				] }, n.id)) })]
			})
		}) : /* @__PURE__ */ (0, R.jsx)("div", {
			className: "small text-muted",
			children: e("Validate the welfare setup (Vulnerability Framework) to list the numeric proxies.")
		})]
	});
}
//#endregion
//#region src/pages/design/StepModel.tsx
k();
var Hm = (e) => [
	{
		value: "none",
		label: e("No stepwise")
	},
	{
		value: "backward",
		label: e("Backward")
	},
	{
		value: "forward",
		label: e("Forward")
	},
	{
		value: "both",
		label: e("Both directions")
	}
];
function Um({ flow: e, meta: t, mode: n, t: r }) {
	let i = I(W("model_method")) ?? "logit", a = I(W("stepwise")) ?? "none", [o, s] = O(!1), c = n === "none", l = n === "pmt", u = !c || !!t?.axes.includes(i) || !!t?.clusters.includes(i), d = e?.fit, f = D(null);
	for (let e of [
		"sc_estimates",
		"sc_comparison",
		"sc_fit",
		"sc_profiles"
	]) V(W(e), f);
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-step",
		ref: f,
		children: [
			/* @__PURE__ */ (0, R.jsx)("p", {
				className: "sc-lead",
				children: r("Fit a model on the retained criteria and turn it into points. Adjust any weight where local knowledge says the model is wrong -- the reference analysis does exactly this.")
			}),
			/* @__PURE__ */ (0, R.jsx)(Up, {
				show: !!e && e.gates.weights,
				text: r("Weights come from a model fitted on the chosen criteria, so choose them first."),
				btn: "back_to_criteria",
				label: r("Back to Criteria")
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-band",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-band-group",
						children: [
							/* @__PURE__ */ (0, R.jsxs)("div", {
								className: "sc-band-label",
								children: ["1. ", r("Model")]
							}),
							/* @__PURE__ */ (0, R.jsxs)("div", {
								className: "sc-model-row",
								children: [/* @__PURE__ */ (0, R.jsx)(z, {
									id: W("model_method"),
									value: "logit",
									clearable: !1,
									className: "flex-grow-1",
									choices: t?.models.outcome,
									label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
										r("Model"),
										" ",
										/* @__PURE__ */ (0, R.jsx)(Wm, { t: r })
									] })
								}), /* @__PURE__ */ (0, R.jsx)(K, {
									when: u,
									className: "sc-model-gear",
									children: /* @__PURE__ */ (0, R.jsx)(B, {
										id: W("model_params"),
										icon: /* @__PURE__ */ (0, R.jsx)(Ai, { size: 14 }),
										variant: "outline-secondary",
										title: r("Settings of this model")
									})
								})]
							}),
							/* @__PURE__ */ (0, R.jsxs)(K, {
								when: !!e?.params,
								className: "sc-params-line",
								children: [
									/* @__PURE__ */ (0, R.jsx)(Ai, { size: 12 }),
									" ",
									/* @__PURE__ */ (0, R.jsx)("span", { children: e?.params ?? "" }),
									" ",
									"·",
									" ",
									/* @__PURE__ */ (0, R.jsx)(B, {
										id: W("model_params2"),
										label: r("change"),
										link: !0
									})
								]
							}),
							/* @__PURE__ */ (0, R.jsx)(K, {
								when: n === "outcome",
								children: /* @__PURE__ */ (0, R.jsx)(z, {
									id: W("model_scheme"),
									value: "odds_ratio",
									clearable: !1,
									choices: t?.schemes,
									label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
										r("Weighting scheme"),
										" ",
										/* @__PURE__ */ (0, R.jsx)(q, { children: r("How model coefficients become points: odds ratios (APP-FA reference), log-odds, whole points out of 10, or 1 point per criterion.") })
									] })
								})
							}),
							/* @__PURE__ */ (0, R.jsx)(K, {
								when: c,
								className: "small text-muted",
								children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: W("unsup_note") })
							}),
							/* @__PURE__ */ (0, R.jsx)(K, {
								when: l,
								className: "small text-muted",
								children: r("Points: 100 × each proxy's coefficient on log welfare per person, so one point is about 1% less predicted welfare; a numeric proxy scores per unit.")
							})
						]
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-band-group",
						children: [/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "sc-band-label",
							children: ["2. ", r("Criteria and data")]
						}), /* @__PURE__ */ (0, R.jsx)(z, {
							id: W("fit_criteria"),
							label: r("Criteria in the model"),
							multiple: !0,
							actions: !0,
							placeholder: r("Nothing selected")
						})]
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-band-group",
						children: [
							/* @__PURE__ */ (0, R.jsxs)("div", {
								className: "sc-band-label",
								children: ["3. ", r(c ? "Orientation" : "Comparison")]
							}),
							/* @__PURE__ */ (0, R.jsx)(K, {
								when: c,
								children: /* @__PURE__ */ (0, R.jsx)(z, {
									id: W("anchor"),
									value: "",
									clearable: !1,
									choices: [{
										value: "",
										label: r("(none: more criteria met = more vulnerable)")
									}],
									label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
										r("Anchor criterion (optional)"),
										" ",
										/* @__PURE__ */ (0, R.jsx)(q, { children: r("Sets the direction of the ranking: a PCA or MCA axis has no direction of its own, so the index is turned so that this criterion raises it, and the cluster profiles are ranked on it. Choose a criterion that clearly marks vulnerability here. With none, more criteria met means more vulnerable (tick criteria so that yes = deprived). Deprivation counting does not use it.") })
									] })
								})
							}),
							/* @__PURE__ */ (0, R.jsxs)("button", {
								type: "button",
								className: "btn btn-outline-secondary btn-sm w-100",
								onClick: () => s(!0),
								children: [
									/* @__PURE__ */ (0, R.jsx)(Ai, { size: 13 }),
									" ",
									r("More options")
								]
							}),
							/* @__PURE__ */ (0, R.jsx)("div", {
								className: "small text-muted mt-1 mb-2",
								children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: W("fit_more_summary") })
							}),
							/* @__PURE__ */ (0, R.jsx)(B, {
								id: W("run_fit"),
								label: r("Fit model"),
								icon: /* @__PURE__ */ (0, R.jsx)(Xr, { size: 14 }),
								variant: "primary",
								size: "md",
								className: "w-100 sc-fit-btn",
								title: r("Fits the chosen model on the training households, turns it into points, and adds the fit to the run history.")
							})
						]
					})
				]
			}),
			/* @__PURE__ */ (0, R.jsx)(Kp, {
				open: o,
				onClose: () => s(!1),
				title: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					/* @__PURE__ */ (0, R.jsx)(Ai, { size: 16 }),
					" ",
					r("More options")
				] }),
				footer: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)("span", {
					className: "small text-muted me-auto",
					children: r("Applied at the next Fit.")
				}), /* @__PURE__ */ (0, R.jsx)("button", {
					type: "button",
					className: "btn btn-primary",
					onClick: () => s(!1),
					children: r("Done")
				})] }),
				children: t ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					/* @__PURE__ */ (0, R.jsx)(z, {
						id: W("model_weights"),
						value: "",
						clearable: !1,
						choices: [{
							value: "",
							label: r("(none)")
						}],
						label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
							r("Survey weights (optional)"),
							" ",
							/* @__PURE__ */ (0, R.jsx)(q, { children: r("Sampling weight column. When set, the model counts each household by its weight so the estimates represent the population, not the sample.") })
						] })
					}),
					/* @__PURE__ */ (0, R.jsx)(K, {
						when: n === "outcome",
						children: /* @__PURE__ */ (0, R.jsx)(z, {
							id: W("compare_models"),
							multiple: !0,
							actions: !0,
							choices: t.models.outcome,
							value: t.compare_default,
							label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
								r("Models to compare"),
								" ",
								/* @__PURE__ */ (0, R.jsx)(q, { children: r("Models fitted next to the chosen one: each variable's effect under every model, and each model's AUC and ROC on the held-out households. Machine-learning models are slow on large data: add them only when you need them.") })
							] })
						})
					}),
					/* @__PURE__ */ (0, R.jsx)(K, {
						when: l,
						children: /* @__PURE__ */ (0, R.jsx)(z, {
							id: W("pmt_compare"),
							multiple: !0,
							actions: !0,
							choices: t.models.pmt,
							value: t.pmt_compare_default,
							label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
								r("Models to compare"),
								" ",
								/* @__PURE__ */ (0, R.jsx)(q, { children: r("Other PMT models fitted on the same proxies and households: R-squared on held-out households, leakage and under-coverage at the line, and how both errors move with the cut-off.") })
							] })
						})
					}),
					/* @__PURE__ */ (0, R.jsxs)(K, {
						when: !c,
						className: "sc-pair",
						children: [/* @__PURE__ */ (0, R.jsx)(z, {
							id: W("stepwise"),
							value: "none",
							clearable: !1,
							choices: Hm(r),
							label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
								r("Stepwise"),
								" ",
								/* @__PURE__ */ (0, R.jsx)(q, { children: r("Selection of the criteria before fitting, for any model. Backward removes criteria from the full set, forward adds them from none, both directions adds and may remove again.") })
							] })
						}), /* @__PURE__ */ (0, R.jsx)(K, {
							when: a !== "none",
							children: /* @__PURE__ */ (0, R.jsx)(z, {
								id: W("stepwise_ic"),
								value: "aic",
								clearable: !1,
								choices: [{
									value: "aic",
									label: "AIC"
								}, {
									value: "bic",
									label: "BIC"
								}],
								label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
									r("Criterion"),
									" ",
									/* @__PURE__ */ (0, R.jsx)(q, { children: r("AIC is the usual choice; BIC penalises each criterion more (log of the sample size) and keeps fewer.") })
								] })
							})
						})]
					})
				] }) : null
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-notes small text-muted",
				children: [
					/* @__PURE__ */ (0, R.jsx)(Sf, { id: W("model_note") }),
					" ",
					/* @__PURE__ */ (0, R.jsx)(Sf, { id: W("scheme_note") }),
					" ",
					/* @__PURE__ */ (0, R.jsx)(K, {
						as: "span",
						when: !!e?.scheme_apply,
						children: /* @__PURE__ */ (0, R.jsx)(B, {
							id: W("scheme_apply"),
							label: r("Apply this scheme to the fitted model"),
							link: !0
						})
					})
				]
			}),
			/* @__PURE__ */ (0, R.jsx)(hm, { t: r }),
			/* @__PURE__ */ (0, R.jsx)(Qm, {
				t: r,
				show: !!d && !d.runs_inline
			}),
			/* @__PURE__ */ (0, R.jsx)(ym, { t: r }),
			/* @__PURE__ */ (0, R.jsx)(Gm, { t: r }),
			/* @__PURE__ */ (0, R.jsx)(gm, { t: r }),
			/* @__PURE__ */ (0, R.jsx)($m, {
				meta: t,
				t: r
			}),
			/* @__PURE__ */ (0, R.jsx)(eh, {
				fit: d ?? null,
				meta: t,
				t: r
			}),
			/* @__PURE__ */ (0, R.jsx)(Wp, {
				back: "nav_back_weights",
				backLabel: r("Back to Criteria"),
				nav: e?.nav.weights,
				next: "nav_next_weights",
				nextLabel: r("Continue to Threshold & errors"),
				t: r
			})
		]
	});
}
function Wm({ t: e }) {
	return /* @__PURE__ */ (0, R.jsx)(q, { children: /* @__PURE__ */ (0, R.jsx)(zp, {
		title: e("How the weights are estimated"),
		items: [
			{
				name: e("Logistic regression."),
				text: e("One model on all criteria; each criterion's effect is net of the others. The APP-FA reference."),
				ref: "Hosmer, Lemeshow & Sturdivant (2013), Applied Logistic Regression, 3rd ed., Wiley."
			},
			{
				name: e("Weight of evidence."),
				text: e("Each criterion's own log odds ratio. Never fails on rare or overlapping criteria, but overlaps count twice."),
				ref: "Siddiqi (2017), Intelligent Credit Scoring, 2nd ed., Wiley."
			},
			{
				name: e("Boosted stumps."),
				text: e("Gradient boosting with one split per tree: still one fixed number of points per criterion."),
				ref: "Friedman (2001), Annals of Statistics 29(5); Chen & Guestrin (2016), XGBoost, KDD."
			},
			{
				name: e("Random forest, XGBoost, naive Bayes, neural network, SVM."),
				text: e("Machine-learning models; each criterion's points are its average marginal effect on the model's log-odds, so the card stays additive. Compare their held-out AUC with the logistic card. SVM optimises a boundary rather than probabilities and can give weak points."),
				ref: "Breiman (2001); Chen & Guestrin (2016); Hastie, Tibshirani & Friedman (2009); Cortes & Vapnik (1995); Molnar (2022), Interpretable Machine Learning."
			},
			{
				name: e("Vulnerability index: PCA."),
				text: e("Not a prediction model: the first principal component of the criteria, turned so a higher index means more vulnerable; its errors are then measured against the outcome like any card. Check that the criteria share enough variation (KMO, Bartlett)."),
				ref: "Filmer & Pritchett (2001), Demography 38(1); Vyas & Kumaranayake (2006), Health Policy and Planning 21(6)."
			},
			{
				name: e("Vulnerability index: LDA."),
				text: e("Fisher's linear discriminant: the weighted sum of the criteria that best separates vulnerable from other households. Supervised like logistic regression, but assumes equal spread in both groups."),
				ref: "Fisher (1936), Annals of Eugenics 7."
			}
		]
	}) });
}
function Gm({ t: e }) {
	let t = L(W("sc_estimates")), n = um();
	return /* @__PURE__ */ (0, R.jsx)(H, {
		title: e("Model estimates"),
		icon: /* @__PURE__ */ (0, R.jsx)(Ri, { size: 15 }),
		className: "sc-est-card",
		actions: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
			/* @__PURE__ */ (0, R.jsx)(Em, {
				show: !!n?.points,
				children: e("Points edited: click Apply points.")
			}),
			/* @__PURE__ */ (0, R.jsx)(B, {
				id: W("apply_points"),
				label: e("Apply points"),
				icon: /* @__PURE__ */ (0, R.jsx)(qe, { size: 13 }),
				variant: "primary"
			}),
			/* @__PURE__ */ (0, R.jsx)(B, {
				id: W("reset_weights"),
				label: e("Reset to model values"),
				icon: /* @__PURE__ */ (0, R.jsx)(ii, { size: 13 }),
				variant: "outline-secondary"
			}),
			/* @__PURE__ */ (0, R.jsx)(bf, {
				id: W("dl_model_tables2"),
				label: e("Export (Excel)"),
				icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 13 })
			})
		] }),
		children: t ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
			t.pmt ? /* @__PURE__ */ (0, R.jsx)(Ym, {
				est: t,
				t: e
			}) : /* @__PURE__ */ (0, R.jsx)(Jm, {
				est: t,
				t: e
			}),
			t.fit_line ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "small text-muted mt-2",
				children: t.fit_line
			}) : null,
			!t.pmt && t.others.length ? /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "small text-muted mt-1",
				children: [
					e("Other models: log-odds effect of each criterion, fitted on the same training households; a dash means the model dropped it."),
					" ",
					/* @__PURE__ */ (0, R.jsx)("span", {
						className: "wfp-agree-yes",
						children: "✔"
					}),
					" ",
					e("same direction under every model,"),
					" ",
					/* @__PURE__ */ (0, R.jsx)("span", {
						className: "wfp-agree-no",
						children: "⚠"
					}),
					" ",
					e("the direction differs: worth a second look.")
				]
			}) : null,
			t.pmt ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "small text-muted mt-2",
				children: e("Inclusion: the proxy lowers predicted welfare, so it adds points. Points = 100 × |β|.")
			}) : null,
			t.rows.some((e) => G(e.p)) ? /* @__PURE__ */ (0, R.jsx)(Ip, { t: e }) : null,
			/* @__PURE__ */ (0, R.jsx)("div", {
				className: "small text-muted mt-2",
				children: e("Every criterion here is observable at registration and not an outcome indicator (Targeting Advisory 1/2025); validate them with the community before implementation.")
			})
		] }) : /* @__PURE__ */ (0, R.jsx)(Y, {
			title: e("No model yet"),
			sub: e("Set the model above, then click Fit model.")
		})
	});
}
function Km({ row: e, stamp: t, t: n }) {
	let [r, i] = qp(W(e.id), e.points, t, "tw.num"), [a, o] = O(r == null ? "" : String(r));
	E(() => {
		r == null ? a !== "" && !isNaN(Number(a)) && o("") : Number(a) !== r && o(String(r));
	}, [r]);
	let s = G(e.points) && G(r) && Math.abs(r - e.points) > 1e-9;
	return /* @__PURE__ */ (0, R.jsx)("input", {
		type: "number",
		className: `form-control form-control-sm sc-points${s ? " is-edited" : ""}`,
		min: 0,
		step: .01,
		value: a,
		"aria-label": `${n("Points")} ${e.criterion}`,
		onChange: (e) => {
			o(e.target.value);
			let t = e.target.value === "" ? null : Number(e.target.value);
			(t === null || !isNaN(t)) && i(t);
		}
	});
}
var qm = (e, t) => G(e) ? `${e >= 0 ? "+" : ""}${e.toFixed(t)}` : "-";
function Jm({ est: e, t }) {
	let n = e.others, r = n.length + +!!e.has_imp + 1, i = (t) => e.rows.some((e) => G(e[t])), [a, o, s] = [
		i("se"),
		i("or"),
		i("p")
	], c = 4 + +!!a + +!!o + +!!s;
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "wfp-model-table-wrap",
		children: /* @__PURE__ */ (0, R.jsxs)("table", {
			className: "wfp-model-table sc-est",
			children: [/* @__PURE__ */ (0, R.jsxs)("thead", { children: [n.length ? /* @__PURE__ */ (0, R.jsxs)("tr", {
				className: "wfp-grp-row",
				children: [/* @__PURE__ */ (0, R.jsx)("th", {
					colSpan: c,
					children: t("Chosen model")
				}), /* @__PURE__ */ (0, R.jsx)("th", {
					colSpan: r,
					className: "wfp-oth-first",
					children: t("Under the other models (log-odds)")
				})]
			}) : null, /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
				/* @__PURE__ */ (0, R.jsx)("th", { children: t("Criterion") }),
				/* @__PURE__ */ (0, R.jsx)("th", {
					className: "num",
					style: { textTransform: "none" },
					children: "β"
				}),
				a ? /* @__PURE__ */ (0, R.jsx)("th", {
					className: "num",
					children: "SE"
				}) : null,
				o ? /* @__PURE__ */ (0, R.jsx)("th", { children: t("Odds ratio (95% CI)") }) : null,
				s ? /* @__PURE__ */ (0, R.jsx)("th", {
					className: "num",
					children: "p"
				}) : null,
				/* @__PURE__ */ (0, R.jsx)("th", { children: t("Direction") }),
				/* @__PURE__ */ (0, R.jsx)("th", {
					className: "num",
					children: t("Points")
				}),
				n.map((e, t) => /* @__PURE__ */ (0, R.jsx)("th", {
					className: `num${t === 0 ? " wfp-oth-first" : ""}`,
					children: e
				}, e)),
				e.has_imp ? /* @__PURE__ */ (0, R.jsx)("th", {
					className: "num",
					children: t("RF importance")
				}) : null,
				n.length ? /* @__PURE__ */ (0, R.jsx)("th", {
					className: "text-center",
					children: t("Agree")
				}) : null
			] })] }), /* @__PURE__ */ (0, R.jsx)("tbody", { children: e.rows.map((r) => /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "tw-var",
					children: /* @__PURE__ */ (0, R.jsx)("strong", { children: r.criterion })
				}),
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: qm(r.beta, 3)
				}),
				a ? /* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: G(r.se) ? r.se.toFixed(3) : "-"
				}) : null,
				o ? /* @__PURE__ */ (0, R.jsx)("td", { children: /* @__PURE__ */ (0, R.jsx)(Rp, {
					or: r.or,
					lo: r.or_low,
					hi: r.or_high
				}) }) : null,
				s ? /* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: /* @__PURE__ */ (0, R.jsx)(Fp, { p: r.p })
				}) : null,
				/* @__PURE__ */ (0, R.jsx)("td", { children: /* @__PURE__ */ (0, R.jsx)(Lp, {
					d: r.dir,
					t
				}) }),
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: /* @__PURE__ */ (0, R.jsx)(Km, {
						row: r,
						stamp: e.stamp,
						t
					})
				}),
				n.map((e, t) => {
					let n = r.others[t];
					return /* @__PURE__ */ (0, R.jsx)("td", {
						className: `num${t === 0 ? " wfp-oth-first" : ""}${G(n) ? n >= 0 ? " wfp-eff-pos" : " wfp-eff-neg" : " text-muted"}`,
						children: G(n) ? qm(n, 2) : "—"
					}, e);
				}),
				e.has_imp ? /* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: G(r.imp) ? `${Math.round(100 * r.imp)}%` : "—"
				}) : null,
				n.length ? /* @__PURE__ */ (0, R.jsx)("td", {
					className: "text-center",
					children: r.agree === null ? /* @__PURE__ */ (0, R.jsx)("span", {
						className: "text-muted",
						children: "—"
					}) : r.agree ? /* @__PURE__ */ (0, R.jsx)("span", {
						className: "wfp-agree-yes",
						title: t("Same direction under every model"),
						children: "✔"
					}) : /* @__PURE__ */ (0, R.jsx)("span", {
						className: "wfp-agree-no",
						title: t("The direction differs between models: worth a second look"),
						children: "⚠"
					})
				}) : null
			] }, r.id)) })]
		})
	});
}
function Ym({ est: e, t }) {
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "wfp-model-table-wrap",
		children: /* @__PURE__ */ (0, R.jsxs)("table", {
			className: "wfp-model-table sc-est",
			children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
				/* @__PURE__ */ (0, R.jsx)("th", { children: t("Proxy") }),
				/* @__PURE__ */ (0, R.jsxs)("th", {
					className: "num",
					children: [
						"β",
						" (",
						t("log welfare"),
						")"
					]
				}),
				/* @__PURE__ */ (0, R.jsx)("th", {
					className: "num",
					children: "SE"
				}),
				/* @__PURE__ */ (0, R.jsxs)("th", {
					className: "num",
					children: [
						t("Effect on welfare"),
						" ",
						/* @__PURE__ */ (0, R.jsx)(q, { children: t("How much higher (+) or lower (-) predicted welfare per person is for a household with this characteristic, or per unit of a number, all else equal.") })
					]
				}),
				/* @__PURE__ */ (0, R.jsx)("th", {
					className: "num",
					children: "p"
				}),
				/* @__PURE__ */ (0, R.jsx)("th", { children: t("Direction") }),
				/* @__PURE__ */ (0, R.jsx)("th", {
					className: "num",
					children: t("Points")
				})
			] }) }), /* @__PURE__ */ (0, R.jsx)("tbody", { children: e.rows.map((n) => /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
				/* @__PURE__ */ (0, R.jsxs)("td", {
					className: "tw-var",
					children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: n.criterion }), n.numeric ? /* @__PURE__ */ (0, R.jsxs)("span", {
						className: "small text-muted",
						children: [
							" (",
							t("per unit"),
							")"
						]
					}) : null]
				}),
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: qm(n.beta, 4)
				}),
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: G(n.se) ? n.se.toFixed(4) : "-"
				}),
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: G(n.beta) ? `${qm(100 * (Math.exp(n.beta) - 1), 1)}%` : "-"
				}),
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: /* @__PURE__ */ (0, R.jsx)(Fp, { p: n.p })
				}),
				/* @__PURE__ */ (0, R.jsx)("td", { children: /* @__PURE__ */ (0, R.jsx)(Lp, {
					d: n.dir,
					t
				}) }),
				/* @__PURE__ */ (0, R.jsx)("td", {
					className: "num",
					children: /* @__PURE__ */ (0, R.jsx)(Km, {
						row: n,
						stamp: e.stamp,
						t
					})
				})
			] }, n.id)) })]
		})
	});
}
function Xm({ x: e }) {
	return G(e) ? /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "wfp-auc",
		children: [/* @__PURE__ */ (0, R.jsx)("span", {
			className: "wfp-auc-bar",
			style: { width: `${Math.round(100 * Math.max(0, (e - .5) / .5))}%` }
		}), /* @__PURE__ */ (0, R.jsx)("span", {
			className: "wfp-auc-num",
			children: e.toFixed(3)
		})]
	}) : /* @__PURE__ */ (0, R.jsx)("span", {
		className: "text-muted",
		children: "-"
	});
}
function Zm({ r: e, t }) {
	return e.current ? /* @__PURE__ */ (0, R.jsxs)("span", {
		className: "wfp-kept",
		children: [
			"✓",
			" ",
			t("shown")
		]
	}) : /* @__PURE__ */ (0, R.jsxs)("span", {
		className: "d-inline-flex gap-1",
		children: [/* @__PURE__ */ (0, R.jsx)("button", {
			type: "button",
			className: "btn btn-outline-primary btn-sm",
			onClick: () => em(W("restore_run"), e.id),
			children: t("Restore")
		}), /* @__PURE__ */ (0, R.jsx)("button", {
			type: "button",
			className: "btn btn-outline-danger btn-sm",
			title: t("Remove this fit from the history"),
			"aria-label": t("Remove this fit from the history"),
			onClick: () => em(W("delete_run"), e.id),
			children: /* @__PURE__ */ (0, R.jsx)(ea, { size: 13 })
		})]
	});
}
function Qm({ show: e, t }) {
	let n = L(W("sc_comparison"));
	return !e || !n || !n.runs.length ? null : /* @__PURE__ */ (0, R.jsxs)("details", {
		className: "sc-runs",
		open: !0,
		children: [/* @__PURE__ */ (0, R.jsxs)("summary", { children: [
			`${t(n.title)} (${n.runs.length} ${n.runs.length === 1 ? t("fit") : t("fits")})`,
			" ",
			"—",
			" ",
			t("best highlighted")
		] }), /* @__PURE__ */ (0, R.jsx)("div", {
			className: "wfp-model-table-wrap mt-2",
			children: /* @__PURE__ */ (0, R.jsxs)("table", {
				className: "wfp-model-table",
				children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
					/* @__PURE__ */ (0, R.jsx)("th", { children: t("Run") }),
					/* @__PURE__ */ (0, R.jsx)("th", { children: t("Model") }),
					/* @__PURE__ */ (0, R.jsx)("th", { children: t("Scheme") }),
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "num",
						children: t("Criteria")
					}),
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "num",
						children: "AUC"
					}),
					/* @__PURE__ */ (0, R.jsx)("th", {})
				] }) }), /* @__PURE__ */ (0, R.jsx)("tbody", { children: n.runs.map((e) => /* @__PURE__ */ (0, R.jsxs)("tr", {
					className: `${e.current ? "is-current" : ""} ${e.best ? "is-best" : ""}`,
					children: [
						/* @__PURE__ */ (0, R.jsxs)("td", { children: [
							/* @__PURE__ */ (0, R.jsxs)("strong", { children: ["#", e.id] }),
							" ",
							/* @__PURE__ */ (0, R.jsx)("span", {
								className: "text-muted small ms-1",
								children: e.at
							})
						] }),
						/* @__PURE__ */ (0, R.jsx)("td", { children: e.model }),
						/* @__PURE__ */ (0, R.jsx)("td", { children: t(e.scheme) }),
						/* @__PURE__ */ (0, R.jsx)("td", {
							className: "num",
							children: e.criteria
						}),
						/* @__PURE__ */ (0, R.jsx)("td", {
							className: "num",
							children: G(e.auc) ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
								/* @__PURE__ */ (0, R.jsx)("strong", { children: e.auc.toFixed(3) }),
								" ",
								/* @__PURE__ */ (0, R.jsx)("span", {
									className: "text-muted small",
									children: e.held_out ? t("held out") : t("training")
								})
							] }) : /* @__PURE__ */ (0, R.jsxs)("span", {
								className: "text-muted",
								children: [
									"–",
									" ",
									t("no outcome")
								]
							})
						}),
						/* @__PURE__ */ (0, R.jsx)("td", { children: /* @__PURE__ */ (0, R.jsx)(Zm, {
							r: e,
							t
						}) })
					]
				}, e.id)) })]
			})
		})]
	});
}
function $m({ meta: e, t }) {
	let n = L(W("sc_comparison"));
	if (!n || n.kind === "none") return null;
	if (n.kind === "pmt") {
		let r = n.table ?? [];
		if (r.length < 2) return /* @__PURE__ */ (0, R.jsx)(H, {
			title: t("PMT model comparison"),
			icon: /* @__PURE__ */ (0, R.jsx)(oa, { size: 15 }),
			children: /* @__PURE__ */ (0, R.jsx)(Y, {
				title: t("No comparison yet"),
				sub: t("Choose other models in “Models to compare” above and fit again.")
			})
		});
		let i = Math.max(...r.map((e) => G(e.r2_test) ? e.r2_test : -Infinity)), a = (e) => G(e) ? `${(100 * e).toFixed(1)}%` : "-", o = (e, t = 3) => G(e) ? e.toFixed(t) : "-";
		return /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "sc-grid-75",
			children: [/* @__PURE__ */ (0, R.jsxs)(H, {
				title: t("PMT model comparison"),
				icon: /* @__PURE__ */ (0, R.jsx)(oa, { size: 15 }),
				children: [/* @__PURE__ */ (0, R.jsx)("div", {
					className: "wfp-model-table-wrap",
					children: /* @__PURE__ */ (0, R.jsxs)("table", {
						className: "wfp-model-table",
						children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
							/* @__PURE__ */ (0, R.jsx)("th", { children: t("Model") }),
							/* @__PURE__ */ (0, R.jsx)("th", {
								className: "num",
								children: t("Proxies")
							}),
							/* @__PURE__ */ (0, R.jsxs)("th", {
								className: "num",
								children: [
									"R²",
									" ",
									t("training")
								]
							}),
							/* @__PURE__ */ (0, R.jsxs)("th", {
								className: "num",
								children: [
									"R²",
									" ",
									t("held out")
								]
							}),
							/* @__PURE__ */ (0, R.jsx)("th", {
								className: "num",
								children: t("Leakage")
							}),
							/* @__PURE__ */ (0, R.jsx)("th", {
								className: "num",
								children: t("Under-coverage")
							}),
							/* @__PURE__ */ (0, R.jsx)("th", {
								className: "num",
								children: t("Accuracy")
							}),
							/* @__PURE__ */ (0, R.jsx)("th", {
								className: "num",
								children: "CGH"
							})
						] }) }), /* @__PURE__ */ (0, R.jsx)("tbody", { children: r.map((e, n) => {
							let r = e.r2_test === i;
							return /* @__PURE__ */ (0, R.jsxs)("tr", {
								className: r ? "is-best" : void 0,
								children: [
									/* @__PURE__ */ (0, R.jsxs)("td", { children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: String(e.model) }), r ? /* @__PURE__ */ (0, R.jsxs)("span", {
										className: "wfp-kept ms-2",
										children: [
											/* @__PURE__ */ (0, R.jsx)(oa, { size: 12 }),
											" ",
											t("best R²")
										]
									}) : null] }),
									/* @__PURE__ */ (0, R.jsx)("td", {
										className: "num",
										children: String(e.proxies ?? "")
									}),
									/* @__PURE__ */ (0, R.jsx)("td", {
										className: "num",
										children: o(e.r2_train)
									}),
									/* @__PURE__ */ (0, R.jsx)("td", {
										className: "num",
										children: o(e.r2_test)
									}),
									/* @__PURE__ */ (0, R.jsx)("td", {
										className: "num",
										children: a(e.inclusion_error)
									}),
									/* @__PURE__ */ (0, R.jsx)("td", {
										className: "num",
										children: a(e.exclusion_error)
									}),
									/* @__PURE__ */ (0, R.jsx)("td", {
										className: "num",
										children: a(e.accuracy)
									}),
									/* @__PURE__ */ (0, R.jsx)("td", {
										className: "num",
										children: o(e.cgh, 2)
									})
								]
							}, n);
						}) })]
					})
				}), /* @__PURE__ */ (0, R.jsx)("div", {
					className: "small text-muted mt-2",
					children: t("Measured on the held-out households with the cut-off at the poverty line. The best held-out R² is marked; a model with a lower R² can still have lower under-coverage (quantile regression usually does).")
				})]
			}), /* @__PURE__ */ (0, R.jsx)(Vp, {
				id: "pmt_compare_plot",
				title: t("Error trade-off by model"),
				icon: /* @__PURE__ */ (0, R.jsx)(yt, { size: 15 }),
				height: 360,
				meta: e,
				t
			})]
		});
	}
	let r = n.table ?? [], i = Math.max(...r.map((e) => G(e.auc_test) ? e.auc_test : -Infinity));
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-75",
		children: [/* @__PURE__ */ (0, R.jsxs)(H, {
			title: t("Model comparison"),
			icon: /* @__PURE__ */ (0, R.jsx)(oa, { size: 15 }),
			className: "sc-cmp-card",
			children: [
				n.why ? /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "small text-muted mb-2",
					children: [
						t("No comparison yet."),
						" ",
						t(n.why)
					]
				}) : null,
				r.length || n.runs.length ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: "wfp-model-table-wrap",
					children: /* @__PURE__ */ (0, R.jsxs)("table", {
						className: "wfp-model-table wfp-cmp",
						children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
							/* @__PURE__ */ (0, R.jsx)("th", { children: t("Model") }),
							/* @__PURE__ */ (0, R.jsx)("th", {
								className: "num",
								children: t("Criteria")
							}),
							/* @__PURE__ */ (0, R.jsx)("th", { children: t("AUC (training)") }),
							/* @__PURE__ */ (0, R.jsx)("th", { children: t("AUC (held out)") }),
							/* @__PURE__ */ (0, R.jsx)("th", {})
						] }) }), /* @__PURE__ */ (0, R.jsxs)("tbody", { children: [
							r.length ? /* @__PURE__ */ (0, R.jsx)("tr", {
								className: "wfp-band-row",
								children: /* @__PURE__ */ (0, R.jsx)("td", {
									colSpan: 5,
									children: t("This fit: the models compared")
								})
							}) : null,
							r.map((e, n) => {
								let r = e.auc_test === i;
								return /* @__PURE__ */ (0, R.jsxs)("tr", {
									className: r ? "is-best" : void 0,
									children: [
										/* @__PURE__ */ (0, R.jsxs)("td", { children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: String(e.model) }), r ? /* @__PURE__ */ (0, R.jsxs)("span", {
											className: "wfp-kept ms-2",
											children: [
												/* @__PURE__ */ (0, R.jsx)(oa, { size: 12 }),
												" ",
												t("best")
											]
										}) : null] }),
										/* @__PURE__ */ (0, R.jsx)("td", {
											className: "num",
											children: G(e.criteria) ? e.criteria : ""
										}),
										/* @__PURE__ */ (0, R.jsx)("td", { children: /* @__PURE__ */ (0, R.jsx)(Xm, { x: e.auc_train }) }),
										/* @__PURE__ */ (0, R.jsx)("td", { children: /* @__PURE__ */ (0, R.jsx)(Xm, { x: e.auc_test }) }),
										/* @__PURE__ */ (0, R.jsx)("td", {})
									]
								}, n);
							}),
							n.runs.length ? /* @__PURE__ */ (0, R.jsx)("tr", {
								className: "wfp-band-row",
								children: /* @__PURE__ */ (0, R.jsx)("td", {
									colSpan: 5,
									children: `${t(n.title)} (${n.runs.length} ${n.runs.length === 1 ? t("fit") : t("fits")})`
								})
							}) : null,
							n.runs.map((e) => /* @__PURE__ */ (0, R.jsxs)("tr", {
								className: `${e.current ? "is-current" : ""} ${e.best ? "is-best-run" : ""}`,
								children: [
									/* @__PURE__ */ (0, R.jsxs)("td", { children: [
										/* @__PURE__ */ (0, R.jsxs)("strong", { children: ["#", e.id] }),
										" ",
										e.model,
										/* @__PURE__ */ (0, R.jsxs)("div", {
											className: "text-muted small",
											children: [
												t(e.scheme),
												" ",
												"·",
												" ",
												e.at
											]
										})
									] }),
									/* @__PURE__ */ (0, R.jsx)("td", {
										className: "num",
										children: e.criteria
									}),
									/* @__PURE__ */ (0, R.jsx)("td", { children: G(e.auc) && !e.held_out ? /* @__PURE__ */ (0, R.jsx)("strong", { children: e.auc.toFixed(3) }) : /* @__PURE__ */ (0, R.jsx)("span", {
										className: "text-muted",
										children: "—"
									}) }),
									/* @__PURE__ */ (0, R.jsx)("td", { children: G(e.auc) && e.held_out ? /* @__PURE__ */ (0, R.jsx)("strong", { children: e.auc.toFixed(3) }) : /* @__PURE__ */ (0, R.jsx)("span", {
										className: "text-muted",
										children: "—"
									}) }),
									/* @__PURE__ */ (0, R.jsx)("td", { children: /* @__PURE__ */ (0, R.jsx)(Zm, {
										r: e,
										t
									}) })
								]
							}, `run${e.id}`))
						] })]
					})
				}) : null,
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "small text-muted mt-2",
					children: t("AUC on the held-out households is the honest figure. Each model is scored as the sum of its effects; if the machine-learning models barely beat the logistic one, more complex models are not needed. The gap between a model and the scorecard is the price of the weighting scheme and of flooring scores at zero.")
				})
			]
		}), /* @__PURE__ */ (0, R.jsx)(K, {
			when: !n.why,
			children: /* @__PURE__ */ (0, R.jsx)(Vp, {
				id: "comparison_roc",
				title: t("ROC, held-out households"),
				icon: /* @__PURE__ */ (0, R.jsx)(yt, { size: 15 }),
				height: 340,
				meta: e,
				t
			})
		})]
	});
}
function eh({ fit: e, meta: t, t: n }) {
	let [r, i] = O(!1), a = D(null);
	if (E(() => {
		r && Bf(a.current, !0);
	}, [
		r,
		e?.method,
		e?.index
	]), V(W("sc_diagram"), a), !e) return null;
	let o = e.index, s = (e, r, i = 480) => /* @__PURE__ */ (0, R.jsx)(Vp, {
		id: e,
		title: r,
		height: i,
		meta: t,
		t: n
	}, e), c;
	return c = e.pmt ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-2",
		children: [s("weights_plot", n("Points and direction"), 440), s("pmt_fit_plot", n("Predicted against measured welfare"), 440)]
	}), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-3",
		children: [
			s("pmt_decile_plot", n("Selected by decile of measured welfare"), 400),
			s("pmt_curve_plot", n("Leakage and under-coverage as the cut-off moves"), 400),
			s("pmt_resid_plot", n("Prediction errors (residuals)"), 400)
		]
	})] }) : o === "pca" ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-3",
		children: [
			s("weights_plot", n("Weight and direction")),
			s("pca_scree", n("Variation explained by each axis")),
			s("pca_loadings", n("Loadings on the axes kept"))
		]
	}), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-2",
		children: [s("pca_var_map", n("Variables: correlation circle, axes 1 and 2")), s("pca_ind_map", n("Households on axes 1 and 2"))]
	})] }) : o === "mca" ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-3",
		children: [
			s("weights_plot", n("Weight and direction")),
			s("pca_scree", n("Variation explained by each axis")),
			s("pca_loadings", n("Weights on the axes kept"))
		]
	}), s("unsup_map", n("Households on the first two components"))] }) : o === "count" ? /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-3",
		children: [
			s("weights_plot", n("Weight of each deprivation")),
			s("dep_count_plot", n("Weighted deprivations per household")),
			s("unsup_map", n("Households on the first two components"))
		]
	}) : e.cluster ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [s("cluster_plot", n("Profiles: share of households meeting each criterion")), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-2",
		children: [s("unsup_map", n("Households by profile, first two components")), s("weights_plot", n("Points that reproduce the targeted profiles"))]
	})] }) : o === "lda" ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-3",
		children: [
			s("weights_plot", n("Weight and direction")),
			s("prevalence_plot", n("How common each criterion is")),
			s("lda_scores", n("Index by group"))
		]
	}), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-2",
		children: [s("lda_var_map", n("Variables: correlation of each criterion with the index")), s("lda_ind_map", n("Households on the index"))]
	})] }) : /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-grid-3",
		children: [
			s("weights_plot", n("Weight and direction")),
			s("prevalence_plot", n("How common each criterion is")),
			s("effects_plot", n("Effect by model"))
		]
	}), /* @__PURE__ */ (0, R.jsxs)("section", {
		className: `sc-more${r ? " open" : ""}`,
		children: [/* @__PURE__ */ (0, R.jsxs)("button", {
			type: "button",
			className: "sc-more-head",
			"aria-expanded": r,
			onClick: () => i(!r),
			children: [
				/* @__PURE__ */ (0, R.jsx)(yt, { size: 15 }),
				" ",
				/* @__PURE__ */ (0, R.jsx)("span", { children: n("More diagnostics: diagram, decision rules and charts") }),
				/* @__PURE__ */ (0, R.jsx)(Dt, {
					size: 15,
					className: "sc-more-chev"
				})
			]
		}), /* @__PURE__ */ (0, R.jsxs)("div", {
			ref: a,
			className: "sc-more-body",
			style: { display: r ? void 0 : "none" },
			children: [/* @__PURE__ */ (0, R.jsx)(bm, { t: n }), c]
		})]
	});
}
//#endregion
//#region src/pages/design/StepThreshold.tsx
k();
function th({ flow: e, meta: t, mode: n, t: r }) {
	let i = L(W("sc_threshold")), a = n === "none", o = n === "pmt", s = !!e?.nav.threshold.adopted, c = um(), l = L(W("sc_ranking")), u = D(null), d = D(null);
	return V(W("sc_threshold"), u), V(W("sc_pmt_accuracy"), u), V(W("sc_ranking"), d), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-step",
		children: [
			/* @__PURE__ */ (0, R.jsx)("p", {
				className: "sc-lead",
				children: r("Choosing the eligibility threshold is a programmatic decision, not a mechanical one (Targeting Advisory 3/2025). The curve shows the whole trade-off; the band below is your tolerance for error.")
			}),
			/* @__PURE__ */ (0, R.jsx)(Up, {
				show: !!e && e.gates.threshold,
				text: r("The threshold is chosen against the errors a scored design produces, so fit the weights first."),
				btn: "back_to_weights",
				label: r("Back to Model & weights")
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-setup-panel sc-thr-setup",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-thr-row tw-align tw-align-bottom",
						children: [
							/* @__PURE__ */ (0, R.jsx)(nh, { t: r }),
							/* @__PURE__ */ (0, R.jsxs)(K, {
								when: !a,
								style: { display: "contents" },
								children: [/* @__PURE__ */ (0, R.jsx)(mf, {
									id: W("tol_lower"),
									value: t?.tol_default[0] ?? 5,
									min: 0,
									max: 49,
									step: 1,
									className: "sc-thr-num",
									label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
										r("Lower %"),
										" ",
										/* @__PURE__ */ (0, R.jsx)(q, { children: r("Lower bound of the tolerance band (Advisory 2/2025). Errors below it are acceptable without action. Changing the default (5%) needs an explanation in the rationale.") })
									] })
								}), /* @__PURE__ */ (0, R.jsx)(mf, {
									id: W("tol_upper"),
									value: t?.tol_default[1] ?? 20,
									min: 1,
									max: 49,
									step: 1,
									className: "sc-thr-num",
									label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
										r("Upper %"),
										" ",
										/* @__PURE__ */ (0, R.jsx)(q, { children: r("Upper bound of the tolerance band. Errors above it call for a redesign; it can never reach 50% (no better than random). Changing the default (20%) needs an explanation in the rationale.") })
									] })
								})]
							}),
							/* @__PURE__ */ (0, R.jsx)(mf, {
								id: W("caseload_pct"),
								min: 1,
								max: 100,
								step: 1,
								className: "sc-thr-caseload",
								label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
									r("Caseload (%)"),
									" ",
									/* @__PURE__ */ (0, R.jsx)(q, { children: r("Share of households the programme can serve. Used by 'Fit to caseload' to set the highest threshold that stays within it.") })
								] })
							}),
							/* @__PURE__ */ (0, R.jsxs)("div", {
								className: "tw-field sc-thr-suggest",
								children: [/* @__PURE__ */ (0, R.jsx)("label", {
									className: "form-label",
									children: r("Suggest")
								}), /* @__PURE__ */ (0, R.jsxs)("div", {
									className: "sc-thr-btns",
									children: [
										/* @__PURE__ */ (0, R.jsxs)(K, {
											as: "span",
											when: !a,
											style: { display: "contents" },
											children: [/* @__PURE__ */ (0, R.jsx)(B, {
												id: W("thr_balanced"),
												label: r("Minimise errors"),
												icon: /* @__PURE__ */ (0, R.jsx)(un, { size: 13 }),
												title: r("Sets the threshold where the larger of the inclusion and exclusion errors is smallest, so neither is traded away for the other.")
											}), /* @__PURE__ */ (0, R.jsx)(B, {
												id: W("thr_youden"),
												label: r("Balance (Youden)"),
												icon: /* @__PURE__ */ (0, R.jsx)(Bn, { size: 13 }),
												title: r("Youden's J: picks the threshold maximising sensitivity + specificity - 1, the point of the ROC curve furthest from the diagonal (Targeting Advisory 3/2025; Youden 1950).")
											})]
										}),
										/* @__PURE__ */ (0, R.jsx)(K, {
											as: "span",
											when: o,
											style: { display: "contents" },
											children: /* @__PURE__ */ (0, R.jsx)(B, {
												id: W("thr_line"),
												label: r("At the poverty line"),
												icon: /* @__PURE__ */ (0, R.jsx)(oi, { size: 13 }),
												title: r("Eligible when predicted welfare per person is at or below the poverty line: the standard PMT cut-off. A cut-off above the line lowers exclusion errors at the cost of inclusion errors (Brown, Ravallion & van de Walle 2018).")
											})
										}),
										/* @__PURE__ */ (0, R.jsx)(B, {
											id: W("thr_caseload"),
											label: r("Fit to caseload"),
											icon: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 13 }),
											title: r("Sets the threshold so no more than the caseload share of households is eligible.")
										})
									]
								})]
							}),
							/* @__PURE__ */ (0, R.jsx)(B, {
								id: W("thr_apply"),
								label: r("Apply"),
								icon: /* @__PURE__ */ (0, R.jsx)(Lt, { size: 14 }),
								variant: "primary",
								size: "md",
								className: "sc-thr-apply"
							})
						]
					}),
					/* @__PURE__ */ (0, R.jsx)(Em, {
						show: !!c?.thr,
						children: r("Threshold or tolerance changed: click Apply to update the errors and charts.")
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "small text-muted mt-1",
						children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: W("thr_note") })
					}),
					/* @__PURE__ */ (0, R.jsx)(K, {
						when: o,
						className: "small mt-1",
						children: /* @__PURE__ */ (0, R.jsx)(Sm, {
							stale: c,
							t: r
						})
					})
				]
			}),
			/* @__PURE__ */ (0, R.jsx)(K, {
				when: !a,
				className: "small text-muted",
				children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: W("eval_note") })
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: `sc-thr-mid${a ? " one" : ""}`,
				children: [/* @__PURE__ */ (0, R.jsx)(K, {
					when: !a,
					children: /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-kpis sc-kpis-2x2",
						children: [
							/* @__PURE__ */ (0, R.jsx)(am, {
								label: /* @__PURE__ */ (0, R.jsx)(Sf, { id: W("kpi_auc_title") }),
								value: /* @__PURE__ */ (0, R.jsx)(Sf, { id: W("kpi_auc") }),
								tone: "primary"
							}),
							/* @__PURE__ */ (0, R.jsx)(am, {
								label: r(o ? "Selected (predicted poor)" : "Eligible households"),
								value: /* @__PURE__ */ (0, R.jsx)(Sf, { id: W("kpi_elig") }),
								tone: "info"
							}),
							i ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(rh, {
								which: "incl",
								th: i,
								t: r
							}), /* @__PURE__ */ (0, R.jsx)(rh, {
								which: "excl",
								th: i,
								t: r
							})] }) : /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(am, {
								label: r("Inclusion error"),
								value: "–"
							}), /* @__PURE__ */ (0, R.jsx)(am, {
								label: r("Exclusion error"),
								value: "–"
							})] })
						]
					})
				}), /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "sc-setup-panel sc-rationale",
					children: [/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "form-label sc-label",
						children: [
							r("Rationale for the band and the threshold"),
							" ",
							/* @__PURE__ */ (0, R.jsx)(q, { children: r("Required by Targeting Advisory 2/2025; it goes into the exported scorecard and the design report.") })
						]
					}), /* @__PURE__ */ (0, R.jsx)(xf, { id: W("host_rationale") })]
				})]
			}),
			/* @__PURE__ */ (0, R.jsx)(K, {
				when: a,
				children: /* @__PURE__ */ (0, R.jsxs)("div", {
					ref: d,
					className: "sc-stack",
					children: [
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "sc-kpis sc-kpis-ranking",
							children: [
								/* @__PURE__ */ (0, R.jsx)(am, {
									label: r("Households selected"),
									value: /* @__PURE__ */ (0, R.jsx)(Sf, { id: W("kpi_selected") }),
									tone: "info"
								}),
								/* @__PURE__ */ (0, R.jsx)(am, {
									label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
										r("Internal consistency"),
										" ",
										/* @__PURE__ */ (0, R.jsx)(q, { children: r("Cronbach's alpha of the criteria: how far they measure one thing. Above 0.7 is usually read as consistent; low values are expected when the criteria cover different dimensions of vulnerability on purpose.") })
									] }),
									value: /* @__PURE__ */ (0, R.jsx)(Sf, { id: W("kpi_alpha") })
								}),
								/* @__PURE__ */ (0, R.jsx)(H, {
									title: r("Stability of the selection"),
									icon: /* @__PURE__ */ (0, R.jsx)(Si, { size: 15 }),
									className: "sc-stability",
									help: /* @__PURE__ */ (0, R.jsx)(q, { children: r("The design is refitted on 20 resamples of the households; each refit selects the same share of households. The agreement with the design's own selection (Jaccard index) says how much the targeting depends on who happened to be in the data.") }),
									children: /* @__PURE__ */ (0, R.jsx)(wm, {
										r: l,
										t: r
									})
								})
							]
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "sc-grid-2 sc-top",
							children: [/* @__PURE__ */ (0, R.jsx)(H, {
								title: r("What the selection concentrates"),
								icon: /* @__PURE__ */ (0, R.jsx)(ur, { size: 15 }),
								help: /* @__PURE__ */ (0, R.jsx)(q, { children: r("A household's deprivations are the criteria it meets in the vulnerable direction (an inclusion criterion met, an exclusion criterion not met).") }),
								children: /* @__PURE__ */ (0, R.jsx)(Tm, {
									r: l,
									t: r
								})
							}), /* @__PURE__ */ (0, R.jsx)(H, {
								full: !0,
								title: r("Share selected by area"),
								icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 15 }),
								help: /* @__PURE__ */ (0, R.jsx)(Bp, {
									id: "cov_area_plot",
									meta: t,
									t: r
								}),
								actions: /* @__PURE__ */ (0, R.jsx)("div", {
									className: "sc-card-select",
									children: /* @__PURE__ */ (0, R.jsx)(z, {
										id: W("cov_area"),
										choices: [{
											value: "",
											label: r("(none)")
										}],
										value: "",
										clearable: !1
									})
								}),
								children: /* @__PURE__ */ (0, R.jsx)(U, {
									id: W("cov_area_plot"),
									height: 320
								})
							})]
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "sc-grid-2",
							children: [/* @__PURE__ */ (0, R.jsx)(H, {
								full: !0,
								title: r("Ranking distribution"),
								icon: /* @__PURE__ */ (0, R.jsx)(wi, { size: 15 }),
								help: /* @__PURE__ */ (0, R.jsx)(Bp, {
									id: "rank_plot",
									meta: t,
									t: r
								}),
								children: /* @__PURE__ */ (0, R.jsx)(U, {
									id: W("rank_plot"),
									height: 400
								})
							}), /* @__PURE__ */ (0, R.jsx)(H, {
								full: !0,
								title: r("Criteria among selected and other households"),
								icon: /* @__PURE__ */ (0, R.jsx)(Yt, { size: 15 }),
								help: /* @__PURE__ */ (0, R.jsx)(Bp, {
									id: "sel_prev_plot",
									meta: t,
									t: r
								}),
								children: /* @__PURE__ */ (0, R.jsx)(U, {
									id: W("sel_prev_plot"),
									height: 400
								})
							})]
						})
					]
				})
			}),
			/* @__PURE__ */ (0, R.jsx)(K, {
				when: !a,
				children: /* @__PURE__ */ (0, R.jsxs)("div", {
					ref: u,
					className: "sc-stack",
					children: [/* @__PURE__ */ (0, R.jsx)(K, {
						when: o,
						children: /* @__PURE__ */ (0, R.jsx)(xm, { t: r })
					}), /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-grid-75",
						children: [/* @__PURE__ */ (0, R.jsx)(H, {
							title: r(o ? "PMT targeting matrix" : "Design error matrix"),
							icon: /* @__PURE__ */ (0, R.jsx)(Wn, { size: 15 }),
							children: i ? /* @__PURE__ */ (0, R.jsx)(ih, {
								th: i,
								t: r
							}) : /* @__PURE__ */ (0, R.jsx)("div", {
								className: "small text-muted",
								children: r("Fit a model and set a threshold to see the matrix.")
							})
						}), /* @__PURE__ */ (0, R.jsx)(H, {
							title: r("Verdict"),
							icon: /* @__PURE__ */ (0, R.jsx)(Ze, { size: 15 }),
							children: i ? /* @__PURE__ */ (0, R.jsx)(oh, {
								th: i,
								t: r
							}) : /* @__PURE__ */ (0, R.jsx)("div", {
								className: "small text-muted",
								children: r("The verdict follows the errors.")
							})
						})]
					})]
				})
			}),
			/* @__PURE__ */ (0, R.jsx)(H, {
				full: !0,
				title: r("Explore the threshold"),
				icon: /* @__PURE__ */ (0, R.jsx)(gi, { size: 15 }),
				className: "sc-explore",
				actions: /* @__PURE__ */ (0, R.jsx)(B, {
					id: W("pct_open"),
					label: r("Score percentiles"),
					icon: /* @__PURE__ */ (0, R.jsx)(Jr, { size: 13 }),
					variant: "outline-secondary",
					title: r("Households between the percentiles of the score you choose, with an Excel export")
				}),
				children: /* @__PURE__ */ (0, R.jsx)(Wf, {
					id: W("thr_explore"),
					tabs: [
						{
							value: "sep",
							label: r("How well it separates"),
							content: a ? /* @__PURE__ */ (0, R.jsx)("div", {
								className: "small text-muted p-2",
								children: r("Needs an outcome indicator: see the ranking distribution above.")
							}) : /* @__PURE__ */ (0, R.jsxs)("div", {
								className: "sc-grid-2",
								children: [/* @__PURE__ */ (0, R.jsx)(Hp, {
									id: "roc_plot",
									title: r("ROC curve"),
									meta: t,
									t: r
								}), /* @__PURE__ */ (0, R.jsx)(Hp, {
									id: "box_plot",
									title: r("Score by group"),
									meta: t,
									t: r
								})]
							})
						},
						{
							value: "fall",
							label: r("Where households fall"),
							content: /* @__PURE__ */ (0, R.jsxs)("div", {
								className: "sc-grid-2",
								children: [a ? /* @__PURE__ */ (0, R.jsx)("div", {
									className: "small text-muted p-2",
									children: r("Score distribution: needs an outcome indicator.")
								}) : /* @__PURE__ */ (0, R.jsx)(Hp, {
									id: "score_plot",
									title: r("Score distribution"),
									meta: t,
									t: r
								}), /* @__PURE__ */ (0, R.jsx)(Hp, {
									id: "met_plot",
									title: r("Criteria met, eligible vs not"),
									meta: t,
									t: r
								})]
							})
						},
						{
							value: "drive",
							label: r("What drives it"),
							content: /* @__PURE__ */ (0, R.jsxs)("div", {
								className: "sc-grid-2",
								children: [/* @__PURE__ */ (0, R.jsx)(Hp, {
									id: "contribution_plot",
									title: r("What drives the score"),
									height: 640,
									meta: t,
									t: r
								}), a ? /* @__PURE__ */ (0, R.jsx)(Hp, {
									id: "sel_by_met_plot",
									title: r("Share selected by number of criteria met"),
									height: 640,
									meta: t,
									t: r
								}) : /* @__PURE__ */ (0, R.jsx)(Hp, {
									id: "coverage_plot",
									title: r("Coverage by criterion"),
									height: 640,
									meta: t,
									t: r
								})]
							})
						}
					]
				})
			}),
			/* @__PURE__ */ (0, R.jsx)(Wp, {
				back: "nav_back_threshold",
				backLabel: r("Back to Model & weights"),
				nav: s ? {
					ok: !0,
					done: `${r("Adopted")} ${e?.nav.threshold.adopted_at ?? ""}. ${r("Any change to the design withdraws the adoption.")}`,
					todo: ""
				} : e?.nav.threshold,
				next: "nav_adopt",
				nextLabel: a ? r("Adopt this ranking") : o ? r("Adopt this PMT") : `${r("Adopt this scorecard")}`,
				nextIcon: /* @__PURE__ */ (0, R.jsx)(Lt, { size: 14 }),
				t: r,
				after: s ? /* @__PURE__ */ (0, R.jsxs)("span", {
					className: "sc-adopted-pill",
					children: [
						/* @__PURE__ */ (0, R.jsx)(Ze, { size: 14 }),
						" ",
						r("Adopted")
					]
				}) : null
			})
		]
	});
}
function nh({ t: e }) {
	let t = L(W("sc_slider")), [n, r] = Kd(W("threshold"), null, {
		debounceMs: 250,
		type: "tw.num"
	}), [i, a] = O({
		min: 0,
		max: 10
	}), o = D(null);
	E(() => {
		t && o.current !== t.stamp && (o.current = t.stamp, a({
			min: t.min,
			max: t.max
		}), r(t.value));
	}, [t]), uf(W("threshold"), (e) => {
		(e.min !== void 0 || e.max !== void 0) && a((t) => ({
			min: e.min ?? t.min,
			max: e.max ?? t.max
		})), e.value !== void 0 && e.value !== null && r(Number(e.value));
	});
	let [s, c] = O("");
	E(() => {
		c(G(n) ? Mp(n) : "");
	}, [n]);
	let l = G(n) ? n : i.min;
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-field sc-threshold",
		children: [
			/* @__PURE__ */ (0, R.jsxs)("label", {
				className: "form-label",
				htmlFor: `${W("threshold")}__num`,
				children: [
					e("Eligible when score is above"),
					" ",
					/* @__PURE__ */ (0, R.jsx)(q, { children: e("Households scoring strictly above this value are eligible. Moving it trades inclusion error against exclusion error.") })
				]
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-threshold-row",
				children: [/* @__PURE__ */ (0, R.jsx)("input", {
					type: "range",
					className: "form-range",
					min: i.min,
					max: i.max,
					step: 1e-4,
					value: l,
					"aria-label": e("Threshold"),
					onChange: (e) => r(Number(e.target.value))
				}), /* @__PURE__ */ (0, R.jsx)("input", {
					id: `${W("threshold")}__num`,
					type: "number",
					className: "form-control form-control-sm",
					step: "any",
					value: s,
					onChange: (e) => {
						c(e.target.value);
						let t = Number(e.target.value);
						e.target.value !== "" && isFinite(t) && r(Math.min(Math.max(t, i.min), i.max));
					}
				})]
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-threshold-scale",
				children: [/* @__PURE__ */ (0, R.jsx)("span", { children: Mp(i.min) }), /* @__PURE__ */ (0, R.jsx)("span", { children: Mp(i.max) })]
			})
		]
	});
}
function rh({ which: e, th: t, t: n }) {
	let r = t.e, i = e === "incl" ? r.inclusion_error : r.exclusion_error, a = e === "incl" ? r.included_not_in_need : r.excluded_in_need, o = e === "incl" ? r.correctly_included + r.included_not_in_need : r.correctly_included + r.excluded_in_need, s = G(i) ? i <= t.lower ? "good" : i <= t.upper ? "review" : "bad" : "na", c = (e) => `${100 * Math.min(Math.max(e, 0), .5) / .5}%`;
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `sc-track is-${s}`,
		children: [
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-track-head",
				children: [/* @__PURE__ */ (0, R.jsx)("span", {
					className: "sc-kpi-label",
					children: e === "incl" ? t.words.incl : t.words.excl
				}), /* @__PURE__ */ (0, R.jsx)("span", {
					className: "sc-track-value",
					children: G(i) ? `${(100 * i).toFixed(1)}%` : "n/a"
				})]
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-track-bar",
				"aria-hidden": "true",
				children: [
					/* @__PURE__ */ (0, R.jsx)("span", {
						className: "zone good",
						style: { width: c(t.lower) }
					}),
					/* @__PURE__ */ (0, R.jsx)("span", {
						className: "zone review",
						style: {
							left: c(t.lower),
							width: `${100 * (Math.min(t.upper, .5) - Math.min(t.lower, .5)) / .5}%`
						}
					}),
					/* @__PURE__ */ (0, R.jsx)("span", {
						className: "zone bad",
						style: {
							left: c(t.upper),
							right: 0
						}
					}),
					G(i) ? /* @__PURE__ */ (0, R.jsx)("span", {
						className: "marker",
						style: { left: c(i) }
					}) : null
				]
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-track-scale",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("span", {
						style: { left: c(t.lower) },
						children: [Math.round(100 * t.lower), "%"]
					}),
					/* @__PURE__ */ (0, R.jsxs)("span", {
						style: { left: c(t.upper) },
						children: [Math.round(100 * t.upper), "%"]
					}),
					/* @__PURE__ */ (0, R.jsx)("span", {
						className: "end-r",
						children: "50%"
					})
				]
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "sc-kpi-sub",
				children: [
					jp(a),
					" / ",
					jp(o),
					" ",
					"—",
					" ",
					e === "incl" ? t.words.incl_mean : t.words.excl_mean
				]
			})
		]
	});
}
function ih({ th: e, t }) {
	let n = e.e, r = e.words, i = n.correctly_included + n.included_not_in_need, a = n.excluded_in_need + n.correctly_excluded, o = n.correctly_included + n.excluded_in_need, s = n.included_not_in_need + n.correctly_excluded, c = (e, t) => t ? `${(100 * e / t).toFixed(1)}%` : "-", l = (e, r, i, a, o) => /* @__PURE__ */ (0, R.jsxs)("td", {
		className: `wfp-cm-cell ${a}`,
		children: [
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "wfp-cm-label",
				children: [
					o,
					" ",
					i
				]
			}),
			/* @__PURE__ */ (0, R.jsx)("div", {
				className: "wfp-cm-count",
				children: jp(e)
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "wfp-cm-share",
				children: [/* @__PURE__ */ (0, R.jsxs)("span", { children: [
					c(e, r),
					" ",
					t("of row")
				] }), /* @__PURE__ */ (0, R.jsxs)("span", { children: [
					c(e, n.n),
					" ",
					t("of all")
				] })]
			})
		]
	});
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)("div", {
		className: "wfp-cm-wrap",
		children: /* @__PURE__ */ (0, R.jsxs)("table", {
			className: "wfp-matrix wfp-cm",
			children: [/* @__PURE__ */ (0, R.jsxs)("thead", { children: [/* @__PURE__ */ (0, R.jsxs)("tr", { children: [
				/* @__PURE__ */ (0, R.jsxs)("th", {
					className: "wfp-cm-corner",
					colSpan: 2,
					rowSpan: 2,
					children: [/* @__PURE__ */ (0, R.jsx)("div", {
						className: "wfp-cm-axis",
						children: r.axis_row
					}), /* @__PURE__ */ (0, R.jsx)("div", {
						className: "wfp-cm-axis",
						children: r.axis_col
					})]
				}),
				/* @__PURE__ */ (0, R.jsxs)("th", {
					className: "wfp-cm-group",
					colSpan: 2,
					children: [
						e.pmt ? t("Welfare per person:") : t("Outcome:"),
						" ",
						/* @__PURE__ */ (0, R.jsx)("strong", { children: e.outcome })
					]
				}),
				/* @__PURE__ */ (0, R.jsx)("th", {
					className: "wfp-cm-tot-head",
					rowSpan: 2,
					children: t("Total")
				})
			] }), /* @__PURE__ */ (0, R.jsxs)("tr", { children: [/* @__PURE__ */ (0, R.jsxs)("th", {
				className: "wfp-cm-col",
				children: [r.vuln, /* @__PURE__ */ (0, R.jsx)("div", {
					className: "wfp-cm-sub",
					children: e.opos
				})]
			}), /* @__PURE__ */ (0, R.jsx)("th", {
				className: "wfp-cm-col",
				children: r.notvuln
			})] })] }), /* @__PURE__ */ (0, R.jsxs)("tbody", { children: [
				/* @__PURE__ */ (0, R.jsxs)("tr", { children: [
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "wfp-cm-rowgroup",
						rowSpan: 2,
						children: /* @__PURE__ */ (0, R.jsx)("span", { children: r.card })
					}),
					/* @__PURE__ */ (0, R.jsxs)("th", {
						className: "wfp-cm-row",
						children: [r.elig, /* @__PURE__ */ (0, R.jsxs)("div", {
							className: "wfp-cm-sub",
							children: [
								t("score >"),
								" ",
								e.threshold
							]
						})]
					}),
					l(n.correctly_included, i, t("Correctly included"), "ok", /* @__PURE__ */ (0, R.jsx)(Lt, { size: 13 })),
					l(n.included_not_in_need, i, r.incl, "err-incl", /* @__PURE__ */ (0, R.jsx)(qt, { size: 13 })),
					/* @__PURE__ */ (0, R.jsxs)("td", {
						className: "wfp-cm-tot",
						children: [jp(i), /* @__PURE__ */ (0, R.jsx)("div", {
							className: "wfp-cm-sub",
							children: c(i, n.n)
						})]
					})
				] }),
				/* @__PURE__ */ (0, R.jsxs)("tr", { children: [
					/* @__PURE__ */ (0, R.jsx)("th", {
						className: "wfp-cm-row",
						children: r.notelig
					}),
					l(n.excluded_in_need, a, r.excl, "err-excl", /* @__PURE__ */ (0, R.jsx)(na, { size: 13 })),
					l(n.correctly_excluded, a, t("Correctly excluded"), "ok", /* @__PURE__ */ (0, R.jsx)(Lt, { size: 13 })),
					/* @__PURE__ */ (0, R.jsxs)("td", {
						className: "wfp-cm-tot",
						children: [jp(a), /* @__PURE__ */ (0, R.jsx)("div", {
							className: "wfp-cm-sub",
							children: c(a, n.n)
						})]
					})
				] }),
				/* @__PURE__ */ (0, R.jsxs)("tr", {
					className: "wfp-matrix-totals-row",
					children: [
						/* @__PURE__ */ (0, R.jsx)("th", {
							className: "wfp-cm-row wfp-cm-tot-label",
							colSpan: 2,
							children: t("Total")
						}),
						/* @__PURE__ */ (0, R.jsxs)("td", {
							className: "wfp-cm-tot",
							children: [jp(o), /* @__PURE__ */ (0, R.jsx)("div", {
								className: "wfp-cm-sub",
								children: c(o, n.n)
							})]
						}),
						/* @__PURE__ */ (0, R.jsxs)("td", {
							className: "wfp-cm-tot",
							children: [jp(s), /* @__PURE__ */ (0, R.jsx)("div", {
								className: "wfp-cm-sub",
								children: c(s, n.n)
							})]
						}),
						/* @__PURE__ */ (0, R.jsx)("td", {
							className: "wfp-cm-tot wfp-cm-grand",
							children: jp(n.n)
						})
					]
				})
			] })]
		})
	}), /* @__PURE__ */ (0, R.jsx)("div", {
		className: "small text-muted mt-2",
		children: t("Valid for direct household-level assistance (Tier 1) only. In emergencies the OGN gives priority to reducing exclusion errors; inclusion errors are more acceptable.")
	})] });
}
var ah = {
	good: "Within tolerance",
	review: "Review recommended",
	redesign: "Redesign required",
	unknown: "Not enough data",
	invalid: "Tolerance not valid"
};
function oh({ th: e, t }) {
	let n = e.verdict, r = [
		"good",
		"review",
		"redesign"
	].includes(n.level) ? n.level : "unknown", i = D(null), a = i.current !== n.level;
	E(() => {
		i.current = n.level;
	}, [n.level]);
	let o = (n, r) => {
		if (!G(r)) return null;
		let i = r <= e.lower ? "is-ok" : r <= e.upper ? "is-mid" : "is-bad";
		return /* @__PURE__ */ (0, R.jsxs)("div", {
			className: `vd-metric ${i}`,
			children: [
				/* @__PURE__ */ (0, R.jsx)("span", {
					className: "vd-metric-label",
					children: n
				}),
				/* @__PURE__ */ (0, R.jsxs)("span", {
					className: "vd-metric-value",
					children: [(100 * r).toFixed(1), "%"]
				}),
				/* @__PURE__ */ (0, R.jsxs)("span", {
					className: "vd-metric-tol",
					children: [
						t("good"),
						" ",
						"≤",
						" ",
						Math.round(100 * e.lower),
						"% ",
						"·",
						" ",
						t("limit"),
						" ",
						"≤",
						" ",
						Math.round(100 * e.upper),
						"%"
					]
				})
			]
		});
	};
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `wfp-verdict is-${r}${a ? "" : " no-anim"}`,
		role: "status",
		children: [/* @__PURE__ */ (0, R.jsx)("div", {
			className: "vd-icon",
			children: /* @__PURE__ */ (0, R.jsx)(er, {
				size: 30,
				strokeWidth: 2.2
			})
		}), /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "vd-text",
			children: [
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "vd-head",
					children: /* @__PURE__ */ (0, R.jsx)("span", {
						className: "vd-status",
						children: t(ah[n.level] ?? ah.unknown)
					})
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "vd-interp",
					children: t(n.interpretation)
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "vd-action",
					children: [/* @__PURE__ */ (0, R.jsxs)("strong", { children: [t("Recommended action:"), " "] }), t(n.action)]
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "vd-metrics",
					children: [o(e.words.incl, e.e.inclusion_error), o(e.words.excl, e.e.exclusion_error)]
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "small mt-2 text-muted",
					children: [
						t("Judged against a tolerance band of %s.").replace("%s", `${Math.round(100 * e.lower)}%-${Math.round(100 * e.upper)}%`),
						" ",
						t("Targeting Advisory 2/2025 observes design errors of 5-20% across country offices.")
					]
				})
			]
		})]
	}, n.level);
}
//#endregion
//#region src/pages/design/DesignPage.tsx
k();
function sh({ t: e }) {
	let t = L(W("sc_meta")), n = L(W("sc_flow")), r = I(W("framework_mode")) ?? n?.mode ?? "outcome", [i, a] = O("data"), o = D(null), s = () => {
		a("data");
		let e = o.current?.closest(".tw-sidebar-layout");
		e?.classList.contains("tw-side-closed") && e.querySelector(".tw-side-toggle")?.click();
	}, c = (e) => {
		let t = document.getElementById(W("steps")), n = window.jQuery, r = t && n ? n(t).data("shiny-input-binding") : void 0;
		t && r?.receiveMessage ? r.receiveMessage(t, { value: e }) : em(W("flow_go"), e);
	}, l = (e) => e === "data" ? s() : c(e), u = r === "none", d = r === "pmt", f = /* @__PURE__ */ (0, R.jsxs)("div", {
		ref: o,
		className: "sc-side",
		children: [/* @__PURE__ */ (0, R.jsx)(ch, {
			open: i,
			setOpen: a,
			sections: [
				{
					key: "data",
					title: e("1. Assessment data"),
					icon: /* @__PURE__ */ (0, R.jsx)(fn, { size: 15 }),
					summary: n?.data ? `${n.data.rows.toLocaleString("en-US")} × ${n.data.cols}` : e("not loaded"),
					content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
						/* @__PURE__ */ (0, R.jsx)("p", {
							className: "small text-muted mb-2",
							children: e("An assessment survey with a food-security outcome (EFSA, VAM...) or a welfare measure (HIES, LSMS), not the registration or PDM data.")
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-dropzone sc-file",
							children: [/* @__PURE__ */ (0, R.jsx)(fa, {
								size: 18,
								className: "tw-dropzone-icon",
								"aria-hidden": !0
							}), /* @__PURE__ */ (0, R.jsx)(xf, {
								id: W("host_file"),
								className: "tw-dropzone-input"
							})]
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "sc-data-tools",
							children: [
								/* @__PURE__ */ (0, R.jsx)(rp, {
									ns: W("moda"),
									label: "MODA",
									size: "sm",
									t: e
								}),
								/* @__PURE__ */ (0, R.jsx)(ip, {
									ns: W("calc"),
									label: "Calculator",
									block: !0,
									t: e
								}),
								/* @__PURE__ */ (0, R.jsx)(B, {
									id: W("fsi-open"),
									label: e("Food security indicators"),
									icon: /* @__PURE__ */ (0, R.jsx)(st, { size: 14 }),
									variant: "outline-secondary",
									title: e("Calculate FCS, rCSI, LCS, FES or CARI from the WFP standard variables"),
									className: "sc-full"
								}),
								/* @__PURE__ */ (0, R.jsx)(up, {
									ns: W("summary"),
									className: "sc-full",
									t: e
								}),
								/* @__PURE__ */ (0, R.jsx)(B, {
									id: W("open_guide"),
									label: e("How it works"),
									icon: /* @__PURE__ */ (0, R.jsx)(at, { size: 14 }),
									variant: "outline-secondary",
									title: e("The design process step by step, with its methods"),
									className: "w-100"
								})
							]
						}),
						/* @__PURE__ */ (0, R.jsx)(lh, {
							flow: n,
							t: e
						})
					] })
				},
				{
					key: "areas",
					title: e("2. Areas covered"),
					icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 15 }),
					content: /* @__PURE__ */ (0, R.jsx)(np, {
						ns: W("scope"),
						title: null,
						t: e
					})
				},
				{
					key: "adopt",
					title: e("3. Exports"),
					icon: /* @__PURE__ */ (0, R.jsx)(vi, { size: 15 }),
					content: /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "sc-exports",
						children: [
							/* @__PURE__ */ (0, R.jsx)(uh, {
								id: W("download"),
								icon: /* @__PURE__ */ (0, R.jsx)(En, { size: 17 }),
								title: `${e(u ? "Vulnerability ranking" : "Scorecard")} (Excel)`,
								sub: e(u ? "Criteria, points, threshold and validity" : "Criteria, points, threshold and design errors")
							}),
							/* @__PURE__ */ (0, R.jsx)(uh, {
								id: W("download_json"),
								icon: /* @__PURE__ */ (0, R.jsx)(Sn, { size: 17 }),
								title: e("Card (JSON)"),
								sub: e("For other tools and systems")
							}),
							/* @__PURE__ */ (0, R.jsx)(uh, {
								id: W("download_report"),
								icon: /* @__PURE__ */ (0, R.jsx)(On, { size: 17 }),
								title: `${e(u ? "Ranking report" : "Design report")} (HTML)`,
								sub: e("Every step and chart, to share and review")
							}),
							/* @__PURE__ */ (0, R.jsx)(uh, {
								id: W("download_xlsform"),
								icon: /* @__PURE__ */ (0, R.jsx)(Zt, { size: 17 }),
								title: e("Registration form (XLSForm)"),
								sub: e("Draft for KoboToolbox, ODK or MODA, from the adopted design")
							})
						]
					})
				}
			]
		}), /* @__PURE__ */ (0, R.jsxs)(Uf, { children: [/* @__PURE__ */ (0, R.jsx)(B, {
			id: W("btn_use"),
			label: e(u ? "Use this ranking" : d ? "Use this PMT" : "Use this scorecard"),
			icon: /* @__PURE__ */ (0, R.jsx)(Lt, { size: 15 }),
			variant: "primary",
			className: "w-100 sc-adopt-btn"
		}), /* @__PURE__ */ (0, R.jsxs)("div", {
			className: `sc-use-status${n?.adopted ? " is-adopted" : ""}`,
			children: [n?.adopted ? /* @__PURE__ */ (0, R.jsx)(Tt, { size: 13 }) : null, /* @__PURE__ */ (0, R.jsx)(Sf, { id: W("use_status") })]
		})] })]
	});
	return /* @__PURE__ */ (0, R.jsxs)(Vf, {
		sidebar: f,
		width: 320,
		className: "sc-page",
		children: [/* @__PURE__ */ (0, R.jsx)(tm, {
			t: e,
			children: /* @__PURE__ */ (0, R.jsx)(fh, {
				flow: n,
				go: l,
				t: e
			})
		}), /* @__PURE__ */ (0, R.jsx)(ph, { panels: [
			{
				value: "outcome",
				content: /* @__PURE__ */ (0, R.jsx)(tm, {
					t: e,
					children: /* @__PURE__ */ (0, R.jsx)(rm, {
						flow: n,
						meta: t,
						mode: r,
						t: e
					})
				})
			},
			{
				value: "screening",
				content: /* @__PURE__ */ (0, R.jsx)(tm, {
					t: e,
					children: /* @__PURE__ */ (0, R.jsx)(Pm, {
						flow: n,
						mode: r,
						t: e
					})
				})
			},
			{
				value: "weights",
				content: /* @__PURE__ */ (0, R.jsx)(tm, {
					t: e,
					children: /* @__PURE__ */ (0, R.jsx)(Um, {
						flow: n,
						meta: t,
						mode: r,
						t: e
					})
				})
			},
			{
				value: "threshold",
				content: /* @__PURE__ */ (0, R.jsx)(tm, {
					t: e,
					children: /* @__PURE__ */ (0, R.jsx)(th, {
						flow: n,
						meta: t,
						mode: r,
						t: e
					})
				})
			}
		] })]
	});
}
function ch({ sections: e, open: t, setOpen: n }) {
	let r = D({});
	return E(() => {
		Bf(r.current[t], !0);
	}, [t]), /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-steps",
		children: e.map((e) => {
			let i = t === e.key;
			return /* @__PURE__ */ (0, R.jsxs)("section", {
				className: `tw-step${i ? " open" : ""}`,
				children: [/* @__PURE__ */ (0, R.jsxs)("button", {
					type: "button",
					className: "tw-step-head",
					"aria-expanded": i,
					onClick: () => n(i ? "" : e.key),
					children: [
						/* @__PURE__ */ (0, R.jsxs)("span", {
							className: "tw-step-title",
							children: [
								e.icon,
								" ",
								e.title
							]
						}),
						!i && e.summary ? /* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-step-summary",
							children: e.summary
						}) : null,
						/* @__PURE__ */ (0, R.jsx)(Dt, {
							size: 14,
							className: "tw-step-chev"
						})
					]
				}), /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-step-body",
					ref: (t) => {
						r.current[e.key] = t;
					},
					style: { display: i ? void 0 : "none" },
					children: e.content
				})]
			}, e.key);
		})
	});
}
function lh({ flow: e, t }) {
	return e?.data ? /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-data-status",
		children: [/* @__PURE__ */ (0, R.jsx)(Lt, { size: 15 }), /* @__PURE__ */ (0, R.jsxs)("div", { children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: t("%s rows, %s columns").replace("%s", e.data.rows.toLocaleString("en-US")).replace("%s", String(e.data.cols)) }), /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "text-muted text-truncate",
			title: e.data.source,
			children: [
				t("Source:"),
				" ",
				e.data.source
			]
		})] })]
	}) : /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-data-status is-empty",
		children: [/* @__PURE__ */ (0, R.jsx)(na, { size: 15 }), /* @__PURE__ */ (0, R.jsxs)("div", { children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: t("No assessment data yet.") }), /* @__PURE__ */ (0, R.jsx)("div", {
			className: "text-muted",
			children: t("Load a needs-assessment extract above to start the design.")
		})] })]
	});
}
function uh({ id: e, icon: t, title: n, sub: r }) {
	return E(() => {
		window.twGates?.apply(e);
	}), /* @__PURE__ */ (0, R.jsxs)($d, {
		id: e,
		tagName: "a",
		className: "sc-export shiny-download-link",
		download: "",
		target: "_blank",
		children: [/* @__PURE__ */ (0, R.jsx)("span", {
			className: "sc-export-icon",
			children: t
		}), /* @__PURE__ */ (0, R.jsxs)("span", {
			className: "sc-export-text",
			children: [/* @__PURE__ */ (0, R.jsx)("span", {
				className: "sc-export-title",
				children: n
			}), /* @__PURE__ */ (0, R.jsx)("span", {
				className: "sc-export-sub",
				children: r
			})]
		})]
	});
}
var dh = {
	outcome: "1",
	screening: "2",
	weights: "3",
	threshold: "4"
};
function fh({ flow: e, go: t, t: n }) {
	if (!e) return /* @__PURE__ */ (0, R.jsx)("div", { className: "sc-flow sc-flow-empty" });
	let r = e.todo_i ? e.steps[e.todo_i - 1]?.key : null, i = (t) => t.key === "outcome" && e.mode === "pmt" ? n("Welfare measure") : n(t.label);
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "sc-flow",
		children: [/* @__PURE__ */ (0, R.jsx)("ol", {
			className: "sc-flow-track",
			children: e.steps.map((a, o) => {
				let s = a.key === e.here, c = a.key === r;
				return /* @__PURE__ */ (0, R.jsxs)("li", {
					className: `sc-flow-step${a.done ? " is-done" : ""}${s ? " is-current" : ""}${c ? " is-next" : ""}`,
					children: [o > 0 ? /* @__PURE__ */ (0, R.jsx)("span", {
						className: `sc-flow-line${e.steps[o - 1].done ? " is-done" : ""}`,
						"aria-hidden": "true"
					}) : null, /* @__PURE__ */ (0, R.jsxs)("button", {
						type: "button",
						onClick: () => t(a.panel),
						title: a.panel === "data" ? n("Open the assessment data (sidebar)") : `${n("Open")} ${i(a)}`,
						"aria-current": s ? "step" : void 0,
						children: [/* @__PURE__ */ (0, R.jsx)("span", {
							className: "sc-flow-dot",
							children: a.done ? /* @__PURE__ */ (0, R.jsx)(Tt, {
								size: 13,
								strokeWidth: 3
							}) : dh[a.key] ?? (a.key === "data" ? /* @__PURE__ */ (0, R.jsx)(fn, { size: 12 }) : /* @__PURE__ */ (0, R.jsx)(Hr, { size: 12 }))
						}), /* @__PURE__ */ (0, R.jsx)("span", {
							className: "sc-flow-label",
							children: i(a)
						})]
					})]
				}, a.key);
			})
		}), /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "sc-flow-next",
			children: [
				/* @__PURE__ */ (0, R.jsxs)("span", {
					className: `sc-flow-status is-${e.status.kind}`,
					children: [
						e.status.kind === "todo" ? /* @__PURE__ */ (0, R.jsxs)("strong", { children: [n("On this step:"), " "] }) : /* @__PURE__ */ (0, R.jsx)(Lt, { size: 15 }),
						" ",
						n(e.status.text)
					]
				}),
				e.earlier ? /* @__PURE__ */ (0, R.jsxs)("span", {
					className: "sc-flow-earlier",
					children: [
						n("%s is not finished.").replace("%s", n(e.earlier.label)),
						" ",
						/* @__PURE__ */ (0, R.jsx)("button", {
							type: "button",
							className: "btn btn-link btn-sm p-0",
							onClick: () => t(e.earlier.panel),
							children: n("Back to it")
						})
					]
				}) : null,
				e.next_panel ? /* @__PURE__ */ (0, R.jsxs)("button", {
					type: "button",
					className: "btn btn-sm btn-outline-primary ms-auto",
					onClick: () => e.here === "screening" ? em(W("nav_next_screening"), Date.now()) : t(e.next_panel),
					children: [
						n("Continue to"),
						" ",
						e.next_panel === "outcome" && e.mode === "pmt" ? n("Welfare measure") : n(e.next_label ?? ""),
						" ",
						"→"
					]
				}) : null
			]
		})]
	});
}
function ph({ panels: e }) {
	let [t, n] = Kd(W("steps"), "outcome", { debounceMs: 0 });
	uf(W("steps"), (e) => {
		e.value !== void 0 && e.value !== null && n(String(Array.isArray(e.value) ? e.value[0] : e.value));
	});
	let r = D({}), i = D(!0);
	return E(() => {
		for (let n of e) Bf(r.current[n.value], n.value === t);
		i.current || r.current[t]?.closest(".tw-side-main")?.scrollTo({ top: 0 }), i.current = !1;
	}, [t]), /* @__PURE__ */ (0, R.jsx)(R.Fragment, { children: e.map((e) => /* @__PURE__ */ (0, R.jsx)("div", {
		ref: (t) => {
			r.current[e.value] = t;
		},
		className: "sc-step-panel",
		role: "region",
		style: { display: e.value === t ? void 0 : "none" },
		children: e.content
	}, e.value)) });
}
//#endregion
//#region src/pages/design/index.tsx
var mh = /* @__PURE__ */ n({
	default: () => sh,
	page: () => hh
}), hh = "scorecard_panel";
//#endregion
//#region src/components/DataExport.tsx
k();
var gh = [
	{
		key: "xlsx",
		label: "Excel (.xlsx, read-only)"
	},
	{
		key: "sav",
		label: "SPSS (.sav)"
	},
	{
		key: "dta",
		label: "Stata (.dta)"
	},
	{
		key: "parquet",
		label: "Parquet (.parquet)"
	}
];
function _h({ ns: e, label: t = "Download data", variant: n = "outline-secondary", block: r, className: i, t: a = (e) => e }) {
	let [o, s] = O(!1), c = D(null);
	return E(() => {
		if (!o) return;
		let e = (e) => {
			c.current && !c.current.contains(e.target) && s(!1);
		};
		return document.addEventListener("click", e), () => document.removeEventListener("click", e);
	}, [o]), /* @__PURE__ */ (0, R.jsxs)("div", {
		ref: c,
		className: `dropdown tw-export${r ? " w-100" : ""}${i ? " " + i : ""}`,
		children: [/* @__PURE__ */ (0, R.jsxs)("button", {
			type: "button",
			className: `btn btn-${n} btn-sm dropdown-toggle-split tw-export-btn${r ? " w-100" : ""}`,
			"aria-expanded": o,
			onClick: () => s(!o),
			title: a("The data as it is now, after cleaning"),
			children: [
				/* @__PURE__ */ (0, R.jsx)(mn, { size: 14 }),
				" ",
				a(t),
				" ",
				/* @__PURE__ */ (0, R.jsx)(Dt, { size: 13 })
			]
		}), /* @__PURE__ */ (0, R.jsx)("div", {
			className: `dropdown-menu tw-export-menu${o ? " show" : ""}`,
			children: gh.map((t) => /* @__PURE__ */ (0, R.jsx)($d, {
				id: `${e}-${t.key}`,
				tagName: "a",
				className: "dropdown-item shiny-download-link",
				download: "",
				target: "_blank",
				onClick: () => s(!1),
				children: a(t.label)
			}, t.key))
		})]
	});
}
//#endregion
//#region src/pages/dq/common.tsx
var X = (e) => `dq_1-${e}`;
function vh({ items: e }) {
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-dq-kpis",
		children: e.map((e) => /* @__PURE__ */ (0, R.jsxs)("div", {
			className: `tw-dq-kpi tone-${e.tone ?? "blue"}`,
			children: [/* @__PURE__ */ (0, R.jsx)("span", {
				className: "tw-dq-kpi-icon",
				"aria-hidden": !0,
				children: e.icon
			}), /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-dq-kpi-body",
				children: [
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "tw-dq-kpi-label",
						children: e.label
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "tw-dq-kpi-value",
						children: e.id ? /* @__PURE__ */ (0, R.jsx)(Sf, { id: X(e.id) }) : e.value
					}),
					e.subId ? /* @__PURE__ */ (0, R.jsx)("div", {
						className: "tw-dq-kpi-sub",
						children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: X(e.subId) })
					}) : e.sub ? /* @__PURE__ */ (0, R.jsx)("div", {
						className: "tw-dq-kpi-sub",
						children: e.sub
					}) : null
				]
			})]
		}, e.label))
	});
}
function yh({ children: e, actions: t, intro: n }) {
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "card tw-card tw-dq-toolbar",
		children: /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "card-body",
			children: [n ? /* @__PURE__ */ (0, R.jsx)("p", {
				className: "tw-dq-intro",
				children: n
			}) : null, /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-dq-toolbar-row",
				children: [e, t ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-dq-toolbar-actions",
					children: t
				}) : null]
			})]
		})
	});
}
var bh = ({ children: e }) => /* @__PURE__ */ (0, R.jsx)("div", {
	className: "tw-dq-note",
	children: e
});
//#endregion
//#region src/pages/dq/HealthTab.tsx
k();
var xh = {
	ok: /* @__PURE__ */ (0, R.jsx)(Lt, { size: 18 }),
	review: /* @__PURE__ */ (0, R.jsx)(na, { size: 18 }),
	na: /* @__PURE__ */ (0, R.jsx)(Vt, { size: 18 })
}, Sh = {
	ok: ["tw-pill-ok", "OK"],
	review: ["tw-pill-review", "Review"],
	na: ["tw-pill-na", "Not checked"]
};
function Ch({ t: e }) {
	let t = D(null);
	V(X("hc_table"), t);
	let n = L(X("hc_table")), r = qd(X("hc_go"), null, {
		debounceMs: 0,
		priority: "event"
	}), i = (e) => n?.rows.filter((t) => t.status === e).length ?? 0;
	return /* @__PURE__ */ (0, R.jsxs)(H, {
		title: e("Health check of the data in scope"),
		icon: /* @__PURE__ */ (0, R.jsx)(Xn, { size: 15 }),
		actions: /* @__PURE__ */ (0, R.jsx)(B, {
			id: X("hc_run"),
			label: e(n ? "Run again" : "Run the health check"),
			icon: /* @__PURE__ */ (0, R.jsx)(Xr, { size: 13 }),
			variant: "primary"
		}),
		children: [/* @__PURE__ */ (0, R.jsx)("p", {
			className: "tw-dq-note",
			children: e("A quick pass with the rules of each tab. Review opens the tab with the detail and the corrections; the Data quality report (sidebar) records everything.")
		}), /* @__PURE__ */ (0, R.jsx)("div", {
			ref: t,
			children: n ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-hc-summary",
					children: [
						/* @__PURE__ */ (0, R.jsxs)("span", {
							className: "tw-pill tw-pill-review",
							children: [
								i("review"),
								" ",
								e("to review")
							]
						}),
						/* @__PURE__ */ (0, R.jsxs)("span", {
							className: "tw-pill tw-pill-ok",
							children: [i("ok"), " OK"]
						}),
						i("na") > 0 && /* @__PURE__ */ (0, R.jsxs)("span", {
							className: "tw-pill tw-pill-na",
							children: [
								i("na"),
								" ",
								e("not checked")
							]
						})
					]
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-hc",
					role: "table",
					children: n.rows.map((t) => /* @__PURE__ */ (0, R.jsxs)("div", {
						className: `tw-hc-row ${t.status}`,
						role: "row",
						children: [
							/* @__PURE__ */ (0, R.jsx)("span", {
								className: `tw-hc-icon ${t.status}`,
								"aria-hidden": !0,
								children: xh[t.status]
							}),
							/* @__PURE__ */ (0, R.jsx)("span", {
								className: "tw-hc-check",
								children: e(t.check)
							}),
							/* @__PURE__ */ (0, R.jsx)("span", {
								className: "tw-hc-found",
								children: t.found
							}),
							/* @__PURE__ */ (0, R.jsx)("span", {
								className: `tw-pill ${Sh[t.status][0]}`,
								children: e(Sh[t.status][1])
							}),
							/* @__PURE__ */ (0, R.jsx)("button", {
								type: "button",
								className: `btn btn-sm ${t.status === "review" ? "btn-outline-primary" : "btn-outline-secondary"}`,
								onClick: () => r(t.tab),
								children: e("Review")
							})
						]
					}, t.check))
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-hc-foot",
					children: [
						e("Checked on"),
						" ",
						n.n.toLocaleString("en-US"),
						" ",
						e("records"),
						", ",
						n.at,
						". ",
						e("Run it again after corrections.")
					]
				})
			] }) : /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("Not run yet"),
				sub: e("Click Run the health check to see what needs attention.")
			})
		})]
	});
}
//#endregion
//#region src/pages/dq/SpellingTab.tsx
function wh({ t: e }) {
	let t = L(X("dq_names_metric")), n = L(X("dq_names_empty"));
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
		/* @__PURE__ */ (0, R.jsxs)(yh, {
			actions: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: X("btn_open_edit"),
					label: e("Edit selected"),
					icon: /* @__PURE__ */ (0, R.jsx)(Kr, { size: 13 })
				}),
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: X("btn_delete_all_missing"),
					label: e("Delete rows with missing names"),
					icon: /* @__PURE__ */ (0, R.jsx)(ea, { size: 13 }),
					variant: "outline-danger"
				}),
				/* @__PURE__ */ (0, R.jsx)(bf, {
					id: X("download_audit"),
					label: e("Export"),
					icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 13 }),
					variant: "outline-secondary"
				})
			] }),
			children: [
				/* @__PURE__ */ (0, R.jsx)(z, {
					id: X("dq_name_cols"),
					label: e("Name columns to audit"),
					help: e("Head of household and alternates"),
					multiple: !0,
					actions: !0,
					placeholder: e("Select all columns representing names..."),
					className: "wide"
				}),
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: X("dq_names_check"),
					label: e("Check names"),
					icon: /* @__PURE__ */ (0, R.jsx)(gi, { size: 13 }),
					variant: "primary"
				}),
				t && /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-dq-metric",
					children: [/* @__PURE__ */ (0, R.jsx)("div", {
						className: "tw-dq-metric-label",
						children: e("Invalid records")
					}), /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-dq-metric-value",
						children: [t.n.toLocaleString("en-US"), /* @__PURE__ */ (0, R.jsxs)("small", { children: [
							t.pct,
							"% ",
							e("of selected")
						] })]
					})]
				})
			]
		}),
		n && /* @__PURE__ */ (0, R.jsx)("div", {
			className: "card tw-card tw-dq-names-empty",
			children: /* @__PURE__ */ (0, R.jsx)("div", {
				className: "card-body",
				children: n === "pick" ? /* @__PURE__ */ (0, R.jsx)(Y, {
					title: e("Pick the name columns to audit"),
					sub: e("Choose the columns holding names (head of household, alternates) above, then click Check names: records with missing or suspicious names are listed here.")
				}) : /* @__PURE__ */ (0, R.jsx)(Y, {
					title: e("No suspicious names"),
					sub: e("Every record has a plausible name in the columns picked.")
				})
			})
		}),
		/* @__PURE__ */ (0, R.jsx)("div", {
			style: { display: t && t.n > 0 ? void 0 : "none" },
			children: /* @__PURE__ */ (0, R.jsxs)(H, {
				title: e("Records with missing or suspicious names"),
				icon: /* @__PURE__ */ (0, R.jsx)(Mi, { size: 15 }),
				full: !0,
				children: [/* @__PURE__ */ (0, R.jsx)("p", {
					className: "tw-dq-note",
					children: e("Select a record, then Edit selected to correct its names or delete it. Every change goes to the audit trail.")
				}), /* @__PURE__ */ (0, R.jsx)(zf, {
					id: X("dq_names_redflags"),
					compact: !0
				})]
			})
		})
	] });
}
//#endregion
//#region src/pages/dq/LocationTab.tsx
var Th = [
	"Admin 1",
	"Admin 2",
	"Admin 3",
	"Admin 4",
	"Village"
];
function Eh({ t: e }) {
	let t = L(X("location_hint")), n = L(X("norm_selection")) ?? [];
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
		/* @__PURE__ */ (0, R.jsxs)(yh, {
			intro: e("Standardise the spelling of place names across the dataset: pick a level, select the variants of one name, type the correct spelling and apply."),
			actions: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: X("btn_apply_norm"),
					label: e("Apply to selected"),
					icon: /* @__PURE__ */ (0, R.jsx)(Aa, { size: 13 }),
					variant: "primary"
				}),
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: X("btn_select_shown"),
					label: e("Select all shown"),
					icon: /* @__PURE__ */ (0, R.jsx)(Ct, { size: 13 }),
					variant: "outline-secondary",
					title: e("Select every row matching the table search")
				}),
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: X("btn_clear_selection"),
					label: e("Deselect all"),
					icon: /* @__PURE__ */ (0, R.jsx)(vn, { size: 13 }),
					variant: "outline-secondary"
				}),
				/* @__PURE__ */ (0, R.jsx)(bf, {
					id: X("download_locations"),
					label: e("Export"),
					icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 13 }),
					variant: "outline-secondary"
				})
			] }),
			children: [
				/* @__PURE__ */ (0, R.jsx)(z, {
					id: X("norm_col"),
					label: e("Level to review"),
					choices: Th,
					value: "Admin 1"
				}),
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: X("norm_show"),
					label: e("Show names"),
					icon: /* @__PURE__ */ (0, R.jsx)(br, { size: 13 })
				}),
				/* @__PURE__ */ (0, R.jsx)(hf, {
					id: X("correct_name"),
					label: e("Correct spelling"),
					placeholder: e("New spelling...")
				})
			]
		}),
		t && /* @__PURE__ */ (0, R.jsx)("div", {
			className: "card tw-card",
			children: /* @__PURE__ */ (0, R.jsx)("div", {
				className: "card-body",
				children: t.state === "none" ? /* @__PURE__ */ (0, R.jsx)(Y, {
					title: e("Choose a level"),
					sub: e("Pick the level to review, then click Show names.")
				}) : /* @__PURE__ */ (0, R.jsx)(Y, {
					title: e("This level is not mapped"),
					sub: `${e("No column is mapped to")} ${e(t.level ?? "this level")}. ${e("Map it in Setup, or pick a level your dataset provides.")}`
				})
			})
		}),
		n.length ? /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-dq-chips tw-dq-norm-sel",
			children: [/* @__PURE__ */ (0, R.jsxs)("strong", { children: [
				n.length,
				" ",
				e("selected")
			] }), n.map((e) => /* @__PURE__ */ (0, R.jsxs)("span", {
				className: "tw-dq-chip",
				children: [e.name, /* @__PURE__ */ (0, R.jsx)("em", { children: e.n.toLocaleString("en-US") })]
			}, e.name))]
		}) : /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-dq-chips empty tw-dq-norm-sel",
			children: [
				/* @__PURE__ */ (0, R.jsx)(Ir, { size: 14 }),
				" ",
				e("Click the rows to merge, or search and use Select all shown.")
			]
		}),
		/* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-grid-2",
			children: [/* @__PURE__ */ (0, R.jsx)(H, {
				title: e("Names and their records"),
				icon: /* @__PURE__ */ (0, R.jsx)(Oi, { size: 15 }),
				full: !0,
				children: /* @__PURE__ */ (0, R.jsx)(zf, {
					id: X("tab_location_norm"),
					compact: !0
				})
			}), /* @__PURE__ */ (0, R.jsxs)(H, {
				title: e("How the names nest"),
				icon: /* @__PURE__ */ (0, R.jsx)(Br, { size: 15 }),
				full: !0,
				children: [/* @__PURE__ */ (0, R.jsx)("p", {
					className: "tw-dq-note",
					children: e("Each box is a place, sized by its records; click one to zoom in. Near-identical names side by side are candidates to merge.")
				}), /* @__PURE__ */ (0, R.jsx)(U, { id: X("dq_location_treemap") })]
			})]
		})
	] });
}
//#endregion
//#region src/pages/dq/MissingTab.tsx
k();
var Dh = [
	"Admin 1",
	"Admin 2",
	"Admin 3",
	"Admin 4",
	"Village"
], Oh = {
	ok: {
		icon: /* @__PURE__ */ (0, R.jsx)(Lt, { size: 18 }),
		tone: "green"
	},
	warn: {
		icon: /* @__PURE__ */ (0, R.jsx)(Nt, { size: 18 }),
		tone: "amber"
	},
	info: {
		icon: /* @__PURE__ */ (0, R.jsx)(gr, { size: 18 }),
		tone: "cyan"
	},
	bad: {
		icon: /* @__PURE__ */ (0, R.jsx)(Ft, { size: 18 }),
		tone: "red"
	}
};
function kh({ t: e }) {
	let t = L(X("missing_results")), n = L(X("missing_kpis")), r = D(null);
	return V(X("missing_kpis"), r), E(() => {
		Mf();
	}, [t]), /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
		/* @__PURE__ */ (0, R.jsxs)(yh, { children: [
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: X("mandatory_vars"),
				label: e("Mandatory fields to check"),
				multiple: !0,
				actions: !0,
				className: "wide"
			}),
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: X("missing_geo_level"),
				label: e("Geographic level"),
				choices: Dh,
				value: "Admin 1"
			}),
			/* @__PURE__ */ (0, R.jsx)(B, {
				id: X("btn_apply_missing"),
				label: e("Apply"),
				icon: /* @__PURE__ */ (0, R.jsx)(Rn, { size: 13 }),
				variant: "primary"
			})
		] }),
		t === !1 && /* @__PURE__ */ (0, R.jsx)("div", {
			className: "card tw-card",
			children: /* @__PURE__ */ (0, R.jsx)("div", {
				className: "card-body",
				children: /* @__PURE__ */ (0, R.jsx)(Y, {
					title: e("No missing-data check yet"),
					sub: e("Pick the fields that must be filled in, choose a geographic level, then click Apply.")
				})
			})
		}),
		/* @__PURE__ */ (0, R.jsxs)("div", {
			ref: r,
			className: "d-flex flex-column gap-3",
			style: { display: t ? void 0 : "none" },
			children: [n && /* @__PURE__ */ (0, R.jsx)(vh, { items: n.map((t) => ({
				label: e(t.label),
				value: t.value,
				sub: t.sub,
				...Oh[t.tone]
			})) }), /* @__PURE__ */ (0, R.jsx)(Wf, { tabs: [
				{
					value: "field",
					label: e("By field"),
					icon: /* @__PURE__ */ (0, R.jsx)(gr, { size: 14 }),
					content: /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-grid-75",
						children: [/* @__PURE__ */ (0, R.jsxs)(H, {
							title: e("Completeness by field"),
							full: !0,
							children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Green: 95% or more filled in; amber: 90 to 95%; red: under 90%.") }), /* @__PURE__ */ (0, R.jsx)(U, { id: X("plot_field_completeness") })]
						}), /* @__PURE__ */ (0, R.jsx)(H, {
							title: e("Column health"),
							full: !0,
							children: /* @__PURE__ */ (0, R.jsx)(zf, {
								id: X("tab_col_health"),
								compact: !0,
								searchable: !1
							})
						})]
					})
				},
				{
					value: "patterns",
					label: e("Patterns"),
					icon: /* @__PURE__ */ (0, R.jsx)(Wn, { size: 14 }),
					content: /* @__PURE__ */ (0, R.jsxs)(H, {
						title: e("Which fields go missing together"),
						full: !0,
						children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Top: the most frequent combinations of empty fields. Bottom: the fields in each combination, with each field's total on the left.") }), /* @__PURE__ */ (0, R.jsx)(U, { id: X("plot_missing_upset") })]
					})
				},
				{
					value: "where",
					label: e("By location"),
					icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 14 }),
					content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)(H, {
						title: e("Gap rate by location"),
						full: !0,
						children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Share of households with at least one checked field empty, the 50 locations with the most gaps.") }), /* @__PURE__ */ (0, R.jsx)(U, { id: X("plot_geo_missing_bars") })]
					}), /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-grid-2",
						children: [/* @__PURE__ */ (0, R.jsxs)(H, {
							title: e("Categorical fields by location"),
							full: !0,
							children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Share of answers left empty, by field and location.") }), /* @__PURE__ */ (0, R.jsx)(U, { id: X("plot_missing_qualitative") })]
						}), /* @__PURE__ */ (0, R.jsxs)(H, {
							title: e("Numeric fields by location"),
							full: !0,
							children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Number of answers left empty, by field and location.") }), /* @__PURE__ */ (0, R.jsx)(U, { id: X("plot_missing_quantitative") })]
						})]
					})] })
				}
			] })]
		})
	] });
}
//#endregion
//#region src/pages/dq/Insights.tsx
var Ah = {
	people: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 14 }),
	stopwatch: /* @__PURE__ */ (0, R.jsx)(Qi, { size: 14 }),
	"calendar-event": /* @__PURE__ */ (0, R.jsx)(lt, { size: 14 }),
	speedometer2: /* @__PURE__ */ (0, R.jsx)(Bn, { size: 14 }),
	"ui-checks": /* @__PURE__ */ (0, R.jsx)(gr, { size: 14 }),
	"arrow-down-up": /* @__PURE__ */ (0, R.jsx)(ze, { size: 14 }),
	bullseye: /* @__PURE__ */ (0, R.jsx)(Wi, { size: 14 }),
	"person-badge": /* @__PURE__ */ (0, R.jsx)(nr, { size: 14 }),
	"geo-alt": /* @__PURE__ */ (0, R.jsx)(Er, { size: 14 }),
	"question-octagon": /* @__PURE__ */ (0, R.jsx)(Ut, { size: 14 }),
	signpost: /* @__PURE__ */ (0, R.jsx)(Oi, { size: 14 })
};
function jh({ items: e, t, onPick: n }) {
	return e.length ? /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-dq-insights",
		children: e.map((e) => /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-dq-insight",
			children: [
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-dq-insight-label",
					children: [
						Ah[e.icon] ?? /* @__PURE__ */ (0, R.jsx)(ir, { size: 14 }),
						" ",
						t(e.label)
					]
				}),
				e.value != null && /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-dq-insight-value",
					children: e.value
				}),
				e.sub && /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-dq-insight-sub",
					children: t(e.sub)
				}),
				e.pick && n && /* @__PURE__ */ (0, R.jsx)("button", {
					type: "button",
					className: "btn btn-link p-0 tw-link tw-dq-insight-pick",
					onClick: () => n(e.pick),
					children: t(e.pick.label)
				})
			]
		}, e.label))
	}) : null;
}
//#endregion
//#region src/pages/dq/OutliersTab.tsx
k();
var Mh = [
	{
		value: "IQR",
		label: "IQR (Tukey)"
	},
	{
		value: "Z",
		label: "Z-Score (mean/SD)"
	},
	{
		value: "MAD",
		label: "Modified Z (MAD)"
	},
	{
		value: "none",
		label: "Allowed range only"
	}
], Nh = {
	IQR: {
		label: "IQR multiplier",
		min: 1,
		max: 5,
		value: 1.5
	},
	Z: {
		label: "Standard deviations",
		min: 1,
		max: 6,
		value: 3
	},
	MAD: {
		label: "Modified-Z multiplier",
		min: 1,
		max: 6,
		value: 3.5
	}
}, Ph = [
	{
		value: "cap",
		label: "Cap at the limits"
	},
	{
		value: "na",
		label: "Set to missing"
	},
	{
		value: "median",
		label: "Replace with Median"
	},
	{
		value: "mean",
		label: "Replace with Mean"
	},
	{
		value: "knn",
		label: "K-Nearest Neighbors"
	},
	{
		value: "drop",
		label: "Drop Row entirely"
	}
];
function Fh({ t: e }) {
	let t = I(X("outlier_method")) || "IQR", n = Nh[t], r = (t) => t.map((t) => ({
		value: t.value,
		label: e(t.label)
	})), i = L(X("range_hint")), a = L(X("outlier_insights")), o = D(null);
	V(X("outlier_insights"), o);
	let s = qd(X("ol_pick"), null, {
		debounceMs: 0,
		priority: "event"
	}), c = (I(X("ol_scan")) ?? 0) > 0;
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
		/* @__PURE__ */ (0, R.jsxs)(yh, {
			actions: /* @__PURE__ */ (0, R.jsx)(B, {
				id: X("btn_apply_outlier_correction"),
				label: e("Correct all flagged"),
				icon: /* @__PURE__ */ (0, R.jsx)(Aa, { size: 13 })
			}),
			children: [
				/* @__PURE__ */ (0, R.jsx)(z, {
					id: X("outlier_var"),
					label: e("Variable")
				}),
				/* @__PURE__ */ (0, R.jsx)(z, {
					id: X("outlier_method"),
					label: e("Detection method"),
					choices: r(Mh),
					value: "IQR"
				}),
				n ? /* @__PURE__ */ (0, R.jsx)(vf, {
					id: X("outlier_threshold"),
					label: e(n.label),
					min: n.min,
					max: n.max,
					step: .5,
					value: n.value
				}, t) : null,
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-dq-fieldset",
					children: [/* @__PURE__ */ (0, R.jsx)("label", {
						className: "form-label",
						title: e("The values this variable can plausibly take (e.g. a household size of 1 to 30). Values outside it are flagged whatever the distribution says."),
						children: e("Allowed range")
					}), /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-dq-range",
						children: [/* @__PURE__ */ (0, R.jsx)(mf, {
							id: X("range_min"),
							placeholder: "min"
						}), /* @__PURE__ */ (0, R.jsx)(mf, {
							id: X("range_max"),
							placeholder: "max"
						})]
					})]
				}),
				/* @__PURE__ */ (0, R.jsx)(z, {
					id: X("outlier_correction_method"),
					label: e("Correction"),
					choices: r(Ph),
					value: "cap"
				})
			]
		}),
		i === "inverted" && /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-dq-hint danger",
			children: [
				/* @__PURE__ */ (0, R.jsx)(na, { size: 14 }),
				" ",
				e("The allowed minimum is above the maximum, so the range is ignored.")
			]
		}),
		i === "tip" && /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-dq-hint",
			children: [
				/* @__PURE__ */ (0, R.jsx)(ur, { size: 14 }),
				" ",
				e("Tip: enter the allowed range for this variable (for example 1 to 30 for a household size). A statistical test only sees what is unusual; the range also catches what is impossible.")
			]
		}),
		i === "suggested" && /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-dq-hint",
			children: [
				/* @__PURE__ */ (0, R.jsx)(ir, { size: 14 }),
				" ",
				e("Suggested range for this field; change it if your context differs.")
			]
		}),
		/* @__PURE__ */ (0, R.jsx)(vh, { items: [
			{
				label: e("Values checked"),
				id: "outlier_total",
				icon: /* @__PURE__ */ (0, R.jsx)(vr, { size: 18 }),
				tone: "blue"
			},
			{
				label: e("Flagged"),
				id: "outlier_count",
				subId: "outlier_verified",
				icon: /* @__PURE__ */ (0, R.jsx)(na, { size: 18 }),
				tone: "amber"
			},
			{
				label: e("Flag rate"),
				id: "outlier_rate",
				icon: /* @__PURE__ */ (0, R.jsx)(Jr, { size: 18 }),
				tone: "cyan"
			},
			{
				label: e("Accepted values"),
				id: "outlier_bounds",
				subId: "outlier_bounds_src",
				icon: /* @__PURE__ */ (0, R.jsx)(oi, { size: 18 }),
				tone: "grey"
			}
		] }),
		/* @__PURE__ */ (0, R.jsx)(Wf, {
			id: X("outlier_tabs"),
			value: "dist",
			tabs: [
				{
					value: "dist",
					label: e("Distribution"),
					icon: /* @__PURE__ */ (0, R.jsx)(yt, { size: 14 }),
					content: /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-grid-2",
						children: [/* @__PURE__ */ (0, R.jsxs)(H, {
							title: e("Distribution and limits"),
							full: !0,
							children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Red dashed: statistical bounds. Blue dotted: allowed range.") }), /* @__PURE__ */ (0, R.jsx)(U, {
								id: X("plot_outlier_hist"),
								height: 320
							})]
						}), /* @__PURE__ */ (0, R.jsxs)(H, {
							title: e("By area"),
							full: !0,
							children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("The spread in each Admin 1; red points lie beyond the whiskers.") }), /* @__PURE__ */ (0, R.jsx)(U, {
								id: X("plot_outlier_box"),
								height: 320
							})]
						})]
					})
				},
				{
					value: "where",
					label: e("Where they come from"),
					icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 14 }),
					content: /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-grid-2",
						children: [/* @__PURE__ */ (0, R.jsx)(H, {
							title: e("Flag rate by Admin 1"),
							full: !0,
							children: /* @__PURE__ */ (0, R.jsx)(U, { id: X("plot_outlier_admin_rates") })
						}), /* @__PURE__ */ (0, R.jsx)(H, {
							title: e("Flag rate by enumerator"),
							full: !0,
							children: /* @__PURE__ */ (0, R.jsx)(U, { id: X("plot_outlier_enum_rates") })
						})]
					})
				},
				{
					value: "flagged",
					label: e("Most extreme values"),
					icon: /* @__PURE__ */ (0, R.jsx)(Ve, { size: 14 }),
					content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)("div", {
						ref: o,
						className: "tw-dq-ol-insights",
						children: a?.empty ? /* @__PURE__ */ (0, R.jsx)(Y, {
							title: e(a.empty.title),
							sub: e(a.empty.sub)
						}) : /* @__PURE__ */ (0, R.jsx)(jh, {
							items: a?.cards ?? [],
							t: e,
							onPick: (e) => s({
								what: e.what,
								value: e.value,
								n: Math.random()
							})
						})
					}), /* @__PURE__ */ (0, R.jsxs)(H, {
						title: e("Flagged values, most extreme first"),
						icon: /* @__PURE__ */ (0, R.jsx)(gr, { size: 15 }),
						full: !0,
						children: [/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-dq-cardbar",
							children: [
								/* @__PURE__ */ (0, R.jsx)(B, {
									id: X("ol_select_all"),
									label: e("Select all"),
									variant: "outline-secondary"
								}),
								/* @__PURE__ */ (0, R.jsx)(B, {
									id: X("ol_select_none"),
									label: e("Clear selection"),
									variant: "outline-secondary"
								}),
								/* @__PURE__ */ (0, R.jsx)("span", {
									className: "tw-dq-sel",
									children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: X("ol_selected_n") })
								}),
								/* @__PURE__ */ (0, R.jsxs)("div", {
									className: "tw-dq-push",
									children: [
										/* @__PURE__ */ (0, R.jsx)(B, {
											id: X("ol_correct_sel"),
											label: e("Correct selected"),
											icon: /* @__PURE__ */ (0, R.jsx)(Aa, { size: 13 })
										}),
										/* @__PURE__ */ (0, R.jsx)(B, {
											id: X("ol_set_value"),
											label: e("Set a value"),
											icon: /* @__PURE__ */ (0, R.jsx)(Kr, { size: 13 })
										}),
										/* @__PURE__ */ (0, R.jsx)(B, {
											id: X("ol_verify"),
											label: e("Mark as verified"),
											icon: /* @__PURE__ */ (0, R.jsx)(Tt, { size: 13 }),
											variant: "outline-secondary"
										}),
										/* @__PURE__ */ (0, R.jsx)(bf, {
											id: X("ol_download"),
											label: e("Export"),
											icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 13 }),
											variant: "outline-secondary"
										})
									]
								})
							]
						}), /* @__PURE__ */ (0, R.jsx)(zf, {
							id: X("ol_table"),
							compact: !0
						})]
					})] })
				},
				{
					value: "all",
					label: e("All numeric variables"),
					icon: /* @__PURE__ */ (0, R.jsx)(Wn, { size: 14 }),
					content: /* @__PURE__ */ (0, R.jsxs)(H, {
						title: e("Every numeric variable, with the settings above"),
						icon: /* @__PURE__ */ (0, R.jsx)(Zt, { size: 15 }),
						full: !0,
						actions: /* @__PURE__ */ (0, R.jsx)(B, {
							id: X("ol_scan"),
							label: e("Audit all numeric variables"),
							icon: /* @__PURE__ */ (0, R.jsx)(gi, { size: 13 })
						}),
						children: [
							/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Checks every numeric column with the detection method and the allowed ranges you entered. Click a row to open that variable.") }),
							!c && /* @__PURE__ */ (0, R.jsx)(Y, {
								title: e("Not run yet"),
								sub: e("Click Audit all numeric variables to check every numeric column at once.")
							}),
							/* @__PURE__ */ (0, R.jsx)(zf, {
								id: X("ol_scan_table"),
								compact: !0
							})
						]
					})
				}
			]
		})
	] });
}
//#endregion
//#region src/pages/dq/DuplicatesTab.tsx
function Ih({ t: e }) {
	let t = I(X("duplicate_fuzzy")), n = L(X("dup_has_rows")), r = L(X("dup_hint"));
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
		/* @__PURE__ */ (0, R.jsxs)(yh, { children: [
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: X("duplicate_vars"),
				label: e("Columns that identify a household"),
				multiple: !0,
				actions: !0,
				className: "wide"
			}),
			/* @__PURE__ */ (0, R.jsx)(gf, {
				id: X("duplicate_fuzzy"),
				label: e("Fuzzy matching"),
				asSwitch: !0,
				className: "tw-dq-btn"
			}),
			/* @__PURE__ */ (0, R.jsx)("div", {
				className: t ? "" : "tw-dq-dim",
				style: { flex: "0 1 200px" },
				title: e("How alike two records must be to count as the same household: 90% lets about one character in ten differ, so longer names allow more typos than short ones. 100% means identical."),
				children: /* @__PURE__ */ (0, R.jsx)(vf, {
					id: X("duplicate_fuzzy_dist"),
					label: e("Similarity"),
					min: 50,
					max: 100,
					step: 1,
					value: 90,
					format: (e) => `${e}%`
				})
			}),
			/* @__PURE__ */ (0, R.jsx)(B, {
				id: X("btn_refresh_duplicates"),
				label: e("Find duplicates"),
				icon: /* @__PURE__ */ (0, R.jsx)(gi, { size: 13 }),
				variant: "primary"
			}),
			/* @__PURE__ */ (0, R.jsx)(bf, {
				id: X("download_duplicates"),
				label: e("Export"),
				icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 13 }),
				variant: "outline-secondary",
				className: "tw-dq-btn"
			})
		] }),
		/* @__PURE__ */ (0, R.jsx)(vh, { items: [
			{
				label: e("Records checked"),
				id: "dup_total",
				icon: /* @__PURE__ */ (0, R.jsx)(vr, { size: 18 }),
				tone: "blue"
			},
			{
				label: e("Duplicate records"),
				id: "dup_count",
				icon: /* @__PURE__ */ (0, R.jsx)(cn, { size: 18 }),
				tone: "amber"
			},
			{
				label: e("Duplicate groups"),
				id: "dup_groups",
				icon: /* @__PURE__ */ (0, R.jsx)(Br, { size: 18 }),
				tone: "cyan"
			},
			{
				label: e("Exact copies"),
				id: "dup_exact",
				sub: e("identical on every column: safe to remove"),
				icon: /* @__PURE__ */ (0, R.jsx)(An, { size: 18 }),
				tone: "red"
			}
		] }),
		r?.state === "none" && /* @__PURE__ */ (0, R.jsx)("div", {
			className: "card tw-card",
			children: /* @__PURE__ */ (0, R.jsx)("div", {
				className: "card-body",
				children: /* @__PURE__ */ (0, R.jsx)(Y, {
					title: e("No duplicate analysis yet"),
					sub: e("Choose the columns that identify a record, then click Find duplicates.")
				})
			})
		}),
		r?.state === "clean" && /* @__PURE__ */ (0, R.jsx)("div", {
			className: "card tw-card",
			children: /* @__PURE__ */ (0, R.jsx)("div", {
				className: "card-body",
				children: /* @__PURE__ */ (0, R.jsx)(Y, {
					title: e("No duplicates found"),
					sub: `${e("Checked")} ${(r.n ?? 0).toLocaleString("en-US")} ${e("records on the selected columns.")}`
				})
			})
		}),
		/* @__PURE__ */ (0, R.jsx)("div", {
			style: { display: n ? void 0 : "none" },
			children: /* @__PURE__ */ (0, R.jsxs)(H, {
				title: e("Duplicate groups"),
				icon: /* @__PURE__ */ (0, R.jsx)(cn, { size: 15 }),
				full: !0,
				children: [
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-dq-cardbar",
						children: [
							/* @__PURE__ */ (0, R.jsx)(B, {
								id: X("dup_sel_extra"),
								label: e("Select all but the first of each group"),
								variant: "outline-secondary"
							}),
							/* @__PURE__ */ (0, R.jsx)(B, {
								id: X("dup_sel_exact"),
								label: e("Select exact copies"),
								variant: "outline-secondary"
							}),
							/* @__PURE__ */ (0, R.jsx)(B, {
								id: X("dup_sel_none"),
								label: e("Clear selection"),
								variant: "outline-secondary"
							}),
							/* @__PURE__ */ (0, R.jsx)("span", {
								className: "tw-dq-sel",
								children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: X("dup_selected_n") })
							}),
							/* @__PURE__ */ (0, R.jsx)("div", {
								className: "tw-dq-push",
								children: /* @__PURE__ */ (0, R.jsx)(B, {
									id: X("dup_delete"),
									label: e("Delete selected"),
									icon: /* @__PURE__ */ (0, R.jsx)(ea, { size: 13 }),
									variant: "outline-danger"
								})
							})
						]
					}),
					/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Each band is one group. 'Differs in' lists the columns where its records disagree; none means exact copies. Compare shows a group side by side, and you can delete from there too.") }),
					/* @__PURE__ */ (0, R.jsx)(zf, {
						id: X("dq_duplicate_table"),
						compact: !0
					})
				]
			})
		})
	] });
}
//#endregion
//#region src/pages/dq/EnumeratorTab.tsx
k();
function Lh({ t: e }) {
	let t = D(null);
	V(X("enum_flagged_ui"), t);
	let n = L(X("enum_flagged_ui")), r = qd(X("enum_open"), null, {
		debounceMs: 0,
		priority: "event"
	}), i = n?.rules;
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		ref: t,
		className: "d-flex flex-column gap-2",
		children: [
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-dq-cardbar",
				children: [/* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-dq-rules",
					children: i && /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(ir, { size: 14 }), /* @__PURE__ */ (0, R.jsxs)("span", { children: [
						e("Flagged against the other enumerators: average interview under"),
						" ",
						i.dur_lo,
						" ",
						e("or over"),
						" ",
						i.dur_hi,
						" ",
						e("min (outside the IQR fences), missing answers over"),
						" ",
						i.miss_hi,
						"% ",
						e("(mean + 2 SD)"),
						i.day_hi ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
							", ",
							e("or more than"),
							" ",
							i.day_hi,
							" ",
							e("interviews in one day")
						] }) : null,
						"."
					] })] })
				}), /* @__PURE__ */ (0, R.jsx)(bf, {
					id: X("enum_flag_download"),
					label: e("Export flagged"),
					icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 13 }),
					variant: "outline-secondary"
				})]
			}),
			n && !n.flagged.length && /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("No enumerator flagged"),
				sub: e("Everyone's speed, completeness and daily load are in line with the team.")
			}),
			n && n.flagged.length > 0 && /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-dq-enum-grid",
				children: n.flagged.map((t) => /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-dq-insight tw-dq-enum-card",
					children: [
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-dq-enum-head",
							children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: t.id }), /* @__PURE__ */ (0, R.jsxs)("small", { children: [
								t.interviews.toLocaleString("en-US"),
								" ",
								e("interviews")
							] })]
						}),
						/* @__PURE__ */ (0, R.jsx)("ul", {
							className: "tw-dq-enum-reasons",
							children: t.reasons.map((e) => /* @__PURE__ */ (0, R.jsx)("li", { children: e }, e))
						}),
						/* @__PURE__ */ (0, R.jsx)("button", {
							type: "button",
							className: "btn btn-link p-0 tw-link align-self-start",
							onClick: () => r(t.id),
							children: e("See their interviews")
						})
					]
				}, t.id))
			})
		]
	});
}
function Rh({ t: e }) {
	let t = D(null);
	V(X("enum_speed_insights"), t);
	let n = L(X("enum_speed_insights"));
	return /* @__PURE__ */ (0, R.jsx)("div", {
		ref: t,
		children: /* @__PURE__ */ (0, R.jsx)(jh, {
			items: n ?? [],
			t: e
		})
	});
}
function zh({ t: e }) {
	let t = L(X("enum_state")), n = t && !t.mapped;
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [n && /* @__PURE__ */ (0, R.jsx)("div", {
		className: "card tw-card",
		children: /* @__PURE__ */ (0, R.jsx)("div", {
			className: "card-body",
			children: /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("No enumerator mapped"),
				sub: e("Map the enumerator in Variable Definition & Setup (Load registration data) to compare their speed, empty answers and daily load.")
			})
		})
	}), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "d-flex flex-column gap-3",
		style: { display: n ? "none" : void 0 },
		children: [/* @__PURE__ */ (0, R.jsx)(vh, { items: [
			{
				label: e("Active enumerators"),
				id: "enum_active",
				icon: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 18 }),
				tone: "blue"
			},
			{
				label: e("Interviews per enumerator"),
				id: "enum_avg_int",
				icon: /* @__PURE__ */ (0, R.jsx)(ba, { size: 18 }),
				tone: "grey"
			},
			{
				label: e("Total interviews"),
				id: "enum_total_int",
				icon: /* @__PURE__ */ (0, R.jsx)(Yt, { size: 18 }),
				tone: "cyan"
			},
			{
				label: e("Flagged for review"),
				id: "enum_flagged",
				icon: /* @__PURE__ */ (0, R.jsx)(Pn, { size: 18 }),
				tone: "red"
			}
		] }), /* @__PURE__ */ (0, R.jsx)(Wf, { tabs: [
			{
				value: "flagged",
				label: e("Flagged enumerators"),
				icon: /* @__PURE__ */ (0, R.jsx)(Pn, { size: 14 }),
				content: /* @__PURE__ */ (0, R.jsx)(Lh, { t: e })
			},
			{
				value: "speed",
				label: e("Workload and speed"),
				icon: /* @__PURE__ */ (0, R.jsx)(yt, { size: 14 }),
				content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					/* @__PURE__ */ (0, R.jsx)(Rh, { t: e }),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-grid-2",
						children: [/* @__PURE__ */ (0, R.jsxs)(H, {
							title: e("Interviews by enumerator"),
							full: !0,
							children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Red: flagged for review. Dashed line: the team median.") }), /* @__PURE__ */ (0, R.jsx)(U, { id: X("enum_interviews_plot") })]
						}), /* @__PURE__ */ (0, R.jsxs)(H, {
							title: e("Average interview duration"),
							full: !0,
							children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Green band: the team's usual range (IQR fences). Red: shorter; amber: longer. The enumerators furthest from the median are shown.") }), /* @__PURE__ */ (0, R.jsx)(U, { id: X("enum_duration_plot") })]
						})]
					}),
					/* @__PURE__ */ (0, R.jsxs)(H, {
						title: e("Interviews per day, by enumerator"),
						full: !0,
						children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Darker cells are busier days. A cell far darker than the rest of its row is a day worth checking.") }), /* @__PURE__ */ (0, R.jsx)(U, { id: X("enum_daily_plot") })]
					})
				] })
			},
			{
				value: "table",
				label: e("Performance table"),
				icon: /* @__PURE__ */ (0, R.jsx)(Ri, { size: 14 }),
				content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(H, {
					title: e("Enumerator metrics"),
					full: !0,
					className: "tw-dq-enum-table",
					children: /* @__PURE__ */ (0, R.jsx)(zf, {
						id: X("enum_metrics_table"),
						compact: !0
					})
				}), /* @__PURE__ */ (0, R.jsxs)(H, {
					title: e("Empty answers by enumerator"),
					full: !0,
					children: [/* @__PURE__ */ (0, R.jsx)(bh, { children: e("Red: over the team's limit (mean + 2 SD).") }), /* @__PURE__ */ (0, R.jsx)(U, { id: X("enum_missingness_plot") })]
				})] })
			}
		] })]
	})] });
}
//#endregion
//#region src/pages/dq/DqPage.tsx
var Bh = (e) => {
	let t = /^(\d{4})-(\d{2})-(\d{2})/.exec(e ?? "");
	return t ? `${t[3]}/${t[2]}/${t[1]}` : "";
};
function Vh({ t: e }) {
	let t = L(X("dq_meta")), n = I(X("dq_filter_adm1")), r = I(X("dq_filter_adm2")), i = I(X("dq_filter_adm3")), a = I(X("dq_filter_date")), o = [
		n,
		r,
		i
	].some((e) => Array.isArray(e) && e.length) ? [
		n,
		r,
		i
	].map((e) => Array.isArray(e) ? e.length : 0).filter(Boolean).join(" / ") + ` ${e("selected")}` : e("All areas"), s = [{
		key: "areas",
		title: e("1. Areas"),
		icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 14 }),
		summary: o,
		content: /* @__PURE__ */ (0, R.jsx)(R.Fragment, { children: [
			1,
			2,
			3
		].map((t) => /* @__PURE__ */ (0, R.jsx)(z, {
			id: X(`dq_filter_adm${t}`),
			label: `Admin ${t}`,
			multiple: !0,
			actions: !0,
			placeholder: e("All")
		}, t)) })
	}];
	t?.dates && s.push({
		key: "dates",
		title: e("2. Interview dates"),
		icon: /* @__PURE__ */ (0, R.jsx)(dt, { size: 14 }),
		summary: Array.isArray(a) && a[0] ? `${Bh(a[0])} - ${Bh(a[1])}` : e("All dates"),
		content: /* @__PURE__ */ (0, R.jsx)(yf, {
			id: X("dq_filter_date"),
			range: !0,
			value: t.dates,
			min: t.dates[0],
			max: t.dates[1]
		})
	});
	let c = /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(Hf, { steps: s }), /* @__PURE__ */ (0, R.jsxs)(Uf, { children: [
		/* @__PURE__ */ (0, R.jsxs)("div", {
			className: "d-flex gap-2",
			children: [/* @__PURE__ */ (0, R.jsx)(B, {
				id: X("btn_apply_dq_filters"),
				label: e("Apply"),
				icon: /* @__PURE__ */ (0, R.jsx)(Rn, { size: 14 }),
				variant: "primary",
				className: "flex-fill"
			}), /* @__PURE__ */ (0, R.jsx)(B, {
				id: X("btn_clear_dq_filters"),
				icon: /* @__PURE__ */ (0, R.jsx)(Ma, { size: 14 }),
				variant: "outline-secondary",
				title: e("Clear the filters")
			})]
		}),
		/* @__PURE__ */ (0, R.jsx)(bf, {
			id: X("dq_report"),
			label: e("Data quality report (HTML)"),
			icon: /* @__PURE__ */ (0, R.jsx)(On, { size: 14 }),
			className: "w-100"
		}),
		/* @__PURE__ */ (0, R.jsx)(_h, {
			ns: "export_dq",
			label: "Download the cleaned data",
			block: !0,
			t: e
		}),
		/* @__PURE__ */ (0, R.jsx)(B, {
			id: X("btn_reset_data"),
			label: e("Reset to original data"),
			icon: /* @__PURE__ */ (0, R.jsx)(ii, { size: 14 }),
			variant: "outline-danger",
			className: "w-100"
		}),
		/* @__PURE__ */ (0, R.jsx)("div", {
			className: "tw-dq-rows",
			children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: X("dq_filtered_rows") })
		})
	] })] }), l = [
		{
			value: "Health check",
			label: e("Health check"),
			icon: /* @__PURE__ */ (0, R.jsx)(Xn, { size: 14 }),
			content: /* @__PURE__ */ (0, R.jsx)(Ch, { t: e })
		},
		{
			value: "Spelling & Integrity",
			label: e("Spelling & Integrity"),
			icon: /* @__PURE__ */ (0, R.jsx)(Mi, { size: 14 }),
			content: /* @__PURE__ */ (0, R.jsx)(wh, { t: e })
		},
		{
			value: "Location names normalization",
			label: e("Location names"),
			icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 14 }),
			content: /* @__PURE__ */ (0, R.jsx)(Eh, { t: e })
		},
		{
			value: "Missing Data Checking",
			label: e("Missing data"),
			icon: /* @__PURE__ */ (0, R.jsx)(Zt, { size: 14 }),
			content: /* @__PURE__ */ (0, R.jsx)(kh, { t: e })
		},
		{
			value: "Outliers",
			label: e("Outliers"),
			icon: /* @__PURE__ */ (0, R.jsx)(Bn, { size: 14 }),
			content: /* @__PURE__ */ (0, R.jsx)(Fh, { t: e })
		},
		{
			value: "Duplicates",
			label: e("Duplicates"),
			icon: /* @__PURE__ */ (0, R.jsx)(cn, { size: 14 }),
			content: /* @__PURE__ */ (0, R.jsx)(Ih, { t: e })
		},
		{
			value: "Enumerator Performance",
			label: e("Enumerators"),
			icon: /* @__PURE__ */ (0, R.jsx)(nr, { size: 14 }),
			content: /* @__PURE__ */ (0, R.jsx)(zh, { t: e })
		}
	];
	return /* @__PURE__ */ (0, R.jsx)(Vf, {
		className: "tw-dq",
		sidebar: c,
		children: /* @__PURE__ */ (0, R.jsx)(Wf, {
			id: X("dq_tabs"),
			tabs: l,
			value: "Health check"
		})
	});
}
//#endregion
//#region src/pages/dq/index.tsx
var Hh = /* @__PURE__ */ n({
	default: () => Vh,
	page: () => Uh
}), Uh = "dq_panel", Wh = (e) => e.toLocaleString("en-US");
function Gh({ ns: e, label: t, hint: n, t: r = (e) => e }) {
	let i = L(`${e}-loaded`);
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-fileimport",
		children: [
			t ? /* @__PURE__ */ (0, R.jsx)("label", {
				className: "form-label",
				children: t
			}) : null,
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-dropzone",
				children: [/* @__PURE__ */ (0, R.jsx)(fa, {
					size: 18,
					className: "tw-dropzone-icon",
					"aria-hidden": !0
				}), /* @__PURE__ */ (0, R.jsx)(xf, {
					id: `${e}-file_ui`,
					className: "tw-dropzone-input"
				})]
			}),
			n ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "form-text",
				children: n
			}) : null,
			i ? /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-file-ok",
				children: [/* @__PURE__ */ (0, R.jsx)(Lt, {
					size: 14,
					"aria-hidden": !0
				}), /* @__PURE__ */ (0, R.jsxs)("span", { children: [
					/* @__PURE__ */ (0, R.jsx)("strong", { children: i.name || r("File loaded.") }),
					" · ",
					Wh(i.rows),
					" ",
					r("rows"),
					" · ",
					Wh(i.cols),
					" ",
					r("columns")
				] })]
			}) : null
		]
	});
}
//#endregion
//#region src/pages/import/ImportPage.tsx
var Kh = (e) => (e ?? 0).toLocaleString("en-US");
function qh({ t: e }) {
	let t = L("setup_1-state");
	return t?.loaded ? /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-imp-status",
		children: [
			t.mapped ? /* @__PURE__ */ (0, R.jsx)(Lt, {
				size: 18,
				className: "tw-imp-ok",
				"aria-hidden": !0
			}) : /* @__PURE__ */ (0, R.jsx)(zt, {
				size: 18,
				className: "tw-imp-todo",
				"aria-hidden": !0
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-imp-status-text",
				children: [/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-imp-status-main",
					children: [
						/* @__PURE__ */ (0, R.jsx)("strong", { children: Kh(t.rows) }),
						" ",
						e("rows"),
						" · ",
						/* @__PURE__ */ (0, R.jsx)("strong", { children: Kh(t.cols) }),
						" ",
						e("columns"),
						/* @__PURE__ */ (0, R.jsx)("span", {
							className: `tw-imp-badge${t.mapped ? " ok" : ""}`,
							children: t.mapped ? `${e("Variables mapped")} (${t.fields})` : e("Variables not mapped yet")
						})
					]
				}), t.source ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-imp-status-sub",
					children: t.source
				}) : null]
			}),
			/* @__PURE__ */ (0, R.jsx)(B, {
				id: "setup_1-open_modal",
				label: e("Variable Definition & Setup"),
				icon: /* @__PURE__ */ (0, R.jsx)(Ai, { size: 15 }),
				variant: t.mapped ? "outline-primary" : "primary",
				size: "md"
			})
		]
	}) : /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-imp-status tw-imp-status-empty",
		children: [/* @__PURE__ */ (0, R.jsx)(zt, {
			size: 18,
			"aria-hidden": !0
		}), /* @__PURE__ */ (0, R.jsx)("div", { children: e("No registration data yet. Load a file or pull it from a server; the variable setup opens after the import.") })]
	});
}
var Jh = (e) => /* @__PURE__ */ (0, R.jsx)("code", { children: e });
function Yh({ t: e }) {
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-imp",
		children: [
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-imp-head",
				children: [/* @__PURE__ */ (0, R.jsx)("h4", { children: e("Load household registration data") }), /* @__PURE__ */ (0, R.jsx)("p", { children: e("The list of households you will clean, check and select beneficiaries from.") })]
			}),
			/* @__PURE__ */ (0, R.jsxs)(H, {
				title: e("Household registration data"),
				icon: /* @__PURE__ */ (0, R.jsx)(Zt, { size: 15 }),
				children: [
					/* @__PURE__ */ (0, R.jsx)("p", {
						className: "tw-imp-formats",
						children: e("Excel (.xlsx), SPSS (.sav), Stata (.dta), CSV or Parquet; CSV and Parquet load fastest for large files. You can also pull the data from MODA, Kobo Toolbox or ODK Central.")
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-imp-row",
						children: [/* @__PURE__ */ (0, R.jsx)(Gh, {
							ns: "file_import_1",
							t: e
						}), /* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-imp-tools",
							children: [
								/* @__PURE__ */ (0, R.jsx)(rp, {
									ns: "moda_import_1",
									size: "sm",
									block: !1,
									t: e
								}),
								/* @__PURE__ */ (0, R.jsx)(ip, {
									ns: "calc_reg",
									size: "sm",
									t: e
								}),
								/* @__PURE__ */ (0, R.jsx)(up, {
									ns: "summary_reg",
									t: e
								}),
								/* @__PURE__ */ (0, R.jsx)(_h, {
									ns: "export_reg",
									t: e
								})
							]
						})]
					}),
					/* @__PURE__ */ (0, R.jsx)(qh, { t: e })
				]
			}),
			/* @__PURE__ */ (0, R.jsx)(H, {
				title: e("Before you start, check your data"),
				icon: /* @__PURE__ */ (0, R.jsx)(gr, { size: 15 }),
				children: /* @__PURE__ */ (0, R.jsxs)("ol", {
					className: "tw-imp-checks",
					children: [
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							e("Ensure quantitative variables (Age, HH Size, Scores) are formatted as"),
							" ",
							Jh("numeric"),
							" ",
							e("in your source file.")
						] }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							e("Vulnerability scales must be"),
							" ",
							Jh("ordered"),
							" ",
							e("(e.g., 1 to 5)."),
							" ",
							e("Fewer and shorter value labels are recommended for qualitative variables.")
						] }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							e("Records with missing"),
							" ",
							Jh("Long/Lat"),
							" ",
							e("coordinates are left off the map.")
						] }),
						/* @__PURE__ */ (0, R.jsx)("li", { children: e("Verify that Administrative names are consistent across all levels to avoid filtering errors.") }),
						/* @__PURE__ */ (0, R.jsxs)("li", { children: [
							e("Do not remove or rename the"),
							" ",
							Jh("start"),
							" / ",
							Jh("end"),
							" ",
							e("variables. They are essential for computing survey duration and tracking operational speed.")
						] })
					]
				})
			})
		]
	});
}
//#endregion
//#region src/pages/import/index.tsx
var Xh = /* @__PURE__ */ n({
	default: () => Yh,
	page: () => Zh
}), Zh = "import_panel";
//#endregion
//#region src/components/VerdictCard.tsx
k();
var Qh = (e) => typeof e == "number" && isFinite(e);
function $h(e) {
	let t = [
		"good",
		"review",
		"redesign"
	].includes(e.level) ? e.level : "unknown";
	return t === "redesign" ? e.stage === "implementation" ? "Corrective action required" : "Redesign required" : {
		good: "Within tolerance",
		review: "Review recommended",
		unknown: e.invalid ? "Tolerance not valid" : "Not enough data"
	}[t];
}
function eg({ v: e, t, labels: n, children: r }) {
	let i = [
		"good",
		"review",
		"redesign"
	].includes(e.level) ? e.level : "unknown", a = D(null), o = a.current !== i;
	E(() => {
		a.current = i;
	}, [i]);
	let s = Qh(e.lower) && Qh(e.upper), c = (n, r) => {
		if (!Qh(r)) return null;
		let i = s ? r <= e.lower ? "is-ok" : r <= e.upper ? "is-mid" : "is-bad" : "";
		return /* @__PURE__ */ (0, R.jsxs)("div", {
			className: `vd-metric ${i}`,
			children: [
				/* @__PURE__ */ (0, R.jsx)("span", {
					className: "vd-metric-label",
					children: n
				}),
				/* @__PURE__ */ (0, R.jsxs)("span", {
					className: "vd-metric-value",
					children: [(100 * r).toFixed(1), "%"]
				}),
				s && /* @__PURE__ */ (0, R.jsxs)("span", {
					className: "vd-metric-tol",
					children: [
						t("good"),
						" ",
						"≤",
						" ",
						Math.round(100 * e.lower),
						"% ",
						"·",
						" ",
						t("limit"),
						" ",
						"≤",
						" ",
						Math.round(100 * e.upper),
						"%"
					]
				})
			]
		});
	}, l = Qh(e.inclusion) || Qh(e.exclusion);
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `wfp-verdict is-${i}${o ? "" : " no-anim"}`,
		role: "status",
		children: [/* @__PURE__ */ (0, R.jsx)("div", {
			className: "vd-icon",
			children: /* @__PURE__ */ (0, R.jsx)(er, {
				size: 30,
				strokeWidth: 2.2
			})
		}), /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "vd-text",
			children: [
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "vd-head",
					children: /* @__PURE__ */ (0, R.jsx)("span", {
						className: "vd-status",
						children: t($h(e))
					})
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "vd-interp",
					children: t(e.interpretation)
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "vd-action",
					children: [/* @__PURE__ */ (0, R.jsxs)("strong", { children: [t("Recommended action:"), " "] }), t(e.action)]
				}),
				l && /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "vd-metrics",
					children: [c(n?.inclusion ?? t("Inclusion error"), e.inclusion), c(n?.exclusion ?? t("Exclusion error"), e.exclusion)]
				}),
				r
			]
		})]
	}, i);
}
//#endregion
//#region src/pages/monitoring/Dropzone.tsx
function tg({ id: e }) {
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-dropzone mb-2",
		children: [/* @__PURE__ */ (0, R.jsx)(fa, {
			size: 18,
			className: "tw-dropzone-icon",
			"aria-hidden": !0
		}), /* @__PURE__ */ (0, R.jsx)(xf, {
			id: e,
			className: "tw-dropzone-input"
		})]
	});
}
//#endregion
//#region src/pages/monitoring/RichText.tsx
k();
var ng = ({ cmd: e, title: t, children: n }) => /* @__PURE__ */ (0, R.jsx)("button", {
	type: "button",
	className: "tw-rt-btn",
	"data-cmd": e,
	title: t,
	"aria-label": t,
	children: n
});
function rg({ id: e, send: t, item: n, label: r, placeholder: i = "", rows: a = 3, value: o = "", compact: s }) {
	let c = D(null), l = D(null), u = Zd();
	return E(() => {
		l.current && (l.current.innerHTML = o);
	}, []), E(() => {
		let t = window.Shiny, n = c.current;
		if (e && u && n && t?.bindAll) return t.bindAll(n), () => t.unbindAll?.(n);
	}, [e, u]), /* @__PURE__ */ (0, R.jsxs)("div", {
		ref: c,
		className: `form-group shiny-input-container tw-rt${s ? " tw-rt-compact" : ""}`,
		style: { width: "100%" },
		children: [r ? /* @__PURE__ */ (0, R.jsx)("label", {
			className: "control-label form-label",
			htmlFor: e,
			children: r
		}) : null, /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-rt-frame",
			children: [/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-rt-toolbar",
				role: "toolbar",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("select", {
						className: "tw-rt-select",
						"data-cmd": "formatBlock",
						title: "Paragraph style",
						defaultValue: "p",
						children: [
							/* @__PURE__ */ (0, R.jsx)("option", {
								value: "p",
								children: "Paragraph"
							}),
							/* @__PURE__ */ (0, R.jsx)("option", {
								value: "h3",
								children: "Heading"
							}),
							/* @__PURE__ */ (0, R.jsx)("option", {
								value: "h4",
								children: "Subheading"
							}),
							/* @__PURE__ */ (0, R.jsx)("option", {
								value: "blockquote",
								children: "Quote"
							})
						]
					}),
					/* @__PURE__ */ (0, R.jsxs)("select", {
						className: "tw-rt-select",
						"data-cmd": "fontSize",
						title: "Text size",
						defaultValue: "3",
						children: [
							/* @__PURE__ */ (0, R.jsx)("option", {
								value: "2",
								children: "Small"
							}),
							/* @__PURE__ */ (0, R.jsx)("option", {
								value: "3",
								children: "Medium"
							}),
							/* @__PURE__ */ (0, R.jsx)("option", {
								value: "5",
								children: "Large"
							}),
							/* @__PURE__ */ (0, R.jsx)("option", {
								value: "6",
								children: "Huge"
							})
						]
					}),
					/* @__PURE__ */ (0, R.jsx)("span", { className: "tw-rt-sep" }),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "bold",
						title: "Bold",
						children: /* @__PURE__ */ (0, R.jsx)(tt, { size: 14 })
					}),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "italic",
						title: "Italic",
						children: /* @__PURE__ */ (0, R.jsx)(or, { size: 14 })
					}),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "underline",
						title: "Underline",
						children: /* @__PURE__ */ (0, R.jsx)(ua, { size: 14 })
					}),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "strikeThrough",
						title: "Strikethrough",
						children: /* @__PURE__ */ (0, R.jsx)(Pi, { size: 14 })
					}),
					/* @__PURE__ */ (0, R.jsx)("span", { className: "tw-rt-sep" }),
					/* @__PURE__ */ (0, R.jsxs)("label", {
						className: "tw-rt-color",
						title: "Text colour",
						children: [/* @__PURE__ */ (0, R.jsx)(ca, { size: 14 }), /* @__PURE__ */ (0, R.jsx)("input", {
							type: "color",
							"data-cmd": "foreColor",
							defaultValue: "#0A6EB4"
						})]
					}),
					/* @__PURE__ */ (0, R.jsxs)("label", {
						className: "tw-rt-color",
						title: "Highlight",
						children: [/* @__PURE__ */ (0, R.jsx)(Qn, { size: 14 }), /* @__PURE__ */ (0, R.jsx)("input", {
							type: "color",
							"data-cmd": "hiliteColor",
							defaultValue: "#fff3bf"
						})]
					}),
					/* @__PURE__ */ (0, R.jsx)("span", { className: "tw-rt-sep" }),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "insertUnorderedList",
						title: "Bulleted list",
						children: /* @__PURE__ */ (0, R.jsx)(br, { size: 14 })
					}),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "insertOrderedList",
						title: "Numbered list",
						children: /* @__PURE__ */ (0, R.jsx)(vr, { size: 14 })
					}),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "justifyLeft",
						title: "Align left",
						children: /* @__PURE__ */ (0, R.jsx)(Xi, { size: 14 })
					}),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "justifyCenter",
						title: "Centre",
						children: /* @__PURE__ */ (0, R.jsx)(Ki, { size: 14 })
					}),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "justifyRight",
						title: "Align right",
						children: /* @__PURE__ */ (0, R.jsx)(Ji, { size: 14 })
					}),
					/* @__PURE__ */ (0, R.jsx)("span", { className: "tw-rt-sep" }),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "createLink",
						title: "Link",
						children: /* @__PURE__ */ (0, R.jsx)(mr, { size: 14 })
					}),
					/* @__PURE__ */ (0, R.jsx)(ng, {
						cmd: "removeFormat",
						title: "Clear formatting",
						children: /* @__PURE__ */ (0, R.jsx)(vn, { size: 14 })
					})
				]
			}), /* @__PURE__ */ (0, R.jsx)("div", {
				ref: l,
				id: e,
				className: e ? "tw-rich" : "tw-rich tw-rich-send",
				contentEditable: !0,
				suppressContentEditableWarning: !0,
				role: "textbox",
				"aria-multiline": "true",
				"aria-label": typeof r == "string" ? r : i,
				"data-placeholder": i,
				"data-send": t,
				"data-item": n,
				style: { minHeight: `${1.6 * a + .9}rem` }
			})]
		})]
	});
}
//#endregion
//#region src/pages/monitoring/ChartBuilder.tsx
k();
function ig({ prefix: e, t }) {
	let n = (t) => e + t, r = L(n("cb_meta")), i = L(n("cb_state")), a = I(n("display")) ?? "chart", o = I(n("type")) ?? "count", s = I(n("title")) ?? "", c = a === "table", l = !!i?.ready, u = D(null);
	E(() => {
		Bf(u.current, !0);
	}, [c, l]);
	let d = D(null);
	if (V(n("cb_state"), d), !r) return null;
	let f = (e) => e ? void 0 : { display: "none" };
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-cb",
		ref: d,
		children: [/* @__PURE__ */ (0, R.jsxs)(H, {
			title: t("Chart"),
			icon: /* @__PURE__ */ (0, R.jsx)(Ai, { size: 15 }),
			className: "tw-cb-fields",
			children: [
				/* @__PURE__ */ (0, R.jsx)(z, {
					id: n("preset"),
					label: t("Ready-made chart"),
					choices: r.presets,
					value: "custom"
				}),
				/* @__PURE__ */ (0, R.jsx)(_f, {
					id: n("display"),
					label: t("Display as"),
					buttons: !0,
					value: "chart",
					choices: [{
						value: "chart",
						label: t("Chart")
					}, {
						value: "table",
						label: t("Table")
					}],
					className: "tw-cb-seg"
				}),
				/* @__PURE__ */ (0, R.jsx)(z, {
					id: n("type"),
					label: t("Show"),
					choices: r.types,
					value: "count"
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					style: f(!c),
					children: /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-cb-row",
						children: [/* @__PURE__ */ (0, R.jsx)(z, {
							id: n("style"),
							label: t("Chart style"),
							choices: r.styles,
							value: "auto",
							className: "flex-fill"
						}), /* @__PURE__ */ (0, R.jsx)(B, {
							id: n("axes"),
							label: i?.axes_set ? t("Axes (set)") : t("Axes"),
							icon: /* @__PURE__ */ (0, R.jsx)(Rr, { size: 13 }),
							variant: "outline-secondary",
							className: "tw-cb-axes",
							title: t("Set the value axis")
						})]
					})
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					style: f(o !== "trend"),
					children: /* @__PURE__ */ (0, R.jsx)(z, {
						id: n("x"),
						label: t("By"),
						choices: [],
						value: ""
					})
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-cb-row",
					style: f(o === "trend"),
					children: [/* @__PURE__ */ (0, R.jsx)(z, {
						id: n("date"),
						label: t("Date column"),
						choices: [],
						value: "",
						className: "flex-fill"
					}), /* @__PURE__ */ (0, R.jsx)(z, {
						id: n("period"),
						label: t("Per"),
						choices: [{
							value: "month",
							label: t("Month")
						}, {
							value: "week",
							label: t("Week")
						}],
						value: "month",
						className: "tw-cb-period"
					})]
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					style: f([
						"sum",
						"mean",
						"share",
						"trend"
					].includes(o)),
					children: /* @__PURE__ */ (0, R.jsx)(z, {
						id: n("value"),
						label: t("Number column"),
						choices: [],
						value: ""
					})
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					style: f(o === "share"),
					children: /* @__PURE__ */ (0, R.jsx)(z, {
						id: n("den"),
						label: t("Out of (total column)"),
						choices: [],
						value: ""
					})
				}),
				/* @__PURE__ */ (0, R.jsx)(z, {
					id: n("group"),
					label: t("Split by (optional; the columns of a crosstab)"),
					choices: [],
					value: ""
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					style: f(o === "crosstab"),
					children: /* @__PURE__ */ (0, R.jsx)(_f, {
						id: n("pct"),
						label: t("Percentages"),
						buttons: !0,
						value: "row",
						choices: [
							{
								value: "row",
								label: t("Row")
							},
							{
								value: "col",
								label: t("Column")
							},
							{
								value: "total",
								label: t("Total")
							},
							{
								value: "count",
								label: t("Counts only")
							}
						]
					})
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-cb-row",
					children: [/* @__PURE__ */ (0, R.jsx)(z, {
						id: n("filter_col"),
						label: t("Only where"),
						choices: [],
						value: "",
						className: "flex-fill"
					}), /* @__PURE__ */ (0, R.jsx)(z, {
						id: n("filter_vals"),
						label: t("is one of"),
						choices: [],
						multiple: !0,
						actions: !0,
						className: "flex-fill"
					})]
				})
			]
		}), /* @__PURE__ */ (0, R.jsxs)(H, {
			title: s.trim() || t("Preview"),
			icon: /* @__PURE__ */ (0, R.jsx)(yt, { size: 15 }),
			full: !0,
			className: "tw-cb-preview",
			children: [/* @__PURE__ */ (0, R.jsxs)("div", {
				ref: u,
				children: [
					i && (i.has_data ? i.too_many ? /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "small text-warning mb-2 tw-cb-note",
						children: [
							/* @__PURE__ */ (0, R.jsx)(na, { size: 14 }),
							" ",
							i.too_many
						]
					}) : !l && /* @__PURE__ */ (0, R.jsx)("div", {
						className: "small text-muted mb-2",
						children: t("Choose the columns on the left to see the chart.")
					}) : /* @__PURE__ */ (0, R.jsx)(Y, {
						title: t("No data yet"),
						sub: t("Load a dataset above to build charts.")
					})),
					i?.note && (i.note.kind === "warning" ? /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "small text-warning mb-2 tw-cb-note",
						children: [
							/* @__PURE__ */ (0, R.jsx)(ir, { size: 14 }),
							" ",
							t(i.note.text)
						]
					}) : /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "small text-muted mb-2 tw-cb-note",
						children: [
							/* @__PURE__ */ (0, R.jsx)(st, { size: 14 }),
							" ",
							i.note.text
						]
					})),
					/* @__PURE__ */ (0, R.jsx)("div", {
						style: f(!c && l),
						children: /* @__PURE__ */ (0, R.jsx)(U, {
							id: n("preview"),
							height: 360
						})
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						style: f(c && l),
						children: /* @__PURE__ */ (0, R.jsx)(zf, {
							id: n("preview_table"),
							searchable: !1,
							compact: !0
						})
					})
				]
			}), /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-cb-add",
				children: [
					/* @__PURE__ */ (0, R.jsx)(hf, {
						id: n("title"),
						label: t("Title in the report")
					}),
					/* @__PURE__ */ (0, R.jsx)(rg, {
						id: n("comment"),
						label: t("Your comment (what it shows, why it matters)"),
						rows: 3,
						placeholder: t("e.g. Women made up 38% of participants in Beni, below the 50% target; sessions were held on market days.")
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "d-flex justify-content-end",
						children: /* @__PURE__ */ (0, R.jsx)(B, {
							id: n("add"),
							label: t("Add to report"),
							icon: /* @__PURE__ */ (0, R.jsx)(Qr, { size: 14 }),
							variant: "primary"
						})
					})
				]
			})]
		})]
	});
}
//#endregion
//#region src/pages/monitoring/PdmTab.tsx
k();
var ag = "monitoring_1-pdm-", Z = (e) => ag + e, og = (e) => Math.round(e).toLocaleString("en-US"), sg = (e) => e == null || !isFinite(e) ? "—" : `${(100 * e).toFixed(1).replace(/\.0$/, "")}%`, cg = (e) => e == null || !isFinite(e) ? "n/a" : `${(100 * e).toFixed(1)}%`, lg = (e) => e ? void 0 : { display: "none" };
function ug({ label: e, value: t, icon: n, tone: r }) {
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `tw-mon-kpi tone-${r}`,
		children: [/* @__PURE__ */ (0, R.jsx)("span", {
			className: "tw-mon-kpi-icon",
			children: n
		}), /* @__PURE__ */ (0, R.jsxs)("div", { children: [/* @__PURE__ */ (0, R.jsx)("div", {
			className: "tw-mon-kpi-label",
			children: e
		}), /* @__PURE__ */ (0, R.jsx)("div", {
			className: "tw-mon-kpi-value",
			children: t
		})] })]
	});
}
function dg({ t: e }) {
	let t = L(Z("pdm_state")), n = L(Z("pdm_side")), r = D(null);
	V(Z("pdm_state"), r);
	let i = I(Z("ptm_size_mode")) ?? "margin", a = I(Z("data_kind")) ?? "Baseline", o = I(Z("benef_source")) ?? "design", s = I(Z("pdm_elig_source")) ?? "column", c = I(Z("pdm_weight_mode")) ?? "design", l = I(Z("pop_scope")) ?? "overall", u = I(Z("pdm_unit")) ?? "", d = t?.results ?? null, f = d ? d.kind !== "PDM" : a !== "PDM", p = d?.decisions ?? [], m = p.filter((e) => e.level === "redesign").length, h = p.filter((e) => e.level === "review").length, g = /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(Hf, {
		open: "sample",
		steps: [
			{
				key: "sample",
				title: e("0. Verification sample"),
				icon: /* @__PURE__ */ (0, R.jsx)(Si, { size: 14 }),
				summary: t?.sample ? `${og(t.sample.n)} ${e("households")}` : e("Not drawn"),
				content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					/* @__PURE__ */ (0, R.jsx)("p", {
						className: "small text-muted mb-2",
						children: e("Draw households the targeting selected and households it did not, area by area, from the current selection (Beneficiary Selection). Survey them before any distribution: errors found then can still be corrected.")
					}),
					/* @__PURE__ */ (0, R.jsx)(z, {
						id: Z("ptm_level"),
						label: e("Area level"),
						choices: [],
						value: ""
					}),
					/* @__PURE__ */ (0, R.jsx)(_f, {
						id: Z("ptm_size_mode"),
						label: e("Households per group and area"),
						value: "margin",
						buttons: !0,
						choices: [{
							value: "margin",
							label: e("From a margin of error")
						}, {
							value: "fixed",
							label: e("A fixed number")
						}]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						style: lg(i === "margin"),
						children: /* @__PURE__ */ (0, R.jsx)(mf, {
							id: Z("ptm_margin"),
							label: e("Margin of error (%)"),
							value: 10,
							min: 3,
							max: 25,
							step: 1,
							help: e("For each group of each area, enough households to estimate a share within this margin at 95% confidence (about 96 households at 10%, fewer in small groups).")
						})
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						style: lg(i === "fixed"),
						children: /* @__PURE__ */ (0, R.jsx)(mf, {
							id: Z("ptm_n"),
							label: e("Households per group"),
							value: 60,
							min: 10,
							step: 10
						})
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-grid-2 tw-mon-pair",
						children: [/* @__PURE__ */ (0, R.jsx)(mf, {
							id: Z("ptm_reserve"),
							label: e("Reserve (%)"),
							value: 10,
							min: 0,
							max: 50,
							step: 5
						}), /* @__PURE__ */ (0, R.jsx)(mf, {
							id: Z("ptm_seed"),
							label: e("Seed"),
							value: 123,
							min: 1,
							step: 1
						})]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "small text-muted mb-2",
						children: e("The reserve replaces households who cannot be found.")
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "d-flex flex-column gap-2",
						children: [/* @__PURE__ */ (0, R.jsx)(B, {
							id: Z("ptm_draw"),
							label: e("Draw the sample"),
							icon: /* @__PURE__ */ (0, R.jsx)(Si, { size: 14 }),
							className: "w-100"
						}), /* @__PURE__ */ (0, R.jsx)(bf, {
							id: Z("ptm_download"),
							label: e("Sample list (Excel)"),
							icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 14 }),
							variant: "outline-secondary",
							className: "w-100"
						})]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "tw-mon-status",
						children: t?.sample ? /* @__PURE__ */ (0, R.jsxs)("span", {
							className: "ok",
							children: [
								e("Drawn"),
								" ",
								t.sample.drawn_at,
								": ",
								og(t.sample.n),
								" ",
								e("households to survey"),
								" (",
								og(t.sample.selected),
								" ",
								e("selected"),
								", ",
								og(t.sample.not_selected),
								" ",
								e("not selected"),
								") ",
								e("and"),
								" ",
								og(t.sample.reserve),
								" ",
								e("in reserve"),
								", ",
								t.sample.areas,
								" ",
								e("area(s).")
							]
						}) : e("No sample drawn yet.")
					})
				] })
			},
			{
				key: "data",
				title: e("1. Survey data"),
				icon: /* @__PURE__ */ (0, R.jsx)(fa, { size: 14 }),
				summary: t?.data ? t.data.source : e("Nothing loaded"),
				content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					/* @__PURE__ */ (0, R.jsx)(_f, {
						id: Z("data_kind"),
						value: "Baseline",
						choices: [{
							value: "Baseline",
							label: e("Post-targeting survey / baseline (before distribution, recommended)")
						}, {
							value: "PDM",
							label: e("PDM (after distribution, least preferred)")
						}]
					}),
					a === "PDM" ? /* @__PURE__ */ (0, R.jsx)(Jf, {
						kind: "warning",
						className: "mb-2",
						children: e("The least preferred option: after distribution nothing can be undone, vulnerability may have changed, and the assistance itself may have changed the answers to some criteria (assets bought, debts paid). Use it when no survey could be done before distribution.")
					}) : /* @__PURE__ */ (0, R.jsx)("p", {
						className: "small text-muted mb-2",
						children: e("A survey of selected and non-selected households after the selection and before the distribution (the sample drawn in step 0): problems in an area can still be fixed, or its distribution paused.")
					}),
					/* @__PURE__ */ (0, R.jsx)(tg, { id: Z("pdm_file_ui") }),
					/* @__PURE__ */ (0, R.jsx)(rp, {
						ns: Z("moda"),
						size: "sm",
						t: e
					}),
					/* @__PURE__ */ (0, R.jsx)(up, {
						ns: Z("summary"),
						block: !0,
						className: "mt-2",
						t: e
					}),
					t?.data && /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-mon-status",
						children: [
							/* @__PURE__ */ (0, R.jsx)("span", {
								className: "ok",
								children: /* @__PURE__ */ (0, R.jsx)("strong", { children: t.data.source })
							}),
							/* @__PURE__ */ (0, R.jsx)("br", {}),
							og(t.data.rows),
							" ",
							e("records"),
							", ",
							og(t.data.cols),
							" ",
							e("variables. Continue with the steps below.")
						]
					})
				] })
			},
			{
				key: "areas",
				title: e("Areas covered"),
				icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 14 }),
				content: /* @__PURE__ */ (0, R.jsx)(np, {
					ns: Z("scope"),
					title: null,
					t: e
				})
			},
			{
				key: "benef",
				title: e("2. Selected or assisted households"),
				icon: /* @__PURE__ */ (0, R.jsx)(ma, { size: 14 }),
				summary: e(o === "design" ? "From the sample list" : "A column"),
				content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					/* @__PURE__ */ (0, R.jsx)(_f, {
						id: Z("benef_source"),
						value: "design",
						choices: [{
							value: "design",
							label: e("From the sample list (match the household ID)")
						}, {
							value: "column",
							label: e("A column in the data")
						}]
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						style: lg(o === "design"),
						children: [/* @__PURE__ */ (0, R.jsx)(z, {
							id: Z("ptm_id"),
							label: e("Household ID in the survey"),
							choices: [],
							value: ""
						}), t?.sample ? t.match && /* @__PURE__ */ (0, R.jsxs)("div", {
							className: `small mb-2 ${t.match.n < t.match.of ? "text-warning" : "text-success"}`,
							children: [
								og(t.match.n),
								" ",
								e("of"),
								" ",
								og(t.match.of),
								" ",
								e("surveyed households found in the sample list."),
								t.match.n < t.match.of ? ` ${e("The others are left out.")}` : ""
							]
						}) : /* @__PURE__ */ (0, R.jsx)("div", {
							className: "small text-warning mb-2",
							children: e("Draw the sample in step 0 first, or use a column in the data.")
						})]
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						style: lg(o === "column"),
						children: [
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: Z("pdm_beneficiary"),
								label: e("Selected / beneficiary column"),
								choices: [],
								value: ""
							}),
							n?.benef && n.benef.n !== 2 && /* @__PURE__ */ (0, R.jsx)("div", {
								className: "small text-danger mb-2",
								children: e("This column has %d different answers; choose one with exactly two (received / not received).").replace("%d", String(n.benef.n))
							}),
							/* @__PURE__ */ (0, R.jsx)("div", {
								hidden: n?.benef?.n !== 2,
								children: /* @__PURE__ */ (0, R.jsx)(_f, {
									id: Z("pdm_benef_level"),
									label: e("Answer meaning 'received assistance'"),
									inline: !0,
									choices: n?.benef?.choices ?? []
								})
							})
						]
					}),
					/* @__PURE__ */ (0, R.jsx)(z, {
						id: Z("pdm_prioritized"),
						label: e("Prioritised column (optional)"),
						choices: [],
						value: "",
						help: e("Eligible households not prioritised for lack of resources are excluded by design, not exclusion errors.")
					}),
					/* @__PURE__ */ (0, R.jsx)(z, {
						id: Z("pdm_unit"),
						label: e("Area column (optional)"),
						choices: [],
						value: ""
					})
				] })
			},
			{
				key: "elig",
				title: e("3. Who was eligible"),
				icon: /* @__PURE__ */ (0, R.jsx)(Yt, { size: 14 }),
				summary: {
					column: e("A column"),
					scorecard: e("The adopted scorecard"),
					rules: e("The eligibility rules")
				}[s],
				content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					/* @__PURE__ */ (0, R.jsx)(_f, {
						id: Z("pdm_elig_source"),
						value: "column",
						choices: [
							{
								value: "column",
								label: e("A column in the data")
							},
							{
								value: "scorecard",
								label: e("Apply the adopted scorecard")
							},
							{
								value: "rules",
								label: e("Apply the eligibility rules")
							}
						]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						style: lg(s === "column"),
						children: /* @__PURE__ */ (0, R.jsx)(z, {
							id: Z("pdm_eligibility"),
							label: e("Eligibility column"),
							choices: [],
							value: ""
						})
					}),
					n?.elig && (n.elig.kind === "warning" ? /* @__PURE__ */ (0, R.jsx)(Jf, {
						kind: "warning",
						className: "mb-2",
						children: e(n.elig.text)
					}) : /* @__PURE__ */ (0, R.jsx)("div", {
						className: "small text-muted mb-2",
						children: e(n.elig.text)
					}))
				] })
			},
			{
				key: "weight",
				title: e("4. Weighting"),
				icon: /* @__PURE__ */ (0, R.jsx)(ui, { size: 14 }),
				summary: {
					design: e("Sample design"),
					population: e("Population sizes"),
					column: e("A weight column"),
					none: e("None")
				}[c],
				content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					/* @__PURE__ */ (0, R.jsx)(_f, {
						id: Z("pdm_weight_mode"),
						value: "design",
						choices: [
							{
								value: "design",
								label: e("From the sample design (recommended)")
							},
							{
								value: "population",
								label: e("Population sizes typed in")
							},
							{
								value: "column",
								label: e("A weight column")
							},
							{
								value: "none",
								label: e("None")
							}
						]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						style: lg(c === "column"),
						children: /* @__PURE__ */ (0, R.jsx)(z, {
							id: Z("pdm_weight"),
							label: e("Weight column"),
							choices: [],
							value: ""
						})
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						style: lg(c === "population"),
						children: [
							/* @__PURE__ */ (0, R.jsx)(_f, {
								id: Z("pop_scope"),
								value: "overall",
								buttons: !0,
								choices: [{
									value: "overall",
									label: e("Overall")
								}, {
									value: "unit",
									label: e("Per area")
								}]
							}),
							/* @__PURE__ */ (0, R.jsxs)("div", {
								style: lg(l === "overall"),
								children: [/* @__PURE__ */ (0, R.jsx)(mf, {
									id: Z("pop_benef"),
									label: e("Beneficiary households"),
									min: 0
								}), /* @__PURE__ */ (0, R.jsx)(mf, {
									id: Z("pop_nonbenef"),
									label: e("Non-beneficiary households"),
									min: 0
								})]
							}),
							l === "unit" && /* @__PURE__ */ (0, R.jsx)("div", {
								className: "small text-muted",
								children: e("Type the sizes per area in the table on the right.")
							})
						]
					})
				] })
			}
		]
	}), /* @__PURE__ */ (0, R.jsxs)(Uf, { children: [
		/* @__PURE__ */ (0, R.jsx)("div", {
			className: "small fw-semibold",
			ref: r,
			children: e("5. Compute")
		}),
		/* @__PURE__ */ (0, R.jsx)(B, {
			id: Z("pdm_run"),
			label: e("Compute implementation errors"),
			icon: /* @__PURE__ */ (0, R.jsx)(st, { size: 14 }),
			variant: "primary",
			className: "w-100"
		}),
		/* @__PURE__ */ (0, R.jsx)(bf, {
			id: Z("pdm_download"),
			label: e("Export (Excel)"),
			icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 14 }),
			variant: "outline-secondary",
			className: "w-100"
		}),
		/* @__PURE__ */ (0, R.jsxs)("div", {
			className: "small text-muted d-flex gap-1",
			children: [/* @__PURE__ */ (0, R.jsx)(ir, {
				size: 14,
				className: "flex-shrink-0 mt-1"
			}), /* @__PURE__ */ (0, R.jsx)("span", { children: e("Implementation errors measure whether the criteria were applied correctly on the ground, not whether they were right (that is the design error).") })]
		})
	] })] });
	return /* @__PURE__ */ (0, R.jsxs)(Vf, {
		width: 330,
		sidebar: g,
		children: [
			c === "population" && l === "unit" && (!u || u === "(none)" ? /* @__PURE__ */ (0, R.jsx)(Jf, {
				kind: "warning",
				children: e("Choose the area column (step 2) to give the population sizes per area.")
			}) : /* @__PURE__ */ (0, R.jsxs)(H, {
				title: e("Population sizes per area"),
				icon: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 15 }),
				children: [/* @__PURE__ */ (0, R.jsx)("p", {
					className: "small text-muted mb-2",
					children: e("Double-click a cell of the last two columns to type the number of beneficiary and non-beneficiary households in each area.")
				}), /* @__PURE__ */ (0, R.jsx)(zf, {
					id: Z("pop_table"),
					searchable: !1,
					compact: !0
				})]
			})),
			t?.data ? !d && /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("Ready to compute"),
				sub: e("Check steps 2 to 4, then click Compute implementation errors.")
			}) : /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("No survey data loaded"),
				sub: e("Draw the verification sample (step 0), survey it before distribution, then load the survey in step 1 and set up steps 2 to 4. A PDM extract can be loaded instead.")
			}),
			/* @__PURE__ */ (0, R.jsx)(Wf, {
				id: Z("pdm_tabs"),
				tabs: [
					{
						value: "errors",
						label: e("Errors and verdict"),
						icon: /* @__PURE__ */ (0, R.jsx)(Wi, { size: 14 }),
						content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
							d && /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)("div", {
								className: "tw-mon-kpis",
								children: [
									/* @__PURE__ */ (0, R.jsx)(ug, {
										label: e("Implementation inclusion error"),
										value: sg(d.inclusion),
										icon: /* @__PURE__ */ (0, R.jsx)(va, { size: 18 }),
										tone: "danger"
									}),
									/* @__PURE__ */ (0, R.jsx)(ug, {
										label: e("Implementation exclusion error"),
										value: sg(d.exclusion),
										icon: /* @__PURE__ */ (0, R.jsx)(ga, { size: 18 }),
										tone: "warning"
									}),
									/* @__PURE__ */ (0, R.jsx)(ug, {
										label: e("Coverage rate"),
										value: sg(d.coverage),
										icon: /* @__PURE__ */ (0, R.jsx)(Jr, { size: 18 }),
										tone: "success"
									}),
									/* @__PURE__ */ (0, R.jsx)(ug, {
										label: e("Precision / Recall"),
										value: `${sg(d.precision)} / ${sg(d.recall)}`,
										icon: /* @__PURE__ */ (0, R.jsx)(Wi, { size: 18 }),
										tone: "info"
									})
								]
							}), /* @__PURE__ */ (0, R.jsxs)(Jf, { children: [
								e("Eligibility from"),
								" ",
								d.elig_source,
								"; ",
								e("weighting"),
								": ",
								d.weighting,
								".",
								d.no_nonbenef && /* @__PURE__ */ (0, R.jsxs)("strong", { children: [" ", e("Only beneficiaries were surveyed: the exclusion error cannot be measured.")] })
							] })] }),
							p.length > 0 && /* @__PURE__ */ (0, R.jsxs)(H, {
								title: e(f ? "Decision by area, before distribution" : "Lessons by area, for the next round"),
								icon: /* @__PURE__ */ (0, R.jsx)(Ei, { size: 15 }),
								children: [/* @__PURE__ */ (0, R.jsxs)("p", {
									className: "small mb-2",
									children: [
										m || h ? /* @__PURE__ */ (0, R.jsxs)("strong", { children: [
											m,
											" ",
											e("area(s) to"),
											" ",
											e(f ? "pause" : "re-target"),
											", ",
											h,
											" ",
											e("to review.")
										] }) : e("No area needs action."),
										" ",
										e("Each area is judged on its own errors with the same decision table and tolerance band; areas with fewer than 30 surveyed households in either group are not judged.")
									]
								}), /* @__PURE__ */ (0, R.jsx)("div", {
									className: "tw-table-wrap",
									children: /* @__PURE__ */ (0, R.jsxs)("table", {
										className: "table table-sm tw-table mb-0",
										children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
											/* @__PURE__ */ (0, R.jsx)("th", { children: e("Area") }),
											/* @__PURE__ */ (0, R.jsx)("th", {
												className: "text-end",
												children: e("Selected surveyed")
											}),
											/* @__PURE__ */ (0, R.jsx)("th", {
												className: "text-end",
												children: e("Not selected surveyed")
											}),
											/* @__PURE__ */ (0, R.jsx)("th", {
												className: "text-end",
												children: e("Inclusion error")
											}),
											/* @__PURE__ */ (0, R.jsx)("th", {
												className: "text-end",
												children: e("Exclusion error")
											}),
											/* @__PURE__ */ (0, R.jsx)("th", { children: e("Decision") })
										] }) }), /* @__PURE__ */ (0, R.jsx)("tbody", { children: p.map((e) => /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
											/* @__PURE__ */ (0, R.jsx)("td", {
												className: "fw-semibold",
												children: e.area
											}),
											/* @__PURE__ */ (0, R.jsx)("td", {
												className: "text-end",
												children: og(e.n_selected)
											}),
											/* @__PURE__ */ (0, R.jsx)("td", {
												className: "text-end",
												children: og(e.n_not)
											}),
											/* @__PURE__ */ (0, R.jsx)("td", {
												className: "text-end",
												children: sg(e.inclusion)
											}),
											/* @__PURE__ */ (0, R.jsx)("td", {
												className: "text-end",
												children: sg(e.exclusion)
											}),
											/* @__PURE__ */ (0, R.jsx)("td", { children: /* @__PURE__ */ (0, R.jsx)("span", {
												className: `tw-mon-decision lv-${e.level}`,
												children: e.decision
											}) })
										] }, e.area)) })]
									})
								})]
							}),
							t?.data && /* @__PURE__ */ (0, R.jsxs)("div", {
								className: "tw-mon-tol",
								children: [/* @__PURE__ */ (0, R.jsx)(mf, {
									id: Z("tol_lower"),
									label: e("Lower error tolerance (%)"),
									value: 5,
									min: 0,
									max: 49,
									step: 1
								}), /* @__PURE__ */ (0, R.jsx)(mf, {
									id: Z("tol_upper"),
									label: e("Upper error tolerance (%)"),
									value: 20,
									min: 1,
									max: 49,
									step: 1
								})]
							}),
							/* @__PURE__ */ (0, R.jsx)(fg, { t: e })
						] })
					},
					{
						value: "details",
						label: e("Details by group and area"),
						icon: /* @__PURE__ */ (0, R.jsx)(Hi, { size: 14 }),
						content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
							!d && /* @__PURE__ */ (0, R.jsx)(Y, {
								title: e("Nothing computed yet"),
								sub: e("Set up the steps on the left, then compute.")
							}),
							/* @__PURE__ */ (0, R.jsxs)("div", {
								className: "tw-grid-2",
								style: lg(!!d),
								children: [/* @__PURE__ */ (0, R.jsx)(H, {
									title: e("Eligibility vs. assistance received (estimated households)"),
									full: !0,
									children: /* @__PURE__ */ (0, R.jsx)(zf, {
										id: Z("pdm_confusion"),
										searchable: !1
									})
								}), /* @__PURE__ */ (0, R.jsx)(H, {
									title: e("Error decomposition"),
									full: !0,
									children: /* @__PURE__ */ (0, R.jsx)(U, {
										id: Z("pdm_plot"),
										height: 300
									})
								})]
							}),
							/* @__PURE__ */ (0, R.jsx)("div", {
								style: lg(!!d),
								children: /* @__PURE__ */ (0, R.jsx)(H, {
									title: e("Coverage by area"),
									full: !0,
									children: /* @__PURE__ */ (0, R.jsx)(zf, { id: Z("pdm_by_unit") })
								})
							})
						] })
					},
					{
						value: "calibrate",
						label: e("Calibrate the ranking"),
						icon: /* @__PURE__ */ (0, R.jsx)(Ai, { size: 14 }),
						content: /* @__PURE__ */ (0, R.jsx)(pg, { t: e })
					},
					{
						value: "explore",
						label: e("Explore the data"),
						icon: /* @__PURE__ */ (0, R.jsx)(yt, { size: 14 }),
						content: /* @__PURE__ */ (0, R.jsx)(ig, {
							prefix: "monitoring_1-pdm_charts-",
							t: e
						})
					}
				]
			})
		]
	});
}
function fg({ t: e }) {
	let t = L(Z("pdm_verdict")), n = D(null);
	V(Z("pdm_verdict"), n);
	let r = t && typeof t.lower == "number" ? Math.round(100 * t.lower) : 5, i = t && typeof t.upper == "number" ? Math.round(100 * t.upper) : 20;
	return /* @__PURE__ */ (0, R.jsx)("div", {
		ref: n,
		className: "tw-mon-verdict",
		children: t && /* @__PURE__ */ (0, R.jsxs)(eg, {
			v: t,
			t: e,
			children: [/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "small mt-2 text-muted",
				children: [
					e("Implementation errors, judged against a %s band.").replace("%s", `${r}%-${i}%`),
					" ",
					e("These measure whether the criteria were applied correctly on the ground, not whether the criteria themselves were right: that is the design error on the Targeting Design tab.")
				]
			}), t.excl_design && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "small mt-2",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("strong", { children: [
						e("Excluded by design"),
						": ",
						og(t.excl_design.n),
						" ",
						e("households"),
						" (",
						sg(t.excl_design.share),
						" ",
						e("of eligible"),
						")."
					] }),
					" ",
					e("Eligible but not prioritised for lack of resources: unmet need, left out of the exclusion error.")
				]
			})]
		})
	});
}
function pg({ t: e }) {
	let t = L(Z("calib_state")), n = D(null);
	V(Z("calib_state"), n);
	let r = t?.result ?? null, i = t?.missing ?? [];
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		ref: n,
		className: "tw-mon-calib",
		children: [
			t ? t.status === "none" ? /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("No vulnerability ranking adopted"),
				sub: e("This tab measures the errors of a ranking built without an outcome indicator (Targeting Design, 'No outcome indicator'). A scorecard built on an outcome already has its design errors.")
			}) : t.status === "nodata" ? /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("Load PDM or verification data"),
				sub: e("Data with a food-security outcome and the ranking's criteria.")
			}) : null : null,
			/* @__PURE__ */ (0, R.jsx)("div", {
				hidden: t?.status !== "ready",
				children: /* @__PURE__ */ (0, R.jsxs)(H, {
					title: e("Calibrate the ranking"),
					icon: /* @__PURE__ */ (0, R.jsx)(Ai, { size: 15 }),
					children: [
						/* @__PURE__ */ (0, R.jsx)("p", {
							className: "small text-muted mb-2",
							children: e("The adopted ranking was built without an outcome, so its inclusion and exclusion errors were unknown. Choose the food-security outcome these data carry (CARI, FCS or rCSI class...) and the level that means vulnerable: the ranking is applied to these households and its errors, its AUC and the threshold that keeps both errors lowest are measured.")
						}),
						i.length > 0 && /* @__PURE__ */ (0, R.jsx)(Jf, {
							kind: "warning",
							className: "mb-2",
							children: e("These data lack %d of the ranking's criteria (%s): they cannot be scored.").replace("%d", String(i.length)).replace("%s", i.slice(0, 5).join(", "))
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-mon-calib-row",
							children: [
								/* @__PURE__ */ (0, R.jsx)(z, {
									id: Z("calib_outcome"),
									label: e("Outcome in these data"),
									value: "",
									clearable: !1,
									choices: [{
										value: "",
										label: e("Choose a column")
									}, ...(t?.cols ?? []).map((e) => ({
										value: e,
										label: e
									}))]
								}),
								/* @__PURE__ */ (0, R.jsx)(z, {
									id: Z("calib_pos"),
									label: e("Level meaning vulnerable"),
									choices: [],
									value: "",
									clearable: !1
								}),
								/* @__PURE__ */ (0, R.jsx)(B, {
									id: Z("calib_run"),
									label: e("Measure the errors"),
									icon: /* @__PURE__ */ (0, R.jsx)(Xr, { size: 14 }),
									variant: "primary",
									className: "tw-mon-calib-go"
								})
							]
						})
					]
				})
			}),
			t?.status === "ready" && r && /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-mon-kpis",
					children: [
						/* @__PURE__ */ (0, R.jsx)(ug, {
							label: e("AUC of the ranking"),
							value: r.auc === null || r.auc === void 0 ? "n/a" : r.auc.toFixed(3),
							icon: /* @__PURE__ */ (0, R.jsx)(ia, { size: 18 }),
							tone: "info"
						}),
						/* @__PURE__ */ (0, R.jsx)(ug, {
							label: e("Inclusion error (adopted threshold)"),
							value: cg(r.inclusion),
							icon: /* @__PURE__ */ (0, R.jsx)(va, { size: 18 }),
							tone: "warning"
						}),
						/* @__PURE__ */ (0, R.jsx)(ug, {
							label: e("Exclusion error (adopted threshold)"),
							value: cg(r.exclusion),
							icon: /* @__PURE__ */ (0, R.jsx)(ga, { size: 18 }),
							tone: "danger"
						}),
						/* @__PURE__ */ (0, R.jsx)(ug, {
							label: e("Households measured"),
							value: og(r.n),
							icon: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 18 }),
							tone: "info"
						})
					]
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "small",
					children: r.best ? e("The threshold that keeps both errors lowest on these data is %1 (inclusion %2, exclusion %3), against %4 adopted. Re-adopt the ranking in Targeting Design with it if the data are representative.").replace("%1", r.best.threshold).replace("%2", cg(r.best.inclusion)).replace("%3", cg(r.best.exclusion)).replace("%4", r.threshold) : e("No threshold does better than selecting everyone on these data.")
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "small text-muted",
					children: [
						e("Outcome"),
						": ",
						r.outcome,
						" = ",
						r.pos,
						". ",
						e("An AUC near 0.5 means the ranking does not order households by this outcome: revisit the criteria or the method.")
					]
				})
			] })
		]
	});
}
//#endregion
//#region src/pages/monitoring/ProcessTab.tsx
var mg = (e) => "monitoring_1-" + e;
function hg({ t: e }) {
	let t = L(mg("mon_state"))?.datasets ?? [], n = /* @__PURE__ */ (0, R.jsx)(Hf, {
		open: "data",
		steps: [{
			key: "data",
			title: e("Datasets"),
			icon: /* @__PURE__ */ (0, R.jsx)(fn, { size: 14 }),
			summary: t.length ? `${t.length} ${t.length > 1 ? e("datasets") : e("dataset")}` : e("None yet"),
			content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
				/* @__PURE__ */ (0, R.jsx)("p", {
					className: "small text-muted mb-2",
					children: e("Complaints and feedback, community sessions, targeting committees, participation of women and minorities, focus groups on the criteria. Load as many as you have.")
				}),
				/* @__PURE__ */ (0, R.jsx)(tg, { id: mg("pm_file_ui") }),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "d-flex gap-2 align-items-end",
					children: [/* @__PURE__ */ (0, R.jsx)(z, {
						id: mg("pm_active"),
						label: e("Dataset to chart"),
						choices: [],
						value: "",
						className: "flex-fill"
					}), /* @__PURE__ */ (0, R.jsx)(B, {
						id: mg("pm_remove"),
						icon: /* @__PURE__ */ (0, R.jsx)(ea, { size: 14 }),
						variant: "outline-danger",
						title: e("Remove this dataset"),
						className: "mb-2"
					})]
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "mb-2",
					children: /* @__PURE__ */ (0, R.jsx)(rp, {
						ns: mg("pm_moda"),
						size: "sm",
						t: e
					})
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "mb-2",
					children: /* @__PURE__ */ (0, R.jsx)(up, {
						ns: mg("pm_summary"),
						label: "Summary of this dataset",
						block: !0,
						t: e
					})
				}),
				t.length > 0 && /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-mon-chips",
					children: t.map((e) => /* @__PURE__ */ (0, R.jsxs)("span", {
						className: "tw-mon-chip",
						title: e.name,
						children: [
							e.name,
							" ",
							/* @__PURE__ */ (0, R.jsx)("em", { children: e.rows.toLocaleString("en-US") })
						]
					}, e.name))
				})
			] })
		}, {
			key: "areas",
			title: e("Areas covered"),
			icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 14 }),
			content: /* @__PURE__ */ (0, R.jsx)(np, {
				ns: mg("pm_scope"),
				title: null,
				t: e
			})
		}]
	});
	return /* @__PURE__ */ (0, R.jsx)(Vf, {
		width: 330,
		sidebar: n,
		children: /* @__PURE__ */ (0, R.jsx)(ig, {
			prefix: "monitoring_1-pm_charts-",
			t: e
		})
	});
}
//#endregion
//#region src/pages/monitoring/ReportTab.tsx
k();
var gg = (e) => "monitoring_1-" + e;
function _g() {
	let e = Zd();
	E(() => {
		let e = window;
		!e.twMonDl && e.Shiny && (e.twMonDl = !0, e.Shiny.addCustomMessageHandler("tw-mon-download", (e) => document.getElementById(e.id)?.click()));
	}, [e]);
}
function vg({ t: e }) {
	_g();
	let t = L(gg("mon_state")), n = t?.items ?? [];
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-mon-report",
		children: [/* @__PURE__ */ (0, R.jsxs)(H, {
			title: e("Your analysis"),
			icon: /* @__PURE__ */ (0, R.jsx)(Wr, { size: 15 }),
			className: "tw-mon-analysis",
			children: [
				/* @__PURE__ */ (0, R.jsxs)("details", {
					className: "tw-mon-tpl",
					open: !0,
					children: [
						/* @__PURE__ */ (0, R.jsxs)("summary", { children: [
							/* @__PURE__ */ (0, R.jsx)(Aa, { size: 14 }),
							" ",
							e("Start from a template, or build your own charts")
						] }),
						/* @__PURE__ */ (0, R.jsx)("p", {
							className: "small text-muted mt-2 mb-2",
							children: e("Fills the report with ready-made charts from the data you loaded, each with a suggested finding you can edit. Your own charts and texts are kept unless you choose to replace them.")
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "d-flex gap-2 align-items-end",
							children: [/* @__PURE__ */ (0, R.jsx)(z, {
								id: gg("tpl"),
								choices: [],
								value: "",
								className: "flex-fill"
							}), /* @__PURE__ */ (0, R.jsx)(B, {
								id: gg("tpl_apply"),
								label: e("Draft"),
								icon: /* @__PURE__ */ (0, R.jsx)(Aa, { size: 14 }),
								className: "mb-2",
								title: e("Fill the report with this template's charts, with findings written from the numbers")
							})]
						}),
						/* @__PURE__ */ (0, R.jsx)("p", {
							className: "small text-muted mb-2",
							children: e("Share a saved template with colleagues or another office as a file (charts and figures, never the data), or import one.")
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "d-flex gap-2 mb-2",
							children: [/* @__PURE__ */ (0, R.jsx)(bf, {
								id: gg("tpl_export"),
								label: e("Export"),
								icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 14 }),
								variant: "outline-secondary",
								title: e("Save the template picked above as a file")
							}), /* @__PURE__ */ (0, R.jsx)(B, {
								id: gg("tpl_delete"),
								icon: /* @__PURE__ */ (0, R.jsx)(ea, { size: 14 }),
								variant: "outline-danger",
								title: e("Delete the saved template picked above")
							})]
						}),
						/* @__PURE__ */ (0, R.jsx)(tg, { id: gg("tpl_import_ui") }),
						t?.rounds && /* @__PURE__ */ (0, R.jsxs)("div", {
							className: "small d-flex align-items-center gap-1",
							children: [
								/* @__PURE__ */ (0, R.jsx)($t, { size: 13 }),
								" ",
								t.rounds
							]
						})
					]
				}),
				/* @__PURE__ */ (0, R.jsx)(rg, {
					id: gg("context"),
					label: e("Context"),
					placeholder: e("Programme, area, period, targeting approach, who collected what.")
				}),
				/* @__PURE__ */ (0, R.jsx)(rg, {
					id: gg("findings"),
					label: e("Key findings"),
					placeholder: e("What worked, what did not, where and for whom.")
				}),
				/* @__PURE__ */ (0, R.jsx)(rg, {
					id: gg("recommendations"),
					label: e("Recommendations"),
					placeholder: e("What to change in the next round, and who does it.")
				}),
				/* @__PURE__ */ (0, R.jsx)(gf, {
					id: gg("include_pdm"),
					label: e("Include the implementation errors (post-targeting survey or PDM)"),
					value: !0
				}),
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: gg("report_check"),
					label: e("Targeting monitoring report (HTML)"),
					icon: /* @__PURE__ */ (0, R.jsx)(On, { size: 14 }),
					variant: "primary",
					size: "md",
					className: "w-100"
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "small text-muted mt-1",
					children: e("The report is checked first (titles, comments, small groups); you can still export as it is.")
				}),
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: gg("tpl_save"),
					label: e("Save this report as a template"),
					icon: /* @__PURE__ */ (0, R.jsx)(ci, { size: 14 }),
					className: "w-100 mt-3",
					title: e("Keep the charts (not the data) and this round's figures; next round, pick it and click Draft")
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					style: { display: "none" },
					children: /* @__PURE__ */ (0, R.jsx)(bf, {
						id: gg("report"),
						label: "Download"
					})
				})
			]
		}), /* @__PURE__ */ (0, R.jsx)(H, {
			title: e("In the report"),
			icon: /* @__PURE__ */ (0, R.jsx)(cr, { size: 15 }),
			className: "tw-mon-items-card",
			actions: n.length ? /* @__PURE__ */ (0, R.jsx)("span", {
				className: "tw-mon-count",
				children: n.length
			}) : null,
			children: n.length ? /* @__PURE__ */ (0, R.jsx)(yg, {
				items: n,
				redraw: t?.redraw ?? 0,
				t: e
			}) : /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("Nothing added yet"),
				sub: e("Build a chart or a table on the PDM or Targeting process tab and click Add to report.")
			})
		})]
	});
}
function yg({ items: e, redraw: t, t: n }) {
	let r = qd(gg("item_act"), null, {
		debounceMs: 0,
		priority: "event"
	}), i = qd(gg("item_order"), null, {
		debounceMs: 0,
		priority: "event"
	}), a = (e, t) => r({
		what: e,
		id: t,
		n: Math.random()
	}), [o, s] = O(null), [c, l] = O(null), [u, d] = O(null), f = e.map((e) => e.id), p = (e) => {
		if (!c || c === e) return;
		let t = f.filter((e) => e !== c), n = e === null ? t.length : t.indexOf(e);
		t.splice(n, 0, c), i(t);
	}, m = () => {
		l(null), d(null), s(null);
	};
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)("p", {
		className: "small text-muted mb-2 d-flex align-items-center gap-1",
		children: [
			/* @__PURE__ */ (0, R.jsx)(Kn, { size: 13 }),
			" ",
			n("Drag an item by its handle to reorder. Two half-width items next to each other sit side by side in the report.")
		]
	}), /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-mon-items",
		onDragOver: (e) => {
			c && e.target === e.currentTarget && e.preventDefault();
		},
		onDrop: (e) => {
			e.target === e.currentTarget && (e.preventDefault(), p(null)), m();
		},
		children: e.map((r, i) => /* @__PURE__ */ (0, R.jsxs)("div", {
			"data-id": r.id,
			draggable: o === r.id,
			className: `tw-mon-item${r.half ? " is-half" : ""}${c === r.id ? " dragging" : ""}${u === r.id ? " drop-before" : ""}`,
			onDragStart: (e) => {
				l(r.id), e.dataTransfer.effectAllowed = "move", e.dataTransfer.setData("text/plain", r.id);
			},
			onDragEnd: m,
			onDragOver: (e) => {
				c && c !== r.id && (e.preventDefault(), d(r.id));
			},
			onDrop: (e) => {
				e.preventDefault(), e.stopPropagation(), p(r.id), m();
			},
			children: [
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-mon-item-head",
					children: [
						/* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-mon-drag",
							title: n("Drag to reorder"),
							onMouseDown: () => s(r.id),
							onMouseUp: () => s(null),
							onTouchStart: () => s(r.id),
							children: /* @__PURE__ */ (0, R.jsx)(Kn, { size: 15 })
						}),
						/* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-mon-num",
							children: i + 1
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "flex-grow-1 min-w-0",
							children: [/* @__PURE__ */ (0, R.jsx)("div", {
								className: "tw-mon-item-title",
								children: r.title
							}), /* @__PURE__ */ (0, R.jsxs)("div", {
								className: "small text-muted",
								children: [
									r.source,
									" · ",
									r.dataset,
									" · ",
									r.display === "table" ? n("table") : n("chart")
								]
							})]
						}),
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "btn-group btn-group-sm",
							children: [
								/* @__PURE__ */ (0, R.jsx)("button", {
									type: "button",
									className: "btn btn-outline-secondary",
									onClick: () => a("width", r.id),
									title: r.half ? n("Make full width") : n("Make half width (side by side)"),
									children: r.half ? /* @__PURE__ */ (0, R.jsx)(Ar, { size: 13 }) : /* @__PURE__ */ (0, R.jsx)(rn, { size: 13 })
								}),
								/* @__PURE__ */ (0, R.jsx)("button", {
									type: "button",
									className: "btn btn-outline-secondary",
									onClick: () => a("up", r.id),
									disabled: i === 0,
									title: n("Move up"),
									children: /* @__PURE__ */ (0, R.jsx)(Ye, { size: 13 })
								}),
								/* @__PURE__ */ (0, R.jsx)("button", {
									type: "button",
									className: "btn btn-outline-secondary",
									onClick: () => a("down", r.id),
									disabled: i === e.length - 1,
									title: n("Move down"),
									children: /* @__PURE__ */ (0, R.jsx)(Ue, { size: 13 })
								}),
								/* @__PURE__ */ (0, R.jsx)("button", {
									type: "button",
									className: "btn btn-outline-danger",
									onClick: () => a("remove", r.id),
									title: n("Remove"),
									children: /* @__PURE__ */ (0, R.jsx)(Ma, { size: 13 })
								})
							]
						})
					]
				}),
				/* @__PURE__ */ (0, R.jsx)(rg, {
					send: gg("item_comment"),
					item: r.id,
					value: r.comment,
					placeholder: n("Comment"),
					rows: 2,
					compact: !0
				}, `${r.id}-${t}`),
				r.caption && /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-mon-suggest small",
					children: [
						/* @__PURE__ */ (0, R.jsx)(ur, { size: 13 }),
						" ",
						/* @__PURE__ */ (0, R.jsx)("span", {
							className: "text-muted",
							children: n("Suggested finding:")
						}),
						" ",
						r.caption,
						" ",
						/* @__PURE__ */ (0, R.jsx)("button", {
							type: "button",
							className: "btn btn-link btn-sm p-0 align-baseline",
							onClick: () => a("caption", r.id),
							children: n("Use it")
						})
					]
				})
			]
		}, r.id))
	})] });
}
//#endregion
//#region src/pages/monitoring/MonitoringPage.tsx
function bg({ t: e }) {
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-mon",
		children: /* @__PURE__ */ (0, R.jsx)(Wf, {
			id: "monitoring_1-tabs",
			tabs: [
				{
					value: "pdm",
					label: e("1. Implementation errors"),
					icon: /* @__PURE__ */ (0, R.jsx)(Wi, { size: 15 }),
					content: /* @__PURE__ */ (0, R.jsx)(dg, { t: e })
				},
				{
					value: "process",
					label: e("2. Targeting process"),
					icon: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 15 }),
					content: /* @__PURE__ */ (0, R.jsx)(hg, { t: e })
				},
				{
					value: "report",
					label: e("3. Monitoring report"),
					icon: /* @__PURE__ */ (0, R.jsx)(On, { size: 15 }),
					content: /* @__PURE__ */ (0, R.jsx)(vg, { t: e })
				}
			]
		})
	});
}
//#endregion
//#region src/pages/monitoring/index.tsx
var xg = /* @__PURE__ */ n({
	default: () => bg,
	page: () => Sg
}), Sg = "pdm_panel";
//#endregion
//#region src/pages/overview/charts.tsx
k();
var Cg = (e) => {
	let [t, n, r] = e.split("-");
	return `${r}/${n}/${t}`;
}, wg = (e) => {
	let [, t, n] = e.split("-");
	return `${n}/${t}`;
}, Tg = (e) => e.replace(/[&<>"]/g, (e) => ({
	"&": "&amp;",
	"<": "&lt;",
	">": "&gt;",
	"\"": "&quot;"
})[e]), Eg = (e) => ({
	fontSize: 9,
	textBorderWidth: 0,
	color: e ? "#c9d1dc" : "#5b6b7c"
});
function Dg() {
	let e = () => document.documentElement.getAttribute("data-bs-theme") === "dark", [t, n] = O(e);
	return E(() => {
		let t = new MutationObserver(() => n(e()));
		return t.observe(document.documentElement, {
			attributes: !0,
			attributeFilter: ["data-bs-theme"]
		}), () => t.disconnect();
	}, []), t;
}
function Og({ daily: e, byArea: t, areas: n, height: r = 205 }) {
	let i = _e(() => {
		let r = [...new Set(e.map((e) => e.day))].sort(), i = t ? [...new Set(e.map((e) => e.area))].sort((e, t) => n.indexOf(e) - n.indexOf(t)) : ["Households"], a = new Map(r.map((e, t) => [e, t])), o = i.map(() => r.map(() => 0));
		for (let n of e) o[t ? i.indexOf(n.area) : 0][a.get(n.day)] += n.n;
		let s = 0, c = r.map((e, t) => s += i.reduce((e, n, r) => e + o[r][t], 0)), l = (e) => t ? Om[n.indexOf(e) % Om.length] : Dm.blue;
		return {
			grid: {
				left: 4,
				right: 4,
				top: t ? 26 : 10,
				bottom: 2,
				containLabel: !0
			},
			legend: t ? {
				top: 0,
				left: 0,
				type: "scroll",
				data: i,
				textStyle: { fontSize: 10 },
				itemWidth: 8,
				itemHeight: 8
			} : { show: !1 },
			tooltip: {
				trigger: "axis",
				axisPointer: { type: "shadow" },
				formatter: (e) => `<b>${Cg(r[e[0].dataIndex])}</b><br>` + e.filter((e) => e.value > 0 || e.seriesName === "Cumulative").map((e) => `${e.marker}${e.seriesName === "Cumulative" ? "In all" : Tg(e.seriesName)}: <b>${Nm(e.value)}</b>`).join("<br>")
			},
			xAxis: {
				type: "category",
				data: r.map(wg),
				axisLabel: { hideOverlap: !0 }
			},
			yAxis: [{
				type: "value",
				minInterval: 1
			}, {
				type: "value",
				minInterval: 1,
				splitLine: { show: !1 }
			}],
			series: [...i.map((e, t) => ({
				type: "bar",
				stack: "d",
				name: e,
				data: o[t],
				itemStyle: {
					color: l(e),
					borderRadius: 0
				},
				barCategoryGap: "15%"
			})), {
				type: "line",
				name: "Cumulative",
				yAxisIndex: 1,
				data: c,
				showSymbol: !1,
				lineStyle: {
					type: "dashed",
					width: 1.5,
					color: Dm.slate
				},
				itemStyle: { color: Dm.slate }
			}]
		};
	}, [
		e,
		t,
		n
	]);
	return /* @__PURE__ */ (0, R.jsx)(Dp, {
		option: i,
		height: r
	});
}
function kg(e, t, n) {
	return {
		grid: {
			left: 4,
			right: 36,
			top: 4,
			bottom: 4,
			containLabel: !0
		},
		tooltip: {
			trigger: "item",
			formatter: (t) => e[t.dataIndex].tip
		},
		xAxis: {
			type: "value",
			show: !1,
			max: Math.max(0, ...e.map((e) => e.value)) * 1.2 || 1
		},
		yAxis: {
			type: "category",
			inverse: !0,
			data: e.map((e) => e.label),
			axisLabel: {
				width: 120,
				overflow: "truncate"
			}
		},
		series: [{
			type: "bar",
			barMaxWidth: 16,
			data: e.map((e) => ({
				value: e.value,
				itemStyle: { color: e.colour }
			})),
			label: {
				show: !0,
				position: "right",
				...Eg(n),
				formatter: (e) => t(e.value)
			}
		}]
	};
}
function Ag({ data: e, kind: t, height: n = 170 }) {
	let r = Dg(), i = _e(() => {
		let n = e.reduce((e, t) => e + t.n, 0) || 1, i = (e) => `${Tg(e.category)}: <b>${Mm(e.n / n, 1)}</b> (${Nm(e.n)} households)`;
		if (t !== "bins") return kg(e.map((e) => ({
			label: e.category,
			value: e.n / n,
			colour: Dm.blue,
			tip: i(e)
		})), (e) => Mm(e), r);
		let a = Math.max(0, ...e.map((e) => e.n / n));
		return {
			grid: {
				left: 4,
				right: 4,
				top: 16,
				bottom: 2,
				containLabel: !0
			},
			tooltip: {
				trigger: "item",
				formatter: (t) => i(e[t.dataIndex])
			},
			xAxis: {
				type: "category",
				data: e.map((e) => e.category),
				axisLabel: {
					interval: 0,
					hideOverlap: !0
				}
			},
			yAxis: {
				type: "value",
				show: !1,
				max: a * 1.15 || 1
			},
			series: [{
				type: "bar",
				barCategoryGap: "20%",
				itemStyle: {
					color: Dm.blue,
					borderRadius: [
						3,
						3,
						0,
						0
					]
				},
				data: e.map((e) => e.n / n),
				label: {
					show: !0,
					position: "top",
					...Eg(r),
					formatter: (e) => Mm(e.value)
				}
			}]
		};
	}, [
		e,
		t,
		r
	]), a = t === "bins" ? n : Math.max(n, 24 * e.length + 12);
	return /* @__PURE__ */ (0, R.jsx)(Dp, {
		option: i,
		height: a
	});
}
function jg({ groups: e, height: t = 200 }) {
	let n = Dg(), r = _e(() => {
		let t = e.reduce((e, t) => e + t.households, 0) || 1;
		return kg(e.map((e) => ({
			label: e.group,
			value: e.households / t,
			colour: e.colour,
			tip: `${Tg(e.group)}: <b>${Mm(e.households / t, 1)}</b> of households, ${Nm(e.people)} people`
		})), (e) => Mm(e), n);
	}, [e, n]);
	return /* @__PURE__ */ (0, R.jsx)(Dp, {
		option: r,
		height: Math.max(t, 28 * e.length + 12)
	});
}
function Mg({ rows: e, pctScale: t, overall: n, label: r }) {
	let i = _e(() => [...new Set(e.map((e) => e.dimension))], [e]), a = Dg(), o = _e(() => {
		let o = (e) => t ? Mm(e) : e.toFixed(1), s = (e) => Om[i.indexOf(e) % Om.length], c = Math.max(0, ...e.map((e) => e.value), n ?? 0), l = kg(e.map((e) => ({
			label: `${e.category} `,
			value: e.value,
			colour: s(e.dimension),
			tip: `${Tg(e.category)} (${Tg(e.dimension)})<br>${Tg(r)}: <b>${t ? Mm(e.value, 1) : e.value.toFixed(1)}</b><br>${Nm(e.households)} households`
		})), o, a);
		return l.grid = {
			left: 4,
			right: 38,
			top: 4,
			bottom: 4,
			containLabel: !0
		}, l.xAxis = {
			type: "value",
			max: c * 1.12 || 1,
			axisLabel: { formatter: (e) => o(e) }
		}, l.yAxis.axisLabel = {
			width: 140,
			overflow: "truncate",
			interval: 0
		}, n !== null && isFinite(n) && (l.series[0].markLine = {
			silent: !0,
			symbol: "none",
			label: { show: !1 },
			lineStyle: {
				type: "dashed",
				color: Dm.slate
			},
			data: [{ xAxis: n }]
		}), l;
	}, [
		e,
		t,
		n,
		r,
		i,
		a
	]);
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(Dp, {
		option: o,
		height: Math.max(160, 19 * e.length + 30)
	}), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "d-flex flex-wrap gap-3 small text-muted mt-1",
		children: [i.map((e, t) => /* @__PURE__ */ (0, R.jsxs)("span", {
			className: "d-inline-flex align-items-center gap-1",
			children: [/* @__PURE__ */ (0, R.jsx)("span", { style: {
				width: 9,
				height: 9,
				borderRadius: 2,
				background: Om[t % Om.length],
				display: "inline-block"
			} }), e]
		}, e)), n !== null && isFinite(n) && /* @__PURE__ */ (0, R.jsxs)("span", {
			className: "d-inline-flex align-items-center gap-1",
			children: [/* @__PURE__ */ (0, R.jsx)("span", { style: {
				width: 12,
				borderTop: `1.5px dashed ${Dm.slate}`,
				display: "inline-block"
			} }), "overall"]
		})]
	})] });
}
//#endregion
//#region src/pages/overview/Builders.tsx
k();
var Ng = (e) => `overview_1-${e}`;
function Pg() {
	let e = L(Ng("ov_explore"));
	return {
		ex: e,
		key: e ? e.all.join("|") : ""
	};
}
function Fg({ t: e }) {
	let { ex: t, key: n } = Pg();
	return t ? t.all.length ? /* @__PURE__ */ (0, R.jsx)(Lg, {
		ex: t,
		t: e
	}, n) : /* @__PURE__ */ (0, R.jsx)(Y, { title: e("No column to tabulate") }) : null;
}
var Ig = [
	{
		value: "n",
		label: "Households"
	},
	{
		value: "row",
		label: "Row %"
	},
	{
		value: "col",
		label: "Column %"
	},
	{
		value: "total",
		label: "Total %"
	},
	{
		value: "mean",
		label: "Mean of a number"
	},
	{
		value: "sum",
		label: "Sum of a number"
	}
];
function Lg({ ex: e, t }) {
	let n = I(Ng("ct_stat")) ?? "n", r = L(Ng("ct_info")), i = n === "mean" || n === "sum";
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-ob",
		children: [
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ob-controls",
				children: [
					/* @__PURE__ */ (0, R.jsx)(z, {
						id: Ng("ct_row"),
						label: t("Rows"),
						choices: e.choices,
						value: e.all[0],
						clearable: !1
					}),
					/* @__PURE__ */ (0, R.jsx)(z, {
						id: Ng("ct_col"),
						label: t("Columns"),
						value: e.all[1] ?? "",
						clearable: !1,
						choices: [{
							value: "",
							label: t("(none: one-way table)")
						}, ...e.choices]
					}),
					/* @__PURE__ */ (0, R.jsx)(z, {
						id: Ng("ct_stat"),
						label: t("Cells"),
						value: "n",
						clearable: !1,
						choices: Ig.map((e) => ({
							...e,
							label: t(e.label)
						}))
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						style: { display: i ? void 0 : "none" },
						children: /* @__PURE__ */ (0, R.jsx)(z, {
							id: Ng("ct_value"),
							label: t("Number"),
							value: e.nums[0] ?? "",
							clearable: !1,
							choices: e.nums.length ? e.nums : [{
								value: "",
								label: t("(no numeric column)")
							}]
						})
					})
				]
			}),
			r && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ob-caption",
				children: [
					/* @__PURE__ */ (0, R.jsx)("b", { children: t(r.what) }),
					" · ",
					r.n,
					" ",
					t("households"),
					r.col_label ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
						" · ",
						t("columns"),
						": ",
						/* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-ob-var",
							children: r.col_label
						})
					] }) : null
				]
			}),
			/* @__PURE__ */ (0, R.jsx)(zf, {
				id: Ng("ct_table"),
				compact: !0,
				searchable: !1,
				height: 360
			}),
			r?.chi ? /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-ob-note",
				children: t(r.chi)
			}) : null
		]
	});
}
function Rg({ t: e }) {
	let { ex: t, key: n } = Pg();
	return t ? t.all.length ? /* @__PURE__ */ (0, R.jsx)(zg, {
		ex: t,
		t: e
	}, n) : /* @__PURE__ */ (0, R.jsx)(Y, { title: e("No column to chart") }) : null;
}
function zg({ ex: e, t }) {
	let n = L(Ng("gb_meta")), [r, i] = Kd(Ng("gb_type"), "", { debounceMs: 0 }), a = n?.types ?? [];
	E(() => {
		a.length && !a.some((e) => e.value === r) && i(a[0].value);
	}, [a.map((e) => e.value).join("|")]);
	let o = {
		value: "",
		label: t("(none)")
	};
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-ob",
		children: [
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ob-controls",
				children: [
					/* @__PURE__ */ (0, R.jsx)(z, {
						id: Ng("gb_x"),
						label: t("Variable"),
						choices: e.choices,
						value: e.all[0],
						clearable: !1
					}),
					/* @__PURE__ */ (0, R.jsx)(z, {
						id: Ng("gb_y"),
						label: t("Against"),
						choices: [o, ...e.choices],
						value: "",
						clearable: !1
					}),
					/* @__PURE__ */ (0, R.jsx)(z, {
						id: Ng("gb_group"),
						label: t("Grouped by"),
						choices: [o, ...e.choices],
						value: "",
						clearable: !1
					})
				]
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-ob-bar",
				children: [a.length > 0 && /* @__PURE__ */ (0, R.jsx)("div", {
					className: "btn-group btn-group-sm tw-seg",
					role: "radiogroup",
					"aria-label": t("Chart"),
					children: a.map((e) => /* @__PURE__ */ (0, R.jsx)("button", {
						type: "button",
						role: "radio",
						"aria-checked": e.value === r,
						className: `btn btn-outline-primary${e.value === r ? " active" : ""}`,
						onClick: () => i(e.value),
						children: t(e.label)
					}, e.value))
				}), /* @__PURE__ */ (0, R.jsx)(B, {
					id: Ng("gb_axes"),
					label: n?.axes_set ? t("Axes (set)") : t("Axes"),
					icon: /* @__PURE__ */ (0, R.jsx)(Rr, { size: 13 }),
					variant: "outline-secondary",
					className: "ms-auto",
					title: t("Set the bounds of the axes")
				})]
			}),
			/* @__PURE__ */ (0, R.jsx)(U, { id: Ng("gb_plot") }),
			/* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-ob-note",
				children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: Ng("gb_note") })
			})
		]
	});
}
//#endregion
//#region src/pages/overview/MapView.tsx
k();
var Bg = [
	"Light",
	"Dark",
	"Terrain",
	"Satellite",
	"Satellite (Clarity)"
], Vg = () => document.documentElement.getAttribute("data-bs-theme") === "dark";
function Hg({ ns: e, t, card: n, fitSignal: r, onColourCol: i }) {
	let a = D(null), o = D(null);
	V(e("map_points"), a), V(e("map_colours"), a);
	let s = L(e("map_points")), c = L(e("map_colours")), l = Yd(e("map_points")), u = qd(e("map_plot_bounds"), null, { debounceMs: 150 }), d = qd(e("map_click"), null, {
		debounceMs: 0,
		priority: "event"
	}), [f, p] = O(null), [m, h] = O(Vg), [g, _] = O("Terrain"), v = D("Terrain"), [y, b] = O(-1), [x, S] = O(0), C = D(null);
	C.current = f, E(() => {
		let e = !1, t = null;
		return import("./chunks/mapgl-suRRulEH.js").then(({ TwMap: r }) => {
			!e && o.current && (t = new r(o.current, n.current, {
				onBounds: (e) => u(e),
				onPick: (e) => d({
					i: e + 1,
					nonce: Date.now()
				}),
				onDrawn: (e) => b(e)
			}, Vg() ? "Dark" : "Terrain", Vg()), p(t));
		}), () => {
			e = !0, t?.destroy();
		};
	}, []), E(() => {
		let e = new MutationObserver(() => h(Vg()));
		return e.observe(document.documentElement, {
			attributes: !0,
			attributeFilter: ["data-bs-theme"]
		}), () => e.disconnect();
	}, []), E(() => {
		_(m ? "Dark" : v.current);
	}, [m]), E(() => {
		f?.setBase(g, m);
	}, [
		f,
		g,
		m
	]), E(() => {
		if (!f || !s) return;
		let e = !1;
		return import("./chunks/mapgl-suRRulEH.js").then(({ b64bytes: e }) => e(s.pos)).then((t) => {
			e || (f.setPoints(new Float32Array(t), s.n, s.bounds), S((e) => e + 1));
		}), () => {
			e = !0;
		};
	}, [f, s]), E(() => {
		if (!f || !c || !s || c.n !== s.n) return;
		let e = !1;
		return import("./chunks/mapgl-suRRulEH.js").then(({ b64bytes: e }) => e(c.code)).then((t) => {
			e || f.setColours(new Uint8Array(t), c.palette);
		}), () => {
			e = !0;
		};
	}, [
		f,
		c,
		x
	]), E(() => {
		c?.refused && i(c.col);
	}, [c]), E(() => {
		r && f?.fit();
	}, [r]), Xd(e("map_popup"), (e) => C.current?.showPopup(e.lng, e.lat, e.html));
	let w = c?.legend;
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		ref: a,
		className: "tw-map-holder",
		"data-points": y,
		children: [
			/* @__PURE__ */ (0, R.jsx)("div", {
				ref: o,
				className: "tw-map-gl"
			}),
			/* @__PURE__ */ (0, R.jsx)("select", {
				className: "form-select form-select-sm tw-map-base",
				value: g,
				"aria-label": t("Basemap"),
				title: t("Basemap"),
				onChange: (e) => {
					_(e.target.value), e.target.value !== "Dark" && (v.current = e.target.value);
				},
				children: Bg.map((e) => /* @__PURE__ */ (0, R.jsx)("option", {
					value: e,
					children: t(e)
				}, e))
			}),
			l?.message && /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-map-note",
				children: l.message
			}),
			s && s.n === 0 && !l?.message && /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-map-note",
				children: t("No household with usable GPS coordinates in these data.")
			}),
			w && c.title && w.colors.length > 0 && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-map-legend",
				children: [/* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-map-legend-title",
					children: c.title
				}), w.numeric ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-map-ramp",
					style: { background: `linear-gradient(to right, ${w.colors.join(", ")})` }
				}), /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-map-ramp-labels",
					children: w.labels.map((e, t) => /* @__PURE__ */ (0, R.jsx)("span", { children: e }, t))
				})] }) : w.colors.map((e, t) => /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-map-legend-row",
					children: [/* @__PURE__ */ (0, R.jsx)("i", { style: { background: e } }), /* @__PURE__ */ (0, R.jsx)("span", { children: w.labels[t] })]
				}, t))]
			})
		]
	});
}
//#endregion
//#region src/pages/overview/OverviewPage.tsx
k();
var Ug = "overview_1-", Wg = (e) => Ug + e, Gg = {
	admin1: "Admin 1",
	admin2: "Admin 2",
	admin3: "Admin 3"
}, Kg = {
	eligible: "Share eligible",
	vulnerable: "Share in the most vulnerable groups",
	score: "Mean score"
};
function qg({ active: e, t }) {
	let n = L(Wg("ov_meta"));
	return n ? /* @__PURE__ */ (0, R.jsx)(Jg, {
		meta: n,
		active: e,
		t
	}) : /* @__PURE__ */ (0, R.jsx)("div", {
		className: "p-4",
		children: /* @__PURE__ */ (0, R.jsx)(Y, { title: t("Load the registration data and map its variables first.") })
	});
}
function Jg({ meta: e, active: t, t: n }) {
	let [r, i] = Kd(Wg("filter_admin1"), []), [a, o] = Kd(Wg("filter_admin2"), []), [s, c] = Kd(Wg("filter_admin3"), []), l = [
		r,
		a,
		s
	], u = [
		i,
		o,
		c
	], [d, f] = Kd(Wg("filter_date"), e.dates ?? []), p = tf(Wg("btn_apply_filters")), m = tf(Wg("btn_clear_filters"));
	E(() => {
		e.dates && d.length !== 2 && f([...e.dates]);
	}, [e.dates]);
	let h = _e(() => e.levels.map((t, n) => {
		let r = e.areas[0]?.length ?? 0, i = /* @__PURE__ */ new Set();
		for (let t = 0; t < r; t++) {
			let r = !0;
			for (let i = 0; i < n; i++) if (l[i].length && !l[i].includes(e.areas[i][t])) {
				r = !1;
				break;
			}
			r && e.areas[n][t] && i.add(e.areas[n][t]);
		}
		return [...i].sort();
	}), [
		e,
		r,
		a,
		s
	]);
	E(() => {
		e.levels.forEach((e, t) => {
			let n = l[t].filter((e) => h[t].includes(e));
			n.length !== l[t].length && u[t](n);
		});
	}, [h]);
	let g = () => {
		i([]), o([]), c([]), e.dates && f([...e.dates]), m();
	}, [_, v] = Kd(Wg("map_var"), e.map_default);
	E(() => {
		!_ && e.map_default && v(e.map_default);
	}, [e.map_default]);
	let [y, b] = Kd(Wg("view_follow"), !1), x = tf(Wg("view_all")), S = D(null), [C, w] = O(0), ee = L(Wg("ov_view")), T = L(Wg("ov_ready")), te = L(Wg("ov_collection")), ne = D(null);
	V(Wg("ov_collection"), ne);
	let re = Jd(Wg("ov_collection")), [ie, ae] = O(!0), oe = L(Wg("ov_profile")), se = L(Wg("ov_vuln")), [ce, le] = O(""), ue = se && !se.empty ? se.cross[ce] ?? se.cross[se.indicator] : void 0, [de, fe] = O("who");
	E(() => {
		t && window.setTimeout(() => window.dispatchEvent(new Event("resize")), 30);
	}, [de, t]);
	let pe = { menuPortal: (e) => ({
		...e,
		zIndex: 1090
	}) };
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-rov",
		children: [
			/* @__PURE__ */ (0, R.jsxs)("aside", {
				className: "tw-rov-side",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("section", {
						className: "tw-rov-step",
						children: [/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-rov-step-title",
							children: ["1. ", n("Areas")]
						}), e.levels.map((e, t) => /* @__PURE__ */ (0, R.jsxs)("label", {
							className: "tw-rov-field",
							children: [/* @__PURE__ */ (0, R.jsx)("span", { children: n(Gg[e] ?? e) }), /* @__PURE__ */ (0, R.jsx)(Wd, {
								isMulti: !0,
								classNamePrefix: "tw-select",
								placeholder: n("Nothing selected"),
								menuPortalTarget: document.body,
								styles: pe,
								options: h[t].map((e) => ({
									value: e,
									label: e
								})),
								value: l[t].map((e) => ({
									value: e,
									label: e
								})),
								onChange: (e) => u[t](e.map((e) => e.value))
							})]
						}, e))]
					}),
					e.dates && /* @__PURE__ */ (0, R.jsxs)("section", {
						className: "tw-rov-step",
						children: [/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-rov-step-title",
							children: ["2. ", n("Interview dates")]
						}), /* @__PURE__ */ (0, R.jsxs)("div", {
							className: "d-flex gap-2",
							children: [/* @__PURE__ */ (0, R.jsx)("input", {
								type: "date",
								className: "form-control form-control-sm",
								"aria-label": "From",
								min: e.dates[0],
								max: e.dates[1],
								value: d[0] ?? "",
								onChange: (t) => f([t.target.value, d[1] ?? e.dates[1]])
							}), /* @__PURE__ */ (0, R.jsx)("input", {
								type: "date",
								className: "form-control form-control-sm",
								"aria-label": "To",
								min: e.dates[0],
								max: e.dates[1],
								value: d[1] ?? "",
								onChange: (t) => f([d[0] ?? e.dates[0], t.target.value])
							})]
						})]
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-rov-actions",
						children: [/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "d-flex gap-2",
							children: [/* @__PURE__ */ (0, R.jsxs)("button", {
								type: "button",
								className: "btn btn-primary btn-sm flex-fill",
								onClick: p,
								children: [
									/* @__PURE__ */ (0, R.jsx)(Rn, { size: 14 }),
									" ",
									n("Apply")
								]
							}), /* @__PURE__ */ (0, R.jsx)("button", {
								type: "button",
								className: "btn btn-outline-secondary btn-sm",
								onClick: g,
								title: n("Clear the filters"),
								"aria-label": n("Clear the filters"),
								children: /* @__PURE__ */ (0, R.jsx)(Ma, { size: 14 })
							})]
						}), /* @__PURE__ */ (0, R.jsxs)($d, {
							id: Wg("overview_report"),
							tagName: "a",
							className: "btn btn-outline-primary btn-sm w-100 mt-2 shiny-download-link",
							download: "",
							target: "_blank",
							children: [
								/* @__PURE__ */ (0, R.jsx)(mn, { size: 14 }),
								" ",
								n("Overview report (HTML)")
							]
						})]
					})
				]
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "card tw-rov-map",
				ref: S,
				children: [/* @__PURE__ */ (0, R.jsx)("div", {
					className: "wfp-map-toolbar",
					children: /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "d-flex align-items-center gap-2",
						children: [/* @__PURE__ */ (0, R.jsx)("span", {
							className: "wfp-map-toolbar-label",
							children: n("Colour by")
						}), /* @__PURE__ */ (0, R.jsx)("select", {
							className: "form-select form-select-sm",
							value: _,
							onChange: (e) => v(e.target.value),
							"aria-label": "Colour by",
							children: e.map_vars.map((e) => /* @__PURE__ */ (0, R.jsx)("option", {
								value: e.value,
								children: n(e.label)
							}, e.value))
						})]
					})
				}), /* @__PURE__ */ (0, R.jsx)(Hg, {
					ns: Wg,
					t: n,
					card: S,
					fitSignal: C,
					onColourCol: (e) => {
						e && e !== _ && v(e);
					}
				})]
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-rov-right",
				children: [/* @__PURE__ */ (0, R.jsxs)("div", {
					ref: ne,
					className: "card tw-rov-collection" + (re === "recalculating" ? " recalculating" : ""),
					children: [
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-ov-head",
							children: [
								/* @__PURE__ */ (0, R.jsxs)("span", {
									className: "tw-ov-title",
									children: [
										/* @__PURE__ */ (0, R.jsx)(Le, { size: 14 }),
										" ",
										n("Data collection")
									]
								}),
								ee && /* @__PURE__ */ (0, R.jsxs)("span", {
									className: "tw-ov-chip" + (ee.zoomed ? " zoomed" : ""),
									children: [
										ee.zoomed ? /* @__PURE__ */ (0, R.jsx)(Pa, { size: 12 }) : /* @__PURE__ */ (0, R.jsx)(gn, { size: 12 }),
										" ",
										ee.label,
										ee.zoomed && /* @__PURE__ */ (0, R.jsx)("a", {
											href: "#",
											className: "ms-1",
											onClick: (e) => {
												e.preventDefault(), b(!1), x(), w((e) => e + 1);
											},
											children: n("show all")
										})
									]
								}),
								/* @__PURE__ */ (0, R.jsxs)("label", {
									className: "form-check form-switch tw-ov-follow ms-auto mb-0",
									title: n("On: the figures describe the households in the map view and follow it as you pan or zoom. Off: every household."),
									children: [/* @__PURE__ */ (0, R.jsx)("input", {
										className: "form-check-input",
										type: "checkbox",
										role: "switch",
										checked: y,
										onChange: (e) => b(e.target.checked)
									}), /* @__PURE__ */ (0, R.jsx)("span", {
										className: "form-check-label",
										children: n("Follow the map")
									})]
								})
							]
						}),
						T && T.off.length > 0 && /* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-ready-strip",
							children: [/* @__PURE__ */ (0, R.jsx)("span", { children: n("Not available with these data:") }), T.off.map((e) => /* @__PURE__ */ (0, R.jsx)("span", {
								className: "tw-ready-chip off",
								title: e.detail,
								children: e.feature
							}, e.feature))]
						}),
						te ? /* @__PURE__ */ (0, R.jsx)(Am, { tiles: te.tiles }) : null,
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-ov-daily",
							children: [/* @__PURE__ */ (0, R.jsxs)("div", {
								className: "tw-ov-daily-bar",
								children: [/* @__PURE__ */ (0, R.jsx)("span", {
									className: "tw-ov-sub",
									children: n("Households per day")
								}), te?.by_area && /* @__PURE__ */ (0, R.jsxs)("div", {
									className: "btn-group btn-group-sm tw-seg-r",
									role: "group",
									"aria-label": "Total or by area",
									children: [/* @__PURE__ */ (0, R.jsx)("button", {
										type: "button",
										className: "btn" + (ie ? "" : " active"),
										onClick: () => ae(!1),
										children: n("Total")
									}), /* @__PURE__ */ (0, R.jsx)("button", {
										type: "button",
										className: "btn" + (ie ? " active" : ""),
										onClick: () => ae(!0),
										children: n("By area")
									})]
								})]
							}), te && te.daily.length > 0 ? /* @__PURE__ */ (0, R.jsx)(Og, {
								daily: te.daily,
								byArea: ie && te.by_area,
								areas: te.areas
							}) : te ? /* @__PURE__ */ (0, R.jsx)("div", {
								className: "small text-muted py-3",
								children: n("Not in these data: map the data collection date to see the daily submissions.")
							}) : null]
						})
					]
				}), /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-rov-sections",
					children: [
						/* @__PURE__ */ (0, R.jsx)(Yg, {
							id: "who",
							title: n("Who is in the data"),
							open: de,
							setOpen: fe,
							watch: Wg("ov_profile"),
							children: oe ? oe.empty ? /* @__PURE__ */ (0, R.jsx)(Y, {
								title: n("No household characteristic is mapped"),
								sub: n("Map the head's sex and age, household size, children under 5, residence status... in Variable Definition & Setup.")
							}) : /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(Am, { tiles: oe.tiles }), /* @__PURE__ */ (0, R.jsx)("div", {
								className: "tw-mini-grid",
								children: oe.charts.map((e) => /* @__PURE__ */ (0, R.jsxs)("div", {
									className: "tw-mini",
									children: [/* @__PURE__ */ (0, R.jsx)("div", {
										className: "tw-mini-title",
										children: n(e.title)
									}), /* @__PURE__ */ (0, R.jsx)(Ag, {
										data: e.data,
										kind: e.kind
									})]
								}, e.key))
							})] }) : null
						}),
						/* @__PURE__ */ (0, R.jsx)(Yg, {
							id: "vuln",
							title: n("Vulnerability"),
							open: de,
							setOpen: fe,
							watch: Wg("ov_vuln"),
							children: se ? se.empty ? /* @__PURE__ */ (0, R.jsx)(Y, {
								title: n("No vulnerability variable is mapped"),
								sub: n("Map a vulnerability score, vulnerability groups or eligibility in Variable Definition & Setup, or build a scorecard in Targeting Design.")
							}) : /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)("div", {
								className: "tw-mini-grid",
								children: [se.groups && /* @__PURE__ */ (0, R.jsxs)("div", {
									className: "tw-mini",
									children: [/* @__PURE__ */ (0, R.jsx)("div", {
										className: "tw-mini-title",
										children: n("Households by vulnerability group")
									}), /* @__PURE__ */ (0, R.jsx)(jg, { groups: se.groups })]
								}), se.score && /* @__PURE__ */ (0, R.jsxs)("div", {
									className: "tw-mini",
									children: [/* @__PURE__ */ (0, R.jsx)("div", {
										className: "tw-mini-title",
										children: n("Distribution of the vulnerability score")
									}), /* @__PURE__ */ (0, R.jsx)(Ag, {
										data: se.score,
										kind: "bins",
										height: 200
									})]
								})]
							}), ue && ue.rows.length > 0 && /* @__PURE__ */ (0, R.jsxs)("div", {
								className: "tw-mini tw-mini-wide",
								children: [/* @__PURE__ */ (0, R.jsxs)("div", {
									className: "tw-mini-title d-flex align-items-center justify-content-between gap-2",
									children: [/* @__PURE__ */ (0, R.jsx)("span", { children: n("Across household profiles") }), /* @__PURE__ */ (0, R.jsx)("select", {
										className: "form-select form-select-sm",
										style: { width: 240 },
										value: ue.indicator,
										onChange: (e) => le(e.target.value),
										"aria-label": "Indicator",
										children: se.available.map((e) => /* @__PURE__ */ (0, R.jsx)("option", {
											value: e,
											children: n(Kg[e] ?? e)
										}, e))
									})]
								}), /* @__PURE__ */ (0, R.jsx)(Mg, {
									rows: ue.rows,
									pctScale: ue.pct,
									overall: ue.overall,
									label: ue.label
								})]
							})] }) : null
						}),
						/* @__PURE__ */ (0, R.jsx)(Yg, {
							id: "explore",
							title: n("Table builder"),
							open: de,
							setOpen: fe,
							children: /* @__PURE__ */ (0, R.jsx)(Fg, { t: n })
						}),
						/* @__PURE__ */ (0, R.jsx)(Yg, {
							id: "charts",
							title: n("Chart builder"),
							open: de,
							setOpen: fe,
							children: /* @__PURE__ */ (0, R.jsx)(Rg, { t: n })
						})
					]
				})]
			})
		]
	});
}
function Yg({ id: e, title: t, open: n, setOpen: r, children: i, watch: a }) {
	let o = n === e, s = D(null);
	return V(a ?? "", s), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-rov-sec" + (o ? " open" : ""),
		children: [/* @__PURE__ */ (0, R.jsxs)("button", {
			type: "button",
			className: "tw-rov-sec-head",
			"aria-expanded": o,
			onClick: () => r(o ? "" : e),
			children: [/* @__PURE__ */ (0, R.jsx)("span", { children: t }), /* @__PURE__ */ (0, R.jsx)("span", {
				className: "tw-rov-chev",
				"aria-hidden": !0,
				children: o ? "⌃" : "⌄"
			})]
		}), /* @__PURE__ */ (0, R.jsx)("div", {
			ref: s,
			className: "tw-rov-sec-body",
			style: { display: o ? "block" : "none" },
			children: i
		})]
	});
}
//#endregion
//#region src/pages/overview/index.tsx
var Xg = /* @__PURE__ */ n({
	default: () => qg,
	page: () => Zg
}), Zg = "overview_panel";
//#endregion
//#region src/pages/selection/SelectionPage.tsx
k();
var Q = (e) => `ben_selection_1-${e}`, Qg = (e) => Math.round(e).toLocaleString("en-US"), $g = {
	people: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 14 }),
	person: /* @__PURE__ */ (0, R.jsx)(Sa, { size: 14 }),
	female: /* @__PURE__ */ (0, R.jsx)(Oa, { size: 14 }),
	cut: /* @__PURE__ */ (0, R.jsx)(Vt, { size: 14 }),
	area: /* @__PURE__ */ (0, R.jsx)(Er, { size: 14 })
};
function e_({ t: e }) {
	let t = L(Q("ben_meta")), n = L(Q("ben_pending"))?.pending ?? [], r = I(Q("ben_approach")) ?? "hybrid", i = t?.approaches.find((e) => e.value === r), a = i?.gates ?? [
		"area",
		"criteria",
		"score"
	], o = [
		I(Q("ben_admin1")),
		I(Q("ben_admin2")),
		I(Q("ben_admin3"))
	].reduce((e, t) => e + (Array.isArray(t) ? t.length : +!!t), 0), s = /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(Hf, { steps: [{
		key: "areas",
		title: `1. ${e("Areas covered")}`,
		icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 15 }),
		summary: o ? `${o} ${e("chosen")}` : e("Every area"),
		content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
			/* @__PURE__ */ (0, R.jsx)("p", {
				className: "small text-muted mb-2",
				children: e("Leave empty to cover every area. Households outside the chosen areas are left out of the selection and its reports.")
			}),
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: Q("ben_admin1"),
				label: e("Admin 1"),
				multiple: !0,
				actions: !0,
				placeholder: e("All areas")
			}),
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: Q("ben_admin2"),
				label: e("Admin 2"),
				multiple: !0,
				actions: !0,
				placeholder: e("All areas")
			}),
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: Q("ben_admin3"),
				label: e("Admin 3"),
				multiple: !0,
				actions: !0,
				placeholder: e("All areas")
			})
		] })
	}] }), /* @__PURE__ */ (0, R.jsxs)(Uf, { children: [
		/* @__PURE__ */ (0, R.jsx)(r_, {
			pending: n,
			t: e
		}),
		/* @__PURE__ */ (0, R.jsxs)("div", {
			className: "d-flex gap-2",
			children: [/* @__PURE__ */ (0, R.jsx)(B, {
				id: Q("ben_apply"),
				label: e("Apply selection"),
				icon: /* @__PURE__ */ (0, R.jsx)(Rn, { size: 14 }),
				variant: "primary",
				className: "flex-fill"
			}), /* @__PURE__ */ (0, R.jsx)(B, {
				id: Q("ben_clear"),
				icon: /* @__PURE__ */ (0, R.jsx)(Ma, { size: 14 }),
				variant: "outline-secondary",
				title: e("Clear the selection criteria")
			})]
		}),
		/* @__PURE__ */ (0, R.jsx)(B, {
			id: Q("export_open"),
			label: e("Export selection (Excel)"),
			icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 14 }),
			className: "w-100 mt-2"
		}),
		/* @__PURE__ */ (0, R.jsx)(bf, {
			id: Q("selection_report"),
			label: e("Selection report (HTML)"),
			icon: /* @__PURE__ */ (0, R.jsx)(On, { size: 14 }),
			className: "w-100 mt-2"
		}),
		/* @__PURE__ */ (0, R.jsx)("div", {
			className: "mt-2",
			children: /* @__PURE__ */ (0, R.jsx)(ip, {
				ns: Q("calc"),
				t: e,
				block: !0
			})
		})
	] })] });
	return /* @__PURE__ */ (0, R.jsx)(Vf, {
		width: 300,
		sidebar: s,
		className: "tw-sel",
		children: /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-sel-main",
			children: [
				t && !t.ready && /* @__PURE__ */ (0, R.jsx)(Y, { title: e("Load the registration data and map its variables first.") }),
				/* @__PURE__ */ (0, R.jsx)(t_, { t: e }),
				/* @__PURE__ */ (0, R.jsx)(n_, { t: e }),
				/* @__PURE__ */ (0, R.jsx)(Wf, {
					id: Q("ben_tabs"),
					value: "design",
					tabs: [
						{
							value: "design",
							label: e("Selection design"),
							icon: /* @__PURE__ */ (0, R.jsx)(Ai, { size: 14 }),
							content: /* @__PURE__ */ (0, R.jsx)(i_, {
								t: e,
								meta: t,
								gates: a,
								approach: i,
								pending: n
							})
						},
						{
							value: "composition",
							label: e("Composition"),
							icon: /* @__PURE__ */ (0, R.jsx)(_t, { size: 14 }),
							content: /* @__PURE__ */ (0, R.jsx)(s_, {
								t: e,
								meta: t
							})
						},
						{
							value: "list",
							label: e("Beneficiary list"),
							icon: /* @__PURE__ */ (0, R.jsx)(br, { size: 14 }),
							content: /* @__PURE__ */ (0, R.jsx)(c_, { t: e })
						}
					]
				})
			]
		})
	});
}
function t_({ t: e }) {
	let t = (e, t, n, r) => /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-sel-kpi",
		children: [/* @__PURE__ */ (0, R.jsx)("span", {
			className: `tw-sel-kpi-icon tone-${r}`,
			children: n
		}), /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "min-w-0",
			children: [/* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-sel-kpi-label",
				children: t
			}), /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-sel-kpi-value",
				children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: Q(e) })
			})]
		})]
	});
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-sel-kpis",
		children: [
			t("ben_total", e("Selected households"), /* @__PURE__ */ (0, R.jsx)(Ea, { size: 18 }), "primary"),
			t("ben_indiv", e("Selected individuals"), /* @__PURE__ */ (0, R.jsx)(wa, { size: 18 }), "secondary"),
			t("ben_eligible", e("Eligible by design"), /* @__PURE__ */ (0, R.jsx)(Lt, { size: 18 }), "info"),
			t("ben_cut", e("Excluded by design"), /* @__PURE__ */ (0, R.jsx)(Vt, { size: 18 }), "warning")
		]
	});
}
function n_({ t: e }) {
	let t = L(Q("selection_note"));
	if (!t) return null;
	let n = t.eligible - t.served;
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-sel-note",
		children: [/* @__PURE__ */ (0, R.jsxs)("div", { children: [
			/* @__PURE__ */ (0, R.jsx)("strong", { children: e(t.label) }),
			": ",
			t.list_produced ? /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
				Qg(t.eligible),
				" ",
				e("eligible by design"),
				t.served < t.eligible && /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					", ",
					Qg(t.served),
					" ",
					e("prioritised"),
					", ",
					/* @__PURE__ */ (0, R.jsxs)("strong", { children: [
						Qg(n),
						" ",
						e("excluded by design")
					] }),
					" (",
					e("unmet need, not an exclusion error"),
					")"
				] }),
				"."
			] }) : e("no household list is produced.")
		] }), t.list_produced && t.notes.map((e) => /* @__PURE__ */ (0, R.jsx)("div", {
			className: "tw-sel-note-warn",
			children: e
		}, e))]
	});
}
function r_({ pending: e, t }) {
	return e.length ? /* @__PURE__ */ (0, R.jsxs)(Jf, {
		kind: "warning",
		className: "tw-sel-pending",
		children: [
			t("Not applied yet"),
			": ",
			e.map(t).join(", "),
			". ",
			t("Apply the selection to use them.")
		]
	}) : null;
}
function i_({ t: e, meta: t, gates: n, approach: r, pending: i }) {
	let a = r?.value ?? "hybrid", o = a === "self", s = I(Q("ben_prio_mode")) ?? "none", c = I(Q("use_scorecard")), l = t?.card ?? null, u = !!l && c !== !1, d = [
		{
			key: "approach",
			title: e("Approach"),
			show: !0,
			body: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
				/* @__PURE__ */ (0, R.jsx)(z, {
					id: Q("ben_approach"),
					value: "hybrid",
					clearable: !1,
					choices: (t?.approaches ?? []).map((t) => ({
						value: t.value,
						label: e(t.label)
					}))
				}),
				r && /* @__PURE__ */ (0, R.jsx)("p", {
					className: "small text-muted mb-2",
					children: e(r.description)
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					hidden: a !== "hybrid",
					children: /* @__PURE__ */ (0, R.jsx)(_f, {
						id: Q("ben_combine"),
						label: e("Criteria and score combine as"),
						value: "both",
						choices: [{
							value: "both",
							label: e("Both (criteria AND score)")
						}, {
							value: "either",
							label: e("Either (criteria OR score)")
						}]
					})
				})
			] })
		},
		{
			key: "rules",
			title: e("Eligibility rules"),
			show: n.includes("criteria"),
			body: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
				/* @__PURE__ */ (0, R.jsx)("p", {
					className: "small text-muted mb-2",
					children: e("Combine conditions on any column, e.g. (A and B) or C.")
				}),
				/* @__PURE__ */ (0, R.jsx)(B, {
					id: Q("btn_rules"),
					label: e("Edit eligibility rules"),
					icon: /* @__PURE__ */ (0, R.jsx)(Ai, { size: 14 })
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "small text-muted mt-2",
					children: /* @__PURE__ */ (0, R.jsx)(Sf, { id: Q("rules_summary") })
				})
			] })
		},
		{
			key: "score",
			title: e("Score"),
			show: n.includes("score"),
			body: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
				/* @__PURE__ */ (0, R.jsxs)("div", {
					hidden: !l,
					children: [
						/* @__PURE__ */ (0, R.jsx)(gf, {
							id: Q("use_scorecard"),
							value: !0,
							asSwitch: !0,
							label: l ? `${e("Apply the")} ${e(l.word)} (${l.n} ${e("criteria")})` : ""
						}, `use-${l?.fp ?? "none"}`),
						/* @__PURE__ */ (0, R.jsx)("div", {
							hidden: !u,
							children: /* @__PURE__ */ (0, R.jsx)(mf, {
								id: Q("scorecard_threshold"),
								label: e("Eligible when score is above"),
								value: l?.threshold ?? null,
								min: 0,
								step: .1
							})
						}),
						/* @__PURE__ */ (0, R.jsx)(a_, { t: e }),
						/* @__PURE__ */ (0, R.jsx)(B, {
							id: Q("sc_rematch"),
							label: e("Match columns"),
							icon: /* @__PURE__ */ (0, R.jsx)(cr, { size: 14 }),
							className: "mt-1"
						})
					]
				}),
				!l && /* @__PURE__ */ (0, R.jsx)("p", {
					className: "small text-muted mb-2",
					children: e("No scorecard or vulnerability ranking in use. Build one under Targeting Design (with an outcome indicator, or without one for a ranking) and adopt it, or load one exported from there.")
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					hidden: u,
					children: [/* @__PURE__ */ (0, R.jsx)(vf, {
						id: Q("ben_score_min"),
						label: e("Minimum vulnerability score"),
						min: 0,
						max: 100,
						value: 0
					}), /* @__PURE__ */ (0, R.jsx)(vf, {
						id: Q("ben_score_max"),
						label: e("Maximum vulnerability score"),
						min: 0,
						max: 100,
						value: 100
					})]
				}),
				/* @__PURE__ */ (0, R.jsx)(xf, { id: Q("scorecard_ui") })
			] })
		},
		{
			key: "community",
			title: e("Community decision"),
			show: n.includes("community"),
			body: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(z, {
				id: Q("ben_comm_col"),
				label: e("Column recording the community's decision"),
				value: "",
				clearable: !1,
				choices: [{
					value: "",
					label: e("Choose a column")
				}]
			}), /* @__PURE__ */ (0, R.jsx)(z, {
				id: Q("ben_comm_vals"),
				label: e("Value(s) meaning selected"),
				multiple: !0,
				actions: !0
			})] })
		},
		{
			key: "prio",
			title: e("Prioritisation"),
			show: !o,
			body: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(_f, {
				id: Q("ben_prio_mode"),
				value: "none",
				choices: [
					{
						value: "none",
						label: e("None: serve all eligible")
					},
					{
						value: "caseload",
						label: e("Total caseload")
					},
					{
						value: "per_unit",
						label: e("Caseload per area")
					}
				]
			}), /* @__PURE__ */ (0, R.jsxs)("div", {
				hidden: s === "none",
				children: [
					/* @__PURE__ */ (0, R.jsx)(_f, {
						id: Q("ben_prio_count"),
						label: e("Caseload counted in"),
						inline: !0,
						value: "people",
						choices: [{
							value: "people",
							label: e("People (beneficiaries)")
						}, {
							value: "households",
							label: e("Households")
						}]
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						hidden: s !== "caseload",
						children: [/* @__PURE__ */ (0, R.jsx)(mf, {
							id: Q("ben_prio_n"),
							label: e("Caseload to serve"),
							min: 1,
							step: 1
						}), /* @__PURE__ */ (0, R.jsx)(hf, {
							id: Q("ben_prio_rationale"),
							label: e("Rationale (required)"),
							area: !0,
							rows: 2,
							placeholder: e("e.g. Caseload set by the funding available for the first round.")
						})]
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						hidden: s !== "per_unit",
						children: [
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: Q("ben_quota_unit"),
								label: e("Per"),
								value: "admin1",
								clearable: !1,
								choices: [
									{
										value: "admin1",
										label: "Admin 1"
									},
									{
										value: "admin2",
										label: "Admin 2"
									},
									{
										value: "admin3",
										label: "Admin 3"
									},
									{
										value: "admin4",
										label: "Admin 4"
									}
								]
							}),
							/* @__PURE__ */ (0, R.jsx)(B, {
								id: Q("quota_open"),
								label: e("Set the caseload per area..."),
								icon: /* @__PURE__ */ (0, R.jsx)(En, { size: 14 }),
								className: "w-100 mb-2"
							}),
							/* @__PURE__ */ (0, R.jsx)(o_, { t: e })
						]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "text-muted small mt-1",
						children: e("Most vulnerable first (highest score). Eligible households cut here are excluded by design: reported separately, not counted as exclusion errors.")
					})
				]
			})] })
		}
	], f = 0;
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)("div", {
		className: "tw-sel-design",
		children: d.map((e) => /* @__PURE__ */ (0, R.jsxs)("section", {
			className: "tw-sel-step",
			hidden: !e.show,
			children: [/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-sel-step-head",
				children: [/* @__PURE__ */ (0, R.jsx)("span", {
					className: "tw-sel-step-num",
					children: e.show ? ++f : ""
				}), e.title]
			}), e.body]
		}, e.key))
	}), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-sel-foot",
		children: [/* @__PURE__ */ (0, R.jsxs)("span", {
			className: "small text-muted",
			children: [
				/* @__PURE__ */ (0, R.jsx)(ir, { size: 14 }),
				" ",
				i.length ? `${e("Not applied yet")}: ${i.map(e).join(", ")}.` : e("The design and the filters take effect together when you apply the selection.")
			]
		}), /* @__PURE__ */ (0, R.jsxs)("button", {
			type: "button",
			className: "btn btn-outline-primary btn-sm",
			onClick: () => document.getElementById(Q("ben_apply"))?.click(),
			children: [
				/* @__PURE__ */ (0, R.jsx)(Rn, { size: 14 }),
				" ",
				e("Apply selection")
			]
		})]
	})] });
}
function a_({ t: e }) {
	let t = L(Q("scorecard_note"));
	return t ? /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-sel-scnote",
		children: [t.ready ? /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "small text-success",
			children: [
				/* @__PURE__ */ (0, R.jsx)(Lt, { size: 14 }),
				" ",
				e("All %d criteria mapped.").replace("%d", String(t.n)),
				" ",
				t.ranking ? e("A vulnerability ranking built without an outcome indicator: its errors are not measured; calibrate it in Monitoring (PDM).") : /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
					e("Outcome"),
					": ",
					t.outcome,
					"."
				] })
			]
		}) : /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "small text-warning",
			children: [
				/* @__PURE__ */ (0, R.jsx)(Nt, { size: 14 }),
				" ",
				e("%1 of %2 criteria are not mapped to this dataset (%3). They score nobody.").replace("%1", String(t.unmapped)).replace("%2", String(t.n)).replace("%3", t.missing.join(", "))
			]
		}), t.stale && /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "small text-warning",
			children: [
				/* @__PURE__ */ (0, R.jsx)(pt, { size: 14 }),
				" ",
				e("Designed %1 months ago (%2). The OGN asks for weights to be reviewed every 2-3 years, annually in dynamic contexts.").replace("%1", String(t.stale.months)).replace("%2", t.stale.created)
			]
		})]
	}) : null;
}
function o_({ t: e }) {
	let t = L(Q("quota_summary"));
	return t ? t.set ? /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "small text-muted tw-sel-quota",
		children: [
			/* @__PURE__ */ (0, R.jsx)(Lt, {
				size: 14,
				className: "text-success"
			}),
			" ",
			Qg(t.total ?? 0),
			" ",
			e(t.count ?? "households"),
			" ",
			e("in"),
			" ",
			t.areas,
			" ",
			e("areas"),
			" (",
			t.share ? e("by share of the total") : e("per area"),
			")."
		]
	}) : /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "small text-warning tw-sel-quota",
		children: [
			/* @__PURE__ */ (0, R.jsx)(Nt, { size: 14 }),
			" ",
			e("No caseload set for this level yet.")
		]
	}) : null;
}
function s_({ t: e, meta: t }) {
	let n = L(Q("comp_insights")), r = L(Q("ben_profile")), i = t?.ranking ?? null, a = Yd(Q("ben_validation_plot"))?.message, o = (t) => /* @__PURE__ */ (0, R.jsx)("span", {
		className: "tw-sel-help",
		title: e(t),
		"aria-label": e(t),
		children: /* @__PURE__ */ (0, R.jsx)(ir, { size: 13 })
	}), s = D(null);
	return V(Q("comp_insights"), s), V(Q("ben_profile"), s), /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-sel-comp",
		ref: s,
		children: [
			n?.empty ? /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("Nobody selected"),
				sub: e("Apply a selection to see what the list is made of.")
			}) : /* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-sel-insights",
				children: (n?.tiles ?? []).map((t) => /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-sel-insight",
					children: [
						/* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-sel-insight-label",
							children: [
								$g[t.icon],
								" ",
								e(t.label)
							]
						}),
						/* @__PURE__ */ (0, R.jsx)("div", {
							className: "tw-sel-insight-value",
							children: t.value
						}),
						t.sub && /* @__PURE__ */ (0, R.jsx)("div", {
							className: "tw-sel-insight-sub",
							children: t.sub
						})
					]
				}, t.label))
			}),
			a && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "small text-muted",
				children: [
					/* @__PURE__ */ (0, R.jsx)(ir, { size: 13 }),
					" ",
					e(a)
				]
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: a ? void 0 : "tw-sel-grid2",
				children: [/* @__PURE__ */ (0, R.jsx)("div", {
					hidden: !!a,
					children: /* @__PURE__ */ (0, R.jsx)(H, {
						title: e("Eligibility and vulnerability mix"),
						icon: /* @__PURE__ */ (0, R.jsx)(_t, { size: 15 }),
						full: !0,
						children: /* @__PURE__ */ (0, R.jsx)(U, { id: Q("ben_validation_plot") })
					})
				}), /* @__PURE__ */ (0, R.jsx)(H, {
					title: e("By area: served, excluded by design, not eligible"),
					icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 15 }),
					full: !0,
					children: /* @__PURE__ */ (0, R.jsx)(U, { id: Q("ben_area_plot") })
				})]
			}),
			/* @__PURE__ */ (0, R.jsx)(H, {
				title: e("Who is selected, compared with who is not"),
				icon: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 15 }),
				full: !0,
				children: r ? r.message ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: "small text-muted",
					children: e(r.message)
				}) : /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-sel-prof-wrap",
					children: /* @__PURE__ */ (0, R.jsxs)("table", {
						className: "table table-sm tw-table tw-sel-prof mb-0",
						children: [/* @__PURE__ */ (0, R.jsx)("thead", { children: /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
							/* @__PURE__ */ (0, R.jsx)("th", { children: e("Indicator") }),
							/* @__PURE__ */ (0, R.jsx)("th", {
								className: "text-end",
								children: e("Selected")
							}),
							/* @__PURE__ */ (0, R.jsx)("th", {
								className: "text-end",
								children: e("Not selected")
							}),
							/* @__PURE__ */ (0, R.jsx)("th", {
								className: "text-end",
								children: e("Difference")
							})
						] }) }), /* @__PURE__ */ (0, R.jsx)("tbody", { children: (r.rows ?? []).map((e) => /* @__PURE__ */ (0, R.jsxs)("tr", { children: [
							/* @__PURE__ */ (0, R.jsx)("td", { children: e.indicator }),
							/* @__PURE__ */ (0, R.jsx)("td", {
								className: "text-end",
								children: e.selected
							}),
							/* @__PURE__ */ (0, R.jsx)("td", {
								className: "text-end",
								children: e.not_selected
							}),
							/* @__PURE__ */ (0, R.jsx)("td", {
								className: `text-end${e.notable ? " tw-sel-notable" : ""}`,
								children: e.difference
							})
						] }, e.indicator)) })]
					})
				}), /* @__PURE__ */ (0, R.jsx)("div", {
					className: "small text-muted mt-2",
					children: e("Means for numbers, shares for categories. Bold: a gap of 10 points or 20% or more, where the selection tells the groups apart.")
				})] }) : null
			}),
			i && /* @__PURE__ */ (0, R.jsxs)("div", {
				className: i.profiles ? "tw-sel-grid2" : void 0,
				children: [/* @__PURE__ */ (0, R.jsx)(H, {
					title: e("Share selected by number of deprivations"),
					icon: /* @__PURE__ */ (0, R.jsx)(cr, { size: 15 }),
					full: !0,
					help: o("Deprivations: the ranking's criteria a household meets in the vulnerable direction. The selection should rise with them."),
					children: /* @__PURE__ */ (0, R.jsx)(U, { id: Q("rank_dep_plot") })
				}), i.profiles && /* @__PURE__ */ (0, R.jsx)(H, {
					title: e("Selected households by ranking profile"),
					icon: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 15 }),
					full: !0,
					help: o("Each registration household joins the ranking profile closest to its answers. The targeted profiles (marked) should be selected most."),
					children: /* @__PURE__ */ (0, R.jsx)(U, { id: Q("rank_prof_plot") })
				})]
			})
		]
	});
}
function c_({ t: e }) {
	return /* @__PURE__ */ (0, R.jsx)(H, {
		title: e("Selected beneficiaries"),
		icon: /* @__PURE__ */ (0, R.jsx)(Ea, { size: 15 }),
		full: !0,
		className: "mt-3",
		actions: /* @__PURE__ */ (0, R.jsxs)("button", {
			type: "button",
			className: "btn btn-outline-primary btn-sm",
			onClick: () => document.getElementById(Q("export_open"))?.click(),
			children: [
				/* @__PURE__ */ (0, R.jsx)(En, { size: 14 }),
				" ",
				e("Download the list (Excel)")
			]
		}),
		children: /* @__PURE__ */ (0, R.jsx)(zf, { id: Q("ben_table") })
	});
}
//#endregion
//#region src/pages/selection/index.tsx
var l_ = /* @__PURE__ */ n({
	default: () => e_,
	page: () => u_
}), u_ = "ben_panel";
//#endregion
//#region src/pages/spot/SpotPage.tsx
k();
var $ = (e) => `spot_checking_1-${e}`;
function d_({ active: e, t }) {
	let n = D(null);
	E(() => {
		e && Bf(n.current, !0);
	}, [e]);
	let r = L($("sc_kpis")), i = I($("sc_admin1")), a = I($("sc_admin2")), o = I($("sc_admin3")), s = I($("sc_search")), c = [
		i,
		a,
		o
	].flatMap((e) => e ?? []), l = /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(Hf, { steps: [{
		key: "areas",
		title: t("1. Areas"),
		icon: /* @__PURE__ */ (0, R.jsx)(Er, { size: 15 }),
		summary: c.length ? c.slice(0, 3).join(", ") + (c.length > 3 ? ` +${c.length - 3}` : "") : t("All areas"),
		content: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: $("sc_admin1"),
				label: t("Admin 1"),
				multiple: !0,
				actions: !0,
				placeholder: t("All")
			}),
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: $("sc_admin2"),
				label: t("Admin 2"),
				multiple: !0,
				actions: !0,
				placeholder: t("All")
			}),
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: $("sc_admin3"),
				label: t("Admin 3"),
				multiple: !0,
				actions: !0,
				placeholder: t("All")
			})
		] })
	}, {
		key: "search",
		title: t("2. Search"),
		icon: /* @__PURE__ */ (0, R.jsx)(gi, { size: 15 }),
		summary: s ? `"${s}"` : t("None"),
		content: /* @__PURE__ */ (0, R.jsx)(hf, {
			id: $("sc_search"),
			placeholder: t("e.g. household ID"),
			help: t("Keeps the households where any column holds this text.")
		})
	}] }), /* @__PURE__ */ (0, R.jsxs)(Uf, { children: [
		/* @__PURE__ */ (0, R.jsxs)("div", {
			className: "d-flex gap-2",
			children: [/* @__PURE__ */ (0, R.jsx)(B, {
				id: $("sc_apply"),
				label: t("Apply"),
				icon: /* @__PURE__ */ (0, R.jsx)(Rn, { size: 14 }),
				className: "flex-fill"
			}), /* @__PURE__ */ (0, R.jsx)(B, {
				id: $("sc_clear"),
				icon: /* @__PURE__ */ (0, R.jsx)(Ma, { size: 14 }),
				variant: "outline-secondary",
				title: t("Clear the filters")
			})]
		}),
		/* @__PURE__ */ (0, R.jsx)("div", {
			className: "tw-spot-group",
			children: t("Back-check results")
		}),
		/* @__PURE__ */ (0, R.jsx)(bf, {
			id: $("verif_report"),
			label: t("Verification report (HTML)"),
			icon: /* @__PURE__ */ (0, R.jsx)(On, { size: 14 }),
			className: "w-100"
		}),
		/* @__PURE__ */ (0, R.jsx)(bf, {
			id: $("verif_download"),
			label: t("Comparison (Excel)"),
			icon: /* @__PURE__ */ (0, R.jsx)(En, { size: 14 }),
			variant: "outline-secondary",
			className: "w-100"
		})
	] })] });
	return /* @__PURE__ */ (0, R.jsx)("div", {
		ref: n,
		className: "h-100",
		children: /* @__PURE__ */ (0, R.jsxs)(Vf, {
			sidebar: l,
			className: "tw-spot",
			children: [
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-spot-kpis",
					children: [
						/* @__PURE__ */ (0, R.jsx)(f_, {
							icon: /* @__PURE__ */ (0, R.jsx)(fn, { size: 16 }),
							label: t("Households in scope"),
							value: r?.pool,
							sub: r?.remote ? t("with a valid phone number") : t("after the area and search filters")
						}),
						/* @__PURE__ */ (0, R.jsx)(f_, {
							icon: /* @__PURE__ */ (0, R.jsx)(xt, { size: 16 }),
							label: t("Share sampled"),
							value: r?.share,
							tone: "info"
						}),
						/* @__PURE__ */ (0, R.jsx)(f_, {
							icon: /* @__PURE__ */ (0, R.jsx)(vr, { size: 16 }),
							label: t("Sample size"),
							value: r?.sample,
							tone: "neutral",
							sub: r?.sample ? void 0 : t("Draw the spot-check sample first.")
						}),
						/* @__PURE__ */ (0, R.jsx)(f_, {
							icon: /* @__PURE__ */ (0, R.jsx)(Lt, { size: 16 }),
							label: t("Back-check agreement"),
							value: r?.agreement,
							tone: "success",
							sub: r?.agreement ? void 0 : t("after the comparison")
						})
					]
				}),
				r?.remote && (r.phone_col ? /* @__PURE__ */ (0, R.jsxs)(Jf, { children: [
					t("Remote check"),
					": ",
					r.reachable ?? "?",
					" ",
					t("of"),
					" ",
					r.in_scope ?? "?",
					" ",
					t("households in scope have a valid phone number in"),
					" ",
					/* @__PURE__ */ (0, R.jsx)("b", { children: r.phone_col }),
					"."
				] }) : /* @__PURE__ */ (0, R.jsx)(Jf, {
					kind: "warning",
					children: t("Remote check: choose the column holding the phone numbers, then draw the sample.")
				})),
				/* @__PURE__ */ (0, R.jsx)(Wf, {
					id: $("sc_tabs"),
					tabs: [{
						value: "sample",
						label: t("1. Sample for checking"),
						icon: /* @__PURE__ */ (0, R.jsx)(gr, { size: 15 }),
						content: /* @__PURE__ */ (0, R.jsx)(p_, { t })
					}, {
						value: "verify",
						label: t("2. Verification"),
						icon: /* @__PURE__ */ (0, R.jsx)(Yt, { size: 15 }),
						content: /* @__PURE__ */ (0, R.jsx)(m_, { t })
					}]
				})
			]
		})
	});
}
function f_({ icon: e, label: t, value: n, sub: r, tone: i = "primary" }) {
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: `tw-spot-kpi tone-${i}`,
		children: [/* @__PURE__ */ (0, R.jsx)("span", {
			className: "tw-spot-kpi-icon",
			children: e
		}), /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "min-w-0",
			children: [
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-spot-kpi-label",
					children: t
				}),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-spot-kpi-value",
					children: n ?? "—"
				}),
				r ? /* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-spot-kpi-sub",
					children: r
				}) : null
			]
		})]
	});
}
function p_({ t: e }) {
	let t = I($("sc_mode")) ?? "face";
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)("div", {
		className: `tw-spot-band tw-align tw-align-bottom${t === "remote" ? " has-help" : ""}`,
		children: [
			/* @__PURE__ */ (0, R.jsx)(_f, {
				id: $("sc_mode"),
				label: e("Interview mode"),
				buttons: !0,
				value: "face",
				choices: [{
					value: "face",
					label: e("Face to face")
				}, {
					value: "remote",
					label: e("Remote (phone)")
				}]
			}),
			/* @__PURE__ */ (0, R.jsx)("div", {
				style: { display: t === "remote" ? void 0 : "none" },
				className: "tw-spot-band-wide",
				children: /* @__PURE__ */ (0, R.jsx)(z, {
					id: $("sc_phone_col"),
					label: e("Phone column"),
					clearable: !1,
					help: e("Only households with a valid phone number are sampled.")
				})
			}),
			/* @__PURE__ */ (0, R.jsx)(mf, {
				id: $("sc_sample_size"),
				label: e("Sample size"),
				value: 30,
				min: 1,
				max: 1e5,
				step: 1,
				className: "tw-spot-band-num"
			}),
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: $("sc_per_unit"),
				label: e("Applies to"),
				value: "all",
				clearable: !1,
				className: "tw-spot-band-wide",
				choices: [
					{
						value: "all",
						label: e("The whole scope")
					},
					{
						value: "admin1",
						label: e("Each Admin 1")
					},
					{
						value: "admin2",
						label: e("Each Admin 2")
					},
					{
						value: "admin3",
						label: e("Each Admin 3")
					},
					{
						value: "village",
						label: e("Each village")
					}
				]
			}),
			/* @__PURE__ */ (0, R.jsx)(z, {
				id: $("sc_sample_method"),
				label: e("Method"),
				value: "random",
				clearable: !1,
				className: "tw-spot-band-wide",
				choices: [
					{
						value: "random",
						label: e("Simple Random")
					},
					{
						value: "systematic",
						label: e("Systematic")
					},
					{
						value: "pps",
						label: e("PPS (size = hh size or weight)")
					}
				]
			}),
			/* @__PURE__ */ (0, R.jsx)(mf, {
				id: $("sc_seed"),
				label: e("Seed"),
				value: 12345,
				min: 1,
				step: 1,
				className: "tw-spot-band-num"
			}),
			/* @__PURE__ */ (0, R.jsx)("div", {
				className: "tw-spot-band-go",
				children: /* @__PURE__ */ (0, R.jsx)(B, {
					id: $("sc_draw"),
					label: e("Draw sample"),
					icon: /* @__PURE__ */ (0, R.jsx)(Si, { size: 14 }),
					variant: "primary"
				})
			})
		]
	}), /* @__PURE__ */ (0, R.jsxs)(H, {
		full: !0,
		title: e("Sampled households"),
		icon: /* @__PURE__ */ (0, R.jsx)(gr, { size: 15 }),
		actions: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsx)(bf, {
			id: $("download_spot"),
			label: e("Export sample (Excel)"),
			icon: /* @__PURE__ */ (0, R.jsx)(mn, { size: 14 }),
			variant: "outline-secondary"
		}), /* @__PURE__ */ (0, R.jsx)(B, {
			id: $("sc_go_verify"),
			label: e("Continue to verification"),
			icon: /* @__PURE__ */ (0, R.jsx)(qe, { size: 14 })
		})] }),
		children: [/* @__PURE__ */ (0, R.jsx)("p", {
			className: "small text-muted mb-2",
			children: e("Export this list, re-visit these households, then load what the team collected in the Verification tab.")
		}), /* @__PURE__ */ (0, R.jsx)(zf, { id: $("spot_table") })]
	})] });
}
function m_({ t: e }) {
	let t = L($("verif_state")), n = I($("verif_source")) ?? "file";
	return /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [/* @__PURE__ */ (0, R.jsxs)(H, {
		title: e("Back-check comparison"),
		icon: /* @__PURE__ */ (0, R.jsx)(Yt, { size: 15 }),
		children: [
			/* @__PURE__ */ (0, R.jsx)("p", {
				className: "small text-muted",
				children: e("Export the sample, re-collect those households, then load the results here to measure how far the two rounds agree.")
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "tw-spot-vc",
				children: [/* @__PURE__ */ (0, R.jsxs)("section", { children: [
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-spot-vc-head",
						children: [/* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-spot-num",
							children: "1"
						}), e("Verification data")]
					}),
					/* @__PURE__ */ (0, R.jsx)(_f, {
						id: $("verif_source"),
						buttons: !0,
						value: "file",
						choices: [{
							value: "file",
							label: e("File")
						}, {
							value: "moda",
							label: e("MODA form")
						}]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						style: { display: n === "file" ? void 0 : "none" },
						children: /* @__PURE__ */ (0, R.jsx)(xf, {
							id: $("verif_file_ui"),
							className: "tw-spot-file"
						})
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						style: { display: n === "moda" ? void 0 : "none" },
						className: "tw-spot-moda tw-align tw-align-bottom",
						children: [
							/* @__PURE__ */ (0, R.jsx)(hf, {
								id: $("verif_form_id"),
								label: e("Form ID"),
								placeholder: e("e.g. 123456")
							}),
							/* @__PURE__ */ (0, R.jsx)(hf, {
								id: $("verif_token"),
								label: e("API key"),
								password: !0
							}),
							/* @__PURE__ */ (0, R.jsx)("div", {
								className: "tw-spot-moda-go",
								children: /* @__PURE__ */ (0, R.jsx)(B, {
									id: $("verif_fetch"),
									label: e("Fetch"),
									icon: /* @__PURE__ */ (0, R.jsx)(tn, { size: 14 })
								})
							})
						]
					}),
					/* @__PURE__ */ (0, R.jsx)(up, {
						ns: $("verif_summary"),
						className: "mt-2",
						t: e
					}),
					t?.loaded && /* @__PURE__ */ (0, R.jsxs)("div", {
						className: `small d-flex align-items-center gap-1 ${t.shared ? "text-success" : "text-danger"}`,
						children: [
							t.shared ? /* @__PURE__ */ (0, R.jsx)(Lt, { size: 14 }) : /* @__PURE__ */ (0, R.jsx)(na, { size: 14 }),
							t.n,
							" ",
							e("records loaded"),
							t.source ? ` (${t.source})` : "",
							"; ",
							t.shared,
							" ",
							t.shared === 1 ? e("column in common with the sample") : e("columns in common with the sample"),
							"."
						]
					})
				] }), /* @__PURE__ */ (0, R.jsxs)("section", { children: [
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-spot-vc-head",
						children: [/* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-spot-num",
							children: "2"
						}), e("Comparison")]
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "tw-spot-cmp tw-align",
						children: [
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: $("verif_key"),
								label: e("Match records on"),
								clearable: !1
							}),
							/* @__PURE__ */ (0, R.jsx)(z, {
								id: $("verif_cols"),
								label: e("Fields to compare"),
								multiple: !0,
								actions: !0,
								placeholder: e("Nothing selected")
							}),
							/* @__PURE__ */ (0, R.jsx)(mf, {
								id: $("verif_tolerance"),
								label: e("Tolerance"),
								value: 0,
								min: 0,
								step: .1,
								help: e("Numeric answers closer than this count as agreeing.")
							})
						]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "d-flex justify-content-end tw-align mt-2",
						children: /* @__PURE__ */ (0, R.jsx)(B, {
							id: $("verif_run"),
							label: e("Run comparison"),
							icon: /* @__PURE__ */ (0, R.jsx)(Hn, { size: 14 }),
							variant: "primary"
						})
					})
				] })]
			}),
			t?.loaded ? t.compared ? null : /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("Ready to compare"),
				sub: e("Confirm the matching key and the fields to compare, then click Run comparison.")
			}) : /* @__PURE__ */ (0, R.jsx)(Y, {
				title: e("No verification data yet"),
				sub: e("Upload the re-collected dataset, or fetch the verification form from MODA, then run the comparison.")
			})
		]
	}), t?.compared && t.kpis && /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
		/* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-spot-kpis",
			children: [
				/* @__PURE__ */ (0, R.jsx)(f_, {
					icon: /* @__PURE__ */ (0, R.jsx)(fr, { size: 16 }),
					label: e("Matched records"),
					value: t.kpis.matched,
					sub: `${e("on")} ${t.kpis.key}`
				}),
				/* @__PURE__ */ (0, R.jsx)(f_, {
					icon: /* @__PURE__ */ (0, R.jsx)(Lt, { size: 16 }),
					label: e("Overall agreement"),
					value: t.kpis.agreement,
					tone: "success",
					sub: `${t.kpis.fields} ${e("fields compared")}`
				}),
				/* @__PURE__ */ (0, R.jsx)(f_, {
					icon: /* @__PURE__ */ (0, R.jsx)(na, { size: 16 }),
					label: e("Records with a discordance"),
					value: t.kpis.discordant,
					tone: "warning"
				}),
				/* @__PURE__ */ (0, R.jsx)(f_, {
					icon: /* @__PURE__ */ (0, R.jsx)(Ut, { size: 16 }),
					label: e("Unmatched"),
					value: t.kpis.unmatched,
					tone: "neutral",
					sub: `${t.kpis.only_original} ${e("not re-visited")}, ${t.kpis.only_verification} ${e("not in the sample")}`
				})
			]
		}),
		/* @__PURE__ */ (0, R.jsxs)("div", {
			className: "tw-grid-2",
			children: [/* @__PURE__ */ (0, R.jsx)(H, {
				full: !0,
				title: e("Agreement by field"),
				help: /* @__PURE__ */ (0, R.jsx)(h_, { t: e }),
				children: /* @__PURE__ */ (0, R.jsx)(U, { id: $("verif_plot") })
			}), /* @__PURE__ */ (0, R.jsx)(H, {
				full: !0,
				title: e("Field summary"),
				children: /* @__PURE__ */ (0, R.jsx)(zf, {
					id: $("verif_field_table"),
					compact: !0
				})
			})]
		}),
		/* @__PURE__ */ (0, R.jsx)(H, {
			full: !0,
			title: e("Discordances"),
			children: /* @__PURE__ */ (0, R.jsx)(zf, {
				id: $("verif_disc_table"),
				compact: !0
			})
		})
	] })] });
}
function h_({ t: e }) {
	return /* @__PURE__ */ (0, R.jsxs)("span", {
		className: "tw-spot-legend",
		children: [
			/* @__PURE__ */ (0, R.jsx)("i", { style: { background: "#3f7e44" } }),
			"95%+ ",
			/* @__PURE__ */ (0, R.jsx)("i", { style: { background: "#f7b825" } }),
			"90-95% ",
			/* @__PURE__ */ (0, R.jsx)("i", { style: { background: "#c5192d" } }),
			e("below 90%")
		]
	});
}
//#endregion
//#region src/pages/spot/index.tsx
var g_ = /* @__PURE__ */ n({
	default: () => d_,
	page: () => __
}), __ = "spot_panel";
//#endregion
//#region src/pages/welcome/WelcomePage.tsx
function v_({ n: e, title: t, dataset: n, body: r, icon: i, action: a }) {
	return /* @__PURE__ */ (0, R.jsx)("div", {
		className: "card tw-card tw-wl-phase wfp-lift",
		children: /* @__PURE__ */ (0, R.jsxs)("div", {
			className: "card-body",
			children: [
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "tw-wl-phase-head",
					children: [
						/* @__PURE__ */ (0, R.jsx)("span", {
							className: "wfp-phase-number",
							children: e
						}),
						/* @__PURE__ */ (0, R.jsx)("span", {
							className: "tw-wl-phase-icon",
							children: i
						}),
						/* @__PURE__ */ (0, R.jsx)("h3", { children: t })
					]
				}),
				/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "wfp-phase-dataset",
					children: [
						/* @__PURE__ */ (0, R.jsx)(fn, {
							size: 12,
							"aria-hidden": !0
						}),
						" ",
						n
					]
				}),
				/* @__PURE__ */ (0, R.jsx)("p", { children: r }),
				/* @__PURE__ */ (0, R.jsx)("div", {
					className: "tw-wl-phase-action",
					children: a
				})
			]
		})
	});
}
function y_({ t: e }) {
	let t = L("welcome_meta"), n = (t, n, r) => /* @__PURE__ */ (0, R.jsx)(B, {
		id: t,
		label: /* @__PURE__ */ (0, R.jsxs)(R.Fragment, { children: [
			e(n),
			" ",
			/* @__PURE__ */ (0, R.jsx)(qe, { size: 14 })
		] }),
		variant: r,
		size: "md",
		className: "w-100"
	});
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "wfp-welcome tw-wl",
		children: [
			/* @__PURE__ */ (0, R.jsxs)("header", {
				className: "wfp-hero text-center",
				children: [
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "wfp-eyebrow",
						children: e("WFP Vulnerability Analysis and Mapping")
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "wfp-hero-brand",
						children: [
							/* @__PURE__ */ (0, R.jsx)("img", {
								src: "www/wfp-logo-standard-white-en.png",
								alt: "World Food Programme",
								className: "wfp-hero-logo"
							}),
							/* @__PURE__ */ (0, R.jsx)("span", { className: "wfp-hero-divider" }),
							/* @__PURE__ */ (0, R.jsx)("h1", { children: "TargetWise" })
						]
					}),
					/* @__PURE__ */ (0, R.jsx)("div", {
						className: "wfp-hero-tagline",
						children: /* @__PURE__ */ (0, R.jsx)("span", { children: e("Reaching the most vulnerable") })
					}),
					/* @__PURE__ */ (0, R.jsx)("div", { className: "wfp-hero-rule" }),
					/* @__PURE__ */ (0, R.jsx)("p", {
						className: "wfp-hero-lead",
						children: e("A workflow for designing, applying and checking humanitarian targeting: build an evidence-based scorecard from assessment data, use it to select beneficiaries from registration data, then measure what actually reached households.")
					})
				]
			}),
			/* @__PURE__ */ (0, R.jsxs)("section", {
				className: "tw-wl-phases",
				"aria-label": e("The three phases"),
				children: [
					/* @__PURE__ */ (0, R.jsx)(v_, {
						n: "1",
						title: e("Targeting Design"),
						dataset: e("Needs-assessment data"),
						icon: /* @__PURE__ */ (0, R.jsx)(ui, { size: 18 }),
						body: e("Screen candidate eligibility criteria against a food-security outcome, fit a scorecard, and see the inclusion and exclusion errors your design would produce before anyone is served."),
						action: n("go_design", "Start a targeting design", "primary")
					}),
					/* @__PURE__ */ (0, R.jsx)(v_, {
						n: "2",
						title: e("Beneficiary Selection"),
						dataset: e("Household registration data"),
						icon: /* @__PURE__ */ (0, R.jsx)(ma, { size: 18 }),
						body: e("Load and clean the registration data, spot-check it against field verification, then apply the scorecard and your eligibility rules to produce the beneficiary list."),
						action: n("go_import", "Load registration data", "outline-primary")
					}),
					/* @__PURE__ */ (0, R.jsx)(v_, {
						n: "3",
						title: e("Targeting Monitoring"),
						dataset: e("Post-distribution monitoring data"),
						icon: /* @__PURE__ */ (0, R.jsx)(Wi, { size: 18 }),
						body: e("Compare who was eligible with who actually received assistance, and measure the errors introduced during implementation rather than in the design."),
						action: n("go_monitor", "Open monitoring", "outline-primary")
					})
				]
			}),
			/* @__PURE__ */ (0, R.jsxs)("section", {
				className: "tw-wl-row",
				children: [/* @__PURE__ */ (0, R.jsxs)("div", {
					className: "card tw-card",
					children: [/* @__PURE__ */ (0, R.jsx)("div", {
						className: "card-header",
						children: /* @__PURE__ */ (0, R.jsxs)("span", {
							className: "tw-card-title",
							children: [
								/* @__PURE__ */ (0, R.jsx)(Oi, { size: 15 }),
								" ",
								e("Where to start")
							]
						})
					}), /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "card-body",
						children: [/* @__PURE__ */ (0, R.jsxs)("ol", {
							className: "tw-wl-steps",
							children: [
								/* @__PURE__ */ (0, R.jsx)("li", { children: e("Designing a new targeting approach? Start with Targeting Design and load your assessment extract there.") }),
								/* @__PURE__ */ (0, R.jsx)("li", { children: e("Already have a design and need the beneficiary list? Go to Beneficiary Selection and load the registration data.") }),
								/* @__PURE__ */ (0, R.jsx)("li", { children: e("Checking a completed distribution? Go to Targeting Monitoring and load the PDM extract.") })
							]
						}), /* @__PURE__ */ (0, R.jsxs)("div", {
							className: "tw-wl-note",
							children: [
								/* @__PURE__ */ (0, R.jsx)(ir, {
									size: 14,
									"aria-hidden": !0
								}),
								" ",
								e("Each phase loads its own dataset. Nothing you load in one phase overwrites another.")
							]
						})]
					})]
				}), /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "card tw-card",
					children: [/* @__PURE__ */ (0, R.jsx)("div", {
						className: "card-header",
						children: /* @__PURE__ */ (0, R.jsxs)("span", {
							className: "tw-card-title",
							children: [
								/* @__PURE__ */ (0, R.jsx)(rt, { size: 15 }),
								" ",
								e("Methodological basis")
							]
						})
					}), /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "card-body",
						children: [/* @__PURE__ */ (0, R.jsx)("div", {
							className: "tw-wl-label",
							children: e("WFP VAM Needs Assessment and Targeting Unit")
						}), /* @__PURE__ */ (0, R.jsxs)("ul", {
							className: "tw-wl-refs",
							children: [
								/* @__PURE__ */ (0, R.jsxs)("li", { children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: "WFP (2021)" }), /* @__PURE__ */ (0, R.jsx)("span", { children: e("Targeting and Prioritization Operational Guidance Note") })] }),
								/* @__PURE__ */ (0, R.jsxs)("li", { children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: "Advisory 1/2025" }), /* @__PURE__ */ (0, R.jsx)("span", { children: e("Concerns regarding the use of outcome indicators during the targeting process") })] }),
								/* @__PURE__ */ (0, R.jsxs)("li", { children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: "Advisory 2/2025" }), /* @__PURE__ */ (0, R.jsx)("span", { children: e("Methodological note on targeting errors measurement") })] }),
								/* @__PURE__ */ (0, R.jsxs)("li", { children: [/* @__PURE__ */ (0, R.jsx)("strong", { children: "Advisory 3/2025" }), /* @__PURE__ */ (0, R.jsx)("span", { children: e("Using ROC curves for targeting analysis") })] })
							]
						})]
					})]
				})]
			}),
			/* @__PURE__ */ (0, R.jsx)("footer", {
				className: "card tw-card wfp-credits",
				children: /* @__PURE__ */ (0, R.jsxs)("div", {
					className: "card-body tw-wl-about",
					children: [/* @__PURE__ */ (0, R.jsxs)("div", { children: [/* @__PURE__ */ (0, R.jsx)("div", {
						className: "tw-wl-label",
						children: e("About")
					}), /* @__PURE__ */ (0, R.jsxs)("div", {
						className: "small",
						children: [e("Open-source R package for humanitarian targeting: design on assessment data, beneficiary selection on registration data, and monitoring on PDM data. "), e("Documentation, how to cite and how to report an issue are in the README distributed with the package.")]
					})] }), /* @__PURE__ */ (0, R.jsxs)("div", { children: [/* @__PURE__ */ (0, R.jsx)("div", {
						className: "tw-wl-label",
						children: e("Release")
					}), /* @__PURE__ */ (0, R.jsxs)("dl", {
						className: "tw-wl-release small",
						children: [
							/* @__PURE__ */ (0, R.jsx)("dt", { children: e("Version") }),
							/* @__PURE__ */ (0, R.jsx)("dd", { children: t?.version ?? "…" }),
							/* @__PURE__ */ (0, R.jsx)("dt", { children: e("Licence") }),
							/* @__PURE__ */ (0, R.jsx)("dd", { children: "GPL (>= 3)" }),
							/* @__PURE__ */ (0, R.jsx)("dt", { children: e("Built with") }),
							/* @__PURE__ */ (0, R.jsx)("dd", { children: "R, Shiny, React" })
						]
					})] })]
				})
			})
		]
	});
}
//#endregion
//#region src/pages/welcome/index.tsx
var b_ = /* @__PURE__ */ n({
	default: () => y_,
	page: () => x_
}), x_ = "welcome_panel";
//#endregion
//#region src/i18n.ts
k();
var S_ = null;
function C_() {
	return S_ ||= fetch("www/translations.json").then((e) => e.ok ? e.json() : { translation: [] }).then((e) => {
		let t = {};
		for (let n of e.translation ?? []) for (let [e, r] of Object.entries(n)) e !== "en" && ((t[e] ??= {})[n.en] = r);
		return t;
	}).catch(() => ({})), S_;
}
function w_(e) {
	let [t, n] = O({});
	return E(() => {
		let t = !0;
		return C_().then((r) => t && n(e === "en" ? {} : r[e] ?? {})), () => {
			t = !1;
		};
	}, [e]), (e) => t[e] ?? e;
}
//#endregion
//#region src/components/SessionToolbar.tsx
function T_({ ns: e = "session_manager_1", t = (e) => e }) {
	let n = (t) => `${e}-${t}`, r = L(n("toolbar")), i = (e) => /* @__PURE__ */ (0, R.jsx)("span", {
		className: "action-label",
		children: t(e)
	});
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "session-toolbar d-flex align-items-center gap-2",
		children: [
			/* @__PURE__ */ (0, R.jsx)("span", {
				style: { fontSize: 15 },
				children: t("Session")
			}),
			/* @__PURE__ */ (0, R.jsxs)("div", {
				className: "btn-group",
				role: "group",
				"aria-label": t("Session controls"),
				children: [
					r?.moda ? /* @__PURE__ */ (0, R.jsx)(B, {
						id: n("btn_sync_moda"),
						label: i("Refresh MODA"),
						icon: /* @__PURE__ */ (0, R.jsx)(ei, { size: 13 }),
						title: t("Fetch only the MODA submissions that are not in this session yet")
					}) : null,
					/* @__PURE__ */ (0, R.jsx)(B, {
						id: n("btn_save_session"),
						label: i("Save"),
						icon: /* @__PURE__ */ (0, R.jsx)(ci, { size: 13 }),
						title: t("Save session")
					}),
					/* @__PURE__ */ (0, R.jsx)(B, {
						id: n("btn_new_session"),
						label: i("New"),
						icon: /* @__PURE__ */ (0, R.jsx)(wn, { size: 13 }),
						title: t("Save this session and start a fresh one")
					}),
					/* @__PURE__ */ (0, R.jsx)(B, {
						id: n("btn_load_session"),
						label: i("Load"),
						icon: /* @__PURE__ */ (0, R.jsx)(In, { size: 13 }),
						title: t("Load a saved session")
					}),
					/* @__PURE__ */ (0, R.jsx)(B, {
						id: n("btn_clear_session"),
						label: i("Clear"),
						icon: /* @__PURE__ */ (0, R.jsx)(ea, { size: 13 }),
						title: t("Delete saved sessions")
					})
				]
			}),
			/* @__PURE__ */ (0, R.jsx)(xf, {
				id: n("restore_modal_container"),
				inline: !0
			})
		]
	});
}
//#endregion
//#region src/App.tsx
k();
var E_ = [
	{
		value: "welcome_panel",
		label: "Welcome",
		Icon: er
	},
	{
		value: "scorecard_panel",
		label: "1. Targeting Design",
		Icon: ui
	},
	{
		menu: "selection",
		value: "selection_menu",
		label: "2. Beneficiary Selection",
		Icon: ma,
		pages: [
			{
				value: "import_panel",
				label: "Load registration data",
				Icon: fa
			},
			{
				value: "overview_panel",
				label: "Overview",
				Icon: Or
			},
			{
				value: "dq_panel",
				label: "Data Quality",
				Icon: Yt
			},
			{
				value: "spot_panel",
				label: "Spot Checking",
				Icon: fi
			},
			{
				value: "ben_panel",
				label: "Selection",
				Icon: Gt
			}
		]
	},
	{
		value: "pdm_panel",
		label: "3. Targeting Monitoring",
		Icon: Wi
	},
	{
		value: "modif_logs",
		label: "Audit Trail",
		Icon: ni
	}
], D_ = E_.flatMap((e) => "pages" in e ? e.pages : [e]), O_ = Object.fromEntries(Object.values([
	$f,
	mh,
	Hh,
	Xh,
	xg,
	Xg,
	l_,
	g_,
	b_
]).map((e) => [e.page, e.default]));
function k_() {
	let [e, t] = Kd("main_nav", "welcome_panel", { debounceMs: 0 }), [n, r] = Kd("lang_selector", "en", { debounceMs: 0 }), [i, a] = Kd("dark_mode", "light", { debounceMs: 0 }), [o, s] = O([
		"overview_panel",
		"dq_panel",
		"spot_panel",
		"ben_panel"
	]);
	Xd("tw-nav-state", (e) => s(e.hidden ?? []));
	let c = new Set(o), l = Zd(), u = qd("tw_client_ready", 0, { debounceMs: 0 });
	Kd("tw_ported", Object.keys(O_), { debounceMs: 0 }), E(() => {
		if (!l) return;
		let e = window.setTimeout(() => u(Date.now()), 50);
		return () => window.clearTimeout(e);
	}, [l]);
	let [d, f] = O(!1), p = w_(n);
	Xd("tw-nav", (e) => {
		e.action === "select" && e.target.length && t(e.target[0]);
	}), E(() => {
		document.documentElement.setAttribute("data-bs-theme", i);
	}, [i]);
	let m = D(null);
	E(() => {
		let e = (e) => {
			m.current && !m.current.contains(e.target) && f(!1);
		};
		return document.addEventListener("click", e), () => document.removeEventListener("click", e);
	}, []);
	let h = (e) => {
		t(e), f(!1);
	}, g = (t) => "pages" in t && t.pages.some((t) => t.value === e);
	return /* @__PURE__ */ (0, R.jsxs)("div", {
		className: "tw-app",
		children: [/* @__PURE__ */ (0, R.jsx)("nav", {
			className: "navbar navbar-expand navbar-dark bg-primary tw-navbar",
			"data-bs-theme": "dark",
			children: /* @__PURE__ */ (0, R.jsxs)("div", {
				className: "container-fluid",
				children: [
					/* @__PURE__ */ (0, R.jsxs)("span", {
						className: "navbar-brand",
						children: [
							/* @__PURE__ */ (0, R.jsx)("img", {
								src: "www/wfp-logo-standard-white-en.png",
								height: 35,
								style: { marginTop: -5 },
								alt: "WFP"
							}),
							/* @__PURE__ */ (0, R.jsx)("span", { className: "brand-divider" }),
							/* @__PURE__ */ (0, R.jsx)("span", {
								className: "brand-text",
								children: "TargetWise"
							})
						]
					}),
					/* @__PURE__ */ (0, R.jsx)("ul", {
						className: "navbar-nav nav me-auto",
						children: E_.map((t) => "pages" in t ? /* @__PURE__ */ (0, R.jsxs)("li", {
							ref: m,
							className: "nav-item dropdown" + (d ? " show" : ""),
							children: [/* @__PURE__ */ (0, R.jsxs)("a", {
								href: "#",
								role: "button",
								className: "nav-link dropdown-toggle" + (g(t) ? " active" : ""),
								onClick: (e) => {
									e.preventDefault(), f(!d);
								},
								children: [
									/* @__PURE__ */ (0, R.jsx)(t.Icon, { size: 15 }),
									" ",
									p(t.label)
								]
							}), /* @__PURE__ */ (0, R.jsx)("ul", {
								className: "dropdown-menu" + (d ? " show" : ""),
								children: t.pages.filter((e) => !c.has(e.value)).map((t) => /* @__PURE__ */ (0, R.jsx)("li", { children: /* @__PURE__ */ (0, R.jsxs)("a", {
									href: "#",
									"data-value": t.value,
									className: "dropdown-item" + (t.value === e ? " active" : ""),
									onClick: (e) => {
										e.preventDefault(), h(t.value);
									},
									children: [
										/* @__PURE__ */ (0, R.jsx)(t.Icon, { size: 15 }),
										" ",
										p(t.label)
									]
								}) }, t.value))
							})]
						}, t.value) : c.has(t.value) ? null : /* @__PURE__ */ (0, R.jsx)("li", {
							className: "nav-item",
							children: /* @__PURE__ */ (0, R.jsxs)("a", {
								href: "#",
								"data-value": t.value,
								className: "nav-link" + (t.value === e ? " active" : ""),
								onClick: (e) => {
									e.preventDefault(), h(t.value);
								},
								children: [
									/* @__PURE__ */ (0, R.jsx)(t.Icon, { size: 15 }),
									" ",
									p(t.label)
								]
							})
						}, t.value))
					}),
					/* @__PURE__ */ (0, R.jsxs)("div", {
						className: "d-flex align-items-center gap-3 tw-nav-right",
						children: [
							/* @__PURE__ */ (0, R.jsx)($d, {
								id: "co_badge",
								tagName: "span",
								className: "shiny-html-output"
							}),
							/* @__PURE__ */ (0, R.jsxs)("div", {
								className: "mini-theme-selector",
								children: [/* @__PURE__ */ (0, R.jsx)("span", { children: p("Language") }), /* @__PURE__ */ (0, R.jsxs)("select", {
									className: "form-select form-select-sm",
									value: n,
									onChange: (e) => r(e.target.value),
									"aria-label": "Language",
									children: [/* @__PURE__ */ (0, R.jsx)("option", {
										value: "en",
										children: "English"
									}), /* @__PURE__ */ (0, R.jsx)("option", {
										value: "fr",
										children: "Français"
									})]
								})]
							}),
							/* @__PURE__ */ (0, R.jsx)(T_, { t: p }),
							/* @__PURE__ */ (0, R.jsx)("button", {
								type: "button",
								className: "btn btn-sm tw-mode-btn",
								onClick: () => a(i === "dark" ? "light" : "dark"),
								title: i === "dark" ? "Light mode" : "Dark mode",
								"aria-label": "Switch light and dark mode",
								children: i === "dark" ? /* @__PURE__ */ (0, R.jsx)(Ii, { size: 18 }) : /* @__PURE__ */ (0, R.jsx)(Pr, { size: 18 })
							})
						]
					})
				]
			})
		}), /* @__PURE__ */ (0, R.jsx)("main", {
			className: "tw-main",
			children: D_.map((t) => {
				let n = O_[t.value], r = t.value === e;
				return n ? /* @__PURE__ */ (0, R.jsx)(A_, {
					value: t.value,
					active: r,
					children: /* @__PURE__ */ (0, R.jsx)(n, {
						active: r,
						t: p
					})
				}, t.value) : /* @__PURE__ */ (0, R.jsx)(j_, {
					value: t.value,
					active: r
				}, t.value);
			})
		})]
	});
}
function A_({ value: e, active: t, children: n }) {
	let r = D(null);
	return E(() => Bf(r.current, t), [t]), /* @__PURE__ */ (0, R.jsx)("div", {
		ref: r,
		className: "tw-page",
		"data-value": e,
		style: { display: t ? "flex" : "none" },
		children: n
	});
}
function j_({ value: e, active: t }) {
	let n = "pg_" + e;
	return E(() => {
		let e = document.getElementById(n), r = window.jQuery;
		e && r && r(e).trigger(t ? "shown" : "hidden"), t && window.dispatchEvent(new Event("resize"));
	}, [t, n]), /* @__PURE__ */ (0, R.jsx)($d, {
		id: n,
		className: "shiny-html-output tw-page tw-hosted html-fill-container",
		style: { display: t ? "flex" : "none" }
	});
}
//#endregion
//#region src/ui.tsx
var { ReactDOM: M_ } = window.shinyreact;
M_.createRoot(document.body.appendChild(document.createElement("div"))).render(/* @__PURE__ */ (0, R.jsx)(k_, {}));
//#endregion

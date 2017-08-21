; frameadv.h.asm

\ dum locals
CLEAR locals, locals_top
ORG locals
GUARD locals_top

.index skip 1
.rowno skip 1
.colno skip 1
.yindex skip 1
.objid skip 1
.state skip 1
.Ay skip 1
.Dy skip 1
.gateposn skip 1
.gatebot skip 1
.xsave skip 1
.blockxco skip 1
\switches ds 1
\obj1 ds 1
\obj2 ds 1
.blockthr skip 1
\ dend

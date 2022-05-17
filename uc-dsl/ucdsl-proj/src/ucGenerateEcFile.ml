open UcSpecTypedSpecCommon
open UcTypedSpec
open EcParsetree
open UcMessage

(* shorthands ****************************************************************)
let stf = Format.std_formatter (*REMOVE*)

let dl = UcUtils.dummyloc

let dll (l : 'a list) : ('a EcLocation.located) list =
  List.map (fun a -> dl a) l

type qsymbol = EcSymbols.qsymbol

let qs = qsymb_of_symb

let pqs (name : string) = dl (qs name)

let ul = EcLocation.unloc

let ull = EcLocation.unlocs

(*****************************************************************************)

(* strings *******************************************************************)
let __self = "_self"
let __adv = "_adv"
let __st = "_st"
let _init = "init"
let _self_ = "self_"
let _adv_ = "adv_"
let _invoke = "invoke"
let _m = "m"
let __m = "_m"
let _r = "r"
let __r = "_r"
let _parties = "parties"
let _dec = "dec"
let _enc = "enc"
let __x = "_x"
let _envport = "envport"
let _and = "/\\"
let _UC__IF = "UC__IF"
let _option = "option"
let _epdp = "epdp"
let _univ = "univ"
let _addr = "addr"
let _port = "port"
let _msg = "msg"
let _int = "int"
let _unit = "unit"
let _pi = "pi"
let __adv_if_pi = "_adv_if_pi"
let __adv_if_pi_gt0 = "_adv_if_pi_gt0"
let _Dir = "Dir"
let _Adv = "Adv"
let sym_or = "\\/"
let sym_eq = "="
let sym_not = "[!]"
let _None = "None"
let _Some = "Some"
let _UCBasicTypes = "UCBasicTypes"
(*****************************************************************************)

(* UcEcInterface calls *******************************************************)  
let decl_open_theory (name : string) : unit =
  UcEcInterface.process (GthOpen (`Global, false, dl name))

let decl_close_theory (name : string) : unit =
  UcEcInterface.process (GthClose ([], dl name))
  
let decl_operator (pop : poperator) : unit =
  UcEcInterface.process (Goperator pop)

let decl_axiom (pax : paxiom) : unit =
  UcEcInterface.process (Gaxiom pax)
  
let decl_type (ptd : ptydecl) : unit =
  UcEcInterface.process (Gtype [ptd])

let decl_module (pmod : pmodule_def_or_decl) : unit =
  UcEcInterface.process (Gmodule pmod)

let env () = UcEcInterface.env ()
  
let clone (tc : theory_cloning) : unit =
  UcEcInterface.process (GthClone tc)
  
let proof () : unit =
  UcEcInterface.process (Gtactics (`Proof {pm_strict = true}))

let admit () : unit =
  let ptac = 
  {
    pt_core = dl Padmit;
    pt_intros = []
  } in
  UcEcInterface.process (Gtactics (`Actual [ptac]))
  
let qed () : unit =
  UcEcInterface.process (Gsave (dl `Qed))

let proof_admit_qed () : unit =
  proof ();
  admit ();
  qed ()
    
let decl_reduction (red : puserred) : unit =
  UcEcInterface.process (Greduction red)
  
let decl_rewrite (rw : is_local * pqsymbol * pqsymbol list) : unit =
  UcEcInterface.process (Gaddrw rw)
  
let decl_require (threq : threquire) : unit =
  UcEcInterface.process (GthRequire threq)
  
(*****************************************************************************)

(* EcEnv lookups *************************************************************)
let ty_lookup_opt (name : string) : (EcPath.path * EcDecl.tydecl) option =
  let env = env () in
  EcEnv.Ty.lookup_opt (qs name) env
  
let op_lookup_opt (name : string) : (EcPath.path * EcDecl.operator) option =
  let env = env () in
  EcEnv.Op.lookup_opt (qs name) env
  
let ty_lookup (name : string) : (EcPath.path * EcDecl.tydecl) =
  let env = env () in
  EcEnv.Ty.lookup (qs name) env
  
let op_lookup (name : string) : (EcPath.path * EcDecl.operator) =
  let env = env () in
  EcEnv.Op.lookup (qs name) env
  
let mod_lookup (name : string) : 
(EcPath.mpath * (EcModules.module_expr * locality option)) =
  let env = env () in
  EcEnv.Mod.lookup (qs name) env
  
let ax_lookup (name : string) : (EcPath.path * EcDecl.axiom)=
  let env = env () in
  EcEnv.Ax.lookup (qs name) env
(*****************************************************************************)

(* printing ******************************************************************)

let ppe () = EcPrinting.PPEnv.ofenv (env ())

let print_newline (ppf : Format.formatter) : unit =
  Format.fprintf stf "@."; (*REMOVE*)
  Format.fprintf ppf "@."
  
let print_open_theory (ppf : Format.formatter) (name : string) : unit =
  Format.fprintf stf "@[theory %s.@]@." name; (*REMOVE*)
  Format.fprintf ppf "@[theory %s.@]@." name;
  print_newline ppf

let print_close_theory (ppf : Format.formatter) (name : string) : unit =
  Format.fprintf stf "@[end %s.@]@." name; (*REMOVE*)
  Format.fprintf ppf "@[end %s.@]@." name;
  print_newline ppf
  
let print_operator (ppf : Format.formatter) (pop : poperator) : unit =
  let name = ul pop.po_name in
  let op = op_lookup name in
  let ppe = ppe () in
  EcPrinting.pp_opdecl ppe stf op; (*REMOVE*)
  EcPrinting.pp_opdecl ppe ppf op;
  print_newline ppf;
  print_newline ppf

let print_type (ppf : Format.formatter) (name : string) : unit =
  let ppe = ppe() in
  let ptd = ty_lookup name in
  EcPrinting.pp_typedecl ppe stf ptd; (*REMOVE*)
  EcPrinting.pp_typedecl ppe ppf ptd;
  print_newline ppf

let print_module (ppf : Format.formatter) (name : string) : unit = 
  let ppe = ppe () in
  let (mpt, (mex, _))  = mod_lookup name in
  EcPrinting.pp_modexp ppe stf (mpt,mex); (*REMOVE*)
  EcPrinting.pp_modexp ppe ppf (mpt,mex);
  print_newline ppf
  
let print_axiom (ppf : Format.formatter) (name : string) : unit = 
  let env = env () in
  let ppe = EcPrinting.PPEnv.ofenv env in
  let ax = ax_lookup name in
  EcPrinting.pp_axiom ppe stf ax; (*REMOVE*)
  EcPrinting.pp_axiom ppe ppf ax;
  print_newline ppf
  
let print_proof_admit_qed (ppf : Format.formatter) : unit =
  Format.fprintf stf "@[proof.@.@[admit.@]@.qed.@]@."; (*REMOVE*)
  Format.fprintf ppf "@[proof.@.@[admit.@]@.qed.@]@."

(*****************************************************************************)

(* writing = declaring + printing ********************************************)
let write_open_theory (ppf : Format.formatter) (name : string) : unit =
  decl_open_theory name;
  print_open_theory ppf name

let write_close_theory (ppf : Format.formatter) (name : string) : unit =
  decl_close_theory name;
  print_close_theory ppf name

let write_operator (ppf : Format.formatter) (pop : poperator) : unit =
  decl_operator pop;
  print_operator ppf pop
  
let write_module (ppf : Format.formatter) (name : string) (pmod : pmodule_def_or_decl) : unit =
  decl_module pmod;
  print_module ppf name

let write_type (ppf : Format.formatter) (ptyd : ptydecl) : unit =
  let name = ul ptyd.pty_name in
  decl_type ptyd;
  print_type ppf name;
  print_newline ppf

let write_lemma (ppf : Format.formatter) (lemma : paxiom) : unit =
  let name = ul lemma.pa_name in
  decl_axiom lemma;
  proof_admit_qed ();
  print_axiom ppf name;
  print_proof_admit_qed ppf;
  print_newline ppf
  
let write_hint_simplify (ppf : Format.formatter) (lname : string) : unit =
  Format.fprintf stf "hint simplify [eqtrue] %s.@." lname; (*REMOVE*)
  let red = ([`EqTrue], [([pqs lname], None)]) in
  decl_reduction red;
  Format.fprintf ppf "hint simplify [eqtrue] %s.@." lname;
  print_newline ppf

let write_hint_rewrite (ppf : Format.formatter) (lname : string) : unit =
  let rw = (`Global, pqs _epdp, [pqs lname]) in
  decl_rewrite rw;
  Format.fprintf stf "hint rewrite epdp : %s.@." lname; (*REMOVE*)
  Format.fprintf ppf "hint rewrite epdp : %s.@." lname;
  print_newline ppf
  
let write_require_import (ppf : Format.formatter) (name : string) : unit =
  let threq = 
    (None,
     [(dl name, None)], (*FIX*)
     Some `Import) in
  decl_require threq;
  Format.fprintf stf "@[require import %s.@]@." name; (*REMOVE*)
  Format.fprintf ppf "@[require import %s.@]@." name;
  print_newline ppf
    
(*****************************************************************************)

(* construction of common EcParsetree objects ********************************) 
let record_decl (name : string) (record_fields : precord) : ptydecl =
  let body = PTYD_Record record_fields in
  {
    pty_name   = dl name;
    pty_tyvars = [];
    pty_body   = body;
    pty_locality = `Global;
  }

let datatype_decl (name : string) (ctors : ( psymbol * pty list) list)
: ptydecl =
  {
    pty_name = dl name;
    pty_tyvars = [];
    pty_body = PTYD_Datatype ctors;
    pty_locality = `Global
  }

let qnamed_pty (qname : EcSymbols.qsymbol) : pty = dl (PTnamed (dl qname))

let named_pty (name : string) : pty = qnamed_pty (qs name)

let option_of_pty (pty : pty) : pty = dl (PTapp (pqs _option,[pty]))

let addr_pty : pty = named_pty _addr

let port_pty : pty = named_pty _port

let msg_pty : pty = named_pty _msg

let int_pty : pty = named_pty _int

let unit_pty : pty = named_pty _unit

let univ_pty : pty = named_pty _univ

let pex_pqident (pqname : pqsymbol) : pexpr =
  dl (PEident (pqname, None))

let pex_ident (name : string) : pexpr = pex_pqident (pqs name)

let pex_Dir = pex_ident _Dir

let pex_Adv = pex_ident _Adv

let pex_tuple (pexs : pexpr list) : pexpr = dl (PEtuple pexs)

let pex_proj (pex : pexpr) (name : string) = dl (PEproj (pex, pqs name))

let pex_app (ex : pexpr)  (args : pexpr list) : pexpr =
  dl (PEapp (ex,args))
  
let pex_let (pat : plpattern) (wty : pexpr_wty) (pex : pexpr) : pexpr =
  dl (PElet (pat,wty,pex))
 
let pex_if (cond : pexpr) (then_br : pexpr) (else_br : pexpr) : pexpr =
  dl (PEif (cond, then_br, else_br))

let pex_proji (pex : pexpr) (i : int) : pexpr =
  dl (PEproji (pex,i))
  
let pex_match (pex : pexpr) (clauses : (ppattern * pexpr) list) : pexpr =
  dl (PEmatch (pex,clauses))
  
let pex_record (opex : pexpr option) (rcrds : pexpr rfield list) : pexpr =
 dl (PErecord (opex, rcrds))

let pex_or = pex_ident sym_or

let pex_Eq = pex_ident sym_eq

let pex_Not = pex_ident sym_not

let pex_None = pex_ident _None

let pex_Some = pex_ident _Some
  
let pex_and = pex_ident _and

let pex_m = pex_ident _m

let pex__self = pex_ident __self

let pex__adv = pex_ident __adv

let pex_unit = pex_tuple []

let pex_of_int (i : int) : pexpr =
  dl (PEint (EcBigInt.of_int i))
  
let pex_projq (pex : pexpr) (qname : EcSymbols.qsymbol) = 
  dl (PEproj (pex, dl qname))

let ppattern (s : string) (sol : (string option) list) : ppattern =
  PPApp (
    (pqs s, None), 
    dll (List.map (
      (fun so -> 
        match so with
        | None -> None
        | Some s -> Some (dl s)
      )
    ) sol)
  )
  
let ppatSome (str : string) : ppattern =
  ppattern _Some [Some str]

let ppatSome_ : ppattern =
  ppattern _Some [None]
  
let ppatNone : ppattern =
  ppattern _None []
  
let pexpr_cascade (ex : pexpr) (exs : pexpr list) : pexpr =
  match List.length exs with
  | 0 -> failure "Cascade at least one  expression"
  | 1 -> List.hd exs
  | _ ->
    let exs = List.rev exs in
    let last = List.hd exs in
    let rest = List.rev (List.tl exs) in
    List.fold_right ( 
      fun ex1 ex2 -> pex_app ex [ex1; ex2]
    ) rest last


let pex_And (exs : pexpr list) : pexpr =
  pexpr_cascade pex_and exs
  
let pex_Or (exs : pexpr list) : pexpr =
  pexpr_cascade pex_or exs

let pex_envport = pex_ident _envport

let pex_app_envport (arg : pexpr) : pexpr =
  pex_app pex_envport [
    pex__self;
    pex__adv;
    arg;
  ]

let pexrfieldq (path : string list) (name : string) (pex : pexpr) 
  : pexpr rfield =
  {
    rf_name  = dl (path, name);
    rf_tvi   = None;
    rf_value = pex;
  }
  
let pexrfield (name : string) (pex : pexpr) : pexpr rfield =
  pexrfieldq [] name pex

let pform_pqident (pqname : pqsymbol) : pformula =
  dl (PFident (pqname, None))
  
let pform_ident (name : string) : pformula =
  pform_pqident (pqs name)

let pf_of_int (i : int) : pformula = 
  dl (PFint (EcBigInt.of_int i))

let pf_0 = dl (PFint EcBigInt.zero)

let pform_tuple (pfs : pformula list) : pformula =
  dl (PFtuple pfs)

let pform_unit = pform_tuple []

let pform_proj (f : pformula) (name : string) : pformula =
  dl (PFproj (f, pqs name))
  
let pform_app (f : pformula) (args : pformula list) : pformula =
  dl (PFapp (f,args))


let pform_Dir = pform_ident _Dir

let pform_Adv = pform_ident _Adv

let abs_oper_pty (name : string) (pty : pty) : poperator =
  let podef = PO_abstr (pty) in
  {
    po_kind     = `Op;
    po_name     = dl name;
    po_aliases  = [];
    po_tags     = [];
    po_tyvars   = None;
    po_args     = [];
    po_def      = podef;
    po_ax       = None;
    po_nosmt    = false;
    po_locality = `Global;
  }
 
let abs_oper_int (name : string) : poperator =  
  abs_oper_pty name int_pty

let op_of_argstyex (name : string) 
(args : (string * pty) list) (tyex : pty) (ex : pexpr) : poperator =
  let podef = PO_concr (tyex, ex) in
  let args = List.map (
    (fun (s,t) -> ([dl (Some (dl s))], t))
  ) args in
  {
    po_kind     = `Op;
    po_name     = dl name;
    po_aliases  = [];
    po_tags     = [];
    po_tyvars   = None;
    po_args     = args;
    po_def      = podef;
    po_ax       = None;
    po_nosmt    = false;
    po_locality = `Global;
  }

let op_of_tyex (name : string) (tyex : pty) (ex : pexpr) : poperator =
  op_of_argstyex name [] tyex ex

let op_of_ex (name : string) (ex : pexpr) : poperator =
  op_of_tyex name (dl PTunivar) ex
  
let oper_int (name : string) (value : int) : poperator =
  op_of_ex name (pex_of_int value)

let paxiom_lemma_varso (name : string) 
(vars : pgtybindings option) (pfrm : pformula) : paxiom =
  {
    pa_name     = dl name;
    pa_tyvars   = None;
    pa_vars     = vars;
    pa_formula  = pfrm;
    pa_kind     = PLemma None;
    pa_nosmt    = false;
    pa_locality = `Global;
  }

let paxiom_lemma_vars (name : string) 
(vars : (string * pty) list) (pfrm : pformula) : paxiom =
  let vars = List.map (
    fun (s,t) -> ([dl (Some (dl s))], PGTY_Type t)
  ) vars in
  paxiom_lemma_varso name (Some vars) pfrm

let paxiom_lemma (name : string) (pfrm : pformula) : paxiom =
  paxiom_lemma_varso name None pfrm
    
let paxiom_axiom (name : string) (pfrm : pformula) : paxiom =
  {
    pa_name     = dl name;
    pa_tyvars   = None;
    pa_vars     = None;
    pa_formula  = pfrm;
    pa_kind     = PAxiom [];
    pa_nosmt    = false;
    pa_locality = `Global;
  }
  
let pmodule (def : pmodule_def ) : pmodule_def_or_decl = {
    ptm_locality = `Global;
    ptm_def      = `Concrete def
  }
  
let pmodule_def (name : string) (items : pstructure): pmodule_def = {
    ptm_header = Pmh_ident (dl name);
    ptm_body   = dl (Pm_struct items);
  }
  
let pfunction_decl (name : string) (params : (psymbol * pty) list) (resty : pty)
: pfunction_decl =
  {
    pfd_name     = dl name;
    pfd_tyargs   = Fparams_exp params;
    pfd_tyresult = resty;
    pfd_uses     = (true, None);
  }

let pfunction_body 
  (locals : pfunction_local list) 
  (stmt : pstmt)
  (retval : pexpr option) : pfunction_body =
  {
    pfb_locals = locals;
    pfb_body   = stmt;
    pfb_return = retval;
  }
  
let fun_def (fdecl : pfunction_decl) (fbody : pfunction_body)
: pstructure_item EcLocation.located = dl (Pst_fun (fdecl, fbody))
 
(* ec parsetree instructions *)
let ps_if_then (ifc : pexpr) (ths : pstmt) : pinstr =
  dl (PSif ((ifc,ths),[],[]))

let ps_if_then_else (ifc : pexpr) (ths : pstmt) (els : pstmt) : pinstr =
  dl (PSif ((ifc,ths),[],els))

let ps_assign (a : string) (ex : pexpr) : pinstr =
  dl (PSasgn (dl (PLvSymbol (pqs a)), ex))

let ps_assign_id (a : string) (id : string) : pinstr =
  ps_assign a (pex_ident id)
  
let ps_assignl ( sl : string list) (ex : pexpr) : pinstr =
  let pqssl = List.map (fun s -> pqs s) sl in
  dl (PSasgn (dl (PLvTuple pqssl), ex))
  
let ps_rnd (a : string) (ex : pexpr) : pinstr =
  dl (PSrnd (dl (PLvSymbol (pqs a)), ex))
  
let ps_rndl ( sl : string list) (ex : pexpr) : pinstr =
  let pqssl = List.map (fun s -> pqs s) sl in
  dl (PSrnd (dl (PLvTuple pqssl), ex))
  
let ps_match (mtch_ex : pexpr) (branches : (ppattern * pstmt) list) : pinstr =
  dl (PSmatch (mtch_ex, `Full branches))
  
let ps_call (var : string) (proc : string) (args : pexpr list) : pinstr =
  dl (PScall (
    Some (dl (PLvSymbol (pqs var))),
    dl ([], dl proc),
    dl args 
  ))
  
let pf_var (name : string) (pty : pty) : pfunction_local =
  { 
    pfl_names = dl (`Single, [dl name]);
    pfl_type  = Some pty;
    pfl_init  = None
  }

(*****************************************************************************)

(*generated message types and epdp operators can shadow already existing types
  and operators with same names. We use shadowed record to handle these ******)
module Qs =
  struct
    type t = EcSymbols.qsymbol
    let compare = Stdlib.compare
  end
  
module QsMap = Map.Make(Qs)

module Tyl =
  struct
    type t = pty_r list
    let compare = Stdlib.compare
  end
  
module TylMap = Map.Make(Tyl)

module App =
  struct
    type t = qsymbol * pty_r list
    let compare = Stdlib.compare
  end
  
module AppMap = Map.Make(App)

module Fun =
  struct
    type t = pty_r * pty_r
    let compare = Stdlib.compare
  end
  
module FunMap = Map.Make(Fun)

type shadowed = {
  types     : pqsymbol IdMap.t;
  operators : pqsymbol IdMap.t;
  nonUCepdp_named : pqsymbol QsMap.t;
  nonUCepdp_tuple : pqsymbol TylMap.t;
  nonUCepdp_appty : pqsymbol AppMap.t;
  nonUCepdp_funty : pqsymbol FunMap.t;
}

let maybe_swap (pqs : pqsymbol) (alt : pqsymbol IdMap.t) : pqsymbol =
  match ul pqs with
  | ([],s) when IdMap.mem s alt -> IdMap.find s alt
  | _ -> pqs

let rec qualify_ty (sh : shadowed) (pty : pty) : pty =
  let qtyl (ptyl : pty list) =
    List.map (fun p -> qualify_ty sh p) ptyl
  in
  match ul pty with
  | PTnamed pqs ->
    dl (PTnamed (maybe_swap pqs sh.types)) 
  | PTtuple  ptyl ->
    dl (PTtuple (qtyl ptyl))
  | PTapp (pqs, ptyl) ->
    dl (PTapp ((maybe_swap pqs sh.types), (qtyl ptyl)))
  | PTfun (pty1,pty2) ->
    dl (PTfun (qualify_ty sh pty1, qualify_ty sh pty2))
  | _ -> 
    failure "Impossible, only named types, tuples, type applications and functions can show up in message declarations"

let qualify_opname (sh : shadowed) (name : string) : pqsymbol =
  if IdMap.mem name sh.operators
  then IdMap.find name sh.operators
  else pqs name

let option_of_msgty (sh : shadowed) (name : string) =
  let msgty = named_pty name in
  if IdMap.mem _option sh.types 
  then dl (PTapp (IdMap.find _option sh.types,[msgty]))
  else option_of_pty (named_pty name)
  
let init_shadowed : shadowed = 
  {
    types = IdMap.empty;
    operators = IdMap.empty;
    nonUCepdp_named = QsMap.empty;
    nonUCepdp_tuple = TylMap.empty;
    nonUCepdp_appty = AppMap.empty;
    nonUCepdp_funty = FunMap.empty;
  }

let add_ty_name (sh : shadowed) (name : string) : shadowed =
  match ty_lookup_opt name with
  | None -> sh
  | Some (path, _) ->
    {
      types = IdMap.add name (dl (EcPath.toqsymbol path)) sh.types;
      operators = sh.operators;
      nonUCepdp_named = sh.nonUCepdp_named;
      nonUCepdp_tuple = sh.nonUCepdp_tuple;
      nonUCepdp_appty = sh.nonUCepdp_appty;
      nonUCepdp_funty = sh.nonUCepdp_funty;
    }

let add_op_name (sh : shadowed) (name : string) : shadowed =
  match op_lookup_opt name with
  | None -> sh
  | Some (path, _) ->
    {
      types = sh.types;
      operators = IdMap.add name (dl (EcPath.toqsymbol path)) sh.operators;
      nonUCepdp_named = sh.nonUCepdp_named;
      nonUCepdp_tuple = sh.nonUCepdp_tuple;
      nonUCepdp_appty = sh.nonUCepdp_appty;
      nonUCepdp_funty = sh.nonUCepdp_funty;
    }

(*****************************************************************************)
  
(* construction of message theory ********************************************)

(**)
let params_map_to_list (pm : ty_index IdMap.t) : (string * pty) list =
  let bpm = IdMap.bindings pm in
  let bpm = List.map (fun (s,ti) -> (s, ul ti)) bpm in
  let bpm_ord = List.sort (fun (_,(_,i1)) (_,(_,i2)) -> i1-i2) bpm in
  List.map (fun (name,((_,pty),_)) -> (name, pty)) bpm_ord

(**)  
let isdirect (mb : message_body_tyd) : bool =
  match mb.port with
  | None -> false
  | Some _ -> true

(* message record field names *)
let name_record_func (msg_name : string) : string = msg_name^"__func"

let name_record_adv (msg_name : string) : string = msg_name^"__adv"

let name_record (msg_name : string) (param_name : string) : string = msg_name^"_"^param_name

let name_record_dir_port (name : string)  (mb : message_body_tyd) : string =
  name_record name (EcUtils.oget mb.port)

(* message type declaration *) 
let msg_type (sh : shadowed) (name : string) (mb : message_body_tyd) : ptydecl =
  let msg_data = List.map (fun (s,t) -> (dl (name_record name s), (qualify_ty sh t)))
    (params_map_to_list mb.params_map) in
  let self_addr = (dl (name_record_func name), (qualify_ty sh addr_pty)) in
  let other_port =
    if (isdirect mb)
    then (dl (name_record_dir_port name mb), (qualify_ty sh port_pty))
    else (dl (name_record_adv name), (qualify_ty sh addr_pty)) in
  record_decl name (self_addr :: other_port :: msg_data)
  
(* epdp stubs for types that are not in UCBasic types *)  
let stub_no = ref 0

let epdp_stub_prefix() : string =
  stub_no := !stub_no+1;
  "UC_epdp_stub"^(string_of_int !stub_no)

let epdp_namedty_stub_name (name : string) : string =
   (epdp_stub_prefix() )^"_"^name
  
let epdp_namedty_op (name : string) : poperator =  
  let opty = PTapp (pqs _epdp, [named_pty name; univ_pty]) in
  abs_oper_pty name (dl opty)
  
let name_lemma_epdp_valid (name : string) : string =
  "valid_"^name

let lemma_epdp (opname : string) : paxiom =
  let f_ve = pform_ident "valid_epdp" in
  let f_e = pform_ident opname in
  let pfrm = pform_app f_ve [f_e] in
  paxiom_lemma (name_lemma_epdp_valid opname) pfrm 

let write_epdp_stub (ppf : Format.formatter) (op : poperator) : string =
  write_operator ppf op;
  let opname = ul op.po_name in
  let le = lemma_epdp opname in
  write_lemma ppf le;
  let lename = ul le.pa_name in
  write_hint_simplify ppf lename;
  write_hint_rewrite ppf lename;
  opname

(* construction of epdp for message data*)

(* epdp for named types*)
let epdp_basicUCnamedty_univ (tyname : qsymbol) : string option =
  let epdp_name (name : string) : string option =
    match name with
    | "unit" -> Some "epdp_unit_univ"
    | "bool" -> Some "epdp_bool_univ"
    | "int"  -> Some "epdp_int_univ"
    | "addr" -> Some "epdp_addr_univ"
    | "port" -> Some "epdp_port_univ"
    | "univ"  -> Some "epdp_id"
    | _ -> None
  in
  let qual,name = tyname in
  match qual with
  | ["UCBasicTypes"] -> epdp_name name
  | [] -> epdp_name name
  | _ -> None
  
 
let add_nonUCepdp_namedty (ppf : Format.formatter) (sh : shadowed) 
(name : qsymbol) : shadowed =
  let _, n = name in
  let opname = write_epdp_stub ppf (epdp_namedty_op n) in
  {
    types = sh.types;
    operators = sh.operators;
    nonUCepdp_named = QsMap.add name (pqs opname) sh.nonUCepdp_named;
    nonUCepdp_tuple = sh.nonUCepdp_tuple;
    nonUCepdp_appty = sh.nonUCepdp_appty;
    nonUCepdp_funty = sh.nonUCepdp_funty;
  }

let epdp_named_non_UC_type (ppf : Format.formatter option) (sh : shadowed) 
(name : qsymbol) : shadowed * pqsymbol =
  let sh = if (QsMap.mem name sh.nonUCepdp_named) then sh else
    add_nonUCepdp_namedty (EcUtils.oget ppf) sh name in
  let epdp_op_pqname = QsMap.find name sh.nonUCepdp_named in
  sh, epdp_op_pqname

let epdp_namedty_univ (ppf : Format.formatter option) (sh : shadowed)
(name : qsymbol) : shadowed * pqsymbol  =
  let eno = epdp_basicUCnamedty_univ name in
  match eno with
  | Some en -> sh, (qualify_opname sh en)
  | None -> epdp_named_non_UC_type ppf sh name

(* epdp for tuples *)
let epdp_basicUCtuple_name (arity : int) : string option =
  match arity with
  | 2 -> Some "epdp_pair_univ"
  | 3 -> Some "epdp_tuple3_univ"
  | 4 -> Some "epdp_tuple4_univ"
  | 5 -> Some "epdp_tuple5_univ"
  | 6 -> Some "epdp_tuple6_univ"
  | 7 -> Some "epdp_tuple7_univ"
  | 8 -> Some "epdp_tuple8_univ"
  | _ -> None

let epdp_tuple_stub_name (tyl : pty_r list) : string =
  (epdp_stub_prefix ())^"_tuple"^(string_of_int (List.length tyl))

let epdp_tuple_op (tyl : pty_r list) : poperator =
  let name = epdp_tuple_stub_name tyl in
  let epdp_app_ty (pty : pty) =
    dl (PTapp (pqs _epdp, [pty; univ_pty]))
  in
  let tuplety = dl (PTtuple (List.map (fun t-> (dl t)) tyl)) in
  let opty = epdp_app_ty tuplety in
  abs_oper_pty name opty

let add_nonUCepdp_tuple (ppf : Format.formatter) (sh : shadowed)
(tyl : pty_r list) : shadowed =
  let opname = write_epdp_stub ppf (epdp_tuple_op tyl) in
  {
    types = sh.types;
    operators = sh.operators;
    nonUCepdp_named = sh.nonUCepdp_named;
    nonUCepdp_tuple = TylMap.add tyl (pqs opname) sh.nonUCepdp_tuple;
    nonUCepdp_appty = sh.nonUCepdp_appty;
    nonUCepdp_funty = sh.nonUCepdp_funty;
  }

let epdp_non_UC_tuple (ppf : Format.formatter option) (sh : shadowed)
(tyl : pty_r list): shadowed * pqsymbol  =
  let sh' = if (TylMap.mem tyl sh.nonUCepdp_tuple) then sh else
    add_nonUCepdp_tuple (EcUtils.oget ppf) sh tyl in
  let epdp_op_pqname = TylMap.find tyl sh'.nonUCepdp_tuple in
  sh', epdp_op_pqname

(* epdp for type applications *)
let epdp_basicUCappty_name (tyname : qsymbol) : string option =
  let epdp_name (name : string) : string option =
  match name with
    | "choice"  -> Some "epdp_choice_univ"
    | "choice3" -> Some "epdp_choice3_univ"
    | "choice4" -> Some "epdp_choice4_univ"
    | "choice5" -> Some "epdp_choice5_univ"
    | "choice6" -> Some "epdp_choice6_univ"
    | "choice7" -> Some "epdp_choice7_univ"
    | "choice8" -> Some "epdp_choice8_univ"
    | "option"  -> Some "epdp_option_univ"
    | "list"    -> Some "epdp_list_univ"
    | _ -> None
  in
  let qual,name = tyname in
  match qual with
  | ["UCBasicTypes"] -> epdp_name name
  | [] -> epdp_name name
  | _ -> None

let epdp_appty_stub_name (app : qsymbol) : string =
  (epdp_stub_prefix ())^"_app_"^(EcSymbols.string_of_qsymbol app)

let epdp_appty_op (app : qsymbol) (tyl : pty_r list) : poperator =
  let name = epdp_appty_stub_name app in
  let epdp_app_ty (pty : pty) =
    dl (PTapp (pqs _epdp, [pty; univ_pty]))
  in
  let app = dl (PTapp ( dl app , (List.map (fun t-> (dl t)) tyl) )) in
  let opty = epdp_app_ty app in
  abs_oper_pty name opty

let add_nonUCepdp_appty (ppf : Format.formatter) (sh : shadowed)
(app : qsymbol) (tyl : pty_r list) : shadowed =
  let opname = write_epdp_stub ppf (epdp_appty_op app tyl) in
  {
    types = sh.types;
    operators = sh.operators;
    nonUCepdp_named = sh.nonUCepdp_named;
    nonUCepdp_tuple = sh.nonUCepdp_tuple;
    nonUCepdp_appty = AppMap.add (app,tyl) (pqs opname) sh.nonUCepdp_appty;
    nonUCepdp_funty = sh.nonUCepdp_funty; 
  }

let epdp_non_UC_appty (ppf : Format.formatter option) (sh : shadowed)
(app : qsymbol) (tyl : pty_r list): shadowed * pqsymbol  =
  let sh' = if (AppMap.mem (app,tyl) sh.nonUCepdp_appty) then sh else
    add_nonUCepdp_appty (EcUtils.oget ppf) sh app tyl in
  let epdp_op_pqname = AppMap.find (app,tyl) sh'.nonUCepdp_appty in
  sh', epdp_op_pqname

(* epdp for function types *)
let epdp_funty_stub_name () : string =
  (epdp_stub_prefix ())^"_fun"

let epdp_funty_op (pty1 : pty_r) (pty2 : pty_r) : poperator =
  let name = epdp_funty_stub_name() in
  let epdp_app_ty (pty : pty) =
    dl (PTapp (pqs _epdp, [pty; univ_pty]))
  in
  let funty = dl (PTfun (dl pty1 , dl pty2)) in
  let opty = epdp_app_ty funty in
  abs_oper_pty name opty

let add_nonUCepdp_funty (ppf : Format.formatter) (sh : shadowed)
(pty1 : pty_r) (pty2 : pty_r) : shadowed =
  let opname = write_epdp_stub ppf (epdp_funty_op pty1 pty2) in
  {
    types = sh.types;
    operators = sh.operators;
    nonUCepdp_named = sh.nonUCepdp_named;
    nonUCepdp_tuple = sh.nonUCepdp_tuple;
    nonUCepdp_appty = sh.nonUCepdp_appty;
    nonUCepdp_funty = FunMap.add (pty1,pty2) (pqs opname) sh.nonUCepdp_funty;  
  }

let epdp_non_UC_funty (ppf : Format.formatter option) (sh : shadowed)
(pty1 : pty_r) (pty2 : pty_r) : shadowed * pqsymbol  =
  let sh' = if (FunMap.mem (pty1,pty2) sh.nonUCepdp_funty) then sh else
    add_nonUCepdp_funty (EcUtils.oget ppf) sh pty1 pty2 in
  let epdp_op_pqname = FunMap.find (pty1,pty2) sh'.nonUCepdp_funty in
  sh', epdp_op_pqname

(* combining epdps to construct epdp for a type  *)
let rec epdp_pty_univ (ppf : Format.formatter option) (sh : shadowed) 
(exf_name : pqsymbol -> 'a) (exf_app : 'a -> 'a list -> 'a)
(t : pty) : shadowed * 'a =
  match ul t with
  | PTtuple  ptys -> epdp_tuple_univ ppf sh exf_name exf_app ptys
  | PTnamed  pqs  -> epdp_namedty_univ_ ppf sh exf_name (ul pqs)
  | PTapp (pqs, ptys) -> epdp_app_univ ppf sh exf_name exf_app (ul pqs) ptys
  | PTfun (pty1, pty2) -> epdp_fun_univ ppf sh exf_name (ul pty1) (ul pty2)
  | _ -> failure ("Only tuples, named types, parametric types and functions are supported." )

and epdp_ptyl (ppf : Format.formatter option) (sh : shadowed) 
(exf_name : pqsymbol -> 'a) (exf_app : 'a -> 'a list -> 'a)
(tl : pty list) : shadowed * ('a list) =
  List.fold_left ( fun (sh, l) t ->
    let qt = qualify_ty sh t in
    let sh', e = epdp_pty_univ ppf sh exf_name exf_app qt in
    sh', l@[e]
  ) (sh,[]) tl
  
and epdp_namedty_univ_ (ppf : Format.formatter option) (sh : shadowed) 
(exf_name : pqsymbol -> 'a) (name : qsymbol) : shadowed * 'a =
  let sh, pqopname = epdp_namedty_univ ppf sh name in
  sh, exf_name pqopname
  
and epdp_tuple_univ (ppf : Format.formatter option) (sh : shadowed) 
(exf_name : pqsymbol -> 'a) (exf_app : 'a -> 'a list -> 'a)
(ptys : pty list) : shadowed * 'a =
  let tyl = ull ptys in
  let arity = List.length tyl in
  let eno = epdp_basicUCtuple_name arity in
  match eno with
  | Some en ->
    let sh', exfl = epdp_ptyl ppf sh exf_name exf_app ptys in
    let epdp_name = qualify_opname sh en in
    sh', exf_app (exf_name epdp_name) exfl
  | None -> 
    let sh', epdp_name = epdp_non_UC_tuple ppf sh tyl in
    sh', exf_name epdp_name

and epdp_app_univ (ppf : Format.formatter option) (sh : shadowed) 
(exf_name : pqsymbol -> 'a) (exf_app : 'a -> 'a list -> 'a)
(app : qsymbol) (ptys : pty list) : shadowed * 'a =
  let tyl = ull ptys in
  let eno = epdp_basicUCappty_name app in
  match eno with
  | Some en ->
    let sh', exfl = epdp_ptyl ppf sh exf_name exf_app ptys in
    let epdp_name = qualify_opname sh en in
    sh', exf_app (exf_name epdp_name) exfl
  | None -> 
    let sh', epdp_name = epdp_non_UC_appty ppf sh app tyl in
    sh', exf_name epdp_name

and epdp_fun_univ (ppf : Format.formatter option) (sh : shadowed) 
(exf_name : pqsymbol -> 'a) (pty1 : pty_r) (pty2 : pty_r) : shadowed * 'a =
  let sh', epdp_name = epdp_non_UC_funty ppf sh pty1 pty2 in
  sh', exf_name epdp_name
    
let epdp_data_univ (ppf : Format.formatter option) (sh : shadowed) 
(exf_name : pqsymbol -> 'a) (exf_app : 'a -> 'a list -> 'a)
(params_map : ty_index IdMap.t) : shadowed * 'a =
  let ptys = List.map (fun (_,pty) -> pty) (params_map_to_list params_map) in
  match ptys with
  | [] -> sh, exf_name (qualify_opname sh "epdp_unit_univ")
  | [t] -> epdp_pty_univ ppf sh exf_name exf_app t
  | _ -> epdp_tuple_univ ppf sh exf_name exf_app ptys

(* enc operator *)  
let enc_args (var_name : string) (msg_name : string ) (params_map : ty_index IdMap.t) : pexpr =
  let pns = fst (List.split (params_map_to_list params_map)) in
  if pns = []
  then pex_unit
  else pex_tuple (List.map (fun pn -> pex_proj (pex_ident var_name) (name_record msg_name pn)) pns)

let enc_u (ppf : Format.formatter option) (sh : shadowed) 
(var_name : string) (msg_name : string) (params_map : ty_index IdMap.t) 
: shadowed * pexpr =
  let sh', ex = epdp_data_univ ppf sh pex_pqident pex_app params_map in
  let ex = pex_proj ex "enc" in
  let args = enc_args var_name msg_name params_map in
  sh', pex_app ex [args]
  
let enc_op_name (name : string) : string = "enc_"^name

let enc_op (ppf : Format.formatter) (sh : shadowed) 
(tag : int) (mty_name : string) (mb : message_body_tyd) : shadowed * poperator =
  let var_name = "x" in
  let sh, u = enc_u (Some ppf) sh var_name mty_name mb.params_map in
  let selfport = pex_tuple [
    pex_proj (pex_ident var_name) (name_record_func mty_name); 
    pex_ident _pi ] in
  let isdirect = isdirect mb in
  let otherport = 
    if isdirect
    then pex_proj (pex_ident var_name) (name_record_dir_port mty_name mb) 
    else pex_tuple [
      pex_proj (pex_ident var_name) (name_record_adv mty_name); 
      pex_ident __adv_if_pi ]
    in
  let ptsource = if mb.dir = In then otherport else selfport in
  let ptdest = if mb.dir = In then selfport else otherport in
  let mode = if isdirect then pex_Dir else pex_Adv in
  let encex = pex_tuple [mode; ptdest; ptsource; pex_of_int tag; u] in
  let args = [(var_name, named_pty mty_name)] in
  sh, op_of_argstyex (enc_op_name mty_name) args (qualify_ty sh msg_pty) encex

(* dec operator *)
let dec_op_name (name : string) : string = "dec_"^name

let dec_op (sh : shadowed) (tag : int) (mty_name : string) (mb : message_body_tyd) : poperator =
  let var_name = "m" in
  let mode = "mod" in
  let pt1 = "pt1" in
  let pt2 = "pt2" in
  let funcport = if mb.dir = In then pt1 else pt2 in
  let otherport = if mb.dir = In then pt2 else pt1 in 
  let _tag = "tag" in
  let v = "v" in
  let osym (name : string) = dl (Some (dl name)) in
  let pat = dl (LPTuple [osym mode; osym pt1; osym pt2; osym _tag; osym v]) in
  
  let wty = (pex_ident var_name, None) in
  let isdirect = isdirect mb in
  let notmode = if isdirect then pex_Adv else pex_Dir in
  let if1 = pex_app pex_Eq [pex_ident mode; notmode] in
  let no0 = pex_app pex_Not 
    [pex_app pex_Eq [pex_proji (pex_ident otherport) 1; pex_ident __adv_if_pi]] in
  let no1 = pex_app pex_Not 
    [pex_app pex_Eq [pex_proji (pex_ident funcport) 1; pex_ident _pi]] in
  let no2 = pex_app pex_Not [pex_app pex_Eq [pex_ident _tag; pex_of_int tag]] in
  let if_cond = 
    if isdirect
    then pex_tuple [pex_Or [if1; no1; no2]] 
    else pex_tuple [pex_Or [if1; no0; no1; no2]] in
  
  let p = "p" in
  let n' (pn : string) : string = pn^"'" in
  let pns = fst (List.split (params_map_to_list mb.params_map)) in
  let patm = dl (LPTuple (List.map (fun pn -> osym (n' pn)) pns)) in
  let wtym = (pex_ident p, None) in
  let funcfld = pexrfield (name_record_func mty_name) (pex_proji (pex_ident funcport) 0) in
  let otherfld = 
    if isdirect
    then pexrfield (name_record_dir_port mty_name mb) (pex_ident otherport) 
    else pexrfield (name_record_adv mty_name) (pex_proji (pex_ident otherport) 0)
    in
  let dataflds = List.map 
    (fun pn -> pexrfield (name_record mty_name pn) (pex_ident (n' pn)) ) 
    pns in
  let msg = pex_record None (funcfld::otherfld::dataflds) in
  let omsg = pex_app pex_Some [msg] in

  let ex2 = 
    if pns = [] 
    then omsg
    else pex_let patm wtym omsg  in
  let pat2 = 
    if pns = []
    then ppatSome_
    else ppatSome p in
  let mtch2 = (pat2, ex2) in
  let mtch1 = (ppatNone, pex_None) in

  let _ , epdp_op = epdp_data_univ None sh pex_pqident pex_app mb.params_map in
  let dd = pex_proj epdp_op "dec" in
  let pmex = pex_app dd [pex_ident v] in
  let else_br = pex_match pmex [mtch1; mtch2] in

  let pif = pex_if if_cond pex_None else_br in
  
  let decex = pex_let pat wty pif in
  let args = [(var_name, qualify_ty sh msg_pty) ] in
  let ret_pty = option_of_msgty sh mty_name in
  op_of_argstyex (dec_op_name mty_name) args ret_pty decex

(* epdp operator for message type *)
let name_epdp_op (mty_name : string) : string = "epdp_"^mty_name

let epdp_op (mty_name : string) : poperator =
  let enc = pexrfield "enc" (pex_ident (enc_op_name mty_name)) in
  let dec = pexrfield "dec" (pex_ident (dec_op_name mty_name)) in
  let epdp = pex_record None [enc; dec] in
  op_of_ex (name_epdp_op mty_name) epdp

(* version of enc_args returning formula instead of expression *)  
let enc_args_form (var_name : string) (msg_name : string ) (params_map : ty_index IdMap.t) : pformula =
  let pns = fst (List.split (params_map_to_list params_map)) in
  if pns = []
  then pform_unit
  else pform_tuple (List.map (fun pn -> pform_proj (pform_ident var_name) (name_record msg_name pn)) pns)

(* version of enc_u returning formula instead of expression *)
let enc_u_form (sh : shadowed) (var_name : string) (msg_name : string) (params_map : ty_index IdMap.t) : pformula =
  let _, epdp_data_form = epdp_data_univ None sh pform_pqident pform_app params_map in
  let f = pform_proj epdp_data_form "enc" in
  let args = enc_args_form var_name msg_name params_map in
  pform_app f [args]

(* lemma eq_of_valid_msgtyname *)
let name_lemma_eq_of_valid (name : string) : string =
  "eq_of_valid_"^name

let lemma_eq_of_valid (sh : shadowed) (tag : int) (mty_name : string) (mb : message_body_tyd) : paxiom =
  let m = "m" in
  let vars = [(m, qualify_ty sh msg_pty)] in
  
  let fepdp = pform_ident (name_epdp_op mty_name) in
  let fm = pform_ident m in
  let f_l = pform_app (pform_ident "is_valid") [fepdp; fm] in
  let f_eq = pform_ident "=" in
  let fdec = pform_tuple [pform_app (pform_proj fepdp _dec) [fm]] in 
  let foget = pform_app (pform_ident "oget") [fdec] in
  
  let x = "x" in
  let fx = pform_ident x in
  let isdirect = isdirect mb in
  let fmode = if isdirect then pform_Dir else pform_Adv in
  let fsadd = pform_proj fx (name_record_func mty_name) in
  let funcport = pform_tuple [fsadd; pform_ident _pi] in
  let otherport = 
    if isdirect
    then pform_proj fx (name_record_dir_port mty_name mb)
    else let fsadv = pform_proj fx (name_record_adv mty_name) in
      pform_tuple [fsadv; pform_ident __adv_if_pi]
    in
  let fdport = if mb.dir = In then funcport else otherport in
  let fsport = if mb.dir = In then otherport else funcport in
  let fdata = enc_u_form sh x mty_name mb.params_map in
  let fmsg = pform_tuple [fmode; fdport; fsport; pf_of_int tag; fdata] in
  
  let flet = dl (PFlet (dl (LPSymbol (dl "x")), (foget, None), fmsg)) in
  let f_r = pform_app f_eq [fm; flet] in
  let f_imp = pform_ident "=>" in
  let pfrm = pform_app f_imp [f_l; f_r] in
  paxiom_lemma_vars (name_lemma_eq_of_valid mty_name) vars pfrm

let write_message (ppf : Format.formatter) (sh : shadowed) 
  (tag : int) (name : string) (mb : message_body_tyd) : shadowed =
  write_type ppf (msg_type sh name mb);
  let sh, op = enc_op ppf sh tag name mb in
  write_operator ppf op;
  write_operator ppf (dec_op sh tag name mb);
  let epdpop = epdp_op name in
  write_operator ppf epdpop;
  let epdplem = lemma_epdp (ul epdpop.po_name) in
  write_lemma ppf epdplem;
  let lename = ul epdplem.pa_name in
  write_hint_simplify ppf lename;
  write_hint_rewrite ppf lename;
  write_lemma ppf (lemma_eq_of_valid sh tag name mb);
  sh
(* basic interface *) 
let pi_op : poperator = abs_oper_int _pi
  
let pi_op2 = oper_int _pi 2

let uc_name (name : string) : string =
  "UC_"^name

let add_shadowing_decls (sh : shadowed) (name : string) : shadowed =
  let sh = add_ty_name sh name in
  let sh = add_op_name sh (name_epdp_op name) in
  sh
  
let write_basic_int 
  (ppf : Format.formatter) 
  (isdirect : bool) 
  (is4ideal : bool) 
  (name : string) 
  (bibt : basic_inter_body_tyd) 
  : unit =
  let name = uc_name name in
  write_open_theory ppf name;
  if (isdirect || (not is4ideal))
  then write_operator ppf pi_op
  else write_operator ppf pi_op2
  ;
  let bibtl = IdMap.bindings bibt in
  let _ = List.fold_left ( fun (i,sh) (n, mb) -> 
    let sh = add_shadowing_decls sh n in
    let sh = write_message ppf sh i n mb in
    (i+1, sh)
  ) (0,init_shadowed) bibtl in
  write_close_theory ppf name

(*****************************************************************************)

(* uc instruction to ec statement translation ********************************)
type locals = { 
  vals  : pexpr IdMap.t
}

type interfaces = {
  di_name : string;
  di      : basic_inter_body_tyd IdMap.t;
  ai_name : string;
  ai      : basic_inter_body_tyd;
}

let get_message_body 
  (interfaces : interfaces) 
  (inter_id_path : string list) 
  (msgtyname : string) 
  : message_body_tyd =
  match inter_id_path with
  | [name; bin] when name = interfaces.di_name -> 
      IdMap.find msgtyname (IdMap.find bin interfaces.di)
  | [name] when name = interfaces.ai_name -> 
      IdMap.find msgtyname interfaces.ai
  | _ -> failure "impossible, ideal fun cannot have other inter_id_path"

let mk_message_record_ex
  (inter_id_path : string list) 
  (msgtyname : string)
  (mb : message_body_tyd)
  (port : pexpr option)
  (data : pexpr list)
  : pexpr =
  let pexrfield_iip = pexrfieldq inter_id_path in
  let funcfld = pexrfield_iip (name_record_func msgtyname) (pex_ident __self) in  
  let otherfld = 
    match (mb.port, port) with
    | (None, None) ->
      pexrfield_iip (name_record_adv msgtyname) (pex_ident __adv)
    | (Some _, Some p) ->
      pexrfield_iip (name_record_dir_port msgtyname mb) p
    | _ -> 
      failure "mb.port and port should either both be None or both Some" in
  let pns = fst (List.split (params_map_to_list mb.params_map)) in
  let dataflds = List.map2
    (fun pn ex -> pexrfield_iip (name_record msgtyname pn) ex) 
    pns data in
  pex_record None (funcfld::otherfld::dataflds)

let state_name (name : string) : string = "_State_"^name

(**)
let rec uc2ec_expr (locals : locals) (uc_expr : pexpr) : pexpr =
  let uc_ec_expr = uc2ec_expr locals in
  match ul uc_expr with
  | PEapp (
      {
        pl_loc  = _;
        pl_desc = PEident (
            {
              pl_loc  = _;
              pl_desc = ([], _envport);
            },
            None
          );
      },
      [arg]) -> 
    pex_app_envport (uc_ec_expr arg)
  | PEident (pqsymbol, ptyannoto) ->
    begin match ((ul pqsymbol), ptyannoto) with
    | (([],s), None) when IdMap.mem s locals.vals -> IdMap.find s locals.vals      
    | _ -> dl (PEident (pqsymbol, ptyannoto))
    end
  | PEcast (pexpr, pty) -> 
    dl (PEcast (uc_ec_expr pexpr, pty))
  | PEint    zint -> 
    dl (PEint zint)
  | PEdecimal (zint, (i, zint2)) -> 
    dl (PEdecimal (zint, (i, zint2)))
  | PEapp (pexpr, pexprl) -> 
    dl (PEapp (uc_ec_expr pexpr, List.map uc_ec_expr pexprl))
  | PElet (plpattern, (pexw, ptyo), pexpr) -> 
    dl (PElet (plpattern, (uc_ec_expr pexw, ptyo), uc_ec_expr pexpr))
  | PEtuple  pexprl ->
    dl (PEtuple (List.map uc_ec_expr pexprl))
  | PEif (pexc, pexif, pexel) ->
    dl (PEif (uc_ec_expr pexc, uc_ec_expr pexif, uc_ec_expr pexel))
  | PEmatch (pexpr, patexl) ->
    dl (PEmatch (
      uc_ec_expr pexpr, 
      List.map (fun (pat,ex) -> (pat, uc_ec_expr ex)) patexl))
  | PEforall (ptybindings, pexpr) ->
    dl (PEforall (ptybindings, uc_ec_expr pexpr))
  | PEexists (ptybindings, pexpr) ->
    dl (PEexists (ptybindings, uc_ec_expr pexpr))
  | PElambda (ptybindings, pexpr) ->
    dl (PElambda (ptybindings, uc_ec_expr pexpr))
  | PErecord (pexpro, pexprrl) ->
    let uc_ec_exprr (pexprr : pexpr rfield) : pexpr rfield =
      {
        rf_name  = pexprr.rf_name;
        rf_tvi   = pexprr.rf_tvi;
        rf_value = uc_ec_expr pexprr.rf_value;
      }
    in
    dl (PErecord (pexpro, List.map uc_ec_exprr pexprrl))
  | PEproj (pexpr, pqsymbol) ->
    dl (PEproj (uc_ec_expr pexpr, pqsymbol))
  | PEproji (pexpr, i) ->
    dl (PEproji (uc_ec_expr pexpr, i))
  | PEscope (pqsymbol, pexpr) ->
    dl (PEscope (pqsymbol, uc_ec_expr pexpr))
    
let uc2ec_ps_assign (locals : locals) (lhs : lhs) (rhs : pexpr) : pinstr =
  let ec_rhs = uc2ec_expr locals rhs in
  match lhs with
  | LHSSimp  ps  -> ps_assign (ul ps) ec_rhs
  | LHSTuple psl -> ps_assignl (List.map (fun ps -> ul ps) psl) ec_rhs
  
let uc2ec_ps_sample (locals : locals) (lhs : lhs) (rhs : pexpr) : pinstr =
  let ec_rhs = uc2ec_expr locals rhs in
  match lhs with
  | LHSSimp  ps  -> ps_rnd (ul ps) ec_rhs
  | LHSTuple psl -> ps_rndl (List.map (fun ps -> ul ps) psl) ec_rhs

let uc_inter_path (path : string list) : string list =
 if path = [] then []
 else 
   let hd = uc_name (List.hd path) in
   let tl = List.tl path in
   hd::tl 

let rec uc2ec_stmt (locals : locals) (interfaces : interfaces) (inst : instruction_tyd) : pstmt =
  match ul inst with
  | Assign (lhs, pexpr) -> [uc2ec_ps_assign locals lhs pexpr]
  | Sample (lhs, pexpr) -> [uc2ec_ps_sample locals lhs pexpr]
  | ITE (pexpr, instruction_tyd_ll, instruction_tyd_llo) ->
     ucITE2ec_stmt locals interfaces pexpr instruction_tyd_ll instruction_tyd_llo
  | Match (pexpr, match_clause_tyd_ll) ->
    ucMatch2ec_stmt locals interfaces pexpr match_clause_tyd_ll
  | SendAndTransition send_and_transition_tyd ->
     ucSandT2ec_stmt locals interfaces send_and_transition_tyd
  | Fail -> []
                
and uc_inst_list2ec_stmt 
  (locals : locals)
  (interfaces : interfaces)
  (uc_instll : instruction_tyd list EcLocation.located) 
  : pstmt =
  List.concat (List.map (uc2ec_stmt locals interfaces) (ul uc_instll))
  
and ucITE2ec_stmt (locals : locals) (interfaces : interfaces)
  (cond : pexpr) 
  (if_br : instruction_tyd list EcLocation.located) 
  (else_bro : instruction_tyd list EcLocation.located option)
  : pstmt =
  let cond = uc2ec_expr locals cond in
  let if_br = uc_inst_list2ec_stmt locals interfaces if_br in
  match else_bro with
  | Some else_br ->
    let else_br = uc_inst_list2ec_stmt locals interfaces else_br in
    [ps_if_then_else cond if_br else_br]
  | None ->
    [ps_if_then cond if_br]
    
and ucMatch2ec_stmt (locals : locals) (interfaces : interfaces)
  (value : pexpr) (clauses : match_clause_tyd list EcLocation.located) : pstmt =
  let value = uc2ec_expr locals value in
  let clauses = ul clauses in
  let uc_clause2ec (clause : match_clause_tyd) : ppattern * pstmt =
    let (s, (bs, is)) = clause in
    print_string ("\n"^s^":");
    let sol = (
      List.map (fun (ecid, _) -> 
        let id = EcIdent.name ecid in
        if id = "_"
        then None
        else Some id
      ) bs
    ) in 
    let stmt = uc_inst_list2ec_stmt locals interfaces is in
    (ppattern s sol, stmt)
  in
  let ec_clauses = List.map uc_clause2ec clauses in
  [ps_match value ec_clauses]
    
and ucSandT2ec_stmt 
  (locals : locals)
  (interfaces : interfaces)
  (s_and_t : send_and_transition_tyd) 
  : pstmt =
  let send locals interfaces (msg_ex : msg_expr_tyd) : pinstr =
    let iip = uc_inter_path (ul msg_ex.path).inter_id_path in
    let mtn = (ul msg_ex.path).msg in
    let mb = get_message_body interfaces iip mtn in
    let porto =
      match msg_ex.port_expr with
      | None -> None
      | Some p -> Some (uc2ec_expr locals p) in
    let args = List.map (fun ex -> uc2ec_expr locals ex) (ul msg_ex.args) in
    let msg = mk_message_record_ex iip mtn mb porto args in
    let epdp_path = (iip, name_epdp_op mtn) in
    let encmsg =
      pex_app (pex_proj (pex_pqident (dl (epdp_path))) _enc) [msg] in
    let msgo = pex_app pex_Some [encmsg] in
    ps_assign __r msgo
  in
  let transition (locals : locals) (st_ex : state_expr_tyd ) : pinstr =
    let args = List.map (fun ex -> uc2ec_expr locals ex) (ul st_ex.args) in
    let st_id = state_name (ul st_ex.id) in
    let st = 
      if args = []
      then pex_ident st_id
      else pex_app (pex_ident st_id) args in
    ps_assign __st st
  in
  [ 
    send locals interfaces s_and_t.msg_expr;
    transition locals s_and_t.state_expr;
  ]
  
(*****************************************************************************)

  
(* ideal functionality theory ************************************************)

(* constructing state type *)
let state_type_name = "_state"

let state_type (states : state_tyd IdMap.t) : ptydecl =
  let s2e (sname, sbod : string * state_tyd) : (psymbol * pty list) =
    let sptys = snd (List.split (params_map_to_list (ul sbod).params)) in
    (dl (state_name sname), sptys)
  in
  let ste = List.map s2e (IdMap.bindings states) in
  datatype_decl state_type_name ste



(* vars *)
let var__self = dl (Pst_var ([dl __self], addr_pty))
let var__adv = dl (Pst_var ([dl __adv], addr_pty))
let var__st = dl (Pst_var ([dl __st], named_pty state_type_name))

(* proc init *)
let pinit_decl = pfunction_decl 
  _init
  [
    (dl _self_, addr_pty);
    (dl _adv_ , addr_pty)
  ]
  unit_pty


let init_name (states : state_tyd IdMap.t) : string =
  let init_state = IdMap.filter (fun _ s -> (ul s).is_initial) states in
  fst (IdMap.choose init_state)

let pinit_body (states : state_tyd IdMap.t) = pfunction_body
  []
  [
    ps_assign_id __self _self_;
    ps_assign_id __adv _adv_;
    ps_assign_id __st (state_name (init_name states));
  ]
  None

let proc_init (states : state_tyd IdMap.t) =
  fun_def pinit_decl (pinit_body states)

(* proc state *)
let add_pat_vals
  (inter_id_path : string list)
  (msgtyname : string)
  (mb : message_body_tyd)
  (port : psymbol option)
  (pat_args : pat list option) 
  (locals : locals) : locals =
  let pex_projq_x fieldname = 
    pex_projq (pex_ident __x) (inter_id_path,fieldname) 
  in
  let add_val (valname : string) (subst_expr : pexpr) (locals : locals) : locals =
    { vals = IdMap.add valname subst_expr locals.vals }
  in
  let locals =
    begin match port with
    | None -> locals
    | Some psymbol ->
      let fieldname = name_record_dir_port msgtyname mb in
      let sourceport = pex_projq_x fieldname in
      add_val (ul psymbol) sourceport locals
    end in
  match pat_args with
  | None -> locals
  | Some patl -> 
    List.fold_left2
      (fun locals pat_arg memname ->
        match pat_arg with
        | PatWildcard _ -> locals
        | PatId psymbol ->
          let fieldname = name_record msgtyname memname in
          let memex = pex_projq_x fieldname in
          add_val (ul psymbol) memex locals
      )
      locals patl (fst (List.split (params_map_to_list mb.params_map)))
    
let rec mmcl2matchinstr
  (interfaces : interfaces) 
  (mmcl : msg_match_clause_tyd list)
  : pstmt =
  match mmcl with
  | [] -> []
  | mmc :: mmcl' ->
    let mpp = ul mmc.msg_pat.msg_path_pat in
    let msgtyname = 
      match mpp.msg_or_star with
      | MsgOrStarMsg n -> n
      | MsgOrStarStar -> failure "impossible, we checked it is not star!" in
    let iip = uc_inter_path mpp.inter_id_path in
    let epdp_path = (iip, name_epdp_op msgtyname) in
    let decmsg = pex_app
      (pex_proj (pex_pqident (dl (epdp_path))) _dec)
      [pex_ident __m] in
    let mb = get_message_body interfaces iip msgtyname in
    let locals = { vals = IdMap.empty } in
    let locals' = add_pat_vals iip msgtyname mb mmc.msg_pat.port_id mmc.msg_pat.pat_args locals in
    let stmt = uc_inst_list2ec_stmt locals' interfaces mmc.code in
    let somebr = (ppatSome __x, stmt) in
    let recur = mmcl2matchinstr interfaces mmcl' in
    let nonebr = (ppatNone, recur) in
    [ps_match decmsg [somebr; nonebr]]

let proc_state_name (stname : string) : string = "proc"^stname

let proc_state_decl (stname : string) (state : state_body_tyd) : pfunction_decl = 
  let pl = params_map_to_list state.params in
  let params = List.map (fun (name, pty) -> (dl name,pty)) pl in
  pfunction_decl
    (proc_state_name stname)
    ((dl __m, msg_pty)::params)
    (option_of_pty msg_pty)

let get_vars (state : state_body_tyd) : pfunction_local list =
    let vars = params_map_to_list state.vars in
    List.map (fun (n,t) -> pf_var n t) vars

let proc_state_body (interfaces : interfaces) (state : state_body_tyd) =
  let assign__r = ps_assign __r pex_None in
  let state_match = mmcl2matchinstr interfaces (List.filter 
      (fun mmc -> not (msg_path_pat_ends_star mmc.msg_pat.msg_path_pat)) 
    state.mmclauses) in
    pfunction_body
      ((get_vars state)@[pf_var __r  (option_of_pty msg_pty)])
      (assign__r :: state_match)
      (Some (pex_ident __r))

let proc_state (interfaces : interfaces) (stname, state : string * state_tyd) =
  let state = ul state in
  let pdecl = proc_state_decl stname state in
  let pbody = proc_state_body interfaces state in
  fun_def pdecl pbody
(*****************************************************************************)

(* proc parties **************************************************************)
let call_state stname param_names =
    let param_exl = List.map (fun n -> pex_ident n) param_names in
    ps_call __r (proc_state_name stname) (pex_ident __m::param_exl)

let state2matchbranch
  (stname, state : string * state_tyd) 
  : ppattern * pstmt =
  let state = ul state in
  let param_names = fst (List.split (params_map_to_list state.params)) in
  let ppat = ppattern (state_name stname) 
    (List.map (fun n -> Some  n) param_names) in
  let pstmt = [call_state stname param_names] in
  (ppat, pstmt)

let party_match
  (states : state_tyd IdMap.t) : pinstr = 
  let mtch_ex = pex_ident __st in
  let branches = List.map state2matchbranch (IdMap.bindings states) in
  ps_match mtch_ex branches

let pparties_decl : pfunction_decl = pfunction_decl
  _parties
  [(dl __m, msg_pty)]
  (option_of_pty msg_pty)

let pparties_body
  (states : state_tyd IdMap.t) =
  let party_match = party_match states in
  pfunction_body
    [pf_var __r  (option_of_pty msg_pty)]
    [party_match]
    (Some (pex_ident __r))

let proc_parties
  (states : state_tyd IdMap.t) =
  fun_def pparties_decl (pparties_body states)
(*****************************************************************************)

(* proc invoke ***************************************************************) 
let pinvoke_decl : pfunction_decl = pfunction_decl
  _invoke
  [(dl _m, msg_pty)]
  (option_of_pty msg_pty)

let call_parties = ps_call _r _parties [pex_m]
    
let adv_msg_guard (piex : pexpr) : pexpr =
  pex_tuple [ pex_And [
    pex_app pex_Eq [
      pex_proji  (pex_m) 0;
      pex_Adv
    ];
    pex_app pex_Eq [
      pex_proji (pex_proji  (pex_m) 1) 0;
      pex__self
    ];
    pex_app pex_Eq [
      pex_proji (pex_proji  (pex_m) 1) 1;
      piex
    ];
    pex_app pex_Eq [
      pex_proji (pex_proji  (pex_m) 2) 0;
      pex__adv
    ];
  ]]
    
let pinvoke_body (guard : pexpr) : pfunction_body = pfunction_body
  [pf_var _r (option_of_pty msg_pty)]
  [ps_if_then guard [call_parties]]
  (Some (pex_ident _r))

let basic_piex (bi_name : string) : pexpr =
  pex_pqident (dl ([bi_name],_pi))
  
let comp_piex (di_name : string) (di_mem : string) : pexpr =
  pex_pqident (dl ([di_name; di_mem],_pi))
  
let dir_msg_guard (piex : pexpr) : pexpr =
  pex_tuple [ pex_And [
    pex_app pex_Eq [
      pex_proji  (pex_m) 0;
      pex_Dir
    ];
    pex_app pex_Eq [
      pex_proji (pex_proji  (pex_m) 1) 0;
      pex__self
    ];
    pex_app pex_Eq [
      pex_proji (pex_proji  (pex_m) 1) 1;
      piex
    ];
    pex_app_envport (pex_proji (pex_m) 2);
  ]]

let proc_invoke 
  (di_name : string) 
  (di_mem_names : string list) 
  (ai_name : string) =
  let dir_guards = List.map (fun n -> dir_msg_guard (comp_piex di_name n)) 
    di_mem_names in
  let adv_guard = adv_msg_guard (basic_piex ai_name) in
  let guard = pex_Or (dir_guards@[adv_guard]) in
  let body = pinvoke_body guard in
  fun_def pinvoke_decl body
(*****************************************************************************)

let ideal_module 
  (name : string) 
  (fbi : ideal_fun_body_tyd)   
  (interfaces : interfaces) : pmodule_def_or_decl 
  =
  let di_mem_names = fst (List.split (IdMap.bindings interfaces.di)) in
  let items = [
    var__self;
    var__adv;
    var__st;
    proc_init fbi.states;
  ]@
  (List.map (proc_state interfaces) (IdMap.bindings fbi.states))@ 
  [
    proc_parties fbi.states;
    proc_invoke interfaces.di_name di_mem_names interfaces.ai_name;
  ] in
  let pmodule_def = pmodule_def name items in
  pmodule pmodule_def
  
let write_ideal_fun 
  (ppf : Format.formatter) 
  (name : string) 
  (fbi : ideal_fun_body_tyd)
  (di_name : string)
  (di : basic_inter_body_tyd IdMap.t)
  (ai_name : string) 
  (ai : basic_inter_body_tyd) : unit 
  =
  write_open_theory ppf _UC__IF;
  write_type ppf (state_type fbi.states);
  let interfaces = {
    di_name = uc_name di_name;
    di      = di;
    ai_name = uc_name ai_name;
    ai      = ai
  } in
  let name = uc_name name in
  write_module ppf name (ideal_module name fbi interfaces);
  write_close_theory ppf _UC__IF
(*****************************************************************************)

let write_clone (ppf : Format.formatter) (name : string) (bi : string) (pindx : int) : unit =
  let thov = PTHO_Op (`BySyntax {
    opov_nosmt  = false; 
    opov_tyvars = None; opov_args = [];
    opov_retty  = dl PTunivar;
    opov_body   = pex_of_int pindx
    }, `Alias) in
  let cl = {
    pthc_base   = pqs bi;
    pthc_name   = Some (dl name);
    pthc_ext    = [(pqs _pi, thov)];
    pthc_prf    = [{pthp_mode = `All (None, []); pthp_tactic = None}];
    pthc_rnm    = [];
    pthc_opts   = [];
    pthc_clears = [];
    pthc_local  = `Global;
    pthc_import = None;
  } in
  clone cl;
  Format.fprintf stf "@[clone %s as %s with@.  op pi = %i@.proof *.@]@." bi name pindx; (*REMOVE*)
  Format.fprintf ppf "@[clone %s as %s with@.  op pi = %i@.proof *.@]@." bi name pindx;
  print_newline ppf

let write_com_int (ppf : Format.formatter) (isdirect : bool) (name : string) (nt : string IdMap.t) : unit =
  let name = uc_name name in
  write_open_theory ppf name;
  let nt = IdMap.to_seq nt in
  let i = if isdirect then ref 1 else ref 2 in
  Seq.iter (fun (n,t) -> write_clone ppf n (uc_name t) !i; i:=!i+2) nt;
  write_close_theory ppf name

type singlefile_typed_spec = {
  dir_inter_map : inter_tyd IdMap.t;
  adv_inter_map : inter_tyd IdMap.t;
  fun_map       : fun_tyd IdMap.t;
  sim_map       : sim_tyd IdMap.t
}
  
let axiom_adv_if_pi_gt0 : paxiom =
  let f_le = pform_ident "<" in
  let f_ax = pform_ident __adv_if_pi in 
  let pfrm = pform_app f_le [pf_0; f_ax] in
  paxiom_axiom __adv_if_pi_gt0 pfrm

let write_ax_adv_if_pi_gt0 (ppf : Format.formatter) : unit =
  decl_axiom (axiom_adv_if_pi_gt0);
  print_axiom ppf __adv_if_pi_gt0;
  print_newline ppf
  
let write_file (ppf : Format.formatter) (sts : singlefile_typed_spec) : unit =
  let basfilt i = 
    let ibt = ul i in
    match ibt with
    | BasicTyd  b -> Some b
    | _ -> None
  in

  let compfilt i = 
    let ibt = ul i in
    match ibt with
    | CompositeTyd c -> Some c
    | _ -> None
  in
  
  let idealfilt f =
    let fbt = ul f in
    match fbt with
    | FunBodyIdealTyd fbi -> Some fbi
    | _ -> None
  in
    
  let ideal_funs = filter_map idealfilt sts.fun_map in
  let aiif_names = IdMap.map (fun fbi -> fbi.id_adv_inter) ideal_funs in
  let aiif_names = snd (List.split (IdMap.bindings aiif_names)) in
  let basdir = filter_map basfilt sts.dir_inter_map in
  let comdir = filter_map compfilt sts.dir_inter_map in
  let basadv = filter_map basfilt sts.adv_inter_map in
  let basadv_ideal = IdMap.filter (fun n _ -> List.mem n aiif_names) basadv in
  let basadv_real = IdMap.filter (fun n _ -> not (List.mem n aiif_names)) basadv in
  let comadv = filter_map compfilt sts.adv_inter_map in
  
  write_require_import ppf _UCBasicTypes;
  write_operator ppf (abs_oper_int __adv_if_pi);
  write_ax_adv_if_pi_gt0 ppf;
  IdMap.iter (fun n i -> write_basic_int ppf true false n i) basdir;
  IdMap.iter (fun n i -> write_com_int ppf true n i) comdir;
  IdMap.iter (fun n i -> write_basic_int ppf false true n i) basadv_ideal;
  IdMap.iter (fun n i -> write_basic_int ppf false false n i) basadv_real;
  IdMap.iter (fun n i -> write_com_int ppf false n i) comadv;
  IdMap.iter (fun n f -> write_ideal_fun ppf n f 
                        f.id_dir_inter
                        (IdMap.map 
                          (fun n -> IdMap.find n basdir)
                          (IdMap.find f.id_dir_inter comdir))
                        f.id_adv_inter
                        (IdMap.find f.id_adv_inter basadv_ideal)) ideal_funs
  

(*---------------------------------------------------------------------------*)

let ec_filename (f : string) : string = "UC__"^f^".eca"

let open_formatter (f : string) : out_channel * Format.formatter =
  let fo = open_out_gen [Open_append; Open_creat] 0o666 f in
  let ppf = Format.formatter_of_out_channel fo in
  (fo,ppf)

let close_formatter ((fo,ppf) : out_channel * Format.formatter) : unit =
  Format.pp_print_flush ppf ();
  close_out fo

let remove_file (fn : string) : unit =
  if Sys.file_exists fn 
  then Sys.remove fn 
  else () 

(*---------------------------------------------------------------------------*)

let fn_list (map : 'a IdPairMap.t) : string list =
    List.map (fun ((fn,_), _) -> fn) (IdPairMap.bindings map)
  
let typed_spec2singlefiles (ts : typed_spec) : singlefile_typed_spec IdMap.t =
  let typed_spec2singlefile (fn : string) (ts : typed_spec) : singlefile_typed_spec =
    let toIdmap = fun (f,n) e idmap -> if (f=fn) then IdMap.add n e idmap else idmap in
    let dm = IdPairMap.fold toIdmap ts.dir_inter_map IdMap.empty in
    let am = IdPairMap.fold toIdmap ts.adv_inter_map IdMap.empty in
    let fm = IdPairMap.fold toIdmap ts.fun_map IdMap.empty in
    let sm = IdPairMap.fold toIdmap ts.sim_map IdMap.empty in
    { dir_inter_map = dm;
      adv_inter_map = am;
      fun_map = fm;
      sim_map = sm }   
  in
  let fns = 
    (fn_list ts.dir_inter_map)@
    (fn_list ts.adv_inter_map)@
    (fn_list ts.fun_map)@
    (fn_list ts.sim_map) in
  let uniq_fns = IdSet.of_list fns in
  IdSet.fold 
    (fun fn idmap -> IdMap.add fn (typed_spec2singlefile fn ts) idmap) 
    uniq_fns IdMap.empty
  
let generate_ec (ts:typed_spec) : unit =
  let stss = typed_spec2singlefiles ts in
  let (fn, sts) = IdMap.min_binding stss in
  let fn = ec_filename fn in
  remove_file fn;
  let (fo,ppf) = open_formatter fn in
  write_file ppf sts;
  close_formatter (fo,ppf)

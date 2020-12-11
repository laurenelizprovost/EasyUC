(* Univ.ec *)

(* Universe of Values Plus EPDPs *)

prover [""].  (* no use of SMT provers *)

require import AllCore List UCEncoding.

(* universe *)

type univ = bool list.  (* universe values are lists of bits *)

(* we axiomatize the existence of encoding/partial decoding operators
   on the following types

   we could provide concrete definitions, but we won't rely on
   the details, and so we prefer to keep things abstract; of course
   all types being encoded must be countable *)

op epdp_unit_univ : (unit, univ) epdp.  (* unit *)

axiom valid_epdp_unit_univ : valid_epdp epdp_unit_univ.

hint simplify [eqtrue] valid_epdp_unit_univ.
hint rewrite epdp : valid_epdp_unit_univ.

op epdp_bool_univ : (bool, univ) epdp.  (* bool *)

axiom valid_epdp_bool_univ : valid_epdp epdp_bool_univ.

hint simplify [eqtrue] valid_epdp_bool_univ.
hint rewrite epdp : valid_epdp_bool_univ.

op epdp_int_univ : (int, univ) epdp.  (* int *)

axiom valid_epdp_int_univ : valid_epdp epdp_int_univ.

hint simplify [eqtrue] valid_epdp_int_univ.
hint rewrite epdp : valid_epdp_int_univ.

op epdp_univ_pair_univ : (univ * univ, univ) epdp.  (* univ * univ *)

axiom valid_epdp_univ_pair_univ : valid_epdp epdp_univ_pair_univ.

hint simplify [eqtrue] valid_epdp_univ_pair_univ.
hint rewrite epdp : valid_epdp_univ_pair_univ.

op epdp_univ_list_univ : (univ list, univ) epdp.  (* univ list *)

axiom valid_epdp_univ_list_univ : valid_epdp epdp_univ_list_univ.

hint simplify [eqtrue] valid_epdp_univ_list_univ.
hint rewrite epdp : valid_epdp_univ_list_univ.

(* now we can build on these axiomatized encoding/partial decoding
   operators *)

(* triple univ encoding: *)

op nosmt enc_univ_triple (t : univ * univ * univ) : univ =
  epdp_univ_pair_univ.`enc (t.`1, (epdp_univ_pair_univ.`enc (t.`2, t.`3))).

op nosmt dec_univ_triple (u : univ) : (univ * univ * univ) option =
  match epdp_univ_pair_univ.`dec u with
  | None   => None
  | Some p =>
      match epdp_univ_pair_univ.`dec p.`2 with
        None   => None
      | Some q => Some (p.`1, q.`1, q.`2)
      end
  end.

op nosmt epdp_univ_triple_univ : (univ * univ * univ, univ) epdp =
  {|enc = enc_univ_triple; dec = dec_univ_triple|}.

lemma valid_epdp_univ_triple_univ : valid_epdp epdp_univ_triple_univ.
apply epdp_intro => [x | u x].
rewrite /epdp_univ_triple_univ /= /enc_univ_triple /dec_univ_triple.
rewrite !epdp /= !epdp /=.
by case x.
rewrite /epdp_univ_triple_univ /= /enc_univ_triple /dec_univ_triple =>
  match_dec_u_eq_some.
have val_u :
  epdp_univ_pair_univ.`dec u =
  Some (x.`1, epdp_univ_pair_univ.`enc (x.`2, x.`3)).
  move : match_dec_u_eq_some.
  case (epdp_univ_pair_univ.`dec u) => // [[]] x1 q /=.
  move => match_dec_q_eq_some.
  have val_y2 :
    epdp_univ_pair_univ.`dec q = Some (x.`2, x.`3).
    move : match_dec_q_eq_some.
    case (epdp_univ_pair_univ.`dec q) => // [[]] x2 x3 /= <- //.
  move : match_dec_q_eq_some.
  rewrite val_y2 /= => <- /=.
  rewrite (epdp_dec_enc _ _ q) 1:valid_epdp_univ_pair_univ //.
by rewrite (epdp_dec_enc _ _ u) 1:valid_epdp_univ_pair_univ.
qed.

hint simplify [eqtrue] valid_epdp_univ_triple_univ.
hint rewrite epdp : valid_epdp_univ_triple_univ.

(* quadruple univ encoding: *)

op nosmt enc_univ_quadruple (t : univ * univ * univ * univ) : univ =
  epdp_univ_pair_univ.`enc
  (t.`1, (epdp_univ_triple_univ.`enc (t.`2, t.`3, t.`4))).

op nosmt dec_univ_quadruple (u : univ) : (univ * univ * univ * univ) option =
  match epdp_univ_pair_univ.`dec u with
  | None   => None
  | Some p =>
      match epdp_univ_triple_univ.`dec p.`2 with
        None   => None
      | Some q => Some (p.`1, q.`1, q.`2, q.`3)
      end
  end.

op nosmt epdp_univ_quadruple_univ : (univ * univ * univ * univ, univ) epdp =
  {|enc = enc_univ_quadruple; dec = dec_univ_quadruple|}.

lemma valid_epdp_univ_quadruple_univ : valid_epdp epdp_univ_quadruple_univ.
apply epdp_intro => [x | u x].
rewrite /epdp_univ_quadruple_univ /= /enc_univ_quadruple /dec_univ_quadruple /=.
rewrite !epdp /= !epdp /=.
by case x.
rewrite /epdp_univ_quadruple_univ /= /enc_univ_quadruple /dec_univ_quadruple =>
  match_dec_u_eq_some.
have val_u :
  epdp_univ_pair_univ.`dec u =
  Some (x.`1, epdp_univ_triple_univ.`enc (x.`2, x.`3, x.`4)).
  move : match_dec_u_eq_some.
  case (epdp_univ_pair_univ.`dec u) => // [[]] x1 q /=.
  move => match_dec_q_eq_some.
  have val_y2 :
    epdp_univ_triple_univ.`dec q = Some (x.`2, x.`3, x.`4).
    move : match_dec_q_eq_some.
    case (epdp_univ_triple_univ.`dec q) => // [[]] x2 x3 x4 /= <- //.
  move : match_dec_q_eq_some.
  rewrite val_y2 /= => <- /=.
  rewrite (epdp_dec_enc _ _ q) 1:valid_epdp_univ_triple_univ //.
by rewrite (epdp_dec_enc _ _ u) 1:valid_epdp_univ_pair_univ.
qed.

hint simplify [eqtrue] valid_epdp_univ_quadruple_univ.
hint rewrite epdp : valid_epdp_univ_quadruple_univ.

(* quintuple univ encoding: *)

op nosmt enc_univ_quintuple (t : univ * univ * univ * univ * univ) : univ =
  epdp_univ_pair_univ.`enc
  (t.`1, (epdp_univ_quadruple_univ.`enc (t.`2, t.`3, t.`4, t.`5))).

op nosmt dec_univ_quintuple (u : univ) :
    (univ * univ * univ * univ * univ) option =
  match epdp_univ_pair_univ.`dec u with
  | None   => None
  | Some p =>
      match epdp_univ_quadruple_univ.`dec p.`2 with
        None   => None
      | Some q => Some (p.`1, q.`1, q.`2, q.`3, q.`4)
      end
  end.

op nosmt epdp_univ_quintuple_univ :
    (univ * univ * univ * univ * univ, univ) epdp =
  {|enc = enc_univ_quintuple; dec = dec_univ_quintuple|}.

lemma valid_epdp_univ_quintuple_univ : valid_epdp epdp_univ_quintuple_univ.
apply epdp_intro => [x | u x].
rewrite /epdp_univ_quintuple_univ /= /enc_univ_quintuple
        /dec_univ_quintuple /=.
rewrite !epdp /= !epdp /=.
by case x.
rewrite /epdp_univ_quintuple_univ /= /enc_univ_quintuple
        /dec_univ_quintuple => match_dec_u_eq_some.
have val_u :
  epdp_univ_pair_univ.`dec u =
  Some (x.`1, epdp_univ_quadruple_univ.`enc (x.`2, x.`3, x.`4, x.`5)).
  move : match_dec_u_eq_some.
  case (epdp_univ_pair_univ.`dec u) => // [[]] x1 q /=.
  move => match_dec_q_eq_some.
  have val_y2 :
    epdp_univ_quadruple_univ.`dec q = Some (x.`2, x.`3, x.`4, x.`5).
    move : match_dec_q_eq_some.
    case (epdp_univ_quadruple_univ.`dec q) => // [[]] x2 x3 x4 x5 /= <- //.
  move : match_dec_q_eq_some.
  rewrite val_y2 /= => <- /=.
  rewrite (epdp_dec_enc _ _ q) 1:valid_epdp_univ_quadruple_univ //.
by rewrite (epdp_dec_enc _ _ u) 1:valid_epdp_univ_pair_univ.
qed.

hint simplify [eqtrue] valid_epdp_univ_quintuple_univ.
hint rewrite epdp : valid_epdp_univ_quintuple_univ.

(* encoding of 'a * 'b *)

op nosmt enc_pair_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp, p : 'a * 'b) : univ =
  epdp_univ_pair_univ.`enc (epdp1.`enc p.`1, epdp2.`enc p.`2).
  
op nosmt dec_pair_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp, u : univ)
       : ('a * 'b) option =
  match epdp_univ_pair_univ.`dec u with
  | None   => None
  | Some p =>
      match epdp1.`dec p.`1 with
      | None    => None
      | Some x1 =>
          match epdp2.`dec p.`2 with
          | None    => None
          | Some x2 => Some (x1, x2)
          end
      end
  end.

op nosmt epdp_pair_univ (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp)
     : ('a * 'b, univ) epdp =
  {|enc = enc_pair_univ epdp1 epdp2; dec = dec_pair_univ epdp1 epdp2|}.

lemma valid_epdp_pair_univ (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp) :
  valid_epdp epdp1 => valid_epdp epdp2 =>
  valid_epdp (epdp_pair_univ epdp1 epdp2).
proof.  
move => valid1 valid2.
apply epdp_intro => [x | y x].
rewrite /epdp_pair_univ /= /dec_pair_univ /enc_pair_univ.
rewrite !epdp /= !epdp // /=.
by case x.  
rewrite /epdp_pair_univ /= /dec_pair_univ /enc_pair_univ => match_dec_y_eq_some.
have val_y :
  epdp_univ_pair_univ.`dec y = Some (epdp1.`enc x.`1, epdp2.`enc x.`2).
  move : match_dec_y_eq_some.
  case (epdp_univ_pair_univ.`dec y) => // [[]] x1 x2 /=.
  move => match_dec_x1_eq_some.
  have val_x1 : epdp1.`dec x1 = Some x.`1.
    move : match_dec_x1_eq_some.
    case (epdp1.`dec x1) => // x1' /=.
    case (epdp2.`dec x2) => // _ /=.
  rewrite (epdp_dec_enc _ _ x1) //=.
  move : match_dec_x1_eq_some.
  rewrite val_x1 /= => match_dec_x2_eq_some.
  have val_x2 : epdp2.`dec x2 = Some x.`2.
    move : match_dec_x2_eq_some.
    case (epdp2.`dec x2) => // x2' /= <- //.
  rewrite (epdp_dec_enc _ _ x2) //.
by rewrite (epdp_dec_enc _ _ y) 1:valid_epdp_univ_pair_univ.
qed.

hint rewrite epdp_sub : valid_epdp_pair_univ.

(* encoding of 'a * 'b * 'c *)

op nosmt enc_triple_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp, epdp3 : ('c, univ) epdp,
      p : 'a * 'b * 'c) : univ =
  epdp_univ_triple_univ.`enc
  (epdp1.`enc p.`1, epdp2.`enc p.`2, epdp3.`enc p.`3).
  
op nosmt dec_triple_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp,
      epdp3 : ('c, univ) epdp, u : univ) : ('a * 'b * 'c) option =
  match epdp_univ_triple_univ.`dec u with
  | None   => None
  | Some p =>
      match epdp1.`dec p.`1 with
      | None    => None
      | Some x1 =>
          match epdp2.`dec p.`2 with
          | None    => None
          | Some x2 =>
              match epdp3.`dec p.`3 with
              | None    => None
              | Some x3 => Some (x1, x2, x3)
              end
          end
      end
  end.

op nosmt epdp_triple_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp, epdp3 : ('c, univ) epdp)
       : ('a * 'b * 'c, univ) epdp =
  {|enc = enc_triple_univ epdp1 epdp2 epdp3;
    dec = dec_triple_univ epdp1 epdp2 epdp3|}.

lemma valid_epdp_triple_univ
      (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp,
       epdp3 : ('c, univ) epdp) :
  valid_epdp epdp1 => valid_epdp epdp2 => valid_epdp epdp3 =>
  valid_epdp (epdp_triple_univ epdp1 epdp2 epdp3).
proof.  
move => valid1 valid2 valid3.
apply epdp_intro => [x | y x].
rewrite /epdp_triple_univ /= /dec_triple_univ /enc_triple_univ.
rewrite !epdp /= !epdp //=.
by case x.  
rewrite /epdp_triple_univ /= /dec_triple_univ /enc_triple_univ =>
  match_dec_y_eq_some.
have val_y :
  epdp_univ_triple_univ.`dec y =
  Some (epdp1.`enc x.`1, epdp2.`enc x.`2, epdp3.`enc x.`3).
  move : match_dec_y_eq_some.
  case (epdp_univ_triple_univ.`dec y) => // [[]] x1 x2 x3 /=.
  move => match_dec_x1_eq_some.
  have val_x1 : epdp1.`dec x1 = Some x.`1.
    move : match_dec_x1_eq_some.
    case (epdp1.`dec x1) => // x1' /=.
    case (epdp2.`dec x2) => // _ /=.
    case (epdp3.`dec x3) => // _ /=.
  rewrite (epdp_dec_enc _ _ x1) 1:valid1 //=.
  move : match_dec_x1_eq_some.
  rewrite val_x1 /= => match_dec_x2_eq_some.
  have val_x2 : epdp2.`dec x2 = Some x.`2.
    move : match_dec_x2_eq_some.
    case (epdp2.`dec x2) => // x2' /=.
    by case (epdp3.`dec x3) => // _ /= <-.
  rewrite (epdp_dec_enc _ _ x2) 1:valid2 //=.
  move : match_dec_x2_eq_some.
  rewrite val_x2 /= => match_dec_x3_eq_some.
  have val_x3 : epdp3.`dec x3 = Some x.`3.
    move : match_dec_x3_eq_some.
    by case (epdp3.`dec x3) => // x3' /= <-.
  rewrite (epdp_dec_enc _ _ x3) //.
by rewrite (epdp_dec_enc _ _ y) 1:valid_epdp_univ_triple_univ.
qed.

hint rewrite epdp_sub : valid_epdp_triple_univ.

(* encoding of 'a * 'b * 'c * 'd *)

op nosmt enc_quadruple_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp,
      epdp3 : ('c, univ) epdp, epdp4 : ('d, univ) epdp,
      p : 'a * 'b * 'c * 'd) : univ =
  epdp_univ_quadruple_univ.`enc
  (epdp1.`enc p.`1, epdp2.`enc p.`2, epdp3.`enc p.`3, epdp4.`enc p.`4).
  
op nosmt dec_quadruple_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp,
      epdp3 : ('c, univ) epdp, epdp4 : ('d, univ) epdp,
      u : univ) : ('a * 'b * 'c * 'd) option =
  match epdp_univ_quadruple_univ.`dec u with
  | None   => None
  | Some p =>
      match epdp1.`dec p.`1 with
      | None    => None
      | Some x1 =>
          match epdp2.`dec p.`2 with
          | None    => None
          | Some x2 =>
              match epdp3.`dec p.`3 with
              | None    => None
              | Some x3 =>
                  match epdp4.`dec p.`4 with
                  | None    => None
                  | Some x4 => Some (x1, x2, x3, x4)
                  end
              end
          end
      end
  end.

op nosmt epdp_quadruple_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp,
      epdp3 : ('c, univ) epdp, epdp4 : ('d, univ) epdp)
       : ('a * 'b * 'c * 'd, univ) epdp =
  {|enc = enc_quadruple_univ epdp1 epdp2 epdp3 epdp4;
    dec = dec_quadruple_univ epdp1 epdp2 epdp3 epdp4|}.

lemma valid_epdp_quadruple_univ
      (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp,
       epdp3 : ('c, univ) epdp, epdp4 : ('d, univ) epdp) :
  valid_epdp epdp1 => valid_epdp epdp2 => valid_epdp epdp3 =>
  valid_epdp epdp4 =>
  valid_epdp (epdp_quadruple_univ epdp1 epdp2 epdp3 epdp4).
proof.  
move => valid1 valid2 valid3 valid4.
apply epdp_intro => [x | y x].
rewrite /epdp_quadruple_univ /= /dec_quadruple_univ /enc_quadruple_univ.
rewrite !epdp /= !epdp //=.
by case x.  
rewrite /epdp_quadruple_univ /= /dec_quadruple_univ /enc_quadruple_univ =>
  match_dec_y_eq_some.
have val_y :
  epdp_univ_quadruple_univ.`dec y =
  Some (epdp1.`enc x.`1, epdp2.`enc x.`2, epdp3.`enc x.`3, epdp4.`enc x.`4).
  move : match_dec_y_eq_some.
  case (epdp_univ_quadruple_univ.`dec y) => // [[]] x1 x2 x3 x4 /=.
  move => match_dec_x1_eq_some.
  have val_x1 : epdp1.`dec x1 = Some x.`1.
    move : match_dec_x1_eq_some.
    case (epdp1.`dec x1) => // x1' /= match_dec_x2_eq_some.
    have val_x2 : epdp2.`dec x2 = Some x.`2.
      move : match_dec_x2_eq_some.
      case (epdp2.`dec x2) => // x2' /=.
      case (epdp3.`dec x3) => // _ /=.
      case (epdp4.`dec x4) => // _ /=.
    move : match_dec_x2_eq_some.
    rewrite val_x2 /=.
    case (epdp3.`dec x3) => // _ /=.
    by case (epdp4.`dec x4) => // _ /= <-.
  move : match_dec_x1_eq_some.
  rewrite val_x1 => /= match_dec_x2_eq_some.
  rewrite (epdp_dec_enc _ _ x1) //=.
  have val_x2 : epdp2.`dec x2 = Some x.`2. 
    move : match_dec_x2_eq_some.
    case (epdp2.`dec x2) => // x2' /=.
    case (epdp3.`dec x3) => // _ /=.
    by case (epdp4.`dec x4) => // _ /= <-.
  rewrite (epdp_dec_enc _ _ x2) //=.
  move : match_dec_x2_eq_some.
  rewrite val_x2 /= => match_dec_x3_eq_some.
  have val_x3 : epdp3.`dec x3 = Some x.`3.
    move : match_dec_x3_eq_some.
    case (epdp3.`dec x3) => // x3' /=.
    by case (epdp4.`dec x4) => // _ /= <-.
  rewrite (epdp_dec_enc _ _ x3) //=.
  move : match_dec_x3_eq_some.
  rewrite val_x3 /= => match_dec_x4_eq_some.
  have val_x4 : epdp4.`dec x4 = Some x.`4.
    move : match_dec_x4_eq_some.
    by case (epdp4.`dec x4) => // x4' /= <-.
  by rewrite (epdp_dec_enc _ _ x4).
by rewrite (epdp_dec_enc _ _ y) 1:valid_epdp_univ_quadruple_univ.
qed.

hint rewrite epdp_sub : valid_epdp_quadruple_univ.

(* encoding of 'a * 'b * 'c * 'd * 'e *)

op nosmt enc_quintuple_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp,
      epdp3 : ('c, univ) epdp, epdp4 : ('d, univ) epdp,
      epdp5 : ('e, univ) epdp,
      p : 'a * 'b * 'c * 'd * 'e) : univ =
  epdp_univ_quintuple_univ.`enc
  (epdp1.`enc p.`1, epdp2.`enc p.`2, epdp3.`enc p.`3,
   epdp4.`enc p.`4, epdp5.`enc p.`5).
  
op nosmt dec_quintuple_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp,
      epdp3 : ('c, univ) epdp, epdp4 : ('d, univ) epdp,
      epdp5 : ('e, univ) epdp,
      u : univ) : ('a * 'b * 'c * 'd * 'e) option =
  match epdp_univ_quintuple_univ.`dec u with
  | None   => None
  | Some p =>
      match epdp1.`dec p.`1 with
      | None    => None
      | Some x1 =>
          match epdp2.`dec p.`2 with
          | None    => None
          | Some x2 =>
              match epdp3.`dec p.`3 with
              | None    => None
              | Some x3 =>
                  match epdp4.`dec p.`4 with
                  | None    => None
                  | Some x4 =>
                      match epdp5.`dec p.`5 with
                      | None    => None
                      | Some x5 => Some (x1, x2, x3, x4, x5)
                      end
                  end
              end
          end
      end
  end.

op nosmt epdp_quintuple_univ
     (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp,
      epdp3 : ('c, univ) epdp, epdp4 : ('d, univ) epdp,
      epdp5 : ('e, univ) epdp)
       : ('a * 'b * 'c * 'd * 'e, univ) epdp =
  {|enc = enc_quintuple_univ epdp1 epdp2 epdp3 epdp4 epdp5;
    dec = dec_quintuple_univ epdp1 epdp2 epdp3 epdp4 epdp5|}.

lemma valid_epdp_quintuple_univ
      (epdp1 : ('a, univ) epdp, epdp2 : ('b, univ) epdp,
       epdp3 : ('c, univ) epdp, epdp4 : ('d, univ) epdp,
       epdp5 : ('e, univ) epdp) :
  valid_epdp epdp1 => valid_epdp epdp2 => valid_epdp epdp3 =>
  valid_epdp epdp4 => valid_epdp epdp5 =>
  valid_epdp (epdp_quintuple_univ epdp1 epdp2 epdp3 epdp4 epdp5).
proof.  
move => valid1 valid2 valid3 valid4 valid5.
apply epdp_intro => [x | y x].
rewrite /epdp_quintuple_univ /= /dec_quintuple_univ /enc_quintuple_univ.
rewrite !epdp /= !epdp //=.
by case x.  
rewrite /epdp_quintuple_univ /= /dec_quintuple_univ /enc_quintuple_univ =>
  match_dec_y_eq_some.
have val_y :
  epdp_univ_quintuple_univ.`dec y =
  Some (epdp1.`enc x.`1, epdp2.`enc x.`2, epdp3.`enc x.`3,
        epdp4.`enc x.`4, epdp5.`enc x.`5).
  move : match_dec_y_eq_some.
  case (epdp_univ_quintuple_univ.`dec y) => // [[]] x1 x2 x3 x4 x5 /=.
  move => match_dec_x1_eq_some.
  have val_x1 : epdp1.`dec x1 = Some x.`1.
    move : match_dec_x1_eq_some.
    case (epdp1.`dec x1) => // x1' /= match_dec_x2_eq_some.
    have val_x2 : epdp2.`dec x2 = Some x.`2.
      move : match_dec_x2_eq_some.
      case (epdp2.`dec x2) => // x2' /=.
      case (epdp3.`dec x3) => // _ /=.
      case (epdp4.`dec x4) => // _ /=.
      case (epdp5.`dec x5) => // _ /=.
    move : match_dec_x2_eq_some.
    rewrite val_x2 /=.
    case (epdp3.`dec x3) => // _ /=.
    case (epdp4.`dec x4) => // _ /=.
    by case (epdp5.`dec x5) => // _ /= <-.
  move : match_dec_x1_eq_some.
  rewrite val_x1 => /= match_dec_x2_eq_some.
  rewrite (epdp_dec_enc _ _ x1) //=.
  have val_x2 : epdp2.`dec x2 = Some x.`2. 
    move : match_dec_x2_eq_some.
    case (epdp2.`dec x2) => // x2' /=.
    case (epdp3.`dec x3) => // _ /=.
    case (epdp4.`dec x4) => // _ /=.
    by case (epdp5.`dec x5) => // _ /= <-.
  rewrite (epdp_dec_enc _ _ x2) //=.
  move : match_dec_x2_eq_some.
  rewrite val_x2 /= => match_dec_x3_eq_some.
  have val_x3 : epdp3.`dec x3 = Some x.`3.
    move : match_dec_x3_eq_some.
    case (epdp3.`dec x3) => // x3' /=.
    case (epdp4.`dec x4) => // _ /=.
    by case (epdp5.`dec x5) => // _ /= <-.
  rewrite (epdp_dec_enc _ _ x3) //=.
  move : match_dec_x3_eq_some.
  rewrite val_x3 /= => match_dec_x4_eq_some.
  have val_x4 : epdp4.`dec x4 = Some x.`4.
    move : match_dec_x4_eq_some.
    case (epdp4.`dec x4) => // x4' /=.
    by case (epdp5.`dec x5) => // _ /= <-.
  rewrite (epdp_dec_enc _ _ x4) //=.
  move : match_dec_x4_eq_some.
  rewrite val_x4 /= => match_dec_x5_eq_some.
  have val_x5 : epdp5.`dec x5 = Some x.`5.
    move : match_dec_x5_eq_some.
    by case (epdp5.`dec x5) => // x5' /= <-.
  by rewrite (epdp_dec_enc _ _ x5).
by rewrite (epdp_dec_enc _ _ y) 1:valid_epdp_univ_quintuple_univ.
qed.

hint rewrite epdp_sub : valid_epdp_quintuple_univ.

(* encoding of 'a list *)

op nosmt enc_list_univ (epdp : ('a, univ) epdp, xs : 'a list) : univ =
  epdp_univ_list_univ.`enc (map epdp.`enc xs).

op nosmt dec_list_univ
     (epdp : ('a, univ) epdp, u : univ) : 'a list option =
  match epdp_univ_list_univ.`dec u with
    None    => None
  | Some vs =>
      let ys = map epdp.`dec vs
      in if all is_some ys
         then Some (map oget ys)
         else None
  end.

op nosmt epdp_list_univ (epdp : ('a, univ) epdp) : ('a list, univ) epdp =
  {|enc = enc_list_univ epdp; dec = dec_list_univ epdp|}.

lemma valid_epdp_list_univ (epdp : ('a, univ) epdp) :
  valid_epdp epdp => valid_epdp (epdp_list_univ epdp).
proof.  
move => valid.
apply epdp_intro => [xs | y xs].
rewrite /epdp_list_univ /enc_list_univ /dec_list_univ /=.
rewrite !epdp /=.
have -> : map epdp.`dec (map epdp.`enc xs) = map Some xs.
  elim xs => [// | y ys /=].
  rewrite !epdp //.
have -> /= : all is_some (map Some xs) = true.
  elim xs => [// | y ys //].
elim xs => [// | y ys //].
rewrite /epdp_list_univ /enc_list_univ /dec_list_univ /= =>
  match_dec_y_eq_some.
have val_u : epdp_univ_list_univ.`dec y = Some (map epdp.`enc xs).
  move : match_dec_y_eq_some.
  case (epdp_univ_list_univ.`dec y) => // zs /=.
  case (all is_some (map epdp.`dec zs)) => // => all_is_some /= <-.
  move : all_is_some.
  elim zs => [// | w ws IH /= [#] is_some_dec_w all_is_some_dec_ws].
  split.
  rewrite (epdp_dec_enc _ _ w) // -(some_oget (epdp.`dec w)) //.
  move : is_some_dec_w; by case (epdp.`dec w).
  by apply IH.
by rewrite (epdp_dec_enc _ _ y) 1:valid_epdp_univ_list_univ.
qed.

hint rewrite epdp_sub : valid_epdp_list_univ.

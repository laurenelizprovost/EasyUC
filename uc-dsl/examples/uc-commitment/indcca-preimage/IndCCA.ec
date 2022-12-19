(* IndCCA.ec *)

(* This theory describes a public key encryption scheme, capturing
   notion of multiple run IND-CCA security, along with a proof that
   such security implies pre-image security *)

prover quorum=2 ["Z3" "Alt-Ergo"].

require import AllCore Distr List FSet SmtMap FelTactic.
require import StdOrder. import RealOrder.
require import StdBigop. import Bigreal BRA.
require import StdRing. import RField.

(* the type of plain texts has pt_siz elements *)

type plaintext.

op pt_siz : int.

axiom gt0_pt_siz : 0 < pt_siz.

op dplaintext : plaintext distr.

axiom dplaintext_ll : is_lossless dplaintext.

axiom dplaintext1E (x : plaintext) :
  mu1 dplaintext x = 1%r / pt_siz%r.

lemma dplaintext_uni : is_uniform dplaintext.
proof.
move => x y _ _.
by rewrite 2!dplaintext1E.
qed.

lemma dplaintext_fu : is_full dplaintext.
proof.
move => x.
rewrite /support dplaintext1E.
rewrite RField.div1r invr_gt0 lt_fromint gt0_pt_siz.
qed.

(* the type of cipher texts has ct_siz elements *)

type ciphertext.

op ct_siz : int.

axiom gt0_ct_siz : 0 < ct_siz.

op dciphertext : ciphertext distr.

axiom dciphertext_ll : is_lossless dciphertext.

axiom dciphertext1E (x : ciphertext) :
  mu1 dciphertext x = 1%r / ct_siz%r.

lemma dciphertext_uni : is_uniform dciphertext.
proof.
move => x y _ _.
by rewrite 2!dciphertext1E.
qed.

lemma dciphertext_fu : is_full dciphertext.
proof.
move => x.
rewrite /support dciphertext1E.
rewrite RField.div1r invr_gt0 lt_fromint gt0_ct_siz.
qed.

(* the type of random values has rd_siz elements *)

type rand.

op rd_siz : int.

axiom gt0_rd_siz : 0 < rd_siz.

op drand : rand distr.

axiom drand_ll : is_lossless drand.

axiom drand1E (x : rand) :
  mu1 drand x = 1%r / rd_siz%r.

lemma drand_uni : is_uniform drand.
proof.
move => x y _ _.
by rewrite 2!drand1E.
qed.

lemma drand_fu : is_full drand.
proof.
move => x.
rewrite /support drand1E.
rewrite RField.div1r invr_gt0 lt_fromint gt0_rd_siz.
qed.

(* public/secret key pairs *)

type pkey.  (* public key *)
type skey.  (* secret key *)

(* lossless distribution on key pairs *)

op dkeygen : (pkey * skey) distr.

axiom keygen_ll : is_lossless dkeygen.

(* test if key pair is in support of dkeygen *)

op valid_keys (keys : pkey * skey) : bool = support dkeygen keys.

(* encrypt plain text relative to randomness *)

op enc (pk : pkey, m : plaintext, r : rand) : ciphertext.

(* decrypt cipher text (randomness not needed); returns None
   when decryption fails, i.e., cipher text is invalid *)

op dec (sk : skey, c : ciphertext) : plaintext option.

(* correctness of encryption scheme *)

axiom correctness (pk : pkey, sk : skey, m : plaintext, r : rand):
  valid_keys (pk, sk) => dec sk (enc pk m r) = Some m.

(* if a cipher text decrypts to a plain text, that plain text
   encrypts to the cipher text for some randomness *)

axiom dec_suceeds (pk : pkey, sk : skey, m : plaintext, c : ciphertext) :
  valid_keys (pk, sk) => dec sk c = Some m =>
  exists (r : rand), enc pk m r = c.

(* if decrypting a cipher text fails, encryption is incapable
   of producing the cipher text from any plain text and randomness *)

lemma dec_fails (pk : pkey, sk : skey, c : ciphertext) :
  valid_keys (pk, sk) => dec sk c = None =>
  forall (m : plaintext, r : rand), enc pk m r <> c.
proof.
move => vk_pk_sk dec_sk_c_eq_None m r.
case (enc pk m r = c) => [enc_pk_m_r_eq_c | //].
have dec_sk_c_eq_Some_m : dec sk c = Some m.
  by rewrite -enc_pk_m_r_eq_c correctness.
by rewrite dec_sk_c_eq_None in dec_sk_c_eq_Some_m.
qed.

(* oblivious encryption of randomness, plus inverse *)

op obliv_enc(pk : pkey, r : rand) : ciphertext.
op obliv_enc_inv(pk : pkey, c : ciphertext) : rand.

(* obliv_enc pk is a bijection, and so rand and ciphertext have
   the same size *)

axiom obliv_enc_bij (pk : pkey, r : rand):
  obliv_enc_inv pk (obliv_enc pk r) = r.
axiom obliv_enc_inv_bij (pk : pkey, c : ciphertext):
  obliv_enc pk (obliv_enc_inv pk c) = c.




lemma eq_ct_siz_rd_siz (pk : pkey, sk : skey) :
  valid_keys (pk, sk) => dmap drand (obliv_enc pk) = dciphertext.
proof.
move => vk_pk_sk.
rewrite (dmap_bij drand dciphertext (obliv_enc pk) (obliv_enc_inv pk)).
move => x _; rewrite dciphertext_fu.
move => x _.
rewrite dciphertext1E.
rewrite drand1E.






rewrite -(in_dmap1E_can drand (obliv_enc pk) (obliv_enc_inv pk)).
by rewrite obliv_enc_inv_bij.
move => y _ <-; by rewrite obliv_enc_bij.


















(* IND-CCA oracle *)

(* number of runs of enc before default cipher text, def_ct, returned *)

op runs : int.

axiom ge0_runs : 0 <= runs.

op def_ct : ciphertext.

module type OR_INDCCA = {
  (* initialization, given key pair *)

  proc init(keys : pkey * skey) : unit

  (* encrypt a plaintext using stored public key and fresh randomness *)

  proc enc(m : plaintext) : ciphertext

  (* decrypt a cipher text, yielding optional plaintext that is
     None if c was previously produced by enc, and is
     the decryption using stored secret key, otherwise *)

  proc dec(c : ciphertext) : plaintext option
}.

(* we have two oracle implementations *)

module OrIndCCA1 : OR_INDCCA = {
  var pk  : pkey
  var sk  : skey
  var cs  : ciphertext fset
  var ctr : int

  proc init(pk_ : pkey, sk_ : skey) : unit = {
    pk <- pk_; sk <- sk_; cs <- fset0; ctr <- 0;
  }

  proc enc(m : plaintext) : ciphertext = {
    var r : rand; var c : ciphertext;
    if (ctr < runs) {
      r <$ drand;
      c <- enc pk m r;  (* normal encryption *)
      cs <- cs `|` fset1 c;
      ctr <- ctr + 1;
    }
    else {
      c <- def_ct;
    }
    return c;
  }

  proc dec(c : ciphertext) : plaintext option = {
    var x : plaintext option;
    if (mem cs c) {
      x <- None;
    }
    else {
      x <- dec sk c;  (* normal decryption *)
    }
    return x;
  }
}.

module OrIndCCA2 : OR_INDCCA = {
  var pk  : pkey
  var sk  : skey
  var cs  : ciphertext fset
  var ctr : int

  proc init(pk_ : pkey, sk_ : skey) : unit = {
    pk <- pk_; sk <- sk_; cs <- fset0; ctr <- 0;
  }

  proc enc(m : plaintext) : ciphertext = {
    var r : rand; var c : ciphertext;
    if (ctr < runs) {
      r <$ drand;
      c <- obliv_enc pk r;  (* oblivious encryption *)
      cs <- cs `|` fset1 c;
      ctr <- ctr + 1;
    }
    else {
      c <- def_ct;
    }
    return c;
  }

  proc dec(c : ciphertext) : plaintext option = {
    var x : plaintext option;
    if (mem cs c) {
      x <- None;
    }
    else {
      x <- dec sk c;  (* normal decryption *)
    }
    return x;
  }
}.

(* IND-CCA adversary, parameterized by IND-CCA oracle

   is given public key, and returns boolean judgment;
   it may not reinitialize oracle *)

module type ADV_INDCCA (Or : OR_INDCCA) = {
  proc main(pk : pkey) : bool {Or.enc, Or.dec}
}.

module IndCCA(Or : OR_INDCCA, Adv : ADV_INDCCA) = {
  module A = Adv(Or)  (* connect adversary and oracle *)

  proc main() : bool = {
    var pk : pkey; var sk : skey;
    var b : bool;
    (pk, sk) <$ dkeygen;  (* generate keypair *)
    Or.init(pk, sk);      (* initialize oracle *)
    b <@ A.main(pk);      (* invoke adversary, which returns judgment *)
    return b;
  }
}.

(* apply IndCCA to the two INDCCA oracle implementations, yielding
   the two IND-CCA games: *)

module IndCCA1 = IndCCA(OrIndCCA1).
module IndCCA2 = IndCCA(OrIndCCA2).

(* The *advantage* of an IND-CCA adversary Adv is

   `|Pr[IndCCA1(Adv).main() @ &m : res] - Pr[IndCCA2(Adv).main() @ &m : res]|
*)

(* pre-image security *)

module type OR_PI = {
  (* initialization, given key pair *)

  proc init(keys : pkey * skey) : unit

  (* obliviously generate a cipher text using stored public key
     and fresh randomness *)

  proc obliv() : ciphertext

  (* decrypt a cipher text, yielding optional plaintext that is None
     if c was previously produced by obliv, and is the decryption
     using stored secret key, otherwise *)

  proc dec(c : ciphertext) : plaintext option

  (* test whether enc of stored public key, x and r yields
     one of the ciphertexts previously produced by obliv *)

  proc check_preimage(x : plaintext, r : rand) : bool
}.

module OrPI : OR_PI = {
  var pk  : pkey
  var sk  : skey
  var cs  : ciphertext fset
  var ctr : int

  proc init(pk_ : pkey, sk_ : skey) : unit = {
    pk <- pk_; sk <- sk_; cs <- fset0; ctr <- 0;
  }

  proc obliv() : ciphertext = {
    var r : rand; var c : ciphertext;
    if (ctr < runs) {
      r <$ drand;
      c <- obliv_enc pk r;
      cs <- cs `|` fset1 c;
      ctr <- ctr + 1;
    }
    else {
      c <- def_ct;
    }
    return c;
  }

  proc dec(c : ciphertext) : plaintext option = {
    var x : plaintext option;
    if (mem cs c) {
      x <- None;
    }
    else {
      x <- dec sk c;
    }
    return x;
  }

  proc check_preimage(x : plaintext, r : rand) : bool = {
    return enc pk x r \in cs;
  }
}.

module type ADV_PI (Or : OR_PI) = {
  proc main(pk : pkey) : plaintext * rand {Or.obliv, Or.dec}
}.

module PreImage(Adv : ADV_PI) = {
  module A = Adv(OrPI)  (* connect adversary and oracle *)

  proc main() : bool = {
    var pk : pkey; var sk : skey;
    var x : plaintext; var r : rand;
    var b : bool;
    (pk, sk) <$ dkeygen;             (* generate keypair *)
    OrPI.init(pk, sk);               (* initialize oracle *)
    (x, r) <@ A.main(pk);            (* invoke adversary *)
    b <@ OrPI.check_preimage(x, r);  (* see if adversary won *)
    return b;
  }
}.

op pt_ex : plaintext.

op mu_obliv_enc_dec_exact (pk : pkey, sk : skey, m : plaintext) =
  mu drand (fun r => dec sk (obliv_enc pk r) = Some m).

op mu_obliv_enc_dec_exact_ub : real.

lemma mu_obliv_enc_dec_exact_ub (m : plaintext, pk : pkey, sk : skey) :
  valid_keys (pk, sk) =>
  mu_obliv_enc_dec_exact pk sk  m <= mu_obliv_enc_dec_exact_ub.
proof.
admit.
qed.

module AdvPI2IndCCAAdv(AdvPI : ADV_PI, IndCCAOr : OR_INDCCA) = {
  module OrPI : OR_PI = {
    var pk  : pkey
    var cs  : ciphertext fset
    var ctr : int

    (* sk_ won't be real: *)

    proc init(pk_ : pkey, sk_ : skey) : unit = {
      pk <- pk_; cs <- fset0; ctr <- 0;
    }

    proc obliv() : ciphertext = {
      var r : rand; var c : ciphertext;
      if (ctr < runs) {
        c <@ IndCCAOr.enc(pt_ex);
        cs <- cs `|` fset1 c;
        ctr <- ctr + 1;
      }
      else {
        c <- def_ct;
      }
      return c;
    }

    proc dec(c : ciphertext) : plaintext option = {
      var x : plaintext option;
      x <@ IndCCAOr.dec(c);
      return x;
    }

    proc check_preimage(x : plaintext, r : rand) : bool = {
      return enc pk x r \in cs /\ x <> pt_ex;
    }
  }

  module A = AdvPI(OrPI)

  proc main(pk : pkey) : bool = {
    var b : bool; var x : plaintext; var r : rand;
    OrPI.init(pk, witness);
    (x, r) <@ A.main(pk);
    b <@ OrPI.check_preimage(x, r);
    return b;
  }
}.

section.

declare module
  AdvPI <: ADV_PI{-OrPI, -OrIndCCA1, -OrIndCCA2, -AdvPI2IndCCAAdv}.

local module OrPI_bad1 : OR_PI = {
  var pk  : pkey
  var sk  : skey
  var cs  : ciphertext fset
  var ctr : int
  var bad : bool

  proc init(pk_ : pkey, sk_ : skey) : unit = {
    pk <- pk_; sk <- sk_; cs <- fset0; ctr <- 0; bad <- false;
  }

  proc obliv() : ciphertext = {
    var r : rand; var c : ciphertext;
    if (ctr < runs) {
      r <$ drand;
      c <- obliv_enc pk r;
      cs <- cs `|` fset1 c;
      ctr <- ctr + 1;
    }
    else {
      c <- def_ct;
    }
    return c;
  }

  proc dec(c : ciphertext) : plaintext option = {
    var x : plaintext option;
    if (mem cs c) {
      x <- None;
    }
    else {
      x <- dec sk c;
    }
    return x;
  }

  proc check_preimage(x : plaintext, r : rand) : bool = {
    var b : bool;
    if (enc pk x r \in cs) {
      b <- true;
      if (x = pt_ex) {
        bad <- true;
      }
    }
    else {
      b <- false;
    }
    return b;
  }
}.

local module PI_bad1 = {
  module A = AdvPI(OrPI_bad1)

  proc main() : bool = {
    var pk : pkey; var sk : skey;
    var x : plaintext; var r : rand;
    var b : bool;
    (pk, sk) <$ dkeygen;
    OrPI_bad1.init(pk, sk);
    (x, r) <@ A.main(pk);
    b <@ OrPI_bad1.check_preimage(x, r);
    return b;
  }
}.

local lemma PreImage_Adv_PI_bad1 &m :
  Pr[PreImage(AdvPI).main() @ &m : res] = Pr[PI_bad1.main() @ &m : res].
proof.
byequiv => //; proc.
call (_ : ={pk, sk, cs, ctr}(OrPI, OrPI_bad1)); first auto.
call (_ : ={pk, sk, cs, ctr}(OrPI, OrPI_bad1)); first 2 sim.
call (_ : ={pk_, sk_} ==> ={pk, sk, cs, ctr}(OrPI, OrPI_bad1)); first sim.
auto.
qed.

local module OrPI_bad2 : OR_PI = {
  var pk  : pkey
  var sk  : skey
  var cs  : ciphertext fset
  var ctr : int
  var bad : bool

  proc init(pk_ : pkey, sk_ : skey) : unit = {
    pk <- pk_; sk <- sk_; cs <- fset0; ctr <- 0; bad <- false;
  }

  proc obliv() : ciphertext = {
    var r : rand; var c : ciphertext;
    if (ctr < runs) {
      r <$ drand;
      c <- obliv_enc pk r;
      cs <- cs `|` fset1 c;
      ctr <- ctr + 1;
    }
    else {
      c <- def_ct;
    }
    return c;
  }

  proc dec(c : ciphertext) : plaintext option = {
    var x : plaintext option;
    if (mem cs c) {
      x <- None;
    }
    else {
      x <- dec sk c;
    }
    return x;
  }

  proc check_preimage(x : plaintext, r : rand) : bool = {
    var b : bool;
    if (enc pk x r \in cs) {
      if (x = pt_ex) {
        b <- false;
        bad <- true;
      }
      else {
        b <- true;
      }
    }
    else {
      b <- false;
    }
    return b;
  }
}.

local module PI_bad2 = {
  module A = AdvPI(OrPI_bad2)

  proc main() : bool = {
    var pk : pkey; var sk : skey;
    var x : plaintext; var r : rand;
    var b : bool;
    (pk, sk) <$ dkeygen;
    OrPI_bad2.init(pk, sk);
    (x, r) <@ A.main(pk);
    b <@ OrPI_bad2.check_preimage(x, r);
    return b;
  }
}.

local lemma PI_bad1_2 &m :
  `|Pr[PI_bad1.main() @ &m : res] - Pr[PI_bad2.main() @ &m : res]| <=
  Pr[PI_bad2.main() @ &m : OrPI_bad2.bad].
proof.
byequiv
  (_ :
   ={glob AdvPI} ==>
   ={bad}(OrPI_bad1, OrPI_bad2) /\ (! OrPI_bad2.bad{2} => ={res})) :
  OrPI_bad1.bad => //.
proc.
seq 3 3 : (={x, r} /\ ={pk, sk, cs, ctr, bad}(OrPI_bad1, OrPI_bad2)).
call (_ : ={pk, sk, cs, ctr, bad}(OrPI_bad1, OrPI_bad2)); first 2 sim.
call
  (_ :
   ={pk_, sk_} ==>
   ={pk, sk, cs, ctr, bad}(OrPI_bad1, OrPI_bad2)); first sim.
auto.
inline*; auto.
smt().
qed.

local lemma PreImage_Adv_PI_bad2 &m :
  `|Pr[PreImage(AdvPI).main() @ &m : res] -
    Pr[PI_bad2.main() @ &m : res]| <=
  Pr[PI_bad2.main() @ &m : OrPI_bad2.bad].
proof.
rewrite (PreImage_Adv_PI_bad1 &m) (PI_bad1_2 &m).
qed.

local module PI_bad_ub = {
  module Or : OR_PI  = {
    var pk  : pkey
    var sk  : skey
    var cs  : ciphertext fset
    var ctr : int
    var bad : bool

    proc init(pk_ : pkey, sk_ : skey) : unit = {
      pk <- pk_; sk <- sk_; cs <- fset0; ctr <- 0; bad <- false;
    }

    proc obliv() : ciphertext = {
      var r : rand; var c : ciphertext;
      if (ctr < runs) {
        r <$ drand;
        c <- obliv_enc pk r;
        if (dec sk c = Some pt_ex) {
          bad <- true;
        }
        cs <- cs `|` fset1 c;
        ctr <- ctr + 1;
      }
      else {
        c <- def_ct;
      }
      return c;
    }

    proc dec(c : ciphertext) : plaintext option = {
      var x : plaintext option;
      if (mem cs c) {
        x <- None;
      }
      else {
        x <- dec sk c;
      }
      return x;
    }

    (* not used: *)

    proc check_preimage(x : plaintext, r : rand) : bool = {
      return true;
    }
  }

  module A = AdvPI(Or)

  proc main() : bool = {
    var pk : pkey; var sk : skey;
    var x : plaintext; var r : rand;
    var b : bool;
    (pk, sk) <$ dkeygen;
    Or.init(pk, sk);
    (x, r) <@ A.main(pk);
    return Or.bad;
  }
}.

local lemma PI_bad2_ub &m :
  Pr[PI_bad2.main() @ &m : OrPI_bad2.bad] <=
  Pr[PI_bad_ub.main() @ &m : PI_bad_ub.Or.bad].
proof.
byequiv => //.
proc.
seq 2 2 : 
  (={pk, sk, glob AdvPI} /\
   ={pk, sk, cs, ctr, bad}(OrPI_bad2, PI_bad_ub.Or) /\
   pk{1} = OrPI_bad2.pk{1} /\ sk{1} = OrPI_bad2.sk{1} /\
   OrPI_bad2.cs{1} = fset0 /\ valid_keys (pk{1}, sk{1}) /\
   ! OrPI_bad2.bad{1}).
inline OrPI_bad2.init PI_bad_ub.Or.init.
auto; smt().
inline OrPI_bad2.check_preimage; wp => /=.
call
  (_ :
   ={pk, sk, cs, ctr}(OrPI_bad2, PI_bad_ub.Or) /\
   ! OrPI_bad2.bad{1} /\
   ((exists c, c \in PI_bad_ub.Or.cs{2} /\
     dec PI_bad_ub.Or.sk{2} c = Some pt_ex) =>
    PI_bad_ub.Or.bad{2})).
proc.
if => //.
auto; smt(in_fsetU in_fset1).
auto.
proc; auto.
auto; smt(in_fset0 correctness).
qed.

local lemma PI_bad_ub_concrete &m :
  Pr[PI_bad_ub.main() @ &m : PI_bad_ub.Or.bad] <=
  mu_obliv_enc_dec_exact_ub * runs%r.
proof.
fel
  2
  PI_bad_ub.Or.ctr
  (fun n => mu_obliv_enc_dec_exact_ub)
  runs
  PI_bad_ub.Or.bad
  [PI_bad_ub.Or.obliv : (PI_bad_ub.Or.ctr < runs);
   PI_bad_ub.Or.dec : false]
  (PI_bad_ub.Or.ctr <= runs /\
   valid_keys (PI_bad_ub.Or.pk, PI_bad_ub.Or.sk)).
(* sum <= bound *)
rewrite sumr_const intmulr count_predT size_range /=.
by rewrite IntOrder.ler_maxr 1:ge0_runs.
(* invariant good *)
trivial.
(* initialization *)
inline*; auto; smt(ge0_runs).
(* obliv bad set prob *)
proc.
if.
wp.
rnd
  (fun r =>
     dec PI_bad_ub.Or.sk (obliv_enc PI_bad_ub.Or.pk r) = Some pt_ex).
skip; progress.
by apply mu_obliv_enc_dec_exact_ub.
smt().
auto.
(* obliv precondition true, preservation *)
move => c; proc.
rcondt 1; first auto.
auto; smt().
(* obliv precondition false, preservation *)
move => b c; proc.
rcondf 1; first auto.
auto.
qed.

local lemma PreImage_Adv_PI_bad2_ub &m :
  `|Pr[PreImage(AdvPI).main() @ &m : res] -
    Pr[PI_bad2.main() @ &m : res]| <=
    mu_obliv_enc_dec_exact_ub * runs%r.
proof.
rewrite (ler_trans Pr[PI_bad2.main() @ &m : OrPI_bad2.bad]).
rewrite (PreImage_Adv_PI_bad2 &m).
rewrite (ler_trans Pr[PI_bad_ub.main() @ &m : PI_bad_ub.Or.bad]).
rewrite (PI_bad2_ub &m).
rewrite (PI_bad_ub_concrete &m).
qed.

local lemma PI_bad2_IndCCA2_AdvPI2IndCCAAdv_AdvPI &m :
  Pr[PI_bad2.main() @ &m : res] =
  Pr[IndCCA2(AdvPI2IndCCAAdv(AdvPI)).main() @ &m : res].
proof.
byequiv => //.
proc.
seq 2 2 : 
  (={pk, sk, glob AdvPI} /\
   ={pk, sk, cs, ctr}(OrPI_bad2, OrIndCCA2) /\
   pk{1} = OrPI_bad2.pk{1} /\ OrPI_bad2.cs{1} = fset0 /\
   OrPI_bad2.ctr{1} = 0).
inline*; auto.
inline*.
wp.
sp.
call
  (_ :
   ={pk, cs, ctr}(OrPI_bad2, AdvPI2IndCCAAdv.OrPI) /\
   ={pk, sk, cs, ctr}(OrPI_bad2, OrIndCCA2)).
proc.
inline*.
if => //.
rcondt{2} 2; first auto.
auto.
auto.
proc.
inline OrIndCCA2.dec.
auto.
auto.
qed.

local lemma IndCCA1_AdvPI2IndCCAAdv_AdvPI_0 &m :
  Pr[IndCCA1(AdvPI2IndCCAAdv(AdvPI)).main() @ &m : res] = 0%r.
proof.
byphoare => //; proc; hoare.
seq 2 :
  (pk = OrIndCCA1.pk /\ sk = OrIndCCA1.sk /\ valid_keys (pk, sk) /\
   OrIndCCA1.cs = fset0 /\ OrIndCCA1.ctr = 0).
inline*; auto; smt().
inline*; wp.
seq 6 :
  (AdvPI2IndCCAAdv.OrPI.pk = OrIndCCA1.pk /\
   AdvPI2IndCCAAdv.OrPI.cs = OrIndCCA1.cs /\
   AdvPI2IndCCAAdv.OrPI.ctr = OrIndCCA1.ctr /\
   pk0 = OrIndCCA1.pk /\ valid_keys (OrIndCCA1.pk, OrIndCCA1.sk) /\
   OrIndCCA1.ctr = 0 /\ OrIndCCA1.cs = fset0).
auto.
conseq
  (_ :
   _ ==>
   enc AdvPI2IndCCAAdv.OrPI.pk x r \notin AdvPI2IndCCAAdv.OrPI.cs \/
   x = pt_ex).
move => /> &hr _ cs r1 x1.
by rewrite negb_and.
call
  (_ :
   AdvPI2IndCCAAdv.OrPI.pk = OrIndCCA1.pk /\
   AdvPI2IndCCAAdv.OrPI.cs = OrIndCCA1.cs /\
   AdvPI2IndCCAAdv.OrPI.ctr = OrIndCCA1.ctr /\
   valid_keys (OrIndCCA1.pk, OrIndCCA1.sk) /\
   0 <= OrIndCCA1.ctr <= runs /\
   (forall c,
    c \in OrIndCCA1.cs =>
    exists r, c = enc OrIndCCA1.pk pt_ex r)).
proc.
if.
wp.
inline*.
rcondt 2.
auto.
auto.
progress.
smt().
smt().
rewrite in_fsetU in_fset1 in H5.
elim H5 => [c1_in_cs | ->].
by rewrite H2.
by exists r00.
auto.
proc; inline *; auto.
auto; progress.
rewrite ge0_runs.
smt(in_fset0).
case (enc OrIndCCA1.pk{hr} result.`1 result.`2 \in cs0) =>
  [/= enc_in_cs0 | //].
have [r1 enc_eq] :
  exists (r1 : rand),
  enc OrIndCCA1.pk{hr} result.`1 result.`2 =
  enc OrIndCCA1.pk{hr} pt_ex r1.
  by apply H6.
have A :
  dec OrIndCCA1.sk{hr} (enc OrIndCCA1.pk{hr} result.`1 result.`2) =
  Some result.`1.
  by rewrite correctness.
have B :
  dec OrIndCCA1.sk{hr} (enc OrIndCCA1.pk{hr} pt_ex r1) = Some pt_ex.
  by rewrite correctness.
rewrite -enc_eq in B.
rewrite A /= in B.
by rewrite B.
qed.

local lemma PI_bad2_0 &m :
  `|Pr[PI_bad2.main() @ &m : res] - 0%r| <=
  `|Pr[IndCCA1(AdvPI2IndCCAAdv(AdvPI)).main() @ &m : res] -
    Pr[IndCCA2(AdvPI2IndCCAAdv(AdvPI)).main() @ &m : res]|.
proof.
rewrite RealOrder.distrC.
rewrite IndCCA1_AdvPI2IndCCAAdv_AdvPI_0.
by rewrite PI_bad2_IndCCA2_AdvPI2IndCCAAdv_AdvPI.
qed.

lemma PreImage_AdvPI_sec &m :
  Pr[PreImage(AdvPI).main() @ &m : res] <=
  mu_obliv_enc_dec_exact_ub * runs%r +
  `|Pr[IndCCA1(AdvPI2IndCCAAdv(AdvPI)).main() @ &m : res] -
    Pr[IndCCA2(AdvPI2IndCCAAdv(AdvPI)).main() @ &m : res]|.
proof.
have -> :
  Pr[PreImage(AdvPI).main() @ &m : res] =
  `|Pr[PreImage(AdvPI).main() @ &m : res] - 0%r|.
  by rewrite /= ger0_norm 1:Pr [mu_ge0].
rewrite
  (ler_trans
   (`|Pr[PreImage(AdvPI).main() @ &m : res] - Pr[PI_bad2.main() @ &m : res] | +
    `|Pr[PI_bad2.main() @ &m : res] - 0%r|)).
rewrite ler_dist_add.
rewrite ler_add.
rewrite (PreImage_Adv_PI_bad2_ub &m).
rewrite (PI_bad2_0 &m).
qed.

end section.

lemma PreImage_AdvPI_securty
      (AdvPI <: ADV_PI{-OrPI, -OrIndCCA1, -OrIndCCA2, -AdvPI2IndCCAAdv})
      &m :
  Pr[PreImage(AdvPI).main() @ &m : res] <=
  mu_obliv_enc_dec_exact_ub * runs%r +
  `|Pr[IndCCA1(AdvPI2IndCCAAdv(AdvPI)).main() @ &m : res] -
    Pr[IndCCA2(AdvPI2IndCCAAdv(AdvPI)).main() @ &m : res]|.
proof.
apply (PreImage_AdvPI_sec AdvPI &m).
qed.

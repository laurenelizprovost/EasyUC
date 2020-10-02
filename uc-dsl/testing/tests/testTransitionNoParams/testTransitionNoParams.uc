ec_requires KeysExponentsAndPlainTexts.

direct a {
in  x@bla()
out bli()@x
}

direct A {A:a}

functionality F() implements A {

 party P serves A {

  initial state I {
   match message with
    sender@* => {send bli()@sender and transition II.}
   end
  }
 
  state II(k:key) {
   match message with
    * => {fail.}
   end
  }
 }
}

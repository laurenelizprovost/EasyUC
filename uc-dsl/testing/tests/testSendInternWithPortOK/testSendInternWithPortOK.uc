ec_requires KeysExponentsAndPlainTexts.

direct d {
in  x@bla()
out bli()@x
}

direct D {D:d}

functionality F(G:D) implements D {

 party P serves D.D {

  initial state I {
   match message with
     x@D.D.bla() => {send D.D.bli()@x and transition I.}
   | * => {fail.}
   end
  }
 }
}

direct D_ {
in  x@bla()
out bli()@x
}

direct D {D:D_}

adversarial Iio {
in  bla()
out bli()
}

direct D2_ {
in  x@bla2()
out bli2()@x
}

direct D2 {D2:D2_}

adversarial A_ {
in  abla()
out abli()
}

adversarial A {A:A_}

adversarial A2_ {
in  abla2()
out abli2()
}

adversarial A2 {A2:A2_}

functionality Q() implements D2 A2_ {

  initial state In {
  match message with * => {fail.} end
  }
}

functionality R(F:D) implements D A {

 subfun SFQ=Q
 
 party P serves D.D A.A {
  initial state In {
  match message with * => {fail.} end
  }
 }
}

functionality I() implements D Iio {

  initial state In {
  match message with *  => {fail.} end
  }
}

simulator S uses Iio simulates R(I) {

 initial state In {
  match message with Iio.* => {fail.} end
 }

 state II() {
  match message with R.F.D.D.bla() => {fail.} end
 }

}

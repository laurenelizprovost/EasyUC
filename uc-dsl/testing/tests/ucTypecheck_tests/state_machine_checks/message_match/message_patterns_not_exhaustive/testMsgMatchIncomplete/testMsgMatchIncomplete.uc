direct D' {
in x@bla()
out bli()@x
}

direct D {D:D'}

adversarial I {
in  bla()
in  blb()
out bli()
}

functionality S() implements D I {

  initial state Is 
  {
   match message with
    p@ D.D.bla => {fail.}
   | I.bla => {fail.}
   end
  }
 
}


;Autojoin sfruttando quello del Mirc
;autore kibo

;Quest'addon è stata sviluppata da kibo per il ProScript ver 0.1
;si ringrazia Sagitt per l'idea e per il "sostegno morale" :-D

alias ProJoin { .dialog -m DProJoin DProJoin }

alias print_fav {
  ;if (!$1) { echo -s Errore nei parametri | return 1 }
  var %x = $mircdir $+ mirc.ini
  var %i = 0 , %max = $maxn()
  while (%i != %max) {
    echo -s $readini(%x,chanfolder,n $+ [ %i ])
    inc %i
  }
}

;stampa il numero di preferiti serve per ciclare
alias maxn {
  var %i = 0
  var %c1 = 1 , %c2 = 2
  var %x = $mircdir $+ mirc.ini
  while (%c1 < %c2) {
    if ($readini(%x,chanfolder,n $+ [ %i ]) == $null) {
      return %i
      halt   
    }
    inc %i
  }
}

;alias inserire un server
;bisogna passare come argomento il server che si vuole aggiungere in questo
;formato

;sintassi senza autojoin
;/add_chan #canale
;sintassi con autojoin
;/add_chan #canale AutoJ

alias add_chan {
  var %pos = $maxn()
  var %nq = n $+ %pos
  if ($2 != AutoJ) { writeini mirc.ini chanfolder %nq $1 }
  else { var %par = $1 $+ , $+ , $+ , $+ , $+ 1 | writeini mirc.ini chanfolder %nq %par } 
}

;cancelliamo
;$1 = canale da cancellare
alias delete_chan {
  ;Verifichiamo che il canale esiste
  if ($find_chan($1) != 1) { echo -s 7>>Il canale che vuoi cancellare non esiste | halt }
  else {
    fun_delete $find_chan($1,sel)
  }

}

alias find_chan {
  var %x = $mircdir $+ mirc.ini
  var %i = 0 , %max = $maxn()
  var %trovato = 0
  var %zaz = 1
  while (%i != %max && %trovato != 1) {
    if ($gettok($readini(%x,chanfolder,n $+ [ %zaz ]),1,44) == $1 ) {
      %trovato = 1
    }
    inc %i
    inc %zaz
  }
  return %trovato
}


alias fun_delete {
  window -ah @win_fav

  var %x = $mircdir $+ mirc.ini
  var %i = 0 , %max = $maxn()
  var %p = 0
  var %zaz = 0
  ;ciclo per memorizzare in una finestra temporanea tutti i canali preferiti
  while (%i != %max) {
    if ($gettok($readini(%x,chanfolder,n $+ [ %i ]),1,44) == $1) { inc %i }
    else { aline @win_fav $readini(%x,chanfolder,n $+ [ %i ]) | inc %i }
  }

  ;cancelliamo tutta la lista

  while (%p != %max) {
    var %nq = n $+ %p
    writeini mirc.ini chanfolder %nq $chr(44)
    inc %p
  }

  ;Riscriviamo tutta la lista
  %p = 1

  while (%p <= $line(@win_fav,0)) {
    var %nq = n $+ %p
    writeini mirc.ini chanfolder %nq $line(@win_fav,%p)
    inc %p
  }

  ;Cancelliamo i dati nella finestra
  var %wi = 0
  var %wix = $lines(0)
  while (%wix != 0) {
    dline @win_fav %wi
    inc %wi
    dec %wix
  }
  window -c @win_fav
}
;Dialog

dialog DProJoin {
  title "ProScript AutoJoin"
  size  -1 -1 120 55
  option dbu notheme
  box "ProScript AutoJoin", 1, 1 0 118 55
  button "Esci", 4, 85 40 30 10, ok
  button "Aggiungi", 19, 15 40 30 10,
  button "Cancella", 33, 50 40 30 10,
  text "Canale: es #canale", 9, 20 20 60 20
  edit "", 10, 20 30 50 9, return autohs
  box "", 12, 1 109 172 18
  list 18, 2 8 169 100, hide size
}

;Aggiungiamo canale all'autojoin

on *:dialog:DProJoin:*:*:{
  if ($devent == sclick) {
    if ($did == 19 && $did(10).text != $null) {
      if ($left($did(10).text,1)* iswm $chr(35)) {
        echo -s Il canale 7 $did(10).text 9 e' stato aggiunto all'autojoin
        add_chan $did(10).text AutoJ
        .did -r $dname 10
      }
      else { echo -s Inserire $+ $chr(32) $+ $chr(35) $+ $chr(32) $+ prima del nome del canale }
    }
    if ($did == 33 && $did(10).text != $null) {
      if ($find_chan($did(10).text) == 1) { ;Canale trovato
        echo -s Il canale 7 $did(10).text 9 e' stato cancellato dall' autojoin
        fun_delete $did(10).text AutoJ 
      }
      .did -r $dname 10 
    }
  }

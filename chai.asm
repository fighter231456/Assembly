;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
;Segmento della PILA
;---------------------------------------------------------------------------------------------------------
;=========================================================================================================
Pila    SEGMENT PARA STACK
	db      64 DUP('DADA007 ')              ;8 * 64 =512 byte, serve per capire quanto si usa della pila.
Pila    ENDS                                    ;Se si usano pi di 512 byte si cancella la scritta 'DADA007 '
						;il massimo per ogni Segment  di 64kbytes

;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
;Segmento delle VARIABILI
;---------------------------------------------------------------------------------------------------------
;=========================================================================================================
Dati    SEGMENT PARA
	;stringhe che verranno stampate a schermo durante l'esecuzione del programma
	;nb: 13 -> inizio riga, 10 -> a capo riga
		mex1    db      '                         ----> S P A C E - C A R <----',13,10,'$' ;30 CARATTERI -> 25 SPAZI A SINISTRA PER CENTRARE
		mex2    db      ' Il gioco consiste nello schivare le asteroidi e collezionare pi monete',13,10,'$'
		mex2b   db      ' possibili per creare un nuovo RECORD!',13,10,'$'
		mex3    db      ' Per muoversi utilizzare i tasti freccia (Destra e Sinistra)',13,10,'$'
		mex4    db      ' I cuoricini sono le vite, ne puoi accumulare un massimo di 5',13,10,'$'
		mex5    db      ' Una volta finite le vite a disposizione finisce il gioco',13,10,'$'
		mex6    db      ' Freccia Su/Gi:  Aumenta/Diminuisci il livello (velocit)',13,10,'$'
		mEsc    db      ' ESC:             Esci immediatamente dal gioco',13,10,'$'
		mPausa  db      ' P:               Metti il gioco in PAUSA',13,10,'$'
		mInizio db      ' Premi INVIO per iniziare la corsa',13,10,'$'

		cInizio db      '                                   ','$'        ;per cancellare mInizio senza fare Clear Screen
		lEsci   db      'Premere INVIO per ritornare a DOS  ','$'

		lPause  db      'PAUSE                              ','$'
		lLose   db      'GAME OVER                          ','$'
		lWin    db      'Hai raggiunto il punteggio massimo!','$'

		fScore  db      'Punteggio finale: ','$'
		fLife   db      'Vite rimanenti: ','$'

		lDead   db      'HAI SBATTUTO CONTRO UN ASTEROIDE!','$'
		lTasto  db      'Premi un tasto per continuare    ','$'
		lInvio  db      'Premi INVIO per continuare       ','$'

		mLife   db      'LIFE: ','$'
		mLevel  db      'LEVEL: ','$'
		mScore  db      'SCORE: ','$'

		lLife   db      '+1 LIFE     ','$'
		lScore  db      '+1 SCORE    ','$'
		lLevelU db      '+1 LEVEL    ','$'
		lLevelD db      '-1 LEVEL    ','$'
		life    dw      3       ;3 vite iniziali
		level   dw      1       ;livello 1
		score   dw      0H      ;score 0
		tLevel  dw      10H     ;cicli al primo livello 16=10H

		maxScore dw     1000     ;punteggio massimo per dare una fine al gioco

		lVuoto  db      '                   ','$'

	;variabili per il Random
		PrimoIN  DB     00H           ; Flag di prima esecuzione (= 0 si; <> 0 no)
		Rnd_Lo   DW     ?             ; valore corrente a 32 bit del numero random
		Rnd_Hi   DW     ?
		Costante DW     8405H         ; Valore del Moltiplicatore

Dati    ENDS






;=========================================================================================================
 ;---------------------------------------------------------------------------------------------------------
;SEGMENTO del PROGRAMMA
;---------------------------------------------------------------------------------------------------------
;=========================================================================================================
_prog    SEGMENT  PARA 'CODE'    ;allocazione Code Segment, Stack Segment e Data Segment
	ASSUME  CS:_prog,        SS:Pila,        DS:Dati        ;ASSUME forza uso segmento corretto a tutti i simboli del segmento
	ORG 0100H       ;lascio liberi le prime 100H locazioni
	INIZIO: JMP     Main    ;parto dall'etichetta Main

	;=========================================================================================================
	;TASTI (COSTANTI)
	;=========================================================================================================
	kESC    EQU     1bh             ;tasto ESC
	kINVIO  EQU     0dh             ;tasto ENTER
	kSU     EQU     4800h           ;cursore movimento su
	kGIU    EQU     5000h           ;cursore movimento gi
	kDX     EQU     4d00h           ;cursore movimento destra
	kSX     EQU     4b00h           ;cursore movimento sinstra
	limDX   EQU     27              ;limite destro per la navicella (colonna dx cornice)
	limSX   EQU     2               ;limite sinistro per la navicella (colonna sx cornice)

;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
;MACRO
;---------------------------------------------------------------------------------------------------------
;=========================================================================================================
setCur MACRO riga,colonna       ;Macro che sceglie dove posizionare il Cursore
	PUSH DX
	MOV DH,riga             ;riga
	MOV DL,colonna          ;colonna
	CALL posCur             ;chiama la procedura posCur - 02H di INT10H che posiziona il cursore
	POP DX
ENDM
;=========================================================================================================
stpChrT MACRO char              ;stampa in modalit TTY (aggiorna il cursore)
	PUSH AX
	MOV AL,char             ;scelgo il carattere passato per parametro
	CALL writeTTY           ;chiama la procedura
	POP AX
ENDM
;=========================================================================================================
stpChrC MACRO char,num,col      ;stampa n caratteri a colori
	PUSH AX
	PUSH CX
	MOV AL,char             ;scelgo il carattere passato per parametro
	MOV CX,num
	MOV BL,col
	CALL writeCOL           ;chiama la procedura
	POP CX
	POP AX
ENDM
;=========================================================================================================
stpChrBN MACRO char             ;stampa un carattere in Bianco e Nero
	PUSH AX
	MOV AL,char             ;scelgo il carattere passato per parametro
	CALL writeBN            ;chiama la procedura
	POP AX
ENDM
;=========================================================================================================
Random  MACRO num       ;ricordarsi di fare un PUSH AX se necessario
			;ES: num=10 il numero random va da 0 a 9
	MOV AX,num      ;mette in ingresso della procedura Random il valore di AX
	CALL rand
ENDM
;=========================================================================================================
stpMex  MACRO mex       ;stampa un messaggio salvato in memoria (Segmento Dati)
	PUSH AX
	PUSH BX
	PUSH DX
	MOV AX,SEG Dati
	MOV DS,AX
	MOV DX,OFFSET mex
	MOV AH,09H
	INT 21H
	POP DX
	POP BX
	POP AX
ENDM
;=========================================================================================================
Ritardo MACRO tick      ;creo un ritardo (1 tick = 0,55 ms -> 18H tick = 1 secondo)
	PUSH CX
	MOV CX,tick
	CALL delay      ;chiamo la procedura delay che si basa sull'orologio
	POP CX
ENDM
;=========================================================================================================

;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
;INIZIO DEL PROGRAMMA
;---------------------------------------------------------------------------------------------------------
;=========================================================================================================

;NB:    in DX salver la posizione della navicella
;       in BX salver l'ostacolo/moneta/vita (BL=Tipo)  x=asteroide, v=vita, m=moneta
;       CX  il contatore del ciclo

Main:           CALL cls        ;clear screen
		setCur 0,0
		stpMex mex1     ;stampa le istruzioni a schermo
		setCur 2,0
		stpMex mex2
		stpMex mex2b
		stpMex mex3
		stpMex mex4
		stpMex mex5
		stpMex mex6
		stpMex mEsc
		stpMex mPausa
		setCur 11,1
		stpMex lTasto
		CALL outCur
		CALL waitKey    ;aspetta un tasto per continuare

Start:          ;ogni volta che si sbatte contro un asteroide, si ricomincia da qui
		CALL cls        ;clear screen
		CALL wBordo     ;disegna bordo

	;STAMPO LE VITE
		setCur 4,40
		stpMex mLife
		setCur 4,50
		stpChrC 03H,life,04H    ;stampo i cuoricini

	;STAMPO IL LIVELLO
		setCur 6,40
		stpMex mLevel
		setCur 6,50
		stpChrC 09H,level,09H   ;stampo i puntini (che rappresentano il numero del livello)

	;STAMPO IL PUNTEGGIO
		setCur 8,40
		stpMex mScore
		setCur 8,50
		MOV AX,score
		CALL word2dec           ;stampo il punteggio


	;POSIZIONO LA NAVICELLA IN BASSO AL CENTRO
		MOV DH,20       ;riga
		MOV DL,14       ;colonna
		CALL setCar     ;posiziono la navicella


		setCur 15,40    ;ZONA IN CUI SI STAMPANO I MESSAGGI
		stpMex mInizio  ;inizio del livello, attende un invio
		CALL outCur
reqINVIO:       CALL waitKey    ;aspetto il tasto INVIO
		CMP AL,kINVIO
		JNE reqINVIO
		setCur 15,40
		stpMex cInizio


		;CALL outCur    ;nascondo il cursore
		MOV BX,0000H    ;inizializzo ogni ciclo il controllore di ostacoli/vite/monete
Ciclo:          MOV CH,BYTE PTR tLevel   ;imposto il livello iniziale (velocit)
		MOV CL,0        ;inizializzo il contatore del ciclo da incrementare


		CMP CH,CL       ;se ho cambiato livello e
		JBE Continue3   ;CH  minore o uguale a CL -> Ricomincio il ciclo
				;se non metto questo controllo il programma pu inchiodarsi
				;ad esempio se CL vale 0AH e CH  arrivato a 0BH mentre ho cambiato il livello
				;JBE = jump below or equal

		PUSH DX
		setCur 15,40    ;cancello il messaggio interattivo
		stpMex lVuoto   ;del ciclo precedente
		POP DX
		CMP BL,'m'      ;se ho preso una moneta, incremento lo score
		 JE addMon
		CMP BL,'v'
		 JE addVita     ;se ho preso un cuoricino, incremento le vite (a meno che non siano gi 5)

Continue3:      JMP AspKey

addMon:         PUSH AX         ;ho preso una moneta
		 MOV AX,score   ;potevo fare anche direttamente "INC score"
		 ;INC AX         ;incremento lo score
		 ADD AX,level    ;invece di incrementare di 1 unit, aggiungo il valore del livello
		 MOV score,AX
		 setCur 8,50    ;posiziono il cursore nella zona SCORE:
		 CALL word2dec  ;stampo il valore ascii/decimale della variabile score
		 setCur 15,40   ;posiziono il cursore nella zona MESSAGGI
		 stpMex lScore  ;scrivo +1 SCORE
		POP AX
		MOV BX,0000H    ;inizializzo controllore di ostacoli/vite/monete
		JMP AspKey

addVita:        CMP life,5      ;ho preso un cuoricino
		JAE life5       ;se le vite sono maggiori o uguali a 5 allora non aggiungere pi vite
		PUSH AX
		 MOV AX,life
		 INC AX         ;incremento la variabile life
		 MOV life,AX
		 setCur 4,50    ;imposto il cursore nella zona LIFE:
		 stpChrC 03H,life,04H   ;stampo tanti cuoricini rossi quanti le vite
		 setCur 15,40   ;posiziono il cursore nella zona MESSAGGI
		 stpMex lLife   ;scrivo +1 LIFE
		POP AX
life5:          MOV BX,0000H    ;inizializzo il controllore di ostacoli/vite/monete
		JMP AspKey


AspKey:
		CMP BL,'x'      ;controllo se ho preso un asteroide
		JE Dead2        ;se presa -> vado a Dead2
		CALL setCar     ;controllo se ho sbattuto contro un ostacolo o se ho preso una moneta/vita e posiziono la navicella
		Ritardo 01H     ;18 "attese" al secondo
		INC CL          ;incremento il contatore delle 18 attese
		CMP CL,CH       ;Se CL=CH allora siamo a fine ciclo (passate 18 attese se il ciclo  di un secondo)
		JE Continue2    ;mando gi di una riga
		CALL pressKey   ;altrimenti controllo se viene premuto un tasto
		JZ AspKey        ;se non viene premuto alcun tasto aspetto ancora
		 CALL waitKey    ;altrimenti controllo che tasto  stato premuto
		 CMP AL,kESC     ;premo ESC
		 JE  Esci2       ;esco al dos
		 CMP AL,'P'      ;premo P
		 JE I_Pause      ;metto il gioco in Pause
		 CMP AL,'p'      ;premo p (minuscolo)
		 JE I_Pause      ;metto il gioco in Pause
		 CMP AX,kDX      ;premo freccia Destra - kDX EQU 4D00H
		 JE Destra2
		 CMP AX,kSX      ;premo freccia Sinistra - kSX EQU 4B00H
		 JE Sinistra2
		 CMP AX,kSU      ;premo freccia Su
		 JE Su2
		 CMP AX,kGIU     ;premo freccia Giu
		 JE Giu2
		 ;CMP AL,'h'      ;AUMENTA DI 100 IL PUNTEGGIO
		 ;JE HintA2
		 ;CMP AL,'H'      ;DIMINUSCI DI 100 IL PUNTEGGIO
		 ;JE HintB2
		 JMP Tasto2      ;vado a stampare il tasto premuto


;----------etichette per JUMP troppo lunghi-------------
;Win2:           JMP Win
Dead2:          JMP Dead
Destra2:        JMP Destra
Sinistra2:      JMP Sinistra
Esci2:          JMP Esci
Continue2:      JMP Continue
Tasto2:         JMP Tasto
Su2:            JMP Su
Giu2:           JMP Giu
;HintA2:         JMP HintA
;HintB2:         JMP HintB
;AspKey2:        JMP AspKey
;------------etichette per JUMP troppo lunghi-----------


;-----Gestione PAUSA------------------------------
I_Pause:        PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		setCur 15,40    ;SCRIVO "PAUSE" nella zona MESSAGGI
		stpMex lPause
Pause:          CALL waitKey    ;aspetto un tasto
		CMP AL,kESC     ;tasto ESC
		JE Esci2         ;vado a Esci
		CMP AL,'P'      ;tasto P
		JE F_Pause       ;Finisco la Pausa
		CMP AL,'p'      ;tasto p
		JE F_Pause       ;Finisco la Pausa
		JMP Pause       ;altrimenti continuo la pausa -> loop Pause
F_Pause:        setCur 15,40    ;CANCELLO la scritta "PAUSE"
		stpMex lVuoto
		POP DX
		POP CX
		POP BX
		POP AX
		JMP AspKey      ;vado a AspKey
;-----Gestione PAUSA-------------------------------

AspKey2:        JMP AspKey

Destra:         ;sposta la navicella a destra
		CMP DL,limDX    ;controllo se la navicella  arrivata al bordo destro
		JE AspKey2      ;se  arrivata al limite destro e voglio farla andare ancora a destra il programma la blocca l
		 INC DX         ;altrimenti la posso spostare a destra di un carattere
		 PUSH DX
		 SUB DX,2       ;sposto il cursore nella zona in cui c'era la navicella prima di spostarsi a destra
		 CALL posCur
		 stpChrBN ' '   ;metto un carattere ' ' a sinistra dove prima c'era la navicella
		 POP DX
	;stampa cartteri di controllo
		;PUSH DX
		;setCur 21,35
		;stpChrBN 'R'
		;setCur 21,36
		;stpChrBN CL
		;POP DX
	;fine stampa caratteri di controllo
		JMP AspKey      ;attendo il prossimo tasto

Sinistra:       ;sposta la navicella a sinistra
		CMP DL,limSX    ;controllo se la navicella  arrivata al bordo sinistro
		JE AspKey2      ;se  arrivata al limite sinistro e voglio farla andare ancora a sinistra il programma la blocca l
		 DEC DX         ;altrimenti la posso spostare a sinistra di un carattere
		 PUSH DX
		 ADD DX,2       ;sposto il cursore dove c'era la navicella prima di essere spostata a sinistra
		 CALL posCur
		 stpChrBN ' '   ;metto un carattere ' ' dove prima c'era la navicella
		 POP DX
	;stampa caratteri di controllo
		;PUSH DX
		;setCur 21,35
		;stpChrBN 'L'
		;setCur 21,36
		;stpChrBN CL
		;POP DX
	;fine stampa caratteri di controllo
		JMP AspKey      ;attendo il prossimo tasto

Su:             ;su di un livello
		CMP level,8     ;controllo se siamo al livello 8
		JAE level8      ;se il livello  maggiore o uguale a 8 allora non aggiungere pi livelli
		 PUSH AX
		 MOV AX,level   ;altrimenti aggiungi un livello
		 INC AX
		 MOV level,AX
		  MOV AX,tLevel ;diminuisci la durata del ciclo di 2tick
		  SUB AX,2
		  MOV tLevel,AX
		 setCur 6,50    ;posiziona il cursore nella zona LEVEL:
		 stpChrC 09H,level,09H  ;stampa il numero di livelli (pallini blu)
		 setCur 15,40   ;posiziona il cursore nella zona MESSAGGI
		 stpMex lLevelU ;stampa +1 LIVELLO
		POP AX
level8:          MOV BX,0000H    ;inizializzo il controllore di ostacoli/vite/monete
		JMP aspKey

Giu:            ;gi di un livello
		CMP level,1
		JBE level1  ;se il livello  minore o uguale a 1 allora non abbassare il livello
		PUSH AX
		 MOV AX,level
		 DEC AX     ;altrimenti decremento il livello
		 MOV level,AX
		  MOV AX,tLevel ;aumento la durata del ciclo di 2 tick
		  ADD AX,2
		  MOV tLevel,AX
		 setCur 6,50
		 stpMex lVuoto  ;cancello i livelli precedenti per poter stampare meno pallini di prima (altrimenti non si nota il decremento dei livelli)
		 setCur 6,50    ;posiziono il cursore nella zona LEVEL:
		 stpChrC 09H,level,09H  ;stampo il numero del livello (palline blu)
		 setCur 15,40   ;posiziono il cursore nella zona MESSAGGI
		 stpMex lLevelD ;scrivo -1 LIVELLO
		POP AX
level1:          MOV BX,0000H    ;inizializzo il controllore di ostacoli/vite/monete
		JMP aspKey


Tasto:          ;se premo un qualsiasi tasto non fa niente
		;lascio l'etichetta se in futuro voglio utilizzare altri tasti
		;o voglio far fare al programma qualcosa con tasti generici
		;stampo caratteri di controllo
		;PUSH DX
		;setCur 20,35
		;stpChrBN AL
		;POP DX
		JMP AspKey

Continue:       CALL goGIU      ;faccio "scendere" gli ostacoli di una riga
		;ora disegno i nuovi ostacoli/vita/moneta (con diverse probabilit)
		Random 99      ;numero random tra 0 e 99 (100 numeri totali)
		CMP AX,95
		 JAE Vita        ;maggiore o uguale a 95 -> vita (5% di prob)
		CMP AX,25
		 JB Moneta      ;minore di 25 -> moneta (25% di prob)
		CALL wOst       ;altrimenti -> stampo un ostacolo (i rimanenti 73% di prob)
		JMP Next

Vita:           CALL wLife      ;stampo una vita
		JMP Next
Moneta:         CALL wMon       ;stampo una moneta
		JMP Next

Dead:           ;PUSH AX
		;MOV AX,life
		;DEC AX
		;MOV life,AX
		;POP AX
		DEC life        ;decremento una vita
		CMP life,0      ;se la vita  zero -> Game Over
		JE Lose
		 CALL setCar    ;altrimenti ricomincio il gioco con una vita in meno
		 PUSH DX
		 setCur 4,50            ;posiziono il cursore nella zona LIFE:
		 stpChrC 03H,life,04H   ;aggiorno il numero di cuoricini
		 setCur 15,40           ;posiziono il cursore nella zona MESSAGGI
		 stpMex lDead           ;stampo il messaggio "Hai sbattuto contro un asteroide"
		 setCur 16,40
		 stpMex lInvio          ;stampo "Premi invio per continuare"
		 POP DX

aspINVIO:        CALL waitKey           ;aspetto il pulsante INVIO
		CMP AL,kINVIO           ;per ricominciare il gioco con una vita in meno
		JNE aspINVIO
		JMP Start


Next:           CALL outCur     ;nascondo il cursore

		PUSH AX         ;controllo se ho raggiunto il punteggio massimo
		MOV AX,maxScore ;non posso fare un compare di due variabili
		CMP score,AX    ;quindi una delle due la metto in AX
		POP AX
		JAE Win

		JMP Ciclo       ;continuo con il Loop e vado all'etichetta Ciclo

Lose:           ;CALL cls
		PUSH DX
		setCur 15,40    ;posiziono il cursore nella zona MESSAGGI
		stpMex lLose    ;scrivo GAME OVER
		POP DX
		CALL setCar
		JMP Exit

Win:            PUSH DX
		setCur 15,40
		stpMex lWin
		POP DX
		CALL setCar

Exit:           setCur 17,40
		stpMex fScore   ;stampo il punteggio finale
		setCur 17,59    ;zona valore del punteggio
		PUSH AX
		MOV AX,score
		CALL word2dec   ;valore decimale del punteggio
		POP AX
		;POP DX
		CALL waitKey    ;aspetto un tasto


Esci:           setCur 19,40
		stpMex lEsci    ;stampo il messagio di uscita
waitINV:        CALL waitKey    ;aspetto invio per uscire
		CMP AL,kINVIO
		JNE waitINV
		CALL cls
		CALL tornaDOS   ;chiamo la procedura per tornare al dos


;=========================================================================================================
;---------------------------------------------------------------------------------------------------------
;PROCEDURE
;---------------------------------------------------------------------------------------------------------
;============================================================================
wBordo PROC NEAR        ;disegna il bordo in cui si gioca
		;STAMPA RIGA IN ALTO
		setCur 0,0      ;posiziona cursore in alto a sinistra
		stpChrT 0DAH    ;stampa l'angolo in alto a sinistra
		MOV CX,28       ;imposta il loop a 28 volte (colonne)
CicloR1:        stpChrT 0C4H    ;stampa la linea in alto
		LOOP CicloR1    ;finch non si arriva alla colonna 29
		stpChrT 0BFH    ;dove stampa l'angolo in alto a destra

		;STAMPA COLONNA DI SINISTRA
		MOV DH,01H      ;imposta la riga a 2
		MOV DL,00H      ;imposta la colonna a 0 (fissa) - prima colonna
		MOV CX,20       ;imposta il loop a 20 volte (righe)
CicloC1:        CALL posCur     ;posiziona il cursore in DH,DL (riga,colonna)
		stpChrT 0B3H    ;stampa il carattere | per la colonna di sinistra
		inc DH          ;aumenta il contatore (passa alla riga sotto)
		LOOP CicloC1    ;per 20 volte

		;STAMPA COLONNA DI DESTRA
		MOV DH,01H      ;imposta la riga a 2
		MOV DL,29       ;imposta la colonna a 29 (fissa) - 30esima colonna
		MOV CX,0020     ;imposta il loop a 20 volte (righe)
CicloC2:        CALL posCur     ;posiziona il cursore in DH,DL (riga,colonna)
		stpChrT 0B3H     ;stampa il carattere | per la colonna di destra
		inc DH          ;aumenta il contatore (passa alla riga sotto)
		LOOP CicloC2    ;per 20 volte

		;STAMPA RIGA IN BASSO
		setCur 21,0     ;posiziona il cursore alla riga 22, colonna 0
		stpChrT 0C0H     ;stampa l'angolo in basso a sinistra
		MOV CX,28     ;imposta il loop a 28 volte (colonne)
CicloR2:        stpChrT 0C4H     ;stampa il trattino per creare la riga
		LOOP CicloR2    ;per 28 volte
		stpChrT 0D9H     ;stampa l'angolo in basso a destra

		;HO CREATO UN RETTANGOLO 22 RIGHE X 30 COLONNE

wBordo  ENDP
;============================================================================
rand    PROC    NEAR        ;funzione che crea un numero random compreso tra 0<n<AX
	OR      AX,AX           ;se il valore del range passato come parametro
	JNZ     Rand_1          ;è nullo si impone  la  fine  immediata  della
	RET                     ;procedura (valore non corretto!)

Rand_1: PUSH    BX          ;Salva i registri utilizzati dalla procedura
	PUSH    CX
	PUSH    DX
	PUSH    DI
	PUSH    DS
	PUSH    AX              ;Salva il valore del range, passato in ingresso
							;come parametro (verrà utilizzato alla fine)
	LEA     DI,PrimoIN      ;Verifica se si  tratta  della  prima  chiamata
      CMP Byte Ptr DS:[DI],00H  ;della procedura che genera il ritardo.
	JNE     Rand_2          ;se NON è così calcola il nuovo valore

	MOV     AH,2CH          ;Se si tratta della prima chiamata la procedura
	INT     21H             ;provvede ad assumere un valore  casuale  dalla
	MOV     DS:[Rnd_Lo],CX  ;memoria CMOS che contiene il tempo corrente.
	MOV     DS:[Rnd_Hi],DX  ;Utilizza la Funzione DOS 2CH che
							;lascia in CH = Ore     (0-23)
							;               in CL = Minuti  (0-59)
							;       in DH = Secondi (0-59)
							;       in DL = Centesimi di secondi (0-99)
	MOV Byte Ptr DS:[DI],01H  ;Modifica il byte di primo ingresso per evitare
							;di ricaricare le variabili random iniziali

							;Indicazioni relative al primo giro
Rand_2: MOV     AX,DS:[Rnd_Lo]  ;AH=Ore     (0-23), AL=Minuti    (0-59)
	MOV     BX,DS:[Rnd_Hi]  ;BH=Secondi (0-59), BL=Centesimi (0-99)
	MOV     CX,AX           ;CH=Ore     (0-23), CL=Minuti    (0-59)

	MUL     DS:[Costante]   ;AX*Costante=AX*8405H=DX,AX (numero a 32 bit)

	SHL     CX,1            ;Algoritmo di calcolo del num Random
	SHL     CX,1
	SHL     CX,1
	ADD     CH,CL
	ADD     DX,CX
	ADD     DX,BX
	SHL     BX,1
	SHL     BX,1
	ADD     DX,BX
	ADD     DH,BL
	MOV     CL,5
	SHL     BX,CL
	ADD     AX,1
	ADC     DX,0

	MOV     DS:[Rnd_Lo],AX  ;Salva il risultato a 32 bit della manipolazione
	MOV     DS:[Rnd_Hi],DX  ;nelle variabili a ciò destinate

	POP     BX              ;Recupera in BX il valore del range, passato in
							;ingresso, in AX
	XOR     AX,AX           ;Prepara il dividendo a 32 bit forzando a  zero
	XCHG    AX,DX           ;i 16 bit più significativi e copiando  nei  16
							;bit bassi il valore corrente di DX
	DIV     BX              ;AX = quoziente (DX,AX / BX)
							;DX = resto
	XCHG    AX,DX           ;il numero random corrente è il valore del resto
							;ed è lasciato, in uscita, in AX
	POP     DS
	POP     DI              ;Recupera i registri utilizzati dalla procedura
	POP     DX
	POP     CX
	POP     BX
	RET
rand  ENDP
;============================================================================
delay PROC NEAR         ;CX=18 per avere 0,55ms*18 = 1secondo di ritardo
	PUSH AX         ;salvo i registri
	PUSH BX
	PUSH DX

	PUSH CX         ;il valore di CX lo metto in BX
	POP BX          ;in BX c' il valore scelto come ritardo
	CALL clock      ;restituisce in CX,DX il time del sistema (32bit)
	ADD DX,BX       ;aggiungo un tot di TICK (CX) a DX (parte bassa del time)
	JNC Delay_0     ;se non ha riporto vado a Delay_0
	INC CX          ;altrimenti aggiungo il riporto a CX
Delay_0: PUSH CX        ;copia in AX,BX il numero di Tick relativi alla prima lettura
	PUSH DX         ;AGGIORNATA con il numero corrispondente al RITARDO desiderato
	POP BX          ;in pratica in AX,BX ho il tempo futuro da raggiungere
	POP AX
Delay_1: PUSH AX        ;salvo nella pila i dati di AX,BX (tempo da raggiungere)
	PUSH BX
	CALL clock      ;salvo i dati della NUOVA lettura in CX,DX
	POP BX          ;e in AX,BX ho sempre i dati del tempo da raggiungere
	POP AX

	CMP AX,CX       ;confronto la parte alta dei due time
	JZ Delay_2      ;se sono gli stessi controllo la parte bassa (Dela_2)
			;altrimenti significa che (quasi sempre) differiscono del riporto
	PUSH AX         ;salvo la parte alta
	SUB AX,CX       ;controllo se differiscono, magari di un numero diverso da 1
	CMP AX,18H      ;infatti se la differenza  18H  passata mezzanotte
	POP AX
	JNZ Delay_1     ;se non  passata mezzanotte allora torno a Delay_1 per continuare l'attesa

	PUSH BX         ;se  passata mezzanotte (la differenza  18H)
	SUB BX,00B0H    ;quindi CX,DX  passato da 0018-00AFH a 0000-0000H
	CMP BX,DX       ;quindi anche la parte bassa va adattata alla nuova situazione
	POP BX
	JG Delay_1      ;se  ancora pi grande BX,DX continuo ad aspettare
	JMP Delay_3     ;altrimenti non serve pi aspettare - ritardo consumato!

Delay_2: CMP BX,DX      ;se la parte alta  la stessa e la parte bassa del
	JG Delay_1      ;tempo corrente  minore, BX>DX -> continua l'attesa

Delay_3: POP DX         ;il ritardo  stato consumato!
	POP BX
	POP AX

	RET             ;ritorna

delay ENDP
;=========================================================================================================
wLife PROC NEAR         ;stampa un cuoricino random
	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX
	Random 27       ;colonna random tra 0 e 27 (mette il valore in AX)
	INC AX          ;colonna random tra 1 e 28 (dentro la cornice)
	setCur 1,AL     ;scelgo la parte passa del numero random (xk parte alta nulla)
	MOV BH,0        ;pagina video 0
	MOV CX,1        ;scelgo di stampare un carattere
	MOV AL,03H      ;scelgo il carattere (Cuoricino)
	MOV BL,04H      ;scelgo il colore rosso su nero
	CALL scrivi     ;stampo il carattere
	POP AX
	POP BX
	POP CX
	POP DX
	RET
wLife ENDP
;=========================================================================================================
wMon PROC NEAR       ;stampa una moneta random
	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX
	Random 27       ;colonna random tra 0 e 27 (mette il valore in AX)
	INC AX          ;colonna random tra 1 e 28 (dentro la cornice)
	setCur 1,AL     ;scelgo la parte passa del numero random (xk parte alta nulla)
	MOV BH,0        ;pagina video 0
	MOV CX,1        ;scelgo di stampare un carattere
	MOV AL,0FH      ;scelgo il carattere (Moneta - Sole)
	MOV BL,0EH      ;scelgo il colore giallo su nero
	CALL scrivi     ;stampo il carattere
	POP AX
	POP BX
	POP CX
	POP DX
	RET
wMon ENDP
;=========================================================================================================
wOst PROC NEAR       ;stampa un ostacolo random
	PUSH DX
	PUSH CX
	PUSH BX
	PUSH AX
	Random 27       ;colonna random tra 0 e 27 (mette il valore in AX)
	INC AX          ;colonna random tra 1 e 28 (dentro la cornice)
	setCur 1,AL     ;scelgo la parte passa del numero random (xk parte alta nulla)
	MOV BH,0        ;pagina video 0
	MOV CX,1        ;scelgo di stampare un carattere
	MOV AL,0B1H     ;scelgo il carattere (Un "masso")
	MOV BL,08H      ;scelgo il colore grigio su nero
	CALL scrivi     ;stampo il carattere
	POP AX
	POP BX
	POP CX
	POP DX
	RET             ;ritorna
wOst ENDP
;============================================================================
goGIU PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	MOV AH,07H      ;funzione sposta in basso una parte dello schermo
	MOV AL,01H      ;num righe
	MOV CH,1        ;riga ang alto sx
	MOV CL,1        ;col ang alto sx
	MOV DH,20       ;riga ang basso dx
	MOV DL,28       ;col ang basso dx
			;da 1,1 a 28,20 (in riga 0 e 22 c' la cornice)
	MOV BH,07H      ;colore righe vuote nero (DEFAULT 07H)
	INT 10H
	POP DX
	POP CX
	POP BX
	POP AX
	RET             ;ritorna
goGIU ENDP
;=========================================================================================================
writeTTY PROC Near      ;AL=char,CX=num di volte
	PUSH BX
	MOV BH,00H      ;Pagina 0
	MOV BL,70H      ;Bianco su nero
	MOV AH,0EH      ;Funzione 0EH di INT 10H (Stampa a schermo uno o pi caratteri colorati
	INT 10H
	POP BX
	RET             ;ritorna
writeTTY ENDP
;=========================================================================================================
writeCOL PROC Near      ;AL=char,CX=num di volte,BL=colore
	MOV BH,00H      ;Pagina 0
	MOV AH,09H      ;Funzione 09H di INT 10H (Stampa a schermo uno o più caratteri colorati
	INT 10H
	RET             ;ritorna
writeCOL ENDP
;=========================================================================================================
writeBN PROC Near      ;AL=char,CX=num di volte
	PUSH BX
	PUSH CX
	MOV BH,00H      ;Pagina 0
	MOV BL,70H      ;Bianco su Nero
	MOV CX,1        ;stampo UN carattere
	MOV AH,0AH      ;Funzione 0AH di INT 10H (Stampa a schermo uno o più caratteri)
	INT 10H
	POP CX
	POP BX
	RET             ;ritorna
writeBN ENDP
;=========================================================================================================
scrivi PROC    Near     ;AL=char,CX=num di volte,BL=colore
	MOV AH,09H      ;Funzione 09H di INT 10H (Stampa a schermo CX caratteri colorati)
	INT 10H
	RET                     ;ritorna
scrivi ENDP
;=========================================================================================================
clock PROC NEAR         ;mette nei registri l'ora corrente:
	MOV AH,00H      ;CX=parte alta clock
	INT 1AH         ;DX=parte bassa clock
	RET
clock ENDP
;=========================================================================================================
waitKey PROC NEAR       ;aspetta un tasto
	MOV AH,00H      ;funzione 00H di INT 16H che aspetta un tasto
	INT 16H
			;AL=codice ascii, AH=codice scansione
	RET             ;ritorna
waitKey ENDP
;============================================================================
pressKey PROC NEAR
	MOV AH,01H      ;se premuto tasto, modifica ZERO FLAG
	INT 16H
	RET
pressKey ENDP
;============================================================================
posCur PROC    Near     ;Procedura che posiziona cursore
	PUSH AX
	PUSH BX
	PUSH DX
	MOV BH,00H      ;pagina video 0 (quella visibile)
	MOV AH,02H      ;funzione 02H di INT 10H che posiziona il cursore in DH,DL (riga,colonna)
	INT 10H
	POP DX
	POP BX
	POP AX
	RET             ;ritorna
posCur ENDP
;============================================================================
setCar PROC NEAR        ;DH=riga,DL=colonna
	PUSH AX
	PUSH CX
	PUSH DX
	MOV CX,0000H

	CALL posCur     ;posiziono il cursore
	 CMP BX,0000H   ;se BX è zero allora non ha ancora toccato niente
	 JNE asd1       ;salto il check
	 CALL checkCar   ;controllo se ha toccato qualcosa
asd1:    CALL posCur
	stpChrBN 1EH    ;posso stampare il carattere centrale

	INC DX          ;mi sposto a destra
	CALL posCur
	 CMP BX,0000H   ;se BX è zero allora non ha ancora toccato niente
	 JNE asd2       ;salto il check
	 CALL checkCar
asd2:   CALL posCur
	stpChrBN '>'    ;stampo il carattere di destra

	SUB DX,2        ;mi sposto a sinistra di 2
	CALL posCur
	 CMP BX,0000H   ;se BX è zero allora non ha ancora toccato niente
	 JNE asd3       ;salto il check
	 CALL checkCar
asd3:   CALL posCur
	stpChrBN '<'    ;posso stampare il carattere di sinistra

	;STAMPA CARATTERE PER CONTROLLARE
	;PUSH DX
	;setCur 18,60    ;stampo l'ostacolo che ho toccato
	;stpChrBN CH
	;POP DX

	CMP CH,'M'      ;ho preso una moneta
	 JE Moneta_2
	CMP CH,'X'      ;ho preso un masso
	 JE Masso_2
	CMP CH,'V'      ;ho preso una vita
	 JE Vita_2
	JMP CONT_2

Moneta_2: JMP CONT_2    ;lascio il codice cos nel caso in cui voglio fare modifiche successive

Masso_2:  JMP CONT_2

Vita_2:   JMP CONT_2


CONT_2: INC DX
	CALL posCur

	POP DX
	POP CX
	POP AX
	RET                     ;ritorna
setCar ENDP
;============================================================================
checkCar PROC NEAR ;DH=riga,DL=colonna
	CMP CL,01H      ;CL controlla se è già stato preso qualcosa
	JE CONT_1       ;CL=1 salto il controllo perchp non serve e vado alla fine

	CALL readCur    ;controllo il carattere ASCII puntato dal cursore AL=carattere, AH=colore
	CMP AH,08H      ;se è grigio -> masso
	 JE Masso_1
	CMP AH,0EH      ;se è giallo -> moneta
	 JE Moneta_1
	CMP AH,04H
	 JE Vita_1      ;se è rosso -> vita
	CMP AH,07H
	 JE Niente_1    ;non prende niente
	JMP CONT_1

Masso_1: MOV CL,01H     ;imposto CL a 1 per dire che ho toccato qualcosa
	 MOV CH,'X'     ;in CH salvo il valore del tipo di ostacolo (in CH dura un tick)
	 MOV BL,'x'     ;in BL salvo il valore del tipo di ostacolo (in BL dura un ciclo)
	 JMP CONT_1

Moneta_1: MOV CL,01H    ;imposto CL a 1 per dire che ho toccato qualcosa
	  MOV CH,'M'    ;in CH salvo il valore del tipo di ostacolo (in CH dura un tick)
	  MOV BL,'m'    ;in BL salvo il valore del tipo di ostacolo (in BL dura un ciclo)
	  JMP CONT_1

Vita_1:   MOV CL,01H    ;imposto CL a 1 per dire che ho toccato qualcosa
	  MOV CH,'V'    ;in CH salvo il valore del tipo di ostacolo (in CH dura un tick)
	  MOV BL,'v'    ;in BL salvo il valore del tipo di ostacolo (in BL dura un ciclo)
	  JMP CONT_1

Niente_1: MOV CH,'_'    ;carattere di controllo
	  JMP CONT_1

CONT_1:   RET

checkCar ENDP
;=========================================================================================================
Word2Dec PROC NEAR      ;trasforma la word esadecimale fornita in AX nei caratteri ASCII corrispondenti
	PUSH    AX
	PUSH    BX
	PUSH    DX
	CMP     AX,10000        ;Se il numero esadecimale in ingresso è minore
	JC      Wor2_0          ;di 10000 la successiva divisione viene evitata
	MOV     DX,0000H        ;(DX,AX=0000XXXX):(BX=10000)=AX, resto DX
	MOV     BX,10000        ;Prepara il divisore a 10000
	DIV     BX              ;Esegue la divisione
	CALL    STAasci         ;Stampa il valore delle Decine di Migliaia
	MOV     AX,DX           ;Sposta in AX il  Resto  RRRR  della  divisione
	JMP     SHORT Wor2_1    ;precedente da dividere  nella  fase successiva
Wor2_0: CMP     AX,1000     ;Se il numero esadecimale in ingresso è minore
	JC      Byt2_0          ;di 1000  la successiva divisione viene evitata
Wor2_1: MOV     DX,0000H    ;(DX,AX=0000XXXX):(BX=1000)=AX, resto DX
	MOV     BX,1000         ;Prepara il divisore a 1000
	DIV     BX              ;Esegue la divisione
	CALL    STAasci         ;Stampa il valore delle Migliaia
	MOV     AX,DX           ;Sposta in AX il  Resto  RRRR  della  divisione
	JMP     SHORT Byt2_1    ;precedente da dividere nella  fase  successiva

;Byte2Dec
	PUSH    AX              ;Salva i Registri usati  dalla Procedura,  com-
	PUSH    BX              ;preso il valore da convertire, passato in  in-
	PUSH    DX              ;gresso in AL
	MOV     AH,00H          ;formatta il dividendo al valore AX=00XX
Byt2_0: CMP     AX,100      ;Se il numero esadecimale in ingresso è minore
	JC      Byt2_2          ;di 100 la  successiva divisione viene evitata
Byt2_1: MOV     BL,100      ;Prepara il divisore a 100
	DIV     BL              ;Divide AX=00XX per BL=100 (AX:BL=AL, resto AH)
	CALL    STAasci         ;Stampa il valore delle Centinaia
	MOV     AL,AH           ;Sposta in AL il Resto RR della divisione  precedente
	MOV     AH,00H          ;da  dividere  nella  fase  successiva,
	JMP     SHORT Byt2_3    ;formattando il dividendo al valore AX=00RR
Byt2_2: CMP     AX,10       ;Se il numero esadecimale in ingresso  è minore
	JC      Byt2_4          ;di 10 la successiva  divisione  viene  evitata
Byt2_3: MOV     BL,10       ;Prepara il divisore a 10
	DIV     BL              ;Divide AX=00XX per BL=10  (AX:BL=AL, resto AH)
	CALL    STAasci         ;Stampa il valore delle Decine
	MOV     AL,AH           ;Prepara in AL la cifra delle Unità
Byt2_4: CALL    STAasci     ;Stampa il valore delle Unità
	POP     DX
	POP     BX
	POP     AX
	RET
Word2Dec ENDP
;========================================================================================================
STAasci PROC NEAR             ;stampa il valore ascii del numero in AL
	PUSH    AX
	ADD     AL,30H        ;sommo 30 al numero per avere il carattere ASCII del numero
	stpChrT AL
	POP     AX
	RET
STAasci ENDP
;=========================================================================================================
readCur PROC NEAR             ;legge il valore del carattere ASCII puntato dal cursore
	MOV AH,08H
	MOV BH,00H
	INT 10H               ;restituisce in AH=Colore, AL=Carattere
	RET
readCur ENDP
;=========================================================================================================
outCur PROC    Near             ;Procedura che nasconde il cursore dal video
	PUSH CX                 ;basandosi sulla procedura ridimensiona cursore (in altezza)
	PUSH AX                 ;(se il bit 5 di CH  1 allora il cursore sparisce)
	MOV CH,20H              ;linea di pixel di partenza
	MOV CL,00H              ;linea di pixel finale
	MOV AH,01H
	INT 10H
	POP AX
	POP CX
	RET                     ;ritorna
outCur ENDP
;============================================================================
cls PROC Near
	MOV AL,03H              ;modalit video 80colonne x 24righe
	MOV AH,00H              ;crea anche un clear screen
	INT 10H
	RET
cls ENDP
;============================================================================
tornaDOS PROC NEAR
	MOV AH,4CH
	INT 21H
tornaDOS ENDP
;============================================================================

_prog    ENDS                   ;FINE SEGMENTO PROGRAMMA
	END     INIZIO          ;fine Programma, tutto quello che viene scritto dopo viene ignorato!
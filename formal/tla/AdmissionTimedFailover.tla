------------------------ MODULE AdmissionTimedFailover ------------------------
(***************************************************************************)
(* The timed model (AdmissionTimed.tla) with a replicated store: a primary  *)
(* and one replica, and at most F failovers per run. Round 10.              *)
(*                                                                         *)
(* The extension covers the designs whose grant is one statement on a       *)
(* counter row: the conditional update on the request's clock              *)
(* (ConditionalUpdate), the conditional update on the datastore's clock     *)
(* (ConditionalUpdateDb), and the reservation on the datastore's clock      *)
(* (ReserveBeforeSendDb). The guarded transaction and the sliding window    *)
(* designs are not part of it: locks are not carried across a failover and  *)
(* their records are not a single row.                                      *)
(*                                                                         *)
(* The actions of the three designs are those of AdmissionTimed.tla, step   *)
(* for step (Start, Roll1, Roll2, Inc, GrantDb, Send, Release, Tick), so    *)
(* that a run with F = 0 reproduces the timed model's verdict and its        *)
(* distinct state count. Two actions are added:                             *)
(*                                                                         *)
(*   Replicate  copies the primary's row to the replica, at any moment.     *)
(*   Failover   promotes the replica: the primary's row is replaced by the  *)
(*              replica's copy, so every acknowledged write the replica has *)
(*              not received is lost; if the replica holds no row, the      *)
(*              counter row disappears altogether. At most F per run.       *)
(*                                                                         *)
(* Sync = TRUE models synchronous replication: no write is acknowledged     *)
(* before the replica has it, so a failover leaves the row unchanged.       *)
(* Sync = FALSE is asynchronous replication: the replica catches up only    *)
(* through Replicate, at any moment, and a failover loses what it missed.   *)
(*                                                                         *)
(* An UPDATE on a row that a failover removed changes nothing, as in SQL:   *)
(* Roll2, Inc and Release are guarded by row.present, and the one statement *)
(* of the datastore clock designs (GrantDb) begins with INSERT OR IGNORE,   *)
(* so it recreates the row. With F = 0 these guards never bind.             *)
(*                                                                         *)
(* Ghost state and the contract are those of the timed model; the weaker   *)
(* bounds (F + 1) * L (C1F, C1tauF, C2F) are added.                         *)
(***************************************************************************)
EXTENDS Naturals, FiniteSets

CONSTANTS N,          \* requests for one number
          L,          \* declared limit per window
          W,          \* window length in ticks
          T,          \* last tick
          K,          \* stores (1 in every run of this extension)
          Design,
          Faults,     \* the provider may fail or time out
          D,          \* the provider call follows the grant within D ticks (D >= T: no bound)
          F,          \* failovers permitted per run (0 or 1)
          Sync        \* TRUE: synchronous replication; FALSE: asynchronous

ASSUME Design \in {"ConditionalUpdate", "ConditionalUpdateDb", "ReserveBeforeSendDb"}
ASSUME F \in Nat /\ Sync \in BOOLEAN

Req == 1..N
Stores == 1..K
Floor(t) == t - (t % W)
Reserve == Design = "ReserveBeforeSendDb"
Outcomes == IF Faults THEN {"ok", "failed", "unkB", "unkU"} ELSE {"ok"}
Billed(o) == o \in {"ok", "unkB"}
None == [used |-> 0, ws |-> 0, present |-> FALSE]

VARIABLES clock, row, rep, fo, pc, now, st, resw, outc, adm, calls

vars == <<clock, row, rep, fo, pc, now, st, resw, outc, adm, calls>>

Init ==
    /\ clock = 0
    /\ row = [k \in Stores |-> None]
    /\ rep = [k \in Stores |-> None]
    /\ fo = 0
    /\ pc = [s \in Req |-> "start"]
    /\ now = [s \in Req |-> 0]
    /\ st = [s \in Req |-> 1]
    /\ resw = [s \in Req |-> 0]
    /\ outc = [s \in Req |-> "none"]
    /\ adm = {}
    /\ calls = {}

Grant(s) == CHOOSE t \in 0..T : \E a \in adm : a.r = s /\ a.tau = t
CallDue(s) == pc[s] = "send" /\ (\E a \in adm : a.r = s)

Tick ==
    /\ clock < T
    /\ \A s \in Req : CallDue(s) => ((clock + 1) - Grant(s) <= D)
    /\ clock' = clock + 1
    /\ UNCHANGED <<row, rep, fo, pc, now, st, resw, outc, adm, calls>>

Goto(s, l) == pc' = [pc EXCEPT ![s] = l]
Admit(s, w) == adm' = adm \cup {[r |-> s, tau |-> clock, w |-> w]}

\* ------------------------------------------------------------ replication
\* The replica catches up at any moment (asynchronous replication). While no
\* failover can still happen the replica plays no part, so the action is
\* enabled only while one can: with F = 0 the state space is the timed model's.
Replicate ==
    /\ ~Sync /\ fo < F
    /\ \E k \in Stores :
         /\ rep[k] # row[k]
         /\ rep' = [rep EXCEPT ![k] = row[k]]
    /\ UNCHANGED <<clock, row, fo, pc, now, st, resw, outc, adm, calls>>

\* The replica is promoted. Asynchronous: the primary's row becomes the
\* replica's copy, and every write the replica had not received is lost.
\* Synchronous: nothing is lost. Locks are not carried across (the datastore
\* clock designs hold theirs only inside GrantDb, one action).
Failover ==
    /\ fo < F
    /\ fo' = fo + 1
    /\ IF Sync THEN UNCHANGED row ELSE row' = rep
    /\ UNCHANGED <<clock, rep, pc, now, st, resw, outc, adm, calls>>

\* ------------------------------------------------------------------ start
Start(s) ==
    /\ pc[s] = "start"
    /\ \E k \in Stores :
         /\ st' = [st EXCEPT ![s] = k]
         /\ now' = [now EXCEPT ![s] = clock]
    /\ Goto(s, IF Design = "ConditionalUpdate" THEN "roll1" ELSE "grantdb")
    /\ UNCHANGED <<clock, row, rep, fo, resw, outc, adm, calls>>

\* ------------------------------------- conditional update, request's clock
Roll1(s) ==            \* INSERT OR IGNORE INTO counters VALUES (phone, 0, floor(now))
    /\ pc[s] = "roll1"
    /\ IF row[st[s]].present THEN UNCHANGED row
       ELSE row' = [row EXCEPT ![st[s]] = [used |-> 0, ws |-> Floor(now[s]), present |-> TRUE]]
    /\ Goto(s, "roll2")
    /\ UNCHANGED <<clock, rep, fo, now, st, resw, outc, adm, calls>>

Roll2(s) ==            \* UPDATE ... SET used=0, window_start=floor(now) WHERE now-window_start >= W
    /\ pc[s] = "roll2"
    /\ IF row[st[s]].present /\ now[s] - row[st[s]].ws >= W
         THEN row' = [row EXCEPT ![st[s]] = [used |-> 0, ws |-> Floor(now[s]), present |-> TRUE]]
         ELSE UNCHANGED row
    /\ Goto(s, "inc")
    /\ UNCHANGED <<clock, rep, fo, now, st, resw, outc, adm, calls>>

Inc(s) ==              \* UPDATE ... SET used=used+1 WHERE used < L RETURNING window_start
    /\ pc[s] = "inc"
    /\ IF row[st[s]].present /\ row[st[s]].used < L
         THEN /\ row' = [row EXCEPT ![st[s]].used = @ + 1]
              /\ resw' = [resw EXCEPT ![s] = row[st[s]].ws]
              /\ Admit(s, row[st[s]].ws)
              /\ Goto(s, "send")
         ELSE Goto(s, "done") /\ UNCHANGED <<row, resw, adm>>
    /\ UNCHANGED <<clock, rep, fo, now, st, outc, calls>>

\* -------------------------------------------- the datastore clock designs
GrantDb(s) ==          \* under the lock: INSERT OR IGNORE; one UPDATE that reads the
    /\ pc[s] = "grantdb" \* datastore's clock, rolls the window, and admits
    /\ LET r0 == IF row[st[s]].present THEN row[st[s]]
                 ELSE [used |-> 0, ws |-> Floor(clock), present |-> TRUE]
           r  == IF clock - r0.ws >= W THEN [used |-> 0, ws |-> Floor(clock), present |-> TRUE] ELSE r0
       IN IF r.used < L
            THEN /\ row' = [row EXCEPT ![st[s]] = [r EXCEPT !.used = @ + 1]]
                 /\ resw' = [resw EXCEPT ![s] = r.ws]
                 /\ Admit(s, r.ws)
                 /\ Goto(s, "send")
            ELSE /\ row' = [row EXCEPT ![st[s]] = r0]
                 /\ Goto(s, "done") /\ UNCHANGED <<resw, adm>>
    /\ UNCHANGED <<clock, rep, fo, now, st, outc, calls>>

\* --------------------------------------------------------- provider call
Send(s) ==
    /\ pc[s] = "send"
    /\ \E o \in Outcomes :
         /\ outc' = [outc EXCEPT ![s] = o]
         /\ calls' = calls \cup {[r |-> s, t |-> clock, o |-> o]}
         /\ Goto(s, IF Reserve /\ o # "ok" THEN "release" ELSE "done")
    /\ UNCHANGED <<clock, row, rep, fo, now, st, resw, adm>>

\* the reservation on the datastore's clock returns its claim only after a
\* certain failure, and only on the row of the window it was claimed in
Release(s) ==
    /\ pc[s] = "release"
    /\ IF outc[s] = "failed" /\ row[st[s]].present /\ row[st[s]].ws = resw[s]
         THEN row' = [row EXCEPT ![st[s]].used = @ - 1]
         ELSE UNCHANGED row
    /\ Goto(s, "done")
    /\ UNCHANGED <<clock, rep, fo, now, st, resw, outc, adm, calls>>

Step(s) == Start(s) \/ Roll1(s) \/ Roll2(s) \/ Inc(s) \/ GrantDb(s) \/ Send(s) \/ Release(s)

AllDone == \A s \in Req : pc[s] = "done"
Terminated == AllDone /\ UNCHANGED vars

Next == Tick \/ Replicate \/ Failover \/ (\E s \in Req : Step(s)) \/ Terminated

Spec == Init /\ [][Next]_vars
FairSpec == Spec /\ \A s \in Req : WF_vars(Step(s))

\* =================================================================== the contract
Windows == {w \in 0..T : w % W = 0}
AdmIn(w)  == {a \in adm : a.w = w}
TauIn(w)  == {a \in adm : Floor(a.tau) = w}
CallOf(a) == {c \in calls : c.r = a.r}
BilledAdm(S) == {a \in S : \E c \in CallOf(a) : Billed(c.o)}

\* C1, send bound, in the implementation's own attribution, and by tau
C1     == \A w \in Windows : Cardinality(AdmIn(w)) <= L
C1tau  == \A w \in Windows : Cardinality(TauIn(w)) <= L
\* the weaker bound of (F + 1) * L grants per window
C1F    == \A w \in Windows : Cardinality(AdmIn(w)) <= (F + 1) * L
C1tauF == \A w \in Windows : Cardinality(TauIn(w)) <= (F + 1) * L
\* C2, billing bound: billed calls per window, own attribution and by tau
C2     == \A w \in Windows : Cardinality(BilledAdm(AdmIn(w))) <= L
C2tau  == \A w \in Windows : Cardinality(BilledAdm(TauIn(w))) <= L
C2F    == \A w \in Windows : Cardinality(BilledAdm(AdmIn(w))) <= (F + 1) * L
C2tauF == \A w \in Windows : Cardinality(BilledAdm(TauIn(w))) <= (F + 1) * L
\* C3, no duplicate call
C3 == \A s \in Req : Cardinality({c \in calls : c.r = s}) <= 1
\* the counter never goes below zero
NonNegative == \A k \in Stores : row[k].used >= 0
\* liveness
Termination == <>AllDone
\* sanity: the limit is reachable
BelowLimit == \A w \in Windows : Cardinality(AdmIn(w)) < L
=============================================================================

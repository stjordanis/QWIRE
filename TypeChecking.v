Require Export HOASCircuits.

(** Projecting out elements of tensors **)

Open Scope circ_scope.
Definition wproj {W1 W2} (p : Pat (W1 ⊗ W2)) : Pat W1 * Pat W2 :=
  match p with
  | pair p1 p2 => (p1, p2)  
  end.

(*** Typechecking Tactic ***)

(* Prevent compute from unfolding important fixpoints *)
Open Scope circ_scope.
Opaque wproj.
Global Opaque merge.
Global Opaque Ctx.
Global Opaque is_valid.

Print Circuit.
Fixpoint pair_circ' {W1 W2} (p : Pat W1) (c2 : Circuit W2) : Circuit (W1 ⊗ W2) :=
  match c2 with
  | output p2   => output (pair p p2)
  | gate g p1 f => gate g p1 (fun p2 => pair_circ' p (f p2))
  | lift p1 f   => lift p1 (fun x => pair_circ' p (f x))
  end.
Fixpoint pair_circ {W1 W2} (c1 : Circuit W1) (c2 : Circuit W2) : Circuit (W1 ⊗ W2) :=
  match c1 with
  | output p1   => pair_circ' p1 c2
  | gate g p1 f => gate g p1 (fun p2 => pair_circ (f p2) c2)
  | lift p f    => lift p (fun b => pair_circ (f b) c2)
  end.
Notation "( x , y , .. , z )" := (pair_circ .. (pair_circ x y) .. z) (at level 0) : circ_scope.


(*** Notations ***)

Set Printing Coercions.

(* These tactics construct circuits by calling out to type_check *)


Notation letpair p1 p2 p c := (let (p1,p2) := wproj p in c).

Notation "'box_' p ⇒ C" := (box (fun p => C)) 
    (at level 11) : circ_scope.
Notation "'box_' () ⇒ C" := (box (fun _ => C)) 
    (at level 11) : circ_scope.
Notation "'box_' ( p1 , p2 ) ⇒ C" := (box (fun p => letpair p1 p2 p C)) 
    (at level 11) : circ_scope.
Notation "'box_' ( p1 , p2 , p3 ) ⇒ C" := (box (fun p =>
    let (y,p3) := wproj p in
    let (p1,p2) := wproj y in C)) 
    (at level 11) : circ_scope.
Notation "'box_' ( p1 , ( p2 , p3 ) ) ⇒ C" := (box (fun x =>
    let (p1,y) := wproj x in
    let (p2,p3) := wproj y in C)) 
    (at level 11) : circ_scope.
Notation "'box_' ( ( p1 , p2 ) , ( p3 , p4 ) ) ⇒ C" := (box (fun x =>
    let (y,z) := wproj x in
    let (p1,p2) := wproj y in
    let (p3,p4) := wproj z in
    C)) 
    (at level 11) : circ_scope.


(* Notations for patterns *)
Notation "()" := unit : circ_scope.
(*Notation "( x , y , .. , z )" := (pair .. (pair x y) .. z) (at level 0) : circ_scope.*)


(* Notations for circuits *)
Notation comp p c1 c2 := (compose c1 (fun p => c2)).
Notation "'let_' p ← c1 ; c2" := (comp p c1 c2)
                            (at level 12, right associativity) : circ_scope.
Notation "'let_' () ← c1 ; c2" := 
    (compose c1 (fun _ => c2)) 
                            (at level 12, right associativity) : circ_scope.
Notation "'let_' ( p1 , p2 ) ← c1 ; c2" := 
    (compose c1 (fun x => letpair p1 p2 x c2)) 
                            (at level 12, right associativity) : circ_scope.
Notation "'let_' ( p1 , p2 , p3 ) ← c1 ; c2" :=
    (compose c1 (fun x => let (y,p3) := wproj x in
                       let (p1,p2) := wproj y in c2))
                            (at level 12, right associativity) : circ_scope.
Notation "'let_' ( ( p1 , p2 ) , p3 ) ← c1 ; c2" := 
    (compose c1 (fun x => let (y,p3) := wproj x in
                       let (p1,p2) := wproj y in c2))
                            (at level 12, right associativity) : circ_scope.
Notation "'let_' ( p1 , ( p2 , p3 ) ) ← c1 ; c2" :=
    (compose c1 (fun x => let (p1,y) := wproj x in
                       let (p2,p3) := wproj y in c2))
                            (at level 12, right associativity) : circ_scope.
Notation "'let_' ( ( p1 , p2 ) , ( p3 , p4 ) ) ← c1 ; c2" :=
    (compose c1 (fun x => let (y,z) := wproj x in
                       let (p1, p2) := wproj y in
                       let (p3, p4) := wproj z in c2))
                            (at level 12, right associativity) : circ_scope.
Notation "'let_' ( p1 , ( p2 , ( p3 , ( p4 , ( p5 , p6 ) ) ) ) ) ← c1 ; c2" :=
    (compose c1 (fun x => let (p1,y) := wproj x in
                       let (p2,z) := wproj y in
                       let (p3,a) := wproj z in
                       let (p4,b) := wproj a in
                       let (p5,p6) := wproj b in c2))
                            (at level 12, right associativity) : circ_scope.


Notation "'gate_' p2 ← g @ p ; c2" := (gate g p (fun p2 => c2))
         (at level 12, right associativity).
Notation "'gate_' () ← g @ p ; c2" := (gate g p (fun _ => c2))
         (at level 12, right associativity).
Notation "'gate_' ( p1 , p2 ) ← g @ p ; c2" := 
    (gate g p (fun x => letpair p1 p2 x c2))
                            (at level 12, right associativity) : circ_scope.
Notation "'gate_' ( p1 , p2 , p3 ) ← g @ p ; c2" :=
    (gate g p (fun x => let (y, p3) := wproj x in
                     let (p1, p2) := wproj y in c2))
                           (at level 12, right associativity) : circ_scope.
Notation "'gate_' ( ( p1 , p2 ) , p3 ) ← g @ p ; c2" := 
    (gate g p (fun x => let (y, p3) := wproj x in
                     let (p1, p2) := wproj y in c2))
                            (at level 12, right associativity) : circ_scope.
Notation "'gate_' ( p1 , ( p2 , p3 ) ) ← g @ p ; c2" :=
    (gate g p (fun x => let (p1, y) := wproj x in
                     let (p2, p3) := wproj y in c2))
                            (at level 12, right associativity) : circ_scope.
Notation "'gate_' ( ( p1 , p2 ) , ( p3 , p4 ) ) ← g @ p ; c2" :=
    (gate g p (fun x => let (y, z) := wproj x in
                     let (p1, p2) := wproj y in
                     let (p3, p4) := wproj z in c2))
                            (at level 12, right associativity) : circ_scope.
Notation "'gate_' ( p1 , ( p2 , ( p3 , ( p4 , ( p5 , p6 ) ) ) ) ) ← g @ p ; c2" :=
    (gate g p (fun x => let (p1,y) := wproj x in
                       let (p2,z) := wproj y in
                       let (p3,a) := wproj z in
                       let (p4,b) := wproj a in
                       let (p5,p6) := wproj b in c2))
                            (at level 12, right associativity) : circ_scope.

Notation lift_circ x c0 c := (compose c0 (fun p => lift p (fun x => c))).
Notation "'lift_' x ← c0 ; c" := (lift_circ x c0 c) 
         (at level 12, right associativity) : circ_scope.

Notation "'lift_' ( x , y ) ← c0 ; c" := (compose c0 (fun p => 
            letpair p1 p2 p (lift_circ x p1 (lift_circ y p2 c))))
         (at level 12, right associativity) : circ_scope.

Notation "'discard_' p ; c" := (gate discard p (fun _ => c))
         (at level 12, right associativity) : circ_scope.
Notation "'discard_' ( p1 , p2 ) ; c" := (gate discard p1 (fun _ => gate discard p2 
                                                                      (fun _ => c)))
         (at level 12, right associativity) : circ_scope.
Notation "'discard_' ( p1 , p2 , p3 ) ; c" := (gate discard p1 
                                                 (fun _ => gate discard p2 
                                                   (fun _ => gate discard p3 
                                                     (fun _ => c))))
         (at level 12, right associativity) : circ_scope.
Notation "'discard_' ( ( p1 , p2 ) , p3 ) ; c" := (gate discard p1 
                                                 (fun _ => gate discard p2 
                                                   (fun _ => gate discard p3 
                                                     (fun _ => c))))
         (at level 12, right associativity) : circ_scope.
Notation "'discard_' ( p1 , ( p2 , p3 ) ) ; c" := (gate discard p1 
                                                 (fun _ => gate discard p2 
                                                   (fun _ => gate discard p3 
                                                     (fun _ => c))))
         (at level 12, right associativity) : circ_scope.
Notation "'discard_' ( ( p1 , p2 ) , ( p3 , p4 ) ) ; c" :=
  (gate discard p1 
        (fun _ => gate discard p2 
                    (fun _ => gate discard p3 
                                (fun _ => gate discard p4 
                                            (fun _ => c)))))
         (at level 12, right associativity) : circ_scope.
Notation "'discard_' ( p1 , ( p2 , ( p3 , ( p4 , ( p5 , p6 ) ) ) ) ) ; c" :=
    (gate discard p1 (fun _ => gate discard p2 
                      (fun _ => gate discard p3
                      (fun _ => gate discard p4
                      (fun _ => gate discard p5
                      (fun _ => gate discard p6))))))
                            (at level 12, right associativity) : circ_scope.

Delimit Scope circ_scope with qc.

(* Automation *)

Ltac goal_has_evars := 
  match goal with 
  [|- ?G ] => has_evars G
  end.

Ltac invert_patterns := 
  repeat match goal with
  | [ p : Pat One |- _ ] => dependent destruction p
  | [ p : Pat Qubit |- _] => dependent destruction p
  | [ p : Pat Bit |- _] => dependent destruction p
  | [ p : Pat (_ ⊗ _) |- _ ] => dependent destruction p
  | [ H : Types_Pat ?Γ () |- _ ]           => is_var Γ; inversion H; subst
  | [ H : Types_Pat ?Γ (qubit _) |- _ ]    => is_var Γ; inversion H; subst
  | [ H : Types_Pat ?Γ (bit _)   |- _ ]    => is_var Γ; inversion H; subst
  | [ H : Types_Pat ?Γ (pair _ _) |- _ ]   => is_var Γ; dependent destruction H
  end.

Create HintDb typed_db.

Ltac type_check_once := 
  intros;
  try match goal with 
  | [|- Typed_Box _ ]           => solve [auto with typed_db] (* extensible *)
  | [|- @Typed_Box  ?W1 ?W2 ?c] => unfold Typed_Box in *; try unfold c
  end;
  intros;
  simpl in *;
  subst; 
  invert_patterns;
  repeat match goal with 
  (* Should break this down by case - in lift case, 
     need to choose bit or qubit as appropriate *)
  | [ b : bool |- _ ]              => destruct b 
  | [ H : _ == _ ∙ _ |- _ ]     => destruct H
  | [ |- @Types_Circuit _ _ _ ] => econstructor; type_check_once

  | [ |- @Types_Circuit _ _ (if ?b then _ else _) ]
                                => destruct b; type_check_once

  (* compose_typing : specify goal. *)                                  
  | [ |- @Types_Circuit _ _ _ ] =>  eapply compose_typing; type_check_once 

  | [ H : forall a b, Types_Pat _ _ -> Types_Circuit _ _ |- Types_Circuit _ _] 
                                => apply H; type_check_once

  | [ H : @Types_Pat _ _ ?p |- @Types_Pat _ _ ?p ] 
                                => exact H
  | [ H : @Types_Pat ?Γ1 _ ?p |- @Types_Pat ?Γ2 _ ?p ] 
                                   (* in case they don't line up exactly *)
                                => replace Γ2 with Γ1; [exact H | monoid]

  | [ |- Types_Pat _ _ ]        => econstructor; type_check_once
  | [ |- ?Γ == ?Γ1 ∙ ?Γ2 ]      => has_evars (Γ1 ⋓ Γ2 ⋓ Γ)
  | [ |- _ == _ ∙ _ ]           => solve_merge
  end; 
  (* Runs monoid iff a single evar appears in context *)
  match goal with 
  | [|- is_valid ?Γ] => tryif (has_evar Γ)   
                        then (idtac (*"can't validate"; print_goal*))
                        else (idtac (*"validate"; print_goal*); validate)
  | [|- ?G ]         => tryif (has_evars G)  
                        then (idtac (*"can't monoid"; print_goal*))
                        else (idtac (*"monoid"; print_goal*); monoid)
  end.

(* Useful for debugging *)
Ltac type_check_num := 
  let pre := numgoals in idtac "Goals before: " pre "";
  [> type_check_once..];
  let post := numgoals in idtac "Goals after: " post "";
  tryif (guard post < pre) then type_check_num else idtac "done".

(* Easiest solution *)

Ltac type_check := let n := numgoals in do n [> type_check_once..].

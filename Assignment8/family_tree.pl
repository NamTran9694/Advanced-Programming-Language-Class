/* ================================
   Family Tree in Prolog
   File: family_tree.pl
   ================================ */

% ---------
% Basic facts
% ---------

% male(Name).
male(robert).
male(john).
male(mark).
male(alex).
male(brian).
male(carl).

% female(Name).
female(helen).
female(susan).
female(linda).
female(alice).
female(diana).
female(emma).

% parent(Parent, Child).
% Grandparent generation
parent(robert, john).
parent(helen,  john).

parent(robert, susan).
parent(helen,  susan).

% Parent generation
parent(john,   alice).
parent(john,   brian).

parent(susan,  carl).
parent(susan,  diana).

% Another branch
parent(mark,   emma).
parent(linda,  emma).

/* ================================
   Derived Relationships (Rules)
   ================================ */

% father(Father, Child) :- Father is a male parent of Child.
father(Father, Child) :-
    parent(Father, Child),
    male(Father).

% mother(Mother, Child) :- Mother is a female parent of Child.
mother(Mother, Child) :-
    parent(Mother, Child),
    female(Mother).

% child(Child, Parent) :- Parent is a parent of Child.
child(Child, Parent) :-
    parent(Parent, Child).

% --------------------------------
% Grandparent – via two generations
% --------------------------------
% grandparent(GP, GC) :- GP is a grandparent of GC.
grandparent(GP, GC) :-
    parent(GP, P),
    parent(P, GC).

% grandchild(GC, GP) :- GC is a grandchild of GP.
grandchild(GC, GP) :-
    grandparent(GP, GC).

% --------------------------------
% Siblings – share at least one parent
% --------------------------------
% sibling(X, Y) :- X and Y share a parent and are not the same person.
sibling(X, Y) :-
    parent(P, X),
    parent(P, Y),
    X \= Y.

% Optional specializations
brother(Bro, Sibling) :-
    sibling(Bro, Sibling),
    male(Bro).

sister(Sis, Sibling) :-
    sibling(Sis, Sibling),
    female(Sis).

% --------------------------------
% Cousins – parents are siblings
% --------------------------------
% cousin(X, Y) :- X and Y have parents who are siblings.
cousin(X, Y) :-
    parent(P1, X),
    parent(P2, Y),
    sibling(P1, P2),
    X \= Y.

/* ================================
   Recursive Logic: Ancestor / Descendant
   ================================ */

% ancestor(Ancestor, Person) :-
%   Ancestor is a direct or indirect parent of Person.

% Base case: direct parent
ancestor(Ancestor, Person) :-
    parent(Ancestor, Person).

% Recursive case: parent of an ancestor
ancestor(Ancestor, Person) :-
    parent(Ancestor, X),
    ancestor(X, Person).

% descendant(Descendant, Person) :-
%   Descendant is a (direct or indirect) child of Person.
descendant(Descendant, Person) :-
    ancestor(Person, Descendant).

/* ================================
   Example Queries (for testing)
   ================================
   Load in SWI-Prolog:

   ?- [family_tree].

   1. Children of a particular person
      ?- child(Child, john).
      ?- parent(john, Child).

   2. Siblings of a particular person
      ?- sibling(alice, S).
      ?- brother(brian, S).
      ?- sister(Sis, carl).

   3. Grandparents / grandchildren
      ?- grandparent(GP, alice).
      ?- grandchild(GC, robert).

   4. Cousins
      ?- cousin(alice, carl).
      ?- cousin(brian, diana).

   5. All descendants of a person (recursive)
      ?- descendant(D, robert).
      ?- ancestor(robert, D).

   ================================ */


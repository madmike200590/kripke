world(a).
world(b).
true_in(p, a).
true_in(q, b).
w_r(a, b).

check_in(or(p, q), a).
check_in(and(p, q), a).
check_in(and(p, neg(q)), a).
check_in(and(neg(p), q), b).

% Every atom is a formula TODO complete these
formula(A) :- true_in(A, _).
% Every negated atom is a formula. (but limit recursion depth)
%formula(neg(A)) :- formula(A), A != neg(A1), formula(A1).

% Force top-down checking
check_in(P, W) :- check_in(or(P, Q), W).
check_in(Q, W) :- check_in(or(P, Q), W).
check_in(P, W) :- check_in(and(P, Q), W).
check_in(Q, W) :- check_in(and(P, Q), W).

% truth of negation and basic connectives
true_in(F, W) :- check_in(F, W), assigned_in(F, W).
true_in(F, W) :- check_in(F, W), F = neg(F1), world(W), formula(F1), not true_in(F1, W).
true_in(F, W) :- check_in(F, W), F = and(P, Q), world(W), formula(P), formula(Q), true_in(P, W), true_in(Q, W).
true_in(F, W) :- check_in(F, W), F = or(P, Q), world(W), formula(P), formula(Q), true_in(P, W).
true_in(F, W) :- check_in(F, W), F = or(P, Q), world(W), formula(P), formula(Q), true_in(Q, W).

#test basic_world(expect: > 0) {
    % simple frame with two worlds connected a -> b with p hoilding in a and q in b.
    given {
        world(a).
        world(b).
        assigned_in(p, a).
        assigned_in(q, b).
        w_r(a, b).

        check_in(or(p, q), a).
        check_in(and(p, q), a).
        check_in(and(p, neg(q)), a).
        check_in(and(neg(p), q), b).
    }
    assertForAll {
        :- not true_in(or(p, q), a).
    }
    assertForAll {
        :- true_in(and(p, q), a).
        :- true_in(and(p, q), b).
    }
    assertForAll {
        :- not true_in(and(p, neg(q)), a).
        :- not true_in(and(neg(p), q), b).
    }
}
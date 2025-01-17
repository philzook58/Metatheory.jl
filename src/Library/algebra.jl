commutativity(op) = :( ($op)(a, b) => ($op)(b, a) ) |> Rule
right_associative(op) = :( ($op)(a, $(op)(b,c)) => ($op)($(op)(a,b), c) ) |> Rule
left_associative(op) = :( ($op)($(op)(a,b), c) => ($op)(a, $(op)(b,c)) ) |> Rule

associativity(op) = [right_associative(op), left_associative(op)]

identity_left(op, id) = :( ($op)($id, a) => a ) |> Rule
identity_right(op, id) = :( ($op)(a, $id) => a ) |> Rule

inverse_left(op, id, invop) = :( ($op)(($invop)(a), a) => $id ) |> Rule
inverse_right(op, id, invop) = :( ($op)(a, ($invop)(a)) => $id ) |> Rule

function monoid(op, id)
	@assert Base.isbinaryoperator(op)
	[right_associative(op), left_associative(op), identity_left(op, id), identity_right(op,id)]
end
macro monoid(op, id) monoid(op, id) end


function commutative_monoid(op, id)
	@assert Base.isbinaryoperator(op)
	[commutativity(op), right_associative(op), identity_left(op, id)]
end
macro commutative_monoid(op, id) commutative_monoid(op, id) end

# constructs a semantic theory about a an abelian group
# The definition of a group does not require that a ⋅ b = b ⋅ a
# for all elements a and b in G. If this additional condition holds,
# then the operation is said to be commutative, and the group is called an abelian group.
function commutative_group(op, id, invop)
	@assert Base.isbinaryoperator(op)
	# @assert Base.isunaryoperator(invop)
	commutative_monoid(op, id) ∪ [inverse_right(op, id, invop)]
end
abelian_group(op, id, invop) = commutative_group(op, id, invop)
macro commutative_group(op, id, invop) commutative_group(op, id, invop) end
macro abelian_group(op, id, invop) commutative_group(op, id, invop) end

# distributivity of two operations
# example: `@distrib (⋅) (⊕)`
function distrib_left(outop, inop)
	@assert Base.isbinaryoperator(outop)
	@assert Base.isbinaryoperator(inop)
	:( ($outop)(a, ($inop)(b,c)) => ($inop)(($outop)(a,b),($outop)(a,c)) ) |> Rule
end

function distrib_right(outop, inop)
	@assert Base.isbinaryoperator(outop)
	@assert Base.isbinaryoperator(inop)
	:( ($outop)(($inop)(a,b), c) => ($inop)(($outop)(a,c),($outop)(b,c)) ) |> Rule
end

function rev_distrib_left(outop, inop)
	@assert Base.isbinaryoperator(outop)
	@assert Base.isbinaryoperator(inop)
	:( ($inop)(($outop)(a,b),($outop)(a,c)) => ($outop)(a, ($inop)(b,c)) ) |> Rule
end

function rev_distrib_right(outop, inop)
	@assert Base.isbinaryoperator(outop)
	@assert Base.isbinaryoperator(inop)
	:( ($inop)(($outop)(a,c),($outop)(b,c)) => ($outop)(($inop)(a,b), c) ) |> Rule
end


distrib(outop, inop) = [
	distrib_left(outop, inop), distrib_right(outop, inop),
	rev_distrib_left(outop, inop), rev_distrib_right(outop, inop),
]

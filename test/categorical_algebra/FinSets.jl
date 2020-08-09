module TestFinSets
using Test

using Catlab.Theories
using Catlab.CategoricalAlgebra.FreeDiagrams, Catlab.CategoricalAlgebra.Limits
using Catlab.CategoricalAlgebra.FinSets

# Category of finite ordinals
#############################

f = FinFunction([1,3,4], 5)
g = FinFunction([1,1,2,2,3], 3)
h = FinFunction([3,1,2], 3)

# Evaluation.
@test map(f, 1:3) == [1,3,4]
@test map(id(FinSet(3)), 1:3) == [1,2,3]
@test map(FinFunction(x -> (x % 3) + 1, 3, 3), 1:3) == [2,3,1]

# Composition and identities.
@test dom(f) == FinSet(3)
@test codom(f) == FinSet(5)
@test compose(f,g) == FinFunction([1,2,2], 3)
@test compose(g,h) == FinFunction([3,3,1,1,2], 3)
@test compose(compose(f,g),h) == compose(f,compose(g,h))
@test force(compose(id(dom(f)),f)) == f
@test force(compose(f,id(codom(f)))) == f

# Limits
########

# Terminal object.
@test ob(terminal(FinSet{Int})) == FinSet(1)

# Binary product.
lim = product(FinSet(2), FinSet(3))
@test ob(lim) == FinSet(6)
@test force(proj1(lim)) == FinFunction([1,2,1,2,1,2])
@test force(proj2(lim)) == FinFunction([1,1,2,2,3,3])

# N-ary product.
lim = product([FinSet(2), FinSet(3)])
@test ob(lim) == FinSet(6)
@test force.(legs(lim)) ==
  [FinFunction([1,2,1,2,1,2]), FinFunction([1,1,2,2,3,3])]
@test ob(product(FinSet{Int}[])) == FinSet(1)

# Equalizer.
f, g = FinFunction([1,2,3]), FinFunction([3,2,1])
@test incl(equalizer(f,g)) == FinFunction([2], 3)
@test incl(equalizer([f,g])) == FinFunction([2], 3)

# Equalizer in case of identical functions.
f = FinFunction([4,2,3,1], 5)
@test incl(equalizer(f,f)) == force(id(FinSet(4)))
@test incl(equalizer([f,f])) == force(id(FinSet(4)))

# Equalizer matching nothing.
f, g = id(FinSet(5)), FinFunction([2,3,4,5,1], 5)
@test incl(equalizer(f,g)) == FinFunction(Int[], 5)
@test incl(equalizer([f,g])) == FinFunction(Int[], 5)

# Pullback.
lim = pullback(FinFunction([1,1,3,2],4), FinFunction([1,1,4,2],4))
@test ob(lim) == FinSet(5)
@test force(proj1(lim)) == FinFunction([1,2,1,2,4], 4)
@test force(proj2(lim)) == FinFunction([1,1,2,2,4], 4)

# Pullback from a singleton set: the degenerate case of a product.
lim = pullback(FinFunction([1,1]), FinFunction([1,1,1]))
@test ob(lim) == FinSet(6)
@test force(proj1(lim)) == FinFunction([1,2,1,2,1,2])
@test force(proj2(lim)) == FinFunction([1,1,2,2,3,3])

# Pullback using generic limit interface
f, g = FinFunction([1,1,3,2],4), FinFunction([1,1,4,2],4)
lim = limit(FreeDiagram([FinSet(4),FinSet(4),FinSet(4)], [(1,3,f),(2,3,g)]))
@test ob(lim) == FinSet(5)
@test force.(legs(lim)[1:2]) ==
  [FinFunction([1,2,1,2,4],4), FinFunction([1,1,2,2,4],4)]

# Colimits
##########

# Initial object.
@test ob(initial(FinSet{Int})) == FinSet(0)

# Binary coproduct.
colim = coproduct(FinSet(2), FinSet(3))
@test ob(colim) == FinSet(5)
@test coproj1(colim) == FinFunction([1,2], 5)
@test coproj2(colim) == FinFunction([3,4,5], 5)

# N-ary coproduct.
colim = coproduct([FinSet(2), FinSet(3)])
@test ob(colim) == FinSet(5)
@test legs(colim) == [FinFunction([1,2], 5), FinFunction([3,4,5], 5)]
@test ob(coproduct(FinSet{Int}[])) == FinSet(0)

# Coequalizer from a singleton set.
f, g = FinFunction([1], 3), FinFunction([3], 3)
@test proj(coequalizer(f,g)) == FinFunction([1,2,1], 2)
@test proj(coequalizer([f,g])) == FinFunction([1,2,1], 2)

# Coequalizer in case of identical functions.
f = FinFunction([4,2,3,1], 5)
@test proj(coequalizer(f,f)) == force(id(FinSet(5)))
@test proj(coequalizer([f,f])) == force(id(FinSet(5)))

# Coequalizer identifying everything.
f, g = id(FinSet(5)), FinFunction([2,3,4,5,1], 5)
@test proj(coequalizer(f,g)) == FinFunction(repeat([1],5))
@test proj(coequalizer([f,g])) == FinFunction(repeat([1],5))

# Pushout from the empty set: the degenerate case of the coproduct.
f, g = FinFunction(Int[], 2), FinFunction(Int[], 3)
colim = pushout(f,g)
@test ob(colim) == FinSet(5)
@test coproj1(colim) == FinFunction([1,2], 5)
@test coproj2(colim) == FinFunction([3,4,5], 5)

# Pushout from a singleton set.
f, g = FinFunction([1], 2), FinFunction([2], 3)
colim = pushout(f,g)
@test ob(colim) == FinSet(4)
h, k = colim
@test compose(f,h) == compose(g,k)
@test h == FinFunction([1,2], 4)
@test k == FinFunction([3,1,4], 4)

# Same thing with generic colimit interface
diag = FreeDiagram([FinSet(1),FinSet(2),FinSet(3)],[(1,2,f), (1,3,g)])
colim = colimit(diag)
@test ob(colim) == FinSet(4)
_, h, k = colim
@test compose(f,h) == compose(g,k)
@test h == FinFunction([1,2], 4)
@test k == FinFunction([3,1,4], 4)

# Pushout from a two-element set, with non-injective legs.
f, g = FinFunction([1,1], 2), FinFunction([1,2], 2)
colim = pushout(f,g)
@test ob(colim) == FinSet(2)
h, k = colim
@test compose(f,h) == compose(g,k)
@test h == FinFunction([1,2], 2)
@test k == FinFunction([1,1], 2)

# Same thing with generic colimit interface
diag = FreeDiagram([FinSet(2),FinSet(2),FinSet(2)],[(1,2,f),(1,3,g)])
colim = colimit(diag)
@test ob(colim) == FinSet(2)
_, h, k = colim
@test compose(f,h) == compose(g,k)
@test h == FinFunction([1,2], 2)
@test k == FinFunction([1,1], 2)

end

import numpy as np
from functools import partial
from deap import gp

################################################################
# Primitive sets: your GP “vocabulary”
# A primitive set lists the operators (primitives) and
# terminals (inputs + ephemeral constants) that trees may use.
################################################################

# 1) Create the primitive set with N inputs (x0..xN-1)
n_inputs = 5
pset = gp.PrimitiveSet("MAIN", n_inputs)

# 2) Add primitives (ops). Each has an arity (unary=1, binary=2).
def div_safe(a, b, eps=1e-8):
    b2 = np.where(np.abs(b) < eps, eps, b)
    return a / b2

pset.addPrimitive(np.add, 2, name="add")
pset.addPrimitive(np.subtract, 2, name="sub")
pset.addPrimitive(np.multiply, 2, name="mul")
pset.addPrimitive(div_safe, 2, name="div_safe")

def log1p_safe(x, clip_min=-0.999999):
    return np.log1p(np.clip(x, clip_min, None))

pset.addPrimitive(log1p_safe, 1, name="log1p_safe")

# 3) Add an ephemeral constant: a random scalar terminal created per node
pset.addEphemeralConstant("rand", partial(np.random.uniform, -1.0, 1.0))

# 4) Rename ARG0.. to x0.. for readability
for i in range(n_inputs):
    pset.renameArguments(**{f"ARG{i}": f"x{i}"})



################################################################
# Trees → functions with gp.compile
# Trees are symbolic expressions over x0.. and rand.gp.compile
# turns a tree into a callable.
################################################################

from deap import base, creator, tools

# Fitness = maximize (we'll use correlation/size penalty later)
if not hasattr(creator, "FitnessMax"):
    creator.create("FitnessMax", base.Fitness, weights=(1.0,))
if not hasattr(creator, "Individual"):
    creator.create("Individual", gp.PrimitiveTree, fitness=creator.FitnessMax)

toolbox = base.Toolbox()
toolbox.register("expr", gp.genHalfAndHalf, pset=pset, min_=1, max_=3)
toolbox.register("individual", tools.initIterate, creator.Individual, toolbox.expr)
toolbox.register("population", tools.initRepeat, list, toolbox.individual)

# Compile builds a Python function f(x0,...,xN-1) from a tree
toolbox.register("compile", gp.compile, pset=pset)

# Example: make an individual and evaluate on data
ind = toolbox.individual()
func = toolbox.compile(ind)

# Vectorized evaluation (NumPy broadcasting)
X = np.random.randn(100, n_inputs)
cols = [X[:, i] for i in range(n_inputs)]
y_new_feature = func(*cols)  # shape (100,)



################################################################
# Ephemeral constants (ERCs)
# ERCs are random numeric terminals sampled when a node is
# created/mutated—great for coefficients/exponents.
################################################################
# Already registered above:
# pset.addEphemeralConstant("rand", partial(np.random.uniform, -1.0, 1.0))
#
# When the GP generator picks a 'rand' terminal, it calls the factory once,
# and the sampled number becomes a literal in the tree/function.
# Example within a tree: mul(x3, 0.42) or pow(abs(x1), -1.7)



################################################################
# Populations, tournaments, crossover, mutation, elitism
# A GP run evolves a population of trees across generations
# using selection, crossover, mutation, and elitism.
################################################################

import copy
from deap import tools

# Register evaluation (example: correlation with y minus size penalty)
def evaluate(individual, X, y):
    func = toolbox.compile(individual)
    cols = [X[:, i] for i in range(X.shape[1])]
    with np.errstate(divide="ignore", invalid="ignore", over="ignore", under="ignore"):
        f = func(*cols)
    f = np.nan_to_num(f, nan=0.0, posinf=0.0, neginf=0.0)
    # Pearson corr (absolute), penalize larger trees
    f_centered = f - f.mean()
    y_centered = y - y.mean()
    num = np.dot(f_centered, y_centered)
    den = (np.linalg.norm(f_centered) * np.linalg.norm(y_centered) + 1e-12)
    corr = 0.0 if den == 0 else num / den
    fitness = abs(corr) - 0.001 * len(individual)
    return (float(fitness),)

toolbox.register("evaluate", evaluate, X=X, y=np.random.randn(100))
toolbox.register("select", tools.selTournament, tournsize=3)
toolbox.register("mate", gp.cxOnePoint)
toolbox.register("expr_mut", gp.genHalfAndHalf, min_=0, max_=5, pset=pset)
toolbox.register("mutate", gp.mutUniform, expr=toolbox.expr_mut, pset=pset)
toolbox.register("clone", copy.deepcopy)

# Create population and Hall of Fame
pop = toolbox.population(n=60)
hof = tools.HallOfFame(maxsize=1)

rng = np.random.RandomState(42)
elite = 1
generations = 10

# Evolutionary loop with protected elites and randomized pairings
for gen in range(generations):
    # Selection (keep elites + tournament for the rest)
    offspring = tools.selBest(pop, elite) + toolbox.select(pop, len(pop) - elite)
    offspring = list(map(toolbox.clone, offspring))

    # Randomized pairings among non-elites
    start = elite
    idx = np.arange(start, len(offspring))
    rng.shuffle(idx)
    pairs = list(zip(idx[::2], idx[1::2]))

    # Crossover
    for a, b in pairs:
        if rng.rand() < 0.6:  # cx_prob
            gp.cxOnePoint(offspring[a], offspring[b])
            del offspring[a].fitness.values
            del offspring[b].fitness.values

    # Mutation
    for i in range(start, len(offspring)):
        if rng.rand() < 0.3:  # mut_prob
            toolbox.mutate(offspring[i])
            del offspring[i].fitness.values

    # Evaluate new/changed individuals
    invalid = [ind for ind in offspring if not ind.fitness.valid]
    for ind in invalid:
        ind.fitness.values = toolbox.evaluate(ind)

    # Update population and Hall of Fame
    pop[:] = offspring
    hof.update(pop)

best = hof[0]
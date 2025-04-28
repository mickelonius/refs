# Objective of a Decision-making Agent
> To maximize return or (un)discounted sum of rewards, $G_t$
> 
> $$G_t=\sum^{\infty}_{k=0}{\gamma^k R_{t+k+1}}$$
> where $R_t$ is the reward at time $t$ and $\gamma$ is the 
> discount factor

# _State-Value_ function
Policies are per-state action prescriptions. Also referred to as _V-function_ States have values when
following a policy, $\pi$:
$$
\begin{align}
& v_{\pi}(s)=\mathbb{E}_{\pi}[G_t \mid S_t=s] \\
& v_{\pi}(s)=\mathbb{E}_{\pi}[R_{t+1}+\gamma R_{t+2}+\gamma^2R_{t+3}+\cdots \mid S_t=s] \\
& v_{\pi}(s)=\mathbb{E}_{\pi}[R_{t+1} + \gamma G+{t+1} \mid S_t=s] \\
\end{align}
$$
where $v_{\pi}(s)$ is the _State-Value_ function, or the value of state $s$ following policy $\pi$.

If we take into account the set of actions $a \in A$, we have the Bellman equation 
for the _State-Value_ function:
$$
v_{\pi}(s)=\sum_{a}{\pi(a \mid s)}\sum_{s^{\prime},r}{p({s^{\prime},r} \mid {s,a})[r+\gamma v_{\pi}(s^{\prime})]},\forall{a} \in A 
$$
where
* $\gamma v_{\pi}(s^{\prime})$ is the discounted value of $s^{\prime}$ added to the reward for same, $r$
* $c$ the probability of the transition from $s$ to $s^{\prime}$ by 
taking action $a$ and receiving reward $r$
* $\pi(a \mid s)$ is policy that dictates action $a$ from state $s$, which is evaluated over all states
i.e. $\forall{a} \in A$ 

Note the value of a state depends recursively on the value of possibly many
other states, which values may also depend on others, including the original state! There are 
algorithms that can iteratively solve these equations and obtain the
state-value function of any policy or any environment.

# _Action-Value_ function
The action-value function, also known as _Q-function_ or
$Q^{\pi}(s,a)$, captures precisely this: the expected return if the agent follows policy $\pi$ after taking
action $a$ in state $s$.
$$
\begin{align}
& q_{\pi}(s,a)=\mathbb{E}_{\pi}[G_t \mid S_t=s,A_t=a] \\
& q_{\pi}(s,a)=\mathbb{E}_{\pi}[R_{t+1}+\gamma R_{t+2}+\gamma^2R_{t+3}+\cdots \mid S_t=s],A_t=a \\
\end{align}
$$
The value of action $a$ in state $s$ under policy $\pi$ is the expectation of returns, 
given we select action $a$ in state $s$ and follow policy $\pi$ thereafter. Expanding that, we
get the Bellman equation again:
$$
q_{\pi}(s,a) = \sum_{s', r} p(s', r \mid s, a) \left[ r + \gamma v_{\pi}(s') \right], \quad a \in A,\ \forall s \in S
$$

# _Action-Advantage_ function
The _Action-Advantage_ function, _A-function_, or $A^{\pi}(s, a)$, is the difference between 
the _Action-Value_ function of action $a$ in state $s$ and the _State-Value_ function of 
state $s$ under policy $\pi$:
$$
a_{\pi}(s,a)=q_{\pi}(s,a)-v_{\pi}(s)
$$
which describes how much better it is to take action $a$ instead of following
policy $\pi$: the advantage of choosing action $a$ over the default action

# Optimality
## _State-Value_ or _V-function_
$$
\begin{align}
v_*(s) &= \max_{\pi} v_{\pi}(s) \\
v_*(s) &= \max_{a} \sum_{s', r} p(s', r \mid s, a) \left[ r + \gamma v_*(s') \right]
\end{align}
$$

## _Action-Value_ function or _Q-function_
$$
\begin{align}
q_*(s,a) &= \max_{\pi} q_{\pi}(s,a), \in A,\forall{s} \in S  \\
q_*(s,a) &= \sum_{s', r} p(s', r \mid s, a) \left[ r + \gamma \max_{a^{\prime}}q_*(s',a^{\prime}) \right]
\end{align}
$$

## Policy Evaluation
Iteratively evaluate _State-Value_ function of policy under evaluation:
$$
\begin{align}  
v_{k+1}(s)=\sum_a{\pi(a \mid s)}\sum_{s',r}{ \left[ r + \gamma v_k(s') \right]} \\
\end{align}
$$
The algorithm converges as $k \to \infty$.Initialize $v_0(s)$ to $0$ if terminal state
and arbitrarily if non-terminal. Then, iterate over $k$ 
until $\left|v_{k}-v_{k-1} \right|<T$, where $T$ is an appropriate threshold.

## Policy Improvement
Using _State-Value_ or _V-Function_ and Markov Decision Process ($p(s', r \mid s, a)$),
we can get an estimate of the _Action-Value_ function or _Q-function_ 
$$
\DeclareMathOperator*{\argmax}{arg\,max}
\pi'(s)=\argmax_a{\sum_{s',r}{p(s', r \mid s, a)\left[ r + \gamma v_{\pi}(s') \right]}}
$$
To improve a policy, we use a _State-Value_ function and an MDP to get a 
one-step look-ahead and determine which of the actions lead to the highest
value. We obtain a new policy $\pi'$ by taking the highest-valued action (${\arg\max}_a$)

# Policy iteration: Improving upon improved behaviors
The plan with this adversarial policy is to alternate between policy evaluation and policy
improvement until the policy coming out of the policy-improvement phase no longer yields
a different policy.

# Value iteration: Improving behaviors early
With the policy evaluation/improvement iteration, things work/converge, but slowly, bc 
the Policy Evaluation has to be iterated to convergence every step. There are improvments even with 
just $k=1$ iteration.

Instead of iterating every policy evaluation to $k \to \infty$ on every step until the 
optimal policy becomes stable, we can run policy evaluation for one iteration and use 
that to feed to policy improvment every step.

In fact, with this method, we don't even need to deal with policies at all,
we just iterate the _V_ and policyless _Q_ functions to get the optimal set of actions per state:

$$
\begin{align}
v_{k+1}(s) &= \max_a(q(s,a)) \\
v_{k+1}(s) &= \max_a{\underbrace{\sum_{s',r}{p(s', r \mid s, a) \left[ r + \gamma v_k(s') \right]}}_{q(s,a)}} \\
\end{align}
$$

We only have to keep track of a V-function and a Q-function and to get the greedy policy over a 
Q-function, we take the arguments of the maxima (argmax) over the actions of that Q-function. 
Instead of improving the policy by taking the argmax to get a better policy and then evaluating 
this improved policy to obtain a value function again, we directly calculate the maximum 
(max, instead of argmax) value across the actions to be used for the next sweep over the states.
[Mistakes to avoid in a data science interview](#Mistakes to avoid in a data science interview)

[Five Tricky Statistics and Probability Riddles](#Five Tricky Statistics and Probability Riddles) 


------
# Mistakes to avoid in a data science interview
See https://towardsdatascience.com/mistakes-to-avoid-in-the-data-science-interview-7a79308872be 
for more details

### 1. GitHub repositories without or incomplete README.md

   Some suggestions:
   * Introduction about the problem you are trying to solve
   * The source of the dataset
   * If the data is scraped, how did you do that?
   * What baseline models were considered or used? (more on this later)?
   * What algorithms are used? What results are achieved?
   * How to reproduce the results?
   * If the app requires Docker, how to run the container?
   * If the app is deployed, a link to the app (Bonus)
### 2. Broken hyperlinks on the resume!
### 3. Your Machine Learning model is not deployed
   Shows
   * You are aware of the technologies/platforms like Docker, AWS, or Heroku
   * You can showcase your creativity with Streamlit or Gradio
   * You have the zeal to learn and implement end-to-end solutions

### 4. Jumping straight to State-of-the-Art (SOTA) Deep Learning in personal projects
### 5. Not practicing Python/Data Structures and Algorithms questions
Even though this is one of the most common questions in the interview — tell me something about this project? Many candidates spend more time on the project introduction and the metrics but a very few talk about the impact and the challenges they overcame!
    
This is one of the most important questions that can help you

To drive the interview discussion in your favor
* Showcase your area of expertise
* Showcase your communication and storytelling skills

So, an ideal answer the interviewer expects you to share is:
* Initial background of the business problem you are trying to solve
* Who are the end-users of this solution? How are they consuming the model predictions?
* Source of the data
* Preprocessing steps
* Baseline models and other experiments
* Metrics used for evaluation
* Model deployment and challenges

  I highly encourage the readers to write down and practice the answers to the common questions. It will make you feel comfortable answering the questions in the interviews. 

### 7. Not building a strong foundations of the basics

------ 
# Five Tricky Statistics and Probability Riddles
That 90% of People Fail
See https://towardsdatascience.com/five-tricky-statistics-and-probability-riddles-that-90-of-people-fail-77db1eda2e15

## Birthday Problem
Riddle: How many random people need to be in the same room for there to be
a 99.95% chance that two people have the same birthday?

A: 75
B: 183
C: 365
D: 500
## Two Problem Child
Riddle: Suppose a family has two children and we know that one of them
is a boy. What is the probability that the family has two boys?
## Monty Hall Problem
Riddle: Suppose you’re at a game show and there are 3 closed doors. Behind one of them is a car and behind the other two are goats. Consider the following scenario:

1. You pick door #1. 
2. The game show host looks at doors #2 and #3 and opens the one with a goat. If both of them have a goat, he chooses one randomly.
3. After opening one door with a goat, the game show host gives you the option of switching to the other door or sticking with your original guess.

Should you switch doors or not?
## Maximizing Odds with Marbles
Riddle: Suppose you are sentenced to death, but the king offers you a chance to live if you beat him in the following game:

1. Suppose you’re given 50 red marbles, 50 blue marbles, and 2 empty bowls. 
2. Your goal is to divide the 100 marbles into the 2 bowls in any way you like as long as you use all the marbles. 
3. Then, one random bowl will be selected, and then one random marble will be chosen from the selected bowl. If the marble
is blue you live, but if the marble is red, you die.

How should you divide the marbles up so that you have the greatest probability of choosing a BLUE marble?
## Multi-colored Card Deck
Riddle: Suppose you have 40 cards with four different colors. Specifically, there’s 10 pick cards, 10 orange Cards, 
10 green cards, and 10 purple cards. The cards of each color are numbered from one to ten. Two cards are picked at 
random. What is the probability that the two cards picked are not of the same number or same color?





















ANSWERS
1) A: 75
In order to understand why the answer is A: 75, you first need to understand two fundamental statistics principles:

Combinations
Combinations are defined as the number of different ways you can choose r out of n objects where order doesn’t matter. This is important because we want to know the possible number of unique pairs (combinations) for a given number of people. This can be calculated with the following equation:


Image created by Author
Basic Properties of Probability
There are several properties of probability, but for this question, we’re particularly interested in one of them, the complementary rule:


Image created by Author
If A is an event in a set, then the probability of A not happening is equal to 1 minus the probability of A occurring.

Why the answer is A: 75
Now that you understand these two concepts, we can dive into the answer.

The probability of two people having different birthdays is 364/365. This makes sense because there’s a 1/365 chance that the second person has the same birthday as the first person. We can re-word this and say that the probability that one pair of people have the same birthday is 364/365.

With 75 people, there are 2775 unique pairs (combinations) of people. This is calculated using the equation discussed earlier:


Image created by Author
Now that we know the probability of one pair of people having the same birthday, and we know the number of unique pairs that 75 people creates is 2775, we can calculate the probability of all 2775 pairs having different birthdays:


Image created by Author
The equation above tells us that the probability of all pairs having different birthdays is 0.05%.

Using the complementary rule, this is the equivalent of saying that there is a 1–0.05% chance, or 99.95% chance, that at least one of the pairs will have the same birthday.

Therefore the answer is 75 people.

2) 1/3
In order to understand why the answer is 1/3, you first need to understand a couple of concepts: universal set and sample spaces.

Universal Set
The universal set represents the set of all possible events (or outcomes) that can possibly occur in a given scenario. For example, the universal set for rolling a single dye is = {1,2,3,4,5,6}.

Sample space
The sample space is a subset of the universal set that considers all possible outcomes given a set of constraints.

Conditional probability
Conditional probability simply represents the probability that one event (A) occurs given that another event (B) already occurred. It is denoted as P(A|B).

Going back to the question, the universal set is made up of the following four possibilities of gender combinations:

Boy and Boy
Girl and Girl
Boy and Girl
Girl and Boy
Since we know that one of them is a boy, then our sample space is made up of three possibilities:

Boy and Boy
Boy and Girl
Girl and Boy
Now we can calculate the conditional probability that the second child is a boy given that one of them is already a boy. Since there’s only one possibility here where both children are boys, the probability is 1/3.

3) Yes, you should always switch doors.
This can be explained by looking at the set of all possibilities, aka, the universal set:


Image created by Author
This table shows what happens in every possible scenario based on which door you choose, which door the prize door is, and whether you switch doors or not.

Notice that when you switch doors, you win 6 of the 9 possible scenarios, which equals 2/3.

Therefore you should always switch doors.

4) Place 1 blue marble in one bowl, and the other 99 marbles in the other bowl.
Since there are several possibilities that we have to take into consideration, our goal is to maximize the expected value of choosing a blue marble. The expected value is defined as the sum of all possible values multiplied by the probability of it occurring.

The expected value of choosing a blue marble can be written in the following equation:

prob of choosing bowl 1 * prob of choosing a blue marble in bowl 1+
prob of choosing bowl 2 * prob of choosing a blue marble in bowl 2

Our goal is to maximize the equation above. Since the probability of choosing a given bowl is 50%, this simplifies to:

0.5 * probability of choosing a blue marble in bowl 1 +
0.5 * probability of choosing a blue marble in bowl 2

By placing 1 blue marble in one bowl and the other 99 marbles in the other bowl, you achieve the highest probability of 74.75%. You can test any other possible combination and would not achieve an expected probability as high as this.


Image created by Author
5. 69.2%
Suppose you have drawn the 1st card from the 40 cards. It has some color and some number.

We now have 39 cards, out of which 9 other cards would have the same color as the 1st card and 3 other cards would have the same number as the 1st card. This means that the probability that the second card has the same color or same number is equal to (9+3)/39 = 4/13.

By the complementary rule, this means that the probability that the second card doesn’t have the same color or the same number is equal to 1–4/13 = 0.692 or 69.2%




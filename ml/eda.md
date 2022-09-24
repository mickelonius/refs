My Secret Sauce to winning ML Hackathons: EDA & Feature Engineering
===================================================================

I recently participated in [MachineHack’s Wipro’s Sustainability Machine Learning Challenge](https://machinehack.com/hackathon/wipro_sustainability_machine_learning_challenge/overview), and achieved **2nd rank out of 1900** participants. This in itself was a surreal experience. Especially considering the approach I took to hack this “**time-series prediction**” hackathon.

The training dataset was pretty small (~175K records) and contained only 15 features. The ask was to build a prediction model to predict ‘**Clearsky DHI**’, ‘**Clearsky DNI**’, ‘**Clearsky GHI**’ for next one year, using the data for last 10 years (at an interval of every 30 mins).

Exploratory Data Analysis
=========================

I started off by deep-diving into the training dataset, trying to find better insights and to get myself familiar with this domain of solar power generation.

Below are some of the insights which really helped in boosting my score.

**Finding-1**

All target variables are 0 between 1AM to 9AM (just before sunrise). This was fascinating discovery, which meant that I can exclude all such records, as target value is already known for these.

![](https://miro.medium.com/max/1400/1*mWR-m0zw9GIPXle-2wvtww.png)

**Finding-2**

All target variables are 0 for Solar Zenith Angle >= 93 degrees. Another interesting discovery, which helped in reducing the training dataset size even further.

![](https://miro.medium.com/max/1400/1*G0Exumt64ks8KERtZOnY0g.png)

**Finding-3**

All target variables are highly correlated, and both DNI and GHI values are 0, when DHI = 0. I used this as a post-processing step, where anytime the model predicted DHI as 0, I defaulted the DNI and GHI also as 0.

![](https://miro.medium.com/max/1400/1*TxaChNrJFeExxLe8HBJ-GQ.png)

Feature Engineering
===================

Now that I had the EDA insights sorted out, I proceeded to engineering new features out of the existing ones.

**Date-Time Features**

I started off by deriving below date-time features.

*   Quarter
*   Week
*   DayofWeek
*   isWeekend
*   Season
*   Time Elapsed (since beginning of month)

Also I converted these into cyclical features using into sine and cosine transformations.

![](https://miro.medium.com/max/1100/1*jQtI4WPepIdyg9CKiFafdw.png)

**Interaction Features**

As next step, I generated various interaction features by taking multiplication and division of existing numerical features.

![](https://miro.medium.com/max/1400/1*_GGnUgzB1r5qg1WVmNmkZg.png)

**Lead-Lag Features**

Finally, I generated lead-lag features by shifting various input features by different time interval.

![](https://miro.medium.com/max/1400/1*RJeXhNYQHzyuh8-yj1N1Mg.png)![](https://miro.medium.com/max/1400/1*0ZoKRfNfG4lQvs5zHiqSjA.png)

ML Models Used
==============

EDA and feature engineering, if done correctly, is like winning 75% of the battle. Rest is picking and training models and hyperparameters search for the best model.

In this case, I went with the usual suspects, listed below.

*   CatBoost (my best performing model)
*   XGBoost
*   LightGBM

I took a weighted average of the model predictions and landed in 2nd position in the leaderboard.

_Ohh, but I forgot to mention one crucial point._

I never did time-series prediction here. But eliminating the records with target values already known, I essentially converted this into a simple regression problem. And that’s the beauty of machine learning. There’s no free lunch and there’s always more than one way to skin a cat. Lol!

Conclusion
==========

In essence, what I meant to say via this blog is, always try to think outside of box and rephrase any ML problem according to your liking and solve it accordingly.

If you want to refer my code for this hackathon, everything’s uploaded on [GitHub](https://github.com/analyticsindiamagazine/MachineHack/tree/master/Hackathon_Solutions/wipro_sustainability_machine_learning_challenge/Tapas_Das_Rank_2)

Also, a shameless plug that I can’t resist.

Meet the winners of Wipro's Sustainability Machine Learning Challenge
---------------------------------------------------------------------
### [Wipro's hiring hackathon - sustainability machine learning challenge - concluded on February 14, 2022. The hackathon…](https://analyticsindiamag.com/meet-the-winners-of-wipros-sustainability-machine-learning-challenge/)

Keep ML-ing!!

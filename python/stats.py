import seaborn as sns
import pandas as pd
from scipy import stats

df = pd.DataFrame.from_dict({
    "group1": [7, 14, 14, 13, 12, 9, 6, 14, 12, 8],
    "group2": [15, 17, 13, 15, 15, 13, 9, 12, 10, 8],
    "group3": [6, 8, 8, 9, 5, 14, 13, 8, 10, 9],
})
df_ = df.stack().reset_index()
df_ = df_.drop('level_0', axis=1)
df_ = df_.rename(columns={'level_1': 'group', 0: 'value'})
print(df_.head(10))

sns.set_theme(style="ticks", palette="pastel")
sns.boxplot(x="group", y="value",
            hue="group", palette=["m", "g"],
            data=df_)
sns.despine(offset=10, trim=True)


# Kruskal-Wallis Test
stats.kruskal(df['group1'], df['group2'], df['group3'])

"""
Interpret the results: (statistic=6.2878, pvalue=0.0431)

The Kruskal-Wallis Test uses the following null and alternative hypotheses:

--> The null hypothesis (H0): The median is equal across all groups.
--> The alternative hypothesis: (Ha): The median is not equal across all groups.

In this case, the test statistic is 6.2878 and the corresponding p-value is 0.0431. 
Since this p-value is less than 0.05, we can reject the null hypothesis that the median 
plant growth is the same for all three fertilizers. We have sufficient evidence to conclude 
that the type of fertilizer used leads to statistically significant differences in plant
growth.
"""




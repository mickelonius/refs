import multiprocessing
import numpy as np
import pandas as pd


def operate_on_df(dff):
    return dff.count()


df = pd.DataFrame
num_cores = multiprocessing.cpu_count()-1
df_split = np.array_split(df, num_cores)
pool = multiprocessing.Pool(num_cores)
df = pd.concat(pool.map(operate_on_df, df_split))
pool.close()
pool.join()
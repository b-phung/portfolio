import pandas as pd
import sys

zip = pd.read_csv("https://raw.githubusercontent.com/biodatascience/datasci611/gh-pages/data/project2_2019/EE_UDES_191102.tsv", sep='\t',
	usecols=['Client ID', 'EE UID', 'Zip Code (of Last Permanent Address, if known)(1932)'],
	na_values=['**'], header = 0) \
	.sort_values(['Client ID', 'EE UID'])
zip['ZC'] = zip[zip.columns[2]].str.slice(0,5)
zip = zip[zip.ZC.str.contains(r'\d{5}', na=False)]
del zip['Zip Code (of Last Permanent Address, if known)(1932)']
zip.to_csv("sys.argv[1]", index=False, header=True)
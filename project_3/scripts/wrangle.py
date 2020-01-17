import pandas as pd
import os

zip = pd.read_csv("https://raw.githubusercontent.com/biodatascience/datasci611/gh-pages/data/project2_2019/EE_UDES_191102.tsv", sep='\t',
	usecols=['Client ID', 'EE UID', 'Zip Code (of Last Permanent Address, if known)(1932)'],
	na_values=['**'], header = 0) \
	.sort_values(['Client ID', 'EE UID'])
zip['ZC'] = zip[zip.columns[2]].str.slice(0,5)
zip = zip[zip.ZC.str.contains(r'\d{5}', na=False)]
del zip['Zip Code (of Last Permanent Address, if known)(1932)']
zip_path = '../data/zip.csv'
zip_path = os.path.join(os.path.dirname(__file__), zip_path)
zip.to_csv(zip_path, index=False, header=True)


year = pd.read_csv("https://raw.githubusercontent.com/biodatascience/datasci611/gh-pages/data/project2_2019/ENTRY_EXIT_191102.tsv", sep='\t',
	usecols=['EE UID', 'Entry Date'])
year['year'] = year[year.columns[1]].str.slice(-4)
del year['Entry Date']
year_path = '../data/year.csv'
year_path = os.path.join(os.path.dirname(__file__), year_path)
year.to_csv(year_path, index=False, header=True)


hpi = pd.read_csv("https://raw.githubusercontent.com/datasci611/bios611-projects-fall-2019-b-phung/master/project_3/data/hpi.csv",
	converters={'Five-Digit ZIP Code': lambda x: str(x)},
	skiprows = 6, usecols=['Five-Digit ZIP Code', 'Year', 'HPI'])
hpi_path = '../data/hpi_wrangled.csv'
hpi_path = os.path.join(os.path.dirname(__file__), hpi_path)
hpi.to_csv(hpi_path, index=False, header=True)
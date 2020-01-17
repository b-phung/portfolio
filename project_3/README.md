# Where do UMD's clients come from?

As per their website, [Urban Ministries of Durham](http://www.umdurham.org/) is non-profit organization that provides food and shelter to those in need. They have provided the first two datasets in the table below. This project will also make use of HPI data from the Federal Housing Finance Agency (FHFA) and ZIP code polygon data from the US Census Bureau.

|Dataset|Source|Notes|
|---|---|---|
|ENTRY_EXIT_191102.tsv|[Link](https://raw.githubusercontent.com/biodatascience/datasci611/gh-pages/data/project2_2019/EE_UDES_191102.tsv)|From UMD. Contains last permanent ZIP codes of clients.|
|EE_UDES_191102.tsv|[Link](https://raw.githubusercontent.com/biodatascience/datasci611/gh-pages/data/project2_2019/ENTRY_EXIT_191102.tsv)|From UMD. Contains date of visit.|
|HPI_AT_BDL_ZIP5.xlsx| [Webpage](https://www.fhfa.gov/DataTools/Downloads/Pages/House-Price-Index-Datasets.aspx) [Link](https://www.fhfa.gov/DataTools/Downloads/Documents/HPI/HPI_AT_BDL_ZIP5.xlsx)|Converted to csv. Contains housing price indices per zipcode per year.
|cb_2018_us_zcta510_500k.zip|[Webpage](https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html) [Link](https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_zcta510_500k.zip)|Contains map polygon data for ZIP codes.

The first part of this project aims to explore the following questions:
* Which ZIP codes do the most clients come from?
* If there is any, what is the relationship between housing price index and visitor frequency?

The second part aims to plot this data out on a map of the Raleigh-Durham area.

  
To recreate all the output from a UNC VCL `base_datasci611` environment, run the following commands:
1. `git clone https://github.com/datasci611/bios611-projects-fall-2019-b-phung.git`
2. `cd bios611-projects-fall-2019-b-phung/project_3`
3. `make`

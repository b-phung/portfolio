# [Visualizing visits of a given client and against the unemployment rate](https://bphung.shinyapps.io/project_2/)

As per their website, [Urban Ministries of Durham](http://www.umdurham.org/) is non-profit organization that provides food and shelter to those in need.

The UMD_Services_Provided [data set](https://raw.githubusercontent.com/datasci611/bios611-projects-fall-2019-b-phung/master/project_2/data/UMD_Services_Provided_20190719.tsv) tracks when clients visit and the sort of assistance that was provided. It should be noted that some preliminary cleaning was done to remove what were presumably data entry errors with years before 1996 and after the date given in the name of the original .tsv file.

The goal of this project is to build a tool (link in the header) that allows the user to quickly visualize the visit history of a given client from the aforementioned data set. Additionally, since it seems logical to infer that visits to the shelter may trend with the (local) unemployment rate, that is given as well in another panel with the same horizontal axis of time. The [data for the unemployment rate](https://data.bls.gov/timeseries/LAUMT372050000000003?amp%253bdata_tool=XGtable&output_view=data&include_graphs=true) is sourced from the Bureau of Labor Statistics with the year range selected from 1996 to 2019, and manually exported to .csv format.

Note that since it may not be obvious which client ID to enter, the user is given a table listing all clients and summarizing some statistics about their visits, and an aggregate of the services they have been provided (as far as known). Sorting and searching this table may be used to answer questions such as "Which client has received the most bus tickets?" and "Which clients visited exactly 5 times?".

Considerations for future updates include:
* Is there a better way to browse through the list of clients? The original data set had upwards of 70,000 entries, and collating them by client has still left us with over 15,000 unique clients.
* Incorporate other macro trends in the vein of unemployment rate such as consumer price index, or housing prices in Durham.
* Look into: invalid values of `Client File Number` renders a generic error message when the dashboard is accessed on shinyapps instead of the intended message which specifies that the value is invalid. The intended messages shows when running locally.

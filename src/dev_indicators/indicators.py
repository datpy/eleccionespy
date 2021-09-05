import typing as t
import pandas as pd


class DevelopmentIndicators:

    __df: pd.DataFrame

    '''
    The columns in the dataframe composed by INDICATOR_NAME.
    '''
    __columns: t.List

    '''
    The value ith corresponds to the year for indicator in column ith.
    '''
    __columns_year: t.List

    '''
    After initializing the class, this dataframe contains all the development
    indicators for each department. The year of the selected indicator is
    stored in a different property of this class.

    See `__columns_year` and `__columns`.
    '''
    __df: pd.DataFrame

    def __init__(self, df: pd.DataFrame) -> None:
        """
        Converts a vertical datafame into an horizontal one while keeping only
        a single value for each indicator (the last year the indicator was
        collected).

        Examples
        -----
        The following dataframe:
        ```
        year  dep         depdes  indicator      value
        2017    0        CAPITAL  ECON_IMAP  4448000.0
        2017    1     CONCEPCION  ECON_IMAP  1619000.0
        2017    2      SAN PEDRO  ECON_IMAP  1862000.0
        2017    3     CORDILLERA  ECON_IMAP  1716000.0
        2017    4         GUAIRA  ECON_IMAP  1604000.0
         ...  ...            ...        ...        ...
        2012   14      CANINDEYU   PBRZ_NBI       55.2
        2012   15    PDTE. HAYES   PBRZ_NBI       67.8
        2012   16       BOQUERON   PBRZ_NBI       92.9
        2012   17  ALTO PARAGUAY   PBRZ_NBI       78.9
        2012  100           PAIS   PBRZ_NBI       43.0
        ```
        becomes
        ```
        dep         depdes  ECON_IMAP  PBRZ_NBI  PBRZ_PTOTL  SALU_PMNV10-19
          0        CAPITAL  4448000.0      22.5        11.6            11.1
          1     CONCEPCION  1619000.0      56.2        44.0            17.6
          2      SAN PEDRO  1862000.0      57.6        43.6            19.5
          3     CORDILLERA  1716000.0      43.4        26.9            15.2
          4         GUAIRA  1604000.0      54.9        33.9            15.3
          5       CAAGUAZU  2539000.0      53.7        43.7            17.2
          6        CAAZAPA  1441000.0      70.2        47.0            19.2
          7         ITAPUA  2123000.0      49.6        33.2            18.1
          8       MISIONES  2066000.0      42.4        27.5            16.1
          9      PARAGUARI  1632000.0      51.8        35.8            16.0
         10    ALTO PARANA  2729000.0      39.6        21.4            16.9
         11        CENTRAL  2500000.0      27.4        16.2            12.5
         12       ÑEEMBUCU  1926000.0      54.1        24.2            10.5
         13        AMAMBAY  2582000.0      48.3        15.2            17.4
         14      CANINDEYU  2532000.0      55.2        38.0            21.8
         15    PDTE. HAYES  2421000.0      67.8        28.5            22.9
         16       BOQUERON  4328000.0      92.9        21.5            20.1
         17  ALTO PARAGUAY  2079000.0      78.9        46.5            25.1
        ```
        """

        # Keep the last year the development indicator was collected.
        indicator_for_year = df.groupby(["indicator"])['year'] \
                               .max().reset_index()

        self.__columns = []
        self.__columns_year = []

        for i, row in indicator_for_year.iterrows():
            indicator = row['indicator']
            year = row["year"]
            self.__columns.append(indicator)
            self.__columns_year.append(year)

            query = (f"indicator == '{indicator}'"
                     f" & year == {year}")
            result = df.query(query)

            # Do not need this columns in merge's output.
            # The indicator is now the column name, while the year is stored in
            # __columns_year.
            del result["indicator"]
            del result["year"]

            # For the first indicator, just use it in its entirety.
            if i == 0:
                self.__df = result.rename(columns={"value": indicator})
                continue

            self.__df = self.__df.merge(
                result, how="right", on=["dep", "depdes"])
            self.__df = self.__df.rename(columns={"value": indicator})

    def to_dataframe(self) -> pd.DataFrame:
        return self.__df

    def get_columns(self) -> t.List:
        return self.__columns

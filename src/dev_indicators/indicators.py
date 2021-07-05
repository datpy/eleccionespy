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

import pandas as pd


class ElectoralRoll:

    __df: pd.DataFrame

    def __init__(self, df: pd.DataFrame):
        self.__df = df

    def voters_by_district(self, year) -> pd.DataFrame:
        df = self.__df[self.__df.anio == year]

        return df.groupby(["anio", "dep", "depdes", "disdes"]).agg({
            "eligible_voters": "sum"
        }).reset_index()

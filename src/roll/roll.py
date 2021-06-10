import pandas as pd


class ElectoralRoll:
    def __init__(self, df: pd.DataFrame):
        self.df = df

    def voters_by_district(self, year):
        df = self.df[self.df.anio == year]

        return df.groupby(["anio", "dep", "depdes", "disdes"]).agg({
            "eligible_voters": ["sum"]
        })

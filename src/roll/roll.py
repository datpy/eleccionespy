from pandas import DataFrame


class ElectoralRoll:
    def __init__(self, df: DataFrame):
        self.df = df

    def votersByDistrict(self, year):
        df = self.df[self.df.anio == year]
        return df.groupby(["anio", "dep", "depdes", "disdes"]).agg({
            "eligible_voters": ["sum"]
        })

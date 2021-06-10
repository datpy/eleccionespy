import pandas as pd


class Departmentwise:
    def share_per_department(self, results: pd.DataFrame) -> pd.DataFrame:
        """
        Returns a dataframe with share of votes obtained at each department.

        It expects the election results to be from a specific election year and
        for a specific party.

        Parameters
        ----------
        electionResults : Pandas dataframe
            Dataframe with results from a specific mayor election year for a
            particular party.
        """
        df = results.groupby(["dep", "depdes"]).agg({
            "votos": "sum",
            "total_votos": "sum",
        }).reset_index()

        df["vote_percent"] = df["votos"] / df["total_votos"] * 100

        return df

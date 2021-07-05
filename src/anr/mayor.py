from src.dev_indicators.indicators import DevelopmentIndicators
import matplotlib.pyplot as plt
import pandas as pd
import pathlib

from ..mayor import Mayor
from ..roll import ElectoralRoll
from ..graph import Grapher


class AnrMayor(Mayor):
    """
    AnrMayor handles statistics and graphs on ANR performance on mayor
    elections.
    """

    output_dir: pathlib.Path
    __mayor_results: pd.DataFrame
    __anr_mayor_results: pd.DataFrame
    __grapher: Grapher
    __roll: pd.DataFrame
    __dev_indicators: DevelopmentIndicators

    def __init__(
        self,
        grapher: Grapher,
        election_results: pd.DataFrame,
        roll: ElectoralRoll,
        dev_indicators: DevelopmentIndicators,
        output_dir: pathlib.Path,
    ):

        self.__grapher = grapher
        self.__dev_indicators = dev_indicators

        query = "cand_desc == 'INTENDENTE' & anio == 2015"
        self.__mayor_results = election_results.query(query)
        self.__anr_mayor_results = self.__mayor_results.query(
            "siglas_lista == 'ANR'"
        )
        self.output_dir = output_dir

        # Use electoral roll for the general elections as proxy for the local
        # ones.
        self.__roll = roll.voters_by_district(2018)

    def stats(self):
        share_per_dep = self.share_per_department(self.__anr_mayor_results)
        # self.__graph_results_vs_income(share_per_dep)
        # self.__graph_results_vs_poverty(share_per_dep)
        # self.__departmentwise_model(share_per_dep)

    def __departmentwise_model(self, share_per_dep: pd.DataFrame):
        """
        Creates a statistical model for datapoints at the department level.
        """

        # Gets electoral roll at the department level.
        df = self.__roll.groupby(["dep", "depdes"]).agg({
            "eligible_voters": "sum",
        }).reset_index()

        # share_per_dep includes votes for ANR, total votes, and vote share for
        # ANR.
        df = df.merge(share_per_dep, on=["dep", "depdes"])

        df["turnout"] = df["total_votos"] / df["eligible_voters"]
        print(df)

    def __graph_results_vs_income(self, share_per_dep: pd.DataFrame):
        title = "Porcentaje de votos vs. Promedio de ingresos"
        xlab = "Promedio de ingresos en 2017 (en millones de Gs.)"
        ylab = "Porcentaje de votos en 2015 (intendencia)"

        axes = \
            self.__grapher.make_vs_income_graph(
                share_per_dep, "vote_percent", title, xlab, ylab)

        plt.plot(axes)
        plt.savefig(
            self.output_dir.joinpath("2015-voteshare_per_dep-vs-income")
        )
        plt.close()

    def __graph_results_vs_poverty(self, share_per_dep: pd.DataFrame):
        title = "Porcentaje de votos vs. Porcentaje de pobreza total"
        xlab = "Porcentaje de personas en pobreza total"
        ylab = "Porcentaje de votos en 2015 (intendencia)"

        ax = \
            self.__grapher.make_vs_poverty_graph(
                share_per_dep, "vote_percent", title, xlab, ylab)

        plt.plot(ax)
        plt.savefig(
            self.output_dir.joinpath("2015-voteshare_per_dep-vs-poverty")
        )
        plt.close()

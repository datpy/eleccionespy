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

    def __init__(
        self,
        grapher: Grapher,
        election_results: pd.DataFrame,
        roll: ElectoralRoll,
        output_dir: pathlib.Path,
    ):

        self.grapher = grapher

        query = "cand_desc == 'INTENDENTE' & anio == 2015"
        self.mayor_results = election_results.query(query)
        self.anr_mayor_results = self.mayor_results.query(
            "siglas_lista == 'ANR'"
        )
        self.output_dir = output_dir

        # Use electoral roll for the general elections as proxy for the local
        # ones.
        self.roll = roll.voters_by_district(2018)

    def stats(self):
        share_per_dep = self.share_per_department(self.anr_mayor_results)
        self.graph_results_vs_income(share_per_dep)
        self.graph_results_vs_poverty(share_per_dep)

    def graph_results_vs_income(self, share_per_dep: pd.DataFrame):
        title = "Porcentaje de votos vs. Promedio de ingresos"
        xlab = "Promedio de ingresos en 2017 (en millones de Gs.)"
        ylab = "Porcentaje de votos en 2015 (intendencia)"

        axes = self.grapher.make_vs_income_graph(
                    share_per_dep,
                    "vote_percent",
                    title,
                    xlab,
                    ylab
                )

        plt.plot(axes)
        plt.savefig(
            self.output_dir.joinpath("2015-voteshare_per_dep-vs-income")
        )
        plt.close()

    def graph_results_vs_poverty(self, share_per_dep: pd.DataFrame):
        title = "Porcentaje de votos vs. Porcentaje de pobreza total"
        xlab = "Porcentaje de personas en pobreza total"
        ylab = "Porcentaje de votos en 2015 (intendencia)"

        ax = self.grapher.make_vs_poverty_graph(
                    share_per_dep,
                    "vote_percent",
                    title,
                    xlab,
                    ylab
                )

        plt.plot(ax)
        plt.savefig(
            self.output_dir.joinpath("2015-voteshare_per_dep-vs-poverty")
        )
        plt.close()

import matplotlib.pyplot as plt
import pandas as pd
import pathlib

from ..mayor import Mayor
from ..roll import ElectoralRoll
from ..graph import Grapher


class AnrMayor(Mayor):
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

        print(self.output_dir)

        # Use electoral roll for the general elections as proxy for the local
        # ones.
        self.roll = roll.voters_by_district(2018)

    def stats(self):
        self.graph_results_vs_income()
        # print(self.anrMayorResults)
        # print(self.roll)

    def graph_results_vs_income(self):
        df = super().share_per_department(self.anr_mayor_results)
        title = "Porcentaje de votos vs. Promedio de ingresos"
        xlab = "Promedio de ingresos en 2017 (en millones de Gs.)"
        ylab = "Porcentaje de votos en 2015 (intendencia)"

        axes = self.grapher.make_vs_income_graph(
                    df, "vote_percent", title, xlab, ylab, yticksuffix="%")

        plt.plot(axes)
        plt.savefig(
            self.output_dir.joinpath("2015-voteshare_per_dep-vs-income")
        )
